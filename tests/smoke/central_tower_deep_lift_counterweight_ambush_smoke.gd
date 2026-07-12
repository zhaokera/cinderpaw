extends SceneTree

const TOWER_SCENE_PATH: String = (
	"res://scenes/areas/central_tower_threshold.tscn"
)
const SENTRY_ENTITY_ID: int = 2703
const PLATFORM_START: Vector2 = Vector2(4380.0, 590.0)
const PLATFORM_TOP: Vector2 = Vector2(4380.0, 290.0)
const ENDPOINT_POSITION: Vector2 = Vector2(4980.0, 252.0)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed: PackedScene = load(TOWER_SCENE_PATH) as PackedScene
	if packed == null:
		_fail("tower_scene_missing")
		return
	var tower: Node = packed.instantiate()
	root.add_child(tower)
	tower.call("set_local_state", _story142_complete_state())
	var player: CharacterBody2D = tower.get_node_or_null(
		"Player"
	) as CharacterBody2D
	var controller: Node = tower.get_node_or_null("DeepLiftController")
	var platform: AnimatableBody2D = tower.get_node_or_null(
		"DeepLiftController/DeepLiftPlatform"
	) as AnimatableBody2D
	var sentry: CharacterBody2D = tower.get_node_or_null(
		"DeepLiftController/CentralTowerCounterweightSentry"
	) as CharacterBody2D
	if player == null or controller == null or platform == null or sentry == null:
		_fail("runtime_nodes_missing")
		return
	_configure_fast_lift(controller)
	var abilities_before: Array[String] = _ability_strings(player)

	player.global_position = PLATFORM_START + Vector2(0.0, -38.0)
	player.velocity = Vector2.ZERO
	await physics_frame
	await physics_frame
	var relative_before: Vector2 = player.global_position - platform.global_position
	if not bool(tower.call("try_activate_deep_lift", player)):
		_fail("lift_activation_failed")
		return
	for _frame: int in range(32):
		await physics_frame
	var active: Dictionary = tower.call(
		"get_central_tower_deep_lift_diagnostics"
	)
	if (
		platform.global_position.y > 526.0
		or (player.global_position - platform.global_position).distance_to(
			relative_before
		) > 6.0
		or not bool(active.get("sentry_activated", false))
		or not sentry.visible
	):
		_fail("platform_carry_or_deployment_failed")
		return

	sentry.set_physics_process(false)
	if not bool(tower.call("request_counterweight_sentry_attack")):
		_fail("sentry_attack_request_failed")
		return
	var sprite: AnimatedSprite2D = sentry.get_node_or_null(
		"Sprite"
	) as AnimatedSprite2D
	if sprite == null or String(sprite.animation) != "attack_tell":
		_fail("sentry_attack_tell_missing")
		return
	sentry.call("advance_attack_frames", 24)
	if (
		not bool(sentry.call("is_enemy_attack_active"))
		or String(sprite.animation) != "attack"
	):
		_fail("sentry_attack_active_missing")
		return
	if not bool(tower.call(
		"apply_damage",
		SENTRY_ENTITY_ID,
		999,
		{"source": &"story143_smoke_player_attack"}
	)):
		_fail("sentry_damage_route_failed")
		return
	if String(sprite.animation) != "death":
		_fail("sentry_death_animation_missing")
		return
	for _frame: int in range(32):
		await physics_frame
	var docked: Dictionary = tower.call(
		"get_central_tower_deep_lift_diagnostics"
	)
	if (
		not bool(docked.get("upper_docked", false))
		or Vector2(docked.get("platform_position", Vector2.ZERO)) != PLATFORM_TOP
	):
		_fail(
			"upper_dock_failed phase=%s position=%s defeated=%s"
			% [
				String(docked.get("phase", "")),
				str(docked.get("platform_position", Vector2.ZERO)),
				str(docked.get("sentry_defeated", false)),
			]
		)
		return

	player.global_position = ENDPOINT_POSITION
	if not bool(tower.call("try_activate_deep_lift_endpoint", player)):
		_fail("upper_endpoint_failed")
		return
	var saved: Dictionary = tower.call("get_local_state")
	if (
		not bool(saved.get("central_tower_counterweight_sentry_defeated", false))
		or not bool(saved.get("central_tower_deep_lift_ascended", false))
		or _ability_strings(player) != abilities_before
	):
		_fail("durable_state_or_abilities_failed")
		return

	var restored: Node = packed.instantiate()
	root.add_child(restored)
	restored.call("set_local_state", saved)
	var restored_state: Dictionary = restored.call(
		"get_central_tower_deep_lift_diagnostics"
	)
	if (
		not bool(restored_state.get("sentry_defeated", false))
		or not bool(restored_state.get("deep_lift_ascended", false))
		or Vector2(restored_state.get(
			"platform_position",
			Vector2.ZERO
		)) != PLATFORM_START
		or int(restored_state.get("activation_feedback_count", -1)) != 0
		or int(restored_state.get("defeat_feedback_count", -1)) != 0
		or int(restored_state.get("endpoint_feedback_count", -1)) != 0
	):
		_fail("fresh_restore_failed")
		return

	root.remove_child(restored)
	restored.free()
	root.remove_child(tower)
	tower.free()
	await process_frame
	print("central_tower_deep_lift_counterweight_ambush_smoke=passed")
	quit(0)


func _configure_fast_lift(controller: Node) -> void:
	controller.set("startup_delay_sec", 0.05)
	controller.set("deploy_grace_sec", 0.05)
	controller.set("lower_travel_speed_px_sec", 480.0)
	controller.set("upper_travel_speed_px_sec", 480.0)
	controller.set("post_defeat_linger_sec", 0.05)


func _story142_complete_state() -> Dictionary:
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
	push_error("central_tower_deep_lift_counterweight_ambush_smoke=" + reason)
	quit(1)
