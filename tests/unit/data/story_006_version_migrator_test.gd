## Story 006: VersionMigrator compatibility formula and chained migrations.
extends GdUnitTestSuite

const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")

var data_manager
var _migration_order: Array[String] = []


func before_test() -> void:
	_migration_order.clear()
	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)


func after_test() -> void:
	if is_instance_valid(data_manager):
		if data_manager.get_parent() != null:
			data_manager.get_parent().remove_child(data_manager)
		data_manager.free()
	data_manager = null
	_migration_order.clear()


func test_exact_version_returns_duplicate_without_migration() -> void:
	var data: Dictionary = _domain_data("1.2", {"value": 10})

	var migrated: Variant = _check_and_migrate(data, "1.2")
	if migrated == null:
		return

	assert_dict(migrated).contains_keys("_meta")
	assert_str(migrated["_meta"]["version"]).is_equal("1.2")
	assert_int(migrated["entries"]["sample"]["value"]).is_equal(10)
	assert_array(_migration_order).is_empty()


func test_lower_minor_executes_migration_chain_to_expected_version() -> void:
	_register_migration("1.0", "1.1", _migrate_1_0_to_1_1)
	_register_migration("1.1", "1.2", _migrate_1_1_to_1_2)
	var data: Dictionary = _domain_data("1.0", {"value": 10})

	var migrated: Variant = _check_and_migrate(data, "1.2")
	if migrated == null:
		return

	assert_str(migrated["_meta"]["version"]).is_equal("1.2")
	assert_int(migrated["entries"]["sample"]["value"]).is_equal(12)
	assert_array(_migration_order).is_equal(["1.0->1.1", "1.1->1.2"])


func test_major_mismatch_returns_null_and_keeps_original_data() -> void:
	var data: Dictionary = _domain_data("2.0", {"value": 10})

	var migrated: Variant = _check_and_migrate(data, "1.2")

	assert_that(migrated).is_null()
	assert_str(data["_meta"]["version"]).is_equal("2.0")
	assert_int(data["entries"]["sample"]["value"]).is_equal(10)


func test_higher_minor_is_compatible_without_migration() -> void:
	var data: Dictionary = _domain_data("1.3", {"value": 10})

	var migrated: Variant = _check_and_migrate(data, "1.1")
	if migrated == null:
		return

	assert_str(migrated["_meta"]["version"]).is_equal("1.3")
	assert_int(migrated["entries"]["sample"]["value"]).is_equal(10)
	assert_array(_migration_order).is_empty()


func test_migration_failure_rolls_back_to_original_data() -> void:
	_register_migration("1.0", "1.1", _migrate_1_0_to_1_1)
	_register_migration("1.1", "1.2", _fail_migration)
	var data: Dictionary = _domain_data("1.0", {"value": 10})

	var migrated: Variant = _check_and_migrate(data, "1.2")
	if migrated == null:
		return

	assert_str(migrated["_meta"]["version"]).is_equal("1.0")
	assert_int(migrated["entries"]["sample"]["value"]).is_equal(10)
	assert_str(data["_meta"]["version"]).is_equal("1.0")
	assert_int(data["entries"]["sample"]["value"]).is_equal(10)
	assert_array(_migration_order).is_equal(["1.0->1.1", "1.1->1.2 fail"])


func test_version_formula_flags_cover_boundary_quadrants() -> void:
	assert_dict(_version_flags("1.0", "1.2")).is_equal({
		"compatible": false,
		"needs_migration": true,
	})
	assert_dict(_version_flags("1.2", "1.2")).is_equal({
		"compatible": true,
		"needs_migration": false,
	})
	assert_dict(_version_flags("1.5", "1.2")).is_equal({
		"compatible": true,
		"needs_migration": false,
	})
	assert_dict(_version_flags("2.0", "1.2")).is_equal({
		"compatible": false,
		"needs_migration": false,
	})
	assert_dict(_version_flags("0.9", "1.2")).is_equal({
		"compatible": false,
		"needs_migration": false,
	})


func _domain_data(version: String, sample_entry: Dictionary) -> Dictionary:
	return {
		"_meta": {
			"version": version,
			"domain": "sample",
		},
		"entries": {
			"sample": sample_entry.duplicate(true),
		},
	}


func _register_migration(from_version: String, to_version: String, migration: Callable) -> void:
	if not data_manager.has_method("register_migration"):
		assert_bool(false).override_failure_message("DataManager.register_migration() must exist").is_true()
		return
	data_manager.register_migration(from_version, to_version, migration)


func _check_and_migrate(data: Dictionary, expected_version: String) -> Variant:
	if not data_manager.has_method("check_and_migrate"):
		assert_bool(false).override_failure_message("DataManager.check_and_migrate() must exist").is_true()
		return null
	return data_manager.check_and_migrate(data, expected_version)


func _version_flags(file_version: String, expected_version: String) -> Dictionary:
	if not data_manager.has_method("get_version_flags"):
		assert_bool(false).override_failure_message("DataManager.get_version_flags() must exist").is_true()
		return {}
	return data_manager.get_version_flags(file_version, expected_version)


func _migrate_1_0_to_1_1(data: Dictionary) -> Dictionary:
	_migration_order.append("1.0->1.1")
	var migrated: Dictionary = data.duplicate(true)
	migrated["_meta"]["version"] = "1.1"
	migrated["entries"]["sample"]["value"] += 1
	return migrated


func _migrate_1_1_to_1_2(data: Dictionary) -> Dictionary:
	_migration_order.append("1.1->1.2")
	var migrated: Dictionary = data.duplicate(true)
	migrated["_meta"]["version"] = "1.2"
	migrated["entries"]["sample"]["value"] += 1
	return migrated


func _fail_migration(_data: Dictionary) -> Dictionary:
	_migration_order.append("1.1->1.2 fail")
	return {}
