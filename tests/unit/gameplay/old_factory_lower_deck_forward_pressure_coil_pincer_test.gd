## Player Abilities Story 082: Old Factory lower deck forward-pressure Coil Pincer.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const EXIT_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_forward_pressure_exit_relay"
const EXIT_RELAY_SPAWN_POINT: String = "lower_deck_forward_pressure_exit_relay"
const PINCER_SPARK_RAT_ENTITY_ID: int = 2126
const PINCER_COIL_RAT_ENTITY_ID: int = 2127
const PINCER_SPARK_RAT_OPENING_GRACE_FRAMES: int = 10
const PINCER_COIL_RAT_OPENING_GRACE_FRAMES: int = 26
const SPARK_RAT_SPRITE_FRAMES: String = (
	"res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres"
)
const COIL_RAT_SPRITE_FRAMES: String = (
	"res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres"
)
const REQUIRED_PINCER_ANIMATIONS: Array[StringName] = [
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


func test_coil_pincer_requires_coil_rat_clear_and_activates_dual_runtime_contract() -> void:
	var locked_scene: Node = _factory_scene_with_coil_pincer_state(false, false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_coil_pincer"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_coil_pincer"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("coil_breakthrough_defeated", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("spark_visible", true))).is_false()
	assert_bool(bool(locked.get("coil_visible", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_coil_pincer"
	))).is_false()

	var destination: Node = _factory_scene_with_coil_pincer_state(true, false, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("coil_breakthrough_defeated", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("cleared", true))).is_false()
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Forward Pressure Coil Rat Breakthrough Cleared"
	)

	player.global_position.x = float(ready.get("activation_x", 0.0)) - 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_coil_pincer",
		player
	))).is_false()
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_coil_pincer",
		player
	))).is_true()

	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("cleared", true))).is_false()
	assert_bool(bool(active.get("spark_visible", false))).is_true()
	assert_bool(bool(active.get("coil_visible", false))).is_true()
	assert_bool(bool(active.get("spark_has_target", false))).is_true()
	assert_bool(bool(active.get("coil_has_target", false))).is_true()
	assert_bool(bool(active.get("spark_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("coil_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("spark_process_enabled", false))).is_true()
	assert_bool(bool(active.get("coil_process_enabled", false))).is_true()
	assert_int(int(active.get("spark_entity_id", 0))).is_equal(PINCER_SPARK_RAT_ENTITY_ID)
	assert_int(int(active.get("coil_entity_id", 0))).is_equal(PINCER_COIL_RAT_ENTITY_ID)
	assert_str(String(active.get("spark_family_id", ""))).is_equal("factory_spark_rat")
	assert_str(String(active.get("coil_family_id", ""))).is_equal("factory_coil_rat")
	assert_str(String(active.get("route_label_text", ""))).is_equal("Break Coil Pincer")
	_assert_pincer_frame_contract(active)
	_assert_pincer_pacing_contract(active)


func test_coil_pincer_defeat_persists_without_replaying_route_chain() -> void:
	var destination: Node = _factory_scene_with_coil_pincer_state(true, false, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return
	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)).is_true()
	assert_bool(destination.has_method(
		"try_activate_factory_lower_deck_forward_pressure_coil_pincer"
	)).is_true()
	if (
		not destination.has_method(
			"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
		)
		or not destination.has_method(
			"try_activate_factory_lower_deck_forward_pressure_coil_pincer"
		)
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_coil_pincer",
		player
	))).is_true()

	assert_bool(destination.call("apply_damage", PINCER_SPARK_RAT_ENTITY_ID, 999, {
		"source": &"unit_test_forward_pressure_coil_pincer_spark",
	})).is_true()
	await get_tree().process_frame
	var partial: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	assert_bool(bool(partial.get("spark_defeated", false))).is_true()
	assert_bool(bool(partial.get("coil_defeated", true))).is_false()
	assert_bool(bool(partial.get("cleared", true))).is_false()
	assert_bool(bool(destination.call("is_factory_route_objective_complete"))).is_false()

	assert_bool(destination.call("apply_damage", PINCER_COIL_RAT_ENTITY_ID, 999, {
		"source": &"unit_test_forward_pressure_coil_pincer_coil",
	})).is_true()
	await get_tree().process_frame

	var cleared: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("spark_visible", false))).is_true()
	assert_bool(bool(cleared.get("coil_visible", false))).is_true()
	assert_bool(bool(cleared.get("spark_physics_enabled", true))).is_false()
	assert_bool(bool(cleared.get("coil_physics_enabled", true))).is_false()
	var spark := destination.get_node_or_null(
		"FactoryLowerDeckForwardPressureCoilPincerSparkRat"
	) as CharacterBody2D
	var coil := destination.get_node_or_null(
		"FactoryLowerDeckForwardPressureCoilPincerCoilRat"
	) as CharacterBody2D
	assert_that(spark).is_not_null()
	assert_that(coil).is_not_null()
	if spark != null and coil != null:
		assert_str(String(
			(spark.get_node("Sprite") as AnimatedSprite2D).animation
		)).is_equal("death")
		assert_str(String(
			(coil.get_node("Sprite") as AnimatedSprite2D).animation
		)).is_equal("death")
	assert_str(String(cleared.get("route_label_text", ""))).is_equal(
		"Forward Pressure Coil Pincer Cleared"
	)
	assert_bool(bool(destination.call("is_factory_route_objective_complete"))).is_true()
	await get_tree().create_timer(0.5).timeout
	cleared = destination.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	assert_bool(bool(cleared.get("spark_visible", false))).is_true()
	assert_bool(bool(cleared.get("coil_visible", false))).is_true()

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_coil_pincer_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_coil_pincer_cleared",
		false
	))).is_true()

	var restored: Node = _factory_scene_with_coil_pincer_state(true, true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return

	var restored_pincer: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	assert_bool(bool(restored_pincer.get("present", false))).is_true()
	assert_bool(bool(restored_pincer.get("coil_breakthrough_defeated", false))).is_true()
	assert_bool(bool(restored_pincer.get("active", true))).is_false()
	assert_bool(bool(restored_pincer.get("cleared", false))).is_true()
	assert_bool(bool(restored_pincer.get("spark_visible", true))).is_false()
	assert_bool(bool(restored_pincer.get("coil_visible", true))).is_false()
	assert_str(String(restored_pincer.get("route_label_text", ""))).is_equal(
		"Forward Pressure Coil Pincer Cleared"
	)
	var coil_breakthrough: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics"
	)
	assert_bool(bool(coil_breakthrough.get("defeated", false))).is_true()
	var relief: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_relief_ambush_diagnostics"
	)
	assert_bool(bool(relief.get("defeated", false))).is_true()
	var breaker: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_breaker_diagnostics"
	)
	assert_bool(bool(breaker.get("cut", false))).is_true()
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


