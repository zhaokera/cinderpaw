## Player Abilities Story 014: Old Factory spark rat attack tell feedback.
extends GdUnitTestSuite

const GAMEPLAY_SCENE_PATH: String = "res://src/gameplay/factory_spark_rat.tscn"
const SPRITE_FRAMES_PATH: String = (
	"res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres"
)
const ATTACK_TELL_ANIMATION: StringName = &"attack_tell"
const ATTACK_ANIMATION: StringName = &"attack"
const EXPECTED_ATTACK_TELL_FRAME_COUNT: int = 3
const ATTACK_TELL_FRAMES: int = 12
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


func test_spark_rat_sprite_frames_include_generated_attack_tell_frames() -> void:
	assert_bool(FileAccess.file_exists(SPRITE_FRAMES_PATH)).is_true()
	var sprite_frames: SpriteFrames = load(SPRITE_FRAMES_PATH) as SpriteFrames
	assert_that(sprite_frames).is_not_null()
	if sprite_frames == null:
		return

	assert_bool(sprite_frames.has_animation(ATTACK_TELL_ANIMATION)).is_true()
	if not sprite_frames.has_animation(ATTACK_TELL_ANIMATION):
		return
	assert_int(sprite_frames.get_frame_count(ATTACK_TELL_ANIMATION)).is_greater_equal(
		EXPECTED_ATTACK_TELL_FRAME_COUNT
	)
	assert_bool(sprite_frames.get_animation_loop(ATTACK_TELL_ANIMATION)).is_false()
	for frame_index: int in range(EXPECTED_ATTACK_TELL_FRAME_COUNT):
		var frame_path: String = (
			"res://assets/characters/factory_spark_rat/attack_tell/"
			+ "factory_spark_rat_attack_tell_%03d.png" % frame_index
		)
		assert_bool(FileAccess.file_exists(frame_path)).is_true()
		assert_bool(_image_has_transparent_background_and_size(frame_path, REQUIRED_FRAME_SIZE)).is_true()


func test_spark_rat_attack_startup_uses_attack_tell_then_active_uses_attack() -> void:
	var spark_rat: Node = _instantiate_spark_rat()
	assert_that(spark_rat).is_not_null()
	if spark_rat == null:
		return

	var sprite: AnimatedSprite2D = spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
	assert_that(sprite).is_not_null()
	if sprite == null:
		return

	assert_bool(bool(spark_rat.call("request_attack"))).is_true()
	assert_that(sprite.animation).is_equal(ATTACK_TELL_ANIMATION)

	spark_rat.call("advance_attack_frames", ATTACK_TELL_FRAMES)
	assert_that(sprite.animation).is_equal(ATTACK_ANIMATION)


func test_spark_rat_attack_metadata_contract_survives_attack_tell_split() -> void:
	var spark_rat: Node = _instantiate_spark_rat()
	assert_that(spark_rat).is_not_null()
	if spark_rat == null:
		return

	assert_bool(bool(spark_rat.call("request_attack"))).is_true()
	spark_rat.call("advance_attack_frames", ATTACK_TELL_FRAMES)
	var metadata: Dictionary = spark_rat.call("_build_attack_metadata")
	assert_str(String(metadata.get("source", ""))).is_equal("factory_spark_rat")
	assert_str(String(metadata.get("weapon_id", ""))).is_equal("factory_spark_rat_bite")
	var damage_params: Dictionary = Dictionary(metadata.get("injected_damage_params", {}))
	var entries: Dictionary = Dictionary(damage_params.get("entries", {}))
	var bite_entry: Dictionary = Dictionary(entries.get("factory_spark_rat_bite", {}))
	assert_int(int(bite_entry.get("weapon_base", 0))).is_equal(9)


func test_spark_rat_attack_tell_visual_uses_no_placeholder_nodes() -> void:
	var spark_rat: Node = _instantiate_spark_rat()
	assert_that(spark_rat).is_not_null()
	if spark_rat == null:
		return
	assert_bool(_has_visible_placeholder_node(spark_rat)).is_false()


func _instantiate_spark_rat() -> Node:
	assert_bool(FileAccess.file_exists(GAMEPLAY_SCENE_PATH)).is_true()
	var packed: PackedScene = load(GAMEPLAY_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var spark_rat: Node = packed.instantiate()
	add_child(spark_rat)
	_spawned_nodes.append(spark_rat)
	return spark_rat


func _image_has_transparent_background_and_size(path: String, size: Vector2i) -> bool:
	var image := Image.new()
	var error: Error = image.load_png_from_buffer(FileAccess.get_file_as_bytes(path))
	if error != OK:
		return false
	if image.get_size() != size:
		return false
	if image.get_format() not in [Image.FORMAT_RGBA8, Image.FORMAT_RGBAF, Image.FORMAT_RGBAH]:
		return false
	return image.get_pixel(0, 0).a < 0.05


func _has_visible_placeholder_node(root: Node) -> bool:
	for child: Node in root.get_children():
		if (child is ColorRect or child is Polygon2D) and child.visible:
			return true
		if _has_visible_placeholder_node(child):
			return true
	return false
