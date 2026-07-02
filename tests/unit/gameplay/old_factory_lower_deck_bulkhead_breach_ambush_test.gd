## Player Abilities Story 061: Old Factory lower deck bulkhead breach ambush.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_BULKHEAD_BREACH_FRONT_ENTITY_ID: int = 2115
const FACTORY_BULKHEAD_BREACH_REAR_ENTITY_ID: int = 2116
const REQUIRED_BREACH_AMBUSH_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]
const MIN_CHARACTER_ANIMATION_FRAMES: int = 3

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


func test_breach_corridor_requires_opened_bulkhead_and_escalates_to_pincer() -> void:
	var locked_scene: Node = _factory_scene_after_deep_bulkhead(false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_breach_corridor_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_breach_corridor_ambush"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_breach_rear_ambusher"
	)).is_true()
	if (
		not locked_scene.has_method("get_factory_lower_deck_breach_corridor_diagnostics")
		or not locked_scene.has_method("try_activate_factory_lower_deck_breach_corridor_ambush")
		or not locked_scene.has_method("try_activate_factory_lower_deck_breach_rear_ambusher")
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_breach_corridor_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("front_visible", true))).is_false()
	assert_bool(bool(locked.get("rear_visible", true))).is_false()
	assert_bool(bool(locked.get("hazard_active", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_breach_corridor_ambush"
	))).is_false()

	var destination: Node = _factory_scene_after_deep_bulkhead(true)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(service_lift).is_not_null()
	if player == null or service_lift == null:
		return

	var before: Dictionary = destination.call("get_factory_lower_deck_breach_corridor_diagnostics")
	assert_bool(bool(before.get("available", false))).is_true()
	assert_bool(bool(before.get("active", true))).is_false()
	assert_bool(bool(before.get("secured", true))).is_false()
	assert_bool(bool(before.get("front_visible", true))).is_false()
	assert_bool(bool(before.get("rear_visible", true))).is_false()
	assert_bool(bool(before.get("hazard_active", true))).is_false()

	player.global_position.x = float(before.get("activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_breach_corridor_ambush",
		player
	))).is_true()

	var active: Dictionary = destination.call("get_factory_lower_deck_breach_corridor_diagnostics")
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("front_visible", false))).is_true()
	assert_bool(bool(active.get("front_has_target", false))).is_true()
	assert_bool(bool(active.get("front_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("front_process_enabled", false))).is_true()
	assert_bool(bool(active.get("rear_visible", true))).is_false()
	assert_bool(bool(active.get("hazard_active", false))).is_true()
	assert_int(int(active.get("front_entity_id", 0))).is_equal(
		FACTORY_BULKHEAD_BREACH_FRONT_ENTITY_ID
	)
	_assert_breach_ambush_frame_contract(active, "front_animation_frame_counts")

	var objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(objective.get("objective_id", ""))).is_equal(
		"clear_breach_corridor_ambush"
	)
	assert_str(String(objective.get("route_label_text", ""))).is_equal(
		"Clear Breach Corridor Ambush"
	)

	player.global_position.x = float(active.get("midpoint_x", 0.0)) + 8.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_breach_rear_ambusher",
		player
	))).is_true()

	var pincer: Dictionary = destination.call("get_factory_lower_deck_breach_corridor_diagnostics")
	assert_bool(bool(pincer.get("rear_activated", false))).is_true()
	assert_bool(bool(pincer.get("rear_visible", false))).is_true()
	assert_bool(bool(pincer.get("rear_has_target", false))).is_true()
	assert_bool(bool(pincer.get("rear_physics_enabled", false))).is_true()
	assert_bool(bool(pincer.get("rear_process_enabled", false))).is_true()
	assert_int(int(pincer.get("rear_entity_id", 0))).is_equal(
		FACTORY_BULKHEAD_BREACH_REAR_ENTITY_ID
	)
	_assert_breach_ambush_frame_contract(pincer, "rear_animation_frame_counts")
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Survive Breach Pincer")

	player.global_position = service_lift.global_position
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


