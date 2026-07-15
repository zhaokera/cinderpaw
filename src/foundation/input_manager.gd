## Input abstraction and tuning registration Autoload.
##
## ADR-0001 defines InputManager as Autoload #2, after DataManager.
## This Foundation system normalizes physical input into game actions without
## referencing Core gameplay systems.
extends Node

signal action_triggered(action_id: StringName, metadata: Dictionary)
signal device_changed(old: StringName, new: StringName)

enum InputState {
	DIRECT,
	BUFFERING,
	TRANSITIONING,
}

const ACTION_TYPE_TRIGGER: StringName = &"trigger"
const ACTION_TYPE_CONTINUOUS: StringName = &"continuous"
const MAX_COMBO_INDEX: int = 2
const DEVICE_GAMEPAD: StringName = &"gamepad"
const DEVICE_KBM: StringName = &"kbm"
const DEVICE_TOUCH: StringName = &"touch"

const ACTION_METADATA: Dictionary = {
	&"move_left": {"type": ACTION_TYPE_CONTINUOUS, "bufferable": false, "priority": 0},
	&"move_right": {"type": ACTION_TYPE_CONTINUOUS, "bufferable": false, "priority": 0},
	&"move_up": {"type": ACTION_TYPE_CONTINUOUS, "bufferable": false, "priority": 0},
	&"move_down": {"type": ACTION_TYPE_CONTINUOUS, "bufferable": false, "priority": 0},
	&"jump": {"type": ACTION_TYPE_TRIGGER, "bufferable": true, "priority": 50},
	&"dash": {"type": ACTION_TYPE_TRIGGER, "bufferable": true, "priority": 80},
	&"attack": {"type": ACTION_TYPE_TRIGGER, "bufferable": true, "priority": 60},
	&"heavy_attack": {"type": ACTION_TYPE_TRIGGER, "bufferable": true, "priority": 70},
	&"dodge": {"type": ACTION_TYPE_TRIGGER, "bufferable": true, "priority": 90},
	&"parry": {"type": ACTION_TYPE_TRIGGER, "bufferable": true, "priority": 100},
	&"interact": {"type": ACTION_TYPE_TRIGGER, "bufferable": false, "priority": 10},
	&"pause": {"type": ACTION_TYPE_TRIGGER, "bufferable": false, "priority": 1000},
}

const TUNING_DEFAULTS: Dictionary = {
	&"input.buffer_window_ms": {"type": &"int", "default": 150, "min": 80, "max": 250},
	&"input.buffer_queue_size": {"type": &"int", "default": 3, "min": 1, "max": 5},
	&"input.pre_input_window_ms": {"type": &"int", "default": 50, "min": 30, "max": 80},
	&"input.combo_chain_window_ms": {"type": &"int", "default": 300, "min": 200, "max": 500},
	&"input.coyote_frames": {"type": &"int", "default": 6, "min": 4, "max": 10},
	&"input.jump_buffer_frames": {"type": &"int", "default": 6, "min": 4, "max": 10},
	&"input.device_switch_debounce_ms": {"type": &"int", "default": 500, "min": 200, "max": 1000},
	&"input.priority_pre_input_bonus": {"type": &"int", "default": 20, "min": 0, "max": 40},
}

const DEVICE_PRIORITY: Dictionary = {
	DEVICE_TOUCH: 0,
	DEVICE_KBM: 1,
	DEVICE_GAMEPAD: 2,
}

var _active_data_manager: Variant = null
var _input_state: InputState = InputState.DIRECT
var _animation_unlock_time_ms: int = 0
var _press_started_ms: Dictionary = {}
var _buffered_inputs: Array[Dictionary] = []
var _combo_counter: int = 0
var _last_attack_consumed_ms: int = -1
var _current_device: StringName = DEVICE_KBM
var _last_device_switch_ms: int = -1
var _combat_input_locked: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	register_input_tuning_knobs(_find_data_manager())


func _process(_delta: float) -> void:
	_update_action_durations(Time.get_ticks_msec())


