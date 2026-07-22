## Story235: production pincer-exit spillway hazard traverse and leech handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const SPILLWAY_VENT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerExitSpillwayVent"
)
const SPILLWAY_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway"
)
const STEAM_SPRITE_FRAMES: String = (
	"res://assets/environment/old_factory_steam_vent/"
	+ "factory_steam_vent_sprite_frames.tres"
)
const SPILLWAY_DIAGNOSTICS: String = (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
)
const LEECH_DIAGNOSTICS: String = (
	"get_factory_tailrace_exit_sluice_leech_skirmish_diagnostics"
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


func test_real_move_runs_spillway_damage_crossing_and_leech_handoff() -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.set_process(false)
	factory.call("set_local_state", _spillway_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var vent := factory.get_node_or_null(SPILLWAY_VENT) as Area2D
	var steam_animation := (
		vent.get_node_or_null("SteamAnimation") as AnimatedSprite2D
		if vent != null
		else null
	)
	assert_that(player).is_not_null()
	assert_that(vent).is_not_null()
	assert_that(steam_animation).is_not_null()
	if player == null or vent == null or steam_animation == null:
		return

	assert_str(String(vent.call("get_visual_sprite_frames_path"))).is_equal(
		STEAM_SPRITE_FRAMES
	)
	for phase: StringName in [&"safe", &"warning", &"active"]:
		assert_int(int(vent.call("get_visual_animation_frame_count", phase))).is_equal(4)

	var ready: Dictionary = factory.call(SPILLWAY_DIAGNOSTICS)
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("hazard_visible", false))).is_true()
	assert_bool(bool(ready.get("hazard_contact_active", true))).is_false()
	assert_str(String(ready.get("phase", ""))).is_equal("idle")

	player.set_physics_process(false)
	player.global_position = Vector2(float(ready.get("activation_x", 0.0)) + 4.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	ready = factory.call(SPILLWAY_DIAGNOSTICS)
	assert_bool(bool(ready.get("active", true))).override_failure_message(
		"No-input placement beyond Story124 activation x must remain idle"
	).is_false()

	player.global_position = Vector2(float(ready.get("activation_x", 0.0)) - 6.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	player.set_physics_process(true)
	var activation_start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(16):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
		ready = factory.call(SPILLWAY_DIAGNOSTICS)
		if bool(ready.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	assert_float(player.global_position.x).is_greater(activation_start_x)
	assert_bool(bool(ready.get("active", false))).override_failure_message(
		"Fresh production move_right must start Story124"
	).is_true()
	assert_str(String(ready.get("phase", ""))).is_equal("grace")
	assert_bool(bool(ready.get("hazard_contact_active", true))).is_false()
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Cross Tailrace Exit Spillway"
	)

	factory.call("_process", 0.26)
	var warning: Dictionary = factory.call(SPILLWAY_DIAGNOSTICS)
	assert_str(String(warning.get("phase", ""))).is_equal("warning")
	assert_bool(bool(warning.get("hazard_contact_active", true))).is_false()
	assert_str(String(vent.call("get_visual_animation_name"))).is_equal("warning")

	factory.call("_process", 0.36)
	var active: Dictionary = factory.call(SPILLWAY_DIAGNOSTICS)
	assert_str(String(active.get("phase", ""))).is_equal("active")
	assert_bool(bool(active.get("hazard_contact_active", false))).is_true()
	assert_int(int(active.get("collision_layer", 0))).is_not_equal(0)
	assert_int(int(active.get("collision_mask", 0))).is_not_equal(0)
	assert_str(String(vent.call("get_visual_animation_name"))).is_equal("active")

	var hp_before: int = player.get_current_hp()
	assert_int(hp_before).is_equal(100)
	player.set_physics_process(false)
	player.global_position = vent.global_position
	player.velocity = Vector2.ZERO
	await get_tree().physics_frame
	await get_tree().physics_frame
	factory.call("_process", 0.0)
	assert_int(player.get_current_hp()).is_equal(92)
	var last_damage: Dictionary = factory.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	assert_str(String(last_damage.get("source", ""))).is_equal(SPILLWAY_HAZARD_ID)
	assert_int(int(last_damage.get("damage", 0))).is_equal(8)
	assert_str(String(last_damage.get("damage_type", ""))).is_equal("steam")

	factory.call("_process", 0.45)
	var safe: Dictionary = factory.call(SPILLWAY_DIAGNOSTICS)
	assert_str(String(safe.get("phase", ""))).is_equal("safe")
	assert_bool(bool(safe.get("hazard_contact_active", true))).is_false()
	assert_str(String(vent.call("get_visual_animation_name"))).is_equal("safe")

	var exit_x: float = float(safe.get("exit_x", 0.0))
	player.global_position = Vector2(exit_x + 4.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	safe = factory.call(SPILLWAY_DIAGNOSTICS)
	var crossed_without_input: bool = bool(safe.get("crossed", false))
	assert_bool(crossed_without_input).override_failure_message(
		"No-input placement beyond Story124 exit x must not complete the traversal"
	).is_false()

	# Preserve the outgoing handoff assertions while completion routing is RED.
	if crossed_without_input:
		factory.call("set_local_state", _spillway_active_state())
		safe = factory.call(SPILLWAY_DIAGNOSTICS)
	player.global_position = Vector2(exit_x - 6.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	player.set_physics_process(true)
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(12):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
		safe = factory.call(SPILLWAY_DIAGNOSTICS)
		if bool(safe.get("crossed", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	assert_bool(bool(safe.get("crossed", false))).override_failure_message(
		"Real positive-x move_right must complete Story124"
	).is_true()
	assert_bool(bool(safe.get("active", true))).is_false()
	assert_bool(bool(safe.get("hazard_contact_active", true))).is_false()
	assert_str(String(safe.get("route_label_text", ""))).is_equal(
		"Tailrace Exit Spillway Crossed"
	)

	var waiting_leech: Dictionary = factory.call(LEECH_DIAGNOSTICS)
	assert_bool(bool(waiting_leech.get("available", false))).is_true()
	assert_bool(bool(waiting_leech.get("active", true))).is_false()
	assert_bool(bool(waiting_leech.get("enemy_visible", true))).is_false()
	assert_bool(bool(waiting_leech.get("enemy_has_target", true))).is_false()
	assert_bool(bool(waiting_leech.get("enemy_process_enabled", true))).is_false()
	assert_bool(bool(waiting_leech.get("enemy_physics_enabled", true))).is_false()

	for _frame: int in range(3):
		factory.call("_process", 0.0)
	waiting_leech = factory.call(LEECH_DIAGNOSTICS)
	assert_bool(bool(waiting_leech.get("active", true))).is_false()

	player.set_physics_process(false)
	player.global_position = Vector2(
		float(waiting_leech.get("activation_x", 0.0)) + 4.0,
		456.0
	)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	waiting_leech = factory.call(LEECH_DIAGNOSTICS)
	var leech_started_without_input: bool = bool(waiting_leech.get("active", false))
	assert_bool(leech_started_without_input).override_failure_message(
		"No-input placement beyond Story126 activation x must leave the leech waiting"
	).is_false()
	if leech_started_without_input:
		return

	Input.action_press(MOVE_RIGHT_ACTION)
	factory.call("_process", 0.0)
	Input.action_release(MOVE_RIGHT_ACTION)
	waiting_leech = factory.call(LEECH_DIAGNOSTICS)
	assert_bool(bool(waiting_leech.get("active", true))).override_failure_message(
		"Held move_right without positive displacement must leave Story126 inactive"
	).is_false()

	var local_state: Dictionary = factory.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_crossed",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_tailrace_exit_sluice_leech_skirmish_activated",
		true
	))).is_false()


func _spillway_ready_state() -> Dictionary:
	var state: Dictionary = _spillway_active_state()
	state[
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_activated"
	] = false
	return state


func _spillway_active_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_crossed": false,
		"factory_tailrace_exit_sluice_leech_skirmish_activated": false,
		"factory_tailrace_exit_sluice_leech_defeated": false,
		"factory_tailrace_exit_sluice_leech_skirmish_cleared": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
		"last_return_checkpoint": {
			"id": "old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay",
			"scene_id": "area_03_factory",
			"spawn_point": "lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay",
			"position": Vector2(13480, 382),
		},
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
