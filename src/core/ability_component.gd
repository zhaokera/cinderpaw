## Core runtime component for player ability unlocks, activation gates, and cooldowns.
class_name AbilityComponent
extends Node

signal ability_unlocked(ability_id: StringName)
signal ability_activated(ability_id: StringName)
signal area_unlock_triggered(ability_id: StringName)
signal airborne_changed(is_airborne: bool)

const ABILITIES_DOMAIN: StringName = &"abilities"
const ABILITY_DASH: StringName = &"dash"
const SAVE_KEY: StringName = &"abilities"

const FALLBACK_ABILITY_CONFIGS: Dictionary = {
	&"basic_attack": {
		"unlock_condition": "game_start",
		"cooldown_sec": 0.0,
		"cooldown_type": "none",
		"air_count_max": 0,
		"requires_airborne": false,
		"combat_state_blocking": [],
	},
	&"jump": {
		"unlock_condition": "game_start",
		"cooldown_sec": 0.0,
		"cooldown_type": "none",
		"air_count_max": 0,
		"requires_airborne": false,
		"combat_state_blocking": [],
	},
	&"dodge": {
		"unlock_condition": "game_start",
		"cooldown_sec": 0.5,
		"cooldown_type": "short",
		"air_count_max": 0,
		"requires_airborne": false,
		"combat_state_blocking": ["HIT_STUN"],
	},
	&"dash": {
		"unlock_condition": "boss_01_rat_king_defeated",
		"unlock_trigger": "boss_defeated",
		"unlock_target": "boss_01_rat_king",
		"cooldown_sec": 1.0,
		"cooldown_type": "medium",
		"air_count_max": 0,
		"requires_airborne": false,
		"combat_state_blocking": ["HIT_STUN"],
	},
	&"double_jump": {
		"unlock_condition": "boss_02_defeated_or_hidden_boss",
		"cooldown_sec": 0.0,
		"cooldown_type": "air_count",
		"air_count_max": 1,
		"requires_airborne": true,
		"combat_state_blocking": [],
	},
	&"aerial_attack": {
		"unlock_condition": "boss_03_defeated",
		"cooldown_sec": 0.0,
		"cooldown_type": "none",
		"air_count_max": 0,
		"requires_airborne": true,
		"combat_state_blocking": [],
	},
	&"wall_climb": {
		"unlock_condition": "boss_04_defeated_or_hidden_altar",
		"cooldown_sec": 0.0,
		"cooldown_type": "none",
		"air_count_max": 0,
		"requires_airborne": false,
		"combat_state_blocking": [],
	},
	&"parry": {
		"unlock_condition": "game_start",
		"cooldown_sec": 0.3,
		"cooldown_type": "short",
		"air_count_max": 0,
		"requires_airborne": false,
		"combat_state_blocking": ["HIT_STUN", "ATTACKING"],
	},
}

var _ability_configs: Dictionary = {}
var _unlocked_abilities: Dictionary = {}
var _cooldown_remaining: Dictionary = {}
var _air_count_used_by_ability: Dictionary = {}
var _is_airborne: bool = false
var _combat: CombatComponent = null
var _data_source: Object = null


func _ready() -> void:
	_refresh_component_refs()
	_load_ability_configs()
	_unlock_initial_abilities(false)


func _physics_process(delta: float) -> void:
	advance_time(delta)


## Injects a DataManager-compatible source for tests or runtime replacement.
func set_data_source(data_source: Object) -> void:
	_data_source = data_source
	_load_ability_configs()
	_unlock_initial_abilities(false)


func has_ability(ability_id: StringName) -> bool:
	return bool(_unlocked_abilities.get(ability_id, false))


func get_unlocked_abilities() -> Array[StringName]:
	var abilities: Array[StringName] = []
	for ability_key: Variant in _unlocked_abilities.keys():
		var ability_id: StringName = StringName(String(ability_key))
		if bool(_unlocked_abilities.get(ability_id, false)):
			abilities.append(ability_id)
	return abilities


func is_ability_on_cooldown(ability_id: StringName) -> bool:
	var config: Dictionary = _get_ability_config(ability_id)
	var cooldown_type: String = String(config.get("cooldown_type", "none"))
	if cooldown_type == "air_count":
		return not _can_use_air_ability(ability_id, config)
	return get_ability_cooldown_remaining(ability_id) > 0.0


func get_ability_cooldown_remaining(ability_id: StringName) -> float:
	return float(_cooldown_remaining.get(ability_id, 0.0))


