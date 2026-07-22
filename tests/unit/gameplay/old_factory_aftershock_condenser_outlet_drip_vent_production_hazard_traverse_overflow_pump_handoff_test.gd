## Story218: production drip vent traversal and overflow pump handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const DRIP_VENT_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent"
)
const DRIP_VENT_HAZARD: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOutletDripVentHazard"
)
const OVERFLOW_PUMP: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPump"
)
const OVERFLOW_PUMP_COIL: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpCoilRat"
)
const OVERFLOW_PUMP_ENTITY_ID: int = 2139
const OVERFLOW_PUMP_OPENING_GRACE_FRAMES: int = 10

var _spawned_nodes: Array[Node] = []


func before_test() -> void:
	Input.action_release(MOVE_RIGHT_ACTION)
	get_tree().paused = false


func after_test() -> void:
	Input.action_release(MOVE_RIGHT_ACTION)
	get_tree().paused = false
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_real_traverse_takes_one_steam_hit_then_requires_fresh_combat_entry() -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.set_process(false)
	factory.call("set_local_state", _drip_vent_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var vent := factory.get_node_or_null(DRIP_VENT_HAZARD) as Area2D
	var pump := factory.get_node_or_null(OVERFLOW_PUMP) as Sprite2D
	var coil := factory.get_node_or_null(OVERFLOW_PUMP_COIL) as CharacterBody2D
	assert_that(player).is_not_null()
	assert_that(vent).is_not_null()
	assert_that(pump).is_not_null()
	assert_that(coil).is_not_null()
	if player == null or vent == null or pump == null or coil == null:
		return
	var coil_collision := coil.call("get_collision_component") as CollisionComponent
	assert_that(coil_collision).is_not_null()
	if coil_collision == null:
		return

	var ready: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	var activation_x: float = float(ready.get("activation_x", 0.0))
	player.global_position = Vector2(activation_x - 12.0, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)

	player.global_position.x = activation_x + 4.0
	factory.call("_process", 0.0)
	var stationary_threshold: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	assert_bool(bool(stationary_threshold.get("active", true))).override_failure_message(
		"Story098 production activation must reject threshold displacement without move_right"
	).is_false()

	player.global_position.x = activation_x - 12.0
	factory.call("_process", 0.0)
	var start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(24):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
		ready = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
		)
		if bool(ready.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	assert_float(player.global_position.x).is_greater(start_x)
	assert_bool(bool(ready.get("active", false))).override_failure_message(
		"Story218 requires production move_right to activate Story098"
	).is_true()
	assert_str(String(ready.get("phase", ""))).is_equal("grace")
	assert_bool(bool(ready.get("hazard_contact_active", true))).is_false()

	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(90):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
		if player.global_position.x >= vent.global_position.x:
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	assert_float(player.global_position.x).override_failure_message(
		"Story218 requires real movement into the outlet drip vent overlap"
	).is_greater_equal(vent.global_position.x)

	var hp_before: int = int(player.call("get_current_hp"))
	factory.call("_process", 0.26)
	var warning: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	assert_str(String(warning.get("phase", ""))).is_equal("warning")
	assert_bool(bool(warning.get("hazard_contact_active", true))).is_false()
	factory.call("_process", 0.36)
	var pressure: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	assert_str(String(pressure.get("phase", ""))).is_equal("active")
	assert_bool(bool(pressure.get("hazard_contact_active", false))).is_true()
	await _wait_physics_frames(2)
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - 8)
	var last_damage: Dictionary = factory.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	assert_str(String(last_damage.get("source", ""))).is_equal(DRIP_VENT_HAZARD_ID)
	factory.call("_process", 0.41)
	var safe: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
	)
	assert_str(String(safe.get("phase", ""))).is_equal("safe")
	assert_bool(bool(safe.get("hazard_contact_active", true))).is_false()
	await _wait_physics_frames(2)
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - 8)

	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(180):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
		safe = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_diagnostics"
		)
		if bool(safe.get("crossed", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	assert_bool(bool(safe.get("crossed", false))).override_failure_message(
		"Story218 requires real movement to cross the Story098 exit"
	).is_true()
	assert_bool(bool(safe.get("active", true))).is_false()
	assert_bool(bool(safe.get("hazard_contact_active", true))).is_false()
	assert_str(String(safe.get("route_label_text", ""))).is_equal(
		"Outlet Drip Vent Crossed"
	)

	var pump_ready: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics"
	)
	assert_bool(bool(pump_ready.get("available", false))).is_true()
	assert_bool(bool(pump_ready.get("active", true))).is_false()
	assert_bool(bool(pump_ready.get("prop_visible", false))).is_true()
	assert_bool(bool(pump_ready.get("coil_visible", true))).is_false()
	assert_bool(bool(pump_ready.get("coil_has_target", true))).is_false()
	assert_bool(bool(pump_ready.get("coil_process_enabled", true))).is_false()
	assert_bool(bool(pump_ready.get("coil_physics_enabled", true))).is_false()
	assert_int(int(coil.call("get_current_hp"))).is_equal(24)
	assert_str(String(coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)

	player.global_position.x = float(pump_ready.get("activation_x", 0.0)) + 4.0
	factory.call("_process", 0.0)
	pump_ready = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics"
	)
	var activated_without_input: bool = bool(pump_ready.get("active", true))
	assert_bool(activated_without_input).override_failure_message(
		"Story099 production activation must reject threshold displacement without move_right"
	).is_false()
	if activated_without_input:
		return

	Input.action_press(MOVE_RIGHT_ACTION)
	player.global_position.x += 4.0
	factory.call("_process", 0.0)
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	var pump_active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_diagnostics"
	)
	assert_bool(bool(pump_active.get("active", false))).override_failure_message(
		"Story099 must accept a later fresh positive movement frame"
	).is_true()
	assert_bool(bool(pump_active.get("coil_visible", false))).is_true()
	assert_bool(bool(pump_active.get("coil_has_target", false))).is_true()
	assert_bool(bool(pump_active.get("coil_process_enabled", false))).is_true()
	assert_bool(bool(pump_active.get("coil_physics_enabled", false))).is_true()
	assert_int(coil.z_index).override_failure_message(
		"Story099 Coil Rat must render in front of the overlapping overflow pump"
	).is_greater(pump.z_index)
	assert_int(int(pump_active.get("coil_entity_id", 0))).is_equal(
		OVERFLOW_PUMP_ENTITY_ID
	)
	assert_int(int(coil.call("get_current_hp"))).is_equal(24)
	assert_str(String(coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_NORMAL)
	)
	var pacing: Dictionary = pump_active.get("pacing", {}) as Dictionary
	assert_int(int(pacing.get("opening_grace_frames", 0))).is_equal(
		OVERFLOW_PUMP_OPENING_GRACE_FRAMES
	)
	assert_str(String(pump_active.get("route_label_text", ""))).is_equal(
		"Clear Overflow Pump Skirmish"
	)


func _drip_vent_ready_state() -> Dictionary:
	return {
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
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_crossed": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_coil_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_cleared": false,
	}


func _wait_process_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().process_frame


func _wait_physics_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().physics_frame


func _stop_runtime_audio_players() -> void:
	for audio_player: AudioStreamPlayer in _find_nodes_of_type(
		get_tree().root,
		AudioStreamPlayer
	):
		audio_player.stop()
	for audio_player_2d: AudioStreamPlayer2D in _find_nodes_of_type(
		get_tree().root,
		AudioStreamPlayer2D
	):
		audio_player_2d.stop()


func _find_nodes_of_type(root: Node, expected_type: Variant) -> Array[Node]:
	var matches: Array[Node] = []
	if is_instance_of(root, expected_type):
		matches.append(root)
	for child: Node in root.get_children():
		matches.append_array(_find_nodes_of_type(child, expected_type))
	return matches
