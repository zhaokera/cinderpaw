## Player Abilities Story 081: Old Factory lower deck forward-pressure Coil Rat breakthrough.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const EXIT_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_forward_pressure_exit_relay"
const EXIT_RELAY_SPAWN_POINT: String = "lower_deck_forward_pressure_exit_relay"
const COIL_RAT_ENTITY_ID: int = 2125
const COIL_RAT_SPRITE_FRAMES: String = (
	"res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres"
)
const REQUIRED_COIL_RAT_ANIMATIONS: Array[StringName] = [
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
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_coil_rat_requires_relief_clear_and_activates_runtime_contract() -> void:
	var locked_scene: Node = _factory_scene_with_coil_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_coil_rat_breakthrough"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_coil_rat_breakthrough"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("relief_defeated", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("enemy_visible", true))).is_false()
	assert_bool(bool(locked.get("enemy_physics_enabled", true))).is_false()
	assert_bool(bool(locked.get("enemy_process_enabled", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_coil_rat_breakthrough"
	))).is_false()

	var destination: Node = _factory_scene_with_coil_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("relief_defeated", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("defeated", true))).is_false()
	assert_bool(bool(ready.get("enemy_visible", true))).is_false()
	assert_bool(bool(ready.get("enemy_physics_enabled", true))).is_false()
	assert_bool(bool(ready.get("enemy_process_enabled", true))).is_false()
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Forward Pressure Relief Ambush Cleared"
	)

	player.global_position.x = float(ready.get("activation_x", 0.0)) - 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_coil_rat_breakthrough",
		player
	))).is_false()
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_coil_rat_breakthrough",
		player
	))).is_true()

	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("defeated", true))).is_false()
	assert_bool(bool(active.get("enemy_visible", false))).is_true()
	assert_bool(bool(active.get("enemy_has_target", false))).is_true()
	assert_bool(bool(active.get("enemy_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("enemy_process_enabled", false))).is_true()
	assert_int(int(active.get("entity_id", 0))).is_equal(COIL_RAT_ENTITY_ID)
	assert_str(String(active.get("enemy_family_id", ""))).is_equal("factory_coil_rat")
	_assert_coil_rat_frame_contract(active)
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Face Coil Rat Breakthrough"
	)


func test_coil_rat_defeat_persists_without_replaying_route_chain() -> void:
	var destination: Node = _factory_scene_with_coil_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return
	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics"
	)).is_true()
	assert_bool(destination.has_method(
		"try_activate_factory_lower_deck_forward_pressure_coil_rat_breakthrough"
	)).is_true()
	if (
		not destination.has_method(
			"get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics"
		)
		or not destination.has_method(
			"try_activate_factory_lower_deck_forward_pressure_coil_rat_breakthrough"
		)
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics"
	)
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_coil_rat_breakthrough",
		player
	))).is_true()
	assert_bool(destination.call(
		"apply_damage",
		COIL_RAT_ENTITY_ID,
		999,
		{"source": &"unit_test_forward_pressure_coil_rat"}
	)).is_true()
	await get_tree().process_frame

	var defeated: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics"
	)
	assert_bool(bool(defeated.get("active", true))).is_false()
	assert_bool(bool(defeated.get("defeated", false))).is_true()
	assert_bool(bool(defeated.get("enemy_visible", false))).is_true()
	assert_str(String(
		(defeated.get("pacing", {}) as Dictionary).get("current_animation", "")
	)).is_equal("death")
	assert_bool(bool(defeated.get("enemy_physics_enabled", true))).is_false()
	assert_str(String(defeated.get("route_label_text", ""))).is_equal(
		"Forward Pressure Coil Rat Breakthrough Cleared"
	)
	assert_bool(bool(destination.call("is_factory_route_objective_complete"))).is_true()
	await get_tree().create_timer(0.5).timeout
	defeated = destination.call(
		"get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics"
	)
	assert_bool(bool(defeated.get("enemy_visible", false))).is_true()

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_defeated",
		false
	))).is_true()

	var restored: Node = _factory_scene_with_coil_state(true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return

	var restored_coil: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics"
	)
	assert_bool(bool(restored_coil.get("present", false))).is_true()
	assert_bool(bool(restored_coil.get("relief_defeated", false))).is_true()
	assert_bool(bool(restored_coil.get("active", true))).is_false()
	assert_bool(bool(restored_coil.get("defeated", false))).is_true()
	assert_bool(bool(restored_coil.get("enemy_visible", true))).is_false()
	assert_str(String(restored_coil.get("route_label_text", ""))).is_equal(
		"Forward Pressure Coil Rat Breakthrough Cleared"
	)
	var relief: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_relief_ambush_diagnostics"
	)
	assert_bool(bool(relief.get("defeated", false))).is_true()
	assert_str(String(relief.get("route_label_text", ""))).is_equal(
		"Forward Pressure Relief Ambush Cleared"
	)
	var breaker: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_breaker_diagnostics"
	)
	assert_bool(bool(breaker.get("cut", false))).is_true()
	assert_str(String(breaker.get("prompt_text", ""))).is_equal("Pressure Cut")
	var relay: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
	)
	assert_bool(bool(relay.get("activated", false))).is_true()
	assert_str(String(relay.get("savepoint_id", ""))).is_equal(EXIT_RELAY_SAVEPOINT_ID)
	assert_str(String(relay.get("spawn_point", ""))).is_equal(EXIT_RELAY_SPAWN_POINT)
	var cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_reward_cache_diagnostics"
	)
	assert_bool(bool(cache.get("claimed", false))).is_true()
	assert_int(int(cache.get("claim_audio_request_count", -1))).is_equal(0)
	var clear_feedback: Dictionary = restored.call(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	)
	assert_int(int(clear_feedback.get("spawn_count", -1))).is_equal(0)
	var restored_lift: Dictionary = restored.call("get_factory_service_lift_diagnostics")
	assert_str(String(restored_lift.get("prompt_text", ""))).is_equal("Call lift")


func _factory_scene_with_coil_state(
		relief_defeated: bool,
		coil_defeated: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _forward_pressure_coil_base_state().merged({
		"factory_lower_deck_forward_pressure_breaker_activated": relief_defeated,
		"factory_lower_deck_forward_pressure_breaker_secured": relief_defeated,
		"factory_lower_deck_forward_pressure_breaker_cut": relief_defeated,
		"factory_lower_deck_forward_pressure_relief_ambush_activated": relief_defeated,
		"factory_lower_deck_forward_pressure_relief_ambush_defeated": relief_defeated,
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_activated": coil_defeated,
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_defeated": coil_defeated,
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


func _forward_pressure_coil_base_state() -> Dictionary:
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
	}


func _assert_coil_rat_frame_contract(diagnostics: Dictionary) -> void:
	assert_bool(FileAccess.file_exists(COIL_RAT_SPRITE_FRAMES)).is_true()
	assert_str(String(diagnostics.get("sprite_frames_path", ""))).is_equal(
		COIL_RAT_SPRITE_FRAMES
	)
	var frame_counts: Dictionary = diagnostics.get("animation_frame_counts", {})
	for animation_name: StringName in REQUIRED_COIL_RAT_ANIMATIONS:
		assert_int(int(frame_counts.get(String(animation_name), 0))).is_greater_equal(
			MIN_CHARACTER_ANIMATION_FRAMES
		)
