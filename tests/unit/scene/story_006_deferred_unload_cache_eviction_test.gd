## Scene Management Story 006: deferred unload and runtime cache eviction.
extends GdUnitTestSuite

const SCENE_MANAGER_PATH: String = "res://src/feature/scene_manager.gd"
const TEST_SCENE_PATH: String = "res://tests/fixtures/scene_manager/stateful_runtime_scene.tscn"
const TEST_SCENE: PackedScene = preload(TEST_SCENE_PATH)
const THREAD_LOAD_IN_PROGRESS: int = 1
const THREAD_LOAD_LOADED: int = 3

var scene_manager: Node
var runtime_root: Node
var detached_nodes: Array[Node] = []


class FakeLoaderAdapter:
	extends RefCounted

	var request_calls: Array[Dictionary] = []
	var get_calls: Array[String] = []
	var status_by_path: Dictionary = {}
	var resource_by_path: Dictionary = {}

	func load_threaded_request(path: String, type_hint: String = "", use_sub_threads: bool = false, cache_mode: int = 1) -> int:
		request_calls.append({
			"path": path,
			"type_hint": type_hint,
			"use_sub_threads": use_sub_threads,
			"cache_mode": cache_mode,
		})
		return OK

	func load_threaded_get_status(path: String, _progress: Array = []) -> int:
		return int(status_by_path.get(path, THREAD_LOAD_IN_PROGRESS))

	func load_threaded_get(path: String) -> Resource:
		get_calls.append(path)
		var resource: Variant = resource_by_path.get(path)
		if resource is Resource:
			return resource as Resource
		return null


func after_test() -> void:
	for node: Node in detached_nodes:
		if is_instance_valid(node) and node.get_parent() == null:
			node.free()
	detached_nodes.clear()
	if is_instance_valid(scene_manager):
		var previous: Node = null
		if scene_manager.has_method("get_previous_runtime_scene_node"):
			previous = scene_manager.call("get_previous_runtime_scene_node") as Node
		if previous != null and is_instance_valid(previous) and previous.get_parent() == null:
			previous.free()
	if is_instance_valid(runtime_root):
		if runtime_root.get_parent() != null:
			runtime_root.get_parent().remove_child(runtime_root)
		runtime_root.free()
	runtime_root = null
	if is_instance_valid(scene_manager):
		if scene_manager.get_parent() != null:
			scene_manager.get_parent().remove_child(scene_manager)
		scene_manager.free()
	scene_manager = null


func test_successful_swap_keeps_outgoing_scene_for_three_seconds_then_queues_free() -> void:
	scene_manager = _configured_scene_manager()
	runtime_root = _configured_runtime_root_with_hub({"hub_gate": "open"})
	if not _assert_deferred_cache_api_exists():
		return
	var loader := _ready_loader()
	scene_manager.call("set_loader_adapter", loader)

	assert_bool(bool(scene_manager.call("request_scene_change", &"main", &"east_gate"))).is_true()
	scene_manager.call("advance_loading", 1.5)

	var hub_scene: Node = detached_nodes[0]
	assert_that(scene_manager.call("get_previous_runtime_scene_node")).is_same(hub_scene)
	assert_str(String(scene_manager.call("get_previous_runtime_scene_id"))).is_equal("hub")
	assert_bool(hub_scene.get_parent() == null).is_true()
	assert_bool(hub_scene.is_queued_for_deletion()).is_false()
	assert_int(int(scene_manager.call("get_resident_runtime_scene_count"))).is_equal(2)
	assert_float(float(scene_manager.call("get_deferred_unload_remaining_seconds"))).is_equal_approx(3.0, 0.001)

	scene_manager.call("advance_deferred_unload", 2.99)

	assert_that(scene_manager.call("get_previous_runtime_scene_node")).is_same(hub_scene)
	assert_bool(hub_scene.is_queued_for_deletion()).is_false()
	assert_float(float(scene_manager.call("get_deferred_unload_remaining_seconds"))).is_equal_approx(0.01, 0.011)

	scene_manager.call("advance_deferred_unload", 0.02)

	assert_that(scene_manager.call("get_previous_runtime_scene_node")).is_null()
	assert_str(String(scene_manager.call("get_previous_runtime_scene_id"))).is_equal("")
	assert_int(int(scene_manager.call("get_resident_runtime_scene_count"))).is_equal(1)
	assert_float(float(scene_manager.call("get_deferred_unload_remaining_seconds"))).is_equal_approx(0.0, 0.001)
	assert_bool(hub_scene.is_queued_for_deletion()).is_true()


func test_quick_return_to_cached_scene_reuses_node_without_new_loader_request() -> void:
	scene_manager = _configured_scene_manager()
	runtime_root = _configured_runtime_root_with_hub({"hub_gate": "open"})
	if not _assert_deferred_cache_api_exists():
		return
	var loader := _ready_loader()
	scene_manager.call("set_loader_adapter", loader)

	assert_bool(bool(scene_manager.call("request_scene_change", &"main", &"east_gate"))).is_true()
	scene_manager.call("advance_loading", 1.5)
	var cached_hub: Node = detached_nodes[0]
	var current_main: Node = scene_manager.call("get_current_runtime_scene_node") as Node

	assert_bool(bool(scene_manager.call("request_scene_change", &"hub", &"clan_base"))).is_true()
	scene_manager.call("advance_loading", 1.5)

	assert_int(loader.request_calls.size()).is_equal(1)
	assert_array(loader.get_calls).is_equal([TEST_SCENE_PATH])
	assert_that(scene_manager.call("get_current_runtime_scene_node")).is_same(cached_hub)
	assert_that(runtime_root.get_child(0)).is_same(cached_hub)
	assert_that(scene_manager.call("get_previous_runtime_scene_node")).is_same(current_main)
	assert_str(String(scene_manager.call("get_previous_runtime_scene_id"))).is_equal("main")
	assert_bool(current_main.get_parent() == null).is_true()
	assert_int(int(scene_manager.call("get_resident_runtime_scene_count"))).is_equal(2)
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("hub")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("clan_base")
	await _release_deferred_cache_now()


