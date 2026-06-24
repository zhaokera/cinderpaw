## Runtime encounter flow for victory, death delay, and quick respawn.
extends Node
class_name GameFlowController

signal respawn_requested(position: Vector2, revive_hp_percentage: float)
signal victory_reached

const DEATH_ANIMATION_DURATION_SEC: float = 1.5
const RESPAWN_INVINCIBILITY_SEC: float = 2.0
const REVIVE_HP_PERCENTAGE: float = 0.5
const DEFAULT_CLAN_BASE_SCENE_ID: StringName = &"hub"
const DEFAULT_CLAN_BASE_SPAWN_POINT: StringName = &"clan_base"
const DEFAULT_BOSS_ENTRANCE_SCENE_ID: StringName = &"main"
const DEFAULT_BOSS_ENTRANCE_SPAWN_POINT: StringName = &"boss_entrance"

enum FlowState {
	PLAYING,
	DYING,
	REVIVED,
	VICTORY,
}

var _state: FlowState = FlowState.PLAYING
var _respawn_position: Vector2 = Vector2.ZERO
var _death_remaining_sec: float = 0.0
var _invincibility_remaining_sec: float = 0.0
var _player_control_locked: bool = false
var _is_boss_encounter_active: bool = false
var _boss_arena_adapter: Object = null
var _boss_arena_snapshot: Dictionary = {}
var _no_loss_state_adapter: Object = null
var _no_loss_state_snapshot: Dictionary = {}
var _has_no_loss_state_snapshot: bool = false
var _savepoint_adapter: Object = null
var _scene_transition_adapter: Object = null
var _clan_base_scene_id: StringName = DEFAULT_CLAN_BASE_SCENE_ID
var _clan_base_spawn_point: StringName = DEFAULT_CLAN_BASE_SPAWN_POINT
var _clan_base_position: Vector2 = Vector2.ZERO
var _boss_entrance_scene_id: StringName = DEFAULT_BOSS_ENTRANCE_SCENE_ID
var _boss_entrance_spawn_point: StringName = DEFAULT_BOSS_ENTRANCE_SPAWN_POINT
var _boss_entrance_position: Vector2 = Vector2.ZERO
var _last_selected_respawn_point: Dictionary = {}


func _process(delta: float) -> void:
	advance_time(delta)


func start_encounter(respawn_position: Vector2) -> void:
	_respawn_position = respawn_position
	_clan_base_position = respawn_position
	_state = FlowState.PLAYING
	_death_remaining_sec = 0.0
	_invincibility_remaining_sec = 0.0
	_player_control_locked = false
	_last_selected_respawn_point.clear()
	_clear_boss_encounter()
	_clear_no_loss_state_snapshot()


func start_boss_encounter(arena_entrance_position: Vector2, boss_arena_adapter: Object) -> void:
	start_encounter(arena_entrance_position)
	_boss_entrance_position = arena_entrance_position
	_is_boss_encounter_active = boss_arena_adapter != null
	_boss_arena_adapter = boss_arena_adapter
	_boss_arena_snapshot = _capture_boss_arena_snapshot()


func set_no_loss_state_adapter(no_loss_state_adapter: Object) -> void:
	_no_loss_state_adapter = no_loss_state_adapter
	_clear_no_loss_state_snapshot()


func set_savepoint_adapter(savepoint_adapter: Object) -> void:
	_savepoint_adapter = savepoint_adapter


func set_scene_transition_adapter(scene_transition_adapter: Object) -> void:
	_scene_transition_adapter = scene_transition_adapter


func configure_clan_base_respawn(
	scene_id: StringName,
	spawn_point: StringName,
	position: Vector2
) -> bool:
	if scene_id == &"" or spawn_point == &"":
		return false
	_clan_base_scene_id = scene_id
	_clan_base_spawn_point = spawn_point
	_clan_base_position = position
	return true


func configure_boss_entrance_respawn(
	scene_id: StringName,
	spawn_point: StringName,
	position: Vector2
) -> bool:
	if scene_id == &"" or spawn_point == &"":
		return false
	_boss_entrance_scene_id = scene_id
	_boss_entrance_spawn_point = spawn_point
	_boss_entrance_position = position
	return true


