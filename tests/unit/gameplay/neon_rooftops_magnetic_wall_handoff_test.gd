## Player Abilities Story 136: Neon Rooftops magnetic-wall scene handoff.
extends GdUnitTestSuite

const UPPER_SCENE_PATH: String = (
	"res://scenes/areas/factory_upper_altar_approach.tscn"
)
const ROOFTOPS_SCENE_PATH: String = (
	"res://scenes/areas/neon_rooftops_entry.tscn"
)
const ROOFTOPS_SCRIPT_PATH: String = (
	"res://src/gameplay/neon_rooftops_entry_scene.gd"
)
const BACKGROUND_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "env_neon_rooftops_entry_1280x720.png"
)
const MAGNETIC_TOWER_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_magnetic_tower_256x512.png"
)
const FACTORY_BRIDGE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_factory_bridge_beacon_256x384.png"
)
const REGISTRY_PATH: String = "res://data/scene_registry.json"
const REGISTRY_SCHEMA_PATH: String = "res://data/schemas/scene_registry.schema.json"
const AUDIO_SCRIPT_PATH: String = "res://src/presentation/audio_system.gd"
const UPPER_SCENE_ID: StringName = &"area_03_factory_upper_altar"
const ROOFTOPS_SCENE_ID: StringName = &"area_05_neon_rooftops"
const ROOFTOPS_ARRIVAL: StringName = &"factory_rooftop_arrival"
const FACTORY_RETURN_SPAWN: StringName = &"neon_rooftops_return"
const WALL_CLIMB_ABILITY: StringName = &"wall_climb"
const FACTORY_ROUTE_NODE: String = "NeonRooftopsRoute"
const FACTORY_RETURN_MARKER: String = "NeonRooftopsReturn"
const ROOFTOPS_RETURN_ROUTE: String = "FactoryReturnRoute"

var _spawned_nodes: Array[Node] = []


