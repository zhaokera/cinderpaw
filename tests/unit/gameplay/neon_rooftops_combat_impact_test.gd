## Combat Presentation Story026: Neon Rooftops combat has real impact feedback.
extends GdUnitTestSuite

const ROOFTOPS_SCENE: PackedScene = preload(
	"res://scenes/areas/neon_rooftops_entry.tscn"
)
const LIGHT_HITBOX_ID: StringName = &"cat_claw_light"
const SIGNAL_RAT_HITBOX_ID: StringName = &"neon_signal_rat_lunge"
const SIGNAL_RAT_ENTITY_ID: int = 2601
const SIGNAL_RAT_ACTIVATION_X: float = 1650.0
const SIGNAL_RAT_STARTUP_FRAMES: int = 18
const TOWER_TRIAL_NODE: NodePath = NodePath("TowerParryTrialController")
const TOWER_EMITTER_NODE: NodePath = NodePath(
	"TowerParryTrialController/LaserEmitter"
)


class FakeSceneManager:
	extends RefCounted

	func request_scene_change(_scene_id: StringName, _spawn: StringName) -> bool:
		return true


var _rooftops: Node
var _player: PlayerController
var _combat: CombatComponent
var _player_collision: CollisionComponent
var _signal_rat: CharacterBody2D
var _signal_rat_collision: CollisionComponent
var _signal_controller: Node
var _presentation: CombatPresentation
var _input_manager: Node


func before_test() -> void:
	Input.action_release(&"attack")
	get_tree().paused = false
	_input_manager = get_node("/root/InputManager")
	_input_manager.call("clear_buffer")
	_input_manager.call("notify_animation_lock", 0)
	_rooftops = ROOFTOPS_SCENE.instantiate()
	add_child(_rooftops)
	_rooftops.set_process(false)
	_player = _rooftops.get_node("Player") as PlayerController
	_combat = _player.get_combat_component()
	_player_collision = _player.get_collision_component()
	_signal_controller = _rooftops.get_node("SignalRoofEncounter")
	_signal_controller.set_process(false)
	_signal_rat = _rooftops.get_node(
		"SignalRoofEncounter/NeonSignalRat"
	) as CharacterBody2D
	_signal_rat.set_physics_process(false)
	_signal_rat_collision = _signal_rat.call(
		"get_collision_component"
	) as CollisionComponent
	_presentation = _rooftops.get_node_or_null(
		"CombatPresentation"
	) as CombatPresentation


func after_test() -> void:
	get_tree().paused = false
	Input.action_release(&"attack")
	if _input_manager != null:
		_input_manager.call("clear_buffer")
		_input_manager.call("notify_animation_lock", 0)
	_stop_runtime_audio_players()
	if is_instance_valid(_rooftops):
		if _rooftops.get_parent() != null:
			_rooftops.get_parent().remove_child(_rooftops)
		_rooftops.free()
	_rooftops = null
	_player = null
	_combat = null
	_player_collision = null
	_signal_rat = null
	_signal_rat_collision = null
	_signal_controller = null
	_presentation = null
	_input_manager = null


func test_real_player_hit_freezes_three_frames_and_releases_one_buffered_attack() -> void:
	var bridge: Node = _rooftops.get_node_or_null("HitstopInputBridge")
	assert_that(_presentation).override_failure_message(
		"Story026 requires one CombatPresentation in Neon Rooftops"
	).is_not_null()
	assert_that(bridge).override_failure_message(
		"Story026 requires one shared HitstopInputBridge in Neon Rooftops"
	).is_not_null()
	assert_int(_rooftops.find_children(
		"CombatPresentation", "", true, false
	).size()).is_equal(1)
	assert_int(_rooftops.find_children(
		"HitstopInputBridge", "", true, false
	).size()).is_equal(1)
	if _presentation == null or bridge == null:
		return
	_activate_signal_rat()
	var hp_before: int = int(_signal_rat.call("get_current_hp"))

	_trigger_player_hit()

	assert_int(int(_signal_rat.call("get_current_hp"))).is_equal(hp_before - 12)
	assert_bool(get_tree().paused).is_true()
	assert_bool(_presentation.is_gameplay_hitstop_active()).is_true()
	assert_int(_presentation.get_hitstop_frames_remaining()).is_equal(3)
	assert_int(_presentation.get_active_spark_count()).is_equal(6)
	assert_str(String(_presentation.get_last_damage_number_snapshot().get(
		"text",
		""
	))).is_equal("12")
	var hit: Dictionary = _rooftops.call("get_last_signal_roof_player_hit")
	assert_int(int(hit.get("target_id", -1))).is_equal(SIGNAL_RAT_ENTITY_ID)
	assert_int(int(hit.get("damage_applied", 0))).is_equal(12)
	assert_bool(bool(hit.get("damage_was_applied", false))).is_true()
	assert_str(String(_input_manager.call("get_input_state"))).is_equal(
		"buffering"
	)
	assert_bool(bool(_input_manager.call(
		"accept_action",
		&"attack",
		Time.get_ticks_msec() - 1,
		&"kbm"
	))).is_true()
	assert_int(int(_input_manager.call("get_buffered_action_count"))).is_equal(1)

	while _presentation.is_gameplay_hitstop_active():
		await get_tree().process_frame

	assert_bool(get_tree().paused).is_false()
	assert_int(_presentation.get_last_completed_hitstop_frames()).is_equal(3)
	assert_str(String(_input_manager.call("get_input_state"))).is_equal("direct")
	assert_int(int(_input_manager.call("get_buffered_action_count"))).is_equal(0)
	assert_bool(_rooftops.has_method("get_last_buffered_input_result")).is_true()
	if not _rooftops.has_method("get_last_buffered_input_result"):
		return
	var buffered: Dictionary = _rooftops.call("get_last_buffered_input_result")
	assert_str(String(buffered.get("action_id", &""))).is_equal("attack")
	assert_bool(bool(buffered.get("accepted", false))).is_true()
	assert_int(int(buffered.get("dispatch_count", 0))).is_equal(1)
	assert_bool(_input_manager.action_triggered.is_connected(
		_combat.on_action_triggered
	)).override_failure_message(
		"HitstopInputBridge must remain the only buffered-action dispatch owner"
	).is_false()


