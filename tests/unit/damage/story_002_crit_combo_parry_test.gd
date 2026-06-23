## Story 002: deterministic crit, combo, and parry multiplier paths.
extends GdUnitTestSuite

const DAMAGE_CALCULATOR_SCRIPT = preload("res://src/foundation/damage_calculator.gd")


func test_crit_windows_apply_perfect_good_and_normal_multipliers() -> void:
	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_crit_multiplier(2, 0)).is_equal(2.5)
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_crit_type(2, 0))).is_equal("perfect")
	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_crit_multiplier(4, 0)).is_equal(1.8)
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_crit_type(4, 0))).is_equal("good")
	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_crit_multiplier(6, 0)).is_equal(1.0)
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_crit_type(6, 0))).is_equal("none")

	var perfect_result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_normal_damage(10, 0, 0, 1.0, &"cat_claw", 0, 2)
	var good_result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_normal_damage(10, 0, 0, 1.0, &"cat_claw", 0, 4)

	assert_int(perfect_result.final_damage).is_equal(25)
	assert_bool(perfect_result.is_crit).is_true()
	assert_str(String(perfect_result.crit_type)).is_equal("perfect")
	assert_int(good_result.final_damage).is_equal(18)
	assert_str(String(good_result.crit_type)).is_equal("good")


func test_parry_intervals_apply_half_open_multiplier_ranges() -> void:
	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_parry_multiplier(3)).is_equal(5.0)
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_parry_type(3))).is_equal("perfect")
	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_parry_multiplier(10)).is_equal(2.5)
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_parry_type(10))).is_equal("good")
	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_parry_multiplier(15)).is_equal(1.5)
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_parry_type(15))).is_equal("late")

	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_parry_multiplier(-1)).is_equal(1.0)
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_parry_type(-1))).is_equal("none")
	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_parry_multiplier(19)).is_equal(1.0)
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_parry_type(19))).is_equal("none")


func test_parry_damage_matches_perfect_good_and_late_gdd_examples() -> void:
	var perfect_result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_parry_damage(10, 0, 0, 1.0, 3)
	var good_result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_parry_damage(10, 0, 0, 1.0, 10)
	var late_result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_parry_damage(10, 0, 0, 1.0, 15)

	assert_int(perfect_result.final_damage).is_equal(50)
	assert_bool(perfect_result.is_parry).is_true()
	assert_str(String(perfect_result.parry_type)).is_equal("perfect")
	assert_int(good_result.final_damage).is_equal(25)
	assert_str(String(good_result.parry_type)).is_equal("good")
	assert_int(late_result.final_damage).is_equal(15)
	assert_str(String(late_result.parry_type)).is_equal("late")


func test_combo_finisher_and_reset_match_gdd_examples() -> void:
	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_combo_multiplier(&"cat_claw", 2)).is_equal(1.8)
	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_combo_multiplier(&"fish_bone", 2)).is_equal(2.2)
	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_combo_multiplier(&"cat_claw", 99)).is_equal(1.0)

	var finisher_result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_normal_damage(13, 0, 0, 1.0, &"cat_claw", 2, 2)
	var reset_result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_normal_damage(10, 0, 0, 1.0, &"cat_claw", 0, -1)

	assert_int(finisher_result.final_damage).is_equal(58)
	assert_int(finisher_result.combo_stage).is_equal(2)
	assert_int(reset_result.final_damage).is_equal(10)
	assert_int(reset_result.combo_stage).is_equal(0)


func test_perfect_parry_with_defense_ignores_combo_multiplier() -> void:
	var parry_result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_parry_damage(10, 0, 20, 1.0, 3, -1, &"cat_claw", 2)

	assert_int(parry_result.final_damage).is_equal(37)
	assert_int(parry_result.combo_stage).is_equal(0)
	assert_str(String(parry_result.parry_type)).is_equal("perfect")
