## Player controller — prototype movement, jump, attack, and dodge.
##
## Provides responsive 2D platformer feel with acceleration/friction,
## coyote time, jump buffering, a simple attack flash, and a dodge dash.
class_name PlayerController
extends CharacterBody2D

signal player_health_changed(current_hp: int, max_hp: int)
signal player_died
signal attack_landed(hit_data: Dictionary)

# ---------------------------------------------------------------------------
# Constants — Movement
# ---------------------------------------------------------------------------

const ACCELERATION: float = 800.0
const MAX_RUN_SPEED: float = 200.0
const FRICTION: float = 1200.0
const GRAVITY: float = 800.0
const JUMP_VELOCITY: float = -360.0

## Frames (at 60 fps) for coyote time and jump buffer.
const COYOTE_FRAMES: int = 5
const JUMP_BUFFER_FRAMES: int = 5

# ---------------------------------------------------------------------------
# Constants — Combat
# ---------------------------------------------------------------------------

const ATTACK_DURATION_FRAMES: int = 6
const DODGE_DURATION_FRAMES: int = 8
const DODGE_COOLDOWN_FRAMES: int = 12
const DODGE_SPEED: float = 400.0
const NORMAL_MODULATE: Color = Color.WHITE
const ATTACK_MODULATE: Color = Color(1.0, 0.55, 0.45, 1.0)
const DAMAGE_MODULATE: Color = Color(1.0, 0.25, 0.25, 1.0)
const PLAYER_ENTITY_ID: int = 1
const PLAYER_MAX_HP: int = 100
const CONTACT_DAMAGE: int = 20
const ATTACK_DISPLAY_DAMAGE: int = 12

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

enum State { IDLE, ATTACKING, DODGING }

var _state: State = State.IDLE
var _facing: float = 1.0  # 1 = right, -1 = left
var _coyote_timer: int = 0
var _jump_buffer_timer: int = 0
var _attack_timer: int = 0
var _dodge_timer: int = 0
var _dodge_cooldown_timer: int = 0
var _control_locked: bool = false

# ---------------------------------------------------------------------------
# Node References
# ---------------------------------------------------------------------------

@onready var _sprite: Sprite2D = $Sprite
@onready var _hitbox_area: Area2D = $AttackHitbox
@onready var _hitbox_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D
@onready var _health: HealthComponent = $HealthComponent

# ---------------------------------------------------------------------------
# Built-in Virtual Methods
# ---------------------------------------------------------------------------

func _ready() -> void:
	_hitbox_area.body_entered.connect(_on_attack_hit_body)
	_health.configure(PLAYER_ENTITY_ID, PLAYER_MAX_HP, PLAYER_MAX_HP, 0, 0, true)
	_health.set_active_enemy_count(1)
	_health.on_hp_changed.connect(_on_health_changed)
	_health.on_death.connect(_on_death)
	player_health_changed.emit(_health.get_current_hp(), _health.get_max_hp())


func _physics_process(delta: float) -> void:
	# Tick timers
	_dodge_cooldown_timer = maxi(_dodge_cooldown_timer - 1, 0)

	# State transitions back to IDLE
	if _state == State.ATTACKING:
		_attack_timer -= 1
		_update_attack_visual()
		if _attack_timer <= 0:
			_state = State.IDLE
			_hitbox_shape.disabled = true
			_sprite.modulate = NORMAL_MODULATE

	if _state == State.DODGING:
		_dodge_timer -= 1
		if _dodge_timer <= 0:
			_state = State.IDLE
			_sprite.modulate = NORMAL_MODULATE

	# Input + movement
	_handle_input()
	_apply_gravity(delta)
	_apply_dodge_velocity(delta)
	move_and_slide()

	# Update facing direction
	_update_facing()

	# Coyote time tracking
	if is_on_floor():
		_coyote_timer = COYOTE_FRAMES
	else:
		_coyote_timer = maxi(_coyote_timer - 1, 0)

# ---------------------------------------------------------------------------
# Input Handling
# ---------------------------------------------------------------------------

