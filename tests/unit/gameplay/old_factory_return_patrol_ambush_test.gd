## Player Abilities Story 040: Old Factory return patrol ambush.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_RETURN_SPARK_RAT_NAME: String = "FactoryReturnSparkRat"
const FACTORY_RETURN_SPARK_RAT_ENTITY_ID: int = 2103
const EXIT_SCENE_ID: StringName = &"main"
const EXIT_SPAWN_POINT: StringName = &"scrap_roost"
const REQUIRED_RETURN_PATROL_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]
const MIN_CHARACTER_ANIMATION_FRAMES: int = 3

var _spawned_nodes: Array[Node] = []


class FakeReturnPatrolSceneManager:
	extends RefCounted

	var request_calls: Array[Dictionary] = []
	var loading: bool = false

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == &"main" or scene_id == &"area_03_factory"

	func is_loading() -> bool:
		return loading

	func is_scene_locked() -> bool:
		return false

	func get_pending_scene() -> StringName:
		if request_calls.is_empty():
			return &""
		return StringName(String(request_calls[request_calls.size() - 1].get("scene_id", "")))

	func get_pending_spawn_point() -> StringName:
		if request_calls.is_empty():
			return &""
		return StringName(String(request_calls[request_calls.size() - 1].get("spawn_point", "")))

	func request_scene_change(scene_id: StringName, spawn_point: StringName = &"default") -> bool:
		if loading or not has_scene(scene_id):
			return false
		request_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		loading = true
		return true


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_return_patrol_does_not_spawn_on_first_factory_clear() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	assert_bool(destination.has_method("get_factory_return_patrol_diagnostics")).is_true()
	if not destination.has_method("get_factory_return_patrol_diagnostics"):
		return

	destination.call("set_local_state", _factory_route_cleared_state())

	var patrol: Dictionary = destination.call("get_factory_return_patrol_diagnostics")
	assert_bool(bool(patrol.get("present", false))).is_true()
	assert_bool(bool(patrol.get("active", true))).is_false()
	assert_bool(bool(patrol.get("visible", true))).is_false()
	assert_bool(bool(patrol.get("defeated", true))).is_false()

	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")
	var objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(objective.get("objective_id", ""))).is_equal("call_service_lift")


func test_return_patrol_activates_from_service_lift_return_contract_and_locks_lift() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	assert_bool(destination.has_method("get_factory_return_patrol_diagnostics")).is_true()
	if not destination.has_method("get_factory_return_patrol_diagnostics"):
		return

	destination.call("set_local_state", _service_lift_return_state())

	var return_rat: Node2D = destination.get_node_or_null(FACTORY_RETURN_SPARK_RAT_NAME) as Node2D
	assert_that(return_rat).is_not_null()
	if return_rat == null:
		return
	var patrol: Dictionary = destination.call("get_factory_return_patrol_diagnostics")
	assert_bool(bool(patrol.get("present", false))).is_true()
	assert_bool(bool(patrol.get("active", false))).is_true()
	assert_bool(bool(patrol.get("visible", false))).is_true()
	assert_bool(bool(patrol.get("defeated", true))).is_false()
	assert_int(int(patrol.get("entity_id", 0))).is_equal(FACTORY_RETURN_SPARK_RAT_ENTITY_ID)
	assert_bool(bool(patrol.get("has_target", false))).is_true()
	assert_bool(bool(patrol.get("physics_enabled", false))).is_true()
	assert_bool(bool(patrol.get("process_enabled", false))).is_true()
	_assert_return_patrol_frame_contract(patrol)

	var objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(objective.get("objective_id", ""))).is_equal("clear_return_patrol")
	assert_str(String(objective.get("route_label_text", ""))).is_equal("Clear Return Patrol")

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(service_lift).is_not_null()
	if player == null or service_lift == null:
		return
	player.global_position = service_lift.global_position
	assert_bool(bool(destination.call("try_activate_factory_service_lift", player))).is_false()

	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", true))).is_false()
	assert_bool(bool(lift.get("activation_ready", true))).is_false()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Clear patrol")
	assert_str(String(lift.get("exit_rejected_reason", ""))).is_equal("return_patrol_active")
	assert_bool(bool(lift.get("return_patrol_active", false))).is_true()
	assert_bool(bool(lift.get("exit_requested", true))).is_false()


