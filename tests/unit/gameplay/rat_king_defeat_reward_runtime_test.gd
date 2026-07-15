## Runtime reward consumption for Rat King defeat in MainScene.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const RAT_KING_BOSS_ID: StringName = &"boss_01_rat_king"

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


func test_rat_king_defeat_consumes_configured_rewards_once_and_persists_progress() -> void:
	var enemy: Node = scene.get_node("Enemy")
	var hud: Node = scene.get_node("HUD")
	var flow: Node = scene.get_node("GameFlowController")
	var initial_progress: Dictionary = scene.call("get_runtime_progress_state")

	assert_int(int(initial_progress.get("currency", -1))).is_equal(0)
	assert_bool(Array(initial_progress.get("unlocked_abilities", [])).has("dash")).is_false()
	assert_int(int(initial_progress.get("skill_points", -1))).is_equal(0)

	enemy.call("apply_damage", int(enemy.call("get_current_hp")), {
		"source": &"rat_king_reward_runtime_test",
	})

	var progress: Dictionary = scene.call("get_runtime_progress_state")
	assert_int(int(progress.get("currency", 0))).is_equal(50)
	assert_bool(Array(progress.get("unlocked_abilities", [])).has("dash")).is_true()
	assert_int(int(progress.get("skill_points", 0))).is_equal(5)
	assert_bool(bool(progress.get("world_flags", {}).get("boss_rat_king_defeated", false))).is_true()
	var dash_gate: Node = scene.get_node_or_null("DashExplorationGate")
	assert_that(dash_gate).is_not_null()
	if dash_gate != null:
		assert_str(String(dash_gate.call("get_gate_state"))).is_equal("unlockable")
		assert_bool(bool(dash_gate.call("is_collision_blocking"))).is_true()

	assert_str(String(flow.call("get_flow_state"))).is_equal("victory_pending")
	assert_bool(bool(hud.call("is_menu_visible"))).is_false()
	flow.call("advance_time", 3.01)

	assert_str(String(hud.call("get_notification_text"))).is_equal("Dash unlocked +50 Gears +5 SP")
	assert_str(String(hud.call("get_menu_title"))).is_equal("Rat King defeated")
	assert_bool(String(hud.call("get_menu_subtitle")).contains("Dash")).is_true()
	assert_bool(String(hud.call("get_menu_subtitle")).contains("50 Gears")).is_true()
	assert_bool(String(hud.call("get_menu_subtitle")).contains("5 SP")).is_true()

	scene.call("_on_victory_reached")
	var repeated_progress: Dictionary = scene.call("get_runtime_progress_state")
	assert_int(int(repeated_progress.get("currency", 0))).is_equal(50)
	assert_int(int(repeated_progress.get("skill_points", 0))).is_equal(5)
	assert_int(Array(repeated_progress.get("unlocked_abilities", [])).count("dash")).is_equal(1)

	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var player_state: Dictionary = Dictionary(snapshot.get("player_state", {}))
	assert_int(int(player_state.get("currency", 0))).is_equal(50)
	assert_int(int(player_state.get("skill_points", 0))).is_equal(5)
	assert_bool(Array(player_state.get("unlocked_abilities", [])).has("dash")).is_true()
