## Story210: aftershock exhaust escape production combat/exit hatch handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const ATTACK_ACTION: StringName = &"attack"
const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const SPARK_ENTITY_ID: int = 2134
const COIL_ENTITY_ID: int = 2135
const PLAYER_LIGHT_HITBOX_ID: StringName = &"cat_claw_light"
const RAT_BITE_HITBOX_ID: StringName = &"rat_minion_bite"
const MIN_PLAYER_FLANK_DISTANCE_X: float = 128.0
const MIN_ENEMY_CENTER_DISTANCE_X: float = 300.0
const SPARK_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockExhaustEscapeSkirmishSparkRat"
)
const COIL_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockExhaustEscapeSkirmishCoilRat"
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


func test_real_dual_combat_preserves_both_deaths_before_exit_hatch_handoff(
) -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	await _wait_process_frames(2)
	factory.call("set_local_state", _escape_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var spark := factory.get_node_or_null(SPARK_NODE) as CharacterBody2D
	var coil := factory.get_node_or_null(COIL_NODE) as CharacterBody2D
	assert_that(player).is_not_null()
	assert_that(spark).is_not_null()
	assert_that(coil).is_not_null()
	if player == null or spark == null or coil == null:
		return

	var spark_collision := spark.call("get_collision_component") as CollisionComponent
	var coil_collision := coil.call("get_collision_component") as CollisionComponent
	assert_that(spark_collision).is_not_null()
	assert_that(coil_collision).is_not_null()
	if spark_collision == null or coil_collision == null:
		return

	var waiting: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_diagnostics"
	)
	var activation_x: float = float(waiting.get("activation_x", 0.0))
	player.global_position = Vector2(activation_x - 12.0, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	assert_bool(bool(waiting.get("available", false))).is_true()
	assert_bool(bool(waiting.get("active", true))).is_false()
	assert_str(String(spark_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_str(String(coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	var locked_hatch: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
	)
	assert_bool(bool(locked_hatch.get("available", true))).is_false()
	assert_bool(bool(locked_hatch.get("visible", true))).is_false()
	assert_bool(bool(locked_hatch.get("interaction_monitoring", true))).is_false()
	assert_bool(bool(locked_hatch.get("interaction_monitorable", true))).is_false()
	assert_bool(bool(locked_hatch.get("collision_disabled", false))).is_true()
	assert_bool(bool(locked_hatch.get("collision_blocking", true))).is_false()

	var start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(18):
		await get_tree().physics_frame
		waiting = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_diagnostics"
		)
		if bool(waiting.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO

	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(start_x)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("spark_visible", false))).is_true()
	assert_bool(bool(active.get("coil_visible", false))).is_true()
	assert_bool(bool(active.get("spark_has_target", false))).is_true()
	assert_bool(bool(active.get("coil_has_target", false))).is_true()
	assert_int(int(spark.call("get_current_hp"))).is_equal(24)
	assert_int(int(coil.call("get_current_hp"))).is_equal(24)
	assert_str(String(spark_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_NORMAL)
	)
	assert_str(String(coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_NORMAL)
	)
	assert_float(spark.global_position.x - player.global_position.x).override_failure_message(
		"Story210 needs a readable forward Spark Rat flank"
	).is_greater_equal(MIN_PLAYER_FLANK_DISTANCE_X)
	assert_float(player.global_position.x - coil.global_position.x).override_failure_message(
		"Story210 needs a readable rear Coil Rat flank"
	).is_greater_equal(MIN_PLAYER_FLANK_DISTANCE_X)
	assert_float(absf(coil.global_position.x - spark.global_position.x)).override_failure_message(
		"Story210 must replace the legacy 44px dual-enemy overlap"
	).is_greater_equal(MIN_ENEMY_CENTER_DISTANCE_X)
	var pacing: Dictionary = active.get("pacing", {}) as Dictionary
	var spark_pacing: Dictionary = pacing.get("spark", {}) as Dictionary
	var coil_pacing: Dictionary = pacing.get("coil", {}) as Dictionary
	assert_int(int(spark_pacing.get("opening_grace_total_frames", 0))).is_equal(10)
	assert_int(int(coil_pacing.get("opening_grace_total_frames", 0))).is_equal(22)

	spark.set_process(false)
	spark.set_physics_process(false)
	coil.set_process(false)
	coil.set_physics_process(false)
	var spark_bite: Dictionary = await _receive_real_bite(
		factory,
		spark,
		spark_collision,
		player,
		9
	)
	assert_str(String(spark_bite.get("source", ""))).is_equal("factory_spark_rat")
	assert_str(String(spark_bite.get("weapon_id", ""))).is_equal(
		"factory_spark_rat_bite"
	)
	assert_int(int(spark_bite.get("attacker_id", 0))).is_equal(SPARK_ENTITY_ID)
	assert_int(int(spark_bite.get("target_id", 0))).is_equal(1)

	var coil_bite: Dictionary = await _receive_real_bite(
		factory,
		coil,
		coil_collision,
		player,
		10
	)
	assert_str(String(coil_bite.get("source", ""))).is_equal("factory_coil_rat")
	assert_str(String(coil_bite.get("weapon_id", ""))).is_equal(
		"factory_coil_rat_bite"
	)
	assert_int(int(coil_bite.get("attacker_id", 0))).is_equal(COIL_ENTITY_ID)
	assert_int(int(coil_bite.get("target_id", 0))).is_equal(1)

	assert_bool(bool(factory.call(
		"apply_damage",
		SPARK_ENTITY_ID,
		12,
		{"source": &"story210_spark_nonlethal_setup"}
	))).is_true()
	assert_bool(bool(factory.call(
		"apply_damage",
		COIL_ENTITY_ID,
		12,
		{"source": &"story210_coil_nonlethal_setup"}
	))).is_true()
	assert_int(int(spark.call("get_current_hp"))).is_equal(12)
	assert_int(int(coil.call("get_current_hp"))).is_equal(12)

	player.global_position = spark.global_position + Vector2(32.0, 0.0)
	player.velocity = Vector2.ZERO
	await _face_player_left(player)
	assert_bool(await _hit_with_real_attack_input(
		player,
		[spark_collision.get_hurtbox()]
	)).is_true()
	assert_int(int(spark.call("get_current_hp"))).is_equal(0)
	assert_int(int(coil.call("get_current_hp"))).is_equal(12)
	var first_hit: Dictionary = factory.call("get_last_player_hit_metadata")
	assert_int(int(first_hit.get("target_id", 0))).is_equal(SPARK_ENTITY_ID)
	assert_str(String(first_hit.get("hitbox_id", ""))).is_equal(
		String(PLAYER_LIGHT_HITBOX_ID)
	)

	var partial: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_diagnostics"
	)
	assert_bool(bool(partial.get("cleared", true))).is_false()
	assert_bool(bool(partial.get("spark_visible", false))).is_true()
	assert_bool(bool(partial.get("spark_process_enabled", false))).is_true()
	assert_bool(bool(partial.get("spark_physics_enabled", true))).is_false()
	assert_bool(bool(partial.get("spark_has_target", true))).is_false()
	assert_bool(bool(partial.get("coil_visible", false))).is_true()
	assert_bool(bool(partial.get("coil_process_enabled", false))).is_true()
	assert_bool(bool(partial.get("coil_physics_enabled", false))).is_true()
	assert_bool(bool(partial.get("coil_has_target", false))).is_true()
	assert_str(String((spark.get_node("Sprite") as AnimatedSprite2D).animation)).is_equal(
		"death"
	)
	assert_str(String(spark_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_int(int(spark.collision_layer)).is_equal(0)
	assert_int(int(spark.collision_mask)).is_equal(0)
	assert_bool(spark_collision.is_hitbox_active(RAT_BITE_HITBOX_ID)).is_false()
	locked_hatch = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
	)
	assert_bool(bool(locked_hatch.get("available", true))).is_false()
	assert_bool(bool(locked_hatch.get("visible", true))).is_false()
	assert_bool(bool(locked_hatch.get("opened", true))).is_false()
	assert_bool(bool(locked_hatch.get("interaction_monitoring", true))).is_false()
	assert_bool(bool(locked_hatch.get("collision_disabled", false))).is_true()
	assert_bool(bool(locked_hatch.get("collision_blocking", true))).is_false()

	assert_bool(await _wait_for_player_combat_idle(player, 60)).is_true()
	coil.set_process(false)
	coil.set_physics_process(false)
	player.global_position = coil.global_position + Vector2(32.0, 0.0)
	player.velocity = Vector2.ZERO
	await _face_player_left(player)
	assert_bool(await _hit_with_real_attack_input(
		player,
		[spark_collision.get_hurtbox(), coil_collision.get_hurtbox()]
	)).is_true()
	assert_int(int(coil.call("get_current_hp"))).is_equal(0)
	var second_hit: Dictionary = factory.call("get_last_player_hit_metadata")
	assert_int(int(second_hit.get("target_id", 0))).is_equal(COIL_ENTITY_ID)
	assert_str(String(second_hit.get("hitbox_id", ""))).is_equal(
		String(PLAYER_LIGHT_HITBOX_ID)
	)

	var cleared: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_diagnostics"
	)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("spark_visible", false))).override_failure_message(
		"Story210 must keep the first corpse visible through full clear"
	).is_true()
	assert_bool(bool(cleared.get("coil_visible", false))).is_true()
	assert_bool(bool(cleared.get("spark_process_enabled", false))).is_true()
	assert_bool(bool(cleared.get("coil_process_enabled", false))).is_true()
	assert_bool(bool(cleared.get("spark_physics_enabled", true))).is_false()
	assert_bool(bool(cleared.get("coil_physics_enabled", true))).is_false()
	assert_bool(bool(cleared.get("spark_has_target", true))).is_false()
	assert_bool(bool(cleared.get("coil_has_target", true))).is_false()
	assert_str(String((coil.get_node("Sprite") as AnimatedSprite2D).animation)).is_equal(
		"death"
	)
	assert_str(String(coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_str(String(spark_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_int(int(spark.collision_layer)).is_equal(0)
	assert_int(int(spark.collision_mask)).is_equal(0)
	assert_int(int(coil.collision_layer)).is_equal(0)
	assert_int(int(coil.collision_mask)).is_equal(0)
	assert_bool(spark_collision.is_hitbox_active(RAT_BITE_HITBOX_ID)).is_false()
	assert_bool(coil_collision.is_hitbox_active(RAT_BITE_HITBOX_ID)).is_false()

	var hatch: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
	)
	assert_bool(bool(hatch.get("available", false))).is_true()
	assert_bool(bool(hatch.get("visible", false))).is_true()
	assert_bool(bool(hatch.get("opened", true))).is_false()
	assert_bool(bool(hatch.get("interaction_monitoring", false))).is_true()
	assert_bool(bool(hatch.get("interaction_monitorable", false))).is_true()
	assert_bool(bool(hatch.get("collision_disabled", true))).is_false()
	assert_bool(bool(hatch.get("collision_blocking", false))).is_true()
	assert_int(int(hatch.get("unlock_feedback_spawn_count", -1))).is_equal(0)
	assert_str(String(hatch.get("prompt_text", ""))).is_equal("Open Exhaust Hatch")
	assert_str(String(hatch.get("route_label_text", ""))).is_equal(
		"Open Aftershock Exhaust Hatch"
	)
	factory.call("_process", 0.0)
	hatch = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
	)
	assert_bool(bool(hatch.get("opened", true))).override_failure_message(
		"Story210 must not auto-open Story092 while the player is stationary"
	).is_false()


func _receive_real_bite(
	factory: Node,
	enemy: CharacterBody2D,
	enemy_collision: CollisionComponent,
	player: PlayerController,
	expected_damage: int
) -> Dictionary:
	enemy.call("begin_pacing", 0)
	assert_bool(bool(enemy.call("request_attack"))).is_true()
	enemy.call("advance_attack_frames", int(enemy.call("get_attack_startup_frames")))
	assert_bool(bool(enemy.call("is_enemy_attack_active"))).is_true()
	var before_hp: int = int(player.call("get_current_hp"))
	enemy_collision.process_detection_frame({
		RAT_BITE_HITBOX_ID: [player.get_collision_component().get_hurtbox()],
	})
	assert_int(int(player.call("get_current_hp"))).is_equal(before_hp - expected_damage)
	var metadata: Dictionary = factory.call("get_last_enemy_hit_metadata")
	assert_int(int(metadata.get("final_damage", 0))).is_equal(expected_damage)
	enemy.call("advance_attack_frames", 32)
	await _wait_until_unpaused(30)
	assert_bool(await _wait_for_player_combat_idle(player, 60)).is_true()
	return metadata


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
	await get_tree().physics_frame
	return true


func _wait_for_player_combat_idle(
	player: PlayerController,
	max_frames: int
) -> bool:
	var combat: CombatComponent = player.get_combat_component()
	if combat == null:
		return false
	for _frame: int in range(max_frames):
		var combo: Dictionary = player.get_light_combo_diagnostics()
		if (
			combat.get_current_state() == CombatComponent.CombatState.IDLE
			and not bool(combo.get("active", false))
		):
			return true
		await get_tree().physics_frame
	return (
		combat.get_current_state() == CombatComponent.CombatState.IDLE
		and not bool(player.get_light_combo_diagnostics().get("active", false))
	)


func _face_player_left(player: PlayerController) -> void:
	Input.action_press(MOVE_LEFT_ACTION)
	await _wait_physics_frames(2)
	Input.action_release(MOVE_LEFT_ACTION)
	player.velocity = Vector2.ZERO


func _instantiate_factory_scene() -> Node:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	return factory


func _escape_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_spark_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_coil_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened": false,
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
