## Rat King boss character frame animation contract.
extends GdUnitTestSuite

const CHARACTER_SCENE_PATH: String = "res://scenes/characters/rat_king.tscn"
const CHARACTER_SCRIPT_PATH: String = "res://src/characters/rat_king.gd"
const SPRITE_FRAMES_PATH: String = "res://assets/characters/rat_king/rat_king_sprite_frames.tres"
const REQUIRED_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
	&"phase_1_intro",
	&"phase_2_rebuild",
	&"phase_3_overload",
]
const MIN_FRAMES_PER_ANIMATION: int = 3


func test_rat_king_character_scene_uses_animated_sprite_frames() -> void:
	assert_bool(FileAccess.file_exists(CHARACTER_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(CHARACTER_SCRIPT_PATH)).is_true()
	assert_bool(FileAccess.file_exists(SPRITE_FRAMES_PATH)).is_true()
	if not FileAccess.file_exists(CHARACTER_SCENE_PATH):
		return

	var scene: PackedScene = load(CHARACTER_SCENE_PATH) as PackedScene
	assert_object(scene).is_not_null()
	if scene == null:
		return
	var character := scene.instantiate()
	add_child(character)
	assert_bool(character is AnimatedSprite2D).is_true()
	if not character is AnimatedSprite2D:
		character.queue_free()
		return
	var sprite := character as AnimatedSprite2D
	assert_bool(sprite.sprite_frames != null).is_true()
	if sprite.sprite_frames == null:
		character.queue_free()
		return

	for animation_name: StringName in REQUIRED_ANIMATIONS:
		assert_bool(sprite.sprite_frames.has_animation(animation_name)).is_true()
		if not sprite.sprite_frames.has_animation(animation_name):
			continue
		assert_int(sprite.sprite_frames.get_frame_count(animation_name)).is_greater_equal(
			MIN_FRAMES_PER_ANIMATION
		)
		assert_bool(_animation_frames_are_textured_and_same_size(
			sprite.sprite_frames,
			animation_name
		)).is_true()

	character.queue_free()


func test_rat_king_animation_assets_follow_project_pipeline_paths() -> void:
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		for frame_index: int in range(MIN_FRAMES_PER_ANIMATION):
			var frame_path := "res://assets/characters/rat_king/%s/rat_king_%s_%03d.png" % [
				String(animation_name),
				String(animation_name),
				frame_index,
			]
			assert_bool(FileAccess.file_exists(frame_path)).is_true()


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
