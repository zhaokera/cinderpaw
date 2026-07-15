## Headless Story159 smoke for focus-mode environment particle clarity.
extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const DUST_MOTE_TEXTURE_PATH: String = (
	"res://assets/generated/combat_focus_environment_dust_mote.png"
)
const NORMAL_ALPHA: float = 1.0
const FOCUS_ALPHA: float = 0.30


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	await process_frame
	main.set_process(false)

	var player: Node = main.get_node("Player")
	var health := player.get_node("HealthComponent") as HealthComponent
	var camera := player.get_node("Camera2D") as Camera2D
	var particles := main.get_node_or_null(
		"FocusEnvironmentParticles"
	) as CPUParticles2D
	var audio_system: Node = root.get_node_or_null("AudioSystem")
	var camera_zoom: Vector2 = camera.zoom
	var camera_limits: Array[int] = [
		camera.limit_left,
		camera.limit_top,
		camera.limit_right,
		camera.limit_bottom,
	]

	if particles == null:
		_fail("particle_node_missing", {})
		return

	var normal_diagnostics: Dictionary = Dictionary(
		particles.call("get_focus_environment_diagnostics")
	)
	if not _diagnostics_match(normal_diagnostics, false, NORMAL_ALPHA):
		_fail("normal_particle_contract_failed", normal_diagnostics)
		return

	health.configure(1, 100, 100, 0, 0, true)
	health.set_active_enemy_count(2)
	health.apply_damage(75, {"source": &"story159_smoke"})
	var focus_diagnostics: Dictionary = Dictionary(
		particles.call("get_focus_environment_diagnostics")
	)
	if (
		not health.is_focus_mode_active()
		or not _diagnostics_match(focus_diagnostics, true, FOCUS_ALPHA)
		or not _camera_matches(camera, camera_zoom, camera_limits)
	):
		_fail("focus_particle_contract_failed", focus_diagnostics)
		return

	health.heal(10)
	var restored_diagnostics: Dictionary = Dictionary(
		particles.call("get_focus_environment_diagnostics")
	)
	var diagnostics: Dictionary = {
		"normal": normal_diagnostics,
		"focus": focus_diagnostics,
		"restored": restored_diagnostics,
		"camera_zoom": camera.zoom,
		"camera_limits": [
			camera.limit_left,
			camera.limit_top,
			camera.limit_right,
			camera.limit_bottom,
		],
	}
	print(
		"main_scene_focus_mode_environment_particle_clarity_diagnostics=",
		JSON.stringify(diagnostics)
	)

	if (
		health.is_focus_mode_active()
		or not _diagnostics_match(restored_diagnostics, false, NORMAL_ALPHA)
		or not _camera_matches(camera, camera_zoom, camera_limits)
	):
		_fail("particle_restore_contract_failed", diagnostics)
		return

	print("main_scene_focus_mode_environment_particle_clarity_smoke=passed")
	_stop_runtime_audio_players(audio_system)
	if main.get_parent() != null:
		main.get_parent().remove_child(main)
	main.free()
	await process_frame
	quit(0)


func _diagnostics_match(
	diagnostics: Dictionary,
	focus_active: bool,
	expected_alpha: float
) -> bool:
	return (
		String(diagnostics.get("node_name", "")) == "FocusEnvironmentParticles"
		and String(diagnostics.get("node_type", "")) == "CPUParticles2D"
		and String(diagnostics.get("texture_path", "")) == DUST_MOTE_TEXTURE_PATH
		and bool(diagnostics.get("focus_active", not focus_active)) == focus_active
		and bool(diagnostics.get("emitting", false))
		and bool(diagnostics.get("fixed_seed", false))
		and int(diagnostics.get("amount", 0)) == 24
		and is_equal_approx(
			float(diagnostics.get("current_alpha", -1.0)),
			expected_alpha
		)
	)


func _camera_matches(
	camera: Camera2D,
	expected_zoom: Vector2,
	expected_limits: Array[int]
) -> bool:
	return (
		camera.zoom == expected_zoom
		and [
			camera.limit_left,
			camera.limit_top,
			camera.limit_right,
			camera.limit_bottom,
		] == expected_limits
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
	push_error(
		"main_scene_focus_mode_environment_particle_clarity_smoke=%s %s" % [
			reason,
			JSON.stringify(diagnostics),
		]
	)
	quit(1)
