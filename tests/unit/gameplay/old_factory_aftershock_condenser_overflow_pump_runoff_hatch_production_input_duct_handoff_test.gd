## Story220: production runoff-hatch input and runoff-duct hazard handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const INTERACT_ACTION: StringName = &"interact"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const RUNOFF_HATCH: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpExitHatch"
)
const RUNOFF_DUCT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffDuct"
)
const RUNOFF_VENT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffSteamVent"
)
const RUNOFF_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct"
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


func test_fresh_interact_opens_hatch_then_real_move_crosses_live_runoff_hazard() -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.set_process(false)
	factory.call("set_local_state", _runoff_hatch_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var hatch := factory.get_node_or_null(RUNOFF_HATCH) as Node2D
	var hatch_visual := hatch.get_node_or_null("Visual") as Sprite2D if hatch != null else null
	var hatch_prompt := hatch.get_node_or_null("PromptLabel") as Label if hatch != null else null
	var duct_visual := factory.get_node_or_null(RUNOFF_DUCT) as Sprite2D
	var vent := factory.get_node_or_null(RUNOFF_VENT) as Area2D
	assert_that(player).is_not_null()
	assert_that(hatch).is_not_null()
	assert_that(hatch_visual).is_not_null()
	assert_that(hatch_prompt).is_not_null()
	assert_that(duct_visual).is_not_null()
	assert_that(vent).is_not_null()
	if (
		player == null
		or hatch == null
		or hatch_visual == null
		or hatch_prompt == null
		or duct_visual == null
		or vent == null
	):
		return

	player.global_position = Vector2(6800.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	var ready: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_diagnostics"
	)
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("opened", true))).is_false()
	assert_bool(bool(ready.get("collision_blocking", false))).is_true()
	assert_vector(hatch_visual.position).is_equal(Vector2.ZERO)

	# Input that starts outside the activation radius stays stale on approach.
	Input.action_press(INTERACT_ACTION)
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(24):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	player.global_position = hatch.global_position
	factory.call("_process", 0.0)
	var held_approach: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(6800.0)
	assert_bool(bool(hatch.call("is_provider_in_activation_range", player))).is_true()
	assert_bool(bool(held_approach.get("opened", true))).override_failure_message(
		"Holding interact before entering range must not open the runoff hatch"
	).is_false()

	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	var opened: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_diagnostics"
	)
	var duct: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_diagnostics"
	)
	assert_bool(bool(opened.get("opened", false))).override_failure_message(
		"Story220 requires production Input.interact to open the Story106 hatch"
	).is_true()
	assert_bool(bool(opened.get("available", true))).is_false()
	assert_bool(bool(opened.get("collision_blocking", true))).is_false()
	assert_float(hatch_visual.position.y).override_failure_message(
		"The opened hatch must lift clear of the route, not rely on tint or text"
	).is_less_equal(-120.0)
	assert_float(absf(rad_to_deg(hatch_visual.rotation))).is_greater_equal(6.0)
	assert_int(hatch.z_index + hatch_visual.z_index).is_greater(duct_visual.z_index)
	assert_int(hatch.z_index + hatch_visual.z_index).is_less(player.z_index)
	assert_bool(hatch_prompt.visible).is_false()
	var unlock_vfx: Dictionary = hatch.call("get_unlock_vfx_snapshot")
	assert_int(int(unlock_vfx.get("spawn_count", 0))).is_equal(1)
	assert_bool(bool(duct.get("available", false))).is_true()
	assert_bool(bool(duct.get("visible", false))).is_true()
	assert_bool(bool(duct.get("active", true))).override_failure_message(
		"Opening Story106 must not activate Story107 in the same frame"
	).is_false()
	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	unlock_vfx = hatch.call("get_unlock_vfx_snapshot")
	assert_int(int(unlock_vfx.get("spawn_count", 0))).override_failure_message(
		"Repeated fresh interact must not replay the hatch unlock feedback"
	).is_equal(1)

	for _frame: int in range(3):
		factory.call("_process", 0.0)
	duct = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_diagnostics"
	)
	assert_bool(bool(duct.get("active", true))).override_failure_message(
		"Stationary frames after opening must not start Story107"
	).is_false()

	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	player.set_physics_process(false)
	player.global_position = Vector2(float(duct.get("activation_x", 0.0)) + 4.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	duct = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_diagnostics"
	)
	assert_bool(bool(duct.get("active", true))).override_failure_message(
		"No-input displacement beyond x=7160 must not start Story107"
	).is_false()

	player.global_position = Vector2(float(duct.get("activation_x", 0.0)) - 6.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	player.set_physics_process(true)
	var activation_start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(16):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
		duct = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_diagnostics"
		)
		if bool(duct.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	assert_float(player.global_position.x).is_greater(activation_start_x)
	assert_bool(bool(duct.get("active", false))).override_failure_message(
		"Fresh production move_right must start the Story107 runoff duct"
	).is_true()
	assert_str(String(duct.get("phase", ""))).is_equal("grace")
	assert_str(String(duct.get("route_label_text", ""))).is_equal(
		"Cross Overflow Pump Runoff Duct"
	)

	var hp_before: int = player.get_current_hp()
	factory.call("_process", 0.32)
	var warning: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_diagnostics"
	)
	assert_str(String(warning.get("phase", ""))).is_equal("warning")
	assert_bool(bool(warning.get("hazard_contact_active", true))).is_false()
	factory.call("_process", 0.36)
	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_diagnostics"
	)
	assert_str(String(active.get("phase", ""))).is_equal("active")
	assert_bool(bool(active.get("hazard_contact_active", false))).is_true()
	assert_bool(bool(factory.call("apply_factory_steam_vent_contact", vent, player))).is_true()
	assert_int(player.get_current_hp()).is_equal(hp_before - 8)
	var last_damage: Dictionary = factory.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	assert_str(String(last_damage.get("source", ""))).is_equal(RUNOFF_HAZARD_ID)
	factory.call("_process", 0.45)
	var safe: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_diagnostics"
	)
	assert_str(String(safe.get("phase", ""))).is_equal("safe")
	assert_bool(bool(safe.get("hazard_contact_active", true))).is_false()

	var exit_before: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_diagnostics"
	)
	var exit_start_x: float = float(exit_before.get("activation_x", 0.0)) - 4.0
	player.global_position = Vector2(exit_start_x, 456.0)
	player.velocity = Vector2.ZERO
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(12):
		await get_tree().physics_frame
		if player.global_position.x >= float(exit_before.get("activation_x", 0.0)):
			break
	factory.call("_process", 0.0)
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	var crossed: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_diagnostics"
	)
	var exit_waiting: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(exit_start_x)
	assert_float(player.global_position.x).is_greater_equal(
		float(exit_before.get("activation_x", 0.0))
	)
	assert_bool(bool(crossed.get("crossed", false))).is_true()
	assert_bool(bool(crossed.get("active", true))).is_false()
	assert_bool(bool(crossed.get("hazard_contact_active", true))).is_false()
	assert_bool(bool(exit_waiting.get("available", false))).is_true()
	assert_bool(bool(exit_waiting.get("active", true))).override_failure_message(
		"Story108 must remain a later player action after Story107 crossing"
	).is_false()
	assert_bool(bool(exit_waiting.get("coil_visible", true))).is_false()
	assert_str(String(crossed.get("route_label_text", ""))).is_equal(
		"Overflow Pump Runoff Duct Crossed"
	)
	var local_state: Dictionary = factory.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed",
		false
	))).is_true()


func _runoff_hatch_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct_crossed": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_skirmish_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_coil_rat_defeated": false,
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
