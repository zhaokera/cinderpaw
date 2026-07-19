## Scene Management Story 024: Factory entry-route real-input loop.
extends GdUnitTestSuite

const FACTORY_SCENE: PackedScene = preload(
	"res://scenes/factory_route_transition_shell.tscn"
)
const CACHE_NAME: String = "FactoryCombatCache"
const DEEP_GUARD_NAME: String = "FactoryDeepGuardRatMinion"
const DEEP_ENDPOINT_NAME: String = "FactoryDeepRouteEndpoint"
const DEEP_GATE_NAME: String = "FactoryDeepRouteGate"
const SPARK_RAT_NAME: String = "FactorySparkRat"

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


func test_optional_upper_cache_uses_real_interact_before_deep_guard_commit() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("handle_factory_interact_input")).is_true()
	if not destination.has_method("handle_factory_interact_input"):
		return
	destination.call("set_local_state", {
		"encounter_cleared": true,
		"factory_cache_claimed": false,
	})

	var player := destination.get_node("Player") as CharacterBody2D
	var cache := destination.get_node(CACHE_NAME) as Node2D
	var route: Dictionary = destination.call("get_factory_deep_route_diagnostics")
	var commit_x: float = float(route.get("deep_guard_activation_x", 0.0))
	assert_float(cache.global_position.x).is_less(commit_x)
	assert_bool(bool(route.get("deep_guard_activated", true))).is_false()

	player.global_position = cache.global_position
	await _press_interact_for_frame(destination)

	var room: Dictionary = destination.call("get_factory_room_clear_diagnostics")
	assert_bool(bool(room.get("cache_claimed", false))).is_true()
	assert_int(int(Dictionary(room.get("last_cache_reward", {})).get("gears", 0))).is_equal(10)
	await _press_interact_for_frame(destination)
	room = destination.call("get_factory_room_clear_diagnostics")
	assert_bool(bool(room.get("cache_claim_available", true))).is_false()
	assert_int(int(Dictionary(room.get("last_cache_reward", {})).get("gears", 0))).is_equal(10)
	assert_bool(bool(destination.call("is_factory_deep_guard_activated"))).is_false()


func test_ground_route_skips_cache_and_real_input_opens_gate_before_spark_rat() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("handle_factory_interact_input")).is_true()
	if not destination.has_method("handle_factory_interact_input"):
		return
	destination.call("set_local_state", {
		"encounter_cleared": true,
		"factory_cache_claimed": false,
	})

	var player := destination.get_node("Player") as CharacterBody2D
	var guard: Node = destination.get_node(DEEP_GUARD_NAME)
	var endpoint := destination.get_node(DEEP_ENDPOINT_NAME) as Node2D
	var gate := destination.get_node_or_null(DEEP_GATE_NAME) as Node2D
	var spark_rat := destination.get_node(SPARK_RAT_NAME) as Node2D
	assert_that(gate).is_not_null()
	if gate == null:
		return

	var route: Dictionary = destination.call("get_factory_deep_route_diagnostics")
	var commit_x: float = float(route.get("deep_guard_activation_x", 0.0))
	assert_float(guard.global_position.x).is_greater(commit_x)
	assert_float(endpoint.global_position.x).is_greater(guard.global_position.x)
	assert_float(gate.global_position.x).is_greater(endpoint.global_position.x)
	assert_float(spark_rat.global_position.x).is_greater(gate.global_position.x)
	assert_bool(bool(route.get("route_gate_blocking", false))).is_true()

	player.global_position.x = commit_x + 1.0
	await get_tree().process_frame
	assert_bool(bool(destination.call("is_factory_deep_guard_activated"))).is_true()
	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get("factory_cache_claimed", true))).is_false()

	guard.call("kill_summon", &"story_024_deep_guard_clear")
	await get_tree().process_frame
	player.global_position = endpoint.global_position
	await _press_interact_for_frame(destination)

	route = destination.call("get_factory_deep_route_diagnostics")
	assert_bool(bool(route.get("deep_route_cleared", false))).is_true()
	assert_bool(bool(route.get("route_gate_blocking", true))).is_false()
	assert_bool(gate.visible).is_false()

	var spark: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	player.global_position.x = float(spark.get("activation_x", 0.0)) + 1.0
	await get_tree().process_frame
	spark = destination.call("get_factory_spark_rat_diagnostics")
	assert_bool(bool(spark.get("active", false))).is_true()


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
