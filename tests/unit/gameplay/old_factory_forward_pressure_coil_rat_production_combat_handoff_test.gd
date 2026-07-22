## Story201: forward-pressure Coil Rat production combat handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const ATTACK_ACTION: StringName = &"attack"
const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const COIL_RAT_ENTITY_ID: int = 2125
const PINCER_SPARK_RAT_ENTITY_ID: int = 2126
const PINCER_COIL_RAT_ENTITY_ID: int = 2127
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


func test_real_attack_clears_coil_rat_before_fresh_move_starts_pincer() -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	await _wait_process_frames(18)
	factory.call("set_local_state", _coil_rat_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var enemy := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureCoilRat"
	) as CharacterBody2D
	var pincer_spark := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureCoilPincerSparkRat"
	) as CharacterBody2D
	var pincer_coil := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureCoilPincerCoilRat"
	) as CharacterBody2D
	assert_that(player).is_not_null()
	assert_that(enemy).is_not_null()
	assert_that(pincer_spark).is_not_null()
	assert_that(pincer_coil).is_not_null()
	if (
		player == null
		or enemy == null
		or pincer_spark == null
		or pincer_coil == null
	):
		return

	player.global_position = Vector2(1884.0, enemy.global_position.y)
	player.velocity = Vector2.ZERO
	await _wait_physics_frames(2)
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(18):
		await get_tree().physics_frame
		var active_probe: Dictionary = factory.call(
			"get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics"
		)
		if bool(active_probe.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)

	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).override_failure_message(
		"Story201 requires real forward movement to enter the Story081 fight"
	).is_true()
	assert_int(int(active.get("entity_id", 0))).is_equal(COIL_RAT_ENTITY_ID)
	assert_int(int(enemy.call("get_current_hp"))).is_equal(24)
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Face Coil Rat Breakthrough"
	)
	if not bool(active.get("active", false)):
		return

	var waiting_pincer: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	assert_bool(bool(waiting_pincer.get("available", true))).is_false()
	assert_bool(bool(waiting_pincer.get("active", true))).is_false()
	assert_bool(bool(waiting_pincer.get("spark_visible", true))).is_false()
	assert_bool(bool(waiting_pincer.get("coil_visible", true))).is_false()
	var pincer_spark_collision := pincer_spark.call(
		"get_collision_component"
	) as CollisionComponent
	var pincer_coil_collision := pincer_coil.call(
		"get_collision_component"
	) as CollisionComponent
	assert_that(pincer_spark_collision).is_not_null()
	assert_that(pincer_coil_collision).is_not_null()
	if pincer_spark_collision == null or pincer_coil_collision == null:
		return
	assert_str(String(pincer_spark_collision.get_hurtbox_state())).override_failure_message(
		"Inactive entity 2126 must not participate in Story081 player attacks"
	).is_equal(String(CollisionComponent.HURTBOX_STATE_GONE))
	assert_str(String(pincer_coil_collision.get_hurtbox_state())).override_failure_message(
		"Inactive entity 2127 must not participate in Story081 player attacks"
	).is_equal(String(CollisionComponent.HURTBOX_STATE_GONE))
	assert_int(int(pincer_spark.call("get_current_hp"))).is_equal(24)
	assert_int(int(pincer_coil.call("get_current_hp"))).is_equal(24)

	assert_bool(bool(factory.call(
		"apply_damage",
		COIL_RAT_ENTITY_ID,
		12,
		{"source": &"story201_nonlethal_setup"}
	))).is_true()
	assert_int(int(enemy.call("get_current_hp"))).is_equal(12)

	# Hold authored locomotion still while retaining the production attack route.
	enemy.set_physics_process(false)
	enemy.global_position = Vector2(2044.0, enemy.global_position.y)
	pincer_spark.global_position = enemy.global_position
	pincer_coil.global_position = enemy.global_position
	player.global_position = Vector2(2076.0, enemy.global_position.y)
	player.velocity = Vector2.ZERO
	Input.action_press(MOVE_LEFT_ACTION)
	await _wait_physics_frames(2)
	Input.action_release(MOVE_LEFT_ACTION)
	var defeated_with_input: bool = await _defeat_enemy_with_real_attack_input(
		factory,
		player,
		enemy
	)
	assert_bool(defeated_with_input).override_failure_message(
		"Story201 requires Input.attack to deliver the lethal hit to entity 2125"
	).is_true()
	if not defeated_with_input:
		return
	assert_float(player.global_position.x).is_greater_equal(2016.0)
	assert_int(int(enemy.call("get_current_hp"))).is_equal(0)
	var lethal_hit: Dictionary = factory.call("get_last_player_hit_metadata")
	assert_int(int(lethal_hit.get("target_id", 0))).is_equal(COIL_RAT_ENTITY_ID)
	assert_str(String(lethal_hit.get("attack_type", &""))).is_equal("light")
	assert_str(String(lethal_hit.get("hitbox_id", &""))).is_equal(
		String(PLAYER_LIGHT_HITBOX_ID)
	)
	assert_bool(bool(lethal_hit.get("damage_was_applied", false))).is_true()

	# Model residual movement from the lethal tick; one clear frame must still win.
	player.global_position.x += 1.0
	await _wait_until_unpaused(30)
	await _wait_process_frames(4)

	var cleared: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics"
	)
	assert_bool(bool(cleared.get("defeated", false))).is_true()
	assert_bool(bool(cleared.get("enemy_visible", false))).override_failure_message(
		"Story201 must keep the authored death frames visible after combat is disabled"
	).is_true()
	assert_str(String(
		(cleared.get("pacing", {}) as Dictionary).get("current_animation", "")
	)).is_equal("death")
	assert_str(String(
		factory.call("get_factory_route_objective_diagnostics").get(
			"route_label_text",
			""
		)
	)).is_equal("Forward Pressure Coil Rat Breakthrough Cleared")
	var cleared_state: Dictionary = factory.call("get_local_state")
	assert_bool(bool(cleared_state.get(
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_activated",
		false
	))).is_true()
	assert_bool(bool(cleared_state.get(
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_defeated",
		false
	))).is_true()
	assert_bool(bool(cleared_state.get(
		"factory_lower_deck_forward_pressure_coil_pincer_activated",
		true
	))).is_false()

	waiting_pincer = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	assert_bool(bool(waiting_pincer.get("available", false))).is_true()
	assert_bool(bool(waiting_pincer.get("active", true))).override_failure_message(
		"Story082 must wait for fresh rightward movement after the Story081 clear"
	).is_false()
	assert_bool(bool(waiting_pincer.get("spark_visible", true))).is_false()
	assert_bool(bool(waiting_pincer.get("coil_visible", true))).is_false()
	assert_bool(bool(waiting_pincer.get("spark_physics_enabled", true))).is_false()
	assert_bool(bool(waiting_pincer.get("coil_physics_enabled", true))).is_false()
	assert_bool(bool(waiting_pincer.get("spark_process_enabled", true))).is_false()
	assert_bool(bool(waiting_pincer.get("coil_process_enabled", true))).is_false()
	assert_str(String(pincer_spark_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_str(String(pincer_coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_int(int(pincer_spark.call("get_current_hp"))).is_equal(24)
	assert_int(int(pincer_coil.call("get_current_hp"))).is_equal(24)
	await get_tree().create_timer(0.5).timeout
	cleared = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics"
	)
	assert_bool(bool(cleared.get("enemy_visible", false))).override_failure_message(
		"The completed death animation must hand off to a visible corpse hold"
	).is_true()

	var stationary_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(16):
		await get_tree().physics_frame
		var pincer_probe: Dictionary = factory.call(
			"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
		)
		if bool(pincer_probe.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	var advanced_pincer: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(stationary_x)
	assert_bool(bool(advanced_pincer.get("active", false))).is_true()
	assert_int(int(advanced_pincer.get("spark_entity_id", 0))).is_equal(
		PINCER_SPARK_RAT_ENTITY_ID
	)
	assert_int(int(advanced_pincer.get("coil_entity_id", 0))).is_equal(
		PINCER_COIL_RAT_ENTITY_ID
	)
	assert_bool(bool(advanced_pincer.get("spark_visible", false))).is_true()
	assert_bool(bool(advanced_pincer.get("coil_visible", false))).is_true()
	assert_bool(bool(advanced_pincer.get("spark_has_target", false))).is_true()
	assert_bool(bool(advanced_pincer.get("coil_has_target", false))).is_true()
	assert_bool(bool(advanced_pincer.get("spark_physics_enabled", false))).is_true()
	assert_bool(bool(advanced_pincer.get("coil_physics_enabled", false))).is_true()
	assert_bool(bool(advanced_pincer.get("spark_process_enabled", false))).is_true()
	assert_bool(bool(advanced_pincer.get("coil_process_enabled", false))).is_true()
	assert_str(String(advanced_pincer.get("spark_family_id", ""))).is_equal(
		"factory_spark_rat"
	)
	assert_str(String(advanced_pincer.get("coil_family_id", ""))).is_equal(
		"factory_coil_rat"
	)
	assert_str(String(advanced_pincer.get("route_label_text", ""))).is_equal(
		"Break Coil Pincer"
	)
	assert_str(String(pincer_spark_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_NORMAL)
	)
	assert_str(String(pincer_coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_NORMAL)
	)
	assert_int(int(pincer_spark.call("get_current_hp"))).is_equal(24)
	assert_int(int(pincer_coil.call("get_current_hp"))).is_equal(24)


func _defeat_enemy_with_real_attack_input(
	factory: Node,
	player: PlayerController,
	enemy: CharacterBody2D
) -> bool:
	var combat: CombatComponent = player.get_combat_component()
	var player_collision: CollisionComponent = player.get_collision_component()
	var enemy_collision: CollisionComponent = enemy.call(
		"get_collision_component"
	) as CollisionComponent
	if combat == null or player_collision == null or enemy_collision == null:
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
		PLAYER_LIGHT_HITBOX_ID: [enemy_collision.get_hurtbox()],
	})
	return _is_coil_rat_defeated(factory)


func _is_coil_rat_defeated(factory: Node) -> bool:
	var diagnostics: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_rat_breakthrough_diagnostics"
	)
	return bool(diagnostics.get("defeated", false))


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


func _coil_rat_ready_state() -> Dictionary:
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
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_activated": false,
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_defeated": false,
		"factory_lower_deck_forward_pressure_coil_pincer_activated": false,
		"factory_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated": false,
		"factory_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated": false,
		"factory_lower_deck_forward_pressure_coil_pincer_cleared": false,
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
	for player: AudioStreamPlayer in _find_nodes_of_type(get_tree().root, AudioStreamPlayer):
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
