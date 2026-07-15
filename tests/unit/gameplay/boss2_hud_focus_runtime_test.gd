## Story 023: Boss2 HUD focus uses the active Echo Guardian target.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const BOSS2_ENTITY_ID: int = 2200
const EXPECTED_BOSS2_MAX_HP: int = 36
const EXPECTED_BOSS2_HIT_DAMAGE: int = 14
const RAT_KING_DEFEATED_FLAG: StringName = &"boss_rat_king_defeated"

var scene: Node2D


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	scene.call("set_world_progress_flag", RAT_KING_DEFEATED_FLAG, true)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_boss2_hud_focuses_echo_guardian_after_rat_king_handoff() -> void:
	var hud: Node = scene.get_node("HUD")
	assert_bool(hud.has_method("get_boss_label_text")).is_true()
	if not hud.has_method("get_boss_label_text"):
		return

	var label: String = String(hud.call("get_boss_label_text"))
	assert_str(label).contains("Echo Guardian")
	assert_str(label).contains("36/36")
	assert_bool(label.contains("垃圾桶鼠王")).is_false()
	assert_bool(label.contains("300/300")).is_false()


func test_boss2_damage_updates_hud_and_rat_king_health_does_not_override_focus() -> void:
	var hud: Node = scene.get_node("HUD")
	var rat_king: Node = scene.get_node("Enemy")
	assert_bool(scene.has_method("apply_damage")).is_true()
	assert_bool(hud.has_method("get_boss_label_text")).is_true()
	assert_bool(rat_king.has_signal("enemy_health_changed")).is_true()
	if not scene.has_method("apply_damage") or not hud.has_method("get_boss_label_text"):
		return

	assert_bool(scene.call("apply_damage", BOSS2_ENTITY_ID, EXPECTED_BOSS2_HIT_DAMAGE, {
		"source": &"unit_test_boss2_hud_damage",
	})).is_true()

	var label: String = String(hud.call("get_boss_label_text"))
	assert_str(label).contains("Echo Guardian")
	assert_str(label).contains("22/36")

	rat_king.enemy_health_changed.emit(250, 300)
	label = String(hud.call("get_boss_label_text"))
	assert_str(label).contains("Echo Guardian")
	assert_str(label).contains("22/36")
	assert_bool(label.contains("垃圾桶鼠王")).is_false()


func test_boss2_defeat_and_restored_flag_hide_completed_boss_hud() -> void:
	var hud: Node = scene.get_node("HUD")
	var boss: Node = scene.get_node("Boss2EchoGuardian")
	assert_bool(scene.has_method("apply_damage")).is_true()
	assert_bool(scene.has_method("set_world_progress_flag")).is_true()
	assert_bool(hud.has_method("get_boss_label_text")).is_true()
	if not (
		scene.has_method("apply_damage")
		and scene.has_method("set_world_progress_flag")
		and hud.has_method("get_boss_label_text")
	):
		return

	assert_bool(scene.call("apply_damage", BOSS2_ENTITY_ID, int(boss.call("get_current_hp")), {
		"source": &"unit_test_boss2_hud_defeat",
	})).is_true()
	assert_bool(bool(Dictionary(hud.call("get_boss_portrait_diagnostics")).get(
		"panel_visible",
		true
	))).is_false()

	scene.call("set_world_progress_flag", &"boss_02_echo_guardian_defeated", true)
	assert_bool(bool(Dictionary(hud.call("get_boss_portrait_diagnostics")).get(
		"panel_visible",
		true
	))).is_false()


func test_restored_boss2_defeated_flag_immediately_hides_boss_hud() -> void:
	var hud: Node = scene.get_node("HUD")
	assert_bool(scene.has_method("set_world_progress_flag")).is_true()
	assert_bool(hud.has_method("get_boss_label_text")).is_true()
	if not scene.has_method("set_world_progress_flag") or not hud.has_method("get_boss_label_text"):
		return

	var label: String = String(hud.call("get_boss_label_text"))
	assert_str(label).contains("Echo Guardian")
	assert_str(label).contains("36/36")

	scene.call("set_world_progress_flag", &"boss_02_echo_guardian_defeated", true)
	assert_bool(bool(Dictionary(hud.call("get_boss_portrait_diagnostics")).get(
		"panel_visible",
		true
	))).is_false()
