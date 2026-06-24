## Story 001: SceneManager registry, Autoload, and public API baseline.
extends GdUnitTestSuite

const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")
const SAVE_SYSTEM_PATH: String = "res://src/feature/save_system.gd"
const SCENE_MANAGER_PATH: String = "res://src/feature/scene_manager.gd"
const TEST_SAVE_DIR: String = "user://cinderpaw_scene_manager_story001/"

var scene_manager: Node


func after_test() -> void:
	if is_instance_valid(scene_manager):
		if scene_manager.get_parent() != null:
			scene_manager.get_parent().remove_child(scene_manager)
		scene_manager.free()
	scene_manager = null
	_cleanup_test_save_dir()


func test_project_autoload_registers_scene_manager_after_save_system_and_script_loads() -> void:
	var project_text: String = FileAccess.get_file_as_string("res://project.godot")
	var save_index: int = project_text.find("SaveSystem=\"*res://src/feature/save_system.gd\"")
	var scene_index: int = project_text.find("SceneManager=\"*res://src/feature/scene_manager.gd\"")
	var helper_index: int = project_text.find("_mcp_game_helper=\"*res://addons/godot_ai/runtime/game_helper.gd\"")

	assert_int(save_index).is_greater_equal(0)
	assert_int(scene_index).is_greater(save_index)
	assert_int(helper_index).is_greater(scene_index)

	var scene_script: Script = load(SCENE_MANAGER_PATH)
	assert_that(scene_script).is_not_null()
	assert_bool(scene_script != null and scene_script.can_instantiate()).is_true()


func test_scene_registry_domain_contains_hub_and_main_existing_scene_paths() -> void:
	var data_manager: Node = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)

	assert_bool(bool(data_manager.call("has_domain", &"scene_registry"))).is_true()
	var registry: Dictionary = Dictionary(data_manager.call("get_domain", &"scene_registry"))
	assert_dict(registry).contains_keys(["hub", "main"])
	assert_str(String(registry["hub"]["path"])).is_equal("res://scenes/main.tscn")
	assert_str(String(registry["main"]["path"])).is_equal("res://scenes/main.tscn")
	assert_bool(FileAccess.file_exists(String(registry["hub"]["path"]))).is_true()
	assert_bool(FileAccess.file_exists(String(registry["main"]["path"]))).is_true()

	data_manager.free()


func test_configure_registry_and_preload_mark_logical_scene_loaded_without_tree_swap() -> void:
	scene_manager = _new_scene_manager()
	assert_bool(bool(scene_manager.call("configure_scene_registry", _test_registry()))).is_true()

	assert_bool(bool(scene_manager.call("preload_scene", &"main"))).is_true()

	assert_bool(bool(scene_manager.call("is_scene_loaded", &"main"))).is_true()
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("hub")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("clan_base")


func test_change_scene_records_current_scene_spawn_and_emits_expected_signals_once() -> void:
	scene_manager = _new_scene_manager()
	assert_bool(bool(scene_manager.call("configure_scene_registry", _test_registry()))).is_true()
	var events: Array[String] = []
	scene_manager.connect("on_scene_loaded", func(scene_id: StringName) -> void:
		events.append("loaded:%s" % String(scene_id))
	)
	scene_manager.connect("on_scene_changed", func(old_scene: StringName, new_scene: StringName) -> void:
		events.append("changed:%s>%s" % [String(old_scene), String(new_scene)])
	)

	assert_bool(bool(scene_manager.call("change_scene", &"main", &"clan_base"))).is_true()

	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("main")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("clan_base")
	assert_array(events).is_equal(["loaded:main", "changed:hub>main"])


func test_lock_and_invalid_scene_reject_change_without_state_or_signal_side_effects() -> void:
	scene_manager = _new_scene_manager()
	assert_bool(bool(scene_manager.call("configure_scene_registry", _test_registry()))).is_true()
	var events: Array[String] = []
	scene_manager.connect("on_scene_loaded", func(scene_id: StringName) -> void:
		events.append("loaded:%s" % String(scene_id))
	)
	scene_manager.connect("on_scene_changed", func(old_scene: StringName, new_scene: StringName) -> void:
		events.append("changed:%s>%s" % [String(old_scene), String(new_scene)])
	)

	scene_manager.call("lock_scene")
	assert_bool(bool(scene_manager.call("change_scene", &"main", &"default"))).is_false()
	scene_manager.call("unlock_scene")
	assert_bool(bool(scene_manager.call("change_scene", &"missing", &"default"))).is_false()

	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("hub")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("clan_base")
	assert_array(events).is_empty()


func test_unlock_scene_allows_change_after_lock() -> void:
	scene_manager = _new_scene_manager()
	assert_bool(bool(scene_manager.call("configure_scene_registry", _test_registry()))).is_true()

	scene_manager.call("lock_scene")
	scene_manager.call("unlock_scene")

	assert_bool(bool(scene_manager.call("change_scene", &"main", &"default"))).is_true()
	assert_bool(bool(scene_manager.call("is_scene_locked"))).is_false()
	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("main")


