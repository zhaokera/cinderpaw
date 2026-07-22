## Story204: Coil Aftershock production combat and reward handoff.
extends GdUnitTestSuite

const FACTORY_SCENE: PackedScene = preload(
	"res://scenes/factory_route_transition_shell.tscn"
)
const ATTACK_ACTION: StringName = &"attack"
const INTERACT_ACTION: StringName = &"interact"
const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const AFTERSHOCK_ENTITY_ID: int = 2128
const PLAYER_LIGHT_HITBOX_ID: StringName = &"cat_claw_light"
const AFTERSHOCK_CACHE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockRewardCache"
)
const AFTERSHOCK_CACHE_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_reward_cache"
)

var _spawned_nodes: Array[Node] = []


func before_test() -> void:
	_release_gameplay_actions()
	get_tree().paused = false


func after_test() -> void:
	_release_gameplay_actions()
	get_tree().paused = false
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_real_combat_clears_aftershock_then_real_interact_claims_cache() -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	await _wait_process_frames(18)
	factory.call("set_local_state", _aftershock_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var coil := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureCoilAftershockCoilRat"
	) as CharacterBody2D
	var cache_node := factory.get_node_or_null(AFTERSHOCK_CACHE_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(coil).is_not_null()
	assert_that(cache_node).is_not_null()
	if player == null or coil == null or cache_node == null:
		return

	var coil_collision := coil.call("get_collision_component") as CollisionComponent
	assert_that(coil_collision).is_not_null()
	if coil_collision == null:
		return

	var waiting: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_aftershock_diagnostics"
	)
	var locked_cache: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_reward_cache_diagnostics"
	)
	assert_bool(bool(waiting.get("available", false))).is_true()
	assert_bool(bool(waiting.get("active", true))).is_false()
	assert_bool(bool(waiting.get("coil_visible", true))).is_false()
	assert_str(String(coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_bool(bool(locked_cache.get("visible", true))).is_false()
	assert_bool(bool(locked_cache.get("claim_available", true))).is_false()

	var activation_x: float = float(waiting.get("activation_x", 0.0))
	player.global_position = Vector2(activation_x - 12.0, coil.global_position.y)
	player.velocity = Vector2.ZERO
	# Prime the production previous-position tracker before the real movement edge.
	factory.call("_process", 0.0)
	var start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(16):
		await get_tree().physics_frame
		var probe: Dictionary = factory.call(
			"get_factory_lower_deck_forward_pressure_coil_aftershock_diagnostics"
		)
		if bool(probe.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)

	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_aftershock_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(start_x)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_int(int(active.get("coil_entity_id", 0))).is_equal(AFTERSHOCK_ENTITY_ID)
	assert_bool(bool(active.get("coil_visible", false))).is_true()
	assert_bool(bool(active.get("coil_has_target", false))).is_true()
	assert_bool(bool(active.get("coil_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("coil_process_enabled", false))).is_true()
	assert_str(String(coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_NORMAL)
	)
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Contain Coil Aftershock"
	)
	assert_int(int(coil.call("get_current_hp"))).is_equal(24)

	assert_bool(bool(factory.call(
		"apply_damage",
		AFTERSHOCK_ENTITY_ID,
		12,
		{"source": &"story204_nonlethal_setup"}
	))).is_true()
	assert_int(int(coil.call("get_current_hp"))).is_equal(12)

	player.global_position = Vector2(coil.global_position.x + 32.0, coil.global_position.y)
	player.velocity = Vector2.ZERO
	await _face_player_left(player)
	assert_bool(await _hit_with_real_attack_input(
		player,
		[coil_collision.get_hurtbox()]
	)).override_failure_message(
		"Story204 requires Input.attack to deliver the lethal hit to entity 2128"
	).is_true()

	var hit: Dictionary = factory.call("get_last_player_hit_metadata")
	assert_int(int(hit.get("target_id", 0))).is_equal(AFTERSHOCK_ENTITY_ID)
	assert_str(String(hit.get("attack_type", &""))).is_equal("light")
	assert_str(String(hit.get("hitbox_id", &""))).is_equal(
		String(PLAYER_LIGHT_HITBOX_ID)
	)
	assert_bool(bool(hit.get("damage_was_applied", false))).is_true()
	assert_int(int(coil.call("get_current_hp"))).is_equal(0)

	await _wait_until_unpaused(30)
	await _wait_process_frames(2)
	var cleared: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_aftershock_diagnostics"
	)
	var available_cache: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_reward_cache_diagnostics"
	)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("coil_visible", false))).override_failure_message(
		"The Coil Aftershock death animation must remain visible through the reward handoff"
	).is_true()
	assert_bool(bool(cleared.get("coil_physics_enabled", true))).is_false()
	assert_bool(bool(cleared.get("coil_process_enabled", false))).is_true()
	assert_bool(bool(cleared.get("coil_has_target", true))).is_false()
	assert_str(String((coil.get_node("Sprite") as AnimatedSprite2D).animation)).is_equal(
		"death"
	)
	assert_str(String(coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_str(String(cleared.get("route_label_text", ""))).is_equal(
		"Forward Pressure Coil Aftershock Cleared"
	)
	assert_bool(bool(available_cache.get("visible", false))).is_true()
	assert_bool(bool(available_cache.get("available", false))).is_true()
	assert_bool(bool(available_cache.get("claim_available", false))).is_true()
	assert_bool(bool(available_cache.get("claimed", true))).is_false()
	assert_str(String(available_cache.get("cache_id", ""))).is_equal(
		AFTERSHOCK_CACHE_ID
	)
	assert_str(String(available_cache.get("prompt_text", ""))).is_equal("+20 Gears")

	player.global_position = available_cache.get("position", Vector2.ZERO) as Vector2
	player.velocity = Vector2.ZERO
	assert_bool(bool(cache_node.call("is_provider_in_reward_range", player))).is_true()
	_press_interact(factory)

	var claimed_cache: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_reward_cache_diagnostics"
	)
	var claimed: bool = bool(claimed_cache.get("claimed", false))
	assert_bool(claimed).override_failure_message(
		"Story204 requires the production Input.interact route to claim the Story084 cache"
	).is_true()
	if not claimed:
		return

	var reward: Dictionary = claimed_cache.get("last_reward", {}) as Dictionary
	var feedback: Dictionary = claimed_cache.get("last_claim_feedback", {}) as Dictionary
	assert_bool(bool(claimed_cache.get("claim_available", true))).is_false()
	assert_int(int(reward.get("gears", 0))).is_equal(20)
	assert_str(String(reward.get("source", ""))).is_equal(AFTERSHOCK_CACHE_ID)
	assert_str(String(feedback.get("text", ""))).is_equal(
		"Forward Pressure Aftershock Cache Claimed +20 Gears"
	)
	assert_str(String(
		factory.call("get_factory_route_objective_diagnostics").get(
			"route_label_text",
			""
		)
	)).is_equal("Forward Pressure Aftershock Cache Claimed +20 Gears")
	assert_bool(bool(factory.call("get_local_state").get(
		"factory_lower_deck_forward_pressure_aftershock_reward_cache_claimed",
		false
	))).is_true()

	# A held press must not duplicate the once-only reward on later process frames.
	for _frame: int in range(3):
		factory.call("_process", 0.0)
	claimed_cache = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_reward_cache_diagnostics"
	)
	assert_bool(bool(claimed_cache.get("claimed", false))).is_true()
	assert_bool(bool(claimed_cache.get("claim_available", true))).is_false()
	assert_int(int((claimed_cache.get("last_reward", {}) as Dictionary).get(
		"gears",
		0
	))).is_equal(20)


