## Scene Management Story 020: Main Dash gate opens a playable Sewer route.
extends GdUnitTestSuite

const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"
const SEWER_SCENE_PATH: String = "res://scenes/areas/sewer.tscn"
const SCENE_MANAGER_SCRIPT: Script = preload("res://src/feature/scene_manager.gd")
const MAIN_SCENE: PackedScene = preload(MAIN_SCENE_PATH)
const MAIN_SCENE_ID: StringName = &"main"
const SEWER_SCENE_ID: StringName = &"area_02_sewer"
const SEWER_ENTRY_SPAWN: StringName = &"default"
const MAIN_RETURN_SPAWN: StringName = &"sewer_return"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const JUMP_ACTION: StringName = &"jump"
const DASH_ACTION: StringName = &"dash"
const THREAD_LOAD_LOADED: int = 3
const TRANSITION_SECONDS: float = 1.5
const MAIN_GATE_DASH_X: float = 930.0
const SEWER_GAP_ACTION_X: float = 530.0

var _runtime_root: Node = null
var _scene_manager: Node = null
var _loader: RouteLoaderAdapter = null


class RouteLoaderAdapter:
	extends RefCounted

	var request_calls: Array[Dictionary] = []
	var _sewer_scene: PackedScene

	func _init(sewer_scene: PackedScene) -> void:
		_sewer_scene = sewer_scene

	func load_threaded_request(
		path: String,
		type_hint: String = "",
		use_sub_threads: bool = false,
		cache_mode: int = 1
	) -> int:
		request_calls.append({
			"path": path,
			"type_hint": type_hint,
			"use_sub_threads": use_sub_threads,
			"cache_mode": cache_mode,
		})
		return OK

	func load_threaded_get_status(_path: String, _progress: Array = []) -> int:
		return THREAD_LOAD_LOADED

	func load_threaded_get(path: String) -> Resource:
		if path == MAIN_SCENE_PATH:
			return MAIN_SCENE
		if path == SEWER_SCENE_PATH:
			return _sewer_scene
		return null


func after_test() -> void:
	_release_actions()
	_stop_runtime_audio_players()
	_runtime_root = null
	_scene_manager = null
	_loader = null


func test_real_dash_enters_sewer_resets_failed_jump_and_returns_once() -> void:
	var sewer_scene: PackedScene = load(SEWER_SCENE_PATH) as PackedScene
	assert_object(sewer_scene).is_not_null()
	if sewer_scene == null:
		return

	_scene_manager = _configured_scene_manager(sewer_scene)
	_runtime_root = auto_free(Node.new()) as Node
	_runtime_root.name = "RuntimeRoot"
	add_child(_runtime_root)
	var main_scene: Node = auto_free(MAIN_SCENE.instantiate()) as Node
	_runtime_root.add_child(main_scene)
	assert_bool(bool(_scene_manager.call(
		"change_scene",
		MAIN_SCENE_ID,
		&"default",
	))).is_true()
	assert_bool(bool(main_scene.call(
		"configure_scene_manager_runtime",
		_scene_manager,
	))).is_true()
	main_scene.call("set_world_progress_flag", &"boss_02_intermission_started", true)
	main_scene.call("set_world_progress_flag", &"boss_rat_king_defeated", true)
	main_scene.call("unlock_ability", &"dash")

	var main_player: PlayerController = main_scene.get_node("Player") as PlayerController
	assert_bool(await _enter_sewer_with_real_dash(main_player)).is_true()
	assert_str(String(_scene_manager.call("get_pending_scene"))).is_equal(
		String(SEWER_SCENE_ID)
	)
	assert_str(String(_scene_manager.call("get_pending_spawn_point"))).is_equal(
		String(SEWER_ENTRY_SPAWN)
	)

	_scene_manager.call("advance_loading", TRANSITION_SECONDS)
	var sewer: Node = _runtime_root.get_child(0)
	auto_free(sewer)
	assert_str(sewer.name).is_equal("SewerDashRoute")
	assert_str(String(_scene_manager.call("get_current_scene"))).is_equal(
		String(SEWER_SCENE_ID)
	)
	var sewer_player: PlayerController = sewer.get_node("Player") as PlayerController
	assert_bool(sewer_player.has_ability(&"dash")).is_true()
	var sprite: AnimatedSprite2D = sewer_player.get_node("Sprite") as AnimatedSprite2D
	assert_int(sprite.sprite_frames.get_frame_count(&"dash")).is_greater_equal(3)

	assert_bool(await _fail_gap_with_real_jump(sewer, sewer_player)).is_true()
	var failed: Dictionary = Dictionary(sewer.call("get_sewer_route_diagnostics"))
	assert_int(int(failed.get("reset_count", 0))).is_equal(1)
	assert_bool(bool(failed.get("dash_crossed", true))).is_false()
	assert_bool(bool(failed.get("transition_requested", true))).is_false()

	assert_bool(await _cross_gap_with_real_dash(sewer, sewer_player)).is_true()
	var crossed: Dictionary = Dictionary(sewer.call("get_sewer_route_diagnostics"))
	assert_bool(bool(crossed.get("dash_crossed", false))).is_true()
	assert_int(int(crossed.get("successful_dash_crossings", 0))).is_equal(1)
	# Story021 owns the new deep-room fight; this regression stays on Dash/round trip.
	var return_ready_state: Dictionary = Dictionary(sewer.call("get_local_state"))
	return_ready_state["sewer_pressure_ambush_cleared"] = true
	sewer.call("set_local_state", return_ready_state)
	sewer_player.respawn_at(Vector2(2380.0, 431.0), 1.0)
	assert_bool(await _reach_sewer_exit(sewer, sewer_player)).is_true()
	assert_str(String(_scene_manager.call("get_pending_scene"))).is_equal(
		String(MAIN_SCENE_ID)
	)
	assert_str(String(_scene_manager.call("get_pending_spawn_point"))).is_equal(
		String(MAIN_RETURN_SPAWN)
	)

	_scene_manager.call("advance_loading", TRANSITION_SECONDS)
	var returned_main: Node = _runtime_root.get_child(0)
	assert_str(returned_main.name).is_equal("Main")
	assert_str(String(_scene_manager.call("get_current_scene"))).is_equal(
		String(MAIN_SCENE_ID)
	)
	assert_str(String(_scene_manager.call("get_current_spawn_point"))).is_equal(
		String(MAIN_RETURN_SPAWN)
	)
	var return_spawn: Node2D = returned_main.get_node("SewerReturnSpawn") as Node2D
	var returned_player: Node2D = returned_main.get_node("Player") as Node2D
	assert_float(returned_player.global_position.distance_to(
		return_spawn.global_position
	)).is_less_equal(2.0)
	var main_state: Dictionary = Dictionary(_scene_manager.call(
		"get_scene_state",
		MAIN_SCENE_ID,
	))
	var world_flags: Dictionary = Dictionary(main_state.get("world_flags", {}))
	assert_bool(bool(world_flags.get("area_02_sewer_unlocked", false))).is_true()
	assert_bool(bool(world_flags.get("sewer_dash_route_crossed", false))).is_true()
	var returned_handoff: Dictionary = Dictionary(returned_main.call(
		"get_sewer_route_handoff_diagnostics",
	))
	assert_bool(bool(returned_handoff.get("dash_gate_unlocked", false))).is_true()
	assert_int(_loader.request_calls.size()).is_equal(2)


