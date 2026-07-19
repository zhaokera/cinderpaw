## Player Abilities Story 037: post-service-lift Factory shortcut re-entry.
extends GdUnitTestSuite

const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"
const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const SCENE_MANAGER_SCRIPT: Script = preload("res://src/feature/scene_manager.gd")
const MAIN_SCENE: PackedScene = preload(MAIN_SCENE_PATH)
const FACTORY_SCENE: PackedScene = preload(FACTORY_SCENE_PATH)
const MAIN_SCENE_ID: StringName = &"main"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_SPAWN_POINT: StringName = &"factory_gate_entry"
const SCRAP_ROOST_SPAWN_POINT: StringName = &"scrap_roost"
const FACTORY_ROUTE_UNLOCKED_FLAG: StringName = &"area_03_factory_unlocked"
const FACTORY_ROUTE_TRIGGER_NAME: String = "FactoryRouteTransitionShell"
const THREAD_LOAD_LOADED: int = 3
const TRANSITION_SECONDS: float = 1.5

var _runtime_root: Node = null
var _scene_manager: Node = null


class RoundtripLoaderAdapter:
	extends RefCounted

	var request_calls: Array[Dictionary] = []
	var resources_by_path: Dictionary = {
		MAIN_SCENE_PATH: MAIN_SCENE,
		FACTORY_SCENE_PATH: FACTORY_SCENE,
	}

	func load_threaded_request(
		path: String,
		type_hint: String = "",
		use_sub_threads: bool = false,
		cache_mode: int = 1
	) -> int:
		request_calls.append({
			"path": path,
			"type_hint": type_hint,
			"use_sub_threads": use_sub_threads,
			"cache_mode": cache_mode,
		})
		return OK

	func load_threaded_get_status(_path: String, _progress: Array = []) -> int:
		return THREAD_LOAD_LOADED

	func load_threaded_get(path: String) -> Resource:
		var resource: Variant = resources_by_path.get(path)
		return resource as Resource if resource is Resource else null


func after_test() -> void:
	_stop_runtime_audio_players()
	_runtime_root = null
	_scene_manager = null


func test_returned_factory_route_reenters_through_runtime_scene_root() -> void:
	_scene_manager = _configured_scene_manager()
	_runtime_root = auto_free(Node.new()) as Node
	_runtime_root.name = "RuntimeRoot"
	add_child(_runtime_root)
	var main_scene: Node = auto_free(MAIN_SCENE.instantiate()) as Node
	_runtime_root.add_child(main_scene)
	assert_bool(bool(_scene_manager.call("change_scene", MAIN_SCENE_ID, &"default"))).is_true()
	assert_bool(bool(main_scene.call("configure_scene_manager_runtime", _scene_manager))).is_true()

	var route_shell: Node2D = main_scene.get_node_or_null(FACTORY_ROUTE_TRIGGER_NAME) as Node2D
	var player: Node2D = main_scene.get_node_or_null("Player") as Node2D
	assert_that(route_shell).is_not_null()
	assert_that(player).is_not_null()
	if route_shell == null or player == null:
		return
	assert_bool(bool(_scene_manager.call("set_scene_state", FACTORY_SCENE_ID, {
		"factory_service_lift_exit_requested": true,
		"factory_service_lift_exit_scene_id": String(MAIN_SCENE_ID),
		"factory_service_lift_exit_spawn_point": String(SCRAP_ROOST_SPAWN_POINT),
	}))).is_true()
	main_scene.call("set_world_progress_flag", FACTORY_ROUTE_UNLOCKED_FLAG, true)
	player.global_position = route_shell.global_position

	assert_bool(bool(main_scene.call("request_factory_route_transition", player))).is_true()
	assert_bool(bool(_scene_manager.call("is_runtime_scene_swap_enabled"))).is_true()
	assert_str(String(_scene_manager.call("get_pending_scene"))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(_scene_manager.call("get_pending_spawn_point"))).is_equal(String(FACTORY_SPAWN_POINT))

	_scene_manager.call("advance_loading", TRANSITION_SECONDS)
	var factory_scene: Node = _runtime_root.get_child(0)
	auto_free(factory_scene)
	assert_str(factory_scene.name).is_equal("FactoryRouteTransitionShellScene")
	assert_str(String(_scene_manager.call("get_current_scene"))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(_scene_manager.call("get_current_spawn_point"))).is_equal(String(FACTORY_SPAWN_POINT))
	assert_bool(factory_scene.has_method("configure_scene_manager_runtime")).is_true()
	assert_bool(bool(factory_scene.call("configure_scene_manager_runtime", _scene_manager))).is_true()
	var factory_player: Node2D = factory_scene.get_node_or_null("Player") as Node2D
	var factory_spawn: Node2D = factory_scene.get_node_or_null("FactoryGateEntrySpawn") as Node2D
	assert_that(factory_player).is_not_null()
	assert_that(factory_spawn).is_not_null()
	if factory_player == null or factory_spawn == null:
		return
	assert_float(
		factory_player.global_position.distance_to(factory_spawn.global_position)
	).is_less_equal(32.0)
	assert_bool(bool(_scene_manager.call("is_loading"))).is_false()


func _configured_scene_manager() -> Node:
	var manager: Node = auto_free(SCENE_MANAGER_SCRIPT.new()) as Node
	add_child(manager)
	assert_bool(bool(manager.call("configure_scene_registry", _roundtrip_registry()))).is_true()
	manager.call("set_loader_adapter", RoundtripLoaderAdapter.new())
	return manager


func _roundtrip_registry() -> Dictionary:
	return {
		"main": {
			"scene_id": "main",
			"path": MAIN_SCENE_PATH,
			"type": "area",
			"preload": true,
			"default_spawn": "default",
			"display_name": "Scrap Alley",
		},
		"area_03_factory": {
			"scene_id": "area_03_factory",
			"path": FACTORY_SCENE_PATH,
			"type": "route_shell",
			"preload": false,
			"default_spawn": "factory_gate_entry",
			"display_name": "Factory Route",
		},
	}


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
