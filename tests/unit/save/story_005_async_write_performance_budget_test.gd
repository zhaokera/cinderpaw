## Story 005: Async write performance budget.
extends GdUnitTestSuite

const SAVE_SYSTEM_PATH: String = "res://src/feature/save_system.gd"
const TEST_SAVE_DIR: String = "user://cinderpaw_save_system_story005/"
const BUDGET_MSEC: float = 100.0

var save_system: Node


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


func after_test() -> void:
	if is_instance_valid(save_system):
		if save_system.has_method("flush_pending_save_write"):
			save_system.call("flush_pending_save_write", 500)
		if save_system.get_parent() != null:
			save_system.get_parent().remove_child(save_system)
		save_system.free()
	save_system = null
	_cleanup_test_save_dir()


func test_async_manual_save_dispatches_under_budget_and_completes_on_process_poll() -> void:
	if not _assert_async_api_available():
		return
	save_system.call("set_async_write_enabled", true)
	var written_slots: Array[int] = []
	save_system.connect("on_save_written", func(slot: int) -> void:
		written_slots.append(slot)
	)

	assert_bool(bool(save_system.call("manual_save", 1, _build_player_state(), {}, {}))).is_true()
	assert_float(float(save_system.call("get_last_save_dispatch_duration_msec"))).is_less(BUDGET_MSEC)
	assert_bool(bool(save_system.call("is_save_write_pending"))).is_true()

	await _wait_for_save_idle()

	assert_bool(bool(save_system.call("is_save_write_pending"))).is_false()
	assert_array(written_slots).is_equal([1])
	assert_bool(FileAccess.file_exists(_slot_path(1))).is_true()
	var saved: Dictionary = _read_json(_slot_path(1))
	assert_str(String(saved["player_state"]["current_weapon"])).is_equal("long_tail")
	assert_int(int(saved["player_state"]["payload_size"])).is_equal(32768)


func test_async_write_rejects_second_save_until_first_completion_is_polled() -> void:
	if not _assert_async_api_available():
		return
	save_system.call("set_async_write_enabled", true)

	assert_bool(bool(save_system.call("manual_save", 1, _build_player_state(), {}, {}))).is_true()
	assert_bool(bool(save_system.call("is_save_write_pending"))).is_true()
	assert_bool(bool(save_system.call("manual_save", 2, {"current_hp": 1}, {}, {}))).is_false()

	await _wait_for_save_idle()

	assert_bool(FileAccess.file_exists(_slot_path(1))).is_true()
	assert_bool(FileAccess.file_exists(_slot_path(2))).is_false()


func test_async_completion_preserves_backup_for_existing_slot() -> void:
	if not _assert_async_api_available():
		return
	save_system.call("set_async_write_enabled", false)
	assert_bool(bool(save_system.call("manual_save", 1, {"current_hp": 100}, {}, {}))).is_true()

	save_system.call("set_async_write_enabled", true)
	assert_bool(bool(save_system.call("manual_save", 1, {"current_hp": 25}, {}, {}))).is_true()
	await _wait_for_save_idle()

	var backup: Dictionary = _read_json(_backup_path(1))
	var saved: Dictionary = _read_json(_slot_path(1))
	assert_int(int(backup["player_state"]["current_hp"])).is_equal(100)
	assert_int(int(saved["player_state"]["current_hp"])).is_equal(25)


func test_sync_fallback_writes_immediately_when_async_disabled() -> void:
	if not _assert_async_api_available():
		return
	save_system.call("set_async_write_enabled", false)
	var written_slots: Array[int] = []
	save_system.connect("on_save_written", func(slot: int) -> void:
		written_slots.append(slot)
	)

	assert_bool(bool(save_system.call("manual_save", 1, {"current_hp": 80}, {}, {}))).is_true()

	assert_bool(bool(save_system.call("is_save_write_pending"))).is_false()
	assert_bool(FileAccess.file_exists(_slot_path(1))).is_true()
	assert_array(written_slots).is_equal([1])


func test_async_write_failure_clears_pending_and_emits_failure_signal() -> void:
	if not _assert_async_api_available():
		return
	var blocker_path: String = TEST_SAVE_DIR.path_join("not_a_directory")
	_write_file(blocker_path, "blocks directory creation")
	save_system.call("configure_save_directory", blocker_path)
	save_system.call("set_async_write_enabled", true)
	var written_slots: Array[int] = []
	var failures: Array[String] = []
	save_system.connect("on_save_written", func(slot: int) -> void:
		written_slots.append(slot)
	)
	save_system.connect("on_save_write_failed", func(slot: int, reason: String) -> void:
		failures.append("%d:%s" % [slot, reason])
	)

	assert_bool(bool(save_system.call("manual_save", 1, {"current_hp": 80}, {}, {}))).is_true()
	await _wait_for_save_idle()

	assert_bool(bool(save_system.call("is_save_write_pending"))).is_false()
	assert_array(written_slots).is_empty()
	assert_int(failures.size()).is_equal(1)
	assert_bool(failures[0].begins_with("1:")).is_true()


func _assert_async_api_available() -> bool:
	assert_bool(save_system != null).is_true()
	if save_system == null:
		return false
	var required_methods: Array[String] = [
		"set_async_write_enabled",
		"is_save_write_pending",
		"get_last_save_dispatch_duration_msec",
		"flush_pending_save_write",
	]
	for method_name: String in required_methods:
		assert_bool(save_system.has_method(method_name)).is_true()
		if not save_system.has_method(method_name):
			return false
	assert_bool(save_system.has_signal("on_save_write_failed")).is_true()
	return save_system.has_signal("on_save_write_failed")


func _wait_for_save_idle(max_frames: int = 120) -> void:
	for _frame: int in range(max_frames):
		if not bool(save_system.call("is_save_write_pending")):
			return
		await get_tree().process_frame
	assert_bool(bool(save_system.call("is_save_write_pending"))).is_false()


func _build_player_state() -> Dictionary:
	return {
		"current_hp": 64,
		"current_weapon": "long_tail",
		"payload_size": 32768,
		"journal": _repeat_text("cinderpaw-save-budget", 32768),
	}


func _repeat_text(seed: String, min_length: int) -> String:
	var text: String = ""
	while text.length() < min_length:
		text += seed
	return text.substr(0, min_length)


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


func _backup_path(slot: int) -> String:
	return "%sslot_%d.json.bak" % [TEST_SAVE_DIR, slot]


func _cleanup_test_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(TEST_SAVE_DIR):
		return
	for file_name: String in DirAccess.get_files_at(TEST_SAVE_DIR):
		DirAccess.remove_absolute(TEST_SAVE_DIR.path_join(file_name))
	DirAccess.remove_absolute(TEST_SAVE_DIR)
