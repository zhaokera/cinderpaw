## Story 023: Sluice Matriarch combat uses the shared real-hitstop input bridge.
extends GdUnitTestSuite

const ARENA_SCENE: PackedScene = preload(
	"res://scenes/bosses/sluice_matriarch_arena.tscn"
)
const LIGHT_HITBOX_ID: StringName = &"cat_claw_light"
const PRESSURE_LUNGE_HITBOX_ID: StringName = &"sluice_matriarch_pressure_lunge"
const PRESSURE_GEYSER_PATTERN_ID: StringName = &"pressure_geyser"
const PRESSURE_GEYSER_HITBOX_ID: StringName = &"sluice_matriarch_pressure_geyser"


class PhysicsProbe extends Node:
	var physics_ticks: int = 0


	func _physics_process(_delta: float) -> void:
		physics_ticks += 1


var arena: Node
var player: PlayerController
var combat: CombatComponent
var collision: CollisionComponent
var boss: CharacterBody2D
var boss_collision: CollisionComponent
var presentation: CombatPresentation
var input_manager: Node


func before_test() -> void:
	Input.action_release(&"attack")
	get_tree().paused = false
	input_manager = get_node("/root/InputManager")
	input_manager.call("clear_buffer")
	input_manager.call("notify_animation_lock", 0)
	arena = ARENA_SCENE.instantiate()
	add_child(arena)
	player = arena.get_node("Player") as PlayerController
	combat = player.get_combat_component()
	collision = player.get_collision_component()
	boss = arena.get_node("SluiceMatriarchBoss") as CharacterBody2D
	boss.set_physics_process(false)
	boss_collision = boss.call("get_collision_component") as CollisionComponent
	presentation = arena.get_node_or_null("CombatPresentation") as CombatPresentation


func after_test() -> void:
	get_tree().paused = false
	Input.action_release(&"attack")
	if input_manager != null:
		input_manager.call("clear_buffer")
		input_manager.call("notify_animation_lock", 0)
	_stop_runtime_audio_players()
	if is_instance_valid(arena):
		if arena.get_parent() != null:
			arena.get_parent().remove_child(arena)
		arena.free()
	arena = null
	player = null
	combat = null
	collision = null
	boss = null
	boss_collision = null
	presentation = null
	input_manager = null


func test_player_hit_freezes_arena_and_releases_one_buffered_combo_attack() -> void:
	var bridge: Node = arena.get_node_or_null("HitstopInputBridge")
	assert_that(presentation).override_failure_message(
		"Story023 requires CombatPresentation in the Boss3 arena"
	).is_not_null()
	assert_that(bridge).override_failure_message(
		"Story023 requires the shared HitstopInputBridge in the Boss3 arena"
	).is_not_null()
	if presentation == null or bridge == null:
		return
	assert_bool(presentation.gameplay_freeze_enabled).is_true()
	var probe := PhysicsProbe.new()
	probe.name = "SluiceHitstopPhysicsProbe"
	probe.process_mode = Node.PROCESS_MODE_PAUSABLE
	arena.add_child(probe)
	await get_tree().physics_frame
	await get_tree().process_frame
	var ticks_before_hitstop: int = probe.physics_ticks
	var finish_probe_ticks: Array[int] = []
	presentation.hitstop_finished.connect(func(_consume: bool) -> void:
		finish_probe_ticks.append(probe.physics_ticks)
	, CONNECT_ONE_SHOT)
	var boss_hp_before: int = int(boss.call("get_current_hp"))

	assert_bool(player.request_attack()).is_true()
	combat.advance_attack_frames(4)
	assert_bool(collision.is_hitbox_active(LIGHT_HITBOX_ID)).is_true()
	collision.process_detection_frame({
		LIGHT_HITBOX_ID: [boss_collision.get_hurtbox()],
	})

	assert_int(int(boss.call("get_current_hp"))).is_equal(boss_hp_before - 12)
	assert_bool(get_tree().paused).is_true()
	assert_bool(presentation.is_gameplay_hitstop_active()).is_true()
	assert_str(String(input_manager.call("get_input_state"))).is_equal("buffering")
	if not get_tree().paused:
		return
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
	assert_int(finish_probe_ticks.size()).is_equal(1)
	if not finish_probe_ticks.is_empty():
		assert_int(finish_probe_ticks[0]).is_equal(ticks_before_hitstop)
	assert_str(String(input_manager.call("get_input_state"))).is_equal("direct")
	assert_int(int(input_manager.call("get_buffered_action_count"))).is_equal(0)
	assert_bool(arena.has_method("get_last_buffered_input_result")).is_true()
	if not arena.has_method("get_last_buffered_input_result"):
		return
	var result: Dictionary = arena.call("get_last_buffered_input_result")
	assert_str(String(result.get("action_id", &""))).is_equal("attack")
	assert_bool(bool(result.get("accepted", false))).is_true()
	assert_int(int(result.get("dispatch_count", 0))).is_equal(1)
	assert_bool(input_manager.action_triggered.is_connected(
		combat.on_action_triggered
	)).override_failure_message(
		"The bridge must be the only buffered-action dispatch owner"
	).is_false()
	var ticks_at_finish: int = probe.physics_ticks
	await get_tree().physics_frame
	await get_tree().process_frame
	assert_int(probe.physics_ticks).is_greater(ticks_at_finish)


