## Persistent application shell for player-driven entry into runtime gameplay.
extends Node

const NEW_GAME_SCENE_ID: StringName = &"area_01_scrap_roost_hunt"
const LEGACY_SAVE_SCENE_ID: StringName = &"main"
const DEFAULT_SPAWN_POINT: StringName = &"default"
const SAVE_SLOT_ORDER: Array[int] = [0, 1, 2, 3]
const LOAD_FAILURE_TEXT: String = "Load failed"

@export var auto_configure_services: bool = true

@onready var _runtime_scene_root: Node = $RuntimeSceneRoot
@onready var _title_screen: Control = $TitleScreen
@onready var _readability_scrim: ColorRect = $TitleScreen/LeftReadabilityScrim
@onready var _title_character: AnimatedSprite2D = $TitleScreen/TitleCinderpaw
@onready var _hud: HUDManager = $TitleHUD

var _save_system: Object
var _scene_manager: Object
var _connected_scene_manager: Object
var _entry_request_active: bool = false
var _pending_load_slot: int = -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_runtime_scene_root.process_mode = Node.PROCESS_MODE_DISABLED
	_connect_hud_signals()
	_hud.set_title_screen_mode(true)
	if auto_configure_services:
		configure_runtime_services(
			get_node_or_null("/root/SaveSystem"),
			get_node_or_null("/root/SceneManager")
		)
	else:
		_show_title_menu()


func _exit_tree() -> void:
	_disconnect_scene_manager_signals()


func configure_runtime_services(save_system: Object, scene_manager: Object) -> bool:
	_disconnect_scene_manager_signals()
	_save_system = save_system
	_scene_manager = scene_manager
	if not _is_valid_save_system(_save_system) or not _is_valid_scene_manager(_scene_manager):
		_show_title_failure(LOAD_FAILURE_TEXT)
		return false
	if _scene_manager.has_method("configure_runtime_scene_root"):
		if not bool(_scene_manager.call("configure_runtime_scene_root", _runtime_scene_root)):
			_show_title_failure(LOAD_FAILURE_TEXT)
			return false
	_connect_scene_manager_signals()
	_show_title_menu()
	return true


func request_new_game() -> bool:
	if _entry_request_active:
		return false
	_pending_load_slot = -1
	return _request_runtime_scene(NEW_GAME_SCENE_ID, DEFAULT_SPAWN_POINT)


func request_continue() -> bool:
	if _entry_request_active:
		return false
	var slot: int = _first_available_slot()
	if slot < 0:
		_show_title_menu()
		return false
	return _request_load_slot(slot)


func request_load_slot(slot: int) -> bool:
	if _entry_request_active or slot not in SAVE_SLOT_ORDER:
		return false
	return _request_load_slot(slot)


func is_title_visible() -> bool:
	return is_instance_valid(_title_screen) and _title_screen.visible and _hud.visible


func get_title_diagnostics() -> Dictionary:
	var title_frames: SpriteFrames = (
		_title_character.sprite_frames
		if is_instance_valid(_title_character)
		else null
	)
	var title_animation: StringName = (
		_title_character.animation
		if is_instance_valid(_title_character)
		else &""
	)
	var menu_panel_rect: Rect2 = (
		_hud.get_menu_panel_rect()
		if is_instance_valid(_hud)
		else Rect2()
	)
	return {
		"title_visible": is_title_visible(),
		"runtime_scene_present": (
			is_instance_valid(_runtime_scene_root)
			and _runtime_scene_root.get_child_count() > 0
		),
		"runtime_scene_count": (
			_runtime_scene_root.get_child_count()
			if is_instance_valid(_runtime_scene_root)
			else 0
		),
		"runtime_processing_enabled": (
			_runtime_scene_root.process_mode != Node.PROCESS_MODE_DISABLED
			if is_instance_valid(_runtime_scene_root)
			else false
		),
		"menu_mode": String(_hud.get_menu_mode()) if is_instance_valid(_hud) else "",
		"menu_title": _hud.get_menu_title() if is_instance_valid(_hud) else "",
		"focused_button": (
			_hud.get_focused_menu_button_text()
			if is_instance_valid(_hud)
			else ""
		),
		"menu_buttons": (
			Array(_hud.call("get_menu_button_texts"))
			if is_instance_valid(_hud) and _hud.has_method("get_menu_button_texts")
			else []
		),
		"disabled_reasons": (
			Dictionary(_hud.call("get_disabled_menu_button_reasons"))
			if is_instance_valid(_hud) and _hud.has_method("get_disabled_menu_button_reasons")
			else {}
		),
		"entry_request_active": _entry_request_active,
		"pending_load_slot": _pending_load_slot,
		"key_art_path": "res://assets/ui/title/cinderpaw_title_threshold_background_1280x720.png",
		"title_character_type": (
			_title_character.get_class()
			if is_instance_valid(_title_character)
			else ""
		),
		"title_character_animation": String(title_animation),
		"title_character_frame_count": (
			title_frames.get_frame_count(title_animation)
			if title_frames != null and title_frames.has_animation(title_animation)
			else 0
		),
		"title_character_playing": (
			_title_character.is_playing()
			if is_instance_valid(_title_character)
			else false
		),
		"readability_scrim_width": (
			_readability_scrim.size.x
			if is_instance_valid(_readability_scrim)
			else 0.0
		),
		"menu_panel_bottom": menu_panel_rect.end.y,
		"menu_focus_contract_valid": (
			_hud.is_menu_focus_contract_valid()
			if is_instance_valid(_hud)
			else false
		),
	}


