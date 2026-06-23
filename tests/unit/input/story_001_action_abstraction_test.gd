## Story 001: InputManager action abstraction, query API, and tuning registration.
extends GdUnitTestSuite

const INPUT_MANAGER_SCRIPT: Script = preload("res://src/foundation/input_manager.gd")
const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")

const PROJECT_PATH: String = "res://project.godot"

var input_manager
var data_manager


func before_test() -> void:
	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)
	input_manager = INPUT_MANAGER_SCRIPT.new()
	add_child(input_manager)


func after_test() -> void:
	if is_instance_valid(input_manager):
		if input_manager.get_parent() != null:
			input_manager.get_parent().remove_child(input_manager)
		input_manager.free()
	if is_instance_valid(data_manager):
		if data_manager.get_parent() != null:
			data_manager.get_parent().remove_child(data_manager)
		data_manager.free()
	input_manager = null
	data_manager = null


func test_project_registers_input_manager_after_data_manager() -> void:
	assert_bool(FileAccess.file_exists(PROJECT_PATH)).is_true()
	var project_text: String = FileAccess.get_file_as_string(PROJECT_PATH)
	var data_manager_index: int = project_text.find("DataManager=\"*res://src/foundation/data_manager.gd\"")
	var input_manager_index: int = project_text.find("InputManager=\"*res://src/foundation/input_manager.gd\"")

	assert_int(data_manager_index).is_greater_equal(0)
	assert_int(input_manager_index).is_greater_equal(0)
	assert_bool(data_manager_index < input_manager_index).is_true()


func test_supported_actions_and_metadata_match_gdd_core_actions() -> void:
	var actions: Array[StringName] = input_manager.get_supported_actions()

	assert_array(actions).contains(&"move_left")
	assert_array(actions).contains(&"move_right")
	assert_array(actions).contains(&"move_up")
	assert_array(actions).contains(&"move_down")
	assert_array(actions).contains(&"jump")
	assert_array(actions).contains(&"dash")
	assert_array(actions).contains(&"attack")
	assert_array(actions).contains(&"heavy_attack")
	assert_array(actions).contains(&"dodge")
	assert_array(actions).contains(&"parry")
	assert_array(actions).contains(&"interact")
	assert_array(actions).contains(&"pause")
	assert_int(actions.size()).is_equal(12)

	var attack_meta: Dictionary = input_manager.get_action_metadata(&"attack")
	var move_meta: Dictionary = input_manager.get_action_metadata(&"move_left")
	var unknown_meta: Dictionary = input_manager.get_action_metadata(&"missing")

	assert_str(String(attack_meta.get("type", &""))).is_equal("trigger")
	assert_bool(attack_meta.get("bufferable", false)).is_true()
	assert_str(String(move_meta.get("type", &""))).is_equal("continuous")
	assert_bool(move_meta.get("bufferable", true)).is_false()
	assert_bool(unknown_meta.is_empty()).is_true()


func test_query_api_returns_safe_defaults_for_unknown_actions() -> void:
	assert_bool(input_manager.is_action_pressed(&"missing")).is_false()
	assert_bool(input_manager.is_action_just_pressed(&"missing")).is_false()
	assert_float(input_manager.get_action_strength(&"missing")).is_equal(0.0)
	assert_float(input_manager.get_action_duration(&"missing")).is_equal(0.0)


func test_input_tuning_knobs_register_with_data_manager() -> void:
	assert_bool(input_manager.register_input_tuning_knobs(data_manager)).is_true()

	assert_int(data_manager.get_tuning(&"input.buffer_window_ms", 0)).is_equal(150)
	assert_int(data_manager.get_tuning(&"input.buffer_queue_size", 0)).is_equal(3)
	assert_int(data_manager.get_tuning(&"input.pre_input_window_ms", 0)).is_equal(50)
	assert_int(data_manager.get_tuning(&"input.combo_chain_window_ms", 0)).is_equal(300)
	assert_int(data_manager.get_tuning(&"input.coyote_frames", 0)).is_equal(6)
	assert_int(data_manager.get_tuning(&"input.jump_buffer_frames", 0)).is_equal(6)
	assert_int(data_manager.get_tuning(&"input.device_switch_debounce_ms", 0)).is_equal(500)
	assert_int(data_manager.get_tuning(&"input.priority_pre_input_bonus", 0)).is_equal(20)


func test_input_tuning_registration_without_data_manager_uses_safe_defaults() -> void:
	assert_bool(input_manager.register_input_tuning_knobs()).is_false()
	assert_int(input_manager.get_input_tuning(&"input.buffer_window_ms", 0)).is_equal(150)
	assert_int(input_manager.get_input_tuning(&"input.buffer_queue_size", 0)).is_equal(3)
