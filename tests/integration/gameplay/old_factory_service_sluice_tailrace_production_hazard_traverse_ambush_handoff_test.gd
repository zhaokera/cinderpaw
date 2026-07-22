## Story228: production tailrace hazard traverse and Coil Rat ambush handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const TAILRACE_DUCT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceDuct"
)
const TAILRACE_VENT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceVent"
)
const TAILRACE_COIL_RAT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceCoilRat"
)
const TAILRACE_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace"
)
const STEAM_SPRITE_FRAMES: String = (
	"res://assets/environment/old_factory_steam_vent/"
	+ "factory_steam_vent_sprite_frames.tres"
)
const TAILRACE_BACKGROUND: String = (
	"res://assets/environment/old_factory_route/background/"
	+ "env_old_factory_route_tailrace_1280x720.png"
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


func test_real_move_runs_tailrace_hazard_crosses_and_leaves_coil_ambush_waiting(
) -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.set_process(false)
	factory.call("set_local_state", _tailrace_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var duct := factory.get_node_or_null(TAILRACE_DUCT) as Sprite2D
	var vent := factory.get_node_or_null(TAILRACE_VENT) as Area2D
	var coil_rat := factory.get_node_or_null(TAILRACE_COIL_RAT) as Node2D
	var steam_animation := vent.get_node_or_null("SteamAnimation") as AnimatedSprite2D if vent != null else null
	var backdrop_09 := factory.get_node_or_null(
		"EnvironmentCohesion/FactoryBackdropTile09"
	) as Sprite2D
	var backdrop_10 := factory.get_node_or_null(
		"EnvironmentCohesion/FactoryBackdropTile10"
	) as Sprite2D
	assert_that(player).is_not_null()
	assert_that(duct).is_not_null()
	assert_that(vent).is_not_null()
	assert_that(coil_rat).is_not_null()
	assert_that(steam_animation).is_not_null()
	assert_that(backdrop_09).is_not_null()
	assert_that(backdrop_10).is_not_null()
	if (
		player == null
		or duct == null
		or vent == null
		or coil_rat == null
		or steam_animation == null
		or backdrop_09 == null
		or backdrop_10 == null
	):
		return

	assert_str(backdrop_09.texture.resource_path).override_failure_message(
		"Story117 must enter the authored tailrace background at tile 09"
	).is_equal(TAILRACE_BACKGROUND)
	assert_str(backdrop_10.texture.resource_path).override_failure_message(
		"Story117/118 handoff must keep the authored tailrace background"
	).is_equal(TAILRACE_BACKGROUND)
	assert_str(String(vent.call("get_visual_sprite_frames_path"))).is_equal(
		STEAM_SPRITE_FRAMES
	)
	for phase: StringName in [&"safe", &"warning", &"active"]:
		assert_int(int(vent.call("get_visual_animation_frame_count", phase))).is_equal(4)

	var ready_tailrace: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	)
	assert_bool(bool(ready_tailrace.get("available", false))).is_true()
	assert_bool(bool(ready_tailrace.get("active", true))).is_false()
	assert_bool(bool(ready_tailrace.get("visible", false))).is_true()
	assert_bool(bool(ready_tailrace.get("hazard_visible", false))).is_true()
	assert_bool(bool(ready_tailrace.get("hazard_contact_active", true))).is_false()

	player.set_physics_process(false)
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
		"No-input placement beyond x=12020 must leave Story117 inactive"
	).is_false()

	player.global_position = Vector2(
		float(ready_tailrace.get("activation_x", 0.0)) - 6.0,
		456.0
	)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	player.set_physics_process(true)
	var activation_start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(16):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
		ready_tailrace = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
		)
		if bool(ready_tailrace.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	assert_float(player.global_position.x).is_greater(activation_start_x)
	assert_bool(bool(ready_tailrace.get("active", false))).override_failure_message(
		"Fresh production move_right must start Story117"
	).is_true()
	assert_str(String(ready_tailrace.get("phase", ""))).is_equal("grace")
	assert_str(String(ready_tailrace.get("route_label_text", ""))).is_equal(
		"Cross Service Sluice Tailrace"
	)

	factory.call("_process", 0.26)
	var warning: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	)
	assert_str(String(warning.get("phase", ""))).is_equal("warning")
	assert_bool(bool(warning.get("hazard_contact_active", true))).is_false()
	assert_str(String(vent.call("get_visual_animation_name"))).is_equal("warning")

	factory.call("_process", 0.36)
	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	)
	assert_str(String(active.get("phase", ""))).is_equal("active")
	assert_bool(bool(active.get("hazard_contact_active", false))).is_true()
	assert_int(int(active.get("collision_layer", 0))).is_not_equal(0)
	assert_int(int(active.get("collision_mask", 0))).is_not_equal(0)
	assert_str(String(vent.call("get_visual_animation_name"))).is_equal("active")

	var hp_before: int = player.get_current_hp()
	player.set_physics_process(false)
	player.global_position = vent.global_position
	player.velocity = Vector2.ZERO
	await get_tree().physics_frame
	await get_tree().physics_frame
	factory.call("_process", 0.0)
	assert_int(player.get_current_hp()).is_equal(hp_before - 8)
	var last_damage: Dictionary = factory.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	assert_str(String(last_damage.get("source", ""))).is_equal(
		TAILRACE_HAZARD_ID
	)

	factory.call("_process", 0.45)
	var safe: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	)
	assert_str(String(safe.get("phase", ""))).is_equal("safe")
	assert_bool(bool(safe.get("hazard_contact_active", true))).is_false()
	assert_str(String(vent.call("get_visual_animation_name"))).is_equal("safe")

	var exit_x: float = float(safe.get("exit_x", 0.0))
	player.global_position = Vector2(exit_x + 4.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	safe = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	)
	var crossed_without_input: bool = bool(safe.get("crossed", false))
	assert_bool(crossed_without_input).override_failure_message(
		"No-input placement beyond x=12480 must not complete Story117"
	).is_false()

	# Re-arm the live crossing when the no-input completion guard is the RED.
	if crossed_without_input:
		factory.call("set_local_state", _tailrace_active_state())
		safe = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
		)
	player.global_position = Vector2(exit_x - 6.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	player.set_physics_process(true)
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(12):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
		safe = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
		)
		if bool(safe.get("crossed", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	var waiting_ambush: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
	)
	assert_bool(bool(safe.get("crossed", false))).override_failure_message(
		"Real positive-x move_right must complete Story117"
	).is_true()
	assert_bool(bool(safe.get("active", true))).is_false()
	assert_bool(bool(safe.get("hazard_contact_active", true))).is_false()
	assert_str(String(safe.get("route_label_text", ""))).is_equal(
		"Service Sluice Tailrace Crossed"
	)
	assert_bool(bool(waiting_ambush.get("available", false))).is_true()
	assert_bool(bool(waiting_ambush.get("active", true))).is_false()
	assert_bool(bool(waiting_ambush.get("coil_visible", true))).is_false()

	for _frame: int in range(3):
		factory.call("_process", 0.0)
	waiting_ambush = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
	)
	assert_bool(bool(waiting_ambush.get("active", true))).override_failure_message(
		"Stationary frames after crossing must leave Story118 inactive"
	).is_false()

	player.set_physics_process(false)
	player.global_position = Vector2(
		float(waiting_ambush.get("activation_x", 0.0)) + 4.0,
		456.0
	)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	waiting_ambush = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
	)
	var ambush_activated_without_input: bool = bool(waiting_ambush.get("active", false))
	assert_bool(ambush_activated_without_input).override_failure_message(
		"No-input placement beyond x=12620 must leave Story118 inactive"
	).is_false()
	if ambush_activated_without_input:
		return

	Input.action_press(MOVE_RIGHT_ACTION)
	factory.call("_process", 0.0)
	Input.action_release(MOVE_RIGHT_ACTION)
	waiting_ambush = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
	)
	assert_bool(bool(waiting_ambush.get("active", true))).override_failure_message(
		"Held move_right without positive displacement must leave Story118 inactive"
	).is_false()

	var local_state: Dictionary = factory.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_crossed",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_activated",
		true
	))).is_false()


func _tailrace_ready_state() -> Dictionary:
	var state: Dictionary = _tailrace_active_state()
	state[
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_activated"
	] = false
	return state


func _tailrace_active_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_crossed": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_coil_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared": false,
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
