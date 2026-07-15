## Story 017: Rat King defeat remains visible before the reward menu.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const HOLD_SEC: float = 3.0

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


func test_rat_king_death_holds_world_view_before_showing_reward_menu() -> void:
	var enemy: Node = scene.get_node("Enemy")
	var sprite: AnimatedSprite2D = enemy.get_node("Sprite") as AnimatedSprite2D
	var flow: Node = scene.get_node("GameFlowController")
	var hud: Node = scene.get_node("HUD")
	var boss_hud := scene.get_node("HUD/HudRoot/BossHudPanel") as Control
	flow.set_process(false)

	enemy.call("apply_damage", int(enemy.call("get_current_hp")), {
		"source": &"rat_king_victory_death_hold_test",
	})
	await get_tree().process_frame

	assert_str(String(sprite.animation)).is_equal("death")
	assert_int(sprite.sprite_frames.get_frame_count(&"death")).is_equal(3)
	assert_str(String(flow.call("get_flow_state"))).is_equal("victory_pending")
	assert_bool(bool(flow.call("is_player_control_locked"))).is_true()
	assert_bool(bool(hud.call("is_menu_visible"))).is_false()
	assert_bool(boss_hud.visible).override_failure_message(
		"Rat King death hold must not replace its HUD with another active boss"
	).is_false()
	assert_bool(flow.has_method("get_victory_presentation_remaining_sec")).is_true()
	if flow.has_method("get_victory_presentation_remaining_sec"):
		assert_float(float(flow.call(
			"get_victory_presentation_remaining_sec"
		))).is_equal_approx(HOLD_SEC, 0.001)

	flow.call("advance_time", HOLD_SEC - 0.01)
	assert_str(String(flow.call("get_flow_state"))).is_equal("victory_pending")
	assert_bool(bool(hud.call("is_menu_visible"))).is_false()

	flow.call("handle_enemy_defeated")
	flow.call("handle_player_death")
	flow.call("advance_time", 0.02)

	assert_str(String(flow.call("get_flow_state"))).is_equal("victory")
	assert_bool(bool(hud.call("is_menu_visible"))).is_true()
	assert_str(String(hud.call("get_menu_title"))).is_equal("Rat King defeated")
	assert_bool(String(hud.call("get_menu_subtitle")).contains(
		"Dash unlocked +50 Gears +5 SP"
	)).is_true()
