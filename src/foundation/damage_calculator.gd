## Stateless damage formula utility.
##
## ADR-0001 defines DamageCalculator as a class_name static utility, not an
## Autoload. Story 001 covers DC-F1, DC-F3, DC-F4, and category metadata.
## Story 003 keeps upper-layer modifiers as injected data dictionaries.
class_name DamageCalculator
extends RefCounted

const DAMAGE_RESULT_SCRIPT: Script = preload("res://src/foundation/damage_result.gd")

## Registers runtime tuning knobs used by the public damage API.
static func register_damage_tuning_knobs(data_manager: Node) -> void:
	if data_manager == null or not data_manager.has_method("register_tuning"):
		return
	data_manager.register_tuning(&"damage.multiplier", &"float", 1.0, 0.5, 2.0, &"damage")
	data_manager.register_tuning(&"damage.defense_curve_constant", &"float", 60.0, 30.0, 100.0, &"damage")
	data_manager.register_tuning(&"damage.floor", &"int", 1, 1, 10, &"damage")
	data_manager.register_tuning(&"damage.cap", &"int", 999, 100, 9999, &"damage")


## Public GDD damage API. Optional injected data keeps tests independent.
static func calculate_damage(
	attack_type: StringName,
	weapon_id: StringName,
	hit_frame: int,
	combo_index: int,
	parry_timing: int,
	attack_power: int,
	enemy_defense: int,
	skill_modifiers: Dictionary = {},
	injected_params: Dictionary = {},
	data_manager: Node = null
) -> RefCounted:
	var global_params: Dictionary = _resolve_global_params(injected_params, data_manager)
	var weapon_params: Dictionary = _resolve_weapon_params(weapon_id, injected_params, data_manager)
	var base_damage: int = calculate_base_damage_with_modifiers(
		_param_int(weapon_params, &"weapon_base", 0),
		attack_power,
		skill_modifiers
	)
	var crit_type: StringName = classify_crit_type_with_modifiers(hit_frame, 0, skill_modifiers)
	var crit_multiplier: float = _crit_multiplier_for_type(crit_type, global_params)
	var options: Dictionary = _damage_options(global_params, data_manager)
	match attack_type:
		&"parry":
			return _calculate_data_parry(base_damage, enemy_defense, parry_timing, crit_type, crit_multiplier, global_params, options)
		&"special":
			return _calculate_data_special(base_damage, enemy_defense, weapon_params, crit_type, crit_multiplier, global_params, options)
		&"heavy", &"heavy_min", &"heavy_max", &"charged", &"aerial", &"aerial_dive":
			return _calculate_data_attack_type(base_damage, enemy_defense, attack_type, crit_type, crit_multiplier, global_params, options)
		_:
			return _calculate_data_normal(base_damage, enemy_defense, weapon_params, combo_index, crit_type, crit_multiplier, global_params, options)


## Calculates the Story 001 baseline pipeline: base_damage -> final_damage.
static func calculate_basic_damage(
	weapon_base: int,
	attack_power: int,
	defense: int,
	damage_multiplier: float,
	defense_curve_constant: float = 60.0,
	damage_floor: int = 1,
	damage_cap: int = 999
) -> RefCounted:
	var base_damage: int = calculate_base_damage(weapon_base, attack_power)
	var reduction_factor: float = calculate_reduction_factor(defense, defense_curve_constant)
	var final_damage: int = apply_final_damage(
		float(base_damage),
		reduction_factor,
		damage_multiplier,
		damage_floor,
		damage_cap
	)
	var result: RefCounted = DAMAGE_RESULT_SCRIPT.new(
		final_damage,
		base_damage,
		float(base_damage),
		reduction_factor,
		damage_multiplier
	)
	result.damage_category = classify_damage_category(final_damage)
	return result


