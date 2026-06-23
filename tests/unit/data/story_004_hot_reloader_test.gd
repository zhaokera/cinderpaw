## Story 004: HotReloader + debug-only polling.
extends GdUnitTestSuite

const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")

const MANIFEST_PATH: String = "res://data/manifest.json"
const DAMAGE_PATH: String = "res://data/combat/damage_params.json"
const ENEMY_STATS_PATH: String = "res://data/combat/enemy_stats.json"
const DAMAGE_SCHEMA_PATH: String = "res://data/schemas/damage_params.schema.json"
const ENEMY_SCHEMA_PATH: String = "res://data/schemas/enemy_stats.schema.json"

var data_manager
var _file_backups: Dictionary = {}
var _changed_domains: Array[StringName] = []


func before_test() -> void:
	_backup_files([
		MANIFEST_PATH,
		DAMAGE_PATH,
		ENEMY_STATS_PATH,
		DAMAGE_SCHEMA_PATH,
		ENEMY_SCHEMA_PATH,
	])
	_create_manifest_with_two_preload_domains()
	_create_damage_params(10)
	_create_enemy_stats(3)
	_create_damage_schema()
	_create_enemy_schema()
	_changed_domains.clear()
	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)


func after_test() -> void:
	if is_instance_valid(data_manager):
		if data_manager.get_parent() != null:
			data_manager.get_parent().remove_child(data_manager)
		data_manager.free()
	data_manager = null
	_restore_files()
	_changed_domains.clear()


func test_debug_file_change_reloads_emits_signal_and_returns_new_entry() -> void:
	if not _connect_domain_changed():
		return
	if not data_manager.has_method("_poll_hot_reload"):
		assert_bool(false).override_failure_message("DataManager._poll_hot_reload() must exist").is_true()
		return
	_create_damage_params(20)
	data_manager._domain_modified_times[&"damage_params"] = -1

	data_manager._poll_hot_reload()

	assert_array(_changed_domains).contains(&"damage_params")
	var entry: Variant = data_manager.get_entry(&"damage_params", &"cat_claw")
	assert_that(entry).is_not_null()
	assert_float(entry["weapon_base"]).is_equal(20.0)


func test_hot_reload_validation_failure_preserves_cache_and_skips_signal() -> void:
	if not _connect_domain_changed():
		return
	_write_file(DAMAGE_PATH, """{
	"_meta": {"version": "1.0", "domain": "damage_params"},
	"entries": {
		"cat_claw": {
			"weapon_base": "invalid",
			"scaling_factor": 1.2,
			"crit_perfect_multiplier": 2.5,
			"crit_good_multiplier": 1.8
		}
	}
}""")

	var did_reload: bool = _reload_domain(&"damage_params")

	assert_bool(did_reload).is_false()
	assert_int(_changed_domains.size()).is_equal(0)
	var entry: Variant = data_manager.get_entry(&"damage_params", &"cat_claw")
	assert_that(entry).is_not_null()
	assert_float(entry["weapon_base"]).is_equal(10.0)


func test_debug_hot_reload_timer_runs_at_one_second_interval() -> void:
	if not _configure_hot_reloader(true):
		return

	var timer: Timer = data_manager._hot_reload_timer
	assert_that(timer).is_not_null()
	assert_float(timer.wait_time).is_equal(1.0)
	assert_bool(timer.is_stopped()).is_false()


func test_release_hot_reload_timer_is_not_created_or_running() -> void:
	if not _configure_hot_reloader(false):
		return

	var timer: Timer = data_manager._hot_reload_timer
	assert_bool(timer == null or timer.is_stopped()).is_true()


func test_same_polling_cycle_reloads_multiple_files_and_emits_each_domain_once() -> void:
	if not _connect_domain_changed():
		return
	_create_damage_params(21)
	_create_enemy_stats(7)

	if not data_manager.has_method("_reload_changed_domains"):
		assert_bool(false).override_failure_message("DataManager._reload_changed_domains() must exist").is_true()
		return
	data_manager._reload_changed_domains([&"damage_params", &"enemy_stats"])

	assert_int(_changed_domains.size()).is_equal(2)
	assert_array(_changed_domains).contains(&"damage_params", &"enemy_stats")
	var damage_entry: Variant = data_manager.get_entry(&"damage_params", &"cat_claw")
	var enemy_entry: Variant = data_manager.get_entry(&"enemy_stats", &"mechanical_rat")
	assert_float(damage_entry["weapon_base"]).is_equal(21.0)
	assert_float(enemy_entry["max_hp"]).is_equal(7.0)