func test_set_get_scene_state_deep_copies_json_safe_state() -> void:
	scene_manager = _new_scene_manager()
	assert_bool(bool(scene_manager.call("configure_scene_registry", _test_registry()))).is_true()
	var state: Dictionary = {
		"doors_opened": ["north_gate"],
		"props": {"trash_can": "broken"},
	}

	assert_bool(bool(scene_manager.call("set_scene_state", &"main", state))).is_true()
	state["props"]["trash_can"] = "intact"

	var stored: Dictionary = Dictionary(scene_manager.call("get_scene_state", &"main"))
	assert_str(String(stored["props"]["trash_can"])).is_equal("broken")
	stored["props"]["trash_can"] = "mutated"

	var stored_again: Dictionary = Dictionary(scene_manager.call("get_scene_state", &"main"))
	assert_str(String(stored_again["props"]["trash_can"])).is_equal("broken")


func test_serialize_deserialize_round_trip_preserves_current_scene_spawn_and_states() -> void:
	scene_manager = _new_scene_manager()
	assert_bool(bool(scene_manager.call("configure_scene_registry", _test_registry()))).is_true()
	assert_bool(bool(scene_manager.call("change_scene", &"main", &"savepoint_01"))).is_true()
	assert_bool(bool(scene_manager.call("set_scene_state", &"main", {"gate": "open"}))).is_true()
	var snapshot: Dictionary = Dictionary(scene_manager.call("serialize"))

	var restored: Node = _new_scene_manager()
	assert_bool(bool(restored.call("configure_scene_registry", _test_registry()))).is_true()
	restored.call("deserialize", snapshot, 1)

	assert_str(String(restored.call("get_current_scene"))).is_equal("main")
	assert_str(String(restored.call("get_current_spawn_point"))).is_equal("savepoint_01")
	assert_dict(Dictionary(restored.call("get_scene_state", &"main"))).is_equal({"gate": "open"})

	restored.free()


func test_save_system_can_register_scene_manager_and_call_deserialize_with_version() -> void:
	_cleanup_test_save_dir()
	scene_manager = _new_scene_manager()
	assert_bool(bool(scene_manager.call("configure_scene_registry", _test_registry()))).is_true()
	assert_bool(bool(scene_manager.call("change_scene", &"main", &"savepoint_02"))).is_true()
	var snapshot: Dictionary = Dictionary(scene_manager.call("serialize"))

	var save_script: Script = load(SAVE_SYSTEM_PATH)
	assert_that(save_script).is_not_null()
	var save_system: Node = save_script.new()
	add_child(save_system)
	save_system.call("configure_save_directory", TEST_SAVE_DIR)
	save_system.call("set_async_write_enabled", false)
	assert_bool(bool(save_system.call("register_serializable", scene_manager, &"scene"))).is_true()
	assert_bool(bool(save_system.call("manual_save", 1, {}, {}, {}))).is_true()

	var saved: Dictionary = _read_json(TEST_SAVE_DIR.path_join("slot_1.json"))
	saved["systems"]["scene"] = snapshot
	_write_file(TEST_SAVE_DIR.path_join("slot_1.json"), JSON.stringify(saved, "\t"))

	assert_bool(bool(scene_manager.call("change_scene", &"hub", &"clan_base"))).is_true()
	assert_bool(bool(save_system.call("load_game", 1))).is_true()

	assert_str(String(scene_manager.call("get_current_scene"))).is_equal("main")
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal("savepoint_02")

	save_system.free()


func _new_scene_manager() -> Node:
	var scene_script: Script = load(SCENE_MANAGER_PATH)
	assert_that(scene_script).is_not_null()
	assert_bool(scene_script != null and scene_script.can_instantiate()).is_true()
	if scene_script == null or not scene_script.can_instantiate():
		return Node.new()
	var manager: Node = scene_script.new()
	add_child(manager)
	return manager


func _test_registry() -> Dictionary:
	return {
		"hub": {
			"scene_id": "hub",
			"path": "res://scenes/main.tscn",
			"type": "hub",
			"preload": true,
			"default_spawn": "clan_base",
		},
		"main": {
			"scene_id": "main",
			"path": "res://scenes/main.tscn",
			"type": "area",
			"preload": false,
			"default_spawn": "default",
		},
	}


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


func _cleanup_test_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(TEST_SAVE_DIR):
		return
	for file_name: String in DirAccess.get_files_at(TEST_SAVE_DIR):
		DirAccess.remove_absolute(TEST_SAVE_DIR.path_join(file_name))
	DirAccess.remove_absolute(TEST_SAVE_DIR)
