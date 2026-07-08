## Player Abilities Story 088: Old Factory lower-deck aftershock exhaust pursuer reward cache.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const EXIT_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_forward_pressure_exit_relay"
const EXIT_RELAY_SPAWN_POINT: String = "lower_deck_forward_pressure_exit_relay"
const EXHAUST_PURSUER_ENTITY_ID: int = 2131
const EXHAUST_PURSUER_REWARD_CACHE_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache"
)
const EXHAUST_PURSUER_REWARD_CACHE_TEXTURE: String = (
	"res://assets/environment/old_factory_lower_deck_skirmish_cache/"
	+ "env_old_factory_lower_deck_skirmish_cache_claimable_256.png"
)

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_exhaust_pursuer_reward_cache_requires_pursuer_clear_and_keeps_lift_optional() -> void:
	var locked_scene: Node = _factory_scene_with_exhaust_pursuer_reward_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
		)
		or not locked_scene.has_method(
			"try_claim_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache"
		)
	):
		return

	var locked_cache: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	)
	assert_bool(bool(locked_cache.get("present", false))).is_true()
	assert_bool(bool(locked_cache.get("exhaust_pursuer_cleared", true))).is_false()
	assert_bool(bool(locked_cache.get("available", true))).is_false()
	assert_bool(bool(locked_cache.get("visible", true))).is_false()
	assert_bool(bool(locked_cache.get("claim_available", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache"
	))).is_false()

	var destination: Node = _factory_scene_with_exhaust_pursuer_reward_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(service_lift).is_not_null()
	if player == null or service_lift == null:
		return

	var available_cache: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	)
	assert_bool(bool(available_cache.get("present", false))).is_true()
	assert_bool(bool(available_cache.get("exhaust_pursuer_cleared", false))).is_true()
	assert_bool(bool(available_cache.get("available", false))).is_true()
	assert_bool(bool(available_cache.get("visible", false))).is_true()
	assert_bool(bool(available_cache.get("claim_available", false))).is_true()
	assert_bool(bool(available_cache.get("claimed", true))).is_false()
	assert_str(String(available_cache.get("cache_id", ""))).is_equal(
		EXHAUST_PURSUER_REWARD_CACHE_ID
	)
	assert_str(String(available_cache.get("texture_path", ""))).is_equal(
		EXHAUST_PURSUER_REWARD_CACHE_TEXTURE
	)
	assert_str(String(available_cache.get("prompt_text", ""))).is_equal("+20 Gears")
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get(
			"route_label_text",
			""
		)
	)).is_equal("Forward Pressure Exhaust Pursuer Cleared")

	player.global_position = service_lift.global_position
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


func test_exhaust_pursuer_reward_cache_claim_persists_without_replaying_forward_chain(
) -> void:
	var destination: Node = _factory_scene_with_exhaust_pursuer_reward_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache"
	)).is_true()
	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	)).is_true()
	if (
		not destination.has_method(
			"try_claim_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache"
		)
		or not destination.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
		)
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var before_cache: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	)
	player.global_position = before_cache.get("position", Vector2.ZERO) as Vector2
	assert_bool(bool(destination.call(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache",
		player
	))).is_true()
	assert_bool(bool(destination.call(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache",
		player
	))).is_false()

	var claimed_cache: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	)
	var reward: Dictionary = claimed_cache.get("last_reward", {}) as Dictionary
	var feedback: Dictionary = claimed_cache.get("last_claim_feedback", {}) as Dictionary
	assert_bool(bool(claimed_cache.get("claimed", false))).is_true()
	assert_bool(bool(claimed_cache.get("claim_available", true))).is_false()
	assert_str(String(reward.get("cache_id", ""))).is_equal(EXHAUST_PURSUER_REWARD_CACHE_ID)
	assert_int(int(reward.get("gears", 0))).is_equal(20)
	assert_str(String(reward.get("source", ""))).is_equal(EXHAUST_PURSUER_REWARD_CACHE_ID)
	assert_str(String(feedback.get("text", ""))).is_equal(
		"Forward Pressure Exhaust Pursuer Cache Claimed +20 Gears"
	)
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get(
			"route_label_text",
			""
		)
	)).is_equal("Forward Pressure Exhaust Pursuer Cache Claimed +20 Gears")

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_cleared",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed",
		false
	))).is_true()

	var restored: Node = _instantiate_factory_scene()
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", local_state)

	var restored_cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	)
	assert_bool(bool(restored_cache.get("claimed", false))).is_true()
	assert_bool(bool(restored_cache.get("claim_available", true))).is_false()
	var restored_pursuer: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_diagnostics"
	)
	assert_bool(bool(restored_pursuer.get("cleared", false))).is_true()
	var restored_exhaust: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_bool(bool(restored_exhaust.get("crossed", false))).is_true()
	var restored_skirmish: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exit_skirmish_diagnostics"
	)
	assert_bool(bool(restored_skirmish.get("cleared", false))).is_true()
	var restored_aftershock_cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_reward_cache_diagnostics"
	)
	assert_bool(bool(restored_aftershock_cache.get("claimed", false))).is_true()
	var restored_relay: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
	)
	assert_bool(bool(restored_relay.get("activated", false))).is_true()
	assert_str(String(restored_relay.get("savepoint_id", ""))).is_equal(
		EXIT_RELAY_SAVEPOINT_ID
	)
	assert_str(String(restored_relay.get("spawn_point", ""))).is_equal(
		EXIT_RELAY_SPAWN_POINT
	)
	var old_forward_cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_reward_cache_diagnostics"
	)
	assert_int(int(old_forward_cache.get("claim_audio_request_count", -1))).is_equal(0)
	var clear_feedback: Dictionary = restored.call(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	)
	assert_int(int(clear_feedback.get("spawn_count", -1))).is_equal(0)
	var restored_lift: Dictionary = restored.call("get_factory_service_lift_diagnostics")
	assert_str(String(restored_lift.get("prompt_text", ""))).is_equal("Call lift")


