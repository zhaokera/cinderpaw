## Headless Story017 smoke for the real Main Rat King victory hold.
extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const HOLD_SEC: float = 3.0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	await process_frame

	var enemy: Node = main.get_node_or_null("Enemy")
	var flow: GameFlowController = (
		main.get_node_or_null("GameFlowController") as GameFlowController
	)
	var hud: Node = main.get_node_or_null("HUD")
	var boss_hud := main.get_node_or_null("HUD/HudRoot/BossHudPanel") as Control
	var audio_system: Node = root.get_node_or_null("AudioSystem")
	if enemy == null or flow == null or hud == null:
		_fail("runtime_nodes_missing")
		return

	flow.set_process(false)
	enemy.call("apply_damage", int(enemy.call("get_current_hp")), {
		"source": &"rat_king_victory_death_hold_smoke",
	})
	await process_frame

	var sprite: AnimatedSprite2D = enemy.get_node_or_null("Sprite") as AnimatedSprite2D
	var collision: CollisionComponent = enemy.call("get_collision_component") as CollisionComponent
	var progress: Dictionary = Dictionary(main.call("get_runtime_progress_state"))
	var hold_diagnostics: Dictionary = {
		"animation": String(sprite.animation) if sprite != null else "missing",
		"death_frames": (
			sprite.sprite_frames.get_frame_count(&"death")
			if sprite != null and sprite.sprite_frames != null
			else -1
		),
		"active_hitboxes": collision.get_active_hitbox_count() if collision != null else -1,
		"hurtbox_state": String(collision.get_hurtbox_state()) if collision != null else "missing",
		"flow_state": String(flow.get_flow_state()),
		"control_locked": flow.is_player_control_locked(),
		"remaining_sec": flow.get_victory_presentation_remaining_sec(),
		"menu_visible": bool(hud.call("is_menu_visible")),
		"boss_hud_visible": boss_hud.visible if boss_hud != null else true,
		"currency": int(progress.get("currency", 0)),
		"skill_points": int(progress.get("skill_points", 0)),
		"abilities": Array(progress.get("unlocked_abilities", [])),
	}
	print("rat_king_victory_death_hold_diagnostics=", JSON.stringify(hold_diagnostics))
	if (
		sprite == null
		or String(sprite.animation) != "death"
		or not sprite.sprite_frames.has_animation(&"death")
		or sprite.sprite_frames.get_frame_count(&"death") != 3
		or collision == null
		or collision.get_active_hitbox_count() != 0
		or collision.get_hurtbox_state() != CollisionComponent.HURTBOX_STATE_GONE
		or String(flow.get_flow_state()) != "victory_pending"
		or not flow.is_player_control_locked()
		or not is_equal_approx(
			flow.get_victory_presentation_remaining_sec(),
			HOLD_SEC
		)
		or bool(hud.call("is_menu_visible"))
		or boss_hud == null
		or boss_hud.visible
		or int(progress.get("currency", 0)) != 50
		or int(progress.get("skill_points", 0)) != 5
		or not Array(progress.get("unlocked_abilities", [])).has("dash")
	):
		_fail("death_hold_contract_failed")
		return

	flow.advance_time(HOLD_SEC - 0.01)
	if (
		String(flow.get_flow_state()) != "victory_pending"
		or bool(hud.call("is_menu_visible"))
	):
		_fail("death_hold_ended_early")
		return

	flow.handle_enemy_defeated()
	flow.handle_player_death()
	flow.advance_time(0.02)
	if (
		String(flow.get_flow_state()) != "victory"
		or not bool(hud.call("is_menu_visible"))
		or String(hud.call("get_menu_title")) != "Rat King defeated"
		or not String(hud.call("get_menu_subtitle")).contains(
			"Dash unlocked +50 Gears +5 SP"
		)
	):
		_fail("delayed_reward_menu_contract_failed")
		return

	print("rat_king_victory_death_presentation_hold_smoke=passed")
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
	push_error("rat_king_victory_death_presentation_hold_smoke=" + reason)
	quit(1)