## Calculates a normal attack path: base_damage * crit * combo.
static func calculate_normal_damage(
	weapon_base: int,
	attack_power: int,
	defense: int,
	damage_multiplier: float,
	weapon_id: StringName = &"cat_claw",
	combo_index: int = 0,
	hit_frame: int = -1,
	window_start: int = 0,
	skill_modifiers: Dictionary = {}
) -> RefCounted:
	var base_damage: int = calculate_base_damage_with_modifiers(weapon_base, attack_power, skill_modifiers)
	var crit_type: StringName = classify_crit_type_with_modifiers(hit_frame, window_start, skill_modifiers)
	var crit_multiplier: float = calculate_crit_multiplier_with_modifiers(hit_frame, window_start, skill_modifiers)
	var combo_multiplier: float = calculate_combo_multiplier(weapon_id, combo_index)
	var attack_damage: float = float(base_damage) * crit_multiplier * combo_multiplier
	var result: RefCounted = _build_result(base_damage, attack_damage, defense, damage_multiplier)
	result.is_crit = crit_type != &"none"
	result.crit_type = crit_type
	result.combo_stage = combo_index if combo_index >= 0 and combo_index < 3 else 0
	return result


## Calculates a parry attack path: base_damage * parry * crit.
static func calculate_parry_damage(
	weapon_base: int,
	attack_power: int,
	defense: int,
	damage_multiplier: float,
	frame_diff: int,
	hit_frame: int = -1,
	_weapon_id: StringName = &"cat_claw",
	_combo_index: int = 0,
	window_start: int = 0,
	skill_modifiers: Dictionary = {}
) -> RefCounted:
	var base_damage: int = calculate_base_damage_with_modifiers(weapon_base, attack_power, skill_modifiers)
	var crit_type: StringName = classify_crit_type_with_modifiers(hit_frame, window_start, skill_modifiers)
	var parry_type: StringName = classify_parry_type(frame_diff)
	var attack_damage: float = (
		float(base_damage)
		* calculate_parry_multiplier(frame_diff)
		* calculate_crit_multiplier_with_modifiers(hit_frame, window_start, skill_modifiers)
	)
	var result: RefCounted = _build_result(base_damage, attack_damage, defense, damage_multiplier)
	result.is_crit = crit_type != &"none"
	result.crit_type = crit_type
	result.is_parry = parry_type != &"none"
	result.parry_type = parry_type
	result.combo_stage = 0
	return result


## Calculates a DC-F9 special move path. Combo and parry multipliers are ignored.
static func calculate_special_damage(
	weapon_base: int,
	attack_power: int,
	defense: int,
	damage_multiplier: float,
	weapon_id: StringName,
	hit_frame: int = -1,
	window_start: int = 0,
	skill_modifiers: Dictionary = {},
	_combo_index: int = 0
) -> RefCounted:
	var base_damage: int = calculate_base_damage_with_modifiers(weapon_base, attack_power, skill_modifiers)
	var crit_type: StringName = classify_crit_type_with_modifiers(hit_frame, window_start, skill_modifiers)
	var crit_multiplier: float = calculate_crit_multiplier_with_modifiers(hit_frame, window_start, skill_modifiers)
	var hit_count: int = calculate_special_hit_count(weapon_id)
	var per_hit_attack_damage: float = float(base_damage) * calculate_special_multiplier(weapon_id) * crit_multiplier
	var reduction_factor: float = calculate_reduction_factor(defense)
	var final_damage: int = 0
	for _hit_index: int in range(hit_count):
		final_damage += apply_final_damage(per_hit_attack_damage, reduction_factor, damage_multiplier)
	var result: RefCounted = DAMAGE_RESULT_SCRIPT.new(
		final_damage,
		base_damage,
		per_hit_attack_damage * float(hit_count),
		reduction_factor,
		damage_multiplier
	)
	result.is_crit = crit_type != &"none"
	result.crit_type = crit_type
	result.combo_stage = 0
	result.damage_category = classify_damage_category(final_damage)
	return result


