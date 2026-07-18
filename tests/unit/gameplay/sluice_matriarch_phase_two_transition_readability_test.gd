## Story174: Boss3 Phase II transition is readable, invulnerable, and bounded.
extends GdUnitTestSuite

const ARENA_SCENE: PackedScene = preload(
	"res://scenes/bosses/sluice_matriarch_arena.tscn"
)
const BOSS_FRAMES_PATH: String = (
	"res://assets/characters/sluice_matriarch/sluice_matriarch_sprite_frames.tres"
)
const BOSS_ENTITY_ID: int = 2300
const PHASE_TWO_TRIGGER_DAMAGE: int = 60
const PHASE_TRANSITION_DURATION_SEC: float = 2.5
const PHASE_TRANSITION_ANIMATION: StringName = &"phase_transition"
const PRESSURE_LUNGE_HITBOX_ID: StringName = &"sluice_matriarch_pressure_lunge"
const PRESSURE_GEYSER_HITBOX_ID: StringName = &"sluice_matriarch_pressure_geyser"
const PHASE_OVERLAY_TEXTURE_PATH: String = (
	"res://assets/generated/combat_boss_phase_overlay_readable.png"
)

var _arena: Node = null


func after_test() -> void:
	get_tree().paused = false
	_stop_runtime_audio_players()
	if _arena == null or not is_instance_valid(_arena):
		return
	if _arena.get_parent() != null:
		_arena.get_parent().remove_child(_arena)
	_arena.free()
	_arena = null


func test_phase_two_waits_then_runs_one_invulnerable_feedback_window() -> void:
	_arena = ARENA_SCENE.instantiate()
	add_child(_arena)
	var boss: CharacterBody2D = (
		_arena.get_node("SluiceMatriarchBoss") as CharacterBody2D
	)
	var presentation: Node = _arena.get_node("CombatPresentation")
	var collision: CollisionComponent = boss.call("get_collision_component")
	var audio_system: Node = get_node_or_null("/root/AudioSystem")

	assert_bool(boss.has_method("advance_phase_transition")).override_failure_message(
		"Story174 requires a deterministic Boss3 phase-transition API"
	).is_true()
	if not boss.has_method("advance_phase_transition"):
		return

	boss.set_physics_process(false)
	var frames: SpriteFrames = load(BOSS_FRAMES_PATH) as SpriteFrames
	assert_that(frames).is_not_null()
	if frames == null:
		return
	assert_bool(frames.has_animation(PHASE_TRANSITION_ANIMATION)).is_true()
	if not frames.has_animation(PHASE_TRANSITION_ANIMATION):
		return
	assert_int(frames.get_frame_count(PHASE_TRANSITION_ANIMATION)).is_equal(3)

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

	assert_bool(bool(boss.call("request_attack"))).is_true()
	boss.call("advance_attack_frames", 18)
	assert_str(String(boss.call("get_attack_phase"))).is_equal("active")
	assert_bool(bool(_arena.call(
		"apply_damage",
		BOSS_ENTITY_ID,
		PHASE_TWO_TRIGGER_DAMAGE,
		{"source": &"story174_threshold_hit"}
	))).is_true()
	assert_int(int(boss.call("get_current_hp"))).is_equal(60)
	assert_int(int(boss.call("get_current_phase"))).is_equal(1)
	assert_bool(bool(boss.call(
		"get_attack_diagnostics"
	).get("phase_two_pending", false))).is_true()

	boss.call("advance_attack_frames", 24)
	var transition: Dictionary = boss.call("get_phase_transition_diagnostics")
	assert_int(int(boss.call("get_current_phase"))).is_equal(2)
	assert_str(String(boss.call("get_attack_phase"))).is_equal("phase_transition")
	assert_bool(bool(transition.get("active", false))).is_true()
	assert_float(float(transition.get("remaining_sec", 0.0))).is_equal_approx(
		PHASE_TRANSITION_DURATION_SEC,
		0.001
	)
	assert_int(int(transition.get("start_count", 0))).is_equal(1)
	assert_str(String(transition.get("animation", ""))).is_equal(
		String(PHASE_TRANSITION_ANIMATION)
	)
	assert_str(String(collision.get_hurtbox_state())).is_equal("gone")
	assert_bool(collision.is_hitbox_active(PRESSURE_LUNGE_HITBOX_ID)).is_false()
	assert_bool(collision.is_hitbox_active(PRESSURE_GEYSER_HITBOX_ID)).is_false()
	assert_bool(bool(boss.call(
		"get_attack_diagnostics"
	).get("geyser_visible", true))).is_false()
	assert_int(transition_events.size()).is_equal(1)
	var metadata: Dictionary = Dictionary(transition_events[0].get("metadata", {}))
	assert_float(float(metadata.get(
		"transition_duration_sec",
		0.0
	))).is_equal_approx(PHASE_TRANSITION_DURATION_SEC, 0.001)
	assert_str(String(metadata.get("transition_animation", ""))).is_equal(
		String(PHASE_TRANSITION_ANIMATION)
	)

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
		"get_boss3_combat_diagnostics"
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
		{"source": &"story174_invulnerability_probe"}
	))).is_false()
	assert_int(int(boss.call("get_current_hp"))).is_equal(60)
	assert_bool(bool(boss.call("request_attack"))).is_false()
	boss.call("advance_phase_transition", 2.49)
	assert_bool(bool(boss.call(
		"get_phase_transition_diagnostics"
	).get("active", false))).is_true()
	boss.call("advance_phase_transition", 0.01)
	assert_bool(bool(boss.call(
		"get_phase_transition_diagnostics"
	).get("active", true))).is_false()
	assert_str(String(boss.call("get_attack_phase"))).is_equal("idle")
	assert_str(String(collision.get_hurtbox_state())).is_equal("normal")
	assert_str(String(boss.call(
		"get_attack_diagnostics"
	).get("next_attack_id", ""))).is_equal("pressure_geyser")

	boss.call("advance_attack_frames", 28)
	assert_bool(bool(boss.call("request_attack"))).is_true()
	var phase_two_attack: Dictionary = boss.call("get_attack_diagnostics")
	assert_str(String(phase_two_attack.get("current_attack_id", ""))).is_equal(
		"pressure_geyser"
	)
	assert_int(int(phase_two_attack.get("startup_frames", 0))).is_equal(18)
	assert_int(int(phase_two_attack.get("active_frames", 0))).is_equal(10)
	assert_int(int(phase_two_attack.get("recovery_frames", 0))).is_equal(18)
	assert_int(transition_events.size()).is_equal(1)

	boss.call("reset_encounter")
	var reset: Dictionary = boss.call("get_phase_transition_diagnostics")
	assert_bool(bool(reset.get("active", true))).is_false()
	assert_int(int(reset.get("start_count", -1))).is_equal(0)
	assert_str(String(collision.get_hurtbox_state())).is_equal("normal")


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
			var player := child as AudioStreamPlayer
			player.stop()
			player.stream = null
		elif child is AudioStreamPlayer2D:
			var spatial_player := child as AudioStreamPlayer2D
			spatial_player.stop()
			spatial_player.stream = null
