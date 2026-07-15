## Core enemy AI component with a six-state behavior machine.
extends Node
class_name AIComponent

signal on_state_changed(old_state: int, new_state: int)
signal on_attack_started(pattern_id: StringName)
signal on_attack_ended(pattern_id: StringName)

enum AIState {
	IDLE,
	PATROL,
	CHASE,
	ATTACK,
	FLEE,
	STUN,
}

const MIN_PERCEPTION_RADIUS: float = 100.0
const MAX_PERCEPTION_RADIUS: float = 500.0
const DEFAULT_PERCEPTION_RADIUS: float = 200.0
const MIN_PERCEPTION_ANGLE_DEGREES: float = 60.0
const MAX_PERCEPTION_ANGLE_DEGREES: float = 180.0
const DEFAULT_PERCEPTION_ANGLE_DEGREES: float = 120.0
const DEFAULT_CHASE_LOST_DELAY_SEC: float = 3.0
const CONE_EDGE_TOLERANCE_DEGREES: float = 1.0
const ENVIRONMENT_COLLISION_MASK: int = 1 << 4
const DEFAULT_ATTACK_STARTUP_FRAMES: int = 12
const DEFAULT_ATTACK_ACTIVE_FRAMES: int = 4
const DEFAULT_ATTACK_RECOVERY_FRAMES: int = 18
const DEFAULT_ATTACK_BASE_WEIGHT: float = 1.0
const DEFAULT_HITBOX_SIZE: Vector2 = Vector2(16, 16)
const DEFAULT_VULNERABILITY_SIZE_FRAMES: int = 4
const DEFAULT_FOCUS_WINDUP_EXTENSION_FRAMES: int = 6
const DEFAULT_FLEE_HP_THRESHOLD: float = 0.2
const DEFAULT_BERSERK_HP_THRESHOLD: float = 0.3
const DEFAULT_BERSERK_ATTACK_SPEED_MULTIPLIER: float = 1.2
const MIN_ATTACK_WEIGHT: float = 0.05
const MAX_ATTACK_WEIGHT: float = 40.0
const MIN_ATTACK_MODIFIER: float = 0.5
const MAX_ATTACK_MODIFIER: float = 2.0
const ATTACK_PHASE_NONE: StringName = &"none"
const ATTACK_PHASE_STARTUP: StringName = &"startup"
const ATTACK_PHASE_ACTIVE: StringName = &"active"
const ATTACK_PHASE_RECOVERY: StringName = &"recovery"

static var _active_enemy_count: int = 0

var _current_state: AIState = AIState.IDLE
var _contributes_active_count: bool = false
var _perception_radius: float = DEFAULT_PERCEPTION_RADIUS
var _perception_angle_degrees: float = DEFAULT_PERCEPTION_ANGLE_DEGREES
var _chase_lost_delay_sec: float = DEFAULT_CHASE_LOST_DELAY_SEC
var _lost_target_time_sec: float = 0.0
var _line_of_sight_adapter: Callable = Callable()
var _target_position_provider: Callable = Callable()
var _facing_direction_provider: Callable = Callable()
var _data_adapter: Object = null
var _collision_adapter: Object = null
var _health_adapter: Object = null
var _entity_id: int = -1
var _attack_patterns: Array[Dictionary] = []
var _phase_attack_patterns: Dictionary = {}
var _current_attack_pattern: Dictionary = {}
var _attack_phase: StringName = ATTACK_PHASE_NONE
var _attack_phase_frame: int = 0
var _hitbox_activated_this_attack: bool = false
var _focus_mode_active: bool = false
var _focus_windup_extension_frames: int = DEFAULT_FOCUS_WINDUP_EXTENSION_FRAMES
var _current_boss_phase: int = 1
var _boss_phase_attack_pattern_ids: Array = []
var _boss_attack_speed_modifier: float = 1.0
var _flee_enabled: bool = true
var _berserk_enabled: bool = true
var _flee_hp_threshold: float = DEFAULT_FLEE_HP_THRESHOLD
var _berserk_hp_threshold: float = DEFAULT_BERSERK_HP_THRESHOLD
var _berserk_attack_speed_multiplier: float = DEFAULT_BERSERK_ATTACK_SPEED_MULTIPLIER
var _berserk_active: bool = false


func _exit_tree() -> void:
	_disconnect_health_adapter()
	if _contributes_active_count:
		_set_active_count_contribution(false)


