## HUDManager presentation behavior tests.
extends GdUnitTestSuite

const HUD_MANAGER_SCRIPT: Script = preload("res://src/presentation/hud_manager.gd")

var hud
var _resume_requests: int = 0
var _retry_requests: int = 0


func before_test() -> void:
	hud = HUD_MANAGER_SCRIPT.new()
	add_child(hud)
	_resume_requests = 0
	_retry_requests = 0
	hud.menu_resume_requested.connect(_on_menu_resume_requested)
	hud.menu_retry_requested.connect(_on_menu_retry_requested)


func after_test() -> void:
	if is_instance_valid(hud):
		if hud.get_parent() != null:
			hud.get_parent().remove_child(hud)
		hud.free()
	hud = null
	_resume_requests = 0
	_retry_requests = 0


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


func test_show_pause_menu_displays_focusable_resume_and_retry_buttons() -> void:
	hud.show_pause_menu()

	assert_bool(hud.is_menu_visible()).is_true()
	assert_str(String(hud.get_menu_mode())).is_equal("pause")
	assert_str(hud.get_menu_title()).is_equal("Paused")
	assert_str(hud.get_resume_button_text()).is_equal("Resume")
	assert_str(hud.get_retry_button_text()).is_equal("Retry Encounter")
	assert_str(hud.get_focused_menu_button_text()).is_equal("Resume")
	assert_bool(hud.are_menu_buttons_focusable()).is_true()


func test_menu_buttons_emit_resume_and_retry_requests() -> void:
	hud.show_pause_menu()

	hud.get_node("HudRoot/MenuOverlay/MenuPanel/MenuContent/MenuButtons/ResumeButton").pressed.emit()
	hud.get_node("HudRoot/MenuOverlay/MenuPanel/MenuContent/MenuButtons/RetryButton").pressed.emit()

	assert_int(_resume_requests).is_equal(1)
	assert_int(_retry_requests).is_equal(1)


func test_hide_menu_clears_menu_mode_and_focus() -> void:
	hud.show_retry_menu("Shadow beast defeated", "Try again with full health.")

	assert_bool(hud.is_menu_visible()).is_true()
	assert_str(String(hud.get_menu_mode())).is_equal("retry")

	hud.hide_menu()

	assert_bool(hud.is_menu_visible()).is_false()
	assert_str(String(hud.get_menu_mode())).is_equal("none")
	assert_str(hud.get_focused_menu_button_text()).is_equal("")


func test_show_battle_summary_formats_stats_tip_and_retry_actions() -> void:
	hud.show_battle_summary({
		"duration_sec": 18.4,
		"damage_dealt": 36,
		"damage_received": 80,
		"dodge_success_rate": 0.25,
		"parry_success_rate": 0.0,
		"tip": "Dodge earlier when the beast crouches.",
	})

	assert_bool(hud.is_menu_visible()).is_true()
	assert_str(String(hud.get_menu_mode())).is_equal("battle_summary")
	assert_str(hud.get_menu_title()).is_equal("Hunter's Lesson")
	assert_str(hud.get_resume_button_text()).is_equal("Skip Lesson")
	assert_str(hud.get_retry_button_text()).is_equal("Retry Encounter")
	assert_str(hud.get_menu_subtitle()).contains("Duration: 18.4s")
	assert_str(hud.get_menu_subtitle()).contains("Damage Dealt: 36")
	assert_str(hud.get_menu_subtitle()).contains("Damage Taken: 80")
	assert_str(hud.get_menu_subtitle()).contains("Dodge: 25%  Parry: 0%")
	assert_str(hud.get_menu_subtitle()).contains("Dodge earlier when the beast crouches.")


func test_show_battle_summary_generates_learning_tip_when_missing() -> void:
	hud.show_battle_summary({
		"duration_sec": 9.0,
		"damage_dealt": 12,
		"damage_received": 40,
		"dodge_success_rate": 0.1,
		"parry_success_rate": 0.2,
	})

	assert_str(hud.get_menu_subtitle()).contains("Dodge a little earlier")


func _on_menu_resume_requested() -> void:
	_resume_requests += 1


func _on_menu_retry_requested() -> void:
	_retry_requests += 1
