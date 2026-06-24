## Main playable scene wiring for the current vertical slice.
extends Node2D

@onready var _player: PlayerController = $Player
@onready var _enemy = $Enemy
@onready var _hud = $HUD
@onready var _combat_presentation = $CombatPresentation
@onready var _game_flow = $GameFlowController

const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")
const RUNTIME_DAMAGE_CALCULATOR_ADAPTER_SCRIPT: Script = preload("res://src/gameplay/runtime_damage_calculator_adapter.gd")
const SAVE_TRIGGER_ADAPTER_SCRIPT: Script = preload("res://src/feature/save_trigger_adapter.gd")
const MAIN_SCENE_SAVE_KEY: StringName = &"main_scene"
const SCENE_MANAGER_SAVE_KEY: StringName = &"scene"
const MAIN_SCENE_ID: String = "main"
const DEFAULT_NEW_GAME_SPAWN_POINT: StringName = &"default"
const RAT_KING_BOSS_ID: String = "boss_01_rat_king"
const RAT_KING_BOSS_DISPLAY_NAME: String = "垃圾桶鼠王"
const RAT_KING_ATTACK_SOURCE: StringName = &"rat_king_claw"

var _pause_menu_active: bool = false
var _currency_amount: int = 0
var _inventory_items: Array[StringName] = []
var _acquired_weapons: Array[StringName] = [&"cat_claw"]
var _current_weapon_id: StringName = &"cat_claw"
var _weapon_levels: Dictionary = {"cat_claw": 0}
var _world_progress_flags: Dictionary = {}
var _weapon_component: WeaponComponent = null
var _damage_calculator_adapter: Object = null
var _last_player_hit_metadata: Dictionary = {}
var _save_system: Object = null
var _registered_save_system: Object = null
var _save_trigger_adapter: SaveTriggerAdapter = null
var _boss_phase_transition_source: Object = null
var _pending_manual_save_slot: int = -1
var _scene_manager: Object = null
var _connected_scene_manager: Object = null
var _audio_system: Object = null
var _last_discovered_savepoint: Dictionary = {}


func _ready() -> void:
	_setup_weapon_component()
	_setup_player_attack_core_chain()
	_setup_enemy_attack_core_chain()
	_game_flow.set_no_loss_state_adapter(self)
	_game_flow.set_savepoint_adapter(self)
	_game_flow.configure_clan_base_respawn(&"hub", &"clan_base", _player.global_position)
	_game_flow.configure_boss_entrance_respawn(
		StringName(MAIN_SCENE_ID),
		&"boss_entrance",
		_player.global_position
	)
	_game_flow.start_boss_encounter(_player.global_position, self)
	_game_flow.respawn_requested.connect(_on_respawn_requested)
	_game_flow.victory_reached.connect(_on_victory_reached)
	_hud.menu_pause_requested.connect(_on_menu_pause_requested)
	_hud.menu_resume_requested.connect(_on_menu_resume_requested)
	_hud.menu_retry_requested.connect(_on_menu_retry_requested)
	_hud.menu_settings_requested.connect(_on_menu_settings_requested)
	_hud.menu_new_game_requested.connect(_on_menu_new_game_requested)
	_hud.menu_continue_requested.connect(_on_menu_continue_requested)
	_hud.menu_load_menu_requested.connect(_on_menu_load_menu_requested)
	_hud.menu_main_menu_requested.connect(_on_menu_main_menu_requested)
	_hud.menu_exit_requested.connect(_on_menu_exit_requested)
	_hud.menu_save_slot_requested.connect(_on_menu_save_slot_requested)
	_hud.menu_load_slot_requested.connect(_on_menu_load_slot_requested)
	_hud.colorblind_mode_changed.connect(_on_hud_colorblind_mode_changed)
	_player.player_health_changed.connect(_on_player_health_changed)
	_player.player_died.connect(_on_player_died)
	_player.attack_landed.connect(_on_player_attack_landed)
	_player.attack_started.connect(_on_player_attack_started)
	_player.dodge_started.connect(_on_player_dodge_started)
	_connect_player_focus_mode_signal()
	_enemy.enemy_health_changed.connect(_on_enemy_health_changed)
	_enemy.enemy_defeated.connect(_on_enemy_defeated)
	_register_enemy_boss_phase_source()
	_combat_presentation.set_camera($Player/Camera2D)
	_sync_combat_presentation_accessibility_settings()

	_hud.update_hp(_player.get_current_hp(), _player.get_max_hp())
	_hud.update_boss_hp(_enemy.get_current_hp(), _enemy.get_max_hp(), 1, _get_enemy_display_name())
	_hud.update_currency(_currency_amount)
	_update_weapon_hud()
	configure_save_system_runtime(get_node_or_null("/root/SaveSystem"))
	configure_scene_manager_runtime(get_node_or_null("/root/SceneManager"))
	configure_audio_system_runtime(get_node_or_null("/root/AudioSystem"))
	_hud.show_notification("Hunt the Rat King", 2.0)


func _exit_tree() -> void:
	_disconnect_scene_manager_signals()
	_disconnect_boss_phase_transition_source()
	_unregister_main_scene_from_save_system()


func _process(_delta: float) -> void:
	_player.set_control_locked(_game_flow.is_player_control_locked())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_swap") and not _hud.is_menu_visible():
		request_weapon_swap()
		get_viewport().set_input_as_handled()


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	_hud.update_hp(current_hp, max_hp)


func _on_player_died(death_metadata: Dictionary) -> void:
	_game_flow.handle_player_death()
	if _hud.is_battle_summary_enabled():
		_hud.show_battle_summary(_battle_summary_from_death_metadata(death_metadata))
	_hud.show_notification("Cinderpaw falls - reviving", 1.5)


func _on_player_attack_landed(hit_data: Dictionary) -> void:
	var enriched_hit_data: Dictionary = _apply_weapon_effects_to_player_hit(hit_data)
	enriched_hit_data["show_damage_number"] = _hud.are_damage_numbers_enabled()
	_last_player_hit_metadata = enriched_hit_data.duplicate(true)
	_combat_presentation.on_hit_event(enriched_hit_data)
	_dispatch_audio_event(&"on_hit_event", [enriched_hit_data])


