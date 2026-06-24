## Scene Management Story 002: title/continue/load runtime handoff.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")

var scene: Node2D


class FakeSceneManager:
	extends RefCounted

	var known_scenes: Dictionary = {"main": true, "hub": true}
	var default_spawns: Dictionary = {"main": "default", "hub": "clan_base"}
	var locked: bool = false
	var reject_changes: bool = false
	var change_calls: Array[Dictionary] = []
	var deserialize_calls: int = 0

	func has_scene(scene_id: StringName) -> bool:
		return bool(known_scenes.get(String(scene_id), false))

	func get_scene_config(scene_id: StringName) -> Dictionary:
		if not has_scene(scene_id):
			return {}
		return {
			"scene_id": String(scene_id),
			"default_spawn": String(default_spawns.get(String(scene_id), "default")),
		}

	func is_scene_locked() -> bool:
		return locked

	func change_scene(scene_id: StringName, spawn_point: StringName = &"default") -> bool:
		change_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		return not reject_changes and not locked and has_scene(scene_id)

	func deserialize(_data: Dictionary, _version: int = 1) -> void:
		deserialize_calls += 1


class FakeSaveSystem:
	extends Node

	signal on_save_written(slot: int)
	signal on_save_write_failed(slot: int, reason: String)

	var slot_payloads: Dictionary = {}
	var loaded_slots: Array[int] = []
	var registered_keys: Array[String] = []
	var unregistered_keys: Array[String] = []
	var registered_systems: Dictionary = {}
	var simulate_deserialize_registered_systems: bool = false
	var last_loaded_data: Dictionary = {}

	func register_serializable(system: Object, save_key: StringName) -> bool:
		var key: String = String(save_key)
		if registered_systems.has(key):
			return false
		if not registered_keys.has(key):
			registered_keys.append(key)
		registered_systems[key] = system
		return true

	func unregister_serializable(save_key: StringName) -> bool:
		var key: String = String(save_key)
		if not registered_systems.has(key):
			return false
		unregistered_keys.append(key)
		registered_keys.erase(key)
		registered_systems.erase(key)
		return true

	func manual_save(_slot: int, _player_state: Dictionary = {}, _world_state: Dictionary = {}, _settings: Dictionary = {}) -> bool:
		return true

	func load_game(slot: int) -> bool:
		if not slot_payloads.has(slot):
			last_loaded_data = {}
			return false
		loaded_slots.append(slot)
		last_loaded_data = Dictionary(slot_payloads[slot]).duplicate(true)
		if simulate_deserialize_registered_systems:
			_deserialize_registered_systems(Dictionary(last_loaded_data.get("systems", {})), 1)
		return true

	func get_last_loaded_data() -> Dictionary:
		return last_loaded_data.duplicate(true)

	func get_save_info(slot: int) -> Dictionary:
		var exists: bool = slot_payloads.has(slot)
		return {
			"slot": slot,
			"is_auto": slot == 0,
			"exists": exists,
			"timestamp": "2026-06-25T10:%02d:00Z" % slot if exists else "",
			"play_time_sec": 120.0 + float(slot),
			"save_point_name": "Slot %d" % slot if exists else "",
			"version": 1 if exists else 0,
			"summary": {
				"current_hp": 42 + slot,
				"current_weapon": "cat_claw",
				"currency": 17 + slot,
			} if exists else {},
			"file_size_bytes": 256 if exists else 0,
		}

	func _deserialize_registered_systems(systems_data: Dictionary, version: int) -> void:
		for key: String in registered_keys.duplicate():
			if not systems_data.has(key):
				continue
			var system: Object = registered_systems.get(key, null)
			if system != null and is_instance_valid(system) and system.has_method("deserialize"):
				system.call("deserialize", Dictionary(systems_data[key]).duplicate(true), version)


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


