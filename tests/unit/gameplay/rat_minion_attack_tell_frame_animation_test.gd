## Combat Presentation Story032: Rat Minion dedicated attack-tell frames.
extends GdUnitTestSuite

const GAMEPLAY_SCENE_PATH: String = "res://src/gameplay/rat_minion.tscn"
const SPRITE_FRAMES_PATH: String = (
	"res://assets/characters/rat_minion/rat_minion_sprite_frames.tres"
)
const ATTACK_TELL_ANIMATION: StringName = &"attack_tell"
const ATTACK_ANIMATION: StringName = &"attack"
const ATTACK_HITBOX_ID: StringName = &"rat_minion_bite"
const EXPECTED_FRAME_COUNT: int = 3
const EXPECTED_STARTUP_FRAMES: int = 7
const REQUIRED_FRAME_SIZE: Vector2i = Vector2i(96, 96)

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_rat_minion_uses_three_generated_tell_frames_before_active_bite() -> void:
	var sprite_frames: SpriteFrames = load(SPRITE_FRAMES_PATH) as SpriteFrames
	assert_that(sprite_frames).is_not_null()
	if sprite_frames == null:
		return
	assert_bool(sprite_frames.has_animation(ATTACK_TELL_ANIMATION)).is_true()
	if not sprite_frames.has_animation(ATTACK_TELL_ANIMATION):
		return
	assert_int(sprite_frames.get_frame_count(ATTACK_TELL_ANIMATION)).is_equal(
		EXPECTED_FRAME_COUNT
	)
	assert_bool(sprite_frames.get_animation_loop(ATTACK_TELL_ANIMATION)).is_false()
	for frame_index: int in range(EXPECTED_FRAME_COUNT):
		var frame_path: String = (
			"res://assets/characters/rat_minion/attack_tell/"
			+ "rat_minion_attack_tell_%03d.png" % frame_index
		)
		assert_bool(FileAccess.file_exists(frame_path)).is_true()
		assert_bool(_image_has_required_alpha_contract(frame_path)).is_true()

	var packed_scene: PackedScene = load(GAMEPLAY_SCENE_PATH) as PackedScene
	assert_that(packed_scene).is_not_null()
	if packed_scene == null:
		return
	var minion: Node = packed_scene.instantiate()
	add_child(minion)
	_spawned_nodes.append(minion)
	var sprite: AnimatedSprite2D = minion.get_node_or_null("Sprite") as AnimatedSprite2D
	var collision: CollisionComponent = minion.call("get_collision_component") as CollisionComponent
	assert_that(sprite).is_not_null()
	assert_that(collision).is_not_null()
	if sprite == null or collision == null:
		return

	assert_int(int(minion.call("get_attack_startup_frames"))).is_equal(
		EXPECTED_STARTUP_FRAMES
	)
	assert_bool(bool(minion.call("request_attack"))).is_true()
	assert_that(sprite.animation).is_equal(ATTACK_TELL_ANIMATION)
	assert_bool(collision.is_hitbox_active(ATTACK_HITBOX_ID)).is_false()

	minion.call("advance_attack_frames", EXPECTED_STARTUP_FRAMES - 1)
	assert_that(sprite.animation).is_equal(ATTACK_TELL_ANIMATION)
	assert_bool(collision.is_hitbox_active(ATTACK_HITBOX_ID)).is_false()
	minion.call("advance_attack_frames", 1)
	assert_that(sprite.animation).is_equal(ATTACK_ANIMATION)
	assert_bool(collision.is_hitbox_active(ATTACK_HITBOX_ID)).is_true()
	assert_int(int(minion.call("get_current_enemy_attack_metadata").get(
		"injected_damage_params", {}
	).get("entries", {}).get(String(ATTACK_HITBOX_ID), {}).get(
		"weapon_base", 0
	))).is_equal(8)


func _image_has_required_alpha_contract(path: String) -> bool:
	var image := Image.new()
	var error: Error = image.load_png_from_buffer(FileAccess.get_file_as_bytes(path))
	if error != OK:
		return false
	if image.get_size() != REQUIRED_FRAME_SIZE:
		return false
	if image.get_format() not in [
		Image.FORMAT_RGBA8,
		Image.FORMAT_RGBAF,
		Image.FORMAT_RGBAH,
	]:
		return false
	return image.get_pixel(0, 0).a < 0.05
