## Story199: forward-pressure breaker production combat/cut handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const ATTACK_ACTION: StringName = &"attack"
const INTERACT_ACTION: StringName = &"interact"
const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const BREAKER_ENTITY_ID: int = 2123
const RELIEF_ENTITY_ID: int = 2124
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


func test_real_attack_and_interact_cut_breaker_before_fresh_move_starts_relief(
) -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	await _wait_process_frames(18)
	factory.call("set_local_state", _breaker_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var enemy := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureBreakerSparkRat"
	) as CharacterBody2D
	var relief_enemy := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureReliefSparkRat"
	) as CharacterBody2D
	var breaker := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureBreaker"
	) as Node2D
	assert_that(player).is_not_null()
	assert_that(enemy).is_not_null()
	assert_that(relief_enemy).is_not_null()
	assert_that(breaker).is_not_null()
	if player == null or enemy == null or relief_enemy == null or breaker == null:
		return

	player.global_position = Vector2(1664.0, enemy.global_position.y)
	player.velocity = Vector2.ZERO
	await _wait_physics_frames(2)
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(18):
		await get_tree().physics_frame
		var active_probe: Dictionary = factory.call(
			"get_factory_lower_deck_forward_pressure_breaker_stand_diagnostics"
		)
		if bool(active_probe.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)

	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_breaker_stand_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).override_failure_message(
		"Story199 requires real forward movement to enter the Story079 fight"
	).is_true()
	assert_int(int(active.get("entity_id", 0))).is_equal(BREAKER_ENTITY_ID)
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Secure Forward Pressure Breaker"
	)
	if not bool(active.get("active", false)):
		return

	var waiting_relief: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_relief_ambush_diagnostics"
	)
	assert_bool(bool(waiting_relief.get("available", true))).is_false()
	assert_bool(bool(waiting_relief.get("active", true))).is_false()
	assert_bool(bool(waiting_relief.get("enemy_visible", true))).is_false()
	assert_bool(bool(waiting_relief.get("hazard_active", true))).is_false()
	var relief_collision := relief_enemy.call(
		"get_collision_component"
	) as CollisionComponent
	assert_that(relief_collision).is_not_null()
	if relief_collision == null:
		return
	assert_str(String(relief_collision.get_hurtbox_state())).override_failure_message(
		"Inactive entity 2124 must not participate in Story079 player attacks"
	).is_equal(String(CollisionComponent.HURTBOX_STATE_GONE))

	assert_bool(bool(factory.call(
		"apply_damage",
		BREAKER_ENTITY_ID,
		12,
		{"source": &"story199_nonlethal_setup"}
	))).is_true()
	assert_int(int(enemy.call("get_current_hp"))).is_equal(12)

	enemy.set_physics_process(false)
	player.global_position = Vector2(1744.0, enemy.global_position.y)
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
		"Story199 requires Input.attack to deliver the lethal hit to entity 2123"
	).is_true()
	if not defeated_with_input:
		return
	var lethal_hit: Dictionary = factory.call("get_last_player_hit_metadata")
	assert_int(int(lethal_hit.get("target_id", 0))).is_equal(BREAKER_ENTITY_ID)
	assert_str(String(lethal_hit.get("attack_type", &""))).is_equal("light")
	assert_str(String(lethal_hit.get("hitbox_id", &""))).is_equal(
		String(PLAYER_LIGHT_HITBOX_ID)
	)
	assert_bool(bool(lethal_hit.get("damage_was_applied", false))).is_true()
	await _wait_until_unpaused(30)
	await _wait_process_frames(4)

	var secured: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_breaker_stand_diagnostics"
	)
	assert_bool(bool(secured.get("active", true))).is_false()
	assert_bool(bool(secured.get("secured", false))).is_true()
	assert_bool(bool(secured.get("enemy_visible", true))).is_false()
	assert_bool(bool(secured.get("hazard_active", true))).is_false()
	assert_bool(bool(secured.get("breaker_visible", false))).is_true()
	assert_str(String(secured.get("prompt_text", ""))).is_equal("Cut Pressure")
	assert_str(String(secured.get("route_label_text", ""))).is_equal(
		"Cut Forward Pressure"
	)

	player.global_position = Vector2(1804.0, 456.0)
	player.velocity = Vector2.ZERO
	assert_bool(bool(breaker.call(
		"is_provider_in_activation_range",
		player
	))).override_failure_message(
		"Story199 fixture must be in breaker range while standing on Story080 threshold"
	).is_true()
	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	for _frame: int in range(3):
		factory.call("_process", 0.0)

	var cut: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_breaker_diagnostics"
	)
	assert_bool(bool(cut.get("cut", false))).override_failure_message(
		"Story199 requires real interact routing through handle_factory_interact_input"
	).is_true()
	assert_bool(bool(cut.get("available", true))).is_false()
	assert_bool(bool(cut.get("visible", false))).is_true()
	assert_str(String(cut.get("prompt_text", ""))).is_equal("Pressure Cut")
	assert_str(String(cut.get("route_label_text", ""))).is_equal(
		"Forward Pressure Breaker Cut"
	)
	assert_int(int(cut.get("unlock_feedback_spawn_count", 0))).is_equal(1)
	var cut_state: Dictionary = factory.call("get_local_state")
	assert_bool(bool(cut_state.get(
		"factory_lower_deck_forward_pressure_breaker_cut",
		false
	))).is_true()

	waiting_relief = factory.call(
		"get_factory_lower_deck_forward_pressure_relief_ambush_diagnostics"
	)
	assert_bool(bool(waiting_relief.get("available", false))).is_true()
	assert_bool(bool(waiting_relief.get("active", true))).override_failure_message(
		"The cut input and threshold position must not start Story080 in the same frame"
	).is_false()
	assert_bool(bool(waiting_relief.get("enemy_visible", true))).is_false()
	assert_bool(bool(waiting_relief.get("hazard_active", true))).is_false()
	assert_str(String(relief_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)

	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	for _frame: int in range(3):
		factory.call("_process", 0.0)
	waiting_relief = factory.call(
		"get_factory_lower_deck_forward_pressure_relief_ambush_diagnostics"
	)
	assert_bool(bool(waiting_relief.get("active", true))).is_false()
	assert_str(String(waiting_relief.get("route_label_text", ""))).is_equal(
		"Forward Pressure Breaker Cut"
	)

	var stationary_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(18):
		await get_tree().physics_frame
		var relief_probe: Dictionary = factory.call(
			"get_factory_lower_deck_forward_pressure_relief_ambush_diagnostics"
		)
		if bool(relief_probe.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	var advanced_relief: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_relief_ambush_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(stationary_x)
	assert_bool(bool(advanced_relief.get("active", false))).is_true()
	assert_int(int(advanced_relief.get("entity_id", 0))).is_equal(RELIEF_ENTITY_ID)
	assert_bool(bool(advanced_relief.get("enemy_visible", false))).is_true()
	assert_bool(bool(advanced_relief.get("enemy_has_target", false))).is_true()
	assert_bool(bool(advanced_relief.get("hazard_active", false))).is_true()
	assert_str(String(advanced_relief.get("route_label_text", ""))).is_equal(
		"Survive Forward Pressure Relief Ambush"
	)
	assert_str(String(relief_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_NORMAL)
	)
	assert_int(int(relief_enemy.call("get_current_hp"))).is_equal(24)


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
	return _is_breaker_secured(factory)


func _is_breaker_secured(factory: Node) -> bool:
	var diagnostics: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_breaker_stand_diagnostics"
	)
	return bool(diagnostics.get("secured", false))


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


func _breaker_ready_state() -> Dictionary:
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
		"factory_lower_deck_forward_pressure_breaker_activated": false,
		"factory_lower_deck_forward_pressure_breaker_secured": false,
		"factory_lower_deck_forward_pressure_breaker_cut": false,
		"factory_lower_deck_forward_pressure_relief_ambush_activated": false,
		"factory_lower_deck_forward_pressure_relief_ambush_defeated": false,
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
