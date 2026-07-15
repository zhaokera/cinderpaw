## Player Abilities Story 156: Mainline Boss encounters activate sequentially.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const RAT_KING_DEFEATED_FLAG: StringName = &"boss_rat_king_defeated"
const HIDDEN_DOUBLE_JUMP_FLAG: StringName = &"hidden_boss_echo_double_jump_claimed"

var _spawned_scenes: Array[Node] = []


func after_test() -> void:
	for scene: Node in _spawned_scenes:
		if not is_instance_valid(scene):
			continue
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	_spawned_scenes.clear()


func test_rat_king_victory_restore_hands_main_encounter_to_boss2_once() -> void:
	var scene: Node2D = _instantiate_main_scene()
	assert_bool(scene.has_method("get_boss2_encounter_handoff_diagnostics")).is_true()
	if not scene.has_method("get_boss2_encounter_handoff_diagnostics"):
		return

	var initial: Dictionary = scene.call("get_boss2_encounter_handoff_diagnostics")
	_assert_rat_king_encounter(initial)
	var boss2: Node = scene.get_node("Boss2EchoGuardian")
	assert_bool(scene.call("apply_damage", int(boss2.call("get_entity_id")), 1, {
		"source": &"story156_inactive_boss2",
	})).is_false()
	assert_bool(bool(boss2.call("request_attack"))).is_false()

	scene.call("set_world_progress_flag", HIDDEN_DOUBLE_JUMP_FLAG, true)
	var hidden_path: Dictionary = scene.call("get_boss2_encounter_handoff_diagnostics")
	_assert_rat_king_encounter(hidden_path)

	var rat_king: Node = scene.get_node("Enemy")
	assert_bool(scene.call("apply_damage", int(rat_king.call("get_entity_id")), int(
		rat_king.call("get_current_hp")
	), {"source": &"story156_rat_king_defeat"})).is_true()
	var pending: Dictionary = scene.call("get_boss2_encounter_handoff_diagnostics")
	assert_str(String(pending.get("game_flow_state", ""))).is_equal("victory_pending")
	assert_bool(bool(pending.get("boss2_encounter_active", true))).is_false()
	assert_bool(bool(pending.get("boss2_visible", true))).is_false()
	assert_bool(bool(pending.get("boss2_arena_frame_visible", true))).is_false()
	assert_bool(bool(pending.get("boss2_room_seals_enabled", true))).is_false()
	assert_bool(bool(pending.get("boss2_camera_lock_enabled", true))).is_false()

	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var restored: Node2D = _instantiate_main_scene()
	restored.call("restore_save_snapshot", snapshot)
	var activated: Dictionary = restored.call("get_boss2_encounter_handoff_diagnostics")
	assert_bool(bool(activated.get("rat_king_defeated", false))).is_true()
	assert_bool(bool(activated.get("rat_king_visible", true))).is_false()
	assert_bool(bool(activated.get("boss2_encounter_active", false))).is_true()
	assert_bool(bool(activated.get("boss2_visible", false))).is_true()
	assert_bool(bool(activated.get("boss2_has_target", false))).is_true()
	assert_int(int(activated.get("boss2_collision_layer", 0))).is_greater(0)
	assert_bool(bool(activated.get("boss2_arena_frame_visible", false))).is_true()
	assert_bool(bool(activated.get("boss2_room_seals_enabled", false))).is_true()
	assert_bool(bool(activated.get("boss2_camera_lock_enabled", false))).is_true()
	assert_str(String(activated.get("boss_hud_label", ""))).contains("Echo Guardian")


func _instantiate_main_scene() -> Node2D:
	var scene := MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	_spawned_scenes.append(scene)
	return scene


func _assert_rat_king_encounter(diagnostics: Dictionary) -> void:
	assert_bool(bool(diagnostics.get("rat_king_defeated", true))).is_false()
	assert_bool(bool(diagnostics.get("rat_king_visible", false))).is_true()
	assert_bool(bool(diagnostics.get("boss2_encounter_active", true))).is_false()
	assert_bool(bool(diagnostics.get("boss2_visible", true))).is_false()
	assert_bool(bool(diagnostics.get("boss2_has_target", true))).is_false()
	assert_int(int(diagnostics.get("boss2_collision_layer", -1))).is_equal(0)
	assert_bool(bool(diagnostics.get("boss2_arena_frame_visible", true))).is_false()
	assert_bool(bool(diagnostics.get("boss2_room_seals_enabled", true))).is_false()
	assert_bool(bool(diagnostics.get("boss2_camera_lock_enabled", true))).is_false()
	assert_str(String(diagnostics.get("boss_hud_label", ""))).contains("垃圾桶鼠王")
