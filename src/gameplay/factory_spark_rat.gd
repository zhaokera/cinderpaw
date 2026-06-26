## Old Factory spark rat enemy variant using the shared RatMinion combat loop.
class_name FactorySparkRat
extends "res://src/gameplay/rat_minion.gd"

const SPARK_RAT_ATTACK_HITBOX_ID: StringName = &"factory_spark_rat_bite"
const SPARK_RAT_BITE_DAMAGE: int = 9
const SPARK_RAT_BITE_HIT_FRAME: int = 101


func get_enemy_family_id() -> StringName:
	return &"factory_spark_rat"


func _build_attack_metadata() -> Dictionary:
	return {
		"source": &"factory_spark_rat",
		"owner_boss_id": get_summon_owner_boss_id(),
		"summon_id": get_current_summon_id(),
		"attack_type": &"light",
		"weapon_id": SPARK_RAT_ATTACK_HITBOX_ID,
		"combo_index": 0,
		"hit_frame": SPARK_RAT_BITE_HIT_FRAME,
		"attack_power": 0,
		"enemy_defense": 0,
		"injected_damage_params": _build_enemy_damage_params(),
	}


func _build_enemy_damage_params() -> Dictionary:
	return {
		"entries": {
			String(SPARK_RAT_ATTACK_HITBOX_ID): {
				"weapon_base": SPARK_RAT_BITE_DAMAGE,
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
