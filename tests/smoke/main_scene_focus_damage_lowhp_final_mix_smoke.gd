## Headless Audio System Story010 smoke for Main focus damage routing and final mix import.
extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const NORMAL_CUE: StringName = &"sfx_damage_taken"
const LOW_HP_CUE: StringName = &"sfx_damage_taken_lowhp"
const LOW_HP_PATH: String = "res://assets/audio/sfx/sfx_damage_taken_lowhp.wav"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	await process_frame
	main.set_process(false)

	var player: Node = main.get_node("Player")
	var health := player.get_node("HealthComponent") as HealthComponent
	var audio_system: Node = root.get_node_or_null("AudioSystem")
	if audio_system == null:
		_fail("audio_system_missing", {})
		return

	health.configure(1, 100, 100, 0, 0, true)
	health.set_active_enemy_count(2)
	main.call("_on_enemy_attack_landed", 5, player.global_position, false)
	var normal_request: Dictionary = audio_system.call("get_last_sfx_request")
	if not _request_matches(audio_system, normal_request, NORMAL_CUE):
		_fail("normal_damage_route_failed", normal_request)
		return

	health.apply_damage(75, {"source": &"story010_smoke"})
	main.call("_on_enemy_attack_landed", 12, player.global_position, false)
	var low_hp_request: Dictionary = audio_system.call("get_last_sfx_request")
	var low_hp_event: Dictionary = audio_system.call("get_last_gameplay_audio_event")
	var low_hp_stream := load(LOW_HP_PATH) as AudioStreamWAV
	var low_hp_player := _request_player(audio_system, low_hp_request)
	var diagnostics: Dictionary = {
		"health": health.get_current_hp(),
		"focus_active": health.is_focus_mode_active(),
		"audio_focus_active": audio_system.call("is_focus_mode_audio_active"),
		"audio_state": String(audio_system.call("get_audio_state")),
		"normal_request": normal_request,
		"low_hp_request": low_hp_request,
		"low_hp_event": low_hp_event,
		"low_hp_path": audio_system.call("get_audio_stream_path", LOW_HP_CUE),
		"low_hp_duration_sec": low_hp_stream.get_length() if low_hp_stream != null else -1.0,
		"player_bus": String(low_hp_player.bus) if low_hp_player != null else "",
		"player_playing": low_hp_player.playing if low_hp_player != null else false,
	}
	print("main_scene_focus_damage_lowhp_final_mix_diagnostics=", JSON.stringify(diagnostics))

	if (
		not health.is_focus_mode_active()
		or not bool(audio_system.call("is_focus_mode_audio_active"))
		or String(audio_system.call("get_audio_state")) != "LOW_HP"
		or not _request_matches(audio_system, low_hp_request, LOW_HP_CUE)
		or String(low_hp_event.get("event_id", &"")) != "damage_taken"
		or String(low_hp_event.get("sfx_id", &"")) != String(LOW_HP_CUE)
		or not bool(low_hp_event.get("metadata", {}).get("focus_mode_active", false))
		or low_hp_stream == null
		or not is_equal_approx(low_hp_stream.get_length(), 0.38)
		or low_hp_player == null
		or String(low_hp_player.bus) != "SFX"
		or not low_hp_player.playing
	):
		_fail("low_hp_damage_route_failed", diagnostics)
		return

	health.heal(10)
	main.call("_on_enemy_attack_landed", 5, player.global_position, false)
	var restored_request: Dictionary = audio_system.call("get_last_sfx_request")
	if (
		health.is_focus_mode_active()
		or bool(audio_system.call("is_focus_mode_audio_active"))
		or not _request_matches(audio_system, restored_request, NORMAL_CUE)
	):
		diagnostics["restored_request"] = restored_request
		_fail("normal_damage_restore_failed", diagnostics)
		return

	print("main_scene_focus_damage_lowhp_final_mix_smoke=passed")
	_stop_runtime_audio_players(audio_system)
	if main.get_parent() != null:
		main.get_parent().remove_child(main)
	main.free()
	await process_frame
	quit(0)


func _request_matches(audio_system: Node, request: Dictionary, cue_id: StringName) -> bool:
	return (
		String(request.get("sfx_id", &"")) == String(cue_id)
		and bool(request.get("stream_found", false))
		and int(request.get("player_index", -1)) >= 0
		and not String(audio_system.call("get_audio_stream_path", cue_id)).is_empty()
	)


func _request_player(audio_system: Node, request: Dictionary) -> AudioStreamPlayer2D:
	var player_index: int = int(request.get("player_index", -1))
	if player_index < 0:
		return null
	return audio_system.get_node_or_null("SFXPlayer%02d" % player_index) as AudioStreamPlayer2D


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


func _fail(reason: String, diagnostics: Dictionary) -> void:
	push_error(
		"main_scene_focus_damage_lowhp_final_mix_smoke=%s %s" % [
			reason,
			JSON.stringify(diagnostics),
		]
	)
	quit(1)