func test_new_game_routes_default_playable_scene_through_scene_manager() -> void:
	var scene_manager := FakeSceneManager.new()
	assert_bool(bool(scene.call("configure_scene_manager_runtime", scene_manager))).is_true()
	var hud: Node = scene.get_node("HUD")
	hud.call("show_main_menu", [])
	scene.get_tree().paused = true

	hud.emit_signal("menu_new_game_requested")

	assert_int(scene_manager.change_calls.size()).is_equal(1)
	if not scene_manager.change_calls.is_empty():
		assert_str(String(scene_manager.change_calls[0]["scene_id"])).is_equal("main")
		assert_str(String(scene_manager.change_calls[0]["spawn_point"])).is_equal("default")
	assert_bool(hud.call("is_menu_visible")).is_false()
	assert_bool(scene.get_tree().paused).is_false()


func test_continue_loads_first_available_slot_and_hands_off_saved_spawn() -> void:
	var save_system := FakeSaveSystem.new()
	add_child(save_system)
	save_system.slot_payloads[0] = _save_payload("main", "scrap_roost", Vector2(312, 444), 64, 17)
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()
	var scene_manager := FakeSceneManager.new()
	assert_bool(bool(scene.call("configure_scene_manager_runtime", scene_manager))).is_true()
	var hud: Node = scene.get_node("HUD")
	hud.call("show_main_menu", [save_system.get_save_info(0)])
	scene.get_tree().paused = true

	hud.emit_signal("menu_continue_requested")

	assert_array(save_system.loaded_slots).is_equal([0])
	assert_int(scene_manager.change_calls.size()).is_equal(1)
	if not scene_manager.change_calls.is_empty():
		assert_str(String(scene_manager.change_calls[0]["scene_id"])).is_equal("main")
		assert_str(String(scene_manager.change_calls[0]["spawn_point"])).is_equal("scrap_roost")
	assert_int(int(scene.call("get_runtime_progress_state")["currency"])).is_equal(17)
	assert_int(int(scene.get_node("Player").call("get_current_hp"))).is_equal(64)
	assert_bool(hud.call("is_menu_visible")).is_false()
	assert_bool(scene.get_tree().paused).is_false()

	save_system.queue_free()


func test_load_slot_uses_selected_slot_not_continue_default() -> void:
	var save_system := FakeSaveSystem.new()
	add_child(save_system)
	save_system.slot_payloads[0] = _save_payload("main", "autosave_roost", Vector2(111, 222), 77, 5)
	save_system.slot_payloads[1] = _save_payload("main", "manual_roost", Vector2(333, 444), 55, 19)
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()
	var scene_manager := FakeSceneManager.new()
	assert_bool(bool(scene.call("configure_scene_manager_runtime", scene_manager))).is_true()
	var hud: Node = scene.get_node("HUD")
	hud.call("show_save_load_menu", [
		save_system.get_save_info(0),
		save_system.get_save_info(1),
	], false, "Saving requires a save point")

	hud.emit_signal("menu_load_slot_requested", 1)

	assert_array(save_system.loaded_slots).is_equal([1])
	assert_int(scene_manager.change_calls.size()).is_equal(1)
	if not scene_manager.change_calls.is_empty():
		assert_str(String(scene_manager.change_calls[0]["scene_id"])).is_equal("main")
		assert_str(String(scene_manager.change_calls[0]["spawn_point"])).is_equal("manual_roost")
	assert_int(int(scene.call("get_runtime_progress_state")["currency"])).is_equal(19)
	assert_int(int(scene.get_node("Player").call("get_current_hp"))).is_equal(55)
	assert_bool(hud.call("is_menu_visible")).is_false()

	save_system.queue_free()


