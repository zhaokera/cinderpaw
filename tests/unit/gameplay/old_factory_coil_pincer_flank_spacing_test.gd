## Player Abilities Story203: Coil Pincer starts and stays readable from both flanks.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const EXPECTED_SPARK_GRACE_FRAMES: int = 10
const EXPECTED_COIL_GRACE_FRAMES: int = 26
const MIN_SIDE_CLEARANCE_PX: float = 48.0
const MIN_CENTER_SEPARATION_PX: float = 130.0
const POST_GRACE_PROBE_FRAMES: int = 20

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


func test_real_forward_entry_stages_pincer_on_opposite_player_flanks() -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	await _wait_process_frames(18)

	var player := factory.get_node_or_null("Player") as PlayerController
	assert_that(player).is_not_null()
	if player == null:
		return
	var ready: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	var activation_x: float = float(ready.get("activation_x", 0.0))
	player.global_position.x = activation_x - 12.0
	player.velocity = Vector2.ZERO
	factory.call("set_local_state", {
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_activated": true,
		"factory_lower_deck_forward_pressure_coil_rat_breakthrough_defeated": true,
	})
	await _wait_process_frames(2)

	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(18):
		await get_tree().physics_frame
		var probe: Dictionary = factory.call(
			"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
		)
		if bool(probe.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO

	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).override_failure_message(
		"Story203 requires production move_right to start the Coil Pincer"
	).is_true()
	if not bool(active.get("active", false)):
		return
	var spark_position: Vector2 = active.get("spark_position", Vector2.ZERO)
	var coil_position: Vector2 = active.get("coil_position", Vector2.ZERO)
	assert_float(spark_position.x).override_failure_message(
		"Short-grace Spark Rat must stage on Cinderpaw's forward/right flank"
	).is_greater(player.global_position.x)
	assert_float(coil_position.x).override_failure_message(
		"Delayed Coil Rat must stage on Cinderpaw's rear/left flank"
	).is_less(player.global_position.x)
	_assert_two_sided_spacing(player.global_position.x, spark_position.x, coil_position.x)
	_assert_opening_grace(active)

	await _wait_until_opening_grace_complete(factory, 40)
	await _wait_physics_frames(POST_GRACE_PROBE_FRAMES)
	var engaged: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
	)
	spark_position = engaged.get("spark_position", Vector2.ZERO)
	coil_position = engaged.get("coil_position", Vector2.ZERO)
	assert_bool(bool(engaged.get("spark_visible", false))).is_true()
	assert_bool(bool(engaged.get("coil_visible", false))).is_true()
	assert_float(spark_position.x).is_greater(player.global_position.x)
	assert_float(coil_position.x).is_less(player.global_position.x)
	_assert_two_sided_spacing(player.global_position.x, spark_position.x, coil_position.x)


func _assert_opening_grace(diagnostics: Dictionary) -> void:
	var pacing: Dictionary = diagnostics.get("pacing", {})
	var spark: Dictionary = pacing.get("spark", {})
	var coil: Dictionary = pacing.get("coil", {})
	assert_int(int(spark.get("opening_grace_total_frames", 0))).is_equal(
		EXPECTED_SPARK_GRACE_FRAMES
	)
	assert_int(int(coil.get("opening_grace_total_frames", 0))).is_equal(
		EXPECTED_COIL_GRACE_FRAMES
	)
	assert_bool(bool(spark.get("target_in_alert_radius", false))).override_failure_message(
		"Front Spark Rat must be close enough to pressure after opening grace"
	).is_true()
	assert_bool(bool(coil.get("target_in_alert_radius", false))).override_failure_message(
		"Rear Coil Rat must remain inside its 180px alert radius after activation"
	).is_true()


func _assert_two_sided_spacing(player_x: float, spark_x: float, coil_x: float) -> void:
	var left_enemy_x: float = minf(spark_x, coil_x)
	var right_enemy_x: float = maxf(spark_x, coil_x)
	assert_float(player_x - left_enemy_x).override_failure_message(
		"Natural Coil Pincer must keep one readable enemy flank left of Cinderpaw"
	).is_greater_equal(MIN_SIDE_CLEARANCE_PX)
	assert_float(right_enemy_x - player_x).override_failure_message(
		"Natural Coil Pincer must keep one readable enemy flank right of Cinderpaw"
	).is_greater_equal(MIN_SIDE_CLEARANCE_PX)
	assert_float(right_enemy_x - left_enemy_x).override_failure_message(
		"Scaled Spark/Coil Rat silhouettes must remain independently readable"
	).is_greater_equal(MIN_CENTER_SEPARATION_PX)


func _wait_until_opening_grace_complete(factory: Node, max_frames: int) -> void:
	for _frame: int in range(max_frames):
		var diagnostics: Dictionary = factory.call(
			"get_factory_lower_deck_forward_pressure_coil_pincer_diagnostics"
		)
		var pacing: Dictionary = diagnostics.get("pacing", {})
		var spark: Dictionary = pacing.get("spark", {})
		var coil: Dictionary = pacing.get("coil", {})
		if (
			int(spark.get("opening_grace_frames", 1)) <= 0
			and int(coil.get("opening_grace_frames", 1)) <= 0
		):
			return
		await get_tree().physics_frame


func _instantiate_factory_scene() -> Node:
	assert_bool(FileAccess.file_exists(FACTORY_SCENE_PATH)).is_true()
	var packed := load(FACTORY_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var factory: Node = packed.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	return factory


func _wait_physics_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().physics_frame


func _wait_process_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().process_frame


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
