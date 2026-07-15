## Combat Presentation Story027: Underground combat has real impact feedback.
extends GdUnitTestSuite

const UNDERGROUND_SCENE: PackedScene = preload(
	"res://scenes/areas/underground_passage.tscn"
)
const LIGHT_HITBOX_ID: StringName = &"cat_claw_light"
const LEECH_HITBOX_ID: StringName = &"factory_sluice_leech_lunge"
const STALKER_HITBOX_ID: StringName = &"underground_cistern_stalker_leap"
const LEFT_LEECH_ENTITY_ID: int = 2401
const STALKER_ENTITY_ID: int = 2501
const CORROSION_ACTIVATION_X: float = 1450.0
const STALKER_ACTIVATION_X: float = 4050.0
const LEECH_STARTUP_FRAMES: int = 18
const STALKER_STARTUP_FRAMES: int = 24
const STALKER_NODE_PATH: NodePath = NodePath(
	"DeepCisternAmbushController/CisternStalker"
)


class FakeSceneManager:
	extends RefCounted

	func request_scene_change(_scene_id: StringName, _spawn: StringName) -> bool:
		return true


var _underground: Node
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
	_underground = UNDERGROUND_SCENE.instantiate()
	add_child(_underground)
	_underground.set_process(false)
	_player = _underground.get_node("Player") as PlayerController
	_combat = _player.get_combat_component()
	_player_collision = _player.get_collision_component()
	_presentation = _underground.get_node_or_null(
		"CombatPresentation"
	) as CombatPresentation


func after_test() -> void:
	get_tree().paused = false
	Input.action_release(&"attack")
	if _input_manager != null:
		_input_manager.call("clear_buffer")
		_input_manager.call("notify_animation_lock", 0)
	_stop_runtime_audio_players()
	if is_instance_valid(_underground):
		if _underground.get_parent() != null:
			_underground.get_parent().remove_child(_underground)
		_underground.free()
	_underground = null
	_player = null
	_combat = null
	_player_collision = null
	_presentation = null
	_input_manager = null


func test_real_leech_hit_freezes_three_frames_and_releases_one_buffered_attack() -> void:
	var bridge: Node = _underground.get_node_or_null("HitstopInputBridge")
	assert_that(_presentation).override_failure_message(
		"Story027 requires one CombatPresentation in Underground Passage"
	).is_not_null()
	assert_that(bridge).override_failure_message(
		"Story027 requires one shared HitstopInputBridge in Underground Passage"
	).is_not_null()
	assert_int(_underground.find_children(
		"CombatPresentation", "", true, false
	).size()).is_equal(1)
	assert_int(_underground.find_children(
		"HitstopInputBridge", "", true, false
	).size()).is_equal(1)
	if _presentation == null or bridge == null:
		return
	var leech: CharacterBody2D = _activate_left_leech()
	var hp_before: int = int(leech.call("get_current_hp"))

	_trigger_player_hit(leech)

	assert_int(int(leech.call("get_current_hp"))).is_equal(hp_before - 12)
	assert_bool(get_tree().paused).is_true()
	assert_int(_presentation.get_hitstop_frames_remaining()).is_equal(3)
	assert_int(_presentation.get_active_spark_count()).is_equal(6)
	assert_str(String(_presentation.get_last_damage_number_snapshot().get(
		"text",
		""
	))).is_equal("12")
	assert_str(String(_input_manager.call("get_input_state"))).is_equal(
		"buffering"
	)
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
	assert_bool(_underground.has_method("get_last_buffered_input_result")).is_true()
	if not _underground.has_method("get_last_buffered_input_result"):
		return
	var buffered: Dictionary = _underground.call(
		"get_last_buffered_input_result"
	)
	assert_str(String(buffered.get("action_id", &""))).is_equal("attack")
	assert_bool(bool(buffered.get("accepted", false))).is_true()
	assert_int(int(buffered.get("dispatch_count", 0))).is_equal(1)
	assert_bool(_input_manager.action_triggered.is_connected(
		_combat.on_action_triggered
	)).override_failure_message(
		"HitstopInputBridge must remain the only buffered-action dispatch owner"
	).is_false()


