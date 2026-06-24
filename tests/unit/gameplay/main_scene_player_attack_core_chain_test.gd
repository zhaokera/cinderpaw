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
	var enemy_start_hp: int = enemy.get_current_hp()

	assert_bool(player.request_attack()).is_true()
	assert_bool(player_collision.is_hitbox_active(&"cat_claw_light")).is_true()

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


func test_electro_bell_runtime_hit_applies_slow_to_enemy_status_component() -> void:
	if not _assert_runtime_attack_contract():
		return
	var player = scene.get_node("Player")
	var enemy = scene.get_node("Enemy")
	var player_collision = player.get_collision_component()
	var enemy_collision = enemy.get_collision_component()

	scene.set_current_weapon_id(&"electro_bell")

	assert_bool(player.request_attack()).is_true()
	assert_bool(player_collision.is_hitbox_active(&"electro_bell_light")).is_true()

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
		and scene.has_method("get_last_player_hit_metadata")
	)
	assert_bool(has_contract).is_true()
	return has_contract