func test_load_slot_rejection_keeps_menu_visible_and_does_not_restore_state() -> void:
	var save_system := FakeSaveSystem.new()
	add_child(save_system)
	save_system.slot_payloads[1] = _save_payload("deleted_scene", "deleted_spawn", Vector2(333, 444), 12, 99)
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()
	var scene_manager := FakeSceneManager.new()
	scene_manager.known_scenes["deleted_scene"] = false
	assert_bool(bool(scene.call("configure_scene_manager_runtime", scene_manager))).is_true()
	var hud: Node = scene.get_node("HUD")
	hud.call("show_save_load_menu", [save_system.get_save_info(1)], false, "Saving requires a save point")

	hud.emit_signal("menu_load_slot_requested", 1)

	assert_array(save_system.loaded_slots).is_equal([1])
	assert_int(scene_manager.change_calls.size()).is_equal(0)
	assert_int(int(scene.call("get_runtime_progress_state")["currency"])).is_equal(0)
	assert_int(int(scene.get_node("Player").call("get_current_hp"))).is_equal(100)
	assert_bool(hud.call("is_menu_visible")).is_true()
	assert_str(String(hud.call("get_menu_mode"))).is_equal("save_load")
	assert_str(String(hud.call("get_notification_text"))).is_equal("Load failed")

	save_system.queue_free()


func test_load_slot_uses_scene_fallback_order_when_savepoint_is_missing() -> void:
	var save_system := FakeSaveSystem.new()
	add_child(save_system)
	save_system.slot_payloads[1] = _save_payload("main", "ignored", Vector2(100, 200), 80, 10)
	var slot_one_world: Dictionary = Dictionary(save_system.slot_payloads[1]["world_state"])
	slot_one_world.erase("last_savepoint")
	slot_one_world["scene_id"] = "hub"
	save_system.slot_payloads[1]["world_state"] = slot_one_world
	save_system.slot_payloads[2] = _save_payload("main", "ignored", Vector2(200, 300), 70, 20)
	var slot_two_world: Dictionary = Dictionary(save_system.slot_payloads[2]["world_state"])
	slot_two_world.erase("last_savepoint")
	slot_two_world.erase("scene_id")
	save_system.slot_payloads[2]["world_state"] = slot_two_world
	var slot_two_player: Dictionary = Dictionary(save_system.slot_payloads[2]["player_state"])
	slot_two_player["scene_id"] = "main"
	save_system.slot_payloads[2]["player_state"] = slot_two_player
	save_system.slot_payloads[3] = _save_payload("main", "ignored", Vector2(300, 400), 60, 30)
	var slot_three_world: Dictionary = Dictionary(save_system.slot_payloads[3]["world_state"])
	slot_three_world.erase("last_savepoint")
	slot_three_world.erase("scene_id")
	save_system.slot_payloads[3]["world_state"] = slot_three_world
	var slot_three_player: Dictionary = Dictionary(save_system.slot_payloads[3]["player_state"])
	slot_three_player.erase("scene_id")
	save_system.slot_payloads[3]["player_state"] = slot_three_player
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()
	var scene_manager := FakeSceneManager.new()
	assert_bool(bool(scene.call("configure_scene_manager_runtime", scene_manager))).is_true()

	assert_bool(bool(scene.call("load_runtime_from_slot", 1))).is_true()
	assert_bool(bool(scene.call("load_runtime_from_slot", 2))).is_true()
	assert_bool(bool(scene.call("load_runtime_from_slot", 3))).is_true()

	assert_int(scene_manager.change_calls.size()).is_equal(3)
	assert_str(String(scene_manager.change_calls[0]["scene_id"])).is_equal("hub")
	assert_str(String(scene_manager.change_calls[0]["spawn_point"])).is_equal("clan_base")
	assert_str(String(scene_manager.change_calls[1]["scene_id"])).is_equal("main")
	assert_str(String(scene_manager.change_calls[1]["spawn_point"])).is_equal("default")
	assert_str(String(scene_manager.change_calls[2]["scene_id"])).is_equal("main")
	assert_str(String(scene_manager.change_calls[2]["spawn_point"])).is_equal("default")

	save_system.queue_free()


