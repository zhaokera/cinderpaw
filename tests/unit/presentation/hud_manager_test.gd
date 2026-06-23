## HUDManager presentation behavior tests.
extends GdUnitTestSuite

const HUD_MANAGER_SCRIPT: Script = preload("res://src/presentation/hud_manager.gd")

var hud


func before_test() -> void:
	hud = HUD_MANAGER_SCRIPT.new()
	add_child(hud)


func after_test() -> void:
	if is_instance_valid(hud):
		if hud.get_parent() != null:
			hud.get_parent().remove_child(hud)
		hud.free()
	hud = null


func test_update_hp_sets_ratio_label_and_healthy_color() -> void:
	hud.update_hp(75, 100)

	assert_float(hud.get_hp_ratio()).is_equal_approx(0.75, 0.001)
	assert_str(hud.get_hp_label_text()).is_equal("75 / 100")
	assert_str(hud.get_hp_color().to_html(false)).is_equal("ecc94b")


func test_low_hp_uses_stable_warning_red_without_pulsing() -> void:
	hud.update_hp(20, 100)

	assert_float(hud.get_hp_ratio()).is_equal_approx(0.2, 0.001)
	assert_str(hud.get_hp_color().to_html(false)).is_equal("e53e3e")
	assert_bool(hud.is_low_hp_pulsing_enabled()).is_false()


func test_show_notification_expires_after_duration() -> void:
	hud.show_notification("Enemy defeated", 0.5)

	assert_bool(hud.is_notification_visible()).is_true()
	assert_str(hud.get_notification_text()).is_equal("Enemy defeated")

	hud.advance_time(0.49)

	assert_bool(hud.is_notification_visible()).is_true()

	hud.advance_time(0.02)

	assert_bool(hud.is_notification_visible()).is_false()
