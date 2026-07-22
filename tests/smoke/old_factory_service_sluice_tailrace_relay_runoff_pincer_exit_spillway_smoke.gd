extends SceneTree

const FACTORY_SCENE := "res://scenes/factory_route_transition_shell.tscn"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const FRAME_COUNT: int = 180
const SPILLWAY_DIAGNOSTICS: String = (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
)
const LEECH_DIAGNOSTICS: String = (
	"get_factory_tailrace_exit_sluice_leech_skirmish_diagnostics"
)
const SPILLWAY_VENT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerExitSpillwayVent"
)
const SPILLWAY_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(FACTORY_SCENE) as PackedScene
	if packed == null:
		push_error("Failed to load factory route transition shell")
		quit(1)
		return

	var factory: Node = packed.instantiate()
	root.add_child(factory)
	await process_frame
	await process_frame
	factory.set_process(false)
	factory.call("set_local_state", _spillway_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var vent := factory.get_node_or_null(SPILLWAY_VENT) as Area2D
	if player == null or vent == null:
		_fail(factory, "missing Story235 Player or spillway vent")
		return

	var spillway: Dictionary = factory.call(SPILLWAY_DIAGNOSTICS)
	if (
		not bool(spillway.get("available", false))
		or not bool(spillway.get("visible", false))
		or bool(spillway.get("active", true))
		or String(spillway.get("phase", "")) != "idle"
	):
		_fail(factory, "Story124 did not start in the waiting state")
		return

	player.set_physics_process(false)
	player.global_position = Vector2(
		float(spillway.get("activation_x", 0.0)) + 4.0,
		456.0
	)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	spillway = factory.call(SPILLWAY_DIAGNOSTICS)
	if bool(spillway.get("active", false)):
		_fail(factory, "no-input placement activated Story124")
		return

	player.global_position = Vector2(
		float(spillway.get("activation_x", 0.0)) - 6.0,
		456.0
	)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	player.set_physics_process(true)
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(16):
		await physics_frame
		factory.call("_process", 0.0)
		spillway = factory.call(SPILLWAY_DIAGNOSTICS)
		if bool(spillway.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	if not bool(spillway.get("active", false)):
		_fail(factory, "real move_right did not activate Story124")
		return
	if String(spillway.get("phase", "")) != "grace":
		_fail(factory, "Story124 did not start in grace")
		return

	factory.call("_process", 0.26)
	var warning: Dictionary = factory.call(SPILLWAY_DIAGNOSTICS)
	if String(warning.get("phase", "")) != "warning":
		_fail(factory, "Story124 did not enter warning")
		return
	if bool(warning.get("hazard_contact_active", true)):
		_fail(factory, "Story124 warning enabled contact")
		return

	factory.call("_process", 0.36)
	var active: Dictionary = factory.call(SPILLWAY_DIAGNOSTICS)
	if String(active.get("phase", "")) != "active":
		_fail(factory, "Story124 did not enter active")
		return
	if not bool(active.get("hazard_contact_active", false)):
		_fail(factory, "Story124 active phase did not enable contact")
		return

	var hp_before: int = player.get_current_hp()
	player.set_physics_process(false)
	player.global_position = vent.global_position
	player.velocity = Vector2.ZERO
	await physics_frame
	await physics_frame
	factory.call("_process", 0.0)
	if player.get_current_hp() != hp_before - 8:
		_fail(factory, "Story124 physical steam overlap did not apply 8 damage")
		return
	var last_damage: Dictionary = factory.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	if String(last_damage.get("source", "")) != SPILLWAY_HAZARD_ID:
		_fail(factory, "Story124 physical damage source mismatch")
		return

	factory.call("_process", 0.45)
	var safe: Dictionary = factory.call(SPILLWAY_DIAGNOSTICS)
	if String(safe.get("phase", "")) != "safe":
		_fail(factory, "Story124 did not enter safe")
		return
	if bool(safe.get("hazard_contact_active", true)):
		_fail(factory, "Story124 safe phase left contact active")
		return

	var exit_x: float = float(safe.get("exit_x", 0.0))
	player.global_position = Vector2(exit_x + 4.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	safe = factory.call(SPILLWAY_DIAGNOSTICS)
	if bool(safe.get("crossed", false)):
		_fail(factory, "no-input placement completed Story124")
		return

	player.global_position = Vector2(exit_x - 6.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	player.set_physics_process(true)
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(12):
		await physics_frame
		factory.call("_process", 0.0)
		safe = factory.call(SPILLWAY_DIAGNOSTICS)
		if bool(safe.get("crossed", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	if not bool(safe.get("crossed", false)):
		_fail(factory, "real move_right did not complete Story124")
		return
	if bool(safe.get("hazard_contact_active", true)):
		_fail(factory, "Story124 contact remained active after crossing")
		return

	var leech: Dictionary = factory.call(LEECH_DIAGNOSTICS)
	if not bool(leech.get("available", false)) or bool(leech.get("active", true)):
		_fail(factory, "Story126 did not enter the waiting handoff")
		return
	if bool(leech.get("enemy_visible", true)):
		_fail(factory, "Story126 enemy appeared before fresh movement")
		return

	player.set_physics_process(false)
	player.global_position = Vector2(
		float(leech.get("activation_x", 0.0)) + 4.0,
		456.0
	)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	leech = factory.call(LEECH_DIAGNOSTICS)
	if bool(leech.get("active", false)):
		_fail(factory, "no-input placement activated Story126")
		return

	_release_gameplay_actions()
	for _frame: int in range(FRAME_COUNT):
		factory.call("_process", 1.0 / 60.0)
		await process_frame

	leech = factory.call(LEECH_DIAGNOSTICS)
	if bool(leech.get("active", false)):
		_fail(factory, "Story126 activated during the 180-frame handoff")
		return
	if bool(leech.get("enemy_visible", true)):
		_fail(factory, "Story126 enemy became visible during the handoff")
		return
	var local_state: Dictionary = factory.call("get_local_state")
	if not bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_crossed",
		false
	)):
		_fail(factory, "Story124 crossed state was not persisted")
		return
	if bool(local_state.get(
		"factory_tailrace_exit_sluice_leech_skirmish_activated",
		false
	)):
		_fail(factory, "Story126 activation state changed during the handoff")
		return

	print("story124_production_smoke=passed frames=%d" % FRAME_COUNT)
	_cleanup_and_quit(factory, 0)


func _spillway_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_activated": false,
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


func _fail(factory: Node, message: String) -> void:
	push_error(message)
	_cleanup_and_quit(factory, 1)


func _release_gameplay_actions() -> void:
	Input.action_release(MOVE_RIGHT_ACTION)


func _cleanup_and_quit(factory: Node, exit_code: int) -> void:
	_release_gameplay_actions()
	paused = false
	factory.queue_free()
	await process_frame
	quit(exit_code)
