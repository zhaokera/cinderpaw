extends SceneTree


const FACTORY_SCENE := "res://scenes/factory_route_transition_shell.tscn"
const RELAY_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_diagnostics"
)
const RELAY_ACTIVATE := (
	"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
)
const RELAY_ID := (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
)
const RELAY_SPAWN_POINT := (
	"lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
)


class SmokeSceneManager:
	extends RefCounted

	var current_scene: StringName = &"area_03_factory"
	var current_spawn_point: StringName = &"factory_gate_entry"
	var request_calls: Array[Dictionary] = []

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == &"area_03_factory" or scene_id == &"main"

	func request_scene_change(
		scene_id: StringName,
		spawn_point: StringName = &"default"
	) -> bool:
		request_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		var known: bool = has_scene(scene_id)
		if known:
			current_scene = scene_id
			current_spawn_point = spawn_point
		return known

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn_point


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

	for method_name: String in [RELAY_DIAGNOSTICS, RELAY_ACTIVATE]:
		if not scene.has_method(method_name):
			push_error("Factory scene missing tailrace relay method: %s" % method_name)
			_cleanup_and_quit(scene, 1)
			return

	scene.call("set_local_state", {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared": true,
	})
	await process_frame

	var diagnostics: Dictionary = scene.call(RELAY_DIAGNOSTICS)
	if not bool(diagnostics.get("present", false)):
		push_error("Tailrace relay is not present")
		_cleanup_and_quit(scene, 1)
		return
	if not bool(diagnostics.get("available", false)):
		push_error("Tailrace relay is not available after ambush clear")
		_cleanup_and_quit(scene, 1)
		return

	var player := scene.get_node_or_null("Player") as Node2D
	var relay_position: Vector2 = diagnostics.get("position", Vector2.ZERO) as Vector2
	if player == null:
		push_error("Factory scene missing Player")
		_cleanup_and_quit(scene, 1)
		return
	player.global_position = relay_position

	if not bool(scene.call(RELAY_ACTIVATE, player)):
		push_error("Tailrace relay did not activate in range")
		_cleanup_and_quit(scene, 1)
		return
	if bool(scene.call(RELAY_ACTIVATE, player)):
		push_error("Tailrace relay activated more than once")
		_cleanup_and_quit(scene, 1)
		return

	diagnostics = scene.call(RELAY_DIAGNOSTICS)
	if not bool(diagnostics.get("activated", false)):
		push_error("Tailrace relay activated flag missing")
		_cleanup_and_quit(scene, 1)
		return
	if String(diagnostics.get("route_label_text", "")) != "Tailrace Relay Secured":
		push_error("Tailrace relay route label mismatch")
		_cleanup_and_quit(scene, 1)
		return
	if int(diagnostics.get("activation_vfx_spawn_count", 0)) != 1:
		push_error("Tailrace relay activation VFX did not spawn once")
		_cleanup_and_quit(scene, 1)
		return

	var last_savepoint: Dictionary = diagnostics.get("last_savepoint", {}) as Dictionary
	if String(last_savepoint.get("id", "")) != RELAY_ID:
		push_error("Tailrace relay savepoint id mismatch")
		_cleanup_and_quit(scene, 1)
		return
	if String(last_savepoint.get("scene_id", "")) != "area_03_factory":
		push_error("Tailrace relay scene id mismatch")
		_cleanup_and_quit(scene, 1)
		return
	if String(last_savepoint.get("spawn_point", "")) != RELAY_SPAWN_POINT:
		push_error("Tailrace relay spawn point mismatch")
		_cleanup_and_quit(scene, 1)
		return

	var scene_manager := SmokeSceneManager.new()
	if not bool(scene.call("configure_scene_manager_runtime", scene_manager)):
		push_error("Failed to configure smoke scene manager")
		_cleanup_and_quit(scene, 1)
		return
	var max_hp: int = int(player.call("get_max_hp"))
	player.global_position = relay_position + Vector2(260.0, 0.0)
	player.call("apply_damage", max_hp, {
		"source": "smoke_service_sluice_tailrace_relay",
		"damage_type": "lethal_probe",
	})
	scene.call("advance_factory_respawn_flow", 1.51)

	if scene_manager.request_calls.size() != 1:
		push_error("Tailrace relay respawn did not request one scene change")
		_cleanup_and_quit(scene, 1)
		return
	if String(scene_manager.request_calls[0].get("scene_id", "")) != "area_03_factory":
		push_error("Tailrace relay respawn scene mismatch")
		_cleanup_and_quit(scene, 1)
		return
	if String(scene_manager.request_calls[0].get("spawn_point", "")) != RELAY_SPAWN_POINT:
		push_error("Tailrace relay respawn spawn point mismatch")
		_cleanup_and_quit(scene, 1)
		return
	if player.global_position.distance_to(relay_position) > 1.0:
		push_error("Player did not respawn at tailrace relay")
		_cleanup_and_quit(scene, 1)
		return

	print("service_sluice_tailrace_relay_smoke=passed")
	_cleanup_and_quit(scene, 0)


func _cleanup_and_quit(scene: Node, exit_code: int) -> void:
	scene.queue_free()
	await process_frame
	quit(exit_code)
