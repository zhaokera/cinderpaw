## Story 002: InputManager direct dispatch and FSM signal contract.
extends GdUnitTestSuite

const INPUT_MANAGER_SCRIPT: Script = preload("res://src/foundation/input_manager.gd")

var input_manager
var _triggered_actions: Array[StringName] = []
var _triggered_metadata: Array[Dictionary] = []


func before_test() -> void:
	input_manager = INPUT_MANAGER_SCRIPT.new()
	add_child(input_manager)
	_triggered_actions.clear()
	_triggered_metadata.clear()
	input_manager.action_triggered.connect(_on_action_triggered)


func after_test() -> void:
	if is_instance_valid(input_manager):
		if input_manager.get_parent() != null:
			input_manager.get_parent().remove_child(input_manager)
		input_manager.free()
	input_manager = null
	_triggered_actions.clear()
	_triggered_metadata.clear()


func test_direct_mode_dispatches_trigger_action_immediately() -> void:
	assert_str(String(input_manager.get_input_state())).is_equal("direct")

	assert_bool(input_manager.accept_action(&"attack", 1000, &"kbm")).is_true()

	assert_array(_triggered_actions).contains(&"attack")
	assert_int(_triggered_actions.size()).is_equal(1)
	assert_int(_triggered_metadata[0].get("buffer_delay_ms", -1)).is_equal(0)


func test_animation_lock_and_unlock_switch_between_buffering_and_direct() -> void:
	input_manager.notify_animation_lock(200, 1000)

	assert_str(String(input_manager.get_input_state())).is_equal("buffering")

	input_manager.notify_animation_unlock(1200)

	assert_str(String(input_manager.get_input_state())).is_equal("direct")


func test_pause_dispatches_immediately_while_buffering() -> void:
	input_manager.notify_animation_lock(200, 1000)

	assert_bool(input_manager.accept_action(&"pause", 1050, &"kbm")).is_true()

	assert_array(_triggered_actions).contains(&"pause")
	assert_int(_triggered_actions.size()).is_equal(1)
	assert_int(_triggered_metadata[0].get("buffer_delay_ms", -1)).is_equal(0)


func test_action_triggered_metadata_contract_has_required_keys() -> void:
	input_manager.accept_action(&"attack", 1000, &"gamepad")

	var metadata: Dictionary = _triggered_metadata[0]

	assert_dict(metadata).contains_keys([
		"combo_index",
		"is_pre_input",
		"buffer_delay_ms",
		"source_device",
	])
	assert_int(metadata["combo_index"]).is_equal(0)
	assert_bool(metadata["is_pre_input"]).is_false()
	assert_str(String(metadata["source_device"])).is_equal("gamepad")


func test_continuous_and_unknown_actions_do_not_emit_trigger_events() -> void:
	assert_bool(input_manager.accept_action(&"move_left", 1000, &"kbm")).is_false()
	assert_bool(input_manager.accept_action(&"missing", 1000, &"kbm")).is_false()

	assert_int(_triggered_actions.size()).is_equal(0)


func _on_action_triggered(action_id: StringName, metadata: Dictionary) -> void:
	_triggered_actions.append(action_id)
	_triggered_metadata.append(metadata.duplicate(true))
