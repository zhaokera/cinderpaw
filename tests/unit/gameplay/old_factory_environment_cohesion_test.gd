## Combat Presentation Story034: unscaled Old Factory environment cohesion.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = (
	"res://scenes/factory_route_transition_shell.tscn"
)
const CONTROLLER_SCRIPT_PATH: String = (
	"res://src/presentation/old_factory_environment_cohesion.gd"
)
const GENERATION_RECORD_PATH: String = (
	"res://assets/generated/source/"
	+ "old_factory_environment_cohesion_imagegen_20260717.md"
)
const BACKGROUND_PATHS: Array[String] = [
	"res://assets/environment/old_factory_route/background/"
	+ "env_old_factory_route_entry_1280x720.png",
	"res://assets/environment/old_factory_route/background/"
	+ "env_old_factory_route_furnace_1280x720.png",
	"res://assets/environment/old_factory_route/background/"
	+ "env_old_factory_route_condenser_1280x720.png",
	"res://assets/environment/old_factory_route/background/"
	+ "env_old_factory_route_tailrace_1280x720.png",
]
const SOURCE_PATHS: Array[String] = [
	"res://assets/generated/source/"
	+ "old_factory_environment_entry_imagegen_20260717.png",
	"res://assets/generated/source/"
	+ "old_factory_environment_furnace_imagegen_20260717.png",
	"res://assets/generated/source/"
	+ "old_factory_environment_condenser_imagegen_20260717.png",
	"res://assets/generated/source/"
	+ "old_factory_environment_tailrace_imagegen_20260717.png",
]
const EXPECTED_VIEWPORT_SIZE: Vector2 = Vector2(1280, 720)
const EXPECTED_TILE_COUNT: int = 24
const EXPECTED_WORLD_WIDTH: float = 30720.0
const EXPECTED_GAMEPLAY_WIDTH: float = 30080.0

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()
	_stop_runtime_audio_players()


func test_factory_route_uses_four_unscaled_generated_backgrounds() -> void:
	for path: String in (
		[CONTROLLER_SCRIPT_PATH, GENERATION_RECORD_PATH]
		+ BACKGROUND_PATHS
		+ SOURCE_PATHS
	):
		assert_bool(FileAccess.file_exists(path)).override_failure_message(
			"Story034 artifact missing: %s" % path
		).is_true()
	for background_path: String in BACKGROUND_PATHS:
		if not FileAccess.file_exists(background_path):
			continue
		var image: Image = Image.load_from_file(
			ProjectSettings.globalize_path(background_path)
		)
		assert_that(image).is_not_null()
		if image != null:
			assert_vector(Vector2(image.get_size())).is_equal(
				EXPECTED_VIEWPORT_SIZE
			)

	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	var cohesion: Node = factory.get_node_or_null("EnvironmentCohesion")
	assert_that(cohesion).override_failure_message(
		"Story034 must author EnvironmentCohesion"
	).is_not_null()
	if cohesion == null or not cohesion.has_method("get_diagnostics"):
		return

	var diagnostics: Dictionary = cohesion.call("get_diagnostics")
	assert_int(int(diagnostics.get("variant_count", 0))).is_equal(
		BACKGROUND_PATHS.size()
	)
	assert_int(int(diagnostics.get("tile_count", 0))).is_equal(
		EXPECTED_TILE_COUNT
	)
	assert_int(int(diagnostics.get("unique_texture_count", 0))).is_equal(
		BACKGROUND_PATHS.size()
	)
	assert_vector(Vector2(diagnostics.get("tile_size", Vector2.ZERO))).is_equal(
		EXPECTED_VIEWPORT_SIZE
	)
	assert_float(float(diagnostics.get("coverage_width", 0.0))).is_equal(
		EXPECTED_WORLD_WIDTH
	)
	assert_bool(bool(diagnostics.get("all_tiles_unscaled", false))).is_true()
	assert_bool(bool(diagnostics.get("all_tiles_opaque", false))).is_true()
	assert_bool(bool(diagnostics.get("legacy_background_covered", false))).is_true()
	assert_that(Array(diagnostics.get("texture_paths", []))).contains_exactly(
		BACKGROUND_PATHS
	)

	assert_bool(factory.has_method("get_factory_route_visual_diagnostics")).is_true()
	if not factory.has_method("get_factory_route_visual_diagnostics"):
		return
	var route: Dictionary = factory.call("get_factory_route_visual_diagnostics")
	assert_float(float(route.get("ground_collision_width", 0.0))).is_equal(
		EXPECTED_GAMEPLAY_WIDTH
	)
	assert_bool(bool(route.get("uses_placeholder_color_rect", true))).is_false()


func _instantiate_factory_scene() -> Node:
	var packed: PackedScene = load(FACTORY_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var destination: Node = packed.instantiate()
	add_child(destination)
	_spawned_nodes.append(destination)
	return destination


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	if audio_system.has_method("stop_music"):
		audio_system.call("stop_music", 0.0)
	if audio_system.has_method("stop_ambient"):
		audio_system.call("stop_ambient", 0.0)
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var player: AudioStreamPlayer = child as AudioStreamPlayer
			player.stop()
			player.stream = null
		elif child is AudioStreamPlayer2D:
			var spatial_player: AudioStreamPlayer2D = child as AudioStreamPlayer2D
			spatial_player.stop()
			spatial_player.stream = null
