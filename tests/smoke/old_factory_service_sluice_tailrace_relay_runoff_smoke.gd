extends SceneTree


const FACTORY_SCENE := "res://scenes/factory_route_transition_shell.tscn"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const FRAME_COUNT := 180
const RUNOFF_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_diagnostics"
)
const PINCER_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_diagnostics"
)
const RUNOFF_VENT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffVent"
)
const RUNOFF_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(FACTORY_SCENE) as PackedScene
	if packed == null:
		push_error("Failed to load factory route transition shell")
		quit(1)
		return

	var scene := packed.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	scene.set_process(false)

	for method_name: String in [RUNOFF_DIAGNOSTICS, PINCER_DIAGNOSTICS]:
		if not scene.has_method(method_name):
			_fail(scene, "Factory scene missing relay-runoff method: %s" % method_name)
			return

	scene.call("set_local_state", _tailrace_relay_state())
	var player := scene.get_node_or_null("Player") as PlayerController
	var vent := scene.get_node_or_null(RUNOFF_VENT) as Area2D
	if player == null or vent == null:
		_fail(scene, "Factory scene missing Player or Tailrace Relay Runoff Vent")
		return

	var diagnostics: Dictionary = scene.call(RUNOFF_DIAGNOSTICS)
	if not bool(diagnostics.get("present", false)):
		_fail(scene, "Tailrace Relay Runoff nodes are not present")
		return
	if not bool(diagnostics.get("visible", false)):
		_fail(scene, "Tailrace Relay Runoff is hidden after relay activation")
		return
	if bool(diagnostics.get("active", true)):
		_fail(scene, "Tailrace Relay Runoff did not start idle")
		return

	player.set_physics_process(false)
	player.global_position = Vector2(
		float(diagnostics.get("activation_x", 0.0)) + 4.0,
		456.0
	)
	player.velocity = Vector2.ZERO
	scene.call("_process", 0.0)
	diagnostics = scene.call(RUNOFF_DIAGNOSTICS)
	if bool(diagnostics.get("active", false)):
		_fail(scene, "No-input placement activated Story120")
		return

	player.global_position = Vector2(
		float(diagnostics.get("activation_x", 0.0)) - 6.0,
		456.0
	)
	player.velocity = Vector2.ZERO
	scene.call("_process", 0.0)
	player.set_physics_process(true)
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(16):
		await physics_frame
		scene.call("_process", 0.0)
		diagnostics = scene.call(RUNOFF_DIAGNOSTICS)
		if bool(diagnostics.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	if not bool(diagnostics.get("active", false)):
		_fail(scene, "Real move_right did not activate Story120")
		return
	if String(diagnostics.get("phase", "")) != "grace":
		_fail(scene, "Story120 did not start in grace")
		return

	scene.call("_process", 0.26)
	var warning: Dictionary = scene.call(RUNOFF_DIAGNOSTICS)
	if String(warning.get("phase", "")) != "warning":
		_fail(scene, "Story120 did not enter warning")
		return
	if bool(warning.get("hazard_contact_active", true)):
		_fail(scene, "Story120 warning enabled contact")
		return

	scene.call("_process", 0.36)
	var active: Dictionary = scene.call(RUNOFF_DIAGNOSTICS)
	if String(active.get("phase", "")) != "active":
		_fail(scene, "Story120 did not enter active")
		return
	if not bool(active.get("hazard_contact_active", false)):
		_fail(scene, "Story120 active phase did not enable contact")
		return

	var hp_before: int = player.get_current_hp()
	player.set_physics_process(false)
	player.global_position = vent.global_position
	player.velocity = Vector2.ZERO
	await physics_frame
	await physics_frame
	scene.call("_process", 0.0)
	if player.get_current_hp() != hp_before - 8:
		_fail(scene, "Story120 physical steam overlap did not apply 8 damage")
		return
	var last_damage: Dictionary = scene.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	if String(last_damage.get("source", "")) != RUNOFF_HAZARD_ID:
		_fail(scene, "Story120 physical damage source mismatch")
		return

	scene.call("_process", 0.45)
	var safe: Dictionary = scene.call(RUNOFF_DIAGNOSTICS)
	if String(safe.get("phase", "")) != "safe":
		_fail(scene, "Story120 did not enter safe")
		return
	if bool(safe.get("hazard_contact_active", true)):
		_fail(scene, "Story120 safe phase left contact active")
		return

	var exit_x: float = float(safe.get("exit_x", 0.0))
	player.global_position = Vector2(exit_x + 4.0, 456.0)
	player.velocity = Vector2.ZERO
	scene.call("_process", 0.0)
	safe = scene.call(RUNOFF_DIAGNOSTICS)
	if bool(safe.get("crossed", false)):
		_fail(scene, "No-input placement completed Story120")
		return

	player.global_position = Vector2(exit_x - 6.0, 456.0)
	player.velocity = Vector2.ZERO
	scene.call("_process", 0.0)
	player.set_physics_process(true)
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(12):
		await physics_frame
		scene.call("_process", 0.0)
		safe = scene.call(RUNOFF_DIAGNOSTICS)
		if bool(safe.get("crossed", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	if not bool(safe.get("crossed", false)):
		_fail(scene, "Real move_right did not complete Story120")
		return
	if bool(safe.get("hazard_contact_active", true)):
		_fail(scene, "Story120 contact remained active after crossing")
		return

	var pincer: Dictionary = scene.call(PINCER_DIAGNOSTICS)
	if not bool(pincer.get("available", false)) or bool(pincer.get("active", true)):
		_fail(scene, "Story121 did not enter the waiting handoff")
		return
	if bool(pincer.get("spark_visible", true)) or bool(pincer.get("coil_visible", true)):
		_fail(scene, "Story121 enemies appeared before fresh movement")
		return

	player.set_physics_process(false)
	player.global_position = Vector2(float(pincer.get("activation_x", 0.0)) + 4.0, 456.0)
	player.velocity = Vector2.ZERO
	scene.call("_process", 0.0)
	pincer = scene.call(PINCER_DIAGNOSTICS)
	if bool(pincer.get("active", false)):
		_fail(scene, "No-input placement activated Story121")
		return

	_release_gameplay_actions()
	for _frame: int in range(FRAME_COUNT):
		scene.call("_process", 1.0 / 60.0)
		await process_frame

	pincer = scene.call(PINCER_DIAGNOSTICS)
	if bool(pincer.get("active", false)):
		_fail(scene, "Story121 activated during the 180-frame handoff")
		return
	if bool(pincer.get("spark_visible", true)) or bool(pincer.get("coil_visible", true)):
		_fail(scene, "Story121 enemies became visible during the handoff")
		return
	var local_state: Dictionary = scene.call("get_local_state")
	if not bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_crossed",
		false
	)):
		_fail(scene, "Story120 crossed state was not persisted")
		return
	if bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_activated",
		false
	)):
		_fail(scene, "Story121 activation state changed during the handoff")
		return

	print("story120_production_smoke=passed frames=%d" % FRAME_COUNT)
	_cleanup_and_quit(scene, 0)


func _tailrace_relay_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_crossed": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_spark_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_coil_rat_defeated": false,
		"last_return_checkpoint": {
			"id": "old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay",
			"scene_id": "area_03_factory",
			"spawn_point": "lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay",
			"position": Vector2(13480, 382),
		},
	}


func _fail(scene: Node, message: String) -> void:
	push_error(message)
	_release_gameplay_actions()
	_cleanup_and_quit(scene, 1)


func _release_gameplay_actions() -> void:
	Input.action_release(MOVE_RIGHT_ACTION)


func _cleanup_and_quit(scene: Node, exit_code: int) -> void:
	_release_gameplay_actions()
	paused = false
	scene.queue_free()
	await process_frame
	quit(exit_code)
