extends SceneTree

const TOWER_SCENE_PATH: String = (
	"res://scenes/areas/central_tower_threshold.tscn"
)
const TOWER_SCENE_ID: StringName = &"area_05_central_tower"
const TOWER_ENTRY_SPAWN: StringName = &"neon_rooftops_threshold_arrival"
const ARENA_SCENE_ID: StringName = &"boss_04_crown_warden_arena"
const ARENA_ENTRY_SPAWN: StringName = &"boss_entry"
const TOWER_RETURN_SPAWN: StringName = &"apex_approach_return"
const MAX_TRANSITION_STEPS: int = 48


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene_manager: Node = root.get_node_or_null("SceneManager")
	if scene_manager == null:
		_fail("scene_manager_missing")
		return
	var packed_tower: PackedScene = load(TOWER_SCENE_PATH) as PackedScene
	if packed_tower == null:
		_fail("tower_scene_missing")
		return
	var runtime_root := Node.new()
	runtime_root.name = "Story145RuntimeRoot"
	root.add_child(runtime_root)
	var tower: Node = packed_tower.instantiate()
	runtime_root.add_child(tower)
	if not bool(scene_manager.call(
		"configure_runtime_scene_root",
		runtime_root,
		tower
	)):
		_fail("runtime_root_configuration_failed")
		return
	if not bool(scene_manager.call(
		"change_scene",
		TOWER_SCENE_ID,
		TOWER_ENTRY_SPAWN
	)):
		_fail("tower_logical_scene_setup_failed")
		return
	tower.call("configure_scene_manager_runtime", scene_manager)
	tower.call("set_local_state", _story144_complete_state())
	await process_frame

	var route_diagnostics: Dictionary = tower.call(
		"get_crown_warden_route_diagnostics"
	)
	if not bool(route_diagnostics.get("available", false)):
		_fail("crown_route_not_available")
		return
	var tower_player: Node2D = tower.get_node_or_null("Player") as Node2D
	var crown_route: Node2D = tower.get_node_or_null(
		"CrownWardenArenaRoute"
	) as Node2D
	if tower_player == null or crown_route == null:
		_fail("tower_player_or_route_missing")
		return
	var abilities_before: Array[String] = _ability_strings(tower_player)
	tower_player.global_position = crown_route.global_position
	if not bool(tower.call(
		"try_request_crown_warden_arena",
		tower_player
	)):
		_fail("tower_to_arena_request_failed")
		return
	if not await _advance_until_scene(scene_manager, ARENA_SCENE_ID):
		_fail("arena_transition_timeout")
		return

	var arena: Node = scene_manager.call("get_current_runtime_scene_node") as Node
	if arena == null or not arena.has_method("get_arena_handoff_diagnostics"):
		_fail("arena_runtime_scene_missing")
		return
	var arena_diagnostics: Dictionary = arena.call(
		"get_arena_handoff_diagnostics"
	)
	if (
		String(arena_diagnostics.get("scene_id", "")) != String(ARENA_SCENE_ID)
		or String(scene_manager.call("get_current_spawn_point"))
		!= String(ARENA_ENTRY_SPAWN)
		or bool(arena_diagnostics.get("boss_actor_present", true))
	):
		_fail("arena_handoff_contract_mismatch")
		return
	var arena_player: Node2D = arena.get_node_or_null("Player") as Node2D
	var return_route: Node2D = arena.get_node_or_null(
		"CentralTowerReturnRoute"
	) as Node2D
	if arena_player == null or return_route == null:
		_fail("arena_player_or_return_route_missing")
		return
	if _ability_strings(arena_player) != abilities_before:
		_fail("arena_ability_state_mismatch")
		return
	arena_player.global_position = return_route.global_position
	if not bool(arena.call(
		"try_request_central_tower_return",
		arena_player
	)):
		_fail("arena_to_tower_request_failed")
		return
	if not await _advance_until_scene(scene_manager, TOWER_SCENE_ID):
		_fail("tower_return_timeout")
		return

	var restored_tower: Node = scene_manager.call(
		"get_current_runtime_scene_node"
	) as Node
	if restored_tower == null or not restored_tower.has_method(
		"get_crown_warden_route_diagnostics"
	):
		_fail("restored_tower_missing")
		return
	if String(scene_manager.call("get_current_spawn_point")) != String(
		TOWER_RETURN_SPAWN
	):
		_fail("tower_return_spawn_id_mismatch")
		return
	var restored_player: Node2D = restored_tower.get_node_or_null(
		"Player"
	) as Node2D
	var return_spawn: Marker2D = restored_tower.get_node_or_null(
		"ApexApproachReturnSpawn"
	) as Marker2D
	var restored_diagnostics: Dictionary = restored_tower.call(
		"get_crown_warden_route_diagnostics"
	)
	if (
		restored_player == null
		or return_spawn == null
		or restored_player.global_position.distance_to(
			return_spawn.global_position
		) > 0.5
		or _ability_strings(restored_player) != abilities_before
		or not bool(restored_diagnostics.get("available", false))
		or bool(restored_diagnostics.get("transition_requested", true))
	):
		_fail("tower_return_state_mismatch")
		return

	scene_manager.call("advance_deferred_unload", 4.0)
	if runtime_root.get_parent() != null:
		runtime_root.get_parent().remove_child(runtime_root)
	runtime_root.free()
	_stop_runtime_audio_players()
	await process_frame
	await create_timer(0.12).timeout
	print("central_tower_crown_warden_arena_handoff_smoke=passed")
	quit(0)


func _advance_until_scene(scene_manager: Node, target_scene_id: StringName) -> bool:
	for _step: int in range(MAX_TRANSITION_STEPS):
		scene_manager.call("advance_loading", 0.1)
		await process_frame
		if (
			StringName(scene_manager.call("get_current_scene")) == target_scene_id
			and not bool(scene_manager.call("is_loading"))
		):
			return true
	return false


func _story144_complete_state() -> Dictionary:
	return {
		"central_tower_threshold_roost_activated": true,
		"central_tower_threshold_guard_activated": true,
		"central_tower_threshold_guard_defeated": true,
		"central_tower_inner_relay_activated": true,
		"central_tower_inner_relay_parried": true,
		"central_tower_relay_mantis_activated": true,
		"central_tower_relay_mantis_defeated": true,
		"central_tower_cooling_shaft_roost_activated": true,
		"central_tower_cooling_shaft_activated": true,
		"central_tower_cooling_shaft_traversed": true,
		"central_tower_counterweight_sentry_defeated": true,
		"central_tower_deep_lift_ascended": true,
		"central_tower_apex_roost_activated": true,
		"central_tower_apex_approach_secured": true,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb", "parry",
		],
	}


func _ability_strings(player: Node) -> Array[String]:
	var result: Array[String] = []
	if player == null or not player.has_method("get_unlocked_abilities"):
		return result
	for value: Variant in Array(player.call("get_unlocked_abilities")):
		result.append(String(value))
	result.sort()
	return result


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = root.get_node_or_null("AudioSystem")
	if audio_system == null:
		return
	if audio_system.has_method("stop_music"):
		audio_system.call("stop_music", 0.0)
	if audio_system.has_method("stop_ambient"):
		audio_system.call("stop_ambient", 0.0)
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var player := child as AudioStreamPlayer
			player.stop()
			player.stream = null
		elif child is AudioStreamPlayer2D:
			var spatial := child as AudioStreamPlayer2D
			spatial.stop()
			spatial.stream = null


func _fail(reason: String) -> void:
	push_error("central_tower_crown_warden_arena_handoff_smoke=" + reason)
	quit(1)
