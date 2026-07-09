## Player Abilities Story 098: Old Factory aftershock condenser outlet drip vent traverse.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const DRAIN_GANTRY_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserDrainGantry"
)
const DRIP_VENT_HAZARD_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserOutletDripVentHazard"
)
const DRIP_VENT_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent"
)
const DRAIN_GANTRY_TEXTURE: String = (
	"res://assets/environment/old_factory_aftershock_condenser_drain_gantry/"
	+ "env_old_factory_aftershock_condenser_drain_gantry_768.png"
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


func test_outlet_drip_vent_requires_outlet_clamp_clear_and_extends_playable_space() -> void:
	assert_bool(FileAccess.file_exists(DRAIN_GANTRY_TEXTURE)).is_true()
	assert_bool(FileAccess.file_exists(STEAM_VENT_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_outlet_drip_vent_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("outlet_clamp_cleared", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("crossed", true))).is_false()
	assert_bool(bool(locked.get("hazard_contact_active", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent"
	))).is_false()

	var destination: Node = _factory_scene_with_outlet_drip_vent_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("outlet_clamp_cleared", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("crossed", true))).is_false()
	assert_str(String(ready.get("node_name", ""))).is_equal(DRAIN_GANTRY_NODE_NAME)
	assert_str(String(ready.get("hazard_node_name", ""))).is_equal(
		DRIP_VENT_HAZARD_NODE_NAME
	)
	assert_str(String(ready.get("drain_gantry_texture_path", ""))).is_equal(
		DRAIN_GANTRY_TEXTURE
	)
	assert_str(String(ready.get("hazard_id", ""))).is_equal(DRIP_VENT_HAZARD_ID)
	assert_int(int(ready.get("hazard_damage", 0))).is_equal(8)
	assert_float(float(ready.get("hazard_cooldown_sec", 0.0))).is_equal(1.0)
	assert_str(String(ready.get("hazard_texture_path", ""))).is_equal(
		STEAM_VENT_TEXTURE
	)
	assert_float(float(ready.get("initial_grace_sec", 0.0))).is_greater(0.0)
	assert_float(float(ready.get("warning_sec", 0.0))).is_greater(0.0)
	assert_float(float(ready.get("active_sec", 0.0))).is_greater(0.0)
	assert_float(float(ready.get("safe_sec", 0.0))).is_greater(0.0)
	assert_bool(bool(ready.get("hazard_visible", false))).is_true()
	assert_bool(bool(ready.get("hazard_contact_active", true))).is_false()
	assert_float(float(ready.get("ground_width", 0.0))).is_greater_equal(6400.0)
	assert_float(float(ready.get("right_wall_x", 0.0))).is_greater_equal(6380.0)
	assert_int(int(ready.get("camera_limit_right", 0))).is_greater_equal(6400)
	assert_float(float(ready.get("activation_x", 0.0))).is_greater(5760.0)
	assert_float(float(ready.get("exit_x", 0.0))).is_greater(
		float(ready.get("activation_x", 0.0))
	)
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Outlet Clamp Ambush Cleared"
	)

	player.global_position.x = float(ready.get("activation_x", 0.0)) - 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent",
		player
	))).is_false()
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent",
		player
	))).is_true()

	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("crossed", true))).is_false()
	assert_str(String(active.get("phase", ""))).is_equal("grace")
	assert_bool(bool(active.get("hazard_contact_active", true))).is_false()
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Cross Outlet Drip Vent"
	)


