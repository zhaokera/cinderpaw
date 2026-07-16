extends SceneTree

const ARENA_SCENE_PATH: String = "res://scenes/bosses/crown_warden_arena.tscn"
const BOSS_ENTITY_ID: int = 2400
const BOSS_MAX_HP: int = 160
const WALL_CLIMB: StringName = &"wall_climb"
const DEFEATED_KEY: String = "boss_04_crown_warden_defeated"
const REWARD_CLAIMED_KEY: String = "boss_04_wall_climb_reward_claimed"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed: PackedScene = load(ARENA_SCENE_PATH) as PackedScene
	if packed == null:
		_fail("arena_scene_missing")
		return
	var arena: Node = packed.instantiate()
	root.add_child(arena)
	await process_frame
	var player: CharacterBody2D = arena.get_node_or_null("Player") as CharacterBody2D
	var source: Node2D = arena.get_node_or_null("WallClimbRewardSource") as Node2D
	if player == null or source == null:
		_fail("player_or_reward_source_missing")
		return
	var initial: Dictionary = arena.call("get_wall_climb_reward_diagnostics")
	if (
		bool(initial.get("reward_visible", true))
		or bool(initial.get("reward_available", true))
		or bool(initial.get("ability_unlocked", true))
	):
		_fail("reward_visible_before_defeat")
		return

	if not bool(arena.call(
		"apply_damage",
		BOSS_ENTITY_ID,
		BOSS_MAX_HP,
		{"source": &"story147_smoke_defeat"}
	)):
		_fail("boss_defeat_rejected")
		return
	var revealed: Dictionary = arena.call("get_wall_climb_reward_diagnostics")
	if (
		not bool(revealed.get("reward_visible", false))
		or not bool(revealed.get("reward_available", false))
		or int(revealed.get("reveal_vfx_spawn_count", 0)) != 1
	):
		_fail("reward_reveal_contract_failed")
		return

	# Let the arena's normal proximity loop perform the claim.
	player.global_position.x = source.global_position.x
	await process_frame
	var claimed: Dictionary = arena.call("get_wall_climb_reward_diagnostics")
	if (
		not bool(claimed.get("reward_claimed", false))
		or not bool(claimed.get("ability_unlocked", false))
		or not bool(claimed.get("feedback_active", false))
		or int(claimed.get("feedback_count", 0)) != 1
		or String(claimed.get("hud_notification", "")).find("Wall Climb") < 0
		or bool(player.call("request_attack"))
	):
		_fail("contact_claim_or_feedback_contract_failed")
		return
	if bool(arena.call("claim_wall_climb_reward_source", player)):
		_fail("duplicate_claim_accepted")
		return

	arena.call("advance_wall_climb_reward_feedback", 1.51)
	var completed: Dictionary = arena.call("get_wall_climb_reward_diagnostics")
	if (
		bool(completed.get("feedback_active", true))
		or String(completed.get("objective_text", ""))
		!= "Climb to the Crown Signal"
		or not bool(completed.get("return_route_available", false))
	):
		_fail("feedback_completion_contract_failed")
		return

	var state: Dictionary = arena.call("get_local_state")
	if (
		not bool(state.get(DEFEATED_KEY, false))
		or not bool(state.get(REWARD_CLAIMED_KEY, false))
		or not Array(state.get("unlocked_abilities", [])).has(String(WALL_CLIMB))
	):
		_fail("local_state_contract_failed")
		return
	var restored_arena: Node = packed.instantiate()
	root.add_child(restored_arena)
	await process_frame
	restored_arena.call("set_local_state", state)
	var restored: Dictionary = restored_arena.call(
		"get_wall_climb_reward_diagnostics"
	)
	if (
		not bool(restored.get("reward_claimed", false))
		or not bool(restored.get("ability_unlocked", false))
		or bool(restored.get("feedback_active", true))
		or int(restored.get("feedback_count", -1)) != 0
		or int(restored.get("reveal_vfx_spawn_count", -1)) != 0
	):
		_fail("restore_replayed_reward")
		return

	_cleanup_node(restored_arena)
	_cleanup_node(arena)
	_stop_runtime_audio_players()
	await process_frame
	await create_timer(0.12).timeout
	print("crown_warden_wall_climb_reward_payoff_smoke=passed")
	quit(0)


func _cleanup_node(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	if node.get_parent() != null:
		node.get_parent().remove_child(node)
	node.free()


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
	push_error("crown_warden_wall_climb_reward_payoff_smoke=" + reason)
	quit(1)
