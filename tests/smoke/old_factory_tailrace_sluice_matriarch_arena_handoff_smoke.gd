extends SceneTree

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const ARENA_SCENE_ID: StringName = &"boss_03_sluice_matriarch_arena"
const ARENA_SPAWN_POINT: StringName = &"boss_entry"
const FACTORY_RETURN_SPAWN_POINT: StringName = &"tailrace_matriarch_gate_return"
const STORY126_CLEAR_KEY: String = "factory_tailrace_exit_sluice_leech_skirmish_cleared"
const MAX_TRANSITION_STEPS: int = 48


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene_manager: Node = root.get_node_or_null("SceneManager")
	if scene_manager == null:
		_fail("scene_manager_missing")
		return
	var packed_factory: PackedScene = load(FACTORY_SCENE_PATH) as PackedScene
	if packed_factory == null:
		_fail("factory_scene_missing")
		return
	var runtime_root := Node.new()
	runtime_root.name = "Story127RuntimeRoot"
	root.add_child(runtime_root)
	var factory: Node = packed_factory.instantiate()
	runtime_root.add_child(factory)
	if not bool(scene_manager.call("configure_runtime_scene_root", runtime_root, factory)):
		_fail("runtime_root_configuration_failed")
		return
	if not bool(scene_manager.call("change_scene", FACTORY_SCENE_ID, &"factory_gate_entry")):
		_fail("factory_logical_scene_setup_failed")
		return
	factory.call("configure_scene_manager_runtime", scene_manager)
	factory.call("set_local_state", {STORY126_CLEAR_KEY: true})
	await process_frame

	var factory_diagnostics: Dictionary = factory.call(
		"get_factory_tailrace_sluice_matriarch_route_diagnostics"
	)
	if not bool(factory_diagnostics.get("available", false)):
		_fail("factory_route_not_available")
		return
	var factory_player: Node2D = factory.get_node_or_null("Player") as Node2D
	var factory_route: Node2D = (
		factory.get_node_or_null("FactoryTailraceSluiceMatriarchRoute") as Node2D
	)
	if factory_player == null or factory_route == null:
		_fail("factory_player_or_route_missing")
		return
	factory_player.global_position = factory_route.global_position
	if not bool(factory.call(
		"try_request_factory_tailrace_sluice_matriarch_transition",
		factory_player
	)):
		_fail("factory_to_arena_request_failed")
		return
	if not await _advance_until_scene(scene_manager, ARENA_SCENE_ID):
		_fail("arena_transition_timeout")
		return

	var arena: Node = scene_manager.call("get_current_runtime_scene_node") as Node
	if arena == null or not arena.has_method("get_arena_handoff_diagnostics"):
		_fail("arena_runtime_scene_missing")
		return
	var arena_diagnostics: Dictionary = arena.call("get_arena_handoff_diagnostics")
	if String(arena_diagnostics.get("scene_id", "")) != String(ARENA_SCENE_ID):
		_fail("arena_scene_id_mismatch")
		return
	if String(scene_manager.call("get_current_spawn_point")) != String(ARENA_SPAWN_POINT):
		_fail("arena_spawn_mismatch")
		return
	var arena_player: Node2D = arena.get_node_or_null("Player") as Node2D
	var return_route: Node2D = arena.get_node_or_null("FactoryReturnRoute") as Node2D
	if arena_player == null or return_route == null:
		_fail("arena_player_or_return_route_missing")
		return
	arena_player.global_position = return_route.global_position
	if not bool(arena.call("try_request_factory_return", arena_player)):
		_fail("arena_to_factory_request_failed")
		return
	if not await _advance_until_scene(scene_manager, FACTORY_SCENE_ID):
		_fail("factory_return_timeout")
		return

	var restored_factory: Node = scene_manager.call("get_current_runtime_scene_node") as Node
	if restored_factory == null \
			or not restored_factory.has_method(
				"get_factory_tailrace_sluice_matriarch_route_diagnostics"
			):
		_fail("restored_factory_missing")
		return
	if String(scene_manager.call("get_current_spawn_point")) != String(
		FACTORY_RETURN_SPAWN_POINT
	):
		_fail("factory_return_spawn_id_mismatch")
		return
	var restored_diagnostics: Dictionary = restored_factory.call(
		"get_factory_tailrace_sluice_matriarch_route_diagnostics"
	)
	if not bool(restored_diagnostics.get("story126_cleared", false)) \
			or not bool(restored_diagnostics.get("available", false)) \
			or bool(restored_diagnostics.get("transition_requested", true)):
		_fail("factory_return_state_mismatch")
		return
	var restored_player: Node2D = restored_factory.get_node_or_null("Player") as Node2D
	var return_spawn: Marker2D = restored_factory.get_node_or_null(
		"FactoryTailraceSluiceMatriarchReturnSpawn"
	) as Marker2D
	if restored_player == null or return_spawn == null \
			or restored_player.global_position.distance_to(return_spawn.global_position) > 0.5:
		_fail("factory_return_position_mismatch")
		return

	scene_manager.call("advance_deferred_unload", 4.0)
	if runtime_root.get_parent() != null:
		runtime_root.get_parent().remove_child(runtime_root)
	runtime_root.free()
	await process_frame
	print("old_factory_tailrace_sluice_matriarch_arena_handoff_smoke=passed")
	quit(0)


func _advance_until_scene(scene_manager: Node, target_scene_id: StringName) -> bool:
	for _step: int in range(MAX_TRANSITION_STEPS):
		scene_manager.call("advance_loading", 0.1)
		await process_frame
		if StringName(scene_manager.call("get_current_scene")) == target_scene_id \
				and not bool(scene_manager.call("is_loading")):
			return true
	return false


func _fail(reason: String) -> void:
	push_error("old_factory_tailrace_sluice_matriarch_arena_handoff_smoke=" + reason)
	quit(1)