func _on_player_attack_started(attack_data: Dictionary) -> void:
	_combat_presentation.on_weapon_attack_event(attack_data)
	_dispatch_audio_event(&"on_weapon_attack_event", [attack_data])


func _on_player_dodge_started(texture: Texture2D, world_position: Vector2, facing: float) -> void:
	_combat_presentation.on_dodge_event(texture, world_position, facing)
	_dispatch_audio_event(&"on_dodge_event", [texture, world_position, facing])


func _on_enemy_attack_landed(damage: int, hit_position: Vector2, is_crit: bool) -> void:
	var hit_data: Dictionary = {
		"damage": damage,
		"hit_position": hit_position,
		"is_crit": is_crit,
		"source": RAT_KING_ATTACK_SOURCE,
		"show_damage_number": _hud.are_damage_numbers_enabled(),
		"focus_mode_active": _is_player_focus_mode_active(),
	}
	_combat_presentation.on_hit_event(hit_data)
	_dispatch_audio_event(&"on_damage_taken_event", [hit_data])


func _on_enemy_health_changed(current_hp: int, max_hp: int) -> void:
	_hud.update_boss_hp(current_hp, max_hp, _get_enemy_phase(), _get_enemy_display_name())


func _on_enemy_defeated() -> void:
	_dispatch_audio_event(&"on_enemy_defeated", [{
		"target_id": RAT_KING_BOSS_ID,
		"position": _enemy.global_position + Vector2(0, -24),
	}])
	_combat_presentation.on_kill_event(2, _enemy.global_position + Vector2(0, -24))
	_game_flow.handle_enemy_defeated()
	set_world_progress_flag(&"boss_rat_king_defeated", true)
	_trigger_runtime_autosave(&"boss_defeat", {
		"boss_id": RAT_KING_BOSS_ID,
	})


func _on_respawn_requested(respawn_position: Vector2, revive_hp_percentage: float) -> void:
	_player.respawn_at(respawn_position, revive_hp_percentage)
	_hud.update_hp(_player.get_current_hp(), _player.get_max_hp())
	_hud.show_notification("Nine lives remain", 2.0)


func _on_victory_reached() -> void:
	_hud.hide_boss_hp()
	grant_currency(25)
	_hud.show_notification("Rat King defeated", 3.0)
	_hud.show_retry_menu("Rat King defeated", "Retry the encounter or stay with your prize.")


func _on_menu_pause_requested() -> void:
	if _game_flow.get_flow_state() == &"victory":
		return
	_pause_menu_active = true
	get_tree().paused = true
	_hud.show_pause_menu()


func _on_menu_resume_requested() -> void:
	if _pause_menu_active:
		get_tree().paused = false
	_pause_menu_active = false
	_hud.hide_menu()


func _on_menu_retry_requested() -> void:
	_pause_menu_active = false
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_settings_requested() -> void:
	_hud.show_settings_menu(_hud.get_menu_mode())


func _on_menu_new_game_requested() -> void:
	if not _request_scene_manager_transition(StringName(MAIN_SCENE_ID), DEFAULT_NEW_GAME_SPAWN_POINT):
		_hud.show_notification("Load failed", 2.0)
		_hud.show_main_menu(_collect_save_slot_infos())
		return
	_pause_menu_active = false
	get_tree().paused = false
	_hud.hide_menu()


func _on_menu_continue_requested() -> void:
	if _try_load_first_available_slot():
		_pause_menu_active = false
		get_tree().paused = false
		_hud.hide_menu()
		return
	_hud.show_notification("Load failed", 2.0)
	_hud.show_main_menu(_collect_save_slot_infos())


func _on_menu_load_menu_requested() -> void:
	_hud.show_save_load_menu(
		_collect_save_slot_infos(),
		false,
		"Saving requires a save point"
	)


func _on_menu_main_menu_requested() -> void:
	_pause_menu_active = false
	get_tree().paused = false
	_hud.show_main_menu(_collect_save_slot_infos())


func _on_menu_exit_requested() -> void:
	_hud.show_notification("Exit is unavailable in this build", 2.0)


func _on_menu_save_slot_requested(slot: int) -> void:
	if _is_manual_save_write_pending():
		_hud.show_notification("Saving...", 1.5)
		_hud.show_save_load_menu(
			_collect_save_slot_infos(),
			false,
			"Saving requires a save point"
		)
		return
	_pending_manual_save_slot = slot
	if save_runtime_to_slot(slot):
		if _save_system.has_method("is_save_write_pending") and bool(_save_system.call("is_save_write_pending")):
			_hud.show_notification("Saving...", 1.5)
		elif _pending_manual_save_slot == slot:
			_pending_manual_save_slot = -1
			_hud.show_notification("Game saved", 1.5)
	elif _pending_manual_save_slot == slot:
		_pending_manual_save_slot = -1
	_hud.show_save_load_menu(
		_collect_save_slot_infos(),
		false,
		"Saving requires a save point"
	)


func _on_menu_load_slot_requested(slot: int) -> void:
	if load_runtime_from_slot(slot):
		_pause_menu_active = false
		get_tree().paused = false
		_hud.hide_menu()
		return
	_hud.show_notification("Load failed", 2.0)
	_hud.show_save_load_menu(
		_collect_save_slot_infos(),
		false,
		"Saving requires a save point"
	)


func _battle_summary_from_death_metadata(death_metadata: Dictionary) -> Dictionary:
	var battle_stats: Dictionary = Dictionary(death_metadata.get("battle_stats", {})).duplicate(true)
	if battle_stats.has("damage_received") and not battle_stats.has("damage_taken"):
		battle_stats["damage_taken"] = battle_stats["damage_received"]
	return battle_stats


func capture_boss_arena_snapshot() -> Dictionary:
	return {
		"enemy": _enemy.capture_respawn_snapshot(),
	}


func reset_boss_arena_to_snapshot(snapshot: Dictionary) -> void:
	if not is_instance_valid(_enemy):
		return
	var enemy_snapshot: Dictionary = Dictionary(snapshot.get("enemy", {}))
	_enemy.restore_respawn_snapshot(enemy_snapshot)
	_hud.update_boss_hp(_enemy.get_current_hp(), _enemy.get_max_hp(), _get_enemy_phase(), _get_enemy_display_name())