func _connect_hud_signals() -> void:
	_hud.menu_new_game_requested.connect(request_new_game)
	_hud.menu_continue_requested.connect(request_continue)
	_hud.menu_load_menu_requested.connect(_show_load_menu)
	_hud.menu_load_slot_requested.connect(request_load_slot)
	_hud.menu_settings_requested.connect(_show_settings_menu)
	_hud.menu_resume_requested.connect(_show_title_menu)
	_hud.menu_exit_requested.connect(_request_exit)


func _connect_scene_manager_signals() -> void:
	_connected_scene_manager = _scene_manager
	_connect_scene_signal("on_scene_load_started", _on_scene_load_started)
	_connect_scene_signal("on_scene_changed", _on_scene_changed)
	_connect_scene_signal("on_scene_load_failed", _on_scene_load_failed)


func _connect_scene_signal(signal_name: StringName, callback: Callable) -> void:
	if _connected_scene_manager == null or not _connected_scene_manager.has_signal(signal_name):
		return
	var scene_signal: Signal = _connected_scene_manager.get(signal_name)
	if not scene_signal.is_connected(callback):
		scene_signal.connect(callback)


func _disconnect_scene_manager_signals() -> void:
	if _connected_scene_manager == null or not is_instance_valid(_connected_scene_manager):
		_connected_scene_manager = null
		return
	_disconnect_scene_signal("on_scene_load_started", _on_scene_load_started)
	_disconnect_scene_signal("on_scene_changed", _on_scene_changed)
	_disconnect_scene_signal("on_scene_load_failed", _on_scene_load_failed)
	_connected_scene_manager = null


func _disconnect_scene_signal(signal_name: StringName, callback: Callable) -> void:
	if not _connected_scene_manager.has_signal(signal_name):
		return
	var scene_signal: Signal = _connected_scene_manager.get(signal_name)
	if scene_signal.is_connected(callback):
		scene_signal.disconnect(callback)


func _show_title_menu() -> void:
	if not is_instance_valid(_title_screen) or not is_instance_valid(_hud):
		return
	_title_screen.visible = true
	_hud.visible = true
	_runtime_scene_root.process_mode = Node.PROCESS_MODE_DISABLED
	_hud.set_title_screen_mode(true)
	_hud.show_main_menu(_collect_save_slot_infos())


func _show_load_menu() -> void:
	_hud.show_save_load_menu(
		_collect_save_slot_infos(),
		false,
		"Saving requires active gameplay"
	)


func _show_settings_menu() -> void:
	_hud.show_settings_menu(_hud.get_menu_mode())


func _request_exit() -> void:
	if is_inside_tree():
		get_tree().quit()


func _collect_save_slot_infos() -> Array:
	var infos: Array = []
	if not _is_valid_save_system(_save_system):
		return infos
	for slot: int in SAVE_SLOT_ORDER:
		infos.append(_save_system.call("get_save_info", slot))
	return infos


func _first_available_slot() -> int:
	if not _is_valid_save_system(_save_system):
		return -1
	for slot: int in SAVE_SLOT_ORDER:
		if bool(_save_system.call("has_save", slot)):
			return slot
	return -1


func _request_load_slot(slot: int) -> bool:
	if not bool(_save_system.call("has_save", slot)):
		_show_title_failure(LOAD_FAILURE_TEXT)
		return false
	var snapshot: Dictionary = Dictionary(_save_system.call("peek_save_data", slot))
	if snapshot.is_empty():
		_show_title_failure(LOAD_FAILURE_TEXT)
		return false
	var target: Dictionary = _resolve_scene_target(snapshot)
	_pending_load_slot = slot
	if _request_runtime_scene(
		StringName(target.get("scene_id", "")),
		StringName(target.get("spawn_point", ""))
	):
		return true
	_pending_load_slot = -1
	return false


