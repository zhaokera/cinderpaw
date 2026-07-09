extends SceneTree


const FACTORY_SCENE := "res://scenes/factory_route_transition_shell.tscn"
const TAILRACE_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
)
const TAILRACE_ACTIVATE := (
	"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace"
)
const TAILRACE_ADVANCE := (
	"advance_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_time"
)
const TAILRACE_COMPLETE := (
	"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace"
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
		TAILRACE_DIAGNOSTICS,
		TAILRACE_ACTIVATE,
		TAILRACE_ADVANCE,
		TAILRACE_COMPLETE,
	]:
		if not scene.has_method(method_name):
			push_error("Factory scene missing tailrace method: %s" % method_name)
			_cleanup_and_quit(scene, 1)
			return

	scene.call("set_local_state", {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_opened": true,
	})
	await process_frame

	var diagnostics: Dictionary = scene.call(TAILRACE_DIAGNOSTICS)
	if not bool(diagnostics.get("present", false)):
		push_error("Service sluice tailrace nodes are not present")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("available", false)):
		push_error("Service sluice tailrace is not available after exit hatch open")
		_cleanup_and_quit(scene, 1)
		return
	if bool(diagnostics.get("hazard_contact_active", true)):
		push_error("Service sluice tailrace hazard contacted before activation")
		_cleanup_and_quit(scene, 1)
		return

	var player := scene.get_node_or_null("Player") as Node2D
	if player == null:
		push_error("Factory scene missing Player")
		_cleanup_and_quit(scene, 1)
		return
	player.global_position.x = float(diagnostics.get("activation_x", 0.0)) + 4.0

	if not bool(scene.call(TAILRACE_ACTIVATE, player)):
		push_error("Service sluice tailrace did not activate in range")
		_cleanup_and_quit(scene, 1)
		return
	scene.call(TAILRACE_ADVANCE, 0.62)

	diagnostics = scene.call(TAILRACE_DIAGNOSTICS)
	if String(diagnostics.get("phase", "")) != "active":
		push_error("Service sluice tailrace did not reach active phase")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("hazard_contact_active", false)):
		push_error("Service sluice tailrace hazard contact inactive during active phase")
		_cleanup_and_quit(scene, 1)
		return

	player.global_position.x = float(diagnostics.get("exit_x", 0.0)) + 4.0
	if not bool(scene.call(TAILRACE_COMPLETE, player)):
		push_error("Service sluice tailrace did not complete at exit")
		_cleanup_and_quit(scene, 1)
		return

	diagnostics = scene.call(TAILRACE_DIAGNOSTICS)
	if not bool(diagnostics.get("crossed", false)):
		push_error("Service sluice tailrace crossed flag missing")
		_cleanup_and_quit(scene, 1)
		return
	if bool(diagnostics.get("hazard_contact_active", true)):
		push_error("Service sluice tailrace hazard contact still active after crossed")
		_cleanup_and_quit(scene, 1)
		return

	var local_state: Dictionary = scene.call("get_local_state")
	if not bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_crossed",
		false
	)):
		push_error("Service sluice tailrace crossed flag missing from local state")
		_cleanup_and_quit(scene, 1)
		return

	print("service_sluice_tailrace_smoke=passed")
	_cleanup_and_quit(scene, 0)


func _cleanup_and_quit(scene: Node, exit_code: int) -> void:
	scene.queue_free()
	await process_frame
	quit(exit_code)
