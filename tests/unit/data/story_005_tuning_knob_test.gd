## Story 005: TuningKnobRegistry + runtime tuning values.
extends GdUnitTestSuite

const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")

const MANIFEST_PATH: String = "res://data/manifest.json"
const TUNING_PATH: String = "res://data/tuning_knobs.json"
const TUNING_SCHEMA_PATH: String = "res://data/schemas/tuning_knobs.schema.json"

var data_manager
var _file_backups: Dictionary = {}
var _changed_knob_ids: Array[StringName] = []
var _changed_values: Array = []


func before_test() -> void:
	_backup_files([
		MANIFEST_PATH,
		TUNING_PATH,
		TUNING_SCHEMA_PATH,
	])
	_create_manifest_with_tuning_domain()
	_create_tuning_knobs({})
	_create_empty_tuning_schema()
	_changed_knob_ids.clear()
	_changed_values.clear()
	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)


func after_test() -> void:
	if is_instance_valid(data_manager):
		if data_manager.get_parent() != null:
			data_manager.get_parent().remove_child(data_manager)
		data_manager.free()
	data_manager = null
	_restore_files()
	_changed_knob_ids.clear()
	_changed_values.clear()


func test_registered_knob_returns_default_value() -> void:
	if not _register_input_buffer_knob():
		return

	assert_int(_get_tuning(&"input.buffer_window_ms", 0)).is_equal(150)


func test_set_tuning_in_range_updates_value_and_emits_signal() -> void:
	if not _connect_knob_changed() or not _register_input_buffer_knob():
		return

	assert_bool(_set_tuning(&"input.buffer_window_ms", 180)).is_true()

	assert_int(_get_tuning(&"input.buffer_window_ms", 0)).is_equal(180)
	assert_array(_changed_knob_ids).contains(&"input.buffer_window_ms")
	assert_array(_changed_values).contains(180)


func test_set_tuning_above_max_clamps_to_max() -> void:
	if not _register_input_buffer_knob():
		return

	assert_bool(_set_tuning(&"input.buffer_window_ms", 999)).is_true()

	assert_int(_get_tuning(&"input.buffer_window_ms", 0)).is_equal(250)


func test_set_tuning_below_min_clamps_to_min() -> void:
	if not _register_input_buffer_knob():
		return

	assert_bool(_set_tuning(&"input.buffer_window_ms", 10)).is_true()

	assert_int(_get_tuning(&"input.buffer_window_ms", 0)).is_equal(80)


func test_unregistered_knob_returns_fallback_value() -> void:
	if not data_manager.has_method("get_tuning"):
		assert_bool(false).override_failure_message("DataManager.get_tuning() must exist").is_true()
		return

	assert_int(data_manager.get_tuning(&"missing.knob", 42)).is_equal(42)


func test_json_hot_reload_updates_knob_value_and_emits_signal() -> void:
	if not _connect_knob_changed() or not _register_input_buffer_knob():
		return
	_create_tuning_knobs({"input.buffer_window_ms": {"value": 200}})
	if not data_manager.has_method("reload_domain"):
		assert_bool(false).override_failure_message("DataManager.reload_domain() must exist").is_true()
		return

	assert_bool(data_manager.reload_domain(&"tuning_knobs")).is_true()

	assert_int(_get_tuning(&"input.buffer_window_ms", 0)).is_equal(200)
	assert_array(_changed_knob_ids).contains(&"input.buffer_window_ms")
	assert_array(_changed_values).contains(200)


func _on_knob_changed(knob_id: StringName, new_value: Variant) -> void:
	_changed_knob_ids.append(knob_id)
	_changed_values.append(new_value)


func _connect_knob_changed() -> bool:
	if not data_manager.has_signal("on_knob_changed"):
		assert_bool(false).override_failure_message("DataManager.on_knob_changed signal must exist").is_true()
		return false
	data_manager.on_knob_changed.connect(_on_knob_changed)
	return true


func _register_input_buffer_knob() -> bool:
	if not data_manager.has_method("register_tuning"):
		assert_bool(false).override_failure_message("DataManager.register_tuning() must exist").is_true()
		return false
	data_manager.register_tuning(&"input.buffer_window_ms", &"int", 150, 80, 250, &"input")
	return true


func _set_tuning(knob_id: StringName, value: Variant) -> bool:
	if not data_manager.has_method("set_tuning"):
		assert_bool(false).override_failure_message("DataManager.set_tuning() must exist").is_true()
		return false
	return data_manager.set_tuning(knob_id, value)


func _get_tuning(knob_id: StringName, fallback: Variant) -> Variant:
	if not data_manager.has_method("get_tuning"):
		assert_bool(false).override_failure_message("DataManager.get_tuning() must exist").is_true()
		return fallback
	return data_manager.get_tuning(knob_id, fallback)


func _create_manifest_with_tuning_domain() -> void:
	_write_file(MANIFEST_PATH, """{
	"_meta": {"version": "1.0", "domain": "manifest"},
	"domains": [
		{"name": "tuning_knobs", "path": "tuning_knobs.json", "preload": true}
	]
}""")


func _create_tuning_knobs(entries: Dictionary) -> void:
	_write_file(TUNING_PATH, JSON.stringify({
		"_meta": {"version": "1.0", "domain": "tuning_knobs"},
		"entries": entries,
	}, "\t"))


func _create_empty_tuning_schema() -> void:
	_write_file(TUNING_SCHEMA_PATH, """{
	"entries": {}
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
