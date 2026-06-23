## Core entity component for weapon style catalog and current weapon queries.
extends Node
class_name WeaponComponent

signal on_weapon_changed(weapon: Resource)
signal on_weapon_upgraded(weapon_id: StringName, new_level: int)

const WEAPON_CONFIG_SCRIPT: Script = preload("res://src/core/weapon_config.gd")
const WEAPON_CONFIG_DOMAIN: StringName = &"weapon_configs"
const WEAPON_CAT_CLAW: StringName = &"cat_claw"
const WEAPON_LONG_TAIL: StringName = &"long_tail"
const WEAPON_FISH_BONE: StringName = &"fish_bone"
const WEAPON_ELECTRO_BELL: StringName = &"electro_bell"
const WEAPON_SWAP_ORDER: Array[StringName] = [
	WEAPON_CAT_CLAW,
	WEAPON_LONG_TAIL,
	WEAPON_FISH_BONE,
	WEAPON_ELECTRO_BELL,
]
const WEAPON_SWAP_DURATION_SEC: float = 0.5
const WEAPON_SWAP_TIMER_EPSILON: float = 0.0001
const COMBAT_STATE_ATTACKING: int = 1

enum SwapState {
	READY,
	SWAPPING,
}

var _data_manager: Object = null
var _combat_adapter: Object = null
var _weapon_configs: Dictionary = {}
var _weapon_levels: Dictionary = {}
var _current_weapon_index: int = 0
var _swap_state: SwapState = SwapState.READY
var _swap_remaining_sec: float = 0.0


func _ready() -> void:
	var root_data_manager: Node = get_node_or_null("/root/DataManager")
	if root_data_manager != null:
		set_data_manager(root_data_manager)


func _physics_process(delta: float) -> void:
	advance_time(delta)


## Injects a DataManager-compatible source and loads the weapon config domain.
func set_data_manager(data_manager: Object) -> void:
	_data_manager = data_manager
	_load_weapon_configs()


## Injects a CombatComponent-compatible adapter for swap gates and reset hooks.
func set_combat_adapter(combat_adapter: Object) -> void:
	_combat_adapter = combat_adapter


## Returns canonical weapon ids in cyclic swap order.
func get_weapon_ids() -> Array[StringName]:
	return WEAPON_SWAP_ORDER.duplicate()


## Returns the loaded config for a weapon id, or null if it is unknown.
func get_weapon_config(weapon_id: StringName) -> Resource:
	return _weapon_configs.get(weapon_id, null) as Resource


## Returns the current weapon config.
func get_current_weapon() -> Resource:
	return get_weapon_config(WEAPON_SWAP_ORDER[_current_weapon_index])


## Returns the next weapon in cyclic order for future HUD previews.
func get_next_weapon() -> Resource:
	var next_index: int = (_current_weapon_index + 1) % WEAPON_SWAP_ORDER.size()
	return get_weapon_config(WEAPON_SWAP_ORDER[next_index])


## Starts the uncancellable weapon swap timer when combat allows it.
func request_swap() -> bool:
	if _swap_state != SwapState.READY or _is_combat_attacking():
		return false
	_swap_state = SwapState.SWAPPING
	_swap_remaining_sec = WEAPON_SWAP_DURATION_SEC
	_call_combat_hook(&"notify_weapon_swapping")
	return true


## Advances deterministic swap timing for tests and frame processing.
func advance_time(delta_sec: float) -> void:
	if _swap_state != SwapState.SWAPPING:
		return
	_swap_remaining_sec = maxf(0.0, _swap_remaining_sec - maxf(0.0, delta_sec))
	if _swap_remaining_sec <= WEAPON_SWAP_TIMER_EPSILON:
		_complete_swap()


## Returns true while a weapon swap is locked in progress.
func is_swap_active() -> bool:
	return _swap_state == SwapState.SWAPPING


## Returns remaining swap time for deterministic tests and future animation sync.
func get_swap_remaining_time() -> float:
	return _swap_remaining_sec


## Returns the zero-based level index for a weapon. Level 1 is index 0.
func get_weapon_level(weapon_id: StringName) -> int:
	return int(_weapon_levels.get(weapon_id, 0))


## Test and data hook for setting a weapon level by zero-based index.
func set_weapon_level(weapon_id: StringName, level_index: int) -> bool:
	var config: Resource = get_weapon_config(weapon_id)
	if config == null or config.upgrade_damage_table.is_empty():
		return false
	if level_index < 0 or level_index >= config.upgrade_damage_table.size():
		return false
	_weapon_levels[weapon_id] = level_index
	return true


## Upgrades a weapon by one level, stopping at level 5.
func upgrade_weapon(weapon_id: StringName) -> bool:
	var config: Resource = get_weapon_config(weapon_id)
	if config == null or config.upgrade_damage_table.is_empty():
		return false
	var current_level: int = get_weapon_level(weapon_id)
	if current_level >= config.upgrade_damage_table.size() - 1:
		return false
	var new_level: int = current_level + 1
	_weapon_levels[weapon_id] = new_level
	on_weapon_upgraded.emit(weapon_id, new_level + 1)
	return true


