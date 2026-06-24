## Story 009: SimpleEnemy frame animation contract.
extends GdUnitTestSuite

const SIMPLE_ENEMY_SCENE: PackedScene = preload("res://src/gameplay/simple_enemy.tscn")
const CHARACTER_SCENE_PATH: String = "res://scenes/characters/shadow_beast.tscn"
const CHARACTER_SCRIPT_PATH: String = "res://src/characters/shadow_beast.gd"
const REQUIRED_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"patrol",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]

var enemy: SimpleEnemy


func before_test() -> void:
	enemy = SIMPLE_ENEMY_SCENE.instantiate() as SimpleEnemy
	add_child(enemy)


func after_test() -> void:
	if is_instance_valid(enemy):
		if enemy.get_parent() != null:
			enemy.get_parent().remove_child(enemy)
		enemy.free()
	enemy = null


func test_enemy_uses_shadow_beast_animated_sprite_frames() -> void:
	assert_bool(FileAccess.file_exists(CHARACTER_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(CHARACTER_SCRIPT_PATH)).is_true()
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
		assert_int(sprite.sprite_frames.get_frame_count(animation_name)).is_greater_equal(2)
		assert_bool(_animation_frames_are_textured_and_same_size(
			sprite.sprite_frames,
			animation_name
		)).is_true()


func test_enemy_animation_assets_follow_project_pipeline_paths() -> void:
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		for frame_index: int in range(2):
			var frame_path := "res://assets/characters/shadow_beast/%s/shadow_beast_%s_%03d.png" % [
				String(animation_name),
				String(animation_name),
				frame_index,
			]
			assert_bool(FileAccess.file_exists(frame_path)).is_true()


func test_enemy_damage_states_play_hurt_and_death_animations() -> void:
	var sprite := _get_animated_sprite_or_fail()
	if sprite == null:
		return

	enemy.apply_damage(5, {"source": &"test"})
	assert_str(String(sprite.animation)).is_equal("hurt")

	enemy.apply_damage(enemy.get_max_hp(), {"source": &"test"})
	assert_str(String(sprite.animation)).is_equal("death")


func _get_animated_sprite_or_fail() -> AnimatedSprite2D:
	var sprite: Node = enemy.get_node("Sprite")
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
