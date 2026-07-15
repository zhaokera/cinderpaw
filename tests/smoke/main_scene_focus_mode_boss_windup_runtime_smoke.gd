## Headless Story157 smoke for the Main low-HP focus windup advantage.
extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const FOCUS_DAMAGE: int = 75


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
	if health == null or rat_king == null or echo_guardian == null:
		_fail("runtime_nodes_missing", {})
		return

	rat_king.set_physics_process(false)
	echo_guardian.call("set_encounter_active", true, player)
	echo_guardian.set_physics_process(false)
	health.configure(1, 100, 100, 0, 0, true)
	health.set_active_enemy_count(2)
	health.apply_damage(FOCUS_DAMAGE, {"source": &"story157_smoke"})

	if (
		not bool(rat_king.call("request_attack_pattern", &"claw_swipe"))
		or not bool(echo_guardian.call("request_attack"))
	):
		_fail("boss_attack_request_failed", {})
		return

	var diagnostics: Dictionary = main.call(
		"get_focus_mode_enemy_windup_diagnostics"
	)
	var rat_diagnostics: Dictionary = Dictionary(diagnostics.get("rat_king", {}))
	var echo_diagnostics: Dictionary = Dictionary(
		diagnostics.get("echo_guardian", {})
	)
	var rat_sprite := rat_king.get_node("Sprite") as AnimatedSprite2D
	var echo_sprite := echo_guardian.get_node("Sprite") as AnimatedSprite2D
	diagnostics["rat_animation"] = String(rat_sprite.animation)
	diagnostics["rat_animation_frames"] = rat_sprite.sprite_frames.get_frame_count(
		rat_sprite.animation
	)
	diagnostics["echo_animation"] = String(echo_sprite.animation)
	diagnostics["echo_animation_frames"] = echo_sprite.sprite_frames.get_frame_count(
		echo_sprite.animation
	)
	print("main_scene_focus_mode_boss_windup_diagnostics=", JSON.stringify(diagnostics))

	if (
		not health.is_focus_mode_active()
		or not bool(diagnostics.get("player_focus_active", false))
		or int(rat_diagnostics.get("base_startup_frames", 0)) != 15
		or int(rat_diagnostics.get("windup_extension_frames", 0)) != 6
		or int(rat_diagnostics.get("current_attack_startup_frames", 0)) != 21
		or int(echo_diagnostics.get("base_startup_frames", 0)) != 8
		or int(echo_diagnostics.get("windup_extension_frames", 0)) != 6
		or int(echo_diagnostics.get("current_attack_startup_frames", 0)) != 14
		or int(diagnostics.get("rat_animation_frames", 0)) < 3
		or int(diagnostics.get("echo_animation_frames", 0)) < 3
	):
		_fail("focus_windup_contract_failed", diagnostics)
		return

	health.heal(10)
	var released: Dictionary = main.call("get_focus_mode_enemy_windup_diagnostics")
	var released_rat: Dictionary = Dictionary(released.get("rat_king", {}))
	var released_echo: Dictionary = Dictionary(released.get("echo_guardian", {}))
	if (
		health.is_focus_mode_active()
		or int(released_rat.get("windup_extension_frames", -1)) != 0
		or int(released_echo.get("windup_extension_frames", -1)) != 0
		or int(rat_king.call("get_current_attack_startup_frames")) != 21
		or int(echo_guardian.call("get_current_attack_startup_frames")) != 14
	):
		_fail("in_flight_windup_changed", released)
		return

	print("main_scene_focus_mode_boss_windup_runtime_smoke=passed")
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


func _fail(reason: String, diagnostics: Dictionary) -> void:
	push_error("main_scene_focus_mode_boss_windup_runtime_smoke=%s %s" % [
		reason,
		JSON.stringify(diagnostics),
	])
	quit(1)
