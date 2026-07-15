## Story 002: SchemaValidator + validation failure handling.
extends GdUnitTestSuite

const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")

const MANIFEST_PATH: String = "res://data/manifest.json"
const DAMAGE_PATH: String = "res://data/combat/damage_params.json"
const DAMAGE_SCHEMA_PATH: String = "res://data/schemas/damage_params.schema.json"

var data_manager
var _file_backups: Dictionary = {}


func before_test() -> void:
	_backup_files([MANIFEST_PATH, DAMAGE_PATH, DAMAGE_SCHEMA_PATH])


func after_test() -> void:
	if is_instance_valid(data_manager):
		if data_manager.get_parent() != null:
			data_manager.get_parent().remove_child(data_manager)
		data_manager.free()
	data_manager = null
	_restore_files()


func test_valid_data_passes_validation() -> void:
	var data: Dictionary = {
		"entries": {
			"cat_claw": {
				"weapon_base": 10,
				"scaling_factor": 1.2,
				"crit_perfect_multiplier": 2.5,
			}
		}
	}

	var result: ValidationResult = SchemaValidator.validate("damage_params", data, _get_test_schema())

	assert_bool(result.is_valid).is_true()
	assert_int(result.errors.size()).is_equal(0)


func test_integral_float_passes_int_validation_for_json_numbers() -> void:
	var data: Dictionary = {
		"entries": {
			"cat_claw": {
				"weapon_base": 10.0,
				"scaling_factor": 1.2,
				"crit_perfect_multiplier": 2.5,
			}
		}
	}

	var result: ValidationResult = SchemaValidator.validate("damage_params", data, _get_test_schema())

	assert_bool(result.is_valid).is_true()
	assert_int(result.errors.size()).is_equal(0)


func test_fractional_float_fails_int_validation() -> void:
	var data: Dictionary = {
		"entries": {
			"cat_claw": {
				"weapon_base": 10.5,
				"scaling_factor": 1.2,
				"crit_perfect_multiplier": 2.5,
			}
		}
	}

	var result: ValidationResult = SchemaValidator.validate("damage_params", data, _get_test_schema())

	assert_bool(result.is_valid).is_false()
	assert_str(" ".join(result.errors)).contains("expected int")


func test_missing_required_field_fails_validation() -> void:
	var data: Dictionary = {
		"entries": {
			"cat_claw": {
				"weapon_base": 10,
			}
		}
	}

	var result: ValidationResult = SchemaValidator.validate("damage_params", data, _get_test_schema())

	assert_bool(result.is_valid).is_false()
	assert_int(result.errors.size()).is_greater_equal(2)
	var all_errors: String = " ".join(result.errors)
	assert_str(all_errors).contains("scaling_factor")
	assert_str(all_errors).contains("crit_perfect_multiplier")


func test_missing_entry_entirely_fails_validation() -> void:
	var data: Dictionary = {"entries": {}}

	var result: ValidationResult = SchemaValidator.validate("damage_params", data, _get_test_schema())

	assert_bool(result.is_valid).is_false()
	assert_str(result.errors[0]).contains("cat_claw")


func test_type_mismatch_fails_validation() -> void:
	var data: Dictionary = {
		"entries": {
			"cat_claw": {
				"weapon_base": "not_an_int",
				"scaling_factor": 1.2,
				"crit_perfect_multiplier": 2.5,
			}
		}
	}

	var result: ValidationResult = SchemaValidator.validate("damage_params", data, _get_test_schema())

	assert_bool(result.is_valid).is_false()
	assert_str(" ".join(result.errors)).contains("expected int")


func test_range_violation_fails_validation() -> void:
	var data: Dictionary = {
		"entries": {
			"cat_claw": {
				"weapon_base": -5,
				"scaling_factor": 1.2,
				"crit_perfect_multiplier": 2.5,
			}
		}
	}

	var result: ValidationResult = SchemaValidator.validate("damage_params", data, _get_test_schema())

	assert_bool(result.is_valid).is_false()
	assert_str(result.errors[0]).contains("below minimum")


func test_enum_violation_fails_validation() -> void:
	var schema: Dictionary = {
		"entries": {
			"test_entry": {
				"required": ["damage_type"],
				"fields": {
					"damage_type": {"type": "String", "enum": ["physical", "magical"]}
				}
			}
		}
	}
	var data: Dictionary = {"entries": {"test_entry": {"damage_type": "fire"}}}

	var result: ValidationResult = SchemaValidator.validate("test_domain", data, schema)

	assert_bool(result.is_valid).is_false()
	assert_str(result.errors[0]).contains("not in enum")


