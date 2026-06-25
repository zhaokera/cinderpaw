## Story 001: AudioSystem autoload, buses, and silent-safe playback baseline.
extends GdUnitTestSuite

const AUDIO_SYSTEM_PATH: String = "res://src/presentation/audio_system.gd"
const PROJECT_PATH: String = "res://project.godot"

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


func test_project_registers_audio_system_between_input_and_save_system() -> void:
	assert_bool(FileAccess.file_exists(PROJECT_PATH)).is_true()
	var project_text: String = FileAccess.get_file_as_string(PROJECT_PATH)
	var data_manager_index: int = project_text.find("DataManager=\"*res://src/foundation/data_manager.gd\"")
	var input_manager_index: int = project_text.find("InputManager=\"*res://src/foundation/input_manager.gd\"")
	var audio_system_index: int = project_text.find("AudioSystem=\"*res://src/presentation/audio_system.gd\"")
	var save_system_index: int = project_text.find("SaveSystem=\"*res://src/feature/save_system.gd\"")
	var scene_manager_index: int = project_text.find("SceneManager=\"*res://src/feature/scene_manager.gd\"")

	assert_int(data_manager_index).is_greater_equal(0)
	assert_int(input_manager_index).is_greater_equal(0)
	assert_int(audio_system_index).is_greater_equal(0)
	assert_int(save_system_index).is_greater_equal(0)
	assert_int(scene_manager_index).is_greater_equal(0)
	assert_bool(data_manager_index < input_manager_index).is_true()
	assert_bool(input_manager_index < audio_system_index).is_true()
	assert_bool(audio_system_index < save_system_index).is_true()
	assert_bool(save_system_index < scene_manager_index).is_true()


func test_audio_system_initializes_default_buses_and_player_pool() -> void:
	assert_object(audio_system).is_not_null()
	if audio_system == null:
		return

	assert_array(audio_system.get_bus_names()).is_equal([&"Master", &"Music", &"SFX", &"Ambient", &"UI"])
	assert_int(audio_system.get_bus_volume_percent(&"Master")).is_equal(80)
	assert_int(audio_system.get_bus_volume_percent(&"Music")).is_equal(60)
	assert_int(audio_system.get_bus_volume_percent(&"SFX")).is_equal(80)
	assert_int(audio_system.get_bus_volume_percent(&"Ambient")).is_equal(50)
	assert_int(audio_system.get_bus_volume_percent(&"UI")).is_equal(70)
	assert_int(audio_system.get_max_concurrent_sfx()).is_equal(16)
	assert_int(audio_system.get_sfx_pool_size()).is_equal(16)

	for bus_name: StringName in audio_system.get_bus_names():
		var bus_index: int = AudioServer.get_bus_index(bus_name)
		assert_int(bus_index).is_greater_equal(0)
		assert_float(AudioServer.get_bus_volume_linear(bus_index)).is_equal_approx(
			float(audio_system.get_bus_volume_percent(bus_name)) / 100.0,
			0.001
		)
		if bus_name != &"Master":
			assert_bool(AudioServer.get_bus_send(bus_index) == &"Master").is_true()

	var first_sfx_player := audio_system.get_node("SFXPlayer00") as AudioStreamPlayer2D
	assert_object(first_sfx_player).is_not_null()
	assert_str(String(first_sfx_player.bus)).is_equal("SFX")
	assert_float(first_sfx_player.max_distance).is_equal(600.0)


func test_set_bus_volume_clamps_values_and_rejects_unknown_bus() -> void:
	assert_object(audio_system).is_not_null()
	if audio_system == null:
		return

	assert_bool(audio_system.set_bus_volume(&"Music", 50)).is_true()
	assert_int(audio_system.get_bus_volume_percent(&"Music")).is_equal(50)
	assert_float(AudioServer.get_bus_volume_linear(AudioServer.get_bus_index(&"Music"))).is_equal_approx(
		0.5,
		0.001
	)

	assert_bool(audio_system.set_bus_volume(&"Music", -25)).is_true()
	assert_int(audio_system.get_bus_volume_percent(&"Music")).is_equal(0)

	assert_bool(audio_system.set_bus_volume(&"Music", 125)).is_true()
	assert_int(audio_system.get_bus_volume_percent(&"Music")).is_equal(100)

	assert_bool(audio_system.set_bus_volume(&"Missing", 40)).is_false()