func test_locked_or_rejected_scene_manager_keeps_load_atomic() -> void:
	var save_system := FakeSaveSystem.new()
	add_child(save_system)
	save_system.slot_payloads[1] = _save_payload("main", "locked_roost", Vector2(333, 444), 12, 99)
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()
	var scene_manager := FakeSceneManager.new()
	assert_bool(bool(scene.call("configure_scene_manager_runtime", scene_manager))).is_true()
	scene_manager.locked = true
	var hud: Node = scene.get_node("HUD")
	hud.call("show_save_load_menu", [save_system.get_save_info(1)], false, "Saving requires a save point")

	hud.emit_signal("menu_load_slot_requested", 1)

	assert_array(save_system.loaded_slots).is_equal([1])
	assert_int(scene_manager.change_calls.size()).is_equal(0)
	assert_int(int(scene.call("get_runtime_progress_state")["currency"])).is_equal(0)
	assert_int(int(scene.get_node("Player").call("get_current_hp"))).is_equal(100)
	assert_bool(hud.call("is_menu_visible")).is_true()
	assert_str(String(hud.call("get_notification_text"))).is_equal("Load failed")

	scene_manager.locked = false
	scene_manager.reject_changes = true
	hud.emit_signal("menu_load_slot_requested", 1)

	assert_array(save_system.loaded_slots).is_equal([1, 1])
	assert_int(scene_manager.change_calls.size()).is_equal(1)
	assert_int(int(scene.call("get_runtime_progress_state")["currency"])).is_equal(0)
	assert_int(int(scene.get_node("Player").call("get_current_hp"))).is_equal(100)
	assert_bool(hud.call("is_menu_visible")).is_true()
	assert_str(String(hud.call("get_notification_text"))).is_equal("Load failed")

	save_system.queue_free()


func test_registered_system_deserialize_is_skipped_until_scene_handoff_succeeds() -> void:
	var save_system := FakeSaveSystem.new()
	add_child(save_system)
	save_system.simulate_deserialize_registered_systems = true
	save_system.slot_payloads[1] = _save_payload("main", "manual_roost", Vector2(333, 444), 12, 99)
	var main_scene_system_payload: Dictionary = Dictionary(save_system.slot_payloads[1]).duplicate(true)
	save_system.slot_payloads[1]["systems"] = {
		"main_scene": main_scene_system_payload,
		"scene": {
			"current_scene_id": "main",
			"current_spawn_point": "manual_roost",
			"scene_states": {},
		},
	}
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()
	var scene_manager := FakeSceneManager.new()
	scene_manager.reject_changes = true
	assert_bool(bool(scene.call("configure_scene_manager_runtime", scene_manager))).is_true()
	assert_bool(save_system.register_serializable(scene_manager, &"scene")).is_true()

	assert_bool(bool(scene.call("load_runtime_from_slot", 1))).is_false()

	assert_array(save_system.loaded_slots).is_equal([1])
	assert_array(save_system.unregistered_keys).contains("main_scene")
	assert_array(save_system.unregistered_keys).contains("scene")
	assert_int(scene_manager.deserialize_calls).is_equal(0)
	assert_int(scene_manager.change_calls.size()).is_equal(1)
	assert_int(int(scene.call("get_runtime_progress_state")["currency"])).is_equal(0)
	assert_int(int(scene.get_node("Player").call("get_current_hp"))).is_equal(100)
	assert_bool(save_system.registered_keys.has("main_scene")).is_true()
	assert_bool(save_system.registered_keys.has("scene")).is_true()

	save_system.queue_free()


func _save_payload(scene_id: String, spawn_point: String, position: Vector2, hp: int, currency: int) -> Dictionary:
	return {
		"player_state": {
			"scene_id": scene_id,
			"position": {"x": position.x, "y": position.y},
			"current_hp": hp,
			"max_hp": 100,
			"current_weapon": "cat_claw",
			"acquired_weapons": ["cat_claw"],
			"weapon_levels": {"cat_claw": 0},
			"currency": currency,
			"inventory": [],
		},
		"world_state": {
			"scene_id": scene_id,
			"defeated_bosses": [],
			"world_flags": {
				"loaded_from_story002": true,
			},
			"last_savepoint": {
				"id": spawn_point,
				"scene_id": scene_id,
				"spawn_point": spawn_point,
				"position": {"x": position.x, "y": position.y},
			},
		},
		"settings": {},
	}
