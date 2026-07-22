## Player Abilities Story 090: Old Factory aftershock exhaust breaker corridor.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const EXIT_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_forward_pressure_exit_relay"
const EXIT_RELAY_SPAWN_POINT: String = "lower_deck_forward_pressure_exit_relay"
const BREAKER_ENTITY_ID: int = 2133
const BREAKER_HAZARD_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockExhaustBreakerVent"
)
const BREAKER_GUARD_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockExhaustBreakerCoilRat"
)
const BREAKER_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockExhaustBreaker"
)
const BREAKER_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker"
)
const BREAKER_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker"
)
const COIL_RAT_SPRITE_FRAMES: String = (
	"res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres"
)
const BREAKER_TEXTURE: String = (
	"res://assets/environment/old_factory_forward_pressure_breaker/"
	+ "env_old_factory_forward_pressure_breaker_console_256.png"
)
const STEAM_VENT_TEXTURE: String = (
	"res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png"
)
const MIN_PLAYABLE_ROUTE_RIGHT: float = 3200.0
const REQUIRED_BREAKER_ANIMATIONS: Array[StringName] = [
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


func test_breaker_corridor_requires_flank_clear_and_extends_playable_route(
) -> void:
	assert_bool(FileAccess.file_exists(COIL_RAT_SPRITE_FRAMES)).is_true()
	assert_bool(FileAccess.file_exists(BREAKER_TEXTURE)).is_true()
	assert_bool(FileAccess.file_exists(STEAM_VENT_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_breaker_state(false, false, false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	_assert_playable_route_extension(locked_scene)
	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("flank_cleared", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("coil_visible", true))).is_false()
	assert_bool(bool(locked.get("hazard_contact_active", true))).is_false()
	assert_bool(bool(locked.get("breaker_visible", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand"
	))).is_false()

	var destination: Node = _factory_scene_with_breaker_state(true, false, false, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
	)
	assert_bool(bool(ready.get("flank_cleared", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("secured", true))).is_false()
	assert_bool(bool(ready.get("cut", true))).is_false()
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Forward Pressure Exhaust Flank Cleared"
	)

	player.global_position.x = float(ready.get("activation_x", 0.0)) - 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand",
		player
	))).is_false()
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand",
		player
	))).is_true()

	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("secured", true))).is_false()
	assert_bool(bool(active.get("coil_visible", false))).is_true()
	assert_bool(bool(active.get("coil_has_target", false))).is_true()
	assert_bool(bool(active.get("coil_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("coil_process_enabled", false))).is_true()
	assert_int(int(active.get("coil_entity_id", 0))).is_equal(BREAKER_ENTITY_ID)
	assert_str(String(active.get("coil_family_id", ""))).is_equal("factory_coil_rat")
	assert_str(String(active.get("coil_sprite_frames_path", ""))).is_equal(
		COIL_RAT_SPRITE_FRAMES
	)
	_assert_breaker_frame_contract(active)
	assert_bool(bool(active.get("hazard_visible", false))).is_true()
	assert_str(String(active.get("hazard_phase", ""))).is_equal("warning")
	assert_bool(bool(active.get("hazard_contact_active", true))).is_false()
	assert_str(String(active.get("hazard_id", ""))).is_equal(BREAKER_HAZARD_ID)
	assert_int(int(active.get("hazard_damage", 0))).is_equal(8)
	assert_float(float(active.get("hazard_cooldown_sec", 0.0))).is_equal(1.0)
	assert_str(String(active.get("hazard_texture_path", ""))).is_equal(STEAM_VENT_TEXTURE)
	assert_bool(bool(active.get("breaker_visible", true))).is_false()
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Secure Aftershock Exhaust Breaker"
	)


func test_breaker_cut_persists_without_replaying_aftershock_route(
) -> void:
	var destination: Node = _factory_scene_with_breaker_state(true, false, false, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
	)
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_stand",
		player
	))).is_true()

	var breaker_vent: Area2D = destination.get_node_or_null(
		BREAKER_HAZARD_NODE_NAME
	) as Area2D
	var breaker_guard := destination.get_node_or_null(
		BREAKER_GUARD_NODE_NAME
	) as CharacterBody2D
	assert_that(breaker_vent).is_not_null()
	assert_that(breaker_guard).is_not_null()
	if breaker_vent == null or breaker_guard == null:
		return
	var breaker_collision := breaker_guard.call(
		"get_collision_component"
	) as CollisionComponent
	assert_that(breaker_collision).is_not_null()
	if breaker_collision == null:
		return

	var hp_before: int = int(player.call("get_current_hp"))
	assert_bool(bool(destination.call(
		"apply_factory_steam_vent_contact",
		breaker_vent,
		player
	))).is_false()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before)
	for _frame: int in range(20):
		await get_tree().process_frame
	var hazard_active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
	)
	assert_str(String(hazard_active.get("hazard_phase", ""))).is_equal("active")
	assert_bool(bool(hazard_active.get("hazard_contact_active", false))).is_true()
	assert_bool(bool(destination.call(
		"apply_factory_steam_vent_contact",
		breaker_vent,
		player
	))).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - 8)

	assert_bool(destination.call("apply_damage", BREAKER_ENTITY_ID, 999, {
		"source": &"unit_test_aftershock_exhaust_breaker",
	})).is_true()
	await get_tree().process_frame

	var secured: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
	)
	assert_bool(bool(secured.get("active", true))).is_false()
	assert_bool(bool(secured.get("secured", false))).is_true()
	assert_bool(bool(secured.get("coil_visible", false))).is_true()
	assert_bool(bool(secured.get("coil_process_enabled", false))).is_true()
	assert_bool(bool(secured.get("coil_physics_enabled", true))).is_false()
	assert_str(String((breaker_guard.get_node("Sprite") as AnimatedSprite2D).animation)).is_equal(
		"death"
	)
	assert_str(String(breaker_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_bool(bool(secured.get("hazard_contact_active", true))).is_false()
	assert_bool(bool(secured.get("breaker_visible", false))).is_true()
	assert_str(String(secured.get("breaker_id", ""))).is_equal(BREAKER_ID)
	assert_str(String(secured.get("prompt_text", ""))).is_equal("Cut Exhaust")
	assert_str(String(secured.get("texture_path", ""))).is_equal(BREAKER_TEXTURE)
	assert_str(String(secured.get("route_label_text", ""))).is_equal(
		"Cut Aftershock Exhaust"
	)

	var breaker_node: Node2D = destination.get_node_or_null(BREAKER_NODE_NAME) as Node2D
	assert_that(breaker_node).is_not_null()
	if breaker_node == null:
		return
	player.global_position = breaker_node.global_position
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker",
		player
	))).is_true()
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker",
		player
	))).is_false()

	var cut: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
	)
	assert_bool(bool(cut.get("cut", false))).is_true()
	assert_bool(bool(cut.get("available", true))).is_false()
	assert_bool(bool(cut.get("breaker_visible", false))).is_true()
	assert_str(String(cut.get("prompt_text", ""))).is_equal("Exhaust Cut")
	assert_str(String(cut.get("route_label_text", ""))).is_equal(
		"Aftershock Exhaust Pressure Cut"
	)
	assert_bool(bool(cut.get("unlock_feedback_played", false))).is_true()
	assert_int(int(cut.get("unlock_feedback_spawn_count", 0))).is_equal(1)
	assert_bool(bool(destination.call("is_factory_route_objective_complete"))).is_true()

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut",
		false
	))).is_true()

	var restored: Node = _factory_scene_with_breaker_state(true, true, true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return

	var restored_breaker: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
	)
	assert_bool(bool(restored_breaker.get("active", true))).is_false()
	assert_bool(bool(restored_breaker.get("secured", false))).is_true()
	assert_bool(bool(restored_breaker.get("cut", false))).is_true()
	assert_bool(bool(restored_breaker.get("coil_visible", true))).is_false()
	assert_bool(bool(restored_breaker.get("hazard_contact_active", true))).is_false()
	assert_bool(bool(restored_breaker.get("breaker_visible", false))).is_true()
	assert_int(int(restored_breaker.get("unlock_feedback_spawn_count", -1))).is_equal(0)
	assert_str(String(restored_breaker.get("route_label_text", ""))).is_equal(
		"Aftershock Exhaust Pressure Cut"
	)

	var restored_flank: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)
	assert_bool(bool(restored_flank.get("cleared", false))).is_true()
	assert_bool(bool(restored_flank.get("active", true))).is_false()
	var restored_cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	)
	assert_bool(bool(restored_cache.get("claimed", false))).is_true()
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


