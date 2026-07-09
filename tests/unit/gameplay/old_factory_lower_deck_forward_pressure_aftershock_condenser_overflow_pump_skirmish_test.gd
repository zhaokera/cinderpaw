## Player Abilities Story 099: Old Factory aftershock condenser overflow pump skirmish.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const OVERFLOW_PUMP_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPump"
)
const OVERFLOW_PUMP_COIL_RAT_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpCoilRat"
)
const OVERFLOW_PUMP_ENTITY_ID: int = 2139
const OVERFLOW_PUMP_OPENING_GRACE_FRAMES: int = 10
const OVERFLOW_PUMP_TEXTURE: String = (
	"res://assets/environment/old_factory_aftershock_condenser_overflow_pump/"
	+ "env_old_factory_aftershock_condenser_overflow_pump_768.png"
)
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


func test_overflow_pump_requires_drip_vent_crossed_and_extends_playable_space(
) -> void:
	assert_bool(FileAccess.file_exists(OVERFLOW_PUMP_TEXTURE)).is_true()
	assert_bool(FileAccess.file_exists(COIL_RAT_SPRITE_FRAMES)).is_true()

	var locked_scene: Node = _factory_scene_with_overflow_pump_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("drip_vent_crossed", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("cleared", true))).is_false()
	assert_bool(bool(locked.get("prop_visible", true))).is_false()
	assert_bool(bool(locked.get("coil_visible", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump"
	))).is_false()

	var destination: Node = _factory_scene_with_overflow_pump_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("drip_vent_crossed", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("cleared", true))).is_false()
	assert_bool(bool(ready.get("prop_visible", false))).is_true()
	assert_bool(bool(ready.get("coil_visible", true))).is_false()
	assert_str(String(ready.get("node_name", ""))).is_equal(OVERFLOW_PUMP_NODE_NAME)
	assert_str(String(ready.get("coil_node_name", ""))).is_equal(
		OVERFLOW_PUMP_COIL_RAT_NODE_NAME
	)
	assert_str(String(ready.get("prop_texture_path", ""))).is_equal(OVERFLOW_PUMP_TEXTURE)
	assert_float(float(ready.get("ground_width", 0.0))).is_greater_equal(7040.0)
	assert_float(float(ready.get("right_wall_x", 0.0))).is_greater_equal(7020.0)
	assert_int(int(ready.get("camera_limit_right", 0))).is_greater_equal(7040)
	assert_float(float(ready.get("activation_x", 0.0))).is_greater(6400.0)
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Outlet Drip Vent Crossed"
	)

	player.global_position.x = float(ready.get("activation_x", 0.0)) - 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump",
		player
	))).is_false()
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump",
		player
	))).is_true()

	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("cleared", true))).is_false()
	assert_bool(bool(active.get("prop_visible", false))).is_true()
	assert_bool(bool(active.get("coil_visible", false))).is_true()
	assert_bool(bool(active.get("coil_has_target", false))).is_true()
	assert_bool(bool(active.get("coil_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("coil_process_enabled", false))).is_true()
	assert_int(int(active.get("coil_entity_id", 0))).is_equal(OVERFLOW_PUMP_ENTITY_ID)
	assert_str(String(active.get("coil_family_id", ""))).is_equal("factory_coil_rat")
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Clear Overflow Pump Skirmish"
	)
	_assert_coil_rat_frame_contract(active)
	_assert_overflow_pump_pacing_contract(active)


func test_overflow_pump_defeat_persists_without_replaying_condenser_chain() -> void:
	var destination: Node = _factory_scene_with_overflow_pump_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return
	assert_bool(destination.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics"
	)).is_true()
	assert_bool(destination.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump"
	)).is_true()
	if (
		not destination.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics"
		)
		or not destination.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump"
		)
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics"
	)
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump",
		player
	))).is_true()

	assert_bool(destination.call("apply_damage", OVERFLOW_PUMP_ENTITY_ID, 999, {
		"source": &"unit_test_aftershock_condenser_overflow_pump",
	})).is_true()
	await get_tree().process_frame

	var cleared: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics"
	)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("prop_visible", false))).is_true()
	assert_bool(bool(cleared.get("coil_visible", true))).is_false()
	assert_bool(bool(cleared.get("coil_physics_enabled", true))).is_false()
	assert_str(String(cleared.get("route_label_text", ""))).is_equal(
		"Overflow Pump Cleared"
	)
	assert_bool(bool(destination.call("is_factory_route_objective_complete"))).is_true()

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_cleared",
		false
	))).is_true()

	var restored: Node = _factory_scene_with_overflow_pump_state(true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	var restored_pump: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics"
	)
	assert_bool(bool(restored_pump.get("active", true))).is_false()
	assert_bool(bool(restored_pump.get("cleared", false))).is_true()
	assert_bool(bool(restored_pump.get("prop_visible", false))).is_true()
	assert_bool(bool(restored_pump.get("coil_visible", true))).is_false()
	assert_str(String(restored_pump.get("route_label_text", ""))).is_equal(
		"Overflow Pump Cleared"
	)
	var restored_drip_vent: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	assert_bool(bool(restored_drip_vent.get("crossed", false))).is_true()
	assert_bool(bool(restored_drip_vent.get("hazard_contact_active", true))).is_false()
	var restored_clamp: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_diagnostics"
	)
	assert_bool(bool(restored_clamp.get("cleared", false))).is_true()
	var savepoint: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_diagnostics"
	)
	assert_bool(bool(savepoint.get("activated", false))).is_true()
	var restored_lift: Dictionary = restored.call("get_factory_service_lift_diagnostics")
	assert_str(String(restored_lift.get("prompt_text", ""))).is_equal("Call lift")