## Calculates heavy/aerial DC-F2 third-path damage without combo or parry.
static func calculate_attack_type_damage(
	weapon_base: int,
	attack_power: int,
	defense: int,
	damage_multiplier: float,
	attack_type: StringName,
	hit_frame: int = -1,
	window_start: int = 0,
	skill_modifiers: Dictionary = {},
	_combo_index: int = 0,
	_frame_diff: int = -1
) -> RefCounted:
	var base_damage: int = calculate_base_damage_with_modifiers(weapon_base, attack_power, skill_modifiers)
	var crit_type: StringName = classify_crit_type_with_modifiers(hit_frame, window_start, skill_modifiers)
	var attack_damage: float = (
		float(base_damage)
		* calculate_attack_type_multiplier(attack_type, skill_modifiers)
		* calculate_crit_multiplier_with_modifiers(hit_frame, window_start, skill_modifiers)
	)
	var result: RefCounted = _build_result(base_damage, attack_damage, defense, damage_multiplier)
	result.is_crit = crit_type != &"none"
	result.crit_type = crit_type
	result.combo_stage = 0
	return result


## DC-F1: weapon_base + floor(attack_power * 0.2).
static func calculate_base_damage(weapon_base: int, attack_power: int) -> int:
	return weapon_base + int(floor(float(attack_power) * 0.2))


## DC-F1 with skill-tree F9 style weapon-base bonus injected as data.
static func calculate_base_damage_with_modifiers(
	weapon_base: int,
	attack_power: int,
	skill_modifiers: Dictionary = {}
) -> int:
	var skill_weapon_bonus: float = _modifier_float(skill_modifiers, &"skill_weapon_bonus", 0.0)
	var skill_weapon_base: int = max(0, int(floor(float(weapon_base) * (1.0 + skill_weapon_bonus))))
	return calculate_base_damage(skill_weapon_base, attack_power)


## DC-F5 base crit window: PERFECT [start,start+3), GOOD [start+3,start+6).
static func calculate_crit_multiplier(hit_frame: int, window_start: int = 0) -> float:
	match classify_crit_type(hit_frame, window_start):
		&"perfect":
			return 2.5
		&"good":
			return 1.8
		_:
			return 1.0


## Returns the base crit label for a hit frame.
static func classify_crit_type(hit_frame: int, window_start: int = 0) -> StringName:
	if hit_frame >= window_start and hit_frame < window_start + 3:
		return &"perfect"
	if hit_frame >= window_start + 3 and hit_frame < window_start + 6:
		return &"good"
	return &"none"


## DC-F5 crit multiplier with injected charm/focus perfect-window bonuses.
static func calculate_crit_multiplier_with_modifiers(
	hit_frame: int,
	window_start: int = 0,
	skill_modifiers: Dictionary = {}
) -> float:
	match classify_crit_type_with_modifiers(hit_frame, window_start, skill_modifiers):
		&"perfect":
			return 2.5
		&"good":
			return 1.8
		_:
			return 1.0


## Returns the crit label after extending the PERFECT sub-window.
static func classify_crit_type_with_modifiers(
	hit_frame: int,
	window_start: int = 0,
	skill_modifiers: Dictionary = {}
) -> StringName:
	var perfect_width: int = 3 + int(_modifier_float(skill_modifiers, &"charm_crit_window_bonus_frames", 0.0))
	perfect_width += int(_modifier_float(skill_modifiers, &"focus_crit_window_bonus_frames", 0.0))
	perfect_width = max(0, perfect_width)
	if hit_frame >= window_start and hit_frame < window_start + perfect_width:
		return &"perfect"
	if hit_frame >= window_start + perfect_width and hit_frame < window_start + perfect_width + 3:
		return &"good"
	return &"none"


