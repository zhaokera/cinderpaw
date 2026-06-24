## Main playable scene wiring for the current vertical slice.
extends Node2D

@onready var _player: PlayerController = $Player
@onready var _enemy: SimpleEnemy = $Enemy
@onready var _hud = $HUD
@onready var _combat_presentation = $CombatPresentation
@onready var _game_flow = $GameFlowController

const BATTLE_SUMMARY_ENABLED: bool = false
const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")
const RUNTIME_DAMAGE_CALCULATOR_ADAPTER_SCRIPT: Script = preload("res://src/gameplay/runtime_damage_calculator_adapter.gd")

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


func _ready() -> void:
	_setup_weapon_component()
	_setup_player_attack_core_chain()
	_game_flow.set_no_loss_state_adapter(self)
	_game_flow.start_boss_encounter(_player.global_position, self)
	_game_flow.respawn_requested.connect(_on_respawn_requested)
	_game_flow.victory_reached.connect(_on_victory_reached)
	_hud.menu_pause_requested.connect(_on_menu_pause_requested)
	_hud.menu_resume_requested.connect(_on_menu_resume_requested)
	_hud.menu_retry_requested.connect(_on_menu_retry_requested)
	_player.player_health_changed.connect(_on_player_health_changed)
	_player.player_died.connect(_on_player_died)
	_player.attack_landed.connect(_on_player_attack_landed)
	_player.attack_started.connect(_combat_presentation.on_weapon_attack_event)
	_enemy.enemy_health_changed.connect(_on_enemy_health_changed)
	_enemy.enemy_defeated.connect(_on_enemy_defeated)
	_combat_presentation.set_camera($Player/Camera2D)

	_hud.update_hp(_player.get_current_hp(), _player.get_max_hp())
	_hud.update_boss_hp(_enemy.get_current_hp(), _enemy.get_max_hp(), 1, "Shadow Beast")
	_hud.update_currency(_currency_amount)
	_update_weapon_hud()
	_hud.show_notification("Hunt the shadow beast", 2.0)


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
	if BATTLE_SUMMARY_ENABLED:
		_hud.show_battle_summary(_battle_summary_from_death_metadata(death_metadata))
	_hud.show_notification("Cinderpaw falls - reviving", 1.5)


func _on_player_attack_landed(hit_data: Dictionary) -> void:
	var enriched_hit_data: Dictionary = _apply_weapon_effects_to_player_hit(hit_data)
	_last_player_hit_metadata = enriched_hit_data.duplicate(true)
	_combat_presentation.on_hit_event(enriched_hit_data)


func _on_enemy_health_changed(current_hp: int, max_hp: int) -> void:
	_hud.update_boss_hp(current_hp, max_hp, 1, "Shadow Beast")


func _on_enemy_defeated() -> void:
	_combat_presentation.on_kill_event(2, _enemy.global_position + Vector2(0, -24))
	_game_flow.handle_enemy_defeated()


func _on_respawn_requested(respawn_position: Vector2, revive_hp_percentage: float) -> void:
	_player.respawn_at(respawn_position, revive_hp_percentage)
	_hud.update_hp(_player.get_current_hp(), _player.get_max_hp())
	_hud.show_notification("Nine lives remain", 2.0)


func _on_victory_reached() -> void:
	_hud.hide_boss_hp()
	grant_currency(25)
	_hud.show_notification("Shadow beast defeated", 3.0)
	_hud.show_retry_menu("Shadow beast defeated", "Retry the encounter or stay with your prize.")


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
	_hud.update_boss_hp(_enemy.get_current_hp(), _enemy.get_max_hp(), 1, "Shadow Beast")


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
		"world_flags": _world_progress_flags.duplicate(true),
	}


func restore_no_loss_state(snapshot: Dictionary) -> void:
	_currency_amount = maxi(0, _read_int(snapshot.get("currency", _currency_amount), _currency_amount))
	_inventory_items = _read_string_name_array(snapshot.get("inventory", _inventory_items))
	var weapon_state: Dictionary = Dictionary(snapshot.get("weapons", {}))
	_current_weapon_id = StringName(String(weapon_state.get("current_weapon", String(_current_weapon_id))))
	_acquired_weapons = _read_string_name_array(weapon_state.get("acquired", _acquired_weapons))
	_weapon_levels = Dictionary(weapon_state.get("levels", _weapon_levels)).duplicate(true)
	_world_progress_flags = Dictionary(snapshot.get("world_flags", _world_progress_flags)).duplicate(true)
	_sync_weapon_component_from_runtime_state()
	_hud.update_currency(_currency_amount)
	_update_weapon_hud()


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