func _physics_process(delta: float) -> void:
	match _current_state:
		AIState.IDLE:
			_process_idle(delta)
		AIState.PATROL:
			_process_patrol(delta)
		AIState.CHASE:
			_process_chase(delta)
		AIState.ATTACK:
			_process_attack(delta)
		AIState.FLEE:
			_process_flee(delta)
		AIState.STUN:
			_process_stun(delta)


## Resets shared active count for deterministic tests and scene teardown.
static func reset_active_enemy_count() -> void:
	_active_enemy_count = 0


## Returns enemies currently in CHASE or ATTACK.
static func get_active_enemy_count() -> int:
	return maxi(0, _active_enemy_count)


## Returns the current AI state enum value.
func get_current_state() -> int:
	return _current_state


## Configures perception and clamps GDD-safe cone values.
func configure_perception(radius: float, angle_degrees: float, chase_lost_delay_sec: float) -> void:
	_perception_radius = clampf(radius, MIN_PERCEPTION_RADIUS, MAX_PERCEPTION_RADIUS)
	_perception_angle_degrees = clampf(
		angle_degrees,
		MIN_PERCEPTION_ANGLE_DEGREES,
		MAX_PERCEPTION_ANGLE_DEGREES
	)
	_chase_lost_delay_sec = maxf(0.0, chase_lost_delay_sec)


## Returns the clamped perception radius in pixels.
func get_perception_radius() -> float:
	return _perception_radius


## Returns the clamped perception cone angle in degrees.
func get_perception_angle_degrees() -> float:
	return _perception_angle_degrees


## Injects a DataManager-compatible adapter with get_entry(domain, entry_id).
func set_data_adapter(data_adapter: Object) -> void:
	_data_adapter = data_adapter


## Injects a CollisionComponent-compatible adapter with activate_hitbox().
func set_collision_adapter(collision_adapter: Object) -> void:
	_collision_adapter = collision_adapter


## Configures this AI component's owning entity id for signal filtering.
func set_entity_id(entity_id: int) -> void:
	_entity_id = entity_id


## Returns the configured owning entity id, or -1 if not configured.
func get_entity_id() -> int:
	return _entity_id


## Connects HealthComponent-compatible focus and boss phase signals.
func set_health_adapter(health_adapter: Object) -> void:
	if _health_adapter == health_adapter:
		return
	_disconnect_health_adapter()
	_health_adapter = health_adapter
	_connect_health_signal(&"on_focus_mode_changed", _handle_focus_mode_changed)
	_connect_health_signal(&"on_boss_phase_change", _handle_boss_phase_change)


## Applies focus emitted by an external target, such as the player hunted by this AI.
func set_target_focus_mode(active: bool, metadata: Dictionary = {}) -> void:
	_set_focus_mode(active, metadata)


func is_target_focus_mode_active() -> bool:
	return _focus_mode_active


func get_focus_windup_extension_frames() -> int:
	return _focus_windup_extension_frames if _focus_mode_active else 0


## Configures low-HP flee and berserk behavior thresholds.
func configure_low_hp_behavior(
	flee_enabled: bool,
	berserk_enabled: bool,
	flee_threshold: float = DEFAULT_FLEE_HP_THRESHOLD,
	berserk_threshold: float = DEFAULT_BERSERK_HP_THRESHOLD,
	berserk_speed_multiplier: float = DEFAULT_BERSERK_ATTACK_SPEED_MULTIPLIER
) -> void:
	_flee_enabled = flee_enabled
	_berserk_enabled = berserk_enabled
	_flee_hp_threshold = clampf(flee_threshold, 0.0, 1.0)
	_berserk_hp_threshold = clampf(berserk_threshold, 0.0, 1.0)
	_berserk_attack_speed_multiplier = maxf(1.0, berserk_speed_multiplier)


## Injects a deterministic line-of-sight query: Callable(origin, target) -> bool.
func set_line_of_sight_adapter(adapter: Callable) -> void:
	_line_of_sight_adapter = adapter


## Injects target and facing providers for frame-driven perception updates.
func set_perception_providers(target_position_provider: Callable, facing_direction_provider: Callable) -> void:
	_target_position_provider = target_position_provider
	_facing_direction_provider = facing_direction_provider


