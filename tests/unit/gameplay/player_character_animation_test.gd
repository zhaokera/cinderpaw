## Story 003: Cinderpaw player AnimatedSprite2D frame animation contract.
extends GdUnitTestSuite

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const REQUIRED_ANIMATIONS: Array[StringName] = [&"idle", &"run", &"attack"]

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


func test_player_uses_animated_sprite_with_required_frame_sets() -> void:
	var animated_sprite := _get_animated_sprite_or_fail()
	if animated_sprite == null:
		return
	assert_bool(animated_sprite.sprite_frames != null).is_true()
	if animated_sprite.sprite_frames == null:
		return

	for animation_name: StringName in REQUIRED_ANIMATIONS:
		assert_bool(animated_sprite.sprite_frames.has_animation(animation_name)).is_true()
		assert_int(animated_sprite.sprite_frames.get_frame_count(animation_name)).is_greater_equal(2)
		assert_bool(_animation_frames_are_textured_and_same_size(
			animated_sprite.sprite_frames,
			animation_name
		)).is_true()


func test_character_animation_assets_follow_project_pipeline_paths() -> void:
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		for frame_index: int in range(2):
			var frame_path := "res://assets/characters/cinderpaw/%s/cinderpaw_%s_%03d.png" % [
				String(animation_name),
				String(animation_name),
				frame_index,
			]
			assert_bool(FileAccess.file_exists(frame_path)).is_true()


func test_player_attack_switches_to_attack_animation() -> void:
	var sprite := _get_animated_sprite_or_fail()
	if sprite == null:
		return

	assert_bool(player.request_attack()).is_true()

	assert_str(String(sprite.animation)).is_equal("attack")
	assert_bool(sprite.is_playing()).is_false()
	assert_int(sprite.frame).is_equal(0)


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