class FakeSceneManager:
	extends RefCounted

	var request_calls: Array[Dictionary] = []
	var scene_states: Dictionary = {}
	var loading: bool = false
	var locked: bool = false
	var current_scene: StringName = UPPER_SCENE_ID
	var current_spawn: StringName = &"cistern_ascender_arrival"

	func has_scene(scene_id: StringName) -> bool:
		return scene_id in [UPPER_SCENE_ID, ROOFTOPS_SCENE_ID]

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn

	func is_loading() -> bool:
		return loading

	func is_scene_locked() -> bool:
		return locked

	func get_pending_scene() -> StringName:
		if request_calls.is_empty():
			return &""
		return StringName(String(request_calls[-1].get("scene_id", "")))

	func get_pending_spawn_point() -> StringName:
		if request_calls.is_empty():
			return &""
		return StringName(String(request_calls[-1].get("spawn_point", "")))

	func get_scene_state(scene_id: StringName) -> Dictionary:
		return Dictionary(scene_states.get(String(scene_id), {})).duplicate(true)

	func set_scene_state(scene_id: StringName, state: Dictionary) -> bool:
		scene_states[String(scene_id)] = state.duplicate(true)
		return true

	func request_scene_change(
		scene_id: StringName,
		spawn_point: StringName = &"default"
	) -> bool:
		if loading or locked or not has_scene(scene_id):
			return false
		request_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		loading = true
		return true

	func reset_for_scene(
		scene_id: StringName,
		spawn_point: StringName
	) -> void:
		request_calls.clear()
		loading = false
		locked = false
		current_scene = scene_id
		current_spawn = spawn_point


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_registry_generated_scene_and_rooftop_audio_contract() -> void:
	assert_bool(FileAccess.file_exists(ROOFTOPS_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(ROOFTOPS_SCRIPT_PATH)).is_true()
	assert_bool(FileAccess.file_exists(BACKGROUND_PATH)).is_true()
	assert_bool(FileAccess.file_exists(MAGNETIC_TOWER_PATH)).is_true()
	assert_bool(FileAccess.file_exists(FACTORY_BRIDGE_PATH)).is_true()

	var registry: Dictionary = _read_json_dictionary(REGISTRY_PATH)
	var entries: Dictionary = Dictionary(registry.get("entries", {}))
	assert_bool(entries.has(String(ROOFTOPS_SCENE_ID))).is_true()
	var entry: Dictionary = Dictionary(entries.get(String(ROOFTOPS_SCENE_ID), {}))
	assert_str(String(entry.get("path", ""))).is_equal(ROOFTOPS_SCENE_PATH)
	assert_str(String(entry.get("type", ""))).is_equal("area")
	assert_str(String(entry.get("default_spawn", ""))).is_equal(
		String(ROOFTOPS_ARRIVAL)
	)
	assert_str(String(entry.get("display_name", ""))).is_equal("Neon Rooftops")
	var schema: Dictionary = _read_json_dictionary(REGISTRY_SCHEMA_PATH)
	assert_bool(Dictionary(schema.get("entries", {})).has(
		String(ROOFTOPS_SCENE_ID)
	)).is_true()

	_assert_png_contract(BACKGROUND_PATH, Vector2i(1280, 720), Image.ALPHA_NONE)
	_assert_png_contract(MAGNETIC_TOWER_PATH, Vector2i(256, 512), Image.ALPHA_BLEND)
	_assert_png_contract(FACTORY_BRIDGE_PATH, Vector2i(256, 384), Image.ALPHA_BLEND)

	var upper: Node = _instantiate_scene(UPPER_SCENE_PATH)
	assert_that(upper).is_not_null()
	if upper != null:
		assert_that(upper.get_node_or_null(FACTORY_ROUTE_NODE)).is_not_null()
		assert_that(upper.get_node_or_null(FACTORY_RETURN_MARKER)).is_not_null()

	var rooftops: Node = _instantiate_scene(ROOFTOPS_SCENE_PATH)
	assert_that(rooftops).is_not_null()
	if rooftops != null:
		assert_str(String(rooftops.get_meta("scene_id", ""))).is_equal(
			String(ROOFTOPS_SCENE_ID)
		)
		assert_that(rooftops.get_node_or_null("FactoryRooftopArrival")).is_not_null()
		assert_that(
			rooftops.get_node_or_null("Player/Sprite") as AnimatedSprite2D
		).is_not_null()
		assert_that(rooftops.get_node_or_null("Player/Camera2D")).is_not_null()
		assert_that(rooftops.get_node_or_null(
			"MagneticTower/CollisionShape2D"
		)).is_not_null()
		assert_that(rooftops.get_node_or_null(
			"UpperRoof/CollisionShape2D"
		)).is_not_null()
		assert_that(rooftops.get_node_or_null(
			"TopBoundary/CollisionShape2D"
		)).is_not_null()
		assert_that(rooftops.get_node_or_null(
			"RooftopProofArea/CollisionShape2D"
		)).is_not_null()
		assert_that(rooftops.get_node_or_null(ROOFTOPS_RETURN_ROUTE)).is_not_null()
		assert_bool(rooftops.has_method(
			"get_neon_rooftops_entry_diagnostics"
		)).is_true()

	var audio: Node = _instantiate_script_node(AUDIO_SCRIPT_PATH)
	assert_that(audio).is_not_null()
	if audio != null and audio.has_method("get_scene_audio_cue"):
		var cue: Dictionary = audio.call(
			"get_scene_audio_cue",
			ROOFTOPS_SCENE_ID
		)
		assert_str(String(cue.get("music_id", ""))).is_equal("mus_rooftop")
		assert_str(String(cue.get("ambient_id", ""))).is_equal("amb_rooftop")


func test_factory_route_is_gated_one_shot_persistent_and_return_spawn_safe() -> void:
	var upper: Node = _instantiate_scene(UPPER_SCENE_PATH)
	assert_that(upper).is_not_null()
	if upper == null:
		return
	assert_bool(upper.has_method("try_request_neon_rooftops")).is_true()
	assert_bool(upper.has_method("get_factory_upper_altar_diagnostics")).is_true()
	if not upper.has_method("try_request_neon_rooftops"):
		return

	var manager := FakeSceneManager.new()
	assert_bool(bool(upper.call("configure_scene_manager_runtime", manager))).is_true()
	upper.call("set_local_state", {
		"factory_upper_hidden_altar_discovered": true,
		"unlocked_abilities": ["dash", "double_jump", "aerial_attack"],
	})
	var player: Node2D = upper.get_node_or_null("Player") as Node2D
	var route: Node2D = upper.get_node_or_null(FACTORY_ROUTE_NODE) as Node2D
	assert_that(player).is_not_null()
	assert_that(route).is_not_null()
	if player == null or route == null:
		return
	player.global_position = route.global_position
	assert_bool(bool(upper.call("try_request_neon_rooftops", player))).is_false()
	var locked: Dictionary = upper.call("get_factory_upper_altar_diagnostics")
	assert_bool(bool(locked.get("neon_route_available", true))).is_false()

	upper.call("set_local_state", {
		"factory_upper_hidden_altar_discovered": true,
		"factory_upper_wall_climb_reward_claimed": true,
		"factory_upper_wall_climb_route_proven": true,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb",
		],
	})
	player.global_position = route.global_position
	var ready: Dictionary = upper.call("get_factory_upper_altar_diagnostics")
	assert_bool(bool(ready.get("neon_route_available", false))).is_true()
	assert_str(String(ready.get("neon_target_scene_id", ""))).is_equal(
		String(ROOFTOPS_SCENE_ID)
	)
	assert_bool(bool(upper.call("try_request_neon_rooftops", player))).is_true()
	assert_bool(bool(upper.call("try_request_neon_rooftops", player))).is_false()
	assert_int(manager.request_calls.size()).is_equal(1)
	assert_str(String(manager.request_calls[0].get("scene_id", ""))).is_equal(
		String(ROOFTOPS_SCENE_ID)
	)
	assert_str(String(manager.request_calls[0].get("spawn_point", ""))).is_equal(
		String(ROOFTOPS_ARRIVAL)
	)
	var persisted: Dictionary = manager.get_scene_state(UPPER_SCENE_ID)
	assert_bool(bool(persisted.get(
		"factory_upper_neon_rooftops_route_opened",
		false
	))).is_true()
	var target_state: Dictionary = manager.get_scene_state(ROOFTOPS_SCENE_ID)
	assert_array(Array(target_state.get("unlocked_abilities", []))).contains([
		"wall_climb",
	])

	var restored: Node = _instantiate_scene(UPPER_SCENE_PATH)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	manager.reset_for_scene(UPPER_SCENE_ID, FACTORY_RETURN_SPAWN)
	assert_bool(bool(restored.call(
		"configure_scene_manager_runtime",
		manager
	))).is_true()
	restored.call("set_local_state", persisted)
	var restored_player: Node2D = restored.get_node_or_null("Player") as Node2D
	var return_marker: Marker2D = restored.get_node_or_null(
		FACTORY_RETURN_MARKER
	) as Marker2D
	assert_that(restored_player).is_not_null()
	assert_that(return_marker).is_not_null()
	if restored_player != null and return_marker != null:
		assert_vector(restored_player.global_position).is_equal(
			return_marker.global_position
		)


