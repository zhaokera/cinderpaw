## Stories 058-060 regression: production interact handoff through Lower Deck progression.
extends GdUnitTestSuite

const FACTORY_SCENE: PackedScene = preload(
	"res://scenes/factory_route_transition_shell.tscn"
)
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_STEAM_SLUICE_ENTITY_ID: int = 2113
const FACTORY_DEEP_BULKHEAD_ENTITY_ID: int = 2114

var _spawned_nodes: Array[Node] = []


func before_test() -> void:
	Input.action_release(&"interact")


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


func test_real_interact_rising_edges_advance_valve_sluice_and_bulkhead_chain() -> void:
	var destination: Node = _instantiate_factory_scene()
	destination.call("set_local_state", _pressure_valve_ready_state())
	var player := destination.get_node(FACTORY_PLAYER_NAME) as CharacterBody2D

	var pressure: Dictionary = destination.call(
		"get_factory_lower_deck_pressure_valve_diagnostics"
	)
	player.global_position = pressure.get("valve_position", Vector2.ZERO) as Vector2
	_press_interact(destination)
	pressure = destination.call("get_factory_lower_deck_pressure_valve_diagnostics")
	assert_bool(bool(pressure.get("valve_opened", false))).is_true()

	var sluice: Dictionary = destination.call(
		"get_factory_lower_deck_steam_sluice_diagnostics"
	)
	player.global_position.x = float(sluice.get("activation_x", 0.0))
	destination.call("_process", 0.0)
	sluice = destination.call("get_factory_lower_deck_steam_sluice_diagnostics")
	assert_bool(bool(sluice.get("active", true))).is_false()

	_release_interact(destination)
	_press_interact(destination)
	sluice = destination.call("get_factory_lower_deck_steam_sluice_diagnostics")
	assert_bool(bool(sluice.get("active", false))).is_true()
	assert_bool(destination.call(
		"apply_damage",
		FACTORY_STEAM_SLUICE_ENTITY_ID,
		999,
		{"source": &"unit_test_production_interact_handoff"}
	)).is_true()
	_release_interact(destination)
	await get_tree().process_frame

	var bulkhead: Dictionary = destination.call(
		"get_factory_lower_deck_deep_bulkhead_diagnostics"
	)
	player.global_position.x = float(bulkhead.get("activation_x", 0.0))
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_deep_bulkhead_guard",
		player
	))).is_true()
	assert_bool(destination.call(
		"apply_damage",
		FACTORY_DEEP_BULKHEAD_ENTITY_ID,
		999,
		{"source": &"unit_test_production_interact_handoff"}
	)).is_true()
	await get_tree().process_frame

	bulkhead = destination.call("get_factory_lower_deck_deep_bulkhead_diagnostics")
	player.global_position = bulkhead.get("bulkhead_position", Vector2.ZERO) as Vector2
	_press_interact(destination)
	bulkhead = destination.call("get_factory_lower_deck_deep_bulkhead_diagnostics")
	assert_bool(bool(bulkhead.get("bulkhead_opened", false))).is_true()

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_pressure_valve_opened",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_steam_sluice_defeated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_deep_bulkhead_opened",
		false
	))).is_true()


func test_overlapping_ready_endpoints_choose_nearest_once_per_rising_edge() -> void:
	var destination: Node = _instantiate_factory_scene()
	destination.call("set_local_state", _overlapping_endpoint_ready_state())
	var player := destination.get_node(FACTORY_PLAYER_NAME) as CharacterBody2D
	var pressure: Dictionary = destination.call(
		"get_factory_lower_deck_pressure_valve_diagnostics"
	)
	var bulkhead: Dictionary = destination.call(
		"get_factory_lower_deck_deep_bulkhead_diagnostics"
	)
	player.global_position = bulkhead.get("bulkhead_position", Vector2.ZERO) as Vector2
	assert_float(player.global_position.distance_to(
		bulkhead.get("bulkhead_position", Vector2.ZERO) as Vector2
	)).is_less(
		player.global_position.distance_to(
			pressure.get("valve_position", Vector2.ZERO) as Vector2
		)
	)

	_press_interact(destination)
	pressure = destination.call("get_factory_lower_deck_pressure_valve_diagnostics")
	bulkhead = destination.call("get_factory_lower_deck_deep_bulkhead_diagnostics")
	assert_bool(bool(bulkhead.get("bulkhead_opened", false))).is_true()
	assert_bool(bool(pressure.get("valve_opened", true))).is_false()

	player.global_position = pressure.get("valve_position", Vector2.ZERO) as Vector2
	destination.call("_process", 0.0)
	pressure = destination.call("get_factory_lower_deck_pressure_valve_diagnostics")
	assert_bool(bool(pressure.get("valve_opened", true))).is_false()

	_release_interact(destination)
	_press_interact(destination)
	pressure = destination.call("get_factory_lower_deck_pressure_valve_diagnostics")
	assert_bool(bool(pressure.get("valve_opened", false))).is_true()


func _instantiate_factory_scene() -> Node:
	var destination: Node = FACTORY_SCENE.instantiate()
	add_child(destination)
	_spawned_nodes.append(destination)
	return destination


func _press_interact(destination: Node) -> void:
	Input.action_press(&"interact")
	destination.call("_process", 0.0)


func _release_interact(destination: Node) -> void:
	Input.action_release(&"interact")
	destination.call("_process", 0.0)


func _pressure_valve_ready_state() -> Dictionary:
	return _completed_route_state().merged({
		"factory_lower_deck_pressure_guard_activated": true,
		"factory_lower_deck_pressure_guard_defeated": true,
		"factory_lower_deck_pressure_valve_opened": false,
		"factory_lower_deck_steam_sluice_activated": false,
		"factory_lower_deck_steam_sluice_defeated": false,
		"factory_lower_deck_deep_bulkhead_guard_activated": false,
		"factory_lower_deck_deep_bulkhead_guard_defeated": false,
		"factory_lower_deck_deep_bulkhead_opened": false,
	}, true)


func _overlapping_endpoint_ready_state() -> Dictionary:
	return _completed_route_state().merged({
		"factory_lower_deck_pressure_guard_activated": true,
		"factory_lower_deck_pressure_guard_defeated": true,
		"factory_lower_deck_pressure_valve_opened": false,
		"factory_lower_deck_steam_sluice_activated": true,
		"factory_lower_deck_steam_sluice_defeated": true,
		"factory_lower_deck_deep_bulkhead_guard_activated": true,
		"factory_lower_deck_deep_bulkhead_guard_defeated": true,
		"factory_lower_deck_deep_bulkhead_opened": false,
	}, true)


func _completed_route_state() -> Dictionary:
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
		"factory_checkpoint_overdrive_duo_activated": true,
		"factory_checkpoint_overdrive_left_defeated": true,
		"factory_checkpoint_overdrive_right_defeated": true,
		"factory_checkpoint_overdrive_duo_cleared": true,
		"factory_checkpoint_overdrive_reward_cache_claimed": true,
		"factory_lower_deck_skirmish_activated": true,
		"factory_lower_deck_skirmish_defeated": true,
		"factory_lower_deck_reward_cache_claimed": true,
		"factory_lower_deck_shortcut_activated": true,
		"factory_lower_deck_shortcut_guard_defeated": true,
		"factory_lower_deck_shortcut_unlocked": true,
		"factory_lower_deck_shortcut_reward_cache_claimed": true,
		"factory_lower_deck_shortcut_pursuer_activated": true,
		"factory_lower_deck_shortcut_pursuer_defeated": true,
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