func test_play_sfx_records_pitch_spatial_metadata_and_enforces_voice_cap() -> void:
	assert_object(audio_system).is_not_null()
	if audio_system == null:
		return

	var stream := AudioStreamGenerator.new()
	assert_bool(audio_system.register_audio_stream(&"sfx_test_claw", stream)).is_true()

	for index: int in range(17):
		audio_system.play_sfx(&"sfx_test_claw", Vector2(index, -index), -3.0, 4.0, index)

	assert_int(audio_system.get_sfx_pool_size()).is_equal(16)
	assert_int(audio_system.get_active_sfx_count()).is_equal(16)
	assert_int(audio_system.get_dropped_sfx_count()).is_equal(1)

	var last_request: Dictionary = audio_system.get_last_sfx_request()
	assert_str(String(last_request.get("sfx_id", &""))).is_equal("sfx_test_claw")
	assert_vector(last_request.get("position", Vector2.ZERO)).is_equal(Vector2(16, -16))
	assert_float(float(last_request.get("volume_db", 0.0))).is_equal(-3.0)
	assert_float(float(last_request.get("pitch_offset", 0.0))).is_equal(4.0)
	assert_float(float(last_request.get("pitch_scale", 0.0))).is_equal_approx(pow(2.0, 4.0 / 12.0), 0.001)

	var last_player_index: int = int(last_request.get("player_index", -1))
	var last_player := audio_system.get_node("SFXPlayer%02d" % last_player_index) as AudioStreamPlayer2D
	assert_object(last_player).is_not_null()
	assert_vector(last_player.global_position).is_equal(Vector2(16, -16))
	assert_float(last_player.volume_db).is_equal(-3.0)
	assert_float(last_player.pitch_scale).is_equal_approx(pow(2.0, 4.0 / 12.0), 0.001)


func test_missing_sfx_asset_does_not_consume_pool_voice() -> void:
	assert_object(audio_system).is_not_null()
	if audio_system == null:
		return

	assert_bool(audio_system.play_sfx(&"missing_sfx", Vector2(4, 5))).is_false()
	assert_int(audio_system.get_active_sfx_count()).is_equal(0)
	assert_int(audio_system.get_dropped_sfx_count()).is_equal(0)


func test_music_and_ambient_requests_are_safe_without_assets() -> void:
	assert_object(audio_system).is_not_null()
	if audio_system == null:
		return

	assert_bool(audio_system.play_music(&"mus_street", 3.0)).is_false()
	assert_str(String(audio_system.get_current_music_id())).is_equal("mus_street")
	assert_float(audio_system.get_music_fade_in_sec()).is_equal(3.0)

	audio_system.stop_music(2.0)
	assert_str(String(audio_system.get_current_music_id())).is_equal("")
	assert_float(audio_system.get_music_fade_out_sec()).is_equal(2.0)

	assert_bool(audio_system.play_ambient(&"amb_street")).is_false()
	assert_str(String(audio_system.get_current_ambient_id())).is_equal("amb_street")

	audio_system.stop_ambient(2.0)
	assert_str(String(audio_system.get_current_ambient_id())).is_equal("")
	assert_float(audio_system.get_ambient_fade_out_sec()).is_equal(2.0)


func test_scene_load_start_forces_music_and_ambient_to_fade_out_over_two_seconds() -> void:
	assert_object(audio_system).is_not_null()
	if audio_system == null:
		return

	audio_system.play_music(&"mus_street", 3.0)
	audio_system.play_ambient(&"amb_street", 3.0)

	audio_system.on_scene_load_started(&"hub", &"clan_base", {
		"display_name": "Clan Base",
		"transition_duration_sec": 1.5,
	})

	assert_bool(bool(audio_system.is_scene_transition_audio_active())).is_true()
	assert_str(String(audio_system.get_current_music_id())).is_equal("")
	assert_str(String(audio_system.get_current_ambient_id())).is_equal("")
	assert_float(audio_system.get_music_fade_out_sec()).is_equal(2.0)
	assert_float(audio_system.get_ambient_fade_out_sec()).is_equal(2.0)

	var transition_state: Dictionary = Dictionary(audio_system.get_scene_transition_audio_state())
	assert_str(String(transition_state.get("target_scene_id", &""))).is_equal("hub")
	assert_str(String(transition_state.get("spawn_point", &""))).is_equal("clan_base")
	assert_dict(Dictionary(transition_state.get("metadata", {}))).contains_keys("display_name")


