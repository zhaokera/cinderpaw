## Story 006: Cinderpaw jump and fall animation contract.
extends GdUnitTestSuite

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const REQUIRED_ANIMATIONS: Array[StringName] = [&"jump", &"fall"]
const REQUIRED_FRAME_COUNT: int = 3

var player: PlayerController


func before_test() -> void:
	player = PLAYER_SCENE.instantiate() as PlayerController
	add_child(player)


func after_test() -> void:
	if is_instance_valid(player):
		if player.get_parent() != null:
			player.get_parent().remove_child(player)
		player.free()
	player = null


func test_player_sprite_frames_include_jump_and_fall_assets() -> void:
	var sprite := _get_animated_sprite_or_fail()
	if sprite == null:
		return
	assert_bool(sprite.sprite_frames != null).is_true()
	if sprite.sprite_frames == null:
		return

	for animation_name: StringName in REQUIRED_ANIMATIONS:
		assert_bool(sprite.sprite_frames.has_animation(animation_name)).is_true()
		if not sprite.sprite_frames.has_animation(animation_name):
			continue
		assert_int(sprite.sprite_frames.get_frame_count(animation_name)).is_equal(
			REQUIRED_FRAME_COUNT
		)
		assert_bool(_animation_frames_are_textured_and_same_size(
			sprite.sprite_frames,
			animation_name
		)).is_true()


func test_air_animation_assets_follow_project_pipeline_paths() -> void:
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		for frame_index: int in range(REQUIRED_FRAME_COUNT):
			var frame_path := "res://assets/characters/cinderpaw/%s/cinderpaw_%s_%03d.png" % [
				String(animation_name),
				String(animation_name),
				frame_index,
			]
			assert_bool(FileAccess.file_exists(frame_path)).is_true()


func test_upward_air_velocity_plays_jump_animation() -> void:
	var sprite := _get_animated_sprite_or_fail()
	if sprite == null:
		return

	player.velocity = Vector2(0.0, -120.0)
	player.call("_physics_process", 1.0 / 60.0)

	assert_str(String(sprite.animation)).is_equal("jump")
	assert_bool(sprite.is_playing()).is_true()


func test_upward_velocity_prefers_jump_during_floor_contact_cache() -> void:
	var animation_name: StringName = player.call(
		"_get_locomotion_animation",
		true,
		Vector2(0.0, -120.0)
	)

	assert_str(String(animation_name)).is_equal("jump")


func test_downward_air_velocity_plays_fall_animation() -> void:
	var sprite := _get_animated_sprite_or_fail()
	if sprite == null:
		return

	player.velocity = Vector2(0.0, 120.0)
	player.call("_physics_process", 1.0 / 60.0)

	assert_str(String(sprite.animation)).is_equal("fall")
	assert_bool(sprite.is_playing()).is_true()


func test_air_animation_does_not_override_locked_damage_state() -> void:
	var sprite := _get_animated_sprite_or_fail()
	if sprite == null:
		return

	player.apply_damage(12, {"source": &"test"})
	player.velocity = Vector2(0.0, -120.0)
	player.call("_physics_process", 1.0 / 60.0)

	assert_str(String(sprite.animation)).is_equal("hurt")


func test_air_animation_does_not_override_attack_state() -> void:
	var sprite := _get_animated_sprite_or_fail()
	if sprite == null:
		return

	assert_bool(player.request_attack()).is_true()
	player.velocity = Vector2(0.0, -120.0)
	player.call("_physics_process", 1.0 / 60.0)

	assert_str(String(sprite.animation)).is_equal("attack")


func test_air_animation_does_not_override_dodge_state() -> void:
	var sprite := _get_animated_sprite_or_fail()
	if sprite == null:
		return

	assert_bool(player.request_dodge()).is_true()
	player.velocity = Vector2(0.0, -120.0)
	player.call("_physics_process", 1.0 / 60.0)

	assert_str(String(sprite.animation)).is_equal("dodge")


func _get_animated_sprite_or_fail() -> AnimatedSprite2D:
	var sprite: Node = player.get_node("Sprite")
	assert_bool(sprite is AnimatedSprite2D).is_true()
	return sprite as AnimatedSprite2D


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
