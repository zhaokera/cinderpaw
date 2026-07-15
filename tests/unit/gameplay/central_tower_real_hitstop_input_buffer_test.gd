## Combat Presentation Story024: Central Tower uses real hitstop and buffered input.
extends GdUnitTestSuite

const TOWER_SCENE: PackedScene = preload(
	"res://scenes/areas/central_tower_threshold.tscn"
)
const LIGHT_HITBOX_ID: StringName = &"cat_claw_light"
const GUARD_HITBOX_ID: StringName = &"central_tower_guard_latch_thrust"
const GUARD_ACTIVATION_X: float = 420.0
const GUARD_STARTUP_FRAMES: int = 24
const GUARD_DAMAGE: int = 14
const ENEMY_PATHS: Array[NodePath] = [
	NodePath("ThresholdGuardController/CentralTowerThresholdGuard"),
	NodePath("InnerRelayController/CentralTowerRelayMantis"),
	NodePath("DeepLiftController/CentralTowerCounterweightSentry"),
]

var tower: Node
var player: PlayerController
var combat: CombatComponent
var player_collision: CollisionComponent
var guard: CharacterBody2D
var guard_collision: CollisionComponent
var presentation: CombatPresentation
var input_manager: Node


func before_test() -> void:
	Input.action_release(&"attack")
	get_tree().paused = false
	input_manager = get_node("/root/InputManager")
	input_manager.call("clear_buffer")
	input_manager.call("notify_animation_lock", 0)
	tower = TOWER_SCENE.instantiate()
	add_child(tower)
	player = tower.get_node("Player") as PlayerController
	combat = player.get_combat_component()
	player_collision = player.get_collision_component()
	guard = tower.get_node(
		"ThresholdGuardController/CentralTowerThresholdGuard"
	) as CharacterBody2D
	guard.set_physics_process(false)
	guard_collision = guard.call("get_collision_component") as CollisionComponent
	presentation = tower.get_node_or_null("CombatPresentation") as CombatPresentation


func after_test() -> void:
	get_tree().paused = false
	Input.action_release(&"attack")
	if input_manager != null:
		input_manager.call("clear_buffer")
		input_manager.call("notify_animation_lock", 0)
	_stop_runtime_audio_players()
	if is_instance_valid(tower):
		if tower.get_parent() != null:
			tower.get_parent().remove_child(tower)
		tower.free()
	tower = null
	player = null
	combat = null
	player_collision = null
	guard = null
	guard_collision = null
	presentation = null
	input_manager = null


func test_real_player_hit_freezes_three_frames_and_dispatches_one_buffered_attack() -> void:
	var bridge: Node = tower.get_node_or_null("HitstopInputBridge")
	assert_that(presentation).override_failure_message(
		"Story024 requires CombatPresentation in Central Tower"
	).is_not_null()
	assert_that(bridge).override_failure_message(
		"Story024 requires the shared HitstopInputBridge in Central Tower"
	).is_not_null()
	if presentation == null or bridge == null:
		return
	_activate_guard()
	var guard_hp_before: int = int(guard.call("get_current_hp"))

	assert_bool(player.request_attack()).is_true()
	combat.advance_attack_frames(4)
	assert_bool(player_collision.is_hitbox_active(LIGHT_HITBOX_ID)).is_true()
	guard_collision.process_detection_frame({})
	player_collision.process_detection_frame({
		LIGHT_HITBOX_ID: [guard_collision.get_hurtbox()],
	})

	assert_int(int(guard.call("get_current_hp"))).is_equal(guard_hp_before - 12)
	assert_bool(get_tree().paused).is_true()
	assert_bool(presentation.is_gameplay_hitstop_active()).is_true()
	assert_int(presentation.get_hitstop_frames_remaining()).is_equal(3)
	assert_str(String(input_manager.call("get_input_state"))).is_equal("buffering")
	var damage_snapshot: Dictionary = presentation.get_last_damage_number_snapshot()
	assert_str(String(damage_snapshot.get("text", ""))).is_equal("12")
	assert_bool(bool(input_manager.call(
		"accept_action",
		&"attack",
		Time.get_ticks_msec() - 1,
		&"kbm"
	))).is_true()
	assert_int(int(input_manager.call("get_buffered_action_count"))).is_equal(1)

	while presentation.is_gameplay_hitstop_active():
		await get_tree().process_frame

	assert_bool(get_tree().paused).is_false()
	assert_int(presentation.get_last_completed_hitstop_frames()).is_equal(3)
	assert_str(String(input_manager.call("get_input_state"))).is_equal("direct")
	assert_int(int(input_manager.call("get_buffered_action_count"))).is_equal(0)
	assert_bool(tower.has_method("get_last_buffered_input_result")).is_true()
	if not tower.has_method("get_last_buffered_input_result"):
		return
	var result: Dictionary = tower.call("get_last_buffered_input_result")
	assert_str(String(result.get("action_id", &""))).is_equal("attack")
	assert_bool(bool(result.get("accepted", false))).is_true()
	assert_int(int(result.get("dispatch_count", 0))).is_equal(1)
	assert_bool(input_manager.action_triggered.is_connected(
		combat.on_action_triggered
	)).override_failure_message(
		"HitstopInputBridge must remain the only buffered-action dispatch owner"
	).is_false()


