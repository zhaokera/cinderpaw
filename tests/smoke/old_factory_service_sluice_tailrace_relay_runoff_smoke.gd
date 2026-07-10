extends SceneTree


const FACTORY_SCENE := "res://scenes/factory_route_transition_shell.tscn"
const RUNOFF_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_diagnostics"
)
const RUNOFF_ACTIVATE := (
	"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff"
)
const RUNOFF_COMPLETE := (
	"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff"
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

	if not scene.has_method(RUNOFF_DIAGNOSTICS):
		push_error("Factory scene missing tailrace relay runoff diagnostics")
		_cleanup_and_quit(scene, 1)
		return

	scene.call("set_local_state", _tailrace_relay_state())
	await process_frame

	var diagnostics: Dictionary = scene.call(RUNOFF_DIAGNOSTICS)
	if not bool(diagnostics.get("present", false)):
		push_error("Tailrace relay runoff nodes are not present")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("visible", false)):
		push_error("Tailrace relay runoff duct is not visible after relay activation")
		_cleanup_and_quit(scene, 1)
		return

	var player := scene.get_node_or_null("Player") as Node2D
	if player == null:
		push_error("Factory scene missing Player")
		_cleanup_and_quit(scene, 1)
		return
	player.global_position.x = float(diagnostics.get("activation_x", 0.0)) + 4.0
	if not bool(scene.call(RUNOFF_ACTIVATE, player)):
		push_error("Tailrace relay runoff did not activate at activation gate")
		_cleanup_and_quit(scene, 1)
		return
	player.global_position.x = float(diagnostics.get("exit_x", 0.0)) + 4.0
	if not bool(scene.call(RUNOFF_COMPLETE, player)):
		push_error("Tailrace relay runoff did not complete at exit gate")
		_cleanup_and_quit(scene, 1)
		return

	diagnostics = scene.call(RUNOFF_DIAGNOSTICS)
	if not bool(diagnostics.get("crossed", false)):
		push_error("Tailrace relay runoff diagnostics did not persist crossed state")
		_cleanup_and_quit(scene, 1)
		return
	var local_state: Dictionary = scene.call("get_local_state")
	if not bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_crossed",
		false
	)):
		push_error("Tailrace relay runoff crossed state was not written to local state")
		_cleanup_and_quit(scene, 1)
		return

	print("service_sluice_tailrace_relay_runoff_smoke=passed")
	_cleanup_and_quit(scene, 0)


func _tailrace_relay_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated": true,
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
