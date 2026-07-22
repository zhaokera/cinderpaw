## Story222: production runoff-exit gate input and runoff-outlet hazard handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const INTERACT_ACTION: StringName = &"interact"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const RUNOFF_EXIT_GATE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffExitGate"
)
const RUNOFF_OUTLET_DUCT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletDuct"
)
const RUNOFF_OUTLET_VENT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletSteamVent"
)
const RUNOFF_OUTLET_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet"
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


func test_fresh_interact_opens_gate_then_real_move_crosses_live_runoff_outlet(
) -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.set_process(false)
	factory.call("set_local_state", _runoff_exit_gate_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var gate := factory.get_node_or_null(RUNOFF_EXIT_GATE) as Node2D
	var gate_visual := gate.get_node_or_null("Visual") as Sprite2D if gate != null else null
	var gate_prompt := gate.get_node_or_null("PromptLabel") as Label if gate != null else null
	var duct_visual := factory.get_node_or_null(RUNOFF_OUTLET_DUCT) as Sprite2D
	var vent := factory.get_node_or_null(RUNOFF_OUTLET_VENT) as Area2D
	assert_that(player).is_not_null()
	assert_that(gate).is_not_null()
	assert_that(gate_visual).is_not_null()
	assert_that(gate_prompt).is_not_null()
	assert_that(duct_visual).is_not_null()
	assert_that(vent).is_not_null()
	if (
		player == null
		or gate == null
		or gate_visual == null
		or gate_prompt == null
		or duct_visual == null
		or vent == null
	):
		return

	player.global_position = Vector2(7980.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	var ready: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_diagnostics"
	)
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("opened", true))).is_false()
	assert_bool(bool(ready.get("collision_blocking", false))).is_true()
	assert_vector(gate_visual.position).is_equal(Vector2.ZERO)

	# Input armed outside the radius must stay stale after entering range.
	Input.action_press(INTERACT_ACTION)
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(20):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	player.global_position = gate.global_position
	factory.call("_process", 0.0)
	var held_approach: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_diagnostics"
	)
	assert_bool(bool(gate.call("is_provider_in_activation_range", player))).is_true()
	assert_bool(bool(held_approach.get("opened", true))).override_failure_message(
		"Holding interact before entering range must not open the runoff-exit gate"
	).is_false()

	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	var opened: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_diagnostics"
	)
	assert_bool(bool(opened.get("opened", false))).override_failure_message(
		"Story222 requires production Input.interact to open the Story109 gate"
	).is_true()

	# Keep later assertions independent when this RED fails at the production router.
	if not bool(opened.get("opened", false)):
		Input.action_release(INTERACT_ACTION)
		factory.call("_process", 0.0)
		assert_bool(bool(factory.call(
			"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate",
			player
		))).is_true()
		opened = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_diagnostics"
		)

	var outlet: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
	)
	assert_bool(bool(opened.get("available", true))).is_false()
	assert_bool(bool(opened.get("collision_blocking", true))).is_false()
	assert_float(gate_visual.position.y).override_failure_message(
		"The opened runoff-exit gate must lift clear of the route"
	).is_less_equal(-120.0)
	assert_float(absf(rad_to_deg(gate_visual.rotation))).is_greater_equal(6.0)
	assert_int(gate.z_index + gate_visual.z_index).is_greater(duct_visual.z_index)
	assert_int(gate.z_index + gate_visual.z_index).is_less(player.z_index)
	assert_bool(gate_prompt.visible).is_false()
	var unlock_vfx: Dictionary = gate.call("get_unlock_vfx_snapshot")
	assert_int(int(unlock_vfx.get("spawn_count", 0))).is_equal(1)
	assert_bool(bool(outlet.get("available", false))).is_true()
	assert_bool(bool(outlet.get("visible", false))).is_true()
	assert_bool(bool(outlet.get("active", true))).override_failure_message(
		"Opening Story109 must not activate Story110 in the same frame"
	).is_false()

	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	unlock_vfx = gate.call("get_unlock_vfx_snapshot")
	assert_int(int(unlock_vfx.get("spawn_count", 0))).override_failure_message(
		"Repeated fresh interact must not replay gate unlock feedback"
	).is_equal(1)

	for _frame: int in range(3):
		factory.call("_process", 0.0)
	outlet = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
	)
	assert_bool(bool(outlet.get("active", true))).override_failure_message(
		"Stationary frames after opening must not start Story110"
	).is_false()

	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	player.set_physics_process(false)
	player.global_position = Vector2(float(outlet.get("activation_x", 0.0)) + 4.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	outlet = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
	)
	assert_bool(bool(outlet.get("active", true))).override_failure_message(
		"No-input displacement beyond x=8480 must not start Story110"
	).is_false()

	# Re-arm the traversal so the movement proof remains independent from the RED above.
	if bool(outlet.get("active", false)):
		factory.call("set_local_state", _runoff_outlet_ready_state())
		outlet = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
		)
	player.global_position = Vector2(float(outlet.get("activation_x", 0.0)) - 6.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	player.set_physics_process(true)
	var activation_start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(16):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
		outlet = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
		)
		if bool(outlet.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	assert_float(player.global_position.x).is_greater(activation_start_x)
	assert_bool(bool(outlet.get("active", false))).override_failure_message(
		"Fresh production move_right must start the Story110 runoff outlet"
	).is_true()
	assert_str(String(outlet.get("phase", ""))).is_equal("grace")
	assert_str(String(outlet.get("route_label_text", ""))).is_equal(
		"Cross Overflow Pump Runoff Outlet"
	)

	var hp_before: int = player.get_current_hp()
	factory.call("_process", 0.32)
	var warning: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
	)
	assert_str(String(warning.get("phase", ""))).is_equal("warning")
	assert_bool(bool(warning.get("hazard_contact_active", true))).is_false()
	factory.call("_process", 0.36)
	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
	)
	assert_str(String(active.get("phase", ""))).is_equal("active")
	assert_bool(bool(active.get("hazard_contact_active", false))).is_true()
	assert_bool(bool(factory.call("apply_factory_steam_vent_contact", vent, player))).is_true()
	assert_int(player.get_current_hp()).is_equal(hp_before - 8)
	var last_damage: Dictionary = factory.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	assert_str(String(last_damage.get("source", ""))).is_equal(RUNOFF_OUTLET_HAZARD_ID)
	factory.call("_process", 0.45)
	var safe: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
	)
	assert_str(String(safe.get("phase", ""))).is_equal("safe")
	assert_bool(bool(safe.get("hazard_contact_active", true))).is_false()

	var skirmish_before: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_diagnostics"
	)
	var skirmish_activation_x: float = float(skirmish_before.get("activation_x", 0.0))
	player.global_position = Vector2(skirmish_activation_x - 6.0, 456.0)
	player.velocity = Vector2.ZERO
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(8):
		await get_tree().physics_frame
		if player.global_position.x >= skirmish_activation_x:
			break
	factory.call("_process", 0.0)
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	var crossed: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
	)
	var skirmish_waiting: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_diagnostics"
	)
	assert_float(player.global_position.x).is_greater_equal(skirmish_activation_x)
	assert_bool(bool(crossed.get("crossed", false))).is_true()
	assert_bool(bool(crossed.get("active", true))).is_false()
	assert_bool(bool(crossed.get("hazard_contact_active", true))).is_false()
	assert_bool(bool(skirmish_waiting.get("available", false))).is_true()
	assert_bool(bool(skirmish_waiting.get("active", true))).override_failure_message(
		"Story111 must remain a later player action after Story110 crossing"
	).is_false()
	assert_bool(bool(skirmish_waiting.get("spark_visible", true))).is_false()
	assert_str(String(crossed.get("route_label_text", ""))).is_equal(
		"Overflow Pump Runoff Outlet Crossed"
	)
	for _frame: int in range(2):
		factory.call("_process", 0.0)
	skirmish_waiting = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_diagnostics"
	)
	assert_bool(bool(skirmish_waiting.get("active", true))).override_failure_message(
		"Released or stationary frames must preserve the Story111 handoff"
	).is_false()
	assert_bool(bool(skirmish_waiting.get("spark_visible", true))).is_false()
	var local_state: Dictionary = factory.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed",
		false
	))).is_true()


func _runoff_exit_gate_ready_state() -> Dictionary:
	var state: Dictionary = _runoff_outlet_ready_state()
	state[
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened"
	] = false
	return state


func _runoff_outlet_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated": false,
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
