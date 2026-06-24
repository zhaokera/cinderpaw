## Presentation-layer combat HUD for the playable vertical slice.
extends CanvasLayer
class_name HUDManager

signal menu_pause_requested
signal menu_resume_requested
signal menu_retry_requested
signal menu_settings_requested

const HP_HEALTHY_COLOR: Color = Color("#ECC94B")
const HP_MID_COLOR: Color = Color("#D9B84A")
const HP_LOW_COLOR: Color = Color("#F97316")
const HP_CRITICAL_COLOR: Color = Color("#E53E3E")
const HP_RG_HEALTHY_COLOR: Color = Color("#2B6CB0")
const HP_RG_MID_COLOR: Color = Color("#4299E1")
const HP_RG_LOW_COLOR: Color = Color("#D69E2E")
const HP_RG_CRITICAL_COLOR: Color = Color("#F6E05E")
const HP_BY_HEALTHY_COLOR: Color = Color("#E53E3E")
const HP_BY_MID_COLOR: Color = Color("#F97316")
const HP_BY_LOW_COLOR: Color = Color("#FED7D7")
const HP_BY_CRITICAL_COLOR: Color = Color("#FFFFFF")
const PANEL_COLOR: Color = Color(0.10, 0.10, 0.18, 0.72)
const BORDER_COLOR: Color = Color("#6B8A9E")
const TEXT_COLOR: Color = Color("#E8E4DC")
const MENU_OVERLAY_COLOR: Color = Color(0.03, 0.03, 0.06, 0.72)
const MENU_NONE: StringName = &"none"
const MENU_PAUSE: StringName = &"pause"
const MENU_RETRY: StringName = &"retry"
const MENU_BATTLE_SUMMARY: StringName = &"battle_summary"
const MENU_SETTINGS: StringName = &"settings"
const COLORBLIND_NONE: StringName = &"none"
const COLORBLIND_RED_GREEN: StringName = &"red_green"
const COLORBLIND_BLUE_YELLOW: StringName = &"blue_yellow"
const SETTINGS_GROUPS: Array[String] = ["Audio", "Display", "Controls", "Gameplay"]
const HUD_VIEWPORT_SIZE: Vector2 = Vector2(1280, 720)
const HUD_BOTTOM_MARGIN: float = 28.0
const HUD_TOP_MARGIN: float = 28.0
const HUD_SIDE_MARGIN: float = 32.0
const PLAYER_PANEL_BASE_SIZE: Vector2 = Vector2(250, 56)
const WEAPON_PANEL_BASE_SIZE: Vector2 = Vector2(194, 66)
const CURRENCY_PANEL_BASE_SIZE: Vector2 = Vector2(160, 38)
const BOSS_PANEL_BASE_SIZE: Vector2 = Vector2(440, 54)
const MENU_TITLE_BASE_FONT_SIZE: int = 28
const MENU_BODY_BASE_FONT_SIZE: int = 16
const MENU_CONTROL_BASE_FONT_SIZE: int = 16

var _hp_ratio: float = 1.0
var _hp_color: Color = HP_HEALTHY_COLOR
var _notification_remaining_sec: float = 0.0
var _menu_mode: StringName = MENU_NONE
var _settings_return_menu: StringName = MENU_NONE
var _battle_summary_enabled: bool = false
var _damage_numbers_enabled: bool = true
var _hud_scale: float = 1.0
var _colorblind_mode: StringName = COLORBLIND_NONE
var _boss_phase_marker_text: String = "I"

var _root: Control
var _player_panel: PanelContainer
var _hp_bar: ProgressBar
var _hp_label: Label
var _boss_panel: PanelContainer
var _boss_bar: ProgressBar
var _boss_label: Label
var _weapon_panel: PanelContainer
var _weapon_label: Label
var _currency_panel: PanelContainer
var _currency_label: Label
var _notification_label: Label
var _menu_overlay: ColorRect
var _menu_panel: PanelContainer
var _menu_content: VBoxContainer
var _settings_box: VBoxContainer
var _menu_title_label: Label
var _menu_subtitle_label: Label
var _resume_button: Button
var _settings_button: Button
var _retry_button: Button
var _master_volume_slider: HSlider
var _hud_scale_slider: HSlider
var _colorblind_option: OptionButton
var _controls_remap_button: Button
var _battle_summary_checkbox: CheckBox
var _damage_numbers_checkbox: CheckBox


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_layout()
	update_hp(100, 100)
	update_weapon(&"Cat Claw", 0.0)
	update_currency(0)
	hide_boss_hp()
	show_notification("", 0.0)


