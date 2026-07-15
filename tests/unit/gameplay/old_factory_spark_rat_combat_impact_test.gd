## Combat Presentation Story028: Old Factory dodge-counter impact uses the shared bridge.
extends GdUnitTestSuite

const FACTORY_SCENE: PackedScene = preload(
	"res://scenes/factory_route_transition_shell.tscn"
)
const SPARK_RAT_HITBOX_ID: StringName = &"rat_minion_bite"
const SPARK_RAT_ENTITY_ID: int = 2102
const DODGE_IFRAME_ENTRY_FRAMES: int = 3
const DODGE_REMAINING_FRAMES: int = 9

var _factory: Node
var _player: PlayerController
var _combat: CombatComponent
var _player_collision: CollisionComponent
var _presentation: CombatPresentation
var _input_manager: Node


func before_test() -> void:
	Input.action_release(&"attack")
	get_tree().paused = false
	_input_manager = get_node("/root/InputManager")
	_input_manager.call("clear_buffer")
	_input_manager.call("notify_animation_lock", 0)
	_factory = FACTORY_SCENE.instantiate()
	add_child(_factory)
	_factory.set_process(false)
	_player = _factory.get_node("Player") as PlayerController
	_combat = _player.get_combat_component()
	_player_collision = _player.get_collision_component()
	_presentation = _factory.get_node_or_null(
		"CombatPresentation"
	) as CombatPresentation


func after_test() -> void:
	get_tree().paused = false
	Input.action_release(&"attack")
	if _input_manager != null:
		_input_manager.call("clear_buffer")
		_input_manager.call("notify_animation_lock", 0)
	_stop_runtime_audio_players()
	if is_instance_valid(_factory):
		if _factory.get_parent() != null:
			_factory.get_parent().remove_child(_factory)
		_factory.free()
	_factory = null
	_player = null
	_combat = null
	_player_collision = null
	_presentation = null
	_input_manager = null


