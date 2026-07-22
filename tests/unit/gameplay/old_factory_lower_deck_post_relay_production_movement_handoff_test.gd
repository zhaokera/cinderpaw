## Player Abilities Story 187: Post-relay trial production movement handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const POST_RELAY_ENTITY_ID: int = 2117

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


func test_player_movement_automatically_starts_visible_post_relay_trial() -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	factory.call("set_local_state", _breach_relay_secured_state())

	var player := factory.get_node_or_null("Player") as Node2D
	var enemy := factory.get_node_or_null("FactoryLowerDeckPostRelaySparkRat") as Node2D
	var hazard := factory.get_node_or_null("FactoryLowerDeckPostRelaySteamHazard") as Node2D
	var relay := factory.get_node_or_null("FactoryLowerDeckBreachRelaySavepoint") as Node2D
	var service_lift := factory.get_node_or_null("FactoryServiceLift") as Node2D
	assert_that(player).is_not_null()
	assert_that(enemy).is_not_null()
	assert_that(hazard).is_not_null()
	assert_that(relay).is_not_null()
	assert_that(service_lift).is_not_null()
	assert_bool(factory.has_method(
		"get_factory_lower_deck_post_relay_trial_diagnostics"
	)).is_true()
	if (
		player == null
		or enemy == null
		or hazard == null
		or relay == null
		or service_lift == null
		or not factory.has_method("get_factory_lower_deck_post_relay_trial_diagnostics")
	):
		return

	var before: Dictionary = factory.call(
		"get_factory_lower_deck_post_relay_trial_diagnostics"
	)
	var activation_x: float = float(before.get("activation_x", 0.0))
	assert_float(activation_x).is_equal(1232.0)
	player.global_position.x = activation_x - 1.0
	factory.call("_process", 0.0)
	var outside: Dictionary = factory.call(
		"get_factory_lower_deck_post_relay_trial_diagnostics"
	)
	assert_bool(bool(outside.get("available", false))).is_true()
	assert_bool(bool(outside.get("breach_relay_activated", false))).is_true()
	assert_bool(bool(outside.get("active", true))).is_false()
	assert_bool(bool(outside.get("enemy_visible", true))).is_false()
	assert_bool(bool(outside.get("enemy_has_target", true))).is_false()
	assert_bool(bool(outside.get("enemy_physics_enabled", true))).is_false()
	assert_bool(bool(outside.get("enemy_process_enabled", true))).is_false()
	assert_bool(bool(outside.get("hazard_active", true))).is_false()
	assert_bool(bool(outside.get("hazard_visible", true))).is_false()
	assert_str(String(
		factory.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Lower Deck Relay Secured")

	player.global_position.x = activation_x
	factory.call("_process", 0.0)
	var active: Dictionary = factory.call(
		"get_factory_lower_deck_post_relay_trial_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	if not bool(active.get("active", false)):
		return
	assert_bool(bool(active.get("enemy_visible", false))).is_true()
	assert_bool(bool(active.get("enemy_has_target", false))).is_true()
	assert_bool(bool(active.get("enemy_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("enemy_process_enabled", false))).is_true()
	assert_int(int(active.get("entity_id", 0))).is_equal(POST_RELAY_ENTITY_ID)
	assert_bool(bool(active.get("hazard_active", false))).is_true()
	assert_bool(bool(active.get("hazard_visible", false))).is_true()
	assert_str(String(active.get("hazard_id", ""))).is_equal(
		"old_factory_lower_deck_post_relay_trial"
	)
	assert_int(int(active.get("hazard_damage", 0))).is_equal(8)
	assert_float(float(active.get("hazard_cooldown_sec", 0.0))).is_equal(1.0)

	var pacing: Dictionary = active.get("pacing", {}) as Dictionary
	assert_str(String(pacing.get("pacing_state", ""))).is_equal("opening_grace")
	assert_int(int(pacing.get("opening_grace_frames", 0))).is_equal(18)
	assert_int(int(pacing.get("opening_grace_total_frames", 0))).is_equal(18)
	assert_str(String(pacing.get("current_animation", ""))).is_equal("idle")
	assert_bool(bool(pacing.get("attack_active", true))).is_false()
	var frame_counts: Dictionary = active.get("animation_frame_counts", {}) as Dictionary
	assert_int(int(frame_counts.get("idle", 0))).is_greater_equal(3)
	assert_int(int(frame_counts.get("run", 0))).is_greater_equal(3)
	assert_int(int(frame_counts.get("attack_tell", 0))).is_greater_equal(3)
	assert_int(int(frame_counts.get("attack", 0))).is_greater_equal(3)
	assert_int(int(frame_counts.get("hurt", 0))).is_greater_equal(3)
	assert_int(int(frame_counts.get("death", 0))).is_greater_equal(3)
	var objective: Dictionary = factory.call("get_factory_route_objective_diagnostics")
	assert_str(String(objective.get("objective_id", ""))).is_equal("clear_post_relay_trial")
	assert_str(String(objective.get("route_label_text", ""))).is_equal(
		"Clear Relay Forward Trial"
	)

	var cache: Dictionary = factory.call(
		"get_factory_lower_deck_relay_forward_reward_cache_diagnostics"
	)
	var hatch: Dictionary = factory.call("get_factory_lower_deck_forward_hatch_diagnostics")
	var lift: Dictionary = factory.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(cache.get("visible", true))).is_false()
	assert_bool(bool(cache.get("claim_available", true))).is_false()
	assert_bool(bool(hatch.get("visible", true))).is_false()
	assert_bool(bool(hatch.get("available", true))).is_false()
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_bool(bool(lift.get("activated", true))).is_false()
	assert_bool(bool(lift.get("exit_requested", true))).is_false()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")
	assert_bool(bool(
		factory.call("get_local_state").get(
			"factory_lower_deck_post_relay_trial_activated",
			false
		)
	)).is_true()
	assert_int(enemy.z_index).is_greater(relay.z_index)
	assert_int(enemy.z_index).is_greater(service_lift.z_index)
	assert_int(hazard.z_index).is_greater(relay.z_index)
	assert_int(hazard.z_index).is_greater(service_lift.z_index)


func _instantiate_factory_scene() -> Node:
	assert_bool(FileAccess.file_exists(FACTORY_SCENE_PATH)).is_true()
	var packed: PackedScene = load(FACTORY_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var factory: Node = packed.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	return factory


func _breach_relay_secured_state() -> Dictionary:
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
		"factory_lower_deck_post_relay_trial_activated": false,
		"factory_lower_deck_post_relay_trial_defeated": false,
		"factory_lower_deck_relay_forward_reward_cache_claimed": false,
		"factory_lower_deck_forward_hatch_opened": false,
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
