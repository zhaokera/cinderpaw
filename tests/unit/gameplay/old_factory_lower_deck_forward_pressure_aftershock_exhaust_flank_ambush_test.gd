## Player Abilities Story 089: Old Factory lower-deck aftershock exhaust flank ambush.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const EXIT_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_forward_pressure_exit_relay"
const EXIT_RELAY_SPAWN_POINT: String = "lower_deck_forward_pressure_exit_relay"
const FLANK_SPARK_RAT_ENTITY_ID: int = 2132
const FLANK_SPARK_RAT_OPENING_GRACE_FRAMES: int = 14
const FLANK_HAZARD_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockExhaustFlankAmbushVent"
)
const FLANK_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush"
)
const SPARK_RAT_SPRITE_FRAMES: String = (
	"res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres"
)
const STEAM_VENT_TEXTURE: String = (
	"res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png"
)
const EXHAUST_PURSUER_REWARD_CACHE_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache"
)
const REQUIRED_FLANK_ANIMATIONS: Array[StringName] = [
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


func test_flank_ambush_requires_exhaust_pursuer_cache_claim_and_activates_contract(
) -> void:
	assert_bool(FileAccess.file_exists(SPARK_RAT_SPRITE_FRAMES)).is_true()
	assert_bool(FileAccess.file_exists(STEAM_VENT_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_flank_state(false, false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("exhaust_pursuer_reward_cache_claimed", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("spark_visible", true))).is_false()
	assert_bool(bool(locked.get("hazard_contact_active", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush"
	))).is_false()

	var destination: Node = _factory_scene_with_flank_state(true, false, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(service_lift).is_not_null()
	if player == null or service_lift == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("exhaust_pursuer_reward_cache_claimed", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("cleared", true))).is_false()
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Forward Pressure Exhaust Pursuer Cache Claimed +20 Gears"
	)

	player.global_position.x = float(ready.get("activation_x", 0.0)) - 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush",
		player
	))).is_false()
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush",
		player
	))).is_true()

	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("cleared", true))).is_false()
	assert_bool(bool(active.get("spark_visible", false))).is_true()
	assert_bool(bool(active.get("spark_has_target", false))).is_true()
	assert_bool(bool(active.get("spark_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("spark_process_enabled", false))).is_true()
	assert_int(int(active.get("spark_entity_id", 0))).is_equal(FLANK_SPARK_RAT_ENTITY_ID)
	assert_str(String(active.get("spark_family_id", ""))).is_equal("factory_spark_rat")
	assert_str(String(active.get("spark_sprite_frames_path", ""))).is_equal(
		SPARK_RAT_SPRITE_FRAMES
	)
	assert_bool(bool(active.get("hazard_visible", false))).is_true()
	assert_bool(bool(active.get("hazard_contact_active", false))).is_true()
	assert_str(String(active.get("hazard_id", ""))).is_equal(FLANK_HAZARD_ID)
	assert_int(int(active.get("hazard_damage", 0))).is_equal(8)
	assert_float(float(active.get("hazard_cooldown_sec", 0.0))).is_equal(1.0)
	assert_str(String(active.get("hazard_texture_path", ""))).is_equal(STEAM_VENT_TEXTURE)
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Break Aftershock Exhaust Flank"
	)
	_assert_flank_frame_contract(active)
	_assert_flank_pacing_contract(active)

	player.global_position = service_lift.global_position
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


func test_flank_ambush_hazard_damage_and_defeat_persist_without_route_replay(
) -> void:
	var destination: Node = _factory_scene_with_flank_state(true, false, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return
	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)).is_true()
	assert_bool(destination.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush"
	)).is_true()
	if (
		not destination.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
		)
		or not destination.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush"
		)
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush",
		player
	))).is_true()

	var flank_vent: Area2D = destination.get_node_or_null(FLANK_HAZARD_NODE_NAME) as Area2D
	assert_that(flank_vent).is_not_null()
	if flank_vent == null:
		return

	var non_player: Node2D = Node2D.new()
	destination.add_child(non_player)
	assert_bool(bool(destination.call(
		"apply_factory_steam_vent_contact",
		flank_vent,
		non_player
	))).is_false()
	var hp_before: int = int(player.call("get_current_hp"))
	assert_bool(bool(destination.call(
		"apply_factory_steam_vent_contact",
		flank_vent,
		player
	))).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - 8)
	var last_damage: Dictionary = destination.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	assert_str(String(last_damage.get("source", ""))).is_equal(FLANK_HAZARD_ID)

	assert_bool(destination.call("apply_damage", FLANK_SPARK_RAT_ENTITY_ID, 999, {
		"source": &"unit_test_aftershock_exhaust_flank",
	})).is_true()
	await get_tree().process_frame

	var cleared: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("spark_visible", true))).is_false()
	assert_bool(bool(cleared.get("spark_physics_enabled", true))).is_false()
	assert_bool(bool(cleared.get("spark_process_enabled", true))).is_false()
	assert_bool(bool(cleared.get("hazard_visible", true))).is_false()
	assert_bool(bool(cleared.get("hazard_contact_active", true))).is_false()
	assert_str(String(cleared.get("route_label_text", ""))).is_equal(
		"Forward Pressure Exhaust Flank Cleared"
	)
	assert_bool(bool(destination.call("is_factory_route_objective_complete"))).is_true()

	await _wait_process_frames(30)
	var settled_cleared: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)
	assert_bool(bool(settled_cleared.get("cleared", false))).is_true()
	assert_bool(bool(settled_cleared.get("spark_visible", true))).is_false()
	assert_int(int(settled_cleared.get("spark_entity_id", -1))).is_equal(0)
	assert_str(String(settled_cleared.get("route_label_text", ""))).is_equal(
		"Forward Pressure Exhaust Flank Cleared"
	)

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_spark_rat_defeated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_cleared",
		false
	))).is_true()

	var restored: Node = _factory_scene_with_flank_state(true, true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	var restored_flank: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)
	assert_bool(bool(restored_flank.get("active", true))).is_false()
	assert_bool(bool(restored_flank.get("cleared", false))).is_true()
	assert_bool(bool(restored_flank.get("spark_visible", true))).is_false()
	assert_bool(bool(restored_flank.get("hazard_contact_active", true))).is_false()
	assert_str(String(restored_flank.get("route_label_text", ""))).is_equal(
		"Forward Pressure Exhaust Flank Cleared"
	)
	var restored_cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	)
	assert_bool(bool(restored_cache.get("claimed", false))).is_true()
	var restored_pursuer: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_diagnostics"
	)
	assert_bool(bool(restored_pursuer.get("cleared", false))).is_true()
	var restored_exhaust: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_bool(bool(restored_exhaust.get("crossed", false))).is_true()
	var restored_skirmish: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exit_skirmish_diagnostics"
	)
	assert_bool(bool(restored_skirmish.get("cleared", false))).is_true()
	var restored_aftershock_cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_reward_cache_diagnostics"
	)
	assert_bool(bool(restored_aftershock_cache.get("claimed", false))).is_true()
	var restored_relay: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
	)
	assert_bool(bool(restored_relay.get("activated", false))).is_true()
	assert_str(String(restored_relay.get("savepoint_id", ""))).is_equal(
		EXIT_RELAY_SAVEPOINT_ID
	)
	assert_str(String(restored_relay.get("spawn_point", ""))).is_equal(
		EXIT_RELAY_SPAWN_POINT
	)
	var old_forward_cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_reward_cache_diagnostics"
	)
	assert_int(int(old_forward_cache.get("claim_audio_request_count", -1))).is_equal(0)
	var clear_feedback: Dictionary = restored.call(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	)
	assert_int(int(clear_feedback.get("spawn_count", -1))).is_equal(0)
	var restored_lift: Dictionary = restored.call("get_factory_service_lift_diagnostics")
	assert_str(String(restored_lift.get("prompt_text", ""))).is_equal("Call lift")


