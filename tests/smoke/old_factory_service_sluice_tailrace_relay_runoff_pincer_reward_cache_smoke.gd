extends SceneTree


const FACTORY_SCENE := "res://scenes/factory_route_transition_shell.tscn"
const PINCER_REWARD_CACHE_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_diagnostics"
)
const PINCER_REWARD_CACHE_CLAIM := (
	"try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache"
)
const PINCER_REWARD_CACHE_STATE_KEY := (
	"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_claimed"
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
		PINCER_REWARD_CACHE_DIAGNOSTICS,
		PINCER_REWARD_CACHE_CLAIM,
	]:
		if not scene.has_method(method_name):
			push_error("Factory scene missing pincer reward cache method: %s" % method_name)
			_cleanup_and_quit(scene, 1)
			return

	scene.call("set_local_state", _tailrace_relay_runoff_pincer_cleared_state())
	await process_frame

	var diagnostics: Dictionary = scene.call(PINCER_REWARD_CACHE_DIAGNOSTICS)
	if not bool(diagnostics.get("present", false)):
		push_error("Tailrace relay runoff pincer reward cache is not present")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("pincer_cleared", false)):
		push_error("Tailrace relay runoff pincer reward cache did not see cleared pincer")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("visible", false)):
		push_error("Tailrace relay runoff pincer reward cache is hidden after pincer clear")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("claim_available", false)):
		push_error("Tailrace relay runoff pincer reward cache is not claimable")
		_cleanup_and_quit(scene, 1)
		return
	if String(diagnostics.get("route_label_text", "")) != "Tailrace Runoff Pincer Cleared":
		push_error("Tailrace relay runoff pincer reward cache pre-claim label is wrong")
		_cleanup_and_quit(scene, 1)
		return

	var player := scene.get_node_or_null("Player") as Node2D
	if player == null:
		push_error("Factory scene missing Player")
		_cleanup_and_quit(scene, 1)
		return
	player.global_position = diagnostics.get("position", Vector2.ZERO) as Vector2

	if not bool(scene.call(PINCER_REWARD_CACHE_CLAIM, player)):
		push_error("Tailrace relay runoff pincer reward cache claim failed")
		_cleanup_and_quit(scene, 1)
		return
	if bool(scene.call(PINCER_REWARD_CACHE_CLAIM, player)):
		push_error("Tailrace relay runoff pincer reward cache claimed twice")
		_cleanup_and_quit(scene, 1)
		return

	diagnostics = scene.call(PINCER_REWARD_CACHE_DIAGNOSTICS)
	if not bool(diagnostics.get("claimed", false)):
		push_error("Tailrace relay runoff pincer reward cache did not persist claimed")
		_cleanup_and_quit(scene, 1)
		return
	if bool(diagnostics.get("claim_available", true)):
		push_error("Tailrace relay runoff pincer reward cache remains claimable")
		_cleanup_and_quit(scene, 1)
		return
	if String(diagnostics.get("route_label_text", "")) != (
		"Tailrace Runoff Pincer Cache Claimed +20 Gears"
	):
		push_error("Tailrace relay runoff pincer reward cache claim label is wrong")
		_cleanup_and_quit(scene, 1)
		return

	var local_state: Dictionary = scene.call("get_local_state")
	if not bool(local_state.get(PINCER_REWARD_CACHE_STATE_KEY, false)):
		push_error("Tailrace relay runoff pincer reward cache claimed state missing")
		_cleanup_and_quit(scene, 1)
		return

	print("service_sluice_tailrace_relay_runoff_pincer_reward_cache_smoke=passed")
	_cleanup_and_quit(scene, 0)


func _tailrace_relay_runoff_pincer_cleared_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_cleared": true,
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
