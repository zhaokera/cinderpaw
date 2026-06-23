## Story 004: Parry timing windows and counter metadata.
extends GdUnitTestSuite

const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")

var combat


func before_test() -> void:
	combat = COMBAT_COMPONENT_SCRIPT.new()
	add_child(combat)


func after_test() -> void:
	if is_instance_valid(combat):
		if combat.get_parent() != null:
			combat.get_parent().remove_child(combat)
		combat.free()
	combat = null


func test_parry_action_from_idle_enters_parrying() -> void:
	combat.on_action_triggered(&"parry", {})

	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.PARRYING)
	assert_int(combat.get_parry_frame()).is_equal(0)


func test_classify_parry_timing_boundaries() -> void:
	assert_str(String(combat.classify_parry_timing(0))).is_equal("perfect")
	assert_str(String(combat.classify_parry_timing(6))).is_equal("perfect")
	assert_str(String(combat.classify_parry_timing(7))).is_equal("good")
	assert_str(String(combat.classify_parry_timing(12))).is_equal("good")
	assert_str(String(combat.classify_parry_timing(13))).is_equal("late")
	assert_str(String(combat.classify_parry_timing(18))).is_equal("late")
	assert_str(String(combat.classify_parry_timing(19))).is_equal("miss")
	assert_str(String(combat.classify_parry_timing(-1))).is_equal("miss")


func test_parrying_lifecycle_exits_after_frame_eighteen() -> void:
	combat.on_action_triggered(&"parry", {})
	combat.advance_parry_frames(18)

	assert_int(combat.get_parry_frame()).is_equal(18)
	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.PARRYING)

	combat.advance_parry_frames(1)

	assert_int(combat.get_parry_frame()).is_equal(19)
	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.IDLE)


func test_repeated_parry_input_during_parrying_is_ignored() -> void:
	combat.on_action_triggered(&"parry", {})
	combat.advance_parry_frames(5)

	combat.on_action_triggered(&"parry", {})

	assert_int(combat.get_parry_frame()).is_equal(5)
	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.PARRYING)


func test_successful_parry_returns_counter_metadata() -> void:
	combat.on_action_triggered(&"parry", {})
	combat.advance_parry_frames(7)

	var metadata: Dictionary = combat.resolve_parry_result()

	assert_dict(metadata).contains_keys(["is_success", "parry_type", "stun_seconds"])
	assert_bool(metadata["is_success"]).is_true()
	assert_str(String(metadata["parry_type"])).is_equal("good")
	assert_float(float(metadata["stun_seconds"])).is_equal(1.0)
	assert_bool(bool(metadata.get("extra_punishment", true))).is_false()
	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.ATTACKING)
	assert_int(combat.get_combo_index()).is_equal(0)


func test_missed_parry_returns_no_stun_or_extra_punishment() -> void:
	combat.on_action_triggered(&"parry", {})
	combat.advance_parry_frames(19)

	var metadata: Dictionary = combat.resolve_parry_result()

	assert_dict(metadata).contains_keys(["is_success", "parry_type", "extra_punishment"])
	assert_bool(metadata["is_success"]).is_false()
	assert_str(String(metadata["parry_type"])).is_equal("miss")
	assert_bool(metadata.has("stun_seconds")).is_false()
	assert_bool(bool(metadata["extra_punishment"])).is_false()