func _request_runtime_scene(scene_id: StringName, spawn_point: StringName) -> bool:
	if not _is_valid_scene_manager(_scene_manager) or scene_id == &"" or spawn_point == &"":
		_show_title_failure(LOAD_FAILURE_TEXT)
		return false
	if _scene_manager.has_method("has_scene") and not bool(_scene_manager.call("has_scene", scene_id)):
		_show_title_failure(LOAD_FAILURE_TEXT)
		return false
	_entry_request_active = true
	var accepted: bool = bool(_scene_manager.call("request_scene_change", scene_id, spawn_point))
	if not accepted:
		_entry_request_active = false
		_show_title_failure(LOAD_FAILURE_TEXT)
	return accepted


func _resolve_scene_target(snapshot: Dictionary) -> Dictionary:
	var player_state: Dictionary = Dictionary(snapshot.get("player_state", {}))
	var world_state: Dictionary = Dictionary(snapshot.get("world_state", {}))
	var last_savepoint: Dictionary = Dictionary(world_state.get("last_savepoint", {}))
	var scene_id: String = String(last_savepoint.get("scene_id", "")).strip_edges()
	var spawn_point: String = String(last_savepoint.get("spawn_point", "")).strip_edges()
	if scene_id.is_empty():
		scene_id = String(world_state.get("scene_id", "")).strip_edges()
	if scene_id.is_empty():
		scene_id = String(player_state.get("scene_id", "")).strip_edges()
	if scene_id.is_empty():
		scene_id = String(LEGACY_SAVE_SCENE_ID)
	if spawn_point.is_empty():
		spawn_point = _default_spawn_for_scene(StringName(scene_id))
	return {
		"scene_id": scene_id,
		"spawn_point": spawn_point,
	}


func _default_spawn_for_scene(scene_id: StringName) -> String:
	if _scene_manager != null and _scene_manager.has_method("get_scene_config"):
		var config_variant: Variant = _scene_manager.call("get_scene_config", scene_id)
		if config_variant is Dictionary:
			var configured: String = String(
				Dictionary(config_variant).get("default_spawn", "")
			).strip_edges()
			if not configured.is_empty():
				return configured
	return String(DEFAULT_SPAWN_POINT)


func _on_scene_load_started(
	scene_id: StringName,
	_spawn_point: StringName,
	metadata: Dictionary
) -> void:
	if not _entry_request_active:
		return
	var display_name: String = String(metadata.get("display_name", "")).strip_edges()
	if display_name.is_empty():
		display_name = String(scene_id).replace("_", " ").capitalize()
	_hud.show_scene_transition(
		scene_id,
		display_name,
		float(metadata.get("transition_duration_sec", 1.5))
	)


func _on_scene_changed(_old_scene: StringName, _new_scene: StringName) -> void:
	if not _entry_request_active:
		return
	if _pending_load_slot >= 0:
		var load_slot: int = _pending_load_slot
		_pending_load_slot = -1
		if not bool(_save_system.call("load_game", load_slot)):
			_entry_request_active = false
			_show_title_failure(LOAD_FAILURE_TEXT)
			return
	_entry_request_active = false
	_hud.hide_scene_transition()
	_title_screen.visible = false
	_hud.visible = false
	_runtime_scene_root.process_mode = Node.PROCESS_MODE_INHERIT


func _on_scene_load_failed(_scene_id: StringName, _reason: StringName) -> void:
	if not _entry_request_active:
		return
	_entry_request_active = false
	_pending_load_slot = -1
	_show_title_failure(LOAD_FAILURE_TEXT)


func _show_title_failure(message: String) -> void:
	_show_title_menu()
	_hud.hide_scene_transition()
	_hud.show_notification(message, 2.0)


func _is_valid_save_system(save_system: Object) -> bool:
	return (
		save_system != null
		and is_instance_valid(save_system)
		and save_system.has_method("has_save")
		and save_system.has_method("get_save_info")
		and save_system.has_method("peek_save_data")
		and save_system.has_method("load_game")
	)


func _is_valid_scene_manager(scene_manager: Object) -> bool:
	return (
		scene_manager != null
		and is_instance_valid(scene_manager)
		and scene_manager.has_method("request_scene_change")
	)
