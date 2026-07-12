extends SceneTree

const TOWER_SCENE_PATH: String = (
	"res://scenes/areas/central_tower_threshold.tscn"
)
const MANTIS_NODE_PATH: String = (
	"InnerRelayController/CentralTowerRelayMantis"
)
const MANTIS_SPRITE_NODE_PATH: String = MANTIS_NODE_PATH + "/Sprite"
const MANTIS_ENTITY_ID: int = 2702
const MANTIS_HITBOX_ID: StringName = (
	&"central_tower_relay_mantis_scythe_dash"
)
const MANTIS_STARTUP_FRAMES: int = 20
const MANTIS_DAMAGE: int = 12
const ACTIVATION_X: float = 1500.0
const PULSE_X: float = 1800.0
const CACHE_X: float = 2320.0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed_tower: PackedScene = load(TOWER_SCENE_PATH) as PackedScene
	if packed_tower == null:
		_fail("tower_scene_missing")
		return
	var tower: Node = packed_tower.instantiate()
	root.add_child(tower)
	await process_frame
	tower.call("set_local_state", _threshold_clear_state())
	await process_frame

	var player: CharacterBody2D = tower.get_node_or_null(
		"Player"
	) as CharacterBody2D
	var mantis: CharacterBody2D = tower.get_node_or_null(
		MANTIS_NODE_PATH
	) as CharacterBody2D
	var sprite: AnimatedSprite2D = tower.get_node_or_null(
		MANTIS_SPRITE_NODE_PATH
	) as AnimatedSprite2D
	if player == null or mantis == null or sprite == null:
		_fail("runtime_nodes_missing")
		return
	if not _has_required_animation_frames(sprite):
		_fail("mantis_animation_contract_failed")
		return
	var abilities_before: Array[String] = _ability_strings(player)

	player.global_position = Vector2(ACTIVATION_X, 552.0)
	if not bool(tower.call("try_activate_inner_relay", player)):
		_fail("relay_activation_failed")
		return
	await process_frame
	var sealed: Dictionary = tower.call(
		"get_central_tower_inner_relay_diagnostics"
	)
	if (
		String(sealed.get("encounter_state", "")) != "relay"
		or not bool(sealed.get("back_shutter_blocking", false))
		or not bool(sealed.get("forward_shutter_blocking", false))
	):
		_fail("relay_room_did_not_seal")
		return

	player.global_position = Vector2(PULSE_X, 552.0)
	tower.call("advance_inner_relay_time", 0.56)
	if not bool(player.call("request_parry")):
		_fail("real_player_parry_failed")
		return
	var reflected: Dictionary = tower.call(
		"get_central_tower_inner_relay_diagnostics"
	)
	if (
		not bool(reflected.get("relay_parried", false))
		or not bool(reflected.get("mantis_visible", false))
		or String(reflected.get("pulse_state", "")) != "complete"
	):
		_fail("relay_reflection_state_failed")
		return

	for _frame: int in range(19):
		player.call("_physics_process", 1.0 / 60.0)
	mantis.set_physics_process(false)
	if not bool(tower.call("request_relay_mantis_attack")):
		_fail("mantis_attack_request_failed")
		return
	mantis.call("advance_attack_frames", MANTIS_STARTUP_FRAMES)
	var enemy_collision: CollisionComponent = mantis.call(
		"get_collision_component"
	) as CollisionComponent
	var player_collision: CollisionComponent = player.call(
		"get_collision_component"
	) as CollisionComponent
	if enemy_collision == null or player_collision == null:
		_fail("collision_components_missing")
		return
	var hp_before: int = int(player.call("get_current_hp"))
	enemy_collision.process_detection_frame({
		MANTIS_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	if int(player.call("get_current_hp")) != hp_before - MANTIS_DAMAGE:
		_fail("mantis_real_hit_damage_failed")
		return

	if not bool(tower.call(
		"apply_damage",
		MANTIS_ENTITY_ID,
		999,
		{"source": &"story141_smoke"}
	)):
		_fail("mantis_clear_damage_failed")
		return
	await process_frame
	var cleared: Dictionary = tower.call(
		"get_central_tower_inner_relay_diagnostics"
	)
	if (
		String(cleared.get("encounter_state", "")) != "cleared"
		or bool(cleared.get("back_shutter_blocking", true))
		or bool(cleared.get("forward_shutter_blocking", true))
		or not bool(cleared.get("cache_available", false))
	):
		_fail("mantis_clear_state_failed")
		return

	player.global_position = Vector2(CACHE_X, 552.0)
	if not bool(tower.call("try_claim_inner_relay_cache", player)):
		_fail("cache_claim_failed")
		return
	if bool(tower.call("try_claim_inner_relay_cache", player)):
		_fail("cache_duplicate_claim_accepted")
		return
	var saved: Dictionary = tower.call("get_local_state")
	if (
		not bool(saved.get("central_tower_relay_mantis_defeated", false))
		or not bool(saved.get("central_tower_inner_cache_claimed", false))
		or _ability_strings(player) != abilities_before
	):
		_fail("claimed_state_or_abilities_failed")
		return

	root.remove_child(tower)
	tower.free()
	var restored: Node = packed_tower.instantiate()
	root.add_child(restored)
	await process_frame
	restored.call("set_local_state", saved)
	await process_frame
	var restored_state: Dictionary = restored.call(
		"get_central_tower_inner_relay_diagnostics"
	)
	var restored_player: Node = restored.get_node_or_null("Player")
	if (
		String(restored_state.get("encounter_state", "")) != "claimed"
		or not bool(restored_state.get("mantis_defeated", false))
		or not bool(restored_state.get("cache_claimed", false))
		or bool(restored_state.get("mantis_visible", true))
		or int(restored_state.get("activation_feedback_count", -1)) != 0
		or int(restored_state.get("defeat_feedback_count", -1)) != 0
		or int(restored_state.get("reward_feedback_count", -1)) != 0
		or _ability_strings(restored_player) != abilities_before
	):
		_fail("fresh_restore_state_failed")
		return

	root.remove_child(restored)
	restored.free()
	await process_frame
	print("central_tower_inner_relay_skirmish_smoke=passed")
	quit(0)


func _has_required_animation_frames(sprite: AnimatedSprite2D) -> bool:
	if sprite.sprite_frames == null:
		return false
	for animation_name: StringName in [
		&"idle", &"run", &"attack_tell", &"attack", &"hurt", &"death",
	]:
		if (
			not sprite.sprite_frames.has_animation(animation_name)
			or sprite.sprite_frames.get_frame_count(animation_name) != 3
		):
			return false
	return true


func _ability_strings(player: Node) -> Array[String]:
	var result: Array[String] = []
	if player == null or not player.has_method("get_unlocked_abilities"):
		return result
	for value: Variant in Array(player.call("get_unlocked_abilities")):
		result.append(String(value))
	result.sort()
	return result


func _threshold_clear_state() -> Dictionary:
	return {
		"central_tower_threshold_roost_activated": true,
		"central_tower_threshold_guard_activated": true,
		"central_tower_threshold_guard_defeated": true,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb", "parry",
		],
	}


func _fail(reason: String) -> void:
	push_error("central_tower_inner_relay_skirmish_smoke=" + reason)
	quit(1)