func test_rooftop_proof_requires_wall_climb_persists_and_returns_to_factory() -> void:
	var rooftops: Node = _instantiate_scene(ROOFTOPS_SCENE_PATH)
	assert_that(rooftops).is_not_null()
	if rooftops == null:
		return
	assert_bool(rooftops.has_method("try_prove_neon_rooftop_entry")).is_true()
	assert_bool(rooftops.has_method("try_request_factory_return")).is_true()
	assert_bool(rooftops.has_method(
		"get_neon_rooftops_entry_diagnostics"
	)).is_true()
	if not rooftops.has_method("try_prove_neon_rooftop_entry"):
		return

	var manager := FakeSceneManager.new()
	manager.reset_for_scene(ROOFTOPS_SCENE_ID, ROOFTOPS_ARRIVAL)
	assert_bool(bool(rooftops.call(
		"configure_scene_manager_runtime",
		manager
	))).is_true()
	rooftops.call("set_local_state", {
		"unlocked_abilities": ["dash", "double_jump", "aerial_attack"],
	})
	var player: Node2D = rooftops.get_node_or_null("Player") as Node2D
	var proof: Node2D = rooftops.get_node_or_null("RooftopProofArea") as Node2D
	assert_that(player).is_not_null()
	assert_that(proof).is_not_null()
	if player == null or proof == null:
		return
	player.global_position = proof.global_position
	assert_bool(bool(rooftops.call(
		"try_prove_neon_rooftop_entry",
		player
	))).is_false()

	rooftops.call("set_local_state", {
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb",
		],
	})
	player.global_position = proof.global_position
	assert_bool(bool(rooftops.call(
		"try_prove_neon_rooftop_entry",
		player
	))).is_true()
	assert_bool(bool(rooftops.call(
		"try_prove_neon_rooftop_entry",
		player
	))).is_false()
	var proven: Dictionary = rooftops.call(
		"get_neon_rooftops_entry_diagnostics"
	)
	assert_bool(bool(proven.get("entry_traversed", false))).is_true()
	assert_str(String(proven.get("objective_text", ""))).is_equal(
		"Neon Rooftops Reached"
	)
	var persisted: Dictionary = manager.get_scene_state(ROOFTOPS_SCENE_ID)
	assert_bool(bool(persisted.get(
		"neon_rooftops_entry_traversed",
		false
	))).is_true()
	assert_array(Array(persisted.get("unlocked_abilities", []))).contains([
		"wall_climb",
	])

	var return_route: Node2D = rooftops.get_node_or_null(
		ROOFTOPS_RETURN_ROUTE
	) as Node2D
	assert_that(return_route).is_not_null()
	if return_route == null:
		return
	player.global_position = return_route.global_position
	assert_bool(bool(rooftops.call(
		"try_request_factory_return",
		player
	))).is_true()
	assert_bool(bool(rooftops.call(
		"try_request_factory_return",
		player
	))).is_false()
	assert_int(manager.request_calls.size()).is_equal(1)
	assert_str(String(manager.request_calls[0].get("scene_id", ""))).is_equal(
		String(UPPER_SCENE_ID)
	)
	assert_str(String(manager.request_calls[0].get("spawn_point", ""))).is_equal(
		String(FACTORY_RETURN_SPAWN)
	)


