## Simple enemy — patrol, take damage, die.
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
const MAX_HP: int = 3
const CONTACT_DAMAGE_COOLDOWN_FRAMES: int = 45
const NORMAL_MODULATE: Color = Color.WHITE
const HIT_MODULATE: Color = Color(1.0, 0.9, 0.9, 1.0)

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

# ---------------------------------------------------------------------------
# Node References
# ---------------------------------------------------------------------------

@onready var _sprite: Sprite2D = $Sprite

# ---------------------------------------------------------------------------
# Built-in Virtual Methods
# ---------------------------------------------------------------------------

func _ready() -> void:
	enemy_health_changed.emit(_hp, MAX_HP)


func _physics_process(delta: float) -> void:
	_contact_damage_timer = maxi(_contact_damage_timer - 1, 0)
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
	velocity.x = _patrol_dir * PATROL_SPEED
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

## Called by the player's attack hitbox via body_entered signal.
func take_damage() -> void:
	if _state == State.DEAD:
		return

	_hp -= 1
	enemy_health_changed.emit(_hp, MAX_HP)
	_hit_timer = HIT_FLASH_FRAMES
	_state = State.HIT
	_sprite.modulate = HIT_MODULATE

	if _hp <= 0:
		_state = State.DEAD
		enemy_defeated.emit()
		_sprite.modulate.a = 0.3
		# Disable collision so player passes through
		set_deferred("collision_layer", 0)
		set_deferred("collision_mask", 0)
		# Remove after a brief fade
		var tween: Tween = create_tween()
		tween.tween_property(_sprite, "modulate:a", 0.0, 0.3)
		tween.tween_callback(queue_free)


func get_current_hp() -> int:
	return maxi(0, _hp)


func get_max_hp() -> int:
	return MAX_HP


func capture_respawn_snapshot() -> Dictionary:
	return {
		"global_position": global_position,
		"hp": _hp,
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
	enemy_health_changed.emit(_hp, MAX_HP)


func _apply_contact_damage(target: Node) -> void:
	if _contact_damage_timer > 0:
		return
	target.call("take_damage")
	_contact_damage_timer = CONTACT_DAMAGE_COOLDOWN_FRAMES


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
