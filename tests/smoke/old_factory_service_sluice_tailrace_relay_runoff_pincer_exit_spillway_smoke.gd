extends SceneTree


const FACTORY_SCENE := "res://scenes/factory_route_transition_shell.tscn"
const SPILLWAY_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
)
const SPILLWAY_ACTIVATE := (
	"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway"
)
const SPILLWAY_ADVANCE := (
	"advance_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_time"
)
const SPILLWAY_COMPLETE := (
	"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway"
)
const SPILLWAY_CROSSED_STATE_KEY := (
	"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_crossed"
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

	for method_name: String in [
		SPILLWAY_DIAGNOSTICS,
		SPILLWAY_ACTIVATE,
		SPILLWAY_ADVANCE,
		SPILLWAY_COMPLETE,
	]:
		if not scene.has_method(method_name):
			push_error("Factory scene missing spillway method: %s" % method_name)
			_cleanup_and_quit(scene, 1)
			return

	scene.call("set_local_state", _tailrace_runoff_pincer_exit_hatch_opened_state())
	await process_frame

	var diagnostics: Dictionary = scene.call(SPILLWAY_DIAGNOSTICS)
	if not bool(diagnostics.get("present", false)):
		push_error("Tailrace runoff pincer exit spillway nodes are not present")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("pincer_exit_hatch_opened", false)):
		push_error("Tailrace runoff pincer exit spillway did not see hatch opened")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("available", false)):
		push_error("Tailrace runoff pincer exit spillway is not available")
		_cleanup_and_quit(scene, 1)
		return
	if String(diagnostics.get("route_label_text", "")) != "Tailrace Runoff Exit Opened":
		push_error("Tailrace runoff pincer exit spillway ready label is wrong")
		_cleanup_and_quit(scene, 1)
		return

	var player := scene.get_node_or_null("Player") as Node2D
	if player == null:
		push_error("Factory scene missing Player")
		_cleanup_and_quit(scene, 1)
		return
	player.global_position.x = float(diagnostics.get("activation_x", 0.0)) + 4.0
	if not bool(scene.call(SPILLWAY_ACTIVATE, player)):
		push_error("Tailrace runoff pincer exit spillway did not activate")
		_cleanup_and_quit(scene, 1)
		return

	diagnostics = scene.call(SPILLWAY_DIAGNOSTICS)
	if String(diagnostics.get("route_label_text", "")) != "Cross Tailrace Exit Spillway":
		push_error("Tailrace runoff pincer exit spillway active label is wrong")
		_cleanup_and_quit(scene, 1)
		return
	scene.call(
		SPILLWAY_ADVANCE,
		float(diagnostics.get("initial_grace_sec", 0.0))
			+ float(diagnostics.get("warning_sec", 0.0))
			+ 0.05
	)
	diagnostics = scene.call(SPILLWAY_DIAGNOSTICS)
	if not bool(diagnostics.get("hazard_contact_active", false)):
		push_error("Tailrace runoff pincer exit spillway did not enter active contact")
		_cleanup_and_quit(scene, 1)
		return

	player.global_position.x = float(diagnostics.get("exit_x", 0.0)) + 4.0
	if not bool(scene.call(SPILLWAY_COMPLETE, player)):
		push_error("Tailrace runoff pincer exit spillway did not complete")
		_cleanup_and_quit(scene, 1)
		return

	diagnostics = scene.call(SPILLWAY_DIAGNOSTICS)
	if not bool(diagnostics.get("crossed", false)):
		push_error("Tailrace runoff pincer exit spillway diagnostics did not cross")
		_cleanup_and_quit(scene, 1)
		return
	if bool(diagnostics.get("hazard_contact_active", true)):
		push_error("Tailrace runoff pincer exit spillway remains contacting after complete")
		_cleanup_and_quit(scene, 1)
		return
	if String(diagnostics.get("route_label_text", "")) != "Tailrace Exit Spillway Crossed":
		push_error("Tailrace runoff pincer exit spillway crossed label is wrong")
		_cleanup_and_quit(scene, 1)
		return

	var local_state: Dictionary = scene.call("get_local_state")
	if not bool(local_state.get(SPILLWAY_CROSSED_STATE_KEY, false)):
		push_error("Tailrace runoff pincer exit spillway crossed state missing")
		_cleanup_and_quit(scene, 1)
		return

	print("service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke=passed")
	_cleanup_and_quit(scene, 0)


func _tailrace_runoff_pincer_exit_hatch_opened_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened": true,
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
