## Story 001: FormulaPipeline + DamageResult core formulas.
extends GdUnitTestSuite

const DAMAGE_CALCULATOR_SCRIPT = preload("res://src/foundation/damage_calculator.gd")
const DAMAGE_RESULT_SCRIPT = preload("res://src/foundation/damage_result.gd")


func test_baseline_pipeline_returns_base_damage_without_reduction() -> void:
	var result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_basic_damage(10, 0, 0, 1.0)

	assert_int(result.final_damage).is_equal(10)
	assert_int(result.base_damage).is_equal(10)
	assert_float(result.reduction_factor).is_equal(1.0)
	assert_str(String(result.damage_category)).is_equal("normal")


func test_defense_reduction_curve_matches_gdd_examples() -> void:
	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_reduction_factor(20, 60.0)).is_equal_approx(0.75, 0.0001)
	assert_int(DAMAGE_CALCULATOR_SCRIPT.calculate_final_damage(10.0, 20, 1.0, 60.0, 1, 999)).is_equal(7)
	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_reduction_factor(50, 60.0)).is_equal_approx(0.5454, 0.0001)
	assert_int(DAMAGE_CALCULATOR_SCRIPT.calculate_final_damage(10.0, 50, 1.0, 60.0, 1, 999)).is_equal(5)


func test_negative_defense_is_clamped_to_zero() -> void:
	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_reduction_factor(-10, 60.0)).is_equal(1.0)
	assert_int(DAMAGE_CALCULATOR_SCRIPT.calculate_final_damage(10.0, -10, 1.0, 60.0, 1, 999)).is_equal(10)


func test_final_damage_floor_cap_and_multiplier_match_gdd_examples() -> void:
	assert_int(DAMAGE_CALCULATOR_SCRIPT.apply_final_damage(100.0, 0.5, 1.0, 1, 999)).is_equal(50)
	assert_int(DAMAGE_CALCULATOR_SCRIPT.calculate_final_damage(1.0, 5940, 1.0, 60.0, 1, 999)).is_equal(1)
	assert_int(DAMAGE_CALCULATOR_SCRIPT.apply_final_damage(2000.0, 1.0, 1.0, 1, 999)).is_equal(999)
	assert_int(DAMAGE_CALCULATOR_SCRIPT.apply_final_damage(100.0, 0.75, 1.5, 1, 999)).is_equal(112)
	assert_int(DAMAGE_CALCULATOR_SCRIPT.apply_final_damage(800.0, 1.0, 2.0, 1, 999)).is_equal(999)


func test_damage_result_exposes_default_metadata_fields() -> void:
	var result = DAMAGE_RESULT_SCRIPT.new()

	assert_int(result.final_damage).is_equal(0)
	assert_bool(result.is_crit).is_false()
	assert_str(String(result.crit_type)).is_equal("none")
	assert_bool(result.is_parry).is_false()
	assert_str(String(result.parry_type)).is_equal("none")
	assert_int(result.combo_stage).is_equal(0)
	assert_str(String(result.damage_category)).is_equal("scratch")


func test_damage_category_thresholds_match_gdd_ranges() -> void:
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_damage_category(1))).is_equal("scratch")
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_damage_category(5))).is_equal("scratch")
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_damage_category(6))).is_equal("normal")
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_damage_category(15))).is_equal("normal")
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_damage_category(16))).is_equal("strong")
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_damage_category(30))).is_equal("strong")
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_damage_category(31))).is_equal("powerful")
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_damage_category(60))).is_equal("powerful")
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_damage_category(61))).is_equal("extreme")
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_damage_category(150))).is_equal("extreme")
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_damage_category(151))).is_equal("legendary")
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_damage_category(999))).is_equal("legendary")
