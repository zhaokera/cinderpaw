extends SceneTree


const FACTORY_SCENE := "res://scenes/factory_route_transition_shell.tscn"
const DIAGNOSTICS := "get_factory_tailrace_exit_sluice_leech_skirmish_diagnostics"
const ACTIVATE := "try_activate_factory_tailrace_exit_sluice_leech_skirmish"
const SLUICE_LEECH_ENTITY_ID := 2146
const SLUICE_LEECH_NODE := "FactoryTailraceExitSluiceLeech"
const STORY124_CROSSED_KEY := (
	"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_"
	+ "runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_"
	+ "spillway_crossed"
)
const STORY126_CLEARED_KEY := "factory_tailrace_exit_sluice_leech_skirmish_cleared"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(FACTORY_SCENE) as PackedScene
	if packed == null:
		_fail(null, "Failed to load factory route transition shell")
		return
	var scene := packed.instantiate()
	root.add_child(scene)
	await process_frame

	if not scene.has_method(DIAGNOSTICS) or not scene.has_method(ACTIVATE):
		_fail(scene, "Factory scene missing Sluice Leech APIs")
		return
	scene.call("set_local_state", {
		STORY124_CROSSED_KEY: true,
		"last_return_checkpoint": _tailrace_relay_checkpoint(),
	})
	var diagnostics: Dictionary = scene.call(DIAGNOSTICS)
	if not bool(diagnostics.get("available", false)):
		_fail(scene, "Sluice Leech skirmish is not available after Story124")
		return

	var player := scene.get_node_or_null("Player") as Node2D
	if player == null:
		_fail(scene, "Factory scene missing Player")
		return
	player.global_position.x = float(diagnostics.get("activation_x", 0.0)) + 4.0
	if not bool(scene.call(ACTIVATE, player)):
		_fail(scene, "Sluice Leech skirmish did not activate")
		return
	diagnostics = scene.call(DIAGNOSTICS)
	if (
		not bool(diagnostics.get("active", false))
		or not bool(diagnostics.get("enemy_visible", false))
		or String(diagnostics.get("route_label_text", ""))
			!= "Break Tailrace Sluice Leech"
	):
		_fail(scene, "Sluice Leech active contract is invalid")
		return

	var enemy := scene.get_node_or_null(SLUICE_LEECH_NODE) as CharacterBody2D
	if enemy == null:
		_fail(scene, "Factory scene missing Sluice Leech enemy")
		return
	enemy.set_physics_process(false)
	if not bool(enemy.call("request_attack")):
		_fail(scene, "Sluice Leech attack request was rejected")
		return
	var before_lunge_x: float = enemy.global_position.x
	enemy.call("advance_attack_frames", 18)
	if not bool(enemy.call("is_enemy_attack_active")):
		_fail(scene, "Sluice Leech did not enter active attack after 18 frames")
		return
	enemy.call("advance_attack_frames", 1)
	if is_equal_approx(enemy.global_position.x, before_lunge_x):
		_fail(scene, "Sluice Leech active attack did not lunge")
		return

	if not bool(scene.call("apply_damage", SLUICE_LEECH_ENTITY_ID, 999, {
		"source": &"story126_smoke",
	})):
		_fail(scene, "Sluice Leech did not accept route damage")
		return
	await process_frame
	diagnostics = scene.call(DIAGNOSTICS)
	var local_state: Dictionary = scene.call("get_local_state")
	if (
		not bool(diagnostics.get("cleared", false))
		or bool(diagnostics.get("enemy_visible", true))
		or String(diagnostics.get("route_label_text", ""))
			!= "Tailrace Sluice Leech Cleared"
		or not bool(local_state.get(STORY126_CLEARED_KEY, false))
	):
		_fail(scene, "Sluice Leech clear state did not persist")
		return

	print("old_factory_tailrace_exit_spillway_sluice_leech_skirmish_smoke=passed")
	_cleanup_and_quit(scene, 0)


func _tailrace_relay_checkpoint() -> Dictionary:
	return {
		"id": "old_factory_lower_deck_forward_pressure_aftershock_condenser_"
			+ "overflow_pump_runoff_outlet_service_sluice_tailrace_relay",
		"scene_id": "area_03_factory",
		"spawn_point": "lower_deck_forward_pressure_aftershock_condenser_"
			+ "overflow_pump_runoff_outlet_service_sluice_tailrace_relay",
		"position": Vector2(13480, 382),
	}


func _fail(scene: Node, message: String) -> void:
	push_error(message)
	_cleanup_and_quit(scene, 1)


func _cleanup_and_quit(scene: Node, exit_code: int) -> void:
	if scene != null:
		scene.queue_free()
		await process_frame
	quit(exit_code)