func _factory_scene_with_overflow_pump_state(
		drip_vent_crossed: bool,
		overflow_pump_cleared: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _aftershock_condenser_base_state().merged({
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_activated": (
			drip_vent_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_crossed": (
			drip_vent_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated": (
			overflow_pump_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated": (
			overflow_pump_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_cleared": (
			overflow_pump_cleared
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


func _aftershock_condenser_base_state() -> Dictionary:
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
		"factory_lower_deck_post_relay_spark_rat_defeated": true,
		"factory_lower_deck_post_relay_trial_cleared": true,
		"factory_lower_deck_relay_forward_reward_cache_claimed": true,
		"factory_lower_deck_forward_hatch_opened": true,
		"factory_lower_deck_forward_conduit_activated": true,
		"factory_lower_deck_forward_conduit_spark_rat_defeated": true,
		"factory_lower_deck_forward_conduit_cleared": true,
		"factory_lower_deck_forward_pressure_activated": true,
		"factory_lower_deck_forward_pressure_crossed": true,
		"factory_lower_deck_forward_pressure_counter_ambush_activated": true,
		"factory_lower_deck_forward_pressure_counter_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_counter_ambush_cleared": true,
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
		"factory_lower_deck_forward_pressure_aftershock_exit_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exit_coil_rat_defeated": true,
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
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared": true,
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
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_cleared": true,
	}


func _assert_coil_rat_frame_contract(diagnostics: Dictionary) -> void:
	assert_str(String(diagnostics.get("coil_sprite_frames_path", ""))).is_equal(
		COIL_RAT_SPRITE_FRAMES
	)
	var counts: Dictionary = diagnostics.get("coil_animation_frame_counts", {}) as Dictionary
	for animation_name: StringName in REQUIRED_COIL_RAT_ANIMATIONS:
		assert_int(int(counts.get(animation_name, 0))).is_greater_equal(
			MIN_CHARACTER_ANIMATION_FRAMES
		)


func _assert_overflow_pump_pacing_contract(diagnostics: Dictionary) -> void:
	var pacing: Dictionary = diagnostics.get("pacing", {}) as Dictionary
	assert_int(int(pacing.get("opening_grace_total_frames", 0))).is_equal(
		OVERFLOW_PUMP_OPENING_GRACE_FRAMES
	)
	assert_int(int(pacing.get("opening_grace_frames", -1))).is_equal(
		OVERFLOW_PUMP_OPENING_GRACE_FRAMES
	)


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
