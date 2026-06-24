class_name SaveTriggerAdapter
extends Node

signal on_autosave_triggered(reason: StringName, context: Dictionary)
signal on_autosave_failed(reason: StringName, context: Dictionary)

var _save_system: Object
var _snapshot_provider: Callable


## Configures the adapter with a SaveSystem-like object and optional snapshot provider.
func configure(save_system: Object, snapshot_provider: Callable = Callable()) -> void:
	_save_system = save_system
	_snapshot_provider = snapshot_provider


## Binds an Area2D-style savepoint body_entered signal to slot 0 autosave.
func bind_savepoint(source: Object, context: Dictionary = {}) -> bool:
	return _bind_trigger(source, &"body_entered", &"savepoint", context)


## Binds a boss defeat signal to slot 0 autosave.
func bind_boss_defeat(source: Object, context: Dictionary = {}) -> bool:
	return _bind_trigger(source, &"on_boss_defeated", &"boss_defeat", context)


## Binds a key-event completion signal to slot 0 autosave.
func bind_key_event(source: Object, context: Dictionary = {}) -> bool:
	return _bind_trigger(source, &"on_key_event_completed", &"key_event", context)


## Binds a scene-change request signal to slot 0 autosave.
func bind_scene_change(source: Object, context: Dictionary = {}) -> bool:
	return _bind_trigger(source, &"on_scene_change_requested", &"scene_change", context)


## Triggers an autosave directly without depending on a concrete gameplay class.
func trigger_auto_save(reason: StringName, context: Dictionary = {}) -> bool:
	var safe_context: Dictionary = context.duplicate(true)
	if _save_system == null or not is_instance_valid(_save_system) or not _save_system.has_method("auto_save"):
		on_autosave_failed.emit(reason, safe_context)
		return false

	var snapshot: Dictionary = _build_snapshot()
	var player_state: Dictionary = Dictionary(snapshot.get("player_state", {})).duplicate(true)
	var world_state: Dictionary = Dictionary(snapshot.get("world_state", {})).duplicate(true)
	var settings: Dictionary = Dictionary(snapshot.get("settings", {})).duplicate(true)
	world_state["autosave_reason"] = String(reason)
	world_state["autosave_context"] = safe_context

	var saved: bool = bool(_save_system.call("auto_save", player_state, world_state, settings))
	if saved:
		on_autosave_triggered.emit(reason, safe_context)
	else:
		on_autosave_failed.emit(reason, safe_context)
	return saved


func _bind_trigger(source: Object, signal_name: StringName, reason: StringName, context: Dictionary) -> bool:
	if source == null or not is_instance_valid(source):
		return false
	if not source.has_signal(signal_name):
		return false
	var callback := func(_arg1: Variant = null, _arg2: Variant = null, _arg3: Variant = null, _arg4: Variant = null) -> void:
		trigger_auto_save(reason, context)
	return source.connect(signal_name, callback) == OK


func _build_snapshot() -> Dictionary:
	if not _snapshot_provider.is_valid():
		return {}
	var provided: Variant = _snapshot_provider.call()
	if not provided is Dictionary:
		return {}
	return Dictionary(provided).duplicate(true)
