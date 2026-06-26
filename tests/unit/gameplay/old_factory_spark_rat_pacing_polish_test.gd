## Player Abilities Story 017: Old Factory spark rat pacing polish.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_ENTRY_GUARD_NAME: String = "FactoryRatMinion"
const FACTORY_DEEP_GUARD_NAME: String = "FactoryDeepGuardRatMinion"
const FACTORY_DEEP_ENDPOINT_NAME: String = "FactoryDeepRouteEndpoint"
const FACTORY_SPARK_RAT_NAME: String = "FactorySparkRat"
const FACTORY_SPARK_RAT_ENTITY_ID: int = 2102
const SPARK_RAT_BITE_DAMAGE: int = 9
const MIN_ATTACK_STARTUP_FRAMES: int = 12

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


func test_spark_rat_waits_for_pacing_trigger_after_endpoint_open() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	assert_bool(destination.has_method("advance_factory_spark_rat_pacing_frames")).is_true()

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	await _open_deep_route_endpoint(destination, player)
	var diagnostics: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	var activation_x: float = float(diagnostics.get("activation_x", -INF))
	assert_float(activation_x).is_greater(0.0)

	player.global_position.x = activation_x - 24.0
	assert_bool(bool(destination.call("try_activate_factory_spark_rat", player))).is_false()

	var blocked_diagnostics: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	assert_bool(bool(blocked_diagnostics.get("active", true))).is_false()
	assert_bool(bool(blocked_diagnostics.get("activation_ready", true))).is_false()
	assert_bool(bool(blocked_diagnostics.get("has_target", true))).is_false()
	assert_int(int(blocked_diagnostics.get("collision_layer", -1))).is_equal(0)
	assert_int(int(blocked_diagnostics.get("collision_mask", -1))).is_equal(0)


func test_spark_rat_activation_starts_with_opening_grace_before_first_bite() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	if not _assert_pacing_api(destination):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var spark_rat: Node2D = await _open_and_activate_spark_rat_at_melee_range(destination)
	assert_that(player).is_not_null()
	assert_that(spark_rat).is_not_null()
	if player == null or spark_rat == null:
		return

	var diagnostics: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	var pacing: Dictionary = Dictionary(diagnostics.get("pacing", {}))
	var opening_grace_frames: int = int(pacing.get("opening_grace_frames", 0))
	assert_bool(bool(diagnostics.get("active", false))).is_true()
	assert_bool(bool(diagnostics.get("activation_ready", false))).is_true()
	assert_bool(bool(diagnostics.get("has_target", false))).is_true()
	assert_int(opening_grace_frames).is_greater_equal(1)
	assert_str(String(pacing.get("pacing_state", ""))).is_equal("opening_grace")
	assert_int(int(pacing.get("attack_sequence_id", -1))).is_equal(0)

	destination.call("advance_factory_spark_rat_pacing_frames", opening_grace_frames - 1)
	var grace_diagnostics: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	var grace_pacing: Dictionary = Dictionary(grace_diagnostics.get("pacing", {}))
	assert_str(String(grace_pacing.get("pacing_state", ""))).is_equal("opening_grace")
	assert_int(int(grace_pacing.get("attack_sequence_id", -1))).is_equal(0)
	assert_bool(bool(grace_pacing.get("attack_active", true))).is_false()

	destination.call("advance_factory_spark_rat_pacing_frames", 2)
	var tell_diagnostics: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	var tell_pacing: Dictionary = Dictionary(tell_diagnostics.get("pacing", {}))
	assert_str(String(tell_pacing.get("pacing_state", ""))).is_equal("attack_tell")
	assert_str(String(tell_pacing.get("current_animation", ""))).is_equal("attack_tell")
	assert_int(int(tell_pacing.get("attack_sequence_id", 0))).is_equal(1)
	assert_bool(bool(tell_pacing.get("attack_active", true))).is_false()