func test_scene_change_crossfades_default_area_music_and_ambient_cues() -> void:
	assert_object(audio_system).is_not_null()
	if audio_system == null:
		return

	audio_system.on_scene_load_started(&"main", &"default", {})
	audio_system.on_scene_changed(&"hub", &"main")

	assert_bool(bool(audio_system.is_scene_transition_audio_active())).is_false()
	assert_str(String(audio_system.get_current_music_id())).is_equal("mus_street")
	assert_str(String(audio_system.get_current_ambient_id())).is_equal("amb_street")
	assert_float(audio_system.get_music_fade_in_sec()).is_equal(3.0)
	assert_float(audio_system.get_ambient_fade_in_sec()).is_equal(3.0)


func test_scene_audio_cues_can_be_overridden_and_unknown_scene_stays_silent() -> void:
	assert_object(audio_system).is_not_null()
	if audio_system == null:
		return

	audio_system.configure_scene_audio_cues({
		"factory": {
			"music_id": &"mus_factory",
			"ambient_id": &"amb_factory",
			"crossfade_sec": 4.0,
		},
	})

	audio_system.on_scene_changed(&"main", &"factory")

	assert_str(String(audio_system.get_current_music_id())).is_equal("mus_factory")
	assert_str(String(audio_system.get_current_ambient_id())).is_equal("amb_factory")
	assert_float(audio_system.get_music_fade_in_sec()).is_equal(4.0)
	assert_float(audio_system.get_ambient_fade_in_sec()).is_equal(4.0)

	audio_system.stop_music(0.0)
	audio_system.stop_ambient(0.0)
	audio_system.on_scene_changed(&"factory", &"missing")

	assert_str(String(audio_system.get_current_music_id())).is_equal("")
	assert_str(String(audio_system.get_current_ambient_id())).is_equal("")


func test_scene_load_failed_clears_transition_state_without_starting_new_cues() -> void:
	assert_object(audio_system).is_not_null()
	if audio_system == null:
		return

	audio_system.on_scene_load_started(&"main", &"default", {})
	audio_system.on_scene_load_failed(&"main", &"timeout")

	assert_bool(bool(audio_system.is_scene_transition_audio_active())).is_false()
	assert_str(String(audio_system.get_current_music_id())).is_equal("")
	assert_str(String(audio_system.get_current_ambient_id())).is_equal("")
	var transition_state: Dictionary = Dictionary(audio_system.get_scene_transition_audio_state())
	assert_str(String(transition_state.get("failed_scene_id", &""))).is_equal("main")
	assert_str(String(transition_state.get("failed_reason", &""))).is_equal("timeout")


func test_hit_event_routes_normal_and_crit_sfx_with_priority() -> void:
	assert_object(audio_system).is_not_null()
	if audio_system == null:
		return
	assert_bool(audio_system.has_method("on_hit_event")).is_true()
	if not audio_system.has_method("on_hit_event"):
		return

	assert_bool(bool(audio_system.call("on_hit_event", {
		"hit_position": Vector2(24, 48),
		"is_crit": false,
	}))).is_false()
	var normal_request: Dictionary = audio_system.get_last_sfx_request()
	assert_str(String(normal_request.get("sfx_id", &""))).is_equal("sfx_hit_normal")
	assert_vector(normal_request.get("position", Vector2.ZERO)).is_equal(Vector2(24, 48))
	var normal_priority: int = int(normal_request.get("priority", 0))

	assert_bool(bool(audio_system.call("on_hit_event", {
		"hit_position": Vector2(32, 56),
		"is_crit": true,
	}))).is_false()
	var crit_request: Dictionary = audio_system.get_last_sfx_request()
	assert_str(String(crit_request.get("sfx_id", &""))).is_equal("sfx_hit_crit")
	assert_vector(crit_request.get("position", Vector2.ZERO)).is_equal(Vector2(32, 56))
	assert_bool(int(crit_request.get("priority", 0)) > normal_priority).is_true()