func test_return_patrol_defeat_persists_and_reenables_service_lift_exit() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	var scene_manager := FakeReturnPatrolSceneManager.new()
	assert_bool(bool(destination.call("configure_scene_manager_runtime", scene_manager))).is_true()
	assert_bool(destination.has_method("get_factory_return_patrol_diagnostics")).is_true()
	if not destination.has_method("get_factory_return_patrol_diagnostics"):
		return
	destination.call("set_local_state", _service_lift_return_state())

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(service_lift).is_not_null()
	if player == null or service_lift == null:
		return

	assert_bool(destination.call("apply_damage", FACTORY_RETURN_SPARK_RAT_ENTITY_ID, 999, {
		"source": &"unit_test_factory_return_patrol",
	})).is_true()
	await get_tree().process_frame

	var patrol: Dictionary = destination.call("get_factory_return_patrol_diagnostics")
	assert_bool(bool(patrol.get("active", true))).is_false()
	assert_bool(bool(patrol.get("visible", true))).is_false()
	assert_bool(bool(patrol.get("defeated", false))).is_true()
	var objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(objective.get("objective_id", ""))).is_equal("repair_return_checkpoint")
	assert_str(String(objective.get("route_label_text", ""))).is_equal("Repair Factory Savepoint")
	assert_bool(bool(objective.get("complete", true))).is_false()

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get("factory_return_patrol_activated", false))).is_true()
	assert_bool(bool(local_state.get("factory_return_patrol_defeated", false))).is_true()
	assert_bool(bool(local_state.get("factory_service_lift_exit_requested", true))).is_false()

	player.global_position = service_lift.global_position
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_bool(bool(lift.get("activation_ready", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")

	assert_bool(bool(destination.call("try_activate_factory_service_lift", player))).is_true()
	assert_int(scene_manager.request_calls.size()).is_equal(1)
	assert_str(String(scene_manager.request_calls[0].get("scene_id", ""))).is_equal(String(EXIT_SCENE_ID))
	assert_str(String(scene_manager.request_calls[0].get("spawn_point", ""))).is_equal(
		String(EXIT_SPAWN_POINT)
	)

	var post_exit_state: Dictionary = destination.call("get_local_state")
	var restored: Node = _instantiate_factory_scene()
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", post_exit_state)
	var restored_patrol: Dictionary = restored.call("get_factory_return_patrol_diagnostics")
	assert_bool(bool(restored_patrol.get("active", true))).is_false()
	assert_bool(bool(restored_patrol.get("defeated", false))).is_true()


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


func _factory_route_cleared_state() -> Dictionary:
	return {
		"encounter_cleared": true,
		"factory_deep_guard_activated": true,
		"factory_deep_guard_defeated": true,
		"factory_deep_route_cleared": true,
		"factory_spark_rat_activated": true,
		"factory_spark_rat_defeated": true,
	}


func _service_lift_return_state() -> Dictionary:
	var state: Dictionary = _factory_route_cleared_state()
	state.merge({
		"factory_service_lift_activated": true,
		"factory_service_lift_exit_requested": true,
		"factory_service_lift_exit_scene_id": String(EXIT_SCENE_ID),
		"factory_service_lift_exit_spawn_point": String(EXIT_SPAWN_POINT),
	}, true)
	return state


func _assert_return_patrol_frame_contract(patrol: Dictionary) -> void:
	var frame_counts: Dictionary = patrol.get("animation_frame_counts", {}) as Dictionary
	for animation_name: StringName in REQUIRED_RETURN_PATROL_ANIMATIONS:
		assert_bool(frame_counts.has(String(animation_name))).is_true()
		if not frame_counts.has(String(animation_name)):
			continue
		assert_int(int(frame_counts[String(animation_name)])).is_greater_equal(
			MIN_CHARACTER_ANIMATION_FRAMES
		)


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