func test_flank_ambush_unlocks_on_live_story088_cache_claim() -> void:
	var destination: Node = _factory_scene_with_flank_state(false, false, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)).is_true()
	if not destination.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	):
		return

	var before_flank: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)
	assert_bool(bool(before_flank.get("available", true))).is_false()

	var cache: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	)
	assert_bool(bool(cache.get("claim_available", false))).is_true()
	player.global_position = cache.get("position", Vector2.ZERO) as Vector2
	assert_bool(bool(destination.call(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache",
		player
	))).is_true()
	await get_tree().process_frame

	var ready_flank: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)
	assert_bool(bool(ready_flank.get("exhaust_pursuer_reward_cache_claimed", false))).is_true()
	assert_bool(bool(ready_flank.get("available", false))).is_true()
	player.global_position.x = float(ready_flank.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush",
		player
	))).is_true()


func _factory_scene_with_flank_state(
		cache_claimed: bool,
		flank_activated: bool,
		flank_cleared: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _flank_base_state().merged({
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed": (
			cache_claimed
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_activated": (
			flank_activated or flank_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_spark_rat_defeated": (
			flank_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_cleared": (
			flank_cleared
		),
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


func _flank_base_state() -> Dictionary:
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
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_activated": true,
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_defeated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_activated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_cleared": true,
		"factory_lower_deck_forward_pressure_coil_aftershock_activated": true,
		"factory_lower_deck_forward_pressure_coil_aftershock_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_coil_aftershock_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_cleared": true,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
		"last_return_checkpoint": {
			"id": EXIT_RELAY_SAVEPOINT_ID,
			"scene_id": String(FACTORY_SCENE_ID),
			"spawn_point": EXIT_RELAY_SPAWN_POINT,
			"position": Vector2(1414, 382),
		},
	}


func _assert_flank_frame_contract(diagnostics: Dictionary) -> void:
	var frame_counts: Dictionary = diagnostics.get(
		"spark_animation_frame_counts",
		{}
	) as Dictionary
	for animation_name: StringName in REQUIRED_FLANK_ANIMATIONS:
		assert_int(int(frame_counts.get(String(animation_name), 0))).is_greater_equal(
			MIN_CHARACTER_ANIMATION_FRAMES
		)


func _assert_flank_pacing_contract(diagnostics: Dictionary) -> void:
	var pacing: Dictionary = diagnostics.get("pacing", {}) as Dictionary
	assert_bool(bool(pacing.get("active", false))).is_true()
	assert_int(int(pacing.get("opening_grace_frames", 0))).is_equal(
		FLANK_SPARK_RAT_OPENING_GRACE_FRAMES
	)
	assert_int(int(pacing.get("remaining_opening_grace_frames", -1))).is_equal(
		FLANK_SPARK_RAT_OPENING_GRACE_FRAMES
	)


func _wait_process_frames(frames: int) -> void:
	for _index: int in range(maxi(0, frames)):
		await get_tree().process_frame


func _stop_runtime_audio_players() -> void:
	for child: Node in get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
			child.queue_free()
