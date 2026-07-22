## Story232: production runoff-pincer combat and reward-cache handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const ATTACK_ACTION: StringName = &"attack"
const INTERACT_ACTION: StringName = &"interact"
const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const PINCER_SPARK_ENTITY_ID: int = 2144
const PINCER_COIL_ENTITY_ID: int = 2145
const PLAYER_LIGHT_HITBOX_ID: StringName = &"cat_claw_light"
const PINCER_SPARK: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerSparkRat"
)
const PINCER_COIL: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerCoilRat"
)
const PINCER_CACHE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerRewardCache"
)
const PINCER_DIAGNOSTICS: String = (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_diagnostics"
)
const CACHE_DIAGNOSTICS: String = (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_diagnostics"
)
const CACHE_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache"
)
const REQUIRED_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]

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


func test_real_move_and_attacks_clear_pincer_and_reveal_unclaimed_cache(
) -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.set_process(false)
	factory.call("set_local_state", _pincer_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var spark := factory.get_node_or_null(PINCER_SPARK) as CharacterBody2D
	var coil := factory.get_node_or_null(PINCER_COIL) as CharacterBody2D
	var cache := factory.get_node_or_null(PINCER_CACHE) as Node2D
	assert_that(player).is_not_null()
	assert_that(spark).is_not_null()
	assert_that(coil).is_not_null()
	assert_that(cache).is_not_null()
	if player == null or spark == null or coil == null or cache == null:
		return
	var spark_collision := spark.call("get_collision_component") as CollisionComponent
	var coil_collision := coil.call("get_collision_component") as CollisionComponent
	assert_that(spark_collision).is_not_null()
	assert_that(coil_collision).is_not_null()
	if spark_collision == null or coil_collision == null:
		return

	var waiting: Dictionary = factory.call(PINCER_DIAGNOSTICS)
	assert_bool(bool(waiting.get("available", false))).is_true()
	assert_bool(bool(waiting.get("active", true))).is_false()
	assert_bool(bool(waiting.get("spark_visible", true))).is_false()
	assert_bool(bool(waiting.get("coil_visible", true))).is_false()

	var activation_x: float = float(waiting.get("activation_x", 0.0))
	player.set_physics_process(false)
	player.global_position = Vector2(activation_x - 8.0, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	player.set_physics_process(true)
	var start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(24):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
		waiting = factory.call(PINCER_DIAGNOSTICS)
		if bool(waiting.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO

	var active: Dictionary = factory.call(PINCER_DIAGNOSTICS)
	assert_float(player.global_position.x).is_greater(start_x)
	assert_bool(bool(active.get("active", false))).override_failure_message(
		"Story232 requires fresh production move_right to activate Story121"
	).is_true()
	assert_int(int(active.get("spark_entity_id", 0))).is_equal(PINCER_SPARK_ENTITY_ID)
	assert_int(int(active.get("coil_entity_id", 0))).is_equal(PINCER_COIL_ENTITY_ID)
	assert_bool(bool(active.get("spark_visible", false))).is_true()
	assert_bool(bool(active.get("coil_visible", false))).is_true()
	assert_bool(bool(active.get("spark_has_target", false))).is_true()
	assert_bool(bool(active.get("coil_has_target", false))).is_true()
	assert_bool(bool(active.get("spark_process_enabled", false))).is_true()
	assert_bool(bool(active.get("coil_process_enabled", false))).is_true()
	assert_bool(bool(active.get("spark_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("coil_physics_enabled", false))).is_true()
	assert_int(int(spark.call("get_current_hp"))).is_equal(24)
	assert_int(int(coil.call("get_current_hp"))).is_equal(24)
	assert_int(spark.z_index).override_failure_message(
		"Spark Rat death must render above the Story122 cache"
	).is_greater(cache.z_index)
	assert_int(coil.z_index).override_failure_message(
		"Coil Rat death must render above the Story122 cache"
	).is_greater(cache.z_index)
	assert_int(spark.z_index).is_less(player.z_index)
	assert_int(coil.z_index).is_less(player.z_index)
	for frame_counts: Dictionary in [
		active.get("spark_animation_frame_counts", {}) as Dictionary,
		active.get("coil_animation_frame_counts", {}) as Dictionary,
	]:
		for animation_name: StringName in REQUIRED_ANIMATIONS:
			assert_int(int(frame_counts.get(animation_name, 0))).is_greater_equal(3)

	spark.set_physics_process(false)
	coil.set_physics_process(false)
	assert_bool(bool(factory.call(
		"apply_damage",
		PINCER_SPARK_ENTITY_ID,
		12,
		{"source": &"story232_spark_nonlethal_setup"}
	))).is_true()
	assert_int(int(spark.call("get_current_hp"))).is_equal(12)
	spark.global_position = Vector2(14960.0, 482.0)
	spark.velocity = Vector2.ZERO
	player.global_position = Vector2(14928.0, 482.0)
	player.velocity = Vector2.ZERO
	await _face_player_right(player)
	player.global_position = Vector2(14928.0, 482.0)
	player.velocity = Vector2.ZERO
	assert_bool(await _hit_with_real_attack_input(
		player,
		[spark_collision.get_hurtbox()]
	)).override_failure_message(
		"Story232 requires Input.attack to finish entity 2144"
	).is_true()
	var spark_hit: Dictionary = factory.call("get_last_player_hit_metadata")
	_assert_light_hit(spark_hit, PINCER_SPARK_ENTITY_ID, 1)
	assert_int(int(spark.call("get_current_hp"))).is_equal(0)

	await _wait_until_unpaused(30)
	await _finish_current_attack(player)
	factory.call("_process", 0.0)
	var half_cleared: Dictionary = factory.call(PINCER_DIAGNOSTICS)
	var locked_cache: Dictionary = factory.call(CACHE_DIAGNOSTICS)
	assert_bool(bool(half_cleared.get("cleared", true))).is_false()
	assert_bool(bool(half_cleared.get("spark_defeated", false))).is_true()
	assert_bool(bool(half_cleared.get("coil_defeated", true))).is_false()
	assert_bool(bool(half_cleared.get("spark_visible", false))).is_true()
	assert_bool(bool(half_cleared.get("spark_process_enabled", false))).is_true()
	assert_bool(bool(half_cleared.get("spark_physics_enabled", true))).is_false()
	assert_bool(bool(half_cleared.get("spark_has_target", true))).is_false()
	assert_str(String((spark.get_node("Sprite") as AnimatedSprite2D).animation)).is_equal(
		"death"
	)
	assert_str(String(spark_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_bool(bool(half_cleared.get("coil_visible", false))).is_true()
	assert_bool(bool(half_cleared.get("coil_has_target", false))).is_true()
	assert_bool(bool(locked_cache.get("available", true))).is_false()
	assert_bool(bool(locked_cache.get("visible", true))).is_false()

	# Production death animation completion frees the first enemy before the
	# second lethal hit reaches the route-state synchronizer.
	spark.free()
	await _wait_process_frames(1)

	assert_bool(bool(factory.call(
		"apply_damage",
		PINCER_COIL_ENTITY_ID,
		12,
		{"source": &"story232_coil_nonlethal_setup"}
	))).is_true()
	assert_int(int(coil.call("get_current_hp"))).is_equal(12)
	coil.global_position = Vector2(15428.0, 482.0)
	coil.velocity = Vector2.ZERO
	player.global_position = Vector2(15460.0, 482.0)
	player.velocity = Vector2.ZERO
	await _face_player_left(player)
	player.global_position = Vector2(15460.0, 482.0)
	player.velocity = Vector2.ZERO
	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	assert_bool(await _hit_with_real_attack_input(
		player,
		[coil_collision.get_hurtbox()]
	)).override_failure_message(
		"Story232 requires Input.attack to finish entity 2145"
	).is_true()
	var coil_hit: Dictionary = factory.call("get_last_player_hit_metadata")
	_assert_light_hit(coil_hit, PINCER_COIL_ENTITY_ID, -1)
	assert_int(int(coil.call("get_current_hp"))).is_equal(0)

	await _wait_until_unpaused(30)
	await _wait_process_frames(2)
	for _frame: int in range(3):
		factory.call("_process", 0.0)
	Input.action_release(INTERACT_ACTION)
	var cleared: Dictionary = factory.call(PINCER_DIAGNOSTICS)
	var available_cache: Dictionary = factory.call(CACHE_DIAGNOSTICS)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("spark_visible", true))).is_false()
	assert_bool(bool(cleared.get("spark_process_enabled", true))).is_false()
	assert_bool(bool(cleared.get("coil_visible", false))).is_true()
	assert_bool(bool(cleared.get("coil_process_enabled", false))).is_true()
	assert_bool(bool(cleared.get("coil_physics_enabled", true))).is_false()
	assert_bool(bool(cleared.get("coil_has_target", true))).is_false()
	assert_str(String((coil.get_node("Sprite") as AnimatedSprite2D).animation)).is_equal(
		"death"
	)
	assert_str(String(coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_bool(bool(available_cache.get("available", false))).is_true()
	assert_bool(bool(available_cache.get("visible", false))).is_true()
	assert_bool(bool(available_cache.get("claim_available", false))).is_true()
	assert_bool(bool(available_cache.get("claimed", true))).override_failure_message(
		"Held pre-clear interact must leave Story122 unclaimed"
	).is_false()
	assert_str(String(available_cache.get("cache_id", ""))).is_equal(CACHE_ID)
	assert_str(String(available_cache.get("prompt_text", ""))).is_equal("+20 Gears")
	assert_bool((available_cache.get("last_reward", {}) as Dictionary).is_empty()).is_true()
	assert_bool(
		(available_cache.get("last_claim_feedback", {}) as Dictionary).is_empty()
	).is_true()
	assert_bool(bool(cache.call("is_provider_in_reward_range", player))).is_true()
	assert_str(String(cleared.get("route_label_text", ""))).is_equal(
		"Tailrace Runoff Pincer Cleared"
	)


func _assert_light_hit(
	hit: Dictionary,
	expected_target_id: int,
	expected_facing: int
) -> void:
	assert_int(int(hit.get("attacker_id", 0))).is_equal(1)
	assert_int(int(hit.get("target_id", 0))).is_equal(expected_target_id)
	assert_str(String(hit.get("weapon_id", &""))).is_equal("cat_claw")
	assert_str(String(hit.get("attack_type", &""))).is_equal("light")
	assert_str(String(hit.get("hitbox_id", &""))).is_equal(
		String(PLAYER_LIGHT_HITBOX_ID)
	)
	assert_int(int(hit.get("facing", 0))).is_equal(expected_facing)
	assert_int(int(hit.get("final_damage", 0))).is_equal(12)
	assert_bool(bool(hit.get("damage_was_applied", false))).is_true()
	assert_int(int(hit.get("damage_applied", 0))).is_equal(12)


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


func _finish_current_attack(player: PlayerController) -> void:
	var combat: CombatComponent = player.get_combat_component()
	if combat == null:
		return
	var attack_frame_data: Dictionary = combat.get_light_attack_frame_data(
		combat.get_combo_index()
	)
	var total_frames: int = int(attack_frame_data.get("total_frames", 0))
	combat.advance_attack_frames(total_frames + 1)
	for _frame: int in range(total_frames + 2):
		await get_tree().physics_frame
		if not bool(player.get_light_combo_diagnostics().get("active", false)):
			return


func _face_player_left(player: PlayerController) -> void:
	Input.action_press(MOVE_LEFT_ACTION)
	await _wait_physics_frames(2)
	Input.action_release(MOVE_LEFT_ACTION)
	player.velocity = Vector2.ZERO


func _face_player_right(player: PlayerController) -> void:
	Input.action_press(MOVE_RIGHT_ACTION)
	await _wait_physics_frames(2)
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO


func _pincer_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_spark_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_coil_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_claimed": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
		"last_return_checkpoint": {
			"id": "old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay",
			"scene_id": "area_03_factory",
			"spawn_point": "lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay",
			"position": Vector2(13480, 382),
		},
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