func _input(event: InputEvent) -> void:
	if _input_state != InputState.BUFFERING:
		return
	if event is InputEventKey and (event as InputEventKey).echo:
		return
	var now_ms: int = Time.get_ticks_msec()
	var source_device: StringName = classify_input_event(event)
	if source_device == &"":
		source_device = _current_device
	else:
		_try_switch_device(source_device, now_ms)
	var candidates: Array[StringName] = []
	for action: StringName in get_supported_actions():
		if _is_bufferable_action(action) and event.is_action_pressed(action):
			candidates.append(action)
	if candidates.is_empty():
		return
	if accept_actions(candidates, now_ms, source_device) <= 0:
		return
	var viewport: Viewport = get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()


## Returns all game actions normalized by InputManager.
func get_supported_actions() -> Array[StringName]:
	var actions: Array[StringName] = []
	for action_key: Variant in ACTION_METADATA.keys():
		actions.append(StringName(action_key))
	return actions


## Returns metadata for a known action, or an empty Dictionary for unknown input.
func get_action_metadata(action: StringName) -> Dictionary:
	if not ACTION_METADATA.has(action):
		return {}
	var metadata: Dictionary = ACTION_METADATA[action]
	return metadata.duplicate(true)


## Returns the current input FSM state.
func get_input_state() -> StringName:
	match _input_state:
		InputState.BUFFERING:
			return &"buffering"
		InputState.TRANSITIONING:
			return &"transitioning"
		_:
			return &"direct"


## Returns the number of currently buffered trigger inputs.
func get_buffered_action_count() -> int:
	return _buffered_inputs.size()


## Returns a snapshot of buffered trigger inputs for diagnostics and tests.
func get_buffered_actions() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for entry: Dictionary in _buffered_inputs:
		entries.append(entry.duplicate(true))
	return entries


## Accepts a normalized Trigger action for immediate dispatch or later buffering.
func accept_action(action: StringName, timestamp_ms: int = -1, source_device: StringName = &"kbm") -> bool:
	if not _is_trigger_action(action):
		return false
	var now_ms: int = _resolve_timestamp(timestamp_ms)
	if action == &"pause":
		_emit_action(action, _build_metadata(action, now_ms, source_device, 0))
		return true
	match _input_state:
		InputState.DIRECT:
			_emit_action(action, _build_metadata(action, now_ms, source_device, 0))
			return true
		InputState.BUFFERING:
			if not _is_bufferable_action(action):
				return false
			_buffer_action(action, now_ms, source_device)
			return true
		_:
			return false


## Accepts same-frame Trigger candidates after applying priority conflict rules.
func accept_actions(
	actions: Array,
	timestamp_ms: int = -1,
	source_device: StringName = &"kbm"
) -> int:
	var selected_action: StringName = _select_highest_priority_action(actions)
	if selected_action == &"":
		return 0
	var now_ms: int = _resolve_timestamp(timestamp_ms)
	if accept_action(selected_action, now_ms, source_device):
		return 1
	return 0


## Returns the current attack combo counter for diagnostics.
func get_combo_counter() -> int:
	return _combo_counter


## Returns the current dominant input device for prompt mapping.
func get_current_device() -> StringName:
	return _current_device


## Returns whether combat has locked device prompt switching.
func is_combat_input_locked() -> bool:
	return _combat_input_locked


## Enables or disables combat-time device switching suppression.
func set_combat_input_lock(is_locked: bool) -> void:
	_combat_input_locked = is_locked


## Classifies Godot input events into the supported device families.
func classify_input_event(event: InputEvent) -> StringName:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return DEVICE_GAMEPAD
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		return DEVICE_KBM
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		return DEVICE_TOUCH
	return &""


## Ingests an input event and switches the dominant device when allowed.
func ingest_input_event(event: InputEvent, timestamp_ms: int = -1) -> bool:
	var device: StringName = classify_input_event(event)
	if device == &"":
		return false
	return _try_switch_device(device, _resolve_timestamp(timestamp_ms))


## Handles explicit device disconnect notifications without referencing combat systems.
func notify_device_disconnected(device: StringName, timestamp_ms: int = -1) -> bool:
	if device != _current_device:
		return false
	if _combat_input_locked:
		return false
	if device == DEVICE_GAMEPAD:
		return _try_switch_device(DEVICE_KBM, _resolve_timestamp(timestamp_ms), true)
	return false


