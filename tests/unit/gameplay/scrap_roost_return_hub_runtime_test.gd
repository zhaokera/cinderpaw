## Player Abilities Story 039: Scrap Roost return hub closure.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const MAIN_SCENE_ID: StringName = &"main"
const SCRAP_ROOST_SPAWN_POINT: StringName = &"scrap_roost"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_ROUTE_UNLOCKED_FLAG: StringName = &"area_03_factory_unlocked"
const RETURN_HUB_FLAG: String = "scrap_roost_return_hub_secured"
const SCRAP_ROOST_SAVEPOINT_PATH: String = "ScrapRoostSavepoint"

var _scene: Node2D


class FakeReturnHubSceneManager:
	extends RefCounted

	signal on_scene_load_started(scene_id: StringName, spawn_point: StringName, metadata: Dictionary)
	signal on_scene_changed(old_scene: StringName, new_scene: StringName)
	signal on_scene_load_failed(scene_id: StringName, reason: StringName)

	var current_scene: StringName = MAIN_SCENE_ID
	var current_spawn_point: StringName = SCRAP_ROOST_SPAWN_POINT
	var scene_states: Dictionary = {}

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn_point

	func get_scene_state(scene_id: StringName) -> Dictionary:
		return Dictionary(scene_states.get(String(scene_id), {})).duplicate(true)

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == MAIN_SCENE_ID or scene_id == FACTORY_SCENE_ID

	func request_scene_change(scene_id: StringName, spawn_point: StringName = &"default") -> bool:
		return has_scene(scene_id) and spawn_point != &""


func before_test() -> void:
	_scene = MAIN_SCENE.instantiate() as Node2D
	add_child(_scene)


func after_test() -> void:
	if is_instance_valid(_scene):
		if _scene.get_parent() != null:
			_scene.get_parent().remove_child(_scene)
		_scene.free()
	_scene = null


func test_service_lift_return_secures_scrap_roost_hub_once() -> void:
	var scene_manager := FakeReturnHubSceneManager.new()
	scene_manager.scene_states[String(FACTORY_SCENE_ID)] = _service_lift_return_state()
	assert_bool(bool(_scene.call("configure_scene_manager_runtime", scene_manager))).is_true()
	_scene.call("set_world_progress_flag", FACTORY_ROUTE_UNLOCKED_FLAG, true)

	var savepoint: Node2D = _scene.get_node_or_null(SCRAP_ROOST_SAVEPOINT_PATH) as Node2D
	assert_that(savepoint).is_not_null()
	if savepoint == null:
		return
	var discovered: Dictionary = Dictionary(_scene.call("get_last_discovered_savepoint"))
	assert_bool(String(discovered.get("id", "")) == "scrap_roost").is_true()
	assert_bool(String(discovered.get("scene_id", "")) == "main").is_true()
	assert_bool(String(discovered.get("spawn_point", "")) == "scrap_roost").is_true()
	assert_float(float(discovered.get("position", {}).get("x", 0.0))).is_equal_approx(
		savepoint.global_position.x,
		0.001
	)
	assert_float(float(discovered.get("position", {}).get("y", 0.0))).is_equal_approx(
		savepoint.global_position.y,
		0.001
	)

	var state: Dictionary = Dictionary(_scene.call("get_runtime_progress_state"))
	assert_bool(bool(state.get("world_flags", {}).get(RETURN_HUB_FLAG, false))).is_true()
	assert_bool(String(state.get("last_savepoint", {}).get("id", "")) == "scrap_roost").is_true()
	var route_diagnostics: Dictionary = _scene.call("get_boss2_victory_route_handoff_diagnostics")
	assert_bool(
		String(route_diagnostics.get("factory_route_prompt_text", "")) == "Return to Factory Route"
	).is_true()
	assert_bool(
		String(route_diagnostics.get("hud_notification_text", "")) == "Returned to Scrap Roost"
	).is_true()

	_scene.call("configure_scene_manager_runtime", scene_manager)
	var repeated: Dictionary = _scene.call("get_boss2_victory_route_handoff_diagnostics")
	assert_bool(
		String(repeated.get("hud_notification_text", "")) == "Returned to Scrap Roost"
	).is_true()


func test_incomplete_factory_return_state_does_not_secure_scrap_roost_hub() -> void:
	var scene_manager := FakeReturnHubSceneManager.new()
	scene_manager.scene_states[String(FACTORY_SCENE_ID)] = {
		"factory_service_lift_exit_requested": true,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "wrong_spawn",
	}
	assert_bool(bool(_scene.call("configure_scene_manager_runtime", scene_manager))).is_true()

	assert_dict(Dictionary(_scene.call("get_last_discovered_savepoint"))).is_empty()
	var state: Dictionary = Dictionary(_scene.call("get_runtime_progress_state"))
	assert_bool(bool(state.get("world_flags", {}).get(RETURN_HUB_FLAG, false))).is_false()
	var route_diagnostics: Dictionary = _scene.call("get_boss2_victory_route_handoff_diagnostics")
	assert_bool(
		String(route_diagnostics.get("hud_notification_text", "")) != "Returned to Scrap Roost"
	).is_true()


func _service_lift_return_state() -> Dictionary:
	return {
		"factory_service_lift_exit_requested": true,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
	}
