## Underground-specific one-shot salvage cache using the shared reward contract.
class_name UndergroundSalvageCache
extends "res://src/feature/factory_combat_cache.gd"


func _ready() -> void:
	super._ready()
	remove_from_group("factory_combat_cache")
	add_to_group("underground_salvage_cache")
