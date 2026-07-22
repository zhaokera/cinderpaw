## Story207: aftershock exhaust pursuer production combat/reward handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const ATTACK_ACTION: StringName = &"attack"
const INTERACT_ACTION: StringName = &"interact"
const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const PURSUER_ENTITY_ID: int = 2131
const PLAYER_LIGHT_HITBOX_ID: StringName = &"cat_claw_light"
const PURSUER_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockExhaustPursuerCoilRat"
)
const REWARD_CACHE_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockExhaustPursuerRewardCache"
)
const FLANK_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockExhaustFlankAmbushSparkRat"
)
const REWARD_CACHE_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache"
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


func test_real_combat_unlocks_and_real_interact_claims_pursuer_cache() -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	await _wait_process_frames(2)
	factory.call("set_local_state", _pursuer_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var pursuer := factory.get_node_or_null(PURSUER_NODE) as CharacterBody2D
	var cache := factory.get_node_or_null(REWARD_CACHE_NODE) as Node2D
	var flank := factory.get_node_or_null(FLANK_NODE) as CharacterBody2D
	assert_that(player).is_not_null()
	assert_that(pursuer).is_not_null()
	assert_that(cache).is_not_null()
	assert_that(flank).is_not_null()
	if player == null or pursuer == null or cache == null or flank == null:
		return

	var pursuer_collision := pursuer.call(
		"get_collision_component"
	) as CollisionComponent
	var flank_collision := flank.call("get_collision_component") as CollisionComponent
	assert_that(pursuer_collision).is_not_null()
	assert_that(flank_collision).is_not_null()
	if pursuer_collision == null or flank_collision == null:
		return

	var waiting: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_diagnostics"
	)
	var locked_cache: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	)
	var activation_x: float = float(waiting.get("activation_x", 0.0))
	player.global_position = Vector2(activation_x + 8.0, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	var completed_exhaust: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	waiting = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_diagnostics"
	)
	assert_bool(bool(completed_exhaust.get("crossed", false))).is_true()
	var chained_pursuer: bool = bool(waiting.get("active", false))
	assert_bool(chained_pursuer).override_failure_message(
		"Story086 completion must not activate Story087 in the same process frame"
	).is_false()
	if chained_pursuer:
		return

	player.global_position = Vector2(activation_x - 12.0, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	waiting = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_diagnostics"
	)
	assert_bool(bool(waiting.get("available", false))).is_true()
	assert_bool(bool(waiting.get("active", true))).is_false()
	assert_bool(bool(waiting.get("coil_visible", true))).is_false()
	assert_str(String(pursuer_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_bool(bool(locked_cache.get("visible", true))).is_false()
	assert_bool(bool(locked_cache.get("claim_available", true))).is_false()

	var start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(16):
		await get_tree().physics_frame
		waiting = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_diagnostics"
		)
		if bool(waiting.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO

	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(start_x)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_int(int(active.get("coil_entity_id", 0))).is_equal(PURSUER_ENTITY_ID)
	assert_bool(bool(active.get("coil_visible", false))).is_true()
	assert_bool(bool(active.get("coil_has_target", false))).is_true()
	assert_bool(bool(active.get("coil_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("coil_process_enabled", false))).is_true()
	assert_int(int(pursuer.call("get_current_hp"))).is_equal(24)
	assert_str(String(pursuer_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_NORMAL)
	)
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Purge Aftershock Exhaust Pursuer"
	)

	assert_bool(bool(factory.call(
		"apply_damage",
		PURSUER_ENTITY_ID,
		12,
		{"source": &"story207_nonlethal_setup"}
	))).is_true()
	assert_int(int(pursuer.call("get_current_hp"))).is_equal(12)

	pursuer.global_position = Vector2(2586.0, 482.0)
	player.global_position = Vector2(2618.0, pursuer.global_position.y)
	player.velocity = Vector2.ZERO
	await _face_player_left(player)
	assert_bool(await _hit_with_real_attack_input(
		player,
		[pursuer_collision.get_hurtbox()]
	)).override_failure_message(
		"Story207 requires Input.attack to finish entity 2131"
	).is_true()

	var hit: Dictionary = factory.call("get_last_player_hit_metadata")
	assert_int(int(hit.get("target_id", 0))).is_equal(PURSUER_ENTITY_ID)
	assert_str(String(hit.get("attack_type", &""))).is_equal("light")
	assert_str(String(hit.get("hitbox_id", &""))).is_equal(
		String(PLAYER_LIGHT_HITBOX_ID)
	)
	assert_bool(bool(hit.get("damage_was_applied", false))).is_true()
	assert_int(int(pursuer.call("get_current_hp"))).is_equal(0)

	await _wait_until_unpaused(30)
	await _wait_process_frames(2)
	var cleared: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_diagnostics"
	)
	var available_cache: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("coil_visible", false))).is_true()
	assert_bool(bool(cleared.get("coil_process_enabled", false))).is_true()
	assert_bool(bool(cleared.get("coil_physics_enabled", true))).is_false()
	assert_bool(bool(cleared.get("coil_has_target", true))).is_false()
	assert_str(String((pursuer.get_node("Sprite") as AnimatedSprite2D).animation)).is_equal(
		"death"
	)
	assert_str(String(pursuer_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_bool(bool(available_cache.get("visible", false))).is_true()
	assert_bool(bool(available_cache.get("available", false))).is_true()
	assert_bool(bool(available_cache.get("claim_available", false))).is_true()
	assert_bool(bool(available_cache.get("claimed", true))).is_false()
	assert_str(String(available_cache.get("cache_id", ""))).is_equal(REWARD_CACHE_ID)
	assert_str(String(available_cache.get("prompt_text", ""))).is_equal("+20 Gears")

	player.global_position = available_cache.get("position", Vector2.ZERO) as Vector2
	player.velocity = Vector2.ZERO
	assert_bool(bool(cache.call("is_provider_in_reward_range", player))).is_true()
	_press_interact(factory)

	var claimed_cache: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	)
	var claimed: bool = bool(claimed_cache.get("claimed", false))
	assert_bool(claimed).override_failure_message(
		"Story207 requires production Input.interact to claim the Story088 cache"
	).is_true()
	if not claimed:
		return

	var reward: Dictionary = claimed_cache.get("last_reward", {}) as Dictionary
	var feedback: Dictionary = claimed_cache.get("last_claim_feedback", {}) as Dictionary
	assert_bool(bool(claimed_cache.get("claim_available", true))).is_false()
	assert_int(int(reward.get("gears", 0))).is_equal(20)
	assert_str(String(reward.get("source", ""))).is_equal(REWARD_CACHE_ID)
	assert_str(String(feedback.get("text", ""))).is_equal(
		"Forward Pressure Exhaust Pursuer Cache Claimed +20 Gears"
	)
	assert_str(String(
		factory.call("get_factory_route_objective_diagnostics").get(
			"route_label_text",
			""
		)
	)).is_equal("Forward Pressure Exhaust Pursuer Cache Claimed +20 Gears")

	var waiting_flank: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_diagnostics"
	)
	assert_bool(bool(waiting_flank.get("available", false))).is_true()
	assert_bool(bool(waiting_flank.get("active", true))).is_false()
	assert_bool(bool(waiting_flank.get("spark_visible", true))).is_false()
	assert_int(int(flank.call("get_current_hp"))).is_equal(24)
	assert_str(String(flank_collision.get_hurtbox_state())).override_failure_message(
		"Inactive entity 2132 must not steal Story207 attacks after the cache claim"
	).is_equal(String(CollisionComponent.HURTBOX_STATE_GONE))

	_press_interact(factory)
	claimed_cache = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_diagnostics"
	)
	assert_bool(bool(claimed_cache.get("claimed", false))).is_true()
	assert_int(int((claimed_cache.get("last_reward", {}) as Dictionary).get(
		"gears",
		0
	))).is_equal(20)


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


func _instantiate_factory_scene() -> Node:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	return factory


func _pursuer_ready_state() -> Dictionary:
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
		"factory_lower_deck_forward_pressure_aftershock_exhaust_crossed": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_spark_rat_defeated": false,
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
