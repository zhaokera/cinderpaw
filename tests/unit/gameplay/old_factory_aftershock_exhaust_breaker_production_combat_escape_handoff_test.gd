## Story209: aftershock exhaust breaker production combat/escape handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const ATTACK_ACTION: StringName = &"attack"
const INTERACT_ACTION: StringName = &"interact"
const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const BREAKER_ENTITY_ID: int = 2133
const PLAYER_LIGHT_HITBOX_ID: StringName = &"cat_claw_light"
const COIL_BITE_HITBOX_ID: StringName = &"rat_minion_bite"
const BREAKER_GUARD_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockExhaustBreakerCoilRat"
)
const BREAKER_VENT_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockExhaustBreakerVent"
)
const BREAKER_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockExhaustBreaker"
)
const ESCAPE_SPARK_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockExhaustEscapeSkirmishSparkRat"
)
const ESCAPE_COIL_NODE: NodePath = (
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


func test_warning_real_combat_and_interact_cut_handoff_without_escape_chain(
) -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	await _wait_process_frames(2)
	factory.call("set_local_state", _breaker_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var coil := factory.get_node_or_null(BREAKER_GUARD_NODE) as CharacterBody2D
	var vent := factory.get_node_or_null(BREAKER_VENT_NODE) as Area2D
	var breaker := factory.get_node_or_null(BREAKER_NODE) as Node2D
	var escape_spark := factory.get_node_or_null(ESCAPE_SPARK_NODE) as CharacterBody2D
	var escape_coil := factory.get_node_or_null(ESCAPE_COIL_NODE) as CharacterBody2D
	assert_that(player).is_not_null()
	assert_that(coil).is_not_null()
	assert_that(vent).is_not_null()
	assert_that(breaker).is_not_null()
	assert_that(escape_spark).is_not_null()
	assert_that(escape_coil).is_not_null()
	if (
		player == null
		or coil == null
		or vent == null
		or breaker == null
		or escape_spark == null
		or escape_coil == null
	):
		return

	var coil_collision := coil.call("get_collision_component") as CollisionComponent
	var escape_spark_collision := escape_spark.call(
		"get_collision_component"
	) as CollisionComponent
	var escape_coil_collision := escape_coil.call(
		"get_collision_component"
	) as CollisionComponent
	assert_that(coil_collision).is_not_null()
	assert_that(escape_spark_collision).is_not_null()
	assert_that(escape_coil_collision).is_not_null()
	if (
		coil_collision == null
		or escape_spark_collision == null
		or escape_coil_collision == null
	):
		return

	var waiting: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
	)
	var activation_x: float = float(waiting.get("activation_x", 0.0))
	player.global_position = Vector2(activation_x - 12.0, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	assert_bool(bool(waiting.get("active", false))).is_false()

	var start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(18):
		await get_tree().physics_frame
		waiting = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
		)
		if bool(waiting.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO

	var warning: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(start_x)
	assert_bool(bool(warning.get("active", false))).is_true()
	assert_str(String(warning.get("hazard_phase", ""))).is_equal("warning")
	assert_int(int(warning.get("hazard_warning_frames_remaining", 0))).is_greater(0)
	assert_str(String(warning.get("hazard_animation", ""))).is_equal("warning")
	assert_int(int(warning.get("hazard_warning_frame_count", 0))).is_greater_equal(3)
	assert_bool(bool(warning.get("hazard_visible", false))).is_true()
	assert_bool(bool(warning.get("hazard_contact_active", true))).is_false()
	assert_float(absf(coil.global_position.x - vent.global_position.x)).override_failure_message(
		"The Coil Rat and steam vent need a readable horizontal silhouette gap"
	).is_greater_equal(96.0)
	player.global_position = vent.global_position + Vector2(0.0, -36.0)
	player.velocity = Vector2.ZERO
	await _wait_physics_frames(2)
	var warning_hp: int = int(player.call("get_current_hp"))
	factory.call("advance_factory_hazard_time", 0.0)
	assert_int(int(player.call("get_current_hp"))).is_equal(warning_hp)

	var active: Dictionary = warning
	for _frame: int in range(20):
		await get_tree().process_frame
		active = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
		)
		if String(active.get("hazard_phase", "")) == "active":
			break
	assert_str(String(active.get("hazard_phase", ""))).is_equal("active")
	assert_str(String(active.get("hazard_animation", ""))).is_equal("active")
	assert_bool(bool(active.get("hazard_contact_active", false))).is_true()
	await _wait_physics_frames(2)
	factory.call("advance_factory_hazard_time", 0.0)
	assert_int(int(player.call("get_current_hp"))).is_equal(warning_hp - 8)
	await _wait_until_unpaused(30)
	assert_bool(await _wait_for_player_combat_idle(player, 60)).is_true()

	coil.set_physics_process(false)
	assert_bool(bool(coil.call("request_attack"))).is_true()
	coil.call(
		"advance_attack_frames",
		int(coil.call("get_attack_startup_frames"))
	)
	assert_bool(bool(coil.call("is_enemy_attack_active"))).is_true()
	var bite_hp: int = int(player.call("get_current_hp"))
	coil_collision.process_detection_frame({
		COIL_BITE_HITBOX_ID: [player.get_collision_component().get_hurtbox()],
	})
	assert_int(int(player.call("get_current_hp"))).is_equal(bite_hp - 10)
	var bite: Dictionary = factory.call("get_last_enemy_hit_metadata")
	assert_str(String(bite.get("source", ""))).is_equal("factory_coil_rat")
	assert_str(String(bite.get("weapon_id", ""))).is_equal("factory_coil_rat_bite")
	assert_int(int(bite.get("target_id", 0))).is_equal(1)
	assert_int(int(bite.get("final_damage", 0))).is_equal(10)
	coil.set_physics_process(true)
	await _wait_until_unpaused(30)
	assert_bool(await _wait_for_player_combat_idle(player, 60)).is_true()

	coil.global_position = Vector2(3104.0, 482.0)
	coil.velocity = Vector2.ZERO
	player.global_position = Vector2(3136.0, 482.0)
	player.velocity = Vector2.ZERO
	await _face_player_left(player)
	assert_bool(await _hit_with_real_attack_input(
		player,
		[coil_collision.get_hurtbox()]
	)).is_true()
	assert_int(int(coil.call("get_current_hp"))).is_equal(12)
	assert_bool(await _wait_for_player_combat_idle(player, 60)).is_true()
	assert_bool(await _hit_with_real_attack_input(
		player,
		[coil_collision.get_hurtbox()]
	)).is_true()
	assert_int(int(coil.call("get_current_hp"))).is_equal(0)

	await _wait_until_unpaused(30)
	await _wait_process_frames(2)
	var secured: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
	)
	assert_bool(bool(secured.get("active", true))).is_false()
	assert_bool(bool(secured.get("secured", false))).is_true()
	assert_bool(bool(secured.get("coil_visible", false))).is_true()
	assert_bool(bool(secured.get("coil_process_enabled", false))).is_true()
	assert_bool(bool(secured.get("coil_physics_enabled", true))).is_false()
	assert_bool(bool(secured.get("coil_has_target", true))).is_false()
	assert_str(String((coil.get_node("Sprite") as AnimatedSprite2D).animation)).is_equal(
		"death"
	)
	assert_str(String(coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_bool(bool(secured.get("hazard_visible", true))).is_false()
	assert_bool(bool(secured.get("hazard_contact_active", true))).is_false()
	assert_bool(bool(secured.get("breaker_visible", false))).is_true()
	assert_str(String(secured.get("prompt_text", ""))).is_equal("Cut Exhaust")

	# Grounded x > Story091's threshold intentionally exercises the same-frame boundary.
	player.global_position = Vector2(3116.0, 482.0)
	player.velocity = Vector2.ZERO
	Input.action_press(INTERACT_ACTION)
	await get_tree().process_frame
	Input.action_release(INTERACT_ACTION)
	await get_tree().process_frame

	var cut: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
	)
	var escape_waiting: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_diagnostics"
	)
	assert_bool(bool(cut.get("cut", false))).is_true()
	assert_str(String(cut.get("prompt_text", ""))).is_equal("Exhaust Cut")
	assert_int(int(cut.get("unlock_feedback_spawn_count", 0))).is_equal(1)
	assert_bool(bool(escape_waiting.get("available", false))).is_true()
	assert_bool(bool(escape_waiting.get("active", true))).override_failure_message(
		"Cutting Story090 must not activate Story091 in the same frame"
	).is_false()
	assert_bool(bool(escape_waiting.get("spark_visible", true))).is_false()
	assert_bool(bool(escape_waiting.get("coil_visible", true))).is_false()
	assert_bool(bool(escape_waiting.get("spark_process_enabled", true))).is_false()
	assert_bool(bool(escape_waiting.get("coil_process_enabled", true))).is_false()
	assert_bool(bool(escape_waiting.get("spark_physics_enabled", true))).is_false()
	assert_bool(bool(escape_waiting.get("coil_physics_enabled", true))).is_false()
	assert_int(int(escape_spark.call("get_current_hp"))).is_equal(24)
	assert_int(int(escape_coil.call("get_current_hp"))).is_equal(24)
	assert_str(String(escape_spark_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_str(String(escape_coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	for _frame: int in range(3):
		await get_tree().process_frame
	escape_waiting = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_diagnostics"
	)
	assert_bool(bool(escape_waiting.get("active", true))).is_false()


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


func _breaker_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_spark_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_coil_rat_defeated": false,
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
