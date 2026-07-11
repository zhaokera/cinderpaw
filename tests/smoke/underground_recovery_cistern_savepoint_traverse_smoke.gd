extends SceneTree

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const UNDERGROUND_SCENE_ID: StringName = &"area_04_underground_passage"
const STORY126_CLEAR_KEY: String = "factory_tailrace_exit_sluice_leech_skirmish_cleared"
const AERIAL_ATTACK: StringName = &"aerial_attack"
const RELAY_NODE_PATH: String = "RecoveryCisternController/RecoveryRelay"
const ENDPOINT_NODE_PATH: String = "RecoveryCisternController/DeepRouteEndpoint"
const RELAY_SPAWN_POINT: String = "recovery_cistern_relay"
const MAX_TRANSITION_STEPS: int = 48


class SmokeSaveSystem:
	extends RefCounted

	var auto_save_calls: Array[Dictionary] = []

	func auto_save(
		player_state: Dictionary = {},
		world_state: Dictionary = {},
		settings: Dictionary = {}
	) -> bool:
		auto_save_calls.append({
			"player_state": player_state.duplicate(true),
			"world_state": world_state.duplicate(true),
			"settings": settings.duplicate(true),
		})
		return true


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
	runtime_root.name = "Story132RuntimeRoot"
	root.add_child(runtime_root)
	var factory: Node = packed_factory.instantiate()
	runtime_root.add_child(factory)
	if not bool(scene_manager.call(
		"configure_runtime_scene_root",
		runtime_root,
		factory
	)):
		_fail("runtime_root_configuration_failed")
		return
	if not bool(scene_manager.call(
		"change_scene",
		FACTORY_SCENE_ID,
		&"factory_gate_entry"
	)):
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

	var underground: Node = scene_manager.call(
		"get_current_runtime_scene_node"
	) as Node
	if underground == null or not underground.has_method(
		"get_underground_recovery_cistern_diagnostics"
	):
		_fail("underground_recovery_runtime_missing")
		return
	underground.call("set_local_state", {
		"underground_corrosion_channel_activated": true,
		"underground_corrosion_left_defeated": true,
		"underground_corrosion_right_defeated": true,
		"underground_corrosion_channel_cleared": true,
		"underground_corrosion_salvage_claimed": true,
		"unlocked_abilities": [String(AERIAL_ATTACK)],
	})
	var save_system := SmokeSaveSystem.new()
	if not bool(underground.call(
		"configure_underground_save_system_runtime",
		save_system
	)):
		_fail("save_system_injection_failed")
		return
	var player: Node2D = underground.get_node_or_null("Player") as Node2D
	var relay: Node2D = underground.get_node_or_null(RELAY_NODE_PATH) as Node2D
	var endpoint: Node2D = underground.get_node_or_null(ENDPOINT_NODE_PATH) as Node2D
	if player == null or relay == null or endpoint == null:
		_fail("recovery_nodes_missing")
		return

	var max_hp: int = int(player.call("get_max_hp"))
	player.call("apply_damage", 24, {
		"source": &"story132_smoke_setup",
		"damage_type": &"setup",
	})
	player.global_position = relay.global_position
	if not bool(underground.call(
		"try_activate_recovery_cistern_savepoint",
		player
	)):
		_fail("relay_activation_failed")
		return
	var relay_active: Dictionary = underground.call(
		"get_underground_recovery_cistern_diagnostics"
	)
	if int(player.call("get_current_hp")) != max_hp \
			or not bool(relay_active.get("relay_activated", false)) \
			or int(relay_active.get("autosave_request_count", 0)) != 1 \
			or save_system.auto_save_calls.size() != 1:
		_fail("relay_recovery_or_autosave_mismatch")
		return

	if not bool(underground.call("apply_recovery_cistern_fall", player)):
		_fail("fall_damage_failed")
		return
	underground.call("advance_underground_recovery_respawn_flow", 1.51)
	var expected_revive_hp: int = maxi(1, int(floor(float(max_hp) * 0.5)))
	var revived: Dictionary = underground.call(
		"get_underground_recovery_cistern_diagnostics"
	)
	if int(player.call("get_current_hp")) != expected_revive_hp \
			or player.global_position.distance_to(relay.global_position) > 1.0 \
			or String(revived.get("respawn_state", "")) != "revived" \
			or String(Dictionary(
				revived.get("last_selected_respawn_point", {})
			).get("spawn_point", "")) != RELAY_SPAWN_POINT:
		_fail("relay_revive_mismatch")
		return
	underground.call("advance_underground_recovery_respawn_flow", 2.01)

	player.global_position = endpoint.global_position
	if not bool(underground.call(
		"try_activate_recovery_cistern_endpoint",
		player
	)):
		_fail("endpoint_activation_failed")
		return
	var secured: Dictionary = underground.call(
		"get_underground_recovery_cistern_diagnostics"
	)
	if not bool(secured.get("traversed", false)) \
			or String(secured.get("objective_text", "")) != "Recovery Cistern Secured":
		_fail("endpoint_state_mismatch")
		return
	var autosave_count_before_return: int = int(
		secured.get("autosave_request_count", 0)
	)
	var audio_count_before_return: int = int(
		secured.get("audio_request_count", 0)
	)
	var relay_vfx_count_before_return: int = int(Dictionary(
		secured.get("relay_vfx", {})
	).get("spawn_count", 0))

	var return_route: Node2D = underground.get_node_or_null(
		"FactoryReturnRoute"
	) as Node2D
	if return_route == null:
		_fail("factory_return_route_missing")
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
	var restored_player: Node2D = restored_factory.get_node_or_null(
		"Player"
	) as Node2D
	var restored_breach: Node2D = restored_factory.get_node_or_null(
		"FactoryTailraceUndergroundAerialBreach"
	) as Node2D
	if restored_player == null or restored_breach == null:
		_fail("restored_factory_route_missing")
		return
	restored_player.global_position = restored_breach.global_position
	if not bool(restored_factory.call(
		"try_request_factory_tailrace_underground_transition",
		restored_player
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
		"get_underground_recovery_cistern_diagnostics"
	)
	var restored_state: Dictionary = restored_underground.call("get_local_state")
	if not bool(restored.get("relay_activated", false)) \
			or not bool(restored.get("traversed", false)) \
			or int(restored.get(
				"autosave_request_count",
				-1
			)) != autosave_count_before_return \
			or int(restored.get(
				"audio_request_count",
				-1
			)) != audio_count_before_return \
			or int(Dictionary(restored.get(
				"relay_vfx",
				{}
			)).get("spawn_count", -1)) != relay_vfx_count_before_return \
			or not bool(restored_state.get(
				"underground_corrosion_salvage_claimed",
				false
			)) \
			or not Array(restored_state.get(
				"unlocked_abilities",
				[]
			)).has(String(AERIAL_ATTACK)):
		_fail("restored_recovery_state_mismatch")
		return

	scene_manager.call("advance_deferred_unload", 4.0)
	if runtime_root.get_parent() != null:
		runtime_root.get_parent().remove_child(runtime_root)
	runtime_root.free()
	await process_frame
	print("underground_recovery_cistern_savepoint_traverse_smoke=passed")
	quit(0)


func _advance_until_scene(
	scene_manager: Node,
	target_scene_id: StringName
) -> bool:
	for _step: int in range(MAX_TRANSITION_STEPS):
		scene_manager.call("advance_loading", 0.1)
		await process_frame
		if StringName(scene_manager.call("get_current_scene")) == target_scene_id \
				and not bool(scene_manager.call("is_loading")):
			return true
	return false


func _fail(reason: String) -> void:
	push_error("underground_recovery_cistern_savepoint_traverse_smoke=" + reason)
	quit(1)
