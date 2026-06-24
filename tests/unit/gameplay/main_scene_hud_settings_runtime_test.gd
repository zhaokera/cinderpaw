## Runtime wiring for HUD settings that affect combat presentation.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const ENEMY_HITBOX_ID: StringName = &"shadow_beast_bite"
const ATTACK_TELL_FRAMES: int = 8

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


func test_damage_number_toggle_controls_runtime_hit_numbers_without_muting_impact() -> void:
	var hud: Node = scene.get_node("HUD")
	var player: Node = scene.get_node("Player")
	var enemy: Node = scene.get_node("Enemy")
	var combat_presentation: Node = scene.get_node("CombatPresentation")
	assert_bool(hud.has_method("set_damage_numbers_enabled")).is_true()
	assert_bool(combat_presentation.has_method("get_active_damage_number_count")).is_true()
	assert_bool(combat_presentation.has_method("get_active_spark_count")).is_true()
	if not (
		hud.has_method("set_damage_numbers_enabled")
		and combat_presentation.has_method("get_active_damage_number_count")
		and combat_presentation.has_method("get_active_spark_count")
	):
		return

	hud.call("set_damage_numbers_enabled", false)
	var start_hp: int = int(player.call("get_current_hp"))

	_land_enemy_attack(enemy, player)

	assert_bool(int(player.call("get_current_hp")) < start_hp).is_true()
	assert_int(int(combat_presentation.call("get_active_damage_number_count"))).is_equal(0)
	assert_int(int(combat_presentation.call("get_active_spark_count"))).is_between(5, 8)


func test_battle_summary_toggle_opens_lesson_panel_on_player_death() -> void:
	var hud: Node = scene.get_node("HUD")
	var player: Node = scene.get_node("Player")
	assert_bool(hud.has_method("set_battle_summary_enabled")).is_true()
	if not hud.has_method("set_battle_summary_enabled"):
		return

	hud.call("set_battle_summary_enabled", true)
	player.call("apply_damage", int(player.call("get_current_hp")), {
		"battle_stats": {
			"duration_sec": 12.0,
			"damage_dealt": 24,
			"damage_received": 100,
			"dodge_success_rate": 0.25,
			"parry_success_rate": 0.0,
		},
	})

	assert_str(String(hud.call("get_menu_mode"))).is_equal("battle_summary")
	assert_str(String(hud.call("get_menu_title"))).is_equal("Hunter's Lesson")


func _land_enemy_attack(enemy: Node, player: Node) -> void:
	assert_bool(bool(enemy.call("request_attack"))).is_true()
	enemy.call("advance_attack_frames", ATTACK_TELL_FRAMES)
	var enemy_collision: CollisionComponent = enemy.call("get_collision_component") as CollisionComponent
	var player_collision: CollisionComponent = player.call("get_collision_component") as CollisionComponent
	enemy_collision.process_detection_frame({
		ENEMY_HITBOX_ID: [player_collision.get_hurtbox()],
	})