## DC-F6: weapon combo multiplier lookup.
static func calculate_combo_multiplier(weapon_id: StringName, combo_index: int) -> float:
	match weapon_id:
		&"cat_claw":
			return _combo_value(combo_index, 1.0, 1.2, 1.8)
		&"long_tail":
			return _combo_value(combo_index, 1.0, 1.15, 1.7)
		&"fish_bone":
			return _combo_value(combo_index, 1.0, 1.3, 2.2)
		&"electro_bell":
			return _combo_value(combo_index, 1.0, 1.1, 1.5)
		_:
			return 1.0


## DC-F9 special multiplier lookup. Story 004 moves these values into JSON.
static func calculate_special_multiplier(weapon_id: StringName) -> float:
	match weapon_id:
		&"cat_claw":
			return 0.8
		&"long_tail":
			return 1.5
		&"fish_bone":
			return 2.0
		_:
			return 1.0


## DC-F9 special hit-count lookup. Story 004 moves these values into JSON.
static func calculate_special_hit_count(weapon_id: StringName) -> int:
	match weapon_id:
		&"cat_claw":
			return 5
		_:
			return 1


## DC-F2 third-path multiplier for heavy/aerial attacks.
static func calculate_attack_type_multiplier(
	attack_type: StringName,
	skill_modifiers: Dictionary = {}
) -> float:
	match attack_type:
		&"heavy", &"heavy_min", &"heavy_max", &"charged", &"aerial", &"aerial_dive":
			return max(0.0, _modifier_float(skill_modifiers, &"attack_type_multiplier", 1.0))
		_:
			return 1.0


## DC-F7 parry timing multiplier.
static func calculate_parry_multiplier(frame_diff: int) -> float:
	match classify_parry_type(frame_diff):
		&"perfect":
			return 5.0
		&"good":
			return 2.5
		&"late":
			return 1.5
		_:
			return 1.0


## Returns the parry label for the half-open frame_diff intervals.
static func classify_parry_type(frame_diff: int) -> StringName:
	if frame_diff >= 0 and frame_diff < 7:
		return &"perfect"
	if frame_diff >= 7 and frame_diff < 13:
		return &"good"
	if frame_diff >= 13 and frame_diff < 19:
		return &"late"
	return &"none"


## DC-F3: 60 / (max(0, defense) + 60), with a tunable constant.
static func calculate_reduction_factor(defense: int, defense_curve_constant: float = 60.0) -> float:
	var safe_defense: int = max(0, defense)
	var safe_constant: float = max(0.001, defense_curve_constant)
	return safe_constant / (float(safe_defense) + safe_constant)


## DC-F4 with explicit reduction_factor.
static func apply_final_damage(
	attack_damage: float,
	reduction_factor: float,
	damage_multiplier: float,
	damage_floor: int = 1,
	damage_cap: int = 999
) -> int:
	var raw_damage: int = int(floor(attack_damage * reduction_factor * damage_multiplier))
	return clampi(raw_damage, damage_floor, damage_cap)


## DC-F4 with defense converted through DC-F3.
static func calculate_final_damage(
	attack_damage: float,
	defense: int,
	damage_multiplier: float,
	defense_curve_constant: float = 60.0,
	damage_floor: int = 1,
	damage_cap: int = 999
) -> int:
	var reduction_factor: float = calculate_reduction_factor(defense, defense_curve_constant)
	return apply_final_damage(attack_damage, reduction_factor, damage_multiplier, damage_floor, damage_cap)


## Maps final damage to the GDD damage-number feedback category.
static func classify_damage_category(final_damage: int) -> StringName:
	if final_damage <= 5:
		return &"scratch"
	if final_damage <= 15:
		return &"normal"
	if final_damage <= 30:
		return &"strong"
	if final_damage <= 60:
		return &"powerful"
	if final_damage <= 150:
		return &"extreme"
	return &"legendary"


