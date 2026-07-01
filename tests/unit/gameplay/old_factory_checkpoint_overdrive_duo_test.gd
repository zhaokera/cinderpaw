## Player Abilities Story 049: Old Factory checkpoint overdrive duo.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_OVERDRIVE_LEFT_NAME: String = "FactoryCheckpointOverdriveSparkRatLeft"
const FACTORY_OVERDRIVE_RIGHT_NAME: String = "FactoryCheckpointOverdriveSparkRatRight"
const FACTORY_OVERDRIVE_LEFT_ENTITY_ID: int = 2106
const FACTORY_OVERDRIVE_RIGHT_ENTITY_ID: int = 2107
const EXIT_SCENE_ID: StringName = &"main"
const EXIT_SPAWN_POINT: StringName = &"scrap_roost"
const REQUIRED_OVERDRIVE_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]
const MIN_CHARACTER_ANIMATION_FRAMES: int = 3

var _spawned_nodes: Array[Node] = []


class FakeOverdriveSceneManager:
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


func test_overdrive_duo_stays_hidden_until_checkpoint_rear_ambush_is_cleared() -> void:
	var destination: Node = _factory_scene_with_rear_ambush_active()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("get_factory_checkpoint_overdrive_duo_diagnostics")).is_true()
	if not destination.has_method("get_factory_checkpoint_overdrive_duo_diagnostics"):
		return

	var left_rat: Node2D = destination.get_node_or_null(FACTORY_OVERDRIVE_LEFT_NAME) as Node2D
	var right_rat: Node2D = destination.get_node_or_null(FACTORY_OVERDRIVE_RIGHT_NAME) as Node2D
	assert_that(left_rat).is_not_null()
	assert_that(right_rat).is_not_null()

	var locked: Dictionary = destination.call("get_factory_checkpoint_overdrive_duo_diagnostics")
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("cleared", true))).is_false()
	assert_bool(bool(locked.get("left_visible", true))).is_false()
	assert_bool(bool(locked.get("right_visible", true))).is_false()
	assert_bool(bool(destination.call("try_activate_factory_checkpoint_overdrive_duo"))).is_false()


