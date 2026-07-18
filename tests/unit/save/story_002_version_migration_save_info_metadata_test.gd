## Story 002: SaveInfo metadata and version migration pipeline.
extends GdUnitTestSuite

const SAVE_SYSTEM_PATH: String = "res://src/feature/save_system.gd"
const TEST_SAVE_DIR: String = "user://cinderpaw_save_system_story002/"

var save_system: Node


class MockSerializable:
	extends RefCounted

	var last_deserialized: Dictionary = {}
	var last_version: int = -1

	func serialize() -> Dictionary:
		return {"field": "current"}

	func deserialize(data: Dictionary, version: int) -> void:
		last_deserialized = data.duplicate(true)
		last_version = version


func before_test() -> void:
	_cleanup_test_save_dir()
	var script: Script = load(SAVE_SYSTEM_PATH)
	assert_that(script).is_not_null()
	assert_bool(script != null and script.can_instantiate()).is_true()
	if script == null or not script.can_instantiate():
		return
	save_system = script.new()
	add_child(save_system)
	save_system.call("configure_save_directory", TEST_SAVE_DIR)
	if save_system.has_method("set_async_write_enabled"):
		save_system.call("set_async_write_enabled", false)


func after_test() -> void:
	if is_instance_valid(save_system):
		if save_system.get_parent() != null:
			save_system.get_parent().remove_child(save_system)
		save_system.free()
	save_system = null
	_cleanup_test_save_dir()


func test_get_save_info_returns_empty_and_populated_slot_metadata() -> void:
	if save_system == null:
		return

	var missing_info: RefCounted = save_system.call("get_save_info", 1)
	assert_that(missing_info).is_not_null()
	assert_int(int(missing_info.get("slot"))).is_equal(1)
	assert_bool(bool(missing_info.get("exists"))).is_false()
	assert_bool(bool(missing_info.get("is_auto"))).is_false()

	var autosave_info: RefCounted = save_system.call("get_save_info", 0)
	assert_bool(bool(autosave_info.get("is_auto"))).is_true()

	assert_bool(bool(save_system.call("manual_save", 1, {
		"current_hp": 42,
		"max_hp": 100,
		"current_weapon": "cat_claw",
		"currency": 17,
		"scene_id": "hub_ruins",
	}, {}, {}))).is_true()

	var info: RefCounted = save_system.call("get_save_info", 1)
	assert_bool(bool(info.get("exists"))).is_true()
	assert_int(int(info.get("slot"))).is_equal(1)
	assert_bool(bool(info.get("is_auto"))).is_false()
	assert_str(String(info.get("timestamp"))).is_not_empty()
	assert_float(float(info.get("play_time_sec"))).is_equal(0.0)
	assert_str(String(info.get("save_point_name"))).is_equal("Manual Save")
	assert_int(int(info.get("version"))).is_equal(1)
	assert_int(int(info.get("file_size_bytes"))).is_greater(0)
	var summary: Dictionary = Dictionary(info.get("summary"))
	assert_int(int(summary["current_hp"])).is_equal(42)
	assert_int(int(summary["max_hp"])).is_equal(100)
	assert_str(String(summary["current_weapon"])).is_equal("cat_claw")
	assert_int(int(summary["currency"])).is_equal(17)
	assert_str(String(summary["scene_id"])).is_equal("hub_ruins")


func test_peek_save_data_returns_snapshot_without_deserializing_runtime_systems() -> void:
	if save_system == null:
		return
	var system := MockSerializable.new()
	assert_bool(bool(save_system.call("register_serializable", system, &"combat"))).is_true()
	assert_bool(bool(save_system.call("manual_save", 1, {
		"current_hp": 64,
		"scene_id": "main",
	}, {
		"last_savepoint": {
			"scene_id": "main",
			"spawn_point": "scrap_roost",
		},
	}, {}))).is_true()

	assert_bool(save_system.has_method("peek_save_data")).is_true()
	var peeked: Dictionary = Dictionary(save_system.call("peek_save_data", 1))
	assert_int(int(peeked["player_state"]["current_hp"])).is_equal(64)
	assert_str(String(peeked["world_state"]["last_savepoint"]["spawn_point"])).is_equal("scrap_roost")
	assert_dict(system.last_deserialized).is_empty()
	assert_int(system.last_version).is_equal(-1)
	assert_dict(Dictionary(save_system.call("get_last_loaded_data"))).is_empty()