func _handle_input() -> void:
	if _control_locked:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * get_physics_process_delta_time())
		return

	var input_dir: float = Input.get_axis("move_left", "move_right")

	# Horizontal movement (disabled during attack/dodge)
	if _state != State.ATTACKING and _state != State.DODGING:
		if input_dir != 0.0:
			velocity.x = move_toward(velocity.x, input_dir * MAX_RUN_SPEED, ACCELERATION * get_physics_process_delta_time())
			_facing = input_dir
		else:
			velocity.x = move_toward(velocity.x, 0.0, FRICTION * get_physics_process_delta_time())
	else:
		# Lock horizontal movement during attack/dodge
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * get_physics_process_delta_time())

	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = JUMP_BUFFER_FRAMES
	else:
		_jump_buffer_timer = maxi(_jump_buffer_timer - 1, 0)

	# Execute jump if buffer active and coyote time valid
	if _jump_buffer_timer > 0 and _coyote_timer > 0 and _state != State.DODGING:
		velocity.y = JUMP_VELOCITY
		_jump_buffer_timer = 0
		_coyote_timer = 0

	# Attack
	if Input.is_action_just_pressed("attack") and _state == State.IDLE:
		_start_attack()

	# Dodge
	if Input.is_action_just_pressed("dodge") and _state == State.IDLE and _dodge_cooldown_timer <= 0:
		_start_dodge()

# ---------------------------------------------------------------------------
# Physics Helpers
# ---------------------------------------------------------------------------

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta


func _apply_dodge_velocity(_delta: float) -> void:
	if _state == State.DODGING:
		velocity.x = _facing * DODGE_SPEED

# ---------------------------------------------------------------------------
# Attack
# ---------------------------------------------------------------------------

func _start_attack() -> void:
	_state = State.ATTACKING
	_attack_timer = ATTACK_DURATION_FRAMES
	_hitbox_shape.disabled = false
	# Position hitbox in front of player
	_hitbox_area.position.x = _facing * 20.0


func _update_attack_visual() -> void:
	# Flash hitbox area red during active frames
	if _attack_timer > 2:
		_sprite.modulate = ATTACK_MODULATE
	else:
		_sprite.modulate = NORMAL_MODULATE


func _on_attack_hit_body(body: Node2D) -> void:
	if _state != State.ATTACKING:
		return
	if body.has_method("take_damage"):
		body.take_damage()
		attack_landed.emit({
			"damage": ATTACK_DISPLAY_DAMAGE,
			"hit_position": body.global_position + Vector2(0, -32),
			"is_crit": false,
			"source": &"cat_claw",
		})

# ---------------------------------------------------------------------------
# Dodge
# ---------------------------------------------------------------------------

func _start_dodge() -> void:
	_state = State.DODGING
	_dodge_timer = DODGE_DURATION_FRAMES
	_dodge_cooldown_timer = DODGE_COOLDOWN_FRAMES
	_sprite.modulate = Color(1.0, 1.0, 1.0, 0.45)


# ---------------------------------------------------------------------------
# Facing
# ---------------------------------------------------------------------------

func _update_facing() -> void:
	_sprite.flip_h = _facing < 0.0
	# Position attack hitbox based on facing
	if _state != State.ATTACKING:
		_hitbox_area.position.x = _facing * 20.0

# ---------------------------------------------------------------------------
# Public API — called by enemy attacks (future use)
# ---------------------------------------------------------------------------

func take_damage() -> void:
	if _control_locked:
		return
	if _state == State.DODGING:
		return  # Invincible during dodge
	_sprite.modulate = DAMAGE_MODULATE
	_health.apply_damage(CONTACT_DAMAGE, {
		"source": &"shadow_beast",
		"damage_type": &"contact",
	})


func get_current_hp() -> int:
	return _health.get_current_hp()


func get_max_hp() -> int:
	return _health.get_max_hp()


func set_control_locked(locked: bool) -> void:
	_control_locked = locked
	if locked:
		velocity = Vector2.ZERO
		_hitbox_shape.disabled = true


func respawn_at(respawn_position: Vector2, revive_hp_percentage: float) -> void:
	global_position = respawn_position
	velocity = Vector2.ZERO
	_state = State.IDLE
	_attack_timer = 0
	_dodge_timer = 0
	_dodge_cooldown_timer = 0
	_jump_buffer_timer = 0
	_coyote_timer = 0
	_hitbox_shape.disabled = true
	_sprite.modulate = NORMAL_MODULATE
	_health.revive(revive_hp_percentage)
	_health.grant_iframes(120)


func _on_health_changed(_entity_id: int, current_hp: int, max_hp: int) -> void:
	player_health_changed.emit(current_hp, max_hp)


func _on_death(_entity_id: int, _metadata: Dictionary) -> void:
	player_died.emit()
