## Player Abilities Story 113: Old Factory runoff outlet service sluice traverse.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const SERVICE_SLUICE_DUCT_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceDuct"
)
const SERVICE_SLUICE_VENT_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceSteamVent"
)
const SERVICE_SLUICE_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice"
)
const SERVICE_SLUICE_DUCT_TEXTURE: String = (
	"res://assets/environment/old_factory_runoff_service_hatch_landing/"
	+ "env_old_factory_runoff_service_hatch_landing_768.png"
)
const SERVICE_SLUICE_VENT_TEXTURE: String = (
	"res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png"
)
const SERVICE_SLUICE_ACTIVATION_X: float = 10160.0
const SERVICE_SLUICE_EXIT_X: float = 10720.0
const EXPECTED_RIGHT_WALL_X: float = 10940.0
const EXPECTED_CAMERA_LIMIT_RIGHT: int = 10960
const EXPECTED_BACKGROUND_WIDTH: float = 10960.0
const EXPECTED_GROUND_WIDTH: float = 12800.0
const EXPECTED_FLOOR_TILE_COUNT: int = 45
const EXPECTED_STEAM_DAMAGE: int = 8

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


func test_service_sluice_requires_service_hatch_open_and_extends_playable_space(
) -> void:
	assert_bool(FileAccess.file_exists(SERVICE_SLUICE_DUCT_TEXTURE)).is_true()
	assert_bool(FileAccess.file_exists(SERVICE_SLUICE_VENT_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_service_sluice_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice"
		)
		or not locked_scene.has_method(
			"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("service_hatch_opened", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("crossed", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("hazard_visible", true))).is_false()
	assert_bool(bool(locked.get("hazard_contact_active", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice"
	))).is_false()

	var destination: Node = _factory_scene_with_service_sluice_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("service_hatch_opened", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("crossed", true))).is_false()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("hazard_visible", false))).is_true()
	assert_bool(bool(ready.get("hazard_contact_active", true))).is_false()
	assert_str(String(ready.get("node_name", ""))).is_equal(SERVICE_SLUICE_DUCT_NODE_NAME)
	assert_str(String(ready.get("hazard_node_name", ""))).is_equal(
		SERVICE_SLUICE_VENT_NODE_NAME
	)
	assert_str(String(ready.get("duct_texture_path", ""))).is_equal(
		SERVICE_SLUICE_DUCT_TEXTURE
	)
	assert_str(String(ready.get("hazard_texture_path", ""))).is_equal(
		SERVICE_SLUICE_VENT_TEXTURE
	)
	assert_str(String(ready.get("hazard_id", ""))).is_equal(SERVICE_SLUICE_HAZARD_ID)
	assert_int(int(ready.get("hazard_damage", 0))).is_equal(EXPECTED_STEAM_DAMAGE)
	assert_float(float(ready.get("activation_x", 0.0))).is_equal(
		SERVICE_SLUICE_ACTIVATION_X
	)
	assert_float(float(ready.get("exit_x", 0.0))).is_equal(SERVICE_SLUICE_EXIT_X)
	assert_float(float(ready.get("right_wall_x", 0.0))).is_greater_equal(
		EXPECTED_RIGHT_WALL_X
	)
	assert_int(int(ready.get("camera_limit_right", 0))).is_greater_equal(
		EXPECTED_CAMERA_LIMIT_RIGHT
	)
	assert_float(float(ready.get("background_width", 0.0))).is_greater_equal(
		EXPECTED_BACKGROUND_WIDTH
	)
	assert_float(float(ready.get("ground_width", 0.0))).is_greater_equal(
		EXPECTED_GROUND_WIDTH
	)
	assert_int(int(ready.get("floor_tile_count", 0))).is_greater_equal(
		EXPECTED_FLOOR_TILE_COUNT
	)
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Runoff Outlet Service Hatch Open"
	)

	player.global_position.x = SERVICE_SLUICE_ACTIVATION_X - 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice",
		player
	))).is_false()
	player.global_position.x = SERVICE_SLUICE_ACTIVATION_X + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice",
		player
	))).is_true()

	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("crossed", true))).is_false()
	assert_str(String(active.get("phase", ""))).is_equal("grace")
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Cross Runoff Outlet Service Sluice"
	)


func test_service_sluice_pressure_cycle_damage_window_and_completion_persist(
) -> void:
	var destination: Node = _factory_scene_with_service_sluice_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return
	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_diagnostics"
	)).is_true()
	assert_bool(destination.has_method(
		"advance_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_time"
	)).is_true()
	if (
		not destination.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_diagnostics"
		)
		or not destination.has_method(
			"advance_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_time"
		)
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return
	player.global_position.x = SERVICE_SLUICE_ACTIVATION_X + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice",
		player
	))).is_true()

	destination.call(
		"advance_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_time",
		0.26
	)
	var warning: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_diagnostics"
	)
	assert_str(String(warning.get("phase", ""))).is_equal("warning")
	assert_bool(bool(warning.get("hazard_contact_active", true))).is_false()

	destination.call(
		"advance_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_time",
		0.36
	)
	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_diagnostics"
	)
	assert_str(String(active.get("phase", ""))).is_equal("active")
	assert_bool(bool(active.get("hazard_contact_active", false))).is_true()
	assert_int(int(active.get("collision_layer", 0))).is_not_equal(0)
	assert_int(int(active.get("collision_mask", 0))).is_not_equal(0)

	player.global_position.x = SERVICE_SLUICE_EXIT_X + 4.0
	assert_bool(bool(destination.call(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice",
		player
	))).is_true()
	assert_bool(bool(destination.call(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice",
		player
	))).is_false()

	var crossed: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_diagnostics"
	)
	assert_bool(bool(crossed.get("active", true))).is_false()
	assert_bool(bool(crossed.get("crossed", false))).is_true()
	assert_bool(bool(crossed.get("hazard_contact_active", true))).is_false()
	assert_str(String(crossed.get("phase", ""))).is_equal("crossed")
	assert_str(String(crossed.get("route_label_text", ""))).is_equal(
		"Runoff Outlet Service Sluice Crossed"
	)
	assert_bool(bool(destination.call("is_factory_route_objective_complete"))).is_true()

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed",
		false
	))).is_true()

	var restored: Node = _factory_scene_with_service_sluice_state(false, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	var restored_sluice: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_diagnostics"
	)
	assert_bool(bool(restored_sluice.get("active", true))).is_false()
	assert_bool(bool(restored_sluice.get("crossed", false))).is_true()
	assert_bool(bool(restored_sluice.get("service_hatch_opened", false))).is_true()
	assert_bool(bool(restored_sluice.get("hazard_contact_active", true))).is_false()
	assert_str(String(restored_sluice.get("route_label_text", ""))).is_equal(
		"Runoff Outlet Service Sluice Crossed"
	)
	var restored_hatch: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_diagnostics"
	)
	assert_bool(bool(restored_hatch.get("opened", false))).is_true()
	assert_bool(bool(restored_hatch.get("collision_blocking", true))).is_false()
	var restored_cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_diagnostics"
	)
	assert_bool(bool(restored_cache.get("claimed", false))).is_true()


func _factory_scene_with_service_sluice_state(
	service_hatch_opened: bool,
	service_sluice_crossed: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated": (
			service_hatch_opened
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated": (
			service_hatch_opened
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_cleared": (
			service_hatch_opened
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed": (
			service_hatch_opened
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened": (
			service_hatch_opened
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated": (
			service_sluice_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed": (
			service_sluice_crossed
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
