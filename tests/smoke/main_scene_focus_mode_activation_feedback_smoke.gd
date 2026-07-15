## Headless Story154 smoke for the real Main focus transition and imported VFX/audio.
extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const FOCUS_TEXTURE_PATH: String = (
	"res://assets/generated/combat_focus_mode_edge_flash_overlay.png"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	await process_frame

	var health: HealthComponent = main.get_node("Player/HealthComponent") as HealthComponent
	var presentation: Node = main.get_node("CombatPresentation")
	var audio_system: Node = root.get_node_or_null("AudioSystem")
	if health == null or presentation == null or audio_system == null:
		_fail("runtime_nodes_missing")
		return

	presentation.set_process(false)
	health.configure(1, 100, 100, 0, 0, true)
	health.set_active_enemy_count(1)
	health.apply_damage(75, {"source": &"story154_smoke"})

	var diagnostics: Dictionary = Dictionary(
		presentation.call("get_focus_mode_activation_diagnostics")
	)
	if (
		not health.is_focus_mode_active()
		or int(presentation.call("get_active_focus_mode_overlay_count")) != 1
		or not bool(diagnostics.get("visible", false))
		or String(diagnostics.get("texture_path", "")) != FOCUS_TEXTURE_PATH
		or String(diagnostics.get("edge_color", "")) != "ecc94b"
		or not is_equal_approx(float(diagnostics.get("remaining_sec", 0.0)), 0.3)
		or diagnostics.get("size", Vector2.ZERO) != Vector2(1280, 720)
	):
		_fail("focus_overlay_contract_failed")
		return
	var overlay: TextureRect = presentation.get_node_or_null(
		"FocusModeActivationLayer/FocusModeActivationOverlay"
	) as TextureRect
	if overlay == null or overlay.texture == null:
		_fail("stable_focus_overlay_node_missing")
		return

	var audio_request: Dictionary = audio_system.call("get_last_sfx_request")
	if (
		String(audio_request.get("sfx_id", &"")) != "sfx_focus_mode_activate"
		or not bool(audio_request.get("stream_found", false))
	):
		_fail("focus_activation_audio_failed")
		return

	presentation.call("advance_time", 0.15)
	diagnostics = Dictionary(presentation.call("get_focus_mode_activation_diagnostics"))
	if not is_equal_approx(float(diagnostics.get("alpha", 0.0)), 0.5):
		_fail("focus_overlay_half_alpha_failed")
		return
	presentation.call("advance_time", 0.15)
	if int(presentation.call("get_active_focus_mode_overlay_count")) != 0:
		_fail("focus_overlay_expiry_failed")
		return

	print(
		"main_scene_focus_mode_activation_feedback_diagnostics=",
		JSON.stringify(diagnostics)
	)
	print("main_scene_focus_mode_activation_feedback_smoke=passed")
	_stop_runtime_audio_players(audio_system)
	if main.get_parent() != null:
		main.get_parent().remove_child(main)
	main.free()
	await process_frame
	quit(0)


func _stop_runtime_audio_players(audio_system: Node) -> void:
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var player := child as AudioStreamPlayer
			player.stop()
			player.stream = null
		elif child is AudioStreamPlayer2D:
			var player_2d := child as AudioStreamPlayer2D
			player_2d.stop()
			player_2d.stream = null


func _fail(reason: String) -> void:
	push_error("main_scene_focus_mode_activation_feedback_smoke=" + reason)
	quit(1)
