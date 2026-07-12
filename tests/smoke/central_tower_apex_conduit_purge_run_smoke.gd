extends SceneTree

const TOWER_SCENE_PATH: String = (
	"res://scenes/areas/central_tower_threshold.tscn"
)
const ROOST_SPAWN: Vector2 = Vector2(5260.0, 252.0)
const TRIGGER_POSITION: Vector2 = Vector2(5360.0, 252.0)
const PURGE_START: Vector2 = Vector2(5200.0, 360.0)
const ENDPOINT_POSITION: Vector2 = Vector2(6280.0, 296.0)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed: PackedScene = load(TOWER_SCENE_PATH) as PackedScene
	if packed == null:
		_fail("tower_scene_missing")
		return
	var tower: Node = packed.instantiate()
	root.add_child(tower)
	tower.call("set_local_state", _story143_complete_state())
	var player: CharacterBody2D = tower.get_node_or_null(
		"Player"
	) as CharacterBody2D
	var controller: Node = tower.get_node_or_null("ApexPurgeController")
	var purge_wall: Area2D = tower.get_node_or_null(
		"ApexPurgeController/PurgeWall"
	) as Area2D
	if player == null or controller == null or purge_wall == null:
		_fail("runtime_nodes_missing")
		return
	var abilities_before: Array[String] = _ability_strings(player)

	player.global_position = ROOST_SPAWN
	if not bool(tower.call("try_activate_apex_roost", player)):
		_fail("roost_activation_failed")
		return
	player.global_position = TRIGGER_POSITION
	if not bool(tower.call("try_trigger_apex_purge", player)):
		_fail("purge_trigger_failed")
		return
	tower.call("advance_apex_purge_time", 0.75)
	var warning_complete: Dictionary = tower.call(
		"get_central_tower_apex_diagnostics"
	)
	if (
		not bool(warning_complete.get("purge_active", false))
		or Vector2(warning_complete.get("purge_position", Vector2.ZERO)) != PURGE_START
	):
		_fail("warning_contract_failed")
		return
	tower.call("advance_apex_purge_time", 1.0)
	var moving: Dictionary = tower.call("get_central_tower_apex_diagnostics")
	if not is_equal_approx(
		Vector2(moving.get("purge_position", Vector2.ZERO)).x,
		5350.0
	):
		_fail("purge_motion_failed")
		return
	if not bool(tower.call("apply_apex_purge_contact", player)):
		_fail("purge_contact_failed")
		return
	tower.call("advance_central_tower_respawn_flow", 1.6)
	var reset: Dictionary = tower.call("get_central_tower_apex_diagnostics")
	if (
		int(player.call("get_current_hp")) != 50
		or player.global_position != ROOST_SPAWN
		or bool(reset.get("attempt_triggered", true))
		or bool(reset.get("purge_active", true))
		or Vector2(reset.get("purge_position", Vector2.ZERO)) != PURGE_START
		or _ability_strings(player) != abilities_before
	):
		_fail("roost_retry_failed")
		return

	player.global_position = TRIGGER_POSITION
	if not bool(tower.call("try_trigger_apex_purge", player)):
		_fail("retry_trigger_failed")
		return
	player.global_position = ENDPOINT_POSITION
	if not bool(tower.call("try_activate_apex_endpoint", player)):
		_fail("endpoint_failed")
		return
	var saved: Dictionary = tower.call("get_local_state")
	if (
		not bool(saved.get("central_tower_apex_roost_activated", false))
		or not bool(saved.get("central_tower_apex_approach_secured", false))
		or not bool(saved.get("central_tower_deep_lift_ascended", false))
	):
		_fail("durable_state_failed")
		return

	var restored: Node = packed.instantiate()
	root.add_child(restored)
	restored.call("set_local_state", saved)
	var restored_state: Dictionary = restored.call(
		"get_central_tower_apex_diagnostics"
	)
	if (
		not bool(restored_state.get("roost_activated", false))
		or not bool(restored_state.get("approach_secured", false))
		or bool(restored_state.get("purge_active", true))
		or int(restored_state.get("roost_feedback_count", -1)) != 0
		or int(restored_state.get("trigger_feedback_count", -1)) != 0
		or int(restored_state.get("endpoint_feedback_count", -1)) != 0
		or int(restored_state.get("audio_request_count", -1)) != 0
		or int(restored_state.get("vfx_request_count", -1)) != 0
	):
		_fail("fresh_restore_failed")
		return

	root.remove_child(restored)
	restored.free()
	root.remove_child(tower)
	tower.free()
	await process_frame
	print("central_tower_apex_conduit_purge_run_smoke=passed")
	quit(0)


func _story143_complete_state() -> Dictionary:
	return {
		"central_tower_threshold_roost_activated": true,
		"central_tower_threshold_guard_activated": true,
		"central_tower_threshold_guard_defeated": true,
		"central_tower_inner_relay_activated": true,
		"central_tower_inner_relay_parried": true,
		"central_tower_relay_mantis_activated": true,
		"central_tower_relay_mantis_defeated": true,
		"central_tower_inner_cache_claimed": false,
		"central_tower_cooling_shaft_roost_activated": true,
		"central_tower_cooling_shaft_activated": true,
		"central_tower_cooling_shaft_traversed": true,
		"central_tower_cooling_shaft_last_savepoint": {
			"id": "central_tower_cooling_shaft_roost",
			"scene_id": "area_05_central_tower",
			"spawn_point": "cooling_shaft_roost",
			"position": {"x": 2740.0, "y": 552.0},
		},
		"central_tower_counterweight_sentry_defeated": true,
		"central_tower_deep_lift_ascended": true,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb", "parry",
		],
	}


func _ability_strings(player: Node) -> Array[String]:
	var result: Array[String] = []
	if player == null or not player.has_method("get_unlocked_abilities"):
		return result
	for value: Variant in Array(player.call("get_unlocked_abilities")):
		result.append(String(value))
	result.sort()
	return result


func _fail(reason: String) -> void:
	push_error("central_tower_apex_conduit_purge_run_smoke=" + reason)
	quit(1)
