extends SceneTree

const TOWER_SCENE_PATH: String = (
	"res://scenes/areas/central_tower_threshold.tscn"
)
const ROOST_NODE_PATH: String = (
	"CoolingShaftController/CoolingShaftRoost"
)
const ROOST_SPAWN_NODE_PATH: String = (
	"CoolingShaftController/CoolingShaftRoostSpawn"
)
const ENDPOINT_NODE_PATH: String = (
	"CoolingShaftController/CoolingShaftEndpoint"
)
const ROOST_SPAWN_POINT: String = "cooling_shaft_roost"


class SmokeSaveSystem:
	extends RefCounted

	var auto_save_calls: Array[Dictionary] = []

	func auto_save(
		player_state: Dictionary = {},
		world_state: Dictionary = {},
		settings: Dictionary = {}
	) -> bool:
		auto_save_calls.append({
			"player_state": player_state.duplicate(true),
			"world_state": world_state.duplicate(true),
			"settings": settings.duplicate(true),
		})
		return true


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed: PackedScene = load(TOWER_SCENE_PATH) as PackedScene
	if packed == null:
		_fail("tower_scene_missing")
		return
	var tower: Node = packed.instantiate()
	root.add_child(tower)
	tower.call("set_local_state", _story141_clear_state())
	var save_system := SmokeSaveSystem.new()
	if not bool(tower.call(
		"configure_cooling_shaft_save_system_runtime",
		save_system
	)):
		_fail("save_system_injection_failed")
		return

	var player: CharacterBody2D = tower.get_node_or_null(
		"Player"
	) as CharacterBody2D
	var sprite: AnimatedSprite2D = tower.get_node_or_null(
		"Player/Sprite"
	) as AnimatedSprite2D
	var roost: Node2D = tower.get_node_or_null(ROOST_NODE_PATH) as Node2D
	var roost_spawn: Marker2D = tower.get_node_or_null(
		ROOST_SPAWN_NODE_PATH
	) as Marker2D
	var endpoint: Node2D = tower.get_node_or_null(
		ENDPOINT_NODE_PATH
	) as Node2D
	if (
		player == null
		or sprite == null
		or roost == null
		or roost_spawn == null
		or endpoint == null
	):
		_fail("runtime_nodes_missing")
		return
	var abilities_before: Array[String] = _ability_strings(player)

	player.call("apply_damage", 20, {"source": &"story142_smoke_setup"})
	player.global_position = roost.global_position
	if not bool(tower.call("try_activate_cooling_shaft_roost", player)):
		_fail("roost_activation_failed")
		return
	var roost_active: Dictionary = tower.call(
		"get_central_tower_cooling_shaft_diagnostics"
	)
	if (
		int(player.call("get_current_hp")) != int(player.call("get_max_hp"))
		or int(roost_active.get("autosave_request_count", 0)) != 1
		or save_system.auto_save_calls.size() != 1
	):
		_fail("roost_recovery_or_autosave_failed")
		return

	player.global_position = Vector2(2920.0, 552.0)
	if not bool(tower.call("try_activate_cooling_shaft", player)):
		_fail("cooling_shaft_activation_failed")
		return
	tower.call("advance_cooling_shaft_time", 0.76)
	tower.call("advance_cooling_shaft_time", 0.51)
	var hp_before_arc: int = int(player.call("get_current_hp"))
	player.global_position = Vector2(3220.0, 430.0)
	if not bool(tower.call("apply_cooling_shaft_arc_contact", player)):
		_fail("active_arc_contact_failed")
		return
	if int(player.call("get_current_hp")) != hp_before_arc - 10:
		_fail("active_arc_damage_mismatch")
		return
	if bool(tower.call("apply_cooling_shaft_arc_contact", player)):
		_fail("arc_cooldown_rejected_no_contact")
		return

	if not bool(tower.call("apply_cooling_shaft_fall", player)):
		_fail("fall_not_applied")
		return
	tower.call("advance_central_tower_respawn_flow", 1.51)
	var revived: Dictionary = tower.call(
		"get_central_tower_cooling_shaft_diagnostics"
	)
	if (
		int(player.call("get_current_hp")) != 50
		or player.global_position.distance_to(roost_spawn.global_position) > 0.5
		or String(revived.get("flow_state", "")) != "revived"
		or String(Dictionary(revived.get(
			"last_discovered_savepoint",
			{}
		)).get("spawn_point", "")) != ROOST_SPAWN_POINT
	):
		_fail("roost_revive_failed")
		return
	tower.call("advance_central_tower_respawn_flow", 2.01)

	player.call("set_airborne", true)
	if not bool(player.call("request_double_jump")):
		_fail("real_double_jump_request_failed")
		return
	if player.velocity.y >= 0.0 or String(sprite.animation) != "jump":
		_fail("double_jump_motion_or_animation_failed")
		return
	if not bool(player.call("request_dash")):
		_fail("real_dash_request_failed")
		return
	if player.velocity.x <= 0.0 or String(sprite.animation) != "dash":
		_fail("dash_motion_or_animation_failed")
		return

	player.global_position = endpoint.global_position
	player.velocity = Vector2.ZERO
	if not bool(tower.call(
		"try_activate_cooling_shaft_endpoint",
		player
	)):
		_fail("endpoint_activation_failed")
		return
	var saved: Dictionary = tower.call("get_local_state")
	var secured: Dictionary = tower.call(
		"get_central_tower_cooling_shaft_diagnostics"
	)
	if (
		not bool(secured.get("traversed", false))
		or String(secured.get("objective_text", "")) != "Cooling Shaft Secured"
		or not bool(saved.get("central_tower_relay_mantis_defeated", false))
		or _ability_strings(player) != abilities_before
	):
		_fail("endpoint_or_state_failed")
		return

	var restored: Node = packed.instantiate()
	root.add_child(restored)
	restored.call("set_local_state", saved)
	var restored_diagnostics: Dictionary = restored.call(
		"get_central_tower_cooling_shaft_diagnostics"
	)
	var restored_player: Node = restored.get_node_or_null("Player")
	if (
		not bool(restored_diagnostics.get("roost_activated", false))
		or not bool(restored_diagnostics.get("traversed", false))
		or int(restored_diagnostics.get("roost_feedback_count", -1)) != 0
		or int(restored_diagnostics.get("endpoint_feedback_count", -1)) != 0
		or int(restored_diagnostics.get("autosave_request_count", -1)) != 0
		or _ability_strings(restored_player) != abilities_before
	):
		_fail("fresh_restore_replayed_or_lost_state")
		return

	root.remove_child(restored)
	restored.free()
	root.remove_child(tower)
	tower.free()
	await process_frame
	print("central_tower_cooling_shaft_roost_traverse_smoke=passed")
	quit(0)


func _story141_clear_state() -> Dictionary:
	return {
		"central_tower_threshold_roost_activated": true,
		"central_tower_threshold_guard_activated": true,
		"central_tower_threshold_guard_defeated": true,
		"central_tower_inner_relay_activated": true,
		"central_tower_inner_relay_parried": true,
		"central_tower_relay_mantis_activated": true,
		"central_tower_relay_mantis_defeated": true,
		"central_tower_inner_cache_claimed": false,
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
	push_error("central_tower_cooling_shaft_roost_traverse_smoke=" + reason)
	quit(1)
