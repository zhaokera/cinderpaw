## Old Factory sluice leech variant with a readable tell and forward lunge.
class_name FactorySluiceLeech
extends "res://src/gameplay/factory_spark_rat.gd"

const SLUICE_LEECH_ATTACK_HITBOX_ID: StringName = &"factory_sluice_leech_lunge"
const SLUICE_LEECH_ATTACK_TELL_ANIMATION: StringName = &"attack_tell"
const SLUICE_LEECH_ATTACK_TELL_FRAMES: int = 18
const SLUICE_LEECH_BITE_DAMAGE: int = 11
const SLUICE_LEECH_BITE_HIT_FRAME: int = 126
const SLUICE_LEECH_LUNGE_SPEED: float = 168.0
const SLUICE_LEECH_HITBOX_SIZE: Vector2 = Vector2(46.0, 22.0)
const SLUICE_LEECH_HITBOX_OFFSET: Vector2 = Vector2(34.0, -20.0)


func get_enemy_family_id() -> StringName:
	return &"factory_sluice_leech"


func _build_attack_metadata() -> Dictionary:
	return {
		"source": &"factory_sluice_leech",
		"owner_boss_id": get_summon_owner_boss_id(),
		"summon_id": get_current_summon_id(),
		"attack_type": &"light",
		"weapon_id": SLUICE_LEECH_ATTACK_HITBOX_ID,
		"combo_index": 0,
		"hit_frame": SLUICE_LEECH_BITE_HIT_FRAME,
		"attack_power": 0,
		"enemy_defense": 0,
		"injected_damage_params": _build_enemy_damage_params(),
	}


func _build_enemy_damage_params() -> Dictionary:
	return {
		"entries": {
			String(SLUICE_LEECH_ATTACK_HITBOX_ID): {
				"weapon_base": SLUICE_LEECH_BITE_DAMAGE,
				"combo_multipliers": {
					"0": 1.0,
				},
				"special_move": {
					"multiplier": 1.0,
					"hits": 1,
				},
			},
		},
	}


func _get_attack_tell_animation() -> StringName:
	return SLUICE_LEECH_ATTACK_TELL_ANIMATION


func _get_attack_tell_frames() -> int:
	return SLUICE_LEECH_ATTACK_TELL_FRAMES


func _enter_attack_active() -> void:
	_state = State.ATTACK_ACTIVE
	_attack_timer = ATTACK_ACTIVE_FRAMES
	_play_character_animation(ANIMATION_ATTACK, true)
	if _collision != null:
		_collision.activate_hitbox(
			SLUICE_LEECH_ATTACK_HITBOX_ID,
			ATTACK_ACTIVE_FRAMES,
			Vector2(
				_facing * SLUICE_LEECH_HITBOX_OFFSET.x,
				SLUICE_LEECH_HITBOX_OFFSET.y
			),
			SLUICE_LEECH_HITBOX_SIZE,
			_build_attack_metadata()
		)


func _process_attack_active(delta: float) -> void:
	velocity.x = _facing * SLUICE_LEECH_LUNGE_SPEED * _get_movement_modifier()
	velocity.y += GRAVITY * delta
	move_and_slide()
	_update_sprite_facing()
	_play_character_animation(ANIMATION_ATTACK)
	_attack_timer -= 1
	if _attack_timer <= 0:
		velocity.x = 0.0
		_state = State.ATTACK_RECOVERY
		_attack_timer = ATTACK_RECOVERY_FRAMES
