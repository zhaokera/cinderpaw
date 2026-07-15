## Story160: Cat Claw T1-B is a persisted, weapon-scoped damage choice.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const CAT_CLAW_T1B_SKILL_ID: StringName = &"cat_claw_t1b"
const CAT_CLAW_DAMAGE_BONUS: float = 0.05

var _runtime_scenes: Array[Node2D] = []


func after_test() -> void:
	_stop_runtime_audio_players()
	for runtime_scene: Node2D in _runtime_scenes:
		if not is_instance_valid(runtime_scene):
			continue
		if runtime_scene.get_parent() != null:
			runtime_scene.get_parent().remove_child(runtime_scene)
		runtime_scene.free()
	_runtime_scenes.clear()


func test_cat_claw_t1b_spends_persists_and_increases_only_cat_claw_runtime_damage() -> void:
	var upgraded_scene: Node2D = _instantiate_main_scene()
	var skill_tree: Node = upgraded_scene.get_node("SkillTreeManager")

	assert_bool(bool(skill_tree.call("has_skill_definition", CAT_CLAW_T1B_SKILL_ID))).is_true()
	if not bool(skill_tree.call("has_skill_definition", CAT_CLAW_T1B_SKILL_ID)):
		return

	upgraded_scene.call("grant_skill_points", 1)
	upgraded_scene.call("show_skill_tree_menu")
	var hud: Node = upgraded_scene.get_node("HUD")
	assert_bool(bool(hud.call("select_next_skill_tree_entry"))).is_true()
	assert_str(String(hud.call("get_active_skill_tree_entry_id"))).is_equal(
		String(CAT_CLAW_T1B_SKILL_ID)
	)
	assert_str(String(hud.call("get_menu_subtitle"))).contains("Cat Claw T1")
	assert_str(String(hud.call("get_menu_subtitle"))).contains("5% more damage")

	assert_bool(bool(upgraded_scene.call("try_unlock_skill", CAT_CLAW_T1B_SKILL_ID))).is_true()
	assert_int(int(upgraded_scene.call("get_skill_points"))).is_equal(0)
	assert_bool(bool(upgraded_scene.call("has_skill", CAT_CLAW_T1B_SKILL_ID))).is_true()
	assert_float(float(skill_tree.call("get_stat_bonus", &"damage"))).is_equal_approx(
		CAT_CLAW_DAMAGE_BONUS,
		0.0001
	)

	var snapshot: Dictionary = upgraded_scene.call("capture_save_snapshot")
	var restored_scene: Node2D = _instantiate_main_scene()
	restored_scene.call("restore_save_snapshot", snapshot)
	assert_bool(bool(restored_scene.call("has_skill", CAT_CLAW_T1B_SKILL_ID))).is_true()
	assert_float(float(restored_scene.get_node("SkillTreeManager").call(
		"get_stat_bonus",
		&"damage"
	))).is_equal_approx(CAT_CLAW_DAMAGE_BONUS, 0.0001)

	var baseline_scene: Node2D = _instantiate_main_scene()
	var baseline_hit: Dictionary = _perform_perfect_light_hit(baseline_scene, &"cat_claw")
	var upgraded_hit: Dictionary = _perform_perfect_light_hit(upgraded_scene, &"cat_claw")
	var upgraded_modifiers: Dictionary = Dictionary(upgraded_hit.get("skill_modifiers", {}))
	assert_float(float(upgraded_modifiers.get("skill_damage_bonus", 0.0))).is_equal_approx(
		CAT_CLAW_DAMAGE_BONUS,
		0.0001
	)
	assert_float(float(upgraded_hit.get("attack_damage", 0.0))).is_equal_approx(
		float(baseline_hit.get("attack_damage", 0.0)) * (1.0 + CAT_CLAW_DAMAGE_BONUS),
		0.001
	)
	assert_int(int(baseline_hit.get("final_damage", 0))).is_equal(25)
	assert_int(int(upgraded_hit.get("final_damage", 0))).is_equal(26)

	var wrong_weapon_scene: Node2D = _instantiate_main_scene()
	wrong_weapon_scene.call("grant_skill_points", 1)
	assert_bool(bool(wrong_weapon_scene.call(
		"try_unlock_skill",
		CAT_CLAW_T1B_SKILL_ID
	))).is_true()
	wrong_weapon_scene.call("acquire_weapon", &"long_tail")
	wrong_weapon_scene.call("set_current_weapon_id", &"long_tail")
	var wrong_weapon_hit: Dictionary = _perform_perfect_light_hit(
		wrong_weapon_scene,
		&"long_tail"
	)
	var wrong_weapon_modifiers: Dictionary = Dictionary(
		wrong_weapon_hit.get("skill_modifiers", {})
	)
	assert_float(float(wrong_weapon_modifiers.get("skill_damage_bonus", 0.0))).is_equal_approx(
		0.0,
		0.0001
	)


func _instantiate_main_scene() -> Node2D:
	var runtime_scene: Node2D = MAIN_SCENE.instantiate() as Node2D
	add_child(runtime_scene)
	_runtime_scenes.append(runtime_scene)
	return runtime_scene


func _perform_perfect_light_hit(runtime_scene: Node2D, weapon_id: StringName) -> Dictionary:
	var player: Node = runtime_scene.get_node("Player")
	var enemy: Node = runtime_scene.get_node("Enemy")
	var player_collision: Node = player.call("get_collision_component")
	var enemy_collision: Node = enemy.call("get_collision_component")
	var weapon_component: Node = runtime_scene.get_node("WeaponComponent")
	var current_weapon: Resource = weapon_component.call("get_current_weapon") as Resource

	assert_str(String(current_weapon.get("weapon_id"))).is_equal(String(weapon_id))
	assert_bool(bool(player.call("request_attack"))).is_true()

	var hitbox_id: StringName = StringName("%s_light" % String(weapon_id))
	player_collision.call("advance_hitbox_frames", 4)
	player_collision.call("process_detection_frame", {
		hitbox_id: [enemy_collision.call("get_hurtbox")],
	})
	var hit_metadata: Dictionary = runtime_scene.call("get_last_player_hit_metadata")
	assert_int(int(hit_metadata.get("combo_index", -1))).is_equal(0)
	assert_int(int(hit_metadata.get("hit_frame", -1))).is_equal(2)
	assert_str(String(hit_metadata.get("weapon_id", ""))).is_equal(String(weapon_id))
	return hit_metadata


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer2D:
			var audio_player: AudioStreamPlayer2D = child as AudioStreamPlayer2D
			audio_player.stop()
			audio_player.stream = null
