## Player Abilities Story 134: deep-cistern ascender and dormant altar approach.
extends GdUnitTestSuite

const UNDERGROUND_SCENE_PATH: String = "res://scenes/areas/underground_passage.tscn"
const UPPER_SCENE_PATH: String = (
	"res://scenes/areas/factory_upper_altar_approach.tscn"
)
const UPPER_SCRIPT_PATH: String = (
	"res://src/gameplay/factory_upper_altar_approach_scene.gd"
)
const BACKGROUND_PATH: String = (
	"res://assets/environment/factory_upper_altar/"
	+ "env_factory_upper_altar_approach_1280x720.png"
)
const ASCENDER_PATH: String = (
	"res://assets/environment/factory_upper_altar/"
	+ "prop_deep_cistern_ascender_384x512.png"
)
const ALTAR_PATH: String = (
	"res://assets/environment/factory_upper_altar/"
	+ "prop_factory_hidden_altar_dormant_384x384.png"
)
const REGISTRY_PATH: String = "res://data/scene_registry.json"
const REGISTRY_SCHEMA_PATH: String = "res://data/schemas/scene_registry.schema.json"
const UNDERGROUND_SCENE_ID: StringName = &"area_04_underground_passage"
const UPPER_SCENE_ID: StringName = &"area_03_factory_upper_altar"
const UPPER_SPAWN_POINT: StringName = &"cistern_ascender_arrival"
const UNDERGROUND_RETURN_SPAWN: StringName = &"deep_cistern_ascender_return"
const ASCENDER_ROUTE_NODE: String = "DeepCisternAscenderRoute"
const ASCENDER_RETURN_MARKER_NODE: String = "DeepCisternAscenderReturnSpawn"
const UPPER_RETURN_ROUTE_NODE: String = "UndergroundReturnRoute"
const ALTAR_NODE: String = "DormantHiddenAltar"

var _spawned_nodes: Array[Node] = []


class FakeSceneManager:
	extends RefCounted

	var request_calls: Array[Dictionary] = []
	var scene_states: Dictionary = {}
	var loading: bool = false
	var locked: bool = false
	var current_scene: StringName = UNDERGROUND_SCENE_ID
	var current_spawn: StringName = &"factory_drop_entry"
	var runtime_root_configured: bool = false

	func has_scene(scene_id: StringName) -> bool:
		return scene_id in [UNDERGROUND_SCENE_ID, UPPER_SCENE_ID]

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn

	func is_loading() -> bool:
		return loading

	func is_scene_locked() -> bool:
		return locked

	func is_runtime_scene_swap_enabled() -> bool:
		return runtime_root_configured

	func configure_runtime_scene_root(
		_root: Node,
		_current_scene_node: Node = null
	) -> bool:
		runtime_root_configured = true
		return true

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