func cleanup_temporary_summons() -> void:
	pass


func clear_arena_locks() -> void:
	pass


func clear_combat_adapters() -> void:
	pass


func capture_no_loss_state() -> Dictionary:
	return {
		"currency": _currency_amount,
		"inventory": _string_names_to_strings(_inventory_items),
		"weapons": {
			"current_weapon": String(_current_weapon_id),
			"acquired": _string_names_to_strings(_acquired_weapons),
			"levels": _weapon_levels.duplicate(true),
		},
		"settings": _hud.capture_settings_state(),
		"world_flags": _world_progress_flags.duplicate(true),
		"last_savepoint": _last_discovered_savepoint.duplicate(true),
	}


func restore_no_loss_state(snapshot: Dictionary) -> void:
	_currency_amount = maxi(0, _read_int(snapshot.get("currency", _currency_amount), _currency_amount))
	_inventory_items = _read_string_name_array(snapshot.get("inventory", _inventory_items))
	var weapon_state: Dictionary = Dictionary(snapshot.get("weapons", {}))
	_current_weapon_id = StringName(String(weapon_state.get("current_weapon", String(_current_weapon_id))))
	_acquired_weapons = _read_string_name_array(weapon_state.get("acquired", _acquired_weapons))
	_weapon_levels = Dictionary(weapon_state.get("levels", _weapon_levels)).duplicate(true)
	_world_progress_flags = Dictionary(snapshot.get("world_flags", _world_progress_flags)).duplicate(true)
	_restore_last_savepoint_from_dictionary(Dictionary(snapshot.get("last_savepoint", {})))
	_sync_weapon_component_from_runtime_state()
	_hud.update_currency(_currency_amount)
	_update_weapon_hud()
	if snapshot.has("settings"):
		_hud.restore_settings_state(Dictionary(snapshot.get("settings", {})))
	_sync_combat_presentation_accessibility_settings()


func grant_currency(amount: int) -> void:
	_currency_amount = maxi(0, _currency_amount + maxi(0, amount))
	_hud.update_currency(_currency_amount)


func add_inventory_item(item_id: StringName) -> void:
	if item_id == &"" or _inventory_items.has(item_id):
		return
	_inventory_items.append(item_id)


func acquire_weapon(weapon_id: StringName) -> void:
	if weapon_id == &"":
		return
	if not _acquired_weapons.has(weapon_id):
		_acquired_weapons.append(weapon_id)
	if not _weapon_levels.has(String(weapon_id)):
		_weapon_levels[String(weapon_id)] = 0


func set_current_weapon_id(weapon_id: StringName) -> void:
	if _acquired_weapons.has(weapon_id):
		_current_weapon_id = weapon_id
		_sync_weapon_component_from_runtime_state()
		_update_weapon_hud()


func set_world_progress_flag(flag_id: StringName, enabled: bool = true) -> void:
	if flag_id == &"":
		return
	_world_progress_flags[String(flag_id)] = enabled


func get_runtime_progress_state() -> Dictionary:
	return capture_no_loss_state()


func configure_scene_manager_runtime(scene_manager: Object) -> bool:
	_disconnect_scene_manager_signals()
	_scene_manager = scene_manager
	_game_flow.set_scene_transition_adapter(_scene_manager)
	_connect_scene_manager_signals(_scene_manager)
	return _is_valid_scene_manager(_scene_manager)


func configure_audio_system_runtime(audio_system: Object) -> bool:
	_audio_system = audio_system
	return _is_valid_audio_system(_audio_system)


func _request_scene_manager_transition(scene_id: StringName, spawn_point: StringName) -> bool:
	if scene_id == &"" or spawn_point == &"":
		return false
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if scene_manager == null:
		return true
	if scene_manager.has_method("has_scene") and not bool(scene_manager.call("has_scene", scene_id)):
		return false
	if scene_manager.has_method("is_scene_locked") and bool(scene_manager.call("is_scene_locked")):
		return false
	if scene_manager.has_method("request_scene_change"):
		return bool(scene_manager.call("request_scene_change", scene_id, spawn_point))
	if not scene_manager.has_method("change_scene"):
		return false
	return bool(scene_manager.call("change_scene", scene_id, spawn_point))


func _handoff_loaded_scene_to_scene_manager(snapshot: Dictionary) -> bool:
	var target: Dictionary = _resolve_scene_target_from_snapshot(snapshot)
	return _request_scene_manager_transition(
		StringName(target.get("scene_id", "")),
		StringName(target.get("spawn_point", ""))
	)


func _resolve_scene_target_from_snapshot(snapshot: Dictionary) -> Dictionary:
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
		scene_id = MAIN_SCENE_ID
	if spawn_point.is_empty():
		spawn_point = _get_default_spawn_for_scene(StringName(scene_id))
	return {
		"scene_id": scene_id,
		"spawn_point": spawn_point,
	}


func _get_default_spawn_for_scene(scene_id: StringName) -> String:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if scene_manager != null and scene_manager.has_method("get_scene_config"):
		var config: Variant = scene_manager.call("get_scene_config", scene_id)
		if config is Dictionary:
			var configured_spawn: String = String(Dictionary(config).get("default_spawn", "")).strip_edges()
			if not configured_spawn.is_empty():
				return configured_spawn
	return String(DEFAULT_NEW_GAME_SPAWN_POINT)


func _resolve_scene_manager_for_runtime() -> Object:
	if _is_valid_scene_manager(_scene_manager):
		return _scene_manager
	if is_inside_tree() and configure_scene_manager_runtime(get_node_or_null("/root/SceneManager")):
		return _scene_manager
	return null


func _is_valid_scene_manager(scene_manager: Object) -> bool:
	return (
		scene_manager != null
		and is_instance_valid(scene_manager)
		and (
			scene_manager.has_method("change_scene")
			or scene_manager.has_method("request_scene_change")
		)
	)


func _resolve_audio_system_for_runtime() -> Object:
	if _is_valid_audio_system(_audio_system):
		return _audio_system
	if is_inside_tree() and configure_audio_system_runtime(get_node_or_null("/root/AudioSystem")):
		return _audio_system
	return null


