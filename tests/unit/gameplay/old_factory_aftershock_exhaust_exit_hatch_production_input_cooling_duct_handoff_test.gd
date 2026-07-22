## Story211: production hatch input and fresh-movement cooling-duct handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const INTERACT_ACTION: StringName = &"interact"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const HATCH_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockExhaustExitHatch"
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


func test_real_interact_opens_once_then_fresh_move_starts_cooling_duct() -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.call("set_local_state", _hatch_ready_state())

	var player := factory.get_node_or_null("Player") as CharacterBody2D
	var hatch := factory.get_node_or_null(HATCH_NODE) as Node2D
	assert_that(player).is_not_null()
	assert_that(hatch).is_not_null()
	if player == null or hatch == null:
		return

	player.global_position = Vector2(3080.0, 456.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	var ready: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
	)
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("opened", true))).is_false()
	assert_bool(bool(ready.get("collision_blocking", false))).is_true()

	# A held input that starts outside the radius cannot open on approach.
	Input.action_press(INTERACT_ACTION)
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(18):
		await get_tree().physics_frame
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	var held_approach: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(3080.0)
	assert_bool(bool(held_approach.get("opened", true))).override_failure_message(
		"Holding interact before entering range must not open Story092"
	).is_false()

	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	Input.action_press(INTERACT_ACTION)
	factory.call("_process", 0.0)
	var opened: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
	)
	var duct: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	assert_bool(bool(opened.get("opened", false))).override_failure_message(
		"Story211 requires production Input.interact to open the Story092 hatch"
	).is_true()
	assert_bool(bool(opened.get("available", true))).is_false()
	assert_bool(bool(opened.get("collision_blocking", true))).is_false()
	assert_bool(bool(opened.get("interaction_monitoring", true))).is_false()
	assert_bool(bool(opened.get("interaction_monitorable", true))).is_false()
	assert_int(int(opened.get("unlock_feedback_spawn_count", 0))).is_equal(1)
	assert_bool(bool(duct.get("available", false))).is_true()
	assert_bool(bool(duct.get("visible", false))).is_true()
	assert_bool(bool(duct.get("active", true))).override_failure_message(
		"Opening Story092 must not activate Story093 in the same frame"
	).is_false()

	for _frame: int in range(3):
		factory.call("_process", 0.0)
	opened = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_diagnostics"
	)
	duct = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	assert_bool(bool(duct.get("active", true))).override_failure_message(
		"Stationary or held input frames must not auto-start Story093"
	).is_false()
	assert_int(int(opened.get("unlock_feedback_spawn_count", 0))).is_equal(1)

	Input.action_release(INTERACT_ACTION)
	factory.call("_process", 0.0)
	player.set_physics_process(false)
	player.global_position.x = float(duct.get("activation_x", 0.0)) + 4.0
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	duct = factory.call(
		"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
	)
	assert_bool(bool(duct.get("active", true))).override_failure_message(
		"A no-input teleport beyond x=3240 must not start Story093"
	).is_false()
	assert_bool(bool(duct.get("hazard_contact_active", true))).is_false()

	player.global_position = Vector2(
		float(duct.get("activation_x", 0.0)) - 4.0,
		456.0
	)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	player.set_physics_process(true)
	var start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(18):
		await get_tree().physics_frame
		duct = factory.call(
			"get_factory_lower_deck_forward_pressure_aftershock_cooling_duct_diagnostics"
		)
		if bool(duct.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO

	assert_float(player.global_position.x).is_greater(start_x)
	assert_bool(bool(duct.get("active", false))).override_failure_message(
		"Fresh production move_right must start Story093 after opening the hatch"
	).is_true()
	assert_bool(bool(duct.get("crossed", true))).is_false()
	assert_str(String(duct.get("phase", ""))).is_equal("grace")
	assert_str(String(duct.get("route_label_text", ""))).is_equal(
		"Cross Aftershock Cooling Duct"
	)
	assert_bool(bool(factory.call("get_local_state").get(
		"factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened",
		false
	))).is_true()


func _hatch_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened": false,
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_cooling_duct_crossed": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
	}


func _wait_process_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().process_frame


func _release_gameplay_actions() -> void:
	Input.action_release(INTERACT_ACTION)
	Input.action_release(MOVE_RIGHT_ACTION)


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
