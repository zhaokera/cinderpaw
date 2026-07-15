## Story 002: Light combo chain frame data, timeout, and cancel windows.
extends GdUnitTestSuite

const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")

var combat
var _extra_combat: Array = []


func before_test() -> void:
	combat = COMBAT_COMPONENT_SCRIPT.new()
	add_child(combat)


func after_test() -> void:
	if is_instance_valid(combat):
		if combat.get_parent() != null:
			combat.get_parent().remove_child(combat)
		combat.free()
	for node: Variant in _extra_combat:
		if is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()
	combat = null
	_extra_combat.clear()


func test_light_attack_stage_frame_data_matches_gdd() -> void:
	assert_dict(combat.get_light_attack_frame_data(0)).is_equal({
		"startup_frames": 4,
		"active_frames": 4,
		"post_active_recovery_frames": 4,
		"recovery_frames": 8,
		"total_frames": 12,
	})
	assert_dict(combat.get_light_attack_frame_data(1)).is_equal({
		"startup_frames": 6,
		"active_frames": 6,
		"post_active_recovery_frames": 6,
		"recovery_frames": 12,
		"total_frames": 18,
	})
	assert_dict(combat.get_light_attack_frame_data(2)).is_equal({
		"startup_frames": 10,
		"active_frames": 10,
		"post_active_recovery_frames": 10,
		"recovery_frames": 20,
		"total_frames": 30,
	})
	assert_dict(combat.get_light_attack_frame_data(99)).is_equal(
		combat.get_light_attack_frame_data(2)
	)


func test_attack_in_recovery_advances_combo_before_timeout() -> void:
	combat.on_action_triggered(&"attack", {})
	combat.advance_attack_frames(4)

	assert_bool(combat.is_in_attack_recovery()).is_true()

	combat.on_action_triggered(&"attack", {})

	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.ATTACKING)
	assert_int(combat.get_combo_index()).is_equal(1)
	assert_int(combat.get_attack_frame()).is_equal(0)


func test_combo_timeout_resets_next_attack_to_stage_zero() -> void:
	combat.on_action_triggered(&"attack", {})
	combat.advance_attack_frames(4)
	combat.advance_combo_time(0.301)

	combat.on_action_triggered(&"attack", {})

	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.ATTACKING)
	assert_int(combat.get_combo_index()).is_equal(0)


func test_dodge_cancels_light_attack_recovery_for_all_stages() -> void:
	for stage: int in [0, 1, 2]:
		var stage_combat = _fresh_combat_at_recovery(stage)

		stage_combat.on_action_triggered(&"dodge", {})

		assert_int(stage_combat.get_current_state()).is_equal(
			COMBAT_COMPONENT_SCRIPT.CombatState.DODGING
		)


func test_stage_two_attack_does_not_create_fourth_combo_stage() -> void:
	var stage_combat = _fresh_combat_at_recovery(2)

	stage_combat.on_action_triggered(&"attack", {})

	assert_int(stage_combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.ATTACKING)
	assert_int(stage_combat.get_combo_index()).is_equal(2)


func _fresh_combat_at_recovery(stage: int):
	var fresh = COMBAT_COMPONENT_SCRIPT.new()
	add_child(fresh)
	_extra_combat.append(fresh)
	fresh.start_light_attack_stage(stage)
	fresh.advance_attack_frames(int(fresh.get_light_attack_frame_data(stage)["startup_frames"]))
	return fresh
