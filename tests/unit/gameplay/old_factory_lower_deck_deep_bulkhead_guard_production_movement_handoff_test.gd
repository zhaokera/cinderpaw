## Player Abilities Story 186: Deep bulkhead guard production movement handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_DEEP_BULKHEAD_ENTITY_ID: int = 2114

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


func test_player_movement_automatically_starts_visible_deep_bulkhead_guard() -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	factory.call("set_local_state", _steam_sluice_cleared_state())

	var player := factory.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var guard := factory.get_node_or_null(
		"FactoryLowerDeckDeepBulkheadSparkRat"
	) as Node2D
	var bulkhead := factory.get_node_or_null("FactoryLowerDeckDeepBulkhead") as Node2D
	var service_lift := factory.get_node_or_null("FactoryServiceLift") as Node2D
	assert_that(player).is_not_null()
	assert_that(guard).is_not_null()
	assert_that(bulkhead).is_not_null()
	assert_that(service_lift).is_not_null()
	assert_bool(factory.has_method("get_factory_lower_deck_deep_bulkhead_diagnostics")).is_true()
	if (
			player == null
			or guard == null
			or bulkhead == null
			or service_lift == null
			or not factory.has_method("get_factory_lower_deck_deep_bulkhead_diagnostics")
		):
			return

	var before: Dictionary = factory.call(
		"get_factory_lower_deck_deep_bulkhead_diagnostics"
	)
	var activation_x: float = float(before.get("activation_x", 0.0))
	assert_float(activation_x).is_equal(1252.0)
	player.global_position.x = activation_x - 1.0
	factory.call("_process", 0.0)
	var outside: Dictionary = factory.call(
		"get_factory_lower_deck_deep_bulkhead_diagnostics"
	)
	assert_bool(bool(outside.get("available", false))).is_true()
	assert_bool(bool(outside.get("steam_sluice_defeated", false))).is_true()
	assert_bool(bool(outside.get("guard_active", true))).is_false()
	assert_bool(bool(outside.get("guard_visible", true))).is_false()
	assert_bool(bool(outside.get("guard_has_target", true))).is_false()
	assert_bool(bool(outside.get("guard_physics_enabled", true))).is_false()
	assert_bool(bool(outside.get("guard_process_enabled", true))).is_false()
	assert_bool(bool(outside.get("bulkhead_collision_blocking", true))).is_false()
	assert_str(String(
		factory.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Steam Sluice Cleared")

	player.global_position.x = activation_x
	factory.call("_process", 0.0)
	var active: Dictionary = factory.call(
		"get_factory_lower_deck_deep_bulkhead_diagnostics"
	)
	assert_bool(bool(active.get("guard_active", false))).is_true()
	if not bool(active.get("guard_active", false)):
		return
	assert_bool(bool(active.get("guard_visible", false))).is_true()
	assert_bool(bool(active.get("guard_has_target", false))).is_true()
	assert_bool(bool(active.get("guard_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("guard_process_enabled", false))).is_true()
	assert_int(int(active.get("guard_entity_id", 0))).is_equal(
		FACTORY_DEEP_BULKHEAD_ENTITY_ID
	)
	assert_str(String(
		factory.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Clear Deep Bulkhead Guard")
	var pacing: Dictionary = active.get("pacing", {}) as Dictionary
	assert_str(String(pacing.get("pacing_state", ""))).is_equal("opening_grace")
	assert_int(int(pacing.get("opening_grace_frames", 0))).is_equal(18)
	assert_int(int(pacing.get("opening_grace_total_frames", 0))).is_equal(18)
	assert_str(String(pacing.get("current_animation", ""))).is_equal("idle")
	assert_bool(bool(pacing.get("attack_active", true))).is_false()
	var frame_counts: Dictionary = active.get("guard_animation_frame_counts", {}) as Dictionary
	assert_int(int(frame_counts.get("idle", 0))).is_greater_equal(3)
	assert_int(int(frame_counts.get("run", 0))).is_greater_equal(3)
	assert_int(int(frame_counts.get("attack_tell", 0))).is_greater_equal(3)
	assert_int(int(frame_counts.get("attack", 0))).is_greater_equal(3)
	assert_int(int(frame_counts.get("hurt", 0))).is_greater_equal(3)
	assert_int(int(frame_counts.get("death", 0))).is_greater_equal(3)
	assert_bool(bool(active.get("bulkhead_collision_blocking", false))).is_true()
	assert_bool(bool(
		factory.call("get_local_state").get(
			"factory_lower_deck_deep_bulkhead_guard_activated",
			false
		)
	)).is_true()

	var lift: Dictionary = factory.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_bool(bool(lift.get("activated", true))).is_false()
	assert_bool(bool(lift.get("exit_requested", true))).is_false()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")
	assert_int(guard.z_index).is_greater(bulkhead.z_index)
	assert_int(guard.z_index).is_greater(service_lift.z_index)


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


func _steam_sluice_cleared_state() -> Dictionary:
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
		"factory_lower_deck_deep_bulkhead_guard_activated": false,
		"factory_lower_deck_deep_bulkhead_guard_defeated": false,
		"factory_lower_deck_deep_bulkhead_opened": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
		"last_return_checkpoint": {
			"id": "old_factory_return_checkpoint",
			"scene_id": "area_03_factory",
			"spawn_point": "return_checkpoint",
			"position": Vector2(704, 380),
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