## Returns the next upgrade damage preview, or -1 when maxed or unknown.
func get_next_level_damage(weapon_id: StringName) -> int:
	var config: Resource = get_weapon_config(weapon_id)
	if config == null or config.upgrade_damage_table.is_empty():
		return -1
	var next_level: int = get_weapon_level(weapon_id) + 1
	if next_level >= config.upgrade_damage_table.size():
		return -1
	return config.get_damage_for_level(next_level)


## Returns base damage for the current weapon or for an explicitly supplied id.
func get_effective_base_damage(weapon_id: StringName = &"") -> int:
	var resolved_id: StringName = weapon_id
	if String(resolved_id).is_empty():
		var current: Resource = get_current_weapon()
		if current == null:
			return 0
		resolved_id = current.weapon_id
	var config: Resource = get_weapon_config(resolved_id)
	if config == null:
		return 0
	return config.get_damage_for_level(get_weapon_level(resolved_id))


## Returns combat-facing attack parameters for the active weapon.
func get_attack_parameters() -> Dictionary:
	var weapon: Resource = get_current_weapon()
	if weapon == null:
		return {}
	return {
		"weapon_id": weapon.weapon_id,
		"base_damage": get_effective_base_damage(weapon.weapon_id),
		"combo_multipliers": weapon.combo_multipliers.duplicate(),
		"attack_range": weapon.attack_range,
		"attack_speed": weapon.attack_speed,
		"special_attack_id": weapon.special_attack_id,
		"special_mechanism": weapon.special_mechanism.duplicate(true),
		"hitbox_offset": weapon.hitbox_offset,
		"hitbox_size": weapon.hitbox_size,
	}


## Serializes weapon state for the future SaveSystem caller.
func serialize() -> Dictionary:
	var serialized_levels: Dictionary = {}
	for weapon_id: StringName in WEAPON_SWAP_ORDER:
		serialized_levels[String(weapon_id)] = get_weapon_level(weapon_id)
	return {
		"version": 1,
		"current_weapon_index": _current_weapon_index,
		"weapon_levels": serialized_levels,
	}


## Restores weapon state defensively from SaveSystem-compatible data.
func deserialize(data: Dictionary) -> void:
	var restored_index: int = int(data.get("current_weapon_index", 0))
	if restored_index < 0 or restored_index >= WEAPON_SWAP_ORDER.size():
		restored_index = 0
	_current_weapon_index = restored_index
	var restored_levels: Dictionary = {}
	var level_data: Variant = data.get("weapon_levels", {})
	if level_data is Dictionary:
		restored_levels = level_data as Dictionary
	for weapon_id: StringName in WEAPON_SWAP_ORDER:
		var raw_level: int = 0
		var raw_entry: Variant = _lookup_entry(restored_levels, weapon_id)
		if raw_entry != null:
			raw_level = int(raw_entry)
		var config: Resource = get_weapon_config(weapon_id)
		if config == null or config.upgrade_damage_table.is_empty():
			_weapon_levels[weapon_id] = 0
			continue
		_weapon_levels[weapon_id] = clampi(raw_level, 0, config.upgrade_damage_table.size() - 1)
	var current_weapon: Resource = get_current_weapon()
	if current_weapon != null:
		on_weapon_changed.emit(current_weapon)


func _load_weapon_configs() -> void:
	_weapon_configs.clear()
	if _data_manager == null or not _data_manager.has_method("get_domain"):
		return
	var domain: Variant = _data_manager.call("get_domain", WEAPON_CONFIG_DOMAIN)
	if not (domain is Dictionary):
		return
	var entries: Dictionary = domain as Dictionary
	for weapon_id: StringName in WEAPON_SWAP_ORDER:
		var entry: Variant = _lookup_entry(entries, weapon_id)
		if entry is Dictionary:
			var config: Resource = WEAPON_CONFIG_SCRIPT.new()
			config.configure_from_dictionary(entry as Dictionary)
			_weapon_configs[weapon_id] = config
			if not _weapon_levels.has(weapon_id):
				_weapon_levels[weapon_id] = 0


func _lookup_entry(entries: Dictionary, weapon_id: StringName) -> Variant:
	if entries.has(weapon_id):
		return entries[weapon_id]
	var string_id: String = String(weapon_id)
	if entries.has(string_id):
		return entries[string_id]
	return null


func _complete_swap() -> void:
	_current_weapon_index = (_current_weapon_index + 1) % WEAPON_SWAP_ORDER.size()
	_call_combat_hook(&"reset_combo")
	_reset_combat_dodge_cooldown()
	_swap_state = SwapState.READY
	_swap_remaining_sec = 0.0
	var current_weapon: Resource = get_current_weapon()
	if current_weapon != null:
		on_weapon_changed.emit(current_weapon)


func _is_combat_attacking() -> bool:
	if _combat_adapter == null or not _combat_adapter.has_method("get_current_state"):
		return false
	return int(_combat_adapter.call("get_current_state")) == COMBAT_STATE_ATTACKING


func _reset_combat_dodge_cooldown() -> void:
	if _call_combat_hook(&"reset_dodge_cooldown"):
		return
	if _combat_adapter != null and _combat_adapter.has_method("advance_dodge_cooldown_time"):
		_combat_adapter.call("advance_dodge_cooldown_time", WEAPON_SWAP_DURATION_SEC)


func _call_combat_hook(method_name: StringName) -> bool:
	if _combat_adapter == null or not _combat_adapter.has_method(String(method_name)):
		return false
	_combat_adapter.call(method_name)
	return true
