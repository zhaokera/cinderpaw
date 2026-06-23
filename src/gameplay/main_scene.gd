## Main playable scene wiring for the current vertical slice.
extends Node2D

@onready var _player: PlayerController = $Player
@onready var _enemy: SimpleEnemy = $Enemy
@onready var _hud = $HUD
@onready var _combat_presentation = $CombatPresentation
@onready var _game_flow = $GameFlowController

const BATTLE_SUMMARY_ENABLED: bool = false

var _pause_menu_active: bool = false
var _currency_amount: int = 0
var _inventory_items: Array[StringName] = []
var _acquired_weapons: Array[StringName] = [&"cat_claw"]
var _current_weapon_id: StringName = &"cat_claw"
var _weapon_levels: Dictionary = {"cat_claw": 0}
var _world_progress_flags: Dictionary = {}


func _ready() -> void:
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
	_enemy.enemy_health_changed.connect(_on_enemy_health_changed)
	_enemy.enemy_defeated.connect(_on_enemy_defeated)
	_combat_presentation.set_camera($Player/Camera2D)

	_hud.update_hp(_player.get_current_hp(), _player.get_max_hp())
	_hud.update_boss_hp(_enemy.get_current_hp(), _enemy.get_max_hp(), 1, "Shadow Beast")
	_hud.update_currency(_currency_amount)
	_hud.show_notification("Hunt the shadow beast", 2.0)


func _process(_delta: float) -> void:
	_player.set_control_locked(_game_flow.is_player_control_locked())


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	_hud.update_hp(current_hp, max_hp)


func _on_player_died(death_metadata: Dictionary) -> void:
	_game_flow.handle_player_death()
	if BATTLE_SUMMARY_ENABLED:
		_hud.show_battle_summary(_battle_summary_from_death_metadata(death_metadata))
	_hud.show_notification("Cinderpaw falls - reviving", 1.5)


func _on_player_attack_landed(hit_data: Dictionary) -> void:
	_combat_presentation.on_hit_event(hit_data)


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
	_hud.update_currency(_currency_amount)
	_hud.update_weapon(_display_name_for_weapon(_current_weapon_id), 0.0)


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
		_hud.update_weapon(_display_name_for_weapon(_current_weapon_id), 0.0)


func set_world_progress_flag(flag_id: StringName, enabled: bool = true) -> void:
	if flag_id == &"":
		return
	_world_progress_flags[String(flag_id)] = enabled


func get_runtime_progress_state() -> Dictionary:
	return capture_no_loss_state()


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
