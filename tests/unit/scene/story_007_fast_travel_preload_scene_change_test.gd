## Scene Management Story 007: fast travel preload and scene change.
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


func test_fast_travel_preload_waits_for_two_second_portal_gate_before_commit() -> void:
	scene_manager = _configured_scene_manager()
	if not _assert_fast_travel_api_exists():
		return
	var loader := _ready_loader()
	scene_manager.call("set_loader_adapter", loader)
	var started_events: Array[Dictionary] = []
	var completed_events: Array[Dictionary] = []
	var changed_events: Array[String] = []
	scene_manager.connect(
		"on_fast_travel_preload_started",
		func(scene_id: StringName, spawn_point: StringName, metadata: Dictionary) -> void:
			started_events.append({
				"scene_id": String(scene_id),
				"spawn_point": String(spawn_point),
				"metadata": metadata.duplicate(true),
			})
	)
	scene_manager.connect(
		"on_fast_travel_preload_completed",
		func(scene_id: StringName, spawn_point: StringName, metadata: Dictionary) -> void:
			completed_events.append({
				"scene_id": String(scene_id),
				"spawn_point": String(spawn_point),
				"metadata": metadata.duplicate(true),
			})
	)
	scene_manager.connect("on_scene_changed", func(old_scene: StringName, new_scene: StringName) -> void:
		changed_events.append("%s>%s" % [String(old_scene), String(new_scene)])
	)

	assert_bool(bool(scene_manager.call("request_fast_travel_scene_change", &"main", &"east_gate"))).is_true()

	assert_bool(bool(scene_manager.call("is_loading"))).is_true()
	assert_bool(bool(scene_manager.call("is_fast_travel_loading"))).is_true()
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("hub")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("clan_base")
	assert_int(loader.request_calls.size()).is_equal(1)
	if not loader.request_calls.is_empty():
		assert_str(String(loader.request_calls[0]["path"])).is_equal(TEST_SCENE_PATH)
	assert_int(started_events.size()).is_equal(1)
	if not started_events.is_empty():
		var metadata: Dictionary = Dictionary(started_events[0]["metadata"])
		assert_bool(bool(metadata.get("fast_travel", false))).is_true()
		assert_str(String(metadata.get("transition_type", ""))).is_equal("fast_travel")
		assert_str(String(metadata.get("path", ""))).is_equal(TEST_SCENE_PATH)
		assert_float(float(metadata.get("portal_duration_sec", 0.0))).is_equal_approx(2.0, 0.001)
		assert_float(float(metadata.get("transition_duration_sec", 0.0))).is_equal_approx(2.0, 0.001)

	scene_manager.call("advance_loading", 1.99)

	assert_bool(bool(scene_manager.call("is_loading"))).is_true()
	assert_bool(bool(scene_manager.call("is_fast_travel_loading"))).is_true()
	assert_float(float(scene_manager.call("get_fast_travel_portal_remaining_seconds"))).is_equal_approx(0.01, 0.011)
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("hub")
	assert_array(loader.get_calls).is_empty()
	assert_array(completed_events).is_empty()
	assert_array(changed_events).is_empty()

	scene_manager.call("advance_loading", 0.02)

	assert_bool(bool(scene_manager.call("is_loading"))).is_false()
	assert_bool(bool(scene_manager.call("is_fast_travel_loading"))).is_false()
	assert_float(float(scene_manager.call("get_fast_travel_portal_remaining_seconds"))).is_equal_approx(0.0, 0.001)
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("main")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("east_gate")
	assert_array(loader.get_calls).is_equal([TEST_SCENE_PATH])
	assert_int(completed_events.size()).is_equal(1)
	if not completed_events.is_empty():
		assert_str(String(completed_events[0]["scene_id"])).is_equal("main")
		assert_str(String(completed_events[0]["spawn_point"])).is_equal("east_gate")
		var completed_metadata: Dictionary = Dictionary(completed_events[0]["metadata"])
		assert_bool(bool(completed_metadata.get("fast_travel", false))).is_true()
		assert_str(String(completed_metadata.get("transition_type", ""))).is_equal("fast_travel")
		assert_float(float(completed_metadata.get("portal_duration_sec", 0.0))).is_equal_approx(2.0, 0.001)
	assert_array(changed_events).is_equal(["hub>main"])


