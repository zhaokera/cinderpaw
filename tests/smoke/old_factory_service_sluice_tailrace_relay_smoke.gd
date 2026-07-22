extends SceneTree


const FACTORY_SCENE := "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_GATE_ENTRY_SPAWN_POINT: StringName = &"factory_gate_entry"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const FRAME_COUNT := 180
const RELAY_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_diagnostics"
)
const RUNOFF_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_diagnostics"
)
const RELAY_ID := (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
)
const RELAY_SPAWN_POINT := (
	"lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
)
const RELAY_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelaySavepoint"
)


class SmokeSceneManager:
	extends RefCounted

	var current_scene: StringName = FACTORY_SCENE_ID
	var current_spawn_point: StringName = FACTORY_GATE_ENTRY_SPAWN_POINT
	var pending_scene: StringName = &""
	var pending_spawn_point: StringName = &""
	var loading: bool = false
	var request_calls: Array[Dictionary] = []

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == FACTORY_SCENE_ID or scene_id == &"main"

	func request_scene_change(
		scene_id: StringName,
		spawn_point: StringName = &"default"
	) -> bool:
		request_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		if not has_scene(scene_id):
			return false
		pending_scene = scene_id
		pending_spawn_point = spawn_point
		loading = true
		return true

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn_point

	func get_pending_scene() -> StringName:
		return pending_scene

	func get_pending_spawn_point() -> StringName:
		return pending_spawn_point

	func is_loading() -> bool:
		return loading


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(FACTORY_SCENE) as PackedScene
	if packed == null:
		push_error("Failed to load factory route transition shell")
		quit(1)
		return

	var scene := packed.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	for method_name: String in [RELAY_DIAGNOSTICS, RUNOFF_DIAGNOSTICS]:
		if not scene.has_method(method_name):
			_fail(scene, "Factory scene missing tailrace relay method: %s" % method_name)
			return

	scene.call("set_local_state", _relay_ready_state())
	var scene_manager := SmokeSceneManager.new()
	if not bool(scene.call("configure_scene_manager_runtime", scene_manager)):
		_fail(scene, "Failed to configure smoke SceneManager")
		return

	var player := scene.get_node_or_null("Player") as PlayerController
	var relay := scene.get_node_or_null(RELAY_NODE) as Node2D
	if player == null or relay == null:
		_fail(scene, "Factory scene missing Player or Tailrace Relay")
		return
	var interaction_area := relay.get_node_or_null("InteractionArea") as Area2D
	if interaction_area == null:
		_fail(scene, "Tailrace Relay missing InteractionArea")
		return

	player.global_position = Vector2(relay.global_position.x - 176.0, 482.0)
	player.velocity = Vector2.ZERO
	await physics_frame
	await physics_frame
	var waiting: Dictionary = scene.call(RELAY_DIAGNOSTICS)
	var locked_runoff: Dictionary = scene.call(RUNOFF_DIAGNOSTICS)
	if not bool(waiting.get("available", false)) or bool(waiting.get("activated", true)):
		_fail(scene, "Tailrace Relay is not waiting after Story118")
		return
	if interaction_area.get_overlapping_bodies().has(player):
		_fail(scene, "Player started inside Tailrace Relay contact")
		return
	if bool(locked_runoff.get("available", true)) or bool(locked_runoff.get("visible", true)):
		_fail(scene, "Story120 is visible before Tailrace Relay activation")
		return

	var start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(60):
		await physics_frame
		await process_frame
		waiting = scene.call(RELAY_DIAGNOSTICS)
		if bool(waiting.get("activated", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	await process_frame

	var activated: Dictionary = scene.call(RELAY_DIAGNOSTICS)
	if player.global_position.x - start_x < 40.0:
		_fail(scene, "move_right did not move Player into Tailrace Relay")
		return
	if not bool(activated.get("activated", false)):
		_fail(scene, "Real contact did not activate Tailrace Relay")
		return
	if bool(activated.get("interaction_monitoring", true)):
		_fail(scene, "Tailrace Relay contact remained active after activation")
		return
	if bool(activated.get("prompt_visible", true)):
		_fail(scene, "Tailrace Relay prompt remained visible after activation")
		return
	if int(activated.get("activation_vfx_spawn_count", 0)) != 1:
		_fail(scene, "Tailrace Relay activation VFX did not spawn exactly once")
		return
	if String(activated.get("route_label_text", "")) != "Tailrace Relay Secured":
		_fail(scene, "Tailrace Relay secured route label mismatch")
		return
	var last_savepoint: Dictionary = activated.get("last_savepoint", {}) as Dictionary
	if String(last_savepoint.get("id", "")) != RELAY_ID:
		_fail(scene, "Tailrace Relay savepoint id mismatch")
		return
	if String(last_savepoint.get("scene_id", "")) != String(FACTORY_SCENE_ID):
		_fail(scene, "Tailrace Relay scene id mismatch")
		return
	if String(last_savepoint.get("spawn_point", "")) != RELAY_SPAWN_POINT:
		_fail(scene, "Tailrace Relay spawn point mismatch")
		return

	var ready_runoff: Dictionary = scene.call(RUNOFF_DIAGNOSTICS)
	if not bool(ready_runoff.get("available", false)):
		_fail(scene, "Story120 is unavailable after Tailrace Relay activation")
		return
	if not bool(ready_runoff.get("visible", false)):
		_fail(scene, "Story120 is hidden after Tailrace Relay activation")
		return
	if bool(ready_runoff.get("active", true)):
		_fail(scene, "Story120 activated in the Tailrace Relay contact frame")
		return

	var runoff_activation_x: float = float(ready_runoff.get("activation_x", 0.0))
	scene.call("_process", 0.0)
	player.global_position = Vector2(runoff_activation_x + 4.0, 482.0)
	player.velocity = Vector2.ZERO
	scene.call("_process", 0.0)
	var stationary_runoff: Dictionary = scene.call(RUNOFF_DIAGNOSTICS)
	if bool(stationary_runoff.get("active", false)):
		_fail(scene, "Story120 activated without fresh positive-x movement")
		return

	player.global_position = Vector2(relay.global_position.x, 482.0)
	player.velocity = Vector2.ZERO
	scene.call("_process", 0.0)
	var max_hp: int = player.get_max_hp()
	player.apply_damage(max_hp, {
		"source": &"story230_smoke_lethal_probe",
		"damage_type": &"lethal_probe",
	})
	var sprite := player.get_node_or_null("Sprite") as AnimatedSprite2D
	if sprite == null or String(sprite.animation) != "death":
		_fail(scene, "Player did not enter death frame animation")
		return
	if String(scene.call(
		"get_factory_respawn_flow_diagnostics"
	).get("state", "")) != "dying":
		_fail(scene, "Factory respawn flow did not enter dying")
		return

	scene.call("advance_factory_respawn_flow", 1.51)
	if scene_manager.request_calls.size() != 1:
		_fail(scene, "Tailrace Relay respawn did not request one scene change")
		return
	if String(scene_manager.request_calls[0].get("scene_id", "")) != String(
		FACTORY_SCENE_ID
	):
		_fail(scene, "Tailrace Relay respawn scene mismatch")
		return
	if String(scene_manager.request_calls[0].get("spawn_point", "")) != RELAY_SPAWN_POINT:
		_fail(scene, "Tailrace Relay respawn spawn point mismatch")
		return
	if player.global_position.distance_to(relay.global_position) > 1.0:
		_fail(scene, "Player did not respawn at Tailrace Relay")
		return
	if player.get_current_hp() != maxi(1, int(round(max_hp * 0.5))):
		_fail(scene, "Tailrace Relay respawn did not restore 50 percent HP")
		return
	if String(sprite.animation) != "revive" or not player.is_respawn_visual_active():
		_fail(scene, "Player revive presentation is not active")
		return
	var respawn_flow: Dictionary = scene.call("get_factory_respawn_flow_diagnostics")
	if String(respawn_flow.get("state", "")) != "revived":
		_fail(scene, "Factory respawn flow did not enter revived")
		return
	if not bool(respawn_flow.get("control_locked", false)):
		_fail(scene, "Player control was not locked during revive")
		return

	scene.call("advance_factory_respawn_flow", 2.01)
	_release_gameplay_actions()
	for _frame: int in range(FRAME_COUNT):
		await process_frame

	respawn_flow = scene.call("get_factory_respawn_flow_diagnostics")
	var final_runoff: Dictionary = scene.call(RUNOFF_DIAGNOSTICS)
	var final_relay: Dictionary = scene.call(RELAY_DIAGNOSTICS)
	if String(respawn_flow.get("state", "")) != "playing":
		_fail(scene, "Factory respawn flow did not return to playing")
		return
	if bool(respawn_flow.get("control_locked", true)):
		_fail(scene, "Player control remained locked after revive")
		return
	if bool(final_runoff.get("active", true)) or bool(final_runoff.get("crossed", true)):
		_fail(scene, "Story120 did not remain idle for 180 frames")
		return
	if bool(final_runoff.get("hazard_contact_active", true)):
		_fail(scene, "Story120 hazard contact activated during relay handoff")
		return
	if int(final_relay.get("activation_vfx_spawn_count", 0)) != 1:
		_fail(scene, "Tailrace Relay activation VFX replayed")
		return
	if scene_manager.request_calls.size() != 1:
		_fail(scene, "Tailrace Relay respawn request replayed")
		return

	print("story119_production_smoke=passed frames=%d" % FRAME_COUNT)
	_cleanup_and_quit(scene, 0)


func _relay_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_crossed": false,
	}


func _release_gameplay_actions() -> void:
	Input.action_release(MOVE_RIGHT_ACTION)


func _fail(scene: Node, message: String) -> void:
	push_error(message)
	_release_gameplay_actions()
	_cleanup_and_quit(scene, 1)


func _cleanup_and_quit(scene: Node, exit_code: int) -> void:
	_release_gameplay_actions()
	paused = false
	scene.queue_free()
	await process_frame
	quit(exit_code)