## Loads and sanitizes attack patterns for one enemy id.
func load_attack_patterns(enemy_id: StringName, data_adapter: Object = null) -> bool:
	_attack_patterns.clear()
	_phase_attack_patterns.clear()
	var adapter: Object = data_adapter if data_adapter != null else _data_adapter
	var enemy_entry: Dictionary = _read_enemy_stats_entry(enemy_id, adapter)
	var source_patterns: Variant = enemy_entry.get("attack_patterns", [])
	if not (source_patterns is Array):
		return false
	for raw_pattern: Variant in source_patterns:
		if raw_pattern is Dictionary:
			_attack_patterns.append(_normalize_attack_pattern(raw_pattern as Dictionary))
	_load_phase_attack_patterns(enemy_entry)
	return has_attack_patterns()


## Returns sanitized attack patterns loaded for this AI component.
func get_attack_patterns() -> Array:
	return _attack_patterns.duplicate(true)


## Returns whether this component has at least one safe attack pattern.
func has_attack_patterns() -> bool:
	return not _attack_patterns.is_empty() or not _phase_attack_patterns.is_empty()


## Starts the selected loaded attack pattern at startup frame 0.
func start_attack(pattern_index: int = 0) -> bool:
	var available_patterns: Array[Dictionary] = _get_current_attack_patterns()
	if pattern_index < 0 or pattern_index >= available_patterns.size():
		return false
	return _start_attack_from_pattern(available_patterns[pattern_index])


## Starts the loaded attack pattern with the given pattern id.
func start_attack_by_pattern_id(pattern_id: StringName) -> bool:
	for pattern: Dictionary in _get_current_attack_patterns():
		if StringName(pattern.get("pattern_id", &"default_attack")) == pattern_id:
			return _start_attack_from_pattern(pattern)
	return false


## Applies the BossConfig phase contract without listening to raw health thresholds.
func apply_boss_phase(
	phase_id: int,
	attack_patterns: Array,
	attack_speed_modifier: float
) -> void:
	_current_boss_phase = maxi(1, phase_id)
	_boss_phase_attack_pattern_ids = _string_names_from_array(attack_patterns)
	_boss_attack_speed_modifier = clampf(
		attack_speed_modifier,
		MIN_ATTACK_MODIFIER,
		MAX_ATTACK_MODIFIER
	)


## Returns the pattern ids available after phase and BossConfig filtering.
func get_current_attack_pattern_ids() -> Array:
	var pattern_ids: Array = []
	for pattern: Dictionary in _get_current_attack_patterns():
		pattern_ids.append(StringName(pattern.get("pattern_id", &"default_attack")))
	return pattern_ids


## Returns the current attack pattern id, or an empty id when no attack is active.
func get_current_attack_pattern_id() -> StringName:
	return StringName(_current_attack_pattern.get("pattern_id", &""))


func _start_attack_from_pattern(pattern: Dictionary) -> bool:
	_current_attack_pattern = pattern.duplicate(true)
	_apply_berserk_timing(_current_attack_pattern)
	_current_attack_pattern["base_startup_frames"] = int(
		_current_attack_pattern.get("startup_frames", DEFAULT_ATTACK_STARTUP_FRAMES)
	)
	_current_attack_pattern["startup_frames"] = _get_effective_startup_frames(_current_attack_pattern)
	_attack_phase = ATTACK_PHASE_STARTUP
	_attack_phase_frame = 0
	_hitbox_activated_this_attack = false
	change_state(AIState.ATTACK)
	on_attack_started.emit(_current_attack_pattern.get("pattern_id", &"default_attack"))
	return true


## Returns the current attack phase name: none/startup/active/recovery.
func get_attack_phase() -> StringName:
	return _attack_phase


## Returns the frame counter inside the current attack phase.
func get_attack_frame() -> int:
	return _attack_phase_frame


## Returns the startup frame count frozen for the current attack.
func get_effective_attack_startup_frames() -> int:
	if _current_attack_pattern.is_empty():
		return 0
	return int(_current_attack_pattern.get("startup_frames", DEFAULT_ATTACK_STARTUP_FRAMES))


func get_current_attack_base_startup_frames() -> int:
	if _current_attack_pattern.is_empty():
		return 0
	return int(_current_attack_pattern.get(
		"base_startup_frames",
		DEFAULT_ATTACK_STARTUP_FRAMES
	))


## Returns the latest accepted boss phase for this entity.
func get_current_boss_phase() -> int:
	return _current_boss_phase


## Evaluates HealthComponent-compatible HP percentage for low-HP behavior.
func evaluate_low_hp_behavior() -> void:
	var hp_percentage: float = _query_health_percentage()
	_berserk_active = _berserk_enabled and hp_percentage < _berserk_hp_threshold
	if _flee_enabled and hp_percentage < _flee_hp_threshold and _is_combat_state(_current_state):
		change_state(AIState.FLEE)


