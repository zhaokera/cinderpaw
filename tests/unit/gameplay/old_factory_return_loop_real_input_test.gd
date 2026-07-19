## Scene Management Story 025: Factory return-loop real-input handoff.
extends GdUnitTestSuite

const FACTORY_SCENE: PackedScene = preload(
	"res://scenes/factory_route_transition_shell.tscn"
)
const RETURN_CACHE_NAME: String = "FactoryReturnPatrolRewardCache"
const RETURN_CHECKPOINT_NAME: String = "FactoryReturnCheckpoint"
const RETURN_SPARK_RAT_ENTITY_ID: int = 2103

var _spawned_nodes: Array[Node] = []


class FakeServiceLiftSceneManager:
	extends RefCounted

	var request_calls: Array[Dictionary] = []
	var loading: bool = false

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == &"main" or scene_id == &"area_03_factory"

	func get_current_scene() -> StringName:
		return &"area_03_factory"

	func is_loading() -> bool:
		return loading

	func is_scene_locked() -> bool:
		return false

	func get_pending_scene() -> StringName:
		if request_calls.is_empty():
			return &""
		return StringName(String(request_calls.back().get("scene_id", "")))

	func get_pending_spawn_point() -> StringName:
		if request_calls.is_empty():
			return &""
		return StringName(String(request_calls.back().get("spawn_point", "")))

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
	Input.action_release(&"interact")
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_spark_rat_clear_guides_real_interact_to_service_lift_return() -> void:
	var destination: Node = _instantiate_factory_scene()
	var scene_manager := FakeServiceLiftSceneManager.new()
	assert_bool(bool(destination.call("configure_scene_manager_runtime", scene_manager))).is_true()
	destination.call("set_local_state", _spark_rat_clear_state())

	var objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(objective.get("objective_id", ""))).is_equal("call_service_lift")
	assert_str(String(objective.get("route_label_text", ""))).is_equal("Call Service Lift")
	assert_bool(bool(objective.get("complete", true))).is_false()

	var player := destination.get_node("Player") as CharacterBody2D
	var lift := destination.get_node("FactoryServiceLift") as Node2D
	player.global_position = lift.global_position
	await _press_interact_for_frame(destination)

	assert_int(scene_manager.request_calls.size()).is_equal(1)
	assert_str(String(scene_manager.request_calls[0].get("scene_id", ""))).is_equal("main")
	assert_str(String(scene_manager.request_calls[0].get("spawn_point", ""))).is_equal(
		"scrap_roost"
	)
	var lift_state: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift_state.get("exit_requested", false))).is_true()
	assert_str(String(lift_state.get("route_label_text", ""))).is_equal(
		"Service Lift Departing"
	)


func test_return_patrol_clear_uses_real_reward_input_and_contact_checkpoint_for_next_patrol() -> void:
	var destination: Node = _instantiate_factory_scene()
	destination.call("set_local_state", _service_lift_return_state())
	var patrol: Dictionary = destination.call("get_factory_return_patrol_diagnostics")
	assert_bool(bool(patrol.get("active", false))).is_true()
	assert_bool(bool(patrol.get("visible", false))).is_true()

	assert_bool(destination.call("apply_damage", RETURN_SPARK_RAT_ENTITY_ID, 999, {
		"source": &"story_025_return_patrol_clear",
	})).is_true()
	await get_tree().process_frame

	var checkpoint_state: Dictionary = destination.call(
		"get_factory_return_checkpoint_diagnostics"
	)
	var objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_bool(bool(checkpoint_state.get("visible", false))).is_true()
	assert_bool(bool(checkpoint_state.get("available", false))).is_true()
	assert_str(String(objective.get("objective_id", ""))).is_equal(
		"repair_return_checkpoint"
	)
	assert_str(String(objective.get("route_label_text", ""))).is_equal(
		"Repair Factory Savepoint"
	)

	var player := destination.get_node("Player") as CharacterBody2D
	var cache := destination.get_node(RETURN_CACHE_NAME) as Node2D
	player.global_position = cache.global_position
	await _press_interact_for_frame(destination)
	var cache_state: Dictionary = destination.call(
		"get_factory_return_patrol_reward_cache_diagnostics"
	)
	assert_bool(bool(cache_state.get("claimed", false))).is_true()
	assert_int(int(Dictionary(cache_state.get("last_reward", {})).get("gears", 0))).is_equal(15)

	var checkpoint := destination.get_node(RETURN_CHECKPOINT_NAME) as Node2D
	var interaction_area := checkpoint.get_node("InteractionArea") as Area2D
	var interaction_shape := interaction_area.get_node("CollisionShape2D") as CollisionShape2D
	assert_bool(interaction_area.monitoring).is_true()
	assert_bool(interaction_shape.disabled).is_false()
	player.global_position = checkpoint.global_position
	interaction_area.body_entered.emit(player)
	await get_tree().process_frame
	checkpoint_state = destination.call("get_factory_return_checkpoint_diagnostics")
	objective = destination.call("get_factory_route_objective_diagnostics")
	assert_bool(bool(checkpoint_state.get("activated", false))).is_true()
	assert_str(String(objective.get("objective_id", ""))).is_equal(
		"advance_from_return_checkpoint"
	)
	assert_str(String(objective.get("route_label_text", ""))).is_equal(
		"Savepoint Secured - Advance Right"
	)

	var forward: Dictionary = destination.call("get_factory_checkpoint_forward_patrol_diagnostics")
	player.global_position.x = float(forward.get("activation_x", 0.0)) + 1.0
	await get_tree().process_frame
	forward = destination.call("get_factory_checkpoint_forward_patrol_diagnostics")
	assert_bool(bool(forward.get("active", false))).is_true()
	assert_bool(bool(forward.get("visible", false))).is_true()
	assert_bool(bool(forward.get("has_target", false))).is_true()
	assert_bool(bool(forward.get("physics_enabled", false))).is_true()
	assert_int(int(Dictionary(forward.get("animation_frame_counts", {})).get("run", 0))).is_greater_equal(3)


func _instantiate_factory_scene() -> Node:
	var destination: Node = FACTORY_SCENE.instantiate()
	add_child(destination)
	_spawned_nodes.append(destination)
	return destination


func _press_interact_for_frame(destination: Node) -> void:
	Input.action_press(&"interact")
	destination.call("_process", 0.0)
	Input.action_release(&"interact")
	await get_tree().process_frame


func _spark_rat_clear_state() -> Dictionary:
	return {
		"encounter_cleared": true,
		"factory_cache_claimed": true,
		"factory_deep_guard_activated": true,
		"factory_deep_guard_defeated": true,
		"factory_deep_route_cleared": true,
		"factory_spark_rat_activated": true,
		"factory_spark_rat_defeated": true,
	}


func _service_lift_return_state() -> Dictionary:
	return _spark_rat_clear_state().merged({
		"factory_service_lift_activated": true,
		"factory_service_lift_exit_requested": true,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
		"factory_return_patrol_activated": false,
		"factory_return_patrol_defeated": false,
	}, true)


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
