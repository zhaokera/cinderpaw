## Story217: production outlet clamp combat and drip vent handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const ATTACK_ACTION: StringName = &"attack"
const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const PLAYER_LIGHT_HITBOX_ID: StringName = &"cat_claw_light"
const SPARK_RAT_BITE_HITBOX_ID: StringName = &"factory_spark_rat_bite"
const OUTLET_CLAMP_ENTITY_ID: int = 2138
const OUTLET_CLAMP_SPARK: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOutletClampSparkRat"
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


func test_real_movement_and_attack_clear_clamp_without_chaining_drip_vent() -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.set_process(false)
	factory.call("set_local_state", _clamp_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var spark := factory.get_node_or_null(OUTLET_CLAMP_SPARK) as CharacterBody2D
	assert_that(player).is_not_null()
	assert_that(spark).is_not_null()
	if player == null or spark == null:
		return

	var spark_collision := spark.call("get_collision_component") as CollisionComponent
	assert_that(spark_collision).is_not_null()
	if spark_collision == null:
		return

	var waiting: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics"
	)
	var activation_x: float = float(waiting.get("activation_x", 0.0))
	player.global_position = Vector2(activation_x - 12.0, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)

	var start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(20):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
		waiting = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics"
		)
		if bool(waiting.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO

	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(start_x)
	assert_bool(bool(active.get("active", false))).override_failure_message(
		"Story217 requires production move_right activation, not a direct Story API"
	).is_true()
	assert_bool(bool(active.get("spark_visible", false))).is_true()
	assert_bool(bool(active.get("spark_has_target", false))).is_true()
	assert_bool(bool(active.get("spark_process_enabled", false))).is_true()
	assert_bool(bool(active.get("spark_physics_enabled", false))).is_true()
	assert_int(int(active.get("spark_entity_id", 0))).is_equal(OUTLET_CLAMP_ENTITY_ID)
	assert_int(int(spark.call("get_current_hp"))).is_equal(24)
	assert_str(String(spark_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_NORMAL)
	)

	assert_bool(bool(factory.call(
		"apply_damage",
		OUTLET_CLAMP_ENTITY_ID,
		12,
		{"source": &"story217_nonlethal_setup"}
	))).is_true()
	assert_int(int(spark.call("get_current_hp"))).is_equal(12)

	# Keep the deterministic acceptance focused on player combat, not enemy locomotion.
	var locked_drip_vent: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	var drip_activation_x: float = float(locked_drip_vent.get("activation_x", 0.0))
	spark.set_physics_process(false)
	spark.global_position = Vector2(drip_activation_x - 36.0, 482.0)
	spark.velocity = Vector2.ZERO
	player.global_position = Vector2(drip_activation_x - 4.0, 482.0)
	player.velocity = Vector2.ZERO
	await _face_player_left(player)
	player.global_position = Vector2(drip_activation_x - 4.0, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	assert_bool(await _hit_with_real_attack_input(
		player,
		[spark_collision.get_hurtbox()],
		true
	)).override_failure_message(
		"Story217 requires Input.attack to finish outlet clamp entity 2138"
	).is_true()

	var hit: Dictionary = factory.call("get_last_player_hit_metadata")
	assert_int(int(hit.get("target_id", 0))).is_equal(OUTLET_CLAMP_ENTITY_ID)
	assert_str(String(hit.get("attack_type", &""))).is_equal("light")
	assert_str(String(hit.get("hitbox_id", &""))).is_equal(
		String(PLAYER_LIGHT_HITBOX_ID)
	)
	assert_bool(bool(hit.get("damage_was_applied", false))).is_true()
	assert_int(int(spark.call("get_current_hp"))).is_equal(0)

	factory.call("_process", 0.0)
	var kill_frame_drip_vent: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	var chained_on_kill_frame: bool = bool(kill_frame_drip_vent.get("active", true))
	assert_bool(chained_on_kill_frame).override_failure_message(
		"Story098 must not chain from the killing frame's held move_right input"
	).is_false()
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	if chained_on_kill_frame:
		return

	await _wait_process_frames(2)
	var cleared: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics"
	)
	var drip_vent: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("spark_visible", false))).is_true()
	assert_bool(bool(cleared.get("spark_process_enabled", false))).is_true()
	assert_bool(bool(cleared.get("spark_physics_enabled", true))).is_false()
	assert_bool(bool(cleared.get("spark_has_target", true))).is_false()
	assert_str(String((spark.get_node("Sprite") as AnimatedSprite2D).animation)).is_equal(
		"death"
	)
	assert_str(String(spark_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_bool(spark_collision.is_hitbox_active(SPARK_RAT_BITE_HITBOX_ID)).is_false()
	assert_int(spark.collision_layer).is_equal(0)
	assert_int(spark.collision_mask).is_equal(0)
	assert_bool(bool(drip_vent.get("available", false))).is_true()
	assert_bool(bool(drip_vent.get("visible", false))).is_true()
	assert_bool(bool(drip_vent.get("active", true))).is_false()
	assert_bool(bool(drip_vent.get("hazard_contact_active", true))).is_false()

	factory.call("_process", 0.0)
	drip_vent = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	assert_bool(bool(drip_vent.get("active", true))).override_failure_message(
		"Story098 must remain idle on the stationary frame after Story217"
	).is_false()

	Input.action_press(MOVE_RIGHT_ACTION)
	player.global_position.x += 4.0
	factory.call("_process", 0.0)
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	drip_vent = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	assert_bool(bool(drip_vent.get("active", false))).override_failure_message(
		"Story098 must accept the later fresh positive movement frame"
	).is_true()
	assert_str(String(drip_vent.get("phase", ""))).is_equal("grace")
	assert_bool(bool(drip_vent.get("hazard_contact_active", true))).is_false()


func _hit_with_real_attack_input(
		player: PlayerController,
		candidates: Array[Area2D],
		hold_move_right_on_detection: bool = false
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
	if hold_move_right_on_detection:
		Input.action_press(MOVE_RIGHT_ACTION)
		player.global_position.x += 12.0
	player_collision.process_detection_frame({
		PLAYER_LIGHT_HITBOX_ID: candidates,
	})
	return true


func _face_player_left(player: PlayerController) -> void:
	Input.action_press(MOVE_LEFT_ACTION)
	await _wait_physics_frames(2)
	Input.action_release(MOVE_LEFT_ACTION)
	player.velocity = Vector2.ZERO


func _clamp_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_spark_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_cleared": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_crossed": false,
	}


func _wait_process_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().process_frame


func _wait_physics_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().physics_frame


func _release_gameplay_actions() -> void:
	Input.action_release(ATTACK_ACTION)
	Input.action_release(MOVE_LEFT_ACTION)
	Input.action_release(MOVE_RIGHT_ACTION)


func _stop_runtime_audio_players() -> void:
	for audio_player: AudioStreamPlayer in _find_nodes_of_type(
		get_tree().root,
		AudioStreamPlayer
	):
		audio_player.stop()
	for audio_player_2d: AudioStreamPlayer2D in _find_nodes_of_type(
		get_tree().root,
		AudioStreamPlayer2D
	):
		audio_player_2d.stop()


func _find_nodes_of_type(root: Node, expected_type: Variant) -> Array[Node]:
	var matches: Array[Node] = []
	if is_instance_of(root, expected_type):
		matches.append(root)
	for child: Node in root.get_children():
		matches.append_array(_find_nodes_of_type(child, expected_type))
	return matches
