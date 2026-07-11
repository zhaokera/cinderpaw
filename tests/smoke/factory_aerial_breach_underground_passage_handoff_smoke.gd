extends SceneTree

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const UNDERGROUND_SCENE_ID: StringName = &"area_04_underground_passage"
const UNDERGROUND_SPAWN_POINT: StringName = &"factory_drop_entry"
const FACTORY_RETURN_SPAWN_POINT: StringName = &"tailrace_underground_return"
const STORY126_CLEAR_KEY: String = "factory_tailrace_exit_sluice_leech_skirmish_cleared"
const BREACH_OPEN_KEY: String = "factory_tailrace_underground_aerial_breach_opened"
const AERIAL_ATTACK: StringName = &"aerial_attack"
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
	runtime_root.name = "Story130RuntimeRoot"
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
	factory.call("set_local_state", {
		STORY126_CLEAR_KEY: true,
		"unlocked_abilities": [String(AERIAL_ATTACK)],
	})
	await process_frame

	var factory_player: Node2D = factory.get_node_or_null("Player") as Node2D
	var breach_gate: Node2D = factory.get_node_or_null(
		"FactoryTailraceUndergroundAerialBreach"
	) as Node2D
	if factory_player == null or breach_gate == null:
		_fail("factory_player_or_breach_missing")
		return
	var before: Dictionary = factory.call(
		"get_factory_tailrace_underground_breach_diagnostics"
	)
	if String(before.get("gate_state", "")) != "unlockable" \
			or not bool(before.get("collision_blocking", false)):
		_fail("breach_not_unlockable")
		return
	factory_player.global_position = breach_gate.global_position + Vector2(0.0, -48.0)
	factory_player.call("set_airborne", true)
	if not bool(factory_player.call("request_aerial_attack")):
		_fail("aerial_attack_request_failed")
		return
	await process_frame
	var opened: Dictionary = factory.call(
		"get_factory_tailrace_underground_breach_diagnostics"
	)
	if not bool(opened.get("opened", false)) \
			or bool(opened.get("collision_blocking", true)) \
			or int(opened.get("unlock_vfx_spawn_count", 0)) != 1:
		_fail("breach_open_contract_failed")
		return
	if not await _advance_until_scene(scene_manager, UNDERGROUND_SCENE_ID):
		_fail("underground_transition_timeout")
		return

	var underground: Node = scene_manager.call("get_current_runtime_scene_node") as Node
	if underground == null or not underground.has_method("get_underground_handoff_diagnostics"):
		_fail("underground_runtime_scene_missing")
		return
	if String(scene_manager.call("get_current_spawn_point")) != String(
		UNDERGROUND_SPAWN_POINT
	):
		_fail("underground_spawn_id_mismatch")
		return
	var underground_diagnostics: Dictionary = underground.call(
		"get_underground_handoff_diagnostics"
	)
	if String(underground_diagnostics.get("scene_id", "")) != String(
		UNDERGROUND_SCENE_ID
	) or not bool(underground_diagnostics.get("return_route_available", false)):
		_fail("underground_handoff_contract_failed")
		return
	if not Array(underground_diagnostics.get("unlocked_abilities", [])).has(
		String(AERIAL_ATTACK)
	):
		_fail("underground_aerial_attack_missing")
		return

	var underground_player: Node2D = underground.get_node_or_null("Player") as Node2D
	var return_route: Node2D = underground.get_node_or_null("FactoryReturnRoute") as Node2D
	if underground_player == null or return_route == null:
		_fail("underground_player_or_return_route_missing")
		return
	underground_player.global_position = return_route.global_position
	if not bool(underground.call("try_request_factory_return", underground_player)):
		_fail("underground_to_factory_request_failed")
		return
	if not await _advance_until_scene(scene_manager, FACTORY_SCENE_ID):
		_fail("factory_return_timeout")
		return

	var restored_factory: Node = scene_manager.call("get_current_runtime_scene_node") as Node
	if restored_factory == null \
			or not restored_factory.has_method(
				"get_factory_tailrace_underground_breach_diagnostics"
			):
		_fail("restored_factory_missing")
		return
	if String(scene_manager.call("get_current_spawn_point")) != String(
		FACTORY_RETURN_SPAWN_POINT
	):
		_fail("factory_return_spawn_id_mismatch")
		return
	var restored: Dictionary = restored_factory.call(
		"get_factory_tailrace_underground_breach_diagnostics"
	)
	if not bool(restored.get("opened", false)) \
			or String(restored.get("gate_state", "")) != "unlocked" \
			or int(restored.get("unlock_vfx_active_count", -1)) != 0 \
			or int(restored.get("unlock_vfx_spawn_count", 0)) > 1 \
			or bool(restored.get("transition_requested", true)):
		_fail("restored_breach_state_mismatch")
		return
	var restored_state: Dictionary = restored_factory.call("get_local_state")
	if not bool(restored_state.get(BREACH_OPEN_KEY, false)) \
			or not Array(restored_state.get("unlocked_abilities", [])).has(
				String(AERIAL_ATTACK)
			):
		_fail("restored_factory_progress_missing")
		return
	var restored_player: Node2D = restored_factory.get_node_or_null("Player") as Node2D
	var return_spawn: Marker2D = restored_factory.get_node_or_null(
		"FactoryTailraceUndergroundReturnSpawn"
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
	print("factory_aerial_breach_underground_passage_handoff_smoke=passed")
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
	push_error("factory_aerial_breach_underground_passage_handoff_smoke=" + reason)
	quit(1)
