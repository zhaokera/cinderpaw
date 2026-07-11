extends SceneTree

const UNDERGROUND_SCENE_PATH: String = "res://scenes/areas/underground_passage.tscn"
const UNDERGROUND_SCENE_ID: StringName = &"area_04_underground_passage"
const STALKER_ENTITY_ID: int = 2501
const STALKER_HITBOX_ID: StringName = &"underground_cistern_stalker_leap"
const ACTIVATION_X: float = 4050.0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed: PackedScene = load(UNDERGROUND_SCENE_PATH) as PackedScene
	if packed == null:
		_fail("underground_scene_missing")
		return
	var runtime_root := Node.new()
	runtime_root.name = "Story133RuntimeRoot"
	root.add_child(runtime_root)
	var underground: Node = packed.instantiate()
	runtime_root.add_child(underground)
	var scene_manager: Node = root.get_node_or_null("SceneManager")
	if scene_manager == null or not bool(scene_manager.call(
		"configure_runtime_scene_root",
		runtime_root,
		underground
	)):
		_fail("scene_manager_runtime_root_failed")
		return
	if not bool(scene_manager.call(
		"change_scene",
		UNDERGROUND_SCENE_ID,
		&"factory_drop_entry"
	)):
		_fail("underground_logical_scene_setup_failed")
		return
	underground.call("configure_scene_manager_runtime", scene_manager)
	underground.call("set_local_state", _story132_traversed_state())
	await process_frame

	var player: Node2D = underground.get_node_or_null("Player") as Node2D
	var enemy: CharacterBody2D = underground.get_node_or_null(
		"DeepCisternAmbushController/CisternStalker"
	) as CharacterBody2D
	if player == null or enemy == null:
		_fail("player_or_stalker_missing")
		return
	player.global_position.x = ACTIVATION_X
	if not bool(underground.call(
		"try_activate_deep_cistern_ambush",
		player
	)):
		_fail("stalker_activation_failed")
		return
	await process_frame
	enemy.set_physics_process(false)
	var active: Dictionary = underground.call(
		"get_underground_deep_cistern_diagnostics"
	)
	if String(active.get("encounter_state", "")) != "active" \
			or not bool(active.get("back_seal_blocking", false)) \
			or not bool(active.get("forward_seal_blocking", false)) \
			or String(active.get("enemy_animation", "")) == "":
		_fail("active_arena_contract_mismatch")
		return

	var hp_before: int = int(player.call("get_current_hp"))
	if not bool(enemy.call("request_attack")):
		_fail("stalker_attack_request_failed")
		return
	enemy.call("advance_attack_frames", 24)
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
		STALKER_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	if int(player.call("get_current_hp")) != hp_before - 14:
		_fail("stalker_real_damage_mismatch")
		return

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
	if not bool(underground.call("apply_damage", STALKER_ENTITY_ID, 999, {
		"source": &"story133_smoke_clear",
	})):
		_fail("stalker_clear_damage_rejected")
		return
	await process_frame

	var cleared: Dictionary = underground.call(
		"get_underground_deep_cistern_diagnostics"
	)
	var state: Dictionary = underground.call("get_local_state")
	if String(cleared.get("encounter_state", "")) != "cleared" \
			or bool(cleared.get("back_seal_blocking", true)) \
			or bool(cleared.get("forward_seal_blocking", true)) \
			or String(cleared.get("objective_text", "")) != "Deep Cistern Secured" \
			or not bool(state.get(
				"underground_deep_cistern_stalker_defeated",
				false
			)):
		_fail("stalker_clear_state_mismatch")
		return

	print("underground_deep_cistern_stalker_ambush_smoke=passed")
	runtime_root.queue_free()
	await process_frame
	quit(0)


func _story132_traversed_state() -> Dictionary:
	return {
		"underground_corrosion_channel_activated": true,
		"underground_corrosion_left_defeated": true,
		"underground_corrosion_right_defeated": true,
		"underground_corrosion_channel_cleared": true,
		"underground_corrosion_salvage_claimed": true,
		"underground_recovery_cistern_relay_activated": true,
		"underground_recovery_cistern_traversed": true,
		"unlocked_abilities": ["aerial_attack"],
	}


func _fail(reason: String) -> void:
	push_error("underground_deep_cistern_stalker_ambush_smoke=%s" % reason)
	quit(1)
