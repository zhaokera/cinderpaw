## Story 032: Boss2 enters a readable Phase II pressure mix at half HP.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const BOSS2_ENTITY_ID: int = 2200
const PHASE_TWO_TRIGGER_DAMAGE: int = 18
const BOSS2_HITBOX_ID: StringName = &"boss2_echo_swipe"
const RAT_KING_DEFEATED_FLAG: StringName = &"boss_rat_king_defeated"

var scene: Node2D


class FakeAudioSystem:
	extends RefCounted

	var boss_phase_events: Array[Dictionary] = []

	func on_scene_load_started(
		_scene_id: StringName,
		_spawn_point: StringName,
		_metadata: Dictionary
	) -> void:
		pass

	func on_boss_phase_transition_started(entity_id: int, phase: int, metadata: Dictionary) -> bool:
		boss_phase_events.append({
			"entity_id": entity_id,
			"phase": phase,
			"metadata": metadata.duplicate(true),
		})
		return true


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	scene.call("set_world_progress_flag", RAT_KING_DEFEATED_FLAG, true)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_boss2_half_hp_enters_phase_two_and_updates_hud() -> void:
	var boss: Node = scene.get_node("Boss2EchoGuardian")
	var hud: Node = scene.get_node("HUD")
	assert_bool(boss.has_method("get_current_phase")).is_true()
	assert_bool(hud.has_method("get_boss_phase_marker_text")).is_true()
	if not boss.has_method("get_current_phase") or not hud.has_method("get_boss_phase_marker_text"):
		return

	assert_int(int(boss.call("get_current_phase"))).is_equal(1)
	assert_str(String(hud.call("get_boss_phase_marker_text"))).is_equal("I")
	assert_bool(scene.call("apply_damage", BOSS2_ENTITY_ID, PHASE_TWO_TRIGGER_DAMAGE, {
		"source": &"unit_test_boss2_phase_two",
	})).is_true()

	assert_int(int(boss.call("get_current_phase"))).is_equal(2)
	assert_str(String(hud.call("get_boss_label_text"))).contains("Echo Guardian")
	assert_str(String(hud.call("get_boss_label_text"))).contains("18/36")
	assert_str(String(hud.call("get_boss_phase_marker_text"))).is_equal("II")


func test_boss2_phase_two_raises_pressure_and_routes_phase_feedback() -> void:
	var boss: Node = scene.get_node("Boss2EchoGuardian")
	var presentation: Node = scene.get_node("CombatPresentation")
	var fake_audio := FakeAudioSystem.new()
	scene.call("configure_audio_system_runtime", fake_audio)
	assert_bool(boss.has_method("get_auto_pressure_diagnostics")).is_true()
	assert_bool(presentation.has_method("get_last_boss_phase")).is_true()
	assert_bool(presentation.has_method("get_active_boss_phase_debris_count")).is_true()
	if (
		not boss.has_method("get_auto_pressure_diagnostics")
		or not presentation.has_method("get_last_boss_phase")
		or not presentation.has_method("get_active_boss_phase_debris_count")
	):
		return

	var phase_one_pressure: Dictionary = boss.call("get_auto_pressure_diagnostics")
	assert_bool(scene.call("apply_damage", BOSS2_ENTITY_ID, PHASE_TWO_TRIGGER_DAMAGE, {
		"source": &"unit_test_boss2_phase_two_feedback",
	})).is_true()
	var phase_two_pressure: Dictionary = boss.call("get_auto_pressure_diagnostics")

	assert_int(int(phase_two_pressure.get("current_phase", 0))).is_equal(2)
	assert_float(float(phase_two_pressure.get("chase_step_px", 0.0))).is_greater(
		float(phase_one_pressure.get("chase_step_px", 0.0))
	)
	assert_int(int(phase_two_pressure.get("attack_cooldown_target_frames", 999))).is_less(
		int(phase_one_pressure.get("attack_cooldown_target_frames", 0))
	)
	assert_int(int(presentation.call("get_last_boss_phase"))).is_equal(2)
	assert_int(int(presentation.call("get_active_boss_phase_debris_count"))).is_greater_equal(30)
	assert_int(fake_audio.boss_phase_events.size()).is_equal(1)
	if fake_audio.boss_phase_events.is_empty():
		return
	var audio_event: Dictionary = fake_audio.boss_phase_events[0]
	assert_int(int(audio_event.get("entity_id", 0))).is_equal(BOSS2_ENTITY_ID)
	assert_int(int(audio_event.get("phase", 0))).is_equal(2)
	var metadata: Dictionary = Dictionary(audio_event.get("metadata", {}))
	assert_str(String(metadata.get("boss_id", &""))).is_equal("boss_02_echo_guardian")
	assert_str(String(metadata.get("display_name", ""))).is_equal("Echo Guardian")


func test_boss2_phase_two_waits_for_current_attack_chain_to_finish() -> void:
	var boss: Node = scene.get_node("Boss2EchoGuardian")
	var presentation: Node = scene.get_node("CombatPresentation")
	var fake_audio := FakeAudioSystem.new()
	scene.call("configure_audio_system_runtime", fake_audio)
	assert_bool(boss.has_method("request_attack")).is_true()
	assert_bool(boss.has_method("advance_attack_frames")).is_true()
	assert_bool(boss.has_method("get_attack_phase")).is_true()
	assert_bool(boss.has_method("get_collision_component")).is_true()
	if (
		not boss.has_method("request_attack")
		or not boss.has_method("advance_attack_frames")
		or not boss.has_method("get_attack_phase")
		or not boss.has_method("get_collision_component")
	):
		return

	assert_bool(bool(boss.call("request_attack"))).is_true()
	assert_str(String(boss.call("get_attack_phase"))).is_equal("startup")
	assert_bool(scene.call("apply_damage", BOSS2_ENTITY_ID, PHASE_TWO_TRIGGER_DAMAGE, {
		"source": &"unit_test_boss2_phase_two_while_attacking",
	})).is_true()

	assert_int(int(boss.call("get_current_phase"))).is_equal(1)
	assert_str(String(scene.get_node("HUD").call("get_boss_phase_marker_text"))).is_equal("I")
	assert_int(int(presentation.call("get_last_boss_phase"))).is_equal(0)
	assert_int(fake_audio.boss_phase_events.size()).is_equal(0)

	boss.call("advance_attack_frames", int(boss.call("get_attack_startup_frames")))
	assert_str(String(boss.call("get_attack_phase"))).is_equal("active")
	var collision: CollisionComponent = boss.call("get_collision_component") as CollisionComponent
	assert_bool(collision.is_hitbox_active(BOSS2_HITBOX_ID)).is_true()

	boss.call("advance_attack_frames", 32)
	assert_int(int(boss.call("get_current_phase"))).is_equal(2)
	assert_str(String(scene.get_node("HUD").call("get_boss_phase_marker_text"))).is_equal("II")
	assert_int(int(presentation.call("get_last_boss_phase"))).is_equal(2)
	assert_int(fake_audio.boss_phase_events.size()).is_equal(1)
