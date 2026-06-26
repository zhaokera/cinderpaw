## MainScene runtime savepoint trigger coverage.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const GAME_FLOW_SCRIPT: Script = preload("res://src/gameplay/game_flow_controller.gd")
const SAVE_SYSTEM_PATH: String = "res://src/feature/save_system.gd"
const TEST_SAVE_DIR: String = "user://cinderpaw_main_scene_savepoint_runtime/"
const SAVEPOINT_NODE_PATH: String = "ScrapRoostSavepoint"
const SAVEPOINT_AREA_PATH: String = "ScrapRoostSavepoint/InteractionArea"
const SAVEPOINT_TEXTURE_PREFIX: String = "res://assets/environment/savepoints/"

var save_system: Node
var scene: Node2D
var _respawn_events: Array[Dictionary] = []


class FakeSceneManager:
	extends RefCounted

	var change_calls: Array[Dictionary] = []

	func has_scene(scene_id: StringName) -> bool:
		return String(scene_id) == "main" or String(scene_id) == "hub"

	func change_scene(scene_id: StringName, spawn_point: StringName = &"default") -> bool:
		change_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		return has_scene(scene_id)


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
	_respawn_events.clear()
	_cleanup_test_save_dir()


func test_main_scene_has_visible_scrap_roost_savepoint_trigger() -> void:
	if scene == null:
		return
	assert_bool(scene.has_node(SAVEPOINT_NODE_PATH)).is_true()
	if not scene.has_node(SAVEPOINT_NODE_PATH):
		return

	var savepoint: Node = scene.get_node(SAVEPOINT_NODE_PATH)
	assert_bool(savepoint.is_in_group("savepoint")).is_true()
	assert_str(String(savepoint.get("savepoint_id"))).is_equal("scrap_roost")
	assert_str(String(savepoint.get("scene_id"))).is_equal("main")
	assert_str(String(savepoint.get("spawn_point"))).is_equal("scrap_roost")

	var visual: Sprite2D = savepoint.get_node("Visual") as Sprite2D
	assert_that(visual).is_not_null()
	assert_that(visual.texture).is_not_null()
	assert_str(visual.texture.resource_path).starts_with(SAVEPOINT_TEXTURE_PREFIX)

	var area: Area2D = savepoint.get_node("InteractionArea") as Area2D
	assert_that(area).is_not_null()
	assert_that(area.get_node("CollisionShape2D")).is_not_null()


func test_touching_scrap_roost_savepoint_discovers_it_and_autosaves_slot_zero() -> void:
	if scene == null or save_system == null:
		return
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()
	assert_bool(scene.has_node(SAVEPOINT_AREA_PATH)).is_true()
	if not scene.has_node(SAVEPOINT_AREA_PATH):
		return

	var player: Node = scene.get_node("Player")
	var area: Area2D = scene.get_node(SAVEPOINT_AREA_PATH) as Area2D
	area.body_entered.emit(player)

	var discovered: Dictionary = Dictionary(scene.call("get_last_discovered_savepoint"))
	assert_str(String(discovered["id"])).is_equal("scrap_roost")
	assert_str(String(discovered["scene_id"])).is_equal("main")
	assert_str(String(discovered["spawn_point"])).is_equal("scrap_roost")
	assert_float(float(discovered["position"]["x"])).is_equal_approx(
		scene.get_node(SAVEPOINT_NODE_PATH).global_position.x,
		0.001
	)
	assert_float(float(discovered["position"]["y"])).is_equal_approx(
		scene.get_node(SAVEPOINT_NODE_PATH).global_position.y,
		0.001
	)

	assert_bool(bool(save_system.call("has_save", 0))).is_true()
	assert_bool(bool(save_system.call("has_save", 1))).is_false()
	var saved: Dictionary = _read_json(_slot_path(0))
	assert_bool(bool(saved["_meta"]["is_auto"])).is_true()
	assert_str(String(saved["world_state"]["autosave_reason"])).is_equal("savepoint")
	assert_str(String(saved["world_state"]["autosave_context"]["savepoint_id"])).is_equal("scrap_roost")
	assert_str(String(saved["world_state"]["last_savepoint"]["id"])).is_equal("scrap_roost")


func test_non_boss_death_after_touching_savepoint_respawns_at_scrap_roost() -> void:
	if scene == null or save_system == null:
		return
	assert_bool(bool(scene.call("configure_save_system_runtime", save_system))).is_true()
	var player: Node = scene.get_node("Player")
	var area: Area2D = scene.get_node(SAVEPOINT_AREA_PATH) as Area2D
	area.body_entered.emit(player)

	var flow: Node = GAME_FLOW_SCRIPT.new()
	add_child(flow)
	flow.call("set_savepoint_adapter", scene)
	var scene_manager := FakeSceneManager.new()
	flow.call("set_scene_transition_adapter", scene_manager)
	flow.call("configure_clan_base_respawn", &"hub", &"clan_base", Vector2(24, 42))
	flow.call("start_encounter", Vector2(24, 42))
	flow.connect("respawn_requested", _on_respawn_requested)

	flow.call("handle_player_death")
	flow.call("advance_time", 1.51)

	assert_int(scene_manager.change_calls.size()).is_equal(1)
	assert_str(String(scene_manager.change_calls[0]["scene_id"])).is_equal("main")
	assert_str(String(scene_manager.change_calls[0]["spawn_point"])).is_equal("scrap_roost")
	assert_str(String(flow.call("get_last_selected_respawn_point")["source"])).is_equal("savepoint")
	assert_int(_respawn_events.size()).is_equal(1)
	assert_vector(_respawn_events[0]["position"]).is_equal(scene.get_node(SAVEPOINT_NODE_PATH).global_position)

	if flow.get_parent() != null:
		flow.get_parent().remove_child(flow)
	flow.free()


func _read_json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	assert_bool(parsed is Dictionary).is_true()
	return Dictionary(parsed)


func _slot_path(slot: int) -> String:
	return "%sslot_%d.json" % [TEST_SAVE_DIR, slot]


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
