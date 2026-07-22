## Player Abilities Story 097: Old Factory aftershock condenser outlet clamp ambush.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const SPARK_RAT_FRAMES: String = (
	"res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres"
)
const OUTLET_CLAMP_TEXTURE: String = (
	"res://assets/environment/old_factory_aftershock_condenser_outlet_clamp/"
	+ "env_old_factory_aftershock_condenser_outlet_clamp_256.png"
)
const OUTLET_CLAMP_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserOutletClamp"
)
const OUTLET_CLAMP_SPARK_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserOutletClampSparkRat"
)
const OUTLET_CLAMP_SPARK_ENTITY_ID: int = 2138

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


func test_outlet_clamp_requires_outlet_crossed_and_extends_combat_pocket() -> void:
	assert_bool(FileAccess.file_exists(OUTLET_CLAMP_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_outlet_clamp_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("outlet_crossed", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("cleared", true))).is_false()
	assert_bool(bool(locked.get("spark_visible", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush"
	))).is_false()

	var ready_scene: Node = _factory_scene_with_outlet_clamp_state(true, false)
	assert_that(ready_scene).is_not_null()
	if ready_scene == null:
		return
	var player: Node2D = ready_scene.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("outlet_crossed", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("cleared", true))).is_false()
	assert_str(String(ready.get("node_name", ""))).is_equal(OUTLET_CLAMP_NODE_NAME)
	assert_str(String(ready.get("spark_node_name", ""))).is_equal(
		OUTLET_CLAMP_SPARK_NODE_NAME
	)
	assert_str(String(ready.get("texture_path", ""))).is_equal(OUTLET_CLAMP_TEXTURE)
	assert_float(float(ready.get("ground_width", 0.0))).is_greater_equal(5760.0)
	assert_float(float(ready.get("right_wall_x", 0.0))).is_greater_equal(5740.0)
	assert_int(int(ready.get("camera_limit_right", 0))).is_greater_equal(5760)
	assert_float(float(ready.get("activation_x", 0.0))).is_greater(5120.0)
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Aftershock Condenser Outlet Crossed"
	)

	player.global_position.x = float(ready.get("activation_x", 0.0)) - 4.0
	assert_bool(bool(ready_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush",
		player
	))).is_false()
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(ready_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush",
		player
	))).is_true()

	var active: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("spark_visible", false))).is_true()
	assert_bool(bool(active.get("spark_has_target", false))).is_true()
	assert_bool(bool(active.get("spark_process_enabled", false))).is_true()
	assert_bool(bool(active.get("spark_physics_enabled", false))).is_true()
	assert_int(int(active.get("spark_entity_id", 0))).is_equal(
		OUTLET_CLAMP_SPARK_ENTITY_ID
	)
	assert_str(String(active.get("spark_family_id", ""))).is_equal("factory_spark_rat")
	assert_str(String(active.get("spark_sprite_frames_path", ""))).is_equal(
		SPARK_RAT_FRAMES
	)
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Clear Outlet Clamp Ambush"
	)
	_assert_spark_rat_animation_contract(active)


func test_outlet_clamp_defeat_persists_without_replaying_condenser_chain() -> void:
	var destination: Node = _factory_scene_with_outlet_clamp_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics"
	)
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush",
		player
	))).is_true()

	assert_bool(bool(destination.call(
		"apply_damage",
		OUTLET_CLAMP_SPARK_ENTITY_ID,
		999
	))).is_true()
	await get_tree().process_frame

	var cleared: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics"
	)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("visible", false))).is_true()
	assert_bool(bool(cleared.get("spark_visible", false))).is_true()
	assert_bool(bool(cleared.get("spark_process_enabled", false))).is_true()
	assert_bool(bool(cleared.get("spark_physics_enabled", true))).is_false()
	assert_str(String(cleared.get("route_label_text", ""))).is_equal(
		"Outlet Clamp Ambush Cleared"
	)
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush",
		player
	))).is_false()

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_spark_rat_defeated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_cleared",
		false
	))).is_true()

	destination.call("set_local_state", local_state)
	var reloaded_same_scene: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics"
	)
	assert_bool(bool(reloaded_same_scene.get("cleared", false))).is_true()
	assert_bool(bool(reloaded_same_scene.get("spark_visible", true))).is_false()

	var restored: Node = _factory_scene_with_outlet_clamp_state(true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	var restored_clamp: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics"
	)
	assert_bool(bool(restored_clamp.get("active", true))).is_false()
	assert_bool(bool(restored_clamp.get("cleared", false))).is_true()
	assert_bool(bool(restored_clamp.get("visible", false))).is_true()
	assert_bool(bool(restored_clamp.get("spark_visible", true))).is_false()
	assert_str(String(restored_clamp.get("route_label_text", ""))).is_equal(
		"Outlet Clamp Ambush Cleared"
	)
	var restored_outlet: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_diagnostics"
	)
	assert_bool(bool(restored_outlet.get("crossed", false))).is_true()
	assert_bool(bool(restored_outlet.get("active", true))).is_false()
	assert_bool(bool(restored_outlet.get("hazard_contact_active", true))).is_false()
	var restored_savepoint: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_diagnostics"
	)
	assert_bool(bool(restored_savepoint.get("activated", false))).is_true()
	var restored_landing: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_valve_diagnostics"
	)
	assert_bool(bool(restored_landing.get("cleared", false))).is_true()
	var restored_lift: Dictionary = restored.call("get_factory_service_lift_diagnostics")
	assert_str(String(restored_lift.get("prompt_text", ""))).is_equal("Call lift")


func _factory_scene_with_outlet_clamp_state(
		outlet_crossed: bool,
		outlet_clamp_cleared: bool
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
		"factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated": (
			outlet_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_activated": (
			outlet_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_crossed": (
			outlet_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated": (
			outlet_clamp_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_spark_rat_defeated": (
			outlet_clamp_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_cleared": (
			outlet_clamp_cleared
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


func _assert_spark_rat_animation_contract(diagnostics: Dictionary) -> void:
	var frame_counts: Dictionary = diagnostics.get(
		"spark_animation_frame_counts",
		{}
	) as Dictionary
	for animation_name: StringName in [&"idle", &"run", &"attack_tell", &"attack", &"hurt", &"death"]:
		assert_int(int(frame_counts.get(String(animation_name), 0))).is_greater_equal(3)


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
