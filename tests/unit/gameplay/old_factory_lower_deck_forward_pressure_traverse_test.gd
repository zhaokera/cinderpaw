## Player Abilities Story 069: Old Factory lower deck forward pressure traverse.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const BREACH_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_breach_relay"
const BREACH_RELAY_SPAWN_POINT: String = "lower_deck_breach_relay"
const FORWARD_PRESSURE_HAZARD_ID: String = "old_factory_lower_deck_forward_pressure_traverse"
const STEAM_VENT_TEXTURE: String = (
	"res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png"
)

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_forward_pressure_traverse_requires_secured_conduit_and_starts_on_boundary() -> void:
	assert_bool(FileAccess.file_exists(STEAM_VENT_TEXTURE)).is_true()

	var destination: Node = _factory_scene_with_forward_state(false, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)).is_true()
	assert_bool(destination.has_method(
		"try_activate_factory_lower_deck_forward_pressure_traverse"
	)).is_true()
	if (
		not destination.has_method("get_factory_lower_deck_forward_pressure_traverse_diagnostics")
		or not destination.has_method("try_activate_factory_lower_deck_forward_pressure_traverse")
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(service_lift).is_not_null()
	if player == null or service_lift == null:
		return

	var pre_clear: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)
	assert_bool(bool(pre_clear.get("present", false))).is_true()
	assert_bool(bool(pre_clear.get("available", true))).is_false()
	assert_bool(bool(pre_clear.get("visible", true))).is_false()
	assert_bool(bool(pre_clear.get("active", true))).is_false()
	assert_bool(bool(pre_clear.get("hazard_contact_active", true))).is_false()
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_traverse",
		player
	))).is_false()

	var secured: Node = _factory_scene_with_forward_state(true, false)
	assert_that(secured).is_not_null()
	if secured == null:
		return
	var secured_player: Node2D = secured.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(secured_player).is_not_null()
	if secured_player == null:
		return

	var ready: Dictionary = secured.call(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("crossed", true))).is_false()
	assert_str(String(ready.get("hazard_id", ""))).is_equal(FORWARD_PRESSURE_HAZARD_ID)
	assert_int(int(ready.get("hazard_damage", 0))).is_equal(8)
	assert_float(float(ready.get("hazard_cooldown_sec", 0.0))).is_equal(1.0)
	assert_str(String(ready.get("hazard_texture_path", ""))).is_equal(STEAM_VENT_TEXTURE)
	assert_float(float(ready.get("initial_grace_sec", 0.0))).is_greater(0.0)
	assert_float(float(ready.get("warning_sec", 0.0))).is_greater(0.0)
	assert_float(float(ready.get("active_sec", 0.0))).is_greater(0.0)
	assert_float(float(ready.get("safe_sec", 0.0))).is_greater(0.0)
	assert_str(String(
		secured.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Forward Conduit Secured")

	secured_player.global_position.x = float(ready.get("activation_x", 0.0)) - 4.0
	assert_bool(bool(secured.call(
		"try_activate_factory_lower_deck_forward_pressure_traverse",
		secured_player
	))).is_false()
	secured_player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(secured.call(
		"try_activate_factory_lower_deck_forward_pressure_traverse",
		secured_player
	))).is_true()

	var active: Dictionary = secured.call(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("crossed", true))).is_false()
	assert_str(String(active.get("phase", ""))).is_equal("grace")
	assert_bool(bool(active.get("hazard_contact_active", true))).is_false()
	assert_str(String(
		secured.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Cross Forward Pressure Leak")

	var lift: Dictionary = secured.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


func test_forward_pressure_traverse_active_window_damage_and_crossed_state_persist() -> void:
	var destination: Node = _factory_scene_with_forward_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)).is_true()
	assert_bool(destination.has_method(
		"try_activate_factory_lower_deck_forward_pressure_traverse"
	)).is_true()
	assert_bool(destination.has_method(
		"advance_factory_lower_deck_forward_pressure_traverse_time"
	)).is_true()
	assert_bool(destination.has_method(
		"try_complete_factory_lower_deck_forward_pressure_traverse"
	)).is_true()
	if (
		not destination.has_method("get_factory_lower_deck_forward_pressure_traverse_diagnostics")
		or not destination.has_method("try_activate_factory_lower_deck_forward_pressure_traverse")
		or not destination.has_method("advance_factory_lower_deck_forward_pressure_traverse_time")
		or not destination.has_method("try_complete_factory_lower_deck_forward_pressure_traverse")
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_traverse",
		player
	))).is_true()

	var pressure_vent: Area2D = destination.get_node_or_null(
		"FactoryLowerDeckForwardPressureVent"
	) as Area2D
	assert_that(pressure_vent).is_not_null()
	if pressure_vent == null:
		return
	var pressure_motion: AnimatedSprite2D = pressure_vent.get_node_or_null(
		"SteamAnimation"
	) as AnimatedSprite2D
	assert_that(pressure_motion).is_not_null()
	if pressure_motion == null:
		return
	assert_that(pressure_motion.animation).is_equal(&"safe")

	assert_bool(bool(destination.call(
		"apply_factory_steam_vent_contact",
		pressure_vent,
		player
	))).is_false()

	destination.call("advance_factory_lower_deck_forward_pressure_traverse_time", 0.32)
	var warning: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)
	assert_str(String(warning.get("phase", ""))).is_equal("warning")
	assert_bool(bool(warning.get("hazard_contact_active", true))).is_false()
	assert_that(pressure_motion.animation).is_equal(&"warning")

	destination.call("advance_factory_lower_deck_forward_pressure_traverse_time", 0.36)
	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)
	assert_str(String(active.get("phase", ""))).is_equal("active")
	assert_bool(bool(active.get("hazard_contact_active", false))).is_true()
	assert_that(pressure_motion.animation).is_equal(&"active")
	var hp_before: int = int(player.call("get_current_hp"))
	assert_bool(bool(destination.call(
		"apply_factory_steam_vent_contact",
		pressure_vent,
		player
	))).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - 8)
	var last_damage: Dictionary = destination.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	assert_str(String(last_damage.get("source", ""))).is_equal(FORWARD_PRESSURE_HAZARD_ID)

	destination.call("advance_factory_lower_deck_forward_pressure_traverse_time", 0.45)
	var safe: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)
	assert_str(String(safe.get("phase", ""))).is_equal("safe")
	assert_bool(bool(safe.get("hazard_contact_active", true))).is_false()
	assert_that(pressure_motion.animation).is_equal(&"safe")

	player.global_position.x = float(safe.get("exit_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_complete_factory_lower_deck_forward_pressure_traverse",
		player
	))).is_true()
	assert_bool(bool(destination.call(
		"try_complete_factory_lower_deck_forward_pressure_traverse",
		player
	))).is_false()

	var crossed: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)
	assert_bool(bool(crossed.get("active", true))).is_false()
	assert_bool(bool(crossed.get("crossed", false))).is_true()
	assert_bool(bool(crossed.get("hazard_contact_active", true))).is_false()
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Forward Pressure Traverse Crossed")
	assert_bool(bool(destination.call("get_local_state").get(
		"factory_lower_deck_forward_pressure_traverse_crossed",
		false
	))).is_true()

	var restored: Node = _factory_scene_with_forward_state(true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	var restored_pressure: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)
	assert_bool(bool(restored_pressure.get("active", true))).is_false()
	assert_bool(bool(restored_pressure.get("crossed", false))).is_true()
	assert_bool(bool(restored_pressure.get("hazard_contact_active", true))).is_false()
	assert_str(String(
		restored.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Forward Pressure Traverse Crossed")

	var restored_clear: Dictionary = restored.call(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	)
	assert_int(int(restored_clear.get("spawn_count", -1))).is_equal(0)
	var restored_conduit: Dictionary = restored.call(
		"get_factory_lower_deck_forward_conduit_diagnostics"
	)
	assert_bool(bool(restored_conduit.get("active", true))).is_false()
	assert_bool(bool(restored_conduit.get("defeated", false))).is_true()
	var restored_lift: Dictionary = restored.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(restored_lift.get("available", false))).is_true()
	assert_str(String(restored_lift.get("prompt_text", ""))).is_equal("Call lift")


func _factory_scene_with_forward_state(conduit_defeated: bool, traverse_crossed: bool) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _forward_base_state().merged({
		"factory_lower_deck_forward_conduit_activated": conduit_defeated,
		"factory_lower_deck_forward_conduit_defeated": conduit_defeated,
		"factory_lower_deck_forward_pressure_traverse_crossed": traverse_crossed,
	}, true))
	return destination


