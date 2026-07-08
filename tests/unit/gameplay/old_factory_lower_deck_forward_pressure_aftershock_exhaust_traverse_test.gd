## Player Abilities Story 086: Old Factory lower-deck aftershock exhaust traverse.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const EXIT_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_forward_pressure_exit_relay"
const EXIT_RELAY_SPAWN_POINT: String = "lower_deck_forward_pressure_exit_relay"
const AFTERSHOCK_EXHAUST_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockExhaustVent"
)
const AFTERSHOCK_EXHAUST_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_exhaust"
)
const STEAM_VENT_TEXTURE: String = (
	"res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png"
)
const EXIT_SKIRMISH_SPARK_ENTITY_ID: int = 2129
const EXIT_SKIRMISH_COIL_ENTITY_ID: int = 2130

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_aftershock_exhaust_requires_exit_skirmish_clear_and_starts_on_boundary() -> void:
	assert_bool(FileAccess.file_exists(STEAM_VENT_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_aftershock_exhaust_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("aftershock_exit_skirmish_cleared", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("hazard_contact_active", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust"
	))).is_false()

	var destination: Node = _factory_scene_with_aftershock_exhaust_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("aftershock_exit_skirmish_cleared", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("crossed", true))).is_false()
	assert_str(String(ready.get("hazard_id", ""))).is_equal(AFTERSHOCK_EXHAUST_HAZARD_ID)
	assert_int(int(ready.get("hazard_damage", 0))).is_equal(8)
	assert_float(float(ready.get("hazard_cooldown_sec", 0.0))).is_equal(1.0)
	assert_str(String(ready.get("hazard_texture_path", ""))).is_equal(STEAM_VENT_TEXTURE)
	assert_float(float(ready.get("initial_grace_sec", 0.0))).is_greater(0.0)
	assert_float(float(ready.get("warning_sec", 0.0))).is_greater(0.0)
	assert_float(float(ready.get("active_sec", 0.0))).is_greater(0.0)
	assert_float(float(ready.get("safe_sec", 0.0))).is_greater(0.0)
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Forward Pressure Aftershock Exit Skirmish Cleared"
	)

	player.global_position.x = float(ready.get("activation_x", 0.0)) - 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust",
		player
	))).is_false()
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust",
		player
	))).is_true()

	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("crossed", true))).is_false()
	assert_str(String(active.get("phase", ""))).is_equal("grace")
	assert_bool(bool(active.get("hazard_contact_active", true))).is_false()
	assert_str(String(active.get("route_label_text", ""))).is_equal("Cross Aftershock Exhaust")


