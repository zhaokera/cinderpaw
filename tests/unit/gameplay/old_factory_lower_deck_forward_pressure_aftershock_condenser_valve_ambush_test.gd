## Player Abilities Story 094: Old Factory aftershock condenser valve ambush.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const SPARK_RAT_FRAMES: String = (
	"res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres"
)
const COIL_RAT_FRAMES: String = (
	"res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres"
)
const CONDENSER_VALVE_TEXTURE: String = (
	"res://assets/environment/old_factory_aftershock_condenser_valve/"
	+ "env_old_factory_aftershock_condenser_valve_768.png"
)
const CONDENSER_VALVE_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserValve"
)
const CONDENSER_SPARK_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserLandingSparkRat"
)
const CONDENSER_COIL_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserLandingCoilRat"
)
const CONDENSER_SPARK_ENTITY_ID: int = 2136
const CONDENSER_COIL_ENTITY_ID: int = 2137

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_condenser_valve_requires_cooling_duct_crossed_and_extends_route() -> void:
	assert_bool(FileAccess.file_exists(CONDENSER_VALVE_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_condenser_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_valve_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_valve"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_valve_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_valve"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_valve_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("cooling_duct_crossed", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("cleared", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_valve"
	))).is_false()

	var ready_scene: Node = _factory_scene_with_condenser_state(true, false)
	assert_that(ready_scene).is_not_null()
	if ready_scene == null:
		return
	var player: Node2D = ready_scene.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_valve_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("cooling_duct_crossed", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("cleared", true))).is_false()
	assert_str(String(ready.get("node_name", ""))).is_equal(CONDENSER_VALVE_NODE_NAME)
	assert_str(String(ready.get("texture_path", ""))).is_equal(CONDENSER_VALVE_TEXTURE)
	assert_float(float(ready.get("ground_width", 0.0))).is_greater_equal(4560.0)
	assert_float(float(ready.get("right_wall_x", 0.0))).is_greater_equal(4540.0)
	assert_int(int(ready.get("camera_limit_right", 0))).is_greater_equal(4560)
	assert_float(float(ready.get("activation_x", 0.0))).is_greater(3840.0)
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Aftershock Cooling Duct Crossed"
	)

	player.global_position.x = float(ready.get("activation_x", 0.0)) - 4.0
	assert_bool(bool(ready_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_valve",
		player
	))).is_false()
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(ready_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_valve",
		player
	))).is_true()
	var active: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_valve_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Secure Aftershock Condenser Landing"
	)
	_assert_enemy_animation_contract(active, "spark")
	_assert_enemy_animation_contract(active, "coil")


func test_condenser_valve_clear_persists_without_replaying_cooling_duct() -> void:
	var destination: Node = _factory_scene_with_condenser_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return
	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_valve_diagnostics"
	)
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_valve",
		player
	))).is_true()

	assert_bool(bool(destination.call("apply_damage", CONDENSER_SPARK_ENTITY_ID, 999))).is_true()
	assert_bool(bool(destination.call("apply_damage", CONDENSER_COIL_ENTITY_ID, 999))).is_true()
	var cleared: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_valve_diagnostics"
	)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("visible", false))).is_true()
	assert_str(String(cleared.get("route_label_text", ""))).is_equal(
		"Aftershock Condenser Landing Secured"
	)
	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_cleared",
		false
	))).is_true()

	var restored: Node = _factory_scene_with_condenser_state(true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	var restored_condenser: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_valve_diagnostics"
	)
	assert_bool(bool(restored_condenser.get("active", true))).is_false()
	assert_bool(bool(restored_condenser.get("cleared", false))).is_true()
	assert_bool(bool(restored_condenser.get("visible", false))).is_true()
	assert_str(String(restored_condenser.get("route_label_text", ""))).is_equal(
		"Aftershock Condenser Landing Secured"
	)
	var restored_duct: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	assert_bool(bool(restored_duct.get("crossed", false))).is_true()
	assert_bool(bool(restored_duct.get("active", true))).is_false()
	assert_bool(bool(restored_duct.get("hazard_contact_active", true))).is_false()
	assert_str(String(restored_duct.get("route_label_text", ""))).is_equal(
		"Aftershock Condenser Landing Secured"
	)
	var hatch: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
	)
	assert_bool(bool(hatch.get("opened", false))).is_true()
	assert_str(String(hatch.get("prompt_text", ""))).is_equal("Exhaust Hatch Open")


func _factory_scene_with_condenser_state(
		cooling_duct_crossed: bool,
		condenser_cleared: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", {
		"factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened": (
			cooling_duct_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_activated": (
			cooling_duct_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_crossed": (
			cooling_duct_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_activated": (
			condenser_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_spark_rat_defeated": (
			condenser_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_coil_rat_defeated": (
			condenser_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_valve_cleared": (
			condenser_cleared
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


func _assert_enemy_animation_contract(diagnostics: Dictionary, prefix: String) -> void:
	assert_bool(bool(diagnostics.get(prefix + "_visible", false))).is_true()
	assert_bool(bool(diagnostics.get(prefix + "_has_target", false))).is_true()
	assert_bool(bool(diagnostics.get(prefix + "_process_enabled", false))).is_true()
	assert_bool(bool(diagnostics.get(prefix + "_physics_enabled", false))).is_true()
	var expected_frames: String = SPARK_RAT_FRAMES if prefix == "spark" else COIL_RAT_FRAMES
	assert_str(String(diagnostics.get(prefix + "_sprite_frames_path", ""))).is_equal(
		expected_frames
	)
	var frame_counts: Dictionary = diagnostics.get(
		prefix + "_animation_frame_counts",
		{}
	) as Dictionary
	for animation_name: StringName in [&"idle", &"run", &"attack_tell", &"attack", &"hurt", &"death"]:
		assert_int(int(frame_counts.get(String(animation_name), 0))).is_greater_equal(3)