func test_spark_rat_patrols_until_player_enters_alert_radius() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	if not _assert_pacing_api(destination):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var spark_rat: Node2D = await _open_and_activate_spark_rat_with_player_offset(
		destination,
		Vector2(-320.0, 0.0)
	)
	assert_that(player).is_not_null()
	assert_that(spark_rat).is_not_null()
	if player == null or spark_rat == null:
		return

	var start_x: float = spark_rat.global_position.x
	var diagnostics: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	var pacing: Dictionary = Dictionary(diagnostics.get("pacing", {}))
	var opening_grace_frames: int = int(pacing.get("opening_grace_frames", 0))
	destination.call("advance_factory_spark_rat_pacing_frames", opening_grace_frames + 8)

	var patrol_diagnostics: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	var patrol_pacing: Dictionary = Dictionary(patrol_diagnostics.get("pacing", {}))
	assert_str(String(patrol_pacing.get("pacing_state", ""))).is_equal("patrol")
	assert_str(String(patrol_pacing.get("current_animation", ""))).is_equal("run")
	assert_int(int(patrol_pacing.get("attack_sequence_id", -1))).is_equal(0)
	assert_bool(bool(patrol_pacing.get("target_in_alert_radius", true))).is_false()
	var patrol_left_x: float = float(patrol_pacing.get("patrol_left_x", start_x))
	var patrol_right_x: float = float(patrol_pacing.get("patrol_right_x", start_x))
	assert_bool(not is_equal_approx(spark_rat.global_position.x, start_x)).is_true()
	assert_bool(
		spark_rat.global_position.x >= patrol_left_x
		and spark_rat.global_position.x <= patrol_right_x
	).is_true()

	player.global_position = spark_rat.global_position + Vector2(-120.0, 0.0)
	destination.call("advance_factory_spark_rat_pacing_frames", 1)
	var chase_diagnostics: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	var chase_pacing: Dictionary = Dictionary(chase_diagnostics.get("pacing", {}))
	assert_bool(bool(chase_pacing.get("target_in_alert_radius", false))).is_true()
	assert_str(String(chase_pacing.get("pacing_state", ""))).is_equal("chase")
	assert_bool(bool(chase_pacing.get("attack_active", true))).is_false()


func test_spark_rat_first_bite_respects_extended_attack_tell_before_damage() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	if not _assert_pacing_api(destination):
		return

	var player: Node = destination.get_node_or_null(FACTORY_PLAYER_NAME)
	var spark_rat: Node = await _open_and_activate_spark_rat_at_melee_range(destination)
	assert_that(player).is_not_null()
	assert_that(spark_rat).is_not_null()
	if player == null or spark_rat == null:
		return

	var startup_frames: int = int(spark_rat.call("get_attack_startup_frames"))
	assert_int(startup_frames).is_greater_equal(MIN_ATTACK_STARTUP_FRAMES)
	assert_bool(bool(spark_rat.call("request_attack"))).is_true()
	spark_rat.call("advance_attack_frames", startup_frames - 1)

	var hp_before: int = int(player.call("get_current_hp"))
	var tell_result: Dictionary = destination.call("resolve_factory_spark_rat_bite_against_player")
	assert_bool(bool(tell_result.get("resolved", true))).is_false()
	assert_bool(bool(tell_result.get("damage_applied", true))).is_false()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before)

	spark_rat.call("advance_attack_frames", 1)
	var active_result: Dictionary = destination.call("resolve_factory_spark_rat_bite_against_player")
	assert_bool(bool(active_result.get("resolved", false))).is_true()
	assert_bool(bool(active_result.get("damage_applied", false))).is_true()
	assert_int(int(active_result.get("damage", 0))).is_equal(SPARK_RAT_BITE_DAMAGE)
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - SPARK_RAT_BITE_DAMAGE)


