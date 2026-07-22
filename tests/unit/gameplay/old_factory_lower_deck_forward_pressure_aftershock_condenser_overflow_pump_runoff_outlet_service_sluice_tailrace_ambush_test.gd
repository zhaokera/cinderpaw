## Player Abilities Story 118: Old Factory service sluice tailrace Coil Rat ambush.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const TAILRACE_COIL_RAT_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceCoilRat"
)
const TAILRACE_COIL_RAT_ENTITY_ID: int = 2143
const TAILRACE_COIL_RAT_ACTIVATION_X: float = 12620.0
const TAILRACE_COIL_RAT_OPENING_GRACE_FRAMES: int = 10
const COIL_RAT_SPRITE_FRAMES: String = (
	"res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres"
)
const REQUIRED_COIL_RAT_ANIMATIONS: Array[StringName] = [
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


func test_tailrace_ambush_requires_tailrace_crossed_and_activates_coil_contract(
) -> void:
	assert_bool(FileAccess.file_exists(COIL_RAT_SPRITE_FRAMES)).is_true()

	var locked_scene: Node = _factory_scene_with_tailrace_ambush_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("tailrace_crossed", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("cleared", true))).is_false()
	assert_bool(bool(locked.get("coil_visible", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush"
	))).is_false()

	var destination: Node = _factory_scene_with_tailrace_ambush_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("tailrace_crossed", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("cleared", true))).is_false()
	assert_bool(bool(ready.get("coil_visible", true))).is_false()
	assert_str(String(ready.get("coil_node_name", ""))).is_equal(
		TAILRACE_COIL_RAT_NODE_NAME
	)
	assert_float(float(ready.get("activation_x", 0.0))).is_equal(
		TAILRACE_COIL_RAT_ACTIVATION_X
	)
	assert_float(float(ready.get("right_wall_x", 0.0))).is_greater_equal(13200.0)
	assert_int(int(ready.get("camera_limit_right", 0))).is_greater_equal(13220)
	assert_float(float(ready.get("background_width", 0.0))).is_greater_equal(13220.0)
	assert_float(float(ready.get("ground_right_edge_x", 0.0))).is_greater_equal(13300.0)
	assert_int(int(ready.get("floor_tile_count", 0))).is_greater_equal(55)
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Service Sluice Tailrace Crossed"
	)

	player.global_position.x = TAILRACE_COIL_RAT_ACTIVATION_X - 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush",
		player
	))).is_false()
	player.global_position.x = TAILRACE_COIL_RAT_ACTIVATION_X + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush",
		player
	))).is_true()

	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("cleared", true))).is_false()
	assert_bool(bool(active.get("coil_visible", false))).is_true()
	assert_bool(bool(active.get("coil_has_target", false))).is_true()
	assert_bool(bool(active.get("coil_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("coil_process_enabled", false))).is_true()
	assert_int(int(active.get("coil_entity_id", 0))).is_equal(
		TAILRACE_COIL_RAT_ENTITY_ID
	)
	assert_str(String(active.get("coil_family_id", ""))).is_equal("factory_coil_rat")
	assert_str(String(active.get("coil_sprite_frames_path", ""))).is_equal(
		COIL_RAT_SPRITE_FRAMES
	)
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Clear Tailrace Coil Rat"
	)
	_assert_coil_rat_frame_contract(active)
	_assert_coil_rat_pacing_contract(active)


func test_tailrace_ambush_defeat_persists_and_backfills_service_sluice_chain(
) -> void:
	var destination: Node = _factory_scene_with_tailrace_ambush_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return
	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
	)).is_true()
	assert_bool(destination.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush"
	)).is_true()
	if (
		not destination.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
		)
		or not destination.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush"
		)
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return
	player.global_position.x = TAILRACE_COIL_RAT_ACTIVATION_X + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush",
		player
	))).is_true()

	assert_bool(destination.call("apply_damage", TAILRACE_COIL_RAT_ENTITY_ID, 999, {
		"source": &"unit_test_service_sluice_tailrace_coil_rat",
	})).is_true()
	await get_tree().process_frame

	var cleared: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
	)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("coil_visible", false))).is_true()
	assert_bool(bool(cleared.get("coil_process_enabled", false))).is_true()
	assert_bool(bool(cleared.get("coil_physics_enabled", true))).is_false()
	assert_str(String(cleared.get("route_label_text", ""))).is_equal(
		"Repair Tailrace Relay"
	)
	assert_bool(bool(destination.call("is_factory_route_objective_complete"))).is_false()
	var relay: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_diagnostics"
	)
	assert_bool(bool(relay.get("available", false))).is_true()
	assert_bool(bool(relay.get("visible", false))).is_true()
	assert_bool(bool(relay.get("activated", true))).is_false()

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_coil_rat_defeated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared",
		false
	))).is_true()

	var restored: Node = _factory_scene_with_tailrace_ambush_state(false, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	var restored_ambush: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
	)
	assert_bool(bool(restored_ambush.get("active", true))).is_false()
	assert_bool(bool(restored_ambush.get("cleared", false))).is_true()
	assert_bool(bool(restored_ambush.get("coil_visible", true))).is_false()
	assert_bool(bool(restored_ambush.get("tailrace_crossed", false))).is_true()
	assert_str(String(restored_ambush.get("route_label_text", ""))).is_equal(
		"Repair Tailrace Relay"
	)
	var restored_relay: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_diagnostics"
	)
	assert_bool(bool(restored_relay.get("available", false))).is_true()
	assert_bool(bool(restored_relay.get("activated", true))).is_false()
	var restored_tailrace: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	)
	assert_bool(bool(restored_tailrace.get("crossed", false))).is_true()
	assert_bool(bool(restored_tailrace.get("service_sluice_exit_hatch_opened", false))).is_true()
	var restored_hatch: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics"
	)
	assert_bool(bool(restored_hatch.get("opened", false))).is_true()
	assert_bool(bool(restored_hatch.get("collision_blocking", true))).is_false()


func _factory_scene_with_tailrace_ambush_state(
	tailrace_crossed: bool,
	tailrace_ambush_cleared: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_cleared": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_claimed": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_opened": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_activated": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_crossed": (
			tailrace_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_activated": (
			tailrace_ambush_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_coil_rat_defeated": (
			tailrace_ambush_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared": (
			tailrace_ambush_cleared
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


func _assert_coil_rat_frame_contract(diagnostics: Dictionary) -> void:
	var frame_counts: Dictionary = diagnostics.get(
		"coil_animation_frame_counts",
		{}
	) as Dictionary
	for animation_name: StringName in REQUIRED_COIL_RAT_ANIMATIONS:
		assert_bool(frame_counts.has(animation_name)).is_true()
		assert_int(int(frame_counts.get(animation_name, 0))).is_greater_equal(
			MIN_CHARACTER_ANIMATION_FRAMES
		)


func _assert_coil_rat_pacing_contract(diagnostics: Dictionary) -> void:
	var pacing: Dictionary = diagnostics.get("pacing", {}) as Dictionary
	assert_str(String(pacing.get("pacing_state", ""))).is_equal("opening_grace")
	assert_int(int(pacing.get("opening_grace_total_frames", 0))).is_equal(
		TAILRACE_COIL_RAT_OPENING_GRACE_FRAMES
	)
	assert_int(int(pacing.get("opening_grace_frames", 0))).is_equal(
		TAILRACE_COIL_RAT_OPENING_GRACE_FRAMES
	)
	assert_bool(bool(pacing.get("active", false))).is_true()


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
