## Story 022: Boss2 Echo Guardian telegraph strike runtime.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const BOSS_NODE_NAME: String = "Boss2EchoGuardian"
const REWARD_NODE_NAME: String = "Boss2DoubleJumpRewardSource"
const BOSS2_HITBOX_ID: StringName = &"boss2_echo_swipe"
const EXPECTED_ATTACK_DAMAGE: int = 14

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


func test_boss2_echo_swipe_startup_then_active_hitbox_damages_player_once() -> void:
	var boss: Node = scene.get_node(BOSS_NODE_NAME)
	var player: Node = scene.get_node("Player")
	var combat_presentation: Node = scene.get_node("CombatPresentation")
	assert_bool(boss.has_signal("enemy_attack_landed")).is_true()
	assert_bool(boss.has_method("request_attack")).is_true()
	assert_bool(boss.has_method("advance_attack_frames")).is_true()
	assert_bool(boss.has_method("get_current_attack_startup_frames")).is_true()
	assert_bool(boss.has_method("get_attack_phase")).is_true()
	assert_bool(boss.has_method("is_enemy_attack_active")).is_true()
	assert_bool(boss.has_method("get_collision_component")).is_true()
	assert_bool(boss.has_method("get_last_enemy_attack_metadata")).is_true()
	assert_bool(player.has_method("get_collision_component")).is_true()
	assert_bool(player.has_method("get_current_hp")).is_true()
	assert_bool(combat_presentation.has_method("get_active_damage_number_count")).is_true()
	if not (
		boss.has_signal("enemy_attack_landed")
		and boss.has_method("advance_attack_frames")
		and boss.has_method("get_current_attack_startup_frames")
		and boss.has_method("get_attack_phase")
		and boss.has_method("is_enemy_attack_active")
		and boss.has_method("get_collision_component")
		and boss.has_method("get_last_enemy_attack_metadata")
		and player.has_method("get_collision_component")
		and player.has_method("get_current_hp")
	):
		return

	var start_hp: int = int(player.call("get_current_hp"))
	assert_bool(bool(boss.call("request_attack"))).is_true()
	assert_str(String(boss.call("get_attack_phase"))).is_equal("startup")
	assert_str(String(boss.get_node("Sprite").get("animation"))).is_equal("attack")

	var boss_collision: CollisionComponent = boss.call("get_collision_component") as CollisionComponent
	var player_collision: CollisionComponent = player.call("get_collision_component") as CollisionComponent
	assert_that(boss_collision).is_not_null()
	assert_that(player_collision).is_not_null()
	if boss_collision == null or player_collision == null:
		return
	assert_bool(boss_collision.is_hitbox_active(BOSS2_HITBOX_ID)).is_false()

	boss.call("advance_attack_frames", int(boss.call("get_current_attack_startup_frames")))
	assert_bool(bool(boss.call("is_enemy_attack_active"))).is_true()
	assert_str(String(boss.call("get_attack_phase"))).is_equal("active")
	assert_bool(boss_collision.is_hitbox_active(BOSS2_HITBOX_ID)).is_true()

	boss_collision.process_detection_frame({
		BOSS2_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	var hp_after_hit: int = int(player.call("get_current_hp"))
	assert_int(start_hp - hp_after_hit).is_equal(EXPECTED_ATTACK_DAMAGE)
	assert_int(int(combat_presentation.call("get_active_damage_number_count"))).is_equal(1)

	var metadata: Dictionary = boss.call("get_last_enemy_attack_metadata")
	assert_int(int(metadata.get("target_id", -1))).is_equal(1)
	assert_bool(StringName(metadata.get("source", &"")) == &"boss2_echo_guardian").is_true()
	assert_bool(StringName(metadata.get("hitbox_id", &"")) == BOSS2_HITBOX_ID).is_true()
	assert_bool(StringName(metadata.get("weapon_id", &"")) == BOSS2_HITBOX_ID).is_true()
	assert_int(int(metadata.get("final_damage", 0))).is_equal(EXPECTED_ATTACK_DAMAGE)

	boss_collision.process_detection_frame({
		BOSS2_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_after_hit)


func test_boss2_echo_swipe_recovers_and_defeat_preserves_reward_path() -> void:
	var boss: Node = scene.get_node(BOSS_NODE_NAME)
	var reward: Node = scene.get_node(REWARD_NODE_NAME)
	assert_bool(boss.has_method("request_attack")).is_true()
	assert_bool(boss.has_method("advance_attack_frames")).is_true()
	assert_bool(boss.has_method("get_current_attack_startup_frames")).is_true()
	assert_bool(boss.has_method("get_attack_phase")).is_true()
	assert_bool(boss.has_method("get_collision_component")).is_true()
	assert_bool(boss.has_method("get_current_hp")).is_true()
	assert_bool(boss.has_method("is_defeated")).is_true()
	assert_bool(reward.has_method("is_claim_available")).is_true()
	if not (
		boss.has_method("advance_attack_frames")
		and boss.has_method("get_current_attack_startup_frames")
		and boss.has_method("get_attack_phase")
		and boss.has_method("get_collision_component")
		and boss.has_method("get_current_hp")
		and boss.has_method("is_defeated")
	):
		return

	assert_bool(bool(boss.call("request_attack"))).is_true()
	assert_bool(bool(boss.call("request_attack"))).is_false()
	boss.call("advance_attack_frames", int(boss.call("get_current_attack_startup_frames")) + 4)
	assert_bool(bool(boss.call("request_attack"))).is_false()

	boss.call("advance_attack_frames", 48)
	assert_str(String(boss.call("get_attack_phase"))).is_equal("idle")
	assert_bool(bool(boss.call("request_attack"))).is_true()

	var collision: CollisionComponent = boss.call("get_collision_component") as CollisionComponent
	boss.call("apply_damage", int(boss.call("get_current_hp")), {
		"source": &"unit_test_boss2_defeat",
	})
	assert_bool(bool(boss.call("is_defeated"))).is_true()
	assert_bool(bool(boss.call("request_attack"))).is_false()
	if collision != null:
		assert_bool(collision.is_hitbox_active(BOSS2_HITBOX_ID)).is_false()
	assert_bool(bool(reward.call("is_claim_available"))).is_true()


func test_player_hit_target_2200_resolves_weapon_effects_to_boss2() -> void:
	var boss: Node = scene.get_node(BOSS_NODE_NAME)
	var enemy: Node = scene.get_node("Enemy")
	assert_bool(boss.has_method("get_entity_id")).is_true()
	if not boss.has_method("get_entity_id"):
		return

	var resolved: Node = scene.call("_resolve_player_hit_target", {
		"target_id": int(boss.call("get_entity_id")),
	})
	assert_bool(resolved == boss).is_true()
	assert_bool(resolved == enemy).is_false()


func test_restored_boss2_defeated_flag_disables_hidden_threat() -> void:
	var boss: Node = scene.get_node(BOSS_NODE_NAME)
	assert_bool(scene.has_method("set_world_progress_flag")).is_true()
	assert_bool(boss.has_method("request_attack")).is_true()
	assert_bool(boss.has_method("is_defeated")).is_true()
	assert_bool(boss.has_method("get_collision_component")).is_true()
	if not (
		scene.has_method("set_world_progress_flag")
		and boss.has_method("request_attack")
		and boss.has_method("is_defeated")
		and boss.has_method("get_collision_component")
	):
		return

	scene.call("set_world_progress_flag", &"boss_02_echo_guardian_defeated", true)
	var collision: CollisionComponent = boss.call("get_collision_component") as CollisionComponent
	assert_bool(bool(boss.call("is_defeated"))).is_true()
	assert_bool(bool(boss.call("request_attack"))).is_false()
	assert_bool(boss.visible).is_false()
	if collision != null:
		assert_bool(collision.is_hitbox_active(BOSS2_HITBOX_ID)).is_false()
		assert_bool(collision.get_hurtbox_state() == CollisionComponent.HURTBOX_STATE_GONE).is_true()
