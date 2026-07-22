## Story234: production pincer-exit input and spillway waiting handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const INTERACT_ACTION: StringName = &"interact"
const PINCER_EXIT_HATCH: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerExitHatch"
)
const PINCER_EXIT_SPILLWAY_DUCT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerExitSpillwayDuct"
)
const HATCH_DIAGNOSTICS: String = (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_diagnostics"
)
const SPILLWAY_DIAGNOSTICS: String = (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
)
const HATCH_OPEN_METHOD: String = (
	"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch"
)

var _spawned_nodes: Array[Node] = []


func before_test() -> void:
	Input.action_release(INTERACT_ACTION)
	get_tree().paused = false


func after_test() -> void:
	Input.action_release(INTERACT_ACTION)
	get_tree().paused = false
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_stale_interact_then_fresh_interact_opens_pincer_exit_once_and_leaves_spillway_waiting(
) -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.set_process(false)
	factory.call("set_local_state", _pincer_exit_hatch_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var hatch := factory.get_node_or_null(PINCER_EXIT_HATCH) as Node2D
	var visual := hatch.get_node_or_null("Visual") as Sprite2D if hatch != null else null
	var prompt := hatch.get_node_or_null("PromptLabel") as Label if hatch != null else null
	var duct := factory.get_node_or_null(PINCER_EXIT_SPILLWAY_DUCT) as Sprite2D
	assert_that(player).is_not_null()
	assert_that(hatch).is_not_null()
	assert_that(visual).is_not_null()
	assert_that(prompt).is_not_null()
	assert_that(duct).is_not_null()
	if player == null or hatch == null or visual == null or prompt == null or duct == null:
		return

	player.set_physics_process(false)
	player.global_position = hatch.global_position + Vector2(-160.0, 64.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	var ready_hatch: Dictionary = factory.call(HATCH_DIAGNOSTICS)
	var locked_spillway: Dictionary = factory.call(SPILLWAY_DIAGNOSTICS)
	assert_bool(bool(ready_hatch.get("available", false))).is_true()
	assert_bool(bool(ready_hatch.get("opened", true))).is_false()
	assert_bool(bool(ready_hatch.get("collision_blocking", false))).is_true()
	assert_int(int(ready_hatch.get("unlock_feedback_spawn_count", -1))).is_equal(0)
	assert_bool(bool(locked_spillway.get("available", true))).is_false()
	assert_bool(bool(locked_spillway.get("visible", true))).is_false()
	assert_vector(visual.position).is_equal(Vector2.ZERO)

	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	player.global_position = hatch.global_position + Vector2(0.0, 64.0)
	factory.call("_process", 0.0)
	var stale_hatch: Dictionary = factory.call(HATCH_DIAGNOSTICS)
	assert_bool(bool(hatch.call("is_provider_in_activation_range", player))).is_true()
	assert_bool(bool(stale_hatch.get("opened", true))).override_failure_message(
		"Holding interact before entering Story123 range must not open the hatch"
	).is_false()
	assert_int(int(stale_hatch.get("unlock_feedback_spawn_count", -1))).is_equal(0)

	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	factory.call("_process", 0.0)
	stale_hatch = factory.call(HATCH_DIAGNOSTICS)
	assert_bool(bool(stale_hatch.get("opened", true))).override_failure_message(
		"No-input placement inside Story123 range must leave the hatch closed"
	).is_false()

	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	var opened_hatch: Dictionary = factory.call(HATCH_DIAGNOSTICS)
	var opened: bool = bool(opened_hatch.get("opened", false))
	assert_bool(opened).override_failure_message(
		"Story234 requires fresh production Input.interact to open Story123"
	).is_true()

	# Preserve downstream visual assertions while the missing router is RED.
	if not opened:
		Input.action_release(INTERACT_ACTION)
		factory.call("_process", 0.0)
		assert_bool(bool(factory.call(HATCH_OPEN_METHOD, player))).is_true()
		opened_hatch = factory.call(HATCH_DIAGNOSTICS)

	var ready_spillway: Dictionary = factory.call(SPILLWAY_DIAGNOSTICS)
	assert_bool(bool(opened_hatch.get("available", true))).is_false()
	assert_bool(bool(opened_hatch.get("interaction_monitoring", true))).is_false()
	assert_bool(bool(opened_hatch.get("interaction_monitorable", true))).is_false()
	assert_bool(bool(opened_hatch.get("collision_blocking", true))).is_false()
	assert_str(String(opened_hatch.get("prompt_text", ""))).is_equal(
		"Tailrace Exit Open"
	)
	assert_str(String(opened_hatch.get("route_label_text", ""))).is_equal(
		"Tailrace Runoff Exit Opened"
	)
	assert_bool(bool(opened_hatch.get("unlock_feedback_active", false))).override_failure_message(
		"Story123 diagnostics must report the active one-shot unlock feedback"
	).is_true()
	assert_float(visual.position.y).override_failure_message(
		"The opened tailrace exit must lift clear of the spillway route"
	).is_less_equal(-120.0)
	assert_float(absf(rad_to_deg(visual.rotation))).is_greater_equal(6.0)
	assert_int(hatch.z_index + visual.z_index).is_greater(duct.z_index)
	assert_int(hatch.z_index + visual.z_index).is_less(player.z_index)
	assert_bool(prompt.visible).is_false()
	var unlock_vfx: Dictionary = hatch.call("get_unlock_vfx_snapshot")
	assert_int(int(unlock_vfx.get("spawn_count", 0))).is_equal(1)

	assert_bool(bool(ready_spillway.get("present", false))).is_true()
	assert_bool(bool(ready_spillway.get("available", false))).is_true()
	assert_bool(bool(ready_spillway.get("visible", false))).is_true()
	assert_bool(bool(ready_spillway.get("hazard_visible", false))).is_true()
	assert_bool(bool(ready_spillway.get("active", true))).override_failure_message(
		"Opening Story123 must leave Story124 waiting at the hatch"
	).is_false()
	assert_bool(bool(ready_spillway.get("crossed", true))).is_false()
	assert_str(String(ready_spillway.get("phase", ""))).is_equal("idle")
	assert_bool(bool(ready_spillway.get("hazard_contact_active", true))).is_false()

	for _frame: int in range(4):
		factory.call("_process", 0.0)
	ready_spillway = factory.call(SPILLWAY_DIAGNOSTICS)
	assert_bool(bool(ready_spillway.get("active", true))).override_failure_message(
		"Held hatch-open input and stationary frames must leave Story124 waiting"
	).is_false()

	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	player.global_position = Vector2(
		float(ready_spillway.get("activation_x", 0.0)) + 4.0,
		410.0
	)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	ready_spillway = factory.call(SPILLWAY_DIAGNOSTICS)
	assert_bool(bool(ready_spillway.get("active", true))).override_failure_message(
		"No-input placement beyond Story124 activation x must remain waiting"
	).is_false()

	player.global_position = Vector2(
		float(ready_spillway.get("exit_x", 0.0)) + 4.0,
		410.0
	)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	ready_spillway = factory.call(SPILLWAY_DIAGNOSTICS)
	assert_bool(bool(ready_spillway.get("active", true))).is_false()
	assert_bool(bool(ready_spillway.get("crossed", true))).override_failure_message(
		"No-input placement beyond Story124 exit x must not complete traversal"
	).is_false()

	player.global_position = hatch.global_position + Vector2(0.0, 64.0)
	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	unlock_vfx = hatch.call("get_unlock_vfx_snapshot")
	assert_int(int(unlock_vfx.get("spawn_count", 0))).override_failure_message(
		"Repeated fresh interact must not replay Story123 unlock feedback"
	).is_equal(1)
	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)

	var local_state: Dictionary = factory.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_activated",
		true
	))).is_false()


func _pincer_exit_hatch_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_crossed": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
	}


func _wait_process_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().process_frame


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