func test_signal_rat_lunge_uses_actual_damage_and_three_frame_feedback() -> void:
	assert_that(_presentation).is_not_null()
	if _presentation == null:
		return
	_activate_signal_rat()
	assert_bool(_prepare_signal_rat_attack()).is_true()
	var hp_before: int = _player.get_current_hp()

	_signal_rat_collision.process_detection_frame({
		SIGNAL_RAT_HITBOX_ID: [_player_collision.get_hurtbox()],
	})

	assert_int(_player.get_current_hp()).is_equal(hp_before - 11)
	assert_bool(get_tree().paused).is_true()
	assert_int(_presentation.get_hitstop_frames_remaining()).is_equal(3)
	assert_str(String(_presentation.get_last_damage_number_snapshot().get(
		"text",
		""
	))).is_equal("11")
	assert_bool(_rooftops.has_method("get_last_signal_roof_enemy_hit")).is_true()
	if not _rooftops.has_method("get_last_signal_roof_enemy_hit"):
		return
	var enemy_hit: Dictionary = _rooftops.call(
		"get_last_signal_roof_enemy_hit"
	)
	assert_int(int(enemy_hit.get("damage", 0))).is_equal(11)


func test_dodge_rejection_does_not_emit_false_signal_rat_feedback() -> void:
	assert_that(_presentation).is_not_null()
	if _presentation == null:
		return
	_activate_signal_rat()
	assert_bool(_player.request_dodge()).is_true()
	_combat.advance_dodge_frames(3)
	assert_bool(_combat.is_dodge_iframe_active()).is_true()
	assert_bool(_prepare_signal_rat_attack()).is_true()
	var hp_before: int = _player.get_current_hp()

	_signal_rat_collision.process_detection_frame({
		SIGNAL_RAT_HITBOX_ID: [_player_collision.get_hurtbox()],
	})

	assert_int(_player.get_current_hp()).is_equal(hp_before)
	assert_bool(_presentation.is_gameplay_hitstop_active()).is_false()
	assert_int(_presentation.get_active_damage_number_count()).is_equal(0)
	assert_dict(Dictionary(_rooftops.call(
		"get_last_signal_roof_enemy_hit"
	))).is_empty()
	assert_str(String(_player_collision.get_hurtbox_state())).is_equal("gone")
	var rejected: Dictionary = _signal_rat.call(
		"get_last_enemy_attack_metadata"
	)
	assert_dict(rejected).override_failure_message(
		"Dodge iframes reject the collision before enemy combat metadata exists"
	).is_empty()


func test_real_final_hit_uses_six_frame_kill_feedback_once() -> void:
	assert_that(_presentation).is_not_null()
	assert_bool(_rooftops.has_method(
		"get_neon_combat_presentation_diagnostics"
	)).is_true()
	if (
		_presentation == null
		or not _rooftops.has_method(
			"get_neon_combat_presentation_diagnostics"
		)
	):
		return
	_activate_signal_rat()
	assert_bool(bool(_rooftops.call(
		"apply_damage",
		SIGNAL_RAT_ENTITY_ID,
		24,
		{"source": &"story026_lethal_setup"}
	))).is_true()
	assert_int(int(_signal_rat.call("get_current_hp"))).is_equal(12)

	_trigger_player_hit()
	_player_collision.process_detection_frame({
		LIGHT_HITBOX_ID: [_signal_rat_collision.get_hurtbox()],
	})

	assert_int(int(_signal_rat.call("get_current_hp"))).is_equal(0)
	assert_bool(get_tree().paused).is_true()
	assert_int(_presentation.get_hitstop_frames_remaining()).is_equal(6)
	assert_int(_presentation.get_active_debris_count()).is_equal(18)
	assert_int(_presentation.get_active_spark_count()).is_equal(6)
	var impact: Dictionary = _rooftops.call(
		"get_neon_combat_presentation_diagnostics"
	)
	assert_int(int(impact.get("kill_feedback_count", 0))).is_equal(1)
	var encounter: Dictionary = _rooftops.call("get_signal_roof_diagnostics")
	assert_bool(bool(encounter.get("signal_rat_defeated", false))).is_true()
	assert_str(String(encounter.get("enemy_animation", ""))).is_equal("death")
	assert_bool(bool(encounter.get("cache_available", false))).is_true()