func _is_valid_audio_system(audio_system: Object) -> bool:
	return (
		audio_system != null
		and is_instance_valid(audio_system)
		and audio_system.has_method("on_scene_load_started")
	)


func _dispatch_audio_event(method_name: StringName, args: Array = []) -> bool:
	var audio_system: Object = _resolve_audio_system_for_runtime()
	if audio_system == null or not audio_system.has_method(String(method_name)):
		return false
	audio_system.callv(method_name, args)
	return true


func _connect_scene_manager_signals(scene_manager: Object) -> void:
	if scene_manager == null or not is_instance_valid(scene_manager):
		return
	_connected_scene_manager = scene_manager
	_connect_scene_manager_signal(
		scene_manager,
		"on_scene_load_started",
		Callable(self, "_on_scene_manager_load_started")
	)
	_connect_scene_manager_signal(
		scene_manager,
		"on_scene_changed",
		Callable(self, "_on_scene_manager_changed")
	)
	_connect_scene_manager_signal(
		scene_manager,
		"on_scene_load_failed",
		Callable(self, "_on_scene_manager_load_failed")
	)


func _connect_scene_manager_signal(scene_manager: Object, signal_name: String, callback: Callable) -> void:
	if scene_manager == null or not is_instance_valid(scene_manager):
		return
	if not scene_manager.has_signal(signal_name):
		return
	var scene_signal: Signal = scene_manager.get(signal_name)
	if not scene_signal.is_connected(callback):
		scene_signal.connect(callback)


func _disconnect_scene_manager_signals() -> void:
	if _connected_scene_manager == null or not is_instance_valid(_connected_scene_manager):
		_connected_scene_manager = null
		return
	_disconnect_scene_manager_signal(
		_connected_scene_manager,
		"on_scene_load_started",
		Callable(self, "_on_scene_manager_load_started")
	)
	_disconnect_scene_manager_signal(
		_connected_scene_manager,
		"on_scene_changed",
		Callable(self, "_on_scene_manager_changed")
	)
	_disconnect_scene_manager_signal(
		_connected_scene_manager,
		"on_scene_load_failed",
		Callable(self, "_on_scene_manager_load_failed")
	)
	_connected_scene_manager = null


func _disconnect_scene_manager_signal(scene_manager: Object, signal_name: String, callback: Callable) -> void:
	if scene_manager == null or not is_instance_valid(scene_manager):
		return
	if not scene_manager.has_signal(signal_name):
		return
	var scene_signal: Signal = scene_manager.get(signal_name)
	if scene_signal.is_connected(callback):
		scene_signal.disconnect(callback)


func _on_scene_manager_load_started(
	scene_id: StringName,
	spawn_point: StringName,
	metadata: Dictionary
) -> void:
	var display_name: String = String(metadata.get("display_name", "")).strip_edges()
	if display_name == "":
		display_name = _display_name_for_scene_id(scene_id)
	var audio_system: Object = _resolve_audio_system_for_runtime()
	if audio_system != null:
		_dispatch_audio_event(&"on_scene_load_started", [scene_id, spawn_point, metadata])
	_hud.show_scene_transition(
		scene_id,
		display_name,
		float(metadata.get("transition_duration_sec", 1.5))
	)


func _on_scene_manager_changed(old_scene: StringName, new_scene: StringName) -> void:
	var audio_system: Object = _resolve_audio_system_for_runtime()
	if audio_system != null:
		_dispatch_audio_event(&"on_scene_changed", [old_scene, new_scene])
	_hud.hide_scene_transition()


func _on_scene_manager_load_failed(scene_id: StringName, reason: StringName) -> void:
	var audio_system: Object = _resolve_audio_system_for_runtime()
	if audio_system != null:
		_dispatch_audio_event(&"on_scene_load_failed", [scene_id, reason])
	_hud.hide_scene_transition()
	_hud.show_notification("Load failed", 2.0)


func discover_savepoint(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2
) -> bool:
	if savepoint_id == &"" or scene_id == &"" or spawn_point == &"":
		return false
	_last_discovered_savepoint = {
		"id": String(savepoint_id),
		"scene_id": String(scene_id),
		"spawn_point": String(spawn_point),
		"position": _vector2_to_dictionary(world_position),
	}
	return true


func get_last_discovered_savepoint() -> Dictionary:
	return _last_discovered_savepoint.duplicate(true)


func clear_last_discovered_savepoint() -> bool:
	_last_discovered_savepoint.clear()
	return true


## Configures the SaveSystem handoff used by runtime save/load and autosave triggers.
func configure_save_system_runtime(save_system: Object) -> bool:
	_unregister_main_scene_from_save_system()
	_save_system = save_system
	if not _is_valid_save_system(_save_system):
		return false
	if not _ensure_save_trigger_adapter():
		return false
	if not _register_main_scene_with_save_system():
		return false
	_connect_save_system_signals(_save_system)
	_save_trigger_adapter.configure(_save_system, capture_save_snapshot)
	return true


func _register_main_scene_with_save_system() -> bool:
	if not _is_valid_save_system(_save_system):
		return false
	if not _save_system.has_method("register_serializable"):
		return true
	var registered: bool = bool(_save_system.call(
		"register_serializable",
		self,
		MAIN_SCENE_SAVE_KEY
	))
	if not registered:
		return false
	_registered_save_system = _save_system
	return true


func _temporarily_unregister_main_scene_from_save_system() -> bool:
	if _registered_save_system == null or not is_instance_valid(_registered_save_system):
		return false
	if _registered_save_system != _save_system:
		return false
	if not _save_system.has_method("unregister_serializable"):
		return false
	_save_system.call("unregister_serializable", MAIN_SCENE_SAVE_KEY)
	_registered_save_system = null
	return true


func _temporarily_unregister_scene_manager_from_save_system() -> bool:
	if not _is_valid_save_system(_save_system):
		return false
	if not _save_system.has_method("unregister_serializable"):
		return false
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if not _is_valid_scene_manager(scene_manager):
		return false
	return bool(_save_system.call("unregister_serializable", SCENE_MANAGER_SAVE_KEY))


