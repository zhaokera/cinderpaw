## Story 029: Boss2 arena camera lock runtime.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const BOSS2_DEFEATED_FLAG: StringName = &"boss_02_echo_guardian_defeated"
const RAT_KING_DEFEATED_FLAG: StringName = &"boss_rat_king_defeated"

var scene: Node2D


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	scene.call("set_world_progress_flag", RAT_KING_DEFEATED_FLAG, true)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_active_boss2_applies_room_camera_lock_and_diagnostics() -> void:
	var camera := scene.get_node_or_null("Player/Camera2D") as Camera2D
	assert_that(camera).is_not_null()
	assert_bool(scene.has_method("refresh_boss2_camera_lock")).is_true()
	assert_bool(scene.has_method("get_boss2_camera_lock_diagnostics")).is_true()
	if camera == null \
			or not scene.has_method("refresh_boss2_camera_lock") \
			or not scene.has_method("get_boss2_camera_lock_diagnostics"):
		return

	assert_bool(bool(scene.call("refresh_boss2_camera_lock"))).is_true()
	var diagnostics: Dictionary = scene.call("get_boss2_camera_lock_diagnostics")
	assert_bool(bool(diagnostics.get("camera_found", false))).is_true()
	assert_bool(bool(diagnostics.get("enabled", false))).is_true()
	assert_str(String(diagnostics.get("reason", ""))).is_equal("boss2_active")
	assert_int(int(diagnostics.get("limit_left", -1))).is_equal(0)
	assert_int(int(diagnostics.get("limit_right", 1280))).is_less(1280)
	assert_int(camera.limit_right).is_equal(int(diagnostics.get("limit_right", -1)))
	assert_float(camera.zoom.x).is_greater(1.0)
	assert_float(camera.zoom.y).is_equal_approx(camera.zoom.x, 0.001)
	assert_bool(camera.position_smoothing_enabled).is_true()


func test_boss2_defeated_progress_releases_camera_to_default_framing() -> void:
	var camera := scene.get_node_or_null("Player/Camera2D") as Camera2D
	assert_that(camera).is_not_null()
	assert_bool(scene.has_method("set_world_progress_flag")).is_true()
	assert_bool(scene.has_method("refresh_boss2_camera_lock")).is_true()
	assert_bool(scene.has_method("get_boss2_camera_lock_diagnostics")).is_true()
	if camera == null \
			or not scene.has_method("set_world_progress_flag") \
			or not scene.has_method("refresh_boss2_camera_lock") \
			or not scene.has_method("get_boss2_camera_lock_diagnostics"):
		return

	scene.call("set_world_progress_flag", BOSS2_DEFEATED_FLAG, true)
	assert_bool(bool(scene.call("refresh_boss2_camera_lock"))).is_false()
	var diagnostics: Dictionary = scene.call("get_boss2_camera_lock_diagnostics")
	assert_bool(bool(diagnostics.get("enabled", true))).is_false()
	assert_str(String(diagnostics.get("reason", ""))).is_equal("boss2_defeated")
	assert_int(camera.limit_left).is_equal(0)
	assert_int(camera.limit_right).is_equal(1280)
	assert_int(camera.limit_top).is_equal(0)
	assert_int(camera.limit_bottom).is_equal(720)
	assert_float(camera.zoom.x).is_equal_approx(1.0, 0.001)
	assert_float(camera.zoom.y).is_equal_approx(1.0, 0.001)


func test_restore_save_snapshot_with_defeated_boss2_releases_camera_lock() -> void:
	var camera := scene.get_node_or_null("Player/Camera2D") as Camera2D
	assert_that(camera).is_not_null()
	assert_bool(scene.has_method("capture_save_snapshot")).is_true()
	assert_bool(scene.has_method("restore_save_snapshot")).is_true()
	if camera == null \
			or not scene.has_method("capture_save_snapshot") \
			or not scene.has_method("restore_save_snapshot"):
		return

	assert_int(camera.limit_right).is_less(1280)
	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var world_state: Dictionary = Dictionary(snapshot.get("world_state", {}))
	var world_flags: Dictionary = Dictionary(world_state.get("world_flags", {}))
	world_flags[String(BOSS2_DEFEATED_FLAG)] = true
	world_state["world_flags"] = world_flags
	snapshot["world_state"] = world_state

	scene.call("restore_save_snapshot", snapshot)
	var diagnostics: Dictionary = scene.call("get_boss2_camera_lock_diagnostics")
	assert_bool(bool(diagnostics.get("enabled", true))).is_false()
	assert_str(String(diagnostics.get("reason", ""))).is_equal("boss2_defeated")
	assert_int(camera.limit_right).is_equal(1280)
	assert_float(camera.zoom.x).is_equal_approx(1.0, 0.001)
	assert_float(camera.zoom.y).is_equal_approx(1.0, 0.001)


func test_camera_release_preserves_combat_presentation_offset_ownership() -> void:
	var camera := scene.get_node_or_null("Player/Camera2D") as Camera2D
	assert_that(camera).is_not_null()
	assert_bool(scene.has_method("set_world_progress_flag")).is_true()
	if camera == null or not scene.has_method("set_world_progress_flag"):
		return

	var shake_offset := Vector2(6.0, 0.0)
	camera.offset = shake_offset
	scene.call("set_world_progress_flag", BOSS2_DEFEATED_FLAG, true)
	assert_vector(camera.offset).is_equal(shake_offset)
