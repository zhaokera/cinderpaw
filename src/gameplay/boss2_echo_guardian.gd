## Minimal single-stage Boss2 threat for the mainline Double Jump payoff.
class_name Boss2EchoGuardian
extends CharacterBody2D

signal boss_health_changed(current_hp: int, max_hp: int)
signal boss_defeated
signal enemy_attack_landed(damage: int, hit_position: Vector2, is_crit: bool)

const ENTITY_ID: int = 2200
const MAX_HP: int = 36
const ATTACK_RANGE_PX: float = 108.0
const ATTACK_TELL_FRAMES: int = 8
const ATTACK_ACTIVE_FRAMES: int = 4
const ATTACK_RECOVERY_FRAMES: int = 14
const ATTACK_COOLDOWN_FRAMES: int = 28
const ATTACK_HITBOX_ID: StringName = &"boss2_echo_swipe"
const ATTACK_HITBOX_SIZE: Vector2 = Vector2(72, 34)
const ATTACK_HITBOX_OFFSET: Vector2 = Vector2(56, -38)
const ATTACK_DAMAGE: int = 14
const ATTACK_HIT_FRAME: int = 99
const BOSS2_HURTBOX_SIZE: Vector2 = Vector2(78, 72)
const HIT_FLASH_FRAMES: int = 5
const NORMAL_MODULATE: Color = Color.WHITE
const HIT_MODULATE: Color = Color(1.0, 0.88, 0.82, 1.0)
const ANIMATION_IDLE: StringName = &"idle"
const ANIMATION_ATTACK: StringName = &"attack"
const ANIMATION_HURT: StringName = &"hurt"
const ANIMATION_DEATH: StringName = &"death"
const HEALTH_COMPONENT_SCRIPT: Script = preload("res://src/core/health_component.gd")
const COLLISION_COMPONENT_SCRIPT: Script = preload("res://src/core/collision_component.gd")
const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")
const STATUS_EFFECT_COMPONENT_SCRIPT: Script = preload("res://src/core/status_effect_component.gd")

enum State { IDLE, HIT, ATTACK_TELL, ATTACK_ACTIVE, ATTACK_RECOVERY, DEAD }

@onready var _sprite: AnimatedSprite2D = $Sprite

var _state: State = State.IDLE
var _facing: float = -1.0
var _hit_timer: int = 0
var _attack_timer: int = 0
var _attack_cooldown_timer: int = 0
var _attack_sequence_id: int = 0
var _defeated: bool = false
var _last_hit_metadata: Dictionary = {}
var _last_enemy_attack_metadata: Dictionary = {}
var _attack_target: Node = null
var _damage_calculator_adapter: Object = null
var _health: HealthComponent = null
var _collision: CollisionComponent = null
var _combat: CombatComponent = null
var _status_effects: StatusEffectComponent = null
var _default_collision_layer: int = 0
var _default_collision_mask: int = 0


func _ready() -> void:
	_default_collision_layer = collision_layer
	_default_collision_mask = collision_mask
	_ensure_core_components()
	_setup_core_components()
	_play_animation(ANIMATION_IDLE, true)
	boss_health_changed.emit(get_current_hp(), MAX_HP)


func _physics_process(_delta: float) -> void:
	if _status_effects != null:
		_status_effects.advance_time(_delta)
	if _defeated:
		return
	_attack_cooldown_timer = maxi(_attack_cooldown_timer - 1, 0)
	match _state:
		State.IDLE:
			_process_idle()
		State.HIT:
			_process_hit()
		State.ATTACK_TELL:
			_process_attack_tell()
		State.ATTACK_ACTIVE:
			_process_attack_active()
		State.ATTACK_RECOVERY:
			_process_attack_recovery()
		State.DEAD:
			return


func set_attack_target(target: Node) -> void:
	_attack_target = target
	if _combat != null:
		_combat.set_health_adapter(_attack_target)


func has_attack_target() -> bool:
	return _attack_target != null


func set_damage_calculator_adapter(damage_calculator_adapter: Object) -> void:
	_damage_calculator_adapter = damage_calculator_adapter
	if _combat != null:
		_combat.set_damage_calculator_adapter(_damage_calculator_adapter)


func request_attack() -> bool:
	if _defeated or _state != State.IDLE or _attack_cooldown_timer > 0:
		return false
	_face_attack_target()
	_attack_sequence_id += 1
	_attack_timer = ATTACK_TELL_FRAMES
	_state = State.ATTACK_TELL
	if _collision != null:
		_collision.deactivate_hitbox(ATTACK_HITBOX_ID)
	_play_animation(ANIMATION_ATTACK, true)
	return true


