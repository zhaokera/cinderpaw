## Story163: Crown Warden Phase II transition is readable, invulnerable, and bounded.
extends GdUnitTestSuite

const ARENA_SCENE: PackedScene = preload(
	"res://scenes/bosses/crown_warden_arena.tscn"
)
const BOSS_ENTITY_ID: int = 2400
const PHASE_TWO_TRIGGER_DAMAGE: int = 80
const PHASE_TRANSITION_DURATION_SEC: float = 2.5
const PHASE_OVERLAY_TEXTURE_PATH: String = (
	"res://assets/generated/combat_boss_phase_overlay_readable.png"
)

var _arena: Node = null


func after_test() -> void:
	_stop_runtime_audio_players()
	if _arena == null or not is_instance_valid(_arena):
		return
	if _arena.get_parent() != null:
		_arena.get_parent().remove_child(_arena)
	_arena.free()
	_arena = null


func test_crown_warden_phase_two_waits_then_runs_one_invulnerable_feedback_window() -> void:
	_arena = ARENA_SCENE.instantiate()
	add_child(_arena)
	var boss: CharacterBody2D = _arena.get_node("CrownWardenBoss") as CharacterBody2D
	var presentation: Node = _arena.get_node("CombatPresentation")
	var collision: Node = boss.call("get_collision_component")
	var audio_system: Node = get_node_or_null("/root/AudioSystem")

	assert_bool(boss.has_method("advance_phase_transition")).override_failure_message(
		"Story163 requires a deterministic Crown Warden phase-transition API"
	).is_true()
	if not boss.has_method("advance_phase_transition"):
		return

	boss.call("set_autonomous_attacks_enabled", false)
	var transition_events: Array[Dictionary] = []
	boss.on_boss_phase_transition_started.connect(func(
		entity_id: int,
		phase: int,
		metadata: Dictionary
	) -> void:
		transition_events.append({
			"entity_id": entity_id,
			"phase": phase,
			"metadata": metadata.duplicate(true),
		})
	)

	assert_bool(bool(boss.call("request_attack", &"wing_sweep"))).is_true()
	boss.call("advance_attack_frames", 24)
	assert_str(String(boss.call("get_attack_phase"))).is_equal("active")
	assert_bool(bool(_arena.call(
		"apply_damage",
		BOSS_ENTITY_ID,
		PHASE_TWO_TRIGGER_DAMAGE,
		{"source": &"story163_threshold_hit"}
	))).is_true()
	assert_int(int(boss.call("get_current_hp"))).is_equal(80)
	assert_int(int(boss.call("get_current_phase"))).is_equal(1)
	assert_bool(bool(boss.call(
		"get_attack_diagnostics"
	).get("phase_two_pending", false))).is_true()

	boss.call("advance_attack_frames", 28)
	var transition: Dictionary = boss.call("get_phase_transition_diagnostics")
	assert_int(int(boss.call("get_current_phase"))).is_equal(2)
	assert_str(String(boss.call("get_attack_phase"))).is_equal("phase_transition")
	assert_bool(bool(transition.get("active", false))).is_true()
	assert_float(float(transition.get("remaining_sec", 0.0))).is_equal_approx(
		PHASE_TRANSITION_DURATION_SEC,
		0.001
	)
	assert_int(int(transition.get("start_count", 0))).is_equal(1)
	assert_str(String(transition.get("animation", ""))).is_equal("hurt")
	assert_str(String(collision.call("get_hurtbox_state"))).is_equal("gone")
	assert_int(transition_events.size()).is_equal(1)
	assert_int(int(transition_events[0].get("entity_id", 0))).is_equal(
		BOSS_ENTITY_ID
	)
	assert_int(int(transition_events[0].get("phase", 0))).is_equal(2)
	var metadata: Dictionary = Dictionary(transition_events[0].get("metadata", {}))
	assert_float(float(metadata.get(
		"transition_duration_sec",
		0.0
	))).is_equal_approx(PHASE_TRANSITION_DURATION_SEC, 0.001)
	assert_str(String(metadata.get("transition_animation", ""))).is_equal("hurt")

	assert_int(int(presentation.call(
		"get_active_boss_phase_overlay_count"
	))).is_equal(1)
	assert_int(int(presentation.call(
		"get_active_boss_phase_debris_count"
	))).is_greater_equal(30)
	assert_str(String(presentation.call(
		"get_last_boss_phase_overlay_texture_path"
	))).is_equal(PHASE_OVERLAY_TEXTURE_PATH)
	assert_str(String(_arena.call(
		"get_boss4_combat_diagnostics"
	).get("boss_hud_label", ""))).contains("Phase II")
	if audio_system != null and audio_system.has_method("get_last_gameplay_audio_event"):
		var audio_event: Dictionary = audio_system.call("get_last_gameplay_audio_event")
		assert_str(String(audio_event.get("event_id", ""))).is_equal(
			"boss_phase_transition"
		)
		assert_str(String(audio_event.get("sfx_id", ""))).is_equal("sfx_boss_phase")

	assert_bool(bool(_arena.call(
		"apply_damage",
		BOSS_ENTITY_ID,
		12,
		{"source": &"story163_invulnerability_probe"}
	))).is_false()
	assert_int(int(boss.call("get_current_hp"))).is_equal(80)
	assert_bool(bool(boss.call("request_attack", &"talon_dive"))).is_false()
	boss.call("advance_phase_transition", 2.49)
	assert_bool(bool(boss.call(
		"get_phase_transition_diagnostics"
	).get("active", false))).is_true()
	boss.call("advance_phase_transition", 0.01)
	assert_bool(bool(boss.call(
		"get_phase_transition_diagnostics"
	).get("active", true))).is_false()
	assert_str(String(boss.call("get_attack_phase"))).is_equal("idle")
	assert_str(String(collision.call("get_hurtbox_state"))).is_equal("normal")
	assert_bool(bool(boss.call("request_attack", &"talon_dive"))).is_true()
	assert_int(transition_events.size()).is_equal(1)


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
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
