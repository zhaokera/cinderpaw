## Player Abilities Story 012: Old Factory deep route unlock feedback.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_ENTRY_GUARD_NAME: String = "FactoryRatMinion"
const FACTORY_DEEP_GUARD_NAME: String = "FactoryDeepGuardRatMinion"
const FACTORY_DEEP_ENDPOINT_NAME: String = "FactoryDeepRouteEndpoint"
const EXPECTED_UNLOCK_VFX_TEXTURE: String = (
	"res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png"
)

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


func test_deep_route_endpoint_mounts_generated_unlock_vfx_texture() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var endpoint: Node = destination.get_node_or_null(FACTORY_DEEP_ENDPOINT_NAME)
	assert_that(endpoint).is_not_null()
	if endpoint == null:
		return

	assert_bool(FileAccess.file_exists(EXPECTED_UNLOCK_VFX_TEXTURE)).is_true()
	assert_bool(endpoint.has_method("get_unlock_vfx_texture_path")).is_true()
	assert_bool(endpoint.has_method("get_unlock_vfx_snapshot")).is_true()
	assert_str(String(endpoint.call("get_unlock_vfx_texture_path"))).is_equal(
		EXPECTED_UNLOCK_VFX_TEXTURE
	)

	var snapshot: Dictionary = endpoint.call("get_unlock_vfx_snapshot")
	assert_str(String(snapshot.get("texture_path", ""))).is_equal(EXPECTED_UNLOCK_VFX_TEXTURE)
	assert_int(int(snapshot.get("active_count", -1))).is_equal(0)
	assert_bool(_endpoint_has_visible_placeholder_feedback(endpoint)).is_false()


func test_endpoint_activation_spawns_one_generated_unlock_vfx() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var endpoint: Node2D = destination.get_node_or_null(FACTORY_DEEP_ENDPOINT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(endpoint).is_not_null()
	if player == null or endpoint == null:
		return

	await _open_deep_route_endpoint(destination, player, endpoint)
	var snapshot: Dictionary = endpoint.call("get_unlock_vfx_snapshot")
	assert_int(int(snapshot.get("active_count", 0))).is_equal(1)
	assert_str(String(snapshot.get("texture_path", ""))).is_equal(EXPECTED_UNLOCK_VFX_TEXTURE)
	assert_float(float(snapshot.get("duration_sec", 0.0))).is_greater(0.0)

	var last_spawn: Dictionary = Dictionary(snapshot.get("last_spawn", {}))
	assert_str(String(last_spawn.get("asset_source", ""))).is_equal("image_generation")
	assert_str(String(last_spawn.get("vfx_role", ""))).is_equal("deep_route_unlock")
	assert_str(String(last_spawn.get("texture_path", ""))).is_equal(EXPECTED_UNLOCK_VFX_TEXTURE)

	var diagnostics: Dictionary = destination.call("get_factory_deep_route_diagnostics")
	assert_str(String(diagnostics.get("unlock_feedback_texture_path", ""))).is_equal(
		EXPECTED_UNLOCK_VFX_TEXTURE
	)
	assert_bool(bool(diagnostics.get("unlock_feedback_active", false))).is_true()
	assert_bool(bool(diagnostics.get("unlock_feedback_played", false))).is_true()
	assert_int(int(diagnostics.get("unlock_feedback_spawn_count", 0))).is_equal(1)


func test_duplicate_endpoint_activation_does_not_spawn_extra_unlock_vfx() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var endpoint: Node2D = destination.get_node_or_null(FACTORY_DEEP_ENDPOINT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(endpoint).is_not_null()
	if player == null or endpoint == null:
		return

	await _open_deep_route_endpoint(destination, player, endpoint)
	assert_bool(bool(destination.call("try_activate_factory_deep_route_endpoint", player))).is_false()
	var snapshot: Dictionary = endpoint.call("get_unlock_vfx_snapshot")
	assert_int(int(snapshot.get("active_count", -1))).is_equal(1)


func test_unlock_vfx_expires_deterministically_after_lifetime() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var endpoint: Node2D = destination.get_node_or_null(FACTORY_DEEP_ENDPOINT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(endpoint).is_not_null()
	if player == null or endpoint == null:
		return

	await _open_deep_route_endpoint(destination, player, endpoint)
	var active_snapshot: Dictionary = endpoint.call("get_unlock_vfx_snapshot")
	assert_int(int(active_snapshot.get("active_count", 0))).is_equal(1)
	assert_bool(endpoint.has_method("advance_unlock_vfx_time")).is_true()

	endpoint.call("advance_unlock_vfx_time", float(active_snapshot.get("duration_sec", 0.0)) + 0.1)
	var expired_snapshot: Dictionary = endpoint.call("get_unlock_vfx_snapshot")
	assert_int(int(expired_snapshot.get("active_count", -1))).is_equal(0)


func test_restoring_cleared_deep_route_does_not_replay_unlock_vfx() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var endpoint: Node = destination.get_node_or_null(FACTORY_DEEP_ENDPOINT_NAME)
	assert_that(endpoint).is_not_null()
	if endpoint == null:
		return

	destination.call("set_local_state", {
		"encounter_cleared": true,
		"factory_deep_guard_activated": true,
		"factory_deep_guard_defeated": true,
		"factory_deep_route_cleared": true,
	})

	assert_bool(bool(destination.call("is_factory_deep_route_cleared"))).is_true()
	var diagnostics: Dictionary = destination.call("get_factory_deep_route_diagnostics")
	assert_bool(bool(diagnostics.get("endpoint_activated", false))).is_true()
	assert_bool(bool(diagnostics.get("unlock_feedback_active", true))).is_false()
	assert_bool(bool(diagnostics.get("unlock_feedback_played", true))).is_false()
	assert_int(int(diagnostics.get("unlock_feedback_spawn_count", -1))).is_equal(0)
	var snapshot: Dictionary = endpoint.call("get_unlock_vfx_snapshot")
	assert_int(int(snapshot.get("active_count", -1))).is_equal(0)


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


func _open_deep_route_endpoint(destination: Node, player: Node2D, endpoint: Node2D) -> void:
	await _defeat_guard(destination, FACTORY_ENTRY_GUARD_NAME, &"unit_test_entry_clear")
	var diagnostics: Dictionary = destination.call("get_factory_deep_route_diagnostics")
	player.global_position.x = float(diagnostics.get("deep_guard_activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call("try_activate_factory_deep_guard", player))).is_true()
	await _defeat_guard(destination, FACTORY_DEEP_GUARD_NAME, &"unit_test_deep_guard_feedback")
	player.global_position = endpoint.global_position
	assert_bool(bool(destination.call("try_activate_factory_deep_route_endpoint", player))).is_true()


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


func _endpoint_has_visible_placeholder_feedback(endpoint: Node) -> bool:
	for child: Node in endpoint.get_children():
		if child is ColorRect or child is Polygon2D:
			if child.visible:
				return true
	return false


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
