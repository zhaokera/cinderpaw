## Typed result payload returned by DamageCalculator.
##
## ADR-0002 requires payloads with more than three fields to use a class_name
## data class instead of an untyped Dictionary.
class_name DamageResult
extends RefCounted

var final_damage: int = 0
var base_damage: int = 0
var attack_damage: float = 0.0
var reduction_factor: float = 1.0
var damage_multiplier: float = 1.0
var is_crit: bool = false
var crit_type: StringName = &"none"
var is_parry: bool = false
var parry_type: StringName = &"none"
var combo_stage: int = 0
var damage_category: StringName = &"scratch"


func _init(
	p_final_damage: int = 0,
	p_base_damage: int = 0,
	p_attack_damage: float = 0.0,
	p_reduction_factor: float = 1.0,
	p_damage_multiplier: float = 1.0
) -> void:
	final_damage = p_final_damage
	base_damage = p_base_damage
	attack_damage = p_attack_damage
	reduction_factor = p_reduction_factor
	damage_multiplier = p_damage_multiplier