func test_real_dodge_counter_hit_uses_three_frame_hitstop_and_one_buffered_followup() -> void:
	var bridge: Node = _factory.get_node_or_null("HitstopInputBridge")
	assert_that(_presentation).override_failure_message(
		"Story028 requires CombatPresentation in Old Factory"
	).is_not_null()
	assert_that(bridge).override_failure_message(
		"Story028 requires one shared HitstopInputBridge in Old Factory"
	).is_not_null()
	assert_int(_factory.find_children(
		"CombatPresentation", "", true, false
	).size()).is_equal(1)
	assert_int(_factory.find_children(
		"HitstopInputBridge", "", true, false
	).size()).is_equal(1)
	if _presentation == null or bridge == null:
		return

	var spark_rat: CharacterBody2D = await _activate_spark_rat()
	assert_that(spark_rat).is_not_null()
	if spark_rat == null:
		return
	assert_bool(_player.request_dodge()).is_true()
	_combat.advance_dodge_frames(DODGE_IFRAME_ENTRY_FRAMES)
	assert_bool(_combat.is_dodge_iframe_active()).is_true()
	var player_hp_before: int = _player.get_current_hp()

	var bite_result: Dictionary = _factory.call(
		"resolve_factory_spark_rat_bite_against_player"
	)

	assert_bool(bool(bite_result.get("dodged", false))).is_true()
	assert_int(_player.get_current_hp()).is_equal(player_hp_before)
	assert_bool(_presentation.is_gameplay_hitstop_active()).is_false()
	assert_int(_presentation.get_active_damage_number_count()).is_equal(0)
	_combat.advance_dodge_frames(DODGE_REMAINING_FRAMES)
	for _frame: int in range(PlayerController.DODGE_DURATION_FRAMES):
		_player.call("_physics_process", 1.0 / 60.0)

	var spark_hp_before: int = int(spark_rat.call("get_current_hp"))
	_combat.on_hit_confirmed({
		"target_id": SPARK_RAT_ENTITY_ID,
		"hit_frame": 4,
		"hit_position": spark_rat.global_position,
		"attack_metadata": {
			"attack_type": &"light",
			"weapon_id": &"cat_claw",
		},
	})

	assert_int(int(spark_rat.call("get_current_hp"))).is_equal(spark_hp_before - 12)
	assert_bool(get_tree().paused).is_true()
	assert_int(_presentation.get_hitstop_frames_remaining()).is_equal(3)
	assert_int(_presentation.get_active_spark_count()).is_equal(6)
	assert_str(String(_presentation.get_last_damage_number_snapshot().get(
		"text",
		""
	))).is_equal("12")
	assert_str(String(_input_manager.call("get_input_state"))).is_equal("buffering")
	assert_bool(bool(_input_manager.call(
		"accept_action",
		&"attack",
		Time.get_ticks_msec() - 1,
		&"kbm"
	))).is_true()

	while _presentation.is_gameplay_hitstop_active():
		await get_tree().process_frame

	assert_bool(get_tree().paused).is_false()
	assert_int(_presentation.get_last_completed_hitstop_frames()).is_equal(3)
	assert_str(String(_input_manager.call("get_input_state"))).is_equal("direct")
	assert_int(int(_input_manager.call("get_buffered_action_count"))).is_equal(0)
	assert_bool(_factory.has_method("get_last_buffered_input_result")).is_true()
	if not _factory.has_method("get_last_buffered_input_result"):
		return
	var buffered: Dictionary = _factory.call("get_last_buffered_input_result")
	assert_str(String(buffered.get("action_id", &""))).is_equal("attack")
	assert_bool(bool(buffered.get("accepted", false))).is_true()
	assert_int(int(buffered.get("dispatch_count", 0))).is_equal(1)
	assert_bool(_input_manager.action_triggered.is_connected(
		_combat.on_action_triggered
	)).override_failure_message(
		"HitstopInputBridge must remain the only buffered-action dispatch owner"
	).is_false()


func test_real_spark_rat_bite_uses_nine_damage_and_three_frame_feedback_once() -> void:
	assert_that(_presentation).is_not_null()
	if _presentation == null:
		return
	var spark_rat: CharacterBody2D = await _activate_spark_rat()
	var spark_collision: CollisionComponent = spark_rat.call(
		"get_collision_component"
	) as CollisionComponent
	var hp_before: int = _player.get_current_hp()

	spark_collision.process_detection_frame({
		SPARK_RAT_HITBOX_ID: [_player_collision.get_hurtbox()],
	})

	assert_int(_player.get_current_hp()).is_equal(hp_before - 9)
	assert_bool(_presentation.is_gameplay_hitstop_active()).is_true()
	assert_int(_presentation.get_hitstop_frames_remaining()).is_equal(3)
	assert_str(String(_presentation.get_last_damage_number_snapshot().get(
		"text",
		""
	))).is_equal("9")
	var hit: Dictionary = _factory.call("get_last_enemy_hit_metadata")
	assert_int(int(hit.get("damage", 0))).is_equal(9)
	assert_str(String(hit.get("source", &""))).is_equal("factory_spark_rat")

	spark_collision.process_detection_frame({
		SPARK_RAT_HITBOX_ID: [_player_collision.get_hurtbox()],
	})
	assert_int(_player.get_current_hp()).is_equal(hp_before - 9)


