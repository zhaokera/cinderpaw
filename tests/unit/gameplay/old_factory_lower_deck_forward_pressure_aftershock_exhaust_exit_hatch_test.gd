## Player Abilities Story 092: Old Factory aftershock exhaust exit hatch handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const EXIT_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_forward_pressure_exit_relay"
const EXIT_RELAY_SPAWN_POINT: String = "lower_deck_forward_pressure_exit_relay"
const EXIT_HATCH_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch"
)
const EXIT_HATCH_TEXTURE: String = (
	"res://assets/environment/old_factory_lower_deck_deep_bulkhead/"
	+ "env_old_factory_lower_deck_deep_bulkhead_closed_256.png"
)
const UNLOCK_VFX_TEXTURE: String = (
	"res://assets/environment/old_factory_deep_route/vfx/"
	+ "factory_deep_route_unlock_spark.png"
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


func test_exit_hatch_requires_escape_skirmish_clear_and_opens_once() -> void:
	assert_bool(FileAccess.file_exists(EXIT_HATCH_TEXTURE)).is_true()
	assert_bool(FileAccess.file_exists(UNLOCK_VFX_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_exit_hatch_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_open_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
		)
		or not locked_scene.has_method(
			"try_open_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("escape_skirmish_cleared", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("opened", true))).is_false()
	assert_bool(bool(locked.get("collision_blocking", true))).is_false()
	assert_str(String(locked.get("prompt_text", ""))).is_equal("Secure exhaust escape")
	assert_bool(bool(locked_scene.call(
		"try_open_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch"
	))).is_false()

	var destination: Node = _factory_scene_with_exit_hatch_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("escape_skirmish_cleared", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("opened", true))).is_false()
	assert_str(String(ready.get("hatch_id", ""))).is_equal(EXIT_HATCH_ID)
	assert_str(String(ready.get("prompt_text", ""))).is_equal("Open Exhaust Hatch")
	assert_str(String(ready.get("texture_path", ""))).is_equal(EXIT_HATCH_TEXTURE)
	assert_str(String(ready.get("unlock_feedback_texture_path", ""))).is_equal(
		UNLOCK_VFX_TEXTURE
	)
	assert_bool(bool(ready.get("interaction_monitoring", false))).is_true()
	assert_bool(bool(ready.get("interaction_monitorable", false))).is_true()
	assert_bool(bool(ready.get("collision_blocking", false))).is_true()
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Open Aftershock Exhaust Hatch"
	)

	var hatch_position: Vector2 = ready.get("position", Vector2.ZERO) as Vector2
	player.global_position = hatch_position
	assert_bool(bool(destination.call(
		"try_open_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch",
		player
	))).is_true()

	var opened: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
	)
	assert_bool(bool(opened.get("opened", false))).is_true()
	assert_bool(bool(opened.get("available", true))).is_false()
	assert_bool(bool(opened.get("visible", false))).is_true()
	assert_bool(bool(opened.get("collision_blocking", true))).is_false()
	assert_str(String(opened.get("prompt_text", ""))).is_equal("Exhaust Hatch Open")
	assert_str(String(opened.get("route_label_text", ""))).is_equal(
		"Aftershock Exhaust Exit Opened"
	)
	assert_bool(bool(opened.get("unlock_feedback_played", false))).is_true()
	assert_int(int(opened.get("unlock_feedback_spawn_count", 0))).is_equal(1)
	assert_bool(bool(destination.call(
		"try_open_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch",
		player
	))).is_false()

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened",
		false
	))).is_true()


func test_exit_hatch_restore_preserves_previous_chain_without_replay() -> void:
	var restored: Node = _factory_scene_with_exit_hatch_state(true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return

	var hatch: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
	)
	assert_bool(bool(hatch.get("present", false))).is_true()
	assert_bool(bool(hatch.get("escape_skirmish_cleared", false))).is_true()
	assert_bool(bool(hatch.get("opened", false))).is_true()
	assert_bool(bool(hatch.get("available", true))).is_false()
	assert_bool(bool(hatch.get("visible", false))).is_true()
	assert_bool(bool(hatch.get("collision_blocking", true))).is_false()
	assert_str(String(hatch.get("prompt_text", ""))).is_equal("Exhaust Hatch Open")
	assert_str(String(hatch.get("route_label_text", ""))).is_equal(
		"Aftershock Exhaust Exit Opened"
	)
	assert_int(int(hatch.get("unlock_feedback_spawn_count", -1))).is_equal(0)
	assert_bool(bool(restored.call(
		"try_open_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch"
	))).is_false()

	var local_state: Dictionary = restored.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened",
		false
	))).is_true()
	var escape: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_diagnostics"
	)
	assert_bool(bool(escape.get("cleared", false))).is_true()
	var breaker: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
	)
	assert_bool(bool(breaker.get("cut", false))).is_true()
	var flank: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)
	assert_bool(bool(flank.get("cleared", false))).is_true()
	var restored_cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	)
	assert_bool(bool(restored_cache.get("claimed", false))).is_true()
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


func _factory_scene_with_exit_hatch_state(
		escape_skirmish_cleared: bool,
		hatch_opened: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _exit_hatch_base_state().merged({
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated": (
			escape_skirmish_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_spark_rat_defeated": (
			escape_skirmish_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_coil_rat_defeated": (
			escape_skirmish_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared": (
			escape_skirmish_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened": (
			hatch_opened
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


func _exit_hatch_base_state() -> Dictionary:
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
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_cleared": true,
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
