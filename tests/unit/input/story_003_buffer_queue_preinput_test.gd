## Story 003: InputManager buffer queue and pre-input priority.
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


func test_buffered_trigger_consumes_on_unlock_within_window() -> void:
	input_manager.notify_animation_lock(200, 900)

	assert_bool(input_manager.accept_action(&"dodge", 1000, &"kbm")).is_true()
	assert_int(_triggered_actions.size()).is_equal(0)

	input_manager.notify_animation_unlock(1149)

	assert_array(_triggered_actions).contains(&"dodge")
	assert_int(_triggered_metadata[0].get("buffer_delay_ms", -1)).is_equal(149)


func test_buffered_trigger_expires_after_window() -> void:
	input_manager.notify_animation_lock(300, 900)
	input_manager.accept_action(&"dodge", 1000, &"kbm")

	input_manager.notify_animation_unlock(1151)

	assert_int(_triggered_actions.size()).is_equal(0)
	assert_int(input_manager.get_buffered_action_count()).is_equal(0)


func test_buffer_queue_drops_oldest_entry_when_capacity_is_exceeded() -> void:
	input_manager.notify_animation_lock(300, 900)

	input_manager.accept_action(&"attack", 1000, &"kbm")
	input_manager.accept_action(&"heavy_attack", 1010, &"kbm")
	input_manager.accept_action(&"dash", 1020, &"kbm")
	input_manager.accept_action(&"dodge", 1030, &"kbm")

	var buffered_actions: Array[StringName] = _buffered_action_ids()

	assert_int(input_manager.get_buffered_action_count()).is_equal(3)
	assert_bool(buffered_actions.has(&"attack")).is_false()
	assert_array(buffered_actions).contains(&"heavy_attack")
	assert_array(buffered_actions).contains(&"dash")
	assert_array(buffered_actions).contains(&"dodge")


func test_duplicate_buffered_action_keeps_latest_timestamp() -> void:
	input_manager.notify_animation_lock(300, 900)

	input_manager.accept_action(&"attack", 1000, &"kbm")
	input_manager.accept_action(&"attack", 1040, &"kbm")
	input_manager.notify_animation_unlock(1150)

	assert_int(input_manager.get_buffered_action_count()).is_equal(0)
	assert_array(_triggered_actions).contains(&"attack")
	assert_int(_triggered_metadata[0].get("buffer_delay_ms", -1)).is_equal(110)


func test_pre_input_gets_bonus_and_wins_over_nearby_base_priority() -> void:
	input_manager.notify_animation_lock(300, 900)

	input_manager.accept_action(&"heavy_attack", 1100, &"kbm")
	input_manager.accept_action(&"attack", 1160, &"kbm")
	input_manager.notify_animation_unlock(1200)

	assert_int(_triggered_actions.size()).is_equal(1)
	assert_str(String(_triggered_actions[0])).is_equal("attack")
	assert_bool(_triggered_metadata[0].get("is_pre_input", false)).is_true()
	assert_int(_triggered_metadata[0].get("priority", 0)).is_equal(80)


func test_clear_buffer_prevents_old_entries_from_consuming() -> void:
	input_manager.notify_animation_lock(300, 900)
	input_manager.accept_action(&"dodge", 1000, &"kbm")
	input_manager.accept_action(&"attack", 1010, &"kbm")

	input_manager.clear_buffer()
	input_manager.notify_animation_unlock(1100)

	assert_int(_triggered_actions.size()).is_equal(0)
	assert_int(input_manager.get_buffered_action_count()).is_equal(0)


func _buffered_action_ids() -> Array[StringName]:
	var action_ids: Array[StringName] = []
	for entry: Dictionary in input_manager.get_buffered_actions():
		action_ids.append(entry.get("action", &""))
	return action_ids


func _on_action_triggered(action_id: StringName, metadata: Dictionary) -> void:
	_triggered_actions.append(action_id)
	_triggered_metadata.append(metadata.duplicate(true))
