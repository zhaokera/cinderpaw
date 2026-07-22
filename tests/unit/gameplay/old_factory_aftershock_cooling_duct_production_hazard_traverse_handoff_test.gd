## Story213: production cooling-duct hazard cycle and condenser handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const COOLING_DUCT_VENT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCoolingDuctVent"
)
const COOLING_DUCT_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_cooling_duct"
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


func test_production_cycle_damage_and_crossing_defer_condenser_activation() -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.set_process(false)
	factory.call("set_local_state", _cooling_duct_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var vent := factory.get_node_or_null(COOLING_DUCT_VENT) as Area2D
	assert_that(player).is_not_null()
	assert_that(vent).is_not_null()
	if player == null or vent == null:
		return

	var duct: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	player.global_position = Vector2(float(duct.get("activation_x", 0.0)) - 4.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)

	var activation_start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(8):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
		duct = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
		)
		if bool(duct.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	assert_float(player.global_position.x).is_greater(activation_start_x)
	assert_bool(bool(duct.get("active", false))).is_true()
	assert_str(String(duct.get("phase", ""))).is_equal("grace")
	assert_bool(bool(factory.call("apply_factory_steam_vent_contact", vent, player))).is_false()

	var hp_before: int = player.get_current_hp()
	factory.call("_process", 0.32)
	var warning: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	assert_str(String(warning.get("phase", ""))).override_failure_message(
		"Production _process(delta) must advance Story093 into warning"
	).is_equal("warning")
	assert_bool(bool(warning.get("hazard_contact_active", true))).is_false()

	factory.call("_process", 0.36)
	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	assert_str(String(active.get("phase", ""))).is_equal("active")
	assert_bool(bool(active.get("hazard_contact_active", false))).is_true()
	assert_bool(bool(factory.call("apply_factory_steam_vent_contact", vent, player))).is_true()
	assert_int(player.get_current_hp()).is_equal(hp_before - 8)
	var last_damage: Dictionary = factory.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	assert_str(String(last_damage.get("source", ""))).is_equal(COOLING_DUCT_HAZARD_ID)

	factory.call("_process", 0.45)
	var safe: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	assert_str(String(safe.get("phase", ""))).is_equal("safe")
	assert_bool(bool(safe.get("hazard_contact_active", true))).is_false()

	var condenser_before: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_valve_diagnostics"
	)
	player.global_position = Vector2(
		float(condenser_before.get("activation_x", 0.0)) - 0.5,
		456.0
	)
	player.velocity = Vector2.ZERO
	Input.action_press(MOVE_RIGHT_ACTION)
	await get_tree().physics_frame
	var exit_start_x: float = float(condenser_before.get("activation_x", 0.0)) - 0.5
	factory.call("_process", 0.0)
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO

	var crossed: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	var condenser_waiting: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_valve_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(exit_start_x)
	assert_bool(bool(crossed.get("crossed", false))).is_true()
	assert_bool(bool(crossed.get("active", true))).is_false()
	assert_bool(bool(crossed.get("hazard_contact_active", true))).is_false()
	assert_bool(bool(condenser_waiting.get("available", false))).is_true()
	assert_bool(bool(condenser_waiting.get("active", true))).override_failure_message(
		"Story094 must not activate in the same _process frame that crosses Story093"
	).is_false()
	assert_bool(bool(condenser_waiting.get("spark_visible", true))).is_false()
	assert_bool(bool(condenser_waiting.get("coil_visible", true))).is_false()
	assert_str(String(condenser_waiting.get("route_label_text", ""))).is_equal(
		"Aftershock Cooling Duct Crossed"
	)
	var local_state: Dictionary = factory.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_crossed",
		false
	))).is_true()


func _cooling_duct_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_crossed": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_cleared": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
	}


func _wait_process_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().process_frame


func _release_gameplay_actions() -> void:
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
