## Story 004: InputManager combo chain and same-frame conflict resolution.
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


func test_consecutive_attack_inputs_increment_combo_index_to_finisher() -> void:
	input_manager.accept_action(&"attack", 1000, &"kbm")
	input_manager.accept_action(&"attack", 1250, &"kbm")
	input_manager.accept_action(&"attack", 1500, &"kbm")

	assert_int(_triggered_metadata[0].get("combo_index", -1)).is_equal(0)
	assert_int(_triggered_metadata[1].get("combo_index", -1)).is_equal(1)
	assert_int(_triggered_metadata[2].get("combo_index", -1)).is_equal(2)


func test_attack_after_combo_window_resets_combo_index() -> void:
	input_manager.accept_action(&"attack", 1000, &"kbm")
	input_manager.accept_action(&"attack", 1300, &"kbm")
	input_manager.accept_action(&"attack", 1601, &"kbm")

	assert_int(_triggered_metadata[1].get("combo_index", -1)).is_equal(1)
	assert_int(_triggered_metadata[2].get("combo_index", -1)).is_equal(0)


func test_same_frame_dodge_and_attack_resolves_to_dodge_only() -> void:
	assert_int(input_manager.accept_actions([&"attack", &"dodge"], 1000, &"kbm")).is_equal(1)

	assert_int(_triggered_actions.size()).is_equal(1)
	assert_str(String(_triggered_actions[0])).is_equal("dodge")


func test_same_frame_parry_and_dodge_resolves_to_parry_only() -> void:
	assert_int(input_manager.accept_actions([&"dodge", &"parry"], 1000, &"kbm")).is_equal(1)

	assert_int(_triggered_actions.size()).is_equal(1)
	assert_str(String(_triggered_actions[0])).is_equal("parry")


func test_same_frame_dash_and_jump_resolves_to_dash_only() -> void:
	assert_int(input_manager.accept_actions([&"jump", &"dash"], 1000, &"kbm")).is_equal(1)

	assert_int(_triggered_actions.size()).is_equal(1)
	assert_str(String(_triggered_actions[0])).is_equal("dash")


func test_pause_has_highest_priority_and_is_not_buffered_by_combat_actions() -> void:
	input_manager.notify_animation_lock(200, 1000)

	assert_int(input_manager.accept_actions([&"attack", &"pause"], 1050, &"kbm")).is_equal(1)

	assert_int(_triggered_actions.size()).is_equal(1)
	assert_str(String(_triggered_actions[0])).is_equal("pause")
	assert_int(input_manager.get_buffered_action_count()).is_equal(0)


func _on_action_triggered(action_id: StringName, metadata: Dictionary) -> void:
	_triggered_actions.append(action_id)
	_triggered_metadata.append(metadata.duplicate(true))
