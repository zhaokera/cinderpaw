## Runtime wiring for HUD settings that affect combat presentation.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const ENEMY_HITBOX_ID: StringName = &"rat_king_claw"
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


func test_runtime_progress_state_hands_off_hud_accessibility_settings() -> void:
	var hud: Node = scene.get_node("HUD")
	var combat_presentation: Node = scene.get_node("CombatPresentation")
	assert_bool(hud.has_method("capture_settings_state")).is_true()
	assert_bool(hud.has_method("restore_settings_state")).is_true()
	assert_bool(combat_presentation.has_method("get_colorblind_mode")).is_true()
	if not hud.has_method("capture_settings_state") or not hud.has_method("restore_settings_state"):
		return

	hud.call("set_hud_scale", 1.5)
	hud.call("set_colorblind_mode", &"blue_yellow")
	hud.call("set_battle_summary_enabled", true)
	hud.call("set_damage_numbers_enabled", false)

	var snapshot: Dictionary = scene.call("capture_no_loss_state")

	assert_bool(snapshot.has("settings")).is_true()
	var settings: Dictionary = Dictionary(snapshot.get("settings", {}))
	assert_float(float(settings.get("hud_scale", 0.0))).is_equal_approx(1.5, 0.001)
	assert_str(String(settings.get("colorblind_mode", ""))).is_equal("blue_yellow")
	assert_bool(bool(settings.get("battle_summary_enabled", false))).is_true()
	assert_bool(bool(settings.get("damage_numbers_enabled", true))).is_false()

	hud.call("set_hud_scale", 0.5)
	hud.call("set_colorblind_mode", &"none")
	hud.call("set_battle_summary_enabled", false)
	hud.call("set_damage_numbers_enabled", true)

	scene.call("restore_no_loss_state", snapshot)

	assert_float(float(hud.call("get_hud_scale"))).is_equal_approx(1.5, 0.001)
	assert_str(String(hud.call("get_colorblind_mode"))).is_equal("blue_yellow")
	if combat_presentation.has_method("get_colorblind_mode"):
		assert_str(String(combat_presentation.call("get_colorblind_mode"))).is_equal("blue_yellow")
	assert_bool(bool(hud.call("is_battle_summary_enabled"))).is_true()
	assert_bool(bool(hud.call("are_damage_numbers_enabled"))).is_false()


func test_hud_colorblind_mode_syncs_to_runtime_combat_particles() -> void:
	var hud: Node = scene.get_node("HUD")
	var combat_presentation: Node = scene.get_node("CombatPresentation")
	assert_bool(hud.has_method("set_colorblind_mode")).is_true()
	assert_bool(combat_presentation.has_method("get_colorblind_mode")).is_true()
	assert_bool(combat_presentation.has_method("get_last_spark_color")).is_true()
	if (
		not hud.has_method("set_colorblind_mode")
		or not combat_presentation.has_method("get_colorblind_mode")
		or not combat_presentation.has_method("get_last_spark_color")
	):
		return

	hud.call("set_colorblind_mode", &"red_green")
	_route_enemy_hit()

	assert_str(String(combat_presentation.call("get_colorblind_mode"))).is_equal("red_green")
	assert_str(_color_html(combat_presentation.call("get_last_spark_color"))).is_equal("4299e1")

	hud.call("set_colorblind_mode", &"blue_yellow")
	_route_enemy_hit()

	assert_str(String(combat_presentation.call("get_colorblind_mode"))).is_equal("blue_yellow")
	assert_str(_color_html(combat_presentation.call("get_last_spark_color"))).is_equal("fed7d7")


func test_player_focus_signal_reduces_runtime_combat_screen_shake() -> void:
	var player: Node = scene.get_node("Player")
	var health: Node = player.get_node("HealthComponent")
	var combat_presentation: Node = scene.get_node("CombatPresentation")
	assert_bool(health.has_signal("on_focus_mode_changed")).is_true()
	assert_bool(combat_presentation.has_method("is_focus_mode_active")).is_true()
	assert_bool(combat_presentation.has_method("get_screen_shake_intensity")).is_true()
	if (
		not health.has_signal("on_focus_mode_changed")
		or not combat_presentation.has_method("is_focus_mode_active")
		or not combat_presentation.has_method("get_screen_shake_intensity")
	):
		return

	var focus_signal: Signal = health.get("on_focus_mode_changed")
	focus_signal.emit(1, true, {
		"hp_percentage": 0.25,
	})
	_route_enemy_hit()

	assert_bool(bool(combat_presentation.call("is_focus_mode_active"))).is_true()
	assert_float(float(combat_presentation.call("get_screen_shake_intensity"))).is_equal_approx(
		1.4,
		0.001
	)


func _color_html(value: Variant) -> String:
	if value is Color:
		return (value as Color).to_html(false)
	return Color(value).to_html(false)


func _route_enemy_hit() -> void:
	scene.call("_on_enemy_attack_landed", 12, Vector2(96, 120), false)


func _land_enemy_attack(enemy: Node, player: Node) -> void:
	assert_bool(bool(enemy.call("request_attack"))).is_true()
	enemy.call("advance_attack_frames", ATTACK_TELL_FRAMES)
	var enemy_collision: CollisionComponent = enemy.call("get_collision_component") as CollisionComponent
	var player_collision: CollisionComponent = player.call("get_collision_component") as CollisionComponent
	enemy_collision.process_detection_frame({
		ENEMY_HITBOX_ID: [player_collision.get_hurtbox()],
	})