func test_parry_dodge_enemy_death_and_boss_phase_events_route_to_expected_sfx() -> void:
	assert_object(audio_system).is_not_null()
	if audio_system == null:
		return
	for method_name: String in [
		"on_parry_event",
		"on_dodge_event",
		"on_enemy_defeated",
		"on_boss_phase_transition_started",
		"get_audio_state",
	]:
		assert_bool(audio_system.has_method(method_name)).is_true()
		if not audio_system.has_method(method_name):
			return

	assert_bool(bool(audio_system.call("on_parry_event", {
		"parry_type": &"perfect",
		"position": Vector2(10, 12),
	}))).is_false()
	var parry_request: Dictionary = audio_system.get_last_sfx_request()
	assert_str(String(parry_request.get("sfx_id", &""))).is_equal("sfx_parry_perfect")
	assert_vector(parry_request.get("position", Vector2.ZERO)).is_equal(Vector2(10, 12))

	assert_bool(bool(audio_system.call("on_parry_event", {
		"parry_type": &"miss",
		"position": Vector2(99, 99),
	}))).is_false()
	assert_str(String(audio_system.get_last_sfx_request().get("sfx_id", &""))).is_equal("sfx_parry_perfect")

	assert_bool(bool(audio_system.call("on_dodge_event", null, Vector2(40, 50), -1.0))).is_false()
	var dodge_request: Dictionary = audio_system.get_last_sfx_request()
	assert_str(String(dodge_request.get("sfx_id", &""))).is_equal("sfx_dodge")
	assert_vector(dodge_request.get("position", Vector2.ZERO)).is_equal(Vector2(40, 50))

	assert_bool(bool(audio_system.call("on_enemy_defeated", {
		"position": Vector2(80, 90),
	}))).is_false()
	var death_request: Dictionary = audio_system.get_last_sfx_request()
	assert_str(String(death_request.get("sfx_id", &""))).is_equal("sfx_enemy_death")
	assert_vector(death_request.get("position", Vector2.ZERO)).is_equal(Vector2(80, 90))

	assert_bool(bool(audio_system.call("on_boss_phase_transition_started", 2, 3, {
		"world_position": Vector2(120, 140),
	}))).is_false()
	var boss_request: Dictionary = audio_system.get_last_sfx_request()
	assert_str(String(boss_request.get("sfx_id", &""))).is_equal("sfx_boss_phase")
	assert_vector(boss_request.get("position", Vector2.ZERO)).is_equal(Vector2(120, 140))
	assert_str(String(audio_system.call("get_audio_state"))).is_equal("BOSS_FIGHT")