func test_fast_travel_runtime_swap_keeps_deferred_cache_contract() -> void:
	scene_manager = _configured_scene_manager()
	runtime_root = _configured_runtime_root_with_hub({"hub_gate": "open"})
	if not _assert_fast_travel_api_exists():
		return
	var loader := _ready_loader()
	scene_manager.call("set_loader_adapter", loader)

	assert_bool(bool(scene_manager.call("request_fast_travel_scene_change", &"main", &"east_gate"))).is_true()
	scene_manager.call("advance_loading", 2.0)

	var current_runtime: Node = scene_manager.call("get_current_runtime_scene_node") as Node
	var cached_hub: Node = detached_nodes[0]
	assert_that(current_runtime).is_not_null()
	assert_that(current_runtime).is_same(runtime_root.get_child(0))
	assert_that(scene_manager.call("get_previous_runtime_scene_node")).is_same(cached_hub)
	assert_str(String(scene_manager.call("get_previous_runtime_scene_id"))).is_equal("hub")
	assert_bool(cached_hub.get_parent() == null).is_true()
	assert_bool(cached_hub.is_queued_for_deletion()).is_false()
	assert_int(int(scene_manager.call("get_resident_runtime_scene_count"))).is_equal(2)
	assert_array(loader.get_calls).is_equal([TEST_SCENE_PATH])
	assert_int(loader.request_calls.size()).is_equal(1)
	await _release_deferred_cache_now()


func test_fast_travel_quick_return_reuses_deferred_cache_after_two_second_gate_without_new_loader_request() -> void:
	scene_manager = _configured_scene_manager()
	runtime_root = _configured_runtime_root_with_hub({"hub_gate": "open"})
	if not _assert_fast_travel_api_exists():
		return
	var loader := _ready_loader()
	scene_manager.call("set_loader_adapter", loader)
	var started_events: Array[Dictionary] = []
	scene_manager.connect(
		"on_fast_travel_preload_started",
		func(scene_id: StringName, spawn_point: StringName, metadata: Dictionary) -> void:
			started_events.append({
				"scene_id": String(scene_id),
				"spawn_point": String(spawn_point),
				"metadata": metadata.duplicate(true),
			})
	)

	assert_bool(bool(scene_manager.call("request_scene_change", &"main", &"east_gate"))).is_true()
	scene_manager.call("advance_loading", 1.5)
	var cached_hub: Node = detached_nodes[0]
	var current_main: Node = scene_manager.call("get_current_runtime_scene_node") as Node

	assert_bool(bool(scene_manager.call("request_fast_travel_scene_change", &"hub", &"clan_base"))).is_true()

	assert_int(loader.request_calls.size()).is_equal(1)
	assert_array(loader.get_calls).is_equal([TEST_SCENE_PATH])
	assert_int(started_events.size()).is_equal(1)
	if not started_events.is_empty():
		var metadata: Dictionary = Dictionary(started_events[0]["metadata"])
		assert_bool(bool(metadata.get("cache_hit", false))).is_true()
		assert_bool(bool(metadata.get("fast_travel", false))).is_true()

	scene_manager.call("advance_loading", 1.99)

	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("main")
	assert_that(scene_manager.call("get_current_runtime_scene_node")).is_same(current_main)
	assert_int(loader.request_calls.size()).is_equal(1)
	assert_array(loader.get_calls).is_equal([TEST_SCENE_PATH])

	scene_manager.call("advance_loading", 0.02)

	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("hub")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("clan_base")
	assert_that(scene_manager.call("get_current_runtime_scene_node")).is_same(cached_hub)
	assert_that(runtime_root.get_child(0)).is_same(cached_hub)
	assert_that(scene_manager.call("get_previous_runtime_scene_node")).is_same(current_main)
	assert_str(String(scene_manager.call("get_previous_runtime_scene_id"))).is_equal("main")
	assert_int(int(scene_manager.call("get_resident_runtime_scene_count"))).is_equal(2)
	assert_int(loader.request_calls.size()).is_equal(1)
	assert_array(loader.get_calls).is_equal([TEST_SCENE_PATH])
	await _release_deferred_cache_now()


func test_regular_scene_change_keeps_one_point_five_second_transition_gate() -> void:
	scene_manager = _configured_scene_manager()
	if not _assert_fast_travel_api_exists():
		return
	var loader := _ready_loader()
	scene_manager.call("set_loader_adapter", loader)

	assert_bool(bool(scene_manager.call("request_scene_change", &"main", &"east_gate"))).is_true()
	scene_manager.call("advance_loading", 1.49)

	assert_bool(bool(scene_manager.call("is_loading"))).is_true()
	assert_bool(bool(scene_manager.call("is_fast_travel_loading"))).is_false()
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("hub")
	assert_array(loader.get_calls).is_empty()

	scene_manager.call("advance_loading", 0.02)

	assert_bool(bool(scene_manager.call("is_loading"))).is_false()
	assert_bool(bool(scene_manager.call("is_fast_travel_loading"))).is_false()
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("main")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("east_gate")
	assert_array(loader.get_calls).is_equal([TEST_SCENE_PATH])


