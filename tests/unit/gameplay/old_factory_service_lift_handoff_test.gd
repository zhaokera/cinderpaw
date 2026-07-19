## Player Abilities Story 035: Old Factory service lift handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const SERVICE_LIFT_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_service_lift/factory_service_lift_console.png"
)
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_ENTRY_GUARD_NAME: String = "FactoryRatMinion"
const FACTORY_DEEP_GUARD_NAME: String = "FactoryDeepGuardRatMinion"
const FACTORY_DEEP_ENDPOINT_NAME: String = "FactoryDeepRouteEndpoint"
const FACTORY_SPARK_RAT_NAME: String = "FactorySparkRat"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_SPARK_RAT_ENTITY_ID: int = 2102
const OBJECTIVE_ROUTE_CLEARED: String = "factory_route_cleared"

var _spawned_nodes: Array[Node] = []


class FakeServiceLiftSceneManager:
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


func test_service_lift_stays_hidden_until_spark_rat_clear_then_activates_once() -> void:
	assert_bool(FileAccess.file_exists(SERVICE_LIFT_TEXTURE_PATH)).is_true()
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	assert_bool(destination.has_method("get_factory_service_lift_diagnostics")).is_true()
	assert_bool(destination.has_method("try_activate_factory_service_lift")).is_true()
	assert_bool(destination.has_method("is_factory_service_lift_activated")).is_true()
	assert_bool(destination.has_method("configure_scene_manager_runtime")).is_true()
	var scene_manager := FakeServiceLiftSceneManager.new()
	assert_bool(bool(destination.call("configure_scene_manager_runtime", scene_manager))).is_true()

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(service_lift).is_not_null()
	if player == null or service_lift == null:
		return
	_assert_service_lift_visual_contract(service_lift)

	player.global_position = service_lift.global_position
	_assert_service_lift_locked(destination)
	assert_bool(bool(destination.call("try_activate_factory_service_lift", player))).is_false()

	await _clear_factory_route(destination, player)

	_assert_service_lift_available(destination)

	assert_bool(bool(destination.call("try_activate_factory_service_lift", player))).is_true()
	assert_int(scene_manager.request_calls.size()).is_equal(1)
	assert_str(String(scene_manager.request_calls[0].get("scene_id", ""))).is_equal("main")
	assert_str(String(scene_manager.request_calls[0].get("spawn_point", ""))).is_equal("scrap_roost")
	var spawn_count: int = _assert_service_lift_activated(destination)
	assert_bool(bool(destination.call("is_factory_service_lift_activated"))).is_true()

	assert_bool(bool(destination.call("try_activate_factory_service_lift", player))).is_false()
	var repeated_diagnostics: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_int(int(repeated_diagnostics.get("unlock_feedback_spawn_count", 0))).is_equal(spawn_count)

	var objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(objective.get("objective_id", ""))).is_equal(OBJECTIVE_ROUTE_CLEARED)
	assert_bool(bool(objective.get("complete", false))).is_true()

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get("factory_service_lift_activated", false))).is_true()
	assert_bool(bool(local_state.get("factory_service_lift_exit_requested", false))).is_true()


