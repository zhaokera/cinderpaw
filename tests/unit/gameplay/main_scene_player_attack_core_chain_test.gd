## Runtime player attack integration through Core combat/collision/health/weapon components.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")

var scene


func before_test() -> void:
	scene = MAIN_SCENE.instantiate()
	add_child(scene)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_player_light_attack_damages_enemy_through_core_chain_once() -> void:
	if not _assert_runtime_attack_contract():
		return
	var player = scene.get_node("Player")
	var enemy = scene.get_node("Enemy")
	var player_collision = player.get_collision_component()
	var enemy_collision = enemy.get_collision_component()
	var combat_presentation = scene.get_node("CombatPresentation")
	var enemy_start_hp: int = enemy.get_current_hp()

	assert_bool(player.request_attack()).is_true()
	assert_bool(player_collision.is_hitbox_active(&"cat_claw_light")).is_true()
	assert_int(combat_presentation.get_active_trail_count()).is_equal(3)

	player_collision.process_detection_frame({
		&"cat_claw_light": [enemy_collision.get_hurtbox()],
	})

	var metadata: Dictionary = scene.get_last_player_hit_metadata()
	var enemy_hp_after_hit: int = enemy.get_current_hp()
	assert_bool(enemy_hp_after_hit < enemy_start_hp).is_true()
	assert_int(int(metadata.get("target_id", -1))).is_equal(enemy.get_entity_id())
	assert_str(String(metadata.get("weapon_id", &""))).is_equal("cat_claw")
	assert_str(String(metadata.get("attack_type", &""))).is_equal("light")
	assert_bool(int(metadata.get("final_damage", 0)) > 0).is_true()
	assert_int(player.get_combat_component().get_battle_stats()["hits_landed"]).is_equal(1)

	player_collision.process_detection_frame({
		&"cat_claw_light": [enemy_collision.get_hurtbox()],
	})

	assert_int(enemy.get_current_hp()).is_equal(enemy_hp_after_hit)
	assert_int(player.get_combat_component().get_battle_stats()["hits_landed"]).is_equal(1)


func test_main_scene_dispatches_long_tail_attack_started_to_blade_arc_vfx() -> void:
	if not _assert_runtime_attack_contract():
		return
	var player = scene.get_node("Player")
	var player_collision = player.get_collision_component()
	var combat_presentation = scene.get_node("CombatPresentation")

	scene.set_current_weapon_id(&"long_tail")

	assert_bool(player.request_attack()).is_true()
	assert_bool(player_collision.is_hitbox_active(&"long_tail_light")).is_true()

	var snapshot: Dictionary = combat_presentation.get_weapon_vfx_snapshot(&"long_tail")
	assert_int(int(snapshot.get("count", 0))).is_equal(1)
	assert_str(String(snapshot.get("texture_path", ""))).is_equal(
		"res://assets/generated/combat_long_tail_arc_runtime.png"
	)


func test_main_scene_dispatches_fish_bone_attack_started_to_shockwave_vfx() -> void:
	if not _assert_runtime_attack_contract():
		return
	var player = scene.get_node("Player")
	var player_collision = player.get_collision_component()
	var combat_presentation = scene.get_node("CombatPresentation")

	scene.set_current_weapon_id(&"fish_bone")

	assert_bool(player.request_attack()).is_true()
	assert_bool(player_collision.is_hitbox_active(&"fish_bone_light")).is_true()

	var snapshot: Dictionary = combat_presentation.get_weapon_vfx_snapshot(&"fish_bone")
	assert_int(int(snapshot.get("count", 0))).is_equal(1)
	assert_str(String(snapshot.get("texture_path", ""))).is_equal(
		"res://assets/generated/combat_fish_bone_wave_runtime.png"
	)


func test_electro_bell_runtime_hit_applies_slow_to_enemy_status_component() -> void:
	if not _assert_runtime_attack_contract():
		return
	var player = scene.get_node("Player")
	var enemy = scene.get_node("Enemy")
	var player_collision = player.get_collision_component()
	var enemy_collision = enemy.get_collision_component()
	var combat_presentation = scene.get_node("CombatPresentation")

	scene.set_current_weapon_id(&"electro_bell")

	assert_bool(player.request_attack()).is_true()
	assert_bool(player_collision.is_hitbox_active(&"electro_bell_light")).is_true()
	var snapshot: Dictionary = combat_presentation.get_weapon_vfx_snapshot(&"electro_bell")
	assert_int(int(snapshot.get("count", 0))).is_between(5, 8)
	assert_str(String(snapshot.get("texture_path", ""))).is_equal(
		"res://assets/generated/combat_electro_bell_arc_runtime.png"
	)

	player_collision.process_detection_frame({
		&"electro_bell_light": [enemy_collision.get_hurtbox()],
	})

	var metadata: Dictionary = scene.get_last_player_hit_metadata()
	var status_component = enemy.get_status_effect_component()
	assert_bool(status_component.has_status(&"slow")).is_true()
	assert_bool(bool(metadata.get("slow_status_applied", false))).is_true()
	assert_str(String(metadata.get("status_effect_id", &""))).is_equal("slow")
	assert_float(status_component.get_remaining_duration(&"slow")).is_equal_approx(2.0, 0.001)
	assert_float(status_component.get_movement_modifier()).is_equal_approx(0.7, 0.001)


func _assert_runtime_attack_contract() -> bool:
	var player = scene.get_node("Player")
	var enemy = scene.get_node("Enemy")
	var has_contract: bool = (
		player.has_method("request_attack")
		and player.has_method("get_combat_component")
		and player.has_method("get_collision_component")
		and enemy.has_method("get_entity_id")
		and enemy.has_method("get_collision_component")
		and enemy.has_method("get_status_effect_component")
		and scene.get_node("CombatPresentation").has_method("get_active_trail_count")
		and scene.get_node("CombatPresentation").has_method("get_weapon_vfx_snapshot")
		and scene.has_method("get_last_player_hit_metadata")
	)
	assert_bool(has_contract).is_true()
	return has_contract