func _register_scene_manager_with_save_system() -> bool:
	if not _is_valid_save_system(_save_system):
		return false
	if not _save_system.has_method("register_serializable"):
		return true
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if not _is_valid_scene_manager(scene_manager):
		return false
	return bool(_save_system.call("register_serializable", scene_manager, SCENE_MANAGER_SAVE_KEY))


## Captures JSON-safe player, world, and settings state for SaveSystem.
func capture_save_snapshot() -> Dictionary:
	return {
		"player_state": _capture_player_state(),
		"world_state": _capture_world_state(),
		"settings": _hud.capture_settings_state(),
	}


## Restores MainScene from a SaveSystem-compatible runtime snapshot.
func restore_save_snapshot(snapshot: Dictionary) -> void:
	var player_state: Dictionary = Dictionary(snapshot.get("player_state", {}))
	var world_state: Dictionary = Dictionary(snapshot.get("world_state", {}))
	var settings: Dictionary = Dictionary(snapshot.get("settings", {}))
	_restore_player_state(player_state)
	_restore_runtime_progress_state(player_state, world_state, settings)


## Writes a manual runtime save through SaveSystem slots 1-3.
func save_runtime_to_slot(slot: int) -> bool:
	if (
		not _is_valid_save_system(_save_system)
		and not configure_save_system_runtime(get_node_or_null("/root/SaveSystem"))
	):
		return false
	if not _save_system.has_method("manual_save"):
		return false
	var snapshot: Dictionary = capture_save_snapshot()
	return bool(_save_system.call(
		"manual_save",
		slot,
		Dictionary(snapshot.get("player_state", {})),
		Dictionary(snapshot.get("world_state", {})),
		Dictionary(snapshot.get("settings", {}))
	))


## Loads a runtime save and applies the loaded MainScene state.
func load_runtime_from_slot(slot: int) -> bool:
	if (
		not _is_valid_save_system(_save_system)
		and not configure_save_system_runtime(get_node_or_null("/root/SaveSystem"))
	):
		return false
	if not _save_system.has_method("load_game") or not _save_system.has_method("get_last_loaded_data"):
		return false
	var temporarily_unregistered_main_scene: bool = _temporarily_unregister_main_scene_from_save_system()
	var temporarily_unregistered_scene_manager: bool = _temporarily_unregister_scene_manager_from_save_system()
	if not bool(_save_system.call("load_game", slot)):
		if temporarily_unregistered_main_scene:
			_register_main_scene_with_save_system()
		if temporarily_unregistered_scene_manager:
			_register_scene_manager_with_save_system()
		return false
	var loaded: Dictionary = Dictionary(_save_system.call("get_last_loaded_data"))
	if temporarily_unregistered_main_scene and not _register_main_scene_with_save_system():
		return false
	if temporarily_unregistered_scene_manager and not _register_scene_manager_with_save_system():
		return false
	if not _handoff_loaded_scene_to_scene_manager(loaded):
		return false
	restore_save_snapshot(loaded)
	return true


## Serializes MainScene as a registered SaveSystem payload.
func serialize() -> Dictionary:
	return capture_save_snapshot()


## Deserializes MainScene when SaveSystem loads registered systems.
func deserialize(data: Dictionary, _version: int = 1) -> void:
	restore_save_snapshot(data)


func set_battle_summary_enabled(enabled: bool) -> void:
	_hud.set_battle_summary_enabled(enabled)


func is_battle_summary_enabled() -> bool:
	return _hud.is_battle_summary_enabled()


func set_damage_numbers_enabled(enabled: bool) -> void:
	_hud.set_damage_numbers_enabled(enabled)


func are_damage_numbers_enabled() -> bool:
	return _hud.are_damage_numbers_enabled()


func set_colorblind_mode(mode: StringName) -> void:
	_hud.set_colorblind_mode(mode)
	_sync_combat_presentation_accessibility_settings()


func get_colorblind_mode() -> StringName:
	return _hud.get_colorblind_mode()


func request_weapon_swap() -> bool:
	if _weapon_component == null:
		return false
	return _weapon_component.request_swap()


func advance_weapon_swap_time(delta_sec: float) -> void:
	if _weapon_component == null:
		return
	_weapon_component.advance_time(delta_sec)


func get_weapon_hud_text() -> String:
	if _hud == null or not _hud.has_method("get_weapon_label_text"):
		return ""
	return _hud.get_weapon_label_text()


func get_last_player_hit_metadata() -> Dictionary:
	return _last_player_hit_metadata.duplicate(true)


func register_boss_phase_transition_source(source: Object) -> bool:
	_disconnect_boss_phase_transition_source()
	if source == null or not source.has_signal("on_boss_phase_transition_started"):
		return false
	var transition_signal: Signal = source.get("on_boss_phase_transition_started")
	if not transition_signal.is_connected(_handle_boss_phase_transition_started):
		transition_signal.connect(_handle_boss_phase_transition_started)
	_boss_phase_transition_source = source
	return true


func _register_enemy_boss_phase_source() -> bool:
	if not is_instance_valid(_enemy) or not _enemy.has_method("get_boss_config_component"):
		return false
	var boss_config: Object = _enemy.call("get_boss_config_component")
	return register_boss_phase_transition_source(boss_config)


func is_boss_phase_transition_source_connected() -> bool:
	if _boss_phase_transition_source == null or not is_instance_valid(_boss_phase_transition_source):
		return false
	if not _boss_phase_transition_source.has_signal("on_boss_phase_transition_started"):
		return false
	var transition_signal: Signal = _boss_phase_transition_source.get("on_boss_phase_transition_started")
	return transition_signal.is_connected(_handle_boss_phase_transition_started)


func _handle_boss_phase_transition_started(entity_id: int, phase: int, metadata: Dictionary) -> void:
	var enriched_metadata: Dictionary = metadata.duplicate(true)
	if not enriched_metadata.has("world_position") and is_instance_valid(_enemy):
		enriched_metadata["world_position"] = _enemy.global_position + Vector2(0, -24)
	if is_instance_valid(_hud) and is_instance_valid(_enemy):
		_hud.update_boss_hp(
			_enemy.get_current_hp(),
			_enemy.get_max_hp(),
			phase,
			String(enriched_metadata.get("display_name", _get_enemy_display_name()))
		)
	_combat_presentation.on_boss_phase_transition_started(entity_id, phase, enriched_metadata)
	_dispatch_audio_event(&"on_boss_phase_transition_started", [entity_id, phase, enriched_metadata])


