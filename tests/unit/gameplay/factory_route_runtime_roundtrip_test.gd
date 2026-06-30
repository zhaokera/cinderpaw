## Player Abilities Story 037: main/runtime-root Factory route roundtrip.
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
const FACTORY_ENTRY_GUARD_NAME: String = "FactoryRatMinion"
const FACTORY_DEEP_GUARD_NAME: String = "FactoryDeepGuardRatMinion"
const FACTORY_DEEP_ENDPOINT_NAME: String = "FactoryDeepRouteEndpoint"
const FACTORY_SPARK_RAT_NAME: String = "FactorySparkRat"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_SPARK_RAT_ENTITY_ID: int = 2102
const THREAD_LOAD_LOADED: int = 3
const TRANSITION_SECONDS: float = 1.5
const SCRAP_ROOST_SPAWN_TOLERANCE_PX: float = 32.0

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


func test_factory_route_roundtrips_through_runtime_scene_root_to_scrap_roost() -> void:
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

	await _clear_factory_route(factory_scene)
	var factory_player: Node2D = factory_scene.get_node_or_null("Player") as Node2D
	var service_lift: Node2D = factory_scene.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(factory_player).is_not_null()
	assert_that(service_lift).is_not_null()
	if factory_player == null or service_lift == null:
		return
	factory_player.global_position = service_lift.global_position

	assert_bool(bool(factory_scene.call("try_activate_factory_service_lift", factory_player))).is_true()
	var exit_diagnostics: Dictionary = factory_scene.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(exit_diagnostics.get("exit_requested", false))).is_true()
	assert_str(String(_scene_manager.call("get_pending_scene"))).is_equal(String(MAIN_SCENE_ID))
	assert_str(String(_scene_manager.call("get_pending_spawn_point"))).is_equal(String(SCRAP_ROOST_SPAWN_POINT))

	_scene_manager.call("advance_loading", TRANSITION_SECONDS)
	var saved_factory_state: Dictionary = _scene_manager.call("get_scene_state", FACTORY_SCENE_ID)
	assert_bool(bool(saved_factory_state.get("factory_service_lift_exit_requested", false))).is_true()
	assert_str(String(saved_factory_state.get("factory_service_lift_exit_spawn_point", ""))).is_equal(
		String(SCRAP_ROOST_SPAWN_POINT)
	)
	var returned_scene: Node = _runtime_root.get_child(0)
	assert_str(returned_scene.name).is_equal("Main")
	assert_str(String(_scene_manager.call("get_current_scene"))).is_equal(String(MAIN_SCENE_ID))
	assert_str(String(_scene_manager.call("get_current_spawn_point"))).is_equal(
		String(SCRAP_ROOST_SPAWN_POINT)
	)
	var scrap_roost_savepoint: Node2D = returned_scene.get_node_or_null("ScrapRoostSavepoint") as Node2D
	var returned_player: Node2D = returned_scene.get_node_or_null("Player") as Node2D
	assert_that(scrap_roost_savepoint).is_not_null()
	assert_that(returned_player).is_not_null()
	if scrap_roost_savepoint == null or returned_player == null:
		return
	assert_float(
		returned_player.global_position.distance_to(scrap_roost_savepoint.global_position)
	).is_less_equal(SCRAP_ROOST_SPAWN_TOLERANCE_PX)
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


func _clear_factory_route(factory_scene: Node) -> void:
	var player: Node2D = factory_scene.get_node_or_null("Player") as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return
	await _defeat_guard(factory_scene, FACTORY_ENTRY_GUARD_NAME, &"unit_test_roundtrip_entry")

	var route_diagnostics: Dictionary = factory_scene.call("get_factory_deep_route_diagnostics")
	player.global_position.x = float(route_diagnostics.get("deep_guard_activation_x", 0.0)) + 8.0
	assert_bool(bool(factory_scene.call("try_activate_factory_deep_guard", player))).is_true()
	await _defeat_guard(factory_scene, FACTORY_DEEP_GUARD_NAME, &"unit_test_roundtrip_deep")

	var endpoint: Node2D = factory_scene.get_node_or_null(FACTORY_DEEP_ENDPOINT_NAME) as Node2D
	assert_that(endpoint).is_not_null()
	if endpoint == null:
		return
	player.global_position = endpoint.global_position
	assert_bool(bool(factory_scene.call("try_activate_factory_deep_route_endpoint", player))).is_true()

	var spark_rat: Node2D = factory_scene.get_node_or_null(FACTORY_SPARK_RAT_NAME) as Node2D
	assert_that(spark_rat).is_not_null()
	if spark_rat == null:
		return
	var spark_diagnostics: Dictionary = factory_scene.call("get_factory_spark_rat_diagnostics")
	player.global_position = spark_rat.global_position + Vector2(-32.0, 0.0)
	player.global_position.x = maxf(
		player.global_position.x,
		float(spark_diagnostics.get("activation_x", spark_rat.global_position.x)) + 8.0
	)
	assert_bool(bool(factory_scene.call("try_activate_factory_spark_rat", player))).is_true()
	assert_bool(factory_scene.call("apply_damage", FACTORY_SPARK_RAT_ENTITY_ID, 999, {
		"source": &"unit_test_factory_roundtrip",
	})).is_true()
	await get_tree().process_frame


func _defeat_guard(root: Node, guard_name: String, reason: StringName) -> void:
	var guard: Node = root.get_node_or_null(guard_name)
	assert_that(guard).is_not_null()
	if guard == null:
		return
	if guard.has_method("kill_summon"):
		guard.call("kill_summon", reason)
	else:
		guard.call("apply_damage", int(guard.call("get_current_hp")), {})
	await get_tree().process_frame


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