func _assert_png_contract(
	path: String,
	expected_size: Vector2i,
	expected_alpha: Image.AlphaMode
) -> void:
	if not FileAccess.file_exists(path):
		return
	var image := Image.new()
	assert_int(image.load(path)).is_equal(OK)
	assert_int(image.get_width()).is_equal(expected_size.x)
	assert_int(image.get_height()).is_equal(expected_size.y)
	assert_int(image.detect_alpha()).is_equal(expected_alpha)


func _instantiate_scene(path: String) -> Node:
	if not FileAccess.file_exists(path):
		return null
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		return null
	var instance: Node = packed.instantiate()
	_spawned_nodes.append(instance)
	add_child(instance)
	return instance


func _instantiate_script_node(path: String) -> Node:
	if not FileAccess.file_exists(path):
		return null
	var script: Script = load(path) as Script
	if script == null:
		return null
	var node: Node = script.new() as Node
	if node == null:
		return null
	_spawned_nodes.append(node)
	add_child(node)
	return node


func _read_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}


func _stop_runtime_audio_players() -> void:
	for player: AudioStreamPlayer in get_tree().get_nodes_in_group(
		"audio_music_player"
	):
		player.stop()
	for player: AudioStreamPlayer in get_tree().get_nodes_in_group(
		"audio_ambient_player"
	):
		player.stop()