func _on_hud_colorblind_mode_changed(mode: StringName) -> void:
	_combat_presentation.set_colorblind_mode(mode)


func _capture_player_state() -> Dictionary:
	var progress: Dictionary = capture_no_loss_state()
	var weapon_state: Dictionary = Dictionary(progress.get("weapons", {}))
	return {
		"scene_id": MAIN_SCENE_ID,
		"position": _vector2_to_dictionary(_player.global_position),
		"current_hp": _player.get_current_hp(),
		"max_hp": _player.get_max_hp(),
		"current_weapon": String(weapon_state.get("current_weapon", String(_current_weapon_id))),
		"acquired_weapons": Array(
			weapon_state.get("acquired", _string_names_to_strings(_acquired_weapons))
		).duplicate(true),
		"weapon_levels": Dictionary(weapon_state.get("levels", _weapon_levels)).duplicate(true),
		"currency": int(progress.get("currency", _currency_amount)),
		"inventory": Array(progress.get("inventory", _string_names_to_strings(_inventory_items))).duplicate(true),
	}


func _capture_world_state() -> Dictionary:
	return {
		"scene_id": MAIN_SCENE_ID,
		"defeated_bosses": _get_defeated_bosses(),
		"world_flags": _world_progress_flags.duplicate(true),
		"last_savepoint": _last_discovered_savepoint.duplicate(true),
	}


func _restore_player_state(player_state: Dictionary) -> void:
	_player.global_position = _read_vector2_dictionary(
		player_state.get("position", _vector2_to_dictionary(_player.global_position)),
		_player.global_position
	)
	_player.velocity = Vector2.ZERO
	var max_hp: int = maxi(1, _read_int(player_state.get("max_hp", _player.get_max_hp()), _player.get_max_hp()))
	var current_hp: int = clampi(
		_read_int(player_state.get("current_hp", _player.get_current_hp()), _player.get_current_hp()),
		0,
		max_hp
	)
	var health: HealthComponent = _player.get_node_or_null("HealthComponent") as HealthComponent
	if health != null:
		health.deserialize({
			"version": 1,
			"entity_id": 1,
			"base_hp": max_hp,
			"skill_hp_flat": 0,
			"charm_hp_flat": 0,
			"current_hp": current_hp,
			"max_hp": max_hp,
			"shield": 0,
			"max_shield": 0,
			"state": "alive" if current_hp > 0 else "dead",
			"focus_mode_enabled": true,
			"focus_mode_active": false,
		}, 1)
	_hud.update_hp(_player.get_current_hp(), _player.get_max_hp())


func _restore_runtime_progress_state(player_state: Dictionary, world_state: Dictionary, settings: Dictionary) -> void:
	restore_no_loss_state({
		"currency": _read_int(player_state.get("currency", _currency_amount), _currency_amount),
		"inventory": Array(player_state.get("inventory", _string_names_to_strings(_inventory_items))).duplicate(true),
		"weapons": {
			"current_weapon": String(player_state.get("current_weapon", String(_current_weapon_id))),
			"acquired": Array(
				player_state.get("acquired_weapons", _string_names_to_strings(_acquired_weapons))
			).duplicate(true),
			"levels": Dictionary(player_state.get("weapon_levels", _weapon_levels)).duplicate(true),
		},
		"settings": settings.duplicate(true),
		"world_flags": Dictionary(world_state.get("world_flags", _world_progress_flags)).duplicate(true),
		"last_savepoint": Dictionary(world_state.get("last_savepoint", {})).duplicate(true),
	})
	var defeated_bosses: Variant = world_state.get("defeated_bosses", [])
	if defeated_bosses is Array:
		for boss_id: Variant in defeated_bosses:
			set_world_progress_flag(StringName("boss_%s_defeated" % String(boss_id)), true)


func _trigger_runtime_autosave(reason: StringName, context: Dictionary) -> bool:
	if _save_trigger_adapter == null:
		return false
	return _save_trigger_adapter.trigger_auto_save(reason, context)


func _collect_save_slot_infos() -> Array[Dictionary]:
	var infos: Array[Dictionary] = []
	var save_system: Object = _resolve_save_system_for_menu()
	for slot: int in range(4):
		infos.append(_get_save_slot_info_dictionary(save_system, slot))
	return infos


func _try_load_first_available_slot() -> bool:
	for slot_info: Dictionary in _collect_save_slot_infos():
		if bool(slot_info.get("exists", false)):
			return load_runtime_from_slot(int(slot_info.get("slot", 0)))
	return false


func _resolve_save_system_for_menu() -> Object:
	if _is_valid_save_system(_save_system):
		return _save_system
	var root_save_system: Object = get_node_or_null("/root/SaveSystem")
	if configure_save_system_runtime(root_save_system):
		return _save_system
	return null


func _get_save_slot_info_dictionary(save_system: Object, slot: int) -> Dictionary:
	var info: Dictionary = _empty_save_slot_info(slot)
	if save_system == null or not is_instance_valid(save_system):
		return info
	if save_system.has_method("get_save_info"):
		var raw_info: Variant = save_system.call("get_save_info", slot)
		if raw_info is Dictionary:
			info = Dictionary(raw_info).duplicate(true)
		elif raw_info != null and raw_info.has_method("to_dictionary"):
			info = Dictionary(raw_info.call("to_dictionary")).duplicate(true)
	elif save_system.has_method("has_save"):
		info["exists"] = bool(save_system.call("has_save", slot))
	info["slot"] = slot
	info["is_auto"] = slot == 0
	if not info.has("summary"):
		info["summary"] = {}
	return info


func _empty_save_slot_info(slot: int) -> Dictionary:
	return {
		"slot": slot,
		"is_auto": slot == 0,
		"exists": false,
		"timestamp": "",
		"play_time_sec": 0.0,
		"save_point_name": "",
		"version": 0,
		"summary": {},
		"file_size_bytes": 0,
	}


