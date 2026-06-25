## Player Abilities Story 010: Old Factory deep route micro-slice contract.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_DEEP_GUARD_NAME: String = "FactoryDeepGuardRatMinion"
const FACTORY_DEEP_ENDPOINT_NAME: String = "FactoryDeepRouteEndpoint"
const FACTORY_DEEP_ENDPOINT_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_deep_route/factory_deep_route_endpoint.png"
)
const FACTORY_DEEP_GUARD_ENTITY_ID: int = 2101
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


func test_factory_room_contains_generated_deep_route_endpoint_without_placeholder_art() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_str(String(destination.get_meta("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_bool(FileAccess.file_exists(FACTORY_DEEP_ENDPOINT_TEXTURE_PATH)).is_true()
	assert_bool(_has_visible_placeholder_shape(destination)).is_false()

	var endpoint: Node2D = destination.get_node_or_null(FACTORY_DEEP_ENDPOINT_NAME) as Node2D
	assert_that(endpoint).is_not_null()
	if endpoint == null:
		return
	assert_bool(endpoint.visible).is_true()
	assert_bool(endpoint.has_method("get_endpoint_id")).is_true()
	assert_bool(endpoint.has_method("get_visual_texture_path")).is_true()
	assert_bool(endpoint.has_method("is_available")).is_true()
	assert_bool(endpoint.has_method("is_activated")).is_true()
	assert_str(String(endpoint.call("get_endpoint_id"))).is_equal("old_factory_deep_route_endpoint")
	assert_str(String(endpoint.call("get_visual_texture_path"))).is_equal(
		FACTORY_DEEP_ENDPOINT_TEXTURE_PATH
	)
	assert_bool(bool(endpoint.call("is_available"))).is_false()
	assert_bool(bool(endpoint.call("is_activated"))).is_false()


func test_factory_deep_route_uses_second_animated_rat_guard() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var guard: Node = destination.get_node_or_null(FACTORY_DEEP_GUARD_NAME)
	assert_that(guard).is_not_null()
	if guard == null:
		return
	assert_bool(guard.visible).is_true()
	assert_bool(guard.has_method("get_entity_id")).is_true()
	assert_int(int(guard.call("get_entity_id"))).is_equal(FACTORY_DEEP_GUARD_ENTITY_ID)
	_assert_character_animation_contract(destination, FACTORY_DEEP_GUARD_NAME, [
		&"idle",
		&"run",
		&"attack",
		&"hurt",
		&"death",
	])


func test_deep_route_unlocks_after_second_guard_defeat_and_endpoint_activates_once() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("is_factory_deep_route_cleared")).is_true()
	assert_bool(destination.has_method("try_activate_factory_deep_route_endpoint")).is_true()
	assert_bool(destination.has_method("get_factory_deep_route_diagnostics")).is_true()
	assert_bool(bool(destination.call("is_factory_deep_route_cleared"))).is_false()

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var guard: Node = destination.get_node_or_null(FACTORY_DEEP_GUARD_NAME)
	var endpoint: Node2D = destination.get_node_or_null(FACTORY_DEEP_ENDPOINT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(guard).is_not_null()
	assert_that(endpoint).is_not_null()
	if player == null or guard == null or endpoint == null:
		return

	player.global_position = endpoint.global_position
	assert_bool(bool(destination.call("try_activate_factory_deep_route_endpoint", player))).is_false()
	if guard.has_method("kill_summon"):
		guard.call("kill_summon", &"unit_test_deep_route")
	else:
		guard.call("apply_damage", int(guard.call("get_current_hp")), {})
	await get_tree().process_frame

	assert_bool(bool(destination.call("try_activate_factory_deep_route_endpoint", player))).is_true()
	assert_bool(bool(destination.call("try_activate_factory_deep_route_endpoint", player))).is_false()
	assert_bool(bool(destination.call("is_factory_deep_route_cleared"))).is_true()

	var diagnostics: Dictionary = destination.call("get_factory_deep_route_diagnostics")
	assert_bool(bool(diagnostics.get("deep_guard_defeated", false))).is_true()
	assert_bool(bool(diagnostics.get("deep_route_cleared", false))).is_true()
	assert_str(String(diagnostics.get("endpoint_texture_path", ""))).is_equal(
		FACTORY_DEEP_ENDPOINT_TEXTURE_PATH
	)


func test_deep_route_state_restores_guard_and_endpoint_progress() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("set_local_state")).is_true()
	assert_bool(destination.has_method("get_local_state")).is_true()
	destination.call("set_local_state", {
		"factory_deep_guard_defeated": true,
		"factory_deep_route_cleared": true,
	})

	var endpoint: Node = destination.get_node_or_null(FACTORY_DEEP_ENDPOINT_NAME)
	var guard: Node = destination.get_node_or_null(FACTORY_DEEP_GUARD_NAME)
	assert_that(endpoint).is_not_null()
	assert_that(guard).is_not_null()
	if endpoint == null or guard == null:
		return
	assert_bool(bool(destination.call("is_factory_deep_route_cleared"))).is_true()
	assert_bool(bool(endpoint.call("is_activated"))).is_true()
	assert_bool(guard.visible).is_false()

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get("factory_deep_guard_defeated", false))).is_true()
	assert_bool(bool(local_state.get("factory_deep_route_cleared", false))).is_true()


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


func _assert_character_animation_contract(
	root: Node,
	character_name: String,
	required_animations: Array[StringName]
) -> void:
	var sprite: AnimatedSprite2D = root.get_node_or_null("%s/Sprite" % character_name) as AnimatedSprite2D
	assert_that(sprite).is_not_null()
	if sprite == null:
		return
	assert_bool(sprite.visible).is_true()
	assert_that(sprite.sprite_frames).is_not_null()
	if sprite.sprite_frames == null:
		return
	for animation_name: StringName in required_animations:
		assert_bool(sprite.sprite_frames.has_animation(animation_name)).is_true()
		if not sprite.sprite_frames.has_animation(animation_name):
			continue
		assert_int(sprite.sprite_frames.get_frame_count(animation_name)).is_greater_equal(
			MIN_CHARACTER_ANIMATION_FRAMES
		)


func _has_visible_placeholder_shape(root: Node) -> bool:
	if root is ColorRect and (root as ColorRect).visible:
		return true
	if root is Polygon2D and (root as Polygon2D).visible:
		return true
	for child: Node in root.get_children():
		if _has_visible_placeholder_shape(child):
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
