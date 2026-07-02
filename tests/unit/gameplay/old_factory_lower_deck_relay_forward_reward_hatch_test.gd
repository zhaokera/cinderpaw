## Player Abilities Story 066: Old Factory lower deck relay-forward reward hatch.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const BREACH_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_breach_relay"
const BREACH_RELAY_SPAWN_POINT: String = "lower_deck_breach_relay"
const RELAY_FORWARD_CACHE_ID: String = "old_factory_lower_deck_relay_forward_cache"
const RELAY_FORWARD_HATCH_ID: String = "old_factory_lower_deck_forward_hatch"
const RELAY_FORWARD_CACHE_TEXTURE: String = (
	"res://assets/environment/old_factory_lower_deck_skirmish_cache/"
	+ "env_old_factory_lower_deck_skirmish_cache_claimable_256.png"
)
const RELAY_FORWARD_HATCH_TEXTURE: String = (
	"res://assets/environment/old_factory_lower_deck_deep_bulkhead/"
	+ "env_old_factory_lower_deck_deep_bulkhead_closed_256.png"
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


func test_relay_forward_reward_cache_requires_post_relay_trial_clear_and_keeps_lift_optional() -> void:
	var locked_scene: Node = _factory_scene_with_post_relay_trial_cleared(false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_relay_forward_reward_cache_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_claim_factory_lower_deck_relay_forward_reward_cache"
	)).is_true()
	assert_bool(locked_scene.has_method("get_factory_lower_deck_forward_hatch_diagnostics")).is_true()
	assert_bool(locked_scene.has_method("try_open_factory_lower_deck_forward_hatch")).is_true()
	if (
		not locked_scene.has_method("get_factory_lower_deck_relay_forward_reward_cache_diagnostics")
		or not locked_scene.has_method("try_claim_factory_lower_deck_relay_forward_reward_cache")
		or not locked_scene.has_method("get_factory_lower_deck_forward_hatch_diagnostics")
		or not locked_scene.has_method("try_open_factory_lower_deck_forward_hatch")
	):
		return

	var locked_cache: Dictionary = locked_scene.call(
		"get_factory_lower_deck_relay_forward_reward_cache_diagnostics"
	)
	assert_bool(bool(locked_cache.get("present", false))).is_true()
	assert_bool(bool(locked_cache.get("available", true))).is_false()
	assert_bool(bool(locked_cache.get("visible", true))).is_false()
	assert_bool(bool(locked_cache.get("claim_available", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_claim_factory_lower_deck_relay_forward_reward_cache"
	))).is_false()

	var locked_hatch: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_hatch_diagnostics"
	)
	assert_bool(bool(locked_hatch.get("present", false))).is_true()
	assert_bool(bool(locked_hatch.get("visible", true))).is_false()
	assert_bool(bool(locked_hatch.get("available", true))).is_false()
	assert_bool(bool(locked_scene.call("try_open_factory_lower_deck_forward_hatch"))).is_false()

	var destination: Node = _factory_scene_with_post_relay_trial_cleared(true)
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
		"get_factory_lower_deck_relay_forward_reward_cache_diagnostics"
	)
	assert_bool(bool(available_cache.get("present", false))).is_true()
	assert_bool(bool(available_cache.get("available", false))).is_true()
	assert_bool(bool(available_cache.get("visible", false))).is_true()
	assert_bool(bool(available_cache.get("claim_available", false))).is_true()
	assert_bool(bool(available_cache.get("claimed", true))).is_false()
	assert_str(String(available_cache.get("cache_id", ""))).is_equal(RELAY_FORWARD_CACHE_ID)
	assert_str(String(available_cache.get("texture_path", ""))).is_equal(RELAY_FORWARD_CACHE_TEXTURE)
	assert_str(String(available_cache.get("prompt_text", ""))).is_equal("+20 Gears")

	var waiting_hatch: Dictionary = destination.call(
		"get_factory_lower_deck_forward_hatch_diagnostics"
	)
	assert_bool(bool(waiting_hatch.get("present", false))).is_true()
	assert_bool(bool(waiting_hatch.get("visible", false))).is_true()
	assert_bool(bool(waiting_hatch.get("available", true))).is_false()
	assert_bool(bool(waiting_hatch.get("opened", true))).is_false()
	assert_str(String(waiting_hatch.get("hatch_id", ""))).is_equal(RELAY_FORWARD_HATCH_ID)
	assert_str(String(waiting_hatch.get("texture_path", ""))).is_equal(RELAY_FORWARD_HATCH_TEXTURE)
	assert_str(String(waiting_hatch.get("prompt_text", ""))).is_equal("Claim relay cache")

	player.global_position = service_lift.global_position
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