## Returns whether a jump remains valid after recently leaving ground.
func can_use_coyote_jump(frames_since_left_ground: int) -> bool:
	return _is_frame_count_within_tuning_window(
		frames_since_left_ground,
		&"input.coyote_frames",
		6
	)


## Returns whether a pre-landing jump press should be consumed on landing.
func should_consume_jump_buffer(frames_before_landing: int) -> bool:
	return _is_frame_count_within_tuning_window(
		frames_before_landing,
		&"input.jump_buffer_frames",
		6
	)


## Moves InputManager into BUFFERING mode for the caller's animation lock.
func notify_animation_lock(duration_ms: int, timestamp_ms: int = -1) -> void:
	if duration_ms <= 0:
		_input_state = InputState.DIRECT
		_animation_unlock_time_ms = 0
		return
	var now_ms: int = _resolve_timestamp(timestamp_ms)
	_prune_expired_buffered_inputs(now_ms)
	_input_state = InputState.BUFFERING
	_animation_unlock_time_ms = now_ms + duration_ms


## Ends the current animation lock, consumes one buffered input, and returns to DIRECT mode.
func notify_animation_unlock(timestamp_ms: int = -1) -> void:
	var now_ms: int = _resolve_timestamp(timestamp_ms)
	var buffered_input: Dictionary = _pop_highest_priority_buffered_input(now_ms)
	_input_state = InputState.DIRECT
	_animation_unlock_time_ms = 0
	if not buffered_input.is_empty():
		_emit_buffered_action(buffered_input, now_ms)


## Returns whether the action is currently pressed according to Godot InputMap.
func is_action_pressed(action: StringName) -> bool:
	if not _is_known_action(action):
		return false
	return Input.is_action_pressed(action)


## Returns whether the action was just pressed according to Godot InputMap.
func is_action_just_pressed(action: StringName) -> bool:
	if not _is_known_action(action):
		return false
	return Input.is_action_just_pressed(action)


## Returns a normalized action strength in the range 0.0..1.0.
func get_action_strength(action: StringName) -> float:
	if not _is_known_action(action):
		return 0.0
	return Input.get_action_strength(action)


## Returns how long the action has been pressed, in seconds.
func get_action_duration(action: StringName) -> float:
	if not _is_known_action(action) or not _press_started_ms.has(action):
		return 0.0
	var elapsed_ms: int = Time.get_ticks_msec() - int(_press_started_ms[action])
	return maxf(0.0, float(elapsed_ms) / 1000.0)


## Clears buffered trigger input state.
func clear_buffer() -> void:
	_buffered_inputs.clear()


## Registers all InputManager tuning knobs with DataManager.
func register_input_tuning_knobs(data_manager: Variant = null) -> bool:
	if data_manager == null or not data_manager.has_method("register_tuning"):
		return false
	_active_data_manager = data_manager
	for knob_key: Variant in TUNING_DEFAULTS.keys():
		var knob_id: StringName = StringName(knob_key)
		var config: Dictionary = TUNING_DEFAULTS[knob_id]
		data_manager.register_tuning(
			knob_id,
			config.get("type", &"int"),
			config.get("default", 0),
			config.get("min", 0),
			config.get("max", 0),
			&"input"
		)
	return true


## Returns an input tuning value, falling back to deterministic defaults.
func get_input_tuning(knob_id: StringName, fallback: Variant) -> Variant:
	if _active_data_manager != null and _active_data_manager.has_method("get_tuning"):
		return _active_data_manager.get_tuning(knob_id, _default_tuning_value(knob_id, fallback))
	return _default_tuning_value(knob_id, fallback)


func _is_known_action(action: StringName) -> bool:
	return ACTION_METADATA.has(action)


func _is_trigger_action(action: StringName) -> bool:
	if not ACTION_METADATA.has(action):
		return false
	var metadata: Dictionary = ACTION_METADATA[action]
	return metadata.get("type", &"") == ACTION_TYPE_TRIGGER


func _is_bufferable_action(action: StringName) -> bool:
	if not ACTION_METADATA.has(action):
		return false
	var metadata: Dictionary = ACTION_METADATA[action]
	return bool(metadata.get("bufferable", false))


func _action_priority(action: StringName) -> int:
	if not ACTION_METADATA.has(action):
		return 0
	var metadata: Dictionary = ACTION_METADATA[action]
	return int(metadata.get("priority", 0))


