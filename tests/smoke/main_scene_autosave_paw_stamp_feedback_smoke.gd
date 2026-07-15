extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const SAVE_SYSTEM_SCRIPT: Script = preload("res://src/feature/save_system.gd")
const TEST_SAVE_DIR: String = "user://cinderpaw_story153_autosave_smoke/"
const SAVEPOINT_AREA_PATH: NodePath = ^"ScrapRoostSavepoint/InteractionArea"


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


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_cleanup_test_save_dir()
	var save_system: Node = SAVE_SYSTEM_SCRIPT.new()
	save_system.name = "Story153SaveSystem"
	root.add_child(save_system)
	save_system.call("configure_save_directory", TEST_SAVE_DIR)
	save_system.call("set_async_write_enabled", false)

	var main: Node2D = MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	await process_frame
	var hud: Node = main.get_node_or_null("HUD")
	var player: Node = main.get_node_or_null("Player")
	var area: Area2D = main.get_node_or_null(SAVEPOINT_AREA_PATH) as Area2D
	var stamp: TextureRect = main.get_node_or_null(
		"HUD/HudRoot/AutosavePawStamp"
	) as TextureRect
	if hud == null or player == null or area == null or stamp == null:
		_fail("runtime_nodes_missing")
		return

	var audio_system := FakeAudioSystem.new()
	if not bool(main.call("configure_audio_system_runtime", audio_system)):
		_fail("audio_adapter_rejected")
		return
	if not bool(main.call("configure_save_system_runtime", save_system)):
		_fail("save_adapter_rejected")
		return
	hud.call("set_hud_scale", 1.5)
	area.body_entered.emit(player)

	var initial: Dictionary = Dictionary(hud.call("get_autosave_stamp_diagnostics"))
	if (
		not bool(initial.get("visible", false))
		or not is_equal_approx(float(initial.get("remaining_sec", 0.0)), 1.5)
		or not is_equal_approx(float(initial.get("alpha", 0.0)), 1.0)
		or bool(hud.call("has_core_hud_overlap"))
		or audio_system.ui_save_events.size() != 1
		or not FileAccess.file_exists(TEST_SAVE_DIR.path_join("slot_0.json"))
	):
		_fail("accepted_autosave_feedback_contract_failed")
		return
	var event: Dictionary = audio_system.ui_save_events[0]
	if (
		int(event.get("slot", -1)) != 0
		or String(event.get("reason", "")) != "savepoint"
		or String(Dictionary(event.get("context", {})).get("savepoint_id", "")) != "scrap_roost"
	):
		_fail("autosave_audio_metadata_failed")
		return

	hud.call("advance_time", 1.0)
	var opaque: Dictionary = Dictionary(hud.call("get_autosave_stamp_diagnostics"))
	hud.call("advance_time", 0.25)
	var fading: Dictionary = Dictionary(hud.call("get_autosave_stamp_diagnostics"))
	hud.call("advance_time", 0.25)
	var expired: Dictionary = Dictionary(hud.call("get_autosave_stamp_diagnostics"))
	if (
		not is_equal_approx(float(opaque.get("alpha", 0.0)), 1.0)
		or not is_equal_approx(float(fading.get("alpha", 0.0)), 0.5)
		or bool(expired.get("visible", true))
		or not is_equal_approx(float(expired.get("alpha", 1.0)), 0.0)
	):
		_fail("autosave_stamp_lifecycle_failed")
		return

	print("main_scene_autosave_paw_stamp_diagnostics=", JSON.stringify(initial))
	_free_runtime_node(main)
	_free_runtime_node(save_system)
	main = null
	save_system = null
	await process_frame
	_cleanup_test_save_dir()
	print("main_scene_autosave_paw_stamp_feedback_smoke=passed")
	quit(0)


func _free_runtime_node(node: Node) -> void:
	if node != null and is_instance_valid(node):
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()


func _cleanup_test_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(TEST_SAVE_DIR):
		return
	for file_name: String in DirAccess.get_files_at(TEST_SAVE_DIR):
		DirAccess.remove_absolute(TEST_SAVE_DIR.path_join(file_name))
	DirAccess.remove_absolute(TEST_SAVE_DIR)


func _fail(reason: String) -> void:
	push_error("main_scene_autosave_paw_stamp_feedback_smoke=" + reason)
	quit(1)
