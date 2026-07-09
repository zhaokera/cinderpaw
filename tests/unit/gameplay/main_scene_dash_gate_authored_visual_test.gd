## Player Abilities Story 100: MainScene Dash Gate authored visual replacement.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const DASH_GATE_TEXTURE_PATH: String = "res://assets/environment/dash_gate/dash_gate_marker.png"
const REUSED_ELECTRIC_LEAK_PATH: String = "res://assets/environment/rat_king_arena/electric_leak.png"

var main_scene: Node2D


func before_test() -> void:
	main_scene = MAIN_SCENE.instantiate() as Node2D
	add_child(main_scene)


func after_test() -> void:
	if is_instance_valid(main_scene):
		if main_scene.get_parent() != null:
			main_scene.get_parent().remove_child(main_scene)
		main_scene.free()
	main_scene = null


func test_dash_gate_uses_dedicated_generated_marker() -> void:
	var visual := _get_dash_gate_visual_or_fail()
	if visual == null:
		return

	assert_that(FileAccess.file_exists(DASH_GATE_TEXTURE_PATH)).is_true()
	assert_object(visual.texture).is_not_null()
	if visual.texture == null:
		return

	assert_str(visual.texture.resource_path).is_equal(DASH_GATE_TEXTURE_PATH)
	assert_str(visual.texture.resource_path).is_not_equal(REUSED_ELECTRIC_LEAK_PATH)
	assert_vector(visual.texture.get_size()).is_equal(Vector2(256, 256))
	assert_float(visual.rotation).is_equal_approx(0.0, 0.001)
	assert_vector(visual.scale).is_equal(Vector2(0.52, 0.52))


func test_dash_gate_scene_file_no_longer_references_reused_electric_leak() -> void:
	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")

	assert_bool(scene_text.contains(REUSED_ELECTRIC_LEAK_PATH)).is_false()
	assert_bool(scene_text.contains(DASH_GATE_TEXTURE_PATH)).is_true()


func _get_dash_gate_visual_or_fail() -> Sprite2D:
	var visual := main_scene.get_node_or_null("DashExplorationGate/Visual") as Sprite2D
	assert_object(visual).is_not_null()
	return visual
