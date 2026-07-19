## Player Abilities Story 011: Old Factory deep guard activation pacing.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_ENTRY_GUARD_NAME: String = "FactoryRatMinion"
const FACTORY_DEEP_GUARD_NAME: String = "FactoryDeepGuardRatMinion"
const FACTORY_DEEP_ENDPOINT_NAME: String = "FactoryDeepRouteEndpoint"

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


func test_deep_guard_stays_idle_until_player_reaches_route_pressure_point() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("is_factory_deep_guard_activated")).is_true()
	assert_bool(destination.has_method("try_activate_factory_deep_guard")).is_true()
	assert_bool(destination.has_method("get_factory_deep_route_diagnostics")).is_true()

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var guard: Node = destination.get_node_or_null(FACTORY_DEEP_GUARD_NAME)
	var endpoint: Node = destination.get_node_or_null(FACTORY_DEEP_ENDPOINT_NAME)
	assert_that(player).is_not_null()
	assert_that(guard).is_not_null()
	assert_that(endpoint).is_not_null()
	if player == null or guard == null or endpoint == null:
		return

	var diagnostics: Dictionary = destination.call("get_factory_deep_route_diagnostics")
	assert_bool(diagnostics.has("deep_guard_activated")).is_true()
	assert_bool(diagnostics.has("deep_guard_activation_x")).is_true()
	assert_bool(diagnostics.has("deep_guard_has_target")).is_true()
	assert_bool(diagnostics.has("deep_guard_physics_enabled")).is_true()
	assert_bool(diagnostics.has("deep_guard_process_enabled")).is_true()
	assert_bool(bool(diagnostics.get("deep_guard_activated", true))).is_false()
	assert_bool(bool(diagnostics.get("deep_guard_has_target", true))).is_false()
	assert_bool(bool(diagnostics.get("deep_guard_physics_enabled", true))).is_false()
	assert_bool(bool(diagnostics.get("deep_guard_process_enabled", true))).is_false()
	assert_bool(bool(endpoint.call("is_available"))).is_false()

	player.global_position.x = float(diagnostics.get("deep_guard_activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call("try_activate_factory_deep_guard", player))).is_false()
	assert_bool(bool(destination.call("is_factory_deep_guard_activated"))).is_false()

	player.global_position.x = float(diagnostics.get("deep_guard_activation_x", 0.0)) - 24.0
	await _defeat_guard(destination, FACTORY_ENTRY_GUARD_NAME, &"unit_test_entry_clear")
	assert_bool(bool(destination.call("try_activate_factory_deep_guard", player))).is_false()
	assert_bool(bool(destination.call("is_factory_deep_guard_activated"))).is_false()


func test_deep_guard_activates_once_after_player_crosses_pressure_point() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	await _defeat_guard(destination, FACTORY_ENTRY_GUARD_NAME, &"unit_test_entry_clear")
	var diagnostics: Dictionary = destination.call("get_factory_deep_route_diagnostics")
	player.global_position.x = float(diagnostics.get("deep_guard_activation_x", 0.0)) + 8.0

	assert_bool(bool(destination.call("try_activate_factory_deep_guard", player))).is_true()
	assert_bool(bool(destination.call("try_activate_factory_deep_guard", player))).is_false()
	assert_bool(bool(destination.call("is_factory_deep_guard_activated"))).is_true()

	var activated_diagnostics: Dictionary = destination.call("get_factory_deep_route_diagnostics")
	assert_bool(bool(activated_diagnostics.get("deep_guard_activated", false))).is_true()
	assert_bool(bool(activated_diagnostics.get("deep_guard_has_target", false))).is_true()
	assert_bool(bool(activated_diagnostics.get("deep_guard_physics_enabled", false))).is_true()
	assert_bool(bool(activated_diagnostics.get("deep_guard_process_enabled", false))).is_true()
	assert_bool(bool(activated_diagnostics.get("endpoint_available", true))).is_false()
	assert_bool(bool(activated_diagnostics.get("deep_guard_defeated", true))).is_false()


func test_deep_guard_activation_restores_without_unlocking_endpoint() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	destination.call("set_local_state", {
		"encounter_cleared": true,
		"factory_deep_guard_activated": true,
		"factory_deep_guard_defeated": false,
		"factory_deep_route_cleared": false,
	})

	var diagnostics: Dictionary = destination.call("get_factory_deep_route_diagnostics")
	assert_bool(bool(destination.call("is_factory_deep_guard_activated"))).is_true()
	assert_bool(bool(destination.call("is_factory_deep_route_cleared"))).is_false()
	assert_bool(bool(diagnostics.get("deep_guard_activated", false))).is_true()
	assert_bool(bool(diagnostics.get("deep_guard_has_target", false))).is_true()
	assert_bool(bool(diagnostics.get("deep_guard_defeated", true))).is_false()
	assert_bool(bool(diagnostics.get("endpoint_available", true))).is_false()
	assert_bool(bool(diagnostics.get("endpoint_activated", true))).is_false()

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get("factory_deep_guard_activated", false))).is_true()
	assert_bool(bool(local_state.get("factory_deep_guard_defeated", true))).is_false()
	assert_bool(bool(local_state.get("factory_deep_route_cleared", true))).is_false()


func test_activated_guard_defeat_still_unlocks_deep_route_endpoint() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var guard: Node = destination.get_node_or_null(FACTORY_DEEP_GUARD_NAME)
	var endpoint: Node2D = destination.get_node_or_null(FACTORY_DEEP_ENDPOINT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(guard).is_not_null()
	assert_that(endpoint).is_not_null()
	if player == null or guard == null or endpoint == null:
		return

	await _defeat_guard(destination, FACTORY_ENTRY_GUARD_NAME, &"unit_test_entry_clear")
	var diagnostics: Dictionary = destination.call("get_factory_deep_route_diagnostics")
	player.global_position.x = float(diagnostics.get("deep_guard_activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call("try_activate_factory_deep_guard", player))).is_true()

	if guard.has_method("kill_summon"):
		guard.call("kill_summon", &"unit_test_deep_guard_pacing")
	else:
		guard.call("apply_damage", int(guard.call("get_current_hp")), {})
	await get_tree().process_frame

	player.global_position = endpoint.global_position
	assert_bool(bool(destination.call("try_activate_factory_deep_route_endpoint", player))).is_true()
	assert_bool(bool(destination.call("is_factory_deep_route_cleared"))).is_true()


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
