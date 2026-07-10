## Player Abilities Story 121: Old Factory tailrace relay runoff pincer.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const TAILRACE_RELAY_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
)
const TAILRACE_RELAY_SPAWN_POINT: String = (
	"lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
)
const TAILRACE_RELAY_RUNOFF_PINCER_SPARK_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerSparkRat"
)
const TAILRACE_RELAY_RUNOFF_PINCER_COIL_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerCoilRat"
)
const TAILRACE_RELAY_RUNOFF_PINCER_SPARK_ENTITY_ID: int = 2144
const TAILRACE_RELAY_RUNOFF_PINCER_COIL_ENTITY_ID: int = 2145
const TAILRACE_RELAY_RUNOFF_PINCER_ACTIVATION_X: float = 14640.0
const TAILRACE_RELAY_RUNOFF_SPARK_OPENING_GRACE_FRAMES: int = 10
const TAILRACE_RELAY_RUNOFF_COIL_OPENING_GRACE_FRAMES: int = 24
const SPARK_RAT_SPRITE_FRAMES: String = (
	"res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres"
)
const COIL_RAT_SPRITE_FRAMES: String = (
	"res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres"
)
const REQUIRED_CHARACTER_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]
const MIN_CHARACTER_ANIMATION_FRAMES: int = 3

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