func test_real_leech_lunge_uses_actual_damage_and_three_frame_feedback() -> void:
	assert_that(_presentation).is_not_null()
	assert_bool(_underground.has_method("get_last_enemy_hit_metadata")).is_true()
	if (
		_presentation == null
		or not _underground.has_method("get_last_enemy_hit_metadata")
	):
		return
	var leech: CharacterBody2D = _activate_left_leech()
	assert_bool(bool(leech.call("request_attack"))).is_true()
	leech.call("advance_attack_frames", LEECH_STARTUP_FRAMES)
	var leech_collision: CollisionComponent = leech.call(
		"get_collision_component"
	) as CollisionComponent
	assert_bool(bool(leech.call("is_enemy_attack_active"))).is_true()
	assert_bool(leech_collision.is_hitbox_active(LEECH_HITBOX_ID)).is_true()
	assert_str(String(_player_collision.get_hurtbox_state())).is_equal("normal")
	assert_bool(_player_collision.get_hurtbox().monitorable).is_true()
	var hp_before: int = _player.get_current_hp()

	leech_collision.process_detection_frame({
		LEECH_HITBOX_ID: [_player_collision.get_hurtbox()],
	})

	assert_int(_player.get_current_hp()).is_equal(hp_before - 11)
	assert_bool(get_tree().paused).is_true()
	assert_int(_presentation.get_hitstop_frames_remaining()).is_equal(3)
	assert_str(String(_presentation.get_last_damage_number_snapshot().get(
		"text",
		""
	))).is_equal("11")
	var hit: Dictionary = _underground.call("get_last_enemy_hit_metadata")
	assert_int(int(hit.get("damage", 0))).is_equal(11)
	assert_str(String(hit.get("source", &""))).is_equal(
		"factory_sluice_leech"
	)


func test_dodge_rejection_does_not_emit_false_underground_feedback() -> void:
	assert_that(_presentation).is_not_null()
	assert_bool(_underground.has_method("get_last_enemy_hit_metadata")).is_true()
	if (
		_presentation == null
		or not _underground.has_method("get_last_enemy_hit_metadata")
	):
		return
	var leech: CharacterBody2D = _activate_left_leech()
	assert_bool(_player.request_dodge()).is_true()
	_combat.advance_dodge_frames(3)
	assert_bool(_combat.is_dodge_iframe_active()).is_true()
	assert_bool(bool(leech.call("request_attack"))).is_true()
	leech.call("advance_attack_frames", LEECH_STARTUP_FRAMES)
	var leech_collision: CollisionComponent = leech.call(
		"get_collision_component"
	) as CollisionComponent
	var hp_before: int = _player.get_current_hp()

	leech_collision.process_detection_frame({
		LEECH_HITBOX_ID: [_player_collision.get_hurtbox()],
	})

	assert_int(_player.get_current_hp()).is_equal(hp_before)
	assert_bool(_presentation.is_gameplay_hitstop_active()).is_false()
	assert_int(_presentation.get_active_damage_number_count()).is_equal(0)
	assert_dict(Dictionary(_underground.call(
		"get_last_enemy_hit_metadata"
	))).is_empty()
	assert_dict(Dictionary(leech.call(
		"get_last_enemy_attack_metadata"
	))).is_empty()


func test_real_leech_perfect_parry_uses_eight_frame_special_feedback() -> void:
	assert_that(_presentation).is_not_null()
	if _presentation == null:
		return
	var leech: CharacterBody2D = _activate_left_leech()
	assert_bool(bool(leech.call("request_attack"))).is_true()
	leech.call("advance_attack_frames", LEECH_STARTUP_FRAMES)
	var leech_collision: CollisionComponent = leech.call(
		"get_collision_component"
	) as CollisionComponent
	assert_bool(_player.request_parry()).is_true()
	var hp_before: int = _player.get_current_hp()

	leech_collision.process_detection_frame({
		LEECH_HITBOX_ID: [_player_collision.get_hurtbox()],
	})

	assert_int(_player.get_current_hp()).is_equal(hp_before)
	assert_int(_presentation.get_active_damage_number_count()).is_equal(0)
	assert_bool(_presentation.is_gameplay_hitstop_active()).is_true()
	assert_int(_presentation.get_hitstop_frames_remaining()).is_equal(8)
	assert_int(_presentation.get_active_parry_spark_count()).is_equal(22)
	assert_int(_presentation.get_active_flash_count()).is_equal(1)
	assert_int(
		_presentation.get_active_perfect_parry_afterimage_count()
	).is_equal(1)
	assert_dict(Dictionary(_underground.call(
		"get_last_enemy_hit_metadata"
	))).is_empty()


