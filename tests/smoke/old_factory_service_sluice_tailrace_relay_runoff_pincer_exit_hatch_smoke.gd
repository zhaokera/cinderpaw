extends SceneTree


const FACTORY_SCENE := "res://scenes/factory_route_transition_shell.tscn"
const PINCER_EXIT_HATCH_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_diagnostics"
)
const PINCER_EXIT_HATCH_OPEN := (
	"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch"
)
const PINCER_EXIT_HATCH_STATE_KEY := (
	"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened"
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
		PINCER_EXIT_HATCH_DIAGNOSTICS,
		PINCER_EXIT_HATCH_OPEN,
	]:
		if not scene.has_method(method_name):
			push_error("Factory scene missing pincer exit hatch method: %s" % method_name)
			_cleanup_and_quit(scene, 1)
			return

	scene.call("set_local_state", _tailrace_runoff_pincer_cache_claimed_state())
	await process_frame

	var diagnostics: Dictionary = scene.call(PINCER_EXIT_HATCH_DIAGNOSTICS)
	if not bool(diagnostics.get("present", false)):
		push_error("Tailrace runoff pincer exit hatch is not present")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("pincer_reward_cache_claimed", false)):
		push_error("Tailrace runoff pincer exit hatch did not see claimed cache")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("visible", false)):
		push_error("Tailrace runoff pincer exit hatch is hidden after cache claim")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("available", false)):
		push_error("Tailrace runoff pincer exit hatch is not available")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("collision_blocking", false)):
		push_error("Tailrace runoff pincer exit hatch is not blocking before open")
		_cleanup_and_quit(scene, 1)
		return
	if String(diagnostics.get("route_label_text", "")) != "Open Tailrace Runoff Exit":
		push_error("Tailrace runoff pincer exit hatch pre-open label is wrong")
		_cleanup_and_quit(scene, 1)
		return

	var player := scene.get_node_or_null("Player") as Node2D
	if player == null:
		push_error("Factory scene missing Player")
		_cleanup_and_quit(scene, 1)
		return
	player.global_position = diagnostics.get("position", Vector2.ZERO) as Vector2

	if not bool(scene.call(PINCER_EXIT_HATCH_OPEN, player)):
		push_error("Tailrace runoff pincer exit hatch open failed")
		_cleanup_and_quit(scene, 1)
		return
	if bool(scene.call(PINCER_EXIT_HATCH_OPEN, player)):
		push_error("Tailrace runoff pincer exit hatch opened twice")
		_cleanup_and_quit(scene, 1)
		return

	diagnostics = scene.call(PINCER_EXIT_HATCH_DIAGNOSTICS)
	if not bool(diagnostics.get("opened", false)):
		push_error("Tailrace runoff pincer exit hatch did not persist opened")
		_cleanup_and_quit(scene, 1)
		return
	if bool(diagnostics.get("available", true)):
		push_error("Tailrace runoff pincer exit hatch remains available after open")
		_cleanup_and_quit(scene, 1)
		return
	if bool(diagnostics.get("collision_blocking", true)):
		push_error("Tailrace runoff pincer exit hatch remains blocking after open")
		_cleanup_and_quit(scene, 1)
		return
	if int(diagnostics.get("unlock_feedback_spawn_count", 0)) != 1:
		push_error("Tailrace runoff pincer exit hatch unlock VFX did not spawn once")
		_cleanup_and_quit(scene, 1)
		return
	if String(diagnostics.get("route_label_text", "")) != "Tailrace Runoff Exit Opened":
		push_error("Tailrace runoff pincer exit hatch open label is wrong")
		_cleanup_and_quit(scene, 1)
		return

	var local_state: Dictionary = scene.call("get_local_state")
	if not bool(local_state.get(PINCER_EXIT_HATCH_STATE_KEY, false)):
		push_error("Tailrace runoff pincer exit hatch opened state missing")
		_cleanup_and_quit(scene, 1)
		return

	print("service_sluice_tailrace_relay_runoff_pincer_exit_hatch_smoke=passed")
	_cleanup_and_quit(scene, 0)


func _tailrace_runoff_pincer_cache_claimed_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_claimed": true,
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
