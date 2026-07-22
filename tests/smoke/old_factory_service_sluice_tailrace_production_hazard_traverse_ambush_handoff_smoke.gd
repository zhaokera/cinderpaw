extends SceneTree

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const FRAME_COUNT: int = 180
const TAILRACE_VENT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceVent"
)
const TAILRACE_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	Input.action_release(MOVE_RIGHT_ACTION)
	var factory: Node = FACTORY_SCENE.instantiate()
	root.add_child(factory)
	await process_frame
	await process_frame
	factory.set_process(false)
	factory.call("set_local_state", _tailrace_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var vent := factory.get_node_or_null(TAILRACE_VENT) as Area2D
	if player == null or vent == null:
		_fail(factory, "missing Story228 runtime nodes")
		return

	var tailrace: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	)
	player.set_physics_process(false)
	player.global_position = Vector2(float(tailrace.get("activation_x", 0.0)) + 4.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	if bool(factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	).get("active", false)):
		_fail(factory, "Story117 activated without movement input")
		return

	player.global_position = Vector2(float(tailrace.get("activation_x", 0.0)) - 6.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	player.set_physics_process(true)
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(16):
		await physics_frame
		factory.call("_process", 0.0)
		tailrace = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
		)
		if bool(tailrace.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	if not bool(tailrace.get("active", false)):
		_fail(factory, "real move_right did not activate Story117")
		return

	factory.call("_process", 0.26)
	var warning: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	)
	factory.call("_process", 0.36)
	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	)
	if String(warning.get("phase", "")) != "warning" or String(active.get("phase", "")) != "active":
		_fail(factory, "Story117 steam phase progression failed")
		return

	var hp_before: int = player.get_current_hp()
	player.set_physics_process(false)
	player.global_position = vent.global_position
	player.velocity = Vector2.ZERO
	await physics_frame
	await physics_frame
	factory.call("_process", 0.0)
	var last_damage: Dictionary = factory.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	if (
		player.get_current_hp() != hp_before - 8
		or String(last_damage.get("source", "")) != TAILRACE_HAZARD_ID
	):
		_fail(factory, "Story117 physical steam damage failed")
		return

	factory.call("_process", 0.45)
	tailrace = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	)
	if String(tailrace.get("phase", "")) != "safe":
		_fail(factory, "Story117 did not return to safe phase")
		return

	var exit_x: float = float(tailrace.get("exit_x", 0.0))
	player.global_position = Vector2(exit_x + 4.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	if bool(factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	).get("crossed", false)):
		_fail(factory, "Story117 completed without movement input")
		return

	player.global_position = Vector2(exit_x - 6.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	player.set_physics_process(true)
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(12):
		await physics_frame
		factory.call("_process", 0.0)
		tailrace = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
		)
		if bool(tailrace.get("crossed", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	if not bool(tailrace.get("crossed", false)):
		_fail(factory, "real move_right did not complete Story117")
		return

	var ambush: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
	)
	player.set_physics_process(false)
	player.global_position = Vector2(float(ambush.get("activation_x", 0.0)) + 4.0, 456.0)
	player.velocity = Vector2.ZERO
	for _frame: int in range(FRAME_COUNT):
		factory.call("_process", 1.0 / 60.0)
		await process_frame
		ambush = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
		)
		if bool(ambush.get("active", false)):
			_fail(factory, "Story118 activated during stationary smoke frames")
			return

	if (
		not bool(ambush.get("available", false))
		or bool(ambush.get("coil_visible", true))
		or bool(ambush.get("coil_physics_enabled", true))
		or bool(ambush.get("coil_process_enabled", true))
	):
		_fail(factory, "Story118 waiting handoff contract failed")
		return

	print("story228_smoke=passed frames=%d" % FRAME_COUNT)
	_cleanup_and_quit(factory, 0)


func _tailrace_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_crossed": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_coil_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
	}


func _fail(factory: Node, message: String) -> void:
	push_error(message)
	_cleanup_and_quit(factory, 1)


func _cleanup_and_quit(factory: Node, exit_code: int) -> void:
	Input.action_release(MOVE_RIGHT_ACTION)
	factory.queue_free()
	await process_frame
	quit(exit_code)
