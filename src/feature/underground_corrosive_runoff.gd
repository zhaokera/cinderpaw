## Scene-local corrosive runoff contact hazard for the Underground Passage.
class_name UndergroundCorrosiveRunoff
extends Area2D

@export var hazard_id: StringName = &"underground_corrosive_runoff"
@export var damage: int = 8
@export var contact_cooldown_sec: float = 1.0

@onready var _visual: Sprite2D = get_node_or_null("Visual") as Sprite2D


func _ready() -> void:
	add_to_group("underground_hazard")
	collision_layer = CollisionComponent.COLLISION_LAYER_ENVIRONMENT
	collision_mask = CollisionComponent.COLLISION_MASK_ENVIRONMENT
	monitoring = true
	monitorable = false


## Returns the deterministic id used by scene cooldown and diagnostics state.
func get_hazard_id() -> StringName:
	return hazard_id


## Returns the resolved damage for an accepted contact.
func get_damage() -> int:
	return damage


## Returns the per-target contact cooldown in seconds.
func get_contact_cooldown_sec() -> float:
	return contact_cooldown_sec


## Returns the imported texture path mounted by the visible runoff sprite.
func get_visual_texture_path() -> String:
	if _visual == null or _visual.texture == null:
		return ""
	return _visual.texture.resource_path
