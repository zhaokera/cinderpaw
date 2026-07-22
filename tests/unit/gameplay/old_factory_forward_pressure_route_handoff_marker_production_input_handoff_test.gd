## Story196: forward-pressure route marker production input handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"

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


func test_real_interact_lights_route_marker_once_without_chaining_ambush_or_lift(
) -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	for _frame: int in range(18):
		await get_tree().process_frame
	factory.call("set_local_state", _exit_gate_opened_state())

	var player := factory.get_node_or_null("Player") as CharacterBody2D
	var marker := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureRouteHandoffMarker"
	) as Node2D
	assert_that(player).is_not_null()
	assert_that(marker).is_not_null()
	if player == null or marker == null:
		return

	player.set_physics_process(false)
	player.global_position = Vector2(1560.0, marker.global_position.y)
	player.velocity = Vector2.ZERO
	var ready: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_route_handoff_marker_diagnostics"
	)
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("lit", true))).is_false()
	assert_int(int(ready.get("unlock_feedback_spawn_count", -1))).is_equal(0)
	var gate: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_exit_gate_diagnostics"
	)
	assert_bool(bool(gate.get("opened", false))).is_true()
	assert_bool(bool(gate.get("collision_blocking", true))).is_false()

	Input.action_press(&"interact")
	factory.call("_process", 0.0)
	for _frame: int in range(3):
		factory.call("_process", 0.0)

	var lit: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_route_handoff_marker_diagnostics"
	)
	assert_bool(bool(lit.get("lit", false))).override_failure_message(
		"Story196: a real interact rising edge must light the available route marker"
	).is_true()
	if not bool(lit.get("lit", false)):
		return
	assert_bool(bool(lit.get("available", true))).is_false()
	assert_bool(bool(lit.get("visible", false))).is_true()
	assert_str(String(lit.get("prompt_text", ""))).is_equal("Route Beacon Lit")
	assert_str(String(lit.get("route_label_text", ""))).is_equal(
		"Forward Pressure Route Beacon Lit"
	)
	assert_bool(bool(lit.get("unlock_feedback_played", false))).is_true()
	assert_int(int(lit.get("unlock_feedback_spawn_count", 0))).is_equal(1)
	assert_bool(bool(factory.call("get_local_state").get(
		"factory_lower_deck_forward_pressure_route_handoff_marker_lit",
		false
	))).is_true()

	var beacon: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_beacon_ambush_diagnostics"
	)
	assert_bool(bool(beacon.get("available", false))).is_true()
	assert_bool(bool(beacon.get("active", true))).is_false()
	assert_bool(bool(beacon.get("enemy_visible", true))).is_false()
	assert_bool(bool(beacon.get("route_marker_lit", false))).is_true()
	var lift: Dictionary = factory.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("activated", true))).is_false()
	assert_bool(bool(lift.get("exit_requested", true))).is_false()
	assert_str(String(lift.get("exit_rejected_reason", "unexpected"))).is_empty()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")

	Input.action_release(&"interact")
	factory.call("_process", 0.0)
	var released_beacon: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_beacon_ambush_diagnostics"
	)
	assert_bool(bool(released_beacon.get("active", true))).is_false()
	assert_bool(bool(released_beacon.get("enemy_visible", true))).is_false()

	player.global_position.x += 1.0
	factory.call("_process", 0.0)
	var advanced_beacon: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_beacon_ambush_diagnostics"
	)
	assert_bool(bool(advanced_beacon.get("active", false))).is_true()
	assert_bool(bool(advanced_beacon.get("enemy_visible", false))).is_true()


func _instantiate_factory_scene() -> Node:
	assert_bool(FileAccess.file_exists(FACTORY_SCENE_PATH)).is_true()
	var packed := load(FACTORY_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var factory: Node = packed.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	return factory


func _exit_gate_opened_state() -> Dictionary:
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
		"factory_checkpoint_forward_patrol_activated": true,
		"factory_checkpoint_forward_patrol_defeated": true,
		"factory_checkpoint_rear_ambush_activated": true,
		"factory_checkpoint_rear_ambush_defeated": true,
		"factory_checkpoint_overdrive_duo_activated": true,
		"factory_checkpoint_overdrive_left_defeated": true,
		"factory_checkpoint_overdrive_right_defeated": true,
		"factory_checkpoint_overdrive_duo_cleared": true,
		"factory_lower_deck_skirmish_activated": true,
		"factory_lower_deck_skirmish_defeated": true,
		"factory_lower_deck_reward_cache_claimed": true,
		"factory_lower_deck_parry_gate_unlocked": true,
		"factory_lower_deck_exit_ambush_activated": true,
		"factory_lower_deck_exit_ambush_defeated": true,
		"factory_lower_deck_shortcut_activated": true,
		"factory_lower_deck_shortcut_guard_defeated": true,
		"factory_lower_deck_shortcut_unlocked": true,
		"factory_lower_deck_shortcut_reward_cache_claimed": true,
		"factory_lower_deck_shortcut_pursuer_activated": true,
		"factory_lower_deck_shortcut_pursuer_defeated": true,
		"factory_lower_deck_pressure_guard_activated": true,
		"factory_lower_deck_pressure_guard_defeated": true,
		"factory_lower_deck_pressure_valve_opened": true,
		"factory_lower_deck_steam_sluice_activated": true,
		"factory_lower_deck_steam_sluice_defeated": true,
		"factory_lower_deck_deep_bulkhead_guard_activated": true,
		"factory_lower_deck_deep_bulkhead_guard_defeated": true,
		"factory_lower_deck_deep_bulkhead_opened": true,
		"factory_lower_deck_breach_corridor_activated": true,
		"factory_lower_deck_breach_front_guard_defeated": true,
		"factory_lower_deck_breach_rear_ambusher_activated": true,
		"factory_lower_deck_breach_rear_ambusher_defeated": true,
		"factory_lower_deck_breach_corridor_secured": true,
		"factory_lower_deck_breach_relay_activated": true,
		"factory_lower_deck_post_relay_trial_activated": true,
		"factory_lower_deck_post_relay_trial_defeated": true,
		"factory_lower_deck_relay_forward_reward_cache_claimed": true,
		"factory_lower_deck_forward_hatch_opened": true,
		"factory_lower_deck_forward_conduit_activated": true,
		"factory_lower_deck_forward_conduit_defeated": true,
		"factory_lower_deck_forward_pressure_traverse_crossed": true,
		"factory_lower_deck_forward_pressure_counter_ambush_activated": true,
		"factory_lower_deck_forward_pressure_counter_ambush_defeated": true,
		"factory_lower_deck_forward_pressure_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_exit_guard_activated": true,
		"factory_lower_deck_forward_pressure_exit_guard_defeated": true,
		"factory_lower_deck_forward_pressure_exit_relay_activated": true,
		"factory_lower_deck_forward_pressure_exit_gate_opened": true,
		"factory_lower_deck_forward_pressure_route_handoff_marker_lit": false,
		"factory_lower_deck_forward_pressure_beacon_ambush_activated": false,
		"factory_lower_deck_forward_pressure_beacon_ambush_defeated": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
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
