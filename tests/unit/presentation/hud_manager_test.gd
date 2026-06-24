## HUDManager presentation behavior tests.
extends GdUnitTestSuite

const HUD_MANAGER_SCRIPT: Script = preload("res://src/presentation/hud_manager.gd")

var hud
var _resume_requests: int = 0
var _retry_requests: int = 0
var _settings_requests: int = 0
var _new_game_requests: int = 0
var _continue_requests: int = 0
var _load_menu_requests: int = 0
var _exit_requests: int = 0
var _save_slot_requests: Array[int] = []
var _load_slot_requests: Array[int] = []


func before_test() -> void:
	hud = HUD_MANAGER_SCRIPT.new()
	add_child(hud)
	_resume_requests = 0
	_retry_requests = 0
	_settings_requests = 0
	_new_game_requests = 0
	_continue_requests = 0
	_load_menu_requests = 0
	_exit_requests = 0
	_save_slot_requests.clear()
	_load_slot_requests.clear()
	hud.menu_resume_requested.connect(_on_menu_resume_requested)
	hud.menu_retry_requested.connect(_on_menu_retry_requested)
	hud.menu_settings_requested.connect(_on_menu_settings_requested)


func after_test() -> void:
	if is_instance_valid(hud):
		if hud.get_parent() != null:
			hud.get_parent().remove_child(hud)
		hud.free()
	hud = null
	_resume_requests = 0
	_retry_requests = 0
	_settings_requests = 0
	_new_game_requests = 0
	_continue_requests = 0
	_load_menu_requests = 0
	_exit_requests = 0
	_save_slot_requests.clear()
	_load_slot_requests.clear()


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
	assert_str(hud.get_settings_button_text()).is_equal("Settings")
	assert_str(hud.get_retry_button_text()).is_equal("Retry Encounter")
	assert_str(hud.get_focused_menu_button_text()).is_equal("Resume")
	assert_bool(hud.are_menu_buttons_focusable()).is_true()


func test_menu_buttons_emit_resume_and_retry_requests() -> void:
	hud.show_pause_menu()

	hud.get_node("HudRoot/MenuOverlay/MenuPanel/MenuContent/MenuButtons/ResumeButton").pressed.emit()
	hud.get_node("HudRoot/MenuOverlay/MenuPanel/MenuContent/MenuButtons/SettingsButton").pressed.emit()
	hud.get_node("HudRoot/MenuOverlay/MenuPanel/MenuContent/MenuButtons/RetryButton").pressed.emit()

	assert_int(_resume_requests).is_equal(1)
	assert_int(_settings_requests).is_equal(1)
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


func test_show_settings_menu_exposes_required_groups_and_focusable_controls() -> void:
	hud.show_settings_menu(&"pause")

	assert_bool(hud.is_menu_visible()).is_true()
	assert_str(String(hud.get_menu_mode())).is_equal("settings")
	assert_str(hud.get_menu_title()).is_equal("Settings")
	assert_array(hud.get_settings_group_names()).is_equal([
		"Audio",
		"Display",
		"Controls",
		"Gameplay",
	])
	assert_bool(hud.are_settings_controls_focusable()).is_true()
	assert_str(hud.get_focused_menu_button_text()).is_equal("Back")


func test_settings_toggles_hud_scale_and_colorblind_palette_update_runtime_state() -> void:
	hud.set_battle_summary_enabled(true)
	hud.set_damage_numbers_enabled(false)
	hud.set_hud_scale(1.5)
	hud.set_colorblind_mode(&"red_green")
	hud.update_hp(20, 100)

	assert_bool(hud.is_battle_summary_enabled()).is_true()
	assert_bool(hud.are_damage_numbers_enabled()).is_false()
	assert_float(hud.get_hud_scale()).is_equal_approx(1.5, 0.001)
	assert_bool(hud.has_core_hud_overlap()).is_false()
	assert_str(hud.get_hp_label_text()).is_equal("20 / 100")
	assert_str(hud.get_hp_color().to_html(false)).is_equal("f6e05e")

	hud.set_hud_scale(2.0)

	assert_float(hud.get_hud_scale()).is_equal_approx(1.5, 0.001)

	hud.set_hud_scale(0.25)

	assert_float(hud.get_hud_scale()).is_equal_approx(0.5, 0.001)


