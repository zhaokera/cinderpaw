## Runtime dash ability contract for the playable Cinderpaw controller.
extends GdUnitTestSuite

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const DASH_ANIMATION: StringName = &"dash"
const DASH_ABILITY: StringName = &"dash"
const REQUIRED_DASH_FRAME_COUNT: int = 3

var player: PlayerController
var received_dash_texture: Texture2D = null
var received_dash_position: Vector2 = Vector2.ZERO
var received_dash_facing: float = 0.0


func before_test() -> void:
	player = PLAYER_SCENE.instantiate() as PlayerController
	add_child(player)
	received_dash_texture = null
	received_dash_position = Vector2.ZERO
	received_dash_facing = 0.0
	if player.has_signal("dash_started"):
		player.dash_started.connect(func(texture: Texture2D, world_position: Vector2, facing: float) -> void:
			received_dash_texture = texture
			received_dash_position = world_position
			received_dash_facing = facing
		)


func after_test() -> void:
	if is_instance_valid(player):
		if player.get_parent() != null:
			player.get_parent().remove_child(player)
		player.free()
	_clear_audio_system_players()
	player = null
	received_dash_texture = null
	received_dash_position = Vector2.ZERO
	received_dash_facing = 0.0


func test_dash_animation_frames_are_imported_through_character_asset_pipeline() -> void:
	var sprite := player.get_node("Sprite") as AnimatedSprite2D
	var ability_component := player.get_node_or_null("AbilityComponent")
	assert_that(ability_component).is_not_null()
	assert_bool(ability_component is AbilityComponent).is_true()
	assert_bool(sprite.sprite_frames.has_animation(DASH_ANIMATION)).is_true()
	if not sprite.sprite_frames.has_animation(DASH_ANIMATION):
		return
	assert_int(sprite.sprite_frames.get_frame_count(DASH_ANIMATION)).is_equal(
		REQUIRED_DASH_FRAME_COUNT
	)
	assert_bool(_animation_frames_are_textured_and_same_size(
		sprite.sprite_frames,
		DASH_ANIMATION
	)).is_true()

	for frame_index: int in range(REQUIRED_DASH_FRAME_COUNT):
		var frame_path := "res://assets/characters/cinderpaw/dash/cinderpaw_dash_%03d.png" % frame_index
		assert_bool(FileAccess.file_exists(frame_path)).is_true()
		var texture := sprite.sprite_frames.get_frame_texture(DASH_ANIMATION, frame_index)
		assert_that(texture).is_not_null()
		if texture == null:
			return
		assert_str(texture.resource_path).is_equal(frame_path)


func test_request_dash_requires_unlock_and_starts_one_second_cooldown() -> void:
	var sprite := player.get_node("Sprite") as AnimatedSprite2D
	assert_bool(player.has_signal("dash_started")).is_true()
	assert_bool(player.has_method("request_dash")).is_true()
	assert_bool(player.has_method("unlock_ability")).is_true()
	assert_bool(player.has_method("has_ability")).is_true()
	assert_bool(player.has_method("is_ability_on_cooldown")).is_true()
	assert_bool(player.has_method("get_ability_cooldown_remaining")).is_true()
	assert_bool(player.has_signal("ability_activated")).is_true()
	if (
		not player.has_signal("dash_started")
		or not player.has_method("request_dash")
		or not player.has_method("unlock_ability")
		or not player.has_method("has_ability")
		or not player.has_method("is_ability_on_cooldown")
		or not player.has_method("get_ability_cooldown_remaining")
	):
		return
	var activated_ids: Array[StringName] = []
	player.ability_activated.connect(func(ability_id: StringName) -> void:
		activated_ids.append(ability_id)
	)

	assert_bool(player.has_ability(DASH_ABILITY)).is_false()
	assert_bool(player.request_dash()).is_false()

	assert_bool(player.unlock_ability(DASH_ABILITY)).is_true()
	assert_bool(player.unlock_ability(DASH_ABILITY)).is_false()
	assert_bool(player.has_ability(DASH_ABILITY)).is_true()

	assert_bool(player.request_dash()).is_true()

	assert_str(String(sprite.animation)).is_equal("dash")
	assert_bool(sprite.is_playing()).is_true()
	assert_array(activated_ids).is_equal([DASH_ABILITY])
	assert_bool(received_dash_texture is Texture2D).is_true()
	assert_vector(received_dash_position).is_equal(sprite.global_position)
	assert_float(received_dash_facing).is_equal_approx(1.0, 0.001)
	assert_float(player.velocity.x).is_greater(0.0)
	assert_bool(player.is_ability_on_cooldown(DASH_ABILITY)).is_true()
	assert_float(player.get_ability_cooldown_remaining(DASH_ABILITY)).is_equal_approx(1.0, 0.001)
	assert_bool(player.request_dash()).is_false()


func test_main_scene_unlock_synchronizes_dash_to_player_controller() -> void:
	var scene := MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	var scene_player := scene.get_node("Player") as PlayerController
	assert_bool(scene_player.has_method("has_ability")).is_true()
	assert_bool(scene_player.has_method("request_dash")).is_true()
	if not scene_player.has_method("has_ability") or not scene_player.has_method("request_dash"):
		scene.queue_free()
		return

	assert_bool(scene_player.has_ability(DASH_ABILITY)).is_false()
	scene.call("unlock_ability", DASH_ABILITY)
	assert_bool(scene_player.has_ability(DASH_ABILITY)).is_true()
	assert_bool(scene_player.request_dash()).is_true()
	scene.queue_free()


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


func _clear_audio_system_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var audio_player := child as AudioStreamPlayer
			audio_player.stop()
			audio_player.stream = null
		elif child is AudioStreamPlayer2D:
			var audio_player_2d := child as AudioStreamPlayer2D
			audio_player_2d.stop()
			audio_player_2d.stream = null
