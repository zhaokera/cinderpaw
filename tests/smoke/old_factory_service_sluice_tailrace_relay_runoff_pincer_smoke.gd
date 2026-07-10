extends SceneTree


const FACTORY_SCENE := "res://scenes/factory_route_transition_shell.tscn"
const PINCER_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_diagnostics"
)
const PINCER_ACTIVATE := (
	"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer"
)
const PINCER_SPARK_ENTITY_ID := 2144
const PINCER_COIL_ENTITY_ID := 2145


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

	if not scene.has_method(PINCER_DIAGNOSTICS):
		push_error("Factory scene missing tailrace relay runoff pincer diagnostics")
		_cleanup_and_quit(scene, 1)
		return

	scene.call("set_local_state", _tailrace_relay_runoff_crossed_state())
	await process_frame

	var diagnostics: Dictionary = scene.call(PINCER_DIAGNOSTICS)
	if not bool(diagnostics.get("present", false)):
		push_error("Tailrace relay runoff pincer nodes are not present")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("available", false)):
		push_error("Tailrace relay runoff pincer is not available after runoff crossed")
		_cleanup_and_quit(scene, 1)
		return

	var player := scene.get_node_or_null("Player") as Node2D
	if player == null:
		push_error("Factory scene missing Player")
		_cleanup_and_quit(scene, 1)
		return
	player.global_position.x = float(diagnostics.get("activation_x", 0.0)) + 4.0
	if not bool(scene.call(PINCER_ACTIVATE, player)):
		push_error("Tailrace relay runoff pincer did not activate at activation gate")
		_cleanup_and_quit(scene, 1)
		return

	diagnostics = scene.call(PINCER_DIAGNOSTICS)
	if not bool(diagnostics.get("spark_visible", false)):
		push_error("Tailrace relay runoff pincer Spark Rat is not visible after activation")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("coil_visible", false)):
		push_error("Tailrace relay runoff pincer Coil Rat is not visible after activation")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("spark_has_target", false)):
		push_error("Tailrace relay runoff pincer Spark Rat has no target")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("coil_has_target", false)):
		push_error("Tailrace relay runoff pincer Coil Rat has no target")
		_cleanup_and_quit(scene, 1)
		return

	if not bool(scene.call("apply_damage", PINCER_SPARK_ENTITY_ID, 999, {
		"source": &"smoke_tailrace_relay_runoff_pincer_spark",
	})):
		push_error("Tailrace relay runoff pincer Spark Rat did not receive damage")
		_cleanup_and_quit(scene, 1)
		return
	await process_frame
	diagnostics = scene.call(PINCER_DIAGNOSTICS)
	if bool(diagnostics.get("cleared", true)):
		push_error("Tailrace relay runoff pincer cleared before Coil Rat defeat")
		_cleanup_and_quit(scene, 1)
		return

	if not bool(scene.call("apply_damage", PINCER_COIL_ENTITY_ID, 999, {
		"source": &"smoke_tailrace_relay_runoff_pincer_coil",
	})):
		push_error("Tailrace relay runoff pincer Coil Rat did not receive damage")
		_cleanup_and_quit(scene, 1)
		return
	await process_frame
	diagnostics = scene.call(PINCER_DIAGNOSTICS)
	if not bool(diagnostics.get("cleared", false)):
		push_error("Tailrace relay runoff pincer diagnostics did not clear after both defeats")
		_cleanup_and_quit(scene, 1)
		return
	if String(diagnostics.get("route_label_text", "")) != "Tailrace Runoff Pincer Cleared":
		push_error("Tailrace relay runoff pincer route label did not update after clear")
		_cleanup_and_quit(scene, 1)
		return

	var local_state: Dictionary = scene.call("get_local_state")
	if not bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_cleared",
		false
	)):
		push_error("Tailrace relay runoff pincer cleared state was not written")
		_cleanup_and_quit(scene, 1)
		return

	print("service_sluice_tailrace_relay_runoff_pincer_smoke=passed")
	_cleanup_and_quit(scene, 0)


func _tailrace_relay_runoff_crossed_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_crossed": true,
		"last_return_checkpoint": {
			"id": "old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay",
			"scene_id": "area_03_factory",
			"spawn_point": "lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay",
			"position": Vector2(13480, 382),
		},
	}


func _cleanup_and_quit(scene: Node, exit_code: int) -> void:
	scene.queue_free()
	await process_frame
	quit(exit_code)
