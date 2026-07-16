## Combat Presentation Story 033: shared Old Factory steam vent motion readability.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const STEAM_VENT_SCRIPT_PATH: String = "res://src/feature/factory_steam_vent_hazard.gd"
const STEAM_VENT_FRAMES_PATH: String = (
	"res://assets/environment/old_factory_steam_vent/factory_steam_vent_sprite_frames.tres"
)
const LEGACY_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png"
)
const ACTIVE_ANIMATION: StringName = &"active"
const EXPECTED_HAZARD_COUNT: int = 26
const EXPECTED_PHASE_FRAMES: int = 4
const EXPECTED_DAMAGE: int = 8
const EXPECTED_COOLDOWN_SEC: float = 1.0

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_shared_factory_steam_vents_use_playing_multiframe_active_animation() -> void:
	assert_bool(FileAccess.file_exists(STEAM_VENT_FRAMES_PATH)).is_true()
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var hazards: Array[Node] = []
	_collect_steam_vent_hazards(destination, hazards)
	assert_int(hazards.size()).is_equal(EXPECTED_HAZARD_COUNT)
	for hazard: Node in hazards:
		var legacy_visual: Sprite2D = hazard.get_node_or_null("Visual") as Sprite2D
		var motion: AnimatedSprite2D = (
			hazard.get_node_or_null("SteamAnimation") as AnimatedSprite2D
		)
		assert_that(legacy_visual).is_not_null()
		assert_that(motion).is_not_null()
		if motion == null:
			continue
		assert_that(motion.sprite_frames).is_not_null()
		if motion.sprite_frames == null:
			continue
		assert_str(motion.sprite_frames.resource_path).is_equal(STEAM_VENT_FRAMES_PATH)
		for phase: StringName in [&"safe", &"warning", ACTIVE_ANIMATION]:
			assert_bool(motion.sprite_frames.has_animation(phase)).is_true()
			assert_int(motion.sprite_frames.get_frame_count(phase)).is_equal(
				EXPECTED_PHASE_FRAMES
			)
			assert_bool(motion.sprite_frames.get_animation_loop(phase)).is_true()
			var texture_paths: Dictionary = {}
			for frame_index: int in range(EXPECTED_PHASE_FRAMES):
				var texture: Texture2D = motion.sprite_frames.get_frame_texture(
					phase,
					frame_index
				)
				assert_that(texture).is_not_null()
				if texture == null:
					continue
				assert_vector(texture.get_size()).is_equal(Vector2(256, 256))
				texture_paths[texture.resource_path] = true
			assert_int(texture_paths.size()).is_equal(EXPECTED_PHASE_FRAMES)
		assert_str(String(hazard.call("get_visual_texture_path"))).is_equal(LEGACY_TEXTURE_PATH)
		assert_int(int(hazard.call("get_damage"))).is_equal(EXPECTED_DAMAGE)
		assert_float(float(hazard.call("get_contact_cooldown_sec"))).is_equal(
			EXPECTED_COOLDOWN_SEC
		)

	await get_tree().process_frame
	var entrance_motion: AnimatedSprite2D = destination.get_node_or_null(
		"FactorySteamVentHazard/SteamAnimation"
	) as AnimatedSprite2D
	var checkpoint_motion: AnimatedSprite2D = destination.get_node_or_null(
		"FactoryCheckpointSteamVentHazard/SteamAnimation"
	) as AnimatedSprite2D
	assert_that(entrance_motion).is_not_null()
	assert_that(checkpoint_motion).is_not_null()
	if entrance_motion != null:
		assert_that(entrance_motion.animation).is_equal(ACTIVE_ANIMATION)
		assert_bool(entrance_motion.is_playing()).is_true()
	if checkpoint_motion != null:
		assert_bool(checkpoint_motion.is_playing()).is_false()


func _instantiate_factory_scene() -> Node:
	var packed: PackedScene = load(FACTORY_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var destination: Node = packed.instantiate()
	add_child(destination)
	_spawned_nodes.append(destination)
	return destination


func _collect_steam_vent_hazards(root: Node, hazards: Array[Node]) -> void:
	var script: Script = root.get_script() as Script
	if script != null and script.resource_path == STEAM_VENT_SCRIPT_PATH:
		hazards.append(root)
	for child: Node in root.get_children():
		_collect_steam_vent_hazards(child, hazards)
