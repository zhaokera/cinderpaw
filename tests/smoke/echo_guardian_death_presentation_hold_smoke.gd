## Headless Story018 smoke for the real Main Echo Guardian death hold.
extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const RAT_KING_DEFEATED_FLAG: StringName = &"boss_rat_king_defeated"
const BOSS2_ENTITY_ID: int = 2200
const HOLD_SEC: float = 2.0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	await process_frame
	main.set_process(false)
	main.call("set_world_progress_flag", RAT_KING_DEFEATED_FLAG, true)

	var boss: Node = main.get_node_or_null("Boss2EchoGuardian")
	var audio_system: Node = root.get_node_or_null("AudioSystem")
	if boss == null:
		_fail("boss_missing")
		return

	if not bool(main.call("apply_damage", BOSS2_ENTITY_ID, int(
		boss.call("get_current_hp")
	), {"source": &"story018_echo_guardian_death_hold_smoke"})):
		_fail("lethal_damage_rejected")
		return

	var holding: Dictionary = main.call("get_boss2_death_presentation_diagnostics")
	print("echo_guardian_death_hold_holding=", JSON.stringify(holding))
	if (
		not bool(holding.get("pending", false))
		or not is_equal_approx(float(holding.get("remaining_sec", -1.0)), HOLD_SEC)
		or not bool(holding.get("boss_visible", false))
		or String(holding.get("animation", "")) != "death"
		or int(holding.get("death_frame_count", 0)) != 3
		or int(holding.get("active_hitbox_count", -1)) != 0
		or bool(holding.get("reward_available", true))
		or not bool(holding.get("camera_lock_enabled", false))
		or not bool(holding.get("room_seals_enabled", false))
		or not bool(holding.get("player_control_locked", false))
	):
		_fail("holding_contract_failed")
		return

	if bool(main.call("advance_boss2_death_presentation", HOLD_SEC - 0.01)):
		_fail("hold_ended_early")
		return
	if not bool(main.call("advance_boss2_death_presentation", 0.02)):
		_fail("hold_did_not_complete")
		return

	var completed: Dictionary = main.call("get_boss2_death_presentation_diagnostics")
	print("echo_guardian_death_hold_completed=", JSON.stringify(completed))
	if (
		bool(completed.get("pending", true))
		or bool(completed.get("boss_visible", true))
		or not bool(completed.get("reward_available", false))
		or bool(completed.get("camera_lock_enabled", true))
		or bool(completed.get("room_seals_enabled", true))
		or bool(completed.get("player_control_locked", true))
		or not String(completed.get("notification_text", "")).contains(
			"Claim Double Jump"
		)
	):
		_fail("completion_contract_failed")
		return

	print("echo_guardian_death_presentation_hold_smoke=passed")
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


func _fail(reason: String) -> void:
	push_error("echo_guardian_death_presentation_hold_smoke=" + reason)
	quit(1)
