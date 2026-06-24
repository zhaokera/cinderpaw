## Simple enemy — patrol, frame animation, core health/status, and bite attack.
##
## Prototype enemy with a deterministic attack tell -> active -> recovery chain.
## Runtime damage flows through CollisionComponent -> CombatComponent ->
## PlayerController.apply_damage instead of direct prototype contact damage.
class_name SimpleEnemy
extends CharacterBody2D

signal enemy_health_changed(current_hp: int, max_hp: int)
signal enemy_defeated
signal enemy_attack_landed(damage: int, hit_position: Vector2, is_crit: bool)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

const PATROL_SPEED: float = 80.0
const GRAVITY: float = 800.0
const HIT_FLASH_FRAMES: int = 6
const MAX_HP: int = 30
const LEGACY_HIT_DAMAGE: int = 10
const ENEMY_ENTITY_ID: int = 2
const CONTACT_DAMAGE_COOLDOWN_FRAMES: int = 45
const NORMAL_MODULATE: Color = Color.WHITE
const HIT_MODULATE: Color = Color(1.0, 0.9, 0.9, 1.0)
const ENEMY_HURTBOX_SIZE: Vector2 = Vector2(28, 42)
const ATTACK_RANGE_PX: float = 78.0
const ATTACK_TELL_FRAMES: int = 8
const ATTACK_ACTIVE_FRAMES: int = 4
const ATTACK_RECOVERY_FRAMES: int = 12
const ATTACK_COOLDOWN_FRAMES: int = 24
const ATTACK_HITBOX_ID: StringName = &"shadow_beast_bite"
const ATTACK_HITBOX_SIZE: Vector2 = Vector2(42, 28)
const ATTACK_HITBOX_OFFSET: Vector2 = Vector2(36, -24)
const SHADOW_BEAST_BITE_DAMAGE: int = 12
const SHADOW_BEAST_BITE_HIT_FRAME: int = 99
const ANIMATION_IDLE: StringName = &"idle"
const ANIMATION_PATROL: StringName = &"patrol"
const ANIMATION_ATTACK_TELL: StringName = &"attack_tell"
const ANIMATION_ATTACK: StringName = &"attack"
const ANIMATION_HURT: StringName = &"hurt"
const ANIMATION_DEATH: StringName = &"death"
const HEALTH_COMPONENT_SCRIPT: Script = preload("res://src/core/health_component.gd")
const COLLISION_COMPONENT_SCRIPT: Script = preload("res://src/core/collision_component.gd")
const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")
const STATUS_EFFECT_COMPONENT_SCRIPT: Script = preload("res://src/core/status_effect_component.gd")

## Raycast offset for edge detection (half body width + margin).
const EDGE_DETECT_OFFSET: Vector2 = Vector2(16, 4)

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

enum State { PATROL, HIT, ATTACK_TELL, ATTACK_ACTIVE, ATTACK_RECOVERY, DEAD }

var _state: State = State.PATROL
var _hp: int = MAX_HP
var _patrol_dir: float = -1.0
var _hit_timer: int = 0
var _attack_timer: int = 0
var _attack_cooldown_timer: int = 0
var _contact_damage_timer: int = 0
var _last_enemy_attack_metadata: Dictionary = {}
var _attack_target: Node = null
var _health: HealthComponent = null
var _collision: CollisionComponent = null
var _combat: CombatComponent = null
var _status_effects: StatusEffectComponent = null
var _damage_calculator_adapter: Object = null

# ---------------------------------------------------------------------------
# Node References
# ---------------------------------------------------------------------------

@onready var _sprite: AnimatedSprite2D = $Sprite

# ---------------------------------------------------------------------------
# Built-in Virtual Methods
# ---------------------------------------------------------------------------

func _ready() -> void:
	_ensure_core_components()
	_setup_core_components()
	_play_character_animation(ANIMATION_PATROL, true)
	enemy_health_changed.emit(get_current_hp(), get_max_hp())


func _physics_process(delta: float) -> void:
	_contact_damage_timer = maxi(_contact_damage_timer - 1, 0)
	_attack_cooldown_timer = maxi(_attack_cooldown_timer - 1, 0)
	if _status_effects != null:
		_status_effects.advance_time(delta)
	match _state:
		State.PATROL:
			_process_patrol(delta)
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

# ---------------------------------------------------------------------------
# Patrol State
# ---------------------------------------------------------------------------

