extends SceneTree


const FACTORY_SCENE := "res://scenes/factory_route_transition_shell.tscn"
const SERVICE_SLUICE_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_diagnostics"
)
const SERVICE_SLUICE_ACTIVATE := (
	"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice"
)
const SERVICE_SLUICE_COMPLETE := (
	"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice"
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

	if not scene.has_method(SERVICE_SLUICE_DIAGNOSTICS):
		push_error("Factory scene missing service sluice diagnostics")
		_cleanup_and_quit(scene, 1)
		return

	scene.call("set_local_state", {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened": true,
	})
	await process_frame

	var diagnostics: Dictionary = scene.call(SERVICE_SLUICE_DIAGNOSTICS)
	if not bool(diagnostics.get("present", false)):
		push_error("Service sluice nodes are not present")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("visible", false)):
		push_error("Service sluice duct is not visible after hatch open")
		_cleanup_and_quit(scene, 1)
		return

	var player := scene.get_node_or_null("Player") as Node2D
	if player == null:
		push_error("Factory scene missing Player")
		_cleanup_and_quit(scene, 1)
		return
	player.global_position.x = float(diagnostics.get("activation_x", 0.0)) + 4.0
	if not bool(scene.call(SERVICE_SLUICE_ACTIVATE, player)):
		push_error("Service sluice did not activate at activation gate")
		_cleanup_and_quit(scene, 1)
		return
	player.global_position.x = float(diagnostics.get("exit_x", 0.0)) + 4.0
	if not bool(scene.call(SERVICE_SLUICE_COMPLETE, player)):
		push_error("Service sluice did not complete at exit gate")
		_cleanup_and_quit(scene, 1)
		return

	diagnostics = scene.call(SERVICE_SLUICE_DIAGNOSTICS)
	if not bool(diagnostics.get("crossed", false)):
		push_error("Service sluice diagnostics did not persist crossed state")
		_cleanup_and_quit(scene, 1)
		return

	print("service_sluice_smoke=passed")
	_cleanup_and_quit(scene, 0)


func _cleanup_and_quit(scene: Node, exit_code: int) -> void:
	scene.queue_free()
	await process_frame
	quit(exit_code)
