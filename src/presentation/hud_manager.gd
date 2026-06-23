## Presentation-layer combat HUD for the playable vertical slice.
extends CanvasLayer
class_name HUDManager

signal menu_pause_requested
signal menu_resume_requested
signal menu_retry_requested

const HP_HEALTHY_COLOR: Color = Color("#ECC94B")
const HP_MID_COLOR: Color = Color("#D9B84A")
const HP_LOW_COLOR: Color = Color("#F97316")
const HP_CRITICAL_COLOR: Color = Color("#E53E3E")
const PANEL_COLOR: Color = Color(0.10, 0.10, 0.18, 0.72)
const BORDER_COLOR: Color = Color("#6B8A9E")
const TEXT_COLOR: Color = Color("#E8E4DC")
const MENU_OVERLAY_COLOR: Color = Color(0.03, 0.03, 0.06, 0.72)
const MENU_NONE: StringName = &"none"
const MENU_PAUSE: StringName = &"pause"
const MENU_RETRY: StringName = &"retry"

var _hp_ratio: float = 1.0
var _hp_color: Color = HP_HEALTHY_COLOR
var _notification_remaining_sec: float = 0.0
var _menu_mode: StringName = MENU_NONE

var _root: Control
var _hp_bar: ProgressBar
var _hp_label: Label
var _boss_panel: PanelContainer
var _boss_bar: ProgressBar
var _boss_label: Label
var _weapon_label: Label
var _currency_label: Label
var _notification_label: Label
var _menu_overlay: ColorRect
var _menu_panel: PanelContainer
var _menu_title_label: Label
var _menu_subtitle_label: Label
var _resume_button: Button
var _retry_button: Button


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
	if _boss_panel != null:
		_boss_panel.visible = safe_current_hp > 0
	if _boss_bar != null:
		_boss_bar.max_value = safe_max_hp
		_boss_bar.value = safe_current_hp
		_apply_progress_color(_boss_bar, HP_CRITICAL_COLOR)
	if _boss_label != null:
		_boss_label.text = "%s  Phase %d  %d/%d" % [
			display_name,
			maxi(1, phase),
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


## Hides the active menu overlay and releases menu button focus.
func hide_menu() -> void:
	_menu_mode = MENU_NONE
	if _menu_overlay != null:
		_menu_overlay.visible = false
	if _resume_button != null:
		_resume_button.release_focus()
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
		and _retry_button != null
		and _resume_button.focus_mode == Control.FOCUS_ALL
		and _retry_button.focus_mode == Control.FOCUS_ALL
	)


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


func _build_player_hp_panel() -> void:
	var panel := _new_panel("PlayerHudPanel")
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
	_menu_panel.size = Vector2(432, 280)
	_menu_overlay.add_child(_menu_panel)

	var content := VBoxContainer.new()
	content.name = "MenuContent"
	content.add_theme_constant_override("separation", 18)
	_menu_panel.add_child(content)

	_menu_title_label = Label.new()
	_menu_title_label.name = "MenuTitle"
	_menu_title_label.custom_minimum_size = Vector2(392, 44)
	_menu_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_menu_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_menu_title_label.add_theme_color_override("font_color", HP_HEALTHY_COLOR)
	_menu_title_label.add_theme_font_size_override("font_size", 28)
	content.add_child(_menu_title_label)

	_menu_subtitle_label = Label.new()
	_menu_subtitle_label.name = "MenuSubtitle"
	_menu_subtitle_label.custom_minimum_size = Vector2(392, 52)
	_menu_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_menu_subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_menu_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_menu_subtitle_label.add_theme_color_override("font_color", TEXT_COLOR)
	content.add_child(_menu_subtitle_label)

	var button_box := VBoxContainer.new()
	button_box.name = "MenuButtons"
	button_box.custom_minimum_size = Vector2(240, 96)
	button_box.add_theme_constant_override("separation", 14)
	button_box.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(button_box)

	_resume_button = _new_menu_button("ResumeButton", "Resume")
	_resume_button.pressed.connect(_on_resume_button_pressed)
	button_box.add_child(_resume_button)

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
	if ratio <= 0.25:
		return HP_CRITICAL_COLOR
	if ratio <= 0.5:
		return HP_LOW_COLOR
	if ratio <= 0.74:
		return HP_MID_COLOR
	return HP_HEALTHY_COLOR


func _show_menu(mode: StringName, title: String, subtitle: String, resume_text: String) -> void:
	_menu_mode = mode
	if _menu_overlay == null:
		return
	_menu_title_label.text = title
	_menu_subtitle_label.text = subtitle
	_resume_button.text = resume_text
	_retry_button.text = "Retry Encounter"
	_menu_overlay.visible = true
	_resume_button.grab_focus()


func _on_resume_button_pressed() -> void:
	menu_resume_requested.emit()


func _on_retry_button_pressed() -> void:
	menu_retry_requested.emit()