func test_real_stalker_leap_uses_actual_damage_and_three_frame_feedback() -> void:
	assert_that(_presentation).is_not_null()
	assert_bool(_underground.has_method("get_last_enemy_hit_metadata")).is_true()
	if (
		_presentation == null
		or not _underground.has_method("get_last_enemy_hit_metadata")
	):
		return
	var stalker: CharacterBody2D = _activate_stalker()
	assert_bool(bool(stalker.call("request_attack"))).is_true()
	stalker.call("advance_attack_frames", STALKER_STARTUP_FRAMES)
	var stalker_collision: CollisionComponent = stalker.call(
		"get_collision_component"
	) as CollisionComponent
	var hp_before: int = _player.get_current_hp()

	stalker_collision.process_detection_frame({
		STALKER_HITBOX_ID: [_player_collision.get_hurtbox()],
	})

	assert_int(_player.get_current_hp()).is_equal(hp_before - 14)
	assert_bool(get_tree().paused).is_true()
	assert_int(_presentation.get_hitstop_frames_remaining()).is_equal(3)
	assert_str(String(_presentation.get_last_damage_number_snapshot().get(
		"text",
		""
	))).is_equal("14")
	var hit: Dictionary = _underground.call("get_last_enemy_hit_metadata")
	assert_int(int(hit.get("damage", 0))).is_equal(14)
	assert_str(String(hit.get("source", &""))).is_equal(
		"underground_cistern_stalker"
	)


func test_real_stalker_final_hit_uses_six_frame_kill_feedback_once() -> void:
	assert_that(_presentation).is_not_null()
	assert_bool(_underground.has_method(
		"get_underground_combat_presentation_diagnostics"
	)).is_true()
	if (
		_presentation == null
		or not _underground.has_method(
			"get_underground_combat_presentation_diagnostics"
		)
	):
		return
	var stalker: CharacterBody2D = _activate_stalker()
	assert_bool(bool(_underground.call(
		"apply_damage",
		STALKER_ENTITY_ID,
		36,
		{"source": &"story027_lethal_setup"}
	))).is_true()
	assert_int(int(stalker.call("get_current_hp"))).is_equal(12)

	_trigger_player_hit(stalker)

	assert_int(int(stalker.call("get_current_hp"))).is_equal(0)
	assert_bool(get_tree().paused).is_true()
	assert_int(_presentation.get_hitstop_frames_remaining()).is_equal(6)
	assert_int(_presentation.get_active_debris_count()).is_equal(18)
	var impact: Dictionary = _underground.call(
		"get_underground_combat_presentation_diagnostics"
	)
	assert_int(int(impact.get("kill_feedback_count", 0))).is_equal(1)
	assert_array(Array(impact.get(
		"kill_feedback_entity_ids",
		[]
	))).contains([STALKER_ENTITY_ID])
	var encounter: Dictionary = _underground.call(
		"get_underground_deep_cistern_diagnostics"
	)
	assert_bool(bool(encounter.get("stalker_defeated", false))).is_true()
	assert_str(String(encounter.get("enemy_animation", ""))).is_equal("death")