func handle_player_death() -> void:
	if _state != FlowState.PLAYING:
		return
	_capture_no_loss_state_before_death()
	_state = FlowState.DYING
	_death_remaining_sec = DEATH_ANIMATION_DURATION_SEC
	_invincibility_remaining_sec = 0.0
	_player_control_locked = true


func handle_enemy_defeated() -> void:
	if _state == FlowState.VICTORY:
		return
	_state = FlowState.VICTORY
	_player_control_locked = true
	victory_reached.emit()


func advance_time(delta_sec: float) -> void:
	var safe_delta: float = maxf(0.0, delta_sec)
	match _state:
		FlowState.DYING:
			_advance_death_timer(safe_delta)
		FlowState.REVIVED:
			_advance_revived_timer(safe_delta)


func get_flow_state() -> StringName:
	match _state:
		FlowState.DYING:
			return &"dying"
		FlowState.REVIVED:
			return &"revived"
		FlowState.VICTORY:
			return &"victory"
		_:
			return &"playing"


func is_player_control_locked() -> bool:
	return _player_control_locked


func get_invincibility_remaining() -> float:
	return _invincibility_remaining_sec


func select_respawn_point() -> Dictionary:
	if _is_boss_encounter_active:
		return _build_respawn_point(
			&"boss_entrance",
			_boss_entrance_scene_id,
			_boss_entrance_spawn_point,
			_boss_entrance_position
		)

	var savepoint: Dictionary = _get_last_discovered_savepoint()
	if _is_valid_respawn_point(savepoint):
		return _normalize_respawn_point(savepoint, &"savepoint")
	return _build_clan_base_respawn_point()


func get_last_selected_respawn_point() -> Dictionary:
	return _last_selected_respawn_point.duplicate(true)


func _advance_death_timer(delta_sec: float) -> void:
	_death_remaining_sec = maxf(0.0, _death_remaining_sec - delta_sec)
	if _death_remaining_sec > 0.0:
		return
	_state = FlowState.REVIVED
	_invincibility_remaining_sec = RESPAWN_INVINCIBILITY_SEC
	_player_control_locked = true
	_reset_boss_arena_to_entry()
	_restore_no_loss_state_after_death()
	var respawn_point: Dictionary = select_respawn_point()
	var transition_applied: bool = _apply_scene_transition(respawn_point)
	if not transition_applied and String(respawn_point.get("source", "")) != "clan_base":
		respawn_point = _build_clan_base_respawn_point()
		_apply_scene_transition(respawn_point)
	_last_selected_respawn_point = respawn_point.duplicate(true)
	respawn_requested.emit(_position_from_respawn_point(respawn_point), REVIVE_HP_PERCENTAGE)


func _advance_revived_timer(delta_sec: float) -> void:
	_invincibility_remaining_sec = maxf(0.0, _invincibility_remaining_sec - delta_sec)
	if _invincibility_remaining_sec > 0.0:
		return
	_state = FlowState.PLAYING
	_player_control_locked = false


func _capture_boss_arena_snapshot() -> Dictionary:
	if not _is_boss_encounter_active:
		return {}
	if not _boss_arena_adapter.has_method("capture_boss_arena_snapshot"):
		return {}
	var snapshot: Variant = _boss_arena_adapter.call("capture_boss_arena_snapshot")
	if not snapshot is Dictionary:
		return {}
	return (snapshot as Dictionary).duplicate(true)


func _reset_boss_arena_to_entry() -> void:
	if not _is_boss_encounter_active or _boss_arena_adapter == null:
		return
	_call_boss_arena_hook("cleanup_temporary_summons")
	_call_boss_arena_hook("clear_arena_locks")
	_call_boss_arena_hook("clear_combat_adapters")
	if _boss_arena_adapter.has_method("reset_boss_arena_to_snapshot"):
		_boss_arena_adapter.call("reset_boss_arena_to_snapshot", _boss_arena_snapshot.duplicate(true))


func _call_boss_arena_hook(method_name: StringName) -> void:
	if _boss_arena_adapter != null and _boss_arena_adapter.has_method(method_name):
		_boss_arena_adapter.call(method_name)