func test_authored_registry_scene_and_generated_asset_contract() -> void:
	assert_bool(FileAccess.file_exists(UPPER_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(UPPER_SCRIPT_PATH)).is_true()
	assert_bool(FileAccess.file_exists(BACKGROUND_PATH)).is_true()
	assert_bool(FileAccess.file_exists(ASCENDER_PATH)).is_true()
	assert_bool(FileAccess.file_exists(ALTAR_PATH)).is_true()

	var registry: Dictionary = _read_json_dictionary(REGISTRY_PATH)
	var entries: Dictionary = Dictionary(registry.get("entries", {}))
	assert_bool(entries.has(String(UPPER_SCENE_ID))).is_true()
	var entry: Dictionary = Dictionary(entries.get(String(UPPER_SCENE_ID), {}))
	assert_str(String(entry.get("path", ""))).is_equal(UPPER_SCENE_PATH)
	assert_str(String(entry.get("type", ""))).is_equal("area")
	assert_str(String(entry.get("default_spawn", ""))).is_equal(
		String(UPPER_SPAWN_POINT)
	)
	var schema: Dictionary = _read_json_dictionary(REGISTRY_SCHEMA_PATH)
	assert_bool(Dictionary(schema.get("entries", {})).has(
		String(UPPER_SCENE_ID)
	)).is_true()

	_assert_png_contract(BACKGROUND_PATH, Vector2i(1280, 720), Image.ALPHA_NONE)
	_assert_png_contract(ASCENDER_PATH, Vector2i(384, 512), Image.ALPHA_BLEND)
	_assert_png_contract(ALTAR_PATH, Vector2i(384, 384), Image.ALPHA_BLEND)

	var underground: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	assert_that(underground).is_not_null()
	if underground != null:
		assert_that(underground.get_node_or_null(ASCENDER_ROUTE_NODE)).is_not_null()
		assert_that(underground.get_node_or_null(
			ASCENDER_RETURN_MARKER_NODE
		)).is_not_null()
		assert_bool(underground.has_method(
			"get_deep_cistern_ascender_diagnostics"
		)).is_true()

	var upper: Node = _instantiate_scene(UPPER_SCENE_PATH)
	assert_that(upper).is_not_null()
	if upper == null:
		return
	assert_str(String(upper.get_meta("scene_id", ""))).is_equal(
		String(UPPER_SCENE_ID)
	)
	assert_that(upper.get_node_or_null("CisternAscenderArrival")).is_not_null()
	assert_that(upper.get_node_or_null("Player/Camera2D")).is_not_null()
	assert_that(upper.get_node_or_null(UPPER_RETURN_ROUTE_NODE)).is_not_null()
	assert_that(upper.get_node_or_null(ALTAR_NODE)).is_not_null()
	assert_that(upper.get_node_or_null("ApproachPlatformA/CollisionShape2D")).is_not_null()
	assert_that(upper.get_node_or_null("ApproachPlatformB/CollisionShape2D")).is_not_null()
	assert_that(upper.get_node_or_null("ApproachPlatformC/CollisionShape2D")).is_not_null()
	assert_bool(upper.has_method("get_factory_upper_altar_diagnostics")).is_true()


func test_stalker_clear_unlocks_one_shot_ascender_transition() -> void:
	var underground: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	assert_that(underground).is_not_null()
	if underground == null:
		return
	assert_bool(underground.has_method(
		"try_request_deep_cistern_ascender"
	)).is_true()
	assert_bool(underground.has_method(
		"get_deep_cistern_ascender_diagnostics"
	)).is_true()
	if not underground.has_method("get_deep_cistern_ascender_diagnostics"):
		return

	var manager := FakeSceneManager.new()
	assert_bool(bool(underground.call(
		"configure_scene_manager_runtime",
		manager
	))).is_true()
	var player: Node2D = underground.get_node_or_null("Player") as Node2D
	var route: Node2D = underground.get_node_or_null(
		ASCENDER_ROUTE_NODE
	) as Node2D
	assert_that(player).is_not_null()
	assert_that(route).is_not_null()
	if player == null or route == null:
		return
	player.global_position = route.global_position
	assert_bool(bool(underground.call(
		"try_request_deep_cistern_ascender",
		player
	))).is_false()
	var locked: Dictionary = underground.call(
		"get_deep_cistern_ascender_diagnostics"
	)
	assert_bool(bool(locked.get("route_available", true))).is_false()

	player.global_position = Vector2(300.0, 576.0)
	underground.call("set_local_state", _story133_cleared_state())
	player.global_position = route.global_position
	await get_tree().process_frame
	var ready: Dictionary = underground.call(
		"get_deep_cistern_ascender_diagnostics"
	)
	assert_bool(bool(ready.get("route_available", false))).is_true()
	assert_str(String(ready.get("target_scene_id", ""))).is_equal(
		String(UPPER_SCENE_ID)
	)
	var objective: Label = underground.get_node_or_null(
		"UndergroundObjectiveLabel"
	) as Label
	assert_that(objective).is_not_null()
	if objective != null:
		assert_str(objective.text).is_equal(
			"Ride Ascender to Upper Factory"
		)
	assert_bool(bool(underground.call(
		"try_request_deep_cistern_ascender",
		player
	))).is_true()
	assert_bool(bool(underground.call(
		"try_request_deep_cistern_ascender",
		player
	))).is_false()
	assert_int(manager.request_calls.size()).is_equal(1)
	assert_str(String(manager.request_calls[0].get("scene_id", ""))).is_equal(
		String(UPPER_SCENE_ID)
	)
	assert_str(String(manager.request_calls[0].get("spawn_point", ""))).is_equal(
		String(UPPER_SPAWN_POINT)
	)
	var persisted: Dictionary = manager.get_scene_state(UNDERGROUND_SCENE_ID)
	assert_bool(bool(persisted.get(
		"underground_deep_cistern_stalker_defeated",
		false
	))).is_true()
	assert_array(Array(persisted.get("unlocked_abilities", []))).contains([
		"dash",
		"double_jump",
		"aerial_attack",
	])


func test_dormant_altar_discovery_restore_and_roundtrip_do_not_unlock_wall_climb() -> void:
	var upper: Node = _instantiate_scene(UPPER_SCENE_PATH)
	assert_that(upper).is_not_null()
	if upper == null:
		return
	assert_bool(upper.has_method("try_discover_hidden_altar")).is_true()
	assert_bool(upper.has_method("try_request_underground_return")).is_true()
	assert_bool(upper.has_method("get_factory_upper_altar_diagnostics")).is_true()
	if not upper.has_method("get_factory_upper_altar_diagnostics"):
		return

	var manager := FakeSceneManager.new()
	manager.reset_for_scene(UPPER_SCENE_ID, UPPER_SPAWN_POINT)
	manager.scene_states[String(UNDERGROUND_SCENE_ID)] = _story133_cleared_state()
	assert_bool(bool(upper.call("configure_scene_manager_runtime", manager))).is_true()
	upper.call("set_local_state", {
		"unlocked_abilities": ["dash", "double_jump", "aerial_attack"],
	})
	var player: Node2D = upper.get_node_or_null("Player") as Node2D
	var altar: Node2D = upper.get_node_or_null(ALTAR_NODE) as Node2D
	assert_that(player).is_not_null()
	assert_that(altar).is_not_null()
	if player == null or altar == null:
		return
	player.global_position = altar.global_position
	assert_bool(bool(upper.call("try_discover_hidden_altar", player))).is_true()
	assert_bool(bool(upper.call("try_discover_hidden_altar", player))).is_false()
	var discovered: Dictionary = upper.call(
		"get_factory_upper_altar_diagnostics"
	)
	assert_bool(bool(discovered.get("altar_discovered", false))).is_true()
	assert_str(String(discovered.get("objective_text", ""))).is_equal(
		"Dormant Altar Found"
	)
	assert_bool(bool(discovered.get("altar_prompt_visible", true))).is_false()
	assert_array(Array(discovered.get("unlocked_abilities", []))).not_contains(
		["wall_climb"]
	)
	var saved: Dictionary = upper.call("get_local_state")
	assert_bool(bool(saved.get(
		"factory_upper_hidden_altar_discovered",
		false
	))).is_true()

	var restored: Node = _instantiate_scene(UPPER_SCENE_PATH)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", saved)
	var restored_diagnostics: Dictionary = restored.call(
		"get_factory_upper_altar_diagnostics"
	)
	assert_bool(bool(restored_diagnostics.get(
		"altar_discovered",
		false
	))).is_true()
	assert_int(int(restored_diagnostics.get(
		"discovery_feedback_count",
		-1
	))).is_equal(0)
	assert_array(Array(restored_diagnostics.get(
		"unlocked_abilities",
		[]
	))).not_contains(["wall_climb"])

	var return_route: Node2D = upper.get_node_or_null(
		UPPER_RETURN_ROUTE_NODE
	) as Node2D
	assert_that(return_route).is_not_null()
	if return_route == null:
		return
	player.global_position = return_route.global_position
	assert_bool(bool(upper.call(
		"try_request_underground_return",
		player
	))).is_true()
	assert_int(manager.request_calls.size()).is_equal(1)
	assert_str(String(manager.request_calls[0].get("scene_id", ""))).is_equal(
		String(UNDERGROUND_SCENE_ID)
	)
	assert_str(String(manager.request_calls[0].get("spawn_point", ""))).is_equal(
		String(UNDERGROUND_RETURN_SPAWN)
	)

	var underground: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	assert_that(underground).is_not_null()
	if underground == null:
		return
	manager.reset_for_scene(UNDERGROUND_SCENE_ID, UNDERGROUND_RETURN_SPAWN)
	underground.call("set_local_state", _story133_cleared_state())
	assert_bool(bool(underground.call(
		"configure_scene_manager_runtime",
		manager
	))).is_true()
	var underground_player: Node2D = underground.get_node_or_null(
		"Player"
	) as Node2D
	var return_marker: Marker2D = underground.get_node_or_null(
		ASCENDER_RETURN_MARKER_NODE
	) as Marker2D
	assert_that(underground_player).is_not_null()
	assert_that(return_marker).is_not_null()
	if underground_player != null and return_marker != null:
		assert_vector(underground_player.global_position).is_equal(
			return_marker.global_position
		)
	var deep: Dictionary = underground.call(
		"get_underground_deep_cistern_diagnostics"
	)
	assert_str(String(deep.get("encounter_state", ""))).is_equal("cleared")
	assert_bool(bool(deep.get("enemy_visible", true))).is_false()


func _story133_cleared_state() -> Dictionary:
	return {
		"underground_corrosion_channel_activated": true,
		"underground_corrosion_left_defeated": true,
		"underground_corrosion_right_defeated": true,
		"underground_corrosion_channel_cleared": true,
		"underground_corrosion_salvage_claimed": true,
		"underground_recovery_cistern_relay_activated": true,
		"underground_recovery_cistern_traversed": true,
		"underground_deep_cistern_ambush_activated": true,
		"underground_deep_cistern_stalker_defeated": true,
		"unlocked_abilities": ["dash", "double_jump", "aerial_attack"],
	}


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


func _read_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}


func _stop_runtime_audio_players() -> void:
	for player: AudioStreamPlayer in get_tree().get_nodes_in_group("audio_music_player"):
		player.stop()
	for player: AudioStreamPlayer in get_tree().get_nodes_in_group("audio_ambient_player"):
		player.stop()
