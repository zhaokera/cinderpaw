extends SceneTree

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const UNDERGROUND_SCENE_ID: StringName = &"area_04_underground_passage"
const UNDERGROUND_SPAWN_POINT: StringName = &"factory_drop_entry"
const STORY126_CLEAR_KEY: String = "factory_tailrace_exit_sluice_leech_skirmish_cleared"
const AERIAL_ATTACK: StringName = &"aerial_attack"
const LEFT_ENTITY_ID: int = 2401
const RIGHT_ENTITY_ID: int = 2402
const ENCOUNTER_ACTIVATION_X: float = 1450.0
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
	runtime_root.name = "Story131RuntimeRoot"
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
	factory_player.global_position = breach_gate.global_position + Vector2(0.0, -48.0)
	factory_player.call("set_airborne", true)
	if not bool(factory_player.call("request_aerial_attack")):
		_fail("aerial_breach_request_failed")
		return
	await process_frame
	if not await _advance_until_scene(scene_manager, UNDERGROUND_SCENE_ID):
		_fail("underground_transition_timeout")
		return

	var underground: Node = scene_manager.call("get_current_runtime_scene_node") as Node
	if underground == null or not underground.has_method(
		"get_underground_combat_diagnostics"
	):
		_fail("underground_runtime_scene_missing")
		return
	if String(scene_manager.call("get_current_spawn_point")) != String(
		UNDERGROUND_SPAWN_POINT
	):
		_fail("underground_spawn_mismatch")
		return
	var ready: Dictionary = underground.call("get_underground_combat_diagnostics")
	if String(ready.get("encounter_state", "")) != "ready" \
			or int(ready.get("active_enemy_count", -1)) != 0 \
			or bool(ready.get("back_seal_blocking", true)) \
			or not bool(ready.get("forward_seal_blocking", false)):
		_fail("underground_ready_state_mismatch")
		return

	var player: Node2D = underground.get_node_or_null("Player") as Node2D
	if player == null:
		_fail("underground_player_missing")
		return
	player.global_position.x = ENCOUNTER_ACTIVATION_X
	if not bool(underground.call(
		"try_activate_corrosion_channel_encounter",
		player
	)):
		_fail("encounter_activation_failed")
		return
	await process_frame
	var active: Dictionary = underground.call("get_underground_combat_diagnostics")
	if String(active.get("encounter_state", "")) != "active" \
			or int(active.get("active_enemy_count", 0)) != 2 \
			or not bool(active.get("back_seal_blocking", false)) \
			or not bool(active.get("forward_seal_blocking", false)):
		_fail("encounter_active_state_mismatch")
		return

	var left_enemy: Node = underground.get_node_or_null("CorrosionLeechLeft")
	if left_enemy == null:
		_fail("left_enemy_missing")
		return
	var enemy_hp_before: int = int(left_enemy.call("get_current_hp"))
	var player_collision: Object = player.call("get_collision_component")
	var enemy_collision: Object = left_enemy.call("get_collision_component")
	if not bool(player.call("request_attack")):
		_fail("player_attack_request_failed")
		return
	player_collision.call("process_detection_frame", {
		&"cat_claw_light": [enemy_collision.call("get_hurtbox")],
	})
	if int(left_enemy.call("get_current_hp")) >= enemy_hp_before:
		_fail("real_core_attack_did_not_damage")
		return
	var hit: Dictionary = underground.call("get_last_player_hit_metadata")
	if int(hit.get("target_id", -1)) != LEFT_ENTITY_ID:
		_fail("real_core_attack_target_mismatch")
		return

	if not bool(underground.call("apply_damage", LEFT_ENTITY_ID, 999, {
		"source": &"story131_smoke",
	})) or not bool(underground.call("apply_damage", RIGHT_ENTITY_ID, 999, {
		"source": &"story131_smoke",
	})):
		_fail("encounter_cleanup_damage_failed")
		return
	await process_frame
	var cleared: Dictionary = underground.call("get_underground_combat_diagnostics")
	if String(cleared.get("encounter_state", "")) != "cleared" \
			or int(cleared.get("active_enemy_count", -1)) != 0 \
			or bool(cleared.get("back_seal_blocking", true)) \
			or bool(cleared.get("forward_seal_blocking", true)) \
			or not bool(cleared.get("cache_available", false)):
		_fail("encounter_clear_state_mismatch")
		return

	var cache: Node2D = underground.get_node_or_null(
		"CorrosionSalvageCache"
	) as Node2D
	if cache == null:
		_fail("salvage_cache_missing")
		return
	player.global_position = cache.global_position
	if not bool(underground.call("try_claim_corrosion_salvage", player)) \
			or bool(underground.call("try_claim_corrosion_salvage", player)):
		_fail("salvage_one_shot_claim_failed")
		return
	var claimed: Dictionary = underground.call("get_underground_combat_diagnostics")
	if String(claimed.get("encounter_state", "")) != "claimed" \
			or not bool(claimed.get("cache_claimed", false)) \
			or int(Dictionary(claimed.get("last_reward", {})).get("gears", 0)) != 20:
		_fail("salvage_claim_state_mismatch")
		return

	var return_route: Node2D = underground.get_node_or_null(
		"FactoryReturnRoute"
	) as Node2D
	if return_route == null:
		_fail("return_route_missing")
		return
	player.global_position = return_route.global_position
	if not bool(underground.call("try_request_factory_return", player)):
		_fail("factory_return_request_failed")
		return
	if not await _advance_until_scene(scene_manager, FACTORY_SCENE_ID):
		_fail("factory_return_timeout")
		return

	var restored_factory: Node = scene_manager.call(
		"get_current_runtime_scene_node"
	) as Node
	if restored_factory == null:
		_fail("restored_factory_missing")
		return
	var restored_factory_player: Node2D = restored_factory.get_node_or_null(
		"Player"
	) as Node2D
	var restored_breach: Node2D = restored_factory.get_node_or_null(
		"FactoryTailraceUndergroundAerialBreach"
	) as Node2D
	if restored_factory_player == null or restored_breach == null:
		_fail("restored_factory_route_missing")
		return
	restored_factory_player.global_position = restored_breach.global_position
	if not bool(restored_factory.call(
		"try_request_factory_tailrace_underground_transition",
		restored_factory_player
	)):
		_fail("underground_reentry_request_failed")
		return
	if not await _advance_until_scene(scene_manager, UNDERGROUND_SCENE_ID):
		_fail("underground_reentry_timeout")
		return

	var restored_underground: Node = scene_manager.call(
		"get_current_runtime_scene_node"
	) as Node
	if restored_underground == null:
		_fail("restored_underground_missing")
		return
	var restored: Dictionary = restored_underground.call(
		"get_underground_combat_diagnostics"
	)
	if String(restored.get("encounter_state", "")) != "claimed" \
			or int(restored.get("active_enemy_count", -1)) != 0 \
			or bool(restored.get("back_seal_blocking", true)) \
			or bool(restored.get("forward_seal_blocking", true)) \
			or not bool(restored.get("cache_claimed", false)):
		_fail("restored_underground_state_mismatch")
		return

	scene_manager.call("advance_deferred_unload", 4.0)
	if runtime_root.get_parent() != null:
		runtime_root.get_parent().remove_child(runtime_root)
	runtime_root.free()
	await process_frame
	print("underground_corrosion_channel_skirmish_smoke=passed")
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
	push_error("underground_corrosion_channel_skirmish_smoke=" + reason)
	quit(1)