func _factory_scene_with_coil_pincer_state(
		coil_breakthrough_defeated: bool,
		spark_defeated: bool,
		coil_defeated: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	var pincer_cleared: bool = spark_defeated and coil_defeated
	destination.call("set_local_state", _forward_pressure_pincer_base_state().merged({
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_activated": (
			coil_breakthrough_defeated
		),
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_defeated": (
			coil_breakthrough_defeated
		),
		"factory_lower_deck_forward_pressure_coil_pincer_activated": pincer_cleared,
		"factory_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated": (
			spark_defeated
		),
		"factory_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated": (
			coil_defeated
		),
		"factory_lower_deck_forward_pressure_coil_pincer_cleared": pincer_cleared,
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


func _forward_pressure_pincer_base_state() -> Dictionary:
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
	}


func _assert_pincer_frame_contract(diagnostics: Dictionary) -> void:
	assert_bool(FileAccess.file_exists(SPARK_RAT_SPRITE_FRAMES)).is_true()
	assert_bool(FileAccess.file_exists(COIL_RAT_SPRITE_FRAMES)).is_true()
	assert_str(String(diagnostics.get("spark_sprite_frames_path", ""))).is_equal(
		SPARK_RAT_SPRITE_FRAMES
	)
	assert_str(String(diagnostics.get("coil_sprite_frames_path", ""))).is_equal(
		COIL_RAT_SPRITE_FRAMES
	)
	var spark_counts: Dictionary = diagnostics.get("spark_animation_frame_counts", {})
	var coil_counts: Dictionary = diagnostics.get("coil_animation_frame_counts", {})
	for animation_name: StringName in REQUIRED_PINCER_ANIMATIONS:
		assert_int(int(spark_counts.get(String(animation_name), 0))).is_greater_equal(
			MIN_CHARACTER_ANIMATION_FRAMES
		)
		assert_int(int(coil_counts.get(String(animation_name), 0))).is_greater_equal(
			MIN_CHARACTER_ANIMATION_FRAMES
		)


func _assert_pincer_pacing_contract(diagnostics: Dictionary) -> void:
	var pacing: Dictionary = diagnostics.get("pacing", {})
	var spark_pacing: Dictionary = pacing.get("spark", {})
	var coil_pacing: Dictionary = pacing.get("coil", {})
	assert_str(String(spark_pacing.get("pacing_state", ""))).is_equal("opening_grace")
	assert_str(String(coil_pacing.get("pacing_state", ""))).is_equal("opening_grace")
	assert_int(int(spark_pacing.get("opening_grace_frames", 0))).is_equal(
		PINCER_SPARK_RAT_OPENING_GRACE_FRAMES
	)
	assert_int(int(coil_pacing.get("opening_grace_frames", 0))).is_equal(
		PINCER_COIL_RAT_OPENING_GRACE_FRAMES
	)