## Returns the active attack speed modifier for future attack timing.
func get_berserk_attack_speed_modifier() -> float:
	if _berserk_active:
		return _berserk_attack_speed_multiplier
	return 1.0


## Returns the combined BossConfig and low-HP attack speed modifier.
func get_attack_speed_modifier() -> float:
	return clampf(
		_boss_attack_speed_modifier * get_berserk_attack_speed_modifier(),
		MIN_ATTACK_MODIFIER,
		MAX_ATTACK_MODIFIER
	)


## Returns current pattern weights after base, phase, and HP modifiers.
func get_attack_selection_weights() -> Array:
	var weights: Array[Dictionary] = []
	for pattern: Dictionary in _get_current_attack_patterns():
		weights.append({
			"pattern_id": pattern.get("pattern_id", &"default_attack"),
			"weight": _calculate_attack_weight(pattern),
		})
	return weights


## Selects a pattern using an injectable 0..1 roll for deterministic tests.
func select_attack_pattern(roll_value: float = -1.0) -> Dictionary:
	var available_patterns: Array[Dictionary] = _get_current_attack_patterns()
	if available_patterns.is_empty():
		return {}
	var weights: Array = get_attack_selection_weights()
	var target_weight: float = _selection_target_weight(weights, roll_value)
	var cumulative_weight: float = 0.0
	for index: int in range(available_patterns.size()):
		cumulative_weight += float((weights[index] as Dictionary).get("weight", 0.0))
		if target_weight <= cumulative_weight:
			return available_patterns[index].duplicate(true)
	return available_patterns[available_patterns.size() - 1].duplicate(true)


## Advances attack execution without relying on engine physics timing.
func advance_attack_frames(frames: int) -> void:
	for _index: int in range(maxi(0, frames)):
		if _current_state != AIState.ATTACK:
			return
		_process_attack(1.0 / 60.0)


## Interrupts the current attack before hitbox activation and enters STUN.
func interrupt_attack_with_stun() -> void:
	if _current_state != AIState.ATTACK:
		return
	_clear_attack_state()
	change_state(AIState.STUN)


## Detects whether a target is visible from this component's owner node.
func detect_target(target_position: Vector2, facing_direction: Vector2) -> Dictionary:
	var origin_position: Vector2 = _get_origin_position()
	var to_target: Vector2 = target_position - origin_position
	var distance: float = to_target.length()
	var direction: Vector2 = Vector2.ZERO
	if distance > 0.001:
		direction = to_target / distance

	var within_radius: bool = distance <= _perception_radius
	var inside_cone: bool = within_radius and _is_inside_perception_cone(direction, facing_direction)
	var line_of_sight_clear: bool = false
	if inside_cone:
		line_of_sight_clear = _has_clear_line_of_sight(origin_position, target_position)

	return {
		"can_see": within_radius and inside_cone and line_of_sight_clear,
		"distance": distance,
		"direction": direction,
		"in_attack_range": false,
		"within_radius": within_radius,
		"inside_cone": inside_cone,
		"line_of_sight_clear": line_of_sight_clear,
	}


## Changes state and updates active-enemy counting once per entity.
func change_state(new_state: int) -> void:
	var normalized_state: AIState = _normalize_state(new_state)
	if _current_state == normalized_state:
		return
	var old_state: AIState = _current_state
	_current_state = normalized_state
	_lost_target_time_sec = 0.0
	if old_state == AIState.ATTACK and _current_state != AIState.ATTACK:
		_clear_attack_state()
	_set_active_count_contribution(_is_active_enemy_state(_current_state))
	on_state_changed.emit(old_state, _current_state)


func _connect_health_signal(signal_name: StringName, callback: Callable) -> void:
	if _health_adapter == null or not _health_adapter.has_signal(signal_name):
		return
	var adapter_signal: Signal = _health_adapter.get(signal_name)
	if not adapter_signal.is_connected(callback):
		adapter_signal.connect(callback)


func _disconnect_health_adapter() -> void:
	_disconnect_health_signal(&"on_focus_mode_changed", _handle_focus_mode_changed)
	_disconnect_health_signal(&"on_boss_phase_change", _handle_boss_phase_change)
	_health_adapter = null


func _disconnect_health_signal(signal_name: StringName, callback: Callable) -> void:
	if _health_adapter == null or not _health_adapter.has_signal(signal_name):
		return
	var adapter_signal: Signal = _health_adapter.get(signal_name)
	if adapter_signal.is_connected(callback):
		adapter_signal.disconnect(callback)