func _instantiate_factory_scene() -> Node:
	assert_bool(FileAccess.file_exists(FACTORY_SCENE_PATH)).is_true()
	var packed: PackedScene = load(FACTORY_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var destination: Node = packed.instantiate()
	add_child(destination)
	_spawned_nodes.append(destination)
	return destination


func _forward_base_state() -> Dictionary:
	return {
		"encounter_cleared": true,
		"factory_cache_claimed": true,
		"factory_deep_guard_activated": true,
		"factory_deep_guard_defeated": true,
		"factory_deep_route_cleared": true,
		"factory_spark_rat_activated": true,
		"factory_spark_rat_defeated": true,
		"factory_return_patrol_activated": true,
		"factory_return_patrol_defeated": true,
		"factory_return_checkpoint_activated": true,
		"factory_checkpoint_forward_patrol_activated": true,
		"factory_checkpoint_forward_patrol_defeated": true,
		"factory_checkpoint_rear_ambush_activated": true,
		"factory_checkpoint_rear_ambush_defeated": true,
		"factory_checkpoint_overdrive_duo_activated": true,
		"factory_checkpoint_overdrive_left_defeated": true,
		"factory_checkpoint_overdrive_right_defeated": true,
		"factory_checkpoint_overdrive_duo_cleared": true,
		"factory_lower_deck_skirmish_activated": true,
		"factory_lower_deck_skirmish_defeated": true,
		"factory_lower_deck_reward_cache_claimed": true,
		"factory_lower_deck_parry_gate_unlocked": true,
		"factory_lower_deck_exit_ambush_activated": true,
		"factory_lower_deck_exit_ambush_defeated": true,
		"factory_lower_deck_shortcut_activated": true,
		"factory_lower_deck_shortcut_guard_defeated": true,
		"factory_lower_deck_shortcut_unlocked": true,
		"factory_lower_deck_shortcut_reward_cache_claimed": true,
		"factory_lower_deck_shortcut_pursuer_activated": true,
		"factory_lower_deck_shortcut_pursuer_defeated": true,
		"factory_lower_deck_pressure_guard_activated": true,
		"factory_lower_deck_pressure_guard_defeated": true,
		"factory_lower_deck_pressure_valve_opened": true,
		"factory_lower_deck_steam_sluice_activated": true,
		"factory_lower_deck_steam_sluice_defeated": true,
		"factory_lower_deck_deep_bulkhead_guard_activated": true,
		"factory_lower_deck_deep_bulkhead_guard_defeated": true,
		"factory_lower_deck_deep_bulkhead_opened": true,
		"factory_lower_deck_breach_corridor_activated": true,
		"factory_lower_deck_breach_front_guard_defeated": true,
		"factory_lower_deck_breach_rear_ambusher_activated": true,
		"factory_lower_deck_breach_rear_ambusher_defeated": true,
		"factory_lower_deck_breach_corridor_secured": true,
		"factory_lower_deck_breach_relay_activated": true,
		"factory_lower_deck_post_relay_trial_activated": true,
		"factory_lower_deck_post_relay_trial_defeated": true,
		"factory_lower_deck_relay_forward_reward_cache_claimed": true,
		"factory_lower_deck_forward_hatch_opened": true,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
		"last_return_checkpoint": {
			"id": BREACH_RELAY_SAVEPOINT_ID,
			"scene_id": String(FACTORY_SCENE_ID),
			"spawn_point": BREACH_RELAY_SPAWN_POINT,
			"position": Vector2(1218, 382),
		},
	}
