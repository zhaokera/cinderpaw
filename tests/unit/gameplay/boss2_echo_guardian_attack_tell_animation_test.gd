## Story 165: Echo Guardian attack-tell frame animation runtime.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const BOSS_NODE_NAME: String = "Boss2EchoGuardian"
const RAT_KING_DEFEATED_FLAG: StringName = &"boss_rat_king_defeated"
const ATTACK_TELL_ANIMATION: StringName = &"attack_tell"
const ATTACK_ANIMATION: StringName = &"attack"
const ATTACK_TELL_FRAME_PREFIX: String = (
	"res://assets/characters/boss2_echo_guardian/attack_tell/"
)
const ATTACK_TELL_FRAME_BASENAME: String = "boss2_echo_guardian_attack_tell"
const EXPECTED_FRAME_SIZE: Vector2 = Vector2(160, 128)
const EXPECTED_FRAME_COUNT: int = 3
const BOSS2_HITBOX_ID: StringName = &"boss2_echo_swipe"

var scene: Node2D = null


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


func test_startup_uses_three_frame_attack_tell_before_active_attack() -> void:
	var boss: Node = scene.get_node(BOSS_NODE_NAME)
	var sprite := boss.get_node("Sprite") as AnimatedSprite2D
	var sprite_frames: SpriteFrames = sprite.sprite_frames

	assert_bool(sprite_frames.has_animation(ATTACK_TELL_ANIMATION)).override_failure_message(
		"Story165 requires a dedicated Echo Guardian attack_tell animation"
	).is_true()
	if not sprite_frames.has_animation(ATTACK_TELL_ANIMATION):
		return

	assert_int(sprite_frames.get_frame_count(ATTACK_TELL_ANIMATION)).is_equal(
		EXPECTED_FRAME_COUNT
	)
	assert_bool(sprite_frames.get_animation_loop(ATTACK_TELL_ANIMATION)).is_false()
	for frame_index: int in range(EXPECTED_FRAME_COUNT):
		var texture: Texture2D = sprite_frames.get_frame_texture(
			ATTACK_TELL_ANIMATION,
			frame_index
		)
		var expected_path := "%s%s_%03d.png" % [
			ATTACK_TELL_FRAME_PREFIX,
			ATTACK_TELL_FRAME_BASENAME,
			frame_index,
		]
		assert_object(texture).is_not_null()
		if texture == null:
			continue
		assert_str(texture.resource_path).is_equal(expected_path)
		assert_vector(texture.get_size()).is_equal(EXPECTED_FRAME_SIZE)
		var frame_image := Image.load_from_file(ProjectSettings.globalize_path(expected_path))
		assert_object(frame_image).is_not_null()
		if frame_image != null:
			assert_float(frame_image.get_pixel(0, 0).a).is_equal_approx(0.0, 0.01)

	boss.set_physics_process(false)
	assert_bool(bool(boss.call("set_target_focus_mode", true, {
		"windup_extension_frames": 6,
	}))).is_true()
	var startup_frames: int = int(boss.call("get_current_attack_startup_frames"))
	assert_int(startup_frames).is_equal(14)
	assert_bool(bool(boss.call("request_attack"))).is_true()
	assert_str(String(boss.call("get_attack_phase"))).is_equal("startup")
	assert_str(String(sprite.animation)).is_equal(String(ATTACK_TELL_ANIMATION))
	var collision: CollisionComponent = boss.call("get_collision_component") as CollisionComponent
	assert_object(collision).is_not_null()
	if collision == null:
		return
	assert_bool(collision.is_hitbox_active(BOSS2_HITBOX_ID)).is_false()

	await sprite.animation_finished
	assert_int(sprite.frame).is_equal(EXPECTED_FRAME_COUNT - 1)
	assert_bool(sprite.is_playing()).is_false()
	boss.call("advance_attack_frames", 1)
	assert_str(String(boss.call("get_attack_phase"))).is_equal("startup")
	assert_str(String(sprite.animation)).is_equal(String(ATTACK_TELL_ANIMATION))
	assert_int(sprite.frame).is_equal(EXPECTED_FRAME_COUNT - 1)
	assert_bool(sprite.is_playing()).is_false()

	boss.call("advance_attack_frames", startup_frames - 1)
	assert_str(String(boss.call("get_attack_phase"))).is_equal("active")
	assert_str(String(sprite.animation)).is_equal(String(ATTACK_ANIMATION))
	assert_bool(collision.is_hitbox_active(BOSS2_HITBOX_ID)).is_true()
