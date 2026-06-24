## Story 001: Save slots, JSON payloads, serializable registry, and backup fallback.
extends GdUnitTestSuite

const SAVE_SYSTEM_PATH: String = "res://src/feature/save_system.gd"
const TEST_SAVE_DIR: String = "user://cinderpaw_save_system_story001/"

var save_system: Node


class MockSerializable:
	extends RefCounted

	var key: StringName
	var payload: Dictionary
	var callbacks: Array[String]
	var last_deserialized: Dictionary = {}
	var last_version: int = -1

	func _init(p_key: StringName, p_payload: Dictionary, p_callbacks: Array[String]) -> void:
		key = p_key
		payload = p_payload.duplicate(true)
		callbacks = p_callbacks

	func serialize() -> Dictionary:
		callbacks.append("serialize:%s" % String(key))
		return payload.duplicate(true)

	func deserialize(data: Dictionary, version: int) -> void:
		callbacks.append("deserialize:%s" % String(key))
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
	assert_bool(save_system.has_method("configure_save_directory")).is_true()
	if save_system.has_method("configure_save_directory"):
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


func test_manual_save_rejects_autosave_slot_and_auto_save_writes_slot_zero() -> void:
	if save_system == null:
		return

	assert_bool(bool(save_system.call("manual_save", 0, {}, {}, {}))).is_false()
	assert_bool(bool(save_system.call("manual_save", -1, {}, {}, {}))).is_false()
	assert_bool(bool(save_system.call("manual_save", 4, {}, {}, {}))).is_false()
	assert_bool(bool(save_system.call("load_game", -1))).is_false()
	assert_bool(FileAccess.file_exists(_slot_path(0))).is_false()

	assert_bool(bool(save_system.call("auto_save", {"hp": 80}, {"boss": false}, {"hud_scale": 1.0}))).is_true()
	assert_bool(FileAccess.file_exists(_slot_path(0))).is_true()

	var saved: Dictionary = _read_json(_slot_path(0))
	assert_int(int(saved["_meta"]["slot"])).is_equal(0)
	assert_bool(bool(saved["_meta"]["is_auto"])).is_true()
	assert_int(int(saved["player_state"]["hp"])).is_equal(80)


func test_manual_save_writes_complete_json_payload_with_registered_systems() -> void:
	if save_system == null:
		return
	var callbacks: Array[String] = []
	var weapon := MockSerializable.new(&"weapon", {
		"current_weapon_index": 2,
		"weapon_levels": {"cat_claw": 2},
	}, callbacks)

	assert_bool(bool(save_system.call("register_serializable", weapon, &"weapon"))).is_true()
	assert_bool(bool(save_system.call("manual_save", 1, {
		"position": {"x": 32, "y": 64},
	}, {
		"defeated_bosses": ["shadow_beast"],
	}, {
		"hud_scale": 1.5,
	}))).is_true()

	var saved: Dictionary = _read_json(_slot_path(1))
	assert_bool(saved.has("_meta")).is_true()
	assert_bool(saved.has("player_state")).is_true()
	assert_bool(saved.has("world_state")).is_true()
	assert_bool(saved.has("settings")).is_true()
	assert_bool(saved.has("systems")).is_true()
	assert_int(int(saved["_meta"]["version"])).is_equal(1)
	assert_str(String(saved["systems"]["weapon"]["weapon_levels"].keys()[0])).is_equal("cat_claw")
	assert_array(callbacks).is_equal(["serialize:weapon"])


func test_registered_systems_deserialize_in_registration_order_and_duplicate_keys_reject() -> void:
	if save_system == null:
		return
	var callbacks: Array[String] = []
	var health := MockSerializable.new(&"health", {"current_hp": 70}, callbacks)
	var weapon := MockSerializable.new(&"weapon", {"current_weapon_index": 1}, callbacks)

	assert_bool(bool(save_system.call("register_serializable", health, &"health"))).is_true()
	assert_bool(bool(save_system.call("register_serializable", weapon, &"weapon"))).is_true()
	assert_bool(bool(save_system.call("register_serializable", weapon, &"weapon"))).is_false()
	assert_bool(bool(save_system.call("manual_save", 1, {}, {}, {}))).is_true()

	health.last_deserialized.clear()
	weapon.last_deserialized.clear()
	callbacks.clear()
	assert_bool(bool(save_system.call("load_game", 1))).is_true()

	assert_array(callbacks).is_equal(["deserialize:health", "deserialize:weapon"])
	assert_int(int(health.last_deserialized["current_hp"])).is_equal(70)
	assert_int(int(weapon.last_deserialized["current_weapon_index"])).is_equal(1)
	assert_int(health.last_version).is_equal(1)
	assert_int(weapon.last_version).is_equal(1)


func test_save_over_existing_slot_creates_backup_and_corrupt_main_loads_backup() -> void:
	if save_system == null:
		return
	assert_bool(bool(save_system.call("manual_save", 1, {"hp": 100}, {}, {}))).is_true()
	var first_save: Dictionary = _read_json(_slot_path(1))

	assert_bool(bool(save_system.call("manual_save", 1, {"hp": 25}, {}, {}))).is_true()
	assert_bool(FileAccess.file_exists(_backup_path(1))).is_true()
	var backup: Dictionary = _read_json(_backup_path(1))
	assert_int(int(backup["player_state"]["hp"])).is_equal(100)

	_write_file(_slot_path(1), "{not valid json")

	assert_bool(bool(save_system.call("load_game", 1))).is_true()
	assert_bool(bool(save_system.call("was_last_load_from_backup"))).is_true()
	var loaded: Dictionary = Dictionary(save_system.call("get_last_loaded_data"))
	assert_int(int(loaded["player_state"]["hp"])).is_equal(int(first_save["player_state"]["hp"]))


func _read_json(path: String) -> Dictionary:
	var content: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(content)
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


func _backup_path(slot: int) -> String:
	return "%sslot_%d.json.bak" % [TEST_SAVE_DIR, slot]


func _cleanup_test_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(TEST_SAVE_DIR):
		return
	for file_name: String in DirAccess.get_files_at(TEST_SAVE_DIR):
		DirAccess.remove_absolute(TEST_SAVE_DIR.path_join(file_name))
	DirAccess.remove_absolute(TEST_SAVE_DIR)
