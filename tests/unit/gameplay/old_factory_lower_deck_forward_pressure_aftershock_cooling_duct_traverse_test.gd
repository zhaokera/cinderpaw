## Player Abilities Story 093: Old Factory aftershock cooling duct traverse.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const EXIT_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_forward_pressure_exit_relay"
const EXIT_RELAY_SPAWN_POINT: String = "lower_deck_forward_pressure_exit_relay"
const COOLING_DUCT_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCoolingDuct"
)
const COOLING_DUCT_HAZARD_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCoolingDuctVent"
)
const COOLING_DUCT_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_cooling_duct"
)
const COOLING_DUCT_TEXTURE: String = (
	"res://assets/environment/old_factory_aftershock_cooling_duct/"
	+ "env_old_factory_aftershock_cooling_duct_768.png"
)
const STEAM_VENT_TEXTURE: String = (
	"res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png"
)

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_cooling_duct_requires_exit_hatch_open_and_extends_playable_space() -> void:
	assert_bool(FileAccess.file_exists(COOLING_DUCT_TEXTURE)).is_true()
	assert_bool(FileAccess.file_exists(STEAM_VENT_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_cooling_duct_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_cooling_duct"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_cooling_duct"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("exit_hatch_opened", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("crossed", true))).is_false()
	assert_bool(bool(locked.get("hazard_contact_active", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_cooling_duct"
	))).is_false()

	var destination: Node = _factory_scene_with_cooling_duct_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("exit_hatch_opened", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("crossed", true))).is_false()
	assert_str(String(ready.get("node_name", ""))).is_equal(COOLING_DUCT_NODE_NAME)
	assert_str(String(ready.get("hazard_node_name", ""))).is_equal(
		COOLING_DUCT_HAZARD_NODE_NAME
	)
	assert_str(String(ready.get("duct_texture_path", ""))).is_equal(COOLING_DUCT_TEXTURE)
	assert_str(String(ready.get("hazard_id", ""))).is_equal(COOLING_DUCT_HAZARD_ID)
	assert_int(int(ready.get("hazard_damage", 0))).is_equal(8)
	assert_float(float(ready.get("hazard_cooldown_sec", 0.0))).is_equal(1.0)
	assert_str(String(ready.get("hazard_texture_path", ""))).is_equal(STEAM_VENT_TEXTURE)
	assert_float(float(ready.get("initial_grace_sec", 0.0))).is_greater(0.0)
	assert_float(float(ready.get("warning_sec", 0.0))).is_greater(0.0)
	assert_float(float(ready.get("active_sec", 0.0))).is_greater(0.0)
	assert_float(float(ready.get("safe_sec", 0.0))).is_greater(0.0)
	assert_bool(bool(ready.get("hazard_visible", false))).is_true()
	assert_bool(bool(ready.get("hazard_contact_active", true))).is_false()
	assert_float(float(ready.get("ground_width", 0.0))).is_greater_equal(3840.0)
	assert_float(float(ready.get("right_wall_x", 0.0))).is_greater_equal(3820.0)
	assert_int(int(ready.get("camera_limit_right", 0))).is_greater_equal(3840)
	assert_float(float(ready.get("activation_x", 0.0))).is_greater(3160.0)
	assert_float(float(ready.get("exit_x", 0.0))).is_greater(
		float(ready.get("activation_x", 0.0))
	)
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Aftershock Exhaust Exit Opened"
	)

	player.global_position.x = float(ready.get("activation_x", 0.0)) - 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_cooling_duct",
		player
	))).is_false()
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_cooling_duct",
		player
	))).is_true()

	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("crossed", true))).is_false()
	assert_str(String(active.get("phase", ""))).is_equal("grace")
	assert_bool(bool(active.get("hazard_contact_active", true))).is_false()
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Cross Aftershock Cooling Duct"
	)


