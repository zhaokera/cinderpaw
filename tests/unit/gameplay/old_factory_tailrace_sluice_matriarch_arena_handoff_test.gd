## Player Abilities Story 127: Tailrace Sluice Matriarch arena handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const ARENA_SCENE_PATH: String = "res://scenes/bosses/sluice_matriarch_arena.tscn"
const ARENA_SCRIPT_PATH: String = "res://src/gameplay/sluice_matriarch_arena.gd"
const ARENA_BACKGROUND_PATH: String = (
	"res://assets/environment/sluice_matriarch_arena/"
	+ "env_sluice_matriarch_arena_backdrop_1280x720.png"
)
const REGISTRY_PATH: String = "res://data/scene_registry.json"
const REGISTRY_SCHEMA_PATH: String = "res://data/schemas/scene_registry.schema.json"
const FACTORY_ROUTE_NODE: String = "FactoryTailraceSluiceMatriarchRoute"
const FACTORY_RETURN_SPAWN_NODE: String = "FactoryTailraceSluiceMatriarchReturnSpawn"
const ARENA_RETURN_ROUTE_NODE: String = "FactoryReturnRoute"
const TARGET_SCENE_ID: StringName = &"boss_03_sluice_matriarch_arena"
const TARGET_SPAWN_POINT: StringName = &"boss_entry"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_RETURN_SPAWN_POINT: StringName = &"tailrace_matriarch_gate_return"
const STORY126_CLEAR_KEY: String = "factory_tailrace_exit_sluice_leech_skirmish_cleared"
const BOSS3_DEFEATED_KEY: String = "boss_03_sluice_matriarch_defeated"

var _spawned_nodes: Array[Node] = []


class FakeArenaSceneManager:
	extends RefCounted

	var request_calls: Array[Dictionary] = []
	var loading: bool = false
	var locked: bool = false
	var current_scene: StringName = FACTORY_SCENE_ID
	var runtime_root_configured: bool = false
	var known_scenes: Dictionary = {
		String(FACTORY_SCENE_ID): true,
		String(TARGET_SCENE_ID): true,
	}

	func has_scene(scene_id: StringName) -> bool:
		return bool(known_scenes.get(String(scene_id), false))

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return TARGET_SPAWN_POINT if current_scene == TARGET_SCENE_ID else &"factory_gate_entry"

	func is_loading() -> bool:
		return loading

	func is_scene_locked() -> bool:
		return locked

	func lock_scene() -> void:
		locked = true

	func unlock_scene() -> void:
		locked = false

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


