## Player Abilities Story 046: Old Factory checkpoint-forward combat route.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_RETURN_CHECKPOINT_NAME: String = "FactoryReturnCheckpoint"
const FACTORY_FORWARD_SPARK_RAT_NAME: String = "FactoryCheckpointForwardSparkRat"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_FORWARD_SPARK_RAT_ENTITY_ID: int = 2104
const EXIT_SCENE_ID: StringName = &"main"
const EXIT_SPAWN_POINT: StringName = &"scrap_roost"
const REQUIRED_FORWARD_PATROL_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]
const MIN_CHARACTER_ANIMATION_FRAMES: int = 3

var _spawned_nodes: Array[Node] = []


class FakeForwardRouteSceneManager:
	extends RefCounted

	var request_calls: Array[Dictionary] = []
	var loading: bool = false

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == EXIT_SCENE_ID or scene_id == &"area_03_factory"

	func is_loading() -> bool:
		return loading

	func is_scene_locked() -> bool:
		return false

	func get_current_scene() -> StringName:
		return &"area_03_factory"

	func get_current_spawn_point() -> StringName:
		return &"return_checkpoint"

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


func test_forward_patrol_is_hidden_until_return_checkpoint_is_activated() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("get_factory_checkpoint_forward_patrol_diagnostics")).is_true()
	if not destination.has_method("get_factory_checkpoint_forward_patrol_diagnostics"):
		return

	destination.call("set_local_state", _service_lift_return_state().merged({
		"factory_return_patrol_defeated": true,
	}, true))

	var forward_rat: Node2D = destination.get_node_or_null(FACTORY_FORWARD_SPARK_RAT_NAME) as Node2D
	assert_that(forward_rat).is_not_null()
	if forward_rat == null:
		return

	var locked: Dictionary = destination.call("get_factory_checkpoint_forward_patrol_diagnostics")
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("defeated", true))).is_false()

	assert_bool(bool(destination.call("try_activate_factory_checkpoint_forward_patrol"))).is_false()


func test_forward_patrol_activation_locks_service_lift_until_defeated() -> void:
	var destination: Node = _factory_scene_with_activated_return_checkpoint()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	assert_bool(destination.has_method("try_activate_factory_checkpoint_forward_patrol")).is_true()
	assert_bool(destination.has_method("get_factory_checkpoint_forward_patrol_diagnostics")).is_true()
	if (
		not destination.has_method("try_activate_factory_checkpoint_forward_patrol")
		or not destination.has_method("get_factory_checkpoint_forward_patrol_diagnostics")
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(service_lift).is_not_null()
	if player == null or service_lift == null:
		return

	var before: Dictionary = destination.call("get_factory_checkpoint_forward_patrol_diagnostics")
	player.global_position.x = float(before.get("activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call("try_activate_factory_checkpoint_forward_patrol", player))).is_true()

	var active: Dictionary = destination.call("get_factory_checkpoint_forward_patrol_diagnostics")
	assert_bool(bool(active.get("present", false))).is_true()
	assert_bool(bool(active.get("visible", false))).is_true()
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("available", false))).is_true()
	assert_bool(bool(active.get("defeated", true))).is_false()
	assert_int(int(active.get("entity_id", 0))).is_equal(FACTORY_FORWARD_SPARK_RAT_ENTITY_ID)
	assert_bool(bool(active.get("has_target", false))).is_true()
	assert_bool(bool(active.get("physics_enabled", false))).is_true()
	assert_bool(bool(active.get("process_enabled", false))).is_true()
	_assert_forward_patrol_frame_contract(active)

	var objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(objective.get("objective_id", ""))).is_equal("clear_checkpoint_forward_patrol")
	assert_str(String(objective.get("route_label_text", ""))).is_equal("Clear Forward Patrol")

	player.global_position = service_lift.global_position
	assert_bool(bool(destination.call("try_activate_factory_service_lift", player))).is_false()
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", true))).is_false()
	assert_bool(bool(lift.get("activation_ready", true))).is_false()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Clear forward patrol")
	assert_str(String(lift.get("exit_rejected_reason", ""))).is_equal("forward_patrol_active")
	assert_bool(bool(lift.get("forward_patrol_active", false))).is_true()


