## Player Abilities Story 043: Old Factory return checkpoint.
extends GdUnitTestSuite

const GAME_FLOW_SCRIPT: Script = preload("res://src/gameplay/game_flow_controller.gd")
const SCENE_MANAGER_SCRIPT: Script = preload("res://src/feature/scene_manager.gd")
const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"
const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const MAIN_SCENE: PackedScene = preload(MAIN_SCENE_PATH)
const FACTORY_SCENE: PackedScene = preload(FACTORY_SCENE_PATH)
const MAIN_SCENE_ID: StringName = &"main"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const THREAD_LOAD_LOADED: int = 3
const TRANSITION_SECONDS: float = 1.5
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_RETURN_CHECKPOINT_NAME: String = "FactoryReturnCheckpoint"
const FACTORY_RETURN_CHECKPOINT_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_return_checkpoint/"
	+ "old_factory_return_checkpoint.png"
)

var _spawned_nodes: Array[Node] = []
var _respawn_events: Array[Dictionary] = []


class FakeFactorySceneManager:
	extends RefCounted

	var change_calls: Array[Dictionary] = []
	var current_scene: StringName = &"area_03_factory"
	var current_spawn_point: StringName = &"factory_gate_entry"

	func has_scene(scene_id: StringName) -> bool:
		return String(scene_id) in ["area_03_factory", "hub"]

	func change_scene(scene_id: StringName, spawn_point: StringName = &"default") -> bool:
		change_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		var known: bool = has_scene(scene_id)
		if known:
			current_scene = scene_id
			current_spawn_point = spawn_point
		return known

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn_point


class ReturnCheckpointLoaderAdapter:
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
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()
	_respawn_events.clear()


func test_return_checkpoint_stays_hidden_until_return_patrol_clear() -> void:
	assert_bool(FileAccess.file_exists(FACTORY_RETURN_CHECKPOINT_TEXTURE_PATH)).is_true()
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("get_factory_return_checkpoint_diagnostics")).is_true()
	assert_bool(destination.has_method("try_activate_factory_return_checkpoint")).is_true()
	if (
		not destination.has_method("get_factory_return_checkpoint_diagnostics")
		or not destination.has_method("try_activate_factory_return_checkpoint")
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	destination.call("set_local_state", _service_lift_return_state())
	var locked: Dictionary = destination.call("get_factory_return_checkpoint_diagnostics")
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(destination.call("try_activate_factory_return_checkpoint", player))).is_false()

	destination.call("set_local_state", _service_lift_return_state().merged({
		"factory_return_patrol_defeated": true,
	}, true))
	var available: Dictionary = destination.call("get_factory_return_checkpoint_diagnostics")
	assert_bool(bool(available.get("present", false))).is_true()
	assert_bool(bool(available.get("visible", false))).is_true()
	assert_bool(bool(available.get("available", false))).is_true()
	assert_bool(bool(available.get("activated", true))).is_false()
	assert_str(String(available.get("savepoint_id", ""))).is_equal("old_factory_return_checkpoint")
	assert_str(String(available.get("scene_id", ""))).is_equal("area_03_factory")
	assert_str(String(available.get("spawn_point", ""))).is_equal("return_checkpoint")
	assert_str(String(available.get("prompt_text", ""))).is_equal("Repair Savepoint")
	assert_str(String(available.get("texture_path", ""))).is_equal(
		FACTORY_RETURN_CHECKPOINT_TEXTURE_PATH
	)