func _process_patrol(delta: float) -> void:
	if _can_auto_attack_target():
		request_attack()
		return

	velocity.x = _patrol_dir * PATROL_SPEED * _get_movement_modifier()
	velocity.y += GRAVITY * delta
	move_and_slide()

	# Reverse at walls.
	if get_slide_collision_count() > 0:
		for i: int in range(get_slide_collision_count()):
			var collision: KinematicCollision2D = get_slide_collision(i)
			var collider: Object = collision.get_collider()
			if collider is Node and (collider as Node).has_method("take_damage"):
				_apply_contact_damage(collider as Node)
			if absf(collision.get_normal().x) > 0.5:
				_patrol_dir *= -1.0
				break

	# Reverse at platform edges (prevent walking off).
	if is_on_floor():
		var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
		var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
			global_position + Vector2(_patrol_dir * EDGE_DETECT_OFFSET.x, 0),
			global_position + Vector2(_patrol_dir * EDGE_DETECT_OFFSET.x, 32),
			1 << 4  # environment layer (layer 5, bit index 4)
		)
		var result: Dictionary = space_state.intersect_ray(query)
		if result.is_empty():
			_patrol_dir *= -1.0

	_update_sprite_facing()
	_play_character_animation(ANIMATION_PATROL)


func _process_hit(delta: float) -> void:
	velocity.x = 0.0
	velocity.y += GRAVITY * delta
	move_and_slide()

	_hit_timer -= 1
	if _hit_timer <= 0:
		_sprite.modulate = NORMAL_MODULATE
		_state = State.PATROL
		_play_character_animation(ANIMATION_PATROL, true)

# ---------------------------------------------------------------------------
# Attack State
# ---------------------------------------------------------------------------

## Requests a Shadow Beast bite attack through the Core collision/combat chain.
func request_attack() -> bool:
	if _state != State.PATROL or _attack_cooldown_timer > 0 or _state == State.DEAD:
		return false
	_face_attack_target()
	velocity = Vector2.ZERO
	_state = State.ATTACK_TELL
	_attack_timer = ATTACK_TELL_FRAMES
	_play_character_animation(ANIMATION_ATTACK_TELL, true)
	return true


## Deterministically advances the attack FSM for tests and MCP runtime probes.
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


func _process_attack_tell(_delta: float) -> void:
	velocity.x = 0.0
	_update_sprite_facing()
	_play_character_animation(ANIMATION_ATTACK_TELL)
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
			Vector2(_patrol_dir * ATTACK_HITBOX_OFFSET.x, ATTACK_HITBOX_OFFSET.y),
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
		_state = State.PATROL
		_attack_cooldown_timer = ATTACK_COOLDOWN_FRAMES
		_play_character_animation(ANIMATION_PATROL, true)

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

## Legacy damage entry point for prototype body/hitbox callers.
func take_damage() -> void:
	apply_damage(LEGACY_HIT_DAMAGE, {
		"source": &"legacy_player_hitbox",
		"damage_type": &"slash",
	})


## Applies resolved combat damage to this enemy's HealthComponent.
func apply_damage(final_damage: int, metadata: Dictionary = {}) -> void:
	if _state == State.DEAD or _health == null:
		return
	_health.apply_damage(final_damage, metadata)


## Proxies shield-break weapon effects to the underlying HealthComponent.
func break_shield() -> bool:
	if _health == null:
		return false
	return _health.break_shield()


## Proxies status weapon effects to the underlying StatusEffectComponent.
func apply_status(target_id: int, effect_id: StringName, source_id: int = 0) -> bool:
	if _status_effects == null:
		return false
	return _status_effects.apply_status(target_id, effect_id, source_id)


## Injects the runtime attack target that receives resolved bite damage.
func set_attack_target(target: Node) -> void:
	_attack_target = target
	if _combat != null:
		_combat.set_health_adapter(_attack_target)


## Injects the shared runtime damage adapter used by CombatComponent.
func set_damage_calculator_adapter(damage_calculator_adapter: Object) -> void:
	_damage_calculator_adapter = damage_calculator_adapter
	if _combat != null:
		_combat.set_damage_calculator_adapter(_damage_calculator_adapter)


func get_current_hp() -> int:
	if _health == null:
		return maxi(0, _hp)
	return _health.get_current_hp()


func get_max_hp() -> int:
	if _health == null:
		return MAX_HP
	return _health.get_max_hp()


## Returns the stable entity id used by runtime hit events.
func get_entity_id() -> int:
	return ENEMY_ENTITY_ID


## Returns the enemy HealthComponent for runtime integration tests and adapters.
func get_health_component() -> HealthComponent:
	return _health


## Returns the enemy CollisionComponent and its managed hurtbox.
func get_collision_component() -> CollisionComponent:
	return _collision


## Returns the enemy CombatComponent used by the bite attack chain.
func get_combat_component() -> CombatComponent:
	return _combat


## Returns the enemy StatusEffectComponent for weapon effect integration.
func get_status_effect_component() -> StatusEffectComponent:
	return _status_effects


## Returns the last resolved enemy hit metadata for verification and telemetry.
func get_last_enemy_attack_metadata() -> Dictionary:
	return _last_enemy_attack_metadata.duplicate(true)


func capture_respawn_snapshot() -> Dictionary:
	return {
		"global_position": global_position,
		"hp": get_current_hp(),
		"state": _state,
		"patrol_dir": _patrol_dir,
		"collision_layer": collision_layer,
		"collision_mask": collision_mask,
		"sprite_modulate": _sprite.modulate,
	}


