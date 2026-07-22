extends SceneTree

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const INTERACT_ACTION: StringName = &"interact"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const FRAME_COUNT: int = 180
const HATCH_PATH: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerExitHatch"
)
const SPILLWAY_DUCT_PATH: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerExitSpillwayDuct"
)
const HATCH_DIAGNOSTICS: String = (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_diagnostics"
)
const SPILLWAY_DIAGNOSTICS: String = (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_release_gameplay_actions()
	var factory: Node = FACTORY_SCENE.instantiate()
	root.add_child(factory)
	await process_frame
	await process_frame
	factory.set_process(false)
	factory.call("set_local_state", _pincer_exit_hatch_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var hatch := factory.get_node_or_null(HATCH_PATH) as Node2D
	var visual := hatch.get_node_or_null("Visual") as Sprite2D if hatch != null else null
	var prompt := hatch.get_node_or_null("PromptLabel") as Label if hatch != null else null
	var duct := factory.get_node_or_null(SPILLWAY_DUCT_PATH) as Sprite2D
	if player == null or hatch == null or visual == null or prompt == null or duct == null:
		_fail(factory, "missing Story234 runtime nodes")
		return
	player.set_physics_process(false)
	player.global_position = hatch.global_position + Vector2(-160.0, 64.0)
	player.velocity = Vector2.ZERO

	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	player.global_position = hatch.global_position + Vector2(0.0, 64.0)
	factory.call("_process", 0.0)
	var hatch_state: Dictionary = factory.call(HATCH_DIAGNOSTICS)
	if bool(hatch_state.get("opened", false)):
		_fail(factory, "stale interact opened Story123")
		return

	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	factory.call("_process", 0.0)
	hatch_state = factory.call(HATCH_DIAGNOSTICS)
	if bool(hatch_state.get("opened", false)):
		_fail(factory, "no-input placement opened Story123")
		return

	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	hatch_state = factory.call(HATCH_DIAGNOSTICS)
	if not bool(hatch_state.get("opened", false)):
		_fail(factory, "fresh production interact did not open Story123")
		return

	for frame: int in range(FRAME_COUNT):
		factory.call("_process", 1.0 / 60.0)
		hatch_state = factory.call(HATCH_DIAGNOSTICS)
		var spillway_frame: Dictionary = factory.call(SPILLWAY_DIAGNOSTICS)
		if not bool(hatch_state.get("opened", false)):
			_fail(factory, "Story123 lost opened state at frame %d" % frame)
			return
		if bool(spillway_frame.get("active", false)) \
				or bool(spillway_frame.get("crossed", false)) \
				or bool(spillway_frame.get("hazard_contact_active", false)):
			_fail(factory, "Story124 advanced during Story234 frame %d" % frame)
			return
		await process_frame

	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	var spillway_state: Dictionary = factory.call(SPILLWAY_DIAGNOSTICS)
	player.global_position = Vector2(
		float(spillway_state.get("activation_x", 0.0)) + 4.0,
		410.0
	)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	spillway_state = factory.call(SPILLWAY_DIAGNOSTICS)
	if bool(spillway_state.get("active", false)):
		_fail(factory, "no-input activation-x placement started Story124")
		return

	player.global_position = Vector2(
		float(spillway_state.get("exit_x", 0.0)) + 4.0,
		410.0
	)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	spillway_state = factory.call(SPILLWAY_DIAGNOSTICS)
	if bool(spillway_state.get("active", false)) \
			or bool(spillway_state.get("crossed", false)):
		_fail(factory, "no-input exit-x placement consumed Story124")
		return

	player.global_position = hatch.global_position + Vector2(0.0, 64.0)
	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)

	hatch_state = factory.call(HATCH_DIAGNOSTICS)
	spillway_state = factory.call(SPILLWAY_DIAGNOSTICS)
	var unlock_vfx: Dictionary = hatch.call("get_unlock_vfx_snapshot")
	if (
		not bool(hatch_state.get("opened", false))
		or bool(hatch_state.get("available", true))
		or bool(hatch_state.get("collision_blocking", true))
		or String(hatch_state.get("prompt_text", "")) != "Tailrace Exit Open"
		or String(hatch_state.get("route_label_text", "")) != "Tailrace Runoff Exit Opened"
		or prompt.visible
		or visual.position.y > -120.0
		or absf(rad_to_deg(visual.rotation)) < 6.0
		or hatch.z_index + visual.z_index <= duct.z_index
		or hatch.z_index + visual.z_index >= player.z_index
		or int(unlock_vfx.get("spawn_count", 0)) != 1
		or not bool(spillway_state.get("available", false))
		or not bool(spillway_state.get("visible", false))
		or bool(spillway_state.get("active", false))
		or bool(spillway_state.get("crossed", false))
		or String(spillway_state.get("phase", "")) != "idle"
		or bool(spillway_state.get("hazard_contact_active", false))
	):
		_fail(factory, "Story234 terminal contract failed")
		return

	var local_state: Dictionary = factory.call("get_local_state")
	if not bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened",
		false
	)) or bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_activated",
		true
	)):
		_fail(factory, "Story234 terminal state did not persist")
		return

	print("story234_production_smoke=passed frames=%d" % FRAME_COUNT)
	_cleanup_and_quit(factory, 0)


func _pincer_exit_hatch_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_crossed": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
	}


func _fail(factory: Node, message: String) -> void:
	push_error(message)
	_cleanup_and_quit(factory, 1)


func _release_gameplay_actions() -> void:
	Input.action_release(INTERACT_ACTION)
	Input.action_release(MOVE_RIGHT_ACTION)


func _cleanup_and_quit(factory: Node, exit_code: int) -> void:
	_release_gameplay_actions()
	factory.queue_free()
	await process_frame
	quit(exit_code)