func test_return_checkpoint_activation_records_scene_local_checkpoint() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	destination.call("set_local_state", _service_lift_return_state().merged({
		"factory_return_patrol_defeated": true,
	}, true))

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var checkpoint: Node2D = destination.get_node_or_null(FACTORY_RETURN_CHECKPOINT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(checkpoint).is_not_null()
	if player == null or checkpoint == null:
		return

	player.global_position = checkpoint.global_position
	assert_bool(bool(destination.call("try_activate_factory_return_checkpoint", player))).is_true()

	var diagnostics: Dictionary = destination.call("get_factory_return_checkpoint_diagnostics")
	var route: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	var last_checkpoint: Dictionary = Dictionary(diagnostics.get("last_checkpoint", {}))
	assert_bool(bool(diagnostics.get("activated", false))).is_true()
	assert_str(String(route.get("route_label_text", ""))).is_equal("Factory Savepoint Secured")
	assert_str(String(last_checkpoint.get("id", ""))).is_equal("old_factory_return_checkpoint")
	assert_str(String(last_checkpoint.get("scene_id", ""))).is_equal("area_03_factory")
	assert_str(String(last_checkpoint.get("spawn_point", ""))).is_equal("return_checkpoint")
	assert_str(String(last_checkpoint.get("display_name", ""))).is_equal("Factory Repair Station")
	assert_float(float(last_checkpoint.get("position", {}).get("x", 0.0))).is_equal_approx(
		checkpoint.global_position.x,
		0.001
	)

	var state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(state.get("factory_return_checkpoint_activated", false))).is_true()
	assert_str(String(Dictionary(state.get("last_return_checkpoint", {})).get("id", ""))).is_equal(
		"old_factory_return_checkpoint"
	)

	var restored: Node = _instantiate_factory_scene()
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", state)
	var restored_diagnostics: Dictionary = restored.call("get_factory_return_checkpoint_diagnostics")
	assert_bool(bool(restored_diagnostics.get("visible", false))).is_true()
	assert_bool(bool(restored_diagnostics.get("available", false))).is_true()
	assert_bool(bool(restored_diagnostics.get("activated", false))).is_true()
	assert_str(String(Dictionary(restored_diagnostics.get(
		"last_checkpoint",
		{}
	)).get("id", ""))).is_equal("old_factory_return_checkpoint")