func test_real_pressure_lunge_uses_the_same_three_frame_presentation_path() -> void:
	assert_that(presentation).is_not_null()
	if presentation == null:
		return
	var player_hp_before: int = player.get_current_hp()
	assert_bool(bool(boss.call("request_attack"))).is_true()
	boss.call("advance_attack_frames", int(boss.call(
		"get_current_attack_startup_frames"
	)))
	assert_bool(boss_collision.is_hitbox_active(PRESSURE_LUNGE_HITBOX_ID)).is_true()
	boss_collision.process_detection_frame({
		PRESSURE_LUNGE_HITBOX_ID: [collision.get_hurtbox()],
	})

	assert_int(player.get_current_hp()).is_equal(player_hp_before - 16)
	assert_bool(get_tree().paused).is_true()
	assert_bool(presentation.is_gameplay_hitstop_active()).is_true()
	assert_int(presentation.get_hitstop_frames_remaining()).is_equal(3)
	var damage_snapshot: Dictionary = presentation.get_last_damage_number_snapshot()
	assert_str(String(damage_snapshot.get("text", ""))).is_equal("16")
	if not get_tree().paused:
		return

	while presentation.is_gameplay_hitstop_active():
		await get_tree().process_frame

	assert_bool(get_tree().paused).is_false()
	assert_int(presentation.get_last_completed_hitstop_frames()).is_equal(3)
	var boss_metadata: Dictionary = boss.call("get_last_enemy_attack_metadata")
	assert_int(int(boss_metadata.get("damage_applied", 0))).is_equal(16)
	assert_bool(bool(boss_metadata.get("damage_was_applied", false))).is_true()
	var arena_diagnostics: Dictionary = arena.call("get_boss3_combat_diagnostics")
	assert_int(int(Dictionary(arena_diagnostics.get(
		"last_boss_attack_metadata",
		{}
	)).get("damage", 0))).is_equal(16)


