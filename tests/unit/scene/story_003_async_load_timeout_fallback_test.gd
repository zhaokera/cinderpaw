## Scene Management Story 003: async load request lifecycle and timeout fallback.
extends GdUnitTestSuite

const SCENE_MANAGER_PATH: String = "res://src/feature/scene_manager.gd"
const THREAD_LOAD_IN_PROGRESS: int = 1
const THREAD_LOAD_FAILED: int = 2
const THREAD_LOAD_LOADED: int = 3

var scene_manager: Node


class FakeLoaderAdapter:
	extends RefCounted

	var request_calls: Array[Dictionary] = []
	var get_calls: Array[String] = []
	var status_by_path: Dictionary = {}
	var requested_paths: Array[String] = []

	func load_threaded_request(path: String, type_hint: String = "", use_sub_threads: bool = false, cache_mode: int = 1) -> int:
		request_calls.append({
			"path": path,
			"type_hint": type_hint,
			"use_sub_threads": use_sub_threads,
			"cache_mode": cache_mode,
		})
		requested_paths.append(path)
		return OK

	func load_threaded_get_status(path: String, _progress: Array = []) -> int:
		return int(status_by_path.get(path, THREAD_LOAD_IN_PROGRESS))

	func load_threaded_get(path: String) -> Resource:
		get_calls.append(path)
		return null


func after_test() -> void:
	if is_instance_valid(scene_manager):
		if scene_manager.get_parent() != null:
			scene_manager.get_parent().remove_child(scene_manager)
		scene_manager.free()
	scene_manager = null


func test_request_scene_change_starts_threaded_request_without_committing_current_scene() -> void:
	scene_manager = _configured_scene_manager()
	if not _assert_async_api_exists():
		return
	var loader := FakeLoaderAdapter.new()
	scene_manager.call("set_loader_adapter", loader)
	assert_bool(scene_manager.has_signal("on_scene_load_started")).is_true()
	if not scene_manager.has_signal("on_scene_load_started"):
		return
	var started_events: Array[Dictionary] = []
	scene_manager.connect(
		"on_scene_load_started",
		func(scene_id: StringName, spawn_point: StringName, metadata: Dictionary) -> void:
			started_events.append({
				"scene_id": String(scene_id),
				"spawn_point": String(spawn_point),
				"metadata": metadata.duplicate(true),
			})
	)

	assert_bool(bool(scene_manager.call("request_scene_change", &"main", &"east_gate"))).is_true()

	assert_bool(bool(scene_manager.call("is_loading"))).is_true()
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("hub")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("clan_base")
	assert_str(String(scene_manager.call("get_pending_scene"))).is_equal("main")
	assert_str(String(scene_manager.call("get_pending_spawn_point"))).is_equal("east_gate")
	assert_int(loader.request_calls.size()).is_equal(1)
	if not loader.request_calls.is_empty():
		assert_str(String(loader.request_calls[0]["path"])).is_equal("res://scenes/main.tscn")
		assert_str(String(loader.request_calls[0]["type_hint"])).is_equal("PackedScene")
	assert_int(started_events.size()).is_equal(1)
	if not started_events.is_empty():
		assert_str(String(started_events[0]["scene_id"])).is_equal("main")
		assert_str(String(started_events[0]["spawn_point"])).is_equal("east_gate")
		var metadata: Dictionary = Dictionary(started_events[0]["metadata"])
		assert_str(String(metadata.get("path", ""))).is_equal("res://scenes/main.tscn")
		assert_float(float(metadata.get("transition_duration_sec", 0.0))).is_equal_approx(1.5, 0.001)


