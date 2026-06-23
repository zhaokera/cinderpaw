## MainScene runtime weapon swap integration tests.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")

var scene


func before_test() -> void:
	scene = MAIN_SCENE.instantiate()
	add_child(scene)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_weapon_swap_action_is_registered_for_runtime_input() -> void:
	assert_bool(InputMap.has_action("weapon_swap")).is_true()


func test_runtime_weapon_swap_updates_progress_state_and_hud_after_half_second() -> void:
	assert_str(String(scene.get_runtime_progress_state()["weapons"]["current_weapon"])).is_equal("cat_claw")
	assert_str(scene.get_weapon_hud_text()).is_equal("猫爪\nSpecial 0%")

	assert_bool(scene.request_weapon_swap()).is_true()
	scene.advance_weapon_swap_time(0.49)

	assert_str(String(scene.get_runtime_progress_state()["weapons"]["current_weapon"])).is_equal("cat_claw")
	assert_str(scene.get_weapon_hud_text()).is_equal("猫爪\nSpecial 0%")

	scene.advance_weapon_swap_time(0.01)

	assert_str(String(scene.get_runtime_progress_state()["weapons"]["current_weapon"])).is_equal("long_tail")
	assert_str(scene.get_weapon_hud_text()).is_equal("长尾刃\nSpecial 0%")
