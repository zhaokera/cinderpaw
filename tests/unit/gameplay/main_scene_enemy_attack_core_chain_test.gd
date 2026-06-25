## Story 009: MainScene enemy attack Core chain.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const ENEMY_HITBOX_ID: StringName = &"rat_king_claw"
const EXPECTED_ATTACK_DAMAGE: int = 12

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


func test_enemy_attack_tell_then_active_hitbox_damages_player_once() -> void:
	var player: Node = scene.get_node("Player")
	var enemy: Node = scene.get_node("Enemy")
	var combat_presentation: Node = scene.get_node("CombatPresentation")
	assert_bool(player.has_method("apply_damage")).is_true()
	assert_bool(player.has_method("get_collision_component")).is_true()
	assert_bool(enemy.has_method("request_attack")).is_true()
	assert_bool(enemy.has_method("request_attack_pattern")).is_true()
	assert_bool(enemy.has_method("advance_attack_frames")).is_true()
	assert_bool(enemy.has_method("get_current_attack_startup_frames")).is_true()
	assert_bool(enemy.has_method("get_collision_component")).is_true()
	assert_bool(enemy.has_method("get_last_enemy_attack_metadata")).is_true()
	assert_bool(combat_presentation.has_method("get_active_damage_number_count")).is_true()
	if not (
		player.has_method("apply_damage")
		and player.has_method("get_collision_component")
		and enemy.has_method("request_attack_pattern")
		and enemy.has_method("advance_attack_frames")
		and enemy.has_method("get_current_attack_startup_frames")
		and enemy.has_method("get_collision_component")
		and enemy.has_method("get_last_enemy_attack_metadata")
		and combat_presentation.has_method("get_active_damage_number_count")
	):
		return

	var start_hp: int = int(player.call("get_current_hp"))
	assert_bool(bool(enemy.call("request_attack_pattern", &"claw_swipe"))).is_true()
	assert_str(String(enemy.get_node("Sprite").get("animation"))).is_equal("claw_swipe")

	var enemy_collision: CollisionComponent = enemy.call("get_collision_component") as CollisionComponent
	var player_collision: CollisionComponent = player.call("get_collision_component") as CollisionComponent
	assert_bool(enemy_collision.is_hitbox_active(ENEMY_HITBOX_ID)).is_false()

	enemy.call("advance_attack_frames", int(enemy.call("get_current_attack_startup_frames")))
	assert_str(String(enemy.get_node("Sprite").get("animation"))).is_equal("claw_swipe")
	assert_bool(enemy_collision.is_hitbox_active(ENEMY_HITBOX_ID)).is_true()

	enemy_collision.process_detection_frame({
		ENEMY_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	var hp_after_hit: int = int(player.call("get_current_hp"))
	assert_bool(hp_after_hit < start_hp).is_true()
	assert_int(start_hp - hp_after_hit).is_equal(EXPECTED_ATTACK_DAMAGE)

	var metadata: Dictionary = enemy.call("get_last_enemy_attack_metadata")
	assert_int(int(metadata.get("target_id", -1))).is_equal(1)
	assert_str(String(metadata.get("hitbox_id", &""))).is_equal("rat_king_claw")
	assert_str(String(metadata.get("pattern_id", &""))).is_equal("claw_swipe")
	assert_int(int(metadata.get("final_damage", 0))).is_equal(EXPECTED_ATTACK_DAMAGE)
	assert_int(int(combat_presentation.call("get_active_damage_number_count"))).is_equal(1)

	enemy_collision.process_detection_frame({
		ENEMY_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_after_hit)


func test_enemy_attack_rejects_reentry_during_tell_and_recovers() -> void:
	var enemy: Node = scene.get_node("Enemy")
	assert_bool(enemy.has_method("request_attack")).is_true()
	assert_bool(enemy.has_method("request_attack_pattern")).is_true()
	assert_bool(enemy.has_method("advance_attack_frames")).is_true()
	assert_bool(enemy.has_method("get_current_attack_startup_frames")).is_true()
	if not (
		enemy.has_method("request_attack_pattern")
		and enemy.has_method("advance_attack_frames")
		and enemy.has_method("get_current_attack_startup_frames")
	):
		return

	assert_bool(bool(enemy.call("request_attack_pattern", &"claw_swipe"))).is_true()
	assert_bool(bool(enemy.call("request_attack_pattern", &"claw_swipe"))).is_false()

	enemy.call("advance_attack_frames", int(enemy.call("get_current_attack_startup_frames")) + 4)
	assert_bool(bool(enemy.call("request_attack_pattern", &"claw_swipe"))).is_false()

	enemy.call("advance_attack_frames", 48)
	assert_bool(bool(enemy.call("request_attack_pattern", &"claw_swipe"))).is_true()
