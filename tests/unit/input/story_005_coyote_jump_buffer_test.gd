## Story 005: InputManager coyote time and jump buffer helpers.
extends GdUnitTestSuite

const INPUT_MANAGER_SCRIPT: Script = preload("res://src/foundation/input_manager.gd")
const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")

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


func test_coyote_jump_uses_default_inclusive_frame_window() -> void:
	assert_bool(input_manager.can_use_coyote_jump(0)).is_true()
	assert_bool(input_manager.can_use_coyote_jump(6)).is_true()
	assert_bool(input_manager.can_use_coyote_jump(7)).is_false()


func test_coyote_jump_rejects_negative_frame_counts() -> void:
	assert_bool(input_manager.can_use_coyote_jump(-1)).is_false()


func test_jump_buffer_uses_default_inclusive_frame_window() -> void:
	assert_bool(input_manager.should_consume_jump_buffer(0)).is_true()
	assert_bool(input_manager.should_consume_jump_buffer(6)).is_true()
	assert_bool(input_manager.should_consume_jump_buffer(7)).is_false()


func test_jump_buffer_rejects_negative_frame_counts() -> void:
	assert_bool(input_manager.should_consume_jump_buffer(-1)).is_false()


func test_tuned_coyote_and_jump_buffer_values_affect_results() -> void:
	assert_bool(input_manager.register_input_tuning_knobs(data_manager)).is_true()
	assert_bool(data_manager.set_tuning(&"input.coyote_frames", 8)).is_true()
	assert_bool(data_manager.set_tuning(&"input.jump_buffer_frames", 8)).is_true()

	assert_bool(input_manager.can_use_coyote_jump(8)).is_true()
	assert_bool(input_manager.can_use_coyote_jump(9)).is_false()
	assert_bool(input_manager.should_consume_jump_buffer(8)).is_true()
	assert_bool(input_manager.should_consume_jump_buffer(9)).is_false()