func _handle_focus_mode_changed(
	active_or_entity: Variant,
	maybe_active: Variant = null,
	metadata: Dictionary = {}
) -> void:
	if maybe_active == null:
		_set_focus_mode(bool(active_or_entity), {})
		return
	if not _matches_entity_id(int(active_or_entity)):
		return
	_set_focus_mode(bool(maybe_active), metadata)


func _handle_boss_phase_change(
	entity_or_phase: Variant,
	maybe_phase: Variant = null,
	_hp_percentage: float = 0.0
) -> void:
	if maybe_phase == null:
		_current_boss_phase = maxi(1, int(entity_or_phase))
		return
	if not _matches_entity_id(int(entity_or_phase)):
		return
	_current_boss_phase = maxi(1, int(maybe_phase))


func _set_focus_mode(active: bool, metadata: Dictionary) -> void:
	_focus_mode_active = active
	if not active:
		_focus_windup_extension_frames = 0
		return
	_focus_windup_extension_frames = _read_int(
		metadata,
		"windup_extension_frames",
		DEFAULT_FOCUS_WINDUP_EXTENSION_FRAMES,
		0,
		300
	)


func _matches_entity_id(incoming_entity_id: int) -> bool:
	return _entity_id == -1 or incoming_entity_id == _entity_id


func _query_health_percentage() -> float:
	if _health_adapter == null or not _health_adapter.has_method("get_hp_percentage"):
		return 1.0
	var hp_percentage: Variant = _health_adapter.call("get_hp_percentage")
	if hp_percentage is int or hp_percentage is float:
		return clampf(float(hp_percentage), 0.0, 1.0)
	return 1.0


func _is_combat_state(state: AIState) -> bool:
	return state == AIState.CHASE or state == AIState.ATTACK


func _apply_berserk_timing(pattern: Dictionary) -> void:
	var speed_modifier: float = get_attack_speed_modifier()
	if speed_modifier <= 1.0:
		return
	pattern["startup_frames"] = _speed_scaled_frame_count(pattern.get("startup_frames", 1))
	pattern["active_frames"] = _speed_scaled_frame_count(pattern.get("active_frames", 1))
	pattern["recovery_frames"] = _speed_scaled_frame_count(pattern.get("recovery_frames", 1))


func _speed_scaled_frame_count(frame_value: Variant) -> int:
	var base_frames: int = maxi(1, int(frame_value))
	return maxi(1, int(round(float(base_frames) / get_attack_speed_modifier())))


func _calculate_attack_weight(pattern: Dictionary) -> float:
	var base_weight: float = float(pattern.get("base_weight", DEFAULT_ATTACK_BASE_WEIGHT))
	var phase_modifier: float = float(pattern.get("phase_modifier", 1.0))
	var hp_modifier: float = float(pattern.get("hp_modifier", 1.0))
	return clampf(base_weight * phase_modifier * hp_modifier, MIN_ATTACK_WEIGHT, MAX_ATTACK_WEIGHT)


func _selection_target_weight(weights: Array, roll_value: float) -> float:
	var total_weight: float = 0.0
	for entry: Dictionary in weights:
		total_weight += float(entry.get("weight", 0.0))
	var roll: float = roll_value if roll_value >= 0.0 else randf()
	return clampf(roll, 0.0, 0.999999) * maxf(0.0, total_weight)


func _normalize_state(state: int) -> AIState:
	match state:
		AIState.IDLE, AIState.PATROL, AIState.CHASE, AIState.ATTACK, AIState.FLEE, AIState.STUN:
			return state as AIState
		_:
			return AIState.IDLE


func _set_active_count_contribution(should_contribute: bool) -> void:
	if _contributes_active_count == should_contribute:
		return
	_contributes_active_count = should_contribute
	if should_contribute:
		_active_enemy_count += 1
	else:
		_active_enemy_count = maxi(0, _active_enemy_count - 1)


func _is_active_enemy_state(state: AIState) -> bool:
	return state == AIState.CHASE or state == AIState.ATTACK


