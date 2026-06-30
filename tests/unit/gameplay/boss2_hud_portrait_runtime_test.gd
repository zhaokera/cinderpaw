## Story 031: Boss2 HUD portrait runtime.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const BOSS2_PORTRAIT_TEXTURE_PATH: String = (
	"res://assets/ui/boss_portraits/boss2_echo_guardian_portrait.png"
)

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


func test_boss2_focus_shows_authored_hud_portrait() -> void:
	var hud: Node = scene.get_node("HUD")
	assert_bool(hud.has_method("get_boss_portrait_diagnostics")).is_true()
	if not hud.has_method("get_boss_portrait_diagnostics"):
		return

	var diagnostics: Dictionary = hud.call("get_boss_portrait_diagnostics")
	assert_bool(bool(diagnostics.get("visible", false))).is_true()
	assert_bool(bool(diagnostics.get("panel_visible", false))).is_true()
	assert_str(String(diagnostics.get("texture_path", ""))).is_equal(BOSS2_PORTRAIT_TEXTURE_PATH)
	assert_vector(diagnostics.get("texture_size", Vector2.ZERO)).is_equal(Vector2(128, 128))
	var rect_size: Vector2 = diagnostics.get("rect_size", Vector2.ZERO)
	assert_float(rect_size.x).is_less_equal(64.0)
	assert_float(rect_size.y).is_less_equal(64.0)
	assert_bool(FileAccess.file_exists(BOSS2_PORTRAIT_TEXTURE_PATH)).is_true()
	assert_bool(FileAccess.file_exists("%s.import" % BOSS2_PORTRAIT_TEXTURE_PATH)).is_true()


func test_boss2_defeated_hands_off_without_stale_portrait() -> void:
	var hud: Node = scene.get_node("HUD")
	assert_bool(scene.has_method("set_world_progress_flag")).is_true()
	assert_bool(hud.has_method("get_boss_portrait_diagnostics")).is_true()
	if not scene.has_method("set_world_progress_flag") \
			or not hud.has_method("get_boss_portrait_diagnostics"):
		return

	scene.call("set_world_progress_flag", &"boss_02_echo_guardian_defeated", true)
	var diagnostics: Dictionary = hud.call("get_boss_portrait_diagnostics")
	assert_bool(bool(diagnostics.get("visible", true))).is_false()
	assert_str(String(diagnostics.get("texture_path", ""))).is_empty()