func test_tailrace_relay_runoff_pincer_requires_runoff_crossed_and_activates_dual_rats(
) -> void:
	assert_bool(FileAccess.file_exists(SPARK_RAT_SPRITE_FRAMES)).is_true()
	assert_bool(FileAccess.file_exists(COIL_RAT_SPRITE_FRAMES)).is_true()

	var locked_scene: Node = _factory_scene_with_tailrace_relay_runoff_pincer_state(
		false,
		false
	)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("tailrace_relay_runoff_crossed", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("cleared", true))).is_false()
	assert_bool(bool(locked.get("spark_visible", true))).is_false()
	assert_bool(bool(locked.get("coil_visible", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer"
	))).is_false()

	var ready_scene: Node = _factory_scene_with_tailrace_relay_runoff_pincer_state(
		true,
		false
	)
	assert_that(ready_scene).is_not_null()
	if ready_scene == null:
		return
	var player: Node2D = ready_scene.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("tailrace_relay_runoff_crossed", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("cleared", true))).is_false()
	assert_bool(bool(ready.get("spark_visible", true))).is_false()
	assert_bool(bool(ready.get("coil_visible", true))).is_false()
	assert_str(String(ready.get("spark_node_name", ""))).is_equal(
		TAILRACE_RELAY_RUNOFF_PINCER_SPARK_NODE_NAME
	)
	assert_str(String(ready.get("coil_node_name", ""))).is_equal(
		TAILRACE_RELAY_RUNOFF_PINCER_COIL_NODE_NAME
	)
	assert_float(float(ready.get("activation_x", 0.0))).is_equal(
		TAILRACE_RELAY_RUNOFF_PINCER_ACTIVATION_X
	)
	assert_float(float(ready.get("right_wall_x", 0.0))).is_greater_equal(15580.0)
	assert_int(int(ready.get("camera_limit_right", 0))).is_greater_equal(15600)
	assert_float(float(ready.get("background_width", 0.0))).is_greater_equal(15600.0)
	assert_float(float(ready.get("ground_right_edge_x", 0.0))).is_greater_equal(15700.0)
	assert_int(int(ready.get("floor_tile_count", 0))).is_greater_equal(63)
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Tailrace Relay Runoff Crossed"
	)

	player.global_position.x = TAILRACE_RELAY_RUNOFF_PINCER_ACTIVATION_X - 4.0
	assert_bool(bool(ready_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer",
		player
	))).is_false()
	player.global_position.x = TAILRACE_RELAY_RUNOFF_PINCER_ACTIVATION_X + 4.0
	assert_bool(bool(ready_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer",
		player
	))).is_true()

	var active: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("cleared", true))).is_false()
	assert_bool(bool(active.get("spark_visible", false))).is_true()
	assert_bool(bool(active.get("coil_visible", false))).is_true()
	assert_bool(bool(active.get("spark_has_target", false))).is_true()
	assert_bool(bool(active.get("coil_has_target", false))).is_true()
	assert_bool(bool(active.get("spark_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("coil_physics_enabled", false))).is_true()
	assert_int(int(active.get("spark_entity_id", 0))).is_equal(
		TAILRACE_RELAY_RUNOFF_PINCER_SPARK_ENTITY_ID
	)
	assert_int(int(active.get("coil_entity_id", 0))).is_equal(
		TAILRACE_RELAY_RUNOFF_PINCER_COIL_ENTITY_ID
	)
	assert_str(String(active.get("spark_family_id", ""))).is_equal("factory_spark_rat")
	assert_str(String(active.get("coil_family_id", ""))).is_equal("factory_coil_rat")
	assert_str(String(active.get("spark_sprite_frames_path", ""))).is_equal(
		SPARK_RAT_SPRITE_FRAMES
	)
	assert_str(String(active.get("coil_sprite_frames_path", ""))).is_equal(
		COIL_RAT_SPRITE_FRAMES
	)
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Break Tailrace Runoff Pincer"
	)
	assert_vector(active.get("spark_position", Vector2.ZERO) as Vector2).is_equal(
		Vector2(14760, 482)
	)
	assert_vector(active.get("coil_position", Vector2.ZERO) as Vector2).is_equal(
		Vector2(15280, 482)
	)
	_assert_frame_contract(active, "spark_animation_frame_counts")
	_assert_frame_contract(active, "coil_animation_frame_counts")
	_assert_pacing_contract(
		active.get("spark_pacing", {}) as Dictionary,
		TAILRACE_RELAY_RUNOFF_SPARK_OPENING_GRACE_FRAMES
	)
	_assert_pacing_contract(
		active.get("coil_pacing", {}) as Dictionary,
		TAILRACE_RELAY_RUNOFF_COIL_OPENING_GRACE_FRAMES
	)


func test_tailrace_relay_runoff_pincer_requires_both_defeats_and_restores_chain(
) -> void:
	var destination: Node = _factory_scene_with_tailrace_relay_runoff_pincer_state(
		true,
		false
	)
	assert_that(destination).is_not_null()
	if destination == null:
		return
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return
	player.global_position.x = TAILRACE_RELAY_RUNOFF_PINCER_ACTIVATION_X + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer",
		player
	))).is_true()

	assert_bool(destination.call("apply_damage", TAILRACE_RELAY_RUNOFF_PINCER_SPARK_ENTITY_ID, 999, {
		"source": &"unit_test_tailrace_relay_runoff_spark_rat",
	})).is_true()
	await get_tree().process_frame
	var half_cleared: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_diagnostics"
	)
	assert_bool(bool(half_cleared.get("active", false))).is_true()
	assert_bool(bool(half_cleared.get("cleared", true))).is_false()
	assert_bool(bool(half_cleared.get("spark_defeated", false))).is_true()
	assert_bool(bool(half_cleared.get("coil_defeated", true))).is_false()
	assert_bool(bool(half_cleared.get("spark_visible", true))).is_false()
	assert_bool(bool(half_cleared.get("coil_visible", false))).is_true()
	assert_str(String(half_cleared.get("route_label_text", ""))).is_equal(
		"Break Tailrace Runoff Pincer"
	)

	assert_bool(destination.call("apply_damage", TAILRACE_RELAY_RUNOFF_PINCER_COIL_ENTITY_ID, 999, {
		"source": &"unit_test_tailrace_relay_runoff_coil_rat",
	})).is_true()
	await get_tree().process_frame
	var cleared: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_diagnostics"
	)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("spark_visible", true))).is_false()
	assert_bool(bool(cleared.get("coil_visible", true))).is_false()
	assert_bool(bool(cleared.get("spark_physics_enabled", true))).is_false()
	assert_bool(bool(cleared.get("coil_physics_enabled", true))).is_false()
	assert_str(String(cleared.get("route_label_text", ""))).is_equal(
		"Tailrace Runoff Pincer Cleared"
	)
	assert_bool(bool(destination.call("is_factory_route_objective_complete"))).is_true()
	var last_savepoint: Dictionary = Dictionary(cleared.get("last_savepoint", {}))
	assert_str(String(last_savepoint.get("id", ""))).is_equal(TAILRACE_RELAY_ID)
	assert_str(String(last_savepoint.get("spawn_point", ""))).is_equal(
		TAILRACE_RELAY_SPAWN_POINT
	)

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_spark_rat_defeated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_coil_rat_defeated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_cleared",
		false
	))).is_true()

	var restored: Node = _factory_scene_with_tailrace_relay_runoff_pincer_state(
		false,
		true
	)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	var restored_pincer: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_diagnostics"
	)
	assert_bool(bool(restored_pincer.get("active", true))).is_false()
	assert_bool(bool(restored_pincer.get("cleared", false))).is_true()
	assert_bool(bool(restored_pincer.get("tailrace_relay_runoff_crossed", false))).is_true()
	assert_bool(bool(restored_pincer.get("spark_visible", true))).is_false()
	assert_bool(bool(restored_pincer.get("coil_visible", true))).is_false()
	assert_str(String(restored_pincer.get("route_label_text", ""))).is_equal(
		"Tailrace Runoff Pincer Cleared"
	)
	var restored_runoff: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_diagnostics"
	)
	assert_bool(bool(restored_runoff.get("crossed", false))).is_true()
	assert_bool(bool(restored_runoff.get("hazard_contact_active", true))).is_false()
	var restored_relay: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_diagnostics"
	)
	assert_bool(bool(restored_relay.get("activated", false))).is_true()
	assert_int(int(restored_relay.get("activation_vfx_spawn_count", -1))).is_equal(0)


