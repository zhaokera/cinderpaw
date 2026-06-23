## Story 003: special moves, skill modifiers, and expanded crit windows.
extends GdUnitTestSuite

const DAMAGE_CALCULATOR_SCRIPT = preload("res://src/foundation/damage_calculator.gd")


func test_cat_claw_special_floors_each_hit_before_summing() -> void:
	var result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_special_damage(
		10,
		5,
		20,
		1.0,
		&"cat_claw",
		-1,
		0,
		{},
		2
	)
	var combined_single_hit: int = DAMAGE_CALCULATOR_SCRIPT.apply_final_damage(11.0 * 0.8 * 5.0, 0.75, 1.0)

	assert_int(result.base_damage).is_equal(11)
	assert_int(result.final_damage).is_equal(30)
	assert_int(combined_single_hit).is_equal(33)
	assert_int(result.combo_stage).is_equal(0)
	assert_bool(result.is_crit).is_false()
	assert_str(String(result.damage_category)).is_equal("strong")


func test_long_tail_special_uses_single_perfect_crit_and_ignores_combo() -> void:
	var result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_special_damage(
		15,
		10,
		0,
		1.0,
		&"long_tail",
		2,
		0,
		{},
		2
	)

	assert_int(result.base_damage).is_equal(17)
	assert_int(result.final_damage).is_equal(63)
	assert_bool(result.is_crit).is_true()
	assert_str(String(result.crit_type)).is_equal("perfect")
	assert_int(result.combo_stage).is_equal(0)


func test_skill_weapon_bonus_replaces_weapon_base_before_dc_f1() -> void:
	var modifiers: Dictionary = {"skill_weapon_bonus": 0.2}
	var result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_normal_damage(
		10,
		0,
		0,
		1.0,
		&"cat_claw",
		0,
		-1,
		0,
		modifiers
	)

	assert_int(DAMAGE_CALCULATOR_SCRIPT.calculate_base_damage_with_modifiers(10, 0, modifiers)).is_equal(12)
	assert_int(DAMAGE_CALCULATOR_SCRIPT.calculate_base_damage_with_modifiers(10, 0, {})).is_equal(10)
	assert_int(result.base_damage).is_equal(12)
	assert_int(result.final_damage).is_equal(12)


func test_charm_and_focus_extend_perfect_crit_window_without_changing_multiplier() -> void:
	var modifiers: Dictionary = {
		"charm_crit_window_bonus_frames": 1,
		"focus_crit_window_bonus_frames": 1
	}

	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_crit_type(4, 0))).is_equal("good")
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_crit_type_with_modifiers(4, 0, modifiers))).is_equal("perfect")
	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_crit_multiplier_with_modifiers(4, 0, modifiers)).is_equal(2.5)
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_crit_type_with_modifiers(5, 0, modifiers))).is_equal("good")
	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_crit_multiplier_with_modifiers(5, 0, modifiers)).is_equal(1.8)


func test_heavy_attack_type_uses_third_path_without_combo_or_parry() -> void:
	var modifiers: Dictionary = {"attack_type_multiplier": 2.0}
	var result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_attack_type_damage(
		10,
		0,
		0,
		1.0,
		&"heavy",
		2,
		0,
		modifiers,
		2,
		3
	)

	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_attack_type_multiplier(&"heavy", modifiers)).is_equal(2.0)
	assert_int(result.final_damage).is_equal(50)
	assert_int(result.combo_stage).is_equal(0)
	assert_bool(result.is_parry).is_false()
	assert_bool(result.is_crit).is_true()
	assert_str(String(result.crit_type)).is_equal("perfect")


func test_unknown_attack_type_falls_back_to_neutral_multiplier() -> void:
	var modifiers: Dictionary = {"attack_type_multiplier": 2.0}
	var result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_attack_type_damage(
		10,
		0,
		0,
		1.0,
		&"unknown",
		-1,
		0,
		modifiers
	)

	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_attack_type_multiplier(&"unknown", modifiers)).is_equal(1.0)
	assert_int(result.final_damage).is_equal(10)
