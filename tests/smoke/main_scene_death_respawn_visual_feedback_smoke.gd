## Headless Story008 smoke for the real Main death/respawn feedback sequence.
extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const DEATH_WISP_TEXTURE_PATH: String = (
	"res://assets/generated/combat_player_death_soul_wisp.png"
)
const REVIVE_HALO_TEXTURE_PATH: String = (
	"res://assets/generated/combat_player_revive_halo.png"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	await process_frame

	var player: PlayerController = main.get_node("Player") as PlayerController
	var flow: GameFlowController = (
		main.get_node("GameFlowController") as GameFlowController
	)
	var presentation: Node = main.get_node("CombatPresentation")
	var audio_system: Node = root.get_node_or_null("AudioSystem")
	if player == null or flow == null or presentation == null:
		_fail("runtime_nodes_missing")
		return

	presentation.set_process(false)
	flow.set_process(false)
	flow.set_scene_transition_adapter(null)
	player.apply_damage(player.get_current_hp(), {"source": &"story008_smoke"})

	var sprite: AnimatedSprite2D = player.get_node("Sprite") as AnimatedSprite2D
	var diagnostics: Dictionary = Dictionary(
		presentation.call("get_player_death_feedback_diagnostics")
	)
	if (
		String(flow.get_flow_state()) != "dying"
		or sprite == null
		or String(sprite.animation) != "death"
		or not sprite.sprite_frames.has_animation(&"death")
		or sprite.sprite_frames.get_frame_count(&"death") != 3
		or int(presentation.call("get_active_player_death_wisp_count")) != 8
		or String(diagnostics.get("phase", "")) != "death_fade_in"
		or String(diagnostics.get("death_wisp_texture_path", ""))
		!= DEATH_WISP_TEXTURE_PATH
	):
		_fail("death_start_contract_failed")
		return
	var overlay: ColorRect = presentation.get_node_or_null(
		"PlayerDeathFeedbackLayer/PlayerDeathGrayscale"
	) as ColorRect
	var wisp: Sprite2D = presentation.get_node_or_null(
		"PlayerDeathVfxLayer/PlayerDeathSoulWisp00"
	) as Sprite2D
	if (
		overlay == null
		or not overlay.material is ShaderMaterial
		or overlay.size != Vector2(1280, 720)
		or wisp == null
		or wisp.texture == null
	):
		_fail("death_runtime_vfx_nodes_missing")
		return

	_advance_death_flow(presentation, flow, 0.25)
	diagnostics = Dictionary(presentation.call("get_player_death_feedback_diagnostics"))
	if (
		String(diagnostics.get("phase", "")) != "death_fade_in"
		or not is_equal_approx(float(diagnostics.get("grayscale_amount", 0.0)), 0.5)
	):
		_fail("death_greyscale_half_step_failed")
		return
	_advance_death_flow(presentation, flow, 0.25)
	diagnostics = Dictionary(presentation.call("get_player_death_feedback_diagnostics"))
	if (
		String(diagnostics.get("phase", "")) != "death_hold"
		or not is_equal_approx(float(diagnostics.get("grayscale_amount", 0.0)), 1.0)
	):
		_fail("death_greyscale_hold_failed")
		return

	_advance_death_flow(presentation, flow, 1.0)
	diagnostics = Dictionary(presentation.call("get_player_death_feedback_diagnostics"))
	if (
		String(flow.get_flow_state()) != "revived"
		or String(sprite.animation) != "revive"
		or not sprite.sprite_frames.has_animation(&"revive")
		or sprite.sprite_frames.get_frame_count(&"revive") != 3
		or player.get_current_hp() != 50
		or not player.is_respawn_visual_active()
		or int(presentation.call("get_active_player_death_wisp_count")) != 0
		or int(presentation.call("get_active_player_revive_halo_count")) != 1
		or String(diagnostics.get("phase", "")) != "revive_fade_out"
		or String(diagnostics.get("revive_halo_texture_path", ""))
		!= REVIVE_HALO_TEXTURE_PATH
	):
		_fail("revive_start_contract_failed")
		return
	var halo: Sprite2D = presentation.get_node_or_null(
		"PlayerDeathVfxLayer/PlayerReviveHalo"
	) as Sprite2D
	if halo == null or halo.texture == null:
		_fail("revive_halo_node_missing")
		return

	_advance_death_flow(presentation, flow, 0.25)
	diagnostics = Dictionary(presentation.call("get_player_death_feedback_diagnostics"))
	if not is_equal_approx(float(diagnostics.get("grayscale_amount", 0.0)), 0.5):
		_fail("revive_greyscale_half_step_failed")
		return
	_advance_death_flow(presentation, flow, 0.25)
	diagnostics = Dictionary(presentation.call("get_player_death_feedback_diagnostics"))
	if (
		bool(diagnostics.get("overlay_visible", true))
		or not is_equal_approx(float(diagnostics.get("grayscale_amount", 1.0)), 0.0)
		or int(presentation.call("get_active_player_revive_halo_count")) != 1
	):
		_fail("revive_greyscale_expiry_failed")
		return
	_advance_death_flow(presentation, flow, 0.5)
	diagnostics = Dictionary(presentation.call("get_player_death_feedback_diagnostics"))
	if (
		int(presentation.call("get_active_player_revive_halo_count")) != 0
		or String(diagnostics.get("phase", "")) != "idle"
	):
		_fail("revive_halo_expiry_failed")
		return

	print("main_scene_death_respawn_visual_feedback_diagnostics=", JSON.stringify(diagnostics))
	print("main_scene_death_respawn_visual_feedback_smoke=passed")
	_stop_runtime_audio_players(audio_system)
	if main.get_parent() != null:
		main.get_parent().remove_child(main)
	main.free()
	await process_frame
	quit(0)


func _stop_runtime_audio_players(audio_system: Node) -> void:
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var player := child as AudioStreamPlayer
			player.stop()
			player.stream = null
		elif child is AudioStreamPlayer2D:
			var player_2d := child as AudioStreamPlayer2D
			player_2d.stop()
			player_2d.stream = null


func _advance_death_flow(
	presentation: Node,
	flow: GameFlowController,
	delta_sec: float
) -> void:
	presentation.call("advance_time", delta_sec)
	flow.advance_time(delta_sec)


func _fail(reason: String) -> void:
	push_error("main_scene_death_respawn_visual_feedback_smoke=" + reason)
	quit(1)
