## Story227: production exit-hatch input and service-sluice tailrace handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const INTERACT_ACTION: StringName = &"interact"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const SERVICE_EXIT_HATCH: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceExitHatch"
)
const TAILRACE_DUCT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceDuct"
)

var _spawned_nodes: Array[Node] = []


func before_test() -> void:
	_release_gameplay_actions()
	get_tree().paused = false


func after_test() -> void:
	_release_gameplay_actions()
	get_tree().paused = false
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_stale_interact_then_fresh_interact_opens_exit_once_and_leaves_tailrace_waiting(
) -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.set_process(false)
	factory.call("set_local_state", _service_exit_hatch_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var hatch := factory.get_node_or_null(SERVICE_EXIT_HATCH) as Node2D
	var hatch_visual := hatch.get_node_or_null("Visual") as Sprite2D if hatch != null else null
	var hatch_prompt := hatch.get_node_or_null("PromptLabel") as Label if hatch != null else null
	var duct := factory.get_node_or_null(TAILRACE_DUCT) as Sprite2D
	assert_that(player).is_not_null()
	assert_that(hatch).is_not_null()
	assert_that(hatch_visual).is_not_null()
	assert_that(hatch_prompt).is_not_null()
	assert_that(duct).is_not_null()
	if (
		player == null
		or hatch == null
		or hatch_visual == null
		or hatch_prompt == null
		or duct == null
	):
		return

	player.set_physics_process(false)
	player.global_position = Vector2(hatch.global_position.x - 160.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	var ready_hatch: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics"
	)
	var locked_tailrace: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	)
	assert_bool(bool(ready_hatch.get("available", false))).is_true()
	assert_bool(bool(ready_hatch.get("opened", true))).is_false()
	assert_bool(bool(ready_hatch.get("collision_blocking", false))).is_true()
	assert_int(int(ready_hatch.get("unlock_feedback_spawn_count", -1))).is_equal(0)
	assert_bool(bool(locked_tailrace.get("available", true))).is_false()
	assert_bool(bool(locked_tailrace.get("visible", true))).is_false()
	assert_vector(hatch_visual.position).is_equal(Vector2.ZERO)

	# An interaction armed outside the radius must stay stale after entering it.
	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	player.global_position = Vector2(hatch.global_position.x, 456.0)
	factory.call("_process", 0.0)
	var stale_hatch: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics"
	)
	assert_bool(bool(hatch.call("is_provider_in_activation_range", player))).is_true()
	assert_bool(bool(stale_hatch.get("opened", true))).override_failure_message(
		"Holding interact before entering Story116 range must not open the hatch"
	).is_false()
	assert_int(int(stale_hatch.get("unlock_feedback_spawn_count", -1))).is_equal(0)

	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	factory.call("_process", 0.0)
	stale_hatch = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics"
	)
	assert_bool(bool(stale_hatch.get("opened", true))).override_failure_message(
		"No-input placement inside Story116 range must leave the hatch closed"
	).is_false()

	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	var opened_hatch: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics"
	)
	var opened: bool = bool(opened_hatch.get("opened", false))
	assert_bool(opened).override_failure_message(
		"Story227 requires fresh production Input.interact to open Story116"
	).is_true()

	# Keep the visual and downstream contract visible when the router is the RED.
	if not opened:
		Input.action_release(INTERACT_ACTION)
		factory.call("_process", 0.0)
		assert_bool(bool(factory.call(
			"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch",
			player
		))).is_true()
		opened_hatch = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics"
		)

	var ready_tailrace: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	)
	assert_bool(bool(opened_hatch.get("available", true))).is_false()
	assert_bool(bool(opened_hatch.get("collision_blocking", true))).is_false()
	assert_str(String(opened_hatch.get("prompt_text", ""))).is_equal(
		"Service Exit Open"
	)
	assert_str(String(opened_hatch.get("route_label_text", ""))).is_equal(
		"Service Sluice Exit Opened"
	)
	assert_float(hatch_visual.position.y).override_failure_message(
		"The opened service exit must lift clear of the tailrace route"
	).is_less_equal(-120.0)
	assert_float(absf(rad_to_deg(hatch_visual.rotation))).is_greater_equal(6.0)
	assert_int(hatch.z_index + hatch_visual.z_index).is_greater(duct.z_index)
	assert_int(hatch.z_index + hatch_visual.z_index).is_less(player.z_index)
	assert_bool(hatch_prompt.visible).is_false()
	var unlock_vfx: Dictionary = hatch.call("get_unlock_vfx_snapshot")
	assert_int(int(unlock_vfx.get("spawn_count", 0))).is_equal(1)

	assert_bool(bool(ready_tailrace.get("present", false))).is_true()
	assert_bool(bool(ready_tailrace.get("available", false))).is_true()
	assert_bool(bool(ready_tailrace.get("visible", false))).is_true()
	assert_bool(bool(ready_tailrace.get("hazard_visible", false))).is_true()
	assert_bool(bool(ready_tailrace.get("active", true))).override_failure_message(
		"Opening Story116 must not activate Story117 in the same frame"
	).is_false()
	assert_bool(bool(ready_tailrace.get("crossed", true))).is_false()
	assert_bool(bool(ready_tailrace.get("hazard_contact_active", true))).is_false()

	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	unlock_vfx = hatch.call("get_unlock_vfx_snapshot")
	assert_int(int(unlock_vfx.get("spawn_count", 0))).override_failure_message(
		"Repeated fresh interact must not replay Story116 unlock feedback"
	).is_equal(1)
	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)

	for _frame: int in range(3):
		factory.call("_process", 0.0)
	ready_tailrace = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	)
	assert_bool(bool(ready_tailrace.get("active", true))).override_failure_message(
		"Stationary frames after opening must leave Story117 inactive"
	).is_false()

	player.global_position = Vector2(
		float(ready_tailrace.get("activation_x", 0.0)) + 4.0,
		456.0
	)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	ready_tailrace = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	)
	assert_bool(bool(ready_tailrace.get("active", true))).override_failure_message(
		"No-input displacement beyond x=12020 must leave Story117 inactive"
	).is_false()

	var local_state: Dictionary = factory.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_opened",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_activated",
		true
	))).is_false()


func _service_exit_hatch_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_opened": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_crossed": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
	}


func _wait_process_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().process_frame


func _release_gameplay_actions() -> void:
	Input.action_release(INTERACT_ACTION)
	Input.action_release(MOVE_RIGHT_ACTION)


func _stop_runtime_audio_players() -> void:
	for audio_player: AudioStreamPlayer in _find_nodes_of_type(
		get_tree().root,
		AudioStreamPlayer
	):
		audio_player.stop()
	for audio_player_2d: AudioStreamPlayer2D in _find_nodes_of_type(
		get_tree().root,
		AudioStreamPlayer2D
	):
		audio_player_2d.stop()


func _find_nodes_of_type(root: Node, expected_type: Variant) -> Array[Node]:
	var matches: Array[Node] = []
	if is_instance_of(root, expected_type):
		matches.append(root)
	for child: Node in root.get_children():
		matches.append_array(_find_nodes_of_type(child, expected_type))
	return matches
