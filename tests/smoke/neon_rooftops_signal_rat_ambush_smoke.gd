extends SceneTree

const ROOFTOPS_SCENE_PATH: String = (
	"res://scenes/areas/neon_rooftops_entry.tscn"
)
const ROOFTOPS_SCENE_ID: StringName = &"area_05_neon_rooftops"
const SIGNAL_RAT_ENTITY_ID: int = 2601
const SIGNAL_RAT_HITBOX_ID: StringName = &"neon_signal_rat_lunge"
const ACTIVATION_X: float = 1650.0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed: PackedScene = load(ROOFTOPS_SCENE_PATH) as PackedScene
	if packed == null:
		_fail("rooftops_scene_missing")
		return
	var runtime_root := Node.new()
	runtime_root.name = "Story137RuntimeRoot"
	root.add_child(runtime_root)
	var rooftops: Node = packed.instantiate()
	runtime_root.add_child(rooftops)
	var scene_manager: Node = root.get_node_or_null("SceneManager")
	if scene_manager == null or not bool(scene_manager.call(
		"configure_runtime_scene_root",
		runtime_root,
		rooftops
	)):
		_fail("scene_manager_runtime_root_failed")
		return
	if not bool(scene_manager.call(
		"change_scene",
		ROOFTOPS_SCENE_ID,
		&"factory_rooftop_arrival"
	)):
		_fail("rooftops_logical_scene_setup_failed")
		return
	rooftops.call("configure_scene_manager_runtime", scene_manager)
	rooftops.call("set_local_state", _story136_traversed_state())
	await process_frame

	var player: Node2D = rooftops.get_node_or_null("Player") as Node2D
	var enemy: CharacterBody2D = rooftops.get_node_or_null(
		"SignalRoofEncounter/NeonSignalRat"
	) as CharacterBody2D
	if player == null or enemy == null:
		_fail("player_or_signal_rat_missing")
		return
	player.global_position = Vector2(ACTIVATION_X, 556.0)
	player.call("set_airborne", false)
	if not bool(rooftops.call(
		"try_activate_signal_roof_encounter",
		player
	)):
		_fail("signal_rat_activation_failed")
		return
	await process_frame
	enemy.set_physics_process(false)
	var active: Dictionary = rooftops.call("get_signal_roof_diagnostics")
	if String(active.get("encounter_state", "")) != "active" \
			or not bool(active.get("back_seal_blocking", false)) \
			or not bool(active.get("forward_seal_blocking", false)) \
			or String(active.get("enemy_animation", "")) == "":
		_fail("active_arena_contract_mismatch")
		return

	var hp_before: int = int(player.call("get_current_hp"))
	if not bool(enemy.call("request_attack")):
		_fail("signal_rat_attack_request_failed")
		return
	enemy.call("advance_attack_frames", 18)
	var enemy_collision: CollisionComponent = enemy.call(
		"get_collision_component"
	) as CollisionComponent
	var player_collision: CollisionComponent = player.call(
		"get_collision_component"
	) as CollisionComponent
	if enemy_collision == null or player_collision == null:
		_fail("collision_component_missing")
		return
	enemy_collision.process_detection_frame({
		SIGNAL_RAT_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	if int(player.call("get_current_hp")) != hp_before - 11:
		_fail("signal_rat_real_damage_mismatch")
		return

	player.call("set_airborne", false)
	var enemy_hp_before: int = int(enemy.call("get_current_hp"))
	if not bool(player.call("request_attack")):
		_fail("player_attack_request_failed")
		return
	player_collision.process_detection_frame({
		&"cat_claw_light": [enemy_collision.get_hurtbox()],
	})
	if int(enemy.call("get_current_hp")) >= enemy_hp_before:
		_fail("player_real_damage_mismatch")
		return
	if not bool(rooftops.call("apply_damage", SIGNAL_RAT_ENTITY_ID, 999, {
		"source": &"story137_smoke_clear",
	})):
		_fail("signal_rat_clear_damage_rejected")
		return
	await process_frame

	var cache: Node2D = rooftops.get_node_or_null(
		"SignalRoofEncounter/SignalCache"
	) as Node2D
	if cache == null:
		_fail("signal_cache_missing")
		return
	player.global_position = cache.global_position
	if not bool(rooftops.call("try_claim_signal_cache", player)):
		_fail("signal_cache_claim_failed")
		return
	if bool(rooftops.call("try_claim_signal_cache", player)):
		_fail("signal_cache_duplicate_claim_accepted")
		return
	var claimed: Dictionary = rooftops.call("get_signal_roof_diagnostics")
	var state: Dictionary = rooftops.call("get_local_state")
	if String(claimed.get("encounter_state", "")) != "claimed" \
			or bool(claimed.get("back_seal_blocking", true)) \
			or bool(claimed.get("forward_seal_blocking", true)) \
			or String(claimed.get("objective_text", "")) != "Signal Roof Secured" \
			or not bool(state.get(
				"neon_rooftops_signal_cache_claimed",
				false
			)):
		_fail("signal_roof_claimed_state_mismatch")
		return

	var restored: Node = packed.instantiate()
	runtime_root.add_child(restored)
	restored.call("set_local_state", state)
	await process_frame
	var restored_diagnostics: Dictionary = restored.call(
		"get_signal_roof_diagnostics"
	)
	if String(restored_diagnostics.get("encounter_state", "")) != "claimed" \
			or bool(restored_diagnostics.get("enemy_visible", true)) \
			or bool(restored_diagnostics.get("back_seal_blocking", true)) \
			or bool(restored_diagnostics.get("forward_seal_blocking", true)) \
			or int(restored_diagnostics.get("reward_feedback_count", -1)) != 0:
		_fail("signal_roof_restore_mismatch")
		return

	print("neon_rooftops_signal_rat_ambush_smoke=passed")
	runtime_root.queue_free()
	await process_frame
	quit(0)


func _story136_traversed_state() -> Dictionary:
	return {
		"neon_rooftops_entry_arrived": true,
		"neon_rooftops_entry_traversed": true,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb",
		],
	}


func _fail(reason: String) -> void:
	push_error("neon_rooftops_signal_rat_ambush_smoke=%s" % reason)
	quit(1)
