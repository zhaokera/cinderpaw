## Player Abilities Story 034: Factory Route arrival objective handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_ENTRY_GUARD_NAME: String = "FactoryRatMinion"
const FACTORY_DEEP_GUARD_NAME: String = "FactoryDeepGuardRatMinion"
const FACTORY_DEEP_ENDPOINT_NAME: String = "FactoryDeepRouteEndpoint"
const FACTORY_SPARK_RAT_NAME: String = "FactorySparkRat"
const FACTORY_SPARK_RAT_ENTITY_ID: int = 2102
const OBJECTIVE_CLEAR_ENTRANCE: String = "clear_factory_entrance"
const OBJECTIVE_REACH_DEEP_GUARD: String = "reach_deep_guard"
const OBJECTIVE_OPEN_DEEP_ROUTE: String = "open_deep_route_endpoint"
const OBJECTIVE_DEFEAT_SPARK_RAT: String = "defeat_spark_rat_patrol"
const OBJECTIVE_ROUTE_CLEARED: String = "factory_route_cleared"

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_factory_route_objective_progresses_from_arrival_to_spark_rat_clear() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	assert_bool(destination.has_method("get_factory_route_objective_diagnostics")).is_true()
	assert_bool(destination.has_method("is_factory_route_objective_complete")).is_true()

	var initial_objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(initial_objective.get("objective_id", ""))).is_equal(OBJECTIVE_CLEAR_ENTRANCE)
	assert_str(String(initial_objective.get("objective_text", ""))).is_equal("Clear Factory Entrance")
	assert_bool(bool(initial_objective.get("route_label_visible", false))).is_true()
	assert_str(String(initial_objective.get("route_label_text", ""))).is_equal("Clear Factory Entrance")
	assert_bool(bool(destination.call("is_factory_route_objective_complete"))).is_false()

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	await _defeat_guard(destination, FACTORY_ENTRY_GUARD_NAME, &"unit_test_entry_clear")
	var entrance_clear_objective: Dictionary = destination.call(
		"get_factory_route_objective_diagnostics"
	)
	assert_str(String(entrance_clear_objective.get("objective_id", ""))).is_equal(
		OBJECTIVE_REACH_DEEP_GUARD
	)
	assert_str(String(entrance_clear_objective.get("objective_text", ""))).is_equal("Reach Deep Guard")

	var route_diagnostics: Dictionary = destination.call("get_factory_deep_route_diagnostics")
	player.global_position.x = float(route_diagnostics.get("deep_guard_activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call("try_activate_factory_deep_guard", player))).is_true()
	await _defeat_guard(destination, FACTORY_DEEP_GUARD_NAME, &"unit_test_deep_guard_clear")
	var guard_clear_objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(guard_clear_objective.get("objective_id", ""))).is_equal(
		OBJECTIVE_OPEN_DEEP_ROUTE
	)
	assert_str(String(guard_clear_objective.get("objective_text", ""))).is_equal(
		"Open Deep Route Endpoint"
	)

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
	var active_objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(active_objective.get("objective_id", ""))).is_equal(
		OBJECTIVE_DEFEAT_SPARK_RAT
	)
	assert_str(String(active_objective.get("objective_text", ""))).is_equal("Defeat Spark Rat Patrol")

	assert_bool(destination.call("apply_damage", FACTORY_SPARK_RAT_ENTITY_ID, 999, {
		"source": &"unit_test_factory_route_objective",
	})).is_true()
	await get_tree().process_frame

	var cleared_objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(cleared_objective.get("objective_id", ""))).is_equal(OBJECTIVE_ROUTE_CLEARED)
	assert_str(String(cleared_objective.get("objective_text", ""))).is_equal("Factory Route Cleared")
	assert_bool(bool(cleared_objective.get("complete", false))).is_true()
	assert_bool(bool(destination.call("is_factory_route_objective_complete"))).is_true()
	assert_str(String(cleared_objective.get("route_label_text", ""))).is_equal(
		"Factory Route Cleared"
	)

	var local_state: Dictionary = destination.call("get_local_state")
	assert_str(String(local_state.get("factory_route_objective_id", ""))).is_equal(
		OBJECTIVE_ROUTE_CLEARED
	)


func test_factory_route_objective_restores_from_scene_local_state() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	assert_bool(destination.has_method("get_factory_route_objective_diagnostics")).is_true()

	destination.call("set_local_state", {
		"encounter_cleared": true,
		"factory_deep_guard_activated": true,
		"factory_deep_guard_defeated": true,
		"factory_deep_route_cleared": true,
		"factory_spark_rat_activated": true,
		"factory_spark_rat_defeated": true,
	})

	var objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(objective.get("objective_id", ""))).is_equal(OBJECTIVE_ROUTE_CLEARED)
	assert_bool(bool(objective.get("complete", false))).is_true()
	assert_bool(bool(objective.get("route_label_visible", false))).is_true()
	assert_str(String(objective.get("route_label_text", ""))).is_equal("Factory Route Cleared")

	var spark_rat: Node2D = destination.get_node_or_null(FACTORY_SPARK_RAT_NAME) as Node2D
	assert_that(spark_rat).is_not_null()
	if spark_rat != null:
		assert_bool(spark_rat.visible).is_false()


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
