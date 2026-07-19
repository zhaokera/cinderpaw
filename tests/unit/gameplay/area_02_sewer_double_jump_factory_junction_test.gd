## Scene Management Story 022: Sewer Double Jump junction reaches Factory.
extends GdUnitTestSuite

const SEWER_SCENE: PackedScene = preload("res://scenes/areas/sewer.tscn")
const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const MAIN_SCENE_ID: StringName = &"main"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_SPAWN_POINT: StringName = &"factory_gate_entry"
const FACTORY_UNLOCKED_FLAG: StringName = &"area_03_factory_unlocked"
const SEWER_FACTORY_REACHED_FLAG: StringName = &"sewer_factory_route_reached"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const JUMP_ACTION: StringName = &"jump"
const DASH_ACTION: StringName = &"dash"
const INITIAL_CURRENCY: int = 22

var _roots: Array[Node2D] = []


class FakeSceneManager:
	extends RefCounted

	signal on_scene_changed(old_scene: StringName, new_scene: StringName)

	var requests: Array[Dictionary] = []
	var scene_states: Dictionary = {}
	var loading: bool = false

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == MAIN_SCENE_ID or scene_id == FACTORY_SCENE_ID

	func is_loading() -> bool:
		return loading

	func request_scene_change(
		scene_id: StringName,
		spawn_point: StringName = &"default"
	) -> bool:
		if loading or not has_scene(scene_id):
			return false
		requests.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		loading = true
		return true

	func get_scene_state(scene_id: StringName) -> Dictionary:
		return Dictionary(scene_states.get(String(scene_id), {})).duplicate(true)

	func set_scene_state(scene_id: StringName, state: Dictionary) -> void:
		scene_states[String(scene_id)] = state.duplicate(true)


func after_test() -> void:
	_release_actions()
	for root: Node2D in _roots:
		if not is_instance_valid(root):
			continue
		if root.get_parent() != null:
			root.get_parent().remove_child(root)
		root.free()
	_roots.clear()


