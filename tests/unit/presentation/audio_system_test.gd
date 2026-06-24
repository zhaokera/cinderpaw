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
