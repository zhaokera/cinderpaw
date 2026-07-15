## Headless Story158 smoke for focus-amplified Main boss attack tells.
extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const ATTACK_TELL_TEXTURE_PATH: String = (
	"res://assets/generated/combat_focus_mode_boss_attack_tell.png"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	await process_frame
	main.set_process(false)

	var player: Node = main.get_node("Player")
	var health := player.get_node("HealthComponent") as HealthComponent
	var rat_king: Node = main.get_node("Enemy")
	var echo_guardian: Node = main.get_node("Boss2EchoGuardian")
	var audio_system: Node = root.get_node_or_null("AudioSystem")
	rat_king.set_physics_process(false)
	echo_guardian.call("set_encounter_active", true, player)
	echo_guardian.set_physics_process(false)
	health.configure(1, 100, 100, 0, 0, true)
	health.set_active_enemy_count(2)
	health.apply_damage(75, {"source": &"story158_smoke"})

	if (
		not bool(rat_king.call("request_attack_pattern", &"claw_swipe"))
		or not bool(echo_guardian.call("request_attack"))
	):
		_fail("boss_attack_request_failed", {})
		return

	var rat_tell: Dictionary = Dictionary(
		rat_king.call("get_focus_attack_tell_diagnostics")
	)
	var echo_tell: Dictionary = Dictionary(
		echo_guardian.call("get_focus_attack_tell_diagnostics")
	)
	var rat_sprite := rat_king.get_node("Sprite") as AnimatedSprite2D
	var echo_sprite := echo_guardian.get_node("Sprite") as AnimatedSprite2D
	var diagnostics: Dictionary = {
		"player_focus_active": health.is_focus_mode_active(),
		"rat_startup_frames": rat_king.call("get_current_attack_startup_frames"),
		"echo_startup_frames": echo_guardian.call("get_current_attack_startup_frames"),
		"rat_tell": rat_tell,
		"echo_tell": echo_tell,
		"rat_animation": String(rat_sprite.animation),
		"rat_animation_frames": rat_sprite.sprite_frames.get_frame_count(
			rat_sprite.animation
		),
		"echo_animation": String(echo_sprite.animation),
		"echo_animation_frames": echo_sprite.sprite_frames.get_frame_count(
			echo_sprite.animation
		),
	}
	print("main_scene_focus_mode_boss_attack_tell_diagnostics=", JSON.stringify(diagnostics))

	if (
		not health.is_focus_mode_active()
		or int(diagnostics.get("rat_startup_frames", 0)) != 21
		or int(diagnostics.get("echo_startup_frames", 0)) != 14
		or not _tell_matches_contract(rat_tell, 15, 17)
		or not _tell_matches_contract(echo_tell, 8, 9)
		or int(diagnostics.get("rat_animation_frames", 0)) < 3
		or int(diagnostics.get("echo_animation_frames", 0)) < 3
	):
		_fail("focus_attack_tell_contract_failed", diagnostics)
		return

	rat_king.call("advance_attack_frames", 17)
	echo_guardian.call("advance_attack_frames", 9)
	if (
		bool(Dictionary(rat_king.call(
			"get_focus_attack_tell_diagnostics"
		)).get("visible", true))
		or bool(Dictionary(echo_guardian.call(
			"get_focus_attack_tell_diagnostics"
		)).get("visible", true))
	):
		_fail("focus_attack_tell_lifecycle_failed", {})
		return

	print("main_scene_focus_mode_boss_attack_tell_smoke=passed")
	_stop_runtime_audio_players(audio_system)
	if main.get_parent() != null:
		main.get_parent().remove_child(main)
	main.free()
	await process_frame
	quit(0)


func _tell_matches_contract(
	diagnostics: Dictionary,
	base_duration_frames: int,
	total_duration_frames: int
) -> bool:
	return (
		bool(diagnostics.get("visible", false))
		and String(diagnostics.get("node_type", "")) == "Sprite2D"
		and String(diagnostics.get("texture_path", "")) == ATTACK_TELL_TEXTURE_PATH
		and is_equal_approx(float(diagnostics.get("area_multiplier", 0.0)), 1.25)
		and is_equal_approx(float(diagnostics.get("duration_multiplier", 0.0)), 1.10)
		and int(diagnostics.get("base_duration_frames", 0)) == base_duration_frames
		and int(diagnostics.get("total_duration_frames", 0)) == total_duration_frames
	)


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


func _fail(reason: String, diagnostics: Dictionary) -> void:
	push_error("main_scene_focus_mode_boss_attack_tell_smoke=%s %s" % [
		reason,
		JSON.stringify(diagnostics),
	])
	quit(1)