func test_fast_travel_rejects_locked_unknown_or_active_loading_without_extra_loader_calls() -> void:
	scene_manager = _configured_scene_manager()
	if not _assert_fast_travel_api_exists():
		return
	var loader := _ready_loader()
	scene_manager.call("set_loader_adapter", loader)

	scene_manager.call("lock_scene")
	assert_bool(bool(scene_manager.call("request_fast_travel_scene_change", &"main", &"locked_spawn"))).is_false()
	scene_manager.call("unlock_scene")
	assert_bool(bool(scene_manager.call("request_fast_travel_scene_change", &"missing", &"default"))).is_false()

	assert_int(loader.request_calls.size()).is_equal(0)
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("hub")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("clan_base")

	assert_bool(bool(scene_manager.call("request_fast_travel_scene_change", &"main", &"east_gate"))).is_true()
	assert_bool(bool(scene_manager.call("request_fast_travel_scene_change", &"arena", &"boss_door"))).is_false()
	assert_bool(bool(scene_manager.call("request_scene_change", &"arena", &"boss_door"))).is_false()

	assert_int(loader.request_calls.size()).is_equal(1)
	assert_str(String(scene_manager.call("get_pending_scene"))).is_equal("main")
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("hub")


func test_fast_travel_timeout_retries_once_then_emits_failure_and_falls_back_to_hub() -> void:
	scene_manager = _configured_scene_manager()
	if not _assert_fast_travel_api_exists():
		return
	var loader := FakeLoaderAdapter.new()
	loader.status_by_path[TEST_SCENE_PATH] = THREAD_LOAD_IN_PROGRESS
	scene_manager.call("set_loader_adapter", loader)
	var scene_failures: Array[String] = []
	var fast_failures: Array[String] = []
	scene_manager.connect("on_scene_load_failed", func(scene_id: StringName, reason: StringName) -> void:
		scene_failures.append("%s:%s" % [String(scene_id), String(reason)])
	)
	scene_manager.connect("on_fast_travel_preload_failed", func(scene_id: StringName, reason: StringName) -> void:
		fast_failures.append("%s:%s" % [String(scene_id), String(reason)])
	)

	assert_bool(bool(scene_manager.call("request_fast_travel_scene_change", &"main", &"east_gate"))).is_true()
	scene_manager.call("advance_loading", 10.0)

	assert_bool(bool(scene_manager.call("is_loading"))).is_true()
	assert_bool(bool(scene_manager.call("is_fast_travel_loading"))).is_true()
	assert_int(int(scene_manager.call("get_load_retry_count"))).is_equal(1)
	assert_int(loader.request_calls.size()).is_equal(2)
	assert_array(scene_failures).is_empty()
	assert_array(fast_failures).is_empty()

	scene_manager.call("advance_loading", 10.0)

	assert_bool(bool(scene_manager.call("is_loading"))).is_false()
	assert_bool(bool(scene_manager.call("is_fast_travel_loading"))).is_false()
	assert_str(String(scene_manager.call("get_last_load_error"))).is_equal("timeout")
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("hub")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("clan_base")
	assert_array(scene_failures).is_equal(["main:timeout"])
	assert_array(fast_failures).is_equal(["main:timeout"])


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


func _assert_fast_travel_api_exists() -> bool:
	var methods: Array[String] = [
		"request_fast_travel_scene_change",
		"is_fast_travel_loading",
		"get_fast_travel_portal_remaining_seconds",
		"set_loader_adapter",
		"advance_loading",
		"request_scene_change",
	]
	var missing_methods: Array[String] = []
	for method_name: String in methods:
		if not scene_manager.has_method(method_name):
			missing_methods.append(method_name)
	assert_array(missing_methods).is_empty()

	var signals: Array[String] = [
		"on_fast_travel_preload_started",
		"on_fast_travel_preload_completed",
		"on_fast_travel_preload_failed",
	]
	var missing_signals: Array[String] = []
	for signal_name: String in signals:
		if not scene_manager.has_signal(signal_name):
			missing_signals.append(signal_name)
	assert_array(missing_signals).is_empty()

	return missing_methods.is_empty() and missing_signals.is_empty()


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
