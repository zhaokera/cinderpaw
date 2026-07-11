## Deep Underground elite with a long tell and committed leap-lunge.
class_name UndergroundCisternStalker
extends "res://src/gameplay/factory_sluice_leech.gd"

const STALKER_MAX_HP: int = 48
const STALKER_ATTACK_HITBOX_ID: StringName = &"underground_cistern_stalker_leap"
const STALKER_ATTACK_TELL_FRAMES: int = 24
const STALKER_ATTACK_ACTIVE_FRAMES: int = 6
const STALKER_ATTACK_RECOVERY_FRAMES: int = 18
const STALKER_ATTACK_DAMAGE: int = 14
const STALKER_ATTACK_HIT_FRAME: int = 133
const STALKER_LEAP_SPEED_X: float = 216.0
const STALKER_LEAP_SPEED_Y: float = -210.0
const STALKER_ATTACK_RANGE_PX: float = 124.0
const STALKER_HITBOX_SIZE: Vector2 = Vector2(58.0, 30.0)
const STALKER_HITBOX_OFFSET: Vector2 = Vector2(38.0, -28.0)
const STALKER_HURTBOX_SIZE: Vector2 = Vector2(58.0, 38.0)


func get_enemy_family_id() -> StringName:
	return &"underground_cistern_stalker"


func get_current_hp() -> int:
	if _health == null:
		return STALKER_MAX_HP
	return _health.get_current_hp()


func get_max_hp() -> int:
	if _health == null:
		return STALKER_MAX_HP
	return _health.get_max_hp()


func get_attack_active_frames() -> int:
	return STALKER_ATTACK_ACTIVE_FRAMES


func get_attack_recovery_frames() -> int:
	return STALKER_ATTACK_RECOVERY_FRAMES


func get_attack_damage() -> int:
	return STALKER_ATTACK_DAMAGE


func get_leap_velocity() -> Vector2:
	return Vector2(STALKER_LEAP_SPEED_X, STALKER_LEAP_SPEED_Y)


func _setup_core_components() -> void:
	_health.configure(_entity_id, STALKER_MAX_HP, STALKER_MAX_HP, 0, 0, false)
	if not _health.on_hp_changed.is_connected(_on_core_hp_changed):
		_health.on_hp_changed.connect(_on_core_hp_changed)
	if not _health.on_death.is_connected(_on_core_death):
		_health.on_death.connect(_on_core_death)
	_collision.configure_entity(_entity_id, &"enemy")
	_collision.set_hurtbox_size(STALKER_HURTBOX_SIZE)
	_collision.set_health_adapter(_health)
	_combat.set_collision_adapter(_collision)
	if _attack_target != null:
		_combat.set_health_adapter(_attack_target)
	if _damage_calculator_adapter != null:
		_combat.set_damage_calculator_adapter(_damage_calculator_adapter)
	if not _combat.on_attack_hit.is_connected(_on_core_attack_hit):
		_combat.on_attack_hit.connect(_on_core_attack_hit)
	_status_effects.configure_entity(_entity_id, false)
	_status_effects.set_health_adapter(_health)


func _build_attack_metadata() -> Dictionary:
	return {
		"source": &"underground_cistern_stalker",
		"owner_boss_id": get_summon_owner_boss_id(),
		"summon_id": get_current_summon_id(),
		"attack_type": &"light",
		"weapon_id": STALKER_ATTACK_HITBOX_ID,
		"combo_index": 0,
		"hit_frame": STALKER_ATTACK_HIT_FRAME,
		"attack_power": 0,
		"enemy_defense": 0,
		"active_frames": STALKER_ATTACK_ACTIVE_FRAMES,
		"recovery_frames": STALKER_ATTACK_RECOVERY_FRAMES,
		"leap_velocity": get_leap_velocity(),
		"injected_damage_params": _build_enemy_damage_params(),
	}


func _build_enemy_damage_params() -> Dictionary:
	return {
		"entries": {
			String(STALKER_ATTACK_HITBOX_ID): {
				"weapon_base": STALKER_ATTACK_DAMAGE,
				"combo_multipliers": {"0": 1.0},
				"special_move": {"multiplier": 1.0, "hits": 1},
			},
		},
	}


func _get_attack_tell_animation() -> StringName:
	return &"attack_tell"


func _get_attack_tell_frames() -> int:
	return STALKER_ATTACK_TELL_FRAMES


func _can_auto_attack_target() -> bool:
	if _attack_target == null or _attack_cooldown_timer > 0:
		return false
	var to_target: Vector2 = _attack_target.global_position - global_position
	return (
		absf(to_target.x) <= STALKER_ATTACK_RANGE_PX
		and absf(to_target.y) <= 56.0
	)


func _enter_attack_active() -> void:
	_state = State.ATTACK_ACTIVE
	_attack_timer = STALKER_ATTACK_ACTIVE_FRAMES
	velocity = Vector2(
		_facing * STALKER_LEAP_SPEED_X * _get_movement_modifier(),
		STALKER_LEAP_SPEED_Y
	)
	_play_character_animation(ANIMATION_ATTACK, true)
	if _collision != null:
		_collision.activate_hitbox(
			STALKER_ATTACK_HITBOX_ID,
			STALKER_ATTACK_ACTIVE_FRAMES,
			Vector2(
				_facing * STALKER_HITBOX_OFFSET.x,
				STALKER_HITBOX_OFFSET.y
			),
			STALKER_HITBOX_SIZE,
			_build_attack_metadata()
		)


func _process_attack_active(delta: float) -> void:
	velocity.x = _facing * STALKER_LEAP_SPEED_X * _get_movement_modifier()
	velocity.y += GRAVITY * delta
	move_and_slide()
	_update_sprite_facing()
	_play_character_animation(ANIMATION_ATTACK)
	_attack_timer -= 1
	if _attack_timer <= 0:
		velocity.x = 0.0
		_state = State.ATTACK_RECOVERY
		_attack_timer = STALKER_ATTACK_RECOVERY_FRAMES


func _process_attack_recovery(delta: float) -> void:
	velocity.x = 0.0
	velocity.y += GRAVITY * delta
	move_and_slide()
	_attack_timer -= 1
	if _attack_timer <= 0:
		_state = State.CHASE
		_attack_cooldown_timer = ATTACK_COOLDOWN_FRAMES
		_play_character_animation(ANIMATION_RUN, true)
