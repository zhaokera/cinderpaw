## Story 024: Boss2 autonomous pressure closes distance and attacks.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const BOSS_NODE_NAME: String = "Boss2EchoGuardian"
const BOSS2_HITBOX_ID: StringName = &"boss2_echo_swipe"
const EXPECTED_ATTACK_DAMAGE: int = 14
const RUN_ANIMATION: StringName = &"run"
const ATTACK_ANIMATION: StringName = &"attack"

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


func test_boss2_chases_player_from_main_scene_start_distance() -> void:
	var boss: Node = scene.get_node(BOSS_NODE_NAME)
	var player: Node = scene.get_node("Player")
	var sprite := boss.get_node("Sprite") as AnimatedSprite2D
	assert_bool(boss.has_method("advance_behavior_frames")).is_true()
	assert_bool(boss.has_method("get_auto_pressure_diagnostics")).is_true()
	if not boss.has_method("advance_behavior_frames") \
			or not boss.has_method("get_auto_pressure_diagnostics"):
		return

	var start_distance: float = absf(boss.global_position.x - player.global_position.x)
	var start_x: float = boss.global_position.x
	boss.call("advance_behavior_frames", 1)

	var diagnostics: Dictionary = boss.call("get_auto_pressure_diagnostics")
	var after_distance: float = absf(boss.global_position.x - player.global_position.x)
	assert_bool(bool(diagnostics.get("is_chasing", false))).is_true()
	assert_str(String(diagnostics.get("behavior_phase", ""))).is_equal("chase")
	assert_float(after_distance).is_less(start_distance)
	assert_float(boss.global_position.x).is_less(start_x)
	assert_str(String(sprite.animation)).is_equal(String(RUN_ANIMATION))
	assert_bool(sprite.is_playing()).is_true()
	assert_bool(sprite.sprite_frames.has_animation(RUN_ANIMATION)).is_true()
	if sprite.sprite_frames.has_animation(RUN_ANIMATION):
		assert_int(sprite.sprite_frames.get_frame_count(RUN_ANIMATION)).is_greater_equal(3)
	if player.global_position.x < boss.global_position.x:
		assert_bool(sprite.flip_h).is_true()
	else:
		assert_bool(sprite.flip_h).is_false()


func test_boss2_sustained_chase_allows_run_animation_to_advance() -> void:
	var boss: Node = scene.get_node(BOSS_NODE_NAME)
	var player: Node = scene.get_node("Player")
	var sprite := boss.get_node("Sprite") as AnimatedSprite2D
	assert_bool(boss.has_method("advance_behavior_frames")).is_true()
	assert_bool(boss.has_method("set_attack_target")).is_true()
	if not (
		boss.has_method("advance_behavior_frames")
		and boss.has_method("set_attack_target")
	):
		return

	player.global_position = Vector2(240, 456)
	boss.global_position = Vector2(540, 456)
	boss.call("set_attack_target", player)
	boss.call("advance_behavior_frames", 1)
	assert_str(String(sprite.animation)).is_equal(String(RUN_ANIMATION))
	assert_int(sprite.frame).is_equal(0)

	for _index: int in range(25):
		boss.call("advance_behavior_frames", 1)
		await get_tree().physics_frame

	assert_str(String(sprite.animation)).is_equal(String(RUN_ANIMATION))
	assert_int(sprite.frame).is_greater_equal(1)


func test_boss2_auto_pressure_enters_startup_without_direct_request_attack() -> void:
	var boss: Node = scene.get_node(BOSS_NODE_NAME)
	assert_bool(boss.has_method("advance_behavior_frames")).is_true()
	assert_bool(boss.has_method("get_attack_phase")).is_true()
	assert_bool(boss.has_method("get_collision_component")).is_true()
	if not (
		boss.has_method("advance_behavior_frames")
		and boss.has_method("get_attack_phase")
		and boss.has_method("get_collision_component")
	):
		return

	assert_bool(_advance_until_attack_phase(boss, &"startup", 96)).is_true()
	assert_str(String(boss.call("get_attack_phase"))).is_equal("startup")
	var sprite := boss.get_node("Sprite") as AnimatedSprite2D
	assert_str(String(sprite.animation)).is_equal(String(ATTACK_ANIMATION))
	var collision: CollisionComponent = boss.call("get_collision_component") as CollisionComponent
	assert_that(collision).is_not_null()
	if collision != null:
		assert_bool(collision.is_hitbox_active(BOSS2_HITBOX_ID)).is_false()