func test_deleted_domain_file_enters_fallback_without_affecting_other_domains() -> void:
	if not _connect_domain_changed():
		return
	_remove_file(DAMAGE_PATH)

	var did_reload: bool = _reload_domain(&"damage_params")

	assert_bool(did_reload).is_true()
	assert_array(_changed_domains).contains(&"damage_params")
	assert_bool(data_manager.has_domain(&"damage_params")).is_true()
	if not data_manager.has_method("is_domain_fallback"):
		assert_bool(false).override_failure_message("DataManager.is_domain_fallback() must exist").is_true()
		return
	assert_bool(data_manager.is_domain_fallback(&"damage_params")).is_true()
	assert_that(data_manager.get_entry(&"damage_params", &"cat_claw")).is_null()
	var enemy_entry: Variant = data_manager.get_entry(&"enemy_stats", &"mechanical_rat")
	assert_that(enemy_entry).is_not_null()
	assert_float(enemy_entry["max_hp"]).is_equal(3.0)


func _on_domain_changed(domain_name: StringName) -> void:
	_changed_domains.append(domain_name)


func _connect_domain_changed() -> bool:
	if not data_manager.has_signal("on_domain_changed"):
		assert_bool(false).override_failure_message("DataManager.on_domain_changed signal must exist").is_true()
		return false
	data_manager.on_domain_changed.connect(_on_domain_changed)
	return true


func _reload_domain(domain_name: StringName) -> bool:
	if not data_manager.has_method("reload_domain"):
		assert_bool(false).override_failure_message("DataManager.reload_domain() must exist").is_true()
		return false
	return data_manager.reload_domain(domain_name)


func _configure_hot_reloader(is_debug_build: bool) -> bool:
	if not data_manager.has_method("_configure_hot_reloader"):
		assert_bool(false).override_failure_message("DataManager._configure_hot_reloader() must exist").is_true()
		return false
	data_manager._configure_hot_reloader(is_debug_build)
	return true


func _create_manifest_with_two_preload_domains() -> void:
	_write_file(MANIFEST_PATH, """{
	"_meta": {"version": "1.0", "domain": "manifest"},
	"domains": [
		{"name": "damage_params", "path": "combat/damage_params.json", "preload": true},
		{"name": "enemy_stats", "path": "combat/enemy_stats.json", "preload": true}
	]
}""")


func _create_damage_params(weapon_base: int) -> void:
	_write_file(DAMAGE_PATH, """{
	"_meta": {"version": "1.0", "domain": "damage_params"},
	"entries": {
		"cat_claw": {
			"weapon_base": %d,
			"scaling_factor": 1.2,
			"crit_perfect_multiplier": 2.5,
			"crit_good_multiplier": 1.8
		}
	}
}""" % weapon_base)


func _create_enemy_stats(max_hp: int) -> void:
	_write_file(ENEMY_STATS_PATH, """{
	"_meta": {"version": "1.0", "domain": "enemy_stats"},
	"entries": {
		"mechanical_rat": {
			"max_hp": %d,
			"patrol_speed": 80
		}
	}
}""" % max_hp)


func _create_damage_schema() -> void:
	_write_file(DAMAGE_SCHEMA_PATH, """{
	"entries": {
		"cat_claw": {
			"required": ["weapon_base", "scaling_factor", "crit_perfect_multiplier", "crit_good_multiplier"],
			"fields": {
				"weapon_base": {"type": "int", "min": 0, "max": 999},
				"scaling_factor": {"type": "float", "min": 0.0, "max": 10.0},
				"crit_perfect_multiplier": {"type": "float", "min": 1.0, "max": 10.0},
				"crit_good_multiplier": {"type": "float", "min": 1.0, "max": 10.0}
			}
		}
	}
}""")


func _create_enemy_schema() -> void:
	_write_file(ENEMY_SCHEMA_PATH, """{
	"entries": {
		"mechanical_rat": {
			"required": ["max_hp", "patrol_speed"],
			"fields": {
				"max_hp": {"type": "int", "min": 0, "max": 999},
				"patrol_speed": {"type": "int", "min": 0, "max": 999}
			}
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
