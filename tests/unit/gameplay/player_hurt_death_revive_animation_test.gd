## Story 005: Cinderpaw hurt, death, and revive animation contract.
extends GdUnitTestSuite

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const REQUIRED_ANIMATIONS: Array[StringName] = [&"hurt", &"death", &"revive"]
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


func test_player_sprite_frames_include_hurt_death_and_revive_assets() -> void:
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


func test_player_animation_assets_follow_project_pipeline_paths() -> void:
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		for frame_index: int in range(REQUIRED_FRAME_COUNT):
			var frame_path := "res://assets/characters/cinderpaw/%s/cinderpaw_%s_%03d.png" % [
				String(animation_name),
				String(animation_name),
				frame_index,
			]
			assert_bool(FileAccess.file_exists(frame_path)).is_true()


func test_player_damage_states_play_hurt_and_death_animations() -> void:
	var sprite := _get_animated_sprite_or_fail()
	if sprite == null:
		return

	player.apply_damage(12, {"source": &"test"})
	assert_str(String(sprite.animation)).is_equal("hurt")
	assert_bool(sprite.is_playing()).is_true()

	player.apply_damage(player.get_current_hp(), {"source": &"test"})
	assert_str(String(sprite.animation)).is_equal("death")
	assert_bool(sprite.is_playing()).is_true()


func test_player_respawn_plays_revive_animation_and_keeps_invincibility_flash() -> void:
	var sprite := _get_animated_sprite_or_fail()
	if sprite == null:
		return

	player.apply_damage(player.get_current_hp(), {"source": &"test"})
	player.respawn_at(Vector2(32, 48), 0.5)

	assert_str(String(sprite.animation)).is_equal("revive")
	assert_bool(sprite.is_playing()).is_true()
	assert_bool(player.is_respawn_visual_active()).is_true()
	assert_bool(sprite.modulate.a < 1.0).is_true()


func test_player_hurt_death_and_revive_are_not_immediately_overridden() -> void:
	var sprite := _get_animated_sprite_or_fail()
	if sprite == null:
		return

	player.apply_damage(12, {"source": &"test"})
	_advance_player_frames(1)
	assert_str(String(sprite.animation)).is_equal("hurt")

	player.apply_damage(player.get_current_hp(), {"source": &"test"})
	_advance_player_frames(1)
	assert_str(String(sprite.animation)).is_equal("death")

	player.respawn_at(Vector2(32, 48), 0.5)
	_advance_player_frames(1)
	assert_str(String(sprite.animation)).is_equal("revive")


func _get_animated_sprite_or_fail() -> AnimatedSprite2D:
	var sprite: Node = player.get_node("Sprite")
	assert_bool(sprite is AnimatedSprite2D).is_true()
	return sprite as AnimatedSprite2D


func _advance_player_frames(frame_count: int) -> void:
	for _frame_index: int in range(frame_count):
		player.call("_physics_process", 1.0 / 60.0)


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