func test_array_items_validate_nested_required_fields() -> void:
	var schema: Dictionary = {
		"entries": {
			"boss": {
				"required": ["attack_patterns"],
				"fields": {
					"attack_patterns": {
						"type": "Array",
						"items": {
							"type": "Dictionary",
							"required": ["pattern_id", "damage"],
							"fields": {
								"pattern_id": {"type": "String"},
								"damage": {"type": "int", "min": 1},
							},
						},
					},
				},
			}
		}
	}
	var data: Dictionary = {
		"entries": {
			"boss": {
				"attack_patterns": [
					{"pattern_id": "talon_dive"},
				]
			}
		}
	}

	var result: ValidationResult = SchemaValidator.validate("enemy_stats", data, schema)

	assert_bool(result.is_valid).is_false()
	assert_str(" ".join(result.errors)).contains("attack_patterns[0].damage")


func test_first_load_validation_failure_empty_cache_and_ready() -> void:
	_create_valid_manifest()
	_write_file(DAMAGE_PATH, """{
	"_meta": {"version": "1.0", "domain": "damage_params"},
	"entries": {
		"cat_claw": {"weapon_base": "invalid", "scaling_factor": 1.2, "crit_perfect_multiplier": 2.5}
	}
}""")
	_create_schema_file("""{
	"entries": {
		"cat_claw": {
			"required": ["weapon_base", "scaling_factor", "crit_perfect_multiplier"],
			"fields": {
				"weapon_base": {"type": "float", "min": 0.0, "max": 999.0},
				"scaling_factor": {"type": "float", "min": 0.0, "max": 10.0},
				"crit_perfect_multiplier": {"type": "float", "min": 1.0, "max": 10.0}
			}
		}
	}
}""")

	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)

	assert_int(data_manager.get_state()).is_equal(data_manager.State.READY)
	assert_that(data_manager.get_entry(&"damage_params", &"cat_claw")).is_null()


func test_hot_reload_preserves_cache_design() -> void:
	var old_data: Dictionary = {
		"entries": {
			"cat_claw": {"weapon_base": 10, "scaling_factor": 1.2, "crit_perfect_multiplier": 2.5}
		}
	}
	var bad_new_data: Dictionary = {
		"entries": {
			"cat_claw": {"weapon_base": "invalid"}
		}
	}

	var old_result: ValidationResult = SchemaValidator.validate("damage_params", old_data, _get_test_schema())
	var new_result: ValidationResult = SchemaValidator.validate("damage_params", bad_new_data, _get_test_schema())

	assert_bool(old_result.is_valid).is_true()
	assert_bool(new_result.is_valid).is_false()


func test_missing_schema_skips_validation_data_loaded() -> void:
	_remove_file(DAMAGE_SCHEMA_PATH)
	_create_valid_manifest()
	_create_valid_domain_file()

	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)

	assert_int(data_manager.get_state()).is_equal(data_manager.State.READY)
	assert_that(data_manager.get_entry(&"damage_params", &"cat_claw")).is_not_null()


func test_schema_without_type_only_checks_required() -> void:
	var schema: Dictionary = {
		"entries": {
			"cat_claw": {"required": ["weapon_base"]}
		}
	}
	var data: Dictionary = {
		"entries": {
			"cat_claw": {"weapon_base": "any_value"}
		}
	}

	var result: ValidationResult = SchemaValidator.validate("damage_params", data, schema)

	assert_bool(result.is_valid).is_true()
	assert_int(result.errors.size()).is_equal(0)


func _get_test_schema() -> Dictionary:
	return {
		"entries": {
			"cat_claw": {
				"required": ["weapon_base", "scaling_factor", "crit_perfect_multiplier"],
				"fields": {
					"weapon_base": {"type": "int", "min": 0, "max": 999},
					"scaling_factor": {"type": "float", "min": 0.0, "max": 10.0},
					"crit_perfect_multiplier": {"type": "float", "min": 1.0, "max": 10.0},
				}
			}
		}
	}


func _create_valid_manifest() -> void:
	_write_file(MANIFEST_PATH, """{
	"_meta": {"version": "1.0", "domain": "manifest"},
	"domains": [
		{"name": "damage_params", "path": "combat/damage_params.json", "preload": true}
	]
}""")


func _create_valid_domain_file() -> void:
	_write_file(DAMAGE_PATH, """{
	"_meta": {"version": "1.0", "domain": "damage_params"},
	"entries": {
		"cat_claw": {
			"weapon_base": 10,
			"scaling_factor": 1.2,
			"crit_perfect_multiplier": 2.5,
			"crit_good_multiplier": 1.8
		}
	}
}""")


func _create_schema_file(content: String) -> void:
	_write_file(DAMAGE_SCHEMA_PATH, content)


func _backup_files(paths: Array) -> void:
	_file_backups.clear()
	for path: String in paths:
		_file_backups[path] = {
			"exists": FileAccess.file_exists(path),
			"content": FileAccess.get_file_as_string(path) if FileAccess.file_exists(path) else "",
		}


func _restore_files() -> void:
	for path: String in _file_backups.keys():
		var backup: Dictionary = _file_backups[path]
		if backup["exists"]:
			_write_file(path, backup["content"])
		else:
			_remove_file(path)
	_file_backups.clear()


func _write_file(path: String, content: String) -> void:
	var dir_path: String = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	assert_that(file).is_not_null()
	file.store_string(content)
	file.close()


func _remove_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