func _build_metadata(
	action: StringName,
	timestamp_ms: int,
	source_device: StringName,
	buffer_delay_ms: int,
	is_pre_input: bool = false,
	priority_override: int = -1,
	combo_timestamp_ms: int = -1
) -> Dictionary:
	var priority: int = priority_override
	if priority < 0:
		priority = _action_priority(action)
	var combo_time_ms: int = combo_timestamp_ms
	if combo_time_ms < 0:
		combo_time_ms = timestamp_ms
	return {
		"combo_index": _consume_combo_index(action, combo_time_ms),
		"is_pre_input": is_pre_input,
		"buffer_delay_ms": buffer_delay_ms,
		"priority": priority,
		"source_device": source_device,
		"timestamp_ms": timestamp_ms,
	}


func _emit_action(action: StringName, metadata: Dictionary) -> void:
	action_triggered.emit(action, metadata)


func _resolve_timestamp(timestamp_ms: int) -> int:
	if timestamp_ms >= 0:
		return timestamp_ms
	return Time.get_ticks_msec()


func _default_tuning_value(knob_id: StringName, fallback: Variant) -> Variant:
	if not TUNING_DEFAULTS.has(knob_id):
		return fallback
	var config: Dictionary = TUNING_DEFAULTS[knob_id]
	return config.get("default", fallback)


func _select_highest_priority_action(actions: Array) -> StringName:
	var selected_action: StringName = &""
	var selected_priority: int = -2147483648
	for action_value: Variant in actions:
		var action: StringName = StringName(action_value)
		if not _is_trigger_action(action):
			continue
		var priority: int = _action_priority(action)
		if selected_action == &"" or priority > selected_priority:
			selected_action = action
			selected_priority = priority
	return selected_action


func _consume_combo_index(action: StringName, consumed_timestamp_ms: int) -> int:
	if action != &"attack":
		return 0
	var combo_window_ms: int = int(get_input_tuning(&"input.combo_chain_window_ms", 300))
	if _last_attack_consumed_ms < 0:
		_combo_counter = 0
	elif consumed_timestamp_ms - _last_attack_consumed_ms > combo_window_ms:
		_combo_counter = 0
	else:
		_combo_counter = mini(_combo_counter + 1, MAX_COMBO_INDEX)
	_last_attack_consumed_ms = consumed_timestamp_ms
	return _combo_counter


func _is_frame_count_within_tuning_window(
	frame_count: int,
	knob_id: StringName,
	fallback: int
) -> bool:
	if frame_count < 0:
		return false
	var frame_window: int = int(get_input_tuning(knob_id, fallback))
	return frame_count <= frame_window


func _try_switch_device(device: StringName, timestamp_ms: int, force: bool = false) -> bool:
	if not _is_known_device(device) or device == _current_device:
		return false
	if _combat_input_locked:
		return false
	if not force and not _can_switch_device(device, timestamp_ms):
		return false
	_switch_device(device, timestamp_ms)
	return true


func _is_known_device(device: StringName) -> bool:
	return DEVICE_PRIORITY.has(device)


func _can_switch_device(device: StringName, timestamp_ms: int) -> bool:
	if _last_device_switch_ms < 0:
		return true
	var debounce_ms: int = int(get_input_tuning(&"input.device_switch_debounce_ms", 500))
	if timestamp_ms - _last_device_switch_ms > debounce_ms:
		return true
	return _device_priority(device) > _device_priority(_current_device)


func _device_priority(device: StringName) -> int:
	if not DEVICE_PRIORITY.has(device):
		return -1
	return int(DEVICE_PRIORITY[device])


func _switch_device(device: StringName, timestamp_ms: int) -> void:
	var old_device: StringName = _current_device
	var previous_state: InputState = _input_state
	_current_device = device
	_last_device_switch_ms = timestamp_ms
	_input_state = InputState.TRANSITIONING
	device_changed.emit(old_device, device)
	_input_state = previous_state


