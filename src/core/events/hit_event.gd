## Typed payload emitted when a hitbox confirms a hurtbox hit.
extends RefCounted
class_name HitEvent

var attacker_id: int
var target_id: int
var hitbox_id: StringName
var hit_position: Vector2
var hit_frame: int
var attack_metadata: Dictionary


func _init(
	p_attacker_id: int = -1,
	p_target_id: int = -1,
	p_hitbox_id: StringName = &"",
	p_hit_position: Vector2 = Vector2.ZERO,
	p_hit_frame: int = 0,
	p_attack_metadata: Dictionary = {}
) -> void:
	attacker_id = p_attacker_id
	target_id = p_target_id
	hitbox_id = p_hitbox_id
	hit_position = p_hit_position
	hit_frame = p_hit_frame
	attack_metadata = p_attack_metadata.duplicate(true)
