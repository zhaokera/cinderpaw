## Story 004: MainScene SaveSystem runtime handoff.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const SAVE_SYSTEM_PATH: String = "res://src/feature/save_system.gd"
const TEST_SAVE_DIR: String = "user://cinderpaw_save_system_story004/"

var save_system: Node
var scene: Node2D


func before_test() -> void:
	_cleanup_test_save_dir()
	var save_script: Script = load(SAVE_SYSTEM_PATH)
	assert_that(save_script).is_not_null()
	assert_bool(save_script != null and save_script.can_instantiate()).is_true()
	if save_script == null or not save_script.can_instantiate():
		return
	save_system = save_script.new()
	add_child(save_system)
	save_system.call("configure_save_directory", TEST_SAVE_DIR)
	if save_system.has_method("set_async_write_enabled"):
		save_system.call("set_async_write_enabled", false)
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null
	if is_instance_valid(save_system):
		if save_system.get_parent() != null:
			save_system.get_parent().remove_child(save_system)
		save_system.free()
	save_system = null
	_cleanup_test_save_dir()


func test_runtime_manual_save_writes_main_scene_snapshot_and_registered_system() -> void:
	if scene == null or save_system == null:
		return
	assert_bool(scene.has_method("configure_save_system_runtime")).is_true()
	assert_bool(scene.has_method("save_runtime_to_slot")).is_true()
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()

	_prepare_saved_runtime_state()

	assert_bool(bool(scene.call("save_runtime_to_slot", 1))).is_true()
	assert_bool(bool(save_system.call("has_save", 1))).is_true()
	assert_bool(bool(save_system.call("has_save", 0))).is_false()

	var saved: Dictionary = _read_json(_slot_path(1))
	assert_int(int(saved["_meta"]["slot"])).is_equal(1)
	assert_bool(bool(saved["_meta"]["is_auto"])).is_false()
	assert_int(int(saved["player_state"]["current_hp"])).is_equal(64)
	assert_int(int(saved["player_state"]["currency"])).is_equal(17)
	assert_str(String(saved["player_state"]["current_weapon"])).is_equal("long_tail")
	assert_float(float(saved["player_state"]["position"]["x"])).is_equal_approx(312.0, 0.001)
	assert_str(String(saved["world_state"]["scene_id"])).is_equal("main")
	assert_bool(bool(saved["world_state"]["world_flags"]["met_old_cat"])).is_true()
	assert_float(float(saved["settings"]["hud_scale"])).is_equal_approx(1.5, 0.001)
	assert_bool(saved["systems"].has("main_scene")).is_true()
	assert_str(String(saved["systems"]["main_scene"]["player_state"]["current_weapon"])).is_equal("long_tail")


func test_load_runtime_from_slot_restores_main_scene_progress_after_mutation() -> void:
	if scene == null or save_system == null:
		return
	assert_bool(scene.has_method("configure_save_system_runtime")).is_true()
	assert_bool(scene.has_method("save_runtime_to_slot")).is_true()
	assert_bool(scene.has_method("load_runtime_from_slot")).is_true()
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()

	_prepare_saved_runtime_state()
	assert_bool(bool(scene.call("save_runtime_to_slot", 1))).is_true()

	var player: Node = scene.get_node("Player")
	var hud: Node = scene.get_node("HUD")
	player.call("apply_damage", 20, {})
	scene.call("grant_currency", 99)
	scene.call("set_current_weapon_id", &"cat_claw")
	scene.call("set_world_progress_flag", &"met_old_cat", false)
	hud.call("set_hud_scale", 1.0)

	assert_bool(bool(scene.call("load_runtime_from_slot", 1))).is_true()

	assert_int(int(player.call("get_current_hp"))).is_equal(64)
	assert_int(int(scene.call("get_runtime_progress_state")["currency"])).is_equal(17)
	assert_str(String(scene.call("get_runtime_progress_state")["weapons"]["current_weapon"])).is_equal("long_tail")
	assert_bool(bool(scene.call("get_runtime_progress_state")["world_flags"]["met_old_cat"])).is_true()
	assert_float(float(hud.call("get_hud_scale"))).is_equal_approx(1.5, 0.001)


func test_boss_defeat_autosaves_slot_zero_through_runtime_trigger_adapter() -> void:
	if scene == null or save_system == null:
		return
	assert_bool(scene.has_method("configure_save_system_runtime")).is_true()
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()

	var enemy: Node = scene.get_node("Enemy")
	enemy.call("apply_damage", int(enemy.call("get_current_hp")), {
		"source": &"story004_test",
	})

	assert_bool(bool(save_system.call("has_save", 0))).is_true()
	assert_bool(bool(save_system.call("has_save", 1))).is_false()
	var saved: Dictionary = _read_json(_slot_path(0))
	assert_bool(bool(saved["_meta"]["is_auto"])).is_true()
	assert_str(String(saved["world_state"]["autosave_reason"])).is_equal("boss_defeat")
	assert_str(String(saved["world_state"]["autosave_context"]["boss_id"])).is_equal("boss_01_rat_king")
	assert_bool(Array(saved["world_state"]["defeated_bosses"]).has("boss_01_rat_king")).is_true()
	assert_int(int(saved["player_state"]["currency"])).is_equal(50)
	assert_int(int(saved["player_state"]["skill_points"])).is_equal(5)
	assert_bool(Array(saved["player_state"]["unlocked_abilities"]).has("dash")).is_true()


func _prepare_saved_runtime_state() -> void:
	var player: Node = scene.get_node("Player")
	var hud: Node = scene.get_node("HUD")
	player.global_position = Vector2(312, 444)
	player.call("apply_damage", 36, {})
	scene.call("grant_currency", 17)
	scene.call("acquire_weapon", &"long_tail")
	scene.call("set_current_weapon_id", &"long_tail")
	scene.call("set_world_progress_flag", &"met_old_cat", true)
	hud.call("set_hud_scale", 1.5)
	hud.call("set_colorblind_mode", &"blue_yellow")


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
