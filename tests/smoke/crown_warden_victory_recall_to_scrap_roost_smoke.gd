extends SceneTree

const ARENA_SCENE_PATH: String = "res://scenes/bosses/crown_warden_arena.tscn"
const ARENA_SCENE_ID: StringName = &"boss_04_crown_warden_arena"
const ARENA_SPAWN: StringName = &"boss_entry"
const MAIN_SCENE_ID: StringName = &"main"
const MAIN_SPAWN: StringName = &"scrap_roost"
const BOSS_ENTITY_ID: int = 2400
const BOSS_MAX_HP: int = 160
const MAX_TRANSITION_STEPS: int = 64
const RAT_KING_DEFEATED_FLAG: String = "boss_rat_king_defeated"
const BOSS2_DEFEATED_FLAG: String = "boss_02_echo_guardian_defeated"
const BOSS2_REWARD_FLAG: String = "boss_02_double_jump_claimed"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene_manager: Node = root.get_node_or_null("SceneManager")
	var packed: PackedScene = load(ARENA_SCENE_PATH) as PackedScene
	if scene_manager == null or packed == null:
		_fail("scene_manager_or_arena_missing")
		return

	var runtime_root := Node.new()
	runtime_root.name = "Story148RuntimeRoot"
	root.add_child(runtime_root)
	var arena: Node = packed.instantiate()
	runtime_root.add_child(arena)
	await process_frame
	# Arena correctly locks transitions while Boss4 is alive. Establish the
	# smoke's logical starting scene before reapplying arena lock ownership.
	scene_manager.call("unlock_scene")
	if not bool(scene_manager.call("set_scene_state", MAIN_SCENE_ID, {
		"unlocked_abilities": [
			"basic_attack", "jump", "dodge", "dash", "double_jump",
			"aerial_attack", "parry", "wall_climb",
		],
		"world_flags": {
			RAT_KING_DEFEATED_FLAG: true,
			BOSS2_DEFEATED_FLAG: true,
			BOSS2_REWARD_FLAG: true,
		},
	})):
		_fail("main_progress_seed_failed")
		return
	if not bool(scene_manager.call("change_scene", ARENA_SCENE_ID, ARENA_SPAWN)):
		_fail("arena_logical_scene_setup_failed")
		return
	if not bool(scene_manager.call(
		"configure_runtime_scene_root", runtime_root, arena
	)):
		_fail("runtime_root_configuration_failed")
		return
	arena.call("configure_scene_manager_runtime", scene_manager)

	var player: Node2D = arena.get_node_or_null("Player") as Node2D
	var reward: Node2D = arena.get_node_or_null("WallClimbRewardSource") as Node2D
	var recall: Node2D = arena.get_node_or_null("CrownVictoryRecallRoute") as Node2D
	if player == null or reward == null or recall == null:
		_fail("arena_post_boss_nodes_missing")
		return
	if not bool(arena.call(
		"apply_damage",
		BOSS_ENTITY_ID,
		BOSS_MAX_HP,
		{"source": &"story148_smoke"}
	)):
		_fail("boss_defeat_rejected")
		return
	player.global_position.x = reward.global_position.x
	await process_frame
	arena.call("advance_wall_climb_reward_feedback", 1.51)
	var available: Dictionary = arena.call("get_victory_recall_diagnostics")
	if (
		not bool(available.get("recall_route_visible", false))
		or not bool(available.get("recall_route_available", false))
		or not bool(available.get("tower_return_available", false))
		or String(available.get("recall_texture_path", ""))
		!= String(available.get("recall_expected_texture_path", "missing"))
	):
		_fail("post_reward_dual_route_contract_failed")
		return

	player.global_position = recall.global_position
	if not bool(arena.call("try_request_victory_recall", player)):
		_fail("victory_recall_request_failed")
		return
	if not await _advance_until_scene(scene_manager, MAIN_SCENE_ID):
		_fail("main_transition_timeout")
		return
	if String(scene_manager.call("get_current_spawn_point")) != String(MAIN_SPAWN):
		_fail("main_spawn_id_mismatch")
		return

	var main: Node = scene_manager.call("get_current_runtime_scene_node") as Node
	if main == null or not main.has_method(
		"get_crown_warden_victory_return_diagnostics"
	):
		_fail("main_runtime_scene_missing")
		return
	var arrived: Dictionary = main.call(
		"get_crown_warden_victory_return_diagnostics"
	)
	print("story148_arrived=", JSON.stringify(arrived))
	if (
		String(arrived.get("current_scene", "")) != String(MAIN_SCENE_ID)
		or String(arrived.get("current_spawn_point", "")) != String(MAIN_SPAWN)
		or not bool(arrived.get("valid_recall_proof", false))
		or not bool(arrived.get("secured", false))
		or float(arrived.get("player_savepoint_distance", 999.0)) > 4.0
		or String(Dictionary(arrived.get("last_savepoint", {})).get("id", ""))
		!= String(MAIN_SPAWN)
		or String(arrived.get("hud_notification_text", "")).find("Crown secured") < 0
	):
		_fail("scrap_roost_arrival_contract_failed")
		return
	var rat_king := main.get_node_or_null("Enemy") as CollisionObject2D
	var echo_guardian := main.get_node_or_null("Boss2EchoGuardian") as CollisionObject2D
	var boss_hud := main.get_node_or_null("HUD/HudRoot/BossHudPanel") as Control
	if (
		rat_king == null
		or echo_guardian == null
		or boss_hud == null
		or rat_king.visible
		or rat_king.collision_layer != 0
		or rat_king.collision_mask != 0
		or echo_guardian.visible
		or boss_hud.visible
	):
		_fail("defeated_main_bosses_restored_on_hub_arrival")
		return

	scene_manager.call("advance_deferred_unload", 4.0)
	if runtime_root.get_parent() != null:
		runtime_root.get_parent().remove_child(runtime_root)
	runtime_root.free()
	_stop_runtime_audio_players()
	await process_frame
	await create_timer(0.12).timeout
	print("crown_warden_victory_recall_to_scrap_roost_smoke=passed")
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
			(child as AudioStreamPlayer).stop()
		elif child is AudioStreamPlayer2D:
			(child as AudioStreamPlayer2D).stop()


func _fail(reason: String) -> void:
	push_error("crown_warden_victory_recall_to_scrap_roost_smoke=" + reason)
	quit(1)
