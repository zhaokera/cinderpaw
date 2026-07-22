## Story206: aftershock exhaust production traverse/pursuer handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const EXHAUST_VENT_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockExhaustVent"
)
const PURSUER_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockExhaustPursuerCoilRat"
)
const EXHAUST_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_exhaust"
)

var _spawned_nodes: Array[Node] = []


func before_test() -> void:
	_release_gameplay_actions()
	get_tree().paused = false


func after_test() -> void:
	_release_gameplay_actions()
	get_tree().paused = false
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_real_movement_crosses_production_exhaust_before_pursuer_handoff(
) -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	await _wait_process_frames(2)
	factory.call("set_local_state", _exhaust_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var vent := factory.get_node_or_null(EXHAUST_VENT_NODE) as Area2D
	var pursuer := factory.get_node_or_null(PURSUER_NODE) as CharacterBody2D
	assert_that(player).is_not_null()
	assert_that(vent).is_not_null()
	assert_that(pursuer).is_not_null()
	if player == null or vent == null or pursuer == null:
		return

	var pursuer_collision := pursuer.call("get_collision_component") as CollisionComponent
	assert_that(pursuer_collision).is_not_null()
	if pursuer_collision == null:
		return

	var waiting: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	player.global_position = Vector2(
		float(waiting.get("activation_x", 0.0)) - 4.0,
		482.0
	)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	assert_bool(bool(waiting.get("available", false))).is_true()
	assert_bool(bool(waiting.get("active", true))).is_false()
	assert_str(String(pursuer_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)

	var activation_start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(16):
		await get_tree().physics_frame
		waiting = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
		)
		if bool(waiting.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	assert_float(player.global_position.x).is_greater(activation_start_x)
	assert_bool(bool(waiting.get("active", false))).is_true()
	assert_str(String(waiting.get("phase", ""))).is_equal("grace")
	assert_bool(bool(waiting.get("hazard_contact_active", true))).is_false()
	assert_str(String(waiting.get("route_label_text", ""))).is_equal(
		"Cross Aftershock Exhaust"
	)

	var hp_before: int = player.get_current_hp()
	assert_bool(bool(factory.call(
		"apply_factory_steam_vent_contact",
		vent,
		player
	))).is_false()

	factory.call("_process", 0.32)
	var warning: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_str(String(warning.get("phase", ""))).is_equal("warning")
	assert_bool(bool(warning.get("hazard_contact_active", true))).is_false()
	assert_int(player.get_current_hp()).is_equal(hp_before)

	factory.call("_process", 0.36)
	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_str(String(active.get("phase", ""))).is_equal("active")
	assert_bool(bool(active.get("hazard_contact_active", false))).is_true()
	assert_bool(bool(factory.call(
		"apply_factory_steam_vent_contact",
		vent,
		player
	))).is_true()
	assert_int(player.get_current_hp()).is_equal(hp_before - 8)
	var last_damage: Dictionary = factory.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	assert_str(String(last_damage.get("source", ""))).is_equal(EXHAUST_HAZARD_ID)

	factory.call("_process", 0.45)
	var safe: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
	)
	assert_str(String(safe.get("phase", ""))).is_equal("safe")
	assert_bool(bool(safe.get("hazard_contact_active", true))).is_false()
	assert_bool(bool(factory.call(
		"apply_factory_steam_vent_contact",
		vent,
		player
	))).is_false()
	assert_int(player.get_current_hp()).is_equal(hp_before - 8)

	player.global_position.x = float(safe.get("exit_x", 0.0)) - 4.0
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	var exit_start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	var crossed: Dictionary = safe
	for _frame: int in range(16):
		await get_tree().physics_frame
		crossed = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_exhaust_diagnostics"
		)
		if bool(crossed.get("crossed", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	assert_float(player.global_position.x).is_greater(exit_start_x)
	assert_bool(bool(crossed.get("active", true))).is_false()
	assert_bool(bool(crossed.get("crossed", false))).is_true()
	assert_bool(bool(crossed.get("visible", true))).is_false()
	assert_bool(bool(crossed.get("hazard_contact_active", true))).is_false()
	assert_str(String(crossed.get("route_label_text", ""))).is_equal(
		"Forward Pressure Aftershock Exhaust Crossed"
	)

	var pursuer_waiting: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_diagnostics"
	)
	assert_bool(bool(pursuer_waiting.get("available", false))).is_true()
	assert_bool(bool(pursuer_waiting.get("active", true))).is_false()
	assert_bool(bool(pursuer_waiting.get("coil_visible", true))).is_false()
	assert_int(pursuer.call("get_current_hp")).is_equal(24)
	assert_str(String(pursuer_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)


func _instantiate_factory_scene() -> Node:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	return factory


func _exhaust_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_exit_relay_activated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_activated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_coil_pincer_cleared": true,
		"factory_lower_deck_forward_pressure_coil_aftershock_activated": true,
		"factory_lower_deck_forward_pressure_coil_aftershock_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_coil_aftershock_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_crossed": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_defeated": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
	}


func _wait_process_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().process_frame


func _release_gameplay_actions() -> void:
	Input.action_release(MOVE_RIGHT_ACTION)


func _stop_runtime_audio_players() -> void:
	for player: AudioStreamPlayer in _find_nodes_of_type(
		get_tree().root,
		AudioStreamPlayer
	):
		player.stop()
	for player_2d: AudioStreamPlayer2D in _find_nodes_of_type(
		get_tree().root,
		AudioStreamPlayer2D
	):
		player_2d.stop()


func _find_nodes_of_type(root: Node, expected_type: Variant) -> Array[Node]:
	var matches: Array[Node] = []
	if is_instance_of(root, expected_type):
		matches.append(root)
	for child: Node in root.get_children():
		matches.append_array(_find_nodes_of_type(child, expected_type))
	return matches
