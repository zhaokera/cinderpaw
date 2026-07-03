## Player Abilities Story 072: Old Factory forward pressure reward cache audio feedback.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FORWARD_PRESSURE_REWARD_CACHE_ID: String = (
	"old_factory_lower_deck_forward_pressure_reward_cache"
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


func test_forward_pressure_reward_cache_claim_routes_one_spatial_audio_event() -> void:
	var destination: Node = _factory_scene_with_forward_pressure_reward_ready(false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var audio_system := get_node_or_null("/root/AudioSystem")
	assert_that(player).is_not_null()
	assert_that(audio_system).is_not_null()
	if player == null or audio_system == null:
		return

	var before_cache: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_reward_cache_diagnostics"
	)
	player.global_position = before_cache.get("position", Vector2.ZERO) as Vector2
	assert_bool(bool(destination.call(
		"try_claim_factory_lower_deck_forward_pressure_reward_cache",
		player
	))).is_true()

	var claimed_cache: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_reward_cache_diagnostics"
	)
	assert_bool(bool(claimed_cache.get("claim_audio_requested", false))).is_true()
	assert_int(int(claimed_cache.get("claim_audio_request_count", 0))).is_equal(1)

	var audio_event: Dictionary = Dictionary(claimed_cache.get("claim_audio_event", {}))
	assert_str(String(audio_event.get("event_id", &""))).is_equal("reward_cache_claimed")
	assert_str(String(audio_event.get("sfx_id", &""))).is_equal("sfx_door_unlock")
	assert_vector(audio_event.get("position", Vector2.ZERO)).is_equal(
		before_cache.get("position", Vector2.ZERO) as Vector2
	)
	var event_metadata: Dictionary = Dictionary(audio_event.get("metadata", {}))
	assert_str(String(event_metadata.get("cache_id", &""))).is_equal(
		FORWARD_PRESSURE_REWARD_CACHE_ID
	)
	assert_str(String(event_metadata.get("source", &""))).is_equal(
		FORWARD_PRESSURE_REWARD_CACHE_ID
	)
	assert_int(int(event_metadata.get("gears", 0))).is_equal(20)
	assert_int(int(event_metadata.get("reward_gears", 0))).is_equal(20)
	assert_str(String(event_metadata.get("feedback_role", &""))).is_equal(
		"reward_cache_claim"
	)
	assert_str(String(event_metadata.get("scene_id", &""))).is_equal("area_03_factory")

	var runtime_event: Dictionary = audio_system.call("get_last_gameplay_audio_event")
	assert_str(String(runtime_event.get("event_id", &""))).is_equal("reward_cache_claimed")
	assert_str(String(runtime_event.get("sfx_id", &""))).is_equal("sfx_door_unlock")
	assert_vector(runtime_event.get("position", Vector2.ZERO)).is_equal(
		before_cache.get("position", Vector2.ZERO) as Vector2
	)
	var runtime_request: Dictionary = audio_system.call("get_last_sfx_request")
	assert_str(String(runtime_request.get("sfx_id", &""))).is_equal("sfx_door_unlock")
	assert_bool(bool(runtime_request.get("stream_found", false))).is_true()

	assert_bool(bool(destination.call(
		"try_claim_factory_lower_deck_forward_pressure_reward_cache",
		player
	))).is_false()
	claimed_cache = destination.call(
		"get_factory_lower_deck_forward_pressure_reward_cache_diagnostics"
	)
	assert_int(int(claimed_cache.get("claim_audio_request_count", 0))).is_equal(1)


func test_restored_forward_pressure_reward_cache_does_not_replay_audio_feedback() -> void:
	var restored: Node = _factory_scene_with_forward_pressure_reward_ready(true)
	assert_that(restored).is_not_null()
	if restored == null:
		return

	var diagnostics: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_reward_cache_diagnostics"
	)
	assert_bool(bool(diagnostics.get("claimed", false))).is_true()
	assert_bool(bool(diagnostics.get("claim_available", true))).is_false()
	assert_bool(bool(diagnostics.get("claim_audio_requested", true))).is_false()
	assert_int(int(diagnostics.get("claim_audio_request_count", -1))).is_equal(0)
	assert_bool(Dictionary(diagnostics.get("claim_audio_event", {})).is_empty()).is_true()


func _factory_scene_with_forward_pressure_reward_ready(cache_claimed: bool) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _forward_pressure_reward_base_state().merged({
		"factory_lower_deck_forward_pressure_counter_ambush_activated": true,
		"factory_lower_deck_forward_pressure_counter_ambush_defeated": true,
		"factory_lower_deck_forward_pressure_reward_cache_claimed": cache_claimed,
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


func _forward_pressure_reward_base_state() -> Dictionary:
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
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
		"last_return_checkpoint": {
			"id": "old_factory_lower_deck_breach_relay",
			"scene_id": "area_03_factory",
			"spawn_point": "lower_deck_breach_relay",
			"position": Vector2(1218, 382),
		},
	}


func _stop_runtime_audio_players() -> void:
	for child: Node in get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
			child.queue_free()