func _factory_scene_with_breaker_state(
		flank_cleared: bool,
		breaker_activated: bool,
		breaker_secured: bool,
		breaker_cut: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _breaker_base_state().merged({
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_activated": (
			flank_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_spark_rat_defeated": (
			flank_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_cleared": (
			flank_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated": (
			breaker_activated or breaker_secured or breaker_cut
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated": (
			breaker_secured or breaker_cut
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured": (
			breaker_secured or breaker_cut
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut": breaker_cut,
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


func _breaker_base_state() -> Dictionary:
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
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed": true,
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


func _assert_playable_route_extension(destination: Node) -> void:
	var ground_shape_node: CollisionShape2D = destination.get_node_or_null(
		"Ground/CollisionShape2D"
	) as CollisionShape2D
	var right_wall: Node2D = destination.get_node_or_null("RightWall") as Node2D
	var camera: Camera2D = destination.get_node_or_null(
		"Player/Camera2D"
	) as Camera2D
	var background: Control = destination.get_node_or_null("Background") as Control
	var post_background: Control = destination.get_node_or_null(
		"PostBulkheadBackground"
	) as Control
	assert_that(ground_shape_node).is_not_null()
	assert_that(right_wall).is_not_null()
	assert_that(camera).is_not_null()
	assert_that(background).is_not_null()
	assert_that(post_background).is_not_null()
	if (
		ground_shape_node == null
		or right_wall == null
		or camera == null
		or background == null
		or post_background == null
	):
		return

	var ground_shape: RectangleShape2D = ground_shape_node.shape as RectangleShape2D
	assert_that(ground_shape).is_not_null()
	if ground_shape == null:
		return
	assert_float(ground_shape.size.x).is_greater_equal(MIN_PLAYABLE_ROUTE_RIGHT)
	assert_float(right_wall.global_position.x).is_greater_equal(
		MIN_PLAYABLE_ROUTE_RIGHT - 24.0
	)
	assert_int(camera.limit_right).is_greater_equal(int(MIN_PLAYABLE_ROUTE_RIGHT))
	assert_float(background.size.x).is_greater_equal(MIN_PLAYABLE_ROUTE_RIGHT)
	assert_float(post_background.size.x).is_greater_equal(MIN_PLAYABLE_ROUTE_RIGHT)


func _assert_breaker_frame_contract(diagnostics: Dictionary) -> void:
	var frame_counts: Dictionary = diagnostics.get(
		"coil_animation_frame_counts",
		{}
	) as Dictionary
	for animation_name: StringName in REQUIRED_BREAKER_ANIMATIONS:
		assert_int(int(frame_counts.get(String(animation_name), 0))).is_greater_equal(
			MIN_CHARACTER_ANIMATION_FRAMES
		)


func _stop_runtime_audio_players() -> void:
	for child: Node in get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
			child.queue_free()
