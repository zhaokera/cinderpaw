## Old Factory spark rat enemy variant using the shared RatMinion combat loop.
class_name FactorySparkRat
extends "res://src/gameplay/rat_minion.gd"

const SPARK_RAT_ATTACK_HITBOX_ID: StringName = &"factory_spark_rat_bite"
const SPARK_RAT_BITE_DAMAGE: int = 9
const SPARK_RAT_BITE_HIT_FRAME: int = 101
const SPARK_RAT_ATTACK_TELL_ANIMATION: StringName = &"attack_tell"
const SPARK_RAT_ATTACK_TELL_FRAMES: int = 12
const SPARK_RAT_OPENING_GRACE_FRAMES: int = 18
const SPARK_RAT_ALERT_RADIUS_PX: float = 180.0
const SPARK_RAT_PATROL_HALF_WIDTH_PX: float = 28.0
const SPARK_RAT_PATROL_SPEED: float = 56.0

var _opening_grace_frames_remaining: int = 0
var _opening_grace_total_frames: int = SPARK_RAT_OPENING_GRACE_FRAMES
var _patrol_center_x: float = 0.0
var _patrol_center_initialized: bool = false


func get_enemy_family_id() -> StringName:
	return &"factory_spark_rat"


func set_attack_target(target: Node) -> void:
	_attack_target = target
	if _combat != null:
		_combat.set_health_adapter(_attack_target)
	if target == null:
		_opening_grace_frames_remaining = 0


func begin_pacing(opening_grace_frames: int = SPARK_RAT_OPENING_GRACE_FRAMES) -> void:
	_patrol_center_x = global_position.x
	_patrol_center_initialized = true
	_opening_grace_total_frames = maxi(0, opening_grace_frames)
	_opening_grace_frames_remaining = _opening_grace_total_frames
	if _opening_grace_frames_remaining > 0:
		_play_character_animation(ANIMATION_IDLE, true)


func advance_pacing_frames(frames: int) -> void:
	for _index: int in range(maxi(0, frames)):
		_physics_process(1.0 / 60.0)


func get_pacing_diagnostics() -> Dictionary:
	_ensure_patrol_center()
	return {
		"pacing_state": String(_get_pacing_state()),
		"opening_grace_frames": _opening_grace_frames_remaining,
		"opening_grace_total_frames": _opening_grace_total_frames,
		"alert_radius_px": SPARK_RAT_ALERT_RADIUS_PX,
		"target_distance": _get_target_distance(),
		"target_in_alert_radius": _is_target_in_alert_radius(),
		"patrol_center_x": _patrol_center_x,
		"patrol_left_x": _get_patrol_left_x(),
		"patrol_right_x": _get_patrol_right_x(),
		"attack_startup_frames": get_attack_startup_frames(),
		"attack_sequence_id": get_current_attack_sequence_id(),
		"attack_active": is_enemy_attack_active(),
		"current_animation": String(_sprite.animation) if _sprite != null else "",
	}


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


func _get_attack_tell_animation() -> StringName:
	return SPARK_RAT_ATTACK_TELL_ANIMATION


func _get_attack_tell_frames() -> int:
	return SPARK_RAT_ATTACK_TELL_FRAMES


func _process_chase(delta: float) -> void:
	_ensure_patrol_center()
	if _opening_grace_frames_remaining > 0:
		_process_opening_grace(delta)
		return
	if _attack_target != null and not _is_target_in_alert_radius():
		_process_patrol(delta)
		return
	if _can_auto_attack_target():
		request_attack()
		return
	velocity.x = _direction_to_target() * CHASE_SPEED * _get_movement_modifier()
	velocity.y += GRAVITY * delta
	move_and_slide()
	_update_sprite_facing()
	if absf(velocity.x) > 1.0:
		_play_character_animation(ANIMATION_RUN)
	else:
		_play_character_animation(ANIMATION_IDLE)


func _process_opening_grace(delta: float) -> void:
	_opening_grace_frames_remaining = maxi(_opening_grace_frames_remaining - 1, 0)
	velocity.x = 0.0
	velocity.y += GRAVITY * delta
	move_and_slide()
	_update_sprite_facing()
	_play_character_animation(ANIMATION_IDLE)


func _process_patrol(delta: float) -> void:
	if global_position.x <= _get_patrol_left_x():
		_facing = 1.0
	elif global_position.x >= _get_patrol_right_x():
		_facing = -1.0
	velocity.x = _facing * SPARK_RAT_PATROL_SPEED * _get_movement_modifier()
	velocity.y += GRAVITY * delta
	move_and_slide()
	_update_sprite_facing()
	_play_character_animation(ANIMATION_RUN)


func _get_pacing_state() -> StringName:
	match _state:
		State.DEAD:
			return &"death"
		State.HIT:
			return &"hit"
		State.ATTACK_TELL:
			return &"attack_tell"
		State.ATTACK_ACTIVE:
			return &"attack_active"
		State.ATTACK_RECOVERY:
			return &"attack_recovery"
		State.CHASE:
			if _attack_target == null:
				return &"inactive"
			if _opening_grace_frames_remaining > 0:
				return &"opening_grace"
			if not _is_target_in_alert_radius():
				return &"patrol"
			return &"chase"
	return &"unknown"


func _is_target_in_alert_radius() -> bool:
	if _attack_target == null:
		return false
	return _get_target_distance() <= SPARK_RAT_ALERT_RADIUS_PX


func _get_target_distance() -> float:
	if _attack_target == null:
		return INF
	return global_position.distance_to(_attack_target.global_position)


func _ensure_patrol_center() -> void:
	if _patrol_center_initialized:
		return
	_patrol_center_x = global_position.x
	_patrol_center_initialized = true


func _get_patrol_left_x() -> float:
	return _patrol_center_x - SPARK_RAT_PATROL_HALF_WIDTH_PX


func _get_patrol_right_x() -> float:
	return _patrol_center_x + SPARK_RAT_PATROL_HALF_WIDTH_PX