func test_boss_music_state_hard_cuts_phase_transitions_and_ends_cleanly() -> void:
	assert_object(audio_system).is_not_null()
	if audio_system == null:
		return
	for method_name: String in [
		"on_boss_encounter_started",
		"on_boss_phase_transition_started",
		"on_boss_encounter_ended",
		"get_boss_music_state",
	]:
		assert_bool(audio_system.has_method(method_name)).is_true()
		if not audio_system.has_method(method_name):
			return

	assert_bool(bool(audio_system.call("on_boss_encounter_started", &"boss_01_rat_king", {
		"display_name": "垃圾桶鼠王",
		"world_position": Vector2(300, 420),
	}))).is_false()
	var started_state: Dictionary = Dictionary(audio_system.call("get_boss_music_state"))
	assert_bool(bool(started_state.get("active", false))).is_true()
	assert_str(String(started_state.get("boss_id", &""))).is_equal("boss_01_rat_king")
	assert_int(int(started_state.get("phase", 0))).is_equal(1)
	assert_str(String(started_state.get("music_id", &""))).is_equal("mus_boss_rat_p1")
	assert_str(String(audio_system.get_current_music_id())).is_equal("mus_boss_rat_p1")
	assert_float(audio_system.get_music_fade_in_sec()).is_equal(1.0)
	assert_str(String(audio_system.call("get_audio_state"))).is_equal("BOSS_FIGHT")

	assert_bool(bool(audio_system.call("on_boss_phase_transition_started", 2, 2, {
		"boss_id": "boss_01_rat_king",
		"world_position": Vector2(320, 360),
	}))).is_false()
	var phase_two_state: Dictionary = Dictionary(audio_system.call("get_boss_music_state"))
	assert_bool(bool(phase_two_state.get("active", false))).is_true()
	assert_int(int(phase_two_state.get("phase", 0))).is_equal(2)
	assert_str(String(phase_two_state.get("music_id", &""))).is_equal("mus_boss_rat_p2")
	assert_str(String(audio_system.get_current_music_id())).is_equal("mus_boss_rat_p2")
	assert_float(audio_system.get_music_fade_in_sec()).is_equal(2.0)

	assert_bool(bool(audio_system.call("on_boss_phase_transition_started", 2, 3, {
		"boss_id": "boss_01_rat_king",
		"world_position": Vector2(340, 380),
	}))).is_false()
	var phase_three_state: Dictionary = Dictionary(audio_system.call("get_boss_music_state"))
	assert_int(int(phase_three_state.get("phase", 0))).is_equal(3)
	assert_str(String(phase_three_state.get("music_id", &""))).is_equal("mus_boss_rat_p3")
	assert_str(String(audio_system.get_current_music_id())).is_equal("mus_boss_rat_p3")
	assert_float(audio_system.get_music_fade_in_sec()).is_equal(2.0)

	audio_system.call("on_boss_encounter_ended", &"boss_01_rat_king", {
		"reason": &"defeated",
	})
	var ended_state: Dictionary = Dictionary(audio_system.call("get_boss_music_state"))
	assert_bool(bool(ended_state.get("active", true))).is_false()
	assert_str(String(ended_state.get("boss_id", &"missing"))).is_equal("")
	assert_int(int(ended_state.get("phase", -1))).is_equal(0)
	assert_str(String(ended_state.get("music_id", &"missing"))).is_equal("")
	assert_str(String(audio_system.get_current_music_id())).is_equal("")
	assert_float(audio_system.get_music_fade_out_sec()).is_equal(3.0)
	assert_str(String(audio_system.call("get_audio_state"))).is_equal("NORMAL")


func test_focus_mode_switches_damage_taken_to_low_hp_cue() -> void:
	assert_object(audio_system).is_not_null()
	if audio_system == null:
		return
	for method_name: String in [
		"on_damage_taken_event",
		"on_focus_mode_changed",
		"is_focus_mode_audio_active",
		"get_audio_state",
	]:
		assert_bool(audio_system.has_method(method_name)).is_true()
		if not audio_system.has_method(method_name):
			return

	assert_bool(bool(audio_system.call("on_damage_taken_event", {
		"position": Vector2(5, 6),
		"damage": 12,
	}))).is_false()
	assert_str(String(audio_system.get_last_sfx_request().get("sfx_id", &""))).is_equal("sfx_damage_taken")

	assert_bool(bool(audio_system.call("on_focus_mode_changed", 1, true, {
		"hp_percentage": 0.25,
	}))).is_false()
	assert_bool(bool(audio_system.call("is_focus_mode_audio_active"))).is_true()
	assert_str(String(audio_system.call("get_audio_state"))).is_equal("LOW_HP")
	assert_str(String(audio_system.get_last_sfx_request().get("sfx_id", &""))).is_equal("sfx_focus_mode_activate")

	assert_bool(bool(audio_system.call("on_damage_taken_event", {
		"hit_position": Vector2(7, 8),
		"damage": 16,
	}))).is_false()
	var low_hp_request: Dictionary = audio_system.get_last_sfx_request()
	assert_str(String(low_hp_request.get("sfx_id", &""))).is_equal("sfx_damage_taken_lowhp")
	assert_vector(low_hp_request.get("position", Vector2.ZERO)).is_equal(Vector2(7, 8))

	assert_bool(bool(audio_system.call("on_focus_mode_changed", 1, false, {}))).is_true()
	assert_bool(bool(audio_system.call("is_focus_mode_audio_active"))).is_false()
	assert_str(String(audio_system.call("get_audio_state"))).is_equal("NORMAL")