func test_blue_yellow_colorblind_palette_uses_red_to_white_hp_mapping() -> void:
	hud.set_colorblind_mode(&"blue_yellow")
	hud.update_hp(100, 100)

	assert_str(hud.get_hp_color().to_html(false)).is_equal("e53e3e")

	hud.update_hp(20, 100)

	assert_str(hud.get_hp_color().to_html(false)).is_equal("ffffff")


func test_scaled_settings_menu_text_does_not_overlap_at_max_hud_scale() -> void:
	assert_bool(hud.has_method("has_menu_text_overlap")).is_true()
	assert_bool(hud.has_method("get_menu_title_font_size")).is_true()
	if not hud.has_method("has_menu_text_overlap"):
		return
	if not hud.has_method("get_menu_title_font_size"):
		return

	hud.set_hud_scale(1.5)
	hud.show_settings_menu(&"pause")

	assert_int(int(hud.call("get_menu_title_font_size"))).is_greater_equal(42)
	assert_bool(bool(hud.call("has_menu_text_overlap"))).is_false()


func test_runtime_hud_scale_change_resizes_visible_settings_menu() -> void:
	hud.show_settings_menu(&"pause")
	var menu_panel: PanelContainer = hud.get_node("HudRoot/MenuOverlay/MenuPanel") as PanelContainer
	var base_size: Vector2 = menu_panel.size

	hud.set_hud_scale(1.5)

	assert_bool(menu_panel.size.x > base_size.x).is_true()
	assert_bool(menu_panel.size.y > base_size.y).is_true()
	assert_bool(bool(hud.call("has_menu_text_overlap"))).is_false()


func test_all_menu_modes_keep_text_non_overlapping_at_max_hud_scale() -> void:
	hud.set_hud_scale(1.5)

	hud.show_pause_menu()
	assert_bool(bool(hud.call("has_menu_text_overlap"))).is_false()

	hud.show_retry_menu("Shadow beast defeated", "Retry the encounter or stay with your prize.")
	assert_bool(bool(hud.call("has_menu_text_overlap"))).is_false()

	hud.show_battle_summary({
		"duration_sec": 18.4,
		"damage_dealt": 36,
		"damage_received": 80,
		"dodge_success_rate": 0.25,
		"parry_success_rate": 0.0,
		"tip": "Dodge earlier when the beast crouches.",
	})
	assert_bool(bool(hud.call("has_menu_text_overlap"))).is_false()

	hud.show_settings_menu(&"pause")
	assert_bool(bool(hud.call("has_menu_text_overlap"))).is_false()


func test_boss_phase_marker_uses_text_shape_not_only_color() -> void:
	assert_bool(hud.has_method("get_boss_phase_marker_text")).is_true()
	if not hud.has_method("get_boss_phase_marker_text"):
		return

	hud.update_boss_hp(90, 100, 1, "Shadow Beast")
	assert_str(String(hud.call("get_boss_phase_marker_text"))).is_equal("I")

	hud.update_boss_hp(50, 100, 2, "Shadow Beast")
	assert_str(String(hud.call("get_boss_phase_marker_text"))).is_equal("II")
	assert_str(hud.get_boss_label_text()).contains("Phase II")

	hud.update_boss_hp(30, 100, 3, "Shadow Beast")
	assert_str(String(hud.call("get_boss_phase_marker_text"))).is_equal("III")

	hud.update_boss_hp(10, 100, 4, "Shadow Beast")
	assert_str(String(hud.call("get_boss_phase_marker_text"))).is_equal("4")


