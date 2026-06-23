## Story 001: StatusEffectComponent catalog and initial state.
extends GdUnitTestSuite

const STATUS_EFFECT_COMPONENT_PATH: String = "res://src/core/status_effect_component.gd"
const SCHEMA_VALIDATOR_SCRIPT: Script = preload("res://src/foundation/schema_validator.gd")

const TUNING_PATH: String = "res://data/tuning_knobs.json"
const TUNING_SCHEMA_PATH: String = "res://data/schemas/tuning_knobs.schema.json"

var status_effects


func before_test() -> void:
	var script: Script = load(STATUS_EFFECT_COMPONENT_PATH)
	if script != null:
		status_effects = script.new()
		add_child(status_effects)


func after_test() -> void:
	if is_instance_valid(status_effects):
		if status_effects.get_parent() != null:
			status_effects.get_parent().remove_child(status_effects)
		status_effects.free()
	status_effects = null


func test_component_starts_empty_with_default_capacity() -> void:
	if not _assert_component_exists():
		return

	assert_int(status_effects.get_max_effects()).is_equal(5)
	assert_array(status_effects.get_active_effects()).is_empty()


func test_catalog_defines_exactly_gdd_effect_ids() -> void:
	if not _assert_component_exists():
		return
	var expected: Array[String] = [
		"poison",
		"slow",
		"stun",
		"burn",
		"speed_boost",
		"damage_boost",
		"invincible",
	]

	assert_array(_stringify_ids(status_effects.get_effect_ids())).is_equal(expected)


func test_catalog_entries_expose_required_metadata() -> void:
	if not _assert_component_exists():
		return
	for effect_id: StringName in status_effects.get_effect_ids():
		var config: Dictionary = status_effects.get_effect_config(effect_id)
		assert_dict(config).contains_keys([
			"category",
			"base_duration_sec",
			"priority",
			"dot_damage",
			"movement_modifier",
			"damage_modifier",
		])

	assert_float(status_effects.get_effect_config(&"slow")["movement_modifier"]).is_equal_approx(
		0.7,
		0.001
	)
	var speed_boost_config: Dictionary = status_effects.get_effect_config(&"speed_boost")
	assert_float(speed_boost_config["movement_modifier"]).is_equal_approx(
		1.3,
		0.001
	)


func test_active_effects_returns_defensive_copy() -> void:
	if not _assert_component_exists():
		return

	var active_effects: Array = status_effects.get_active_effects()
	active_effects.append({"effect_id": &"poison"})

	assert_array(status_effects.get_active_effects()).is_empty()


func test_project_status_tuning_knobs_validate_through_schema() -> void:
	var data: Dictionary = _load_json(TUNING_PATH)
	var schema: Dictionary = _load_json(TUNING_SCHEMA_PATH)
	var result: Variant = SCHEMA_VALIDATOR_SCRIPT.validate("tuning_knobs", data, schema)
	var entries: Dictionary = data.get("entries", {})

	assert_bool(result.is_valid).is_true()
	for knob_id: String in _expected_status_knob_ids():
		assert_bool(entries.has(knob_id)).override_failure_message(
			"Missing status tuning knob: %s" % knob_id
		).is_true()


func _assert_component_exists() -> bool:
	assert_that(status_effects).override_failure_message(
		"StatusEffectComponent script must exist at %s" % STATUS_EFFECT_COMPONENT_PATH
	).is_not_null()
	return status_effects != null


func _stringify_ids(effect_ids: Array) -> Array[String]:
	var result: Array[String] = []
	for effect_id: Variant in effect_ids:
		result.append(String(effect_id))
	return result


func _expected_status_knob_ids() -> Array[String]:
	return [
		"status.poison_duration_sec",
		"status.poison_dps",
		"status.slow_duration_sec",
		"status.slow_percentage",
		"status.stun_duration_sec",
		"status.burn_duration_sec",
		"status.burn_dps",
		"status.max_effects_per_entity",
		"status.speed_boost_percentage",
		"status.damage_boost_percentage",
		"status.invincible_duration_sec",
	]


func _load_json(path: String) -> Dictionary:
	assert_bool(FileAccess.file_exists(path)).override_failure_message(
		"Missing JSON file: %s" % path
	).is_true()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	assert_bool(parsed is Dictionary).override_failure_message(
		"Invalid JSON object: %s" % path
	).is_true()
	return parsed as Dictionary