func test_relay_forward_reward_cache_claim_then_hatch_open_persists_without_replaying_relay_chain() -> void:
	var destination: Node = _factory_scene_with_post_relay_trial_cleared(true)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method(
		"try_claim_factory_lower_deck_relay_forward_reward_cache"
	)).is_true()
	assert_bool(destination.has_method("try_open_factory_lower_deck_forward_hatch")).is_true()
	if (
		not destination.has_method("try_claim_factory_lower_deck_relay_forward_reward_cache")
		or not destination.has_method("try_open_factory_lower_deck_forward_hatch")
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var before_cache: Dictionary = destination.call(
		"get_factory_lower_deck_relay_forward_reward_cache_diagnostics"
	)
	player.global_position = before_cache.get("position", Vector2.ZERO) as Vector2
	assert_bool(bool(destination.call(
		"try_claim_factory_lower_deck_relay_forward_reward_cache",
		player
	))).is_true()
	assert_bool(bool(destination.call(
		"try_claim_factory_lower_deck_relay_forward_reward_cache",
		player
	))).is_false()

	var claimed_cache: Dictionary = destination.call(
		"get_factory_lower_deck_relay_forward_reward_cache_diagnostics"
	)
	var reward: Dictionary = claimed_cache.get("last_reward", {}) as Dictionary
	var feedback: Dictionary = claimed_cache.get("last_claim_feedback", {}) as Dictionary
	assert_bool(bool(claimed_cache.get("claimed", false))).is_true()
	assert_bool(bool(claimed_cache.get("claim_available", true))).is_false()
	assert_str(String(reward.get("cache_id", ""))).is_equal(RELAY_FORWARD_CACHE_ID)
	assert_int(int(reward.get("gears", 0))).is_equal(20)
	assert_str(String(reward.get("source", ""))).is_equal(RELAY_FORWARD_CACHE_ID)
	assert_str(String(feedback.get("text", ""))).is_equal(
		"Relay Forward Cache Claimed +20 Gears"
	)
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Relay Forward Cache Claimed +20 Gears")

	var hatch_ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_hatch_diagnostics"
	)
	assert_bool(bool(hatch_ready.get("available", false))).is_true()
	assert_bool(bool(hatch_ready.get("collision_blocking", false))).is_true()
	assert_str(String(hatch_ready.get("prompt_text", ""))).is_equal("Open forward hatch")

	player.global_position = hatch_ready.get("position", Vector2.ZERO) as Vector2
	assert_bool(bool(destination.call("try_open_factory_lower_deck_forward_hatch", player))).is_true()
	assert_bool(bool(destination.call("try_open_factory_lower_deck_forward_hatch", player))).is_false()

	var opened_hatch: Dictionary = destination.call(
		"get_factory_lower_deck_forward_hatch_diagnostics"
	)
	assert_bool(bool(opened_hatch.get("opened", false))).is_true()
	assert_bool(bool(opened_hatch.get("available", true))).is_false()
	assert_bool(bool(opened_hatch.get("collision_blocking", true))).is_false()
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Lower Deck Forward Hatch Opened")

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get("factory_lower_deck_post_relay_trial_defeated", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_relay_forward_reward_cache_claimed", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_forward_hatch_opened", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_shortcut_reward_cache_claimed", false))).is_true()
	assert_bool(bool(local_state.get("factory_checkpoint_overdrive_reward_cache_claimed", false))).is_false()

	var restored: Node = _instantiate_factory_scene()
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", local_state)

	var restored_cache: Dictionary = restored.call(
		"get_factory_lower_deck_relay_forward_reward_cache_diagnostics"
	)
	assert_bool(bool(restored_cache.get("claimed", false))).is_true()
	assert_bool(bool(restored_cache.get("claim_available", true))).is_false()
	var restored_hatch: Dictionary = restored.call(
		"get_factory_lower_deck_forward_hatch_diagnostics"
	)
	assert_bool(bool(restored_hatch.get("opened", false))).is_true()
	assert_bool(bool(restored_hatch.get("collision_blocking", true))).is_false()

	var restored_trial: Dictionary = restored.call(
		"get_factory_lower_deck_post_relay_trial_diagnostics"
	)
	assert_bool(bool(restored_trial.get("active", true))).is_false()
	assert_bool(bool(restored_trial.get("defeated", false))).is_true()
	assert_bool(bool(restored_trial.get("enemy_visible", true))).is_false()
	var restored_relay: Dictionary = restored.call("get_factory_lower_deck_breach_relay_diagnostics")
	assert_bool(bool(restored_relay.get("activated", false))).is_true()
	assert_int(int(restored_relay.get("activation_audio_request_count", 99))).is_equal(0)
	assert_int(int(restored_relay.get("activation_feedback_spawn_count", 99))).is_equal(0)


func _factory_scene_with_post_relay_trial_cleared(trial_cleared: bool) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _post_relay_trial_state(trial_cleared))
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


func _post_relay_trial_state(trial_cleared: bool) -> Dictionary:
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
		"factory_lower_deck_post_relay_trial_activated": trial_cleared,
		"factory_lower_deck_post_relay_trial_defeated": trial_cleared,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
		"last_return_checkpoint": {
			"id": BREACH_RELAY_SAVEPOINT_ID,
			"scene_id": String(FACTORY_SCENE_ID),
			"spawn_point": BREACH_RELAY_SPAWN_POINT,
			"position": Vector2(1218, 382),
		},
	}


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var audio_player := child as AudioStreamPlayer
			audio_player.stop()
			audio_player.stream = null
		if child is AudioStreamPlayer2D:
			var spatial_player := child as AudioStreamPlayer2D
			spatial_player.stop()
			spatial_player.stream = null
