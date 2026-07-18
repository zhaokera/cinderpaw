## Story176: Crown Warden uses a dedicated looping Phase II transition animation.
extends GdUnitTestSuite

const ARENA_SCENE: PackedScene = preload(
	"res://scenes/bosses/crown_warden_arena.tscn"
)
const BOSS_ENTITY_ID: int = 2400
const PHASE_TWO_TRIGGER_DAMAGE: int = 80
const TRANSITION_ANIMATION: StringName = &"phase_transition"
const TRANSITION_FRAME_COUNT: int = 3
const TRANSITION_FPS: float = 6.0
const TRANSITION_FRAME_ROOT: String = (
	"res://assets/characters/crown_warden/phase_transition/"
)

var _arena: Node


func after_test() -> void:
	_stop_runtime_audio_players()
	if _arena == null or not is_instance_valid(_arena):
		return
	if _arena.get_parent() != null:
		_arena.get_parent().remove_child(_arena)
	_arena.free()
	_arena = null


func test_phase_two_uses_three_frame_generated_transition_instead_of_hurt_hold() -> void:
	_arena = ARENA_SCENE.instantiate()
	add_child(_arena)
	var boss: CharacterBody2D = _arena.get_node("CrownWardenBoss") as CharacterBody2D
	var sprite: AnimatedSprite2D = boss.get_node("Sprite") as AnimatedSprite2D
	var frames: SpriteFrames = sprite.sprite_frames

	assert_bool(frames.has_animation(TRANSITION_ANIMATION)).override_failure_message(
		"Story176 RED: Crown Warden needs a dedicated phase_transition animation"
	).is_true()
	if not frames.has_animation(TRANSITION_ANIMATION):
		return

	assert_int(frames.get_frame_count(TRANSITION_ANIMATION)).is_equal(
		TRANSITION_FRAME_COUNT
	)
	assert_bool(frames.get_animation_loop(TRANSITION_ANIMATION)).is_true()
	assert_float(frames.get_animation_speed(TRANSITION_ANIMATION)).is_equal_approx(
		TRANSITION_FPS,
		0.001
	)
	var frame_bottoms: Array[int] = []
	var frame_centers: Array[float] = []
	var frame_pixels: Array[PackedByteArray] = []
	for frame_index: int in range(TRANSITION_FRAME_COUNT):
		var frame_path: String = (
			TRANSITION_FRAME_ROOT
			+ "crown_warden_phase_transition_%03d.png" % frame_index
		)
		var texture: Texture2D = frames.get_frame_texture(
			TRANSITION_ANIMATION,
			frame_index
		)
		assert_that(texture).is_not_null()
		if texture != null:
			assert_str(texture.resource_path).is_equal(frame_path)
		assert_bool(FileAccess.file_exists(frame_path)).is_true()
		if not FileAccess.file_exists(frame_path):
			continue
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(frame_path))
		assert_that(image).is_not_null()
		if image == null or image.is_empty():
			continue
		assert_vector(Vector2(image.get_size())).is_equal(Vector2(192, 192))
		assert_float(image.get_pixel(0, 0).a).is_equal(0.0)
		var used_rect: Rect2i = image.get_used_rect()
		frame_bottoms.append(used_rect.end.y)
		frame_centers.append(
			float(used_rect.position.x) + float(used_rect.size.x) * 0.5
		)
		frame_pixels.append(image.get_data())
	assert_int(frame_bottoms.size()).is_equal(TRANSITION_FRAME_COUNT)
	if frame_bottoms.size() == TRANSITION_FRAME_COUNT:
		assert_int(frame_bottoms.max() - frame_bottoms.min()).is_less_equal(2)
		assert_float(frame_centers.max() - frame_centers.min()).is_less_equal(3.0)
		assert_bool(frame_pixels[0] != frame_pixels[1]).is_true()
		assert_bool(frame_pixels[1] != frame_pixels[2]).is_true()
		assert_bool(frame_pixels[0] != frame_pixels[2]).is_true()
		var idle_image: Image = Image.load_from_file(ProjectSettings.globalize_path(
			"res://assets/characters/crown_warden/idle/crown_warden_idle_000.png"
		))
		var idle_bottom: int = idle_image.get_used_rect().end.y
		for frame_bottom: int in frame_bottoms:
			assert_int(absi(frame_bottom - idle_bottom)).is_less_equal(2)

	var config: Dictionary = boss.call("get_config_diagnostics")
	assert_str(String(config.get("phase_transition_animation", ""))).is_equal(
		String(TRANSITION_ANIMATION)
	)
	boss.call("set_autonomous_attacks_enabled", false)
	assert_bool(bool(boss.call("request_attack", &"wing_sweep"))).is_true()
	boss.call("advance_attack_frames", 24)
	assert_bool(bool(_arena.call(
		"apply_damage",
		BOSS_ENTITY_ID,
		PHASE_TWO_TRIGGER_DAMAGE,
		{"source": &"story176_phase_threshold"}
	))).is_true()
	boss.call("advance_attack_frames", 28)
	var transition: Dictionary = boss.call("get_phase_transition_diagnostics")
	assert_str(String(transition.get("animation", ""))).is_equal(
		String(TRANSITION_ANIMATION)
	)
	assert_str(String(sprite.animation)).is_equal(String(TRANSITION_ANIMATION))
	assert_bool(sprite.is_playing()).is_true()
	assert_bool(bool(transition.get("active", false))).is_true()


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	if audio_system.has_method("stop_music"):
		audio_system.call("stop_music", 0.0)
	if audio_system.has_method("stop_ambient"):
		audio_system.call("stop_ambient", 0.0)
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var player := child as AudioStreamPlayer
			player.stop()
			player.stream = null
		elif child is AudioStreamPlayer2D:
			var player_2d := child as AudioStreamPlayer2D
			player_2d.stop()
			player_2d.stream = null
