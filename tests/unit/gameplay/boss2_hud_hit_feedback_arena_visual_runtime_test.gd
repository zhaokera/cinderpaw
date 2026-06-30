## Story 028: Boss2 HUD hit feedback and arena visual runtime.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const BOSS2_ENTITY_ID: int = 2200
const BOSS2_ARENA_FRAME_TEXTURE_PATH: String = (
	"res://assets/environment/boss2_arena/boss2_echo_guardian_arena_frame.png"
)
const BOSS2_HIT_DAMAGE: int = 9

var scene: Node2D


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_boss2_arena_frame_uses_authored_transparent_environment_asset() -> void:
	var frame := scene.get_node_or_null("Boss2ArenaFrame") as Sprite2D
	assert_that(frame).is_not_null()
	if frame == null:
		return

	assert_bool(frame.visible).is_true()
	assert_int(frame.z_index).is_less(33)
	assert_that(frame.texture).is_not_null()
	if frame.texture == null:
		return
	assert_str(frame.texture.resource_path).is_equal(BOSS2_ARENA_FRAME_TEXTURE_PATH)
	assert_vector(frame.texture.get_size()).is_equal(Vector2(640, 256))
	assert_bool(FileAccess.file_exists(BOSS2_ARENA_FRAME_TEXTURE_PATH)).is_true()
	assert_bool(FileAccess.file_exists("%s.import" % BOSS2_ARENA_FRAME_TEXTURE_PATH)).is_true()


func test_boss2_damage_triggers_short_hud_hit_flash_without_losing_focus() -> void:
	var hud: Node = scene.get_node("HUD")
	assert_bool(hud.has_method("is_boss_hit_flash_visible")).is_true()
	assert_bool(hud.has_method("get_boss_hit_flash_remaining_sec")).is_true()
	assert_bool(hud.has_method("get_boss_hit_flash_color")).is_true()
	if (
		not hud.has_method("is_boss_hit_flash_visible")
		or not hud.has_method("get_boss_hit_flash_remaining_sec")
		or not hud.has_method("get_boss_hit_flash_color")
	):
		return

	assert_bool(bool(hud.call("is_boss_hit_flash_visible"))).is_false()
	assert_bool(scene.call("apply_damage", BOSS2_ENTITY_ID, BOSS2_HIT_DAMAGE, {
		"source": &"unit_test_boss2_hud_hit_flash",
	})).is_true()

	assert_str(String(hud.call("get_boss_label_text"))).contains("Echo Guardian")
	assert_bool(bool(hud.call("is_boss_hit_flash_visible"))).is_true()
	var flash_remaining: float = float(hud.call("get_boss_hit_flash_remaining_sec"))
	assert_float(flash_remaining).is_greater(0.0)
	assert_str(_color_html(hud.call("get_boss_hit_flash_color"))).is_equal("ffffff")

	hud.call("advance_time", flash_remaining * 0.5)
	assert_float(float(hud.call("get_boss_hit_flash_remaining_sec"))).is_less(flash_remaining)
	assert_bool(bool(hud.call("is_boss_hit_flash_visible"))).is_true()

	hud.call("advance_time", 1.0)
	assert_float(float(hud.call("get_boss_hit_flash_remaining_sec"))).is_equal_approx(0.0, 0.001)
	assert_bool(bool(hud.call("is_boss_hit_flash_visible"))).is_false()


func _color_html(value: Variant) -> String:
	if value is Color:
		return (value as Color).to_html(false)
	return Color(value).to_html(false)
