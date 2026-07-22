## Story205: aftershock exit skirmish production combat/exhaust handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const ATTACK_ACTION: StringName = &"attack"
const INTERACT_ACTION: StringName = &"interact"
const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const EXIT_SPARK_RAT_ENTITY_ID: int = 2129
const EXIT_COIL_RAT_ENTITY_ID: int = 2130
const PLAYER_LIGHT_HITBOX_ID: StringName = &"cat_claw_light"
const MIN_PLAYER_FLANK_DISTANCE_X: float = 48.0
const MIN_ENEMY_CENTER_DISTANCE_X: float = 250.0

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


func test_real_combat_clears_exit_skirmish_before_fresh_move_starts_exhaust(
) -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	await _wait_process_frames(2)
	factory.call("set_local_state", _exit_skirmish_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var spark := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockExitSkirmishSparkRat"
	) as CharacterBody2D
	var coil := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureAftershockExitSkirmishCoilRat"
	) as CharacterBody2D
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
		"get_factory_lower_deck_forward_pressure_aftershock_exit_skirmish_diagnostics"
	)
	player.global_position = Vector2(
		float(waiting.get("activation_x", 0.0)),
		482.0
	)
	player.velocity = Vector2.ZERO
	assert_bool(bool(waiting.get("available", true))).is_false()
	assert_bool(bool(waiting.get("active", true))).is_false()
	assert_str(String(spark_collision.get_hurtbox_state())).override_failure_message(
		"Inactive entity 2129 must not steal Story204 attacks"
	).is_equal(String(CollisionComponent.HURTBOX_STATE_GONE))
	assert_str(String(coil_collision.get_hurtbox_state())).override_failure_message(
		"Inactive entity 2130 must not steal Story204 attacks"
	).is_equal(String(CollisionComponent.HURTBOX_STATE_GONE))

	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	var claimed_cache: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_reward_cache_diagnostics"
	)
	waiting = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exit_skirmish_diagnostics"
	)
	assert_bool(bool(claimed_cache.get("claimed", false))).is_true()
	assert_bool(bool(waiting.get("available", false))).is_true()
	assert_bool(bool(waiting.get("active", true))).override_failure_message(
		"Claiming Story084 at the Story085 threshold must not chain in one process"
	).is_false()

	Input.action_press(MOVE_LEFT_ACTION)
	for _frame: int in range(12):
		await get_tree().physics_frame
		if player.global_position.x <= float(waiting.get("activation_x", 0.0)) - 4.0:
			break
	Input.action_release(MOVE_LEFT_ACTION)
	player.velocity = Vector2.ZERO
	await _wait_process_frames(2)

	var start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(16):
		await get_tree().physics_frame
		waiting = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_exit_skirmish_diagnostics"
		)
		if bool(waiting.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO

	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exit_skirmish_diagnostics"
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
		"Story205 must stage the Spark Rat on the forward flank"
	).is_greater_equal(MIN_PLAYER_FLANK_DISTANCE_X)
	assert_float(player.global_position.x - coil.global_position.x).override_failure_message(
		"Story205 must stage the Coil Rat on the rear flank"
	).is_greater_equal(MIN_PLAYER_FLANK_DISTANCE_X)
	assert_float(absf(spark.global_position.x - coil.global_position.x)).is_greater_equal(
		MIN_ENEMY_CENTER_DISTANCE_X
	)
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Break Aftershock Exit Skirmish"
	)

	var waiting_exhaust: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_bool(bool(waiting_exhaust.get("available", true))).is_false()
	assert_bool(bool(waiting_exhaust.get("active", true))).is_false()
	assert_bool(bool(waiting_exhaust.get("visible", true))).is_false()

	assert_bool(bool(factory.call(
		"apply_damage",
		EXIT_SPARK_RAT_ENTITY_ID,
		12,
		{"source": &"story205_spark_nonlethal_setup"}
	))).is_true()
	assert_bool(bool(factory.call(
		"apply_damage",
		EXIT_COIL_RAT_ENTITY_ID,
		12,
		{"source": &"story205_coil_nonlethal_setup"}
	))).is_true()
	assert_int(int(spark.call("get_current_hp"))).is_equal(12)
	assert_int(int(coil.call("get_current_hp"))).is_equal(12)

	player.global_position = Vector2(2376.0, spark.global_position.y)
	player.velocity = Vector2.ZERO
	spark.global_position = Vector2(2344.0, spark.global_position.y)
	await _face_player_left(player)
	assert_bool(await _hit_with_real_attack_input(
		player,
		[spark_collision.get_hurtbox()]
	)).override_failure_message(
		"Story205 requires Input.attack to finish entity 2129"
	).is_true()

	var first_hit: Dictionary = factory.call("get_last_player_hit_metadata")
	assert_int(int(first_hit.get("target_id", 0))).is_equal(EXIT_SPARK_RAT_ENTITY_ID)
	assert_str(String(first_hit.get("hitbox_id", &""))).is_equal(
		String(PLAYER_LIGHT_HITBOX_ID)
	)
	assert_int(int(spark.call("get_current_hp"))).is_equal(0)
	assert_int(int(coil.call("get_current_hp"))).is_equal(12)
	var partial: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exit_skirmish_diagnostics"
	)
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
	assert_bool(bool(factory.call("is_factory_route_objective_complete"))).is_false()

	await _finish_player_attack(player)
	player.global_position = Vector2(2416.0, coil.global_position.y)
	player.velocity = Vector2.ZERO
	coil.global_position = Vector2(2384.0, coil.global_position.y)
	await _face_player_left(player)
	assert_bool(await _hit_with_real_attack_input(
		player,
		[spark_collision.get_hurtbox(), coil_collision.get_hurtbox()]
	)).override_failure_message(
		"Story205 requires a second Input.attack to finish entity 2130"
	).is_true()

	var second_hit: Dictionary = factory.call("get_last_player_hit_metadata")
	assert_int(int(second_hit.get("target_id", 0))).is_equal(EXIT_COIL_RAT_ENTITY_ID)
	assert_str(String(second_hit.get("hitbox_id", &""))).is_equal(
		String(PLAYER_LIGHT_HITBOX_ID)
	)
	assert_int(int(coil.call("get_current_hp"))).is_equal(0)
	var cleared: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exit_skirmish_diagnostics"
	)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("spark_visible", false))).is_true()
	assert_bool(bool(cleared.get("coil_visible", false))).is_true()
	assert_bool(bool(cleared.get("spark_physics_enabled", true))).is_false()
	assert_bool(bool(cleared.get("coil_physics_enabled", true))).is_false()
	assert_bool(bool(cleared.get("spark_process_enabled", false))).is_true()
	assert_bool(bool(cleared.get("coil_process_enabled", false))).is_true()
	assert_str(String((coil.get_node("Sprite") as AnimatedSprite2D).animation)).is_equal(
		"death"
	)
	assert_str(String(coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_str(String(cleared.get("route_label_text", ""))).is_equal(
		"Forward Pressure Aftershock Exit Skirmish Cleared"
	)

	waiting_exhaust = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_bool(bool(waiting_exhaust.get("available", false))).is_true()
	assert_bool(bool(waiting_exhaust.get("active", true))).is_false()
	assert_bool(bool(waiting_exhaust.get("visible", false))).is_true()
	assert_bool(bool(waiting_exhaust.get("hazard_contact_active", true))).is_false()

	# Model residual movement from the lethal tick. Clear must win this frame.
	player.global_position.x += 1.0
	factory.call("_process", 0.0)
	waiting_exhaust = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_bool(bool(waiting_exhaust.get("active", true))).override_failure_message(
		"Story086 must not start from the Story085 lethal tick"
	).is_false()
	factory.call("_process", 0.0)
	waiting_exhaust = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_bool(bool(waiting_exhaust.get("active", true))).override_failure_message(
		"Story086 must remain inactive while the player is stationary"
	).is_false()

	var clear_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(16):
		await get_tree().physics_frame
		waiting_exhaust = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
		)
		if bool(waiting_exhaust.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	assert_float(player.global_position.x).is_greater(clear_x)
	assert_bool(bool(waiting_exhaust.get("active", false))).is_true()
	assert_str(String(waiting_exhaust.get("phase", ""))).is_equal("grace")
	assert_bool(bool(waiting_exhaust.get("hazard_contact_active", true))).is_false()
	assert_str(String(waiting_exhaust.get("route_label_text", ""))).is_equal(
		"Cross Aftershock Exhaust"
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
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	return factory


func _exit_skirmish_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_coil_pincer_activated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_cleared": true,
		"factory_lower_deck_forward_pressure_coil_aftershock_activated": true,
		"factory_lower_deck_forward_pressure_coil_aftershock_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_coil_aftershock_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_reward_cache_claimed": false,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_spark_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_coil_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_crossed": false,
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
