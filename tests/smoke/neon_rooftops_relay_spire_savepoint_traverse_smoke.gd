extends SceneTree

const ROOFTOPS_SCENE_PATH: String = (
	"res://scenes/areas/neon_rooftops_entry.tscn"
)
const ROOST_NODE_PATH: String = "RelaySpireController/RelaySpireRoost"
const ENDPOINT_NODE_PATH: String = "RelaySpireController/TowerApproachEndpoint"
const ROOST_SPAWN_POINT: String = "relay_spire_roost"


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
	var packed: PackedScene = load(ROOFTOPS_SCENE_PATH) as PackedScene
	if packed == null:
		_fail("scene_missing")
		return
	var rooftops: Node = packed.instantiate()
	root.add_child(rooftops)
	rooftops.call("set_local_state", {
		"neon_rooftops_entry_arrived": true,
		"neon_rooftops_entry_traversed": true,
		"neon_rooftops_signal_rat_encounter_activated": true,
		"neon_rooftops_signal_rat_defeated": true,
		"neon_rooftops_signal_cache_claimed": true,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb",
		],
	})
	var save_system := SmokeSaveSystem.new()
	if not bool(rooftops.call(
		"configure_neon_relay_spire_save_system_runtime",
		save_system
	)):
		_fail("save_system_injection_failed")
		return
	var player: CharacterBody2D = rooftops.get_node_or_null(
		"Player"
	) as CharacterBody2D
	var roost: Node2D = rooftops.get_node_or_null(ROOST_NODE_PATH) as Node2D
	var endpoint: Node2D = rooftops.get_node_or_null(
		ENDPOINT_NODE_PATH
	) as Node2D
	if player == null or roost == null or endpoint == null:
		_fail("runtime_nodes_missing")
		return

	player.call("apply_damage", 30, {"source": &"story138_smoke_setup"})
	player.global_position = roost.global_position
	player.velocity = Vector2.ZERO
	if not bool(rooftops.call(
		"try_activate_neon_relay_spire_roost",
		player
	)):
		_fail("roost_activation_failed")
		return
	var active: Dictionary = rooftops.call("get_neon_relay_spire_diagnostics")
	if int(active.get("autosave_request_count", 0)) != 1 \
			or save_system.auto_save_calls.size() != 1 \
			or int(player.call("get_current_hp")) != int(player.call("get_max_hp")):
		_fail("roost_recovery_or_autosave_failed")
		return

	if not bool(rooftops.call("apply_neon_relay_spire_fall", player)):
		_fail("fall_not_applied")
		return
	rooftops.call("advance_neon_relay_spire_respawn_flow", 1.51)
	var expected_hp: int = maxi(
		1,
		int(floor(float(player.call("get_max_hp")) * 0.5))
	)
	var revived: Dictionary = rooftops.call("get_neon_relay_spire_diagnostics")
	if int(player.call("get_current_hp")) != expected_hp \
			or player.global_position.distance_to(roost.global_position) > 0.5 \
			or String(revived.get("respawn_state", "")) != "revived" \
			or String(Dictionary(revived.get(
				"last_selected_respawn_point",
				{}
			)).get("spawn_point", "")) != ROOST_SPAWN_POINT:
		_fail("roost_revive_failed")
		return
	rooftops.call("advance_neon_relay_spire_respawn_flow", 2.01)

	player.global_position = Vector2(3148.0, 560.0)
	player.velocity = Vector2.ZERO
	Input.action_press("move_right")
	Input.action_press("move_up")
	var climb_started: bool = false
	var climb_start_y: float = player.global_position.y
	for _frame: int in range(180):
		await physics_frame
		var wall_state: Dictionary = player.call("get_wall_climb_diagnostics")
		if bool(wall_state.get("active", false)):
			if not climb_started:
				climb_started = true
				climb_start_y = player.global_position.y
			if player.global_position.y < 210.0:
				break
	Input.action_release("move_right")
	Input.action_release("move_up")
	if not climb_started:
		_fail("real_relay_spire_wall_climb_never_started")
		return
	if player.global_position.y >= climb_start_y - 120.0:
		_fail("real_relay_spire_wall_climb_gained_no_height")
		return
	var climb_state: Dictionary = player.call("get_wall_climb_diagnostics")
	if String(climb_state.get("animation", "")) != "wall_climb":
		_fail("wall_climb_animation_missing")
		return

	player.global_position = endpoint.global_position
	player.velocity = Vector2.ZERO
	if not bool(rooftops.call(
		"try_activate_neon_relay_spire_endpoint",
		player
	)):
		_fail("endpoint_activation_failed")
		return
	var saved: Dictionary = rooftops.call("get_local_state")
	var secured: Dictionary = rooftops.call("get_neon_relay_spire_diagnostics")
	if not bool(secured.get("traversed", false)) \
			or String(secured.get("objective_text", "")) != "Tower Approach Reached" \
			or not bool(saved.get(
				"neon_rooftops_signal_cache_claimed",
				false
			)) \
			or not Array(saved.get("unlocked_abilities", [])).has("wall_climb"):
		_fail("endpoint_or_state_failed")
		return

	var restored: Node = packed.instantiate()
	root.add_child(restored)
	restored.call("set_local_state", saved)
	var restored_diagnostics: Dictionary = restored.call(
		"get_neon_relay_spire_diagnostics"
	)
	if not bool(restored_diagnostics.get("roost_activated", false)) \
			or not bool(restored_diagnostics.get("traversed", false)) \
			or int(restored_diagnostics.get("autosave_request_count", -1)) != 0 \
			or int(restored_diagnostics.get("audio_request_count", -1)) != 0 \
			or bool(restored_diagnostics.get("access_seal_blocking", true)):
		_fail("fresh_restore_replayed_or_lost_state")
		return

	root.remove_child(restored)
	restored.free()
	root.remove_child(rooftops)
	rooftops.free()
	await process_frame
	print("neon_rooftops_relay_spire_savepoint_traverse_smoke=passed")
	quit(0)


func _fail(reason: String) -> void:
	Input.action_release("move_right")
	Input.action_release("move_up")
	push_error(
		"neon_rooftops_relay_spire_savepoint_traverse_smoke=" + reason
	)
	quit(1)
