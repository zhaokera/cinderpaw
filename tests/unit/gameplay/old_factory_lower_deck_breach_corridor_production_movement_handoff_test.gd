## Player Abilities Story 185: Breach corridor production movement handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"

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


func test_player_movement_automatically_starts_breach_ambush_and_pincer() -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	factory.call("set_local_state", _opened_deep_bulkhead_state())

	var player: Node2D = factory.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_bool(factory.has_method("get_factory_lower_deck_breach_corridor_diagnostics")).is_true()
	if player == null or not factory.has_method(
		"get_factory_lower_deck_breach_corridor_diagnostics"
	):
		return

	var before: Dictionary = factory.call(
		"get_factory_lower_deck_breach_corridor_diagnostics"
	)
	var activation_x: float = float(before.get("activation_x", 0.0))
	var midpoint_x: float = float(before.get("midpoint_x", 0.0))
	player.global_position.x = activation_x - 1.0
	factory.call("_process", 0.0)
	var outside: Dictionary = factory.call(
		"get_factory_lower_deck_breach_corridor_diagnostics"
	)
	assert_bool(bool(outside.get("active", true))).is_false()
	assert_bool(bool(outside.get("rear_activated", true))).is_false()

	player.global_position.x = activation_x + 1.0
	factory.call("_process", 0.0)
	var front: Dictionary = factory.call(
		"get_factory_lower_deck_breach_corridor_diagnostics"
	)
	assert_bool(bool(front.get("active", false))).is_true()
	if not bool(front.get("active", false)):
		return
	assert_bool(bool(front.get("front_visible", false))).is_true()
	assert_bool(bool(front.get("front_has_target", false))).is_true()
	assert_bool(bool(front.get("hazard_active", false))).is_true()
	assert_bool(bool(front.get("rear_activated", true))).is_false()
	assert_str(String(
		factory.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Clear Breach Corridor Ambush")

	player.global_position.x = midpoint_x + 1.0
	factory.call("_process", 0.0)
	var pincer: Dictionary = factory.call(
		"get_factory_lower_deck_breach_corridor_diagnostics"
	)
	assert_bool(bool(pincer.get("rear_activated", false))).is_true()
	if not bool(pincer.get("rear_activated", false)):
		return
	assert_bool(bool(pincer.get("rear_visible", false))).is_true()
	assert_bool(bool(pincer.get("rear_has_target", false))).is_true()
	assert_str(String(
		factory.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Survive Breach Pincer")


func test_breach_combatants_render_above_overlapping_lower_deck_endpoints() -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return

	var player := factory.get_node_or_null("Player") as Node2D
	var front := factory.get_node_or_null("FactoryLowerDeckBreachFrontSparkRat") as Node2D
	var rear := factory.get_node_or_null("FactoryLowerDeckBreachRearSparkRat") as Node2D
	var hazard := factory.get_node_or_null("FactoryLowerDeckBreachSteamHazard") as Node2D
	var bulkhead := factory.get_node_or_null("FactoryLowerDeckDeepBulkhead") as Node2D
	var service_lift := factory.get_node_or_null("FactoryServiceLift") as Node2D
	assert_that(player).is_not_null()
	assert_that(front).is_not_null()
	assert_that(rear).is_not_null()
	assert_that(hazard).is_not_null()
	assert_that(bulkhead).is_not_null()
	assert_that(service_lift).is_not_null()
	if (
		player == null
		or front == null
		or rear == null
		or hazard == null
		or bulkhead == null
		or service_lift == null
	):
		return

	var endpoint_visual_z: int = maxi(bulkhead.z_index, service_lift.z_index)
	assert_int(player.z_index).is_greater(endpoint_visual_z)
	if player.z_index <= endpoint_visual_z:
		return
	assert_int(front.z_index).is_greater(endpoint_visual_z)
	assert_int(rear.z_index).is_greater(endpoint_visual_z)
	assert_int(hazard.z_index).is_greater(endpoint_visual_z)


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


func _opened_deep_bulkhead_state() -> Dictionary:
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
