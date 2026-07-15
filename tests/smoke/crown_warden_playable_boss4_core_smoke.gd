extends SceneTree

const ARENA_SCENE_PATH: String = "res://scenes/bosses/crown_warden_arena.tscn"
const BOSS_ENTITY_ID: int = 2400
const BOSS_MAX_HP: int = 160
const BOSS_DEFEATED_KEY: String = "boss_04_crown_warden_defeated"
const PLAYER_COMBAT_POSITION: Vector2 = Vector2(430.0, 552.0)
const BOSS_COMBAT_POSITION: Vector2 = Vector2(515.0, 540.0)


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
	var active: Dictionary = arena.call("get_boss4_combat_diagnostics")
	if (
		not bool(active.get("boss_present", false))
		or bool(active.get("boss_defeated", true))
		or int(active.get("boss_current_hp", 0)) != BOSS_MAX_HP
		or not bool(active.get("room_seals_enabled", false))
		or not bool(active.get("boss_hud_visible", false))
		or bool(active.get("return_route_available", true))
		or not bool(active.get("scene_manager_locked", false))
	):
		_fail("active_arena_contract_failed")
		return

	var boss: CharacterBody2D = arena.get_node_or_null(
		"CrownWardenBoss"
	) as CharacterBody2D
	var player: CharacterBody2D = arena.get_node_or_null("Player") as CharacterBody2D
	if boss == null or player == null:
		_fail("boss_or_player_missing")
		return
	boss.call("set_autonomous_attacks_enabled", false)

	# Real physics overlap: Cinderpaw's normal attack must reach the authored hurtbox.
	boss.call("reset_encounter")
	player.global_position = PLAYER_COMBAT_POSITION
	boss.global_position = BOSS_COMBAT_POSITION
	await _advance_physics(2)
	if not bool(player.call("request_attack")):
		_fail("player_attack_request_failed")
		return
	await _advance_physics(4)
	if int(boss.call("get_current_hp")) != BOSS_MAX_HP - 12:
		_fail("player_attack_damage_path_failed")
		return

	# Both Boss patterns must naturally overlap the grounded player with exact damage.
	for attack_contract: Dictionary in [
		{"id": &"talon_dive", "damage": 18},
		{"id": &"wing_sweep", "damage": 14},
	]:
		boss.call("reset_encounter")
		player.call("restore_at_savepoint")
		player.global_position = PLAYER_COMBAT_POSITION
		boss.global_position = BOSS_COMBAT_POSITION
		await _advance_physics(2)
		var hp_before: int = int(player.call("get_current_hp"))
		if not bool(boss.call("request_attack", attack_contract["id"])):
			_fail("boss_attack_request_failed_%s" % String(attack_contract["id"]))
			return
		await _advance_physics(int(boss.call("get_current_attack_startup_frames")) + 5)
		if int(player.call("get_current_hp")) != hp_before - int(attack_contract["damage"]):
			_fail("boss_attack_damage_failed_%s" % String(attack_contract["id"]))
			return

	# Threshold damage during an active chain must remain pending until recovery ends.
	boss.call("reset_encounter")
	player.call("restore_at_savepoint")
	if not bool(boss.call("request_attack", &"wing_sweep")):
		_fail("phase_attack_request_failed")
		return
	boss.call("advance_attack_frames", 24)
	arena.call("apply_damage", BOSS_ENTITY_ID, 80, {"source": &"story146_smoke_phase"})
	var pending: Dictionary = boss.call("get_attack_diagnostics")
	if int(boss.call("get_current_phase")) != 1 \
			or not bool(pending.get("phase_two_pending", false)):
		_fail("phase_two_pending_contract_failed")
		return
	boss.call("advance_attack_frames", 28)
	var phase_two: Dictionary = boss.call("get_attack_diagnostics")
	if int(boss.call("get_current_phase")) != 2 \
			or int(phase_two.get("cooldown_frames", 0)) != 30 \
			or float(phase_two.get("dive_step_px", 0.0)) != 12.0:
		_fail("phase_two_contract_failed")
		return

	# Player death restores a fully collidable encounter instead of only HP values.
	boss.call("reset_encounter")
	arena.call("apply_damage", BOSS_ENTITY_ID, 40, {"source": &"story146_smoke_retry"})
	player.call("apply_damage", 999, {"source": &"story146_smoke_retry"})
	await process_frame
	await process_frame
	await _advance_physics(30)
	var retried: Dictionary = arena.call("get_boss4_combat_diagnostics")
	var player_collision: CollisionComponent = player.call("get_collision_component")
	var player_hurtbox: Area2D = player_collision.get_hurtbox()
	if (
		int(retried.get("player_death_count", 0)) != 1
		or int(retried.get("boss_current_hp", 0)) != BOSS_MAX_HP
		or int(retried.get("boss_phase", 0)) != 1
		or int(player.call("get_current_hp")) != int(player.call("get_max_hp"))
		or String(player_collision.get_hurtbox_state()) != "normal"
		or not player_hurtbox.monitorable
		or not bool(retried.get("room_seals_enabled", false))
		or not bool(retried.get("scene_manager_locked", false))
	):
		_fail("player_retry_contract_failed:%s" % JSON.stringify({
			"diagnostics": retried,
			"player_hp": int(player.call("get_current_hp")),
			"player_max_hp": int(player.call("get_max_hp")),
			"hurtbox_state": String(player_collision.get_hurtbox_state()),
			"hurtbox_monitorable": player_hurtbox.monitorable,
		}))
		return

	if not bool(arena.call(
		"apply_damage",
		BOSS_ENTITY_ID,
		BOSS_MAX_HP,
		{"source": &"story146_smoke_finish"}
	)):
		_fail("boss_defeat_damage_rejected")
		return
	var defeated: Dictionary = arena.call("get_boss4_combat_diagnostics")
	if (
		not bool(defeated.get("boss_defeated", false))
		or bool(defeated.get("room_seals_enabled", true))
		or bool(defeated.get("boss_hud_visible", true))
		or not bool(defeated.get("return_route_available", false))
		or bool(defeated.get("scene_manager_locked", true))
		or String(defeated.get("boss_animation", "")) != "death"
		or not bool(arena.call("get_local_state").get(BOSS_DEFEATED_KEY, false))
	):
		_fail("defeat_open_contract_failed")
		return

	var restored_arena: Node = packed.instantiate()
	root.add_child(restored_arena)
	await process_frame
	restored_arena.call("set_local_state", {BOSS_DEFEATED_KEY: true})
	var restored: Dictionary = restored_arena.call("get_boss4_combat_diagnostics")
	if (
		not bool(restored.get("boss_defeated", false))
		or bool(restored.get("room_seals_enabled", true))
		or bool(restored.get("boss_hud_visible", true))
		or not bool(restored.get("return_route_available", false))
		or bool(restored.get("transition_requested", true))
	):
		_fail("defeat_restore_contract_failed")
		return

	_cleanup_node(restored_arena)
	_cleanup_node(arena)
	_stop_runtime_audio_players()
	await process_frame
	await create_timer(0.12).timeout
	print("crown_warden_playable_boss4_core_smoke=passed")
	quit(0)


func _advance_physics(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await physics_frame


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
	push_error("crown_warden_playable_boss4_core_smoke=" + reason)
	quit(1)