func _read_enemy_stats_entry(enemy_id: StringName, adapter: Object) -> Dictionary:
	if adapter == null:
		return {}
	if adapter.has_method("get_entry"):
		var entry: Variant = adapter.call("get_entry", &"enemy_stats", enemy_id)
		if entry is Dictionary:
			return entry as Dictionary
	if adapter.has_method("get_domain"):
		var domain: Variant = adapter.call("get_domain", &"enemy_stats")
		if domain is Dictionary and (domain as Dictionary).has(enemy_id):
			var domain_entry: Variant = (domain as Dictionary)[enemy_id]
			if domain_entry is Dictionary:
				return domain_entry as Dictionary
	return {}


func _normalize_attack_pattern(source: Dictionary) -> Dictionary:
	var startup_frames: int = _read_int(source, "startup_frames", DEFAULT_ATTACK_STARTUP_FRAMES, 1, 300)
	var pattern: Dictionary = {
		"pattern_id": StringName(String(source.get("pattern_id", "default_attack"))),
		"startup_frames": startup_frames,
		"active_frames": _read_int(source, "active_frames", DEFAULT_ATTACK_ACTIVE_FRAMES, 1, 120),
		"recovery_frames": _read_int(source, "recovery_frames", DEFAULT_ATTACK_RECOVERY_FRAMES, 1, 300),
		"damage_type": StringName(String(source.get("damage_type", "physical"))),
		"damage": _read_int(source, "damage", 0, 0, 999),
		"hitbox_config": _normalize_hitbox_config(source.get("hitbox_config", {})),
		"vulnerability_window": _normalize_vulnerability_window(
			source.get("vulnerability_window", {}),
			startup_frames
			),
	}
	pattern.merge(_normalize_attack_weighting(source))
	return pattern


func _normalize_attack_weighting(source: Dictionary) -> Dictionary:
	return {
		"base_weight": _read_float(
			source,
			"base_weight",
			DEFAULT_ATTACK_BASE_WEIGHT,
			MIN_ATTACK_WEIGHT,
			MAX_ATTACK_WEIGHT
		),
		"phase_modifier": _read_float(
			source,
			"phase_modifier",
			1.0,
			MIN_ATTACK_MODIFIER,
			MAX_ATTACK_MODIFIER
		),
		"hp_modifier": _read_float(
			source,
			"hp_modifier",
			1.0,
			MIN_ATTACK_MODIFIER,
			MAX_ATTACK_MODIFIER
		),
		"windup_extension_frames": _read_int(
			source,
			"windup_extension_frames",
			DEFAULT_FOCUS_WINDUP_EXTENSION_FRAMES,
			0,
			300
		),
	}


func _load_phase_attack_patterns(enemy_entry: Dictionary) -> void:
	_load_phase_attack_patterns_map(enemy_entry.get("phase_attack_patterns", {}))
	_load_phase_attack_patterns_array(enemy_entry.get("phases", []))


func _load_phase_attack_patterns_map(source_value: Variant) -> void:
	if not (source_value is Dictionary):
		return
	var phase_map: Dictionary = source_value
	for phase_key: Variant in phase_map.keys():
		_store_phase_attack_patterns(phase_key, phase_map[phase_key])


func _load_phase_attack_patterns_array(source_value: Variant) -> void:
	if not (source_value is Array):
		return
	for entry: Variant in source_value:
		if entry is Dictionary:
			var phase_entry: Dictionary = entry
			_store_phase_attack_patterns(
				phase_entry.get("phase", phase_entry.get("id", 1)),
				phase_entry.get("attack_patterns", [])
			)


func _store_phase_attack_patterns(phase_value: Variant, raw_patterns: Variant) -> void:
	if not (raw_patterns is Array):
		return
	var phase: int = maxi(1, int(phase_value))
	var normalized_patterns: Array[Dictionary] = []
	for raw_pattern: Variant in raw_patterns:
		if raw_pattern is Dictionary:
			normalized_patterns.append(_normalize_attack_pattern(raw_pattern as Dictionary))
	if not normalized_patterns.is_empty():
		_phase_attack_patterns[phase] = normalized_patterns


func _normalize_hitbox_config(source_value: Variant) -> Dictionary:
	var source: Dictionary = source_value if source_value is Dictionary else {}
	var size: Vector2 = _read_vector2(source.get("size", DEFAULT_HITBOX_SIZE), DEFAULT_HITBOX_SIZE)
	if size.x <= 0.0 or size.y <= 0.0:
		size = DEFAULT_HITBOX_SIZE
	return {
		"hitbox_id": StringName(String(source.get("hitbox_id", "default_hitbox"))),
		"offset": _read_vector2(source.get("offset", Vector2.ZERO), Vector2.ZERO),
		"size": size,
	}


