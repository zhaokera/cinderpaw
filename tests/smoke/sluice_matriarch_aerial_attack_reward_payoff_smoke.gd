extends SceneTree

const ARENA_SCENE_PATH: String = "res://scenes/bosses/sluice_matriarch_arena.tscn"
const BOSS_ENTITY_ID: int = 2300
const BOSS_MAX_HP: int = 120
const AERIAL_ATTACK: StringName = &"aerial_attack"
const DOUBLE_JUMP: StringName = &"double_jump"
const REWARD_CLAIMED_KEY: String = "boss_03_aerial_attack_reward_claimed"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed: PackedScene = load(ARENA_SCENE_PATH) as PackedScene
	if packed == null:
		_fail("arena_scene_missing")
		return
	var reward_arena: Node = packed.instantiate()
	root.add_child(reward_arena)
	await process_frame
	var reward_player: Node2D = reward_arena.get_node_or_null("Player") as Node2D
	var reward_source: Node2D = reward_arena.get_node_or_null(
		"AerialAttackRewardSource"
	) as Node2D
	if reward_player == null or reward_source == null:
		_fail("reward_nodes_missing")
		return
	if not bool(reward_arena.call(
		"apply_damage",
		BOSS_ENTITY_ID,
		BOSS_MAX_HP,
		{"source": &"story129_smoke_reward"}
	)):
		_fail("boss_defeat_rejected")
		return
	var revealed: Dictionary = reward_arena.call("get_aerial_attack_payoff_diagnostics")
	if not bool(revealed.get("reward_visible", false)) \
			or not bool(revealed.get("reward_available", false)) \
			or int(revealed.get("reveal_vfx_spawn_count", 0)) != 1:
		_fail("reward_reveal_contract_failed")
		return
	reward_player.global_position = reward_source.global_position
	if not bool(reward_arena.call(
		"claim_aerial_attack_reward_source",
		reward_player
	)):
		_fail("reward_claim_rejected")
		return
	if not bool(reward_player.call("has_ability", AERIAL_ATTACK)):
		_fail("aerial_attack_not_unlocked")
		return
	var reward_state: Dictionary = reward_arena.call("get_local_state")
	if not bool(reward_state.get(REWARD_CLAIMED_KEY, false)):
		_fail("reward_claim_not_persisted")
		return

	var restored_arena: Node = packed.instantiate()
	root.add_child(restored_arena)
	await process_frame
	restored_arena.call("set_local_state", reward_state)
	var restored_player: Node = restored_arena.get_node_or_null("Player")
	var restored_reward: Dictionary = restored_arena.call(
		"get_aerial_attack_payoff_diagnostics"
	)
	if not bool(restored_player.call("has_ability", AERIAL_ATTACK)) \
			or not bool(restored_reward.get("reward_claimed", false)) \
			or bool(restored_reward.get("reward_available", true)):
		_fail("reward_restore_contract_failed")
		return

	var combat_arena: Node = packed.instantiate()
	root.add_child(combat_arena)
	await process_frame
	var player: CharacterBody2D = combat_arena.get_node_or_null("Player") as CharacterBody2D
	var boss: Node = combat_arena.get_node_or_null("SluiceMatriarchBoss")
	if player == null or boss == null:
		_fail("combat_nodes_missing")
		return
	boss.set_physics_process(false)
	if not bool(player.call("unlock_ability", AERIAL_ATTACK)) \
			or not bool(player.call("unlock_ability", DOUBLE_JUMP)):
		_fail("ability_setup_failed")
		return
	player.call("set_airborne", true)
	if not bool(player.call("request_double_jump")):
		_fail("double_jump_setup_failed")
		return
	player.position.y -= 96.0
	if not bool(player.call("request_attack")):
		_fail("aerial_attack_request_failed")
		return
	var started: Dictionary = player.call("get_aerial_attack_diagnostics")
	if String(started.get("animation", "")) != "aerial_attack" \
			or String(started.get("hitbox_id", "")) != "cat_claw_aerial" \
			or player.velocity.y <= 0.0:
		_fail("aerial_attack_start_contract_failed")
		return
	var player_combat: CombatComponent = player.call("get_combat_component")
	var player_collision: CollisionComponent = player.call("get_collision_component")
	var boss_collision: CollisionComponent = boss.call("get_collision_component")
	var hp_before: int = int(boss.call("get_current_hp"))
	var energy_before: int = player_combat.get_cat_energy()
	player_collision.process_detection_frame({
		&"cat_claw_aerial": [boss_collision.get_hurtbox()],
	})
	var bounced: Dictionary = player.call("get_aerial_attack_diagnostics")
	if int(boss.call("get_current_hp")) != hp_before - 12 \
			or player_combat.get_cat_energy() != energy_before + 8 \
			or player.velocity.y >= 0.0 \
			or not bool(bounced.get("air_jump_restored", false)):
		_fail("aerial_hit_bounce_contract_failed")
		return

	_cleanup_node(combat_arena)
	_cleanup_node(restored_arena)
	_cleanup_node(reward_arena)
	await process_frame
	print("sluice_matriarch_aerial_attack_reward_payoff_smoke=passed")
	quit(0)


func _cleanup_node(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	if node.get_parent() != null:
		node.get_parent().remove_child(node)
	node.free()


func _fail(reason: String) -> void:
	push_error("sluice_matriarch_aerial_attack_reward_payoff_smoke=" + reason)
	quit(1)
