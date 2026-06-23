## Story 006: InputManager device detection and debounced switching.
extends GdUnitTestSuite

const INPUT_MANAGER_SCRIPT: Script = preload("res://src/foundation/input_manager.gd")
const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")

var input_manager
var data_manager
var _device_changes: Array[Dictionary] = []


func before_test() -> void:
	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)
	input_manager = INPUT_MANAGER_SCRIPT.new()
	add_child(input_manager)
	_device_changes.clear()
	input_manager.device_changed.connect(_on_device_changed)


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
	_device_changes.clear()


func test_classifies_input_sources() -> void:
	assert_str(String(input_manager.classify_input_event(InputEventJoypadButton.new()))).is_equal("gamepad")
	assert_str(String(input_manager.classify_input_event(InputEventJoypadMotion.new()))).is_equal("gamepad")
	assert_str(String(input_manager.classify_input_event(InputEventKey.new()))).is_equal("kbm")
	assert_str(String(input_manager.classify_input_event(InputEventMouseButton.new()))).is_equal("kbm")
	assert_str(String(input_manager.classify_input_event(InputEventScreenTouch.new()))).is_equal("touch")


func test_valid_gamepad_switch_emits_device_changed_once() -> void:
	assert_str(String(input_manager.get_current_device())).is_equal("kbm")

	assert_bool(input_manager.ingest_input_event(InputEventJoypadButton.new(), 1000)).is_true()

	assert_str(String(input_manager.get_current_device())).is_equal("gamepad")
	assert_int(_device_changes.size()).is_equal(1)
	assert_str(String(_device_changes[0].get("old", &""))).is_equal("kbm")
	assert_str(String(_device_changes[0].get("new", &""))).is_equal("gamepad")


func test_debounce_suppresses_lower_priority_switch_until_window_expires() -> void:
	input_manager.ingest_input_event(InputEventJoypadButton.new(), 1000)

	assert_bool(input_manager.ingest_input_event(InputEventMouseButton.new(), 1200)).is_false()
	assert_str(String(input_manager.get_current_device())).is_equal("gamepad")
	assert_int(_device_changes.size()).is_equal(1)

	assert_bool(input_manager.ingest_input_event(InputEventMouseButton.new(), 1501)).is_true()
	assert_str(String(input_manager.get_current_device())).is_equal("kbm")
	assert_int(_device_changes.size()).is_equal(2)


func test_higher_priority_device_can_win_inside_debounce_window() -> void:
	input_manager.ingest_input_event(InputEventScreenTouch.new(), 1000)

	assert_bool(input_manager.ingest_input_event(InputEventKey.new(), 1200)).is_true()
	assert_str(String(input_manager.get_current_device())).is_equal("kbm")

	assert_bool(input_manager.ingest_input_event(InputEventJoypadButton.new(), 1300)).is_true()
	assert_str(String(input_manager.get_current_device())).is_equal("gamepad")


func test_same_device_events_do_not_emit_duplicate_changes() -> void:
	input_manager.ingest_input_event(InputEventJoypadButton.new(), 1000)

	assert_bool(input_manager.ingest_input_event(InputEventJoypadMotion.new(), 1600)).is_false()

	assert_str(String(input_manager.get_current_device())).is_equal("gamepad")
	assert_int(_device_changes.size()).is_equal(1)


func test_tuned_debounce_value_affects_switch_timing() -> void:
	assert_bool(input_manager.register_input_tuning_knobs(data_manager)).is_true()
	assert_bool(data_manager.set_tuning(&"input.device_switch_debounce_ms", 250)).is_true()
	input_manager.ingest_input_event(InputEventJoypadButton.new(), 1000)

	assert_bool(input_manager.ingest_input_event(InputEventMouseButton.new(), 1250)).is_false()
	assert_bool(input_manager.ingest_input_event(InputEventMouseButton.new(), 1251)).is_true()
	assert_str(String(input_manager.get_current_device())).is_equal("kbm")


func test_combat_lock_preserves_current_mapping_and_suppresses_disconnect_switch() -> void:
	input_manager.ingest_input_event(InputEventJoypadButton.new(), 1000)
	input_manager.set_combat_input_lock(true)

	assert_bool(input_manager.ingest_input_event(InputEventKey.new(), 2000)).is_false()
	assert_bool(input_manager.notify_device_disconnected(&"gamepad", 2100)).is_false()

	assert_bool(input_manager.is_combat_input_locked()).is_true()
	assert_str(String(input_manager.get_current_device())).is_equal("gamepad")
	assert_int(_device_changes.size()).is_equal(1)

	input_manager.set_combat_input_lock(false)
	assert_bool(input_manager.ingest_input_event(InputEventKey.new(), 2601)).is_true()
	assert_str(String(input_manager.get_current_device())).is_equal("kbm")
	assert_int(_device_changes.size()).is_equal(2)


func _on_device_changed(old: StringName, new: StringName) -> void:
	_device_changes.append({
		"old": old,
		"new": new,
	})
