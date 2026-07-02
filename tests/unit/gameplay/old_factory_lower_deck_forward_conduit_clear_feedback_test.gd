## Player Abilities Story 068: Old Factory lower deck forward conduit clear feedback.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const BREACH_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_breach_relay"
const BREACH_RELAY_SPAWN_POINT: String = "lower_deck_breach_relay"
const FORWARD_CONDUIT_ENTITY_ID: int = 2118
const FORWARD_CONDUIT_HAZARD_ID: String = "old_factory_lower_deck_forward_conduit"
const OVERDRIVE_DEFEAT_BURST_TEXTURE: String = (
	"res://assets/environment/old_factory_overdrive_defeat_burst/"
	+ "vfx_old_factory_overdrive_defeat_burst_256.png"
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


func test_forward_conduit_clear_feedback_spawns_once_after_entity_2118_defeat() -> void:
	assert_bool(FileAccess.file_exists(OVERDRIVE_DEFEAT_BURST_TEXTURE)).is_true()

	var destination: Node = _factory_scene_with_forward_hatch_opened(true)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	)).is_true()
	assert_bool(destination.has_method("try_activate_factory_lower_deck_forward_conduit")).is_true()
	if (
		not destination.has_method(
			"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
		)
		or not destination.has_method("try_activate_factory_lower_deck_forward_conduit")
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(service_lift).is_not_null()
	if player == null or service_lift == null:
		return

	var initial_feedback: Dictionary = destination.call(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	)
	assert_bool(bool(initial_feedback.get("present", false))).is_true()
	assert_bool(bool(initial_feedback.get("visible", true))).is_false()
	assert_bool(bool(initial_feedback.get("played", true))).is_false()
	assert_int(int(initial_feedback.get("spawn_count", -1))).is_equal(0)
	assert_str(String(initial_feedback.get("texture_path", ""))).is_equal(
		OVERDRIVE_DEFEAT_BURST_TEXTURE
	)

	var before: Dictionary = destination.call(
		"get_factory_lower_deck_forward_conduit_diagnostics"
	)
	player.global_position.x = float(before.get("activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_conduit",
		player
	))).is_true()

	var active_feedback: Dictionary = destination.call(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	)
	assert_bool(bool(active_feedback.get("visible", true))).is_false()
	assert_bool(bool(active_feedback.get("played", true))).is_false()
	assert_int(int(active_feedback.get("spawn_count", -1))).is_equal(0)

	var active_conduit: Dictionary = destination.call(
		"get_factory_lower_deck_forward_conduit_diagnostics"
	)
	var enemy_position: Vector2 = active_conduit.get("enemy_position", Vector2.ZERO) as Vector2
	assert_bool(destination.call(
		"apply_damage",
		FORWARD_CONDUIT_ENTITY_ID,
		999,
		{"source": &"unit_test_forward_conduit_clear_feedback"}
	)).is_true()
	await get_tree().process_frame

	var cleared: Dictionary = destination.call(
		"get_factory_lower_deck_forward_conduit_diagnostics"
	)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("defeated", false))).is_true()
	assert_bool(bool(cleared.get("enemy_visible", true))).is_false()
	assert_bool(bool(cleared.get("hazard_active", true))).is_false()
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Forward Conduit Secured")

	var feedback: Dictionary = destination.call(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	)
	assert_bool(bool(feedback.get("present", false))).is_true()
	assert_bool(bool(feedback.get("visible", false))).is_true()
	assert_bool(bool(feedback.get("played", false))).is_true()
	assert_int(int(feedback.get("spawn_count", 0))).is_equal(1)
	assert_int(int(feedback.get("entity_id", 0))).is_equal(FORWARD_CONDUIT_ENTITY_ID)
	assert_str(String(feedback.get("hazard_id", ""))).is_equal(FORWARD_CONDUIT_HAZARD_ID)
	assert_str(String(feedback.get("asset_source", ""))).is_equal("image_generation")
	assert_str(String(feedback.get("vfx_role", ""))).is_equal("forward_conduit_clear_feedback")
	assert_str(String(feedback.get("texture_path", ""))).is_equal(OVERDRIVE_DEFEAT_BURST_TEXTURE)
	assert_vector(feedback.get("last_position", Vector2.ZERO) as Vector2).is_equal(enemy_position)

	destination.call(
		"apply_damage",
		FORWARD_CONDUIT_ENTITY_ID,
		999,
		{"source": &"unit_test_forward_conduit_clear_feedback_repeat"}
	)
	var repeated_feedback: Dictionary = destination.call(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	)
	assert_int(int(repeated_feedback.get("spawn_count", 0))).is_equal(1)

	player.global_position = service_lift.global_position
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


func test_restored_forward_conduit_clear_does_not_replay_feedback() -> void:
	var destination: Node = _factory_scene_with_forward_hatch_opened(true)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	)).is_true()
	if not destination.has_method(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	):
		return

	destination.call("set_local_state", _forward_hatch_state(true).merged({
		"factory_lower_deck_forward_conduit_activated": true,
		"factory_lower_deck_forward_conduit_defeated": true,
	}, true))

	var restored_conduit: Dictionary = destination.call(
		"get_factory_lower_deck_forward_conduit_diagnostics"
	)
	assert_bool(bool(restored_conduit.get("active", true))).is_false()
	assert_bool(bool(restored_conduit.get("defeated", false))).is_true()
	assert_bool(bool(restored_conduit.get("enemy_visible", true))).is_false()
	assert_bool(bool(restored_conduit.get("hazard_active", true))).is_false()
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Forward Conduit Secured")

	var feedback: Dictionary = destination.call(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	)
	assert_bool(bool(feedback.get("present", false))).is_true()
	assert_bool(bool(feedback.get("visible", true))).is_false()
	assert_bool(bool(feedback.get("played", true))).is_false()
	assert_int(int(feedback.get("spawn_count", -1))).is_equal(0)
	assert_str(String(feedback.get("texture_path", ""))).is_equal(OVERDRIVE_DEFEAT_BURST_TEXTURE)

	var restored_trial: Dictionary = destination.call(
		"get_factory_lower_deck_post_relay_trial_diagnostics"
	)
	assert_bool(bool(restored_trial.get("active", true))).is_false()
	assert_bool(bool(restored_trial.get("defeated", false))).is_true()
	var restored_cache: Dictionary = destination.call(
		"get_factory_lower_deck_relay_forward_reward_cache_diagnostics"
	)
	assert_bool(bool(restored_cache.get("claimed", false))).is_true()
	var restored_hatch: Dictionary = destination.call(
		"get_factory_lower_deck_forward_hatch_diagnostics"
	)
	assert_bool(bool(restored_hatch.get("opened", false))).is_true()
	var restored_relay: Dictionary = destination.call("get_factory_lower_deck_breach_relay_diagnostics")
	assert_bool(bool(restored_relay.get("activated", false))).is_true()
	assert_int(int(restored_relay.get("activation_audio_request_count", 99))).is_equal(0)
	assert_int(int(restored_relay.get("activation_feedback_spawn_count", 99))).is_equal(0)

	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(service_lift).is_not_null()
	assert_that(player).is_not_null()
	if service_lift == null or player == null:
		return
	player.global_position = service_lift.global_position
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


func _factory_scene_with_forward_hatch_opened(hatch_opened: bool) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _forward_hatch_state(hatch_opened))
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


func _forward_hatch_state(hatch_opened: bool) -> Dictionary:
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
		"factory_lower_deck_relay_forward_reward_cache_claimed": hatch_opened,
		"factory_lower_deck_forward_hatch_opened": hatch_opened,
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
