## Story 004: Savepoint respawn selection via SceneManager.
extends GdUnitTestSuite

const GAME_FLOW_SCRIPT: Script = preload("res://src/gameplay/game_flow_controller.gd")
const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const SAVE_SYSTEM_PATH: String = "res://src/feature/save_system.gd"
const TEST_SAVE_DIR: String = "user://cinderpaw_savepoint_respawn_story004/"

var flow
var _respawn_events: Array[Dictionary] = []


class FakeSavepointAdapter:
	extends RefCounted

	var savepoint: Dictionary = {}

	func get_last_discovered_savepoint() -> Dictionary:
		return savepoint.duplicate(true)


class FakeSceneManager:
	extends RefCounted

	var known_scenes: Dictionary = {
		"hub": true,
		"main": true,
	}
	var change_calls: Array[Dictionary] = []

	func has_scene(scene_id: StringName) -> bool:
		return bool(known_scenes.get(String(scene_id), false))

	func change_scene(scene_id: StringName, spawn_point: StringName = &"default") -> bool:
		change_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		return has_scene(scene_id)


func before_test() -> void:
	flow = GAME_FLOW_SCRIPT.new()
	add_child(flow)
	_respawn_events.clear()
	flow.respawn_requested.connect(_on_respawn_requested)


func after_test() -> void:
	if is_instance_valid(flow):
		if flow.get_parent() != null:
			flow.get_parent().remove_child(flow)
		flow.free()
	flow = null
	_respawn_events.clear()
	_cleanup_test_save_dir()


func test_last_discovered_savepoint_is_preferred_and_routed_through_scene_manager() -> void:
	var savepoints := FakeSavepointAdapter.new()
	savepoints.savepoint = {
		"id": "scrap_roost",
		"scene_id": "main",
		"spawn_point": "scrap_roost",
		"position": Vector2(512, 320),
	}
	var scene_manager := FakeSceneManager.new()
	flow.set_savepoint_adapter(savepoints)
	flow.set_scene_transition_adapter(scene_manager)
	flow.configure_clan_base_respawn(&"hub", &"clan_base", Vector2(24, 42))
	flow.start_encounter(Vector2(24, 42))

	flow.handle_player_death()
	flow.advance_time(1.51)

	assert_int(scene_manager.change_calls.size()).is_equal(1)
	assert_str(String(scene_manager.change_calls[0]["scene_id"])).is_equal("main")
	assert_str(String(scene_manager.change_calls[0]["spawn_point"])).is_equal("scrap_roost")
	assert_int(_respawn_events.size()).is_equal(1)
	assert_vector(_respawn_events[0]["position"]).is_equal(Vector2(512, 320))
	assert_str(String(flow.get_last_selected_respawn_point()["source"])).is_equal("savepoint")


func test_missing_or_invalid_savepoint_falls_back_to_clan_base() -> void:
	var savepoints := FakeSavepointAdapter.new()
	savepoints.savepoint = {
		"id": "deleted_nest",
		"scene_id": "deleted_scene",
		"spawn_point": "deleted_spawn",
		"position": Vector2(999, 888),
	}
	var scene_manager := FakeSceneManager.new()
	flow.set_savepoint_adapter(savepoints)
	flow.set_scene_transition_adapter(scene_manager)
	flow.configure_clan_base_respawn(&"hub", &"clan_base", Vector2(24, 42))
	flow.start_encounter(Vector2(24, 42))

	flow.handle_player_death()
	flow.advance_time(1.51)

	assert_int(scene_manager.change_calls.size()).is_equal(1)
	assert_str(String(scene_manager.change_calls[0]["scene_id"])).is_equal("hub")
	assert_str(String(scene_manager.change_calls[0]["spawn_point"])).is_equal("clan_base")
	assert_int(_respawn_events.size()).is_equal(1)
	assert_vector(_respawn_events[0]["position"]).is_equal(Vector2(24, 42))
	assert_str(String(flow.get_last_selected_respawn_point()["source"])).is_equal("clan_base")


func test_boss_entrance_remains_higher_priority_than_discovered_savepoint() -> void:
	var savepoints := FakeSavepointAdapter.new()
	savepoints.savepoint = {
		"id": "scrap_roost",
		"scene_id": "main",
		"spawn_point": "scrap_roost",
		"position": Vector2(512, 320),
	}
	var scene_manager := FakeSceneManager.new()
	flow.set_savepoint_adapter(savepoints)
	flow.set_scene_transition_adapter(scene_manager)
	flow.configure_clan_base_respawn(&"hub", &"clan_base", Vector2(24, 42))
	flow.configure_boss_entrance_respawn(&"main", &"boss_entrance", Vector2(640, 384))
	flow.start_boss_encounter(Vector2(640, 384), RefCounted.new())

	flow.handle_player_death()
	flow.advance_time(1.51)

	assert_int(scene_manager.change_calls.size()).is_equal(1)
	assert_str(String(scene_manager.change_calls[0]["scene_id"])).is_equal("main")
	assert_str(String(scene_manager.change_calls[0]["spawn_point"])).is_equal("boss_entrance")
	assert_int(_respawn_events.size()).is_equal(1)
	assert_vector(_respawn_events[0]["position"]).is_equal(Vector2(640, 384))
	assert_str(String(flow.get_last_selected_respawn_point()["source"])).is_equal("boss_entrance")


func test_main_scene_save_system_round_trips_last_discovered_savepoint() -> void:
	var save_script: Script = load(SAVE_SYSTEM_PATH)
	assert_that(save_script).is_not_null()
	assert_bool(save_script != null and save_script.can_instantiate()).is_true()
	if save_script == null or not save_script.can_instantiate():
		return

	var save_system: Node = save_script.new()
	add_child(save_system)
	save_system.call("configure_save_directory", TEST_SAVE_DIR)
	if save_system.has_method("set_async_write_enabled"):
		save_system.call("set_async_write_enabled", false)

	var scene: Node2D = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()

	assert_bool(bool(scene.call(
		"discover_savepoint",
		&"scrap_roost",
		&"main",
		&"scrap_roost",
		Vector2(512, 320)
	))).is_true()
	assert_bool(bool(scene.call("save_runtime_to_slot", 1))).is_true()

	assert_bool(bool(scene.call("clear_last_discovered_savepoint"))).is_true()
	assert_dict(Dictionary(scene.call("get_last_discovered_savepoint"))).is_empty()

	assert_bool(bool(scene.call("load_runtime_from_slot", 1))).is_true()
	var restored: Dictionary = Dictionary(scene.call("get_last_discovered_savepoint"))

	assert_str(String(restored["id"])).is_equal("scrap_roost")
	assert_str(String(restored["scene_id"])).is_equal("main")
	assert_str(String(restored["spawn_point"])).is_equal("scrap_roost")
	assert_float(float(restored["position"]["x"])).is_equal_approx(512.0, 0.001)
	assert_float(float(restored["position"]["y"])).is_equal_approx(320.0, 0.001)

	scene.queue_free()
	save_system.queue_free()


func _on_respawn_requested(position: Vector2, revive_hp_percentage: float) -> void:
	_respawn_events.append({
		"position": position,
		"revive_hp_percentage": revive_hp_percentage,
	})


func _cleanup_test_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(TEST_SAVE_DIR):
		return
	for file_name: String in DirAccess.get_files_at(TEST_SAVE_DIR):
		DirAccess.remove_absolute(TEST_SAVE_DIR.path_join(file_name))
	DirAccess.remove_absolute(TEST_SAVE_DIR)
