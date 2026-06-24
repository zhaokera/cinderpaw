## Story 003: Autosave trigger adapter coverage.
extends GdUnitTestSuite

const SAVE_SYSTEM_PATH: String = "res://src/feature/save_system.gd"
const SAVE_TRIGGER_ADAPTER_PATH: String = "res://src/feature/save_trigger_adapter.gd"
const TEST_SAVE_DIR: String = "user://cinderpaw_save_system_story003/"

var save_system: Node
var adapter: Node


class MockSaveSource:
	extends Node

	signal body_entered(body: Node)
	signal on_boss_defeated(boss_id: StringName)
	signal on_key_event_completed(event_id: StringName)
	signal on_scene_change_requested(old_scene: StringName, new_scene: StringName)

	func emit_savepoint() -> void:
		var body := Node.new()
		body_entered.emit(body)
		body.free()

	func emit_boss_defeat() -> void:
		on_boss_defeated.emit(&"rat_king")

	func emit_key_event() -> void:
		on_key_event_completed.emit(&"ability_wall_climb")

	func emit_scene_change() -> void:
		on_scene_change_requested.emit(&"hub", &"rat_den")


class FailingSaveSystem:
	extends RefCounted

	var auto_save_calls: int = 0
	var manual_slot_calls: Array[int] = []

	func auto_save(_player_state: Dictionary = {}, _world_state: Dictionary = {}, _settings: Dictionary = {}) -> bool:
		auto_save_calls += 1
		return false

	func manual_save(slot: int, _player_state: Dictionary = {}, _world_state: Dictionary = {}, _settings: Dictionary = {}) -> bool:
		manual_slot_calls.append(slot)
		return false


func before_test() -> void:
	_cleanup_test_save_dir()
	var save_script: Script = load(SAVE_SYSTEM_PATH)
	var adapter_script: Script = load(SAVE_TRIGGER_ADAPTER_PATH)
	assert_that(save_script).is_not_null()
	assert_that(adapter_script).is_not_null()
	if save_script == null or adapter_script == null:
		return
	save_system = save_script.new()
	adapter = adapter_script.new()
	add_child(save_system)
	add_child(adapter)
	save_system.call("configure_save_directory", TEST_SAVE_DIR)
	adapter.call("configure", save_system, _build_snapshot)


func after_test() -> void:
	if is_instance_valid(adapter):
		if adapter.get_parent() != null:
			adapter.get_parent().remove_child(adapter)
		adapter.free()
	adapter = null
	if is_instance_valid(save_system):
		if save_system.get_parent() != null:
			save_system.get_parent().remove_child(save_system)
		save_system.free()
	save_system = null
	_cleanup_test_save_dir()


func test_savepoint_signal_writes_slot_zero_with_snapshot_and_context() -> void:
	if adapter == null or save_system == null:
		return
	var source := MockSaveSource.new()
	add_child(source)
	assert_bool(bool(adapter.call("bind_savepoint", source, {
		"save_point_name": "Cat Nest",
	}))).is_true()

	source.emit_savepoint()

	assert_bool(bool(save_system.call("has_save", 0))).is_true()
	assert_bool(bool(save_system.call("has_save", 1))).is_false()
	var saved: Dictionary = _read_json(_slot_path(0))
	assert_int(int(saved["player_state"]["current_hp"])).is_equal(64)
	assert_str(String(saved["world_state"]["autosave_reason"])).is_equal("savepoint")
	assert_str(String(saved["world_state"]["autosave_context"]["save_point_name"])).is_equal("Cat Nest")
	assert_bool(bool(saved["settings"]["colorblind_mode"] == "none")).is_true()
	source.queue_free()


func test_boss_key_and_scene_triggers_share_autosave_path_and_emit_reasons() -> void:
	if adapter == null or save_system == null:
		return
	var source := MockSaveSource.new()
	add_child(source)
	var reasons: Array[StringName] = []
	adapter.connect("on_autosave_triggered", func(reason: StringName, _context: Dictionary) -> void:
		reasons.append(reason)
	)
	assert_bool(bool(adapter.call("bind_boss_defeat", source))).is_true()
	assert_bool(bool(adapter.call("bind_key_event", source))).is_true()
	assert_bool(bool(adapter.call("bind_scene_change", source))).is_true()

	source.emit_boss_defeat()
	source.emit_key_event()
	source.emit_scene_change()

	assert_array(reasons).is_equal([&"boss_defeat", &"key_event", &"scene_change"])
	assert_bool(bool(save_system.call("has_save", 0))).is_true()
	assert_bool(FileAccess.file_exists(_slot_path(0) + ".bak")).is_true()
	var saved: Dictionary = _read_json(_slot_path(0))
	assert_str(String(saved["world_state"]["autosave_reason"])).is_equal("scene_change")
	source.queue_free()


func test_invalid_and_failed_autosave_triggers_fail_without_manual_slot_write() -> void:
	var adapter_script: Script = load(SAVE_TRIGGER_ADAPTER_PATH)
	assert_that(adapter_script).is_not_null()
	if adapter_script == null:
		return
	var local_adapter: Node = adapter_script.new()
	add_child(local_adapter)
	assert_bool(bool(local_adapter.call("bind_savepoint", null))).is_false()
	assert_bool(bool(local_adapter.call("trigger_auto_save", &"savepoint"))).is_false()

	var failing := FailingSaveSystem.new()
	var failed_reasons: Array[StringName] = []
	local_adapter.connect("on_autosave_failed", func(reason: StringName, _context: Dictionary) -> void:
		failed_reasons.append(reason)
	)
	local_adapter.call("configure", failing, Callable())

	assert_bool(bool(local_adapter.call("trigger_auto_save", &"boss_defeat", {
		"boss_id": "rat_king",
	}))).is_false()
	assert_int(failing.auto_save_calls).is_equal(1)
	assert_array(failing.manual_slot_calls).is_empty()
	assert_array(failed_reasons).is_equal([&"boss_defeat"])
	local_adapter.queue_free()


func _build_snapshot() -> Dictionary:
	return {
		"player_state": {
			"current_hp": 64,
			"max_hp": 100,
			"scene_id": "hub_ruins",
		},
		"world_state": {
			"defeated_bosses": ["rat_king_intro"],
		},
		"settings": {
			"colorblind_mode": "none",
		},
	}


func _read_json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	assert_bool(parsed is Dictionary).is_true()
	return Dictionary(parsed)


func _slot_path(slot: int) -> String:
	return "%sslot_%d.json" % [TEST_SAVE_DIR, slot]


func _cleanup_test_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(TEST_SAVE_DIR):
		return
	for file_name: String in DirAccess.get_files_at(TEST_SAVE_DIR):
		DirAccess.remove_absolute(TEST_SAVE_DIR.path_join(file_name))
	DirAccess.remove_absolute(TEST_SAVE_DIR)
