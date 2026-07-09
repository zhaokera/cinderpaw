## Player Abilities Story 102: Old Factory route floor/platform visual pass.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FLOOR_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_route_floor/"
	+ "env_old_factory_route_floor_tile_256x96.png"
)
const ENTRY_PLATFORM_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_route_platform/"
	+ "env_old_factory_route_entry_platform_320x96.png"
)
const CACHE_PLATFORM_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_route_platform/"
	+ "env_old_factory_route_cache_platform_320x96.png"
)
const MIN_FACTORY_ROUTE_WIDTH: float = 7040.0

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_factory_route_has_generated_floor_and_platform_visuals() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	assert_bool(destination.has_method("get_factory_route_visual_diagnostics")).is_true()
	if not destination.has_method("get_factory_route_visual_diagnostics"):
		return

	var diagnostics: Dictionary = destination.call("get_factory_route_visual_diagnostics")
	assert_float(float(diagnostics.get("ground_collision_width", 0.0))).is_greater_equal(
		MIN_FACTORY_ROUTE_WIDTH
	)

	var floor: Dictionary = Dictionary(diagnostics.get("floor", {}))
	var entry_platform: Dictionary = Dictionary(diagnostics.get("entry_platform", {}))
	var cache_platform: Dictionary = Dictionary(diagnostics.get("cache_platform", {}))
	_assert_visual_contract(floor, "Ground/FactoryRouteFloorVisual", FLOOR_TEXTURE_PATH, 11)
	_assert_visual_contract(
		entry_platform,
		"EntryPlatform/FactoryRouteEntryPlatformVisual",
		ENTRY_PLATFORM_TEXTURE_PATH,
		11
	)
	_assert_visual_contract(
		cache_platform,
		"FactoryCachePlatform/FactoryRouteCachePlatformVisual",
		CACHE_PLATFORM_TEXTURE_PATH,
		11
	)

	assert_float(float(floor.get("world_width", 0.0))).is_greater_equal(MIN_FACTORY_ROUTE_WIDTH)
	assert_float(float(floor.get("world_height", 0.0))).is_greater_equal(96.0)
	assert_float(float(entry_platform.get("world_width", 0.0))).is_greater_equal(240.0)
	assert_float(float(cache_platform.get("world_width", 0.0))).is_greater_equal(240.0)
	assert_bool(bool(diagnostics.get("uses_placeholder_color_rect", true))).is_false()


func _instantiate_factory_scene() -> Node:
	assert_bool(FileAccess.file_exists(FACTORY_SCENE_PATH)).is_true()
	var packed: PackedScene = load(FACTORY_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var destination: Node = packed.instantiate()
	add_child(destination)
	_spawned_nodes.append(destination)
	return destination


func _assert_visual_contract(
	visual: Dictionary,
	expected_node_path: String,
	expected_texture_path: String,
	expected_z_index: int
) -> void:
	assert_str(String(visual.get("node_path", ""))).is_equal(expected_node_path)
	assert_bool(bool(visual.get("visible", false))).is_true()
	assert_str(String(visual.get("texture_path", ""))).is_equal(expected_texture_path)
	assert_bool(FileAccess.file_exists(expected_texture_path)).is_true()
	assert_int(int(visual.get("z_index", -999))).is_equal(expected_z_index)
	assert_vector(Vector2(visual.get("texture_size", Vector2.ZERO))).is_not_equal(Vector2.ZERO)