func test_forward_patrol_defeat_persists_and_reopens_deeper_route() -> void:
	var destination: Node = _factory_scene_with_activated_return_checkpoint()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	var scene_manager := FakeForwardRouteSceneManager.new()
	assert_bool(bool(destination.call("configure_scene_manager_runtime", scene_manager))).is_true()

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(service_lift).is_not_null()
	if player == null or service_lift == null:
		return

	var before: Dictionary = destination.call("get_factory_checkpoint_forward_patrol_diagnostics")
	player.global_position.x = float(before.get("activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call("try_activate_factory_checkpoint_forward_patrol", player))).is_true()
	assert_bool(destination.call("apply_damage", FACTORY_FORWARD_SPARK_RAT_ENTITY_ID, 999, {
		"source": &"unit_test_checkpoint_forward_patrol",
	})).is_true()
	await get_tree().process_frame

	var cleared: Dictionary = destination.call("get_factory_checkpoint_forward_patrol_diagnostics")
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("visible", true))).is_false()
	assert_bool(bool(cleared.get("defeated", false))).is_true()

	var objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(objective.get("objective_id", ""))).is_equal("checkpoint_forward_route_opened")
	assert_str(String(objective.get("route_label_text", ""))).is_equal("Deeper Factory Route Opened")
	assert_bool(bool(objective.get("complete", false))).is_true()

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

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get("factory_checkpoint_forward_patrol_activated", false))).is_true()
	assert_bool(bool(local_state.get("factory_checkpoint_forward_patrol_defeated", false))).is_true()

	var restored: Node = _instantiate_factory_scene()
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", local_state)
	var restored_forward: Dictionary = restored.call(
		"get_factory_checkpoint_forward_patrol_diagnostics"
	)
	assert_bool(bool(restored_forward.get("active", true))).is_false()
	assert_bool(bool(restored_forward.get("defeated", false))).is_true()
	assert_bool(bool(restored_forward.get("visible", true))).is_false()


func test_uncleared_forward_patrol_restores_as_locked_checkpoint_challenge() -> void:
	var destination: Node = _factory_scene_with_activated_return_checkpoint()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var before: Dictionary = destination.call("get_factory_checkpoint_forward_patrol_diagnostics")
	player.global_position.x = float(before.get("activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call("try_activate_factory_checkpoint_forward_patrol", player))).is_true()

	var active_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(active_state.get(
		"factory_checkpoint_forward_patrol_activated",
		false
	))).is_true()
	assert_bool(bool(active_state.get(
		"factory_checkpoint_forward_patrol_defeated",
		true
	))).is_false()

	var restored: Node = _instantiate_factory_scene()
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", active_state)

	var restored_forward: Dictionary = restored.call(
		"get_factory_checkpoint_forward_patrol_diagnostics"
	)
	var restored_lift: Dictionary = restored.call("get_factory_service_lift_diagnostics")
	var restored_objective: Dictionary = restored.call("get_factory_route_objective_diagnostics")
	assert_bool(bool(restored_forward.get("active", false))).is_true()
	assert_bool(bool(restored_forward.get("visible", false))).is_true()
	assert_bool(bool(restored_forward.get("defeated", true))).is_false()
	assert_bool(bool(restored_lift.get("available", true))).is_false()
	assert_str(String(restored_lift.get("exit_rejected_reason", ""))).is_equal("")
	assert_str(String(restored_objective.get("objective_id", ""))).is_equal(
		"clear_checkpoint_forward_patrol"
	)
	assert_str(String(restored_objective.get("route_label_text", ""))).is_equal(
		"Clear Forward Patrol"
	)


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
		"factory_service_lift_exit_scene_id": String(EXIT_SCENE_ID),
		"factory_service_lift_exit_spawn_point": String(EXIT_SPAWN_POINT),
	}


func _assert_forward_patrol_frame_contract(patrol: Dictionary) -> void:
	var frame_counts: Dictionary = patrol.get("animation_frame_counts", {}) as Dictionary
	for animation_name: StringName in REQUIRED_FORWARD_PATROL_ANIMATIONS:
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