func test_spark_rat_pacing_state_restores_without_replaying_bite_state() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return
	if not _assert_pacing_api(destination):
		return

	destination.call("set_local_state", {
		"encounter_cleared": true,
		"factory_deep_guard_activated": true,
		"factory_deep_guard_defeated": true,
		"factory_deep_route_cleared": true,
		"factory_spark_rat_activated": true,
		"factory_spark_rat_defeated": false,
		"factory_spark_rat_opening_grace_frames": 6,
	})

	var diagnostics: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	var pacing: Dictionary = Dictionary(diagnostics.get("pacing", {}))
	var counter: Dictionary = Dictionary(diagnostics.get("counter", {}))
	assert_bool(bool(diagnostics.get("active", false))).is_true()
	assert_bool(bool(diagnostics.get("has_target", false))).is_true()
	assert_str(String(pacing.get("pacing_state", ""))).is_equal("opening_grace")
	assert_int(int(pacing.get("opening_grace_frames", 0))).is_equal(6)
	assert_int(int(pacing.get("attack_sequence_id", -1))).is_equal(0)
	assert_bool(bool(counter.get("last_bite_resolved", true))).is_false()


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


func _assert_pacing_api(destination: Node) -> bool:
	var has_advance: bool = destination.has_method("advance_factory_spark_rat_pacing_frames")
	assert_bool(has_advance).is_true()
	var diagnostics: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	var pacing: Variant = diagnostics.get("pacing", null)
	assert_bool(pacing is Dictionary).is_true()
	return has_advance and pacing is Dictionary


func _open_and_activate_spark_rat_at_melee_range(destination: Node) -> Node2D:
	return await _open_and_activate_spark_rat_with_player_offset(destination, Vector2(-32.0, 0.0))


func _open_and_activate_spark_rat_with_player_offset(
	destination: Node,
	player_offset_from_spark_rat: Vector2
) -> Node2D:
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return null

	await _open_deep_route_endpoint(destination, player)
	var spark_rat: Node2D = destination.get_node_or_null(FACTORY_SPARK_RAT_NAME) as Node2D
	assert_that(spark_rat).is_not_null()
	if spark_rat == null:
		return null
	var diagnostics: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	var activation_x: float = float(diagnostics.get("activation_x", spark_rat.global_position.x))
	var activation_position: Vector2 = spark_rat.global_position + Vector2(-32.0, 0.0)
	activation_position.x = maxf(activation_position.x, activation_x + 8.0)
	player.global_position = activation_position
	assert_bool(bool(destination.call("try_activate_factory_spark_rat", player))).is_true()
	await get_tree().process_frame
	player.global_position = spark_rat.global_position + player_offset_from_spark_rat
	return spark_rat


func _open_deep_route_endpoint(destination: Node, player: Node2D) -> void:
	await _defeat_guard(destination, FACTORY_ENTRY_GUARD_NAME, &"unit_test_entry_clear")
	var route_diagnostics: Dictionary = destination.call("get_factory_deep_route_diagnostics")
	player.global_position.x = float(route_diagnostics.get("deep_guard_activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call("try_activate_factory_deep_guard", player))).is_true()
	await _defeat_guard(destination, FACTORY_DEEP_GUARD_NAME, &"unit_test_deep_guard_clear")
	var endpoint: Node2D = destination.get_node_or_null(FACTORY_DEEP_ENDPOINT_NAME) as Node2D
	assert_that(endpoint).is_not_null()
	if endpoint == null:
		return
	player.global_position = endpoint.global_position
	assert_bool(bool(destination.call("try_activate_factory_deep_route_endpoint", player))).is_true()
	await get_tree().process_frame


func _defeat_guard(root: Node, guard_name: String, reason: StringName) -> void:
	var guard: Node = root.get_node_or_null(guard_name)
	assert_that(guard).is_not_null()
	if guard == null:
		return
	if guard.has_method("kill_summon"):
		guard.call("kill_summon", reason)
	else:
		guard.call("apply_damage", int(guard.call("get_current_hp")), {})
	await get_tree().process_frame


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var audio_player := child as AudioStreamPlayer
			audio_player.stop()
			audio_player.stream = null
		if child is AudioStreamPlayer2D:
			var spatial_player := child as AudioStreamPlayer2D
			spatial_player.stop()
			spatial_player.stream = null
