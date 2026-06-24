## Core entity component for weapon style catalog and current weapon queries.
extends Node
class_name WeaponComponent

signal on_weapon_changed(weapon: Resource)
signal on_weapon_upgraded(weapon_id: StringName, new_level: int)
signal on_special_attack_started(attack_id: StringName)
signal on_special_cooldown(remaining_sec: float)
signal on_insufficient_energy(required_energy: int)

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
const SPECIAL_COOLDOWN_TIMER_EPSILON: float = 0.0001
const COMBAT_STATE_ATTACKING: int = 1
const SPECIAL_CAT_ENERGY_COST_BY_ATTACK: Dictionary = {
	&"gale_claw": 30,
	&"whirlwind_slash": 40,
	&"earth_splitter": 50,
	&"em_pulse": 60,
}

enum SwapState {
	READY,
	SWAPPING,
}

var _data_manager: Object = null
var _combat_adapter: Object = null
var _collision_adapter: Object = null
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
	_sync_combat_weapon_id()


## Injects a CollisionComponent-compatible adapter for weapon hitbox activation.
func set_collision_adapter(collision_adapter: Object) -> void:
	_collision_adapter = collision_adapter


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


## Activates the current weapon's attack hitbox through CollisionComponent.
func activate_current_attack_hitbox(
	attack_type: StringName = &"light",
	duration_frames: int = 3,
	combo_index: int = 0
) -> bool:
	if _collision_adapter == null or not _collision_adapter.has_method("activate_hitbox"):
		return false
	var weapon: Resource = get_current_weapon()
	if weapon == null:
		return false
	var hitbox_id: StringName = StringName("%s_%s" % [String(weapon.weapon_id), String(attack_type)])
	_collision_adapter.call(
		"activate_hitbox",
		hitbox_id,
		maxi(1, duration_frames),
		weapon.hitbox_offset,
		weapon.hitbox_size,
		_build_attack_hitbox_metadata(weapon, attack_type, combo_index)
	)
	return true


## Applies current-weapon effects after a confirmed hit.
func apply_confirmed_hit_effects(target_adapter: Object, hit_metadata: Dictionary = {}) -> Dictionary:
	var metadata: Dictionary = hit_metadata.duplicate(true)
	metadata["shield_break_attempted"] = false
	metadata["shield_broken"] = false
	var weapon: Resource = get_current_weapon()
	if weapon == null:
		metadata["shield_break_skipped_reason"] = &"missing_weapon"
		return metadata
	var mechanism: Dictionary = weapon.special_mechanism.duplicate(true)
	var mechanism_type: StringName = StringName(mechanism.get("type", &""))
	metadata["weapon_id"] = weapon.weapon_id
	metadata["mechanism_type"] = mechanism_type
	if mechanism_type != &"shield_break":
		metadata["shield_break_skipped_reason"] = &"not_shield_break_weapon"
		return metadata
	return _apply_shield_break_hit_effect(target_adapter, metadata)


## Returns special attack metadata for the active weapon or an explicit weapon id.
func get_special_attack_parameters(weapon_id: StringName = &"") -> Dictionary:
	var resolved_id: StringName = weapon_id
	if String(resolved_id).is_empty():
		var current_weapon: Resource = get_current_weapon()
		if current_weapon == null:
			return {}
		resolved_id = current_weapon.weapon_id
	var weapon: Resource = get_weapon_config(resolved_id)
	if weapon == null:
		return {}
	return {
		"weapon_id": weapon.weapon_id,
		"attack_id": weapon.special_attack_id,
		"cooldown_sec": weapon.special_cooldown_sec,
		"required_energy": _get_special_energy_cost(weapon.special_attack_id),
		"cooldown_remaining_sec": _get_special_cooldown_remaining(weapon.weapon_id),
	}


## Requests the active weapon special if cat energy and cooldown gates pass.
func request_special_attack() -> bool:
	var weapon: Resource = get_current_weapon()
	if weapon == null:
		return false
	var cooldown_remaining: float = _get_special_cooldown_remaining(weapon.weapon_id)
	if cooldown_remaining > SPECIAL_COOLDOWN_TIMER_EPSILON:
		on_special_cooldown.emit(cooldown_remaining)
		return false
	var required_energy: int = _get_special_energy_cost(weapon.special_attack_id)
	if _get_combat_cat_energy() < required_energy:
		on_insufficient_energy.emit(required_energy)
		return false
	if not _try_start_combat_special(weapon.weapon_id):
		return false
	on_special_attack_started.emit(weapon.special_attack_id)
	return true


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
		_sync_combat_weapon_id()
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
		_sync_combat_weapon_id()
		on_weapon_changed.emit(current_weapon)