func test_registry_and_authored_arena_scene_contract() -> void:
	assert_bool(FileAccess.file_exists(ARENA_SCRIPT_PATH)).is_true()
	assert_bool(FileAccess.file_exists(ARENA_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(ARENA_BACKGROUND_PATH)).is_true()
	if not FileAccess.file_exists(ARENA_SCENE_PATH) \
			or not FileAccess.file_exists(ARENA_BACKGROUND_PATH):
		return

	var registry: Dictionary = _read_json_dictionary(REGISTRY_PATH)
	var entries: Dictionary = Dictionary(registry.get("entries", {}))
	assert_bool(entries.has(String(TARGET_SCENE_ID))).is_true()
	var arena_entry: Dictionary = Dictionary(entries.get(String(TARGET_SCENE_ID), {}))
	assert_str(String(arena_entry.get("path", ""))).is_equal(ARENA_SCENE_PATH)
	assert_str(String(arena_entry.get("type", ""))).is_equal("boss_arena")
	assert_bool(bool(arena_entry.get("preload", true))).is_false()
	assert_str(String(arena_entry.get("default_spawn", ""))).is_equal(String(TARGET_SPAWN_POINT))
	assert_str(String(arena_entry.get("display_name", ""))).is_equal("Sluice Matriarch Lair")

	var schema: Dictionary = _read_json_dictionary(REGISTRY_SCHEMA_PATH)
	assert_bool(Dictionary(schema.get("entries", {})).has(String(TARGET_SCENE_ID))).is_true()

	var image: Image = _load_png(ARENA_BACKGROUND_PATH)
	assert_that(image).is_not_null()
	if image != null:
		assert_int(image.get_width()).is_equal(1280)
		assert_int(image.get_height()).is_equal(720)
		assert_int(image.detect_alpha()).is_equal(Image.ALPHA_NONE)

	var arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(arena).is_not_null()
	if arena == null:
		return
	assert_str(String(arena.get_meta("scene_id", ""))).is_equal(String(TARGET_SCENE_ID))
	assert_that(arena.get_node_or_null("BossEntrySpawn")).is_not_null()
	assert_that(arena.get_node_or_null("Player/Camera2D")).is_not_null()
	assert_that(arena.get_node_or_null("Ground/CollisionShape2D")).is_not_null()
	assert_that(arena.get_node_or_null("LeftWall/CollisionShape2D")).is_not_null()
	assert_that(arena.get_node_or_null("RightWall/CollisionShape2D")).is_not_null()
	assert_that(arena.get_node_or_null(ARENA_RETURN_ROUTE_NODE)).is_not_null()
	assert_that(arena.get_node_or_null("ArenaObjectiveLabel")).is_not_null()
	var hud: Node = arena.get_node_or_null("HUD")
	for color_rect: Node in arena.find_children("*", "ColorRect", true, false):
		assert_bool(_is_descendant_of(color_rect, hud)).is_true()
	assert_int(arena.find_children("*", "Polygon2D", true, false).size()).is_equal(0)
	assert_bool(arena.has_method("get_arena_handoff_diagnostics")).is_true()
	if not arena.has_method("get_arena_handoff_diagnostics"):
		return
	var diagnostics: Dictionary = arena.call("get_arena_handoff_diagnostics")
	assert_str(String(diagnostics.get("background_texture_path", ""))).is_equal(
		ARENA_BACKGROUND_PATH
	)
	assert_str(String(diagnostics.get("return_target_scene_id", ""))).is_equal(
		String(FACTORY_SCENE_ID)
	)
	assert_str(String(diagnostics.get("return_spawn_point", ""))).is_equal(
		String(FACTORY_RETURN_SPAWN_POINT)
	)


func test_factory_clear_requests_arena_and_arena_requests_factory_return_once() -> void:
	var factory: Node = _instantiate_scene(FACTORY_SCENE_PATH)
	assert_that(factory).is_not_null()
	if factory == null:
		return
	assert_that(factory.get_node_or_null(FACTORY_ROUTE_NODE)).is_not_null()
	assert_that(factory.get_node_or_null(FACTORY_RETURN_SPAWN_NODE)).is_not_null()
	assert_bool(factory.has_method("get_factory_tailrace_sluice_matriarch_route_diagnostics")).is_true()
	assert_bool(factory.has_method("try_request_factory_tailrace_sluice_matriarch_transition")).is_true()
	if not factory.has_method("get_factory_tailrace_sluice_matriarch_route_diagnostics") \
			or not factory.has_method("try_request_factory_tailrace_sluice_matriarch_transition"):
		return

	var locked: Dictionary = factory.call(
		"get_factory_tailrace_sluice_matriarch_route_diagnostics"
	)
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_str(String(locked.get("prompt_text", ""))).is_equal("Defeat Sluice Leech")

	factory.call("set_local_state", {STORY126_CLEAR_KEY: true})
	await get_tree().process_frame
	var available: Dictionary = factory.call(
		"get_factory_tailrace_sluice_matriarch_route_diagnostics"
	)
	assert_bool(bool(available.get("story126_cleared", false))).is_true()
	assert_bool(bool(available.get("available", false))).is_true()
	assert_str(String(available.get("prompt_text", ""))).is_equal(
		"Enter Sluice Matriarch Lair"
	)
	assert_str(String(available.get("target_scene_id", ""))).is_equal(String(TARGET_SCENE_ID))
	assert_str(String(available.get("spawn_point", ""))).is_equal(String(TARGET_SPAWN_POINT))

	var manager := FakeArenaSceneManager.new()
	assert_bool(bool(factory.call("configure_scene_manager_runtime", manager))).is_true()
	var player: Node2D = factory.get_node_or_null("Player") as Node2D
	var route: Node2D = factory.get_node_or_null(FACTORY_ROUTE_NODE) as Node2D
	assert_that(player).is_not_null()
	assert_that(route).is_not_null()
	if player == null or route == null:
		return
	player.global_position = route.global_position
	assert_bool(bool(factory.call(
		"try_request_factory_tailrace_sluice_matriarch_transition",
		player
	))).is_true()
	assert_int(manager.request_calls.size()).is_equal(1)
	assert_str(String(manager.request_calls[0].get("scene_id", ""))).is_equal(
		String(TARGET_SCENE_ID)
	)
	assert_str(String(manager.request_calls[0].get("spawn_point", ""))).is_equal(
		String(TARGET_SPAWN_POINT)
	)
	assert_bool(bool(factory.call(
		"try_request_factory_tailrace_sluice_matriarch_transition",
		player
	))).is_false()
	assert_int(manager.request_calls.size()).is_equal(1)

	var arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(arena).is_not_null()
	if arena == null:
		return
	assert_bool(arena.has_method("configure_scene_manager_runtime")).is_true()
	assert_bool(arena.has_method("try_request_factory_return")).is_true()
	if not arena.has_method("try_request_factory_return"):
		return
	manager.reset_for_scene(TARGET_SCENE_ID)
	assert_bool(bool(arena.call("configure_scene_manager_runtime", manager))).is_true()
	assert_bool(manager.locked).is_true()
	arena.call("set_local_state", {BOSS3_DEFEATED_KEY: true})
	assert_bool(manager.locked).is_false()
	var arena_player: Node2D = arena.get_node_or_null("Player") as Node2D
	var return_route: Node2D = arena.get_node_or_null(ARENA_RETURN_ROUTE_NODE) as Node2D
	assert_that(arena_player).is_not_null()
	assert_that(return_route).is_not_null()
	if arena_player == null or return_route == null:
		return
	arena_player.global_position = return_route.global_position
	assert_bool(bool(arena.call("try_request_factory_return", arena_player))).is_true()
	assert_int(manager.request_calls.size()).is_equal(1)
	assert_str(String(manager.request_calls[0].get("scene_id", ""))).is_equal(
		String(FACTORY_SCENE_ID)
	)
	assert_str(String(manager.request_calls[0].get("spawn_point", ""))).is_equal(
		String(FACTORY_RETURN_SPAWN_POINT)
	)
	assert_bool(bool(arena.call("try_request_factory_return", arena_player))).is_false()
	assert_int(manager.request_calls.size()).is_equal(1)


func _is_descendant_of(node: Node, ancestor: Node) -> bool:
	if node == null or ancestor == null:
		return false
	var current: Node = node
	while current != null:
		if current == ancestor:
			return true
		current = current.get_parent()
	return false


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
			var audio_player := child as AudioStreamPlayer
			audio_player.stop()
			audio_player.stream = null
		if child is AudioStreamPlayer2D:
			var spatial_player := child as AudioStreamPlayer2D
			spatial_player.stop()
			spatial_player.stream = null
