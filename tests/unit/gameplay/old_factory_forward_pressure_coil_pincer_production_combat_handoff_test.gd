## Story202: forward-pressure Coil Pincer production combat handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const ATTACK_ACTION: StringName = &"attack"
const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const PINCER_SPARK_RAT_ENTITY_ID: int = 2126
const PINCER_COIL_RAT_ENTITY_ID: int = 2127
const AFTERSHOCK_COIL_RAT_ENTITY_ID: int = 2128
const PLAYER_LIGHT_HITBOX_ID: StringName = &"cat_claw_light"

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


func test_real_attacks_clear_pincer_before_fresh_move_starts_aftershock() -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	await _wait_process_frames(18)
	factory.call("set_local_state", _pincer_active_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var spark := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureCoilPincerSparkRat"
	) as CharacterBody2D
	var coil := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureCoilPincerCoilRat"
	) as CharacterBody2D
	var aftershock := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureCoilAftershockCoilRat"
	) as CharacterBody2D
	assert_that(player).is_not_null()
	assert_that(spark).is_not_null()
	assert_that(coil).is_not_null()
	assert_that(aftershock).is_not_null()
	if player == null or spark == null or coil == null or aftershock == null:
		return

	var spark_collision := spark.call("get_collision_component") as CollisionComponent
	var coil_collision := coil.call("get_collision_component") as CollisionComponent
	var aftershock_collision := (
		aftershock.call("get_collision_component") as CollisionComponent
	)
	assert_that(spark_collision).is_not_null()
	assert_that(coil_collision).is_not_null()
	assert_that(aftershock_collision).is_not_null()
	if (
		spark_collision == null
		or coil_collision == null
		or aftershock_collision == null
	):
		return

	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("spark_visible", false))).is_true()
	assert_bool(bool(active.get("coil_visible", false))).is_true()
	assert_int(int(spark.call("get_current_hp"))).is_equal(24)
	assert_int(int(coil.call("get_current_hp"))).is_equal(24)

	var waiting_aftershock: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_aftershock_diagnostics"
	)
	assert_bool(bool(waiting_aftershock.get("available", true))).is_false()
	assert_bool(bool(waiting_aftershock.get("active", true))).is_false()
	assert_bool(bool(waiting_aftershock.get("coil_visible", true))).is_false()
	assert_str(String(aftershock_collision.get_hurtbox_state())).override_failure_message(
		"Inactive entity 2128 must not participate in Story082 player attacks"
	).is_equal(String(CollisionComponent.HURTBOX_STATE_GONE))
	assert_int(int(aftershock.call("get_current_hp"))).is_equal(24)

	assert_bool(bool(factory.call(
		"apply_damage",
		PINCER_SPARK_RAT_ENTITY_ID,
		12,
		{"source": &"story202_spark_nonlethal_setup"}
	))).is_true()
	assert_bool(bool(factory.call(
		"apply_damage",
		PINCER_COIL_RAT_ENTITY_ID,
		12,
		{"source": &"story202_coil_nonlethal_setup"}
	))).is_true()
	assert_int(int(spark.call("get_current_hp"))).is_equal(12)
	assert_int(int(coil.call("get_current_hp"))).is_equal(12)

	player.global_position = Vector2(2200.0, spark.global_position.y)
	player.velocity = Vector2.ZERO
	spark.global_position = Vector2(2168.0, spark.global_position.y)
	aftershock.global_position = spark.global_position
	await _face_player_left(player)
	var first_candidates: Array[Area2D] = [
		aftershock_collision.get_hurtbox(),
		spark_collision.get_hurtbox(),
	]
	assert_bool(await _hit_with_real_attack_input(
		player,
		first_candidates
	)).override_failure_message(
		"Story202 requires Input.attack to deliver the lethal hit to entity 2126"
	).is_true()

	var first_hit: Dictionary = factory.call("get_last_player_hit_metadata")
	assert_int(int(first_hit.get("target_id", 0))).is_equal(
		PINCER_SPARK_RAT_ENTITY_ID
	)
	assert_str(String(first_hit.get("attack_type", &""))).is_equal("light")
	assert_str(String(first_hit.get("hitbox_id", &""))).is_equal(
		String(PLAYER_LIGHT_HITBOX_ID)
	)
	assert_bool(bool(first_hit.get("damage_was_applied", false))).is_true()
	assert_int(int(spark.call("get_current_hp"))).is_equal(0)
	assert_int(int(coil.call("get_current_hp"))).is_equal(12)
	assert_int(int(aftershock.call("get_current_hp"))).override_failure_message(
		"Hidden entity 2128 must not steal damage from the active pincer"
	).is_equal(24)

	var partial: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	assert_bool(bool(partial.get("spark_defeated", false))).is_true()
	assert_bool(bool(partial.get("coil_defeated", true))).is_false()
	assert_bool(bool(partial.get("cleared", true))).is_false()
	assert_bool(bool(partial.get("spark_visible", false))).override_failure_message(
		"The first pincer death must remain visible while the survivor keeps fighting"
	).is_true()
	assert_bool(bool(partial.get("spark_physics_enabled", true))).is_false()
	assert_bool(bool(partial.get("spark_process_enabled", false))).is_true()
	assert_bool(bool(partial.get("spark_has_target", true))).is_false()
	assert_str(String((spark.get_node("Sprite") as AnimatedSprite2D).animation)).is_equal(
		"death"
	)
	assert_str(String(spark_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_bool(bool(partial.get("coil_visible", false))).is_true()
	assert_bool(bool(partial.get("coil_physics_enabled", false))).is_true()
	assert_bool(bool(partial.get("coil_process_enabled", false))).is_true()
	assert_bool(bool(partial.get("coil_has_target", false))).is_true()
	assert_str(String(coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_NORMAL)
	)
	assert_str(String(partial.get("route_label_text", ""))).is_equal(
		"Break Coil Pincer"
	)
	assert_bool(bool(factory.call("is_factory_route_objective_complete"))).is_false()

	await _finish_player_attack(player)
	player.global_position = Vector2(2220.0, coil.global_position.y)
	player.velocity = Vector2.ZERO
	coil.global_position = Vector2(2188.0, coil.global_position.y)
	aftershock.global_position = coil.global_position
	await _face_player_left(player)
	var second_candidates: Array[Area2D] = [
		aftershock_collision.get_hurtbox(),
		spark_collision.get_hurtbox(),
		coil_collision.get_hurtbox(),
	]
	assert_bool(await _hit_with_real_attack_input(
		player,
		second_candidates
	)).override_failure_message(
		"Story202 requires a second Input.attack to finish entity 2127"
	).is_true()

	var second_hit: Dictionary = factory.call("get_last_player_hit_metadata")
	assert_int(int(second_hit.get("target_id", 0))).is_equal(
		PINCER_COIL_RAT_ENTITY_ID
	)
	assert_str(String(second_hit.get("hitbox_id", &""))).is_equal(
		String(PLAYER_LIGHT_HITBOX_ID)
	)
	assert_int(int(coil.call("get_current_hp"))).is_equal(0)
	assert_int(int(aftershock.call("get_current_hp"))).is_equal(24)

	# Model residual movement from the second lethal tick; clear must still win.
	player.global_position.x += 1.0
	await _wait_until_unpaused(30)
	await _wait_process_frames(4)

	var cleared: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("coil_visible", false))).override_failure_message(
		"The final pincer death must remain visible through the clear frame"
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
		"Forward Pressure Coil Pincer Cleared"
	)
	assert_bool(bool(factory.call("is_factory_route_objective_complete"))).is_true()

	waiting_aftershock = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_aftershock_diagnostics"
	)
	assert_bool(bool(waiting_aftershock.get("available", false))).is_true()
	assert_bool(bool(waiting_aftershock.get("active", true))).override_failure_message(
		"Story083 must wait for fresh rightward movement after the pincer clear"
	).is_false()
	assert_bool(bool(waiting_aftershock.get("coil_visible", true))).is_false()
	assert_bool(bool(waiting_aftershock.get("coil_physics_enabled", true))).is_false()
	assert_bool(bool(waiting_aftershock.get("coil_process_enabled", true))).is_false()
	assert_str(String(aftershock_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_int(int(aftershock.call("get_current_hp"))).is_equal(24)

	await get_tree().create_timer(0.5).timeout
	cleared = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	assert_bool(bool(cleared.get("spark_visible", false))).is_true()
	assert_bool(bool(cleared.get("coil_visible", false))).is_true()
	waiting_aftershock = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_aftershock_diagnostics"
	)
	assert_bool(bool(waiting_aftershock.get("active", true))).is_false()

	var stationary_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(16):
		await get_tree().physics_frame
		var aftershock_probe: Dictionary = factory.call(
			"get_factory_lower_deck_forward_pressure_coil_aftershock_diagnostics"
		)
		if bool(aftershock_probe.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	var active_aftershock: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_aftershock_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(stationary_x)
	assert_bool(bool(active_aftershock.get("active", false))).is_true()
	assert_int(int(active_aftershock.get("coil_entity_id", 0))).is_equal(
		AFTERSHOCK_COIL_RAT_ENTITY_ID
	)
	assert_str(String(active_aftershock.get("coil_family_id", ""))).is_equal(
		"factory_coil_rat"
	)
	assert_bool(bool(active_aftershock.get("coil_visible", false))).is_true()
	assert_bool(bool(active_aftershock.get("coil_has_target", false))).is_true()
	assert_bool(bool(active_aftershock.get("coil_physics_enabled", false))).is_true()
	assert_bool(bool(active_aftershock.get("coil_process_enabled", false))).is_true()
	assert_str(String(aftershock_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_NORMAL)
	)
	assert_int(int(aftershock.call("get_current_hp"))).is_equal(24)
	assert_str(String(active_aftershock.get("route_label_text", ""))).is_equal(
		"Contain Coil Aftershock"
	)


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


func _finish_player_attack(player: PlayerController) -> void:
	await _wait_until_unpaused(30)
	var combat: CombatComponent = player.get_combat_component()
	if combat == null:
		return
	for _frame: int in range(30):
		if combat.get_current_state() == CombatComponent.CombatState.IDLE:
			break
		combat.advance_attack_frames(1)
	await get_tree().physics_frame


func _face_player_left(player: PlayerController) -> void:
	Input.action_press(MOVE_LEFT_ACTION)
	await _wait_physics_frames(2)
	Input.action_release(MOVE_LEFT_ACTION)
	player.velocity = Vector2.ZERO


func _instantiate_factory_scene() -> Node:
	assert_bool(FileAccess.file_exists(FACTORY_SCENE_PATH)).is_true()
	var packed := load(FACTORY_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var factory: Node = packed.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	return factory


func _pincer_active_state() -> Dictionary:
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
		"factory_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated": false,
		"factory_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated": false,
		"factory_lower_deck_forward_pressure_coil_pincer_cleared": false,
		"factory_lower_deck_forward_pressure_coil_aftershock_activated": false,
		"factory_lower_deck_forward_pressure_coil_aftershock_coil_rat_defeated": false,
		"factory_lower_deck_forward_pressure_coil_aftershock_cleared": false,
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
