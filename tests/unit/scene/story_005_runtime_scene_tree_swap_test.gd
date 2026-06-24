## Scene Management Story 005: runtime scene-tree swap ownership.
extends GdUnitTestSuite

const SCENE_MANAGER_PATH: String = "res://src/feature/scene_manager.gd"
const TEST_SCENE_PATH: String = "res://tests/fixtures/scene_manager/stateful_runtime_scene.tscn"
const TEST_SCENE: PackedScene = preload(TEST_SCENE_PATH)
const THREAD_LOAD_IN_PROGRESS: int = 1
const THREAD_LOAD_LOADED: int = 3

var scene_manager: Node
var runtime_root: Node


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
	var previous: Node = null
	if is_instance_valid(scene_manager) and scene_manager.has_method("get_previous_runtime_scene_node"):
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


func test_configure_runtime_root_enables_scene_tree_swap_diagnostics() -> void:
	scene_manager = _configured_scene_manager()
	runtime_root = Node.new()
	runtime_root.name = "RuntimeRoot"
	add_child(runtime_root)
	var hub_scene: Node = _new_stateful_scene("RuntimeHub", {"gate": "open"})
	runtime_root.add_child(hub_scene)
	if not _assert_runtime_swap_api_exists():
		return

	assert_bool(bool(scene_manager.call("configure_runtime_scene_root", runtime_root, hub_scene))).is_true()

	assert_bool(bool(scene_manager.call("is_runtime_scene_swap_enabled"))).is_true()
	assert_that(scene_manager.call("get_runtime_scene_root_node")).is_same(runtime_root)
	assert_that(scene_manager.call("get_current_runtime_scene_node")).is_same(hub_scene)
	assert_that(scene_manager.call("get_previous_runtime_scene_node")).is_null()


func test_async_loaded_packed_scene_is_instantiated_into_runtime_root_after_transition_gate() -> void:
	scene_manager = _configured_scene_manager()
	runtime_root = Node.new()
	runtime_root.name = "RuntimeRoot"
	add_child(runtime_root)
	var hub_scene: Node = _new_stateful_scene("RuntimeHub", {"hub_gate": "opened"})
	runtime_root.add_child(hub_scene)
	if not _assert_runtime_swap_api_exists():
		return
	assert_bool(bool(scene_manager.call("configure_runtime_scene_root", runtime_root, hub_scene))).is_true()
	assert_bool(bool(scene_manager.call("set_scene_state", &"main", {"crate": "broken"}))).is_true()
	var loader := FakeLoaderAdapter.new()
	loader.status_by_path[TEST_SCENE_PATH] = THREAD_LOAD_LOADED
	loader.resource_by_path[TEST_SCENE_PATH] = TEST_SCENE
	scene_manager.call("set_loader_adapter", loader)
	var events: Array[String] = []
	scene_manager.connect("on_scene_loaded", func(scene_id: StringName) -> void:
		events.append("loaded:%s" % String(scene_id))
	)
	scene_manager.connect("on_scene_changed", func(old_scene: StringName, new_scene: StringName) -> void:
		events.append("changed:%s>%s" % [String(old_scene), String(new_scene)])
	)

	assert_bool(bool(scene_manager.call("request_scene_change", &"main", &"east_gate"))).is_true()
	scene_manager.call("advance_loading", 1.5)

	assert_int(runtime_root.get_child_count()).is_equal(1)
	var current_runtime: Node = scene_manager.call("get_current_runtime_scene_node") as Node
	assert_that(current_runtime).is_not_null()
	assert_that(current_runtime).is_same(runtime_root.get_child(0))
	assert_that(scene_manager.call("get_previous_runtime_scene_node")).is_same(hub_scene)
	assert_bool(hub_scene.get_parent() == null).is_true()
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("main")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("east_gate")
	assert_dict(Dictionary(scene_manager.call("get_scene_state", &"hub"))).is_equal({"hub_gate": "opened"})
	assert_dict(Dictionary(current_runtime.get("local_state"))).is_equal({"crate": "broken"})
	assert_array(current_runtime.get("applied_states")).is_equal([{"crate": "broken"}])
	assert_array(events).is_equal(["loaded:main", "changed:hub>main"])
	assert_array(loader.get_calls).is_equal([TEST_SCENE_PATH])
	hub_scene.free()


func test_invalid_loaded_resource_fails_without_detaching_current_runtime_scene() -> void:
	scene_manager = _configured_scene_manager()
	runtime_root = Node.new()
	runtime_root.name = "RuntimeRoot"
	add_child(runtime_root)
	var main_scene: Node = _new_stateful_scene("RuntimeMain", {"transient": "must_not_overwrite"})
	runtime_root.add_child(main_scene)
	if not _assert_runtime_swap_api_exists():
		return
	assert_bool(bool(scene_manager.call("change_scene", &"main", &"east_gate"))).is_true()
	assert_bool(bool(scene_manager.call("configure_runtime_scene_root", runtime_root, main_scene))).is_true()
	assert_bool(bool(scene_manager.call("set_scene_state", &"main", {"persisted": "safe"}))).is_true()
	var loader := FakeLoaderAdapter.new()
	loader.status_by_path[TEST_SCENE_PATH] = THREAD_LOAD_LOADED
	scene_manager.call("set_loader_adapter", loader)
	var failures: Array[String] = []
	scene_manager.connect("on_scene_load_failed", func(scene_id: StringName, reason: StringName) -> void:
		failures.append("%s:%s" % [String(scene_id), String(reason)])
	)

	assert_bool(bool(scene_manager.call("request_scene_change", &"hub", &"clan_base"))).is_true()
	scene_manager.call("advance_loading", 1.5)

	assert_int(runtime_root.get_child_count()).is_equal(1)
	assert_that(runtime_root.get_child(0)).is_same(main_scene)
	assert_that(scene_manager.call("get_current_runtime_scene_node")).is_same(main_scene)
	assert_that(scene_manager.call("get_previous_runtime_scene_node")).is_null()
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("main")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("east_gate")
	assert_dict(Dictionary(scene_manager.call("get_scene_state", &"main"))).is_equal({"persisted": "safe"})
	assert_array(failures).is_equal(["hub:invalid_packed_scene"])


func test_no_runtime_root_preserves_story003_logical_async_commit() -> void:
	scene_manager = _configured_scene_manager()
	if not _assert_runtime_swap_api_exists():
		return
	var loader := FakeLoaderAdapter.new()
	loader.status_by_path[TEST_SCENE_PATH] = THREAD_LOAD_LOADED
	loader.resource_by_path[TEST_SCENE_PATH] = TEST_SCENE
	scene_manager.call("set_loader_adapter", loader)

	assert_bool(bool(scene_manager.call("request_scene_change", &"main", &"east_gate"))).is_true()
	scene_manager.call("advance_loading", 1.5)

	assert_bool(bool(scene_manager.call("is_runtime_scene_swap_enabled"))).is_false()
	assert_that(scene_manager.call("get_current_runtime_scene_node")).is_null()
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


func _new_stateful_scene(scene_name: String, state: Dictionary) -> Node:
	var node: Node = TEST_SCENE.instantiate()
	node.name = scene_name
	node.set("local_state", state.duplicate(true))
	return node


func _assert_runtime_swap_api_exists() -> bool:
	var methods: Array[String] = [
		"configure_runtime_scene_root",
		"is_runtime_scene_swap_enabled",
		"get_runtime_scene_root_node",
		"get_current_runtime_scene_node",
		"get_previous_runtime_scene_node",
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
	}
