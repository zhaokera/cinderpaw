## Player Abilities Story 060: Old Factory lower deck deep bulkhead gate.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_DEEP_BULKHEAD_ENTITY_ID: int = 2114
const REQUIRED_DEEP_BULKHEAD_GUARD_ANIMATIONS: Array[StringName] = [
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


func test_deep_bulkhead_requires_steam_sluice_clear_and_keeps_lift_optional() -> void:
	var locked_scene: Node = _factory_scene_after_steam_sluice(false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_deep_bulkhead_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_deep_bulkhead_guard"
	)).is_true()
	assert_bool(locked_scene.has_method("try_open_factory_lower_deck_deep_bulkhead")).is_true()
	if (
		not locked_scene.has_method("get_factory_lower_deck_deep_bulkhead_diagnostics")
		or not locked_scene.has_method("try_activate_factory_lower_deck_deep_bulkhead_guard")
		or not locked_scene.has_method("try_open_factory_lower_deck_deep_bulkhead")
	):
		return

	var locked: Dictionary = locked_scene.call("get_factory_lower_deck_deep_bulkhead_diagnostics")
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("guard_active", true))).is_false()
	assert_bool(bool(locked.get("guard_visible", true))).is_false()
	assert_bool(bool(locked.get("bulkhead_visible", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_deep_bulkhead_guard"
	))).is_false()

	var destination: Node = _factory_scene_after_steam_sluice(true)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(service_lift).is_not_null()
	if player == null or service_lift == null:
		return

	var before: Dictionary = destination.call("get_factory_lower_deck_deep_bulkhead_diagnostics")
	assert_bool(bool(before.get("available", false))).is_true()
	assert_bool(bool(before.get("guard_active", true))).is_false()
	assert_bool(bool(before.get("guard_visible", true))).is_false()
	assert_bool(bool(before.get("bulkhead_visible", false))).is_true()

	player.global_position.x = float(before.get("activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_deep_bulkhead_guard",
		player
	))).is_true()

	var active: Dictionary = destination.call("get_factory_lower_deck_deep_bulkhead_diagnostics")
	assert_bool(bool(active.get("guard_active", false))).is_true()
	assert_bool(bool(active.get("guard_visible", false))).is_true()
	assert_bool(bool(active.get("guard_has_target", false))).is_true()
	assert_bool(bool(active.get("guard_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("guard_process_enabled", false))).is_true()
	assert_int(int(active.get("guard_entity_id", 0))).is_equal(FACTORY_DEEP_BULKHEAD_ENTITY_ID)
	_assert_deep_bulkhead_guard_frame_contract(active)

	var objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(objective.get("objective_id", ""))).is_equal("clear_deep_bulkhead_guard")
	assert_str(String(objective.get("route_label_text", ""))).is_equal(
		"Clear Deep Bulkhead Guard"
	)

	player.global_position = service_lift.global_position
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


func test_deep_bulkhead_open_persists_without_replaying_steam_sluice_chain() -> void:
	var destination: Node = _factory_scene_after_steam_sluice(true)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("try_activate_factory_lower_deck_deep_bulkhead_guard")).is_true()
	assert_bool(destination.has_method("try_open_factory_lower_deck_deep_bulkhead")).is_true()
	assert_bool(destination.has_method("get_factory_lower_deck_deep_bulkhead_diagnostics")).is_true()
	if (
		not destination.has_method("try_activate_factory_lower_deck_deep_bulkhead_guard")
		or not destination.has_method("try_open_factory_lower_deck_deep_bulkhead")
		or not destination.has_method("get_factory_lower_deck_deep_bulkhead_diagnostics")
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var before: Dictionary = destination.call("get_factory_lower_deck_deep_bulkhead_diagnostics")
	player.global_position.x = float(before.get("activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_deep_bulkhead_guard",
		player
	))).is_true()

	assert_bool(destination.call(
		"apply_damage",
		FACTORY_DEEP_BULKHEAD_ENTITY_ID,
		999,
		{"source": &"unit_test_deep_bulkhead_guard"}
	)).is_true()
	await get_tree().process_frame

	var defeated: Dictionary = destination.call("get_factory_lower_deck_deep_bulkhead_diagnostics")
	var bulkhead_prompt := destination.get_node_or_null(
		"FactoryLowerDeckDeepBulkhead/PromptLabel"
	) as Label
	assert_that(bulkhead_prompt).is_not_null()
	assert_bool(bool(defeated.get("guard_active", true))).is_false()
	assert_bool(bool(defeated.get("guard_defeated", false))).is_true()
	assert_bool(bool(defeated.get("guard_visible", true))).is_false()
	assert_bool(bool(defeated.get("bulkhead_available", false))).is_true()
	assert_bool(bool(defeated.get("bulkhead_opened", true))).is_false()
	assert_str(String(defeated.get("bulkhead_prompt_text", ""))).is_equal("Open bulkhead")
	if bulkhead_prompt != null:
		assert_bool(bulkhead_prompt.visible).is_true()
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Open Deep Bulkhead")

	player.global_position = defeated.get("bulkhead_position", Vector2.ZERO)
	assert_bool(bool(destination.call("try_open_factory_lower_deck_deep_bulkhead", player))).is_true()

	var opened: Dictionary = destination.call("get_factory_lower_deck_deep_bulkhead_diagnostics")
	assert_bool(bool(opened.get("bulkhead_opened", false))).is_true()
	assert_bool(bool(opened.get("bulkhead_available", true))).is_false()
	assert_bool(bool(opened.get("bulkhead_collision_blocking", true))).is_false()
	if bulkhead_prompt != null:
		assert_bool(bulkhead_prompt.visible).is_false()
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Deep Bulkhead Opened")

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get("factory_lower_deck_deep_bulkhead_guard_activated", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_deep_bulkhead_guard_defeated", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_deep_bulkhead_opened", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_steam_sluice_defeated", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_pressure_valve_opened", false))).is_true()

	var restored: Node = _instantiate_factory_scene()
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", local_state)

	var restored_bulkhead: Dictionary = restored.call(
		"get_factory_lower_deck_deep_bulkhead_diagnostics"
	)
	assert_bool(bool(restored_bulkhead.get("guard_active", true))).is_false()
	assert_bool(bool(restored_bulkhead.get("guard_defeated", false))).is_true()
	assert_bool(bool(restored_bulkhead.get("guard_visible", true))).is_false()
	assert_bool(bool(restored_bulkhead.get("bulkhead_opened", false))).is_true()
	assert_bool(bool(restored_bulkhead.get("bulkhead_collision_blocking", true))).is_false()

	var restored_sluice: Dictionary = restored.call("get_factory_lower_deck_steam_sluice_diagnostics")
	assert_bool(bool(restored_sluice.get("active", true))).is_false()
	assert_bool(bool(restored_sluice.get("defeated", false))).is_true()
	assert_bool(bool(restored_sluice.get("enemy_visible", true))).is_false()


func _factory_scene_after_steam_sluice(steam_sluice_defeated: bool) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _steam_sluice_state(steam_sluice_defeated))
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


func _steam_sluice_state(steam_sluice_defeated: bool) -> Dictionary:
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
		"factory_lower_deck_steam_sluice_activated": steam_sluice_defeated,
		"factory_lower_deck_steam_sluice_defeated": steam_sluice_defeated,
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


func _assert_deep_bulkhead_guard_frame_contract(diagnostics: Dictionary) -> void:
	var frame_counts: Dictionary = diagnostics.get("guard_animation_frame_counts", {}) as Dictionary
	for animation_name: StringName in REQUIRED_DEEP_BULKHEAD_GUARD_ANIMATIONS:
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
