## Story175 smoke for the real Main Echo Guardian pounce loop.
extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const RAT_KING_DEFEATED_FLAG: StringName = &"boss_rat_king_defeated"
const SWIPE_PATTERN_ID: StringName = &"echo_swipe"
const POUNCE_PATTERN_ID: StringName = &"echo_pounce"
const POUNCE_HITBOX_ID: StringName = &"boss2_echo_pounce"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	await process_frame
	main.set_process(false)
	main.call("set_world_progress_flag", RAT_KING_DEFEATED_FLAG, true)

	var boss: Node = main.get_node_or_null("Boss2EchoGuardian")
	var player: Node2D = main.get_node_or_null("Player") as Node2D
	if boss == null or player == null:
		_fail("encounter_nodes_missing")
		return

	if not bool(boss.call("request_attack")) \
			or StringName(boss.call("get_current_attack_pattern_id")) != SWIPE_PATTERN_ID:
		_fail("opening_swipe_missing")
		return
	boss.call("apply_damage", 18, {"source": &"story175_smoke_phase_boundary"})
	var swipe_total: int = (
		int(boss.call("get_current_attack_startup_frames"))
		+ int(boss.call("get_current_attack_active_frames"))
		+ int(boss.call("get_current_attack_recovery_frames"))
	)
	boss.call("advance_attack_frames", swipe_total + 60)
	player.global_position = Vector2(boss.global_position.x + 72.0, boss.global_position.y)

	if not bool(boss.call("request_attack")):
		_fail("pounce_request_rejected")
		return
	var startup: Dictionary = boss.call("get_secondary_attack_diagnostics")
	print("echo_guardian_pounce_startup=", JSON.stringify(startup))
	var sprite: AnimatedSprite2D = boss.get_node("Sprite") as AnimatedSprite2D
	var collision: CollisionComponent = boss.call("get_collision_component") as CollisionComponent
	if (
		StringName(startup.get("current_pattern_id", &"")) != POUNCE_PATTERN_ID
		or int(startup.get("startup_frames", 0)) != 15
		or not bool(startup.get("landing_tell_visible", false))
		or String(sprite.animation) != "echo_pounce_tell"
		or sprite.sprite_frames.get_frame_count(&"echo_pounce_tell") != 3
		or collision == null
		or collision.is_hitbox_active(POUNCE_HITBOX_ID)
	):
		_fail("pounce_startup_contract_failed")
		return

	var locked_position: Vector2 = startup.get(
		"locked_pounce_position",
		Vector2.INF
	) as Vector2
	player.global_position.x = locked_position.x + 120.0
	boss.call("advance_attack_frames", int(startup.get("startup_frames", 0)))
	var active: Dictionary = boss.call("get_secondary_attack_diagnostics")
	print("echo_guardian_pounce_active=", JSON.stringify(active))
	if (
		String(boss.call("get_attack_phase")) != "active"
		or String(sprite.animation) != "echo_pounce"
		or not is_equal_approx(boss.global_position.x, locked_position.x)
		or collision == null
		or not collision.is_hitbox_active(POUNCE_HITBOX_ID)
		or bool(active.get("landing_tell_visible", true))
	):
		_fail("pounce_active_contract_failed")
		return

	boss.call("advance_attack_frames", int(active.get("active_frames", 0)))
	if (
		String(boss.call("get_attack_phase")) != "recovery"
		or String(sprite.animation) != "echo_pounce_recovery"
		or collision.is_hitbox_active(POUNCE_HITBOX_ID)
	):
		_fail("pounce_recovery_contract_failed")
		return

	print("echo_guardian_secondary_attack_playable_loop_smoke=passed")
	_stop_runtime_audio_players(root.get_node_or_null("AudioSystem"))
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


func _fail(reason: String) -> void:
	push_error("echo_guardian_secondary_attack_playable_loop_smoke=" + reason)
	quit(1)
