## Runtime skill-tree spending slice: spend Rat King SP into a visible Cat Claw T1-A upgrade.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const CAT_CLAW_T1A_SKILL_ID: StringName = &"cat_claw_t1a"
const QUICKSTEP_LUNGE_PX: float = 8.0

var scene: Node2D


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_pause_menu_opens_skill_tree_and_spends_rat_king_skill_point_on_cat_claw_t1a() -> void:
	var enemy: Node = scene.get_node("Enemy")
	var hud: Node = scene.get_node("HUD")

	enemy.call("apply_damage", int(enemy.call("get_current_hp")), {
		"source": &"skill_tree_spending_ui_runtime_test",
	})

	assert_int(int(scene.call("get_skill_points"))).is_equal(5)
	assert_bool(scene.has_method("show_skill_tree_menu")).is_true()
	assert_bool(scene.has_method("try_unlock_skill")).is_true()
	assert_bool(hud.has_method("show_skill_tree_menu")).is_true()
	assert_bool(hud.has_signal("skill_unlock_requested")).is_true()
	assert_bool(hud.has_signal("menu_skill_tree_requested")).is_true()
	if not scene.has_method("show_skill_tree_menu") or not scene.has_method("try_unlock_skill"):
		return

	scene.call("show_skill_tree_menu")

	assert_str(String(hud.call("get_menu_mode"))).is_equal("skill_tree")
	assert_str(String(hud.call("get_menu_title"))).is_equal("Skill Tree")
	assert_str(String(hud.call("get_menu_subtitle"))).contains("SP 5")
	assert_str(String(hud.call("get_menu_subtitle"))).contains("Quickstep Claws")
	assert_str(String(hud.call("get_skill_unlock_button_text"))).is_equal("Learn Quickstep Claws")
	assert_bool(bool(hud.call("is_skill_unlock_button_disabled"))).is_false()

	assert_bool(bool(scene.call("try_unlock_skill", CAT_CLAW_T1A_SKILL_ID))).is_true()

	var progress: Dictionary = scene.call("get_runtime_progress_state")
	assert_int(int(progress.get("skill_points", -1))).is_equal(4)
	assert_bool(Array(progress.get("unlocked_skills", [])).has(String(CAT_CLAW_T1A_SKILL_ID))).is_true()
	var modifiers: Array = scene.call("get_skill_tree_modifiers", &"light_attack_2")
	assert_int(modifiers.size()).is_equal(1)
	var modifier: Dictionary = modifiers[0]
	assert_str(String(modifier.get("skill_id", ""))).is_equal(String(CAT_CLAW_T1A_SKILL_ID))
	assert_str(String(modifier.get("stat_key", ""))).is_equal("dash_distance")
	assert_str(String(modifier.get("operation", ""))).is_equal("ADD")
	assert_float(float(modifier.get("value", 0.0))).is_equal_approx(QUICKSTEP_LUNGE_PX, 0.001)
	assert_str(String(hud.call("get_notification_text"))).is_equal("Quickstep Claws learned")
	assert_str(String(hud.call("get_skill_unlock_button_text"))).is_equal("Quickstep Claws learned")
	assert_bool(bool(hud.call("is_skill_unlock_button_disabled"))).is_true()


func test_cat_claw_t1a_persists_and_lunges_second_light_attack_forward() -> void:
	var player: Node = scene.get_node("Player")
	var player_collision: Node = player.call("get_collision_component")
	var combat: Node = player.call("get_combat_component")

	assert_bool(player.has_method("get_last_skill_lunge_px")).is_true()
	if not player.has_method("get_last_skill_lunge_px"):
		return
	assert_float(float(player.call("get_last_skill_lunge_px"))).is_equal_approx(0.0, 0.001)

	assert_bool(bool(scene.call("try_unlock_skill", CAT_CLAW_T1A_SKILL_ID))).is_false()
	scene.call("grant_skill_points", 1)
	assert_bool(bool(scene.call("try_unlock_skill", CAT_CLAW_T1A_SKILL_ID))).is_true()

	var start_x: float = player.global_position.x
	assert_bool(bool(player.call("request_attack"))).is_true()
	combat.call("advance_attack_frames", 4)
	assert_bool(bool(player.call("request_attack"))).is_true()
	combat.call("advance_attack_frames", 4)
	assert_int(int(combat.call("get_combo_index"))).is_equal(1)
	combat.call("advance_attack_frames", 6)

	var hitbox: Area2D = player_collision.call("get_hitbox", &"cat_claw_light") as Area2D
	var metadata: Dictionary = hitbox.call("get_attack_metadata")
	assert_int(int(metadata.get("combo_index", -1))).is_equal(1)
	assert_float(float(metadata.get("skill_lunge_px", 0.0))).is_equal_approx(QUICKSTEP_LUNGE_PX, 0.001)
	assert_float(hitbox.position.x).is_equal_approx(16.0 + QUICKSTEP_LUNGE_PX, 0.001)
	assert_float(float(player.call("get_last_skill_lunge_px"))).is_equal_approx(QUICKSTEP_LUNGE_PX, 0.001)
	assert_float(player.global_position.x).is_equal_approx(start_x + QUICKSTEP_LUNGE_PX, 0.001)

	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var player_state: Dictionary = Dictionary(snapshot.get("player_state", {}))
	assert_bool(Array(player_state.get("unlocked_skills", [])).has(String(CAT_CLAW_T1A_SKILL_ID))).is_true()

	var restored_scene: Node2D = MAIN_SCENE.instantiate() as Node2D
	add_child(restored_scene)
	restored_scene.call("restore_save_snapshot", snapshot)

	assert_int(int(restored_scene.call("get_skill_points"))).is_equal(0)
	assert_bool(Array(restored_scene.call("get_runtime_progress_state").get("unlocked_skills", [])).has(
		String(CAT_CLAW_T1A_SKILL_ID)
	)).is_true()

	restored_scene.get_parent().remove_child(restored_scene)
	restored_scene.free()
