extends SceneTree

const ARENA_SCENE_PATH: String = "res://scenes/bosses/sluice_matriarch_arena.tscn"
const BOSS_ENTITY_ID: int = 2300
const BOSS_MAX_HP: int = 120
const BOSS_DEFEATED_KEY: String = "boss_03_sluice_matriarch_defeated"
const ATTACK_HITBOX_ID: StringName = &"sluice_matriarch_pressure_lunge"


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
	if not arena.has_method("get_boss3_combat_diagnostics"):
		_fail("boss3_diagnostics_missing")
		return
	var active: Dictionary = arena.call("get_boss3_combat_diagnostics")
	if not bool(active.get("boss_present", false)) \
			or bool(active.get("boss_defeated", true)) \
			or not bool(active.get("room_seals_enabled", false)) \
			or bool(active.get("return_route_available", true)) \
			or not bool(active.get("boss_hud_visible", false)):
		_fail("active_arena_contract_failed")
		return

	var boss: Node2D = arena.get_node_or_null("SluiceMatriarchBoss") as Node2D
	var player: Node2D = arena.get_node_or_null("Player") as Node2D
	if boss == null or player == null:
		_fail("boss_or_player_missing")
		return
	boss.set_physics_process(false)
	var boss_collision: CollisionComponent = boss.call("get_collision_component")
	if boss_collision == null:
		_fail("boss_collision_missing")
		return
	boss_collision.set_physics_process(false)
	boss.call("reset_encounter")
	boss.call("set_attack_target", player)
	var start_x: float = boss.global_position.x
	if not bool(boss.call("request_attack")):
		_fail("pressure_lunge_request_failed")
		return
	boss.call("advance_attack_frames", 19)
	var lunge: Dictionary = boss.call("get_pressure_lunge_diagnostics")
	if String(lunge.get("attack_phase", "")) != "active" \
			or not bool(lunge.get("hitbox_active", false)) \
			or boss.global_position.x >= start_x:
		_fail("pressure_lunge_active_contract_failed")
		return
	var player_collision: CollisionComponent = player.call("get_collision_component")
	if player_collision == null:
		_fail("player_collision_missing")
		return
	var hp_before: int = int(player.call("get_current_hp"))
	boss_collision.process_detection_frame({
		ATTACK_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	if int(player.call("get_current_hp")) != hp_before - 16:
		_fail("pressure_lunge_damage_path_failed")
		return
	boss.call("apply_damage", 61, {"source": &"story128_smoke"})
	boss.call("advance_attack_frames", 32)
	var phase_two: Dictionary = boss.call("get_pressure_lunge_diagnostics")
	if int(phase_two.get("current_phase", 0)) != 2 \
			or float(phase_two.get("lunge_step_px", 0.0)) < 20.0 \
			or int(phase_two.get("attack_cooldown_frames", 99)) >= 42:
		_fail("phase_two_contract_failed")
		return
	if not bool(arena.call(
		"apply_damage",
		BOSS_ENTITY_ID,
		BOSS_MAX_HP,
		{"source": &"story128_smoke_finish"}
	)):
		_fail("boss_defeat_damage_rejected")
		return
	var defeated: Dictionary = arena.call("get_boss3_combat_diagnostics")
	if not bool(defeated.get("boss_defeated", false)) \
			or bool(defeated.get("room_seals_enabled", true)) \
			or not bool(defeated.get("return_route_available", false)) \
			or bool(defeated.get("boss_hud_visible", true)):
		_fail("defeat_open_contract_failed")
		return
	var state: Dictionary = arena.call("get_local_state")
	if not bool(state.get(BOSS_DEFEATED_KEY, false)):
		_fail("defeated_state_not_persisted")
		return

	var restored_arena: Node = packed.instantiate()
	root.add_child(restored_arena)
	await process_frame
	restored_arena.call("set_local_state", {BOSS_DEFEATED_KEY: true})
	var restored: Dictionary = restored_arena.call("get_boss3_combat_diagnostics")
	if not bool(restored.get("boss_defeated", false)) \
			or bool(restored.get("room_seals_enabled", true)) \
			or not bool(restored.get("return_route_available", false)) \
			or bool(restored.get("return_transition_requested", true)):
		_fail("defeat_restore_contract_failed")
		return

	_cleanup_node(restored_arena)
	_cleanup_node(arena)
	await process_frame
	print("sluice_matriarch_playable_boss3_core_smoke=passed")
	quit(0)


func _cleanup_node(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	if node.get_parent() != null:
		node.get_parent().remove_child(node)
	node.free()


func _fail(reason: String) -> void:
	push_error("sluice_matriarch_playable_boss3_core_smoke=" + reason)
	quit(1)
