## Player Abilities Story 110: Old Factory runoff outlet traverse.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const RUNOFF_OUTLET_DUCT_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletDuct"
)
const RUNOFF_OUTLET_HAZARD_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletSteamVent"
)
const RUNOFF_OUTLET_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet"
)
const RUNOFF_OUTLET_DUCT_TEXTURE: String = (
	"res://assets/environment/old_factory_aftershock_cooling_duct/"
	+ "env_old_factory_aftershock_cooling_duct_768.png"
)
const RUNOFF_OUTLET_HAZARD_TEXTURE: String = (
	"res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png"
)
const RUNOFF_OUTLET_ACTIVATION_X: float = 8480.0
const RUNOFF_OUTLET_EXIT_X: float = 9060.0
const EXPECTED_RIGHT_WALL_X: float = 9340.0
const EXPECTED_CAMERA_LIMIT_RIGHT: int = 9360
const EXPECTED_GROUND_WIDTH: float = 12288.0
const EXPECTED_FLOOR_TILE_COUNT: int = 39

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


func test_runoff_outlet_traverse_requires_gate_opened_and_cycles_steam_vent(
) -> void:
	assert_bool(FileAccess.file_exists(RUNOFF_OUTLET_DUCT_TEXTURE)).is_true()
	assert_bool(FileAccess.file_exists(RUNOFF_OUTLET_HAZARD_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_runoff_outlet_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return
	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"advance_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_time"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet"
		)
		or not locked_scene.has_method(
			"advance_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_time"
		)
		or not locked_scene.has_method(
			"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("runoff_exit_gate_opened", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("crossed", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("hazard_visible", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet"
	))).is_false()

	var destination: Node = _factory_scene_with_runoff_outlet_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("runoff_exit_gate_opened", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("crossed", true))).is_false()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("hazard_visible", false))).is_true()
	assert_bool(bool(ready.get("hazard_contact_active", true))).is_false()
	assert_str(String(ready.get("node_name", ""))).is_equal(RUNOFF_OUTLET_DUCT_NODE_NAME)
	assert_str(String(ready.get("hazard_node_name", ""))).is_equal(
		RUNOFF_OUTLET_HAZARD_NODE_NAME
	)
	assert_str(String(ready.get("duct_texture_path", ""))).is_equal(
		RUNOFF_OUTLET_DUCT_TEXTURE
	)
	assert_str(String(ready.get("hazard_texture_path", ""))).is_equal(
		RUNOFF_OUTLET_HAZARD_TEXTURE
	)
	assert_str(String(ready.get("hazard_id", ""))).is_equal(RUNOFF_OUTLET_HAZARD_ID)
	assert_int(int(ready.get("hazard_damage", 0))).is_equal(8)
	assert_str(String(ready.get("phase", ""))).is_equal("idle")
	assert_float(float(ready.get("activation_x", 0.0))).is_equal(
		RUNOFF_OUTLET_ACTIVATION_X
	)
	assert_float(float(ready.get("exit_x", 0.0))).is_equal(RUNOFF_OUTLET_EXIT_X)
	assert_float(float(ready.get("ground_width", 0.0))).is_greater_equal(
		EXPECTED_GROUND_WIDTH
	)
	assert_float(float(ready.get("right_wall_x", 0.0))).is_greater_equal(
		EXPECTED_RIGHT_WALL_X
	)
	assert_int(int(ready.get("camera_limit_right", 0))).is_greater_equal(
		EXPECTED_CAMERA_LIMIT_RIGHT
	)
	assert_int(int(ready.get("floor_tile_count", 0))).is_greater_equal(
		EXPECTED_FLOOR_TILE_COUNT
	)
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Overflow Pump Runoff Exit Gate Open"
	)

	player.global_position.x = RUNOFF_OUTLET_ACTIVATION_X - 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet",
		player
	))).is_false()
	player.global_position.x = RUNOFF_OUTLET_ACTIVATION_X + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet",
		player
	))).is_true()

	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_str(String(active.get("phase", ""))).is_equal("grace")
	assert_bool(bool(active.get("hazard_contact_active", true))).is_false()
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Cross Overflow Pump Runoff Outlet"
	)

	destination.call(
		"advance_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_time",
		0.65
	)
	var contact: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
	)
	assert_str(String(contact.get("phase", ""))).is_equal("active")
	assert_bool(bool(contact.get("hazard_contact_active", false))).is_true()

	player.global_position.x = RUNOFF_OUTLET_EXIT_X + 4.0
	assert_bool(bool(destination.call(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet",
		player
	))).is_true()
	assert_bool(bool(destination.call(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet",
		player
	))).is_false()

	var crossed: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
	)
	assert_bool(bool(crossed.get("crossed", false))).is_true()
	assert_bool(bool(crossed.get("active", true))).is_false()
	assert_str(String(crossed.get("phase", ""))).is_equal("crossed")
	assert_bool(bool(crossed.get("hazard_contact_active", true))).is_false()
	assert_str(String(crossed.get("route_label_text", ""))).is_equal(
		"Overflow Pump Runoff Outlet Crossed"
	)

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed",
		false
	))).is_true()


func test_runoff_outlet_restore_backfills_gate_chain_and_stays_safe() -> void:
	var restored: Node = _factory_scene_with_runoff_outlet_state(true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	assert_bool(restored.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
	)).is_true()
	if not restored.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
	):
		return
	var outlet: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_diagnostics"
	)
	assert_bool(bool(outlet.get("crossed", false))).is_true()
	assert_bool(bool(outlet.get("active", true))).is_false()
	assert_str(String(outlet.get("phase", ""))).is_equal("crossed")
	assert_bool(bool(outlet.get("visible", false))).is_true()
	assert_bool(bool(outlet.get("hazard_visible", false))).is_true()
	assert_bool(bool(outlet.get("hazard_contact_active", true))).is_false()
	assert_str(String(outlet.get("route_label_text", ""))).is_equal(
		"Overflow Pump Runoff Outlet Crossed"
	)

	var gate: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_diagnostics"
	)
	assert_bool(bool(gate.get("opened", false))).is_true()
	assert_bool(bool(gate.get("collision_blocking", true))).is_false()
	var cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_diagnostics"
	)
	assert_bool(bool(cache.get("claimed", false))).is_true()


func _factory_scene_with_runoff_outlet_state(
		runoff_exit_gate_opened: bool,
		runoff_outlet_crossed: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed": (
			runoff_exit_gate_opened
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened": (
			runoff_exit_gate_opened
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated": (
			runoff_outlet_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed": (
			runoff_outlet_crossed
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