func test_real_pressure_geyser_uses_the_authored_fourteen_damage_path() -> void:
	assert_that(presentation).is_not_null()
	if presentation == null:
		return
	var player_hp_before: int = player.get_current_hp()
	assert_bool(bool(boss.call(
		"request_attack_pattern",
		PRESSURE_GEYSER_PATTERN_ID
	))).is_true()
	boss.call("advance_attack_frames", 24)
	assert_bool(boss_collision.is_hitbox_active(PRESSURE_GEYSER_HITBOX_ID)).is_true()
	boss_collision.process_detection_frame({
		PRESSURE_GEYSER_HITBOX_ID: [collision.get_hurtbox()],
	})

	var applied_damage: int = player_hp_before - player.get_current_hp()
	assert_int(applied_damage).is_equal(14)
	if applied_damage != 14:
		return
	assert_bool(get_tree().paused).is_true()
	assert_bool(presentation.is_gameplay_hitstop_active()).is_true()
	var damage_snapshot: Dictionary = presentation.get_last_damage_number_snapshot()
	assert_str(String(damage_snapshot.get("text", ""))).is_equal("14")
	var boss_metadata: Dictionary = boss.call("get_last_enemy_attack_metadata")
	assert_int(int(boss_metadata.get("damage_applied", 0))).is_equal(14)
	var arena_diagnostics: Dictionary = arena.call("get_boss3_combat_diagnostics")
	assert_int(int(Dictionary(arena_diagnostics.get(
		"last_boss_attack_metadata",
		{}
	)).get("damage", 0))).is_equal(14)

	if not get_tree().paused:
		return
	while presentation.is_gameplay_hitstop_active():
		await get_tree().process_frame
	assert_bool(get_tree().paused).is_false()


func test_dodged_pressure_lunge_does_not_emit_damage_feedback_or_hitstop() -> void:
	assert_that(presentation).is_not_null()
	if presentation == null:
		return
	var player_hp_before: int = player.get_current_hp()
	assert_bool(player.request_dodge()).is_true()
	combat.advance_dodge_frames(3)
	assert_bool(combat.is_dodge_iframe_active()).is_true()
	assert_bool(bool(boss.call("request_attack"))).is_true()
	boss.call("advance_attack_frames", int(boss.call(
		"get_current_attack_startup_frames"
	)))
	assert_bool(boss_collision.is_hitbox_active(PRESSURE_LUNGE_HITBOX_ID)).is_true()
	boss_collision.process_detection_frame({
		PRESSURE_LUNGE_HITBOX_ID: [collision.get_hurtbox()],
	})

	assert_int(player.get_current_hp()).is_equal(player_hp_before)
	assert_bool(get_tree().paused).is_false()
	assert_bool(presentation.is_gameplay_hitstop_active()).is_false()
	assert_int(presentation.get_active_damage_number_count()).is_equal(0)
	var arena_diagnostics: Dictionary = arena.call("get_boss3_combat_diagnostics")
	assert_dict(Dictionary(arena_diagnostics.get(
		"last_boss_attack_metadata",
		{}
	))).is_empty()


func test_perfect_parry_keeps_special_feedback_without_false_damage_hit() -> void:
	assert_that(presentation).is_not_null()
	if presentation == null:
		return
	var player_hp_before: int = player.get_current_hp()
	assert_bool(bool(boss.call("request_attack"))).is_true()
	boss.call("advance_attack_frames", int(boss.call(
		"get_current_attack_startup_frames"
	)))
	assert_bool(boss_collision.is_hitbox_active(PRESSURE_LUNGE_HITBOX_ID)).is_true()
	assert_bool(player.request_parry()).is_true()
	boss_collision.process_detection_frame({
		PRESSURE_LUNGE_HITBOX_ID: [collision.get_hurtbox()],
	})

	assert_int(player.get_current_hp()).is_equal(player_hp_before)
	assert_int(presentation.get_active_damage_number_count()).is_equal(0)
	assert_bool(presentation.is_gameplay_hitstop_active()).override_failure_message(
		"PERFECT parry must keep its dedicated presentation feedback"
	).is_true()
	assert_int(presentation.get_hitstop_frames_remaining()).is_equal(8)
	assert_int(presentation.get_active_perfect_parry_afterimage_count()).is_equal(1)
	var arena_diagnostics: Dictionary = arena.call("get_boss3_combat_diagnostics")
	assert_dict(Dictionary(arena_diagnostics.get(
		"last_boss_attack_metadata",
		{}
	))).is_empty()


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
			var audio_player := child as AudioStreamPlayer
			audio_player.stop()
			audio_player.stream = null
		if child is AudioStreamPlayer2D:
			var spatial_player := child as AudioStreamPlayer2D
			spatial_player.stop()
			spatial_player.stream = null