func _process(delta: float) -> void:
	advance_time(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_menu_visible():
			menu_resume_requested.emit()
		else:
			menu_pause_requested.emit()
		get_viewport().set_input_as_handled()


## Updates the player HP strip. The low-HP state is stable red and does not pulse.
func update_hp(current_hp: int, max_hp: int) -> void:
	var safe_max_hp: int = maxi(1, max_hp)
	var safe_current_hp: int = clampi(current_hp, 0, safe_max_hp)
	_hp_ratio = float(safe_current_hp) / float(safe_max_hp)
	_hp_color = _hp_color_for_ratio(_hp_ratio)

	if _hp_bar != null:
		_hp_bar.max_value = safe_max_hp
		_hp_bar.value = safe_current_hp
		_apply_progress_color(_hp_bar, _hp_color)
	if _hp_label != null:
		_hp_label.text = "%d / %d" % [safe_current_hp, safe_max_hp]


## Updates the top-center enemy or boss HP strip.
func update_boss_hp(current_hp: int, max_hp: int, phase: int = 1, display_name: String = "Target") -> void:
	var safe_max_hp: int = maxi(1, max_hp)
	var safe_current_hp: int = clampi(current_hp, 0, safe_max_hp)
	_boss_phase_marker_text = _phase_marker_for_phase(maxi(1, phase))
	if _boss_panel != null:
		_boss_panel.visible = safe_current_hp > 0
	if _boss_bar != null:
		_boss_bar.max_value = safe_max_hp
		_boss_bar.value = safe_current_hp
		_apply_progress_color(_boss_bar, HP_CRITICAL_COLOR)
	if _boss_label != null:
		_boss_label.text = "%s  Phase %s  %d/%d" % [
			display_name,
			_boss_phase_marker_text,
			safe_current_hp,
			safe_max_hp,
		]


func hide_boss_hp() -> void:
	if _boss_panel != null:
		_boss_panel.visible = false


func update_weapon(display_name: StringName, cooldown_ratio: float) -> void:
	if _weapon_label == null:
		return
	var normalized_cooldown: float = clampf(cooldown_ratio, 0.0, 1.0)
	_weapon_label.text = "%s\nSpecial %.0f%%" % [
		String(display_name),
		normalized_cooldown * 100.0,
	]


func update_currency(amount: int) -> void:
	if _currency_label != null:
		_currency_label.text = "Gears %d" % maxi(0, amount)


func show_notification(text: String, duration_sec: float = 2.0) -> void:
	_notification_remaining_sec = maxf(0.0, duration_sec)
	if _notification_label == null:
		return
	_notification_label.text = text
	_notification_label.visible = text.strip_edges() != "" and _notification_remaining_sec > 0.0


## Displays the pause menu and gives keyboard/gamepad focus to Resume.
func show_pause_menu() -> void:
	_show_menu(MENU_PAUSE, "Paused", "Take a breath. The wasteland waits.", "Resume")


## Displays an encounter retry menu for victory, defeat, or battle-summary routes.
func show_retry_menu(title: String, subtitle: String) -> void:
	_show_menu(MENU_RETRY, title, subtitle, "Continue")


## Displays the optional death lesson panel from battle summary metadata.
func show_battle_summary(battle_summary: Dictionary) -> void:
	_show_menu(
		MENU_BATTLE_SUMMARY,
		"Hunter's Lesson",
		_format_battle_summary(battle_summary),
		"Skip Lesson",
		"Retry Encounter"
	)


## Displays settings controls grouped by audio, display, controls, and gameplay.
func show_settings_menu(invoking_menu: StringName = MENU_PAUSE) -> void:
	_settings_return_menu = invoking_menu
	_menu_mode = MENU_SETTINGS
	if _menu_overlay == null:
		return
	_resize_menu_panel(true)
	_settings_box.visible = true
	_menu_title_label.text = "Settings"
	_menu_subtitle_label.text = "Tune audio, display, controls, and gameplay."
	_resume_button.text = "Back"
	_resume_button.visible = true
	_settings_button.visible = false
	_retry_button.visible = false
	_sync_settings_controls()
	_menu_overlay.visible = true
	_resume_button.grab_focus()


## Closes settings and restores focus to the menu that opened it.
func close_settings_menu() -> void:
	var return_menu: StringName = _settings_return_menu
	if return_menu == MENU_PAUSE:
		show_pause_menu()
		if _settings_button != null:
			_settings_button.grab_focus()
		return
	hide_menu()


## Hides the active menu overlay and releases menu button focus.
func hide_menu() -> void:
	_menu_mode = MENU_NONE
	_settings_return_menu = MENU_NONE
	if _menu_overlay != null:
		_menu_overlay.visible = false
	if _settings_box != null:
		_settings_box.visible = false
	if _resume_button != null:
		_resume_button.release_focus()
	if _settings_button != null:
		_settings_button.release_focus()
	if _retry_button != null:
		_retry_button.release_focus()


func advance_time(delta_sec: float) -> void:
	if _notification_remaining_sec <= 0.0:
		return
	_notification_remaining_sec = maxf(0.0, _notification_remaining_sec - maxf(0.0, delta_sec))
	if _notification_remaining_sec <= 0.0 and _notification_label != null:
		_notification_label.visible = false


func get_hp_ratio() -> float:
	return _hp_ratio


func get_hp_label_text() -> String:
	if _hp_label == null:
		return ""
	return _hp_label.text


func get_hp_color() -> Color:
	return _hp_color


func is_low_hp_pulsing_enabled() -> bool:
	return false


func is_notification_visible() -> bool:
	return _notification_label != null and _notification_label.visible


func get_notification_text() -> String:
	if _notification_label == null:
		return ""
	return _notification_label.text


func get_weapon_label_text() -> String:
	if _weapon_label == null:
		return ""
	return _weapon_label.text


func get_boss_label_text() -> String:
	if _boss_label == null:
		return ""
	return _boss_label.text


func get_boss_phase_marker_text() -> String:
	return _boss_phase_marker_text


## Returns whether a pause/retry menu overlay is currently visible.
func is_menu_visible() -> bool:
	return _menu_overlay != null and _menu_overlay.visible


## Returns the active menu mode for diagnostics and integration tests.
func get_menu_mode() -> StringName:
	return _menu_mode


## Returns the current menu title text.
func get_menu_title() -> String:
	if _menu_title_label == null:
		return ""
	return _menu_title_label.text


## Returns the current menu body text.
func get_menu_subtitle() -> String:
	if _menu_subtitle_label == null:
		return ""
	return _menu_subtitle_label.text


## Returns the first menu button text.
func get_resume_button_text() -> String:
	if _resume_button == null:
		return ""
	return _resume_button.text


## Returns the second menu button text.
func get_retry_button_text() -> String:
	if _retry_button == null:
		return ""
	return _retry_button.text


## Returns the settings button text for menu tests and focus restoration.
func get_settings_button_text() -> String:
	if _settings_button == null:
		return ""
	return _settings_button.text


## Returns the focused menu button text, or the default first button fallback.
func get_focused_menu_button_text() -> String:
	if not is_menu_visible():
		return ""
	var focus_owner: Control = get_viewport().gui_get_focus_owner()
	if focus_owner is Button:
		return (focus_owner as Button).text
	if _resume_button != null:
		return _resume_button.text
	return ""


## Returns true when menu controls support keyboard/gamepad focus.
func are_menu_buttons_focusable() -> bool:
	return (
		_resume_button != null
		and _settings_button != null
		and _retry_button != null
		and _resume_button.focus_mode == Control.FOCUS_ALL
		and _settings_button.focus_mode == Control.FOCUS_ALL
		and _retry_button.focus_mode == Control.FOCUS_ALL
	)


func get_settings_group_names() -> Array[String]:
	var result: Array[String] = []
	result.assign(SETTINGS_GROUPS)
	return result


func are_settings_controls_focusable() -> bool:
	return (
		_resume_button != null
		and _master_volume_slider != null
		and _hud_scale_slider != null
		and _colorblind_option != null
		and _controls_remap_button != null
		and _battle_summary_checkbox != null
		and _damage_numbers_checkbox != null
		and _resume_button.focus_mode == Control.FOCUS_ALL
		and _master_volume_slider.focus_mode == Control.FOCUS_ALL
		and _hud_scale_slider.focus_mode == Control.FOCUS_ALL
		and _colorblind_option.focus_mode == Control.FOCUS_ALL
		and _controls_remap_button.focus_mode == Control.FOCUS_ALL
		and _battle_summary_checkbox.focus_mode == Control.FOCUS_ALL
		and _damage_numbers_checkbox.focus_mode == Control.FOCUS_ALL
	)


func set_battle_summary_enabled(enabled: bool) -> void:
	_battle_summary_enabled = enabled
	if _battle_summary_checkbox != null:
		_battle_summary_checkbox.set_pressed_no_signal(enabled)


func is_battle_summary_enabled() -> bool:
	return _battle_summary_enabled


func set_damage_numbers_enabled(enabled: bool) -> void:
	_damage_numbers_enabled = enabled
	if _damage_numbers_checkbox != null:
		_damage_numbers_checkbox.set_pressed_no_signal(enabled)


func are_damage_numbers_enabled() -> bool:
	return _damage_numbers_enabled


func set_hud_scale(hud_scale_value: float) -> void:
	_hud_scale = clampf(hud_scale_value, 0.5, 1.5)
	if _hud_scale_slider != null:
		_hud_scale_slider.set_value_no_signal(_hud_scale * 100.0)
	_apply_hud_scale_layout()
	if is_menu_visible():
		_resize_menu_panel(_menu_mode == MENU_SETTINGS)


func get_hud_scale() -> float:
	return _hud_scale


func set_colorblind_mode(mode: StringName) -> void:
	if mode != COLORBLIND_RED_GREEN and mode != COLORBLIND_BLUE_YELLOW:
		mode = COLORBLIND_NONE
	_colorblind_mode = mode
	if _colorblind_option != null:
		_colorblind_option.select(_colorblind_index_for_mode(mode))
	_hp_color = _hp_color_for_ratio(_hp_ratio)
	if _hp_bar != null:
		_apply_progress_color(_hp_bar, _hp_color)


func get_colorblind_mode() -> StringName:
	return _colorblind_mode


func capture_settings_state() -> Dictionary:
	return {
		"hud_scale": _hud_scale,
		"colorblind_mode": String(_colorblind_mode),
		"battle_summary_enabled": _battle_summary_enabled,
		"damage_numbers_enabled": _damage_numbers_enabled,
	}


func restore_settings_state(settings_state: Dictionary) -> void:
	set_hud_scale(float(settings_state.get("hud_scale", _hud_scale)))
	set_colorblind_mode(StringName(String(settings_state.get(
		"colorblind_mode",
		String(_colorblind_mode)
	))))
	set_battle_summary_enabled(bool(settings_state.get(
		"battle_summary_enabled",
		_battle_summary_enabled
	)))
	set_damage_numbers_enabled(bool(settings_state.get(
		"damage_numbers_enabled",
		_damage_numbers_enabled
	)))


func has_core_hud_overlap() -> bool:
	var rects: Array[Rect2] = get_core_hud_rects()
	for left_index: int in range(rects.size()):
		for right_index: int in range(left_index + 1, rects.size()):
			if rects[left_index].intersects(rects[right_index], false):
				return true
	return false


func get_core_hud_rects() -> Array[Rect2]:
	var rects: Array[Rect2] = []
	for panel: PanelContainer in [_player_panel, _weapon_panel, _currency_panel, _boss_panel]:
		if panel != null and panel.visible:
			rects.append(Rect2(panel.position, panel.size))
	return rects


func has_menu_text_overlap() -> bool:
	if _menu_panel == null or not is_menu_visible():
		return false
	var required_height: float = 0.0
	var visible_blocks: int = 0
	for block: Control in [_menu_title_label, _menu_subtitle_label, _settings_box]:
		if block != null and block.visible:
			required_height += block.custom_minimum_size.y
			visible_blocks += 1
	var buttons_height: float = _visible_menu_buttons_height()
	if buttons_height > 0.0:
		required_height += buttons_height
		visible_blocks += 1
	var separation: float = 0.0
	if _menu_content != null:
		separation = float(_menu_content.get_theme_constant("separation"))
	required_height += maxf(0.0, float(visible_blocks - 1)) * separation
	var usable_height: float = maxf(0.0, _menu_panel.size.y - 32.0)
	return required_height > usable_height


func get_menu_title_font_size() -> int:
	if _menu_title_label == null:
		return 0
	return _menu_title_label.get_theme_font_size("font_size")


func _build_layout() -> void:
	if _root != null:
		return
	_root = Control.new()
	_root.name = "HudRoot"
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	_build_player_hp_panel()
	_build_weapon_panel()
	_build_currency_panel()
	_build_boss_panel()
	_build_notification_label()
	_build_menu_overlay()
	_apply_hud_scale_layout()


func _build_player_hp_panel() -> void:
	var panel := _new_panel("PlayerHudPanel")
	_player_panel = panel
	panel.position = Vector2(32, 636)
	panel.size = Vector2(250, 56)
	_root.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)

	var title := Label.new()
	title.text = "Cinderpaw"
	title.add_theme_color_override("font_color", TEXT_COLOR)
	box.add_child(title)

	_hp_bar = ProgressBar.new()
	_hp_bar.custom_minimum_size = Vector2(210, 16)
	_hp_bar.show_percentage = false
	box.add_child(_hp_bar)

	_hp_label = Label.new()
	_hp_label.add_theme_color_override("font_color", TEXT_COLOR)
	box.add_child(_hp_label)


