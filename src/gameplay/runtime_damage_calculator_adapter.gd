## Thin runtime adapter that lets CombatComponent call the static DamageCalculator API.
extends RefCounted
class_name RuntimeDamageCalculatorAdapter

var _data_manager: Node = null


func _init(data_manager: Node = null) -> void:
	_data_manager = data_manager


## Sets the DataManager source used by DamageCalculator's data-driven path.
func set_data_manager(data_manager: Node) -> void:
	_data_manager = data_manager


## Forwards CombatComponent damage requests to the static DamageCalculator utility.
func calculate_damage(
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
	var resolved_data_manager: Node = data_manager if data_manager != null else _data_manager
	return DamageCalculator.calculate_damage(
		attack_type,
		weapon_id,
		hit_frame,
		combo_index,
		parry_timing,
		attack_power,
		enemy_defense,
		skill_modifiers,
		injected_params,
		resolved_data_manager
	)