static func _calculate_data_normal(
	base_damage: int,
	defense: int,
	weapon_params: Dictionary,
	combo_index: int,
	crit_type: StringName,
	crit_multiplier: float,
	global_params: Dictionary,
	options: Dictionary
) -> RefCounted:
	var combo_multiplier: float = _combo_multiplier_from_params(weapon_params, combo_index)
	var attack_damage: float = float(base_damage) * crit_multiplier * combo_multiplier
	var result: RefCounted = _build_result_with_options(base_damage, attack_damage, defense, options, global_params)
	result.is_crit = crit_type != &"none"
	result.crit_type = crit_type
	result.combo_stage = combo_index if combo_index >= 0 and combo_index < 3 else 0
	return result


static func _calculate_data_parry(
	base_damage: int,
	defense: int,
	frame_diff: int,
	crit_type: StringName,
	crit_multiplier: float,
	global_params: Dictionary,
	options: Dictionary
) -> RefCounted:
	var parry_type: StringName = classify_parry_type(frame_diff)
	var parry_multiplier: float = _parry_multiplier_for_type(parry_type, global_params)
	var attack_damage: float = float(base_damage) * parry_multiplier * crit_multiplier
	var result: RefCounted = _build_result_with_options(base_damage, attack_damage, defense, options, global_params)
	result.is_crit = crit_type != &"none"
	result.crit_type = crit_type
	result.is_parry = parry_type != &"none"
	result.parry_type = parry_type
	result.combo_stage = 0
	return result


static func _calculate_data_attack_type(
	base_damage: int,
	defense: int,
	attack_type: StringName,
	crit_type: StringName,
	crit_multiplier: float,
	global_params: Dictionary,
	options: Dictionary
) -> RefCounted:
	var type_multiplier: float = _attack_type_multiplier_from_params(attack_type, global_params)
	var attack_damage: float = float(base_damage) * type_multiplier * crit_multiplier
	var result: RefCounted = _build_result_with_options(base_damage, attack_damage, defense, options, global_params)
	result.is_crit = crit_type != &"none"
	result.crit_type = crit_type
	result.combo_stage = 0
	return result


static func _calculate_data_special(
	base_damage: int,
	defense: int,
	weapon_params: Dictionary,
	crit_type: StringName,
	crit_multiplier: float,
	global_params: Dictionary,
	options: Dictionary
) -> RefCounted:
	var special: Dictionary = _param_dict(weapon_params, &"special_move")
	var per_hit_attack_damage: float = float(base_damage) * _param_float(special, &"multiplier", 1.0) * crit_multiplier
	var hit_count: int = max(1, _param_int(special, &"hits", 1))
	var reduction_factor: float = calculate_reduction_factor(defense, options["defense_curve_constant"])
	var final_damage: int = 0
	for _hit_index: int in range(hit_count):
		final_damage += apply_final_damage(per_hit_attack_damage, reduction_factor, options["damage_multiplier"], options["damage_floor"], options["damage_cap"])
	var result: RefCounted = DAMAGE_RESULT_SCRIPT.new(final_damage, base_damage, per_hit_attack_damage * float(hit_count), reduction_factor, options["damage_multiplier"])
	result.is_crit = crit_type != &"none"
	result.crit_type = crit_type
	result.combo_stage = 0
	result.damage_category = _classify_damage_category_from_params(final_damage, global_params)
	return result


static func _build_result_with_options(
	base_damage: int,
	attack_damage: float,
	defense: int,
	options: Dictionary,
	global_params: Dictionary
) -> RefCounted:
	var reduction_factor: float = calculate_reduction_factor(defense, options["defense_curve_constant"])
	var final_damage: int = apply_final_damage(
		attack_damage,
		reduction_factor,
		options["damage_multiplier"],
		options["damage_floor"],
		options["damage_cap"]
	)
	var result: RefCounted = DAMAGE_RESULT_SCRIPT.new(
		final_damage,
		base_damage,
		attack_damage,
		reduction_factor,
		options["damage_multiplier"]
	)
	result.damage_category = _classify_damage_category_from_params(final_damage, global_params)
	return result


