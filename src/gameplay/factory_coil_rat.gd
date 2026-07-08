## Old Factory coil rat enemy variant using the shared FactorySparkRat loop.
class_name FactoryCoilRat
extends "res://src/gameplay/factory_spark_rat.gd"

const COIL_RAT_ATTACK_HITBOX_ID: StringName = &"factory_coil_rat_bite"
const COIL_RAT_BITE_DAMAGE: int = 10
const COIL_RAT_BITE_HIT_FRAME: int = 121


func get_enemy_family_id() -> StringName:
	return &"factory_coil_rat"


func _build_attack_metadata() -> Dictionary:
	return {
		"source": &"factory_coil_rat",
		"owner_boss_id": get_summon_owner_boss_id(),
		"summon_id": get_current_summon_id(),
		"attack_type": &"light",
		"weapon_id": COIL_RAT_ATTACK_HITBOX_ID,
		"combo_index": 0,
		"hit_frame": COIL_RAT_BITE_HIT_FRAME,
		"attack_power": 0,
		"enemy_defense": 0,
		"injected_damage_params": _build_enemy_damage_params(),
	}


func _build_enemy_damage_params() -> Dictionary:
	return {
		"entries": {
			String(COIL_RAT_ATTACK_HITBOX_ID): {
				"weapon_base": COIL_RAT_BITE_DAMAGE,
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
