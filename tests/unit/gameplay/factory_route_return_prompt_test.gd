## Player Abilities Story 038: Factory route return prompt.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_SPAWN_POINT: StringName = &"factory_gate_entry"
const FACTORY_ROUTE_UNLOCKED_FLAG: StringName = &"area_03_factory_unlocked"
const FACTORY_ROUTE_TRIGGER_NAME: String = "FactoryRouteTransitionShell"

var _scene: Node2D


class FakeFactorySceneManager:
	extends RefCounted

	signal on_scene_load_started(scene_id: StringName, spawn_point: StringName, metadata: Dictionary)
	signal on_scene_changed(old_scene: StringName, new_scene: StringName)
	signal on_scene_load_failed(scene_id: StringName, reason: StringName)

	var request_calls: Array[Dictionary] = []
	var loading: bool = false
	var runtime_root_configured: bool = false
	var current_scene_node: Node = null
	var scene_states: Dictionary = {}

	func has_scene(scene_id: StringName) -> bool:
		return String(scene_id) == "main" or scene_id == FACTORY_SCENE_ID

	func get_scene_config(scene_id: StringName) -> Dictionary:
		if scene_id == FACTORY_SCENE_ID:
			return {
				"scene_id": String(FACTORY_SCENE_ID),
				"default_spawn": String(FACTORY_SPAWN_POINT),
				"display_name": "Factory Route",
			}
		return {
			"scene_id": String(scene_id),
			"default_spawn": "default",
			"display_name": "Scrap Alley",
		}

	func get_current_scene() -> StringName:
		return &"main"

	func get_current_spawn_point() -> StringName:
		return &"scrap_roost"

	func get_scene_state(scene_id: StringName) -> Dictionary:
		return Dictionary(scene_states.get(String(scene_id), {})).duplicate(true)

	func is_loading() -> bool:
		return loading

	func is_runtime_scene_swap_enabled() -> bool:
		return runtime_root_configured

	func configure_runtime_scene_root(root: Node, current_scene: Node = null) -> bool:
		runtime_root_configured = root != null and current_scene != null
		current_scene_node = current_scene
		return runtime_root_configured

	func request_scene_change(scene_id: StringName, spawn_point: StringName = &"default") -> bool:
		if loading or not has_scene(scene_id):
			return false
		request_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		loading = true
		var metadata: Dictionary = get_scene_config(scene_id)
		metadata["transition_duration_sec"] = 1.5
		on_scene_load_started.emit(scene_id, spawn_point, metadata)
		return true


func before_test() -> void:
	_scene = MAIN_SCENE.instantiate() as Node2D
	add_child(_scene)


func after_test() -> void:
	if is_instance_valid(_scene):
		if _scene.get_parent() != null:
			_scene.get_parent().remove_child(_scene)
		_scene.free()
	_scene = null


func test_factory_route_prompt_changes_to_return_after_service_lift_roundtrip() -> void:
	var scene_manager := FakeFactorySceneManager.new()
	assert_bool(bool(_scene.call("configure_scene_manager_runtime", scene_manager))).is_true()

	_scene.call("set_world_progress_flag", FACTORY_ROUTE_UNLOCKED_FLAG, true)
	var initial: Dictionary = _scene.call("get_boss2_victory_route_handoff_diagnostics")
	assert_bool(bool(initial.get("factory_route_available", false))).is_true()
	assert_str(String(initial.get("factory_route_prompt_text", ""))).is_equal("Enter Factory Route")

	scene_manager.scene_states[String(FACTORY_SCENE_ID)] = {
		"factory_service_lift_exit_requested": true,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
	}
	_scene.call("set_world_progress_flag", FACTORY_ROUTE_UNLOCKED_FLAG, true)
	var returned: Dictionary = _scene.call("get_boss2_victory_route_handoff_diagnostics")
	assert_str(String(returned.get("factory_route_prompt_text", ""))).is_equal(
		"Return to Factory Route"
	)

	var route_shell: Node2D = _scene.get_node_or_null(FACTORY_ROUTE_TRIGGER_NAME) as Node2D
	var player: Node2D = _scene.get_node_or_null("Player") as Node2D
	assert_that(route_shell).is_not_null()
	assert_that(player).is_not_null()
	if route_shell == null or player == null:
		return
	player.global_position = route_shell.global_position
	assert_bool(bool(_scene.call("request_factory_route_transition", player))).is_true()
	assert_int(scene_manager.request_calls.size()).is_equal(1)
	assert_str(String(scene_manager.request_calls[0].get("scene_id", ""))).is_equal(
		String(FACTORY_SCENE_ID)
	)
	assert_str(String(scene_manager.request_calls[0].get("spawn_point", ""))).is_equal(
		String(FACTORY_SPAWN_POINT)
	)


func test_factory_route_prompt_ignores_incomplete_return_state_and_locked_route() -> void:
	var scene_manager := FakeFactorySceneManager.new()
	assert_bool(bool(_scene.call("configure_scene_manager_runtime", scene_manager))).is_true()

	scene_manager.scene_states[String(FACTORY_SCENE_ID)] = {
		"factory_service_lift_exit_requested": true,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "wrong_spawn",
	}
	_scene.call("set_world_progress_flag", FACTORY_ROUTE_UNLOCKED_FLAG, false)
	var locked: Dictionary = _scene.call("get_boss2_victory_route_handoff_diagnostics")
	assert_bool(bool(locked.get("factory_route_available", true))).is_false()
	assert_str(String(locked.get("factory_route_prompt_text", ""))).is_equal("Factory route locked")

	_scene.call("set_world_progress_flag", FACTORY_ROUTE_UNLOCKED_FLAG, true)
	var incomplete: Dictionary = _scene.call("get_boss2_victory_route_handoff_diagnostics")
	assert_bool(bool(incomplete.get("factory_route_available", false))).is_true()
	assert_str(String(incomplete.get("factory_route_prompt_text", ""))).is_equal("Enter Factory Route")