func test_hud_settings_state_round_trip_hands_off_to_save_system() -> void:
	assert_bool(hud.has_method("capture_settings_state")).is_true()
	assert_bool(hud.has_method("restore_settings_state")).is_true()
	if not hud.has_method("capture_settings_state") or not hud.has_method("restore_settings_state"):
		return

	hud.set_hud_scale(1.5)
	hud.set_colorblind_mode(&"blue_yellow")
	hud.set_battle_summary_enabled(true)
	hud.set_damage_numbers_enabled(false)
	var snapshot: Dictionary = hud.call("capture_settings_state")
	var serialized: String = JSON.stringify(snapshot)

	assert_float(float(snapshot.get("hud_scale", 0.0))).is_equal_approx(1.5, 0.001)
	assert_str(String(snapshot.get("colorblind_mode", ""))).is_equal("blue_yellow")
	assert_bool(bool(snapshot.get("battle_summary_enabled", false))).is_true()
	assert_bool(bool(snapshot.get("damage_numbers_enabled", true))).is_false()
	assert_bool(serialized.contains("\"hud_scale\"")).is_true()

	var restored = HUD_MANAGER_SCRIPT.new()
	add_child(restored)
	restored.call("restore_settings_state", {
		"hud_scale": 9.0,
		"colorblind_mode": "invalid",
		"battle_summary_enabled": true,
		"damage_numbers_enabled": false,
	})

	assert_float(restored.get_hud_scale()).is_equal_approx(1.5, 0.001)
	assert_str(String(restored.get_colorblind_mode())).is_equal("none")

	restored.call("restore_settings_state", snapshot)

	assert_float(restored.get_hud_scale()).is_equal_approx(1.5, 0.001)
	assert_str(String(restored.get_colorblind_mode())).is_equal("blue_yellow")
	assert_bool(restored.is_battle_summary_enabled()).is_true()
	assert_bool(restored.are_damage_numbers_enabled()).is_false()

	restored.queue_free()


func test_close_settings_returns_to_invoking_pause_menu_focus() -> void:
	hud.show_pause_menu()
	hud.get_node("HudRoot/MenuOverlay/MenuPanel/MenuContent/MenuButtons/SettingsButton").grab_focus()

	hud.show_settings_menu(&"pause")
	hud.close_settings_menu()

	assert_bool(hud.is_menu_visible()).is_true()
	assert_str(String(hud.get_menu_mode())).is_equal("pause")
	assert_str(hud.get_focused_menu_button_text()).is_equal("Settings")


func test_close_settings_returns_to_invoking_main_menu_focus() -> void:
	hud.call("show_main_menu", [])
	hud.get_node("HudRoot/MenuOverlay/MenuPanel/MenuContent/MenuButtons/SettingsButton").grab_focus()

	hud.show_settings_menu(StringName(String(hud.get_menu_mode())))
	hud.close_settings_menu()

	assert_bool(hud.is_menu_visible()).is_true()
	assert_str(String(hud.get_menu_mode())).is_equal("main_menu")
	assert_array(Array(hud.call("get_menu_button_texts"))).is_equal([
		"New Game",
		"Continue",
		"Load Game",
		"Settings",
		"Exit",
	])
	assert_str(hud.get_focused_menu_button_text()).is_equal("Settings")


func test_main_menu_shows_entry_points_and_disabled_save_actions_explain_availability() -> void:
	assert_bool(hud.has_method("show_main_menu")).is_true()
	assert_bool(hud.has_method("get_menu_button_texts")).is_true()
	assert_bool(hud.has_method("get_disabled_menu_button_reasons")).is_true()
	if (
		not hud.has_method("show_main_menu")
		or not hud.has_method("get_menu_button_texts")
		or not hud.has_method("get_disabled_menu_button_reasons")
	):
		return
	assert_bool(hud.has_signal("menu_new_game_requested")).is_true()
	assert_bool(hud.has_signal("menu_continue_requested")).is_true()
	assert_bool(hud.has_signal("menu_load_menu_requested")).is_true()
	assert_bool(hud.has_signal("menu_exit_requested")).is_true()
	if not (
		hud.has_signal("menu_new_game_requested")
		and hud.has_signal("menu_continue_requested")
		and hud.has_signal("menu_load_menu_requested")
		and hud.has_signal("menu_exit_requested")
	):
		return
	hud.connect("menu_new_game_requested", _on_menu_new_game_requested)
	hud.connect("menu_continue_requested", _on_menu_continue_requested)
	hud.connect("menu_load_menu_requested", _on_menu_load_menu_requested)
	hud.connect("menu_exit_requested", _on_menu_exit_requested)

	hud.call("show_main_menu", [])

	assert_bool(hud.is_menu_visible()).is_true()
	assert_str(String(hud.get_menu_mode())).is_equal("main_menu")
	assert_str(hud.get_menu_title()).is_equal("Cinderpaw")
	assert_array(Array(hud.call("get_menu_button_texts"))).is_equal([
		"New Game",
		"Continue",
		"Load Game",
		"Settings",
		"Exit",
	])
	assert_str(hud.get_focused_menu_button_text()).is_equal("New Game")
	var disabled_reasons: Dictionary = Dictionary(hud.call("get_disabled_menu_button_reasons"))
	assert_str(String(disabled_reasons.get("Continue", ""))).is_equal("No save file available")
	assert_str(String(disabled_reasons.get("Load Game", ""))).is_equal("No save file available")

	hud.get_node("HudRoot/MenuOverlay/MenuPanel/MenuContent/MenuButtons/NewGameButton").pressed.emit()
	hud.get_node("HudRoot/MenuOverlay/MenuPanel/MenuContent/MenuButtons/SettingsButton").pressed.emit()
	hud.get_node("HudRoot/MenuOverlay/MenuPanel/MenuContent/MenuButtons/ExitButton").pressed.emit()

	assert_int(_new_game_requests).is_equal(1)
	assert_int(_settings_requests).is_equal(1)
	assert_int(_exit_requests).is_equal(1)


