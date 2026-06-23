## Typed bridge Resource for weapon style JSON data.
extends Resource
class_name WeaponConfig

@export var weapon_id: StringName = &""
@export var display_name: String = ""
@export var style: StringName = &""
@export var base_damage_range: Vector2i = Vector2i.ZERO
@export var attack_speed: float = 1.0
@export var attack_range: float = 1.0
@export var combo_multipliers: Array[float] = []
@export var upgrade_damage_table: Array[int] = []
@export var special_attack_id: StringName = &""
@export var special_cooldown_sec: float = 0.0
@export var special_damage_multiplier: float = 1.0
@export var special_mechanism: Dictionary = {}
@export var hitbox_offset: Vector2 = Vector2.ZERO
@export var hitbox_size: Vector2 = Vector2.ZERO


func configure_from_dictionary(data: Dictionary) -> void:
	weapon_id = StringName(data.get("weapon_id", ""))
	display_name = String(data.get("display_name", ""))
	style = StringName(data.get("style", ""))
	base_damage_range = _vector2i_from_dict(data.get("base_damage_range", {}))
	attack_speed = float(data.get("attack_speed", 1.0))
	attack_range = float(data.get("attack_range", 1.0))
	combo_multipliers = _float_array(data.get("combo_multipliers", []))
	upgrade_damage_table = _int_array(data.get("upgrade_damage_table", []))
	special_attack_id = StringName(data.get("special_attack_id", ""))
	special_cooldown_sec = float(data.get("special_cooldown_sec", 0.0))
	special_damage_multiplier = float(data.get("special_damage_multiplier", 1.0))
	special_mechanism = _dictionary_copy(data.get("special_mechanism", {}))
	hitbox_offset = _vector2_from_dict(data.get("hitbox_offset", {}))
	hitbox_size = _vector2_from_dict(data.get("hitbox_size", {}))


func get_damage_for_level(level_index: int) -> int:
	if upgrade_damage_table.is_empty():
		return 0
	var clamped_index: int = clampi(level_index, 0, upgrade_damage_table.size() - 1)
	return int(upgrade_damage_table[clamped_index])


func get_snapshot() -> Dictionary:
	return {
		"weapon_id": weapon_id,
		"display_name": display_name,
		"style": style,
		"base_damage_range": base_damage_range,
		"attack_speed": attack_speed,
		"attack_range": attack_range,
		"combo_multipliers": combo_multipliers.duplicate(),
		"upgrade_damage_table": upgrade_damage_table.duplicate(),
		"special_attack_id": special_attack_id,
		"special_cooldown_sec": special_cooldown_sec,
		"special_damage_multiplier": special_damage_multiplier,
		"special_mechanism": special_mechanism.duplicate(true),
		"hitbox_offset": hitbox_offset,
		"hitbox_size": hitbox_size,
	}


static func _float_array(value: Variant) -> Array[float]:
	var result: Array[float] = []
	if value is Array:
		for entry: Variant in value:
			result.append(float(entry))
	return result


static func _int_array(value: Variant) -> Array[int]:
	var result: Array[int] = []
	if value is Array:
		for entry: Variant in value:
			result.append(int(entry))
	return result


static func _dictionary_copy(value: Variant) -> Dictionary:
	if value is Dictionary:
		return (value as Dictionary).duplicate(true)
	return {}


static func _vector2i_from_dict(value: Variant) -> Vector2i:
	if not (value is Dictionary):
		return Vector2i.ZERO
	var data: Dictionary = value as Dictionary
	return Vector2i(int(data.get("x", 0)), int(data.get("y", 0)))


static func _vector2_from_dict(value: Variant) -> Vector2:
	if not (value is Dictionary):
		return Vector2.ZERO
	var data: Dictionary = value as Dictionary
	return Vector2(float(data.get("x", 0.0)), float(data.get("y", 0.0)))