func _factory_scene_with_tailrace_relay_runoff_pincer_state(
	tailrace_relay_runoff_crossed: bool,
	pincer_cleared: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	var chain_complete: bool = tailrace_relay_runoff_crossed or pincer_cleared
	var state: Dictionary = _service_sluice_tailrace_base_state().merged({
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_activated": (
			chain_complete
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_crossed": (
			chain_complete
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_activated": (
			pincer_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_spark_rat_defeated": (
			pincer_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_coil_rat_defeated": (
			pincer_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_cleared": (
			pincer_cleared
		),
	}, true)
	state["last_return_checkpoint"] = _tailrace_relay_checkpoint_snapshot()
	destination.call("set_local_state", state)
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


func _service_sluice_tailrace_base_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_crossed": true,
	}


func _tailrace_relay_checkpoint_snapshot() -> Dictionary:
	return {
		"id": TAILRACE_RELAY_ID,
		"scene_id": "area_03_factory",
		"spawn_point": TAILRACE_RELAY_SPAWN_POINT,
		"position": Vector2(13480, 382),
	}


func _assert_frame_contract(diagnostics: Dictionary, key: String) -> void:
	var frame_counts: Dictionary = diagnostics.get(key, {}) as Dictionary
	for animation_name: StringName in REQUIRED_CHARACTER_ANIMATIONS:
		assert_bool(frame_counts.has(animation_name)).is_true()
		assert_int(int(frame_counts.get(animation_name, 0))).is_greater_equal(
			MIN_CHARACTER_ANIMATION_FRAMES
		)


func _assert_pacing_contract(pacing: Dictionary, opening_grace_frames: int) -> void:
	assert_str(String(pacing.get("pacing_state", ""))).is_equal("opening_grace")
	assert_int(int(pacing.get("opening_grace_total_frames", 0))).is_equal(
		opening_grace_frames
	)
	assert_int(int(pacing.get("opening_grace_frames", 0))).is_equal(
		opening_grace_frames
	)
	assert_bool(bool(pacing.get("active", false))).is_true()


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
