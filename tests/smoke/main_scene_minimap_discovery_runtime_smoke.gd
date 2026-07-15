extends SceneTree

const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"
const MAIN_AREA_ID: String = "main"
const SEWER_AREA_ID: String = "area_02_sewer"
const DASH_ABILITY_ID: StringName = &"dash"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_disable_runtime_audio_playback()
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	if packed == null:
		_fail("main_scene_missing")
		return
	var main := packed.instantiate() as Node2D
	root.add_child(main)
	await process_frame

	var hud: Node = main.get_node_or_null("HUD")
	var player: Node2D = main.get_node_or_null("Player") as Node2D
	var gate: Node2D = main.get_node_or_null("DashExplorationGate") as Node2D
	var panel: Control = main.get_node_or_null(
		"HUD/HudRoot/MinimapHudPanel"
	) as Control
	if hud == null or player == null or gate == null or panel == null:
		_fail("runtime_nodes_missing")
		return
	var initial: Dictionary = main.call("get_main_minimap_diagnostics")
	if (
		not bool(initial.get("visible", false))
		or Vector2(initial.get("panel_size", Vector2.ZERO)) != Vector2(120, 120)
		or not _region_matches(initial, MAIN_AREA_ID, true, 1.0)
		or not _region_matches(initial, SEWER_AREA_ID, false, 0.0)
	):
		_fail("initial_minimap_contract_failed")
		return

	player.global_position.x = 1280.0
	main.call("_process", 0.0)
	var marker: Dictionary = main.call("get_main_minimap_diagnostics")
	if not is_equal_approx(float(marker.get("player_normalized_x", -1.0)), 1.0):
		_fail("player_marker_not_clamped")
		return

	main.call("unlock_ability", DASH_ABILITY_ID)
	player.global_position = gate.global_position + Vector2(-48, 0)
	if not bool(player.call("request_dash")):
		_fail("dash_request_failed")
		return
	var revealing: Dictionary = main.call("get_main_minimap_diagnostics")
	if (
		not _region_matches(revealing, SEWER_AREA_ID, true, 0.0)
		or String(hud.call("get_notification_text")) != "Sewer Access discovered"
	):
		_fail("gate_discovery_feedback_failed")
		return
	hud.call("advance_time", 0.5)
	if not _region_matches(
		main.call("get_main_minimap_diagnostics"),
		SEWER_AREA_ID,
		true,
		0.5
	):
		_fail("halfway_reveal_timing_failed")
		return
	hud.call("advance_time", 0.5)
	var revealed: Dictionary = main.call("get_main_minimap_diagnostics")
	if (
		not _region_matches(revealed, SEWER_AREA_ID, true, 1.0)
		or int(revealed.get("active_reveal_count", -1)) != 0
	):
		_fail("completed_reveal_timing_failed")
		return

	var snapshot: Dictionary = main.call("capture_save_snapshot")
	var world_flags: Dictionary = Dictionary(
		Dictionary(snapshot.get("world_state", {})).get("world_flags", {})
	)
	if not bool(world_flags.get("area_02_sewer_unlocked", false)):
		_fail("world_flag_missing")
		return
	var restored := packed.instantiate() as Node2D
	root.add_child(restored)
	await process_frame
	restored.call("restore_save_snapshot", snapshot)
	var restored_map: Dictionary = restored.call("get_main_minimap_diagnostics")
	if (
		not _region_matches(restored_map, SEWER_AREA_ID, true, 1.0)
		or int(restored_map.get("active_reveal_count", -1)) != 0
	):
		_fail("save_restore_replayed_reveal")
		return

	print("main_scene_minimap_diagnostics=", JSON.stringify(restored_map))
	_stop_runtime_audio_players()
	_free_runtime_scene(restored)
	_free_runtime_scene(main)
	restored = null
	main = null
	packed = null
	await process_frame
	await create_timer(0.12).timeout
	print("main_scene_minimap_discovery_runtime_smoke=passed")
	quit(0)


func _region_matches(
	diagnostics: Dictionary,
	region_id: String,
	discovered: bool,
	reveal_progress: float
) -> bool:
	var regions: Dictionary = Dictionary(diagnostics.get("regions", {}))
	if not regions.has(region_id):
		return false
	var region: Dictionary = Dictionary(regions.get(region_id, {}))
	return (
		bool(region.get("discovered", not discovered)) == discovered
		and is_equal_approx(
			float(region.get("reveal_progress", -1.0)),
			reveal_progress
		)
	)


func _disable_runtime_audio_playback() -> void:
	var audio_system: Node = root.get_node_or_null("AudioSystem")
	if (
		audio_system == null
		or not audio_system.has_method("get_registered_audio_stream_ids")
		or not audio_system.has_method("unregister_audio_stream")
	):
		return
	for audio_id: Variant in Array(audio_system.call("get_registered_audio_stream_ids")):
		audio_system.call("unregister_audio_stream", StringName(audio_id))


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = root.get_node_or_null("AudioSystem")
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


func _free_runtime_scene(scene: Node) -> void:
	if scene != null and is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()


func _fail(reason: String) -> void:
	push_error("main_scene_minimap_discovery_runtime_smoke=" + reason)
	quit(1)
