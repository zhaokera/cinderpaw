## Rat King summoned rat minion with a minimal chase -> bite -> recover loop.
class_name RatMinion
extends CharacterBody2D

signal enemy_health_changed(current_hp: int, max_hp: int)
signal enemy_defeated
signal enemy_attack_landed(damage: int, hit_position: Vector2, is_crit: bool)

const CHASE_SPEED: float = 96.0
const GRAVITY: float = 800.0
const MAX_HP: int = 24
const DEFAULT_ENTITY_ID: int = 2000
const HIT_FLASH_FRAMES: int = 5
const ATTACK_RANGE_PX: float = 58.0
const ATTACK_TELL_FRAMES: int = 7
const ATTACK_ACTIVE_FRAMES: int = 4
const ATTACK_RECOVERY_FRAMES: int = 12
const ATTACK_COOLDOWN_FRAMES: int = 28
const ATTACK_HITBOX_ID: StringName = &"rat_minion_bite"
const ATTACK_HITBOX_SIZE: Vector2 = Vector2(38, 22)
const ATTACK_HITBOX_OFFSET: Vector2 = Vector2(30, -24)
const RAT_MINION_BITE_DAMAGE: int = 8
const RAT_MINION_BITE_HIT_FRAME: int = 99
const MINION_HURTBOX_SIZE: Vector2 = Vector2(34, 30)
const NORMAL_MODULATE: Color = Color.WHITE
const HIT_MODULATE: Color = Color(1.0, 0.9, 0.84, 1.0)
const ANIMATION_IDLE: StringName = &"idle"
const ANIMATION_RUN: StringName = &"run"
const ANIMATION_ATTACK: StringName = &"attack"
const ANIMATION_HURT: StringName = &"hurt"
const ANIMATION_DEATH: StringName = &"death"
const HEALTH_COMPONENT_SCRIPT: Script = preload("res://src/core/health_component.gd")
const COLLISION_COMPONENT_SCRIPT: Script = preload("res://src/core/collision_component.gd")
const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")
const STATUS_EFFECT_COMPONENT_SCRIPT: Script = preload("res://src/core/status_effect_component.gd")

enum State { CHASE, HIT, ATTACK_TELL, ATTACK_ACTIVE, ATTACK_RECOVERY, DEAD }

var _state: State = State.CHASE
var _entity_id: int = DEFAULT_ENTITY_ID
var _summon_owner_boss_id: StringName = &""
var _summon_id: StringName = &"summon_minion"
var _facing: float = -1.0
var _hit_timer: int = 0
var _attack_timer: int = 0
var _attack_cooldown_timer: int = 0
var _attack_target: Node = null
var _last_enemy_attack_metadata: Dictionary = {}
var _damage_calculator_adapter: Object = null
var _health: HealthComponent = null
var _collision: CollisionComponent = null
var _combat: CombatComponent = null
var _status_effects: StatusEffectComponent = null

@onready var _sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	_ensure_core_components()
	_setup_core_components()
	_play_character_animation(ANIMATION_IDLE, true)
	enemy_health_changed.emit(get_current_hp(), get_max_hp())


func _physics_process(delta: float) -> void:
	_attack_cooldown_timer = maxi(_attack_cooldown_timer - 1, 0)
	if _status_effects != null:
		_status_effects.advance_time(delta)
	match _state:
		State.CHASE:
			_process_chase(delta)
		State.HIT:
			_process_hit(delta)
		State.ATTACK_TELL:
			_process_attack_tell(delta)
		State.ATTACK_ACTIVE:
			_process_attack_active(delta)
		State.ATTACK_RECOVERY:
			_process_attack_recovery(delta)
		State.DEAD:
			return


func configure_summon(
	owner_boss_id: StringName,
	entity_id: int,
	summon_id: StringName = &"summon_minion"
) -> void:
	_summon_owner_boss_id = owner_boss_id
	_entity_id = entity_id
	_summon_id = summon_id
	if _health != null:
		_setup_core_components()


func set_attack_target(target: Node) -> void:
	_attack_target = target
	if _combat != null:
		_combat.set_health_adapter(_attack_target)


func set_damage_calculator_adapter(damage_calculator_adapter: Object) -> void:
	_damage_calculator_adapter = damage_calculator_adapter
	if _combat != null:
		_combat.set_damage_calculator_adapter(_damage_calculator_adapter)


func request_attack() -> bool:
	if _state != State.CHASE or _attack_cooldown_timer > 0:
		return false
	_face_attack_target()
	velocity = Vector2.ZERO
	_state = State.ATTACK_TELL
	_attack_timer = ATTACK_TELL_FRAMES
	_play_character_animation(ANIMATION_ATTACK, true)
	return true


