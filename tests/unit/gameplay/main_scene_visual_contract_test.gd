## Main scene visual contract for non-placeholder runtime characters and VFX routing.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const PLAYER_REQUIRED_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack",
	&"dodge",
	&"hurt",
	&"death",
	&"revive",
	&"jump",
	&"fall",
]
const ENEMY_REQUIRED_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"patrol",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]

class FakeBossPhaseSource:
	extends Node

	signal on_boss_phase_transition_started(entity_id: int, phase: int, metadata: Dictionary)

	func emit_transition_started() -> void:
		on_boss_phase_transition_started.emit(42, 2, {
			"boss_id": "shadow_beast",
			"display_name": "Shadow Beast",
			"previous_phase": 1,
			"hp_threshold": 0.66,
			"trigger_hp_percentage": 0.65,
			"transition_duration_sec": 2.5,
			"transition_animation": "phase_2_rebuild",
			"attack_patterns": PackedStringArray(["bite", "lunge"]),
			"attack_speed_modifier": 1.15,
			"special_attacks": PackedStringArray(["overload_pounce"]),
			"arena_changes": {
				"debris_density": "high",
			},
		})

var main_scene: Node2D


func before_test() -> void:
	main_scene = MAIN_SCENE.instantiate() as Node2D
	add_child(main_scene)


func after_test() -> void:
	if is_instance_valid(main_scene):
		if main_scene.get_parent() != null:
			main_scene.get_parent().remove_child(main_scene)
		main_scene.free()
	main_scene = null


func test_runtime_characters_use_animated_sprite_frames() -> void:
	var player_sprite := _animated_sprite_or_fail("Player/Sprite")
	var enemy_sprite := _animated_sprite_or_fail("Enemy/Sprite")
	if player_sprite == null or enemy_sprite == null:
		return

	_assert_required_animations(player_sprite, PLAYER_REQUIRED_ANIMATIONS)
	_assert_required_animations(enemy_sprite, ENEMY_REQUIRED_ANIMATIONS)


func test_runtime_characters_do_not_use_legacy_single_image_textures() -> void:
	assert_bool(_scene_file_text_contains("assets/generated/cinderpaw_player.png")).is_false()
	assert_bool(_scene_file_text_contains("assets/generated/shadow_beast_enemy.png")).is_false()
	var player_sprite := _animated_sprite_or_fail("Player/Sprite")
	var enemy_sprite := _animated_sprite_or_fail("Enemy/Sprite")
	if player_sprite == null or enemy_sprite == null:
		return

	assert_bool(_sprite_frames_use_texture_path(
		player_sprite.sprite_frames,
		"res://assets/generated/cinderpaw_player.png"
	)).is_false()
	assert_bool(_sprite_frames_use_texture_path(
		enemy_sprite.sprite_frames,
		"res://assets/generated/shadow_beast_enemy.png"
	)).is_false()


func test_main_scene_startup_has_no_visible_gameplay_color_rect_blocks() -> void:
	var visible_color_rect_paths := _collect_visible_color_rect_paths(main_scene)

	assert_array(visible_color_rect_paths).is_empty()


func test_main_scene_routes_boss_phase_transition_source_to_combat_presentation() -> void:
	assert_bool(main_scene.has_method("register_boss_phase_transition_source")).is_true()
	if not main_scene.has_method("register_boss_phase_transition_source"):
		return

	var source := FakeBossPhaseSource.new()
	main_scene.add_child(source)
	var presentation := main_scene.get_node("CombatPresentation")

	assert_bool(bool(main_scene.call("register_boss_phase_transition_source", source))).is_true()

	source.emit_transition_started()

	assert_int(presentation.get_hitstop_frames_remaining()).is_equal(4)
	assert_float(presentation.get_screen_shake_intensity()).is_equal_approx(6.0, 0.001)
	assert_int(int(presentation.call("get_active_boss_phase_debris_count"))).is_greater_equal(30)
	assert_int(int(presentation.call("get_last_boss_phase"))).is_equal(2)


func _animated_sprite_or_fail(node_path: NodePath) -> AnimatedSprite2D:
	var node := main_scene.get_node_or_null(node_path)
	assert_bool(node is AnimatedSprite2D).is_true()
	return node as AnimatedSprite2D


func _assert_required_animations(sprite: AnimatedSprite2D, required_animations: Array[StringName]) -> void:
	assert_bool(sprite.sprite_frames != null).is_true()
	if sprite.sprite_frames == null:
		return
	for animation_name: StringName in required_animations:
		assert_bool(sprite.sprite_frames.has_animation(animation_name)).is_true()
		if not sprite.sprite_frames.has_animation(animation_name):
			continue
		assert_int(sprite.sprite_frames.get_frame_count(animation_name)).is_greater_equal(3)
		assert_bool(_animation_frames_are_textured_and_same_size(
			sprite.sprite_frames,
			animation_name
		)).is_true()


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


func _collect_visible_color_rect_paths(root: Node) -> Array[String]:
	var result: Array[String] = []
	for child: Node in root.get_children():
		var color_rect := child as ColorRect
		if color_rect != null and color_rect.visible:
			result.append(str(root.get_path_to(color_rect)))
		result.append_array(_collect_visible_color_rect_paths(child))
	return result


func _scene_file_text_contains(needle: String) -> bool:
	return FileAccess.get_file_as_string("res://scenes/main.tscn").contains(needle)


func _sprite_frames_use_texture_path(sprite_frames: SpriteFrames, texture_path: String) -> bool:
	if sprite_frames == null:
		return false
	for animation_name: StringName in sprite_frames.get_animation_names():
		for frame_index: int in range(sprite_frames.get_frame_count(animation_name)):
			var texture := sprite_frames.get_frame_texture(animation_name, frame_index)
			if texture != null and texture.resource_path == texture_path:
				return true
	return false