func test_real_guard_hit_uses_actual_damage_and_the_same_three_frame_path() -> void:
	assert_that(presentation).is_not_null()
	if presentation == null:
		return
	_activate_guard()
	assert_bool(_prepare_guard_attack()).is_true()
	var player_hp_before: int = player.get_current_hp()

	guard_collision.process_detection_frame({
		GUARD_HITBOX_ID: [player_collision.get_hurtbox()],
	})

	assert_int(player.get_current_hp()).is_equal(player_hp_before - GUARD_DAMAGE)
	assert_bool(get_tree().paused).is_true()
	assert_bool(presentation.is_gameplay_hitstop_active()).is_true()
	assert_int(presentation.get_hitstop_frames_remaining()).is_equal(3)
	var damage_snapshot: Dictionary = presentation.get_last_damage_number_snapshot()
	assert_str(String(damage_snapshot.get("text", ""))).is_equal("14")
	var guard_metadata: Dictionary = guard.call("get_last_enemy_attack_metadata")
	assert_int(int(guard_metadata.get("damage_applied", 0))).is_equal(GUARD_DAMAGE)
	assert_bool(bool(guard_metadata.get("damage_was_applied", false))).is_true()

	while presentation.is_gameplay_hitstop_active():
		await get_tree().process_frame

	assert_bool(get_tree().paused).is_false()
	assert_int(presentation.get_last_completed_hitstop_frames()).is_equal(3)


func test_dodge_iframes_do_not_emit_ordinary_hit_feedback() -> void:
	assert_that(presentation).is_not_null()
	if presentation == null:
		return
	_activate_guard()
	assert_bool(player.request_dodge()).is_true()
	combat.advance_dodge_frames(3)
	assert_bool(combat.is_dodge_iframe_active()).is_true()
	assert_bool(_prepare_guard_attack()).is_true()
	var hp_before_dodge: int = player.get_current_hp()
	guard_collision.process_detection_frame({
		GUARD_HITBOX_ID: [player_collision.get_hurtbox()],
	})

	assert_int(player.get_current_hp()).is_equal(hp_before_dodge)
	assert_bool(presentation.is_gameplay_hitstop_active()).is_false()
	assert_int(presentation.get_active_damage_number_count()).is_equal(0)
	assert_dict(Dictionary(tower.call(
		"get_last_enemy_hit_metadata"
	))).is_empty()
	var dodge_metadata: Dictionary = guard.call("get_last_enemy_attack_metadata")
	assert_dict(dodge_metadata).is_empty()


func test_respawn_iframes_do_not_emit_ordinary_hit_feedback() -> void:
	assert_that(presentation).is_not_null()
	if presentation == null:
		return
	_activate_guard()
	player.respawn_at(Vector2(520.0, 552.0), 1.0)
	var health: HealthComponent = player.get_node("HealthComponent") as HealthComponent
	assert_int(health.get_iframe_remaining()).is_equal(120)
	assert_bool(_prepare_guard_attack()).is_true()
	var hp_before_respawn_hit: int = player.get_current_hp()
	guard_collision.process_detection_frame({
		GUARD_HITBOX_ID: [player_collision.get_hurtbox()],
	})

	assert_int(player.get_current_hp()).is_equal(hp_before_respawn_hit)
	assert_bool(presentation.is_gameplay_hitstop_active()).is_false()
	assert_int(presentation.get_active_damage_number_count()).is_equal(0)
	assert_dict(Dictionary(tower.call(
		"get_last_enemy_hit_metadata"
	))).is_empty()
	var respawn_metadata: Dictionary = guard.call("get_last_enemy_attack_metadata")
	assert_bool(bool(respawn_metadata.get("damage_was_applied", true))).is_false()


func test_perfect_parry_keeps_special_feedback_without_false_guard_damage_number() -> void:
	assert_that(presentation).is_not_null()
	if presentation == null:
		return
	_activate_guard()
	assert_bool(_prepare_guard_attack()).is_true()
	assert_bool(player.request_parry()).is_true()
	var hp_before: int = player.get_current_hp()
	guard_collision.process_detection_frame({
		GUARD_HITBOX_ID: [player_collision.get_hurtbox()],
	})

	assert_int(player.get_current_hp()).is_equal(hp_before)
	assert_int(presentation.get_active_damage_number_count()).is_equal(0)
	assert_bool(presentation.is_gameplay_hitstop_active()).is_true()
	assert_int(presentation.get_hitstop_frames_remaining()).is_equal(8)
	assert_int(presentation.get_active_perfect_parry_afterimage_count()).is_equal(1)
	assert_dict(Dictionary(tower.call(
		"get_last_enemy_hit_metadata"
	))).is_empty()


func test_all_three_tower_enemies_share_one_scene_presentation_handler() -> void:
	assert_int(tower.find_children(
		"CombatPresentation", "", true, false
	).size()).is_equal(1)
	assert_int(tower.find_children(
		"HitstopInputBridge", "", true, false
	).size()).is_equal(1)
	var presentation_handler := Callable(tower, "_on_enemy_attack_landed")
	for enemy_path: NodePath in ENEMY_PATHS:
		var enemy: Node = tower.get_node_or_null(enemy_path)
		assert_that(enemy).override_failure_message(
			"Missing Central Tower enemy at %s" % enemy_path
		).is_not_null()
		if enemy == null:
			continue
		var attack_signal: Signal = enemy.get("enemy_attack_landed")
		assert_bool(attack_signal.is_connected(presentation_handler)).override_failure_message(
			"%s must route real hits through the scene presentation owner" % enemy_path
		).is_true()


func _activate_guard() -> void:
	player.global_position.x = GUARD_ACTIVATION_X
	assert_bool(bool(tower.call("try_activate_threshold_guard", player))).is_true()
	guard.set_physics_process(false)


func _prepare_guard_attack() -> bool:
	guard.call("reset_for_encounter")
	guard.call("advance_pacing_frames", 25)
	var requested: bool = bool(tower.call("request_threshold_guard_attack"))
	guard.call("advance_attack_frames", GUARD_STARTUP_FRAMES)
	return requested and guard_collision.is_hitbox_active(GUARD_HITBOX_ID)


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