func test_breach_corridor_secures_and_persists_without_replaying_deep_bulkhead_chain() -> void:
	var destination: Node = _factory_scene_after_deep_bulkhead(true)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method(
		"try_activate_factory_lower_deck_breach_corridor_ambush"
	)).is_true()
	assert_bool(destination.has_method(
		"try_activate_factory_lower_deck_breach_rear_ambusher"
	)).is_true()
	assert_bool(destination.has_method(
		"get_factory_lower_deck_breach_corridor_diagnostics"
	)).is_true()
	if (
		not destination.has_method("try_activate_factory_lower_deck_breach_corridor_ambush")
		or not destination.has_method("try_activate_factory_lower_deck_breach_rear_ambusher")
		or not destination.has_method("get_factory_lower_deck_breach_corridor_diagnostics")
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var before: Dictionary = destination.call("get_factory_lower_deck_breach_corridor_diagnostics")
	player.global_position.x = float(before.get("activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_breach_corridor_ambush",
		player
	))).is_true()
	var active: Dictionary = destination.call("get_factory_lower_deck_breach_corridor_diagnostics")
	player.global_position.x = float(active.get("midpoint_x", 0.0)) + 8.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_breach_rear_ambusher",
		player
	))).is_true()

	assert_bool(destination.call(
		"apply_damage",
		FACTORY_BULKHEAD_BREACH_FRONT_ENTITY_ID,
		999,
		{"source": &"unit_test_bulkhead_breach_front"}
	)).is_true()
	assert_bool(destination.call(
		"apply_damage",
		FACTORY_BULKHEAD_BREACH_REAR_ENTITY_ID,
		999,
		{"source": &"unit_test_bulkhead_breach_rear"}
	)).is_true()
	await get_tree().process_frame

	var cleared: Dictionary = destination.call("get_factory_lower_deck_breach_corridor_diagnostics")
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("secured", false))).is_true()
	assert_bool(bool(cleared.get("front_defeated", false))).is_true()
	assert_bool(bool(cleared.get("rear_defeated", false))).is_true()
	assert_bool(bool(cleared.get("front_visible", true))).is_false()
	assert_bool(bool(cleared.get("rear_visible", true))).is_false()
	assert_bool(bool(cleared.get("hazard_active", true))).is_false()
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Breach Corridor Secured")

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get("factory_lower_deck_breach_corridor_activated", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_breach_front_guard_defeated", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_breach_rear_ambusher_activated", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_breach_rear_ambusher_defeated", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_breach_corridor_secured", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_deep_bulkhead_opened", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_steam_sluice_defeated", false))).is_true()

	var restored: Node = _instantiate_factory_scene()
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", local_state)

	var restored_breach: Dictionary = restored.call(
		"get_factory_lower_deck_breach_corridor_diagnostics"
	)
	assert_bool(bool(restored_breach.get("active", true))).is_false()
	assert_bool(bool(restored_breach.get("secured", false))).is_true()
	assert_bool(bool(restored_breach.get("front_visible", true))).is_false()
	assert_bool(bool(restored_breach.get("rear_visible", true))).is_false()
	assert_bool(bool(restored_breach.get("hazard_active", true))).is_false()

	var restored_bulkhead: Dictionary = restored.call(
		"get_factory_lower_deck_deep_bulkhead_diagnostics"
	)
	assert_bool(bool(restored_bulkhead.get("bulkhead_opened", false))).is_true()
	assert_bool(bool(restored_bulkhead.get("bulkhead_collision_blocking", true))).is_false()


func _factory_scene_after_deep_bulkhead(deep_bulkhead_opened: bool) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _deep_bulkhead_state(deep_bulkhead_opened))
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


func _deep_bulkhead_state(deep_bulkhead_opened: bool) -> Dictionary:
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
		"factory_lower_deck_deep_bulkhead_guard_activated": deep_bulkhead_opened,
		"factory_lower_deck_deep_bulkhead_guard_defeated": deep_bulkhead_opened,
		"factory_lower_deck_deep_bulkhead_opened": deep_bulkhead_opened,
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


func _assert_breach_ambush_frame_contract(
	diagnostics: Dictionary,
	frame_counts_key: String
) -> void:
	var frame_counts: Dictionary = diagnostics.get(frame_counts_key, {}) as Dictionary
	for animation_name: StringName in REQUIRED_BREACH_AMBUSH_ANIMATIONS:
		var animation_key: String = String(animation_name)
		assert_bool(frame_counts.has(animation_key)).is_true()
		if frame_counts.has(animation_key):
			assert_int(int(frame_counts[animation_key])).is_greater_equal(
				MIN_CHARACTER_ANIMATION_FRAMES
			)


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
