## Story 001: ManifestLoader + 4-state machine + retry.
##
## Uses backup/restore around res://data because DataManager currently has a
## fixed manifest path.
extends GdUnitTestSuite

const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")

const MANIFEST_PATH: String = "res://data/manifest.json"
const DAMAGE_PATH: String = "res://data/combat/damage_params.json"
const DAMAGE_SCHEMA_PATH: String = "res://data/schemas/damage_params.schema.json"

var data_manager
var _file_backups: Dictionary = {}


func before_test() -> void:
	_backup_files([MANIFEST_PATH, DAMAGE_PATH, DAMAGE_SCHEMA_PATH])
	_remove_file(DAMAGE_SCHEMA_PATH)
	data_manager = DATA_MANAGER_SCRIPT.new()


func after_test() -> void:
	if is_instance_valid(data_manager):
		if data_manager.get_parent() != null:
			data_manager.get_parent().remove_child(data_manager)
		data_manager.free()
	data_manager = null
	_restore_files()


func test_valid_manifest_enters_ready_state() -> void:
	_create_valid_manifest()
	_create_valid_domain_file()

	add_child(data_manager)

	assert_int(data_manager.get_state()).is_equal(data_manager.State.READY)
	var entry: Variant = data_manager.get_entry(&"damage_params", &"cat_claw")
	assert_that(entry).is_not_null()
	assert_bool(entry is Dictionary).is_true()


func test_missing_manifest_enters_error_state() -> void:
	_remove_file(MANIFEST_PATH)

	add_child(data_manager)

	assert_int(data_manager.get_state()).is_equal(data_manager.State.ERROR)
	assert_that(data_manager.get_entry(&"damage_params", &"cat_claw")).is_null()


func test_corrupt_manifest_enters_error_state() -> void:
	_write_file(MANIFEST_PATH, "{this is not valid json")

	add_child(data_manager)

	assert_int(data_manager.get_state()).is_equal(data_manager.State.ERROR)
	assert_that(data_manager.get_entry(&"damage_params", &"cat_claw")).is_null()


func test_get_entry_returns_null_in_non_ready_state() -> void:
	_remove_file(MANIFEST_PATH)

	add_child(data_manager)

	assert_int(data_manager.get_state()).is_equal(data_manager.State.ERROR)
	assert_that(data_manager.get_entry(&"damage_params", &"cat_claw")).is_null()


func test_retry_when_manifest_fixed_transitions_to_ready() -> void:
	_remove_file(MANIFEST_PATH)
	add_child(data_manager)
	assert_int(data_manager.get_state()).is_equal(data_manager.State.ERROR)

	_create_valid_manifest()
	_create_valid_domain_file()
	data_manager.retry()

	assert_int(data_manager.get_state()).is_equal(data_manager.State.READY)
	assert_that(data_manager.get_entry(&"damage_params", &"cat_claw")).is_not_null()


func test_retry_in_ready_state_is_noop() -> void:
	_create_valid_manifest()
	_create_valid_domain_file()
	add_child(data_manager)
	assert_int(data_manager.get_state()).is_equal(data_manager.State.READY)

	data_manager.retry()

	assert_int(data_manager.get_state()).is_equal(data_manager.State.READY)


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