static func _build_result(
	base_damage: int,
	attack_damage: float,
	defense: int,
	damage_multiplier: float,
	defense_curve_constant: float = 60.0,
	damage_floor: int = 1,
	damage_cap: int = 999
) -> RefCounted:
	var reduction_factor: float = calculate_reduction_factor(defense, defense_curve_constant)
	var final_damage: int = apply_final_damage(
		attack_damage,
		reduction_factor,
		damage_multiplier,
		damage_floor,
		damage_cap
	)
	var result: RefCounted = DAMAGE_RESULT_SCRIPT.new(
		final_damage,
		base_damage,
		attack_damage,
		reduction_factor,
		damage_multiplier
	)
	result.damage_category = classify_damage_category(final_damage)
	return result


static func _combo_value(combo_index: int, first: float, second: float, third: float) -> float:
	match combo_index:
		0:
			return first
		1:
			return second
		2:
			return third
		_:
			return 1.0


static func _modifier_float(skill_modifiers: Dictionary, key: StringName, default_value: float) -> float:
	var value: Variant = default_value
	if skill_modifiers.has(key):
		value = skill_modifiers[key]
	elif skill_modifiers.has(String(key)):
		value = skill_modifiers[String(key)]
	match typeof(value):
		TYPE_INT, TYPE_FLOAT:
			return float(value)
		_:
			return default_value


static func _resolve_global_params(injected_params: Dictionary, data_manager: Node) -> Dictionary:
	var injected_entries: Dictionary = _param_dict(injected_params, &"entries")
	if injected_entries.has(&"_global"):
		return injected_entries[&"_global"] as Dictionary
	if injected_entries.has("_global"):
		return injected_entries["_global"] as Dictionary
	if injected_params.has(&"_global") and injected_params[&"_global"] is Dictionary:
		return injected_params[&"_global"] as Dictionary
	if injected_params.has("_global") and injected_params["_global"] is Dictionary:
		return injected_params["_global"] as Dictionary
	if data_manager != null and data_manager.has_method("get_entry"):
		var entry: Variant = data_manager.get_entry(&"damage_params", &"_global")
		if entry is Dictionary:
			return entry as Dictionary
	return {}


static func _resolve_weapon_params(
	weapon_id: StringName,
	injected_params: Dictionary,
	data_manager: Node
) -> Dictionary:
	var injected_entries: Dictionary = _param_dict(injected_params, &"entries")
	if injected_entries.has(weapon_id) and injected_entries[weapon_id] is Dictionary:
		return injected_entries[weapon_id] as Dictionary
	if injected_entries.has(String(weapon_id)) and injected_entries[String(weapon_id)] is Dictionary:
		return injected_entries[String(weapon_id)] as Dictionary
	if injected_params.has(weapon_id) and injected_params[weapon_id] is Dictionary:
		return injected_params[weapon_id] as Dictionary
	if data_manager != null and data_manager.has_method("get_entry"):
		var entry: Variant = data_manager.get_entry(&"damage_params", weapon_id)
		if entry is Dictionary:
			return entry as Dictionary
	return {}


static func _damage_options(global_params: Dictionary, data_manager: Node) -> Dictionary:
	var multiplier: float = _param_float(global_params, &"damage_multiplier", 1.0)
	var curve_constant: float = _param_float(global_params, &"defense_curve_constant", 60.0)
	var damage_floor: int = _param_int(global_params, &"damage_floor", 1)
	var damage_cap: int = _param_int(global_params, &"damage_cap", 999)
	return {
		"damage_multiplier": _tuning_float(data_manager, &"damage.multiplier", multiplier),
		"defense_curve_constant": _tuning_float(data_manager, &"damage.defense_curve_constant", curve_constant),
		"damage_floor": _tuning_int(data_manager, &"damage.floor", damage_floor),
		"damage_cap": _tuning_int(data_manager, &"damage.cap", damage_cap),
	}