func _normalize_vulnerability_window(source_value: Variant, startup_frames: int) -> Dictionary:
	var source: Dictionary = source_value if source_value is Dictionary else {}
	return {
		"start_frame": _read_int(source, "start_frame", startup_frames, 0, 300),
		"size_frames": _read_int(
			source,
			"size_frames",
			DEFAULT_VULNERABILITY_SIZE_FRAMES,
			1,
			60
		),
	}


func _read_int(source: Dictionary, key: String, default_value: int, min_value: int, max_value: int) -> int:
	var value: Variant = source.get(key, default_value)
	if value is int:
		return clampi(value, min_value, max_value)
	if value is float:
		return clampi(int(value), min_value, max_value)
	return default_value


func _read_float(
	source: Dictionary,
	key: String,
	default_value: float,
	min_value: float,
	max_value: float
) -> float:
	var value: Variant = source.get(key, default_value)
	if value is int or value is float:
		return clampf(float(value), min_value, max_value)
	return default_value


func _read_vector2(value: Variant, default_value: Vector2) -> Vector2:
	if value is Vector2:
		return value
	if value is Dictionary:
		var data: Dictionary = value
		return Vector2(float(data.get("x", default_value.x)), float(data.get("y", default_value.y)))
	return default_value


func _advance_attack_phase() -> void:
	match _attack_phase:
		ATTACK_PHASE_STARTUP:
			_advance_startup_phase()
		ATTACK_PHASE_ACTIVE:
			_advance_active_phase()
		ATTACK_PHASE_RECOVERY:
			_advance_recovery_phase()


func _advance_startup_phase() -> void:
	_attack_phase_frame += 1
	if _attack_phase_frame < int(_current_attack_pattern.get("startup_frames", 1)):
		return
	_activate_current_hitbox()
	_attack_phase = ATTACK_PHASE_ACTIVE
	_attack_phase_frame = 0


func _advance_active_phase() -> void:
	_attack_phase_frame += 1
	if _attack_phase_frame < int(_current_attack_pattern.get("active_frames", 1)):
		return
	_attack_phase = ATTACK_PHASE_RECOVERY
	_attack_phase_frame = 0


func _advance_recovery_phase() -> void:
	_attack_phase_frame += 1
	if _attack_phase_frame < int(_current_attack_pattern.get("recovery_frames", 1)):
		return
	var ended_pattern_id: StringName = _current_attack_pattern.get("pattern_id", &"default_attack")
	_clear_attack_state()
	change_state(AIState.IDLE)
	on_attack_ended.emit(ended_pattern_id)


func _activate_current_hitbox() -> void:
	if _hitbox_activated_this_attack:
		return
	_hitbox_activated_this_attack = true
	if _collision_adapter == null or not _collision_adapter.has_method("activate_hitbox"):
		return
	var hitbox_config: Dictionary = _current_attack_pattern.get("hitbox_config", {})
	_collision_adapter.call(
		"activate_hitbox",
		hitbox_config.get("hitbox_id", &"default_hitbox"),
		int(_current_attack_pattern.get("active_frames", DEFAULT_ATTACK_ACTIVE_FRAMES)),
		hitbox_config.get("offset", Vector2.ZERO),
		hitbox_config.get("size", DEFAULT_HITBOX_SIZE),
		_build_attack_metadata()
	)


func _get_current_attack_patterns() -> Array[Dictionary]:
	var phase_patterns: Variant = _phase_attack_patterns.get(_current_boss_phase, [])
	var source_patterns: Array[Dictionary] = []
	if phase_patterns is Array and not (phase_patterns as Array).is_empty():
		source_patterns = _dictionary_array_from_array(phase_patterns as Array)
	else:
		source_patterns = _attack_patterns
	return _filter_patterns_by_boss_phase_ids(source_patterns)


func _dictionary_array_from_array(source: Array) -> Array[Dictionary]:
	var typed_values: Array[Dictionary] = []
	for value: Variant in source:
		if value is Dictionary:
			typed_values.append(value as Dictionary)
	return typed_values


func _filter_patterns_by_boss_phase_ids(source_patterns: Array[Dictionary]) -> Array[Dictionary]:
	if _boss_phase_attack_pattern_ids.is_empty():
		return source_patterns
	var filtered_patterns: Array[Dictionary] = []
	for pattern: Dictionary in source_patterns:
		var pattern_id: StringName = StringName(pattern.get("pattern_id", &"default_attack"))
		if _boss_phase_attack_pattern_ids.has(pattern_id):
			filtered_patterns.append(pattern)
	return filtered_patterns


