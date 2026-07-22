## Story208: aftershock exhaust flank production combat/breaker handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const ATTACK_ACTION: StringName = &"attack"
const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const FLANK_ENTITY_ID: int = 2132
const BREAKER_ENTITY_ID: int = 2133
const PLAYER_LIGHT_HITBOX_ID: StringName = &"cat_claw_light"
const FLANK_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush"
)
const FLANK_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockExhaustFlankAmbushSparkRat"
)
const FLANK_VENT_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockExhaustFlankAmbushVent"
)
const BREAKER_GUARD_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockExhaustBreakerCoilRat"
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


func test_real_movement_combat_and_hazard_clear_flank_without_chaining_breaker(
) -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	await _wait_process_frames(2)
	factory.call("set_local_state", _flank_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var spark := factory.get_node_or_null(FLANK_NODE) as CharacterBody2D
	var flank_vent := factory.get_node_or_null(FLANK_VENT_NODE) as Area2D
	var breaker_guard := factory.get_node_or_null(BREAKER_GUARD_NODE) as CharacterBody2D
	assert_that(player).is_not_null()
	assert_that(spark).is_not_null()
	assert_that(flank_vent).is_not_null()
	assert_that(breaker_guard).is_not_null()
	if player == null or spark == null or flank_vent == null or breaker_guard == null:
		return

	var spark_collision := spark.call("get_collision_component") as CollisionComponent
	var breaker_collision := breaker_guard.call(
		"get_collision_component"
	) as CollisionComponent
	assert_that(spark_collision).is_not_null()
	assert_that(breaker_collision).is_not_null()
	if spark_collision == null or breaker_collision == null:
		return

	var waiting: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)
	var activation_x: float = float(waiting.get("activation_x", 0.0))
	player.global_position = Vector2(activation_x + 8.0, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	waiting = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)
	var stationary_activated: bool = bool(waiting.get("active", false))
	assert_bool(stationary_activated).override_failure_message(
		"Story089 must require fresh positive movement after Story088 is claimed"
	).is_false()
	if stationary_activated:
		return

	player.global_position = Vector2(activation_x - 12.0, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	waiting = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)
	assert_bool(bool(waiting.get("available", false))).is_true()
	assert_str(String(spark_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)

	var start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(16):
		await get_tree().physics_frame
		waiting = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
		)
		if bool(waiting.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO

	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(start_x)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_int(int(active.get("spark_entity_id", 0))).is_equal(FLANK_ENTITY_ID)
	assert_bool(bool(active.get("spark_visible", false))).is_true()
	assert_bool(bool(active.get("spark_has_target", false))).is_true()
	assert_bool(bool(active.get("spark_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("spark_process_enabled", false))).is_true()
	assert_int(int(spark.call("get_current_hp"))).is_equal(24)
	assert_str(String(spark_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_NORMAL)
	)
	assert_bool(bool(active.get("hazard_visible", false))).is_true()
	assert_bool(bool(active.get("hazard_contact_active", false))).is_true()
	assert_str(String(active.get("hazard_id", ""))).is_equal(FLANK_HAZARD_ID)
	assert_int(int(active.get("hazard_damage", 0))).is_equal(8)
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Break Aftershock Exhaust Flank"
	)

	var hp_before: int = int(player.call("get_current_hp"))
	assert_bool(bool(factory.call(
		"apply_factory_steam_vent_contact",
		flank_vent,
		player
	))).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - 8)
	var last_hazard: Dictionary = factory.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	assert_str(String(last_hazard.get("source", ""))).is_equal(FLANK_HAZARD_ID)
	await _wait_until_unpaused(30)
	assert_bool(await _wait_for_player_combat_idle(player, 60)).override_failure_message(
		"Player must recover from steam hit-stun before the real attack input"
	).is_true()

	assert_bool(bool(factory.call(
		"apply_damage",
		FLANK_ENTITY_ID,
		12,
		{"source": &"story208_nonlethal_setup"}
	))).is_true()
	assert_int(int(spark.call("get_current_hp"))).is_equal(12)

	var waiting_breaker: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
	)
	var breaker_activation_x: float = float(waiting_breaker.get("activation_x", 0.0))
	spark.global_position = Vector2(breaker_activation_x, 482.0)
	spark.velocity = Vector2.ZERO
	player.global_position = Vector2(breaker_activation_x + 32.0, 482.0)
	player.velocity = Vector2.ZERO
	await _face_player_left(player)
	assert_bool(await _hit_with_real_attack_input(
		player,
		[spark_collision.get_hurtbox()]
	)).override_failure_message(
		"Story208 requires Input.attack to finish entity 2132"
	).is_true()

	var hit: Dictionary = factory.call("get_last_player_hit_metadata")
	assert_int(int(hit.get("target_id", 0))).is_equal(FLANK_ENTITY_ID)
	assert_str(String(hit.get("attack_type", &""))).is_equal("light")
	assert_str(String(hit.get("hitbox_id", &""))).is_equal(
		String(PLAYER_LIGHT_HITBOX_ID)
	)
	assert_bool(bool(hit.get("damage_was_applied", false))).is_true()
	assert_int(int(spark.call("get_current_hp"))).is_equal(0)

	await _wait_until_unpaused(30)
	await _wait_process_frames(2)
	var cleared: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)
	waiting_breaker = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_diagnostics"
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
	assert_bool(bool(cleared.get("hazard_visible", true))).is_false()
	assert_bool(bool(cleared.get("hazard_contact_active", true))).is_false()
	assert_str(String(cleared.get("route_label_text", ""))).is_equal(
		"Forward Pressure Exhaust Flank Cleared"
	)

	assert_bool(bool(waiting_breaker.get("available", false))).is_true()
	assert_bool(bool(waiting_breaker.get("active", true))).override_failure_message(
		"Story089 defeat must not activate Story090 without fresh movement"
	).is_false()
	assert_bool(bool(waiting_breaker.get("coil_visible", true))).is_false()
	assert_bool(bool(waiting_breaker.get("coil_process_enabled", true))).is_false()
	assert_bool(bool(waiting_breaker.get("coil_physics_enabled", true))).is_false()
	assert_int(int(breaker_guard.call("get_current_hp"))).is_equal(24)
	assert_str(String(breaker_collision.get_hurtbox_state())).override_failure_message(
		"Inactive entity 2133 must not steal attacks during the Story090 handoff"
	).is_equal(String(CollisionComponent.HURTBOX_STATE_GONE))
	assert_bool(bool(waiting_breaker.get("hazard_visible", true))).is_false()
	assert_bool(bool(waiting_breaker.get("hazard_contact_active", true))).is_false()
	assert_bool(bool(waiting_breaker.get("breaker_visible", true))).is_false()


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


func _instantiate_factory_scene() -> Node:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	return factory


func _flank_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_exit_relay_activated": true,
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
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_spark_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut": false,
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
		if combat.get_current_state() == CombatComponent.CombatState.IDLE:
			return true
		await get_tree().physics_frame
	return combat.get_current_state() == CombatComponent.CombatState.IDLE


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
