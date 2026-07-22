## Story225: production service-sluice combat and reward-cache handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const ATTACK_ACTION: StringName = &"attack"
const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const SERVICE_SLUICE_ENTITY_ID: int = 2142
const PLAYER_LIGHT_HITBOX_ID: StringName = &"cat_claw_light"
const SERVICE_SLUICE_SPARK: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceSparkRat"
)
const SERVICE_SLUICE_DUCT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceDuct"
)
const SERVICE_SLUICE_CACHE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceRewardCache"
)
const SERVICE_SLUICE_CACHE_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache"
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


func test_real_move_and_attack_reveal_unclaimed_service_sluice_cache() -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.call("set_local_state", _service_sluice_skirmish_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var spark := factory.get_node_or_null(SERVICE_SLUICE_SPARK) as CharacterBody2D
	var duct := factory.get_node_or_null(SERVICE_SLUICE_DUCT) as Sprite2D
	var cache := factory.get_node_or_null(SERVICE_SLUICE_CACHE) as Node2D
	assert_that(player).is_not_null()
	assert_that(spark).is_not_null()
	assert_that(duct).is_not_null()
	assert_that(cache).is_not_null()
	if player == null or spark == null or duct == null or cache == null:
		return
	var spark_collision := spark.call("get_collision_component") as CollisionComponent
	assert_that(spark_collision).is_not_null()
	if spark_collision == null:
		return

	var waiting: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_diagnostics"
	)
	var activation_x: float = float(waiting.get("activation_x", 0.0))
	assert_bool(bool(waiting.get("available", false))).is_true()
	assert_bool(bool(waiting.get("active", true))).is_false()
	assert_bool(bool(waiting.get("spark_visible", true))).is_false()
	player.set_physics_process(false)
	player.global_position = Vector2(activation_x + 4.0, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	waiting = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_diagnostics"
	)
	assert_bool(bool(waiting.get("active", true))).override_failure_message(
		"No-input displacement beyond x=10920 must not activate Story114"
	).is_false()

	factory.call("set_local_state", _service_sluice_skirmish_ready_state())
	player.global_position = Vector2(activation_x - 8.0, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	player.set_physics_process(true)
	var start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(24):
		await get_tree().physics_frame
		waiting = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_diagnostics"
		)
		if bool(waiting.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO

	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(start_x)
	assert_bool(bool(active.get("active", false))).override_failure_message(
		"Story225 requires production move_right to activate entity 2142"
	).is_true()
	assert_int(int(active.get("spark_entity_id", 0))).is_equal(SERVICE_SLUICE_ENTITY_ID)
	assert_bool(bool(active.get("spark_visible", false))).is_true()
	assert_bool(bool(active.get("spark_has_target", false))).is_true()
	assert_bool(bool(active.get("spark_process_enabled", false))).is_true()
	assert_bool(bool(active.get("spark_physics_enabled", false))).is_true()
	assert_int(int(spark.call("get_current_hp"))).is_equal(24)
	assert_int(spark.z_index).override_failure_message(
		"The active service-sluice Spark Rat must render in front of the duct and cache"
	).is_greater(maxi(duct.z_index, cache.z_index))
	assert_int(spark.z_index).is_less(player.z_index)
	assert_str(String(spark_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_NORMAL)
	)
	var frame_counts: Dictionary = active.get("spark_animation_frame_counts", {}) as Dictionary
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		assert_int(int(frame_counts.get(animation_name, 0))).is_greater_equal(3)
	var pacing: Dictionary = active.get("pacing", {}) as Dictionary
	assert_str(String(pacing.get("pacing_state", ""))).is_equal("opening_grace")
	assert_int(int(pacing.get("opening_grace_total_frames", 0))).is_equal(12)

	assert_bool(bool(factory.call(
		"apply_damage",
		SERVICE_SLUICE_ENTITY_ID,
		12,
		{"source": &"story225_nonlethal_setup"}
	))).is_true()
	assert_int(int(spark.call("get_current_hp"))).is_equal(12)

	spark.global_position = Vector2(11120.0, 482.0)
	player.global_position = Vector2(11152.0, 482.0)
	player.velocity = Vector2.ZERO
	await _face_player_left(player)
	assert_bool(await _hit_with_real_attack_input(
		player,
		[spark_collision.get_hurtbox()]
	)).override_failure_message(
		"Story225 requires Input.attack to finish entity 2142"
	).is_true()

	var hit: Dictionary = factory.call("get_last_player_hit_metadata")
	assert_int(int(hit.get("target_id", 0))).is_equal(SERVICE_SLUICE_ENTITY_ID)
	assert_str(String(hit.get("attack_type", &""))).is_equal("light")
	assert_str(String(hit.get("hitbox_id", &""))).is_equal(
		String(PLAYER_LIGHT_HITBOX_ID)
	)
	assert_bool(bool(hit.get("damage_was_applied", false))).is_true()
	assert_int(int(spark.call("get_current_hp"))).is_equal(0)

	await _wait_until_unpaused(30)
	await _wait_process_frames(2)
	factory.call("_process", 0.0)
	var cleared: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_diagnostics"
	)
	var available_cache: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_diagnostics"
	)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("spark_visible", false))).override_failure_message(
		"Story225 must preserve the authored Spark Rat death presentation"
	).is_true()
	assert_bool(bool(cleared.get("spark_process_enabled", false))).is_true()
	assert_bool(bool(cleared.get("spark_physics_enabled", true))).is_false()
	assert_bool(bool(cleared.get("spark_has_target", true))).is_false()
	assert_str(String((spark.get_node("Sprite") as AnimatedSprite2D).animation)).is_equal(
		"death"
	)
	assert_str(String(spark_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_bool(bool(available_cache.get("visible", false))).is_true()
	assert_bool(bool(available_cache.get("available", false))).is_true()
	assert_bool(bool(available_cache.get("claim_available", false))).is_true()
	assert_bool(bool(available_cache.get("claimed", true))).is_false()
	assert_str(String(available_cache.get("cache_id", ""))).is_equal(
		SERVICE_SLUICE_CACHE_ID
	)
	assert_str(String(available_cache.get("prompt_text", ""))).is_equal("+20 Gears")
	assert_vector(available_cache.get("position", Vector2.ZERO) as Vector2).is_equal(
		Vector2(11360.0, 410.0)
	)
	assert_bool((available_cache.get("last_reward", {}) as Dictionary).is_empty()).is_true()
	assert_bool(
		(available_cache.get("last_claim_feedback", {}) as Dictionary).is_empty()
	).is_true()
	assert_str(String(cleared.get("route_label_text", ""))).is_equal(
		"Service Sluice Spark Rat Cleared"
	)

	player.set_physics_process(false)
	player.global_position = available_cache.get("position", Vector2.ZERO) as Vector2
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	available_cache = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_diagnostics"
	)
	assert_bool(bool(cache.call("is_provider_in_reward_range", player))).is_true()
	assert_bool(bool(available_cache.get("claimed", true))).override_failure_message(
		"No-input displacement into reward range must leave Story115 unclaimed"
	).is_false()


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


func _service_sluice_skirmish_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_claimed": false,
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