func test_boss2_auto_pressure_active_hit_damages_player_once() -> void:
	var boss: Node = scene.get_node(BOSS_NODE_NAME)
	var player: Node = scene.get_node("Player")
	assert_bool(boss.has_method("advance_behavior_frames")).is_true()
	assert_bool(boss.has_method("get_collision_component")).is_true()
	assert_bool(player.has_method("get_collision_component")).is_true()
	assert_bool(player.has_method("get_current_hp")).is_true()
	if not (
		boss.has_method("advance_behavior_frames")
		and boss.has_method("get_collision_component")
		and player.has_method("get_collision_component")
		and player.has_method("get_current_hp")
	):
		return

	assert_bool(_advance_until_attack_phase(boss, &"active", 120)).is_true()
	var boss_collision: CollisionComponent = boss.call("get_collision_component") as CollisionComponent
	var player_collision: CollisionComponent = player.call("get_collision_component") as CollisionComponent
	assert_that(boss_collision).is_not_null()
	assert_that(player_collision).is_not_null()
	if boss_collision == null or player_collision == null:
		return

	var start_hp: int = int(player.call("get_current_hp"))
	boss_collision.process_detection_frame({
		BOSS2_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	var hp_after_hit: int = int(player.call("get_current_hp"))
	assert_int(start_hp - hp_after_hit).is_equal(EXPECTED_ATTACK_DAMAGE)

	boss_collision.process_detection_frame({
		BOSS2_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_after_hit)


func test_boss2_restored_defeated_flag_stops_auto_pressure() -> void:
	var boss: Node = scene.get_node(BOSS_NODE_NAME)
	assert_bool(scene.has_method("set_world_progress_flag")).is_true()
	assert_bool(boss.has_method("advance_behavior_frames")).is_true()
	assert_bool(boss.has_method("get_auto_pressure_diagnostics")).is_true()
	if not (
		scene.has_method("set_world_progress_flag")
		and boss.has_method("advance_behavior_frames")
		and boss.has_method("get_auto_pressure_diagnostics")
	):
		return

	scene.call("set_world_progress_flag", &"boss_02_echo_guardian_defeated", true)
	var start_x: float = boss.global_position.x
	boss.call("advance_behavior_frames", 24)
	var diagnostics: Dictionary = boss.call("get_auto_pressure_diagnostics")
	assert_bool(bool(diagnostics.get("is_chasing", true))).is_false()
	assert_str(String(diagnostics.get("behavior_phase", ""))).is_equal("defeated")
	var sprite := boss.get_node("Sprite") as AnimatedSprite2D
	assert_str(String(sprite.animation)).is_not_equal(String(RUN_ANIMATION))
	assert_float(boss.global_position.x).is_equal(start_x)
	assert_bool(boss.visible).is_false()


func test_boss2_stale_attack_target_does_not_start_manual_or_auto_pressure() -> void:
	var boss: Node = scene.get_node(BOSS_NODE_NAME)
	assert_bool(boss.has_method("set_attack_target")).is_true()
	assert_bool(boss.has_method("has_attack_target")).is_true()
	assert_bool(boss.has_method("request_attack")).is_true()
	assert_bool(boss.has_method("advance_behavior_frames")).is_true()
	assert_bool(boss.has_method("get_auto_pressure_diagnostics")).is_true()
	if not (
		boss.has_method("set_attack_target")
		and boss.has_method("has_attack_target")
		and boss.has_method("request_attack")
		and boss.has_method("advance_behavior_frames")
		and boss.has_method("get_auto_pressure_diagnostics")
	):
		return

	var released_target := Node2D.new()
	scene.add_child(released_target)
	released_target.global_position = Vector2(320, 456)
	boss.call("set_attack_target", released_target)
	assert_bool(bool(boss.call("has_attack_target"))).is_true()

	released_target.free()
	assert_bool(bool(boss.call("has_attack_target"))).is_false()
	assert_bool(bool(boss.call("request_attack"))).is_false()

	boss.call("advance_behavior_frames", 1)
	var diagnostics: Dictionary = boss.call("get_auto_pressure_diagnostics")
	assert_bool(bool(diagnostics.get("has_target", true))).is_false()
	assert_bool(bool(diagnostics.get("is_chasing", true))).is_false()
	assert_str(String(diagnostics.get("behavior_phase", ""))).is_equal("idle")
	assert_str(String(diagnostics.get("attack_phase", ""))).is_equal("idle")
	var sprite := boss.get_node("Sprite") as AnimatedSprite2D
	assert_str(String(sprite.animation)).is_not_equal(String(RUN_ANIMATION))


func _advance_until_attack_phase(boss: Node, phase: StringName, max_frames: int) -> bool:
	for _index: int in range(max_frames):
		boss.call("advance_behavior_frames", 1)
		if StringName(boss.call("get_attack_phase")) == phase:
			return true
	return false
