## Scene Management Story 026: overlapping Factory reward/lift input priority.
extends GdUnitTestSuite

const FACTORY_SCENE: PackedScene = preload(
	"res://scenes/factory_route_transition_shell.tscn"
)
const OVERDRIVE_CACHE_NAME: String = "FactoryCheckpointOverdriveRewardCache"
const SERVICE_LIFT_NAME: String = "FactoryServiceLift"

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

	func request_scene_change(
		scene_id: StringName,
		spawn_point: StringName = &"default"
	) -> bool:
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


func test_real_interact_claims_overdrive_cache_before_overlapping_lift() -> void:
	var destination: Node = _instantiate_factory_scene()
	var scene_manager := FakeServiceLiftSceneManager.new()
	assert_bool(bool(destination.call(
		"configure_scene_manager_runtime",
		scene_manager
	))).is_true()
	destination.call("set_local_state", _overdrive_cleared_state())

	var player := destination.get_node("Player") as CharacterBody2D
	var cache := destination.get_node(OVERDRIVE_CACHE_NAME) as Node2D
	var lift := destination.get_node(SERVICE_LIFT_NAME) as Node2D
	player.global_position = cache.global_position
	assert_float(player.global_position.distance_to(lift.global_position)).is_less_equal(96.0)

	Input.action_press(&"interact")
	destination.call("_process", 0.0)
	destination.call("_process", 0.0)

	var cache_state: Dictionary = destination.call(
		"get_factory_checkpoint_overdrive_reward_cache_diagnostics"
	)
	var lift_state: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(cache_state.get("claimed", false))).is_true()
	assert_int(int(Dictionary(cache_state.get("last_reward", {})).get("gears", 0))).is_equal(25)
	assert_int(scene_manager.request_calls.size()).is_equal(0)
	assert_bool(bool(lift_state.get("exit_requested", false))).is_false()

	Input.action_release(&"interact")
	destination.call("_process", 0.0)
	Input.action_press(&"interact")
	destination.call("_process", 0.0)
	Input.action_release(&"interact")

	lift_state = destination.call("get_factory_service_lift_diagnostics")
	assert_int(scene_manager.request_calls.size()).is_equal(1)
	assert_str(String(scene_manager.request_calls[0].get("scene_id", ""))).is_equal("main")
	assert_str(String(scene_manager.request_calls[0].get("spawn_point", ""))).is_equal(
		"scrap_roost"
	)
	assert_bool(bool(lift_state.get("exit_requested", false))).is_true()


func _instantiate_factory_scene() -> Node:
	var destination: Node = FACTORY_SCENE.instantiate()
	add_child(destination)
	_spawned_nodes.append(destination)
	return destination


func _overdrive_cleared_state() -> Dictionary:
	return {
		"encounter_cleared": true,
		"factory_cache_claimed": true,
		"factory_deep_guard_activated": true,
		"factory_deep_guard_defeated": true,
		"factory_deep_route_cleared": true,
		"factory_spark_rat_activated": true,
		"factory_spark_rat_defeated": true,
		"factory_return_patrol_activated": true,
		"factory_return_patrol_defeated": true,
		"factory_return_patrol_reward_cache_claimed": true,
		"factory_return_checkpoint_activated": true,
		"factory_checkpoint_forward_patrol_activated": true,
		"factory_checkpoint_forward_patrol_defeated": true,
		"factory_checkpoint_rear_ambush_activated": true,
		"factory_checkpoint_rear_ambush_defeated": true,
		"factory_checkpoint_overdrive_duo_activated": true,
		"factory_checkpoint_overdrive_left_defeated": true,
		"factory_checkpoint_overdrive_right_defeated": true,
		"factory_checkpoint_overdrive_duo_cleared": true,
		"factory_checkpoint_overdrive_reward_cache_claimed": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
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
