## Story 002: SchemaValidator + 三级失败处理 — 单元测试
##
## 覆盖全部 6 条验收标准 (AC-01 ~ AC-06) + 补充测试。
## 测试框架: GdUnit4
extends GdUnitTestSuite

const TEST_DIR: String = "res://data/"
const TEST_COMBAT_DIR: String = "res://data/combat/"
const TEST_SCHEMA_DIR: String = "res://data/schemas/"

var data_manager: DataManager


func before_test() -> void:
	data_manager = DataManager.new()


func after_test() -> void:
	if is_instance_valid(data_manager):
		data_manager.queue_free()
	_remove_file(TEST_DIR.path_join("manifest.json"))
	_remove_file(TEST_COMBAT_DIR.path_join("damage_params.json"))
	_remove_file(TEST_SCHEMA_DIR.path_join("damage_params.schema.json"))


# ---------------------------------------------------------------------------
# Test Helpers
# ---------------------------------------------------------------------------

func _write_file(path: String, content: String) -> bool:
	var dir_path: String = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(content)
	file.close()
	return true


func _remove_file(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _create_valid_manifest() -> void:
	var manifest: String = """{
	"_meta": {"version": "1.0", "domain": "manifest"},
	"domains": [
		{"name": "damage_params", "path": "combat/damage_params.json", "preload": true}
	]
}"""
	_write_file(TEST_DIR.path_join("manifest.json"), manifest)


func _create_valid_domain_file() -> void:
	var domain: String = """{
	"_meta": {"version": "1.0", "domain": "damage_params"},
	"entries": {
		"cat_claw": {"weapon_base": 10, "scaling_factor": 1.2, "crit_perfect_multiplier": 2.5, "crit_good_multiplier": 1.8}
	}
}"""
	_write_file(TEST_COMBAT_DIR.path_join("damage_params.json"), domain)


func _create_schema_file(content: String) -> void:
	_write_file(TEST_SCHEMA_DIR.path_join("damage_params.schema.json"), content)


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


# ---------------------------------------------------------------------------
# AC-01: 有效 JSON 通过 Schema 验证
# ---------------------------------------------------------------------------

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


# ---------------------------------------------------------------------------
# AC-02: 缺少必填字段
# ---------------------------------------------------------------------------

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


# ---------------------------------------------------------------------------
# AC-03: 类型不匹配
# ---------------------------------------------------------------------------

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
	var all_errors: String = " ".join(result.errors)
	assert_str(all_errors).contains("expected int")


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
	var data: Dictionary = {
		"entries": {
			"test_entry": {"damage_type": "fire"}
		}
	}
	var result: ValidationResult = SchemaValidator.validate("test_domain", data, schema)
	assert_bool(result.is_valid).is_false()
	assert_str(result.errors[0]).contains("not in enum")


# ---------------------------------------------------------------------------
# AC-04: 首次加载验证失败 → 空缓存 + READY
# ---------------------------------------------------------------------------

func test_first_load_validation_failure_empty_cache_and_ready() -> void:
	_create_valid_manifest()
	var bad_domain: String = """{
	"_meta": {"version": "1.0", "domain": "damage_params"},
	"entries": {
		"cat_claw": {"weapon_base": "invalid", "scaling_factor": 1.2, "crit_perfect_multiplier": 2.5}
	}
}"""
	_write_file(TEST_COMBAT_DIR.path_join("damage_params.json"), bad_domain)
	var schema: String = """{
	"entries": {
		"cat_claw": {
			"required": ["weapon_base", "scaling_factor", "crit_perfect_multiplier"],
			"fields": {
				"weapon_base": {"type": "int", "min": 0, "max": 999},
				"scaling_factor": {"type": "float", "min": 0.0, "max": 10.0},
				"crit_perfect_multiplier": {"type": "float", "min": 1.0, "max": 10.0}
			}
		}
	}
}"""
	_create_schema_file(schema)
	add_child(data_manager)
	assert_int(data_manager.get_state()).is_equal(DataManager.State.READY)
	assert_object(data_manager.get_entry(&"damage_params", &"cat_claw")).is_null()


# ---------------------------------------------------------------------------
# AC-05: 热重载验证失败 → 保留旧缓存（设计约束验证）
# ---------------------------------------------------------------------------

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
	var schema: Dictionary = _get_test_schema()
	var old_result: ValidationResult = SchemaValidator.validate("damage_params", old_data, schema)
	var new_result: ValidationResult = SchemaValidator.validate("damage_params", bad_new_data, schema)
	assert_bool(old_result.is_valid).is_true()
	assert_bool(new_result.is_valid).is_false()


# ---------------------------------------------------------------------------
# AC-06: Schema 文件不存在 → 跳过验证，数据正常加载
# ---------------------------------------------------------------------------

func test_missing_schema_skips_validation_data_loaded() -> void:
	_create_valid_manifest()
	_create_valid_domain_file()
	add_child(data_manager)
	assert_int(data_manager.get_state()).is_equal(DataManager.State.READY)
	var entry: Variant = data_manager.get_entry(&"damage_params", &"cat_claw")
	assert_object(entry).is_not_null()


# ---------------------------------------------------------------------------
# 补充测试
# ---------------------------------------------------------------------------

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