func test_laser_perfect_parry_uses_eight_frame_special_feedback() -> void:
	assert_that(_presentation).is_not_null()
	if _presentation == null:
		return
	_rooftops.call("set_local_state", _tower_trial_prerequisite_state())
	var controller: Node = _rooftops.get_node(TOWER_TRIAL_NODE)
	var emitter: Node2D = _rooftops.get_node(TOWER_EMITTER_NODE) as Node2D
	controller.set_process(false)
	_player.global_position = emitter.global_position
	assert_bool(bool(_rooftops.call(
		"try_activate_central_tower_parry_trial",
		_player
	))).is_true()
	_rooftops.call("advance_central_tower_parry_trial", 0.61)
	assert_bool(_player.request_parry()).is_true()

	assert_bool(_presentation.is_gameplay_hitstop_active()).is_true()
	assert_int(_presentation.get_hitstop_frames_remaining()).is_equal(8)
	assert_int(_presentation.get_active_damage_number_count()).is_equal(0)
	assert_int(_presentation.get_active_parry_spark_count()).is_equal(22)
	assert_int(_presentation.get_active_flash_count()).is_equal(1)
	assert_int(
		_presentation.get_active_perfect_parry_afterimage_count()
	).is_equal(1)
	var trial: Dictionary = _rooftops.call(
		"get_central_tower_parry_trial_diagnostics"
	)
	assert_int(int(trial.get("successful_parries", 0))).is_equal(1)
	var impact: Dictionary = _rooftops.call(
		"get_neon_combat_presentation_diagnostics"
	)
	assert_int(int(impact.get("laser_parry_feedback_count", 0))).is_equal(1)


func test_cached_scene_reentry_reconfigures_the_shared_input_bridge() -> void:
	assert_that(_presentation).is_not_null()
	var bridge: Node = _rooftops.get_node_or_null("HitstopInputBridge")
	assert_that(bridge).is_not_null()
	if _presentation == null or bridge == null:
		return
	remove_child(_rooftops)
	add_child(_rooftops)
	assert_bool(bool(_rooftops.call(
		"configure_scene_manager_runtime",
		FakeSceneManager.new()
	))).is_true()
	_activate_signal_rat()

	_trigger_player_hit()

	assert_bool(_presentation.is_gameplay_hitstop_active()).is_true()
	assert_str(String(_input_manager.call("get_input_state"))).override_failure_message(
		"A cached Neon Rooftops instance must rebind hitstop input on re-entry"
	).is_equal("buffering")


func _activate_signal_rat() -> void:
	_rooftops.call("set_local_state", _signal_roof_prerequisite_state())
	_player.global_position.x = SIGNAL_RAT_ACTIVATION_X
	assert_bool(bool(_rooftops.call(
		"try_activate_signal_roof_encounter",
		_player
	))).is_true()
	_signal_rat.set_physics_process(false)


func _trigger_player_hit() -> void:
	assert_bool(_player.request_attack()).is_true()
	_combat.advance_attack_frames(4)
	assert_bool(_player_collision.is_hitbox_active(LIGHT_HITBOX_ID)).is_true()
	_player_collision.process_detection_frame({
		LIGHT_HITBOX_ID: [_signal_rat_collision.get_hurtbox()],
	})


func _prepare_signal_rat_attack() -> bool:
	var requested: bool = bool(_rooftops.call("request_signal_rat_attack"))
	_signal_rat.call("advance_attack_frames", SIGNAL_RAT_STARTUP_FRAMES)
	return requested and _signal_rat_collision.is_hitbox_active(
		SIGNAL_RAT_HITBOX_ID
	)


func _signal_roof_prerequisite_state() -> Dictionary:
	return {
		"neon_rooftops_entry_arrived": true,
		"neon_rooftops_entry_traversed": true,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb",
		],
	}


func _tower_trial_prerequisite_state() -> Dictionary:
	return {
		"neon_rooftops_entry_arrived": true,
		"neon_rooftops_entry_traversed": true,
		"neon_rooftops_signal_rat_encounter_activated": true,
		"neon_rooftops_signal_rat_defeated": true,
		"neon_rooftops_signal_cache_claimed": true,
		"neon_rooftops_relay_spire_roost_activated": true,
		"neon_rooftops_relay_spire_traversed": true,
		"neon_rooftops_relay_spire_last_savepoint": {
			"id": "neon_rooftops_relay_spire_roost",
			"scene_id": "area_05_neon_rooftops",
			"spawn_point": "relay_spire_roost",
			"position": {"x": 2760.0, "y": 413.0},
		},
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb", "parry",
		],
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
