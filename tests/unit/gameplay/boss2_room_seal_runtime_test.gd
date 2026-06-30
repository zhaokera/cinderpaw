## Story 030: Boss2 room seal runtime.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const BOSS2_DEFEATED_FLAG: StringName = &"boss_02_echo_guardian_defeated"
const BOSS2_ROOM_SEAL_TEXTURE_PATH: String = (
	"res://assets/environment/boss2_arena/boss2_echo_guardian_room_seal.png"
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


func test_active_boss2_room_seals_are_visible_and_blocking() -> void:
	assert_bool(scene.has_method("refresh_boss2_room_seals")).is_true()
	assert_bool(scene.has_method("get_boss2_room_seal_diagnostics")).is_true()
	if not scene.has_method("refresh_boss2_room_seals") \
			or not scene.has_method("get_boss2_room_seal_diagnostics"):
		return

	assert_bool(bool(scene.call("refresh_boss2_room_seals"))).is_true()
	var diagnostics: Dictionary = scene.call("get_boss2_room_seal_diagnostics")
	assert_bool(bool(diagnostics.get("enabled", false))).is_true()
	assert_str(String(diagnostics.get("reason", ""))).is_equal("boss2_active")
	assert_str(String(diagnostics.get("texture_path", ""))).is_equal(BOSS2_ROOM_SEAL_TEXTURE_PATH)
	assert_bool(FileAccess.file_exists(BOSS2_ROOM_SEAL_TEXTURE_PATH)).is_true()
	assert_bool(FileAccess.file_exists("%s.import" % BOSS2_ROOM_SEAL_TEXTURE_PATH)).is_true()

	var left: Dictionary = diagnostics.get("left", {})
	var right: Dictionary = diagnostics.get("right", {})
	assert_bool(bool(left.get("found", false))).is_true()
	assert_bool(bool(right.get("found", false))).is_true()
	assert_bool(bool(left.get("visible", false))).is_true()
	assert_bool(bool(right.get("visible", false))).is_true()
	assert_bool(bool(left.get("blocking", false))).is_true()
	assert_bool(bool(right.get("blocking", false))).is_true()
	assert_int(int(left.get("collision_layer", 0))).is_equal(16)
	assert_int(int(right.get("collision_layer", 0))).is_equal(16)


func test_defeated_progress_opens_boss2_room_seals_without_hiding_reward() -> void:
	assert_bool(scene.has_method("set_world_progress_flag")).is_true()
	assert_bool(scene.has_method("get_boss2_room_seal_diagnostics")).is_true()
	if not scene.has_method("set_world_progress_flag") \
			or not scene.has_method("get_boss2_room_seal_diagnostics"):
		return

	scene.call("set_world_progress_flag", BOSS2_DEFEATED_FLAG, true)
	var diagnostics: Dictionary = scene.call("get_boss2_room_seal_diagnostics")
	assert_bool(bool(diagnostics.get("enabled", true))).is_false()
	assert_str(String(diagnostics.get("reason", ""))).is_equal("boss2_defeated")
	assert_bool(bool(Dictionary(diagnostics.get("left", {})).get("blocking", true))).is_false()
	assert_bool(bool(Dictionary(diagnostics.get("right", {})).get("blocking", true))).is_false()
	assert_bool(bool(Dictionary(diagnostics.get("left", {})).get("visible", true))).is_false()
	assert_bool(bool(Dictionary(diagnostics.get("right", {})).get("visible", true))).is_false()

	var reward := scene.get_node_or_null("Boss2DoubleJumpRewardSource")
	assert_that(reward).is_not_null()
	if reward != null and reward.has_method("is_available"):
		assert_bool(bool(reward.call("is_available"))).is_true()


func test_restored_defeated_progress_keeps_boss2_room_seals_open() -> void:
	assert_bool(scene.has_method("capture_save_snapshot")).is_true()
	assert_bool(scene.has_method("restore_save_snapshot")).is_true()
	assert_bool(scene.has_method("get_boss2_room_seal_diagnostics")).is_true()
	if not scene.has_method("capture_save_snapshot") \
			or not scene.has_method("restore_save_snapshot") \
			or not scene.has_method("get_boss2_room_seal_diagnostics"):
		return

	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var world_state: Dictionary = Dictionary(snapshot.get("world_state", {}))
	var world_flags: Dictionary = Dictionary(world_state.get("world_flags", {}))
	world_flags[String(BOSS2_DEFEATED_FLAG)] = true
	world_state["world_flags"] = world_flags
	snapshot["world_state"] = world_state

	scene.call("restore_save_snapshot", snapshot)
	var diagnostics: Dictionary = scene.call("get_boss2_room_seal_diagnostics")
	assert_bool(bool(diagnostics.get("enabled", true))).is_false()
	assert_str(String(diagnostics.get("reason", ""))).is_equal("boss2_defeated")
	assert_bool(bool(Dictionary(diagnostics.get("left", {})).get("blocking", true))).is_false()
	assert_bool(bool(Dictionary(diagnostics.get("right", {})).get("blocking", true))).is_false()
