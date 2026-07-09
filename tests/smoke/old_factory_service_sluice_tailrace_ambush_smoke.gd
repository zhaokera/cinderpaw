extends SceneTree


const FACTORY_SCENE := "res://scenes/factory_route_transition_shell.tscn"
const AMBUSH_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
)
const AMBUSH_ACTIVATE := (
	"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush"
)
const TAILRACE_COIL_RAT_ENTITY_ID := 2143


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

	for method_name: String in [AMBUSH_DIAGNOSTICS, AMBUSH_ACTIVATE]:
		if not scene.has_method(method_name):
			push_error("Factory scene missing tailrace ambush method: %s" % method_name)
			_cleanup_and_quit(scene, 1)
			return

	scene.call("set_local_state", {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_crossed": true,
	})
	await process_frame

	var diagnostics: Dictionary = scene.call(AMBUSH_DIAGNOSTICS)
	if not bool(diagnostics.get("present", false)):
		push_error("Service sluice tailrace Coil Rat is not present")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("available", false)):
		push_error("Tailrace ambush is not available after tailrace crossed")
		_cleanup_and_quit(scene, 1)
		return
	if bool(diagnostics.get("coil_visible", true)):
		push_error("Tailrace Coil Rat is visible before activation")
		_cleanup_and_quit(scene, 1)
		return

	var player := scene.get_node_or_null("Player") as Node2D
	if player == null:
		push_error("Factory scene missing Player")
		_cleanup_and_quit(scene, 1)
		return
	player.global_position.x = float(diagnostics.get("activation_x", 0.0)) + 4.0

	if not bool(scene.call(AMBUSH_ACTIVATE, player)):
		push_error("Tailrace ambush did not activate in range")
		_cleanup_and_quit(scene, 1)
		return

	diagnostics = scene.call(AMBUSH_DIAGNOSTICS)
	if not bool(diagnostics.get("active", false)):
		push_error("Tailrace ambush active flag missing")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("coil_visible", false)):
		push_error("Tailrace Coil Rat is hidden after activation")
		_cleanup_and_quit(scene, 1)
		return
	if int(diagnostics.get("coil_entity_id", 0)) != TAILRACE_COIL_RAT_ENTITY_ID:
		push_error("Tailrace Coil Rat entity id mismatch")
		_cleanup_and_quit(scene, 1)
		return

	if not bool(scene.call("apply_damage", TAILRACE_COIL_RAT_ENTITY_ID, 999, {
		"source": &"smoke_tailrace_ambush",
	})):
		push_error("Tailrace Coil Rat damage application failed")
		_cleanup_and_quit(scene, 1)
		return
	await process_frame

	diagnostics = scene.call(AMBUSH_DIAGNOSTICS)
	if not bool(diagnostics.get("cleared", false)):
		push_error("Tailrace ambush cleared flag missing")
		_cleanup_and_quit(scene, 1)
		return
	if bool(diagnostics.get("coil_visible", true)):
		push_error("Tailrace Coil Rat still visible after defeat")
		_cleanup_and_quit(scene, 1)
		return

	var local_state: Dictionary = scene.call("get_local_state")
	if not bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared",
		false
	)):
		push_error("Tailrace ambush cleared flag missing from local state")
		_cleanup_and_quit(scene, 1)
		return

	print("service_sluice_tailrace_ambush_smoke=passed")
	_cleanup_and_quit(scene, 0)


func _cleanup_and_quit(scene: Node, exit_code: int) -> void:
	scene.queue_free()
	await process_frame
	quit(exit_code)
