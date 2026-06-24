## Simple enemy — patrol, core health/status, take damage, die.
##
## Prototype enemy with a 3-state machine (PATROL → HIT → DEAD).
## Patrols horizontally, reversing at platform edges.
## Takes 3 hits from the player's attack to die.
class_name SimpleEnemy
extends CharacterBody2D

signal enemy_health_changed(current_hp: int, max_hp: int)
signal enemy_defeated

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
const ENEMY_HURTBOX_SIZE: Vector2 = Vector2(24, 40)
const HEALTH_COMPONENT_SCRIPT: Script = preload("res://src/core/health_component.gd")
const COLLISION_COMPONENT_SCRIPT: Script = preload("res://src/core/collision_component.gd")
const STATUS_EFFECT_COMPONENT_SCRIPT: Script = preload("res://src/core/status_effect_component.gd")

## Raycast offset for edge detection (half body width + margin).
const EDGE_DETECT_OFFSET: Vector2 = Vector2(16, 4)

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

enum State { PATROL, HIT, DEAD }

var _state: State = State.PATROL
var _hp: int = MAX_HP
var _patrol_dir: float = -1.0
var _hit_timer: int = 0
var _contact_damage_timer: int = 0
var _health: HealthComponent = null
var _collision: CollisionComponent = null
var _status_effects: StatusEffectComponent = null

# ---------------------------------------------------------------------------
# Node References
# ---------------------------------------------------------------------------

@onready var _sprite: Sprite2D = $Sprite

# ---------------------------------------------------------------------------
# Built-in Virtual Methods
# ---------------------------------------------------------------------------

func _ready() -> void:
	_ensure_core_components()
	_setup_core_components()
	enemy_health_changed.emit(get_current_hp(), get_max_hp())


func _physics_process(delta: float) -> void:
	_contact_damage_timer = maxi(_contact_damage_timer - 1, 0)
	if _status_effects != null:
		_status_effects.advance_time(delta)
	match _state:
		State.PATROL:
			_process_patrol(delta)
		State.HIT:
			_process_hit(delta)
		State.DEAD:
			return

# ---------------------------------------------------------------------------
# Patrol State
# ---------------------------------------------------------------------------

func _process_patrol(delta: float) -> void:
	velocity.x = _patrol_dir * PATROL_SPEED * _get_movement_modifier()
	velocity.y += GRAVITY * delta
	move_and_slide()

	# Reverse at walls
	if get_slide_collision_count() > 0:
		for i: int in range(get_slide_collision_count()):
			var collision: KinematicCollision2D = get_slide_collision(i)
			var collider: Object = collision.get_collider()
			if collider is Node and (collider as Node).has_method("take_damage"):
				_apply_contact_damage(collider as Node)
			if absf(collision.get_normal().x) > 0.5:
				_patrol_dir *= -1.0
				break

	# Reverse at platform edges (prevent walking off)
	if is_on_floor():
		var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
		var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
			global_position + Vector2(_patrol_dir * 16, 0),
			global_position + Vector2(_patrol_dir * 16, 32),
			1 << 4  # environment layer (layer 5, bit index 4)
		)
		var result: Dictionary = space_state.intersect_ray(query)
		if result.is_empty():
			_patrol_dir *= -1.0

	_sprite.flip_h = _patrol_dir > 0


func _process_hit(delta: float) -> void:
	velocity.x = 0.0
	velocity.y += GRAVITY * delta
	move_and_slide()

	_hit_timer -= 1
	if _hit_timer <= 0:
		_sprite.modulate = NORMAL_MODULATE
		_state = State.PATROL

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


## Returns the enemy StatusEffectComponent for weapon effect integration.
func get_status_effect_component() -> StatusEffectComponent:
	return _status_effects


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
	_contact_damage_timer = 0
	velocity = Vector2.ZERO
	collision_layer = _read_int(snapshot.get("collision_layer", collision_layer), collision_layer)
	collision_mask = _read_int(snapshot.get("collision_mask", collision_mask), collision_mask)
	_sprite.modulate = _read_color(snapshot.get("sprite_modulate", NORMAL_MODULATE), NORMAL_MODULATE)
	if _health != null:
		_health.configure(ENEMY_ENTITY_ID, MAX_HP, _hp, 0, 0, false)
	if _collision != null:
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


func _on_core_death(_entity_id: int, _metadata: Dictionary) -> void:
	if _state == State.DEAD:
		return
	_state = State.DEAD
	enemy_defeated.emit()
	_sprite.modulate.a = 0.3
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	var tween: Tween = create_tween()
	tween.tween_property(_sprite, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)


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