func _string_names_from_array(source: Array) -> Array:
	var result: Array = []
	for value: Variant in source:
		var pattern_id: StringName = StringName(String(value))
		if pattern_id != &"":
			result.append(pattern_id)
	return result


func _get_effective_startup_frames(pattern: Dictionary) -> int:
	var base_startup: int = int(pattern.get("startup_frames", DEFAULT_ATTACK_STARTUP_FRAMES))
	if not _focus_mode_active:
		return base_startup
	var extension: int = int(pattern.get("windup_extension_frames", _focus_windup_extension_frames))
	return base_startup + maxi(0, extension)


func _build_attack_metadata() -> Dictionary:
	return {
		"pattern_id": _current_attack_pattern.get("pattern_id", &"default_attack"),
		"damage_type": _current_attack_pattern.get("damage_type", &"physical"),
		"damage": _current_attack_pattern.get("damage", 0),
		"base_startup_frames": _current_attack_pattern.get(
			"base_startup_frames",
			DEFAULT_ATTACK_STARTUP_FRAMES
		),
		"startup_frames": _current_attack_pattern.get("startup_frames", DEFAULT_ATTACK_STARTUP_FRAMES),
		"active_frames": _current_attack_pattern.get("active_frames", DEFAULT_ATTACK_ACTIVE_FRAMES),
		"recovery_frames": _current_attack_pattern.get("recovery_frames", DEFAULT_ATTACK_RECOVERY_FRAMES),
		"base_weight": _current_attack_pattern.get("base_weight", DEFAULT_ATTACK_BASE_WEIGHT),
		"vulnerability_window": _current_attack_pattern.get("vulnerability_window", {}).duplicate(true),
	}


func _clear_attack_state() -> void:
	_current_attack_pattern.clear()
	_attack_phase = ATTACK_PHASE_NONE
	_attack_phase_frame = 0
	_hitbox_activated_this_attack = false


func _update_perception_state(delta: float) -> void:
	if not _target_position_provider.is_valid() or not _facing_direction_provider.is_valid():
		return
	var target_position: Vector2 = _target_position_provider.call()
	var facing_direction: Vector2 = _facing_direction_provider.call()
	var perception: Dictionary = detect_target(target_position, facing_direction)
	if perception["can_see"]:
		_lost_target_time_sec = 0.0
		if _current_state == AIState.IDLE or _current_state == AIState.PATROL:
			change_state(AIState.CHASE)
		return
	if _current_state == AIState.CHASE:
		_lost_target_time_sec += maxf(0.0, delta)
		if _lost_target_time_sec >= _chase_lost_delay_sec:
			change_state(AIState.PATROL)


func _get_origin_position() -> Vector2:
	var owner_node := get_parent() as Node2D
	if owner_node == null:
		return Vector2.ZERO
	return owner_node.global_position


func _is_inside_perception_cone(direction: Vector2, facing_direction: Vector2) -> bool:
	if direction == Vector2.ZERO:
		return true
	var normalized_facing: Vector2 = facing_direction.normalized()
	if normalized_facing == Vector2.ZERO:
		normalized_facing = Vector2.RIGHT
	var angle_degrees: float = absf(rad_to_deg(normalized_facing.angle_to(direction)))
	return angle_degrees <= (_perception_angle_degrees * 0.5) + CONE_EDGE_TOLERANCE_DEGREES


func _has_clear_line_of_sight(origin_position: Vector2, target_position: Vector2) -> bool:
	if _line_of_sight_adapter.is_valid():
		return bool(_line_of_sight_adapter.call(origin_position, target_position))
	var owner_node := get_parent() as Node2D
	if owner_node == null or not owner_node.is_inside_tree():
		return true
	var space_state: PhysicsDirectSpaceState2D = owner_node.get_world_2d().direct_space_state
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
		origin_position,
		target_position,
		ENVIRONMENT_COLLISION_MASK
	)
	var result: Dictionary = space_state.intersect_ray(query)
	return result.is_empty()


func _process_idle(delta: float) -> void:
	_update_perception_state(delta)


func _process_patrol(delta: float) -> void:
	_update_perception_state(delta)


func _process_chase(delta: float) -> void:
	_update_perception_state(delta)


func _process_attack(_delta: float) -> void:
	_advance_attack_phase()


func _process_flee(_delta: float) -> void:
	pass


func _process_stun(_delta: float) -> void:
	pass
