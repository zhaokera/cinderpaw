## Story 004: DamageParams data API integration.
extends GdUnitTestSuite

const DAMAGE_CALCULATOR_SCRIPT = preload("res://src/foundation/damage_calculator.gd")
const DATA_MANAGER_SCRIPT = preload("res://src/foundation/data_manager.gd")
const SCHEMA_VALIDATOR_SCRIPT = preload("res://src/foundation/schema_validator.gd")

const DAMAGE_PARAMS_PATH: String = "res://data/combat/damage_params.json"
const DAMAGE_SCHEMA_PATH: String = "res://data/schemas/damage_params.schema.json"

var data_manager


func before_test() -> void:
	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)


func after_test() -> void:
	if is_instance_valid(data_manager):
		if data_manager.get_parent() != null:
			data_manager.get_parent().remove_child(data_manager)
		data_manager.free()
	data_manager = null


func test_damage_params_contains_all_supported_weapon_entries() -> void:
	var data: Dictionary = _load_json(DAMAGE_PARAMS_PATH)
	var entries: Dictionary = data.get("entries", {})

	assert_dict(entries).contains_keys(["_global", "cat_claw", "long_tail", "fish_bone", "electro_bell"])
	assert_int(int(entries["cat_claw"]["weapon_base"])).is_equal(10)
	assert_int(int(entries["long_tail"]["weapon_base"])).is_equal(15)
	assert_int(int(entries["fish_bone"]["weapon_base"])).is_equal(40)
	assert_dict(entries["cat_claw"]).contains_keys(["combo_multipliers", "special_move"])
	assert_dict(entries["_global"]).contains_keys([
		"crit_multipliers",
		"parry_multipliers",
		"attack_type_multipliers",
		"category_thresholds",
	])


func test_damage_params_schema_accepts_valid_data_and_declares_required_fields() -> void:
	var data: Dictionary = _load_json(DAMAGE_PARAMS_PATH)
	var schema: Dictionary = _load_json(DAMAGE_SCHEMA_PATH)
	var schema_entries: Dictionary = schema.get("entries", {})
	var global_required: Variant = schema_entries["_global"].get("required", [])
	var weapon_required: Variant = schema_entries["cat_claw"].get("required", [])
	var result: Variant = SCHEMA_VALIDATOR_SCRIPT.validate("damage_params", data, schema)

	assert_bool(result.is_valid).is_true()
	assert_array(global_required).contains("crit_multipliers")
	assert_array(global_required).contains("parry_multipliers")
	assert_array(global_required).contains("attack_type_multipliers")
	assert_array(global_required).contains("category_thresholds")
	assert_array(weapon_required).contains("weapon_base")
	assert_array(weapon_required).contains("combo_multipliers")
	assert_array(weapon_required).contains("special_move")


func test_damage_params_schema_rejects_missing_nested_special_move_parameter() -> void:
	var data: Dictionary = _load_json(DAMAGE_PARAMS_PATH)
	var schema: Dictionary = _load_json(DAMAGE_SCHEMA_PATH)
	data["entries"]["cat_claw"]["special_move"].erase("hits")
	var result: Variant = SCHEMA_VALIDATOR_SCRIPT.validate("damage_params", data, schema)

	assert_bool(result.is_valid).is_false()
	assert_array(result.errors).contains("damage_params.cat_claw.special_move.hits: required field missing")


func test_calculate_damage_public_api_uses_data_values_for_all_paths() -> void:
	var normal_result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_damage(
		&"normal",
		&"cat_claw",
		-1,
		0,
		-1,
		0,
		0,
		{},
		{},
		data_manager
	)
	var special_result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_damage(
		&"special",
		&"long_tail",
		2,
		2,
		-1,
		10,
		0,
		{},
		{},
		data_manager
	)
	var parry_result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_damage(
		&"parry",
		&"cat_claw",
		2,
		2,
		3,
		0,
		30,
		{},
		{},
		data_manager
	)

	assert_int(normal_result.final_damage).is_equal(10)
	assert_str(String(normal_result.damage_category)).is_equal("normal")
	assert_int(special_result.final_damage).is_equal(63)
	assert_bool(special_result.is_crit).is_true()
	assert_int(special_result.combo_stage).is_equal(0)
	assert_int(parry_result.final_damage).is_equal(83)
	assert_bool(parry_result.is_parry).is_true()
	assert_bool(parry_result.is_crit).is_true()


func test_calculate_damage_covers_remaining_gdd_ac10_and_ac17_examples() -> void:
	var ac10_params: Dictionary = _load_json(DAMAGE_PARAMS_PATH)
	ac10_params["entries"]["_global"]["damage_multiplier"] = 0.5
	var ac10_result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_damage(
		&"normal",
		&"cat_claw",
		-1,
		0,
		-1,
		0,
		30,
		{},
		ac10_params
	)
	var expert_result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_damage(
		&"parry",
		&"cat_claw",
		2,
		0,
		3,
		0,
		30,
		{},
		{},
		data_manager
	)
	var novice_result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_damage(
		&"normal",
		&"fish_bone",
		-1,
		0,
		-1,
		50,
		30,
		{},
		{},
		data_manager
	)

	assert_int(ac10_result.final_damage).is_equal(3)
	assert_int(expert_result.final_damage).is_equal(83)
	assert_int(novice_result.final_damage).is_equal(33)
	assert_bool(expert_result.final_damage > novice_result.final_damage).is_true()


func test_tuning_knobs_affect_damage_multiplier_floor_and_cap() -> void:
	DAMAGE_CALCULATOR_SCRIPT.register_damage_tuning_knobs(data_manager)

	assert_bool(data_manager.set_tuning(&"damage.multiplier", 2.0)).is_true()
	var boosted_result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_damage(
		&"normal",
		&"cat_claw",
		-1,
		0,
		-1,
		0,
		0,
		{},
		{},
		data_manager
	)
	assert_int(boosted_result.final_damage).is_equal(20)

	assert_bool(data_manager.set_tuning(&"damage.cap", 100)).is_true()
	var capped_result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_damage(
		&"parry",
		&"fish_bone",
		2,
		0,
		3,
		50,
		0,
		{},
		{},
		data_manager
	)
	assert_int(capped_result.final_damage).is_equal(100)


func test_missing_weapon_id_returns_safe_damage_result() -> void:
	var result: Variant = DAMAGE_CALCULATOR_SCRIPT.calculate_damage(
		&"normal",
		&"missing_weapon",
		-1,
		0,
		-1,
		0,
		0
	)

	assert_int(result.base_damage).is_equal(0)
	assert_int(result.final_damage).is_equal(1)
	assert_str(String(result.damage_category)).is_equal("scratch")


func _load_json(path: String) -> Dictionary:
	assert_bool(FileAccess.file_exists(path)).override_failure_message("Missing JSON file: %s" % path).is_true()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	assert_bool(parsed is Dictionary).override_failure_message("Invalid JSON object: %s" % path).is_true()
	return parsed as Dictionary