func test_cooling_duct_active_window_damage_and_crossed_state_persist() -> void:
	var destination: Node = _factory_scene_with_cooling_duct_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)).is_true()
	assert_bool(destination.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_cooling_duct"
	)).is_true()
	assert_bool(destination.has_method(
		"advance_factory_lower_deck_forward_pressure_aftershock_cooling_duct_time"
	)).is_true()
	assert_bool(destination.has_method(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_cooling_duct"
	)).is_true()
	if (
		not destination.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
		)
		or not destination.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_cooling_duct"
		)
		or not destination.has_method(
			"advance_factory_lower_deck_forward_pressure_aftershock_cooling_duct_time"
		)
		or not destination.has_method(
			"try_complete_factory_lower_deck_forward_pressure_aftershock_cooling_duct"
		)
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_cooling_duct",
		player
	))).is_true()

	var duct_vent: Area2D = destination.get_node_or_null(
		COOLING_DUCT_HAZARD_NODE_NAME
	) as Area2D
	assert_that(duct_vent).is_not_null()
	if duct_vent == null:
		return

	assert_bool(bool(destination.call(
		"apply_factory_steam_vent_contact",
		duct_vent,
		player
	))).is_false()

	destination.call(
		"advance_factory_lower_deck_forward_pressure_aftershock_cooling_duct_time",
		0.32
	)
	var warning: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	assert_str(String(warning.get("phase", ""))).is_equal("warning")
	assert_bool(bool(warning.get("hazard_contact_active", true))).is_false()

	destination.call(
		"advance_factory_lower_deck_forward_pressure_aftershock_cooling_duct_time",
		0.36
	)
	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	assert_str(String(active.get("phase", ""))).is_equal("active")
	assert_bool(bool(active.get("hazard_contact_active", false))).is_true()
	var hp_before: int = int(player.call("get_current_hp"))
	assert_bool(bool(destination.call(
		"apply_factory_steam_vent_contact",
		duct_vent,
		player
	))).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - 8)
	var last_damage: Dictionary = destination.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	assert_str(String(last_damage.get("source", ""))).is_equal(COOLING_DUCT_HAZARD_ID)

	destination.call(
		"advance_factory_lower_deck_forward_pressure_aftershock_cooling_duct_time",
		0.45
	)
	var safe: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	assert_str(String(safe.get("phase", ""))).is_equal("safe")
	assert_bool(bool(safe.get("hazard_contact_active", true))).is_false()

	player.global_position.x = float(safe.get("exit_x", 0.0)) + 4.0
	destination._process(0.0)
	assert_bool(bool(destination.call(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_cooling_duct",
		player
	))).is_false()

	var crossed: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	assert_bool(bool(crossed.get("active", true))).is_false()
	assert_bool(bool(crossed.get("crossed", false))).is_true()
	assert_bool(bool(crossed.get("visible", false))).is_true()
	assert_bool(bool(crossed.get("hazard_contact_active", true))).is_false()
	assert_str(String(crossed.get("route_label_text", ""))).is_equal(
		"Aftershock Cooling Duct Crossed"
	)
	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_crossed",
		false
	))).is_true()

	var restored: Node = _factory_scene_with_cooling_duct_state(true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	var restored_duct: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	assert_bool(bool(restored_duct.get("active", true))).is_false()
	assert_bool(bool(restored_duct.get("crossed", false))).is_true()
	assert_bool(bool(restored_duct.get("visible", false))).is_true()
	assert_bool(bool(restored_duct.get("hazard_contact_active", true))).is_false()
	assert_str(String(restored_duct.get("route_label_text", ""))).is_equal(
		"Aftershock Cooling Duct Crossed"
	)
	var hatch: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
	)
	assert_bool(bool(hatch.get("opened", false))).is_true()
	assert_bool(bool(hatch.get("visible", false))).is_true()
	assert_bool(bool(hatch.get("collision_blocking", true))).is_false()
	assert_str(String(hatch.get("prompt_text", ""))).is_equal("Exhaust Hatch Open")
	assert_int(int(hatch.get("unlock_feedback_spawn_count", -1))).is_equal(0)
	var restored_escape: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_diagnostics"
	)
	assert_bool(bool(restored_escape.get("cleared", false))).is_true()
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
	var restored_lift: Dictionary = restored.call("get_factory_service_lift_diagnostics")
	assert_str(String(restored_lift.get("prompt_text", ""))).is_equal("Call lift")


func _factory_scene_with_cooling_duct_state(
		exit_hatch_opened: bool,
		cooling_duct_crossed: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _cooling_duct_base_state().merged({
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened": (
			exit_hatch_opened
		),
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_activated": (
			cooling_duct_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_crossed": (
			cooling_duct_crossed
		),
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


func _cooling_duct_base_state() -> Dictionary:
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
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_cleared": true,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
		"last_return_checkpoint": {
			"id": EXIT_RELAY_SAVEPOINT_ID,
			"scene_id": String(FACTORY_SCENE_ID),
			"spawn_point": EXIT_RELAY_SPAWN_POINT,
			"position": Vector2(1414, 382),
		},
	}


func _stop_runtime_audio_players() -> void:
	for child: Node in get_children():
		if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
			child.queue_free()