func unlock_ability(ability_id: StringName) -> bool:
	return _set_ability_unlocked(ability_id, true)


## Replaces save/restored unlocks while preserving start-of-game abilities.
func set_unlocked_abilities(ability_ids: Array) -> void:
	for ability_key: Variant in _unlocked_abilities.keys():
		_unlocked_abilities[ability_key] = false
	_unlock_initial_abilities(false)
	for ability_value: Variant in ability_ids:
		_set_ability_unlocked(StringName(String(ability_value)), false)


func try_activate_ability(ability_id: StringName, context: Dictionary = {}) -> bool:
	if not has_ability(ability_id):
		return false
	if is_ability_on_cooldown(ability_id):
		return false
	if not _check_prerequisites(ability_id, context):
		return false
	ability_activated.emit(ability_id)
	_start_cooldown(ability_id)
	return true


func reset_air_abilities() -> void:
	_air_count_used_by_ability.clear()
	_is_airborne = false
	airborne_changed.emit(false)


## Restores one consumed use for a specific air-count ability without landing.
func restore_air_ability_use(ability_id: StringName) -> bool:
	var config: Dictionary = _get_ability_config(ability_id)
	if maxi(0, int(config.get("air_count_max", 0))) <= 0:
		return false
	var used_count: int = int(_air_count_used_by_ability.get(ability_id, 0))
	if used_count <= 0:
		return false
	if used_count == 1:
		_air_count_used_by_ability.erase(ability_id)
	else:
		_air_count_used_by_ability[ability_id] = used_count - 1
	return true


func set_airborne(is_in_air: bool) -> void:
	if _is_airborne == is_in_air:
		return
	_is_airborne = is_in_air
	if not _is_airborne:
		_air_count_used_by_ability.clear()
	airborne_changed.emit(_is_airborne)


func advance_time(delta_sec: float) -> void:
	var safe_delta: float = maxf(0.0, delta_sec)
	if safe_delta <= 0.0:
		return
	for ability_key: Variant in _cooldown_remaining.keys():
		var ability_id: StringName = StringName(String(ability_key))
		var remaining: float = float(_cooldown_remaining.get(ability_id, 0.0))
		if remaining > 0.0:
			_cooldown_remaining[ability_id] = maxf(0.0, remaining - safe_delta)


func get_save_key() -> StringName:
	return SAVE_KEY


func serialize() -> Dictionary:
	var unlocked: Array[String] = []
	for ability_id: StringName in get_unlocked_abilities():
		unlocked.append(String(ability_id))
	return {
		"version": 1,
		"unlocked": unlocked,
	}


func deserialize(data: Dictionary, _version: int = 1) -> void:
	set_unlocked_abilities(Array(data.get("unlocked", [])))
	for ability_key: Variant in _cooldown_remaining.keys():
		_cooldown_remaining[ability_key] = 0.0
	_air_count_used_by_ability.clear()


func _load_ability_configs() -> void:
	_ability_configs.clear()
	var data_loaded: bool = _load_configs_from_data_source()
	if not data_loaded:
		_load_fallback_configs()
	_reset_runtime_state_for_configs()


func _load_configs_from_data_source() -> bool:
	var data_source: Object = _get_data_source()
	if data_source == null or not data_source.has_method("get_domain"):
		return false
	var domain_value: Variant = data_source.call("get_domain", ABILITIES_DOMAIN)
	if not (domain_value is Dictionary):
		return false
	var domain_entries: Dictionary = domain_value as Dictionary
	if domain_entries.is_empty():
		return false
	for ability_key: Variant in domain_entries.keys():
		var config_value: Variant = domain_entries[ability_key]
		if config_value is Dictionary:
			_ability_configs[StringName(String(ability_key))] = (
				config_value as Dictionary
			).duplicate(true)
	return not _ability_configs.is_empty()


func _load_fallback_configs() -> void:
	for ability_key: Variant in FALLBACK_ABILITY_CONFIGS.keys():
		_ability_configs[ability_key] = Dictionary(FALLBACK_ABILITY_CONFIGS[ability_key]).duplicate(true)


func _reset_runtime_state_for_configs() -> void:
	_unlocked_abilities.clear()
	_cooldown_remaining.clear()
	_air_count_used_by_ability.clear()
	for ability_key: Variant in _ability_configs.keys():
		var ability_id: StringName = StringName(String(ability_key))
		_unlocked_abilities[ability_id] = false
		_cooldown_remaining[ability_id] = 0.0


