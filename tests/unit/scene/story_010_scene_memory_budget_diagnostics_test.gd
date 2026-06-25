## Scene Management Story 010: scene memory budget diagnostics.
extends GdUnitTestSuite

const SCENE_MANAGER_PATH: String = "res://src/feature/scene_manager.gd"
const TEST_SCENE_PATH: String = "res://tests/fixtures/scene_manager/stateful_runtime_scene.tscn"
const TEST_SCENE: PackedScene = preload(TEST_SCENE_PATH)
const THREAD_LOAD_IN_PROGRESS: int = 1
const THREAD_LOAD_LOADED: int = 3

var scene_manager: Node
var runtime_root: Node
var detached_nodes: Array[Node] = []
var memory_budget_events: Array[Dictionary] = []


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
	memory_budget_events.clear()
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


func test_memory_budget_diagnostics_reports_platform_budget_and_resident_estimates() -> void:
	scene_manager = _configured_scene_manager()
	runtime_root = _configured_runtime_root_with_hub({"hub_gate": "open"}, 900_000_000)
	if not _assert_memory_budget_api_exists():
		return
	var loader := _ready_loader()
	scene_manager.call("set_loader_adapter", loader)

	assert_bool(bool(scene_manager.call("request_scene_change", &"main", &"east_gate"))).is_true()
	scene_manager.call("advance_loading", 1.5)
	_set_estimated_memory_bytes(
		scene_manager.call("get_current_runtime_scene_node") as Node,
		800_000_000
	)

	var diagnostics: Dictionary = scene_manager.call("get_memory_budget_diagnostics", &"mobile") as Dictionary

	assert_str(String(diagnostics.get("platform", ""))).is_equal("mobile")
	assert_int(int(diagnostics.get("platform_budget_bytes", 0))).is_equal(1_000_000_000)
	assert_int(int(diagnostics.get("resident_runtime_scene_count", 0))).is_equal(2)
	assert_int(int(diagnostics.get("max_resident_runtime_scenes", 0))).is_equal(2)
	assert_array(Array(diagnostics.get("resident_runtime_scene_ids", []))).is_equal(["main", "hub"])
	assert_int(int(diagnostics.get("estimated_runtime_memory_bytes", 0))).is_equal(1_700_000_000)
	assert_int(int(diagnostics.get("over_budget_bytes", 0))).is_equal(700_000_000)
	assert_bool(bool(diagnostics.get("within_resident_count_budget", true))).is_true()
	assert_bool(bool(diagnostics.get("within_memory_budget", true))).is_false()
	assert_bool(bool(diagnostics.get("within_budget", true))).is_false()
	await _release_deferred_cache_now()


func test_enforce_memory_budget_evicts_previous_cache_without_removing_current_scene() -> void:
	scene_manager = _configured_scene_manager()
	runtime_root = _configured_runtime_root_with_hub({"hub_gate": "open"}, 900_000_000)
	if not _assert_memory_budget_api_exists():
		return
	var loader := _ready_loader()
	scene_manager.call("set_loader_adapter", loader)

	assert_bool(bool(scene_manager.call("request_scene_change", &"main", &"east_gate"))).is_true()
	scene_manager.call("advance_loading", 1.5)
	var current_scene: Node = scene_manager.call("get_current_runtime_scene_node") as Node
	_set_estimated_memory_bytes(current_scene, 800_000_000)
	var cached_scene: Node = scene_manager.call("get_previous_runtime_scene_node") as Node

	assert_bool(bool(scene_manager.call("enforce_runtime_memory_budget", &"mobile"))).is_true()

	assert_that(scene_manager.call("get_current_runtime_scene_node")).is_same(current_scene)
	assert_that(runtime_root.get_child(0)).is_same(current_scene)
	assert_that(scene_manager.call("get_previous_runtime_scene_node")).is_null()
	assert_bool(cached_scene.is_queued_for_deletion()).is_true()
	assert_int(int(scene_manager.call("get_resident_runtime_scene_count"))).is_equal(1)
	var diagnostics: Dictionary = scene_manager.call("get_memory_budget_diagnostics", &"mobile") as Dictionary
	assert_int(int(diagnostics.get("estimated_runtime_memory_bytes", 0))).is_equal(800_000_000)
	assert_bool(bool(diagnostics.get("within_budget", false))).is_true()
	await get_tree().process_frame


