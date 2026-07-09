## Player Abilities Story 103: Main scene boundary wall authored visual pass.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const WALL_TEXTURE_PATH: String = (
	"res://assets/environment/main_scene_boundary_wall/"
	+ "main_scene_boundary_wall_96x720.png"
)

var _main_scene: Node2D


func before_test() -> void:
	_main_scene = MAIN_SCENE.instantiate() as Node2D
	add_child(_main_scene)


func after_test() -> void:
	if is_instance_valid(_main_scene):
		if _main_scene.get_parent() != null:
			_main_scene.get_parent().remove_child(_main_scene)
		_main_scene.free()
	_main_scene = null


func test_main_scene_uses_generated_boundary_wall_sprites() -> void:
	_assert_wall_visual("LeftWall/BoundaryWallVisual", false)
	_assert_wall_visual("RightWall/BoundaryWallVisual", true)
	assert_bool(_wall_has_color_rect_visual("LeftWall")).is_false()
	assert_bool(_wall_has_color_rect_visual("RightWall")).is_false()


func _assert_wall_visual(node_path: NodePath, expected_flip_h: bool) -> void:
	var visual := _main_scene.get_node_or_null(node_path) as Sprite2D
	assert_object(visual).is_not_null()
	if visual == null:
		return

	assert_bool(visual.visible).is_true()
	assert_bool(visual.is_visible_in_tree()).is_true()
	assert_bool(FileAccess.file_exists(WALL_TEXTURE_PATH)).is_true()
	assert_object(visual.texture).is_not_null()
	if visual.texture == null:
		return

	assert_str(visual.texture.resource_path).is_equal(WALL_TEXTURE_PATH)
	assert_vector(visual.texture.get_size()).is_equal(Vector2(96, 720))
	assert_bool(visual.flip_h).is_equal(expected_flip_h)
	assert_float(visual.get_rect().size.y * absf(visual.scale.y)).is_greater_equal(720.0)
	assert_float(visual.get_rect().size.x * absf(visual.scale.x)).is_greater_equal(40.0)
	assert_int(visual.z_index).is_equal(8)
	assert_bool(visual.z_as_relative).is_false()


func _wall_has_color_rect_visual(wall_path: NodePath) -> bool:
	var wall := _main_scene.get_node_or_null(wall_path)
	assert_object(wall).is_not_null()
	if wall == null:
		return true
	for child: Node in wall.get_children():
		if child is ColorRect:
			return true
	return false
