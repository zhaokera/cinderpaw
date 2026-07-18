## Scene Management Story 015: real project title bootstrap and deferred save load.
extends GdUnitTestSuite

const TITLE_SCENE_PATH: String = "res://scenes/title_bootstrap.tscn"
const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"

var bootstrap: Node


class FakeSaveSystem:
	extends RefCounted

	var snapshots: Dictionary = {}
	var peeked_slots: Array[int] = []
	var loaded_slots: Array[int] = []

	func has_save(slot: int) -> bool:
		return snapshots.has(slot)

	func get_save_info(slot: int) -> RefCounted:
		var info := SaveInfo.new(slot)
		info.exists = snapshots.has(slot)
		info.save_point_name = "Autosave" if slot == 0 else "Manual Save"
		return info

	func peek_save_data(slot: int) -> Dictionary:
		peeked_slots.append(slot)
		return Dictionary(snapshots.get(slot, {})).duplicate(true)

	func load_game(slot: int) -> bool:
		loaded_slots.append(slot)
		return snapshots.has(slot)


class FakeSceneManager:
	extends RefCounted

	signal on_scene_load_started(scene_id: StringName, spawn_point: StringName, metadata: Dictionary)
	signal on_scene_changed(old_scene: StringName, new_scene: StringName)
	signal on_scene_load_failed(scene_id: StringName, reason: StringName)

	var requests: Array[Dictionary] = []
	var runtime_root: Node

	func configure_runtime_scene_root(root: Node, _current_scene: Node = null) -> bool:
		runtime_root = root
		return root != null

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == &"main"

	func get_scene_config(scene_id: StringName) -> Dictionary:
		if scene_id != &"main":
			return {}
		return {
			"path": MAIN_SCENE_PATH,
			"default_spawn": "default",
			"display_name": "Scrap Roost",
		}

	func request_scene_change(scene_id: StringName, spawn_point: StringName) -> bool:
		requests.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		on_scene_load_started.emit(scene_id, spawn_point, {
			"display_name": "Scrap Roost",
			"transition_duration_sec": 1.5,
		})
		return true

	func complete_change(old_scene: StringName = &"hub", new_scene: StringName = &"main") -> void:
		on_scene_changed.emit(old_scene, new_scene)


func after_test() -> void:
	if is_instance_valid(bootstrap):
		if bootstrap.get_parent() != null:
			bootstrap.get_parent().remove_child(bootstrap)
		bootstrap.free()
	bootstrap = null


func test_project_boots_title_only_and_new_game_waits_for_scene_commit() -> void:
	var configured_main_scene: String = String(
		ProjectSettings.get_setting("application/run/main_scene", "")
	)
	assert_str(configured_main_scene).is_equal(TITLE_SCENE_PATH)
	var title_scene: PackedScene = load(configured_main_scene) as PackedScene
	assert_that(title_scene).is_not_null()
	if title_scene == null:
		return

	bootstrap = title_scene.instantiate()
	bootstrap.set("auto_configure_services", false)
	add_child(bootstrap)
	var save_system := FakeSaveSystem.new()
	var scene_manager := FakeSceneManager.new()
	assert_bool(bool(bootstrap.call("configure_runtime_services", save_system, scene_manager))).is_true()

	var diagnostics: Dictionary = Dictionary(bootstrap.call("get_title_diagnostics"))
	assert_bool(bool(diagnostics.get("title_visible", false))).is_true()
	assert_bool(bool(diagnostics.get("runtime_scene_present", true))).is_false()
	assert_str(String(diagnostics.get("menu_mode", ""))).is_equal("main_menu")
	assert_str(String(diagnostics.get("focused_button", ""))).is_equal("New Game")
	assert_str(String(diagnostics.get("title_character_type", ""))).is_equal("AnimatedSprite2D")
	assert_str(String(diagnostics.get("title_character_animation", ""))).is_equal("title_idle")
	assert_int(int(diagnostics.get("title_character_frame_count", 0))).is_equal(6)
	assert_bool(bool(diagnostics.get("title_character_playing", false))).is_true()
	assert_bool(float(diagnostics.get("readability_scrim_width", 0.0)) >= 480.0).is_true()
	assert_bool(float(diagnostics.get("menu_panel_bottom", 9999.0)) <= 684.0).is_true()
	assert_bool(bool(diagnostics.get("menu_focus_contract_valid", false))).is_true()
	assert_bool(_action_has_joy_button(&"ui_accept", 0)).is_true()
	assert_bool(_action_has_joy_button(&"ui_cancel", 1)).is_true()
	assert_bool(_action_has_joy_button(&"ui_up", 11)).is_true()
	assert_bool(_action_has_joy_button(&"ui_down", 12)).is_true()
	assert_array(Array(diagnostics.get("menu_buttons", []))).is_equal([
		"New Game",
		"Continue",
		"Load Game",
		"Settings",
		"Exit",
	])
	var disabled_reasons: Dictionary = Dictionary(diagnostics.get("disabled_reasons", {}))
	assert_str(String(disabled_reasons.get("Continue", ""))).is_equal("No save file available")
	assert_str(String(disabled_reasons.get("Load Game", ""))).is_equal("No save file available")

	bootstrap.call("request_new_game")
	assert_array(scene_manager.requests).is_equal([{
		"scene_id": "main",
		"spawn_point": "default",
	}])
	assert_bool(bool(bootstrap.call("is_title_visible"))).is_true()

	scene_manager.complete_change()
	assert_bool(bool(bootstrap.call("is_title_visible"))).is_false()
	assert_array(save_system.peeked_slots).is_empty()
	assert_array(save_system.loaded_slots).is_empty()


func test_continue_peeks_autosave_and_deserializes_only_after_scene_commit() -> void:
	var title_scene: PackedScene = load(TITLE_SCENE_PATH) as PackedScene
	assert_that(title_scene).is_not_null()
	if title_scene == null:
		return
	bootstrap = title_scene.instantiate()
	bootstrap.set("auto_configure_services", false)
	add_child(bootstrap)
	var save_system := FakeSaveSystem.new()
	save_system.snapshots[0] = {
		"player_state": {"scene_id": "main"},
		"world_state": {
			"scene_id": "main",
			"last_savepoint": {
				"scene_id": "main",
				"spawn_point": "scrap_roost",
			},
		},
		"settings": {},
		"systems": {},
	}
	var scene_manager := FakeSceneManager.new()
	assert_bool(bool(bootstrap.call("configure_runtime_services", save_system, scene_manager))).is_true()
	var diagnostics: Dictionary = Dictionary(bootstrap.call("get_title_diagnostics"))
	assert_str(String(diagnostics.get("focused_button", ""))).is_equal("Continue")

	assert_bool(bool(bootstrap.call("request_continue"))).is_true()
	assert_array(save_system.peeked_slots).is_equal([0])
	assert_array(save_system.loaded_slots).is_empty()
	assert_array(scene_manager.requests).is_equal([{
		"scene_id": "main",
		"spawn_point": "scrap_roost",
	}])
	assert_bool(bool(bootstrap.call("is_title_visible"))).is_true()

	scene_manager.complete_change()
	assert_array(save_system.loaded_slots).is_equal([0])
	assert_bool(bool(bootstrap.call("is_title_visible"))).is_false()


func _action_has_joy_button(action: StringName, button_index: int) -> bool:
	for event: InputEvent in InputMap.action_get_events(action):
		if (
			event is InputEventJoypadButton
			and (event as InputEventJoypadButton).button_index == button_index
		):
			return true
	return false