func test_return_checkpoint_drives_non_boss_respawn_scene_selection() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	destination.call("set_local_state", _service_lift_return_state().merged({
		"factory_return_patrol_defeated": true,
	}, true))

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var checkpoint: Node2D = destination.get_node_or_null(FACTORY_RETURN_CHECKPOINT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(checkpoint).is_not_null()
	if player == null or checkpoint == null:
		return

	player.global_position = checkpoint.global_position
	assert_bool(bool(destination.call("try_activate_factory_return_checkpoint", player))).is_true()

	var scene_manager := FakeFactorySceneManager.new()
	var flow: Node = GAME_FLOW_SCRIPT.new()
	add_child(flow)
	_spawned_nodes.append(flow)
	flow.respawn_requested.connect(_on_respawn_requested)
	flow.call("set_savepoint_adapter", destination)
	flow.call("set_scene_transition_adapter", scene_manager)
	flow.call("configure_clan_base_respawn", &"hub", &"clan_base", Vector2(24, 42))
	flow.call("start_encounter", Vector2(24, 42))

	flow.call("handle_player_death")
	flow.call("advance_time", 1.51)

	assert_int(scene_manager.change_calls.size()).is_equal(1)
	assert_str(String(scene_manager.change_calls[0]["scene_id"])).is_equal("area_03_factory")
	assert_str(String(scene_manager.change_calls[0]["spawn_point"])).is_equal("return_checkpoint")
	assert_int(_respawn_events.size()).is_equal(1)
	assert_vector(_respawn_events[0]["position"]).is_equal(checkpoint.global_position)
	assert_str(String(Dictionary(flow.call("get_last_selected_respawn_point")).get(
		"source",
		""
	))).is_equal("savepoint")


func test_scene_manager_return_checkpoint_spawn_moves_player_to_checkpoint() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	destination.call("set_local_state", _service_lift_return_state().merged({
		"factory_return_patrol_defeated": true,
		"factory_return_checkpoint_activated": true,
		"last_return_checkpoint": {
			"id": "old_factory_return_checkpoint",
			"scene_id": "area_03_factory",
			"spawn_point": "return_checkpoint",
			"position": Vector2(704, 380),
		},
	}, true))

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var checkpoint: Node2D = destination.get_node_or_null(FACTORY_RETURN_CHECKPOINT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(checkpoint).is_not_null()
	if player == null or checkpoint == null:
		return
	player.global_position = checkpoint.global_position + Vector2(260.0, 0.0)

	var scene_manager := FakeFactorySceneManager.new()
	scene_manager.current_scene = &"area_03_factory"
	scene_manager.current_spawn_point = &"return_checkpoint"

	assert_bool(bool(destination.call("configure_scene_manager_runtime", scene_manager))).is_true()

	var route: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_float(player.global_position.distance_to(checkpoint.global_position)).is_less_equal(1.0)
	assert_str(String(route.get("route_label_text", ""))).is_equal("Returned to Factory Savepoint")


func test_non_boss_death_runtime_swaps_to_factory_checkpoint_spawn() -> void:
	var source_factory: Node = _factory_scene_with_activated_return_checkpoint()
	assert_that(source_factory).is_not_null()
	if source_factory == null:
		return

	var scene_manager: Node = _configured_scene_manager_with_runtime_root()
	var runtime_root: Node = scene_manager.call("get_runtime_scene_root_node")
	assert_that(runtime_root).is_not_null()
	if runtime_root == null:
		return

	var flow: Node = GAME_FLOW_SCRIPT.new()
	add_child(flow)
	_spawned_nodes.append(flow)
	flow.call("set_savepoint_adapter", source_factory)
	flow.call("set_scene_transition_adapter", scene_manager)
	flow.call("configure_clan_base_respawn", &"hub", &"clan_base", Vector2(24, 42))
	flow.call("start_encounter", Vector2(24, 42))

	flow.call("handle_player_death")
	flow.call("advance_time", 1.51)

	assert_bool(bool(scene_manager.call("is_loading"))).is_true()
	assert_str(String(scene_manager.call("get_pending_scene"))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(scene_manager.call("get_pending_spawn_point"))).is_equal("return_checkpoint")

	scene_manager.call("advance_loading", TRANSITION_SECONDS)
	scene_manager.call("advance_deferred_unload", 3.1)
	await get_tree().process_frame
	var factory_scene: Node = runtime_root.get_child(0)
	assert_str(factory_scene.name).is_equal("FactoryRouteTransitionShellScene")
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("return_checkpoint")

	var player: Node2D = factory_scene.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var checkpoint: Node2D = (
		factory_scene.get_node_or_null(FACTORY_RETURN_CHECKPOINT_NAME) as Node2D
	)
	assert_that(player).is_not_null()
	assert_that(checkpoint).is_not_null()
	if player == null or checkpoint == null:
		return
	var route: Dictionary = factory_scene.call("get_factory_route_objective_diagnostics")
	assert_float(player.global_position.distance_to(checkpoint.global_position)).is_less_equal(1.0)
	assert_str(String(route.get("route_label_text", ""))).is_equal("Returned to Factory Savepoint")
	assert_str(String(Dictionary(flow.call("get_last_selected_respawn_point")).get(
		"source",
		""
	))).is_equal("savepoint")


func test_factory_runtime_death_preserves_checkpoint_state_on_same_scene_respawn() -> void:
	var scene_manager: Node = _configured_scene_manager_with_factory_runtime()
	var runtime_root: Node = scene_manager.call("get_runtime_scene_root_node")
	assert_that(runtime_root).is_not_null()
	if runtime_root == null:
		return

	var current_factory: Node = runtime_root.get_child(0)
	current_factory.call("set_local_state", _service_lift_return_state().merged({
		"factory_return_patrol_defeated": true,
	}, true))
	var player: Node2D = current_factory.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var checkpoint: Node2D = (
		current_factory.get_node_or_null(FACTORY_RETURN_CHECKPOINT_NAME) as Node2D
	)
	assert_that(player).is_not_null()
	assert_that(checkpoint).is_not_null()
	if player == null or checkpoint == null:
		return
	player.global_position = checkpoint.global_position
	assert_bool(bool(current_factory.call(
		"try_activate_factory_return_checkpoint",
		player
	))).is_true()

	var flow: Node = GAME_FLOW_SCRIPT.new()
	add_child(flow)
	_spawned_nodes.append(flow)
	flow.call("set_savepoint_adapter", current_factory)
	flow.call("set_scene_transition_adapter", scene_manager)
	flow.call("configure_clan_base_respawn", &"hub", &"clan_base", Vector2(24, 42))
	flow.call("start_encounter", Vector2(24, 42))

	flow.call("handle_player_death")
	flow.call("advance_time", 1.51)

	assert_bool(bool(scene_manager.call("is_loading"))).is_true()
	assert_str(String(scene_manager.call("get_pending_scene"))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(scene_manager.call("get_pending_spawn_point"))).is_equal("return_checkpoint")

	scene_manager.call("advance_loading", TRANSITION_SECONDS)
	scene_manager.call("advance_deferred_unload", 3.1)
	await get_tree().process_frame
	var restored_factory: Node = runtime_root.get_child(0)
	assert_bool(restored_factory != current_factory).is_true()
	assert_str(restored_factory.name).is_equal("FactoryRouteTransitionShellScene")

	var restored_player: Node2D = restored_factory.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var restored_checkpoint: Node2D = (
		restored_factory.get_node_or_null(FACTORY_RETURN_CHECKPOINT_NAME) as Node2D
	)
	assert_that(restored_player).is_not_null()
	assert_that(restored_checkpoint).is_not_null()
	if restored_player == null or restored_checkpoint == null:
		return

	var diagnostics: Dictionary = restored_factory.call("get_factory_return_checkpoint_diagnostics")
	var route: Dictionary = restored_factory.call("get_factory_route_objective_diagnostics")
	assert_bool(bool(diagnostics.get("visible", false))).is_true()
	assert_bool(bool(diagnostics.get("available", false))).is_true()
	assert_bool(bool(diagnostics.get("activated", false))).is_true()
	assert_float(
		restored_player.global_position.distance_to(restored_checkpoint.global_position)
	).is_less_equal(1.0)
	assert_str(String(route.get("route_label_text", ""))).is_equal("Returned to Factory Savepoint")
	assert_bool(bool(Dictionary(restored_factory.call("get_local_state")).get(
		"factory_service_lift_activated",
		false
	))).is_true()
	assert_bool(bool(Dictionary(restored_factory.call("get_local_state")).get(
		"factory_return_patrol_defeated",
		false
	))).is_true()


func _instantiate_factory_scene() -> Node:
	assert_bool(FileAccess.file_exists(FACTORY_SCENE_PATH)).is_true()
	var packed: PackedScene = load(FACTORY_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var destination: Node = packed.instantiate()
	add_child(destination)
	_spawned_nodes.append(destination)
	return destination


func _factory_scene_with_activated_return_checkpoint() -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _service_lift_return_state().merged({
		"factory_return_patrol_defeated": true,
	}, true))
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var checkpoint: Node2D = destination.get_node_or_null(FACTORY_RETURN_CHECKPOINT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(checkpoint).is_not_null()
	if player == null or checkpoint == null:
		return null
	player.global_position = checkpoint.global_position
	assert_bool(bool(destination.call("try_activate_factory_return_checkpoint", player))).is_true()
	return destination


func _configured_scene_manager_with_runtime_root() -> Node:
	var manager: Node = SCENE_MANAGER_SCRIPT.new()
	add_child(manager)
	_spawned_nodes.append(manager)
	assert_bool(bool(manager.call("configure_scene_registry", _roundtrip_registry()))).is_true()
	manager.call("set_loader_adapter", ReturnCheckpointLoaderAdapter.new())

	var runtime_root: Node = Node.new()
	runtime_root.name = "RuntimeRoot"
	add_child(runtime_root)
	_spawned_nodes.append(runtime_root)
	var main_scene: Node = MAIN_SCENE.instantiate()
	runtime_root.add_child(main_scene)
	assert_bool(bool(manager.call("configure_runtime_scene_root", runtime_root, main_scene))).is_true()
	assert_bool(bool(manager.call("change_scene", MAIN_SCENE_ID, &"default"))).is_true()
	return manager


func _configured_scene_manager_with_factory_runtime() -> Node:
	var manager: Node = SCENE_MANAGER_SCRIPT.new()
	add_child(manager)
	_spawned_nodes.append(manager)
	assert_bool(bool(manager.call("configure_scene_registry", _roundtrip_registry()))).is_true()
	manager.call("set_loader_adapter", ReturnCheckpointLoaderAdapter.new())

	var runtime_root: Node = Node.new()
	runtime_root.name = "RuntimeRoot"
	add_child(runtime_root)
	_spawned_nodes.append(runtime_root)
	var factory_scene: Node = FACTORY_SCENE.instantiate()
	runtime_root.add_child(factory_scene)
	assert_bool(bool(manager.call(
		"configure_runtime_scene_root",
		runtime_root,
		factory_scene
	))).is_true()
	assert_bool(bool(manager.call(
		"change_scene",
		FACTORY_SCENE_ID,
		&"factory_gate_entry"
	))).is_true()
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


func _service_lift_return_state() -> Dictionary:
	return {
		"encounter_cleared": true,
		"factory_cache_claimed": true,
		"factory_deep_guard_activated": true,
		"factory_deep_guard_defeated": true,
		"factory_deep_route_cleared": true,
		"factory_spark_rat_activated": true,
		"factory_spark_rat_defeated": true,
		"factory_service_lift_activated": true,
		"factory_service_lift_exit_requested": true,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
	}


func _on_respawn_requested(position: Vector2, revive_hp_percentage: float) -> void:
	_respawn_events.append({
		"position": position,
		"revive_hp_percentage": revive_hp_percentage,
	})


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
