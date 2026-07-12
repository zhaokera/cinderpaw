extends SceneTree

const ROOFTOPS_SCENE_PATH: String = (
	"res://scenes/areas/neon_rooftops_entry.tscn"
)
const ROOFTOPS_SCENE_ID: StringName = &"area_05_neon_rooftops"
const ROOFTOPS_START_SPAWN: StringName = &"factory_rooftop_arrival"
const TOWER_SCENE_ID: StringName = &"area_05_central_tower"
const TOWER_ENTRY_SPAWN: StringName = &"neon_rooftops_threshold_arrival"
const ROOFTOPS_RETURN_SPAWN: StringName = &"central_tower_threshold_return"
const GUARD_NODE_PATH: String = (
	"ThresholdGuardController/CentralTowerThresholdGuard"
)
const GUARD_SPRITE_NODE_PATH: String = GUARD_NODE_PATH + "/Sprite"
const GUARD_ENTITY_ID: int = 2701
const GUARD_ATTACK_HITBOX_ID: StringName = (
	&"central_tower_guard_latch_thrust"
)
const GUARD_STARTUP_FRAMES: int = 24
const GUARD_DAMAGE: int = 14
const ACTIVATION_X: float = 420.0
const MAX_TRANSITION_STEPS: int = 64
const REQUIRED_PLAYER_ABILITIES: Array[String] = [
	"dash",
	"double_jump",
	"aerial_attack",
	"wall_climb",
	"parry",
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene_manager: Node = root.get_node_or_null("SceneManager")
	if scene_manager == null:
		_fail("scene_manager_missing")
		return
	var packed_rooftops: PackedScene = load(ROOFTOPS_SCENE_PATH) as PackedScene
	if packed_rooftops == null:
		_fail("rooftops_scene_missing")
		return

	var runtime_root := Node.new()
	runtime_root.name = "Story140RuntimeRoot"
	root.add_child(runtime_root)
	var rooftops: Node = packed_rooftops.instantiate()
	runtime_root.add_child(rooftops)
	if not bool(scene_manager.call(
		"configure_runtime_scene_root",
		runtime_root,
		rooftops
	)):
		_fail("runtime_root_configuration_failed")
		return
	if not bool(scene_manager.call(
		"change_scene",
		ROOFTOPS_SCENE_ID,
		ROOFTOPS_START_SPAWN
	)):
		_fail("rooftops_logical_scene_setup_failed")
		return
	rooftops.call("configure_scene_manager_runtime", scene_manager)
	rooftops.call("set_local_state", _story139_secured_state())
	await process_frame

	var rooftop_player: CharacterBody2D = rooftops.get_node_or_null(
		"Player"
	) as CharacterBody2D
	var tower_route: Node2D = rooftops.get_node_or_null(
		"CentralTowerRoute"
	) as Node2D
	if rooftop_player == null or tower_route == null:
		_fail("rooftops_player_or_tower_route_missing")
		return
	rooftop_player.global_position = tower_route.global_position
	rooftop_player.velocity = Vector2.ZERO
	if not bool(rooftops.call(
		"try_request_central_tower_entry",
		rooftop_player
	)):
		_fail("rooftops_to_tower_request_failed")
		return
	if not await _advance_until_scene(scene_manager, TOWER_SCENE_ID):
		_fail("tower_transition_timeout")
		return

	var tower: Node = scene_manager.call("get_current_runtime_scene_node") as Node
	if tower == null or not tower.has_method(
		"get_central_tower_threshold_diagnostics"
	):
		_fail("tower_runtime_scene_missing")
		return
	if String(scene_manager.call("get_current_spawn_point")) != String(
		TOWER_ENTRY_SPAWN
	):
		_fail("tower_spawn_id_mismatch")
		return
	var first_tower_instance_id: int = tower.get_instance_id()
	await process_frame
	var tower_player: CharacterBody2D = tower.get_node_or_null(
		"Player"
	) as CharacterBody2D
	var arrival: Marker2D = tower.get_node_or_null(
		"NeonRooftopsThresholdArrival"
	) as Marker2D
	var guard: CharacterBody2D = tower.get_node_or_null(
		GUARD_NODE_PATH
	) as CharacterBody2D
	var sprite: AnimatedSprite2D = tower.get_node_or_null(
		GUARD_SPRITE_NODE_PATH
	) as AnimatedSprite2D
	if tower_player == null or arrival == null or guard == null or sprite == null:
		_fail("tower_runtime_nodes_missing")
		return
	if tower_player.global_position.distance_to(arrival.global_position) > 0.5:
		_fail(
			"tower_arrival_position_mismatch actual=%s expected=%s spawn=%s"
			% [
				tower_player.global_position,
				arrival.global_position,
				String(scene_manager.call("get_current_spawn_point")),
			]
		)
		return
	if not _has_required_animation_frames(sprite):
		_fail("guard_animation_contract_failed")
		return
	var initial: Dictionary = tower.call(
		"get_central_tower_threshold_diagnostics"
	)
	if not bool(initial.get("threshold_roost_activated", false)):
		_fail("threshold_roost_not_activated")
		return
	var expected_unlocked_abilities: Array = Array(initial.get(
		"unlocked_abilities",
		[]
	)).duplicate()
	if not _contains_all_strings(
		expected_unlocked_abilities,
		REQUIRED_PLAYER_ABILITIES
	):
		_fail("tower_ability_state_not_restored")
		return

	tower_player.global_position.x = ACTIVATION_X
	if not bool(tower.call("try_activate_threshold_guard", tower_player)):
		_fail("guard_activation_failed")
		return
	await process_frame
	var active: Dictionary = tower.call(
		"get_central_tower_threshold_diagnostics"
	)
	if (
		String(active.get("encounter_state", "")) != "active"
		or not bool(active.get("rear_seal_blocking", false))
		or not bool(active.get("inner_seal_blocking", false))
	):
		_fail("encounter_did_not_seal")
		return

	guard.set_physics_process(false)
	if not bool(tower.call("request_threshold_guard_attack")):
		_fail("guard_attack_request_failed")
		return
	guard.call("advance_attack_frames", GUARD_STARTUP_FRAMES)
	var guard_collision: CollisionComponent = guard.call(
		"get_collision_component"
	) as CollisionComponent
	var player_collision: CollisionComponent = tower_player.call(
		"get_collision_component"
	) as CollisionComponent
	if guard_collision == null or player_collision == null:
		_fail("collision_components_missing")
		return
	var hp_before: int = int(tower_player.call("get_current_hp"))
	guard_collision.process_detection_frame({
		GUARD_ATTACK_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	if int(tower_player.call("get_current_hp")) != hp_before - GUARD_DAMAGE:
		_fail("guard_attack_damage_failed")
		return

	if not bool(tower.call(
		"apply_damage",
		GUARD_ENTITY_ID,
		999,
		{"source": &"story140_smoke"}
	)):
		_fail("guard_clear_damage_failed")
		return
	if String(sprite.animation) != "death":
		_fail("guard_death_animation_missing")
		return
	var cleared: Dictionary = tower.call(
		"get_central_tower_threshold_diagnostics"
	)
	if (
		String(cleared.get("encounter_state", "")) != "cleared"
		or bool(cleared.get("rear_seal_blocking", true))
		or bool(cleared.get("inner_seal_blocking", true))
		or String(cleared.get("objective_text", ""))
		!= "Central Tower Threshold Secured"
	):
		_fail("guard_clear_state_failed")
		return

	var return_route: Node2D = tower.get_node_or_null(
		"NeonRooftopsReturnRoute"
	) as Node2D
	if return_route == null:
		_fail("tower_return_route_missing")
		return
	tower_player.global_position = return_route.global_position
	tower_player.velocity = Vector2.ZERO
	if not bool(tower.call(
		"try_request_neon_rooftops_return",
		tower_player
	)):
		_fail("tower_to_rooftops_request_failed")
		return
	if not await _advance_until_scene(scene_manager, ROOFTOPS_SCENE_ID):
		_fail("rooftops_return_timeout")
		return

	var restored_rooftops: Node = scene_manager.call(
		"get_current_runtime_scene_node"
	) as Node
	if restored_rooftops == null or not restored_rooftops.has_method(
		"get_neon_rooftops_entry_diagnostics"
	):
		_fail("restored_rooftops_missing")
		return
	if String(scene_manager.call("get_current_spawn_point")) != String(
		ROOFTOPS_RETURN_SPAWN
	):
		_fail("rooftops_return_spawn_id_mismatch")
		return
	var restored_player: CharacterBody2D = restored_rooftops.get_node_or_null(
		"Player"
	) as CharacterBody2D
	var return_spawn: Marker2D = restored_rooftops.get_node_or_null(
		"CentralTowerThresholdReturn"
	) as Marker2D
	if (
		restored_player == null
		or return_spawn == null
		or restored_player.global_position.distance_to(
			return_spawn.global_position
		) > 0.5
	):
		_fail("rooftops_return_position_failed")
		return
	var restored: Dictionary = restored_rooftops.call(
		"get_neon_rooftops_entry_diagnostics"
	)
	var restored_state: Dictionary = restored_rooftops.call("get_local_state")
	if (
		not bool(restored.get("central_tower_route_available", false))
		or bool(restored.get("central_tower_transition_requested", true))
		or not bool(restored_state.get(
			"neon_rooftops_central_tower_threshold_secured",
			false
		))
		or not _has_exact_string_values(
			Array(restored.get("unlocked_abilities", [])),
			expected_unlocked_abilities
		)
	):
		_fail("restored_rooftops_state_failed")
		return
	var persisted_tower: Dictionary = scene_manager.call(
		"get_scene_state",
		TOWER_SCENE_ID
	)
	if not bool(persisted_tower.get(
		"central_tower_threshold_guard_defeated",
		false
	)):
		_fail("tower_clear_state_not_persisted")
		return

	var restored_tower_route: Node2D = restored_rooftops.get_node_or_null(
		"CentralTowerRoute"
	) as Node2D
	if restored_tower_route == null:
		_fail("restored_tower_route_missing")
		return
	restored_player.global_position = restored_tower_route.global_position
	restored_player.velocity = Vector2.ZERO
	if not bool(restored_rooftops.call(
		"try_request_central_tower_entry",
		restored_player
	)):
		_fail("tower_reentry_request_failed")
		return
	if not await _advance_until_scene(scene_manager, TOWER_SCENE_ID):
		_fail("tower_reentry_timeout")
		return
	var reused_tower: Node = scene_manager.call(
		"get_current_runtime_scene_node"
	) as Node
	if (
		reused_tower == null
		or reused_tower.get_instance_id() != first_tower_instance_id
	):
		_fail("tower_runtime_scene_not_reused")
		return
	if String(scene_manager.call("get_current_spawn_point")) != String(
		TOWER_ENTRY_SPAWN
	):
		_fail("tower_reentry_spawn_id_mismatch")
		return
	var reused_tower_state: Dictionary = reused_tower.call(
		"get_central_tower_threshold_diagnostics"
	)
	if (
		String(reused_tower_state.get("encounter_state", "")) != "cleared"
		or bool(reused_tower_state.get("guard_visible", true))
		or not _has_exact_string_values(
			Array(reused_tower_state.get("unlocked_abilities", [])),
			expected_unlocked_abilities
		)
	):
		_fail("reused_tower_state_failed")
		return
	var reused_player: CharacterBody2D = reused_tower.get_node_or_null(
		"Player"
	) as CharacterBody2D
	var reused_return_route: Node2D = reused_tower.get_node_or_null(
		"NeonRooftopsReturnRoute"
	) as Node2D
	if reused_player == null or reused_return_route == null:
		_fail("reused_tower_return_nodes_missing")
		return
	reused_player.global_position = reused_return_route.global_position
	reused_player.velocity = Vector2.ZERO
	if not bool(reused_tower.call(
		"try_request_neon_rooftops_return",
		reused_player
	)):
		_fail("reused_tower_return_request_failed")
		return
	if not await _advance_until_scene(scene_manager, ROOFTOPS_SCENE_ID):
		_fail("reused_tower_return_timeout")
		return
	if String(scene_manager.call("get_current_spawn_point")) != String(
		ROOFTOPS_RETURN_SPAWN
	):
		_fail("reused_tower_return_spawn_id_mismatch")
		return
	var second_restored_rooftops: Node = scene_manager.call(
		"get_current_runtime_scene_node"
	) as Node
	if (
		second_restored_rooftops == null
		or not second_restored_rooftops.has_method(
			"get_neon_rooftops_entry_diagnostics"
		)
	):
		_fail("second_restored_rooftops_missing")
		return
	var second_restored: Dictionary = second_restored_rooftops.call(
		"get_neon_rooftops_entry_diagnostics"
	)
	if not _has_exact_string_values(
		Array(second_restored.get("unlocked_abilities", [])),
		expected_unlocked_abilities
	):
		_fail("second_restored_rooftops_abilities_changed")
		return

	scene_manager.call("advance_deferred_unload", 4.0)
	if runtime_root.get_parent() != null:
		runtime_root.get_parent().remove_child(runtime_root)
	runtime_root.free()
	await process_frame
	print("central_tower_threshold_guard_handoff_smoke=passed")
	quit(0)


func _advance_until_scene(
	scene_manager: Node,
	target_scene_id: StringName
) -> bool:
	for _step: int in range(MAX_TRANSITION_STEPS):
		scene_manager.call("advance_loading", 0.1)
		await process_frame
		if StringName(scene_manager.call("get_current_scene")) == target_scene_id \
				and not bool(scene_manager.call("is_loading")):
			return true
	return false


func _has_required_animation_frames(sprite: AnimatedSprite2D) -> bool:
	if sprite.sprite_frames == null:
		return false
	for animation_name: StringName in [
		&"idle", &"run", &"attack_tell", &"attack", &"hurt", &"death",
	]:
		if (
			not sprite.sprite_frames.has_animation(animation_name)
			or sprite.sprite_frames.get_frame_count(animation_name) < 3
		):
			return false
	return true


func _contains_all_strings(actual: Array, expected: Array) -> bool:
	var normalized_actual: Array[String] = _normalized_strings(actual)
	for value: String in _normalized_strings(expected):
		if not normalized_actual.has(value):
			return false
	return true


func _has_exact_string_values(actual: Array, expected: Array) -> bool:
	return _normalized_strings(actual) == _normalized_strings(expected)


func _normalized_strings(values: Array) -> Array[String]:
	var normalized: Array[String] = []
	for value: Variant in values:
		normalized.append(String(value))
	normalized.sort()
	return normalized


func _story139_secured_state() -> Dictionary:
	return {
		"neon_rooftops_entry_arrived": true,
		"neon_rooftops_entry_traversed": true,
		"neon_rooftops_signal_rat_encounter_activated": true,
		"neon_rooftops_signal_rat_defeated": true,
		"neon_rooftops_signal_cache_claimed": true,
		"neon_rooftops_relay_spire_roost_activated": true,
		"neon_rooftops_relay_spire_traversed": true,
		"neon_rooftops_central_tower_trial_started": true,
		"neon_rooftops_central_tower_parry_count": 3,
		"neon_rooftops_central_tower_gate_unlocked": true,
		"neon_rooftops_central_tower_threshold_secured": true,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb", "parry",
		],
	}


func _fail(reason: String) -> void:
	push_error("central_tower_threshold_guard_handoff_smoke=" + reason)
	quit(1)