func _configured_scene_manager(sewer_scene: PackedScene) -> Node:
	var manager: Node = auto_free(SCENE_MANAGER_SCRIPT.new()) as Node
	add_child(manager)
	assert_bool(bool(manager.call("configure_scene_registry", {
		"main": {
			"scene_id": "main",
			"path": MAIN_SCENE_PATH,
			"type": "area",
			"preload": true,
			"default_spawn": "default",
			"display_name": "Scrap Roost",
		},
		"area_02_sewer": {
			"scene_id": "area_02_sewer",
			"path": SEWER_SCENE_PATH,
			"type": "area",
			"preload": false,
			"default_spawn": "default",
			"display_name": "Sewer Dash Channel",
		},
	}))).is_true()
	_loader = RouteLoaderAdapter.new(sewer_scene)
	manager.call("set_loader_adapter", _loader)
	return manager


func _enter_sewer_with_real_dash(player: PlayerController) -> bool:
	Input.action_press(MOVE_RIGHT_ACTION)
	var dash_pressed: bool = false
	for _frame: int in range(360):
		if not dash_pressed and player.global_position.x >= MAIN_GATE_DASH_X:
			dash_pressed = true
			Input.action_press(DASH_ACTION)
		await get_tree().physics_frame
		if Input.is_action_pressed(DASH_ACTION):
			Input.action_release(DASH_ACTION)
		if bool(_scene_manager.call("is_loading")):
			Input.action_release(MOVE_RIGHT_ACTION)
			return dash_pressed
	Input.action_release(MOVE_RIGHT_ACTION)
	return false


func _fail_gap_with_real_jump(root: Node, player: PlayerController) -> bool:
	Input.action_press(MOVE_RIGHT_ACTION)
	var jump_pressed: bool = false
	for _frame: int in range(300):
		if not jump_pressed and player.global_position.x >= SEWER_GAP_ACTION_X:
			jump_pressed = true
			Input.action_press(JUMP_ACTION)
		await get_tree().physics_frame
		if Input.is_action_pressed(JUMP_ACTION):
			Input.action_release(JUMP_ACTION)
		var diagnostics: Dictionary = Dictionary(root.call("get_sewer_route_diagnostics"))
		if int(diagnostics.get("reset_count", 0)) >= 1:
			Input.action_release(MOVE_RIGHT_ACTION)
			return jump_pressed
	Input.action_release(MOVE_RIGHT_ACTION)
	return false


func _cross_gap_with_real_dash(root: Node, player: PlayerController) -> bool:
	Input.action_press(MOVE_RIGHT_ACTION)
	var dash_pressed: bool = false
	for _frame: int in range(300):
		if not dash_pressed and player.global_position.x >= SEWER_GAP_ACTION_X:
			dash_pressed = true
			Input.action_press(DASH_ACTION)
		await get_tree().physics_frame
		if Input.is_action_pressed(DASH_ACTION):
			Input.action_release(DASH_ACTION)
		var diagnostics: Dictionary = Dictionary(root.call("get_sewer_route_diagnostics"))
		if bool(diagnostics.get("dash_crossed", false)):
			Input.action_release(MOVE_RIGHT_ACTION)
			return dash_pressed
	Input.action_release(MOVE_RIGHT_ACTION)
	return false


func _reach_sewer_exit(root: Node, _player: PlayerController) -> bool:
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(300):
		await get_tree().physics_frame
		var diagnostics: Dictionary = Dictionary(root.call("get_sewer_route_diagnostics"))
		if bool(diagnostics.get("transition_requested", false)):
			Input.action_release(MOVE_RIGHT_ACTION)
			return true
	Input.action_release(MOVE_RIGHT_ACTION)
	return false


func _release_actions() -> void:
	Input.action_release(MOVE_RIGHT_ACTION)
	Input.action_release(JUMP_ACTION)
	Input.action_release(DASH_ACTION)


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
			(child as AudioStreamPlayer).stream = null
		elif child is AudioStreamPlayer2D:
			(child as AudioStreamPlayer2D).stop()
			(child as AudioStreamPlayer2D).stream = null