func test_aftershock_exhaust_active_window_damage_and_crossed_state_persist() -> void:
	var destination: Node = _factory_scene_with_aftershock_exhaust_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)).is_true()
	assert_bool(destination.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust"
	)).is_true()
	assert_bool(destination.has_method(
		"advance_factory_lower_deck_forward_pressure_aftershock_exhaust_time"
	)).is_true()
	assert_bool(destination.has_method(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_exhaust"
	)).is_true()
	if (
		not destination.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
		)
		or not destination.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust"
		)
		or not destination.has_method(
			"advance_factory_lower_deck_forward_pressure_aftershock_exhaust_time"
		)
		or not destination.has_method(
			"try_complete_factory_lower_deck_forward_pressure_aftershock_exhaust"
		)
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust",
		player
	))).is_true()

	var exhaust_vent: Area2D = destination.get_node_or_null(
		AFTERSHOCK_EXHAUST_NODE_NAME
	) as Area2D
	assert_that(exhaust_vent).is_not_null()
	if exhaust_vent == null:
		return

	assert_bool(bool(destination.call(
		"apply_factory_steam_vent_contact",
		exhaust_vent,
		player
	))).is_false()

	destination.call("advance_factory_lower_deck_forward_pressure_aftershock_exhaust_time", 0.32)
	var warning: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_str(String(warning.get("phase", ""))).is_equal("warning")
	assert_bool(bool(warning.get("hazard_contact_active", true))).is_false()

	destination.call("advance_factory_lower_deck_forward_pressure_aftershock_exhaust_time", 0.36)
	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_str(String(active.get("phase", ""))).is_equal("active")
	assert_bool(bool(active.get("hazard_contact_active", false))).is_true()
	var non_player: Node2D = Node2D.new()
	destination.add_child(non_player)
	assert_bool(bool(destination.call(
		"apply_factory_steam_vent_contact",
		exhaust_vent,
		non_player
	))).is_false()
	var hp_before: int = int(player.call("get_current_hp"))
	assert_bool(bool(destination.call(
		"apply_factory_steam_vent_contact",
		exhaust_vent,
		player
	))).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - 8)
	var last_damage: Dictionary = destination.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	assert_str(String(last_damage.get("source", ""))).is_equal(AFTERSHOCK_EXHAUST_HAZARD_ID)

	destination.call("advance_factory_lower_deck_forward_pressure_aftershock_exhaust_time", 0.45)
	var safe: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_str(String(safe.get("phase", ""))).is_equal("safe")
	assert_bool(bool(safe.get("hazard_contact_active", true))).is_false()

	player.global_position.x = float(safe.get("exit_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_exhaust",
		player
	))).is_true()
	assert_bool(bool(destination.call(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_exhaust",
		player
	))).is_false()

	var crossed: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_bool(bool(crossed.get("active", true))).is_false()
	assert_bool(bool(crossed.get("crossed", false))).is_true()
	assert_bool(bool(crossed.get("visible", true))).is_false()
	assert_bool(bool(crossed.get("hazard_contact_active", true))).is_false()
	assert_str(String(crossed.get("route_label_text", ""))).is_equal(
		"Forward Pressure Aftershock Exhaust Crossed"
	)
	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_crossed",
		false
	))).is_true()

	var restored: Node = _factory_scene_with_aftershock_exhaust_state(true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	var restored_exhaust: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_bool(bool(restored_exhaust.get("active", true))).is_false()
	assert_bool(bool(restored_exhaust.get("crossed", false))).is_true()
	assert_bool(bool(restored_exhaust.get("visible", true))).is_false()
	assert_bool(bool(restored_exhaust.get("hazard_contact_active", true))).is_false()
	assert_str(String(restored_exhaust.get("route_label_text", ""))).is_equal(
		"Forward Pressure Aftershock Exhaust Crossed"
	)
	var restored_skirmish: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exit_skirmish_diagnostics"
	)
	assert_bool(bool(restored_skirmish.get("cleared", false))).is_true()
	assert_bool(bool(restored_skirmish.get("active", true))).is_false()
	var restored_cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_reward_cache_diagnostics"
	)
	assert_bool(bool(restored_cache.get("claimed", false))).is_true()
	var restored_relay: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
	)
	assert_bool(bool(restored_relay.get("activated", false))).is_true()
	assert_str(String(restored_relay.get("savepoint_id", ""))).is_equal(
		EXIT_RELAY_SAVEPOINT_ID
	)
	assert_str(String(restored_relay.get("spawn_point", ""))).is_equal(
		EXIT_RELAY_SPAWN_POINT
	)
	var old_forward_cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_reward_cache_diagnostics"
	)
	assert_int(int(old_forward_cache.get("claim_audio_request_count", -1))).is_equal(0)
	var clear_feedback: Dictionary = restored.call(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	)
	assert_int(int(clear_feedback.get("spawn_count", -1))).is_equal(0)
	var restored_lift: Dictionary = restored.call("get_factory_service_lift_diagnostics")
	assert_str(String(restored_lift.get("prompt_text", ""))).is_equal("Call lift")


