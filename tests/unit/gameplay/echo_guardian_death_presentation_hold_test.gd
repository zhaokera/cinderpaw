## Combat Presentation Story018: Echo Guardian death remains visible before payoff.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const RAT_KING_DEFEATED_FLAG: StringName = &"boss_rat_king_defeated"
const BOSS2_ENTITY_ID: int = 2200
const HOLD_SEC: float = 2.0

var _scene: Node2D


func before_test() -> void:
	_scene = MAIN_SCENE.instantiate() as Node2D
	add_child(_scene)
	_scene.set_process(false)
	_scene.call("set_world_progress_flag", RAT_KING_DEFEATED_FLAG, true)


func after_test() -> void:
	if is_instance_valid(_scene):
		if _scene.get_parent() != null:
			_scene.get_parent().remove_child(_scene)
		_scene.free()
	_scene = null


func test_echo_guardian_death_holds_arena_before_double_jump_payoff() -> void:
	assert_bool(_scene.has_method("get_boss2_death_presentation_diagnostics")).is_true()
	assert_bool(_scene.has_method("advance_boss2_death_presentation")).is_true()
	if (
		not _scene.has_method("get_boss2_death_presentation_diagnostics")
		or not _scene.has_method("advance_boss2_death_presentation")
	):
		return

	var boss: Node = _scene.get_node("Boss2EchoGuardian")
	assert_bool(_scene.call("apply_damage", BOSS2_ENTITY_ID, int(
		boss.call("get_current_hp")
	), {"source": &"story018_echo_guardian_death_hold"})).is_true()

	var holding: Dictionary = _scene.call("get_boss2_death_presentation_diagnostics")
	_assert_holding_contract(holding)

	assert_bool(bool(_scene.call(
		"advance_boss2_death_presentation",
		HOLD_SEC - 0.01
	))).is_false()
	var almost_done: Dictionary = _scene.call(
		"get_boss2_death_presentation_diagnostics"
	)
	assert_bool(bool(almost_done.get("pending", false))).is_true()
	assert_bool(bool(almost_done.get("reward_available", true))).is_false()

	assert_bool(bool(_scene.call(
		"advance_boss2_death_presentation",
		0.02
	))).is_true()
	var completed: Dictionary = _scene.call(
		"get_boss2_death_presentation_diagnostics"
	)
	assert_bool(bool(completed.get("pending", true))).is_false()
	assert_float(float(completed.get("remaining_sec", -1.0))).is_equal_approx(0.0, 0.001)
	assert_bool(bool(completed.get("boss_visible", true))).is_false()
	assert_bool(bool(completed.get("reward_available", false))).is_true()
	assert_bool(bool(completed.get("camera_lock_enabled", true))).is_false()
	assert_bool(bool(completed.get("room_seals_enabled", true))).is_false()
	assert_bool(bool(completed.get("player_control_locked", true))).is_false()
	assert_bool(String(completed.get("notification_text", "")).contains(
		"Claim Double Jump"
	)).is_true()


func _assert_holding_contract(diagnostics: Dictionary) -> void:
	assert_bool(bool(diagnostics.get("pending", false))).is_true()
	assert_float(float(diagnostics.get("remaining_sec", -1.0))).is_equal_approx(
		HOLD_SEC,
		0.001
	)
	assert_bool(bool(diagnostics.get("boss_defeated", false))).is_true()
	assert_bool(bool(diagnostics.get("boss_visible", false))).is_true()
	assert_str(String(diagnostics.get("animation", ""))).is_equal("death")
	assert_int(int(diagnostics.get("death_frame_count", 0))).is_equal(3)
	assert_int(int(diagnostics.get("active_hitbox_count", -1))).is_equal(0)
	assert_bool(bool(diagnostics.get("reward_available", true))).is_false()
	assert_bool(bool(diagnostics.get("camera_lock_enabled", false))).is_true()
	assert_bool(bool(diagnostics.get("room_seals_enabled", false))).is_true()
	assert_bool(bool(diagnostics.get("player_control_locked", false))).is_true()
