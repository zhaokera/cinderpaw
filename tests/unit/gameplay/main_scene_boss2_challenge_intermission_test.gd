## Scene Management Story 019: Rat King victory yields a safe, player-owned handoff.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const INTERACT_ACTION: StringName = &"interact"

var _spawned_scenes: Array[Node] = []


func after_test() -> void:
	Input.action_release(MOVE_RIGHT_ACTION)
	Input.action_release(INTERACT_ACTION)
	for scene: Node in _spawned_scenes:
		if not is_instance_valid(scene):
			continue
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	_spawned_scenes.clear()
	_stop_runtime_audio()


func test_rat_king_continue_waits_for_real_echo_challenge_interaction() -> void:
	var scene: Node2D = _instantiate_main_scene()
	var rat_king: Node = scene.get_node("Enemy")
	var flow: Node = scene.get_node("GameFlowController")
	var hud: Node = scene.get_node("HUD")

	assert_bool(scene.call("apply_damage", int(rat_king.call("get_entity_id")), int(
		rat_king.call("get_current_hp")
	), {"source": &"story019_rat_king_defeat"})).is_true()
	flow.call("advance_time", 3.01)
	assert_str(String(flow.call("get_flow_state"))).is_equal("victory")
	hud.emit_signal("menu_resume_requested")

	var intermission: Dictionary = Dictionary(
		scene.call("get_boss2_encounter_handoff_diagnostics")
	)
	assert_str(String(intermission.get("game_flow_state", ""))).is_equal("playing")
	assert_bool(bool(intermission.get("boss2_intermission_started", false))).is_true()
	assert_bool(bool(intermission.get("boss2_encounter_started", true))).is_false()
	assert_bool(bool(intermission.get("boss2_encounter_active", true))).is_false()
	assert_bool(bool(intermission.get("boss2_visible", true))).is_false()
	assert_bool(bool(intermission.get("boss2_room_seals_enabled", true))).is_false()
	assert_bool(bool(intermission.get("boss2_camera_lock_enabled", true))).is_false()
	assert_bool(bool(intermission.get("challenge_marker_visible", false))).is_true()
	assert_str(String(intermission.get("challenge_texture_path", ""))).is_equal(
		"res://assets/environment/echo_guardian_challenge/"
		+ "echo_guardian_challenge_beacon.png"
	)

	var snapshot: Dictionary = Dictionary(scene.call("capture_save_snapshot"))
	var restored: Node2D = _instantiate_main_scene()
	restored.call("restore_save_snapshot", snapshot)
	var restored_state: Dictionary = Dictionary(
		restored.call("get_boss2_encounter_handoff_diagnostics")
	)
	assert_bool(bool(restored_state.get("boss2_encounter_active", true))).is_false()
	assert_bool(bool(restored_state.get("challenge_marker_visible", false))).is_true()

	assert_bool(await _move_player_into_challenge_range(restored)).is_true()
	Input.action_press(INTERACT_ACTION)
	await get_tree().process_frame
	Input.action_release(INTERACT_ACTION)
	await get_tree().process_frame

	var active: Dictionary = Dictionary(
		restored.call("get_boss2_encounter_handoff_diagnostics")
	)
	assert_bool(bool(active.get("boss2_encounter_started", false))).is_true()
	assert_bool(bool(active.get("boss2_encounter_active", false))).is_true()
	assert_bool(bool(active.get("boss2_visible", false))).is_true()
	assert_bool(bool(active.get("boss2_has_target", false))).is_true()
	assert_int(int(active.get("boss2_collision_layer", 0))).is_greater(0)
	assert_bool(bool(active.get("boss2_arena_frame_visible", false))).is_true()
	assert_bool(bool(active.get("boss2_room_seals_enabled", false))).is_true()
	assert_bool(bool(active.get("boss2_camera_lock_enabled", false))).is_true()
	assert_bool(bool(active.get("challenge_marker_visible", true))).is_false()
	assert_str(String(active.get("boss_hud_label", ""))).contains("Echo Guardian")


func _instantiate_main_scene() -> Node2D:
	var scene := MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	_spawned_scenes.append(scene)
	return scene


func _move_player_into_challenge_range(scene: Node2D) -> bool:
	for _frame: int in range(240):
		var diagnostics: Dictionary = Dictionary(
			scene.call("get_boss2_encounter_handoff_diagnostics")
		)
		if bool(diagnostics.get("challenge_prompt_visible", false)):
			Input.action_release(MOVE_RIGHT_ACTION)
			return true
		Input.action_press(MOVE_RIGHT_ACTION)
		await get_tree().physics_frame
	Input.action_release(MOVE_RIGHT_ACTION)
	return false


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