func test_exhaust_pursuer_reward_cache_unlocks_on_live_pursuer_defeat() -> void:
	var destination: Node = _factory_scene_with_exhaust_pursuer_reward_state(false, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	)).is_true()
	if not destination.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready_pursuer: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_diagnostics"
	)
	assert_bool(bool(ready_pursuer.get("available", false))).is_true()
	assert_bool(bool(ready_pursuer.get("cleared", true))).is_false()
	player.global_position.x = float(ready_pursuer.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer",
		player
	))).is_true()

	assert_bool(destination.call("apply_damage", EXHAUST_PURSUER_ENTITY_ID, 999, {
		"source": &"unit_test_exhaust_pursuer_reward_cache_unlock",
	})).is_true()
	await get_tree().process_frame

	var available_cache: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	)
	assert_bool(bool(available_cache.get("exhaust_pursuer_cleared", false))).is_true()
	assert_bool(bool(available_cache.get("visible", false))).is_true()
	assert_bool(bool(available_cache.get("available", false))).is_true()
	assert_bool(bool(available_cache.get("claim_available", false))).is_true()
	assert_str(String(available_cache.get("prompt_text", ""))).is_equal("+20 Gears")

	player.global_position = available_cache.get("position", Vector2.ZERO) as Vector2
	assert_bool(bool(destination.call(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache",
		player
	))).is_true()


func _factory_scene_with_exhaust_pursuer_reward_state(
		pursuer_cleared: bool,
		cache_claimed: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _exhaust_pursuer_reward_base_state().merged({
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_activated": (
			pursuer_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat_defeated": (
			pursuer_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_cleared": (
			pursuer_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed": (
			cache_claimed
		),
	}, true))
	return destination