func advance_attack_frames(frames: int) -> void:
	for _index: int in range(maxi(0, frames)):
		_attack_cooldown_timer = maxi(_attack_cooldown_timer - 1, 0)
		match _state:
			State.ATTACK_TELL:
				_process_attack_tell(1.0 / 60.0)
			State.ATTACK_ACTIVE:
				_process_attack_active(1.0 / 60.0)
			State.ATTACK_RECOVERY:
				_process_attack_recovery(1.0 / 60.0)
			_:
				pass


func apply_damage(final_damage: int, metadata: Dictionary = {}) -> void:
	if _state == State.DEAD or _health == null:
		return
	_health.apply_damage(final_damage, metadata)


func kill_summon(reason: StringName = &"cleanup") -> void:
	if _state == State.DEAD:
		return
	if _health != null and _health.get_current_hp() > 0:
		_health.apply_damage(_health.get_current_hp(), {
			"source": reason,
			"damage_type": &"cleanup",
		})
		return
	_die({"source": reason})


func get_entity_id() -> int:
	return _entity_id


func get_summon_owner_boss_id() -> StringName:
	return _summon_owner_boss_id


func get_current_summon_id() -> StringName:
	return _summon_id


func get_current_hp() -> int:
	if _health == null:
		return MAX_HP
	return _health.get_current_hp()


func get_max_hp() -> int:
	if _health == null:
		return MAX_HP
	return _health.get_max_hp()


func get_collision_component() -> CollisionComponent:
	return _collision


func get_combat_component() -> CombatComponent:
	return _combat


func get_status_effect_component() -> StatusEffectComponent:
	return _status_effects


func get_last_enemy_attack_metadata() -> Dictionary:
	return _last_enemy_attack_metadata.duplicate(true)


func _process_chase(delta: float) -> void:
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


func _process_hit(delta: float) -> void:
	velocity.x = 0.0
	velocity.y += GRAVITY * delta
	move_and_slide()
	_hit_timer -= 1
	if _hit_timer <= 0:
		_sprite.modulate = NORMAL_MODULATE
		_state = State.CHASE
		_play_character_animation(ANIMATION_RUN, true)


func _process_attack_tell(_delta: float) -> void:
	velocity.x = 0.0
	_update_sprite_facing()
	_play_character_animation(ANIMATION_ATTACK)
	_attack_timer -= 1
	if _attack_timer <= 0:
		_enter_attack_active()


func _enter_attack_active() -> void:
	_state = State.ATTACK_ACTIVE
	_attack_timer = ATTACK_ACTIVE_FRAMES
	_play_character_animation(ANIMATION_ATTACK, true)
	if _collision != null:
		_collision.activate_hitbox(
			ATTACK_HITBOX_ID,
			ATTACK_ACTIVE_FRAMES,
			Vector2(_facing * ATTACK_HITBOX_OFFSET.x, ATTACK_HITBOX_OFFSET.y),
			ATTACK_HITBOX_SIZE,
			_build_attack_metadata()
		)


func _process_attack_active(_delta: float) -> void:
	velocity.x = 0.0
	_play_character_animation(ANIMATION_ATTACK)
	_attack_timer -= 1
	if _attack_timer <= 0:
		_state = State.ATTACK_RECOVERY
		_attack_timer = ATTACK_RECOVERY_FRAMES


func _process_attack_recovery(_delta: float) -> void:
	velocity.x = 0.0
	_attack_timer -= 1
	if _attack_timer <= 0:
		_state = State.CHASE
		_attack_cooldown_timer = ATTACK_COOLDOWN_FRAMES
		_play_character_animation(ANIMATION_RUN, true)


func _ensure_core_components() -> void:
	_health = get_node_or_null("HealthComponent") as HealthComponent
	if _health == null:
		_health = HEALTH_COMPONENT_SCRIPT.new() as HealthComponent
		_health.name = "HealthComponent"
		add_child(_health)
	_collision = get_node_or_null("CollisionComponent") as CollisionComponent
	if _collision == null:
		_collision = COLLISION_COMPONENT_SCRIPT.new() as CollisionComponent
		_collision.name = "CollisionComponent"
		add_child(_collision)
	_combat = get_node_or_null("CombatComponent") as CombatComponent
	if _combat == null:
		_combat = COMBAT_COMPONENT_SCRIPT.new() as CombatComponent
		_combat.name = "CombatComponent"
		add_child(_combat)
	_status_effects = get_node_or_null("StatusEffectComponent") as StatusEffectComponent
	if _status_effects == null:
		_status_effects = STATUS_EFFECT_COMPONENT_SCRIPT.new() as StatusEffectComponent
		_status_effects.name = "StatusEffectComponent"
		add_child(_status_effects)


