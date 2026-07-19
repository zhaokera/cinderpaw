## Player Abilities Story 013: Old Factory spark rat patrol encounter.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const CHARACTER_SCENE_PATH: String = "res://scenes/characters/factory_spark_rat.tscn"
const CHARACTER_SCRIPT_PATH: String = "res://src/characters/factory_spark_rat.gd"
const GAMEPLAY_SCENE_PATH: String = "res://src/gameplay/factory_spark_rat.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_ENTRY_GUARD_NAME: String = "FactoryRatMinion"
const FACTORY_DEEP_GUARD_NAME: String = "FactoryDeepGuardRatMinion"
const FACTORY_DEEP_ENDPOINT_NAME: String = "FactoryDeepRouteEndpoint"
const FACTORY_SPARK_RAT_NAME: String = "FactorySparkRat"
const FACTORY_SPARK_RAT_ENTITY_ID: int = 2102
const SPRITE_FRAMES_PATH: String = (
	"res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres"
)
const REQUIRED_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
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


func test_factory_spark_rat_character_assets_follow_frame_animation_rules() -> void:
	assert_bool(FileAccess.file_exists(CHARACTER_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(CHARACTER_SCRIPT_PATH)).is_true()
	assert_bool(FileAccess.file_exists(SPRITE_FRAMES_PATH)).is_true()

	var packed: PackedScene = load(CHARACTER_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return
	var character: Node = packed.instantiate()
	add_child(character)
	_spawned_nodes.append(character)

	assert_bool(character is AnimatedSprite2D).is_true()
	var sprite := character as AnimatedSprite2D
	assert_that(sprite.sprite_frames).is_not_null()
	if sprite.sprite_frames == null:
		return
	assert_str(sprite.sprite_frames.resource_path).is_equal(SPRITE_FRAMES_PATH)
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		assert_bool(sprite.sprite_frames.has_animation(animation_name)).is_true()
		if not sprite.sprite_frames.has_animation(animation_name):
			continue
		assert_int(sprite.sprite_frames.get_frame_count(animation_name)).is_greater_equal(
			MIN_CHARACTER_ANIMATION_FRAMES
		)
		assert_bool(_animation_frames_are_textured_and_same_size(
			sprite.sprite_frames,
			animation_name
		)).is_true()
		for frame_index: int in range(MIN_CHARACTER_ANIMATION_FRAMES):
			var frame_path: String = (
				"res://assets/characters/factory_spark_rat/%s/factory_spark_rat_%s_%03d.png"
				% [String(animation_name), String(animation_name), frame_index]
			)
			assert_bool(FileAccess.file_exists(frame_path)).is_true()


func test_old_factory_hides_inactive_spark_rat_until_deep_route_opens() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(FileAccess.file_exists(GAMEPLAY_SCENE_PATH)).is_true()
	assert_bool(destination.has_method("get_factory_spark_rat_diagnostics")).is_true()
	assert_bool(destination.has_method("try_activate_factory_spark_rat")).is_true()
	assert_bool(destination.has_method("is_factory_spark_rat_defeated")).is_true()

	var spark_rat: Node = destination.get_node_or_null(FACTORY_SPARK_RAT_NAME)
	assert_that(spark_rat).is_not_null()
	if spark_rat == null:
		return

	var diagnostics: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	assert_bool(bool(diagnostics.get("present", false))).is_true()
	assert_bool(bool(diagnostics.get("visible", true))).is_false()
	assert_bool(bool(diagnostics.get("active", true))).is_false()
	assert_bool(bool(diagnostics.get("defeated", true))).is_false()
	assert_int(int(diagnostics.get("entity_id", 0))).is_equal(FACTORY_SPARK_RAT_ENTITY_ID)
	assert_str(String(diagnostics.get("sprite_frames_path", ""))).is_equal(SPRITE_FRAMES_PATH)
	assert_bool(bool(destination.call("try_activate_factory_spark_rat"))).is_false()


func test_spark_rat_activates_after_endpoint_open_and_can_be_defeated() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	await _open_deep_route_endpoint(destination, player)
	var pending_diagnostics: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	player.global_position.x = float(pending_diagnostics.get("activation_x", 0.0)) + 8.0
	await get_tree().process_frame
	assert_bool(bool(destination.call("try_activate_factory_spark_rat", player))).is_false()

	var active_diagnostics: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	assert_bool(bool(active_diagnostics.get("active", false))).is_true()
	assert_bool(bool(active_diagnostics.get("has_target", false))).is_true()
	assert_bool(bool(active_diagnostics.get("physics_enabled", false))).is_true()
	assert_bool(bool(active_diagnostics.get("process_enabled", false))).is_true()

	var spark_rat: Node = destination.get_node_or_null(FACTORY_SPARK_RAT_NAME)
	assert_that(spark_rat).is_not_null()
	if spark_rat == null:
		return
	assert_bool(destination.call("apply_damage", FACTORY_SPARK_RAT_ENTITY_ID, 12, {})).is_true()
	assert_bool(destination.call("apply_damage", FACTORY_SPARK_RAT_ENTITY_ID, 12, {})).is_true()
	await get_tree().process_frame

	assert_bool(bool(destination.call("is_factory_spark_rat_defeated"))).is_true()
	var defeated_diagnostics: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	assert_bool(bool(defeated_diagnostics.get("defeated", false))).is_true()
	assert_bool(bool(defeated_diagnostics.get("active", true))).is_false()


func test_spark_rat_defeat_state_restores_without_replaying_route_feedback() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	destination.call("set_local_state", {
		"encounter_cleared": true,
		"factory_deep_guard_activated": true,
		"factory_deep_guard_defeated": true,
		"factory_deep_route_cleared": true,
		"factory_spark_rat_activated": true,
		"factory_spark_rat_defeated": true,
	})

	assert_bool(bool(destination.call("is_factory_spark_rat_defeated"))).is_true()
	var diagnostics: Dictionary = destination.call("get_factory_spark_rat_diagnostics")
	assert_bool(bool(diagnostics.get("defeated", false))).is_true()
	assert_bool(bool(diagnostics.get("visible", true))).is_false()
	assert_bool(bool(diagnostics.get("active", true))).is_false()
	var route_diagnostics: Dictionary = destination.call("get_factory_deep_route_diagnostics")
	assert_bool(bool(route_diagnostics.get("deep_route_cleared", false))).is_true()
	assert_bool(bool(route_diagnostics.get("unlock_feedback_active", true))).is_false()
	assert_int(int(route_diagnostics.get("unlock_feedback_spawn_count", -1))).is_equal(0)

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get("factory_spark_rat_activated", false))).is_true()
	assert_bool(bool(local_state.get("factory_spark_rat_defeated", false))).is_true()


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


func _animation_frames_are_textured_and_same_size(
	sprite_frames: SpriteFrames,
	animation_name: StringName
) -> bool:
	var expected_size := Vector2.ZERO
	for frame_index: int in range(sprite_frames.get_frame_count(animation_name)):
		var texture := sprite_frames.get_frame_texture(animation_name, frame_index)
		if texture == null:
			return false
		var texture_size := texture.get_size()
		if expected_size == Vector2.ZERO:
			expected_size = texture_size
		elif texture_size != expected_size:
			return false
	return true


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
