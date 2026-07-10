## Player Abilities Story 125: Tailrace exit spillway visual pass.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const TAILRACE_EXIT_SPILLWAY_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_tailrace_exit_spillway/"
	+ "env_old_factory_tailrace_exit_spillway_768.png"
)
const PREVIOUS_REUSED_LANDING_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_runoff_service_hatch_landing/"
	+ "env_old_factory_runoff_service_hatch_landing_768.png"
)
const STEAM_VENT_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png"
)
const SPILLWAY_DUCT_NODE_PATH: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerExitSpillwayDuct"
)
const SPILLWAY_VISUAL_STATE_KEY: String = (
	"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened"
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


func test_tailrace_exit_spillway_uses_dedicated_generated_visual() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	assert_bool(destination.has_method("set_local_state")).is_true()
	assert_bool(
		destination.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
		)
	).is_true()
	if (
		not destination.has_method("set_local_state")
		or not destination.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
		)
	):
		return

	destination.call("set_local_state", {SPILLWAY_VISUAL_STATE_KEY: true})
	var diagnostics: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
	)
	var duct: Sprite2D = destination.get_node_or_null(SPILLWAY_DUCT_NODE_PATH) as Sprite2D

	assert_bool(bool(diagnostics.get("present", false))).is_true()
	assert_bool(bool(diagnostics.get("available", false))).is_true()
	assert_bool(bool(diagnostics.get("visible", false))).is_true()
	assert_that(duct).is_not_null()
	if duct == null:
		return

	assert_bool(duct.visible).is_true()
	assert_bool(duct.is_visible_in_tree()).is_true()
	assert_int(duct.z_index).is_equal(12)
	assert_bool(duct.z_as_relative).is_false()
	assert_vector(duct.position).is_equal(Vector2(16720, 392))
	assert_vector(duct.scale).is_equal(Vector2(0.78, 0.78))

	assert_bool(FileAccess.file_exists(TAILRACE_EXIT_SPILLWAY_TEXTURE_PATH)).is_true()
	assert_str(String(diagnostics.get("duct_texture_path", ""))).is_equal(
		TAILRACE_EXIT_SPILLWAY_TEXTURE_PATH
	)
	assert_str(String(diagnostics.get("duct_texture_path", ""))).is_not_equal(
		PREVIOUS_REUSED_LANDING_TEXTURE_PATH
	)
	assert_that(duct.texture).is_not_null()
	if duct.texture != null:
		assert_vector(duct.texture.get_size()).is_equal(Vector2(768, 320))

	assert_str(String(diagnostics.get("hazard_texture_path", ""))).is_equal(
		STEAM_VENT_TEXTURE_PATH
	)
	assert_int(int(diagnostics.get("hazard_damage", 0))).is_equal(8)
	assert_float(float(diagnostics.get("hazard_cooldown_sec", 0.0))).is_equal(1.0)
	assert_bool(bool(diagnostics.get("hazard_contact_active", true))).is_false()
	assert_float(float(diagnostics.get("right_wall_x", 0.0))).is_greater_equal(17280.0)
	assert_int(int(diagnostics.get("camera_limit_right", 0))).is_greater_equal(17300)
	assert_float(float(diagnostics.get("background_width", 0.0))).is_greater_equal(17300.0)
	assert_float(float(diagnostics.get("ground_right_edge_x", 0.0))).is_greater_equal(17400.0)
	assert_int(int(diagnostics.get("floor_tile_count", 0))).is_greater_equal(69)


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
