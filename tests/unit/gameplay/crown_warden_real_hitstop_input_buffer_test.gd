## Story 022: Crown Warden combat uses the shared real-hitstop input bridge.
extends GdUnitTestSuite

const ARENA_SCENE: PackedScene = preload(
	"res://scenes/bosses/crown_warden_arena.tscn"
)
const LIGHT_HITBOX_ID: StringName = &"cat_claw_light"


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
var boss_combat: CombatComponent
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
	boss = arena.get_node("CrownWardenBoss") as CharacterBody2D
	boss_collision = boss.call("get_collision_component") as CollisionComponent
	boss_combat = boss.call("get_combat_component") as CombatComponent
	presentation = arena.get_node("CombatPresentation") as CombatPresentation
	boss.call("set_autonomous_attacks_enabled", false)


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
	boss_combat = null
	presentation = null
	input_manager = null


func test_player_hit_freezes_arena_and_releases_one_buffered_combo_attack() -> void:
	var bridge: Node = arena.get_node_or_null("HitstopInputBridge")
	assert_that(bridge).override_failure_message(
		"Story022 requires a reusable HitstopInputBridge scene node"
	).is_not_null()
	assert_bool(presentation.gameplay_freeze_enabled).is_true()
	var probe := PhysicsProbe.new()
	probe.name = "CrownHitstopPhysicsProbe"
	probe.process_mode = Node.PROCESS_MODE_PAUSABLE
	arena.add_child(probe)
	await get_tree().physics_frame
	await get_tree().process_frame
	assert_int(probe.physics_ticks).override_failure_message(
		"The pausable probe must run before hitstop"
	).is_greater(0)
	var finish_probe_ticks: Array[int] = []
	presentation.hitstop_finished.connect(func(_consume: bool) -> void:
		finish_probe_ticks.append(probe.physics_ticks)
	, CONNECT_ONE_SHOT)
	var ticks_before_hitstop: int = probe.physics_ticks
	var boss_hp_before: int = int(boss.call("get_current_hp"))

	assert_bool(player.request_attack()).is_true()
	combat.advance_attack_frames(4)
	assert_bool(collision.is_hitbox_active(LIGHT_HITBOX_ID)).is_true()
	collision.process_detection_frame({
		LIGHT_HITBOX_ID: [boss_collision.get_hurtbox()],
	})

	assert_int(int(boss.call("get_current_hp"))).is_equal(boss_hp_before - 12)
	assert_bool(get_tree().paused).override_failure_message(
		"A real Crown Warden hit must pause gameplay immediately"
	).is_true()
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
	assert_bool(bool(player.get_light_combo_diagnostics().get(
		"chain_queued",
		false
	))).is_true()
	assert_bool(input_manager.action_triggered.is_connected(
		combat.on_action_triggered
	)).override_failure_message(
		"The bridge must be the only buffered-action dispatch owner"
	).is_false()
	var ticks_at_finish: int = probe.physics_ticks
	await get_tree().physics_frame
	await get_tree().process_frame
	assert_int(probe.physics_ticks).override_failure_message(
		"Pausable gameplay must resume after hitstop"
	).is_greater(ticks_at_finish)


func test_real_boss_hit_uses_the_same_three_frame_presentation_path() -> void:
	var player_hp_before: int = player.get_current_hp()
	assert_bool(bool(boss.call("request_attack", &"wing_sweep"))).is_true()
	boss.call("advance_attack_frames", int(boss.call(
		"get_current_attack_startup_frames"
	)))
	assert_bool(boss_collision.is_hitbox_active(
		&"crown_warden_wing_sweep"
	)).is_true()
	boss_collision.process_detection_frame({
		&"crown_warden_wing_sweep": [collision.get_hurtbox()],
	})

	assert_int(player.get_current_hp()).is_equal(player_hp_before - 14)
	assert_bool(get_tree().paused).override_failure_message(
		"Crown Warden damage must route through CombatPresentation"
	).is_true()
	assert_bool(presentation.is_gameplay_hitstop_active()).is_true()
	assert_int(presentation.get_hitstop_frames_remaining()).is_equal(3)
	var damage_snapshot: Dictionary = presentation.get_last_damage_number_snapshot()
	assert_str(String(damage_snapshot.get("text", ""))).is_equal("14")
	if not get_tree().paused:
		return

	while presentation.is_gameplay_hitstop_active():
		await get_tree().process_frame

	assert_bool(get_tree().paused).is_false()
	assert_int(presentation.get_last_completed_hitstop_frames()).is_equal(3)
	assert_str(String(input_manager.call("get_input_state"))).is_equal("direct")
	var boss_metadata: Dictionary = boss.call("get_last_enemy_attack_metadata")
	assert_str(String(boss_metadata.get("weapon_id", ""))).is_equal(
		"crown_warden_wing_sweep"
	)
	assert_int(int(boss_metadata.get("damage_applied", 0))).is_equal(14)
	var arena_diagnostics: Dictionary = arena.call("get_boss4_combat_diagnostics")
	assert_int(int(Dictionary(arena_diagnostics.get(
		"last_boss_attack_metadata",
		{}
	)).get("damage", 0))).is_equal(14)


func test_dodged_boss_hit_does_not_emit_damage_feedback_or_hitstop() -> void:
	var player_hp_before: int = player.get_current_hp()
	assert_bool(player.request_dodge()).is_true()
	combat.advance_dodge_frames(3)
	assert_bool(combat.is_dodge_iframe_active()).is_true()
	assert_bool(bool(boss.call("request_attack", &"wing_sweep"))).is_true()
	boss.call("advance_attack_frames", int(boss.call(
		"get_current_attack_startup_frames"
	)))
	boss_collision.process_detection_frame({
		&"crown_warden_wing_sweep": [collision.get_hurtbox()],
	})

	assert_int(player.get_current_hp()).is_equal(player_hp_before)
	assert_bool(get_tree().paused).override_failure_message(
		"Rejected dodge damage must not pause gameplay"
	).is_false()
	assert_bool(presentation.is_gameplay_hitstop_active()).is_false()
	assert_int(presentation.get_active_damage_number_count()).is_equal(0)
	var arena_diagnostics: Dictionary = arena.call("get_boss4_combat_diagnostics")
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
			(child as AudioStreamPlayer).stop()
		elif child is AudioStreamPlayer2D:
			(child as AudioStreamPlayer2D).stop()
