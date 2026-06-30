## Story 032: Boss2 Phase II reuses boss music mix routing and phase SFX.
extends GdUnitTestSuite

const AUDIO_SYSTEM_PATH: String = "res://src/presentation/audio_system.gd"
const BOSS2_ID: StringName = &"boss_02_echo_guardian"
const BOSS2_ENTITY_ID: int = 2200

var audio_system = null


func before_test() -> void:
	var audio_system_script: Script = load(AUDIO_SYSTEM_PATH)
	if audio_system_script != null:
		audio_system = audio_system_script.new()
		add_child(audio_system)


func after_test() -> void:
	if is_instance_valid(audio_system):
		if audio_system.get_parent() != null:
			audio_system.get_parent().remove_child(audio_system)
		audio_system.free()
	audio_system = null


func test_boss2_phase_music_cues_are_registered_and_transition_with_phase_sfx() -> void:
	assert_object(audio_system).is_not_null()
	if audio_system == null:
		return

	assert_str(String(audio_system.call("get_boss_music_cue", BOSS2_ID, 1))).is_equal("mus_boss_rat_p1")
	assert_str(String(audio_system.call("get_boss_music_cue", BOSS2_ID, 2))).is_equal("mus_boss_rat_p2")

	assert_bool(bool(audio_system.call("on_boss_encounter_started", BOSS2_ID, {
		"display_name": "Echo Guardian",
		"phase": 1,
		"world_position": Vector2(680, 320),
	}))).is_true()
	var started_state: Dictionary = Dictionary(audio_system.call("get_boss_music_state"))
	assert_bool(bool(started_state.get("active", false))).is_true()
	assert_str(String(started_state.get("boss_id", &""))).is_equal("boss_02_echo_guardian")
	assert_int(int(started_state.get("phase", 0))).is_equal(1)
	assert_str(String(started_state.get("music_id", &""))).is_equal("mus_boss_rat_p1")
	assert_str(String(audio_system.call("get_audio_state"))).is_equal("BOSS_FIGHT")

	assert_bool(bool(audio_system.call("on_boss_phase_transition_started", BOSS2_ENTITY_ID, 2, {
		"boss_id": BOSS2_ID,
		"display_name": "Echo Guardian",
		"previous_phase": 1,
		"hp_percentage": 0.5,
		"world_position": Vector2(704, 264),
	}))).is_true()
	var phase_two_state: Dictionary = Dictionary(audio_system.call("get_boss_music_state"))
	assert_bool(bool(phase_two_state.get("active", false))).is_true()
	assert_str(String(phase_two_state.get("boss_id", &""))).is_equal("boss_02_echo_guardian")
	assert_int(int(phase_two_state.get("phase", 0))).is_equal(2)
	assert_str(String(phase_two_state.get("music_id", &""))).is_equal("mus_boss_rat_p2")
	assert_str(String(audio_system.get_current_music_id())).is_equal("mus_boss_rat_p2")
	assert_float(float(audio_system.get_music_fade_in_sec())).is_equal(2.0)
	var phase_event: Dictionary = Dictionary(phase_two_state.get("last_event", {}))
	assert_str(String(phase_event.get("transition_kind", &""))).is_equal("phase_transition")
	assert_float(float(phase_event.get("transition_sec", 0.0))).is_equal(2.0)
	assert_bool(bool(phase_event.get("stream_found", false))).is_true()

	var sfx_request: Dictionary = audio_system.get_last_sfx_request()
	assert_str(String(sfx_request.get("sfx_id", &""))).is_equal("sfx_boss_phase")
	assert_bool(bool(sfx_request.get("stream_found", false))).is_true()
	assert_vector(sfx_request.get("position", Vector2.ZERO)).is_equal(Vector2(704, 264))
