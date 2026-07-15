## Shared scene-level integration between hitstop, InputManager, and PlayerController.
class_name HitstopInputBridge
extends Node

signal buffered_action_dispatched(result: Dictionary)

var _presentation: CombatPresentation = null
var _player: PlayerController = null
var _input_manager: Node = null
var _pause_restore_predicate: Callable = Callable()
var _last_buffered_input_result: Dictionary = {}
var _buffered_input_dispatch_count: int = 0


func _exit_tree() -> void:
	_disconnect_runtime()
	_release_input_without_consuming()


func configure(
	presentation: CombatPresentation,
	player: PlayerController,
	input_manager: Node,
	pause_restore_predicate: Callable = Callable()
) -> bool:
	_disconnect_runtime()
	_presentation = presentation
	_player = player
	_input_manager = input_manager
	_pause_restore_predicate = pause_restore_predicate
	if _presentation == null or _player == null or _input_manager == null:
		return false
	_presentation.set_gameplay_freeze_enabled(true)
	var player_combat: CombatComponent = _player.get_combat_component()
	if player_combat != null:
		# PlayerController owns visual synchronization for released actions.
		player_combat.set_input_dispatcher(null)
	if not _presentation.hitstop_started.is_connected(_on_hitstop_started):
		_presentation.hitstop_started.connect(_on_hitstop_started)
	if not _presentation.hitstop_finished.is_connected(_on_hitstop_finished):
		_presentation.hitstop_finished.connect(_on_hitstop_finished)
	if not _input_manager.action_triggered.is_connected(_on_action_triggered):
		_input_manager.action_triggered.connect(_on_action_triggered)
	return true


func get_last_buffered_input_result() -> Dictionary:
	return _last_buffered_input_result.duplicate(true)


func get_diagnostics() -> Dictionary:
	return {
		"configured": (
			_presentation != null
			and _player != null
			and _input_manager != null
		),
		"dispatch_count": _buffered_input_dispatch_count,
		"input_state": (
			String(_input_manager.call("get_input_state"))
			if _input_manager != null
			else "unavailable"
		),
		"last_result": _last_buffered_input_result.duplicate(true),
	}


func _on_hitstop_started(frames: int) -> void:
	if _input_manager == null:
		return
	var physics_fps: int = maxi(1, Engine.physics_ticks_per_second)
	var duration_ms: int = ceili(
		float(maxi(1, frames)) * 1000.0 / float(physics_fps)
	)
	_input_manager.call("notify_animation_lock", duration_ms)


func _on_hitstop_finished(consume_buffered_input: bool) -> void:
	if consume_buffered_input and _input_manager != null:
		_input_manager.call("notify_animation_unlock")
	else:
		_release_input_without_consuming()
	if (
		_pause_restore_predicate.is_valid()
		and bool(_pause_restore_predicate.call())
		and get_tree() != null
	):
		get_tree().paused = true


func _on_action_triggered(action_id: StringName, metadata: Dictionary) -> void:
	if int(metadata.get("buffer_delay_ms", 0)) <= 0 or _player == null:
		return
	_buffered_input_dispatch_count += 1
	var combo_before: Dictionary = _player.get_light_combo_diagnostics()
	var combat: CombatComponent = _player.get_combat_component()
	var combat_state_before: int = (
		combat.get_current_state() if combat != null else -1
	)
	_last_buffered_input_result = {
		"action_id": action_id,
		"accepted": _player.request_buffered_action(action_id),
		"buffer_delay_ms": int(metadata.get("buffer_delay_ms", 0)),
		"dispatch_count": _buffered_input_dispatch_count,
		"player_attack_active_before": bool(combo_before.get("active", false)),
		"combat_state_before": combat_state_before,
	}
	buffered_action_dispatched.emit(_last_buffered_input_result.duplicate(true))


func _release_input_without_consuming() -> void:
	if _input_manager == null:
		return
	_input_manager.call("clear_buffer")
	_input_manager.call("notify_animation_lock", 0)


func _disconnect_runtime() -> void:
	if _presentation != null and is_instance_valid(_presentation):
		if _presentation.hitstop_started.is_connected(_on_hitstop_started):
			_presentation.hitstop_started.disconnect(_on_hitstop_started)
		if _presentation.hitstop_finished.is_connected(_on_hitstop_finished):
			_presentation.hitstop_finished.disconnect(_on_hitstop_finished)
	if _input_manager != null and is_instance_valid(_input_manager):
		if _input_manager.action_triggered.is_connected(_on_action_triggered):
			_input_manager.action_triggered.disconnect(_on_action_triggered)