func _is_combat_attacking() -> bool:
	if _combat_adapter == null or not _combat_adapter.has_method("get_current_state"):
		return false
	return int(_combat_adapter.call("get_current_state")) == COMBAT_STATE_ATTACKING


func _get_special_energy_cost(attack_id: StringName) -> int:
	return int(SPECIAL_CAT_ENERGY_COST_BY_ATTACK.get(attack_id, 0))


func _get_special_cooldown_remaining(weapon_id: StringName) -> float:
	if _combat_adapter == null or not _combat_adapter.has_method("get_special_cooldown_remaining"):
		return 0.0
	return maxf(0.0, float(_combat_adapter.call("get_special_cooldown_remaining", weapon_id)))


func _get_combat_cat_energy() -> int:
	if _combat_adapter == null or not _combat_adapter.has_method("get_cat_energy"):
		return 0
	return maxi(0, int(_combat_adapter.call("get_cat_energy")))


func _try_start_combat_special(weapon_id: StringName) -> bool:
	if _combat_adapter == null or not _combat_adapter.has_method("try_use_special"):
		return false
	return bool(_combat_adapter.call("try_use_special", weapon_id))


func _build_attack_hitbox_metadata(weapon: Resource, attack_type: StringName, combo_index: int) -> Dictionary:
	var mechanism: Dictionary = weapon.special_mechanism.duplicate(true)
	var mechanism_type: StringName = StringName(mechanism.get("type", &""))
	var is_multi_target: bool = mechanism_type == &"multi_target"
	var max_targets: int = 1
	if is_multi_target:
		max_targets = maxi(1, int(mechanism.get("max_targets", 1)))
	return {
		"weapon_id": weapon.weapon_id,
		"attack_type": attack_type,
		"combo_index": clampi(combo_index, 0, 2),
		"base_damage": get_effective_base_damage(weapon.weapon_id),
		"attack_range": weapon.attack_range,
		"multi_target": is_multi_target,
		"targeting_type": &"multi_target" if is_multi_target else &"single_target",
		"max_targets": max_targets,
		"mechanism_type": mechanism_type,
		"special_mechanism": mechanism,
	}


func _apply_shield_break_hit_effect(target_adapter: Object, metadata: Dictionary) -> Dictionary:
	var attack_type: StringName = StringName(metadata.get("attack_type", &""))
	var charge_ratio: float = _get_combat_charge_ratio()
	metadata["charge_ratio"] = charge_ratio
	if not _is_charge_attack_type(attack_type):
		metadata["shield_break_skipped_reason"] = &"not_charge_attack"
		return metadata
	if charge_ratio < 1.0:
		metadata["shield_break_skipped_reason"] = &"partial_charge"
		return metadata
	metadata["shield_break_attempted"] = true
	if target_adapter == null or not target_adapter.has_method("break_shield"):
		metadata["shield_break_skipped_reason"] = &"missing_break_shield"
		return metadata
	var break_result: Variant = target_adapter.call("break_shield")
	metadata["shield_broken"] = true if break_result == null else bool(break_result)
	metadata["shield_break_skipped_reason"] = &"" if bool(metadata["shield_broken"]) else &"no_active_shield"
	return metadata


func _get_combat_charge_ratio() -> float:
	if _combat_adapter == null or not _combat_adapter.has_method("get_charge_ratio"):
		return 0.0
	return clampf(float(_combat_adapter.call("get_charge_ratio")), 0.0, 1.0)


func _is_charge_attack_type(attack_type: StringName) -> bool:
	match attack_type:
		&"heavy", &"heavy_min", &"heavy_max", &"charged":
			return true
		_:
			return false


func _sync_combat_weapon_id() -> void:
	if _combat_adapter == null or not _combat_adapter.has_method("set_current_weapon_id"):
		return
	var current_weapon: Resource = get_current_weapon()
	if current_weapon == null:
		return
	_combat_adapter.call("set_current_weapon_id", current_weapon.weapon_id)


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