func test_save_load_shell_lists_slot_info_without_owning_save_file_rules() -> void:
	assert_bool(hud.has_method("show_save_load_menu")).is_true()
	assert_bool(hud.has_method("get_save_slot_labels")).is_true()
	assert_bool(hud.has_method("get_disabled_menu_button_reasons")).is_true()
	if (
		not hud.has_method("show_save_load_menu")
		or not hud.has_method("get_save_slot_labels")
		or not hud.has_method("get_disabled_menu_button_reasons")
	):
		return
	assert_bool(hud.has_signal("menu_save_slot_requested")).is_true()
	assert_bool(hud.has_signal("menu_load_slot_requested")).is_true()
	if not hud.has_signal("menu_save_slot_requested") or not hud.has_signal("menu_load_slot_requested"):
		return
	hud.connect("menu_save_slot_requested", _on_menu_save_slot_requested)
	hud.connect("menu_load_slot_requested", _on_menu_load_slot_requested)

	hud.call("show_save_load_menu", [
		{
			"slot": 0,
			"is_auto": true,
			"exists": false,
			"save_point_name": "",
			"summary": {},
			"timestamp": "",
		},
		{
			"slot": 1,
			"is_auto": false,
			"exists": true,
			"save_point_name": "Manual Save",
			"summary": {
				"current_hp": 78,
				"current_weapon": "long_tail",
				"currency": 11,
			},
			"timestamp": "2026-06-24T09:00:00Z",
		},
	], false, "Saving requires a save point")

	assert_bool(hud.is_menu_visible()).is_true()
	assert_str(String(hud.get_menu_mode())).is_equal("save_load")
	assert_str(hud.get_menu_title()).is_equal("Save / Load")
	assert_array(Array(hud.call("get_save_slot_labels"))).is_equal([
		"Autosave: Empty",
		"Slot 1: Manual Save | HP 78 | long_tail | Gears 11",
	])
	var disabled_reasons: Dictionary = Dictionary(hud.call("get_disabled_menu_button_reasons"))
	assert_str(String(disabled_reasons.get("Save Slot 1", ""))).is_equal("Saving requires a save point")
	assert_str(String(disabled_reasons.get("Load Autosave", ""))).is_equal("No autosave available")

	hud.get_node("HudRoot/MenuOverlay/MenuPanel/MenuContent/MenuButtons/LoadSlot1Button").pressed.emit()

	assert_array(_load_slot_requests).is_equal([1])
	assert_array(_save_slot_requests).is_empty()


func _on_menu_resume_requested() -> void:
	_resume_requests += 1


func _on_menu_retry_requested() -> void:
	_retry_requests += 1


func _on_menu_settings_requested() -> void:
	_settings_requests += 1


func _on_menu_new_game_requested() -> void:
	_new_game_requests += 1


func _on_menu_continue_requested() -> void:
	_continue_requests += 1


func _on_menu_load_menu_requested() -> void:
	_load_menu_requests += 1


func _on_menu_exit_requested() -> void:
	_exit_requests += 1


func _on_menu_save_slot_requested(slot: int) -> void:
	_save_slot_requests.append(slot)


func _on_menu_load_slot_requested(slot: int) -> void:
	_load_slot_requests.append(slot)