func test_perfect_parry_and_lethal_counter_use_special_and_kill_feedback() -> void:
	assert_that(_presentation).is_not_null()
	if _presentation == null:
		return
	var spark_rat: CharacterBody2D = await _activate_spark_rat()
	var spark_collision: CollisionComponent = spark_rat.call(
		"get_collision_component"
	) as CollisionComponent
	assert_bool(_player.request_parry()).is_true()
	var hp_before: int = _player.get_current_hp()

	spark_collision.process_detection_frame({
		SPARK_RAT_HITBOX_ID: [_player_collision.get_hurtbox()],
	})

	assert_int(_player.get_current_hp()).is_equal(hp_before)
	assert_int(_presentation.get_hitstop_frames_remaining()).is_equal(8)
	assert_int(_presentation.get_active_parry_spark_count()).is_equal(22)
	assert_int(_presentation.get_active_flash_count()).is_equal(1)
	assert_int(
		_presentation.get_active_perfect_parry_afterimage_count()
	).is_equal(1)
	assert_dict(Dictionary(_factory.call("get_last_enemy_hit_metadata"))).is_empty()
	while _presentation.is_gameplay_hitstop_active():
		await get_tree().process_frame

	assert_bool(bool(_factory.call(
		"apply_damage",
		SPARK_RAT_ENTITY_ID,
		12,
		{"source": &"story028_lethal_setup"}
	))).is_true()
	assert_int(int(spark_rat.call("get_current_hp"))).is_equal(12)
	_combat.on_hit_confirmed({
		"target_id": SPARK_RAT_ENTITY_ID,
		"hit_frame": 4,
		"hit_position": spark_rat.global_position,
		"attack_metadata": {
			"attack_type": &"light",
			"weapon_id": &"cat_claw",
		},
	})

	assert_int(int(spark_rat.call("get_current_hp"))).is_equal(0)
	assert_int(_presentation.get_hitstop_frames_remaining()).is_equal(6)
	assert_int(_presentation.get_active_debris_count()).is_equal(18)
	var impact: Dictionary = _factory.call(
		"get_factory_combat_presentation_diagnostics"
	)
	assert_int(int(impact.get("kill_feedback_count", 0))).is_equal(1)
	assert_array(Array(impact.get(
		"kill_feedback_entity_ids",
		[]
	))).contains([SPARK_RAT_ENTITY_ID])


func _activate_spark_rat() -> CharacterBody2D:
	await _open_deep_route_endpoint()
	assert_bool(bool(_factory.call(
		"try_activate_factory_spark_rat",
		_player
	))).is_true()
	var spark_rat: CharacterBody2D = _factory.get_node(
		"FactorySparkRat"
	) as CharacterBody2D
	spark_rat.set_physics_process(false)
	assert_bool(bool(spark_rat.call("request_attack"))).is_true()
	spark_rat.call(
		"advance_attack_frames",
		int(spark_rat.call("get_attack_startup_frames"))
	)
	return spark_rat


func _open_deep_route_endpoint() -> void:
	await _defeat_guard("FactoryRatMinion", &"story028_entry_clear")
	var route: Dictionary = _factory.call("get_factory_deep_route_diagnostics")
	_player.global_position.x = float(route.get("deep_guard_activation_x", 0.0)) + 8.0
	assert_bool(bool(_factory.call(
		"try_activate_factory_deep_guard",
		_player
	))).is_true()
	await _defeat_guard("FactoryDeepGuardRatMinion", &"story028_deep_clear")
	var endpoint: Node2D = _factory.get_node("FactoryDeepRouteEndpoint") as Node2D
	_player.global_position = endpoint.global_position
	assert_bool(bool(_factory.call(
		"try_activate_factory_deep_route_endpoint",
		_player
	))).is_true()


func _defeat_guard(guard_name: String, reason: StringName) -> void:
	var guard: Node = _factory.get_node(guard_name)
	if guard.has_method("kill_summon"):
		guard.call("kill_summon", reason)
	else:
		guard.call("apply_damage", int(guard.call("get_current_hp")), {})
	await get_tree().process_frame


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	if audio_system.has_method("stop_music"):
		audio_system.call("stop_music", 0.0)
	if audio_system.has_method("stop_ambient"):
		audio_system.call("stop_ambient", 0.0)
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
		elif child is AudioStreamPlayer2D:
			(child as AudioStreamPlayer2D).stop()
