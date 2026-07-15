extends SceneTree

const ARENA_SCENE_PATH: String = "res://scenes/bosses/crown_warden_arena.tscn"
const BOSS_ENTITY_ID: int = 2400
const PHASE_TWO_TRIGGER_DAMAGE: int = 80
const EXPECTED_PHASE_TWO_HP: int = 80


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
	var presentation: CombatPresentation = arena.get_node_or_null(
		"CombatPresentation"
	) as CombatPresentation
	if boss == null or presentation == null:
		_fail("runtime_nodes_missing")
		return
	boss.call("set_autonomous_attacks_enabled", false)
	boss.call("reset_encounter")

	if not bool(boss.call("request_attack", &"wing_sweep")):
		_fail("wing_sweep_request_failed")
		return
	boss.call("advance_attack_frames", 24)
	if not bool(arena.call(
		"apply_damage",
		BOSS_ENTITY_ID,
		PHASE_TWO_TRIGGER_DAMAGE,
		{"source": &"story163_smoke_threshold_hit"}
	)):
		_fail("phase_two_threshold_damage_rejected")
		return
	boss.call("advance_attack_frames", 28)
	var transition: Dictionary = boss.call("get_phase_transition_diagnostics")
	var combat: Dictionary = arena.call("get_boss4_combat_diagnostics")
	var collision: Node = boss.call("get_collision_component")
	var audio_event: Dictionary = _get_last_audio_event()
	if (
		int(boss.call("get_current_hp")) != EXPECTED_PHASE_TWO_HP
		or int(boss.call("get_current_phase")) != 2
		or String(boss.call("get_attack_phase")) != "phase_transition"
		or not bool(transition.get("active", false))
		or absf(float(transition.get("remaining_sec", 0.0)) - 2.5) > 0.001
		or int(transition.get("start_count", 0)) != 1
		or String(transition.get("animation", "")) != "hurt"
		or collision == null
		or String(collision.call("get_hurtbox_state")) != "gone"
		or presentation.get_active_boss_phase_overlay_count() != 1
		or presentation.get_active_boss_phase_debris_count() < 30
		or not String(combat.get("boss_hud_label", "")).contains("Phase II")
		or String(audio_event.get("event_id", "")) != "boss_phase_transition"
		or String(audio_event.get("sfx_id", "")) != "sfx_boss_phase"
	):
		_fail("phase_two_transition_contract_failed:%s" % JSON.stringify({
			"transition": transition,
			"combat": combat,
			"audio": audio_event,
		}))
		return

	if bool(arena.call(
		"apply_damage",
		BOSS_ENTITY_ID,
		12,
		{"source": &"story163_smoke_invulnerability_probe"}
	)):
		_fail("phase_transition_damage_was_not_rejected")
		return
	if bool(boss.call("request_attack", &"talon_dive")):
		_fail("phase_transition_attack_was_not_rejected")
		return
	boss.call("advance_phase_transition", 2.5)
	if (
		bool(boss.call(
			"get_phase_transition_diagnostics"
		).get("active", true))
		or String(boss.call("get_attack_phase")) != "idle"
		or String(collision.call("get_hurtbox_state")) != "normal"
		or not bool(boss.call("request_attack", &"talon_dive"))
	):
		_fail("phase_two_transition_recovery_failed")
		return

	_cleanup_node(arena)
	_stop_runtime_audio_players()
	await process_frame
	await create_timer(0.12).timeout
	print("crown_warden_phase_two_transition_feedback_smoke=passed")
	quit(0)


func _get_last_audio_event() -> Dictionary:
	var audio_system: Node = root.get_node_or_null("AudioSystem")
	if audio_system == null or not audio_system.has_method(
		"get_last_gameplay_audio_event"
	):
		return {}
	return audio_system.call("get_last_gameplay_audio_event")


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
	push_error("crown_warden_phase_two_transition_feedback_smoke=" + reason)
	quit(1)