func test_outlet_drip_vent_pressure_window_damage_and_crossed_state_persist() -> void:
	var destination: Node = _factory_scene_with_outlet_drip_vent_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)).is_true()
	assert_bool(destination.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent"
	)).is_true()
	assert_bool(destination.has_method(
		"advance_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_time"
	)).is_true()
	assert_bool(destination.has_method(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent"
	)).is_true()
	if (
		not destination.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
		)
		or not destination.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent"
		)
		or not destination.has_method(
			"advance_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_time"
		)
		or not destination.has_method(
			"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent"
		)
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent",
		player
	))).is_true()

	var outlet_drip_vent_vent: Area2D = destination.get_node_or_null(
		DRIP_VENT_HAZARD_NODE_NAME
	) as Area2D
	assert_that(outlet_drip_vent_vent).is_not_null()
	if outlet_drip_vent_vent == null:
		return

	assert_bool(bool(destination.call(
		"apply_factory_steam_vent_contact",
		outlet_drip_vent_vent,
		player
	))).is_false()

	destination.call(
		"advance_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_time",
		0.32
	)
	var warning: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	assert_str(String(warning.get("phase", ""))).is_equal("warning")
	assert_bool(bool(warning.get("hazard_contact_active", true))).is_false()

	destination.call(
		"advance_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_time",
		0.36
	)
	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	assert_str(String(active.get("phase", ""))).is_equal("active")
	assert_bool(bool(active.get("hazard_contact_active", false))).is_true()
	var hp_before: int = int(player.call("get_current_hp"))
	assert_bool(bool(destination.call(
		"apply_factory_steam_vent_contact",
		outlet_drip_vent_vent,
		player
	))).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - 8)
	var last_damage: Dictionary = destination.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	assert_str(String(last_damage.get("source", ""))).is_equal(DRIP_VENT_HAZARD_ID)

	destination.call(
		"advance_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_time",
		0.45
	)
	var safe: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	assert_str(String(safe.get("phase", ""))).is_equal("safe")
	assert_bool(bool(safe.get("hazard_contact_active", true))).is_false()

	player.global_position.x = float(safe.get("exit_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent",
		player
	))).is_true()

	var crossed: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	assert_bool(bool(crossed.get("active", true))).is_false()
	assert_bool(bool(crossed.get("crossed", false))).is_true()
	assert_bool(bool(crossed.get("visible", false))).is_true()
	assert_bool(bool(crossed.get("hazard_contact_active", true))).is_false()
	assert_str(String(crossed.get("route_label_text", ""))).is_equal(
		"Outlet Drip Vent Crossed"
	)
	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_crossed",
		false
	))).is_true()

	var restored: Node = _factory_scene_with_outlet_drip_vent_state(true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	var restored_outlet_drip_vent: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	assert_bool(bool(restored_outlet_drip_vent.get("active", true))).is_false()
	assert_bool(bool(restored_outlet_drip_vent.get("crossed", false))).is_true()
	assert_bool(bool(restored_outlet_drip_vent.get("visible", false))).is_true()
	assert_bool(bool(restored_outlet_drip_vent.get("hazard_contact_active", true))).is_false()
	assert_str(String(restored_outlet_drip_vent.get("route_label_text", ""))).is_equal(
		"Outlet Drip Vent Crossed"
	)
	var restored_clamp: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics"
	)
	assert_bool(bool(restored_clamp.get("cleared", false))).is_true()
	var restored_outlet: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_diagnostics"
	)
	assert_bool(bool(restored_outlet.get("crossed", false))).is_true()
	assert_bool(bool(restored_outlet.get("hazard_contact_active", true))).is_false()
	var restored_lift: Dictionary = restored.call("get_factory_service_lift_diagnostics")
	assert_str(String(restored_lift.get("prompt_text", ""))).is_equal("Call lift")


func _factory_scene_with_outlet_drip_vent_state(
		outlet_clamp_cleared: bool,
		outlet_drip_vent_crossed: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", {
		"encounter_cleared": true,
		"factory_deep_guard_activated": true,
		"factory_deep_guard_defeated": true,
		"factory_deep_route_cleared": true,
		"factory_spark_rat_activated": true,
		"factory_spark_rat_defeated": true,
		"factory_return_patrol_activated": true,
		"factory_return_patrol_defeated": true,
		"factory_checkpoint_forward_patrol_activated": true,
		"factory_checkpoint_forward_patrol_defeated": true,
		"factory_checkpoint_rear_ambush_activated": true,
		"factory_checkpoint_rear_ambush_defeated": true,
		"factory_checkpoint_overdrive_duo_activated": true,
		"factory_checkpoint_overdrive_left_defeated": true,
		"factory_checkpoint_overdrive_right_defeated": true,
		"factory_checkpoint_overdrive_duo_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated": (
			outlet_clamp_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_spark_rat_defeated": (
			outlet_clamp_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_cleared": (
			outlet_clamp_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_activated": (
			outlet_drip_vent_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_crossed": (
			outlet_drip_vent_crossed
		),
	})
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


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