func test_third_scene_swap_evicts_older_cache_and_keeps_only_two_resident_scenes() -> void:
	scene_manager = _configured_scene_manager()
	runtime_root = _configured_runtime_root_with_hub({"hub_gate": "open"})
	if not _assert_deferred_cache_api_exists():
		return
	var loader := _ready_loader()
	scene_manager.call("set_loader_adapter", loader)

	assert_bool(bool(scene_manager.call("request_scene_change", &"main", &"east_gate"))).is_true()
	scene_manager.call("advance_loading", 1.5)
	var cached_hub: Node = detached_nodes[0]
	var current_main: Node = scene_manager.call("get_current_runtime_scene_node") as Node

	assert_bool(bool(scene_manager.call("request_scene_change", &"arena", &"boss_door"))).is_true()
	scene_manager.call("advance_loading", 1.5)

	assert_that(scene_manager.call("get_current_runtime_scene_node")).is_same(runtime_root.get_child(0))
	assert_that(scene_manager.call("get_previous_runtime_scene_node")).is_same(current_main)
	assert_str(String(scene_manager.call("get_previous_runtime_scene_id"))).is_equal("main")
	assert_bool(current_main.get_parent() == null).is_true()
	assert_bool(cached_hub.is_queued_for_deletion()).is_true()
	assert_int(int(scene_manager.call("get_resident_runtime_scene_count"))).is_equal(2)
	assert_int(runtime_root.get_child_count()).is_equal(1)
	await _release_deferred_cache_now()


func test_no_runtime_root_keeps_deferred_cache_diagnostics_empty() -> void:
	scene_manager = _configured_scene_manager()
	if not _assert_deferred_cache_api_exists():
		return
	var loader := _ready_loader()
	scene_manager.call("set_loader_adapter", loader)

	assert_bool(bool(scene_manager.call("request_scene_change", &"main", &"east_gate"))).is_true()
	scene_manager.call("advance_loading", 1.5)
	scene_manager.call("advance_deferred_unload", 3.0)

	assert_that(scene_manager.call("get_previous_runtime_scene_node")).is_null()
	assert_str(String(scene_manager.call("get_previous_runtime_scene_id"))).is_equal("")
	assert_float(float(scene_manager.call("get_deferred_unload_remaining_seconds"))).is_equal_approx(0.0, 0.001)
	assert_int(int(scene_manager.call("get_resident_runtime_scene_count"))).is_equal(0)
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("main")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("east_gate")


func _configured_scene_manager() -> Node:
	var scene_script: Script = load(SCENE_MANAGER_PATH)
	assert_that(scene_script).is_not_null()
	assert_bool(scene_script != null and scene_script.can_instantiate()).is_true()
	if scene_script == null or not scene_script.can_instantiate():
		return Node.new()
	var manager: Node = scene_script.new()
	add_child(manager)
	assert_bool(bool(manager.call("configure_scene_registry", _test_registry()))).is_true()
	return manager


func _configured_runtime_root_with_hub(state: Dictionary) -> Node:
	var root := Node.new()
	root.name = "RuntimeRoot"
	add_child(root)
	var hub_scene: Node = _new_stateful_scene("RuntimeHub", state)
	root.add_child(hub_scene)
	detached_nodes.append(hub_scene)
	assert_bool(bool(scene_manager.call("configure_runtime_scene_root", root, hub_scene))).is_true()
	return root


func _new_stateful_scene(scene_name: String, state: Dictionary) -> Node:
	var node: Node = TEST_SCENE.instantiate()
	node.name = scene_name
	node.set("local_state", state.duplicate(true))
	return node


func _ready_loader() -> FakeLoaderAdapter:
	var loader := FakeLoaderAdapter.new()
	loader.status_by_path[TEST_SCENE_PATH] = THREAD_LOAD_LOADED
	loader.resource_by_path[TEST_SCENE_PATH] = TEST_SCENE
	return loader


func _release_deferred_cache_now() -> void:
	if scene_manager != null and scene_manager.has_method("advance_deferred_unload"):
		scene_manager.call("advance_deferred_unload", 3.0)
	await get_tree().process_frame


func _assert_deferred_cache_api_exists() -> bool:
	var methods: Array[String] = [
		"get_previous_runtime_scene_id",
		"get_deferred_unload_remaining_seconds",
		"get_resident_runtime_scene_count",
		"advance_deferred_unload",
	]
	var missing: Array[String] = []
	for method_name: String in methods:
		if not scene_manager.has_method(method_name):
			missing.append(method_name)
	assert_array(missing).is_empty()
	return missing.is_empty()


func _test_registry() -> Dictionary:
	return {
		"hub": {
			"scene_id": "hub",
			"path": TEST_SCENE_PATH,
			"type": "hub",
			"preload": true,
			"default_spawn": "clan_base",
		},
		"main": {
			"scene_id": "main",
			"path": TEST_SCENE_PATH,
			"type": "area",
			"preload": false,
			"default_spawn": "default",
		},
		"arena": {
			"scene_id": "arena",
			"path": TEST_SCENE_PATH,
			"type": "boss_arena",
			"preload": false,
			"default_spawn": "boss_door",
		},
	}
