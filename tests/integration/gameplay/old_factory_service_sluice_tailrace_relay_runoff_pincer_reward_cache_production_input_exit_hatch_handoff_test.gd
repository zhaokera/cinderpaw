## Story233: production pincer-cache input and exit-hatch handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const INTERACT_ACTION: StringName = &"interact"
const PINCER_CACHE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerRewardCache"
)
const PINCER_HATCH: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerExitHatch"
)
const PINCER_CACHE_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache"
)
const PINCER_HATCH_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch"
)
const CACHE_DIAGNOSTICS: String = (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_diagnostics"
)
const HATCH_DIAGNOSTICS: String = (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_diagnostics"
)
const SPILLWAY_DIAGNOSTICS: String = (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
)

var _spawned_nodes: Array[Node] = []


func before_test() -> void:
	Input.action_release(INTERACT_ACTION)
	get_tree().paused = false


func after_test() -> void:
	Input.action_release(INTERACT_ACTION)
	get_tree().paused = false
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_fresh_interact_claims_pincer_cache_without_opening_tailrace_exit(
) -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.set_process(false)
	factory.call("set_local_state", _pincer_reward_state(false))

	var player := factory.get_node_or_null("Player") as PlayerController
	var cache := factory.get_node_or_null(PINCER_CACHE) as Node2D
	var hatch := factory.get_node_or_null(PINCER_HATCH) as Node2D
	assert_that(player).is_not_null()
	assert_that(cache).is_not_null()
	assert_that(hatch).is_not_null()
	if player == null or cache == null or hatch == null:
		return
	player.set_physics_process(false)
	player.global_position = cache.global_position
	player.velocity = Vector2.ZERO

	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	var locked_cache: Dictionary = factory.call(CACHE_DIAGNOSTICS)
	assert_bool(bool(locked_cache.get("available", true))).is_false()
	assert_bool(bool(locked_cache.get("claimed", true))).is_false()

	factory.call("set_local_state", _pincer_reward_state(true))
	factory.call("_process", 0.0)
	var stale_cache: Dictionary = factory.call(CACHE_DIAGNOSTICS)
	assert_bool(bool(stale_cache.get("visible", false))).is_true()
	assert_bool(bool(stale_cache.get("claim_available", false))).is_true()
	assert_bool(bool(stale_cache.get("claimed", true))).override_failure_message(
		"Held interact from before Story122 became available must remain stale"
	).is_false()

	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	player.global_position = stale_cache.get("position", Vector2.ZERO) as Vector2
	factory.call("_process", 0.0)
	stale_cache = factory.call(CACHE_DIAGNOSTICS)
	assert_bool(bool(cache.call("is_provider_in_reward_range", player))).is_true()
	assert_bool(bool(stale_cache.get("claimed", true))).override_failure_message(
		"No-input placement inside Story122 range must leave the cache unclaimed"
	).is_false()

	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	var claimed_cache: Dictionary = factory.call(CACHE_DIAGNOSTICS)
	var claimed: bool = bool(claimed_cache.get("claimed", false))
	assert_bool(claimed).override_failure_message(
		"Story233 requires fresh Input.interact to route into the Story122 cache"
	).is_true()
	if not claimed:
		return

	var reward: Dictionary = claimed_cache.get("last_reward", {}) as Dictionary
	var feedback: Dictionary = (
		claimed_cache.get("last_claim_feedback", {}) as Dictionary
	)
	assert_bool(bool(claimed_cache.get("claim_available", true))).is_false()
	assert_str(String(reward.get("cache_id", ""))).is_equal(PINCER_CACHE_ID)
	assert_int(int(reward.get("gears", 0))).is_equal(20)
	assert_str(String(reward.get("source", ""))).is_equal(PINCER_CACHE_ID)
	assert_str(String(feedback.get("text", ""))).is_equal(
		"Tailrace Runoff Pincer Cache Claimed +20 Gears"
	)
	assert_str(String(claimed_cache.get("route_label_text", ""))).is_equal(
		"Tailrace Runoff Pincer Cache Claimed +20 Gears"
	)

	var ready_hatch: Dictionary = factory.call(HATCH_DIAGNOSTICS)
	assert_bool(bool(ready_hatch.get("present", false))).is_true()
	assert_bool(bool(ready_hatch.get("available", false))).is_true()
	assert_bool(bool(ready_hatch.get("visible", false))).is_true()
	assert_bool(bool(ready_hatch.get("opened", true))).is_false()
	assert_bool(bool(ready_hatch.get("collision_blocking", false))).is_true()
	assert_bool(bool(ready_hatch.get("interaction_monitoring", false))).is_true()
	assert_bool(bool(ready_hatch.get("interaction_monitorable", false))).is_true()
	assert_int(int(ready_hatch.get("unlock_feedback_spawn_count", -1))).is_equal(0)
	assert_str(String(ready_hatch.get("hatch_id", ""))).is_equal(PINCER_HATCH_ID)
	assert_str(String(ready_hatch.get("prompt_text", ""))).is_equal(
		"Open Tailrace Exit"
	)
	assert_vector(ready_hatch.get("position", Vector2.ZERO) as Vector2).is_equal(
		Vector2(16080.0, 392.0)
	)

	player.global_position = ready_hatch.get("position", Vector2.ZERO) as Vector2
	for _frame: int in range(4):
		factory.call("_process", 0.0)
	var held_hatch: Dictionary = factory.call(HATCH_DIAGNOSTICS)
	assert_bool(bool(held_hatch.get("opened", true))).override_failure_message(
		"The cache claim edge and held interact must not also open Story123"
	).is_false()
	assert_int(int(held_hatch.get("unlock_feedback_spawn_count", -1))).is_equal(0)

	var locked_spillway: Dictionary = factory.call(SPILLWAY_DIAGNOSTICS)
	assert_bool(bool(locked_spillway.get("available", true))).is_false()
	assert_bool(bool(locked_spillway.get("active", true))).is_false()
	assert_bool(bool(locked_spillway.get("visible", true))).is_false()
	assert_bool(bool(locked_spillway.get("hazard_contact_active", true))).is_false()

	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	var local_state: Dictionary = factory.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_claimed",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened",
		true
	))).is_false()


func _pincer_reward_state(pincer_cleared: bool) -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_cleared": pincer_cleared,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_claimed": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
	}


func _wait_process_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().process_frame


func _stop_runtime_audio_players() -> void:
	for audio_player: AudioStreamPlayer in _find_nodes_of_type(
		get_tree().root,
		AudioStreamPlayer
	):
		audio_player.stop()
	for audio_player_2d: AudioStreamPlayer2D in _find_nodes_of_type(
		get_tree().root,
		AudioStreamPlayer2D
	):
		audio_player_2d.stop()


func _find_nodes_of_type(root: Node, expected_type: Variant) -> Array[Node]:
	var matches: Array[Node] = []
	if is_instance_of(root, expected_type):
		matches.append(root)
	for child: Node in root.get_children():
		matches.append_array(_find_nodes_of_type(child, expected_type))
	return matches
