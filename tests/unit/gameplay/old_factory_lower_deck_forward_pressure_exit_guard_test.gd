## Player Abilities Story 073: Old Factory lower deck forward-pressure exit guard.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const BREACH_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_breach_relay"
const BREACH_RELAY_SPAWN_POINT: String = "lower_deck_breach_relay"
const EXIT_GUARD_ENTITY_ID: int = 2120
const EXIT_GUARD_HAZARD_ID: String = "old_factory_lower_deck_forward_pressure_exit_guard"
const STEAM_VENT_TEXTURE: String = (
	"res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png"
)
const REQUIRED_EXIT_GUARD_ANIMATIONS: Array[StringName] = [
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


func test_forward_pressure_exit_guard_requires_reward_cache_claim_and_activates_guard() -> void:
	assert_bool(FileAccess.file_exists(STEAM_VENT_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_exit_guard_state(false, false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_exit_guard"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_exit_guard"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("enemy_visible", true))).is_false()
	assert_bool(bool(locked.get("hazard_active", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_exit_guard"
	))).is_false()

	var destination: Node = _factory_scene_with_exit_guard_state(true, false, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("enemy_visible", true))).is_false()
	assert_bool(bool(ready.get("hazard_active", true))).is_false()
	assert_bool(bool(ready.get("reward_cache_claimed", false))).is_true()

	player.global_position.x = float(ready.get("activation_x", 0.0)) - 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_exit_guard",
		player
	))).is_false()
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_exit_guard",
		player
	))).is_true()

	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("defeated", true))).is_false()
	assert_bool(bool(active.get("enemy_visible", false))).is_true()
	assert_bool(bool(active.get("enemy_has_target", false))).is_true()
	assert_bool(bool(active.get("enemy_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("enemy_process_enabled", false))).is_true()
	assert_int(int(active.get("entity_id", 0))).is_equal(EXIT_GUARD_ENTITY_ID)
	_assert_exit_guard_frame_contract(active)
	assert_bool(bool(active.get("hazard_active", false))).is_true()
	assert_bool(bool(active.get("hazard_visible", false))).is_true()
	assert_str(String(active.get("hazard_id", ""))).is_equal(EXIT_GUARD_HAZARD_ID)
	assert_int(int(active.get("hazard_damage", 0))).is_equal(8)
	assert_float(float(active.get("hazard_cooldown_sec", 0.0))).is_equal(1.0)
	assert_str(String(active.get("hazard_texture_path", ""))).is_equal(STEAM_VENT_TEXTURE)
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Clear Forward Pressure Exit Guard")

	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


func test_forward_pressure_exit_guard_defeat_persists_without_replaying_forward_chain() -> void:
	var destination: Node = _factory_scene_with_exit_guard_state(true, false, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method(
		"try_activate_factory_lower_deck_forward_pressure_exit_guard"
	)).is_true()
	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
	)).is_true()
	if (
		not destination.has_method("try_activate_factory_lower_deck_forward_pressure_exit_guard")
		or not destination.has_method(
			"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
		)
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
	)
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_exit_guard",
		player
	))).is_true()
	assert_bool(destination.call(
		"apply_damage",
		EXIT_GUARD_ENTITY_ID,
		999,
		{"source": &"unit_test_forward_pressure_exit_guard"}
	)).is_true()
	await get_tree().process_frame

	var defeated: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
	)
	assert_bool(bool(defeated.get("active", true))).is_false()
	assert_bool(bool(defeated.get("defeated", false))).is_true()
	assert_bool(bool(defeated.get("enemy_visible", true))).is_false()
	assert_bool(bool(defeated.get("hazard_active", true))).is_false()
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Forward Pressure Exit Secured")

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_exit_guard_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_exit_guard_defeated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_reward_cache_claimed",
		false
	))).is_true()

	var restored: Node = _factory_scene_with_exit_guard_state(true, true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	var restored_guard: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
	)
	assert_bool(bool(restored_guard.get("active", true))).is_false()
	assert_bool(bool(restored_guard.get("defeated", false))).is_true()
	assert_bool(bool(restored_guard.get("enemy_visible", true))).is_false()
	assert_bool(bool(restored_guard.get("hazard_active", true))).is_false()
	assert_str(String(
		restored.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Forward Pressure Exit Secured")

	var restored_cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_reward_cache_diagnostics"
	)
	assert_bool(bool(restored_cache.get("claimed", false))).is_true()
	assert_int(int(restored_cache.get("claim_audio_request_count", -1))).is_equal(0)
	var restored_counter: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_counter_ambush_diagnostics"
	)
	assert_bool(bool(restored_counter.get("active", true))).is_false()
	assert_bool(bool(restored_counter.get("defeated", false))).is_true()
	var restored_pressure: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)
	assert_bool(bool(restored_pressure.get("active", true))).is_false()
	assert_bool(bool(restored_pressure.get("crossed", false))).is_true()
	var restored_clear: Dictionary = restored.call(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	)
	assert_int(int(restored_clear.get("spawn_count", -1))).is_equal(0)


func _factory_scene_with_exit_guard_state(
		reward_cache_claimed: bool,
		exit_guard_activated: bool,
		exit_guard_defeated: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _forward_pressure_reward_base_state().merged({
		"factory_lower_deck_forward_pressure_counter_ambush_activated": true,
		"factory_lower_deck_forward_pressure_counter_ambush_defeated": true,
		"factory_lower_deck_forward_pressure_reward_cache_claimed": reward_cache_claimed,
		"factory_lower_deck_forward_pressure_exit_guard_activated": exit_guard_activated,
		"factory_lower_deck_forward_pressure_exit_guard_defeated": exit_guard_defeated,
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
			"id": BREACH_RELAY_SAVEPOINT_ID,
			"scene_id": String(FACTORY_SCENE_ID),
			"spawn_point": BREACH_RELAY_SPAWN_POINT,
			"position": Vector2(1218, 382),
		},
	}


func _assert_exit_guard_frame_contract(diagnostics: Dictionary) -> void:
	var frame_counts: Dictionary = diagnostics.get("animation_frame_counts", {}) as Dictionary
	for animation_name: StringName in REQUIRED_EXIT_GUARD_ANIMATIONS:
		assert_int(int(frame_counts.get(String(animation_name), 0))).is_greater_equal(
			MIN_CHARACTER_ANIMATION_FRAMES
		)


func _stop_runtime_audio_players() -> void:
	for child: Node in get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
			child.queue_free()