func restore_respawn_snapshot(snapshot: Dictionary) -> void:
	global_position = _read_vector2(snapshot.get("global_position", global_position), global_position)
	_hp = clampi(_read_int(snapshot.get("hp", MAX_HP), MAX_HP), 0, MAX_HP)
	_state = State.PATROL
	_patrol_dir = _read_float(snapshot.get("patrol_dir", _patrol_dir), _patrol_dir)
	_hit_timer = 0
	_attack_timer = 0
	_attack_cooldown_timer = 0
	_contact_damage_timer = 0
	_last_enemy_attack_metadata = {}
	velocity = Vector2.ZERO
	collision_layer = _read_int(snapshot.get("collision_layer", collision_layer), collision_layer)
	collision_mask = _read_int(snapshot.get("collision_mask", collision_mask), collision_mask)
	_sprite.modulate = _read_color(snapshot.get("sprite_modulate", NORMAL_MODULATE), NORMAL_MODULATE)
	_update_sprite_facing()
	_play_character_animation(ANIMATION_PATROL, true)
	if _health != null:
		_health.configure(ENEMY_ENTITY_ID, MAX_HP, _hp, 0, 0, false)
	if _collision != null:
		_collision.deactivate_all_hitboxes()
		_collision.set_hurtbox_state(&"normal")
	if _status_effects != null:
		_status_effects.clear_all_effects()
	enemy_health_changed.emit(get_current_hp(), get_max_hp())


func _apply_contact_damage(target: Node) -> void:
	if _contact_damage_timer > 0:
		return
	target.call("take_damage")
	_contact_damage_timer = CONTACT_DAMAGE_COOLDOWN_FRAMES


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
	_health.configure(ENEMY_ENTITY_ID, MAX_HP, MAX_HP, 0, 0, false)
	if not _health.on_hp_changed.is_connected(_on_core_hp_changed):
		_health.on_hp_changed.connect(_on_core_hp_changed)
	if not _health.on_death.is_connected(_on_core_death):
		_health.on_death.connect(_on_core_death)
	_collision.configure_entity(ENEMY_ENTITY_ID, &"enemy")
	_collision.set_hurtbox_size(ENEMY_HURTBOX_SIZE)
	_collision.set_health_adapter(_health)
	_combat.set_collision_adapter(_collision)
	if _attack_target != null:
		_combat.set_health_adapter(_attack_target)
	if _damage_calculator_adapter != null:
		_combat.set_damage_calculator_adapter(_damage_calculator_adapter)
	if not _combat.on_attack_hit.is_connected(_on_core_attack_hit):
		_combat.on_attack_hit.connect(_on_core_attack_hit)
	_status_effects.configure_entity(ENEMY_ENTITY_ID, false)
	_status_effects.set_health_adapter(_health)


func _on_core_hp_changed(_entity_id: int, current_hp: int, max_hp: int) -> void:
	_hp = current_hp
	enemy_health_changed.emit(current_hp, max_hp)
	if current_hp <= 0 or _state == State.DEAD:
		return
	_hit_timer = HIT_FLASH_FRAMES
	_state = State.HIT
	_sprite.modulate = HIT_MODULATE
	_play_character_animation(ANIMATION_HURT, true)


func _on_core_death(_entity_id: int, _metadata: Dictionary) -> void:
	if _state == State.DEAD:
		return
	_state = State.DEAD
	_collision.deactivate_all_hitboxes()
	_play_character_animation(ANIMATION_DEATH, true)
	enemy_defeated.emit()
	_sprite.modulate.a = 0.85
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	var tween: Tween = create_tween()
	tween.tween_interval(0.25)
	tween.tween_property(_sprite, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)


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
		"source": &"shadow_beast",
		"attack_type": &"light",
		"weapon_id": ATTACK_HITBOX_ID,
		"combo_index": 0,
		"hit_frame": SHADOW_BEAST_BITE_HIT_FRAME,
		"attack_power": 0,
		"enemy_defense": 0,
		"injected_damage_params": _build_enemy_damage_params(),
	}


func _build_enemy_damage_params() -> Dictionary:
	return {
		"entries": {
			String(ATTACK_HITBOX_ID): {
				"weapon_base": SHADOW_BEAST_BITE_DAMAGE,
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
	return absf(to_target.x) <= ATTACK_RANGE_PX and absf(to_target.y) <= 42.0


func _face_attack_target() -> void:
	if _attack_target != null:
		var delta_x: float = _attack_target.global_position.x - global_position.x
		if absf(delta_x) > 1.0:
			_patrol_dir = signf(delta_x)
	_update_sprite_facing()


func _update_sprite_facing() -> void:
	if _sprite == null:
		return
	_sprite.flip_h = _patrol_dir < 0.0


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


func _read_int(value: Variant, fallback: int) -> int:
	if value is int:
		return value
	if value is float:
		return int(value)
	return fallback


func _read_float(value: Variant, fallback: float) -> float:
	if value is int or value is float:
		return float(value)
	return fallback


func _read_color(value: Variant, fallback: Color) -> Color:
	if value is Color:
		return value
	return fallback