func test_aftershock_exhaust_unlocks_on_live_exit_skirmish_clear() -> void:
	var destination: Node = _factory_scene_with_aftershock_exit_skirmish_ready_state()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)).is_true()
	assert_bool(destination.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust"
	)).is_true()
	if (
		not destination.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
		)
		or not destination.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust"
		)
	):
		return

	var before_exhaust: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_bool(bool(before_exhaust.get("available", true))).is_false()
	assert_bool(bool(before_exhaust.get("visible", true))).is_false()

	var skirmish_ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exit_skirmish_diagnostics"
	)
	player.global_position.x = float(skirmish_ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exit_skirmish",
		player
	))).is_true()
	assert_bool(destination.call("apply_damage", EXIT_SKIRMISH_SPARK_ENTITY_ID, 999, {
		"source": &"unit_test_aftershock_exhaust_spark",
	})).is_true()
	assert_bool(destination.call("apply_damage", EXIT_SKIRMISH_COIL_ENTITY_ID, 999, {
		"source": &"unit_test_aftershock_exhaust_coil",
	})).is_true()
	await get_tree().process_frame

	var ready_exhaust: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_bool(bool(ready_exhaust.get("aftershock_exit_skirmish_cleared", false))).is_true()
	assert_bool(bool(ready_exhaust.get("available", false))).is_true()
	assert_bool(bool(ready_exhaust.get("visible", false))).is_true()
	player.global_position.x = float(ready_exhaust.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_exhaust",
		player
	))).is_true()

	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_str(String(active.get("route_label_text", ""))).is_equal("Cross Aftershock Exhaust")


func _factory_scene_with_aftershock_exhaust_state(
		aftershock_exit_skirmish_cleared: bool,
		aftershock_exhaust_crossed: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _aftershock_exhaust_base_state().merged({
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_activated": (
			aftershock_exit_skirmish_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_spark_rat_defeated": (
			aftershock_exit_skirmish_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_coil_rat_defeated": (
			aftershock_exit_skirmish_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared": (
			aftershock_exit_skirmish_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_activated": (
			aftershock_exhaust_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_exhaust_crossed": (
			aftershock_exhaust_crossed
		),
	}, true))
	return destination


func _factory_scene_with_aftershock_exit_skirmish_ready_state() -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _aftershock_exhaust_base_state().merged({
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_spark_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_coil_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_crossed": false,
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


func _aftershock_exhaust_base_state() -> Dictionary:
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
		"factory_lower_deck_forward_conduit_activated": true,
		"factory_lower_deck_forward_conduit_defeated": true,
		"factory_lower_deck_forward_pressure_traverse_crossed": true,
		"factory_lower_deck_forward_pressure_counter_ambush_activated": true,
		"factory_lower_deck_forward_pressure_counter_ambush_defeated": true,
		"factory_lower_deck_forward_pressure_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_exit_guard_activated": true,
		"factory_lower_deck_forward_pressure_exit_guard_defeated": true,
		"factory_lower_deck_forward_pressure_exit_relay_activated": true,
		"factory_lower_deck_forward_pressure_exit_gate_opened": true,
		"factory_lower_deck_forward_pressure_route_handoff_marker_lit": true,
		"factory_lower_deck_forward_pressure_beacon_ambush_activated": true,
		"factory_lower_deck_forward_pressure_beacon_ambush_defeated": true,
		"factory_lower_deck_forward_pressure_overrun_activated": true,
		"factory_lower_deck_forward_pressure_overrun_defeated": true,
		"factory_lower_deck_forward_pressure_breaker_activated": true,
		"factory_lower_deck_forward_pressure_breaker_secured": true,
		"factory_lower_deck_forward_pressure_breaker_cut": true,
		"factory_lower_deck_forward_pressure_relief_ambush_activated": true,
		"factory_lower_deck_forward_pressure_relief_ambush_defeated": true,
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_activated": true,
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_defeated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_activated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_cleared": true,
		"factory_lower_deck_forward_pressure_coil_aftershock_activated": true,
		"factory_lower_deck_forward_pressure_coil_aftershock_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_coil_aftershock_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_reward_cache_claimed": true,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
		"last_return_checkpoint": {
			"id": EXIT_RELAY_SAVEPOINT_ID,
			"scene_id": "area_03_factory",
			"spawn_point": EXIT_RELAY_SPAWN_POINT,
			"position": Vector2(1414, 382),
		},
	}