func _buffer_action(action: StringName, timestamp_ms: int, source_device: StringName) -> void:
	_prune_expired_buffered_inputs(timestamp_ms)
	var existing_index: int = _find_buffered_action_index(action)
	if existing_index >= 0:
		_buffered_inputs.remove_at(existing_index)
	_buffered_inputs.append({
		"action": action,
		"timestamp_ms": timestamp_ms,
		"source_device": source_device,
	})
	var queue_size: int = int(get_input_tuning(&"input.buffer_queue_size", 3))
	while _buffered_inputs.size() > queue_size:
		_buffered_inputs.remove_at(0)


func _find_buffered_action_index(action: StringName) -> int:
	for index: int in range(_buffered_inputs.size()):
		var entry: Dictionary = _buffered_inputs[index]
		if entry.get("action", &"") == action:
			return index
	return -1


func _prune_expired_buffered_inputs(now_ms: int) -> void:
	var buffer_window_ms: int = int(get_input_tuning(&"input.buffer_window_ms", 150))
	var valid_inputs: Array[Dictionary] = []
	for entry: Dictionary in _buffered_inputs:
		var age_ms: int = now_ms - int(entry.get("timestamp_ms", now_ms))
		if age_ms >= 0 and age_ms <= buffer_window_ms:
			valid_inputs.append(entry)
	_buffered_inputs = valid_inputs


func _pop_highest_priority_buffered_input(now_ms: int) -> Dictionary:
	_prune_expired_buffered_inputs(now_ms)
	var best_index: int = -1
	var best_priority: int = -2147483648
	var best_timestamp_ms: int = 2147483647
	for index: int in range(_buffered_inputs.size()):
		var entry: Dictionary = _buffered_inputs[index]
		var priority: int = _buffer_entry_priority(entry, now_ms)
		var entry_timestamp_ms: int = int(entry.get("timestamp_ms", now_ms))
		if priority > best_priority or (
			priority == best_priority and entry_timestamp_ms < best_timestamp_ms
		):
			best_index = index
			best_priority = priority
			best_timestamp_ms = entry_timestamp_ms
	if best_index < 0:
		return {}
	var selected: Dictionary = _buffered_inputs[best_index].duplicate(true)
	_buffered_inputs.remove_at(best_index)
	selected["is_pre_input"] = _is_pre_input_entry(selected, now_ms)
	selected["priority"] = _buffer_entry_priority(selected, now_ms)
	return selected


func _buffer_entry_priority(entry: Dictionary, unlock_timestamp_ms: int) -> int:
	var action: StringName = StringName(entry.get("action", &""))
	var priority: int = _action_priority(action)
	if _is_pre_input_entry(entry, unlock_timestamp_ms):
		priority += int(get_input_tuning(&"input.priority_pre_input_bonus", 20))
	return priority


func _is_pre_input_entry(entry: Dictionary, unlock_timestamp_ms: int) -> bool:
	var animation_end_ms: int = _animation_unlock_time_ms
	if animation_end_ms <= 0:
		animation_end_ms = unlock_timestamp_ms
	var ms_before_end: int = animation_end_ms - int(entry.get("timestamp_ms", animation_end_ms))
	var pre_input_window_ms: int = int(get_input_tuning(&"input.pre_input_window_ms", 50))
	return ms_before_end >= 0 and ms_before_end <= pre_input_window_ms


func _emit_buffered_action(entry: Dictionary, unlock_timestamp_ms: int) -> void:
	var action: StringName = StringName(entry.get("action", &""))
	var source_device: StringName = StringName(entry.get("source_device", &"kbm"))
	var timestamp_ms: int = int(entry.get("timestamp_ms", unlock_timestamp_ms))
	var buffer_delay_ms: int = maxi(0, unlock_timestamp_ms - timestamp_ms)
	_emit_action(action, _build_metadata(
		action,
		timestamp_ms,
		source_device,
		buffer_delay_ms,
		bool(entry.get("is_pre_input", false)),
		int(entry.get("priority", _action_priority(action))),
		unlock_timestamp_ms
	))


func _find_data_manager() -> Variant:
	if get_tree() == null or get_tree().root == null:
		return null
	var root: Window = get_tree().root
	if not root.has_node("DataManager"):
		return null
	return root.get_node("DataManager")


func _update_action_durations(now_ms: int) -> void:
	for action: StringName in get_supported_actions():
		if Input.is_action_pressed(action):
			if not _press_started_ms.has(action):
				_press_started_ms[action] = now_ms
		else:
			_press_started_ms.erase(action)
