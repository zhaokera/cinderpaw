## Player Abilities Story173: readable Sluice Matriarch pressure geyser pattern.
extends GdUnitTestSuite

const BOSS_SCENE_PATH: String = "res://src/gameplay/sluice_matriarch_boss.tscn"
const BOSS_FRAMES_PATH: String = (
	"res://assets/characters/sluice_matriarch/sluice_matriarch_sprite_frames.tres"
)
const GEYSER_FRAMES_PATH: String = (
	"res://assets/environment/sluice_matriarch_arena/pressure_geyser/"
	+ "pressure_geyser_sprite_frames.tres"
)
const REQUIRED_BOSS_ANIMATIONS: Array[StringName] = [
	&"geyser_tell",
	&"geyser_attack",
	&"attack_recovery",
]
const REQUIRED_GEYSER_ANIMATIONS: Array[StringName] = [&"warning", &"active"]
const PRESSURE_LUNGE_ID: StringName = &"pressure_lunge"
const PRESSURE_GEYSER_ID: StringName = &"pressure_geyser"


func test_pressure_geyser_is_telegraphed_damaging_only_when_active_and_recovers() -> void:
	assert_bool(FileAccess.file_exists(GEYSER_FRAMES_PATH)).is_true()
	if not FileAccess.file_exists(GEYSER_FRAMES_PATH):
		return
	_assert_animation_contract(BOSS_FRAMES_PATH, REQUIRED_BOSS_ANIMATIONS)
	_assert_animation_contract(GEYSER_FRAMES_PATH, REQUIRED_GEYSER_ANIMATIONS)

	var packed: PackedScene = load(BOSS_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return
	var boss: Node2D = auto_free(packed.instantiate()) as Node2D
	add_child(boss)
	boss.set_physics_process(false)
	assert_bool(boss.has_method("request_attack_pattern")).is_true()
	assert_bool(boss.has_method("get_attack_diagnostics")).is_true()
	if (
		not boss.has_method("request_attack_pattern")
		or not boss.has_method("get_attack_diagnostics")
	):
		return

	boss.global_position = Vector2(930, 540)
	var target := Node2D.new()
	target.global_position = Vector2(420, 540)
	add_child(auto_free(target))
	boss.call("set_attack_target", target)

	var initial: Dictionary = boss.call("get_attack_diagnostics")
	assert_str(String(initial.get("next_attack_id", ""))).is_equal(
		String(PRESSURE_LUNGE_ID)
	)
	assert_bool(bool(boss.call("request_attack_pattern", PRESSURE_LUNGE_ID))).is_true()
	boss.call("advance_attack_frames", 42)
	var after_lunge: Dictionary = boss.call("get_attack_diagnostics")
	assert_str(String(after_lunge.get("next_attack_id", ""))).is_equal(
		String(PRESSURE_GEYSER_ID)
	)
	boss.call("advance_attack_frames", 42)

	assert_bool(bool(boss.call("request_attack_pattern", PRESSURE_GEYSER_ID))).is_true()
	var warning: Dictionary = boss.call("get_attack_diagnostics")
	assert_str(String(warning.get("current_attack_id", ""))).is_equal(
		String(PRESSURE_GEYSER_ID)
	)
	assert_str(String(warning.get("attack_phase", ""))).is_equal("startup")
	assert_str(String(warning.get("animation", ""))).is_equal("geyser_tell")
	assert_int(int(warning.get("startup_frames", 0))).is_equal(24)
	assert_int(int(warning.get("active_frames", 0))).is_equal(10)
	assert_int(int(warning.get("recovery_frames", 0))).is_equal(24)
	assert_int(int(warning.get("attack_damage", 0))).is_equal(14)
	assert_bool(bool(warning.get("hitbox_active", true))).is_false()
	assert_bool(bool(warning.get("geyser_visible", false))).is_true()
	assert_str(String(warning.get("geyser_animation", ""))).is_equal("warning")
	assert_float(float(warning.get("geyser_target_x", 0.0))).is_equal_approx(420.0, 0.1)
	assert_bool(float(warning.get("safe_space_px", 0.0)) >= 160.0).is_true()

	boss.call("advance_attack_frames", 24)
	var active: Dictionary = boss.call("get_attack_diagnostics")
	assert_str(String(active.get("attack_phase", ""))).is_equal("active")
	assert_str(String(active.get("animation", ""))).is_equal("geyser_attack")
	assert_bool(bool(active.get("hitbox_active", false))).is_true()
	assert_str(String(active.get("hitbox_id", ""))).is_equal(
		"sluice_matriarch_pressure_geyser"
	)
	assert_str(String(active.get("geyser_animation", ""))).is_equal("active")

	boss.call("advance_attack_frames", 10)
	var recovery: Dictionary = boss.call("get_attack_diagnostics")
	assert_str(String(recovery.get("attack_phase", ""))).is_equal("recovery")
	assert_str(String(recovery.get("animation", ""))).is_equal("attack_recovery")
	assert_bool(bool(recovery.get("hitbox_active", true))).is_false()
	assert_bool(bool(recovery.get("geyser_visible", true))).is_false()

	boss.call("reset_encounter")
	boss.call("apply_damage", 61, {"source": &"story173_phase_two"})
	boss.call("advance_attack_frames", 5)
	assert_bool(bool(boss.call("request_attack_pattern", PRESSURE_GEYSER_ID))).is_true()
	var phase_two: Dictionary = boss.call("get_attack_diagnostics")
	assert_int(int(phase_two.get("current_phase", 0))).is_equal(2)
	assert_int(int(phase_two.get("startup_frames", 0))).is_equal(18)
	assert_int(int(phase_two.get("active_frames", 0))).is_equal(10)
	assert_int(int(phase_two.get("recovery_frames", 0))).is_equal(18)
	boss.call("mark_defeated_from_progress")
	var defeated: Dictionary = boss.call("get_attack_diagnostics")
	assert_bool(bool(defeated.get("hitbox_active", true))).is_false()
	assert_bool(bool(defeated.get("geyser_visible", true))).is_false()


func _assert_animation_contract(
	resource_path: String,
	animation_names: Array[StringName]
) -> void:
	var frames: SpriteFrames = load(resource_path) as SpriteFrames
	assert_that(frames).is_not_null()
	if frames == null:
		return
	for animation_name: StringName in animation_names:
		assert_bool(frames.has_animation(animation_name)).is_true()
		if not frames.has_animation(animation_name):
			continue
		assert_int(frames.get_frame_count(animation_name)).is_equal(3)
		for frame_index: int in range(3):
			var texture: Texture2D = frames.get_frame_texture(animation_name, frame_index)
			assert_that(texture).is_not_null()
			if texture == null:
				continue
			assert_vector(texture.get_size()).is_equal(Vector2(192, 192))
			var image: Image = texture.get_image()
			assert_that(image).is_not_null()
			if image != null:
				assert_bool(image.detect_alpha() != Image.ALPHA_NONE).is_true()
				assert_int(image.get_pixel(0, 0).a8).is_equal(0)
