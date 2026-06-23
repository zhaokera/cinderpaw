## Runtime encounter flow for victory, death delay, and quick respawn.
extends Node
class_name GameFlowController

signal respawn_requested(position: Vector2, revive_hp_percentage: float)
signal victory_reached

const DEATH_ANIMATION_DURATION_SEC: float = 1.5
const RESPAWN_INVINCIBILITY_SEC: float = 2.0
const REVIVE_HP_PERCENTAGE: float = 0.5

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


func _process(delta: float) -> void:
	advance_time(delta)


func start_encounter(respawn_position: Vector2) -> void:
	_respawn_position = respawn_position
	_state = FlowState.PLAYING
	_death_remaining_sec = 0.0
	_invincibility_remaining_sec = 0.0
	_player_control_locked = false
	_clear_boss_encounter()
	_clear_no_loss_state_snapshot()


func start_boss_encounter(arena_entrance_position: Vector2, boss_arena_adapter: Object) -> void:
	start_encounter(arena_entrance_position)
	_is_boss_encounter_active = boss_arena_adapter != null
	_boss_arena_adapter = boss_arena_adapter
	_boss_arena_snapshot = _capture_boss_arena_snapshot()


func set_no_loss_state_adapter(no_loss_state_adapter: Object) -> void:
	_no_loss_state_adapter = no_loss_state_adapter
	_clear_no_loss_state_snapshot()


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


func _advance_death_timer(delta_sec: float) -> void:
	_death_remaining_sec = maxf(0.0, _death_remaining_sec - delta_sec)
	if _death_remaining_sec > 0.0:
		return
	_state = FlowState.REVIVED
	_invincibility_remaining_sec = RESPAWN_INVINCIBILITY_SEC
	_player_control_locked = true
	_reset_boss_arena_to_entry()
	_restore_no_loss_state_after_death()
	respawn_requested.emit(_respawn_position, REVIVE_HP_PERCENTAGE)


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