func test_unknown_platform_defaults_to_pc_budget_and_missing_estimators_count_zero() -> void:
	scene_manager = _configured_scene_manager()
	runtime_root = _configured_runtime_root_with_plain_hub()
	if not _assert_memory_budget_api_exists():
		return

	var diagnostics: Dictionary = scene_manager.call("get_memory_budget_diagnostics", &"steam_deck") as Dictionary

	assert_str(String(diagnostics.get("platform", ""))).is_equal("pc")
	assert_int(int(diagnostics.get("platform_budget_bytes", 0))).is_equal(2_000_000_000)
	assert_int(int(diagnostics.get("resident_runtime_scene_count", 0))).is_equal(1)
	assert_array(Array(diagnostics.get("resident_runtime_scene_ids", []))).is_equal(["hub"])
	assert_int(int(diagnostics.get("estimated_runtime_memory_bytes", -1))).is_equal(0)
	assert_bool(bool(diagnostics.get("within_budget", false))).is_true()


func test_console_and_empty_platform_budgets_are_normalized() -> void:
	scene_manager = _configured_scene_manager()
	runtime_root = _configured_runtime_root_with_hub({"hub_gate": "open"}, 0)
	if not _assert_memory_budget_api_exists():
		return

	var console_diagnostics: Dictionary = scene_manager.call(
		"get_memory_budget_diagnostics",
		&"console"
	) as Dictionary
	var empty_diagnostics: Dictionary = scene_manager.call(
		"get_memory_budget_diagnostics",
		&""
	) as Dictionary

	assert_str(String(console_diagnostics.get("platform", ""))).is_equal("console")
	assert_int(int(console_diagnostics.get("platform_budget_bytes", 0))).is_equal(4_000_000_000)
	assert_str(String(empty_diagnostics.get("platform", ""))).is_equal("pc")
	assert_int(int(empty_diagnostics.get("platform_budget_bytes", 0))).is_equal(2_000_000_000)


func test_memory_diagnostics_include_pending_reused_scene_and_update_after_deferred_unload() -> void:
	scene_manager = _configured_scene_manager()
	runtime_root = _configured_runtime_root_with_hub({"hub_gate": "open"}, 350_000_000)
	if not _assert_memory_budget_api_exists():
		return
	var loader := _ready_loader()
	scene_manager.call("set_loader_adapter", loader)

	assert_bool(bool(scene_manager.call("request_scene_change", &"main", &"east_gate"))).is_true()
	scene_manager.call("advance_loading", 1.5)
	_set_estimated_memory_bytes(
		scene_manager.call("get_current_runtime_scene_node") as Node,
		450_000_000
	)
	assert_bool(bool(scene_manager.call("request_scene_change", &"hub", &"clan_base"))).is_true()

	var pending_diagnostics: Dictionary = scene_manager.call(
		"get_memory_budget_diagnostics",
		&"mobile"
	) as Dictionary

	assert_array(Array(pending_diagnostics.get("resident_runtime_scene_ids", []))).is_equal(["main", "hub"])
	assert_int(int(pending_diagnostics.get("resident_runtime_scene_count", 0))).is_equal(2)
	assert_int(int(pending_diagnostics.get("estimated_runtime_memory_bytes", 0))).is_equal(800_000_000)

	scene_manager.call("advance_loading", 1.5)
	scene_manager.call("advance_deferred_unload", 3.0)

	var unloaded_diagnostics: Dictionary = scene_manager.call(
		"get_memory_budget_diagnostics",
		&"mobile"
	) as Dictionary
	assert_array(Array(unloaded_diagnostics.get("resident_runtime_scene_ids", []))).is_equal(["hub"])
	assert_int(int(unloaded_diagnostics.get("resident_runtime_scene_count", 0))).is_equal(1)
	assert_int(int(unloaded_diagnostics.get("estimated_runtime_memory_bytes", 0))).is_equal(350_000_000)
	await get_tree().process_frame


func test_enforce_memory_budget_returns_false_when_already_within_budget() -> void:
	scene_manager = _configured_scene_manager()
	runtime_root = _configured_runtime_root_with_hub({"hub_gate": "open"}, 250_000_000)
	if not _assert_memory_budget_api_exists():
		return

	assert_bool(bool(scene_manager.call("enforce_runtime_memory_budget", &"mobile"))).is_false()
	assert_int(int(scene_manager.call("get_resident_runtime_scene_count"))).is_equal(1)