func _clear_boss_encounter() -> void:
	_is_boss_encounter_active = false
	_boss_arena_adapter = null
	_boss_arena_snapshot.clear()


func _capture_no_loss_state_before_death() -> void:
	_clear_no_loss_state_snapshot()
	if _no_loss_state_adapter == null:
		return
	if not _no_loss_state_adapter.has_method("capture_no_loss_state"):
		return
	var snapshot: Variant = _no_loss_state_adapter.call("capture_no_loss_state")
	if not snapshot is Dictionary:
		return
	_no_loss_state_snapshot = (snapshot as Dictionary).duplicate(true)
	_has_no_loss_state_snapshot = true


func _restore_no_loss_state_after_death() -> void:
	if not _has_no_loss_state_snapshot or _no_loss_state_adapter == null:
		return
	if _no_loss_state_adapter.has_method("restore_no_loss_state"):
		_no_loss_state_adapter.call("restore_no_loss_state", _no_loss_state_snapshot.duplicate(true))


func _clear_no_loss_state_snapshot() -> void:
	_no_loss_state_snapshot.clear()
	_has_no_loss_state_snapshot = false


func _get_last_discovered_savepoint() -> Dictionary:
	if (
		_savepoint_adapter == null
		or not _savepoint_adapter.has_method("get_last_discovered_savepoint")
	):
		return {}
	var raw_savepoint: Variant = _savepoint_adapter.call("get_last_discovered_savepoint")
	if not raw_savepoint is Dictionary:
		return {}
	return Dictionary(raw_savepoint).duplicate(true)


func _is_valid_respawn_point(respawn_point: Dictionary) -> bool:
	var normalized: Dictionary = _normalize_respawn_point(respawn_point, &"savepoint")
	if normalized.is_empty():
		return false
	var scene_id: StringName = StringName(normalized.get("scene_id", ""))
	if scene_id == &"":
		return false
	if _scene_transition_adapter != null and _scene_transition_adapter.has_method("has_scene"):
		if not bool(_scene_transition_adapter.call("has_scene", scene_id)):
			return false
	return true


func _normalize_respawn_point(respawn_point: Dictionary, source: StringName) -> Dictionary:
	var scene_id: StringName = StringName(respawn_point.get("scene_id", ""))
	var spawn_point: StringName = StringName(respawn_point.get("spawn_point", ""))
	if scene_id == &"" or spawn_point == &"":
		return {}
	return _build_respawn_point(
		source,
		scene_id,
		spawn_point,
		_position_from_respawn_point(respawn_point),
		String(respawn_point.get("id", ""))
	)


func _build_clan_base_respawn_point() -> Dictionary:
	return _build_respawn_point(
		&"clan_base",
		_clan_base_scene_id,
		_clan_base_spawn_point,
		_clan_base_position
	)


func _build_respawn_point(
	source: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	position: Vector2,
	savepoint_id: String = ""
) -> Dictionary:
	var point: Dictionary = {
		"source": String(source),
		"scene_id": String(scene_id),
		"spawn_point": String(spawn_point),
		"position": _vector2_to_dictionary(position),
	}
	if not savepoint_id.is_empty():
		point["id"] = savepoint_id
	return point


func _apply_scene_transition(respawn_point: Dictionary) -> bool:
	if _scene_transition_adapter == null or not _scene_transition_adapter.has_method("change_scene"):
		return true
	var scene_id: StringName = StringName(respawn_point.get("scene_id", ""))
	var spawn_point: StringName = StringName(respawn_point.get("spawn_point", ""))
	if scene_id == &"" or spawn_point == &"":
		return false
	return bool(_scene_transition_adapter.call("change_scene", scene_id, spawn_point))


func _position_from_respawn_point(respawn_point: Dictionary) -> Vector2:
	var value: Variant = respawn_point.get("position", _clan_base_position)
	if value is Vector2:
		return value
	if value is Dictionary:
		var position_data: Dictionary = Dictionary(value)
		return Vector2(
			float(position_data.get("x", _clan_base_position.x)),
			float(position_data.get("y", _clan_base_position.y))
		)
	return _clan_base_position


func _vector2_to_dictionary(value: Vector2) -> Dictionary:
	return {
		"x": value.x,
		"y": value.y,
	}
