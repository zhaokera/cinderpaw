## Combat Presentation Story 036: Rat King naturally gates Phase-I with its intro.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const RAT_KING_DEFEATED_FLAG: StringName = &"boss_rat_king_defeated"

var _spawned_scenes: Array[Node] = []


func after_test() -> void:
	for scene: Node in _spawned_scenes:
		if not is_instance_valid(scene):
			continue
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	_spawned_scenes.clear()
	_stop_runtime_audio()


func test_real_main_starts_intro_once_then_hands_off_and_rearms_on_retry() -> void:
	var scene: Node2D = _instantiate_main_scene()
	assert_bool(scene.has_method("get_rat_king_phase_one_intro_diagnostics")).is_true()
	if not scene.has_method("get_rat_king_phase_one_intro_diagnostics"):
		return

	await _await_completed_physics_tick()
	var boss: Node = scene.get_node("Enemy")
	var player: Node = scene.get_node("Player")
	var collision: Node = boss.call("get_collision_component")
	var intro: Dictionary = scene.call("get_rat_king_phase_one_intro_diagnostics")
	assert_bool(bool(intro.get("active", false))).is_true()
	assert_str(String(intro.get("animation", ""))).is_equal("phase_1_intro")
	assert_int(int(intro.get("frame_count", 0))).is_equal(3)
	assert_bool(bool(intro.get("loop", true))).is_false()
	assert_float(float(intro.get("duration_sec", 0.0))).is_equal_approx(0.75, 0.001)
	assert_int(int(intro.get("started_count", 0))).is_equal(1)
	assert_bool(bool(intro.get("player_control_locked", true))).is_false()
	assert_bool(bool(boss.call("request_attack_pattern", &"claw_swipe"))).is_false()
	assert_int(int(collision.call("get_active_hitbox_count"))).is_equal(0)

	var hp_before: int = int(boss.call("get_current_hp"))
	boss.call("apply_damage", 25, {"source": &"story036_intro_probe"})
	assert_int(int(boss.call("get_current_hp"))).is_equal(hp_before)
	assert_bool(bool(player.call("request_attack"))).is_true()

	var arena_snapshot: Dictionary = scene.call("capture_boss_arena_snapshot")
	boss.call("advance_boss_runtime", float(intro.get("remaining_sec", 0.75)) + 0.01)
	var handed_off: Dictionary = scene.call("get_rat_king_phase_one_intro_diagnostics")
	assert_bool(bool(handed_off.get("active", true))).is_false()
	assert_str(String(handed_off.get("animation", ""))).is_equal("idle")
	assert_int(int(handed_off.get("completed_count", 0))).is_equal(1)
	assert_bool(bool(boss.call("request_attack_pattern", &"claw_swipe"))).is_true()
	assert_bool(bool(scene.call("request_rat_king_phase_one_intro"))).is_false()

	scene.call("reset_boss_arena_to_snapshot", arena_snapshot)
	await _await_completed_physics_tick()
	var replayed: Dictionary = scene.call("get_rat_king_phase_one_intro_diagnostics")
	assert_bool(bool(replayed.get("active", false))).is_true()
	assert_int(int(replayed.get("started_count", 0))).is_equal(2)

	var defeated_scene: Node2D = _instantiate_main_scene()
	defeated_scene.call("set_world_progress_flag", RAT_KING_DEFEATED_FLAG, true)
	await _await_completed_physics_tick()
	var skipped: Dictionary = defeated_scene.call(
		"get_rat_king_phase_one_intro_diagnostics"
	)
	assert_bool(bool(skipped.get("active", true))).is_false()
	assert_int(int(skipped.get("started_count", -1))).is_equal(0)
	assert_bool(defeated_scene.get_node("Enemy").visible).is_false()


func _instantiate_main_scene() -> Node2D:
	var scene := MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	_spawned_scenes.append(scene)
	return scene


func _await_completed_physics_tick() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame


func _stop_runtime_audio() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	if audio_system.has_method("stop_all_runtime_audio"):
		audio_system.call("stop_all_runtime_audio")
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
		elif child is AudioStreamPlayer2D:
			(child as AudioStreamPlayer2D).stop()
