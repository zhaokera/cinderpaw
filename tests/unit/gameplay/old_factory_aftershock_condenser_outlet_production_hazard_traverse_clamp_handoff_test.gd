## Story216: production condenser outlet hazard traverse and clamp handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const OUTLET_VENT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOutletVent"
)
const OUTLET_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet"
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


func test_real_movement_takes_one_steam_hit_and_defers_clamp_ambush() -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.set_process(false)
	factory.call("set_local_state", _outlet_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var vent := factory.get_node_or_null(OUTLET_VENT) as Area2D
	assert_that(player).is_not_null()
	assert_that(vent).is_not_null()
	if player == null or vent == null:
		return

	var outlet: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_diagnostics"
	)
	var activation_x: float = float(outlet.get("activation_x", 0.0))
	player.global_position = Vector2(activation_x - 12.0, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)

	var activation_start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(20):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
		outlet = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_diagnostics"
		)
		if bool(outlet.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO

	assert_float(player.global_position.x).is_greater(activation_start_x)
	assert_bool(bool(outlet.get("active", false))).override_failure_message(
		"Story216 requires production move_right activation, not a direct Story API"
	).is_true()
	assert_str(String(outlet.get("phase", ""))).is_equal("grace")
	assert_str(String(outlet.get("route_label_text", ""))).is_equal(
		"Cross Aftershock Condenser Outlet"
	)

	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(90):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
		if player.global_position.x >= vent.global_position.x:
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	assert_float(player.global_position.x).is_greater_equal(vent.global_position.x)

	var hp_before: int = player.get_current_hp()
	factory.call("_process", 0.26)
	var warning: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_diagnostics"
	)
	assert_str(String(warning.get("phase", ""))).is_equal("warning")
	assert_bool(bool(warning.get("hazard_contact_active", true))).is_false()

	factory.call("_process", 0.36)
	await _wait_physics_frames(2)
	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_diagnostics"
	)
	assert_str(String(active.get("phase", ""))).is_equal("active")
	assert_bool(bool(active.get("hazard_contact_active", false))).is_true()
	assert_int(player.get_current_hp()).override_failure_message(
		"The production Area2D overlap must apply one visible steam hit"
	).is_equal(hp_before - 8)
	var last_damage: Dictionary = factory.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	assert_str(String(last_damage.get("source", ""))).is_equal(OUTLET_HAZARD_ID)

	factory.call("_process", 0.41)
	var safe: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_diagnostics"
	)
	assert_str(String(safe.get("phase", ""))).is_equal("safe")
	assert_bool(bool(safe.get("hazard_contact_active", true))).is_false()

	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(240):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
		outlet = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_diagnostics"
		)
		if bool(outlet.get("crossed", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO

	assert_bool(bool(outlet.get("crossed", false))).is_true()
	assert_bool(bool(outlet.get("active", true))).is_false()
	assert_bool(bool(outlet.get("hazard_contact_active", true))).is_false()
	assert_str(String(outlet.get("route_label_text", ""))).is_equal(
		"Aftershock Condenser Outlet Crossed"
	)
	var clamp: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics"
	)
	assert_bool(bool(clamp.get("available", false))).is_true()
	assert_bool(bool(clamp.get("visible", false))).is_true()
	assert_bool(bool(clamp.get("active", true))).is_false()

	var clamp_activation_x: float = float(clamp.get("activation_x", 0.0))
	factory.call("_process", 0.0)
	player.global_position = Vector2(clamp_activation_x + 4.0, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	var stationary_clamp: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics"
	)
	assert_bool(bool(stationary_clamp.get("active", true))).override_failure_message(
		"Story097 must require a later fresh movement frame after Story096"
	).is_false()
	assert_bool(bool(stationary_clamp.get("spark_visible", true))).is_false()
	assert_bool(bool(stationary_clamp.get("spark_has_target", true))).is_false()
	assert_bool(bool(stationary_clamp.get("spark_process_enabled", true))).is_false()
	assert_bool(bool(stationary_clamp.get("spark_physics_enabled", true))).is_false()


func _outlet_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_crossed": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_spark_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_cleared": false,
	}


func _wait_process_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().process_frame


func _wait_physics_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().physics_frame


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
