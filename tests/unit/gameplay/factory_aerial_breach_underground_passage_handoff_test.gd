## Player Abilities Story 130: aerial breach and Underground handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const UNDERGROUND_SCENE_PATH: String = "res://scenes/areas/underground_passage.tscn"
const UNDERGROUND_SCRIPT_PATH: String = "res://src/gameplay/underground_passage_scene.gd"
const UNDERGROUND_BACKGROUND_PATH: String = (
	"res://assets/environment/underground_passage/"
	+ "env_underground_passage_entry_1280x720.png"
)
const BREACH_TEXTURE_PATH: String = (
	"res://assets/environment/underground_passage/"
	+ "prop_factory_aerial_breach_floor_384x160.png"
)
const REGISTRY_PATH: String = "res://data/scene_registry.json"
const REGISTRY_SCHEMA_PATH: String = "res://data/schemas/scene_registry.schema.json"
const FACTORY_GATE_NODE: String = "FactoryTailraceUndergroundAerialBreach"
const FACTORY_RETURN_SPAWN_NODE: String = "FactoryTailraceUndergroundReturnSpawn"
const UNDERGROUND_RETURN_ROUTE_NODE: String = "FactoryReturnRoute"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const UNDERGROUND_SCENE_ID: StringName = &"area_04_underground_passage"
const UNDERGROUND_SPAWN_POINT: StringName = &"factory_drop_entry"
const FACTORY_RETURN_SPAWN_POINT: StringName = &"tailrace_underground_return"
const AERIAL_ATTACK: StringName = &"aerial_attack"
const STORY126_CLEAR_KEY: String = "factory_tailrace_exit_sluice_leech_skirmish_cleared"
const BREACH_OPEN_KEY: String = "factory_tailrace_underground_aerial_breach_opened"

var _spawned_nodes: Array[Node] = []


