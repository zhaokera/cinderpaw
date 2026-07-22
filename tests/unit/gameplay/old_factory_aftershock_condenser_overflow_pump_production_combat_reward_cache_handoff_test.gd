## Story219: overflow pump production combat and reward-cache input handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const ATTACK_ACTION: StringName = &"attack"
const INTERACT_ACTION: StringName = &"interact"
const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const OVERFLOW_PUMP_ENTITY_ID: int = 2139
const PLAYER_LIGHT_HITBOX_ID: StringName = &"cat_claw_light"
const OVERFLOW_PUMP_COIL: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpCoilRat"
)
const OVERFLOW_PUMP_CACHE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRewardCache"
)
const OVERFLOW_PUMP_HATCH: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpExitHatch"
)
const OVERFLOW_PUMP_CACHE_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache"
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


func test_real_attack_preserves_death_then_fresh_interact_claims_cache() -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.call("set_local_state", _overflow_pump_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var coil := factory.get_node_or_null(OVERFLOW_PUMP_COIL) as CharacterBody2D
	var cache := factory.get_node_or_null(OVERFLOW_PUMP_CACHE) as Node2D
	var hatch := factory.get_node_or_null(OVERFLOW_PUMP_HATCH) as Node2D
	assert_that(player).is_not_null()
	assert_that(coil).is_not_null()
	assert_that(cache).is_not_null()
	assert_that(hatch).is_not_null()
	if player == null or coil == null or cache == null or hatch == null:
		return
	var coil_collision := coil.call("get_collision_component") as CollisionComponent
	assert_that(coil_collision).is_not_null()
	if coil_collision == null:
		return

	var waiting: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics"
	)
	var activation_x: float = float(waiting.get("activation_x", 0.0))
	player.global_position = Vector2(activation_x - 12.0, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	var start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(24):
		await get_tree().physics_frame
		waiting = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics"
		)
		if bool(waiting.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO

	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(start_x)
	assert_bool(bool(active.get("active", false))).override_failure_message(
		"Story219 requires production move_right to activate entity 2139"
	).is_true()
	assert_int(int(active.get("coil_entity_id", 0))).is_equal(
		OVERFLOW_PUMP_ENTITY_ID
	)
	assert_bool(bool(active.get("coil_visible", false))).is_true()
	assert_bool(bool(active.get("coil_has_target", false))).is_true()
	assert_bool(bool(active.get("coil_process_enabled", false))).is_true()
	assert_bool(bool(active.get("coil_physics_enabled", false))).is_true()
	assert_int(int(coil.call("get_current_hp"))).is_equal(24)
	assert_str(String(coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_NORMAL)
	)

	assert_bool(bool(factory.call(
		"apply_damage",
		OVERFLOW_PUMP_ENTITY_ID,
		12,
		{"source": &"story219_nonlethal_setup"}
	))).is_true()
	assert_int(int(coil.call("get_current_hp"))).is_equal(12)

	coil.global_position = Vector2(6668.0, 482.0)
	player.global_position = Vector2(6700.0, 482.0)
	player.velocity = Vector2.ZERO
	await _face_player_left(player)

	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	assert_bool(await _hit_with_real_attack_input(
		player,
		[coil_collision.get_hurtbox()]
	)).override_failure_message(
		"Story219 requires Input.attack to finish entity 2139"
	).is_true()

	var hit: Dictionary = factory.call("get_last_player_hit_metadata")
	assert_int(int(hit.get("target_id", 0))).is_equal(OVERFLOW_PUMP_ENTITY_ID)
	assert_str(String(hit.get("attack_type", &""))).is_equal("light")
	assert_str(String(hit.get("hitbox_id", &""))).is_equal(
		String(PLAYER_LIGHT_HITBOX_ID)
	)
	assert_bool(bool(hit.get("damage_was_applied", false))).is_true()
	assert_int(int(coil.call("get_current_hp"))).is_equal(0)
	var immediate_cache: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_diagnostics"
	)
	var immediate_state: Dictionary = factory.call("get_local_state")
	assert_bool(bool(immediate_cache.get("available", false))).is_true()
	assert_bool(bool(immediate_cache.get("claim_available", false))).is_true()
	assert_bool(bool(immediate_cache.get("claimed", true))).is_false()
	assert_bool((immediate_cache.get("last_reward", {}) as Dictionary).is_empty()).is_true()
	assert_bool(bool(immediate_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_cleared",
		false
	))).is_true()
	assert_bool(bool(immediate_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed",
		true
	))).is_false()
	assert_bool(bool(immediate_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened",
		true
	))).is_false()

	await _wait_until_unpaused(30)
	await _wait_process_frames(2)
	factory.call("_process", 0.0)
	var cleared: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics"
	)
	var available_cache: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_diagnostics"
	)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("coil_visible", false))).override_failure_message(
		"Story219 must preserve the Coil Rat death presentation after defeat"
	).is_true()
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
		"A held pre-clear interact must not consume the newly revealed cache"
	).is_false()
	assert_str(String(available_cache.get("cache_id", ""))).is_equal(
		OVERFLOW_PUMP_CACHE_ID
	)
	assert_str(String(available_cache.get("prompt_text", ""))).is_equal("+20 Gears")
	assert_str(String(cleared.get("route_label_text", ""))).is_equal(
		"Overflow Pump Cleared"
	)
	assert_bool(bool(available_cache.get("claimed", true))).override_failure_message(
		"A held pre-clear interact must remain stale after the cache appears"
	).is_false()
	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)

	player.global_position = available_cache.get("position", Vector2.ZERO) as Vector2
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	available_cache = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_diagnostics"
	)
	assert_bool(bool(cache.call("is_provider_in_reward_range", player))).is_true()
	assert_bool(bool(available_cache.get("claimed", true))).override_failure_message(
		"No-input displacement into reward range must leave Story106 unclaimed"
	).is_false()

	_press_interact(factory)
	var claimed_cache: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_diagnostics"
	)
	var claimed: bool = bool(claimed_cache.get("claimed", false))
	assert_bool(claimed).override_failure_message(
		"Story219 requires fresh Input.interact to claim the Story106 cache"
	).is_true()
	if not claimed:
		return
	var reward: Dictionary = claimed_cache.get("last_reward", {}) as Dictionary
	var feedback: Dictionary = (
		claimed_cache.get("last_claim_feedback", {}) as Dictionary
	)
	assert_bool(bool(claimed_cache.get("claim_available", true))).is_false()
	assert_int(int(reward.get("gears", 0))).is_equal(20)
	assert_str(String(reward.get("source", ""))).is_equal(OVERFLOW_PUMP_CACHE_ID)
	assert_str(String(feedback.get("text", ""))).is_equal(
		"Overflow Pump Cache Claimed +20 Gears"
	)
	var claimed_state: Dictionary = factory.call("get_local_state")
	assert_bool(bool(claimed_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed",
		false
	))).is_true()
	assert_bool(bool(claimed_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened",
		true
	))).is_false()
	assert_str(String(
		factory.call("get_factory_route_objective_diagnostics").get(
			"route_label_text",
			""
		)
	)).is_equal("Overflow Pump Cache Claimed +20 Gears")

	var available_hatch: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_diagnostics"
	)
	assert_bool(bool(available_hatch.get("available", false))).is_true()
	assert_bool(bool(available_hatch.get("visible", false))).is_true()
	assert_bool(bool(available_hatch.get("opened", true))).is_false()
	assert_bool(bool(available_hatch.get("collision_blocking", false))).is_true()
	assert_str(String(available_hatch.get("prompt_text", ""))).is_equal(
		"Open Runoff Hatch"
	)

	_press_interact(factory)
	claimed_cache = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_diagnostics"
	)
	assert_bool(bool(claimed_cache.get("claimed", false))).is_true()
	assert_int(int((claimed_cache.get("last_reward", {}) as Dictionary).get(
		"gears",
		0
	))).is_equal(20)
	available_hatch = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_diagnostics"
	)
	assert_bool(bool(available_hatch.get("opened", true))).is_false()


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
	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)


func _overflow_pump_ready_state() -> Dictionary:
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
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_cleared": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_reward_cache_claimed": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_exit_hatch_opened": false,
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