func test_overdrive_duo_activation_after_rear_ambush_locks_service_lift() -> void:
	var destination: Node = _factory_scene_with_rear_ambush_cleared()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("try_activate_factory_checkpoint_overdrive_duo")).is_true()
	assert_bool(destination.has_method("get_factory_checkpoint_overdrive_duo_diagnostics")).is_true()
	if (
		not destination.has_method("try_activate_factory_checkpoint_overdrive_duo")
		or not destination.has_method("get_factory_checkpoint_overdrive_duo_diagnostics")
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(service_lift).is_not_null()
	if player == null or service_lift == null:
		return

	var before: Dictionary = destination.call("get_factory_checkpoint_overdrive_duo_diagnostics")
	assert_bool(bool(before.get("available", false))).is_true()
	assert_bool(bool(before.get("active", true))).is_false()
	player.global_position.x = float(before.get("activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call("try_activate_factory_checkpoint_overdrive_duo", player))).is_true()

	var active: Dictionary = destination.call("get_factory_checkpoint_overdrive_duo_diagnostics")
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("left_visible", false))).is_true()
	assert_bool(bool(active.get("right_visible", false))).is_true()
	assert_bool(bool(active.get("left_has_target", false))).is_true()
	assert_bool(bool(active.get("right_has_target", false))).is_true()
	assert_int(int(active.get("left_entity_id", 0))).is_equal(FACTORY_OVERDRIVE_LEFT_ENTITY_ID)
	assert_int(int(active.get("right_entity_id", 0))).is_equal(FACTORY_OVERDRIVE_RIGHT_ENTITY_ID)
	assert_bool(bool(active.get("left_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("right_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("left_process_enabled", false))).is_true()
	assert_bool(bool(active.get("right_process_enabled", false))).is_true()
	_assert_overdrive_frame_contract(active)

	var objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(objective.get("objective_id", ""))).is_equal("clear_checkpoint_overdrive_duo")
	assert_str(String(objective.get("route_label_text", ""))).is_equal("Clear Overdrive Duo")

	player.global_position = service_lift.global_position
	assert_bool(bool(destination.call("try_activate_factory_service_lift", player))).is_false()
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", true))).is_false()
	assert_bool(bool(lift.get("activation_ready", true))).is_false()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Clear overdrive duo")
	assert_str(String(lift.get("exit_rejected_reason", ""))).is_equal("overdrive_duo_active")
	assert_bool(bool(lift.get("overdrive_duo_active", false))).is_true()


func test_overdrive_duo_defeat_persists_and_unlocks_service_lift() -> void:
	var destination: Node = _factory_scene_with_rear_ambush_cleared()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	var scene_manager := FakeOverdriveSceneManager.new()
	assert_bool(bool(destination.call("configure_scene_manager_runtime", scene_manager))).is_true()

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(service_lift).is_not_null()
	if player == null or service_lift == null:
		return

	var before: Dictionary = destination.call("get_factory_checkpoint_overdrive_duo_diagnostics")
	player.global_position.x = float(before.get("activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call("try_activate_factory_checkpoint_overdrive_duo", player))).is_true()

	assert_bool(destination.call("apply_damage", FACTORY_OVERDRIVE_LEFT_ENTITY_ID, 999, {
		"source": &"unit_test_checkpoint_overdrive_left",
	})).is_true()
	await get_tree().process_frame
	var half_cleared: Dictionary = destination.call("get_factory_checkpoint_overdrive_duo_diagnostics")
	assert_bool(bool(half_cleared.get("left_defeated", false))).is_true()
	assert_bool(bool(half_cleared.get("right_defeated", true))).is_false()
	assert_bool(bool(half_cleared.get("cleared", true))).is_false()
	player.global_position = service_lift.global_position
	assert_bool(bool(destination.call("try_activate_factory_service_lift", player))).is_false()

	assert_bool(destination.call("apply_damage", FACTORY_OVERDRIVE_RIGHT_ENTITY_ID, 999, {
		"source": &"unit_test_checkpoint_overdrive_right",
	})).is_true()
	await get_tree().process_frame

	var cleared: Dictionary = destination.call("get_factory_checkpoint_overdrive_duo_diagnostics")
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("left_visible", true))).is_false()
	assert_bool(bool(cleared.get("right_visible", true))).is_false()

	var objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(objective.get("objective_id", ""))).is_equal("checkpoint_overdrive_duo_cleared")
	assert_str(String(objective.get("route_label_text", ""))).is_equal("Factory Lift Secured")
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
	assert_bool(bool(local_state.get("factory_checkpoint_overdrive_duo_activated", false))).is_true()
	assert_bool(bool(local_state.get("factory_checkpoint_overdrive_left_defeated", false))).is_true()
	assert_bool(bool(local_state.get("factory_checkpoint_overdrive_right_defeated", false))).is_true()
	assert_bool(bool(local_state.get("factory_checkpoint_overdrive_duo_cleared", false))).is_true()

	var restored: Node = _instantiate_factory_scene()
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", local_state)
	var restored_duo: Dictionary = restored.call("get_factory_checkpoint_overdrive_duo_diagnostics")
	assert_bool(bool(restored_duo.get("active", true))).is_false()
	assert_bool(bool(restored_duo.get("cleared", false))).is_true()
	assert_bool(bool(restored_duo.get("left_visible", true))).is_false()
	assert_bool(bool(restored_duo.get("right_visible", true))).is_false()


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


func _factory_scene_with_rear_ambush_active() -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _return_checkpoint_state().merged({
		"factory_checkpoint_forward_patrol_activated": true,
		"factory_checkpoint_forward_patrol_defeated": true,
		"factory_checkpoint_rear_ambush_activated": true,
		"factory_checkpoint_rear_ambush_defeated": false,
	}, true))
	return destination


func _factory_scene_with_rear_ambush_cleared() -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _return_checkpoint_state().merged({
		"factory_checkpoint_forward_patrol_activated": true,
		"factory_checkpoint_forward_patrol_defeated": true,
		"factory_checkpoint_rear_ambush_activated": true,
		"factory_checkpoint_rear_ambush_defeated": true,
	}, true))
	return destination


func _return_checkpoint_state() -> Dictionary:
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
		"factory_return_checkpoint_activated": true,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
		"last_return_checkpoint": {
			"id": "old_factory_return_checkpoint",
			"scene_id": "area_03_factory",
			"spawn_point": "return_checkpoint",
			"position": Vector2(704, 380),
		},
	}


func _assert_overdrive_frame_contract(duo: Dictionary) -> void:
	var left_frame_counts: Dictionary = duo.get("left_animation_frame_counts", {}) as Dictionary
	var right_frame_counts: Dictionary = duo.get("right_animation_frame_counts", {}) as Dictionary
	for animation_name: StringName in REQUIRED_OVERDRIVE_ANIMATIONS:
		var animation_key: String = String(animation_name)
		assert_bool(left_frame_counts.has(animation_key)).is_true()
		assert_bool(right_frame_counts.has(animation_key)).is_true()
		if left_frame_counts.has(animation_key):
			assert_int(int(left_frame_counts[animation_key])).is_greater_equal(
				MIN_CHARACTER_ANIMATION_FRAMES
			)
		if right_frame_counts.has(animation_key):
			assert_int(int(right_frame_counts[animation_key])).is_greater_equal(
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