func test_load_game_migrates_older_save_before_deserializing_and_writes_current_version() -> void:
	if save_system == null:
		return
	var system := MockSerializable.new()
	assert_bool(bool(save_system.call("register_serializable", system, &"combat"))).is_true()
	assert_bool(bool(save_system.call("register_migration", 0, _migrate_v0_to_v1))).is_true()

	_write_json(_slot_path(1), {
		"_meta": {
			"version": 0,
			"timestamp": "2026-06-24T00:00:00Z",
			"play_time_sec": 12.5,
			"slot": 1,
			"is_auto": false,
			"save_point_name": "Old Nest",
			"summary": {},
		},
		"player_state": {},
		"world_state": {},
		"settings": {},
		"systems": {
			"combat": {
				"cat_energy": 30,
			},
		},
	})

	assert_bool(bool(save_system.call("load_game", 1))).is_true()
	assert_int(system.last_version).is_equal(0)
	assert_bool(bool(system.last_deserialized["focus_mode_active"])).is_false()
	assert_int(int(system.last_deserialized["cat_energy"])).is_equal(30)

	var loaded: Dictionary = Dictionary(save_system.call("get_last_loaded_data"))
	assert_int(int(loaded["_meta"]["version"])).is_equal(1)
	assert_bool(bool(loaded["systems"]["combat"]["focus_mode_active"])).is_false()
	var rewritten: Dictionary = _read_json(_slot_path(1))
	assert_int(int(rewritten["_meta"]["version"])).is_equal(1)


func test_missing_migration_and_future_version_fail_without_loaded_data() -> void:
	if save_system == null:
		return

	_write_json(_slot_path(1), _save_payload_for_version(0))
	assert_bool(bool(save_system.call("load_game", 1))).is_false()
	assert_dict(Dictionary(save_system.call("get_last_loaded_data"))).is_empty()

	_write_json(_slot_path(1), _save_payload_for_version(99))
	assert_bool(bool(save_system.call("load_game", 1))).is_false()
	assert_dict(Dictionary(save_system.call("get_last_loaded_data"))).is_empty()


func _migrate_v0_to_v1(data: Dictionary) -> Dictionary:
	var migrated: Dictionary = data.duplicate(true)
	migrated["_meta"]["version"] = 1
	if migrated.has("systems") and migrated["systems"] is Dictionary:
		var systems: Dictionary = Dictionary(migrated["systems"])
		if systems.has("combat") and systems["combat"] is Dictionary:
			var combat: Dictionary = Dictionary(systems["combat"])
			combat["focus_mode_active"] = false
			systems["combat"] = combat
			migrated["systems"] = systems
	return migrated


func _save_payload_for_version(version: int) -> Dictionary:
	return {
		"_meta": {
			"version": version,
			"timestamp": "2026-06-24T00:00:00Z",
			"play_time_sec": 0.0,
			"slot": 1,
			"is_auto": false,
			"save_point_name": "Version Test",
			"summary": {},
		},
		"player_state": {},
		"world_state": {},
		"settings": {},
		"systems": {},
	}


func _write_json(path: String, data: Dictionary) -> void:
	_write_file(path, JSON.stringify(data, "\t"))


func _read_json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	assert_bool(parsed is Dictionary).is_true()
	return Dictionary(parsed)


func _write_file(path: String, content: String) -> void:
	var dir_path: String = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	assert_that(file).is_not_null()
	file.store_string(content)
	file.close()


func _slot_path(slot: int) -> String:
	return "%sslot_%d.json" % [TEST_SAVE_DIR, slot]


func _cleanup_test_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(TEST_SAVE_DIR):
		return
	for file_name: String in DirAccess.get_files_at(TEST_SAVE_DIR):
		DirAccess.remove_absolute(TEST_SAVE_DIR.path_join(file_name))
	DirAccess.remove_absolute(TEST_SAVE_DIR)