func test_memory_budget_exceeded_signal_emits_once_until_budget_recovers() -> void:
	scene_manager = _configured_scene_manager()
	runtime_root = _configured_runtime_root_with_hub({"hub_gate": "open"}, 900_000_000)
	if not _assert_memory_budget_api_exists():
		return
	scene_manager.connect(&"on_memory_budget_exceeded", Callable(self, "_record_memory_budget_exceeded"))
	var loader := _ready_loader()
	scene_manager.call("set_loader_adapter", loader)

	assert_bool(bool(scene_manager.call("request_scene_change", &"main", &"east_gate"))).is_true()
	scene_manager.call("advance_loading", 1.5)
	var current_scene: Node = scene_manager.call("get_current_runtime_scene_node") as Node
	_set_estimated_memory_bytes(current_scene, 800_000_000)

	assert_bool(bool(scene_manager.call("check_runtime_memory_budget", &"mobile"))).is_false()
	assert_int(memory_budget_events.size()).is_equal(1)
	assert_bool(bool(scene_manager.call("check_runtime_memory_budget", &"mobile"))).is_false()
	assert_int(memory_budget_events.size()).is_equal(1)

	assert_bool(bool(scene_manager.call("enforce_runtime_memory_budget", &"mobile"))).is_true()
	assert_bool(bool(scene_manager.call("check_runtime_memory_budget", &"mobile"))).is_true()
	_set_estimated_memory_bytes(current_scene, 1_200_000_000)

	assert_bool(bool(scene_manager.call("check_runtime_memory_budget", &"mobile"))).is_false()
	assert_int(memory_budget_events.size()).is_equal(2)
	assert_str(String(memory_budget_events[1].get("platform", ""))).is_equal("mobile")
	await get_tree().process_frame


func _record_memory_budget_exceeded(diagnostics: Dictionary) -> void:
	memory_budget_events.append(diagnostics.duplicate(true))


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


func _configured_runtime_root_with_hub(state: Dictionary, memory_bytes: int) -> Node:
	var root := Node.new()
	root.name = "RuntimeRoot"
	add_child(root)
	var hub_scene: Node = _new_stateful_scene("RuntimeHub", state, memory_bytes)
	root.add_child(hub_scene)
	detached_nodes.append(hub_scene)
	assert_bool(bool(scene_manager.call("configure_runtime_scene_root", root, hub_scene))).is_true()
	return root


func _configured_runtime_root_with_plain_hub() -> Node:
	var root := Node.new()
	root.name = "RuntimeRoot"
	add_child(root)
	var hub_scene := Node2D.new()
	hub_scene.name = "RuntimeHubWithoutEstimator"
	root.add_child(hub_scene)
	detached_nodes.append(hub_scene)
	assert_bool(bool(scene_manager.call("configure_runtime_scene_root", root, hub_scene))).is_true()
	return root


func _new_stateful_scene(scene_name: String, state: Dictionary, memory_bytes: int) -> Node:
	var node: Node = TEST_SCENE.instantiate()
	node.name = scene_name
	node.set("local_state", state.duplicate(true))
	_set_estimated_memory_bytes(node, memory_bytes)
	return node


func _set_estimated_memory_bytes(node: Node, memory_bytes: int) -> void:
	assert_bool(node != null and node.has_method("get_estimated_memory_bytes")).is_true()
	if node == null or not node.has_method("get_estimated_memory_bytes"):
		return
	node.set("estimated_memory_bytes", memory_bytes)


func _ready_loader() -> FakeLoaderAdapter:
	var loader := FakeLoaderAdapter.new()
	loader.status_by_path[TEST_SCENE_PATH] = THREAD_LOAD_LOADED
	loader.resource_by_path[TEST_SCENE_PATH] = TEST_SCENE
	return loader


func _release_deferred_cache_now() -> void:
	if scene_manager != null and scene_manager.has_method("advance_deferred_unload"):
		scene_manager.call("advance_deferred_unload", 3.0)
	await get_tree().process_frame


func _assert_memory_budget_api_exists() -> bool:
	var methods: Array[String] = [
		"get_memory_budget_diagnostics",
		"check_runtime_memory_budget",
		"enforce_runtime_memory_budget",
	]
	var missing: Array[String] = []
	for method_name: String in methods:
		if not scene_manager.has_method(method_name):
			missing.append(method_name)
	if not scene_manager.has_signal("on_memory_budget_exceeded"):
		missing.append("signal:on_memory_budget_exceeded")
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
