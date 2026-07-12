extends SceneTree

const ROOFTOPS_SCENE_PATH: String = (
	"res://scenes/areas/neon_rooftops_entry.tscn"
)
const CONTROLLER_NODE_PATH: String = "TowerParryTrialController"
const EMITTER_NODE_PATH: String = "TowerParryTrialController/LaserEmitter"
const ENDPOINT_NODE_PATH: String = (
	"TowerParryTrialController/TowerThresholdEndpoint"
)
const ROOST_POSITION: Vector2 = Vector2(2760.0, 413.0)
const REQUIRED_PARRIES: int = 3


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed: PackedScene = load(ROOFTOPS_SCENE_PATH) as PackedScene
	if packed == null:
		_fail("scene_missing")
		return
	var rooftops: Node = packed.instantiate()
	root.add_child(rooftops)
	rooftops.call("set_local_state", _prerequisite_state())
	var player: CharacterBody2D = rooftops.get_node_or_null(
		"Player"
	) as CharacterBody2D
	var controller: Node = rooftops.get_node_or_null(CONTROLLER_NODE_PATH)
	var emitter: Node2D = rooftops.get_node_or_null(EMITTER_NODE_PATH) as Node2D
	var endpoint: Node2D = rooftops.get_node_or_null(
		ENDPOINT_NODE_PATH
	) as Node2D
	if player == null or controller == null or emitter == null or endpoint == null:
		_fail("runtime_nodes_missing")
		return

	player.global_position = emitter.global_position
	player.velocity = Vector2.ZERO
	if not bool(rooftops.call(
		"try_activate_central_tower_parry_trial",
		player
	)):
		_fail("trial_activation_failed")
		return
	controller.set_process(false)
	player.call("apply_damage", 85, {"source": &"story139_smoke_setup"})
	rooftops.call("advance_central_tower_parry_trial", 0.61)
	rooftops.call("advance_central_tower_parry_trial", 0.19)
	if int(player.call("get_current_hp")) != 0:
		_fail("laser_miss_was_not_lethal")
		return
	rooftops.call("advance_neon_relay_spire_respawn_flow", 1.51)
	var expected_hp: int = maxi(
		1,
		int(floor(float(player.call("get_max_hp")) * 0.5))
	)
	var revived: Dictionary = rooftops.call(
		"get_neon_relay_spire_diagnostics"
	)
	if int(player.call("get_current_hp")) != expected_hp \
			or player.global_position.distance_to(ROOST_POSITION) > 0.5 \
			or String(revived.get("respawn_state", "")) != "revived" \
			or not bool(revived.get("player_control_locked", false)):
		_fail("relay_roost_revive_failed")
		return
	rooftops.call("advance_neon_relay_spire_respawn_flow", 2.01)
	controller.set_process(false)
	player.global_position = emitter.global_position
	player.velocity = Vector2.ZERO

	for parry_index: int in range(REQUIRED_PARRIES):
		rooftops.call("advance_central_tower_parry_trial", 0.61)
		var strike: Dictionary = rooftops.call(
			"get_central_tower_parry_trial_diagnostics"
		)
		if String(strike.get("pulse_state", "")) != "strike":
			_fail("pulse_did_not_enter_strike_%d" % parry_index)
			return
		Input.action_press("parry")
		await physics_frame
		await process_frame
		Input.action_release("parry")
		var reflected: Dictionary = rooftops.call(
			"get_central_tower_parry_trial_diagnostics"
		)
		if int(reflected.get("successful_parries", 0)) != parry_index + 1:
			_fail("real_parry_not_reflected_%d" % parry_index)
			return
		var sprite: AnimatedSprite2D = player.get_node_or_null(
			"Sprite"
		) as AnimatedSprite2D
		if sprite == null or sprite.animation != &"parry":
			_fail("parry_animation_missing_%d" % parry_index)
			return
		for _frame: int in range(20):
			await physics_frame
		if parry_index < REQUIRED_PARRIES - 1:
			rooftops.call("advance_central_tower_parry_trial", 0.56)

	var opened: Dictionary = rooftops.call(
		"get_central_tower_parry_trial_diagnostics"
	)
	if String(opened.get("gate_state", "")) != "unlocked" \
			or bool(opened.get("gate_collision_blocking", true)) \
			or int(opened.get("parry_feedback_count", 0)) != REQUIRED_PARRIES \
			or int(opened.get("gate_unlock_feedback_count", 0)) != 1:
		_fail("tower_gate_not_opened_once")
		return

	player.global_position = endpoint.global_position
	player.velocity = Vector2.ZERO
	if not bool(rooftops.call(
		"try_activate_central_tower_threshold",
		player
	)):
		_fail("threshold_activation_failed")
		return
	var saved: Dictionary = rooftops.call("get_local_state")
	var restored: Node = packed.instantiate()
	root.add_child(restored)
	restored.call("set_local_state", saved)
	var restored_state: Dictionary = restored.call(
		"get_central_tower_parry_trial_diagnostics"
	)
	if not bool(restored_state.get("threshold_secured", false)) \
			or String(restored_state.get("gate_state", "")) != "unlocked" \
			or int(restored_state.get("successful_parries", 0)) != REQUIRED_PARRIES \
			or int(restored_state.get("parry_feedback_count", -1)) != 0 \
			or int(restored_state.get("gate_unlock_feedback_count", -1)) != 0 \
			or String(restored_state.get("objective_text", "")) \
			!= "Central Tower Gate Secured":
		_fail("restored_threshold_state_invalid")
		return

	root.remove_child(restored)
	restored.free()
	root.remove_child(rooftops)
	rooftops.free()
	await process_frame
	print("neon_rooftops_central_tower_parry_laser_trial_smoke=passed")
	quit(0)


func _prerequisite_state() -> Dictionary:
	return {
		"neon_rooftops_entry_arrived": true,
		"neon_rooftops_entry_traversed": true,
		"neon_rooftops_signal_rat_encounter_activated": true,
		"neon_rooftops_signal_rat_defeated": true,
		"neon_rooftops_signal_cache_claimed": true,
		"neon_rooftops_relay_spire_roost_activated": true,
		"neon_rooftops_relay_spire_traversed": true,
		"neon_rooftops_relay_spire_last_savepoint": {
			"id": "neon_rooftops_relay_spire_roost",
			"scene_id": "area_05_neon_rooftops",
			"spawn_point": "relay_spire_roost",
			"position": {"x": ROOST_POSITION.x, "y": ROOST_POSITION.y},
		},
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb", "parry",
		],
	}


func _fail(reason: String) -> void:
	Input.action_release("parry")
	push_error(
		"neon_rooftops_central_tower_parry_laser_trial_smoke=" + reason
	)
	quit(1)
