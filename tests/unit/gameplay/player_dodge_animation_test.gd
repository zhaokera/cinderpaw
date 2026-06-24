## Story 004: Player dodge animation and presentation signal contract.
extends GdUnitTestSuite

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const DODGE_ANIMATION: StringName = &"dodge"
const REQUIRED_DODGE_FRAME_COUNT: int = 3

var player: PlayerController
var received_dodge_texture: Texture2D = null
var received_dodge_position: Vector2 = Vector2.ZERO
var received_dodge_facing: float = 0.0


func before_test() -> void:
	player = PLAYER_SCENE.instantiate() as PlayerController
	add_child(player)
	received_dodge_texture = null
	received_dodge_position = Vector2.ZERO
	received_dodge_facing = 0.0
	if player.has_signal("dodge_started"):
		player.dodge_started.connect(func(texture: Texture2D, world_position: Vector2, facing: float) -> void:
			received_dodge_texture = texture
			received_dodge_position = world_position
			received_dodge_facing = facing
		)


func after_test() -> void:
	if is_instance_valid(player):
		if player.get_parent() != null:
			player.get_parent().remove_child(player)
		player.free()
	player = null
	received_dodge_texture = null
	received_dodge_position = Vector2.ZERO
	received_dodge_facing = 0.0


func test_player_has_three_frame_dodge_animation_from_character_asset_pipeline() -> void:
	var sprite := player.get_node("Sprite") as AnimatedSprite2D
	assert_bool(sprite.sprite_frames.has_animation(DODGE_ANIMATION)).is_true()
	if not sprite.sprite_frames.has_animation(DODGE_ANIMATION):
		return
	assert_int(sprite.sprite_frames.get_frame_count(DODGE_ANIMATION)).is_equal(
		REQUIRED_DODGE_FRAME_COUNT
	)
	assert_bool(_animation_frames_are_textured_and_same_size(
		sprite.sprite_frames,
		DODGE_ANIMATION
	)).is_true()

	for frame_index: int in range(REQUIRED_DODGE_FRAME_COUNT):
		var frame_path := "res://assets/characters/cinderpaw/dodge/cinderpaw_dodge_%03d.png" % frame_index
		assert_bool(FileAccess.file_exists(frame_path)).is_true()


func test_request_dodge_plays_dodge_animation_and_emits_afterimage_metadata() -> void:
	var sprite := player.get_node("Sprite") as AnimatedSprite2D
	assert_bool(player.has_signal("dodge_started")).is_true()
	assert_bool(player.has_method("request_dodge")).is_true()
	if not player.has_signal("dodge_started") or not player.has_method("request_dodge"):
		return

	assert_bool(player.request_dodge()).is_true()

	assert_str(String(sprite.animation)).is_equal("dodge")
	assert_bool(sprite.is_playing()).is_true()
	assert_bool(received_dodge_texture is Texture2D).is_true()
	assert_vector(received_dodge_position).is_equal(sprite.global_position)
	assert_float(received_dodge_facing).is_equal_approx(1.0, 0.001)


func test_request_dodge_respects_cooldown_until_dodge_window_finishes() -> void:
	assert_bool(player.has_method("request_dodge")).is_true()
	if not player.has_method("request_dodge"):
		return
	assert_bool(player.request_dodge()).is_true()
	assert_bool(player.request_dodge()).is_false()


func _animation_frames_are_textured_and_same_size(
	sprite_frames: SpriteFrames,
	animation_name: StringName
) -> bool:
	var expected_size := Vector2.ZERO
	for frame_index: int in range(sprite_frames.get_frame_count(animation_name)):
		var texture := sprite_frames.get_frame_texture(animation_name, frame_index)
		if texture == null:
			return false
		var texture_size := texture.get_size()
		if expected_size == Vector2.ZERO:
			expected_size = texture_size
		elif texture_size != expected_size:
			return false
	return true