func _instantiate_factory_scene() -> Node:
	assert_bool(FileAccess.file_exists(FACTORY_SCENE_PATH)).is_true()
	var packed: PackedScene = load(FACTORY_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var destination: Node = packed.instantiate()
	add_child(destination)
	_spawned_nodes.append(destination)
	return destination


func _exhaust_pursuer_reward_base_state() -> Dictionary:
	return {
		"encounter_cleared": true,
		"factory_cache_claimed": true,
		"factory_deep_guard_activated": true,
		"factory_deep_guard_defeated": true,
		"factory_deep_route_cleared": true,
		"factory_spark_rat_activated": true,
		"factory_spark_rat_defeated": true,
		"factory_return_patrol_activated": true,
		"factory_return_patrol_defeated": true,
		"factory_return_checkpoint_activated": true,
		"factory_checkpoint_forward_patrol_activated": true,
		"factory_checkpoint_forward_patrol_defeated": true,
		"factory_checkpoint_rear_ambush_activated": true,
		"factory_checkpoint_rear_ambush_defeated": true,
		"factory_checkpoint_overdrive_duo_activated": true,
		"factory_checkpoint_overdrive_left_defeated": true,
		"factory_checkpoint_overdrive_right_defeated": true,
		"factory_checkpoint_overdrive_duo_cleared": true,
		"factory_lower_deck_skirmish_activated": true,
		"factory_lower_deck_skirmish_defeated": true,
		"factory_lower_deck_reward_cache_claimed": true,
		"factory_lower_deck_parry_gate_unlocked": true,
		"factory_lower_deck_exit_ambush_activated": true,
		"factory_lower_deck_exit_ambush_defeated": true,
		"factory_lower_deck_shortcut_activated": true,
		"factory_lower_deck_shortcut_guard_defeated": true,
		"factory_lower_deck_shortcut_unlocked": true,
		"factory_lower_deck_shortcut_reward_cache_claimed": true,
		"factory_lower_deck_shortcut_pursuer_activated": true,
		"factory_lower_deck_shortcut_pursuer_defeated": true,
		"factory_lower_deck_pressure_guard_activated": true,
		"factory_lower_deck_pressure_guard_defeated": true,
		"factory_lower_deck_pressure_valve_opened": true,
		"factory_lower_deck_steam_sluice_activated": true,
		"factory_lower_deck_steam_sluice_defeated": true,
		"factory_lower_deck_deep_bulkhead_guard_activated": true,
		"factory_lower_deck_deep_bulkhead_guard_defeated": true,
		"factory_lower_deck_deep_bulkhead_opened": true,
		"factory_lower_deck_breach_corridor_activated": true,
		"factory_lower_deck_breach_front_guard_defeated": true,
		"factory_lower_deck_breach_rear_ambusher_activated": true,
		"factory_lower_deck_breach_rear_ambusher_defeated": true,
		"factory_lower_deck_breach_corridor_secured": true,
		"factory_lower_deck_breach_relay_activated": true,
		"factory_lower_deck_post_relay_trial_activated": true,
		"factory_lower_deck_post_relay_trial_defeated": true,
		"factory_lower_deck_relay_forward_reward_cache_claimed": true,
		"factory_lower_deck_forward_hatch_opened": true,
		"factory_lower_deck_forward_conduit_activated": true,
		"factory_lower_deck_forward_conduit_defeated": true,
		"factory_lower_deck_forward_pressure_traverse_crossed": true,
		"factory_lower_deck_forward_pressure_counter_ambush_activated": true,
		"factory_lower_deck_forward_pressure_counter_ambush_defeated": true,
		"factory_lower_deck_forward_pressure_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_exit_guard_activated": true,
		"factory_lower_deck_forward_pressure_exit_guard_defeated": true,
		"factory_lower_deck_forward_pressure_exit_relay_activated": true,
		"factory_lower_deck_forward_pressure_exit_gate_opened": true,
		"factory_lower_deck_forward_pressure_route_handoff_marker_lit": true,
		"factory_lower_deck_forward_pressure_beacon_ambush_activated": true,
		"factory_lower_deck_forward_pressure_beacon_ambush_defeated": true,
		"factory_lower_deck_forward_pressure_overrun_activated": true,
		"factory_lower_deck_forward_pressure_overrun_defeated": true,
		"factory_lower_deck_forward_pressure_breaker_activated": true,
		"factory_lower_deck_forward_pressure_breaker_secured": true,
		"factory_lower_deck_forward_pressure_breaker_cut": true,
		"factory_lower_deck_forward_pressure_relief_ambush_activated": true,
		"factory_lower_deck_forward_pressure_relief_ambush_defeated": true,
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_activated": true,
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_defeated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_activated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_cleared": true,
		"factory_lower_deck_forward_pressure_coil_aftershock_activated": true,
		"factory_lower_deck_forward_pressure_coil_aftershock_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_coil_aftershock_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_crossed": true,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
		"last_return_checkpoint": {
			"id": EXIT_RELAY_SAVEPOINT_ID,
			"scene_id": String(FACTORY_SCENE_ID),
			"spawn_point": EXIT_RELAY_SPAWN_POINT,
			"position": Vector2(1414, 382),
		},
	}


func _stop_runtime_audio_players() -> void:
	for child: Node in get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
			child.queue_free()