static func _crit_multiplier_for_type(crit_type: StringName, global_params: Dictionary) -> float:
	var multipliers: Dictionary = _param_dict(global_params, &"crit_multipliers")
	match crit_type:
		&"perfect":
			return _param_float(multipliers, &"perfect", 2.5)
		&"good":
			return _param_float(multipliers, &"good", 1.8)
		_:
			return _param_float(multipliers, &"none", 1.0)


static func _parry_multiplier_for_type(parry_type: StringName, global_params: Dictionary) -> float:
	var multipliers: Dictionary = _param_dict(global_params, &"parry_multipliers")
	match parry_type:
		&"perfect":
			return _param_float(multipliers, &"perfect", 5.0)
		&"good":
			return _param_float(multipliers, &"good", 2.5)
		&"late":
			return _param_float(multipliers, &"late", 1.5)
		_:
			return _param_float(multipliers, &"none", 1.0)


static func _combo_multiplier_from_params(weapon_params: Dictionary, combo_index: int) -> float:
	var multipliers: Dictionary = _param_dict(weapon_params, &"combo_multipliers")
	return _param_float(multipliers, StringName(str(combo_index)), 1.0)


static func _attack_type_multiplier_from_params(
	attack_type: StringName,
	global_params: Dictionary
) -> float:
	var multipliers: Dictionary = _param_dict(global_params, &"attack_type_multipliers")
	return _param_float(multipliers, attack_type, 1.0)


static func _classify_damage_category_from_params(final_damage: int, global_params: Dictionary) -> StringName:
	var thresholds: Dictionary = _param_dict(global_params, &"category_thresholds")
	if thresholds.is_empty():
		return classify_damage_category(final_damage)
	if final_damage <= _param_int(thresholds, &"scratch_max", 5):
		return &"scratch"
	if final_damage <= _param_int(thresholds, &"normal_max", 15):
		return &"normal"
	if final_damage <= _param_int(thresholds, &"strong_max", 30):
		return &"strong"
	if final_damage <= _param_int(thresholds, &"powerful_max", 60):
		return &"powerful"
	if final_damage <= _param_int(thresholds, &"extreme_max", 150):
		return &"extreme"
	return &"legendary"


static func _tuning_float(data_manager: Node, knob_id: StringName, fallback: float) -> float:
	if data_manager == null or not data_manager.has_method("get_tuning") or not _has_tuning(data_manager, knob_id):
		return fallback
	return float(data_manager.get_tuning(knob_id, fallback))


static func _tuning_int(data_manager: Node, knob_id: StringName, fallback: int) -> int:
	if data_manager == null or not data_manager.has_method("get_tuning") or not _has_tuning(data_manager, knob_id):
		return fallback
	return int(data_manager.get_tuning(knob_id, fallback))


static func _has_tuning(data_manager: Node, knob_id: StringName) -> bool:
	var tuning_knobs: Variant = data_manager.get("_tuning_knobs")
	return tuning_knobs is Dictionary and (tuning_knobs as Dictionary).has(knob_id)


static func _param_dict(source: Dictionary, key: StringName) -> Dictionary:
	var value: Variant = _param_value(source, key, {})
	if value is Dictionary:
		return value as Dictionary
	return {}


static func _param_int(source: Dictionary, key: StringName, default_value: int) -> int:
	var value: Variant = _param_value(source, key, default_value)
	match typeof(value):
		TYPE_INT, TYPE_FLOAT:
			return int(value)
		_:
			return default_value


static func _param_float(source: Dictionary, key: StringName, default_value: float) -> float:
	var value: Variant = _param_value(source, key, default_value)
	match typeof(value):
		TYPE_INT, TYPE_FLOAT:
			return float(value)
		_:
			return default_value


static func _param_value(source: Dictionary, key: StringName, default_value: Variant) -> Variant:
	if source.has(key):
		return source[key]
	var string_key: String = String(key)
	if source.has(string_key):
		return source[string_key]
	return default_value
