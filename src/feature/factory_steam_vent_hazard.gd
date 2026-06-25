## Scene-local Old Factory steam vent contact hazard.
class_name FactorySteamVentHazard
extends Area2D

@export var hazard_id: StringName = &"old_factory_steam_vent"
@export var damage: int = 8
@export var contact_cooldown_sec: float = 1.0

@onready var _visual: Sprite2D = get_node_or_null("Visual") as Sprite2D


func _ready() -> void:
	add_to_group("factory_hazard")
	collision_layer = CollisionComponent.COLLISION_LAYER_ENVIRONMENT
	collision_mask = CollisionComponent.COLLISION_MASK_ENVIRONMENT
	monitoring = true
	monitorable = false


## Returns the deterministic hazard id used by diagnostics and cooldown keys.
func get_hazard_id() -> StringName:
	return hazard_id


## Returns the imported texture path mounted by the visible hazard sprite.
func get_visual_texture_path() -> String:
	if _visual == null or _visual.texture == null:
		return ""
	return _visual.texture.resource_path


## Returns the resolved contact damage for this hazard.
func get_damage() -> int:
	return damage


## Returns the contact cooldown in seconds for repeated overlap damage.
func get_contact_cooldown_sec() -> float:
	return contact_cooldown_sec