func test_real_double_jump_opens_persistent_sewer_factory_junction_once() -> void:
	var sewer: Node2D = _instantiate_scene(SEWER_SCENE)
	assert_object(sewer).is_not_null()
	if sewer == null:
		return
	var scene_manager := FakeSceneManager.new()
	scene_manager.scene_states[String(MAIN_SCENE_ID)] = {
		"unlocked_abilities": ["dash", "double_jump"],
		"currency": INITIAL_CURRENCY,
		"world_flags": {
			"area_02_sewer_unlocked": true,
			"sewer_pressure_ambush_cleared": true,
		},
	}
	assert_bool(bool(sewer.call(
		"configure_scene_manager_runtime",
		scene_manager
	))).is_true()
	sewer.call("set_local_state", {
		"unlocked_abilities": ["dash"],
		"dash_crossed": true,
		"successful_dash_crossings": 1,
		"sewer_pressure_ambush_cleared": true,
		"sewer_pressure_cache_claimed": true,
		"currency": INITIAL_CURRENCY,
	})
	await _wait_physics_frames(2)

	# Intentional RED boundary: Story022 owns this physical junction contract.
	assert_bool(sewer.has_method("get_sewer_factory_junction_diagnostics")).is_true()
	if not sewer.has_method("get_sewer_factory_junction_diagnostics"):
		return

	var player: PlayerController = sewer.get_node_or_null("Player") as PlayerController
	assert_object(player).is_not_null()
	if player == null:
		return
	var activation_trace: Dictionary = {
		"dash_count": 0,
		"double_jump_count": 0,
		"double_jump_position": Vector2.ZERO,
	}
	player.dash_started.connect(func(
		_texture: Texture2D,
		_world_position: Vector2,
		_facing: float
	) -> void:
		activation_trace["dash_count"] = int(
			activation_trace.get("dash_count", 0)
		) + 1
	)
	player.double_jump_started.connect(func(
		_texture: Texture2D,
		world_position: Vector2,
		_facing: float
	) -> void:
		activation_trace["double_jump_count"] = int(
			activation_trace.get("double_jump_count", 0)
		) + 1
		activation_trace["double_jump_position"] = world_position
	)
	var initial: Dictionary = _junction_diagnostics(sewer)
	assert_str(String(initial.get("gate_state", ""))).is_equal("locked")
	assert_bool(bool(initial.get("route_available", true))).is_false()
	assert_bool(bool(initial.get("platform_collision_enabled", false))).is_true()
	assert_str(String(initial.get("platform_texture_path", ""))).is_equal(
		"res://assets/environment/old_factory_route_platform/"
		+ "env_old_factory_route_entry_platform_320x96.png"
	)
	assert_str(String(initial.get("gate_texture_path", ""))).is_equal(
		"res://assets/environment/high_platform_gate/high_platform_gate_marker.png"
	)
	assert_str(String(initial.get("route_texture_path", ""))).is_equal(
		"res://assets/environment/factory_route_transition/"
		+ "factory_route_transition_shell.png"
	)

	player.respawn_at(Vector2(1940.0, 431.0), 1.0)
	var dash_only_result: Dictionary = await _attempt_high_route(
		player,
		scene_manager,
		false
	)
	assert_bool(bool(dash_only_result.get("jump_started", false))).is_true()
	assert_bool(bool(dash_only_result.get("dash_started", false))).is_true()
	assert_float(float(dash_only_result.get("highest_y", 0.0))).is_greater(326.0)
	assert_int(int(activation_trace.get("dash_count", 0))).is_equal(1)
	assert_int(int(activation_trace.get("double_jump_count", 0))).is_equal(0)
	assert_array(scene_manager.requests).is_empty()
	var still_locked: Dictionary = _junction_diagnostics(sewer)
	assert_str(String(still_locked.get("gate_state", ""))).is_equal("locked")
	assert_bool(bool(still_locked.get("route_available", true))).is_false()

	player.respawn_at(Vector2(1940.0, 431.0), 1.0)
	assert_bool(player.unlock_ability(&"double_jump")).is_true()
	var double_jump_result: Dictionary = await _attempt_high_route(
		player,
		scene_manager,
		true
	)
	assert_bool(bool(double_jump_result.get("second_jump_started", false))).is_true()
	assert_int(int(activation_trace.get("double_jump_count", 0))).is_equal(1)
	assert_array(scene_manager.requests).is_equal([{
		"scene_id": "area_03_factory",
		"spawn_point": "factory_gate_entry",
	}])
	var opened: Dictionary = _junction_diagnostics(sewer)
	assert_str(String(opened.get("gate_state", ""))).is_equal("unlocked")
	assert_bool(bool(opened.get("route_available", false))).is_true()
	assert_bool(bool(opened.get("transition_requested", false))).is_true()
	assert_int(int(opened.get("transition_request_count", 0))).is_equal(1)
	assert_str(String(opened.get("last_transition_target_scene", ""))).is_equal(
		String(FACTORY_SCENE_ID)
	)

	var factory_state: Dictionary = scene_manager.get_scene_state(FACTORY_SCENE_ID)
	assert_array(Array(factory_state.get("unlocked_abilities", []))).contains([
		"dash",
		"double_jump",
	])
	assert_int(int(factory_state.get("currency", -1))).is_equal(INITIAL_CURRENCY)
	var main_state: Dictionary = scene_manager.get_scene_state(MAIN_SCENE_ID)
	var world_flags: Dictionary = Dictionary(main_state.get("world_flags", {}))
	assert_bool(bool(world_flags.get(String(FACTORY_UNLOCKED_FLAG), false))).is_true()
	assert_bool(bool(world_flags.get(String(SEWER_FACTORY_REACHED_FLAG), false))).is_true()
	assert_int(int(main_state.get("currency", -1))).is_equal(INITIAL_CURRENCY)

	var saved_state: Dictionary = Dictionary(sewer.call("get_local_state"))
	var cold_sewer: Node2D = _instantiate_scene(SEWER_SCENE)
	assert_object(cold_sewer).is_not_null()
	if cold_sewer == null:
		return
	cold_sewer.call("set_local_state", saved_state)
	await _wait_physics_frames(2)
	var restored: Dictionary = _junction_diagnostics(cold_sewer)
	assert_str(String(restored.get("gate_state", ""))).is_equal("unlocked")
	assert_bool(bool(restored.get("route_available", false))).is_true()
	assert_bool(bool(restored.get("transition_requested", true))).is_false()
	assert_int(int(restored.get("currency", -1))).is_equal(INITIAL_CURRENCY)

	var main: Node2D = _instantiate_scene(MAIN_SCENE)
	main.call("set_world_progress_flag", FACTORY_UNLOCKED_FLAG, true)
	var before_sewer: Dictionary = Dictionary(main.call(
		"get_boss2_victory_route_handoff_diagnostics"
	))
	assert_bool(bool(before_sewer.get("factory_route_available", true))).is_false()
	main.call("set_world_progress_flag", SEWER_FACTORY_REACHED_FLAG, true)
	var after_sewer: Dictionary = Dictionary(main.call(
		"get_boss2_victory_route_handoff_diagnostics"
	))
	assert_bool(bool(after_sewer.get("factory_route_available", true))).is_false()
	var shortcut_manager := FakeSceneManager.new()
	shortcut_manager.scene_states[String(FACTORY_SCENE_ID)] = {
		"factory_service_lift_exit_requested": true,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
	}
	assert_bool(bool(main.call(
		"configure_scene_manager_runtime",
		shortcut_manager
	))).is_true()
	main.call("set_world_progress_flag", FACTORY_UNLOCKED_FLAG, true)
	var after_lift: Dictionary = Dictionary(main.call(
		"get_boss2_victory_route_handoff_diagnostics"
	))
	assert_bool(bool(after_lift.get("factory_route_available", false))).is_true()


