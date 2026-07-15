extends SceneTree

const ARENA_SCENE_PATH: String = "res://scenes/bosses/crown_warden_arena.tscn"
const PLAYER_COMBAT_POSITION: Vector2 = Vector2(430.0, 552.0)
const BOSS_COMBAT_POSITION: Vector2 = Vector2(515.0, 540.0)
const EXPECTED_PLAYER_HP: int = 100
const EXPECTED_BOSS_HP_AFTER_COUNTER: int = 110


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
	var boss: CharacterBody2D = arena.get_node_or_null(
		"CrownWardenBoss"
	) as CharacterBody2D
	var player: CharacterBody2D = arena.get_node_or_null(
		"Player"
	) as CharacterBody2D
	var presentation: CombatPresentation = arena.get_node_or_null(
		"CombatPresentation"
	) as CombatPresentation
	if boss == null or player == null or presentation == null:
		_fail("runtime_nodes_missing")
		return
	boss.call("set_autonomous_attacks_enabled", false)
	boss.call("reset_encounter")
	player.call("restore_at_savepoint")
	player.global_position = PLAYER_COMBAT_POSITION
	boss.global_position = BOSS_COMBAT_POSITION
	await _advance_physics(2)

	if not bool(boss.call("request_attack", &"talon_dive")):
		_fail("talon_dive_request_failed")
		return
	var startup_frames: int = int(boss.call("get_current_attack_startup_frames"))
	await _advance_physics(startup_frames - 1)
	if String(boss.call("get_attack_phase")) != "startup":
		_fail("talon_dive_startup_contract_failed")
		return
	if not bool(player.call("request_parry")):
		_fail("player_parry_request_failed")
		return
	await _advance_physics(3)

	var parry: Dictionary = arena.call("get_boss4_parry_counter_diagnostics")
	var status_effects: StatusEffectComponent = boss.call(
		"get_status_effect_component"
	) as StatusEffectComponent
	if (
		int(player.call("get_current_hp")) != EXPECTED_PLAYER_HP
		or int(boss.call("get_current_hp")) != EXPECTED_BOSS_HP_AFTER_COUNTER
		or String(parry.get("parry_type", "")) != "perfect"
		or float(parry.get("damage_multiplier", 0.0)) != 5.0
		or int(parry.get("counter_damage", 0)) != 50
		or bool(parry.get("enter_stun", true))
		or int(parry.get("counter_count", 0)) != 1
		or status_effects == null
		or status_effects.has_status(&"stun")
		or not bool(parry.get("perfect_afterimage_active", false))
		or presentation.get_active_perfect_parry_afterimage_count() != 1
	):
		_fail("perfect_parry_contract_failed:%s" % JSON.stringify({
			"player_hp": int(player.call("get_current_hp")),
			"boss_hp": int(boss.call("get_current_hp")),
			"parry": parry,
		}))
		return

	await _advance_physics(2)
	var repeated: Dictionary = arena.call("get_boss4_parry_counter_diagnostics")
	if (
		int(boss.call("get_current_hp")) != EXPECTED_BOSS_HP_AFTER_COUNTER
		or int(repeated.get("counter_count", 0)) != 1
	):
		_fail("parry_counter_repeated_for_single_contact")
		return

	_cleanup_node(arena)
	_stop_runtime_audio_players()
	await process_frame
	await create_timer(0.12).timeout
	print("crown_warden_parry_counter_runtime_smoke=passed")
	quit(0)


func _advance_physics(frame_count: int) -> void:
	for _frame: int in range(maxi(0, frame_count)):
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
	push_error("crown_warden_parry_counter_runtime_smoke=" + reason)
	quit(1)
