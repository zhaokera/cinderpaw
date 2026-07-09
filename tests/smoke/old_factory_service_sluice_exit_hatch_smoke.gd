extends SceneTree


const FACTORY_SCENE := "res://scenes/factory_route_transition_shell.tscn"
const EXIT_HATCH_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics"
)
const EXIT_HATCH_OPEN := (
	"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch"
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

	if not scene.has_method(EXIT_HATCH_DIAGNOSTICS):
		push_error("Factory scene missing service sluice exit hatch diagnostics")
		_cleanup_and_quit(scene, 1)
		return
	if not scene.has_method(EXIT_HATCH_OPEN):
		push_error("Factory scene missing service sluice exit hatch open API")
		_cleanup_and_quit(scene, 1)
		return

	scene.call("set_local_state", {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_claimed": true,
	})
	await process_frame

	var diagnostics: Dictionary = scene.call(EXIT_HATCH_DIAGNOSTICS)
	if not bool(diagnostics.get("present", false)):
		push_error("Service sluice exit hatch node is not present")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("available", false)):
		push_error("Service sluice exit hatch is not available after cache claim")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("collision_blocking", false)):
		push_error("Service sluice exit hatch is not blocking before open")
		_cleanup_and_quit(scene, 1)
		return

	var player := scene.get_node_or_null("Player") as Node2D
	if player == null:
		push_error("Factory scene missing Player")
		_cleanup_and_quit(scene, 1)
		return
	player.global_position = diagnostics.get("position", Vector2.ZERO) as Vector2

	if not bool(scene.call(EXIT_HATCH_OPEN, player)):
		push_error("Service sluice exit hatch did not open in range")
		_cleanup_and_quit(scene, 1)
		return

	diagnostics = scene.call(EXIT_HATCH_DIAGNOSTICS)
	if not bool(diagnostics.get("opened", false)):
		push_error("Service sluice exit hatch diagnostics did not persist opened state")
		_cleanup_and_quit(scene, 1)
		return
	if bool(diagnostics.get("collision_blocking", true)):
		push_error("Service sluice exit hatch remained blocking after open")
		_cleanup_and_quit(scene, 1)
		return
	if int(diagnostics.get("unlock_feedback_spawn_count", 0)) != 1:
		push_error("Service sluice exit hatch unlock feedback did not spawn once")
		_cleanup_and_quit(scene, 1)
		return

	var local_state: Dictionary = scene.call("get_local_state")
	if not bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_opened",
		false
	)):
		push_error("Service sluice exit hatch opened flag missing from local state")
		_cleanup_and_quit(scene, 1)
		return

	print("service_sluice_exit_hatch_smoke=passed")
	_cleanup_and_quit(scene, 0)


func _cleanup_and_quit(scene: Node, exit_code: int) -> void:
	scene.queue_free()
	await process_frame
	quit(exit_code)