func test_service_lift_restores_activated_state_without_replaying_feedback() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	assert_bool(destination.has_method("get_factory_service_lift_diagnostics")).is_true()

	destination.call("set_local_state", {
		"encounter_cleared": true,
		"factory_deep_guard_activated": true,
		"factory_deep_guard_defeated": true,
		"factory_deep_route_cleared": true,
		"factory_spark_rat_activated": true,
		"factory_spark_rat_defeated": true,
		"factory_service_lift_activated": true,
	})

	var diagnostics: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(diagnostics.get("present", false))).is_true()
	assert_bool(bool(diagnostics.get("available", false))).is_false()
	assert_bool(bool(diagnostics.get("activated", false))).is_true()
	assert_str(String(diagnostics.get("prompt_text", ""))).is_equal("Lift online")
	assert_int(int(diagnostics.get("unlock_feedback_spawn_count", -1))).is_equal(0)

	var entrance_diagnostics: Dictionary = destination.call("get_factory_entrance_diagnostics")
	assert_bool(entrance_diagnostics.has("service_lift")).is_true()
	assert_bool(bool((entrance_diagnostics.get("service_lift", {}) as Dictionary).get(
		"activated",
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


func _clear_factory_route(destination: Node, player: Node2D) -> void:
	await _defeat_guard(destination, FACTORY_ENTRY_GUARD_NAME, &"unit_test_service_lift_entry")

	var route_diagnostics: Dictionary = destination.call("get_factory_deep_route_diagnostics")
	player.global_position.x = float(route_diagnostics.get("deep_guard_activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call("try_activate_factory_deep_guard", player))).is_true()
	await _defeat_guard(destination, FACTORY_DEEP_GUARD_NAME, &"unit_test_service_lift_deep_guard")

	var endpoint: Node2D = destination.get_node_or_null(FACTORY_DEEP_ENDPOINT_NAME) as Node2D
	assert_that(endpoint).is_not_null()
	if endpoint == null:
		return
	player.global_position = endpoint.global_position
	assert_bool(bool(destination.call("try_activate_factory_deep_route_endpoint", player))).is_true()

	var spark_rat: Node2D = destination.get_node_or_null(FACTORY_SPARK_RAT_NAME) as Node2D
	assert_that(spark_rat).is_not_null()
	if spark_rat == null:
		return
	var spark_diagnostics: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	player.global_position = spark_rat.global_position + Vector2(-32.0, 0.0)
	player.global_position.x = maxf(
		player.global_position.x,
		float(spark_diagnostics.get("activation_x", spark_rat.global_position.x)) + 8.0
	)
	assert_bool(bool(destination.call("try_activate_factory_spark_rat", player))).is_true()
	assert_bool(destination.call("apply_damage", FACTORY_SPARK_RAT_ENTITY_ID, 999, {
		"source": &"unit_test_factory_service_lift",
	})).is_true()
	await get_tree().process_frame

	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(service_lift).is_not_null()
	if service_lift != null:
		player.global_position = service_lift.global_position


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


func _assert_service_lift_visual_contract(service_lift: Node2D) -> void:
	var visual := service_lift.get_node_or_null("Visual") as Sprite2D
	assert_that(visual).is_not_null()
	if visual != null:
		assert_that(visual.texture).is_not_null()
		assert_str(visual.texture.resource_path).is_equal(SERVICE_LIFT_TEXTURE_PATH)
	assert_that(_find_first_child_by_class(service_lift, "ColorRect")).is_null()
	assert_that(_find_first_child_by_class(service_lift, "Polygon2D")).is_null()


func _assert_service_lift_locked(destination: Node) -> void:
	var diagnostics: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(diagnostics.get("present", false))).is_true()
	assert_bool(bool(diagnostics.get("available", true))).is_false()
	assert_bool(bool(diagnostics.get("activated", true))).is_false()
	assert_bool(bool(diagnostics.get("activation_ready", true))).is_false()
	assert_str(String(diagnostics.get("endpoint_id", ""))).is_equal("old_factory_service_lift")
	assert_str(String(diagnostics.get("texture_path", ""))).is_equal(SERVICE_LIFT_TEXTURE_PATH)
	assert_str(String(diagnostics.get("prompt_text", ""))).is_equal("Clear patrol")


func _assert_service_lift_available(destination: Node) -> void:
	var diagnostics: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(diagnostics.get("available", false))).is_true()
	assert_bool(bool(diagnostics.get("activation_ready", false))).is_true()
	assert_str(String(diagnostics.get("prompt_text", ""))).is_equal("Call lift")


func _assert_service_lift_activated(destination: Node) -> int:
	var diagnostics: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(diagnostics.get("activated", false))).is_true()
	assert_str(String(diagnostics.get("prompt_text", ""))).is_equal("Lift online")
	assert_str(String(diagnostics.get("route_label_text", ""))).is_equal("Service Lift Departing")
	var spawn_count: int = int(diagnostics.get("unlock_feedback_spawn_count", 0))
	assert_int(spawn_count).is_equal(1)
	return spawn_count


func _find_first_child_by_class(root: Node, class_name_value: String) -> Node:
	for child: Node in root.get_children():
		if child.is_class(class_name_value):
			return child
		var nested := _find_first_child_by_class(child, class_name_value)
		if nested != null:
			return nested
	return null


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