class FakeUndergroundSceneManager:
	extends RefCounted

	var request_calls: Array[Dictionary] = []
	var scene_states: Dictionary = {}
	var loading: bool = false
	var locked: bool = false
	var current_scene: StringName = FACTORY_SCENE_ID
	var runtime_root_configured: bool = false

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == FACTORY_SCENE_ID or scene_id == UNDERGROUND_SCENE_ID

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return UNDERGROUND_SPAWN_POINT if current_scene == UNDERGROUND_SCENE_ID else &"factory_gate_entry"

	func is_loading() -> bool:
		return loading

	func is_scene_locked() -> bool:
		return locked

	func is_runtime_scene_swap_enabled() -> bool:
		return runtime_root_configured

	func configure_runtime_scene_root(_root: Node, _current_scene_node: Node = null) -> bool:
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

	func reset_for_scene(scene_id: StringName) -> void:
		request_calls.clear()
		loading = false
		locked = false
		current_scene = scene_id


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_authored_gate_registry_and_underground_scene_contract() -> void:
	assert_bool(FileAccess.file_exists(UNDERGROUND_SCRIPT_PATH)).is_true()
	assert_bool(FileAccess.file_exists(UNDERGROUND_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(UNDERGROUND_BACKGROUND_PATH)).is_true()
	assert_bool(FileAccess.file_exists(BREACH_TEXTURE_PATH)).is_true()

	var registry: Dictionary = _read_json_dictionary(REGISTRY_PATH)
	var entries: Dictionary = Dictionary(registry.get("entries", {}))
	assert_bool(entries.has(String(UNDERGROUND_SCENE_ID))).is_true()
	var entry: Dictionary = Dictionary(entries.get(String(UNDERGROUND_SCENE_ID), {}))
	assert_str(String(entry.get("path", ""))).is_equal(UNDERGROUND_SCENE_PATH)
	assert_str(String(entry.get("type", ""))).is_equal("area")
	assert_bool(bool(entry.get("preload", true))).is_false()
	assert_str(String(entry.get("default_spawn", ""))).is_equal(
		String(UNDERGROUND_SPAWN_POINT)
	)
	var schema: Dictionary = _read_json_dictionary(REGISTRY_SCHEMA_PATH)
	assert_bool(Dictionary(schema.get("entries", {})).has(String(UNDERGROUND_SCENE_ID))).is_true()

	var background: Image = _load_png(UNDERGROUND_BACKGROUND_PATH)
	assert_that(background).is_not_null()
	if background != null:
		assert_int(background.get_width()).is_equal(1280)
		assert_int(background.get_height()).is_equal(720)
		assert_int(background.detect_alpha()).is_equal(Image.ALPHA_NONE)
	var breach_image: Image = _load_png(BREACH_TEXTURE_PATH)
	assert_that(breach_image).is_not_null()
	if breach_image != null:
		assert_int(breach_image.get_width()).is_equal(384)
		assert_int(breach_image.get_height()).is_equal(160)
		assert_int(breach_image.detect_alpha()).is_equal(Image.ALPHA_BLEND)

	var factory: Node = _instantiate_scene(FACTORY_SCENE_PATH)
	assert_that(factory).is_not_null()
	if factory == null:
		return
	var gate: Node = factory.get_node_or_null(FACTORY_GATE_NODE)
	assert_that(gate).is_not_null()
	assert_that(factory.get_node_or_null(FACTORY_RETURN_SPAWN_NODE)).is_not_null()
	assert_bool(factory.has_method("get_factory_tailrace_underground_breach_diagnostics")).is_true()
	if gate != null:
		assert_str(String(gate.call("get_gate_id"))).is_equal(
			"factory_tailrace_underground_aerial_breach"
		)
		assert_str(String(gate.call("get_required_ability"))).is_equal("aerial_attack")
		assert_str(String(gate.call("get_target_area_id"))).is_equal(
			String(UNDERGROUND_SCENE_ID)
		)

	var underground: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	assert_that(underground).is_not_null()
	if underground == null:
		return
	assert_str(String(underground.get_meta("scene_id", ""))).is_equal(
		String(UNDERGROUND_SCENE_ID)
	)
	assert_that(underground.get_node_or_null("UndergroundEntrySpawn")).is_not_null()
	assert_that(underground.get_node_or_null("Player/Camera2D")).is_not_null()
	assert_that(underground.get_node_or_null("Ground/CollisionShape2D")).is_not_null()
	assert_that(underground.get_node_or_null(UNDERGROUND_RETURN_ROUTE_NODE)).is_not_null()
	assert_that(underground.get_node_or_null("UndergroundObjectiveLabel")).is_not_null()
	assert_bool(underground.has_method("get_underground_handoff_diagnostics")).is_true()


func test_aerial_activation_opens_persists_and_roundtrips_the_route() -> void:
	var factory: Node = _instantiate_scene(FACTORY_SCENE_PATH)
	assert_that(factory).is_not_null()
	if factory == null:
		return
	assert_bool(factory.has_method("get_factory_tailrace_underground_breach_diagnostics")).is_true()
	assert_bool(factory.has_method("try_request_factory_tailrace_underground_transition")).is_true()
	if not factory.has_method("get_factory_tailrace_underground_breach_diagnostics"):
		return

	factory.call("set_local_state", {
		STORY126_CLEAR_KEY: true,
		"unlocked_abilities": [],
	})
	await get_tree().process_frame
	var locked: Dictionary = factory.call(
		"get_factory_tailrace_underground_breach_diagnostics"
	)
	assert_str(String(locked.get("gate_state", ""))).is_equal("locked")
	assert_bool(bool(locked.get("collision_blocking", false))).is_true()
	assert_str(String(locked.get("prompt_text", ""))).is_equal("Requires Aerial Attack")

	factory.call("set_local_state", {
		STORY126_CLEAR_KEY: true,
		"unlocked_abilities": [String(AERIAL_ATTACK)],
	})
	await get_tree().process_frame
	var unlockable: Dictionary = factory.call(
		"get_factory_tailrace_underground_breach_diagnostics"
	)
	assert_str(String(unlockable.get("gate_state", ""))).is_equal("unlockable")
	assert_bool(bool(unlockable.get("collision_blocking", false))).is_true()
	assert_str(String(unlockable.get("prompt_text", ""))).is_equal(
		"Aerial Attack to Breach"
	)

	var manager := FakeUndergroundSceneManager.new()
	assert_bool(bool(factory.call("configure_scene_manager_runtime", manager))).is_true()
	var player: Node2D = factory.get_node_or_null("Player") as Node2D
	var gate: Node2D = factory.get_node_or_null(FACTORY_GATE_NODE) as Node2D
	assert_that(player).is_not_null()
	assert_that(gate).is_not_null()
	if player == null or gate == null:
		return
	player.global_position = gate.global_position + Vector2(0.0, -48.0)
	player.call("set_airborne", true)
	assert_bool(bool(player.call("request_aerial_attack"))).is_true()
	await get_tree().process_frame

	var opened: Dictionary = factory.call(
		"get_factory_tailrace_underground_breach_diagnostics"
	)
	assert_str(String(opened.get("gate_state", ""))).is_equal("unlocked")
	assert_bool(bool(opened.get("opened", false))).is_true()
	assert_bool(bool(opened.get("collision_blocking", true))).is_false()
	assert_int(int(opened.get("unlock_vfx_spawn_count", 0))).is_equal(1)
	assert_int(manager.request_calls.size()).is_equal(1)
	assert_str(String(manager.request_calls[0].get("scene_id", ""))).is_equal(
		String(UNDERGROUND_SCENE_ID)
	)
	assert_str(String(manager.request_calls[0].get("spawn_point", ""))).is_equal(
		String(UNDERGROUND_SPAWN_POINT)
	)
	assert_array(Array(manager.get_scene_state(
		UNDERGROUND_SCENE_ID
	).get("unlocked_abilities", []))).contains([String(AERIAL_ATTACK)])
	var saved_factory: Dictionary = factory.call("get_local_state")
	assert_bool(bool(saved_factory.get(BREACH_OPEN_KEY, false))).is_true()
	assert_array(Array(saved_factory.get("unlocked_abilities", []))).contains(
		[String(AERIAL_ATTACK)]
	)
	factory.call("set_local_state", saved_factory)
	await get_tree().process_frame
	var cached_restore: Dictionary = factory.call(
		"get_factory_tailrace_underground_breach_diagnostics"
	)
	assert_int(int(cached_restore.get("unlock_vfx_spawn_count", 0))).is_equal(1)
	assert_int(int(cached_restore.get("unlock_vfx_active_count", -1))).is_equal(0)
	assert_bool(bool(cached_restore.get("transition_requested", true))).is_false()

	var restored_factory: Node = _instantiate_scene(FACTORY_SCENE_PATH)
	restored_factory.call("set_local_state", saved_factory)
	await get_tree().process_frame
	var restored: Dictionary = restored_factory.call(
		"get_factory_tailrace_underground_breach_diagnostics"
	)
	assert_bool(bool(restored.get("opened", false))).is_true()
	assert_str(String(restored.get("gate_state", ""))).is_equal("unlocked")
	assert_int(int(restored.get("unlock_vfx_spawn_count", -1))).is_equal(0)
	assert_bool(bool(restored.get("transition_requested", true))).is_false()

	var underground: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	assert_that(underground).is_not_null()
	if underground == null:
		return
	manager.reset_for_scene(UNDERGROUND_SCENE_ID)
	assert_bool(bool(underground.call("configure_scene_manager_runtime", manager))).is_true()
	underground.call("set_local_state", {
		"underground_passage_discovered": true,
		"unlocked_abilities": [String(AERIAL_ATTACK)],
	})
	var underground_player: Node2D = underground.get_node_or_null("Player") as Node2D
	var return_route: Node2D = (
		underground.get_node_or_null(UNDERGROUND_RETURN_ROUTE_NODE) as Node2D
	)
	if underground_player == null or return_route == null:
		return
	underground_player.global_position = return_route.global_position
	assert_bool(bool(underground.call("try_request_factory_return", underground_player))).is_true()
	assert_bool(bool(underground.call("try_request_factory_return", underground_player))).is_false()
	assert_int(manager.request_calls.size()).is_equal(1)
	assert_str(String(manager.request_calls[0].get("scene_id", ""))).is_equal(
		String(FACTORY_SCENE_ID)
	)
	assert_str(String(manager.request_calls[0].get("spawn_point", ""))).is_equal(
		String(FACTORY_RETURN_SPAWN_POINT)
	)


func _instantiate_scene(path: String) -> Node:
	if not FileAccess.file_exists(path):
		return null
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		return null
	var instance: Node = packed.instantiate()
	add_child(instance)
	_spawned_nodes.append(instance)
	return instance


func _read_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _load_png(path: String) -> Image:
	if not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	if image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) != OK:
		return null
	return image


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
