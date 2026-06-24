## MainScene save/load menu shell runtime wiring tests.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")

var scene: Node2D


class AsyncMenuSaveSystem:
	extends Node

	signal on_save_written(slot: int)
	signal on_save_write_failed(slot: int, reason: String)

	var manual_save_calls: int = 0
	var pending_slot: int = -1
	var pending_info: Dictionary = {}
	var saved_infos: Dictionary = {}

	func register_serializable(_system: Object, _save_key: StringName) -> bool:
		return true

	func unregister_serializable(_save_key: StringName) -> bool:
		return true

	func manual_save(slot: int, player_state: Dictionary = {}, _world_state: Dictionary = {}, _settings: Dictionary = {}) -> bool:
		if pending_slot >= 0:
			on_save_write_failed.emit(slot, "write_pending")
			return false
		manual_save_calls += 1
		pending_slot = slot
		pending_info = {
			"slot": slot,
			"is_auto": slot == 0,
			"exists": true,
			"timestamp": "2026-06-24T09:00:00Z",
			"play_time_sec": 0.0,
			"save_point_name": "Manual Save",
			"version": 1,
			"summary": {
				"current_hp": int(player_state.get("current_hp", 0)),
				"current_weapon": String(player_state.get("current_weapon", "")),
				"currency": int(player_state.get("currency", 0)),
			},
			"file_size_bytes": 256,
		}
		return true

	func is_save_write_pending() -> bool:
		return pending_slot >= 0

	func get_save_info(slot: int) -> Dictionary:
		if saved_infos.has(slot):
			return Dictionary(saved_infos[slot]).duplicate(true)
		return {
			"slot": slot,
			"is_auto": slot == 0,
			"exists": false,
			"timestamp": "",
			"play_time_sec": 0.0,
			"save_point_name": "",
			"version": 0,
			"summary": {},
			"file_size_bytes": 0,
		}

	func complete_pending() -> void:
		if pending_slot < 0:
			return
		var completed_slot: int = pending_slot
		saved_infos[completed_slot] = pending_info.duplicate(true)
		pending_slot = -1
		pending_info = {}
		on_save_written.emit(completed_slot)

	func fail_pending(reason: String = "write_failed") -> void:
		if pending_slot < 0:
			return
		var failed_slot: int = pending_slot
		pending_slot = -1
		pending_info = {}
		on_save_write_failed.emit(failed_slot, reason)


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)


func after_test() -> void:
	if scene != null and is_instance_valid(scene):
		if scene.get_tree() != null:
			scene.get_tree().paused = false
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_returning_from_pause_to_main_menu_releases_pause_state_and_focus() -> void:
	if scene == null:
		return
	var hud: Node = scene.get_node("HUD")
	assert_bool(hud.has_signal("menu_main_menu_requested")).is_true()
	assert_bool(hud.has_method("get_menu_button_texts")).is_true()
	if not hud.has_signal("menu_main_menu_requested") or not hud.has_method("get_menu_button_texts"):
		return

	hud.emit_signal("menu_pause_requested")

	assert_bool(scene.get_tree().paused).is_true()
	assert_str(String(hud.call("get_menu_mode"))).is_equal("pause")

	hud.emit_signal("menu_main_menu_requested")

	assert_bool(scene.get_tree().paused).is_false()
	assert_str(String(hud.call("get_menu_mode"))).is_equal("main_menu")
	assert_str(String(hud.call("get_focused_menu_button_text"))).is_equal("New Game")
	assert_array(Array(hud.call("get_menu_button_texts"))).is_equal([
		"New Game",
		"Continue",
		"Load Game",
		"Settings",
		"Exit",
	])


func test_save_slot_request_waits_for_async_completion_before_success_feedback() -> void:
	if scene == null:
		return
	assert_bool(scene.has_method("configure_save_system_runtime")).is_true()
	if not scene.has_method("configure_save_system_runtime"):
		return
	var save_system := AsyncMenuSaveSystem.new()
	add_child(save_system)
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()
	var hud: Node = scene.get_node("HUD")

	hud.emit_signal("menu_save_slot_requested", 1)

	assert_int(save_system.manual_save_calls).is_equal(1)
	assert_bool(save_system.is_save_write_pending()).is_true()
	assert_str(String(hud.call("get_notification_text"))).is_equal("Saving...")
	assert_array(Array(hud.call("get_save_slot_labels"))).contains("Slot 1: Empty")

	save_system.complete_pending()

	assert_bool(save_system.is_save_write_pending()).is_false()
	assert_str(String(hud.call("get_notification_text"))).is_equal("Game saved")
	assert_array(Array(hud.call("get_save_slot_labels"))).contains(
		"Slot 1: Manual Save | HP 100 | cat_claw | Gears 0"
	)

	save_system.queue_free()


func test_save_slot_request_does_not_replace_pending_slot_when_write_in_progress() -> void:
	if scene == null:
		return
	var save_system := AsyncMenuSaveSystem.new()
	add_child(save_system)
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()
	var hud: Node = scene.get_node("HUD")

	hud.emit_signal("menu_save_slot_requested", 1)
	hud.emit_signal("menu_save_slot_requested", 2)

	assert_int(save_system.manual_save_calls).is_equal(1)
	assert_bool(save_system.is_save_write_pending()).is_true()
	assert_str(String(hud.call("get_notification_text"))).is_equal("Saving...")

	save_system.complete_pending()

	assert_str(String(hud.call("get_notification_text"))).is_equal("Game saved")
	assert_array(Array(hud.call("get_save_slot_labels"))).contains(
		"Slot 1: Manual Save | HP 100 | cat_claw | Gears 0"
	)
	assert_array(Array(hud.call("get_save_slot_labels"))).contains("Slot 2: Empty")

	save_system.queue_free()


func test_save_slot_request_reports_async_failure_without_success_refresh() -> void:
	if scene == null:
		return
	var save_system := AsyncMenuSaveSystem.new()
	add_child(save_system)
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()
	var hud: Node = scene.get_node("HUD")

	hud.emit_signal("menu_save_slot_requested", 1)
	save_system.fail_pending("slot_write_failed")

	assert_bool(save_system.is_save_write_pending()).is_false()
	assert_str(String(hud.call("get_notification_text"))).is_equal("Save failed")
	assert_array(Array(hud.call("get_save_slot_labels"))).contains("Slot 1: Empty")

	save_system.queue_free()
