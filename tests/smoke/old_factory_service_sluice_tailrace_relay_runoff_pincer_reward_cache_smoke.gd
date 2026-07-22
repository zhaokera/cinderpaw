extends SceneTree


const FACTORY_SCENE := "res://scenes/factory_route_transition_shell.tscn"
const INTERACT_ACTION: StringName = &"interact"
const PINCER_CACHE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerRewardCache"
)
const PINCER_REWARD_CACHE_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_diagnostics"
)
const PINCER_EXIT_HATCH_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_diagnostics"
)
const PINCER_EXIT_SPILLWAY_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
)
const PINCER_REWARD_CACHE_ID := (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache"
)
const PINCER_REWARD_CACHE_STATE_KEY := (
	"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_claimed"
)
const PINCER_EXIT_HATCH_STATE_KEY := (
	"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	Input.action_release(INTERACT_ACTION)
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

	for method_name: String in [
		PINCER_REWARD_CACHE_DIAGNOSTICS,
		PINCER_EXIT_HATCH_DIAGNOSTICS,
		PINCER_EXIT_SPILLWAY_DIAGNOSTICS,
		"handle_factory_interact_input",
	]:
		if not scene.has_method(method_name):
			push_error("Factory scene missing Story233 method: %s" % method_name)
			_cleanup_and_quit(scene, 1)
			return

	var player := scene.get_node_or_null("Player") as CharacterBody2D
	var cache := scene.get_node_or_null(PINCER_CACHE) as Node2D
	if player == null or cache == null:
		push_error("Factory scene missing Story233 Player or reward cache")
		_cleanup_and_quit(scene, 1)
		return
	player.set_physics_process(false)
	player.global_position = cache.global_position
	player.velocity = Vector2.ZERO

	scene.call("set_local_state", _tailrace_relay_runoff_pincer_state(false))
	Input.action_press(INTERACT_ACTION)
	scene.call("_process", 0.0)
	var diagnostics: Dictionary = scene.call(PINCER_REWARD_CACHE_DIAGNOSTICS)
	if bool(diagnostics.get("available", true)) \
			or bool(diagnostics.get("claimed", true)):
		push_error("Story233 pre-clear interact was not locked")
		_cleanup_and_quit(scene, 1)
		return

	scene.call("set_local_state", _tailrace_relay_runoff_pincer_state(true))
	scene.call("_process", 0.0)
	diagnostics = scene.call(PINCER_REWARD_CACHE_DIAGNOSTICS)
	if not bool(diagnostics.get("visible", false)) \
			or not bool(diagnostics.get("claim_available", false)) \
			or bool(diagnostics.get("claimed", true)):
		push_error("Held pre-clear interact consumed the Story122 cache")
		_cleanup_and_quit(scene, 1)
		return

	Input.action_release(INTERACT_ACTION)
	scene.call("_process", 0.0)
	player.global_position = diagnostics.get("position", Vector2.ZERO) as Vector2
	scene.call("_process", 0.0)
	if not bool(cache.call("is_provider_in_reward_range", player)):
		push_error("Cinderpaw is outside Story122 reward range")
		_cleanup_and_quit(scene, 1)
		return

	Input.action_press(INTERACT_ACTION)
	scene.call("_process", 0.0)
	diagnostics = scene.call(PINCER_REWARD_CACHE_DIAGNOSTICS)
	var reward: Dictionary = diagnostics.get("last_reward", {}) as Dictionary
	var feedback: Dictionary = (
		diagnostics.get("last_claim_feedback", {}) as Dictionary
	)
	if not bool(diagnostics.get("claimed", false)) \
			or bool(diagnostics.get("claim_available", true)):
		push_error("Fresh production interact did not claim Story122 once")
		_cleanup_and_quit(scene, 1)
		return
	if String(reward.get("cache_id", "")) != PINCER_REWARD_CACHE_ID \
			or int(reward.get("gears", 0)) != 20 \
			or String(reward.get("source", "")) != PINCER_REWARD_CACHE_ID:
		push_error("Story122 reward payload is incorrect")
		_cleanup_and_quit(scene, 1)
		return
	if String(feedback.get("text", "")) != (
		"Tailrace Runoff Pincer Cache Claimed +20 Gears"
	):
		push_error("Story122 claim feedback is incorrect")
		_cleanup_and_quit(scene, 1)
		return

	var hatch: Dictionary = scene.call(PINCER_EXIT_HATCH_DIAGNOSTICS)
	if not bool(hatch.get("available", false)) \
			or not bool(hatch.get("visible", false)) \
			or bool(hatch.get("opened", true)) \
			or not bool(hatch.get("collision_blocking", false)) \
			or not bool(hatch.get("interaction_monitoring", false)):
		push_error("Story123 waiting hatch handoff is incorrect")
		_cleanup_and_quit(scene, 1)
		return
	if String(hatch.get("prompt_text", "")) != "Open Tailrace Exit" \
			or int(hatch.get("unlock_feedback_spawn_count", -1)) != 0:
		push_error("Story123 waiting hatch feedback is incorrect")
		_cleanup_and_quit(scene, 1)
		return

	player.global_position = hatch.get("position", Vector2.ZERO) as Vector2
	for frame: int in range(180):
		scene.call("_process", 1.0 / 60.0)
		hatch = scene.call(PINCER_EXIT_HATCH_DIAGNOSTICS)
		if bool(hatch.get("opened", false)):
			push_error("Held cache-claim input opened Story123 at frame %d" % frame)
			_cleanup_and_quit(scene, 1)
			return
	var spillway: Dictionary = scene.call(PINCER_EXIT_SPILLWAY_DIAGNOSTICS)
	if bool(spillway.get("available", true)) \
			or bool(spillway.get("active", true)) \
			or bool(spillway.get("visible", true)) \
			or bool(spillway.get("hazard_contact_active", true)):
		push_error("Story124 advanced during Story233 handoff")
		_cleanup_and_quit(scene, 1)
		return

	Input.action_release(INTERACT_ACTION)
	scene.call("_process", 0.0)
	var local_state: Dictionary = scene.call("get_local_state")
	if not bool(local_state.get(PINCER_REWARD_CACHE_STATE_KEY, false)) \
			or bool(local_state.get(PINCER_EXIT_HATCH_STATE_KEY, true)):
		push_error("Story233 terminal state did not persist")
		_cleanup_and_quit(scene, 1)
		return

	print("story233_production_smoke=passed frames=180")
	_cleanup_and_quit(scene, 0)


func _tailrace_relay_runoff_pincer_state(pincer_cleared: bool) -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_cleared": pincer_cleared,
		PINCER_REWARD_CACHE_STATE_KEY: false,
		PINCER_EXIT_HATCH_STATE_KEY: false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
	}


func _cleanup_and_quit(scene: Node, exit_code: int) -> void:
	Input.action_release(INTERACT_ACTION)
	scene.queue_free()
	await process_frame
	quit(exit_code)