func _ensure_save_trigger_adapter() -> bool:
	var existing: Node = get_node_or_null("SaveTriggerAdapter")
	if existing is SaveTriggerAdapter:
		_save_trigger_adapter = existing as SaveTriggerAdapter
		return true
	if _save_trigger_adapter != null and is_instance_valid(_save_trigger_adapter):
		return true
	_save_trigger_adapter = SAVE_TRIGGER_ADAPTER_SCRIPT.new() as SaveTriggerAdapter
	if _save_trigger_adapter == null:
		return false
	_save_trigger_adapter.name = "SaveTriggerAdapter"
	add_child(_save_trigger_adapter)
	return true


func _is_valid_save_system(save_system: Object) -> bool:
	return save_system != null and is_instance_valid(save_system) and save_system.has_method("manual_save")


func _connect_save_system_signals(save_system: Object) -> void:
	if save_system == null or not is_instance_valid(save_system):
		return
	if save_system.has_signal("on_save_written"):
		var written_callback := Callable(self, "_on_save_system_written")
		if not save_system.is_connected("on_save_written", written_callback):
			save_system.connect("on_save_written", written_callback)
	if save_system.has_signal("on_save_write_failed"):
		var failed_callback := Callable(self, "_on_save_system_write_failed")
		if not save_system.is_connected("on_save_write_failed", failed_callback):
			save_system.connect("on_save_write_failed", failed_callback)


func _disconnect_save_system_signals(save_system: Variant) -> void:
	if save_system == null or not is_instance_valid(save_system):
		return
	if save_system.has_signal("on_save_written"):
		var written_callback := Callable(self, "_on_save_system_written")
		if save_system.is_connected("on_save_written", written_callback):
			save_system.disconnect("on_save_written", written_callback)
	if save_system.has_signal("on_save_write_failed"):
		var failed_callback := Callable(self, "_on_save_system_write_failed")
		if save_system.is_connected("on_save_write_failed", failed_callback):
			save_system.disconnect("on_save_write_failed", failed_callback)


func _on_save_system_written(slot: int) -> void:
	if slot > 0 and slot == _pending_manual_save_slot:
		_pending_manual_save_slot = -1
		_hud.show_notification("Game saved", 1.5)
	_refresh_save_menu_if_visible()


func _on_save_system_write_failed(slot: int, _reason: String) -> void:
	if slot > 0 and slot == _pending_manual_save_slot:
		_pending_manual_save_slot = -1
		_hud.show_notification("Save failed", 2.0)
	_refresh_save_menu_if_visible()


func _refresh_save_menu_if_visible() -> void:
	var menu_mode: StringName = _hud.get_menu_mode()
	if menu_mode == &"save_load":
		_hud.show_save_load_menu(
			_collect_save_slot_infos(),
			false,
			"Saving requires a save point"
		)
	elif menu_mode == &"main_menu":
		_hud.show_main_menu(_collect_save_slot_infos())


func _is_manual_save_write_pending() -> bool:
	if _pending_manual_save_slot < 0:
		return false
	if not _is_valid_save_system(_save_system):
		return false
	if not _save_system.has_method("is_save_write_pending"):
		return false
	return bool(_save_system.call("is_save_write_pending"))


func _unregister_main_scene_from_save_system() -> void:
	_disconnect_save_system_signals(_save_system)
	_pending_manual_save_slot = -1
	_save_system = null
	if _registered_save_system == null or not is_instance_valid(_registered_save_system):
		_registered_save_system = null
		return
	if _registered_save_system.has_method("unregister_serializable"):
		_registered_save_system.call("unregister_serializable", MAIN_SCENE_SAVE_KEY)
	_registered_save_system = null


func _disconnect_boss_phase_transition_source() -> void:
	if _boss_phase_transition_source == null or not is_instance_valid(_boss_phase_transition_source):
		_boss_phase_transition_source = null
		return
	if _boss_phase_transition_source.has_signal("on_boss_phase_transition_started"):
		var transition_signal: Signal = _boss_phase_transition_source.get("on_boss_phase_transition_started")
		if transition_signal.is_connected(_handle_boss_phase_transition_started):
			transition_signal.disconnect(_handle_boss_phase_transition_started)
	_boss_phase_transition_source = null


func _get_defeated_bosses() -> Array[String]:
	var defeated: Array[String] = []
	if bool(_world_progress_flags.get("boss_rat_king_defeated", false)):
		defeated.append(RAT_KING_BOSS_ID)
	return defeated


func _get_enemy_display_name() -> String:
	if is_instance_valid(_enemy) and _enemy.has_method("get_display_name"):
		var display_name: String = String(_enemy.call("get_display_name")).strip_edges()
		if display_name != "":
			return display_name
	return RAT_KING_BOSS_DISPLAY_NAME


func _get_enemy_phase() -> int:
	if is_instance_valid(_enemy) and _enemy.has_method("get_current_phase"):
		return maxi(1, int(_enemy.call("get_current_phase")))
	return 1


func _vector2_to_dictionary(value: Vector2) -> Dictionary:
	return {
		"x": value.x,
		"y": value.y,
	}


func _read_vector2_dictionary(value: Variant, fallback: Vector2) -> Vector2:
	if not value is Dictionary:
		return fallback
	var data: Dictionary = Dictionary(value)
	return Vector2(
		float(data.get("x", fallback.x)),
		float(data.get("y", fallback.y))
	)


func _restore_last_savepoint_from_dictionary(savepoint: Dictionary) -> void:
	if savepoint.is_empty():
		_last_discovered_savepoint.clear()
		return
	var savepoint_id: StringName = StringName(savepoint.get("id", ""))
	var scene_id: StringName = StringName(savepoint.get("scene_id", ""))
	var spawn_point: StringName = StringName(savepoint.get("spawn_point", ""))
	var savepoint_position: Vector2 = _read_vector2_dictionary(
		savepoint.get("position", {}),
		_player.global_position
	)
	if not discover_savepoint(savepoint_id, scene_id, spawn_point, savepoint_position):
		_last_discovered_savepoint.clear()


