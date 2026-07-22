extends SceneTree

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const INTERACT_ACTION: StringName = &"interact"
const FRAME_COUNT: int = 180
const HATCH_PATH: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceExitHatch"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	Input.action_release(INTERACT_ACTION)
	var factory: Node = FACTORY_SCENE.instantiate()
	root.add_child(factory)
	await process_frame
	await process_frame
	factory.set_process(false)
	factory.call("set_local_state", _service_exit_hatch_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var hatch := factory.get_node_or_null(HATCH_PATH) as Node2D
	var visual := hatch.get_node_or_null("Visual") as Sprite2D if hatch != null else null
	var prompt := hatch.get_node_or_null("PromptLabel") as Label if hatch != null else null
	if player == null or hatch == null or visual == null or prompt == null:
		_fail(factory, "missing Story227 runtime nodes")
		return
	player.set_physics_process(false)
	player.global_position = Vector2(hatch.global_position.x - 160.0, 456.0)
	player.velocity = Vector2.ZERO

	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	player.global_position = Vector2(hatch.global_position.x, 456.0)
	factory.call("_process", 0.0)
	var hatch_state: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics"
	)
	if bool(hatch_state.get("opened", false)):
		_fail(factory, "stale interact opened Story116")
		return

	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)

	for _frame: int in range(FRAME_COUNT):
		factory.call("_process", 1.0 / 60.0)
		await process_frame

	hatch_state = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics"
	)
	var tailrace_state: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	)
	var unlock_vfx: Dictionary = hatch.call("get_unlock_vfx_snapshot")
	if (
		not bool(hatch_state.get("opened", false))
		or bool(hatch_state.get("collision_blocking", true))
		or String(hatch_state.get("prompt_text", "")) != "Service Exit Open"
		or prompt.visible
		or visual.position.y > -120.0
		or absf(rad_to_deg(visual.rotation)) < 6.0
		or hatch.z_index + visual.z_index >= player.z_index
		or int(unlock_vfx.get("spawn_count", 0)) != 1
		or not bool(tailrace_state.get("available", false))
		or not bool(tailrace_state.get("visible", false))
		or bool(tailrace_state.get("active", false))
		or bool(tailrace_state.get("hazard_contact_active", false))
	):
		_fail(factory, "Story227 terminal contract failed")
		return

	print("story227_smoke=passed frames=%d" % FRAME_COUNT)
	_cleanup_and_quit(factory, 0)


func _service_exit_hatch_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_opened": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_crossed": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
	}


func _fail(factory: Node, message: String) -> void:
	push_error(message)
	_cleanup_and_quit(factory, 1)


func _cleanup_and_quit(factory: Node, exit_code: int) -> void:
	Input.action_release(INTERACT_ACTION)
	factory.queue_free()
	await process_frame
	quit(exit_code)