func _setup_core_components() -> void:
	_health.configure(_entity_id, MAX_HP, MAX_HP, 0, 0, false)
	if not _health.on_hp_changed.is_connected(_on_core_hp_changed):
		_health.on_hp_changed.connect(_on_core_hp_changed)
	if not _health.on_death.is_connected(_on_core_death):
		_health.on_death.connect(_on_core_death)
	_collision.configure_entity(_entity_id, &"enemy")
	_collision.set_hurtbox_size(MINION_HURTBOX_SIZE)
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


func _on_core_hp_changed(_entity_id_value: int, current_hp: int, max_hp: int) -> void:
	enemy_health_changed.emit(current_hp, max_hp)
	if current_hp <= 0 or _state == State.DEAD:
		return
	_hit_timer = HIT_FLASH_FRAMES
	_state = State.HIT
	_sprite.modulate = HIT_MODULATE
	_play_character_animation(ANIMATION_HURT, true)


func _on_core_death(_entity_id_value: int, metadata: Dictionary) -> void:
	_die(metadata)


func _die(_metadata: Dictionary) -> void:
	if _state == State.DEAD:
		return
	_state = State.DEAD
	if _collision != null:
		_collision.deactivate_all_hitboxes()
		_collision.set_hurtbox_state(&"gone")
	_play_character_animation(ANIMATION_DEATH, true)
	enemy_defeated.emit()
	_sprite.modulate = NORMAL_MODULATE
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	if is_inside_tree():
		var tween: Tween = create_tween()
		tween.tween_interval(0.18)
		tween.tween_property(_sprite, "modulate:a", 0.0, 0.22)
		tween.tween_callback(queue_free)
	else:
		queue_free()


func _on_core_attack_hit(metadata: Dictionary) -> void:
	_last_enemy_attack_metadata = metadata.duplicate(true)
	var hit_position: Vector2 = _read_vector2(
		metadata.get("hit_position", global_position),
		global_position
	)
	enemy_attack_landed.emit(
		int(metadata.get("final_damage", 0)),
		hit_position,
		bool(metadata.get("is_crit", false))
	)


func _build_attack_metadata() -> Dictionary:
	return {
		"source": &"rat_minion",
		"owner_boss_id": _summon_owner_boss_id,
		"summon_id": _summon_id,
		"attack_type": &"light",
		"weapon_id": ATTACK_HITBOX_ID,
		"combo_index": 0,
		"hit_frame": RAT_MINION_BITE_HIT_FRAME,
		"attack_power": 0,
		"enemy_defense": 0,
		"injected_damage_params": _build_enemy_damage_params(),
	}


func _build_enemy_damage_params() -> Dictionary:
	return {
		"entries": {
			String(ATTACK_HITBOX_ID): {
				"weapon_base": RAT_MINION_BITE_DAMAGE,
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


func _can_auto_attack_target() -> bool:
	if _attack_target == null or _attack_cooldown_timer > 0:
		return false
	var to_target: Vector2 = _attack_target.global_position - global_position
	return absf(to_target.x) <= ATTACK_RANGE_PX and absf(to_target.y) <= 44.0


func _direction_to_target() -> float:
	if _attack_target == null:
		return _facing
	var delta_x: float = _attack_target.global_position.x - global_position.x
	if absf(delta_x) > 1.0:
		_facing = signf(delta_x)
	return _facing


func _face_attack_target() -> void:
	_direction_to_target()
	_update_sprite_facing()


func _update_sprite_facing() -> void:
	if _sprite == null:
		return
	_sprite.flip_h = _facing < 0.0


func _play_character_animation(animation_name: StringName, restart: bool = false) -> void:
	if _sprite == null or _sprite.sprite_frames == null:
		return
	if not _sprite.sprite_frames.has_animation(animation_name):
		return
	if restart:
		_sprite.animation = animation_name
		_sprite.frame = 0
		_sprite.frame_progress = 0.0
	_sprite.play(animation_name)


func _get_movement_modifier() -> float:
	if _status_effects == null:
		return 1.0
	return _status_effects.get_movement_modifier()


func _read_vector2(value: Variant, fallback: Vector2) -> Vector2:
	if value is Vector2:
		return value
	return fallback