func _setup_weapon_component() -> void:
	_weapon_component = WEAPON_COMPONENT_SCRIPT.new() as WeaponComponent
	_weapon_component.name = "WeaponComponent"
	add_child(_weapon_component)
	var root_data_manager: Node = get_node_or_null("/root/DataManager")
	if root_data_manager != null:
		_weapon_component.set_data_manager(root_data_manager)
	_weapon_component.on_weapon_changed.connect(_on_weapon_changed)
	_acquired_weapons = _weapon_component.get_weapon_ids()
	_sync_weapon_component_from_runtime_state()


func _setup_player_attack_core_chain() -> void:
	var root_data_manager: Node = get_node_or_null("/root/DataManager")
	_damage_calculator_adapter = RUNTIME_DAMAGE_CALCULATOR_ADAPTER_SCRIPT.new(root_data_manager)
	if _player.has_method("set_damage_calculator_adapter"):
		_player.set_damage_calculator_adapter(_damage_calculator_adapter)
	if _player.has_method("set_target_health_adapter"):
		_player.set_target_health_adapter(_enemy)
	if _player.has_method("set_weapon_component"):
		_player.set_weapon_component(_weapon_component)
	if _weapon_component != null:
		if _player.has_method("get_combat_component"):
			_weapon_component.set_combat_adapter(_player.get_combat_component())
		if _player.has_method("get_collision_component"):
			_weapon_component.set_collision_adapter(_player.get_collision_component())


func _setup_enemy_attack_core_chain() -> void:
	if _enemy.has_method("set_damage_calculator_adapter"):
		_enemy.set_damage_calculator_adapter(_damage_calculator_adapter)
	if _enemy.has_method("set_attack_target"):
		_enemy.set_attack_target(_player)
	if not _enemy.enemy_attack_landed.is_connected(_on_enemy_attack_landed):
		_enemy.enemy_attack_landed.connect(_on_enemy_attack_landed)


func _connect_player_focus_mode_signal() -> void:
	var health: Node = _player.get_node_or_null("HealthComponent")
	if health == null or not health.has_signal("on_focus_mode_changed"):
		return
	var focus_signal: Signal = health.get("on_focus_mode_changed")
	var audio_focus_callback := Callable(self, "_on_player_focus_mode_changed")
	if not focus_signal.is_connected(audio_focus_callback):
		focus_signal.connect(audio_focus_callback)


func _on_player_focus_mode_changed(entity_id: int, active: bool, metadata: Dictionary) -> void:
	_combat_presentation.on_focus_mode_changed(entity_id, active, metadata)
	_dispatch_audio_event(&"on_focus_mode_changed", [entity_id, active, metadata])


func _is_player_focus_mode_active() -> bool:
	var health: Node = _player.get_node_or_null("HealthComponent")
	if health == null or not health.has_method("is_focus_mode_active"):
		return false
	return bool(health.call("is_focus_mode_active"))


func _sync_combat_presentation_accessibility_settings() -> void:
	_combat_presentation.set_colorblind_mode(_hud.get_colorblind_mode())


func _on_weapon_changed(weapon: Resource) -> void:
	if weapon == null:
		return
	_current_weapon_id = weapon.weapon_id
	acquire_weapon(_current_weapon_id)
	_weapon_levels[String(_current_weapon_id)] = _weapon_component.get_weapon_level(_current_weapon_id)
	_update_weapon_hud_with_resource(weapon)


func _sync_weapon_component_from_runtime_state() -> void:
	if _weapon_component == null:
		return
	var weapon_ids: Array[StringName] = _weapon_component.get_weapon_ids()
	var current_index: int = weapon_ids.find(_current_weapon_id)
	if current_index < 0:
		current_index = 0
		_current_weapon_id = weapon_ids[current_index]
	_weapon_component.deserialize({
		"version": 1,
		"current_weapon_index": current_index,
		"weapon_levels": _weapon_levels.duplicate(true),
	})


func _update_weapon_hud() -> void:
	if _weapon_component != null:
		var current_weapon: Resource = _weapon_component.get_current_weapon()
		if current_weapon != null:
			_update_weapon_hud_with_resource(current_weapon)
			return
	_hud.update_weapon(_display_name_for_weapon(_current_weapon_id), 0.0)


func _update_weapon_hud_with_resource(weapon: Resource) -> void:
	var display_name: StringName = _display_name_for_weapon(weapon.weapon_id)
	if String(weapon.display_name).strip_edges() != "":
		display_name = StringName(weapon.display_name)
	_hud.update_weapon(display_name, 0.0)


func _apply_weapon_effects_to_player_hit(hit_data: Dictionary) -> Dictionary:
	if _weapon_component == null:
		return hit_data.duplicate(true)
	return _weapon_component.apply_confirmed_hit_effects(_enemy, hit_data)


func _string_names_to_strings(values: Array[StringName]) -> Array[String]:
	var result: Array[String] = []
	for value: StringName in values:
		result.append(String(value))
	return result


func _read_string_name_array(value: Variant) -> Array[StringName]:
	var result: Array[StringName] = []
	if not value is Array:
		return result
	for entry: Variant in value:
		var entry_id: StringName = StringName(String(entry))
		if entry_id != &"" and not result.has(entry_id):
			result.append(entry_id)
	return result


func _read_int(value: Variant, fallback: int) -> int:
	if value is int:
		return value
	if value is float:
		return int(value)
	return fallback


func _display_name_for_weapon(weapon_id: StringName) -> StringName:
	match weapon_id:
		&"long_tail":
			return &"Long Tail"
		&"fish_bone":
			return &"Fish Bone"
		&"electro_bell":
			return &"Electro Bell"
		_:
			return &"Cat Claw"


func _display_name_for_scene_id(scene_id: StringName) -> String:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if scene_manager != null and scene_manager.has_method("get_scene_config"):
		var config_variant: Variant = scene_manager.call("get_scene_config", scene_id)
		if config_variant is Dictionary:
			var display_name: String = String(Dictionary(config_variant).get("display_name", "")).strip_edges()
			if display_name != "":
				return display_name
	match scene_id:
		&"hub":
			return "Clan Base"
		&"main":
			return "Scrap Alley"
		_:
			var words: PackedStringArray = String(scene_id).replace("_", " ").split(" ", false)
			for index: int in range(words.size()):
				words[index] = words[index].capitalize()
			return " ".join(words)