func advance_attack_frames(frames: int) -> void:
	for _index: int in range(maxi(0, frames)):
		if _defeated:
			return
		_attack_cooldown_timer = maxi(_attack_cooldown_timer - 1, 0)
		match _state:
			State.ATTACK_TELL:
				_process_attack_tell()
			State.ATTACK_ACTIVE:
				_process_attack_active()
			State.ATTACK_RECOVERY:
				_process_attack_recovery()
			State.IDLE:
				_process_idle(false)
			_:
				pass


func apply_damage(final_damage: int, metadata: Dictionary = {}) -> void:
	if _defeated or _health == null or final_damage <= 0:
		return
	_last_hit_metadata = metadata.duplicate(true)
	_health.apply_damage(final_damage, metadata)


func apply_status(target_id: int, effect_id: StringName, source_id: int = 0) -> bool:
	if _status_effects == null:
		return false
	return _status_effects.apply_status(target_id, effect_id, source_id)


func break_shield() -> bool:
	if _health == null:
		return false
	return _health.break_shield()


func reset_encounter() -> void:
	_defeated = false
	_state = State.IDLE
	_hit_timer = 0
	_attack_timer = 0
	_attack_cooldown_timer = 0
	_last_hit_metadata.clear()
	_last_enemy_attack_metadata.clear()
	collision_layer = _default_collision_layer
	collision_mask = _default_collision_mask
	_ensure_core_components()
	_setup_core_components()
	if _collision != null:
		_collision.deactivate_all_hitboxes()
		_collision.set_hurtbox_state(CollisionComponent.HURTBOX_STATE_NORMAL)
	_sprite.modulate = NORMAL_MODULATE
	_play_animation(ANIMATION_IDLE, true)
	boss_health_changed.emit(get_current_hp(), MAX_HP)


func mark_defeated_from_progress() -> void:
	_defeated = true
	_state = State.DEAD
	_attack_timer = 0
	_attack_cooldown_timer = 0
	if _collision != null:
		_collision.deactivate_all_hitboxes()
		_collision.set_hurtbox_state(CollisionComponent.HURTBOX_STATE_GONE)
	if _sprite != null:
		_sprite.modulate = NORMAL_MODULATE
	_play_animation(ANIMATION_DEATH, true)
	collision_layer = 0
	collision_mask = 0


func get_entity_id() -> int:
	return ENTITY_ID


func get_current_hp() -> int:
	if _health == null:
		return MAX_HP
	return _health.get_current_hp()


func get_max_hp() -> int:
	return MAX_HP


func is_defeated() -> bool:
	return _defeated


func get_collision_component() -> CollisionComponent:
	return _collision


func get_combat_component() -> CombatComponent:
	return _combat


func get_status_effect_component() -> StatusEffectComponent:
	return _status_effects


func get_last_hit_metadata() -> Dictionary:
	return _last_hit_metadata.duplicate(true)


func get_last_enemy_attack_metadata() -> Dictionary:
	return _last_enemy_attack_metadata.duplicate(true)


func get_current_enemy_attack_metadata() -> Dictionary:
	return _build_attack_metadata().duplicate(true)


func is_enemy_attack_active() -> bool:
	return _state == State.ATTACK_ACTIVE


func get_current_attack_sequence_id() -> int:
	return _attack_sequence_id


func get_current_attack_startup_frames() -> int:
	return ATTACK_TELL_FRAMES


func get_attack_startup_frames() -> int:
	return get_current_attack_startup_frames()


func get_attack_phase() -> StringName:
	match _state:
		State.ATTACK_TELL:
			return &"startup"
		State.ATTACK_ACTIVE:
			return &"active"
		State.ATTACK_RECOVERY:
			return &"recovery"
		State.HIT:
			return &"hurt"
		State.DEAD:
			return &"dead"
		_:
			return &"idle"


func _process_idle(auto_attack: bool = true) -> void:
	velocity = Vector2.ZERO
	_update_sprite_facing()
	_play_animation(ANIMATION_IDLE)
	if auto_attack and _can_auto_attack_target():
		request_attack()


func _process_hit() -> void:
	_hit_timer -= 1
	if _hit_timer <= 0:
		_state = State.IDLE
		if _sprite != null:
			_sprite.modulate = NORMAL_MODULATE
		_play_animation(ANIMATION_IDLE, true)


func _process_attack_tell() -> void:
	velocity = Vector2.ZERO
	_update_sprite_facing()
	_play_animation(ANIMATION_ATTACK)
	_attack_timer -= 1
	if _attack_timer <= 0:
		_enter_attack_active()


func _enter_attack_active() -> void:
	_state = State.ATTACK_ACTIVE
	_attack_timer = ATTACK_ACTIVE_FRAMES
	_play_animation(ANIMATION_ATTACK, true)
	if _collision == null:
		return
	_collision.activate_hitbox(
		ATTACK_HITBOX_ID,
		ATTACK_ACTIVE_FRAMES,
		Vector2(_facing * ATTACK_HITBOX_OFFSET.x, ATTACK_HITBOX_OFFSET.y),
		ATTACK_HITBOX_SIZE,
		_build_attack_metadata()
	)


