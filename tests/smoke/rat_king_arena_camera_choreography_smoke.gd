## Headless Story014 smoke for phase-aware Rat King arena framing.
extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const PHASE_TRANSITION_BUFFER_SEC: float = 3.0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	await process_frame

	var enemy: Node = main.get_node_or_null("Enemy")
	var camera := main.get_node_or_null("Player/Camera2D") as Camera2D
	if enemy == null or camera == null:
		_fail("runtime_nodes_missing", {})
		return

	var phase_one: Dictionary = main.call("get_rat_king_camera_choreography_diagnostics")
	var health := enemy.call("get_health_component") as HealthComponent
	health.apply_damage(120, {"source": &"camera_choreography_smoke"})
	enemy.call("advance_boss_runtime", 0.0)
	var phase_two: Dictionary = main.call("get_rat_king_camera_choreography_diagnostics")
	enemy.call("advance_boss_runtime", PHASE_TRANSITION_BUFFER_SEC)
	health.apply_damage(100, {"source": &"camera_choreography_smoke"})
	enemy.call("advance_boss_runtime", 0.0)
	var phase_three: Dictionary = main.call("get_rat_king_camera_choreography_diagnostics")
	enemy.call("advance_boss_runtime", PHASE_TRANSITION_BUFFER_SEC)
	enemy.call("apply_damage", int(enemy.call("get_current_hp")), {
		"source": &"camera_choreography_smoke",
	})
	await process_frame
	var released: Dictionary = main.call("get_rat_king_camera_choreography_diagnostics")
	var handoff: Dictionary = main.call("get_boss2_encounter_handoff_diagnostics")
	var diagnostics: Dictionary = {
		"phase_one": phase_one,
		"phase_two": phase_two,
		"phase_three": phase_three,
		"released": released,
		"handoff": handoff,
	}
	print("rat_king_arena_camera_choreography_diagnostics=", JSON.stringify(diagnostics))

	if (
		not bool(phase_one.get("enabled", false))
		or int(phase_one.get("phase", 0)) != 1
		or not is_equal_approx(float(phase_one.get("zoom", Vector2.ONE).x), 1.08)
		or int(phase_two.get("phase", 0)) != 2
		or not is_equal_approx(float(phase_two.get("zoom", Vector2.ONE).x), 1.12)
		or int(phase_three.get("phase", 0)) != 3
		or not is_equal_approx(float(phase_three.get("zoom", Vector2.ONE).x), 1.16)
		or bool(released.get("enabled", true))
		or String(released.get("reason", "")) != "rat_king_defeated"
		or camera.limit_right != 1280
		or camera.zoom != Vector2.ONE
		or String(handoff.get("game_flow_state", "")) != "victory_pending"
		or bool(handoff.get("boss2_encounter_active", true))
	):
		_fail("camera_choreography_contract_failed", diagnostics)
		return

	print("rat_king_arena_camera_choreography_smoke=passed")
	_stop_runtime_audio_players(root.get_node_or_null("AudioSystem"))
	_cleanup(main)
	await process_frame
	quit(0)


func _cleanup(main: Node) -> void:
	if main != null and is_instance_valid(main):
		if main.get_parent() != null:
			main.get_parent().remove_child(main)
		main.free()


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
	push_error("rat_king_arena_camera_choreography_smoke=%s %s" % [
		reason,
		JSON.stringify(diagnostics),
	])
	quit(1)
