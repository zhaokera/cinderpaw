## Story153 acceptance coverage for MainScene autosave HUD/audio feedback.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const SAVE_SYSTEM_SCRIPT: Script = preload("res://src/feature/save_system.gd")
const TEST_SAVE_DIR: String = "user://cinderpaw_main_autosave_paw_stamp/"
const SAVEPOINT_AREA_PATH: NodePath = ^"ScrapRoostSavepoint/InteractionArea"
const PAW_TEXTURE_PATH: String = "res://assets/generated/scene_transition_paw_spinner.png"

var scene: Node2D
var save_system: Node


class FakeAudioSystem:
	extends RefCounted

	var ui_save_events: Array[Dictionary] = []

	func on_scene_load_started(
		_scene_id: StringName,
		_spawn_point: StringName,
		_metadata: Dictionary
	) -> void:
		pass

	func on_ui_save(metadata: Dictionary = {}) -> bool:
		ui_save_events.append(metadata.duplicate(true))
		return true


class RejectingSaveSystem:
	extends Node

	func manual_save(
		_slot: int,
		_player_state: Dictionary = {},
		_world_state: Dictionary = {},
		_settings: Dictionary = {}
	) -> bool:
		return false

	func auto_save(
		_player_state: Dictionary = {},
		_world_state: Dictionary = {},
		_settings: Dictionary = {}
	) -> bool:
		return false


func before_test() -> void:
	_cleanup_test_save_dir()
	save_system = SAVE_SYSTEM_SCRIPT.new()
	add_child(save_system)
	save_system.call("configure_save_directory", TEST_SAVE_DIR)
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


func test_accepted_savepoint_autosave_shows_fading_paw_stamp_and_routes_one_cue() -> void:
	var hud: Node = scene.get_node("HUD")
	assert_bool(hud.has_method("show_autosave_stamp")).is_true()
	assert_bool(hud.has_method("get_autosave_stamp_diagnostics")).is_true()
	if (
		not hud.has_method("show_autosave_stamp")
		or not hud.has_method("get_autosave_stamp_diagnostics")
	):
		return

	var audio_system := FakeAudioSystem.new()
	assert_bool(bool(scene.call("configure_audio_system_runtime", audio_system))).is_true()
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()
	hud.call("set_hud_scale", 1.5)

	var area: Area2D = scene.get_node(SAVEPOINT_AREA_PATH) as Area2D
	area.body_entered.emit(scene.get_node("Player"))

	var diagnostics: Dictionary = Dictionary(hud.call("get_autosave_stamp_diagnostics"))
	assert_bool(bool(diagnostics.get("visible", false))).is_true()
	assert_str(String(diagnostics.get("source_texture_path", ""))).is_equal(PAW_TEXTURE_PATH)
	assert_float(float(diagnostics.get("remaining_sec", 0.0))).is_equal_approx(1.5, 0.001)
	assert_float(float(diagnostics.get("alpha", 0.0))).is_equal_approx(1.0, 0.001)
	assert_bool(bool(hud.call("has_core_hud_overlap"))).is_false()
	var stamp_position: Vector2 = diagnostics.get("position", Vector2.ZERO)
	var stamp_size: Vector2 = diagnostics.get("size", Vector2.ZERO)
	assert_bool(stamp_position.x >= 0.0 and stamp_position.y >= 0.0).is_true()
	assert_bool(stamp_position.x + stamp_size.x <= 1280.0).is_true()
	assert_bool(stamp_position.y + stamp_size.y <= 720.0).is_true()

	assert_int(audio_system.ui_save_events.size()).is_equal(1)
	if audio_system.ui_save_events.size() == 1:
		var event: Dictionary = audio_system.ui_save_events[0]
		assert_int(int(event.get("slot", -1))).is_equal(0)
		assert_str(String(event.get("source", ""))).is_equal("autosave")
		assert_str(String(event.get("reason", ""))).is_equal("savepoint")
		assert_str(String(Dictionary(event.get("context", {})).get("savepoint_id", ""))).is_equal(
			"scrap_roost"
		)

	hud.call("advance_time", 1.0)
	diagnostics = Dictionary(hud.call("get_autosave_stamp_diagnostics"))
	assert_bool(bool(diagnostics.get("visible", false))).is_true()
	assert_float(float(diagnostics.get("alpha", 0.0))).is_equal_approx(1.0, 0.001)

	hud.call("advance_time", 0.25)
	diagnostics = Dictionary(hud.call("get_autosave_stamp_diagnostics"))
	assert_bool(bool(diagnostics.get("visible", false))).is_true()
	assert_float(float(diagnostics.get("alpha", 0.0))).is_equal_approx(0.5, 0.001)

	hud.call("advance_time", 0.25)
	diagnostics = Dictionary(hud.call("get_autosave_stamp_diagnostics"))
	assert_bool(bool(diagnostics.get("visible", true))).is_false()
	assert_float(float(diagnostics.get("alpha", 1.0))).is_equal_approx(0.0, 0.001)


func test_rejected_autosave_keeps_stamp_hidden_and_does_not_route_save_cue() -> void:
	var hud: Node = scene.get_node("HUD")
	assert_bool(hud.has_method("get_autosave_stamp_diagnostics")).is_true()
	if not hud.has_method("get_autosave_stamp_diagnostics"):
		return
	var audio_system := FakeAudioSystem.new()
	var rejecting_save_system := RejectingSaveSystem.new()
	add_child(rejecting_save_system)
	assert_bool(bool(scene.call("configure_audio_system_runtime", audio_system))).is_true()
	assert_bool(bool(scene.call("configure_save_system_runtime", rejecting_save_system))).is_true()

	var area: Area2D = scene.get_node(SAVEPOINT_AREA_PATH) as Area2D
	area.body_entered.emit(scene.get_node("Player"))

	var diagnostics: Dictionary = Dictionary(hud.call("get_autosave_stamp_diagnostics"))
	assert_bool(bool(diagnostics.get("visible", false))).is_false()
	assert_int(audio_system.ui_save_events.size()).is_equal(0)

	remove_child(rejecting_save_system)
	rejecting_save_system.free()


func _cleanup_test_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(TEST_SAVE_DIR):
		return
	for file_name: String in DirAccess.get_files_at(TEST_SAVE_DIR):
		DirAccess.remove_absolute(TEST_SAVE_DIR.path_join(file_name))
	DirAccess.remove_absolute(TEST_SAVE_DIR)