func _process_attack_active() -> void:
	velocity = Vector2.ZERO
	_play_animation(ANIMATION_ATTACK)
	_attack_timer -= 1
	if _attack_timer <= 0:
		_enter_attack_recovery()


func _enter_attack_recovery() -> void:
	_state = State.ATTACK_RECOVERY
	_attack_timer = ATTACK_RECOVERY_FRAMES
	if _collision != null:
		_collision.deactivate_hitbox(ATTACK_HITBOX_ID)


func _process_attack_recovery() -> void:
	velocity = Vector2.ZERO
	_attack_timer -= 1
	if _attack_timer <= 0:
		_state = State.IDLE
		_attack_cooldown_timer = ATTACK_COOLDOWN_FRAMES
		_play_animation(ANIMATION_IDLE, true)


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
	_health.configure(ENTITY_ID, MAX_HP, MAX_HP, 0, 0, false)
	if not _health.on_hp_changed.is_connected(_on_core_hp_changed):
		_health.on_hp_changed.connect(_on_core_hp_changed)
	if not _health.on_death.is_connected(_on_core_death):
		_health.on_death.connect(_on_core_death)
	_collision.configure_entity(ENTITY_ID, &"enemy")
	_collision.set_hurtbox_size(BOSS2_HURTBOX_SIZE)
	_collision.set_health_adapter(_health)
	_combat.set_collision_adapter(_collision)
	if _attack_target != null:
		_combat.set_health_adapter(_attack_target)
	if _damage_calculator_adapter != null:
		_combat.set_damage_calculator_adapter(_damage_calculator_adapter)
	if not _combat.on_attack_hit.is_connected(_on_core_attack_hit):
		_combat.on_attack_hit.connect(_on_core_attack_hit)
	_status_effects.configure_entity(ENTITY_ID, true)
	_status_effects.set_health_adapter(_health)


func _on_core_hp_changed(_entity_id_value: int, current_hp: int, max_hp: int) -> void:
	boss_health_changed.emit(current_hp, max_hp)
	if current_hp <= 0 or _defeated:
		return
	if _sprite != null:
		_sprite.modulate = HIT_MODULATE
	if _state == State.ATTACK_TELL or _state == State.ATTACK_ACTIVE or _state == State.ATTACK_RECOVERY:
		return
	_hit_timer = HIT_FLASH_FRAMES
	_state = State.HIT
	_play_animation(ANIMATION_HURT, true)


func _on_core_death(_entity_id_value: int, metadata: Dictionary) -> void:
	_die(metadata)


func _die(_metadata: Dictionary) -> void:
	if _defeated:
		return
	_defeated = true
	_state = State.DEAD
	_attack_timer = 0
	_attack_cooldown_timer = 0
	if _collision != null:
		_collision.deactivate_all_hitboxes()
		_collision.set_hurtbox_state(CollisionComponent.HURTBOX_STATE_GONE)
	if _sprite != null:
		_sprite.modulate = NORMAL_MODULATE
	_play_animation(ANIMATION_DEATH, true)
	collision_layer = 0
	collision_mask = 0
	boss_defeated.emit()


func _on_core_attack_hit(metadata: Dictionary) -> void:
	if not metadata.has("source"):
		metadata["source"] = &"boss2_echo_guardian"
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
		"source": &"boss2_echo_guardian",
		"attack_type": &"light",
		"weapon_id": ATTACK_HITBOX_ID,
		"combo_index": 0,
		"hit_frame": ATTACK_HIT_FRAME,
		"attack_power": 0,
		"enemy_defense": 0,
		"attack_sequence_id": _attack_sequence_id,
		"injected_damage_params": _build_enemy_damage_params(),
	}


func _build_enemy_damage_params() -> Dictionary:
	return {
		"entries": {
			String(ATTACK_HITBOX_ID): {
				"weapon_base": ATTACK_DAMAGE,
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
	return absf(to_target.x) <= ATTACK_RANGE_PX and absf(to_target.y) <= 72.0


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


func _play_animation(animation_name: StringName, restart: bool = false) -> void:
	if _sprite == null or _sprite.sprite_frames == null:
		return
	if not _sprite.sprite_frames.has_animation(animation_name):
		return
	if restart:
		_sprite.animation = animation_name
		_sprite.frame = 0
		_sprite.frame_progress = 0.0
	_sprite.play(animation_name)


func _read_vector2(value: Variant, fallback: Vector2) -> Vector2:
	if value is Vector2:
		return value
	return fallback