func test_cached_reentry_after_freed_leech_rebinds_remaining_real_hit_once() -> void:
	assert_that(_presentation).is_not_null()
	var bridge: Node = _underground.get_node_or_null("HitstopInputBridge")
	assert_that(bridge).is_not_null()
	if _presentation == null or bridge == null:
		return
	var left_leech: CharacterBody2D = _activate_left_leech()
	var right_leech: CharacterBody2D = _underground.get_node(
		"CorrosionLeechRight"
	) as CharacterBody2D
	right_leech.set_physics_process(false)
	assert_bool(bool(_underground.call(
		"apply_damage",
		LEFT_LEECH_ENTITY_ID,
		12,
		{"source": &"story027_reentry_setup"}
	))).is_true()
	_trigger_player_hit(left_leech)
	assert_int(int(left_leech.call("get_current_hp"))).is_equal(0)
	while _presentation.is_gameplay_hitstop_active():
		await get_tree().process_frame
	left_leech.queue_free()
	await get_tree().process_frame
	assert_bool(is_instance_valid(left_leech)).is_false()

	remove_child(_underground)
	add_child(_underground)
	assert_bool(bool(_underground.call(
		"configure_scene_manager_runtime",
		FakeSceneManager.new()
	))).is_true()
	var hp_before: int = _player.get_current_hp()
	assert_bool(bool(right_leech.call("request_attack"))).is_true()
	right_leech.call("advance_attack_frames", LEECH_STARTUP_FRAMES)
	var right_collision: CollisionComponent = right_leech.call(
		"get_collision_component"
	) as CollisionComponent

	right_collision.process_detection_frame({
		LEECH_HITBOX_ID: [_player_collision.get_hurtbox()],
	})

	assert_int(_player.get_current_hp()).is_equal(hp_before - 11)
	assert_bool(_presentation.is_gameplay_hitstop_active()).is_true()
	assert_int(_presentation.get_hitstop_frames_remaining()).is_equal(3)
	assert_str(String(_input_manager.call("get_input_state"))).override_failure_message(
		"A cached Underground instance must rebind hitstop input on re-entry"
	).is_equal("buffering")
	assert_bool(bool(_input_manager.call(
		"accept_action",
		&"attack",
		Time.get_ticks_msec() - 1,
		&"kbm"
	))).is_true()
	while _presentation.is_gameplay_hitstop_active():
		await get_tree().process_frame
	assert_bool(get_tree().paused).is_false()
	assert_str(String(_input_manager.call("get_input_state"))).is_equal("direct")
	var buffered: Dictionary = _underground.call(
		"get_last_buffered_input_result"
	)
	assert_int(int(buffered.get("dispatch_count", 0))).is_equal(1)


func _activate_left_leech() -> CharacterBody2D:
	_player.global_position.x = CORROSION_ACTIVATION_X
	assert_bool(bool(_underground.call(
		"try_activate_corrosion_channel_encounter",
		_player
	))).is_true()
	var leech: CharacterBody2D = _underground.get_node(
		"CorrosionLeechLeft"
	) as CharacterBody2D
	leech.set_physics_process(false)
	return leech


func _activate_stalker() -> CharacterBody2D:
	_underground.call("set_local_state", _story132_traversed_state())
	_player.global_position.x = STALKER_ACTIVATION_X
	assert_bool(bool(_underground.call(
		"try_activate_deep_cistern_ambush",
		_player
	))).is_true()
	var stalker: CharacterBody2D = _underground.get_node(
		STALKER_NODE_PATH
	) as CharacterBody2D
	stalker.set_physics_process(false)
	return stalker


func _trigger_player_hit(enemy: CharacterBody2D) -> void:
	var enemy_collision: CollisionComponent = enemy.call(
		"get_collision_component"
	) as CollisionComponent
	assert_bool(_player.request_attack()).is_true()
	_combat.advance_attack_frames(4)
	assert_bool(_player_collision.is_hitbox_active(LIGHT_HITBOX_ID)).is_true()
	_player_collision.process_detection_frame({
		LIGHT_HITBOX_ID: [enemy_collision.get_hurtbox()],
	})


func _story132_traversed_state() -> Dictionary:
	return {
		"underground_corrosion_channel_activated": true,
		"underground_corrosion_left_defeated": true,
		"underground_corrosion_right_defeated": true,
		"underground_corrosion_channel_cleared": true,
		"underground_corrosion_salvage_claimed": true,
		"underground_recovery_cistern_relay_activated": true,
		"underground_recovery_cistern_traversed": true,
		"unlocked_abilities": ["aerial_attack"],
	}


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