func _instantiate_scene(packed_scene: PackedScene) -> Node2D:
	var root: Node2D = packed_scene.instantiate() as Node2D
	if root == null:
		return null
	if String(root.name) == "SewerDashRoute":
		root.set("auto_configure_runtime_services", false)
	add_child(root)
	_roots.append(root)
	return root


func _attempt_high_route(
	player: PlayerController,
	scene_manager: FakeSceneManager,
	use_double_jump: bool
) -> Dictionary:
	var result: Dictionary = {
		"jump_started": false,
		"dash_started": false,
		"second_jump_started": false,
		"highest_y": player.global_position.y,
		"furthest_x": player.global_position.x,
		"final_position": player.global_position,
	}
	Input.action_press(MOVE_RIGHT_ACTION)
	Input.action_press(JUMP_ACTION)
	for frame: int in range(180 if use_double_jump else 48):
		if frame == 1:
			Input.action_release(JUMP_ACTION)
		if not use_double_jump and frame == 10:
			Input.action_press(DASH_ACTION)
		if not use_double_jump and frame == 11:
			Input.action_release(DASH_ACTION)
		if use_double_jump and frame == 22:
			Input.action_press(JUMP_ACTION)
		if use_double_jump and frame == 23:
			Input.action_release(JUMP_ACTION)
		await get_tree().physics_frame
		result["highest_y"] = minf(
			float(result.get("highest_y", player.global_position.y)),
			player.global_position.y
		)
		result["furthest_x"] = maxf(
			float(result.get("furthest_x", player.global_position.x)),
			player.global_position.x
		)
		result["final_position"] = player.global_position
		result["jump_started"] = bool(result.get("jump_started", false)) \
			or player.global_position.y < 420.0
		result["dash_started"] = bool(result.get("dash_started", false)) \
			or frame >= 10
		result["second_jump_started"] = bool(
			result.get("second_jump_started", false)
		) or (use_double_jump and frame >= 22 and player.velocity.y < -200.0)
		if not scene_manager.requests.is_empty():
			break
	_release_actions()
	return result


func _junction_diagnostics(sewer: Node) -> Dictionary:
	return Dictionary(sewer.call("get_sewer_factory_junction_diagnostics"))


func _wait_physics_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().physics_frame


func _release_actions() -> void:
	Input.action_release(MOVE_RIGHT_ACTION)
	Input.action_release(JUMP_ACTION)
	Input.action_release(DASH_ACTION)