func _build_weapon_panel() -> void:
	var panel := _new_panel("WeaponHudPanel")
	_weapon_panel = panel
	panel.position = Vector2(1054, 626)
	panel.size = Vector2(194, 66)
	_root.add_child(panel)

	_weapon_label = Label.new()
	_weapon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_weapon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_weapon_label.add_theme_color_override("font_color", TEXT_COLOR)
	panel.add_child(_weapon_label)


func _build_currency_panel() -> void:
	var panel := _new_panel("CurrencyHudPanel")
	_currency_panel = panel
	panel.position = Vector2(1088, 28)
	panel.size = Vector2(160, 38)
	_root.add_child(panel)

	_currency_label = Label.new()
	_currency_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_currency_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_currency_label.add_theme_color_override("font_color", TEXT_COLOR)
	panel.add_child(_currency_label)


func _build_boss_panel() -> void:
	_boss_panel = _new_panel("BossHudPanel")
	_boss_panel.position = Vector2(420, 26)
	_boss_panel.size = Vector2(440, 54)
	_root.add_child(_boss_panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	_boss_panel.add_child(box)

	_boss_label = Label.new()
	_boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_label.add_theme_color_override("font_color", TEXT_COLOR)
	box.add_child(_boss_label)

	_boss_bar = ProgressBar.new()
	_boss_bar.custom_minimum_size = Vector2(400, 14)
	_boss_bar.show_percentage = false
	box.add_child(_boss_bar)


func _build_notification_label() -> void:
	_notification_label = Label.new()
	_notification_label.name = "NotificationLabel"
	_notification_label.position = Vector2(390, 92)
	_notification_label.size = Vector2(500, 44)
	_notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_notification_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_notification_label.add_theme_color_override("font_color", HP_HEALTHY_COLOR)
	_notification_label.add_theme_font_size_override("font_size", 24)
	_root.add_child(_notification_label)


func _build_menu_overlay() -> void:
	_menu_overlay = ColorRect.new()
	_menu_overlay.name = "MenuOverlay"
	_menu_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_menu_overlay.color = MENU_OVERLAY_COLOR
	_menu_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_menu_overlay.visible = false
	_menu_overlay.focus_mode = Control.FOCUS_NONE
	_root.add_child(_menu_overlay)

	_menu_panel = _new_panel("MenuPanel")
	_menu_panel.position = Vector2(424, 188)
	_menu_panel.size = Vector2(432, 340)
	_menu_overlay.add_child(_menu_panel)

	_menu_content = VBoxContainer.new()
	_menu_content.name = "MenuContent"
	_menu_content.add_theme_constant_override("separation", 18)
	_menu_panel.add_child(_menu_content)

	_menu_title_label = Label.new()
	_menu_title_label.name = "MenuTitle"
	_menu_title_label.custom_minimum_size = Vector2(392, 44)
	_menu_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_menu_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_menu_title_label.add_theme_color_override("font_color", HP_HEALTHY_COLOR)
	_menu_title_label.add_theme_font_size_override("font_size", MENU_TITLE_BASE_FONT_SIZE)
	_menu_content.add_child(_menu_title_label)

	_menu_subtitle_label = Label.new()
	_menu_subtitle_label.name = "MenuSubtitle"
	_menu_subtitle_label.custom_minimum_size = Vector2(392, 118)
	_menu_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_menu_subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_menu_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_menu_subtitle_label.add_theme_color_override("font_color", TEXT_COLOR)
	_menu_subtitle_label.add_theme_font_size_override("font_size", MENU_BODY_BASE_FONT_SIZE)
	_menu_content.add_child(_menu_subtitle_label)

	_settings_box = VBoxContainer.new()
	_settings_box.name = "SettingsGroups"
	_settings_box.custom_minimum_size = Vector2(392, 224)
	_settings_box.add_theme_constant_override("separation", 10)
	_settings_box.visible = false
	_menu_content.add_child(_settings_box)
	_build_settings_controls()

	var button_box := VBoxContainer.new()
	button_box.name = "MenuButtons"
	button_box.custom_minimum_size = Vector2(240, 96)
	button_box.add_theme_constant_override("separation", 14)
	button_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_menu_content.add_child(button_box)

	_resume_button = _new_menu_button("ResumeButton", "Resume")
	_resume_button.pressed.connect(_on_resume_button_pressed)
	button_box.add_child(_resume_button)

	_settings_button = _new_menu_button("SettingsButton", "Settings")
	_settings_button.pressed.connect(_on_settings_button_pressed)
	button_box.add_child(_settings_button)

	_retry_button = _new_menu_button("RetryButton", "Retry Encounter")
	_retry_button.pressed.connect(_on_retry_button_pressed)
	button_box.add_child(_retry_button)


func _new_menu_button(node_name: String, button_text: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = button_text
	button.focus_mode = Control.FOCUS_ALL
	button.custom_minimum_size = Vector2(240, 38)
	button.add_theme_color_override("font_color", TEXT_COLOR)
	return button


func _build_settings_controls() -> void:
	_master_volume_slider = _new_settings_slider("MasterVolumeSlider", 0.0, 100.0, 100.0, 1.0)
	_settings_box.add_child(_new_settings_row("Audio", _master_volume_slider))

	var display_box := HBoxContainer.new()
	display_box.add_theme_constant_override("separation", 8)
	_hud_scale_slider = _new_settings_slider("HudScaleSlider", 50.0, 150.0, _hud_scale * 100.0, 5.0)
	_hud_scale_slider.value_changed.connect(_on_hud_scale_slider_changed)
	display_box.add_child(_hud_scale_slider)
	_colorblind_option = OptionButton.new()
	_colorblind_option.name = "ColorblindModeOption"
	_colorblind_option.focus_mode = Control.FOCUS_ALL
	_colorblind_option.custom_minimum_size = Vector2(126, 34)
	_colorblind_option.add_item("None")
	_colorblind_option.add_item("Red-Green")
	_colorblind_option.add_item("Blue-Yellow")
	_colorblind_option.item_selected.connect(_on_colorblind_option_selected)
	display_box.add_child(_colorblind_option)
	_settings_box.add_child(_new_settings_row("Display", display_box))

	_controls_remap_button = _new_menu_button("ControlsRemapButton", "Remap Inputs")
	_settings_box.add_child(_new_settings_row("Controls", _controls_remap_button))

	var gameplay_box := HBoxContainer.new()
	gameplay_box.add_theme_constant_override("separation", 8)
	_battle_summary_checkbox = CheckBox.new()
	_battle_summary_checkbox.name = "BattleSummaryToggle"
	_battle_summary_checkbox.text = "Battle Summary"
	_battle_summary_checkbox.focus_mode = Control.FOCUS_ALL
	_battle_summary_checkbox.add_theme_color_override("font_color", TEXT_COLOR)
	_battle_summary_checkbox.toggled.connect(set_battle_summary_enabled)
	gameplay_box.add_child(_battle_summary_checkbox)
	_damage_numbers_checkbox = CheckBox.new()
	_damage_numbers_checkbox.name = "DamageNumbersToggle"
	_damage_numbers_checkbox.text = "Damage Numbers"
	_damage_numbers_checkbox.focus_mode = Control.FOCUS_ALL
	_damage_numbers_checkbox.add_theme_color_override("font_color", TEXT_COLOR)
	_damage_numbers_checkbox.toggled.connect(set_damage_numbers_enabled)
	gameplay_box.add_child(_damage_numbers_checkbox)
	_settings_box.add_child(_new_settings_row("Gameplay", gameplay_box))
	_sync_settings_controls()


func _new_settings_row(group_name: String, control: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.name = "%sSettingsRow" % group_name
	row.custom_minimum_size = Vector2(392, 40)
	row.add_theme_constant_override("separation", 12)

	var label := Label.new()
	label.name = "%sSettingsLabel" % group_name
	label.text = group_name
	label.custom_minimum_size = Vector2(92, 34)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", HP_HEALTHY_COLOR)
	row.add_child(label)

	control.custom_minimum_size.x = maxf(control.custom_minimum_size.x, 220.0)
	row.add_child(control)
	return row


func _new_settings_slider(node_name: String, min_value: float, max_value: float, value: float, step: float) -> HSlider:
	var slider := HSlider.new()
	slider.name = node_name
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.value = value
	slider.focus_mode = Control.FOCUS_ALL
	slider.custom_minimum_size = Vector2(220, 34)
	return slider


func _new_panel(node_name: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = node_name
	panel.focus_mode = Control.FOCUS_NONE
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.border_color = BORDER_COLOR
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.content_margin_left = 12
	style.content_margin_top = 8
	style.content_margin_right = 12
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _apply_progress_color(bar: ProgressBar, fill_color: Color) -> void:
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.03, 0.03, 0.06, 0.95)
	background.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", background)

	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("fill", fill)


func _hp_color_for_ratio(ratio: float) -> Color:
	if _colorblind_mode == COLORBLIND_RED_GREEN:
		if ratio <= 0.25:
			return HP_RG_CRITICAL_COLOR
		if ratio <= 0.5:
			return HP_RG_LOW_COLOR
		if ratio <= 0.74:
			return HP_RG_MID_COLOR
		return HP_RG_HEALTHY_COLOR
	if _colorblind_mode == COLORBLIND_BLUE_YELLOW:
		if ratio <= 0.25:
			return HP_BY_CRITICAL_COLOR
		if ratio <= 0.5:
			return HP_BY_LOW_COLOR
		if ratio <= 0.74:
			return HP_BY_MID_COLOR
		return HP_BY_HEALTHY_COLOR
	if ratio <= 0.25:
		return HP_CRITICAL_COLOR
	if ratio <= 0.5:
		return HP_LOW_COLOR
	if ratio <= 0.74:
		return HP_MID_COLOR
	return HP_HEALTHY_COLOR


func _show_menu(
	mode: StringName,
	title: String,
	subtitle: String,
	resume_text: String,
	retry_text: String = "Retry Encounter"
) -> void:
	_menu_mode = mode
	if _menu_overlay == null:
		return
	_resize_menu_panel(false)
	if _settings_box != null:
		_settings_box.visible = false
	_menu_title_label.text = title
	_menu_subtitle_label.text = subtitle
	_resume_button.text = resume_text
	_resume_button.visible = true
	_settings_button.text = "Settings"
	_settings_button.visible = mode == MENU_PAUSE
	_retry_button.text = retry_text
	_retry_button.visible = true
	_menu_overlay.visible = true
	_resume_button.grab_focus()


func _format_battle_summary(battle_summary: Dictionary) -> String:
	var duration_sec: float = maxf(0.0, float(battle_summary.get("duration_sec", 0.0)))
	var damage_dealt: int = maxi(0, int(battle_summary.get("damage_dealt", 0)))
	var damage_received: int = maxi(0, int(battle_summary.get("damage_received", 0)))
	var dodge_rate: float = clampf(float(battle_summary.get("dodge_success_rate", 0.0)), 0.0, 1.0)
	var parry_rate: float = clampf(float(battle_summary.get("parry_success_rate", 0.0)), 0.0, 1.0)
	var tip: String = String(battle_summary.get("tip", "")).strip_edges()
	if tip == "":
		tip = _generate_battle_tip(dodge_rate, parry_rate)
	return "Duration: %.1fs\nDamage Dealt: %d\nDamage Taken: %d\nDodge: %.0f%%  Parry: %.0f%%\n%s" % [
		duration_sec,
		damage_dealt,
		damage_received,
		dodge_rate * 100.0,
		parry_rate * 100.0,
		tip,
	]


func _generate_battle_tip(dodge_rate: float, parry_rate: float) -> String:
	if dodge_rate < 0.5:
		return "Dodge a little earlier when the enemy winds up."
	if parry_rate < 0.3:
		return "Parry just before impact to turn pressure into a counter."
	return "Keep the rhythm: punish after the enemy's final swing."


func _sync_settings_controls() -> void:
	if _master_volume_slider != null:
		_master_volume_slider.set_value_no_signal(100.0)
	if _hud_scale_slider != null:
		_hud_scale_slider.set_value_no_signal(_hud_scale * 100.0)
	if _colorblind_option != null:
		_colorblind_option.select(_colorblind_index_for_mode(_colorblind_mode))
	if _battle_summary_checkbox != null:
		_battle_summary_checkbox.set_pressed_no_signal(_battle_summary_enabled)
	if _damage_numbers_checkbox != null:
		_damage_numbers_checkbox.set_pressed_no_signal(_damage_numbers_enabled)


func _resize_menu_panel(is_settings: bool) -> void:
	if _menu_panel == null:
		return
	var menu_scale: float = _menu_text_scale()
	if is_settings:
		_menu_panel.size = Vector2(
			496.0 + 72.0 * (menu_scale - 1.0),
			516.0 + 64.0 * (menu_scale - 1.0)
		)
		_menu_panel.position = Vector2(
			(HUD_VIEWPORT_SIZE.x - _menu_panel.size.x) * 0.5,
			maxf(48.0, (HUD_VIEWPORT_SIZE.y - _menu_panel.size.y) * 0.5)
		)
		if _menu_title_label != null:
			_menu_title_label.custom_minimum_size = Vector2(456, 42) * menu_scale
		if _menu_subtitle_label != null:
			_menu_subtitle_label.custom_minimum_size = Vector2(456, 46) * menu_scale
		_apply_menu_scale_layout()
		return
	_menu_panel.size = Vector2(
		432.0 + 88.0 * (menu_scale - 1.0),
		340.0 + 250.0 * (menu_scale - 1.0)
	)
	_menu_panel.position = Vector2(
		(HUD_VIEWPORT_SIZE.x - _menu_panel.size.x) * 0.5,
		(HUD_VIEWPORT_SIZE.y - _menu_panel.size.y) * 0.5
	)
	if _menu_title_label != null:
		_menu_title_label.custom_minimum_size = Vector2(392, 44) * menu_scale
	if _menu_subtitle_label != null:
		_menu_subtitle_label.custom_minimum_size = Vector2(392, 118) * menu_scale
	_apply_menu_scale_layout()


func _apply_hud_scale_layout() -> void:
	if _player_panel == null:
		return
	var hud_scale_value: float = _hud_scale
	var player_size: Vector2 = PLAYER_PANEL_BASE_SIZE * hud_scale_value
	var weapon_size: Vector2 = WEAPON_PANEL_BASE_SIZE * hud_scale_value
	var currency_size: Vector2 = CURRENCY_PANEL_BASE_SIZE * hud_scale_value
	var boss_size: Vector2 = BOSS_PANEL_BASE_SIZE * hud_scale_value

	_player_panel.size = player_size
	_player_panel.position = Vector2(HUD_SIDE_MARGIN, HUD_VIEWPORT_SIZE.y - HUD_BOTTOM_MARGIN - player_size.y)
	_weapon_panel.size = weapon_size
	_weapon_panel.position = Vector2(HUD_VIEWPORT_SIZE.x - HUD_SIDE_MARGIN - weapon_size.x, HUD_VIEWPORT_SIZE.y - HUD_BOTTOM_MARGIN - weapon_size.y)
	_currency_panel.size = currency_size
	_currency_panel.position = Vector2(HUD_VIEWPORT_SIZE.x - HUD_SIDE_MARGIN - currency_size.x, HUD_TOP_MARGIN)
	_boss_panel.size = boss_size
	_boss_panel.position = Vector2((HUD_VIEWPORT_SIZE.x - boss_size.x) * 0.5, 26.0)

	if _hp_bar != null:
		_hp_bar.custom_minimum_size = Vector2(210, 16) * hud_scale_value
	if _boss_bar != null:
		_boss_bar.custom_minimum_size = Vector2(400, 14) * hud_scale_value
	if _notification_label != null:
		_notification_label.position = Vector2((HUD_VIEWPORT_SIZE.x - 500.0 * hud_scale_value) * 0.5, 92.0 * hud_scale_value)
		_notification_label.size = Vector2(500, 44) * hud_scale_value
		_notification_label.add_theme_font_size_override("font_size", int(roundf(24.0 * hud_scale_value)))
	_apply_menu_scale_layout()


func _apply_menu_scale_layout() -> void:
	var menu_scale: float = _menu_text_scale()
	if _menu_title_label != null:
		_menu_title_label.add_theme_font_size_override(
			"font_size",
			int(roundf(MENU_TITLE_BASE_FONT_SIZE * menu_scale))
		)
	if _menu_subtitle_label != null:
		_menu_subtitle_label.add_theme_font_size_override(
			"font_size",
			int(roundf(MENU_BODY_BASE_FONT_SIZE * menu_scale))
		)
	for button: Button in [_resume_button, _settings_button, _retry_button, _controls_remap_button]:
		if button != null:
			button.add_theme_font_size_override(
				"font_size",
				int(roundf(MENU_CONTROL_BASE_FONT_SIZE * menu_scale))
			)
	for check_box: CheckBox in [_battle_summary_checkbox, _damage_numbers_checkbox]:
		if check_box != null:
			check_box.add_theme_font_size_override(
				"font_size",
				int(roundf(MENU_CONTROL_BASE_FONT_SIZE * menu_scale))
			)
	for label: Label in _get_settings_row_labels():
		label.add_theme_font_size_override(
			"font_size",
			int(roundf(MENU_BODY_BASE_FONT_SIZE * menu_scale))
		)


func _menu_text_scale() -> float:
	return clampf(_hud_scale, 0.5, 1.5)


func _visible_menu_buttons_height() -> float:
	var height: float = 0.0
	var visible_count: int = 0
	for button: Button in [_resume_button, _settings_button, _retry_button]:
		if button != null and button.visible:
			height += button.custom_minimum_size.y
			visible_count += 1
	if visible_count <= 1:
		return height
	return height + float(visible_count - 1) * 14.0


func _get_settings_row_labels() -> Array[Label]:
	var labels: Array[Label] = []
	if _settings_box == null:
		return labels
	for row: Node in _settings_box.get_children():
		for child: Node in row.get_children():
			if child is Label:
				labels.append(child as Label)
	return labels


func _phase_marker_for_phase(phase: int) -> String:
	match maxi(1, phase):
		1:
			return "I"
		2:
			return "II"
		3:
			return "III"
		_:
			return str(maxi(1, phase))


func _colorblind_index_for_mode(mode: StringName) -> int:
	match mode:
		COLORBLIND_RED_GREEN:
			return 1
		COLORBLIND_BLUE_YELLOW:
			return 2
		_:
			return 0


func _mode_for_colorblind_index(index: int) -> StringName:
	match index:
		1:
			return COLORBLIND_RED_GREEN
		2:
			return COLORBLIND_BLUE_YELLOW
		_:
			return COLORBLIND_NONE


func _on_hud_scale_slider_changed(value: float) -> void:
	set_hud_scale(value / 100.0)


func _on_colorblind_option_selected(index: int) -> void:
	set_colorblind_mode(_mode_for_colorblind_index(index))


func _on_resume_button_pressed() -> void:
	if _menu_mode == MENU_SETTINGS:
		close_settings_menu()
		return
	menu_resume_requested.emit()


func _on_settings_button_pressed() -> void:
	menu_settings_requested.emit()


func _on_retry_button_pressed() -> void:
	menu_retry_requested.emit()
