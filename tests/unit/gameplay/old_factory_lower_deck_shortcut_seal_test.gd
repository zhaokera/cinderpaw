## Player Abilities Story 055: Old Factory lower deck shortcut seal combat gate.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_LOWER_DECK_SHORTCUT_SPARK_RAT_ENTITY_ID: int = 2110
const REQUIRED_SHORTCUT_GUARD_ANIMATIONS: Array[StringName] = [
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


func test_shortcut_seal_requires_lower_deck_exit_clear_and_keeps_service_lift_optional() -> void:
	var locked_scene: Node = _factory_scene_with_lower_deck_exit_cleared(false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method("get_factory_lower_deck_shortcut_seal_diagnostics")).is_true()
	assert_bool(locked_scene.has_method("try_activate_factory_lower_deck_shortcut_seal")).is_true()
	if (
		not locked_scene.has_method("get_factory_lower_deck_shortcut_seal_diagnostics")
		or not locked_scene.has_method("try_activate_factory_lower_deck_shortcut_seal")
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_shortcut_seal_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("unlocked", true))).is_false()
	assert_bool(bool(locked_scene.call("try_activate_factory_lower_deck_shortcut_seal"))).is_false()

	var destination: Node = _factory_scene_with_lower_deck_exit_cleared(true)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(service_lift).is_not_null()
	if player == null or service_lift == null:
		return

	var before: Dictionary = destination.call(
		"get_factory_lower_deck_shortcut_seal_diagnostics"
	)
	assert_bool(bool(before.get("present", false))).is_true()
	assert_bool(bool(before.get("available", false))).is_true()
	assert_bool(bool(before.get("active", true))).is_false()
	assert_bool(bool(before.get("guard_visible", true))).is_false()
	assert_bool(bool(before.get("seal_visible", false))).is_true()
	assert_bool(bool(before.get("seal_unlockable", true))).is_false()

	player.global_position.x = float(before.get("activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call("try_activate_factory_lower_deck_shortcut_seal", player))).is_true()

	var active: Dictionary = destination.call(
		"get_factory_lower_deck_shortcut_seal_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("guard_visible", false))).is_true()
	assert_bool(bool(active.get("guard_has_target", false))).is_true()
	assert_bool(bool(active.get("guard_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("guard_process_enabled", false))).is_true()
	assert_bool(bool(active.get("seal_unlockable", true))).is_false()
	assert_int(int(active.get("guard_entity_id", 0))).is_equal(
		FACTORY_LOWER_DECK_SHORTCUT_SPARK_RAT_ENTITY_ID
	)
	_assert_shortcut_guard_frame_contract(active)

	var objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(objective.get("objective_id", ""))).is_equal("clear_lower_deck_shortcut_guard")
	assert_str(String(objective.get("route_label_text", ""))).is_equal("Clear Shortcut Guard")

	player.global_position = service_lift.global_position
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


func test_shortcut_guard_defeat_unlocks_seal_and_persists_without_replaying_exit_ambush() -> void:
	var destination: Node = _factory_scene_with_lower_deck_exit_cleared(true)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("try_activate_factory_lower_deck_shortcut_seal")).is_true()
	assert_bool(destination.has_method("try_open_factory_lower_deck_shortcut_seal")).is_true()
	assert_bool(destination.has_method("get_factory_lower_deck_shortcut_seal_diagnostics")).is_true()
	if (
		not destination.has_method("try_activate_factory_lower_deck_shortcut_seal")
		or not destination.has_method("try_open_factory_lower_deck_shortcut_seal")
		or not destination.has_method("get_factory_lower_deck_shortcut_seal_diagnostics")
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var before: Dictionary = destination.call(
		"get_factory_lower_deck_shortcut_seal_diagnostics"
	)
	player.global_position.x = float(before.get("activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call("try_activate_factory_lower_deck_shortcut_seal", player))).is_true()

	assert_bool(destination.call("apply_damage", FACTORY_LOWER_DECK_SHORTCUT_SPARK_RAT_ENTITY_ID, 999, {
		"source": &"unit_test_lower_deck_shortcut_guard",
	})).is_true()
	await get_tree().process_frame

	var guard_cleared: Dictionary = destination.call(
		"get_factory_lower_deck_shortcut_seal_diagnostics"
	)
	assert_bool(bool(guard_cleared.get("active", true))).is_false()
	assert_bool(bool(guard_cleared.get("guard_defeated", false))).is_true()
	assert_bool(bool(guard_cleared.get("guard_visible", true))).is_false()
	assert_bool(bool(guard_cleared.get("seal_unlockable", false))).is_true()
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Open Lower Deck Shortcut")

	player.global_position = guard_cleared.get("seal_position", Vector2.ZERO) as Vector2
	assert_bool(bool(destination.call("try_open_factory_lower_deck_shortcut_seal", player))).is_true()
	assert_bool(bool(destination.call("try_open_factory_lower_deck_shortcut_seal", player))).is_false()

	var opened: Dictionary = destination.call("get_factory_lower_deck_shortcut_seal_diagnostics")
	assert_bool(bool(opened.get("unlocked", false))).is_true()
	assert_bool(bool(opened.get("collision_blocking", true))).is_false()
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Lower Deck Shortcut Opened")

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get("factory_lower_deck_shortcut_activated", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_shortcut_guard_defeated", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_shortcut_unlocked", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_exit_ambush_defeated", false))).is_true()

	var restored: Node = _instantiate_factory_scene()
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", local_state)
	var restored_shortcut: Dictionary = restored.call(
		"get_factory_lower_deck_shortcut_seal_diagnostics"
	)
	assert_bool(bool(restored_shortcut.get("active", true))).is_false()
	assert_bool(bool(restored_shortcut.get("guard_defeated", false))).is_true()
	assert_bool(bool(restored_shortcut.get("guard_visible", true))).is_false()
	assert_bool(bool(restored_shortcut.get("unlocked", false))).is_true()
	assert_bool(bool(restored_shortcut.get("collision_blocking", true))).is_false()

	var restored_ambush: Dictionary = restored.call(
		"get_factory_lower_deck_exit_ambush_diagnostics"
	)
	assert_bool(bool(restored_ambush.get("active", true))).is_false()
	assert_bool(bool(restored_ambush.get("defeated", false))).is_true()
	assert_bool(bool(restored_ambush.get("enemy_visible", true))).is_false()


func _factory_scene_with_lower_deck_exit_cleared(exit_cleared: bool) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _lower_deck_exit_state(exit_cleared))
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


func _lower_deck_exit_state(exit_cleared: bool) -> Dictionary:
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
		"factory_lower_deck_exit_ambush_activated": exit_cleared,
		"factory_lower_deck_exit_ambush_defeated": exit_cleared,
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


func _assert_shortcut_guard_frame_contract(diagnostics: Dictionary) -> void:
	var frame_counts: Dictionary = diagnostics.get("guard_animation_frame_counts", {}) as Dictionary
	for animation_name: StringName in REQUIRED_SHORTCUT_GUARD_ANIMATIONS:
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
