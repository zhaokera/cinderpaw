## Story 003: DomainCache + core query API + lazy loading.
extends GdUnitTestSuite

const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")

const MANIFEST_PATH: String = "res://data/manifest.json"
const DAMAGE_PATH: String = "res://data/combat/damage_params.json"
const ENEMY_STATS_PATH: String = "res://data/combat/enemy_stats.json"
const INPUT_CONFIG_PATH: String = "res://data/input/input_config.json"
const DAMAGE_SCHEMA_PATH: String = "res://data/schemas/damage_params.schema.json"

var data_manager
var _file_backups: Dictionary = {}


func before_test() -> void:
	_backup_files([
		MANIFEST_PATH,
		DAMAGE_PATH,
		ENEMY_STATS_PATH,
		INPUT_CONFIG_PATH,
		DAMAGE_SCHEMA_PATH,
	])
	_remove_file(DAMAGE_SCHEMA_PATH)
	_create_manifest_with_lazy_domains()
	_create_damage_params()
	_create_enemy_stats()
	_create_input_config()
	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)


func after_test() -> void:
	if is_instance_valid(data_manager):
		if data_manager.get_parent() != null:
			data_manager.get_parent().remove_child(data_manager)
		data_manager.free()
	data_manager = null
	_restore_files()


func test_get_entry_returns_loaded_domain_entry() -> void:
	var entry: Variant = data_manager.get_entry(&"damage_params", &"cat_claw")

	assert_that(entry).is_not_null()
	assert_bool(entry is Dictionary).is_true()
	assert_float(entry["weapon_base"]).is_equal(10.0)


func test_get_entry_returns_null_for_missing_entry() -> void:
	assert_that(data_manager.get_entry(&"damage_params", &"missing")).is_null()


func test_get_entry_returns_null_for_missing_domain() -> void:
	assert_that(data_manager.get_entry(&"missing_domain", &"cat_claw")).is_null()


func test_preload_false_domain_lazy_loads_on_first_query() -> void:
	assert_bool(data_manager.has_domain(&"enemy_stats")).is_false()

	var entry: Variant = data_manager.get_entry(&"enemy_stats", &"mechanical_rat")

	assert_that(entry).is_not_null()
	assert_bool(entry is Dictionary).is_true()
	assert_bool(data_manager.has_domain(&"enemy_stats")).is_true()
	assert_float(entry["max_hp"]).is_equal(3.0)


func test_get_domain_returns_entries_and_lazy_loads_registered_domain() -> void:
	assert_bool(data_manager.has_domain(&"enemy_stats")).is_false()
	if not data_manager.has_method("get_domain"):
		assert_bool(false).override_failure_message("DataManager.get_domain() must exist").is_true()
		return

	var entries: Dictionary = data_manager.get_domain(&"enemy_stats")

	assert_dict(entries).is_not_empty()
	assert_bool(data_manager.has_domain(&"enemy_stats")).is_true()
	assert_dict(entries).contains_keys("mechanical_rat")
	assert_float(entries["mechanical_rat"]["max_hp"]).is_equal(3.0)


func test_has_entry_uses_lazy_loading_and_reports_missing_entries() -> void:
	assert_bool(data_manager.has_domain(&"enemy_stats")).is_false()

	assert_bool(data_manager.has_entry(&"enemy_stats", &"mechanical_rat")).is_true()
	assert_bool(data_manager.has_entry(&"enemy_stats", &"missing_enemy")).is_false()
	assert_bool(data_manager.has_domain(&"enemy_stats")).is_true()


func test_load_input_config_returns_full_config_and_accepts_legacy_path_arg() -> void:
	var config: Dictionary = data_manager.load_input_config("res://data/input/input_config.json")

	assert_dict(config).is_not_empty()
	assert_dict(config).contains_keys("_meta", "entries")
	assert_dict(config["entries"]).contains_keys("jump", "attack")


func _create_manifest_with_lazy_domains() -> void:
	_write_file(MANIFEST_PATH, """{
	"_meta": {"version": "1.0", "domain": "manifest"},
	"domains": [
		{"name": "damage_params", "path": "combat/damage_params.json", "preload": true},
		{"name": "enemy_stats", "path": "combat/enemy_stats.json", "preload": false},
		{"name": "input_config", "path": "input/input_config.json", "preload": false}
	]
}""")


func _create_damage_params() -> void:
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


func _create_enemy_stats() -> void:
	_write_file(ENEMY_STATS_PATH, """{
	"_meta": {"version": "1.0", "domain": "enemy_stats"},
		"entries": {
			"mechanical_rat": {
				"max_hp": 3,
				"patrol_speed": 80,
				"attack_patterns": []
			}
		}
	}""")


func _create_input_config() -> void:
	_write_file(INPUT_CONFIG_PATH, """{
	"_meta": {"version": "1.0", "domain": "input_config"},
	"entries": {
		"jump": {"action": "jump", "buffer_frames": 6},
		"attack": {"action": "attack", "buffer_frames": 4}
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
