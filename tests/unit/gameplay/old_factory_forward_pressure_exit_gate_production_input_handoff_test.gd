## Story195: forward-pressure exit gate production input handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const EXIT_RELAY_SAVEPOINT_ID: String = (
	"old_factory_lower_deck_forward_pressure_exit_relay"
)
const FACTORY_SCENE_ID: String = "area_03_factory"
const EXIT_RELAY_SPAWN_POINT: String = "lower_deck_forward_pressure_exit_relay"

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


func test_real_interact_opens_gate_without_chaining_marker_or_lift() -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	for _frame: int in range(18):
		await get_tree().process_frame
	factory.call("set_local_state", _exit_relay_secured_state())

	var player := factory.get_node_or_null("Player") as CharacterBody2D
	var gate := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureExitGate"
	) as Node2D
	var marker := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureRouteHandoffMarker"
	) as Node2D
	assert_that(player).is_not_null()
	assert_that(gate).is_not_null()
	assert_that(marker).is_not_null()
	if player == null or gate == null or marker == null:
		return
	var gate_prompt := gate.get_node_or_null("PromptLabel") as Label
	var marker_prompt := marker.get_node_or_null("PromptLabel") as Label
	assert_that(gate_prompt).is_not_null()
	assert_that(marker_prompt).is_not_null()
	if gate_prompt == null or marker_prompt == null:
		return

	player.set_physics_process(false)
	player.global_position = gate.global_position
	player.velocity = Vector2.ZERO
	var ready: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_exit_gate_diagnostics"
	)
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("opened", true))).is_false()
	assert_bool(bool(ready.get("collision_blocking", false))).is_true()
	assert_str(String(ready.get("prompt_text", ""))).is_equal("Open Exit Gate")
	assert_bool(gate_prompt.visible).is_true()
	var locked_marker: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_route_handoff_marker_diagnostics"
	)
	assert_bool(bool(locked_marker.get("available", true))).is_false()
	assert_bool(bool(locked_marker.get("visible", true))).is_false()
	assert_bool(bool(locked_marker.get("lit", true))).is_false()

	Input.action_press(&"interact")
	factory.call("_process", 0.0)
	for _frame: int in range(3):
		factory.call("_process", 0.0)

	var opened: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_exit_gate_diagnostics"
	)
	assert_bool(bool(opened.get("opened", false))).override_failure_message(
		"Story195: a real interact rising edge must open the available exit gate"
	).is_true()
	if not bool(opened.get("opened", false)):
		return
	assert_bool(bool(opened.get("available", true))).is_false()
	assert_bool(bool(opened.get("visible", false))).is_true()
	assert_bool(bool(opened.get("collision_blocking", true))).is_false()
	assert_str(String(opened.get("prompt_text", ""))).is_equal("Exit Gate Open")
	assert_str(String(opened.get("route_label_text", ""))).is_equal(
		"Forward Pressure Exit Gate Opened"
	)
	assert_bool(gate_prompt.visible).override_failure_message(
		"Story195: the opened gate prompt must hide before the marker prompt appears"
	).is_false()
	var gate_vfx: Dictionary = gate.call("get_unlock_vfx_snapshot")
	assert_bool(bool(gate_vfx.get("played", false))).is_true()
	assert_int(int(gate_vfx.get("spawn_count", 0))).is_equal(1)
	assert_bool(bool(factory.call("get_local_state").get(
		"factory_lower_deck_forward_pressure_exit_gate_opened",
		false
	))).is_true()

	var available_marker: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_route_handoff_marker_diagnostics"
	)
	assert_bool(bool(available_marker.get("available", false))).is_true()
	assert_bool(bool(available_marker.get("visible", false))).is_true()
	assert_bool(bool(available_marker.get("lit", true))).is_false()
	assert_str(String(available_marker.get("prompt_text", ""))).is_equal(
		"Light Route Beacon"
	)
	assert_int(int(available_marker.get("unlock_feedback_spawn_count", -1))).is_equal(0)
	assert_bool(marker_prompt.visible).is_true()

	var beacon: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_beacon_ambush_diagnostics"
	)
	assert_bool(bool(beacon.get("available", true))).is_false()
	assert_bool(bool(beacon.get("active", true))).is_false()
	assert_bool(bool(beacon.get("route_marker_lit", true))).is_false()
	assert_bool(bool(beacon.get("enemy_visible", true))).is_false()
	var lift: Dictionary = factory.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("activated", true))).is_false()
	assert_bool(bool(lift.get("exit_requested", true))).is_false()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")
	var relay: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
	)
	assert_bool(bool(relay.get("activated", false))).is_true()
	var last_savepoint: Dictionary = relay.get("last_savepoint", {}) as Dictionary
	assert_str(String(last_savepoint.get("id", ""))).is_equal(EXIT_RELAY_SAVEPOINT_ID)
	assert_str(String(last_savepoint.get("scene_id", ""))).is_equal(FACTORY_SCENE_ID)
	assert_str(String(last_savepoint.get("spawn_point", ""))).is_equal(
		EXIT_RELAY_SPAWN_POINT
	)

	Input.action_release(&"interact")
	factory.call("_process", 0.0)


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


func _exit_relay_secured_state() -> Dictionary:
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
		"factory_lower_deck_forward_pressure_exit_gate_opened": false,
		"factory_lower_deck_forward_pressure_route_handoff_marker_lit": false,
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