func _unlock_initial_abilities(emit_events: bool) -> void:
	for ability_key: Variant in _ability_configs.keys():
		var ability_id: StringName = StringName(String(ability_key))
		var config: Dictionary = _get_ability_config(ability_id)
		var unlock_condition: String = String(config.get("unlock_condition", ""))
		if unlock_condition == "game_start" or unlock_condition == "tutorial":
			_set_ability_unlocked(ability_id, emit_events)


func _set_ability_unlocked(ability_id: StringName, emit_events: bool) -> bool:
	if ability_id == &"" or not _ability_configs.has(ability_id):
		return false
	if bool(_unlocked_abilities.get(ability_id, false)):
		return false
	_unlocked_abilities[ability_id] = true
	if emit_events:
		ability_unlocked.emit(ability_id)
		area_unlock_triggered.emit(ability_id)
	return true


func _check_prerequisites(ability_id: StringName, context: Dictionary) -> bool:
	var config: Dictionary = _get_ability_config(ability_id)
	if bool(config.get("requires_airborne", false)) and not _is_airborne:
		return false
	var blocking_states: Array = Array(config.get("combat_state_blocking", []))
	if blocking_states.is_empty():
		return true
	var state_name: String = _get_combat_state_name(context)
	return state_name.is_empty() or not blocking_states.has(state_name)


func _start_cooldown(ability_id: StringName) -> void:
	var config: Dictionary = _get_ability_config(ability_id)
	var cooldown_type: String = String(config.get("cooldown_type", "none"))
	match cooldown_type:
		"short", "medium":
			_cooldown_remaining[ability_id] = _get_effective_cooldown(ability_id)
		"air_count":
			_air_count_used_by_ability[ability_id] = (
				int(_air_count_used_by_ability.get(ability_id, 0)) + 1
			)
		_:
			_cooldown_remaining[ability_id] = 0.0


func _get_effective_cooldown(ability_id: StringName) -> float:
	var config: Dictionary = _get_ability_config(ability_id)
	var effective: float = maxf(0.0, float(config.get("cooldown_sec", 0.0)))
	for modifier: Variant in _get_modifiers_for(ability_id):
		if not (modifier is Dictionary):
			continue
		var modifier_data: Dictionary = modifier as Dictionary
		if String(modifier_data.get("stat_key", "")) == "cooldown":
			effective = _apply_modifier(effective, modifier_data)
	return maxf(0.0, effective)


func _get_modifiers_for(ability_id: StringName) -> Array:
	if get_tree() == null:
		return []
	var skill_tree: Node = get_tree().get_first_node_in_group("skill_tree_manager")
	if skill_tree == null or not skill_tree.has_method("get_modifiers"):
		return []
	var modifiers: Variant = skill_tree.call("get_modifiers", StringName("ability:%s" % ability_id))
	return Array(modifiers) if modifiers is Array else []


func _apply_modifier(base_value: float, modifier: Dictionary) -> float:
	var value: float = float(modifier.get("value", 0.0))
	match String(modifier.get("operation", "add_flat")):
		"add_flat":
			return base_value + value
		"add_percent":
			return base_value * (1.0 + value)
		"multiply":
			return base_value * value
		_:
			return base_value


func _can_use_air_ability(ability_id: StringName, config: Dictionary) -> bool:
	if bool(config.get("requires_airborne", false)) and not _is_airborne:
		return false
	var max_count: int = maxi(0, int(config.get("air_count_max", 0)))
	if max_count <= 0:
		return true
	return int(_air_count_used_by_ability.get(ability_id, 0)) < max_count


func _get_ability_config(ability_id: StringName) -> Dictionary:
	return Dictionary(_ability_configs.get(ability_id, {}))


func _get_combat_state_name(context: Dictionary) -> String:
	var state_value: Variant = context.get("combat_state", null)
	if state_value == null:
		_refresh_component_refs()
		if _combat != null:
			state_value = _combat.get_current_state()
	if state_value == null:
		return ""
	if state_value is StringName or state_value is String:
		return String(state_value)
	if state_value is int:
		var states: Array = CombatComponent.CombatState.keys()
		var state_index: int = int(state_value)
		if state_index >= 0 and state_index < states.size():
			return String(states[state_index])
	return ""


func _refresh_component_refs() -> void:
	var parent_node: Node = get_parent()
	if parent_node == null:
		return
	_combat = parent_node.get_node_or_null("CombatComponent") as CombatComponent


func _get_data_source() -> Object:
	if _data_source != null:
		return _data_source
	if get_tree() == null:
		return null
	return get_node_or_null("/root/DataManager")
