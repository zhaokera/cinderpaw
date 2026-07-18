## Story 175: Echo Guardian deterministic swipe/pounce playable loop.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const RAT_KING_DEFEATED_FLAG: StringName = &"boss_rat_king_defeated"
const SWIPE_PATTERN_ID: StringName = &"echo_swipe"
const POUNCE_PATTERN_ID: StringName = &"echo_pounce"
const SWIPE_HITBOX_ID: StringName = &"boss2_echo_swipe"
const POUNCE_HITBOX_ID: StringName = &"boss2_echo_pounce"
const POUNCE_TELL_ANIMATION: StringName = &"echo_pounce_tell"
const POUNCE_ACTIVE_ANIMATION: StringName = &"echo_pounce"
const POUNCE_RECOVERY_ANIMATION: StringName = &"echo_pounce_recovery"
const POUNCE_DAMAGE: int = 12

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


func test_swipe_then_phase_two_pounce_locks_one_landing_damage_window() -> void:
	var boss: Node = scene.get_node("Boss2EchoGuardian")
	var player: Node2D = scene.get_node("Player") as Node2D
	var required_api: bool = (
		boss.has_method("get_current_attack_pattern_id")
		and boss.has_method("get_current_attack_active_frames")
		and boss.has_method("get_current_attack_recovery_frames")
		and boss.has_method("get_secondary_attack_diagnostics")
	)
	assert_bool(required_api).override_failure_message(
		"Story175 RED: Echo Guardian must expose the secondary attack runtime contract"
	).is_true()
	if not required_api:
		return

	var sprite: AnimatedSprite2D = boss.get_node("Sprite") as AnimatedSprite2D
	var frames: SpriteFrames = sprite.sprite_frames
	for animation_name: StringName in [
		POUNCE_TELL_ANIMATION,
		POUNCE_ACTIVE_ANIMATION,
		POUNCE_RECOVERY_ANIMATION,
	]:
		assert_bool(frames.has_animation(animation_name)).is_true()
		if frames.has_animation(animation_name):
			assert_int(frames.get_frame_count(animation_name)).is_greater_equal(3)

	assert_bool(bool(boss.call("request_attack"))).is_true()
	assert_bool(
		StringName(boss.call("get_current_attack_pattern_id")) == SWIPE_PATTERN_ID
	).is_true()
	boss.call("apply_damage", 18, {"source": &"story175_phase_boundary"})
	assert_int(int(boss.call("get_current_phase"))).is_equal(1)
	var swipe_total_frames: int = (
		int(boss.call("get_current_attack_startup_frames"))
		+ int(boss.call("get_current_attack_active_frames"))
		+ int(boss.call("get_current_attack_recovery_frames"))
	)
	boss.call("advance_attack_frames", swipe_total_frames)
	assert_int(int(boss.call("get_current_phase"))).is_equal(2)
	boss.call("advance_attack_frames", 60)

	player.global_position = Vector2(
		boss.global_position.x + 72.0,
		boss.global_position.y
	)
	boss.call("set_target_focus_mode", true, {"windup_extension_frames": 6})
	assert_bool(bool(boss.call("request_attack"))).is_true()
	assert_bool(
		StringName(boss.call("get_current_attack_pattern_id")) == POUNCE_PATTERN_ID
	).is_true()
	assert_int(int(boss.call("get_current_attack_startup_frames"))).is_equal(21)
	assert_int(int(boss.call("get_current_attack_active_frames"))).is_equal(6)
	assert_int(int(boss.call("get_current_attack_recovery_frames"))).is_equal(15)
	assert_str(String(sprite.animation)).is_equal(String(POUNCE_TELL_ANIMATION))

	var collision: CollisionComponent = boss.call("get_collision_component") as CollisionComponent
	var player_collision: CollisionComponent = player.call("get_collision_component") as CollisionComponent
	assert_that(collision).is_not_null()
	assert_that(player_collision).is_not_null()
	if collision == null or player_collision == null:
		return
	assert_bool(collision.is_hitbox_active(POUNCE_HITBOX_ID)).is_false()
	assert_bool(collision.is_hitbox_active(SWIPE_HITBOX_ID)).is_false()

	var startup_diagnostics: Dictionary = boss.call("get_secondary_attack_diagnostics")
	assert_bool(bool(startup_diagnostics.get("loaded_enemy_stats", false))).is_true()
	assert_bool(bool(startup_diagnostics.get("loaded_boss_config", false))).is_true()
	assert_bool(bool(startup_diagnostics.get("landing_tell_visible", false))).is_true()
	assert_float(float(startup_diagnostics.get("phase_speed_modifier", 0.0))).is_equal(1.2)
	var locked_position: Vector2 = startup_diagnostics.get(
		"locked_pounce_position",
		Vector2.INF
	) as Vector2
	assert_float(locked_position.x).is_equal(player.global_position.x)
	assert_float(
		float(startup_diagnostics.get("landing_tell_global_x", INF))
	).is_equal(locked_position.x)

	player.global_position.x = locked_position.x + 120.0
	boss.call("advance_attack_frames", int(boss.call("get_current_attack_startup_frames")))
	assert_str(String(boss.call("get_attack_phase"))).is_equal("active")
	assert_str(String(sprite.animation)).is_equal(String(POUNCE_ACTIVE_ANIMATION))
	assert_float(boss.global_position.x).is_equal(locked_position.x)
	assert_bool(collision.is_hitbox_active(POUNCE_HITBOX_ID)).is_true()
	assert_bool(collision.is_hitbox_active(SWIPE_HITBOX_ID)).is_false()
	assert_bool(bool(
		boss.call("get_secondary_attack_diagnostics").get("landing_tell_visible", true)
	)).is_false()

	var hp_before_hit: int = int(player.call("get_current_hp"))
	collision.process_detection_frame({
		POUNCE_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	var hp_after_hit: int = int(player.call("get_current_hp"))
	assert_int(hp_before_hit - hp_after_hit).is_equal(POUNCE_DAMAGE)
	collision.process_detection_frame({
		POUNCE_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_after_hit)

	boss.call("advance_attack_frames", int(boss.call("get_current_attack_active_frames")))
	assert_str(String(boss.call("get_attack_phase"))).is_equal("recovery")
	assert_str(String(sprite.animation)).is_equal(String(POUNCE_RECOVERY_ANIMATION))
	assert_bool(collision.is_hitbox_active(POUNCE_HITBOX_ID)).is_false()
	boss.call("advance_attack_frames", 60)
	assert_bool(bool(boss.call("request_attack"))).is_true()
	assert_bool(
		StringName(boss.call("get_current_attack_pattern_id")) == SWIPE_PATTERN_ID
	).is_true()