func _hit_with_real_attack_input(
		player: PlayerController,
		candidates: Array[Area2D]
) -> bool:
	var combat: CombatComponent = player.get_combat_component()
	var player_collision: CollisionComponent = player.get_collision_component()
	if combat == null or player_collision == null:
		return false
	Input.action_press(ATTACK_ACTION)
	await _wait_physics_frames(2)
	Input.action_release(ATTACK_ACTION)
	var attack_frame_data: Dictionary = combat.get_light_attack_frame_data(
		combat.get_combo_index()
	)
	for _frame: int in range(int(attack_frame_data.get("total_frames", 0)) + 1):
		if player_collision.is_hitbox_active(PLAYER_LIGHT_HITBOX_ID):
			break
		combat.advance_attack_frames(1)
	if not player_collision.is_hitbox_active(PLAYER_LIGHT_HITBOX_ID):
		return false
	player_collision.process_detection_frame({
		PLAYER_LIGHT_HITBOX_ID: candidates,
	})
	return true


func _face_player_left(player: PlayerController) -> void:
	Input.action_press(MOVE_LEFT_ACTION)
	await _wait_physics_frames(2)
	Input.action_release(MOVE_LEFT_ACTION)
	player.velocity = Vector2.ZERO


func _press_interact(factory: Node) -> void:
	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)


func _instantiate_factory_scene() -> Node:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	return factory


func _aftershock_ready_state() -> Dictionary:
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
		"factory_lower_deck_forward_pressure_coil_aftershock_activated": false,
		"factory_lower_deck_forward_pressure_coil_aftershock_coil_rat_defeated": false,
		"factory_lower_deck_forward_pressure_coil_aftershock_cleared": false,
		"factory_lower_deck_forward_pressure_aftershock_reward_cache_claimed": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
	}


func _wait_physics_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().physics_frame


func _wait_process_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().process_frame


func _wait_until_unpaused(max_frames: int) -> void:
	for _frame: int in range(max_frames):
		if not get_tree().paused:
			return
		await get_tree().process_frame


func _release_gameplay_actions() -> void:
	Input.action_release(ATTACK_ACTION)
	Input.action_release(INTERACT_ACTION)
	Input.action_release(MOVE_LEFT_ACTION)
	Input.action_release(MOVE_RIGHT_ACTION)


func _stop_runtime_audio_players() -> void:
	for player: AudioStreamPlayer in _find_nodes_of_type(
		get_tree().root,
		AudioStreamPlayer
	):
		player.stop()
	for player_2d: AudioStreamPlayer2D in _find_nodes_of_type(
		get_tree().root,
		AudioStreamPlayer2D
	):
		player_2d.stop()


func _find_nodes_of_type(root: Node, expected_type: Variant) -> Array[Node]:
	var matches: Array[Node] = []
	if is_instance_of(root, expected_type):
		matches.append(root)
	for child: Node in root.get_children():
		matches.append_array(_find_nodes_of_type(child, expected_type))
	return matches