func test_loaded_scene_waits_for_transition_gate_before_logical_commit() -> void:
	scene_manager = _configured_scene_manager()
	if not _assert_async_api_exists():
		return
	var loader := FakeLoaderAdapter.new()
	loader.status_by_path["res://scenes/main.tscn"] = THREAD_LOAD_LOADED
	scene_manager.call("set_loader_adapter", loader)
	var events: Array[String] = []
	scene_manager.connect("on_scene_loaded", func(scene_id: StringName) -> void:
		events.append("loaded:%s" % String(scene_id))
	)
	scene_manager.connect("on_scene_changed", func(old_scene: StringName, new_scene: StringName) -> void:
		events.append("changed:%s>%s" % [String(old_scene), String(new_scene)])
	)

	assert_bool(bool(scene_manager.call("request_scene_change", &"main", &"east_gate"))).is_true()
	scene_manager.call("advance_loading", 1.0)

	assert_bool(bool(scene_manager.call("is_loading"))).is_true()
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("hub")
	assert_array(events).is_empty()

	scene_manager.call("advance_loading", 0.5)

	assert_bool(bool(scene_manager.call("is_loading"))).is_false()
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("main")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("east_gate")
	assert_array(events).is_equal(["loaded:main", "changed:hub>main"])
	assert_array(loader.get_calls).is_equal(["res://scenes/main.tscn"])


func test_timeout_retries_once_then_records_failure_and_falls_back_to_hub() -> void:
	scene_manager = _configured_scene_manager()
	if not _assert_async_api_exists():
		return
	var loader := FakeLoaderAdapter.new()
	loader.status_by_path["res://scenes/main.tscn"] = THREAD_LOAD_IN_PROGRESS
	scene_manager.call("set_loader_adapter", loader)
	var failures: Array[String] = []
	scene_manager.connect("on_scene_load_failed", func(scene_id: StringName, reason: StringName) -> void:
		failures.append("%s:%s" % [String(scene_id), String(reason)])
	)

	assert_bool(bool(scene_manager.call("request_scene_change", &"main", &"east_gate"))).is_true()
	scene_manager.call("advance_loading", 10.0)

	assert_bool(bool(scene_manager.call("is_loading"))).is_true()
	assert_int(int(scene_manager.call("get_load_retry_count"))).is_equal(1)
	assert_int(loader.request_calls.size()).is_equal(2)
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("hub")

	scene_manager.call("advance_loading", 10.0)

	assert_bool(bool(scene_manager.call("is_loading"))).is_false()
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("hub")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("clan_base")
	assert_str(String(scene_manager.call("get_last_load_error"))).is_equal("timeout")
	assert_array(failures).is_equal(["main:timeout"])


func test_locked_unknown_or_active_loading_requests_are_rejected_without_loader_calls() -> void:
	scene_manager = _configured_scene_manager()
	if not _assert_async_api_exists():
		return
	var loader := FakeLoaderAdapter.new()
	scene_manager.call("set_loader_adapter", loader)

	scene_manager.call("lock_scene")
	assert_bool(bool(scene_manager.call("request_scene_change", &"main", &"locked_spawn"))).is_false()
	scene_manager.call("unlock_scene")
	assert_bool(bool(scene_manager.call("request_scene_change", &"missing", &"default"))).is_false()

	assert_int(loader.request_calls.size()).is_equal(0)
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("hub")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("clan_base")

	loader.status_by_path["res://scenes/main.tscn"] = THREAD_LOAD_IN_PROGRESS
	assert_bool(bool(scene_manager.call("request_scene_change", &"main", &"east_gate"))).is_true()
	assert_bool(bool(scene_manager.call("request_scene_change", &"hub", &"clan_base"))).is_false()

	assert_int(loader.request_calls.size()).is_equal(1)
	assert_str(String(scene_manager.call("get_pending_scene"))).is_equal("main")


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


func _assert_async_api_exists() -> bool:
	var methods: Array[String] = [
		"set_loader_adapter",
		"request_scene_change",
		"advance_loading",
		"get_pending_scene",
		"get_pending_spawn_point",
		"get_load_retry_count",
		"get_last_load_error",
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
			"path": "res://scenes/main.tscn",
			"type": "hub",
			"preload": true,
			"default_spawn": "clan_base",
		},
		"main": {
			"scene_id": "main",
			"path": "res://scenes/main.tscn",
			"type": "area",
			"preload": false,
			"default_spawn": "default",
		},
	}
