## Player controller — prototype movement, jump, attack, and dodge.
##
## Provides responsive 2D platformer feel with acceleration/friction,
## coyote time, jump buffering, a simple attack flash, and a dodge dash.
class_name PlayerController
extends CharacterBody2D

signal player_health_changed(current_hp: int, max_hp: int)
signal player_died(death_metadata: Dictionary)
signal attack_landed(hit_data: Dictionary)
signal attack_started(attack_data: Dictionary)
signal dodge_started(texture: Texture2D, world_position: Vector2, facing: float)
signal dash_started(texture: Texture2D, world_position: Vector2, facing: float)
signal double_jump_started(texture: Texture2D, world_position: Vector2, facing: float)
signal aerial_attack_started(texture: Texture2D, world_position: Vector2, facing: float)
signal aerial_attack_bounced(metadata: Dictionary)
signal heavy_charge_changed(active: bool, charge_ratio: float, charge_seconds: float, ready: bool)
signal wall_climb_started(
	texture: Texture2D,
	world_position: Vector2,
	wall_normal: Vector2
)
signal wall_jump_started(world_position: Vector2, wall_normal: Vector2)
signal ability_unlocked(ability_id: StringName)
signal ability_activated(ability_id: StringName)

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
const COMBAT_PROCESS_PHYSICS_PRIORITY: int = -100
const COLLISION_PROCESS_PHYSICS_PRIORITY: int = -50
const DODGE_DURATION_FRAMES: int = 12
const DODGE_COOLDOWN_FRAMES: int = 12
const DODGE_SPEED: float = 400.0
const DASH_DURATION_FRAMES: int = 10
const DASH_SPEED: float = 620.0
const DOUBLE_JUMP_HEIGHT_RATIO: float = 0.82
const DOUBLE_JUMP_ANIMATION_LOCK_FRAMES: int = 10
const AERIAL_ATTACK_DURATION_FRAMES: int = 12
const AERIAL_ATTACK_HITBOX_FRAMES: int = 8
const AERIAL_ATTACK_DIVE_SPEED: float = 480.0
const AERIAL_ATTACK_BOUNCE_VELOCITY: float = -280.0
const AERIAL_ATTACK_HITBOX_OFFSET_Y: float = 34.0
const HEAVY_ATTACK_DURATION_FRAMES: int = 12
const HEAVY_ATTACK_HITBOX_FRAMES: int = 8
const HEAVY_CHARGE_MIN_SEC: float = 0.5
const HEAVY_CHARGE_MAX_SEC: float = 1.5
const HEAVY_DAMAGE_MULTIPLIER_MIN: float = 1.2
const HEAVY_DAMAGE_MULTIPLIER_MAX: float = 2.0
const HEAVY_HITBOX_SIZE_MULTIPLIER: float = 1.25
const SKILL_DAMAGE_BONUS_CAP: float = 0.25
const NORMAL_MODULATE: Color = Color.WHITE
const ATTACK_MODULATE: Color = Color(1.0, 0.55, 0.45, 1.0)
const HEAVY_CHARGE_MODULATE: Color = Color(1.0, 0.78, 0.32, 1.0)
const DAMAGE_MODULATE: Color = Color(1.0, 0.25, 0.25, 1.0)
const ANIMATION_IDLE: StringName = &"idle"
const ANIMATION_RUN: StringName = &"run"
const ANIMATION_ATTACK: StringName = &"attack"
const ANIMATION_ATTACK_2: StringName = &"attack_2"
const ANIMATION_ATTACK_3: StringName = &"attack_3"
const LIGHT_ATTACK_ANIMATIONS: Array[StringName] = [
	ANIMATION_ATTACK,
	ANIMATION_ATTACK_2,
	ANIMATION_ATTACK_3,
]
const LIGHT_ATTACK_CONTACT_VISUAL_FRAME: int = 1
const ANIMATION_DODGE: StringName = &"dodge"
const ANIMATION_DASH: StringName = &"dash"
const ANIMATION_PARRY: StringName = &"parry"
const ANIMATION_HURT: StringName = &"hurt"
const ANIMATION_DEATH: StringName = &"death"
const ANIMATION_REVIVE: StringName = &"revive"
const ANIMATION_JUMP: StringName = &"jump"
const ANIMATION_FALL: StringName = &"fall"
const ANIMATION_AERIAL_ATTACK: StringName = &"aerial_attack"
const ANIMATION_WALL_CLIMB: StringName = &"wall_climb"
const ANIMATION_HEAVY_CHARGE: StringName = &"heavy_charge"
const ANIMATION_HEAVY_ATTACK: StringName = &"heavy_attack"
const PARRY_DURATION_FRAMES: int = 18
const RUN_ANIMATION_MIN_SPEED: float = 5.0
const HURT_ANIMATION_LOCK_FRAMES: int = 12
const DEATH_ANIMATION_LOCK_FRAMES: int = 90
const REVIVE_ANIMATION_LOCK_FRAMES: int = 24
const PLAYER_ENTITY_ID: int = 1
const PLAYER_MAX_HP: int = 100
const CONTACT_DAMAGE: int = 20
const ATTACK_DISPLAY_DAMAGE: int = 12
const RESPAWN_INVINCIBILITY_FRAMES: int = 120
const RESPAWN_FLASH_INTERVAL_FRAMES: int = 8
const RESPAWN_FLASH_DIM_ALPHA: float = 0.42
const RESPAWN_FLASH_BRIGHT_ALPHA: float = 0.72
const PLAYER_HURTBOX_SIZE: Vector2 = Vector2(20, 44)
const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")
const COLLISION_COMPONENT_SCRIPT: Script = preload("res://src/core/collision_component.gd")
const ABILITY_COMPONENT_SCRIPT: Script = preload("res://src/core/ability_component.gd")
const ABILITY_DASH: StringName = &"dash"
const ABILITY_DOUBLE_JUMP: StringName = &"double_jump"
const ABILITY_PARRY: StringName = &"parry"
const ABILITY_AERIAL_ATTACK: StringName = &"aerial_attack"
const ABILITY_WALL_CLIMB: StringName = &"wall_climb"
const WALL_NORMAL_X_MIN: float = 0.65
const WALL_INPUT_EPSILON: float = 0.1
const WALL_CONTACT_HOLD_SPEED: float = 24.0

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

enum State {
	IDLE,
	ATTACKING,
	DODGING,
	DASHING,
	PARRYING,
	AERIAL_ATTACKING,
	WALL_CLIMBING,
	CHARGING,
}

var _state: State = State.IDLE
var _facing: float = 1.0  # 1 = right, -1 = left
var _coyote_timer: int = 0
var _jump_buffer_timer: int = 0
var _attack_timer: int = 0
var _dodge_timer: int = 0
var _dodge_cooldown_timer: int = 0
var _dash_timer: int = 0
var _parry_timer: int = 0
var _aerial_attack_timer: int = 0
var _aerial_bounce_consumed: bool = false
var _aerial_air_jump_restored: bool = false
var _last_aerial_attack_metadata: Dictionary = {}
var _last_heavy_attack_metadata: Dictionary = {}
var _last_skill_range_tiles: float = 0.0
var _wall_normal: Vector2 = Vector2.ZERO
var _wall_regrab_lock_frames: int = 0
var _control_locked: bool = false
var _respawn_visual_remaining_frames: int = 0
var _respawn_visual_elapsed_frames: int = 0
var _presentation_animation_lock_frames: int = 0
var _combat: CombatComponent = null
var _collision: CollisionComponent = null
var _ability: AbilityComponent = null
var _weapon_component: Object = null
var _damage_calculator_adapter: Object = null
var _skill_modifier_provider: Object = null
var _last_skill_lunge_px: float = 0.0
var _active_attack_animation: StringName = ANIMATION_ATTACK
var _active_light_attack_stage: int = -1
var _pending_light_hitbox_stage: int = -1
var _pending_light_hitbox_lunge_px: float = 0.0
var _pending_light_hitbox_range_tiles: float = 0.0
var _active_light_hitbox_id: StringName = &""
var _light_attack_chain_queued: bool = false
var _is_airborne_state: bool = false

# ---------------------------------------------------------------------------
# Node References
# ---------------------------------------------------------------------------

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _hitbox_area: Area2D = $AttackHitbox
@onready var _hitbox_shape: CollisionShape2D = $AttackHitbox/CollisionShape2D
@onready var _health: HealthComponent = $HealthComponent

# ---------------------------------------------------------------------------
# Built-in Virtual Methods
# ---------------------------------------------------------------------------

func _ready() -> void:
	_ensure_core_components()
	_hitbox_area.body_entered.connect(_on_attack_hit_body)
	_health.configure(PLAYER_ENTITY_ID, PLAYER_MAX_HP, PLAYER_MAX_HP, 0, 0, true)
	_health.set_active_enemy_count(1)
	_health.on_hp_changed.connect(_on_health_changed)
	_health.on_death.connect(_on_death)
	_setup_core_combat_chain()
	_play_character_animation(ANIMATION_IDLE)
	player_health_changed.emit(_health.get_current_hp(), _health.get_max_hp())


func _physics_process(delta: float) -> void:
	# Tick timers
	_dodge_cooldown_timer = maxi(_dodge_cooldown_timer - 1, 0)
	_wall_regrab_lock_frames = maxi(_wall_regrab_lock_frames - 1, 0)

	# State transitions back to IDLE
	if _state == State.ATTACKING:
		_attack_timer -= 1
		_update_attack_visual()
		if _attack_timer <= 0:
			_clear_light_attack_hitbox_timing()
			_state = State.IDLE
			_active_attack_animation = ANIMATION_ATTACK
			_active_light_attack_stage = -1
			_hitbox_shape.disabled = true
			_sprite.modulate = NORMAL_MODULATE

	if _state == State.CHARGING:
		_emit_heavy_charge_progress()

	if _state == State.DODGING:
		_dodge_timer -= 1
		if _dodge_timer <= 0:
			_state = State.IDLE
			_sprite.modulate = NORMAL_MODULATE

	if _state == State.DASHING:
		_dash_timer -= 1
		if _dash_timer <= 0:
			_state = State.IDLE
			_sprite.modulate = NORMAL_MODULATE

	if _state == State.PARRYING:
		_parry_timer -= 1
		if _parry_timer <= 0:
			_state = State.IDLE
			_sprite.modulate = NORMAL_MODULATE

	if _state == State.AERIAL_ATTACKING:
		_aerial_attack_timer -= 1
		if _aerial_attack_timer <= 0:
			_state = State.IDLE
			_sprite.modulate = NORMAL_MODULATE

	# Input + movement
	_handle_input()
	_apply_gravity(delta)
	_apply_burst_movement_velocity(delta)
	move_and_slide()
	if _state == State.WALL_CLIMBING and (is_on_floor() or not is_on_wall()):
		_stop_wall_climb()

	# Update facing direction
	_update_facing()

	# Coyote time tracking
	if is_on_floor():
		clear_wall_climb_regrab_lock()
		set_airborne(false)
		_coyote_timer = COYOTE_FRAMES
	else:
		set_airborne(true)
		_coyote_timer = maxi(_coyote_timer - 1, 0)
	_advance_respawn_visual()
	_update_character_animation()

# ---------------------------------------------------------------------------
# Input Handling
# ---------------------------------------------------------------------------

func _handle_input() -> void:
	if _control_locked:
		_stop_wall_climb()
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * get_physics_process_delta_time())
		return

	var input_dir: float = Input.get_axis("move_left", "move_right")
	var vertical_input: float = Input.get_axis("move_up", "move_down")
	if _handle_wall_climb_input(input_dir, vertical_input):
		return

	# Horizontal movement (disabled during attack/dodge)
	if (
		_state != State.ATTACKING
		and _state != State.DODGING
		and _state != State.DASHING
			and _state != State.PARRYING
			and _state != State.AERIAL_ATTACKING
			and _state != State.CHARGING
		):
		if input_dir != 0.0:
			velocity.x = move_toward(velocity.x, input_dir * MAX_RUN_SPEED, ACCELERATION * get_physics_process_delta_time())
			_facing = input_dir
		else:
			velocity.x = move_toward(velocity.x, 0.0, FRICTION * get_physics_process_delta_time())
	else:
		# Lock horizontal movement during attack/dodge/dash
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * get_physics_process_delta_time())

	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = JUMP_BUFFER_FRAMES
	else:
		_jump_buffer_timer = maxi(_jump_buffer_timer - 1, 0)

	# Execute jump if buffer active; airborne presses can consume double jump.
	if _jump_buffer_timer > 0 and _state not in [State.DODGING, State.CHARGING]:
		if _coyote_timer > 0:
			_start_ground_jump()
		elif request_double_jump():
			_jump_buffer_timer = 0

	# Attack
	if Input.is_action_just_pressed("attack") and _state in [State.IDLE, State.ATTACKING]:
		request_attack()

	if Input.is_action_just_pressed("heavy_attack"):
		request_heavy_attack_press()
	elif Input.is_action_just_released("heavy_attack"):
		request_heavy_attack_release()

	# Dodge
	if Input.is_action_just_pressed("dodge"):
		request_dodge()

	# Dash
	if Input.is_action_just_pressed("dash"):
		request_dash()

	# Parry
	if Input.is_action_just_pressed("parry"):
		request_parry()


func _handle_wall_climb_input(
	horizontal_input: float,
	vertical_input: float
) -> bool:
	if _state == State.WALL_CLIMBING:
		if Input.is_action_just_pressed("jump"):
			return request_wall_jump()
		if not is_on_wall() or not _is_input_toward_wall(
			horizontal_input,
			_wall_normal
		):
			_stop_wall_climb()
			return false
		return request_wall_climb(
			get_wall_normal(),
			vertical_input,
			true
		)
	if (
		_wall_regrab_lock_frames > 0
		or is_on_floor()
		or not is_on_wall()
		or absf(vertical_input) <= WALL_INPUT_EPSILON
	):
		return false
	var wall_normal: Vector2 = get_wall_normal()
	if not _is_input_toward_wall(horizontal_input, wall_normal):
		return false
	return request_wall_climb(wall_normal, vertical_input, true)


func _is_input_toward_wall(
	horizontal_input: float,
	wall_normal: Vector2
) -> bool:
	return (
		absf(horizontal_input) > WALL_INPUT_EPSILON
		and horizontal_input * wall_normal.x < -WALL_INPUT_EPSILON
	)

# ---------------------------------------------------------------------------
# Physics Helpers
# ---------------------------------------------------------------------------

func _apply_gravity(delta: float) -> void:
	if not is_on_floor() and _state != State.WALL_CLIMBING:
		velocity.y += GRAVITY * delta


func _apply_burst_movement_velocity(_delta: float) -> void:
	if _state == State.DODGING:
		velocity.x = _facing * DODGE_SPEED
	elif _state == State.DASHING:
		velocity.x = _facing * DASH_SPEED
	elif _state == State.AERIAL_ATTACKING:
		velocity.y = maxf(velocity.y, AERIAL_ATTACK_DIVE_SPEED)

# ---------------------------------------------------------------------------
# Attack
# ---------------------------------------------------------------------------

## Requests a player light attack through the Core combat/collision/weapon chain.
func request_attack() -> bool:
	if _control_locked:
		return false
	if _state == State.IDLE:
		if request_aerial_attack():
			return true
		return _request_light_attack_stage(0, false)
	if (
		_state == State.ATTACKING
		and _active_light_attack_stage >= 0
		and _combat != null
		and _combat.is_in_attack_recovery()
	):
		if _active_light_attack_stage < CombatComponent.MAX_COMBO_INDEX:
			if _is_light_attack_active_window():
				if _light_attack_chain_queued:
					return false
				_light_attack_chain_queued = true
				return true
		_combat.on_action_triggered(&"attack", {})
		if _combat.get_attack_frame() != 0:
			return false
		return _request_light_attack_stage(_combat.get_combo_index(), true)
	return false


## Starts a grounded heavy charge through the existing Core combat state machine.
func request_heavy_attack_press() -> bool:
	if _control_locked or _state != State.IDLE or _is_airborne_state or _combat == null:
		return false
	if _combat.get_current_state() != CombatComponent.CombatState.IDLE:
		return false
	_last_heavy_attack_metadata.clear()
	_combat.on_action_triggered(&"heavy_attack", {"pressed": true})
	if _combat.get_current_state() != CombatComponent.CombatState.CHARGING:
		return false
	_state = State.CHARGING
	velocity.x = 0.0
	_sprite.modulate = HEAVY_CHARGE_MODULATE
	_play_character_animation(ANIMATION_HEAVY_CHARGE, true)
	_emit_heavy_charge_progress()
	return true


## Releases a valid charge or cancels an early release without creating a hitbox.
func request_heavy_attack_release() -> bool:
	if _state != State.CHARGING or _combat == null:
		return false
	_last_heavy_attack_metadata.clear()
	_combat.on_action_triggered(&"heavy_attack", {"pressed": false})
	var released: bool = not _last_heavy_attack_metadata.is_empty()
	if not released:
		_reset_heavy_charge_presentation()
	return released


## Advances charge time deterministically for tests and non-frame-driven callers.
func advance_heavy_charge_time(delta_sec: float) -> void:
	if _state != State.CHARGING or _combat == null:
		return
	_combat.advance_charge_time(delta_sec)
	if _state == State.CHARGING:
		_emit_heavy_charge_progress()


## Returns the visible and Core charge state for tests and MCP inspection.
func get_heavy_attack_diagnostics() -> Dictionary:
	var charge_ratio: float = _combat.get_charge_ratio() if _combat != null else 0.0
	return {
		"charging": _state == State.CHARGING,
		"animation": String(_sprite.animation) if _sprite != null else "",
		"charge_ratio": charge_ratio,
		"charge_seconds": charge_ratio * HEAVY_CHARGE_MAX_SEC,
		"ready": charge_ratio >= HEAVY_CHARGE_MIN_SEC / HEAVY_CHARGE_MAX_SEC,
		"hitbox_id": StringName("%s_heavy" % String(_get_current_weapon_id())),
		"last_attack_metadata": _last_heavy_attack_metadata.duplicate(true),
	}


func _on_core_heavy_attack_released(metadata: Dictionary) -> void:
	var charge_seconds: float = clampf(
		float(metadata.get("charge_seconds", 0.0)),
		HEAVY_CHARGE_MIN_SEC,
		HEAVY_CHARGE_MAX_SEC
	)
	var charge_ratio: float = clampf(charge_seconds / HEAVY_CHARGE_MAX_SEC, 0.0, 1.0)
	var power_ratio: float = inverse_lerp(
		HEAVY_CHARGE_MIN_SEC,
		HEAVY_CHARGE_MAX_SEC,
		charge_seconds
	)
	var charge_multiplier: float = lerpf(
		HEAVY_DAMAGE_MULTIPLIER_MIN,
		HEAVY_DAMAGE_MULTIPLIER_MAX,
		power_ratio
	)
	var skill_knockback_px: float = _resolve_skill_knockback_px()
	var skill_modifiers: Dictionary = _build_skill_damage_modifiers()
	skill_modifiers["attack_type_multiplier"] = charge_multiplier
	var attack_metadata: Dictionary = {
		"weapon_id": _get_current_weapon_id(),
		"attack_type": &"heavy",
		"combo_index": 0,
		"attack_position": global_position + Vector2(_facing * 38.0, -24.0),
		"facing": _facing,
		"hitbox_id": StringName("%s_heavy" % String(_get_current_weapon_id())),
		"charge_seconds": charge_seconds,
		"charge_ratio": charge_ratio,
		"charge_multiplier": charge_multiplier,
		"skill_knockback_px": skill_knockback_px,
		"knockback_direction": _facing,
		"hitbox_size_multiplier": HEAVY_HITBOX_SIZE_MULTIPLIER,
		"skill_modifiers": skill_modifiers,
	}
	_last_heavy_attack_metadata = attack_metadata.duplicate(true)
	_activate_heavy_attack_hitbox(attack_metadata)
	_start_heavy_attack_visual()
	heavy_charge_changed.emit(false, charge_ratio, charge_seconds, true)
	attack_started.emit(attack_metadata.duplicate(true))


func _activate_heavy_attack_hitbox(metadata: Dictionary) -> bool:
	if _weapon_component == null or not _weapon_component.has_method("activate_current_attack_hitbox"):
		return false
	return bool(_weapon_component.call(
		"activate_current_attack_hitbox",
		&"heavy",
		HEAVY_ATTACK_HITBOX_FRAMES,
		0,
		metadata
	))


func _start_heavy_attack_visual() -> void:
	_state = State.ATTACKING
	_attack_timer = HEAVY_ATTACK_DURATION_FRAMES
	_active_attack_animation = ANIMATION_HEAVY_ATTACK
	_active_light_attack_stage = -1
	_set_hitbox_shape_disabled(true)
	_play_character_animation(ANIMATION_HEAVY_ATTACK, true)


func _emit_heavy_charge_progress() -> void:
	if _combat == null or _state != State.CHARGING:
		return
	var charge_ratio: float = _combat.get_charge_ratio()
	var charge_seconds: float = charge_ratio * HEAVY_CHARGE_MAX_SEC
	heavy_charge_changed.emit(
		true,
		charge_ratio,
		charge_seconds,
		charge_seconds >= HEAVY_CHARGE_MIN_SEC
	)


func _reset_heavy_charge_presentation(cancel_core: bool = false) -> void:
	if cancel_core and _combat != null and _combat.has_method("cancel_heavy_charge"):
		_combat.call("cancel_heavy_charge")
	if _state == State.CHARGING:
		_state = State.IDLE
	_sprite.modulate = NORMAL_MODULATE
	heavy_charge_changed.emit(false, 0.0, 0.0, false)


## Starts the unlocked airborne downward strike through the Core hit chain.
func request_aerial_attack() -> bool:
	if _control_locked or _state != State.IDLE:
		return false
	_ensure_ability_component()
	if _combat != null and _combat.get_current_state() != CombatComponent.CombatState.IDLE:
		return false
	if _ability == null or not _ability.try_activate_ability(ABILITY_AERIAL_ATTACK):
		return false
	var hitbox_activated: bool = _activate_aerial_attack_hitbox()
	if not hitbox_activated and _weapon_component != null:
		return false
	if _combat != null:
		_combat.on_action_triggered(&"attack", {"combo_index": 0})
	_start_aerial_attack_visual()
	_last_aerial_attack_metadata = _build_aerial_attack_metadata()
	attack_started.emit(_last_aerial_attack_metadata.duplicate(true))
	aerial_attack_started.emit(
		_get_current_sprite_texture(),
		_sprite.global_position,
		_facing
	)
	return true


func _activate_aerial_attack_hitbox() -> bool:
	if _weapon_component == null or not _weapon_component.has_method("activate_current_attack_hitbox"):
		return false
	return bool(_weapon_component.call(
		"activate_current_attack_hitbox",
		&"aerial",
		AERIAL_ATTACK_HITBOX_FRAMES,
		0,
		{
			"hitbox_offset_y": AERIAL_ATTACK_HITBOX_OFFSET_Y,
			"aerial_attack": true,
			"skill_modifiers": _build_skill_damage_modifiers(),
		}
	))


func _start_aerial_attack_visual() -> void:
	_state = State.AERIAL_ATTACKING
	_aerial_attack_timer = AERIAL_ATTACK_DURATION_FRAMES
	_aerial_bounce_consumed = false
	_aerial_air_jump_restored = false
	velocity.y = AERIAL_ATTACK_DIVE_SPEED
	_set_hitbox_shape_disabled(true)
	_play_character_animation(ANIMATION_AERIAL_ATTACK, true)


func _build_aerial_attack_metadata() -> Dictionary:
	return {
		"weapon_id": _get_current_weapon_id(),
		"attack_type": &"aerial",
		"combo_index": 0,
		"attack_position": global_position + Vector2(0.0, AERIAL_ATTACK_HITBOX_OFFSET_Y),
		"facing": _facing,
		"hitbox_id": StringName("%s_aerial" % String(_get_current_weapon_id())),
	}


func _request_light_attack_stage(combo_index: int, combat_already_advanced: bool) -> bool:
	if (
		_combat != null
		and not combat_already_advanced
		and _combat.get_current_state() != CombatComponent.CombatState.IDLE
	):
		return false
	if (
		_weapon_component != null
		and not _weapon_component.has_method("activate_current_attack_hitbox")
	):
		return false
	var skill_lunge_px: float = _resolve_skill_lunge_px(combo_index)
	var skill_range_tiles: float = _resolve_skill_range_tiles(combo_index)
	_clear_light_attack_hitbox_timing()
	_apply_skill_lunge(skill_lunge_px)
	if _combat != null and not combat_already_advanced:
		_combat.on_action_triggered(&"attack", {"combo_index": combo_index})
	_start_attack_visual(combo_index)
	_schedule_light_attack_hitbox(combo_index, skill_lunge_px, skill_range_tiles)
	attack_started.emit(_build_attack_started_metadata(combo_index))
	return true


func _start_attack_visual(combo_index: int) -> void:
	var safe_combo_index: int = clampi(combo_index, 0, LIGHT_ATTACK_ANIMATIONS.size() - 1)
	var frame_data: Dictionary = (
		_combat.get_light_attack_frame_data(safe_combo_index)
		if _combat != null
		else {}
	)
	_state = State.ATTACKING
	_attack_timer = int(frame_data.get("total_frames", ATTACK_DURATION_FRAMES))
	_active_light_attack_stage = safe_combo_index
	_active_attack_animation = LIGHT_ATTACK_ANIMATIONS[safe_combo_index]
	_set_hitbox_shape_disabled(true)
	# Position hitbox in front of player
	_hitbox_area.position.x = _facing * 20.0
	_play_character_animation(_active_attack_animation, true)
	_sprite.pause()


func _activate_weapon_hitbox(
	combo_index: int,
	duration_frames: int,
	skill_lunge_px: float = 0.0,
	skill_range_tiles: float = 0.0
) -> bool:
	if _weapon_component == null or not _weapon_component.has_method("activate_current_attack_hitbox"):
		return false
	var skill_modifiers: Dictionary = {}
	var skill_damage_bonus: float = _resolve_skill_damage_bonus()
	if skill_damage_bonus > 0.0:
		skill_modifiers["skill_damage_bonus"] = skill_damage_bonus
	var slow_pulse: Dictionary = _resolve_skill_slow_pulse(combo_index)
	if not slow_pulse.is_empty():
		skill_modifiers["slow_pulse"] = slow_pulse
	return bool(_weapon_component.call(
		"activate_current_attack_hitbox",
		&"light",
		duration_frames,
		combo_index,
			{
				"hit_frame": ATTACK_DURATION_FRAMES,
				"authored_attack_frame": (
					_combat.get_attack_frame() if _combat != null else 0
				),
				"skill_lunge_px": skill_lunge_px,
				"skill_range_tiles": skill_range_tiles,
				"hitbox_offset_x": skill_lunge_px * _facing,
				"facing": _facing,
				"skill_modifiers": skill_modifiers,
			}
		))


func _schedule_light_attack_hitbox(
	combo_index: int,
	skill_lunge_px: float,
	skill_range_tiles: float
) -> void:
	_pending_light_hitbox_stage = combo_index
	_pending_light_hitbox_lunge_px = skill_lunge_px
	_pending_light_hitbox_range_tiles = skill_range_tiles
	_active_light_hitbox_id = StringName("%s_light" % String(_get_current_weapon_id()))
	_light_attack_chain_queued = false


func _on_core_light_attack_frame_advanced(combo_index: int, attack_frame: int) -> void:
	if _state != State.ATTACKING or combo_index != _active_light_attack_stage:
		return
	var frame_data: Dictionary = _combat.get_light_attack_frame_data(combo_index)
	var active_start_frame: int = int(frame_data.get("startup_frames", 0))
	var active_frames: int = int(frame_data.get("active_frames", 0))
	var active_end_frame: int = active_start_frame + active_frames
	if attack_frame == active_start_frame and _pending_light_hitbox_stage == combo_index:
		_sync_light_attack_contact_visual()
		_activate_pending_light_attack_hitbox(active_frames)
	if attack_frame == active_end_frame:
		_sync_light_attack_recovery_visual()
	if attack_frame >= active_end_frame:
		_set_hitbox_shape_disabled(true)
	if attack_frame >= active_end_frame and _light_attack_chain_queued:
		_commit_queued_light_attack(combo_index)


func _activate_pending_light_attack_hitbox(active_frames: int) -> void:
	var activated: bool = _activate_weapon_hitbox(
		_pending_light_hitbox_stage,
		active_frames,
		_pending_light_hitbox_lunge_px,
		_pending_light_hitbox_range_tiles
	)
	_pending_light_hitbox_stage = -1
	_pending_light_hitbox_lunge_px = 0.0
	_pending_light_hitbox_range_tiles = 0.0
	if activated:
		_set_hitbox_shape_disabled(false)


func _sync_light_attack_contact_visual() -> void:
	if _sprite == null or _sprite.sprite_frames == null:
		return
	if _sprite.animation != _active_attack_animation:
		return
	if (
		_sprite.sprite_frames.get_frame_count(_sprite.animation)
		<= LIGHT_ATTACK_CONTACT_VISUAL_FRAME
	):
		return
	_sprite.frame = LIGHT_ATTACK_CONTACT_VISUAL_FRAME
	_sprite.frame_progress = 0.0


func _sync_light_attack_recovery_visual() -> void:
	if _sprite == null or _sprite.sprite_frames == null:
		return
	if _sprite.animation != _active_attack_animation:
		return
	var recovery_frame: int = LIGHT_ATTACK_CONTACT_VISUAL_FRAME + 1
	if _sprite.sprite_frames.get_frame_count(_sprite.animation) <= recovery_frame:
		return
	_sprite.frame = recovery_frame
	_sprite.frame_progress = 0.0


func _commit_queued_light_attack(previous_stage: int) -> void:
	_light_attack_chain_queued = false
	_combat.on_action_triggered(&"attack", {})
	if (
		_combat.get_combo_index() != previous_stage + 1
		or _combat.get_attack_frame() != 0
	):
		return
	_request_light_attack_stage(_combat.get_combo_index(), true)


func _is_light_attack_active_window() -> bool:
	if _combat == null or _active_light_attack_stage < 0:
		return false
	var frame_data: Dictionary = _combat.get_light_attack_frame_data(
		_active_light_attack_stage
	)
	var active_start_frame: int = int(frame_data.get("startup_frames", 0))
	var active_end_frame: int = (
		active_start_frame + int(frame_data.get("active_frames", 0))
	)
	var attack_frame: int = _combat.get_attack_frame()
	return attack_frame >= active_start_frame and attack_frame < active_end_frame


func _clear_light_attack_hitbox_timing() -> void:
	if _collision != null and not String(_active_light_hitbox_id).is_empty():
		_collision.deactivate_hitbox(_active_light_hitbox_id)
	_pending_light_hitbox_stage = -1
	_pending_light_hitbox_lunge_px = 0.0
	_pending_light_hitbox_range_tiles = 0.0
	_active_light_hitbox_id = &""
	_light_attack_chain_queued = false
	_set_hitbox_shape_disabled(true)


func _build_attack_started_metadata(combo_index: int) -> Dictionary:
	return {
		"weapon_id": _get_current_weapon_id(),
		"attack_type": &"light",
		"combo_index": combo_index,
		"attack_position": global_position + Vector2(_facing * 34.0, -24.0),
		"facing": _facing,
		"skill_lunge_px": _last_skill_lunge_px,
	}


func _get_current_weapon_id() -> StringName:
	if _weapon_component == null or not _weapon_component.has_method("get_current_weapon"):
		return &"cat_claw"
	var weapon: Resource = _weapon_component.call("get_current_weapon")
	if weapon == null:
		return &"cat_claw"
	var weapon_id: Variant = weapon.get("weapon_id")
	if weapon_id == null:
		return &"cat_claw"
	return StringName(String(weapon_id))


func _update_attack_visual() -> void:
	# Flash hitbox area red during active frames
	if _attack_timer > 2:
		_sprite.modulate = ATTACK_MODULATE
	else:
		_sprite.modulate = NORMAL_MODULATE


func _on_attack_hit_body(body: Node2D) -> void:
	if _combat != null:
		return
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

## Requests a player dodge through the presentation-aware runtime controller.
func request_dodge() -> bool:
	if _control_locked or _state not in [State.IDLE, State.CHARGING] or _dodge_cooldown_timer > 0:
		return false
	var canceled_heavy_charge: bool = _state == State.CHARGING
	if _combat != null:
		_combat.on_action_triggered(&"dodge", {})
		if _combat.get_current_state() != CombatComponent.CombatState.DODGING:
			return false
	if canceled_heavy_charge:
		_reset_heavy_charge_presentation()
	_start_dodge()
	return true


func _start_dodge() -> void:
	_state = State.DODGING
	_dodge_timer = DODGE_DURATION_FRAMES
	_dodge_cooldown_timer = DODGE_COOLDOWN_FRAMES
	_sprite.modulate = Color(1.0, 1.0, 1.0, 0.45)
	_play_character_animation(ANIMATION_DODGE, true)
	dodge_started.emit(_get_current_sprite_texture(), _sprite.global_position, _facing)


func _start_ground_jump() -> void:
	velocity.y = JUMP_VELOCITY
	_jump_buffer_timer = 0
	_coyote_timer = 0
	set_airborne(true)
	_play_character_animation(ANIMATION_JUMP, true)


## Unlocks a player ability. Returns false when the ability is already unlocked.
func unlock_ability(ability_id: StringName) -> bool:
	_ensure_ability_component()
	if _ability == null:
		return false
	return _ability.unlock_ability(ability_id)


## Replaces unlock state while preserving start-of-game abilities.
func set_unlocked_abilities(ability_ids: Array) -> void:
	_ensure_ability_component()
	if _ability != null:
		_ability.set_unlocked_abilities(ability_ids)
		if not _ability.has_ability(ABILITY_WALL_CLIMB):
			_stop_wall_climb()


func has_ability(ability_id: StringName) -> bool:
	_ensure_ability_component()
	return _ability != null and _ability.has_ability(ability_id)


func get_unlocked_abilities() -> Array[StringName]:
	_ensure_ability_component()
	return _ability.get_unlocked_abilities() if _ability != null else []


func is_ability_on_cooldown(ability_id: StringName) -> bool:
	_ensure_ability_component()
	return _ability != null and _ability.is_ability_on_cooldown(ability_id)


func get_ability_cooldown_remaining(ability_id: StringName) -> float:
	_ensure_ability_component()
	return _ability.get_ability_cooldown_remaining(ability_id) if _ability != null else 0.0


func advance_ability_cooldowns(delta_sec: float) -> void:
	_ensure_ability_component()
	if _ability != null:
		_ability.advance_time(delta_sec)


## Updates the AbilityComponent airborne state used by air-count abilities.
func set_airborne(is_in_air: bool) -> void:
	_is_airborne_state = is_in_air
	_ensure_ability_component()
	if _ability != null:
		_ability.set_airborne(is_in_air)


## Clears air-count ability usage, matching the landing reset contract.
func reset_air_abilities() -> void:
	set_airborne(false)


## Requests a dash movement burst if the ability is unlocked and ready.
func request_dash() -> bool:
	if _control_locked or _state != State.IDLE:
		return false
	_ensure_ability_component()
	if _ability == null or not _ability.try_activate_ability(ABILITY_DASH):
		return false
	_start_dash()
	return true


func _start_dash() -> void:
	_state = State.DASHING
	_dash_timer = DASH_DURATION_FRAMES
	velocity.x = _facing * DASH_SPEED
	_sprite.modulate = Color(0.75, 0.95, 1.0, 0.58)
	_play_character_animation(ANIMATION_DASH, true)
	dash_started.emit(_get_current_sprite_texture(), _sprite.global_position, _facing)


## Requests an unlocked double jump while airborne and consumes its air count.
func request_double_jump() -> bool:
	if _control_locked or _state != State.IDLE:
		return false
	_ensure_ability_component()
	if _ability == null:
		return false
	if not _ability.try_activate_ability(ABILITY_DOUBLE_JUMP):
		return false
	velocity.y = JUMP_VELOCITY * DOUBLE_JUMP_HEIGHT_RATIO
	_jump_buffer_timer = 0
	_coyote_timer = 0
	_play_timed_character_animation(ANIMATION_JUMP, DOUBLE_JUMP_ANIMATION_LOCK_FRAMES)
	double_jump_started.emit(_get_current_sprite_texture(), _sprite.global_position, _facing)
	return true


## Starts or advances wall movement from a valid horizontal wall contact.
func request_wall_climb(
	wall_normal: Vector2,
	vertical_input: float,
	holding_toward_wall: bool = true
) -> bool:
	if (
		_control_locked
		or is_on_floor()
		or not holding_toward_wall
		or absf(wall_normal.x) < WALL_NORMAL_X_MIN
		or _state not in [State.IDLE, State.WALL_CLIMBING]
	):
		return false
	var starting_climb: bool = _state != State.WALL_CLIMBING
	if starting_climb and _wall_regrab_lock_frames > 0:
		return false
	_ensure_ability_component()
	if _ability == null or not _ability.has_ability(ABILITY_WALL_CLIMB):
		return false
	if starting_climb:
		if _combat != null and _combat.get_current_state() != CombatComponent.CombatState.IDLE:
			return false
		if not _ability.try_activate_ability(ABILITY_WALL_CLIMB):
			return false
	var tuning: Dictionary = _ability.get_ability_config(ABILITY_WALL_CLIMB)
	var climb_speed: float = float(tuning.get("climb_speed_px_sec", 0.0))
	var slide_speed: float = float(tuning.get("wall_slide_speed_px_sec", 0.0))
	if climb_speed <= 0.0 or slide_speed < 0.0:
		return false
	_wall_normal = wall_normal.normalized()
	_state = State.WALL_CLIMBING
	_facing = -signf(_wall_normal.x)
	velocity.x = -_wall_normal.x * WALL_CONTACT_HOLD_SPEED
	if vertical_input < -WALL_INPUT_EPSILON:
		velocity.y = -climb_speed
	elif vertical_input > WALL_INPUT_EPSILON:
		velocity.y = climb_speed
	else:
		velocity.y = slide_speed
	_play_character_animation(ANIMATION_WALL_CLIMB, starting_climb)
	if starting_climb:
		wall_climb_started.emit(
			_get_current_sprite_texture(),
			_sprite.global_position,
			_wall_normal
		)
	return true


## Jumps away from the current wall and starts the configured regrab lock.
func request_wall_jump() -> bool:
	if _control_locked or _state != State.WALL_CLIMBING:
		return false
	_ensure_ability_component()
	if _ability == null:
		return false
	var tuning: Dictionary = _ability.get_ability_config(ABILITY_WALL_CLIMB)
	var horizontal_speed: float = float(tuning.get(
		"wall_jump_horizontal_speed_px_sec",
		0.0
	))
	var vertical_speed: float = float(tuning.get(
		"wall_jump_vertical_speed_px_sec",
		0.0
	))
	var regrab_frames: int = maxi(0, int(tuning.get(
		"wall_regrab_lock_frames",
		0
	)))
	if horizontal_speed <= 0.0 or vertical_speed <= 0.0:
		return false
	var jump_normal: Vector2 = _wall_normal
	_state = State.IDLE
	_wall_normal = Vector2.ZERO
	_wall_regrab_lock_frames = regrab_frames
	_facing = signf(jump_normal.x)
	velocity = Vector2(
		jump_normal.x * horizontal_speed,
		-vertical_speed
	)
	set_airborne(true)
	_play_character_animation(ANIMATION_JUMP, true)
	wall_jump_started.emit(_sprite.global_position, jump_normal)
	return true


## Clears the short post-jump wall regrab lock, including on landing/respawn.
func clear_wall_climb_regrab_lock() -> void:
	_wall_regrab_lock_frames = 0


## Returns wall movement state and resolved data tuning for tests and MCP.
func get_wall_climb_diagnostics() -> Dictionary:
	_ensure_ability_component()
	var tuning: Dictionary = (
		_ability.get_ability_config(ABILITY_WALL_CLIMB)
		if _ability != null
		else {}
	)
	return {
		"active": _state == State.WALL_CLIMBING,
		"animation": String(_sprite.animation) if _sprite != null else "",
		"wall_normal": _wall_normal,
		"velocity": velocity,
		"regrab_lock_frames": _wall_regrab_lock_frames,
		"climb_speed_px_sec": float(tuning.get("climb_speed_px_sec", 0.0)),
		"wall_slide_speed_px_sec": float(tuning.get(
			"wall_slide_speed_px_sec",
			0.0
		)),
		"wall_jump_horizontal_speed_px_sec": float(tuning.get(
			"wall_jump_horizontal_speed_px_sec",
			0.0
		)),
		"wall_jump_vertical_speed_px_sec": float(tuning.get(
			"wall_jump_vertical_speed_px_sec",
			0.0
		)),
	}


## Requests a player parry through AbilityComponent cooldowns and Core combat timing.
func request_parry() -> bool:
	if _control_locked or _state != State.IDLE:
		return false
	_ensure_ability_component()
	if _combat != null and _combat.get_current_state() != CombatComponent.CombatState.IDLE:
		return false
	if _ability == null or not _ability.try_activate_ability(ABILITY_PARRY):
		return false
	if _combat != null:
		_combat.on_action_triggered(&"parry", {})
		if _combat.get_current_state() != CombatComponent.CombatState.PARRYING:
			return false
	_start_parry()
	return true


func _start_parry() -> void:
	_state = State.PARRYING
	_parry_timer = PARRY_DURATION_FRAMES
	_sprite.modulate = Color(0.72, 0.95, 1.0, 0.82)
	_play_character_animation(ANIMATION_PARRY, true)


func _stop_wall_climb() -> void:
	if _state != State.WALL_CLIMBING:
		return
	_state = State.IDLE
	_wall_normal = Vector2.ZERO


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
	apply_damage(CONTACT_DAMAGE, {
		"source": &"shadow_beast",
		"damage_type": &"contact",
	})


## Applies resolved combat damage from Core enemy hit confirmations.
func apply_damage(final_damage: int, metadata: Dictionary = {}) -> void:
	if _control_locked:
		return
	if _state == State.DASHING or is_dodge_iframe_active():
		return  # Dash and Core dodge i-frames ignore incoming damage.
	if final_damage <= 0:
		return
	if _try_resolve_incoming_parry(metadata):
		return
	_stop_wall_climb()
	_sprite.modulate = DAMAGE_MODULATE
	var hp_before: int = _health.get_current_hp()
	_health.apply_damage(final_damage, metadata)
	var hp_after: int = _health.get_current_hp()
	if hp_after > 0 and hp_after < hp_before:
		if _combat != null:
			_combat.on_damage_taken(hp_before - hp_after)
		_reset_heavy_charge_presentation()
		_play_timed_character_animation(ANIMATION_HURT, HURT_ANIMATION_LOCK_FRAMES)


func _try_resolve_incoming_parry(metadata: Dictionary) -> bool:
	if (
		_state != State.PARRYING
		or _combat == null
		or _combat.get_current_state() != CombatComponent.CombatState.PARRYING
		or int(metadata.get("attacker_id", -1)) <= 0
	):
		return false
	var parry_result: Dictionary = _combat.resolve_parry_result()
	if not bool(parry_result.get("is_success", false)):
		return false
	_parry_timer = 0
	_start_parry_counter_visual(parry_result)
	return true


func _start_parry_counter_visual(parry_result: Dictionary) -> void:
	_state = State.ATTACKING
	_attack_timer = ATTACK_DURATION_FRAMES
	_active_attack_animation = ANIMATION_ATTACK
	_active_light_attack_stage = -1
	_set_hitbox_shape_disabled(true)
	_sprite.modulate = NORMAL_MODULATE
	_play_character_animation(ANIMATION_ATTACK, true)
	var attack_data: Dictionary = _build_attack_started_metadata(0)
	attack_data["attack_type"] = &"parry"
	attack_data["parry_type"] = parry_result.get("parry_type", &"miss")
	attack_data["parry_frame"] = int(parry_result.get("parry_frame", -1))
	attack_started.emit(attack_data)


func get_current_hp() -> int:
	return _health.get_current_hp()


func get_max_hp() -> int:
	return _health.get_max_hp()


## Restores full health and shield through the shared savepoint health contract.
func restore_at_savepoint() -> void:
	_health.restore_at_savepoint()
	_sprite.modulate = NORMAL_MODULATE


## Returns the runtime CombatComponent used by the playable attack chain.
func get_combat_component() -> CombatComponent:
	return _combat


## Returns the runtime CollisionComponent used by combat hitboxes and hurtbox state.
func get_collision_component() -> CollisionComponent:
	return _collision


## Returns synchronized light-combo state for tests and MCP runtime inspection.
func get_light_combo_diagnostics() -> Dictionary:
	var combo_index: int = _combat.get_combo_index() if _combat != null else 0
	var frame_data: Dictionary = (
		_combat.get_light_attack_frame_data(combo_index)
		if _combat != null
		else {}
	)
	return {
		"active": _state == State.ATTACKING and _active_light_attack_stage >= 0,
		"combo_index": combo_index,
		"attack_frame": _combat.get_attack_frame() if _combat != null else 0,
		"remaining_frames": _attack_timer,
		"startup_frames": int(frame_data.get("startup_frames", 0)),
		"hitbox_active_start_frame": int(frame_data.get("startup_frames", 0)),
		"hitbox_active_frames": int(frame_data.get("active_frames", 0)),
		"hitbox_active_end_frame": (
			int(frame_data.get("startup_frames", 0))
			+ int(frame_data.get("active_frames", 0))
		),
		"hitbox_id": String(_active_light_hitbox_id),
		"hitbox_pending": _pending_light_hitbox_stage >= 0,
		"hitbox_active": (
			_collision != null
			and not String(_active_light_hitbox_id).is_empty()
			and _collision.is_hitbox_active(_active_light_hitbox_id)
		),
		"chain_queued": _light_attack_chain_queued,
		"recovery_frames": int(frame_data.get("recovery_frames", 0)),
		"total_frames": int(frame_data.get("total_frames", 0)),
		"is_recovery": _combat.is_in_attack_recovery() if _combat != null else false,
		"animation": String(_sprite.animation) if _sprite != null else "",
		"animation_frame": _sprite.frame if _sprite != null else -1,
	}


## Returns true while the Core combat dodge i-frame window is active.
func is_dodge_iframe_active() -> bool:
	return _combat != null and _combat.is_dodge_iframe_active()


## Returns remaining Cat Claw dodge-counter frames from Core combat.
func get_dodge_counter_window() -> int:
	return _combat.get_dodge_counter_window() if _combat != null else 0


## Injects the active weapon component used to activate attack hitboxes.
func set_weapon_component(weapon_component: Object) -> void:
	_weapon_component = weapon_component


## Injects the target adapter that receives resolved player attack damage.
func set_target_health_adapter(target_health_adapter: Object) -> void:
	if _combat == null:
		return
	_combat.set_health_adapter(target_health_adapter)


## Injects the runtime damage adapter used by CombatComponent.
func set_damage_calculator_adapter(damage_calculator_adapter: Object) -> void:
	_damage_calculator_adapter = damage_calculator_adapter
	if _combat != null:
		_combat.set_damage_calculator_adapter(_damage_calculator_adapter)


## Injects a scene-level skill modifier provider.
func set_skill_modifier_provider(skill_modifier_provider: Object) -> void:
	_skill_modifier_provider = skill_modifier_provider


## Returns the most recent skill-driven attack lunge distance in pixels.
func get_last_skill_lunge_px() -> float:
	return _last_skill_lunge_px


## Returns the most recent skill-driven attack range bonus in combat tiles.
func get_last_skill_range_tiles() -> float:
	return _last_skill_range_tiles


## Returns deterministic aerial state for tests and MCP runtime inspection.
func get_aerial_attack_diagnostics() -> Dictionary:
	return {
		"active": _state == State.AERIAL_ATTACKING,
		"animation": String(_sprite.animation) if _sprite != null else "",
		"hitbox_id": StringName("%s_aerial" % String(_get_current_weapon_id())),
		"remaining_frames": _aerial_attack_timer,
		"velocity": velocity,
		"bounce_consumed": _aerial_bounce_consumed,
		"air_jump_restored": _aerial_air_jump_restored,
		"last_attack_metadata": _last_aerial_attack_metadata.duplicate(true),
	}


func set_control_locked(locked: bool) -> void:
	_control_locked = locked
	if locked:
		_clear_light_attack_hitbox_timing()
		_reset_heavy_charge_presentation(true)
		_stop_wall_climb()
		velocity = Vector2.ZERO
		_set_hitbox_shape_disabled(true)
		_parry_timer = 0
		_aerial_attack_timer = 0


func respawn_at(respawn_position: Vector2, revive_hp_percentage: float) -> void:
	_clear_light_attack_hitbox_timing()
	_reset_heavy_charge_presentation(true)
	global_position = respawn_position
	velocity = Vector2.ZERO
	_state = State.IDLE
	_attack_timer = 0
	_dodge_timer = 0
	_dodge_cooldown_timer = 0
	_dash_timer = 0
	_parry_timer = 0
	_aerial_attack_timer = 0
	_aerial_bounce_consumed = false
	_aerial_air_jump_restored = false
	_last_aerial_attack_metadata.clear()
	_last_heavy_attack_metadata.clear()
	_active_attack_animation = ANIMATION_ATTACK
	_active_light_attack_stage = -1
	_wall_normal = Vector2.ZERO
	_wall_regrab_lock_frames = 0
	advance_ability_cooldowns(999.0)
	reset_air_abilities()
	_jump_buffer_timer = 0
	_coyote_timer = 0
	_set_hitbox_shape_disabled(true)
	_sprite.modulate = NORMAL_MODULATE
	_health.revive(revive_hp_percentage)
	if _collision != null:
		_collision.set_hurtbox_state(CollisionComponent.HURTBOX_STATE_NORMAL)
	_health.grant_iframes(RESPAWN_INVINCIBILITY_FRAMES)
	_start_respawn_visual_feedback()
	_play_timed_character_animation(ANIMATION_REVIVE, REVIVE_ANIMATION_LOCK_FRAMES)


## Returns true while the respawn invincibility visual feedback is active.
func is_respawn_visual_active() -> bool:
	return _respawn_visual_remaining_frames > 0


func _set_hitbox_shape_disabled(disabled: bool) -> void:
	if _hitbox_shape == null:
		return
	if _hitbox_shape.disabled == disabled:
		return
	if _hitbox_shape.is_inside_tree() and Engine.is_in_physics_frame():
		_hitbox_shape.set_deferred("disabled", disabled)
	else:
		_hitbox_shape.disabled = disabled


## Returns remaining respawn feedback frames for flow-alignment tests.
func get_respawn_visual_remaining_frames() -> int:
	return _respawn_visual_remaining_frames


func _on_health_changed(_entity_id: int, current_hp: int, max_hp: int) -> void:
	player_health_changed.emit(current_hp, max_hp)


func _on_death(_entity_id: int, metadata: Dictionary) -> void:
	_clear_light_attack_hitbox_timing()
	_reset_heavy_charge_presentation(true)
	_stop_wall_climb()
	_play_timed_character_animation(ANIMATION_DEATH, DEATH_ANIMATION_LOCK_FRAMES)
	player_died.emit(metadata.duplicate(true))


func _ensure_core_components() -> void:
	_combat = get_node_or_null("CombatComponent") as CombatComponent
	if _combat == null:
		_combat = COMBAT_COMPONENT_SCRIPT.new() as CombatComponent
		_combat.name = "CombatComponent"
		add_child(_combat)
	_combat.process_physics_priority = COMBAT_PROCESS_PHYSICS_PRIORITY
	_collision = get_node_or_null("CollisionComponent") as CollisionComponent
	if _collision == null:
		_collision = COLLISION_COMPONENT_SCRIPT.new() as CollisionComponent
		_collision.name = "CollisionComponent"
		add_child(_collision)
	_collision.process_physics_priority = COLLISION_PROCESS_PHYSICS_PRIORITY
	_ensure_ability_component()


func _setup_core_combat_chain() -> void:
	if _collision != null:
		_collision.configure_entity(PLAYER_ENTITY_ID, &"player")
		_collision.set_hurtbox_size(PLAYER_HURTBOX_SIZE)
		_collision.set_health_adapter(_health)
	if _combat != null:
		_combat.set_collision_adapter(_collision)
		_combat.set_hurtbox_adapter(_collision)
		if _damage_calculator_adapter != null:
			_combat.set_damage_calculator_adapter(_damage_calculator_adapter)
		if not _combat.on_attack_hit.is_connected(_on_core_attack_hit):
			_combat.on_attack_hit.connect(_on_core_attack_hit)
		if not _combat.on_light_attack_frame_advanced.is_connected(
			_on_core_light_attack_frame_advanced
		):
			_combat.on_light_attack_frame_advanced.connect(
				_on_core_light_attack_frame_advanced
			)
		if not _combat.on_heavy_attack_released.is_connected(_on_core_heavy_attack_released):
			_combat.on_heavy_attack_released.connect(_on_core_heavy_attack_released)
	if not _health.on_focus_mode_changed.is_connected(_combat.on_focus_mode_changed):
		_health.on_focus_mode_changed.connect(_combat.on_focus_mode_changed)


func _on_core_attack_hit(metadata: Dictionary) -> void:
	if (
		StringName(metadata.get("attack_type", &"")) == &"aerial"
		and not _aerial_bounce_consumed
	):
		_resolve_aerial_attack_bounce(metadata)
	attack_landed.emit(metadata.duplicate(true))


func _resolve_aerial_attack_bounce(metadata: Dictionary) -> void:
	_aerial_bounce_consumed = true
	_aerial_attack_timer = 0
	_state = State.IDLE
	velocity.y = AERIAL_ATTACK_BOUNCE_VELOCITY
	if _ability != null:
		_aerial_air_jump_restored = _ability.restore_air_ability_use(ABILITY_DOUBLE_JUMP)
	var bounce_metadata: Dictionary = metadata.duplicate(true)
	bounce_metadata["restore_jump"] = _aerial_air_jump_restored
	bounce_metadata["bounce_velocity"] = AERIAL_ATTACK_BOUNCE_VELOCITY
	_last_aerial_attack_metadata = bounce_metadata.duplicate(true)
	_play_timed_character_animation(ANIMATION_JUMP, DOUBLE_JUMP_ANIMATION_LOCK_FRAMES)
	aerial_attack_bounced.emit(bounce_metadata)


func _resolve_skill_lunge_px(combo_index: int) -> float:
	_last_skill_lunge_px = 0.0
	if _skill_modifier_provider == null or not _skill_modifier_provider.has_method("get_modifiers"):
		return 0.0
	var target_action: StringName = StringName("light_attack_%d" % (combo_index + 1))
	var modifiers: Variant = _skill_modifier_provider.call("get_modifiers", target_action)
	if not modifiers is Array:
		return 0.0
	var modifier_list: Array = modifiers as Array
	for raw_modifier: Variant in modifier_list:
		if not raw_modifier is Dictionary:
			continue
		var modifier: Dictionary = raw_modifier as Dictionary
		if not _is_modifier_for_current_weapon(modifier):
			continue
		if StringName(String(modifier.get("operation", ""))) != &"ADD":
			continue
		if StringName(String(modifier.get("stat_key", ""))) != &"dash_distance":
			continue
		_last_skill_lunge_px += maxf(0.0, float(modifier.get("value", 0.0)))
	return _last_skill_lunge_px


func _resolve_skill_range_tiles(combo_index: int) -> float:
	_last_skill_range_tiles = 0.0
	if _skill_modifier_provider == null or not _skill_modifier_provider.has_method("get_modifiers"):
		return 0.0
	var target_action: StringName = StringName("light_attack_%d" % (combo_index + 1))
	var modifiers: Variant = _skill_modifier_provider.call("get_modifiers", target_action)
	if not modifiers is Array:
		return 0.0
	for raw_modifier: Variant in modifiers as Array:
		if not raw_modifier is Dictionary:
			continue
		var modifier: Dictionary = raw_modifier as Dictionary
		if not _is_modifier_for_current_weapon(modifier):
			continue
		if StringName(String(modifier.get("operation", ""))) != &"ADD":
			continue
		if StringName(String(modifier.get("stat_key", ""))) != &"attack_range":
			continue
		_last_skill_range_tiles += maxf(0.0, float(modifier.get("value", 0.0)))
	return _last_skill_range_tiles


func _resolve_skill_slow_pulse(combo_index: int) -> Dictionary:
	if _skill_modifier_provider == null or not _skill_modifier_provider.has_method("get_modifiers"):
		return {}
	var target_action: StringName = StringName("light_attack_%d" % (combo_index + 1))
	var modifiers: Variant = _skill_modifier_provider.call("get_modifiers", target_action)
	if not modifiers is Array:
		return {}
	for raw_modifier: Variant in modifiers as Array:
		if not raw_modifier is Dictionary:
			continue
		var modifier: Dictionary = raw_modifier as Dictionary
		if not _is_modifier_for_current_weapon(modifier):
			continue
		if StringName(String(modifier.get("operation", ""))) != &"ADD":
			continue
		if StringName(String(modifier.get("stat_key", ""))) != &"slow_percentage":
			continue
		var bonus_percentage: float = maxf(0.0, float(modifier.get("value", 0.0)))
		var duration_sec: float = maxf(0.0, float(modifier.get("duration_sec", 0.0)))
		if bonus_percentage <= 0.0 or duration_sec <= 0.0:
			continue
		return {
			"skill_id": StringName(String(modifier.get("skill_id", ""))),
			"bonus_percentage": bonus_percentage,
			"duration_sec": duration_sec,
		}
	return {}


func _resolve_skill_knockback_px() -> float:
	if _skill_modifier_provider == null or not _skill_modifier_provider.has_method("get_modifiers"):
		return 0.0
	var modifiers: Variant = _skill_modifier_provider.call("get_modifiers", &"heavy_attack")
	if not modifiers is Array:
		return 0.0
	var knockback_px: float = 0.0
	for raw_modifier: Variant in modifiers as Array:
		if not raw_modifier is Dictionary:
			continue
		var modifier: Dictionary = raw_modifier as Dictionary
		if not _is_modifier_for_current_weapon(modifier):
			continue
		if StringName(String(modifier.get("operation", ""))) != &"ADD":
			continue
		if StringName(String(modifier.get("stat_key", ""))) != &"knockback_distance":
			continue
		knockback_px += maxf(0.0, float(modifier.get("value", 0.0)))
	return knockback_px


func _build_skill_damage_modifiers() -> Dictionary:
	var damage_bonus: float = _resolve_skill_damage_bonus()
	return {"skill_damage_bonus": damage_bonus} if damage_bonus > 0.0 else {}


func _resolve_skill_damage_bonus() -> float:
	if _skill_modifier_provider == null or not _skill_modifier_provider.has_method("get_modifiers"):
		return 0.0
	var modifiers: Variant = _skill_modifier_provider.call("get_modifiers")
	if not modifiers is Array:
		return 0.0
	var damage_bonus: float = 0.0
	for raw_modifier: Variant in modifiers as Array:
		if not raw_modifier is Dictionary:
			continue
		var modifier: Dictionary = raw_modifier as Dictionary
		if not _is_modifier_for_current_weapon(modifier):
			continue
		if StringName(String(modifier.get("operation", ""))) != &"ADD":
			continue
		if StringName(String(modifier.get("stat_key", ""))) != &"damage":
			continue
		damage_bonus += maxf(0.0, float(modifier.get("value", 0.0)))
	return clampf(damage_bonus, 0.0, SKILL_DAMAGE_BONUS_CAP)


func _is_modifier_for_current_weapon(modifier: Dictionary) -> bool:
	var condition: Dictionary = Dictionary(modifier.get("condition", {}))
	var weapon_condition: StringName = StringName(String(condition.get("weapon", "")))
	return weapon_condition == &"" or weapon_condition == _get_current_weapon_id()


func _apply_skill_lunge(skill_lunge_px: float) -> void:
	if skill_lunge_px <= 0.0:
		return
	global_position.x += _facing * skill_lunge_px


func _start_respawn_visual_feedback() -> void:
	_respawn_visual_remaining_frames = RESPAWN_INVINCIBILITY_FRAMES
	_respawn_visual_elapsed_frames = 0
	_apply_respawn_visual_alpha()


func _advance_respawn_visual() -> void:
	if _respawn_visual_remaining_frames <= 0:
		return
	_respawn_visual_remaining_frames -= 1
	_respawn_visual_elapsed_frames += 1
	if _respawn_visual_remaining_frames <= 0:
		_set_sprite_alpha(1.0)
		return
	_apply_respawn_visual_alpha()


func _apply_respawn_visual_alpha() -> void:
	var flash_step: int = floori(float(_respawn_visual_elapsed_frames) / float(RESPAWN_FLASH_INTERVAL_FRAMES))
	var alpha: float = RESPAWN_FLASH_DIM_ALPHA
	if flash_step % 2 == 1:
		alpha = RESPAWN_FLASH_BRIGHT_ALPHA
	_set_sprite_alpha(alpha)


func _set_sprite_alpha(alpha: float) -> void:
	var current_modulate: Color = _sprite.modulate
	current_modulate.a = clampf(alpha, 0.0, 1.0)
	_sprite.modulate = current_modulate


func _update_character_animation() -> void:
	if _presentation_animation_lock_frames > 0:
		_presentation_animation_lock_frames -= 1
		return
	if _state == State.ATTACKING:
		if _sprite.animation != _active_attack_animation:
			_play_character_animation(_active_attack_animation, true)
			_sprite.pause()
		return
	if _state == State.CHARGING:
		_play_character_animation(ANIMATION_HEAVY_CHARGE)
		return
	if _state == State.DODGING:
		_play_character_animation(ANIMATION_DODGE)
		return
	if _state == State.DASHING:
		_play_character_animation(ANIMATION_DASH)
		return
	if _state == State.PARRYING:
		_play_character_animation(ANIMATION_PARRY)
		return
	if _state == State.AERIAL_ATTACKING:
		_play_character_animation(ANIMATION_AERIAL_ATTACK)
		return
	if _state == State.WALL_CLIMBING:
		_play_character_animation(ANIMATION_WALL_CLIMB)
		return
	_play_character_animation(_get_locomotion_animation(is_on_floor(), velocity))


func _get_locomotion_animation(is_grounded: bool, current_velocity: Vector2) -> StringName:
	if current_velocity.y < 0.0:
		return ANIMATION_JUMP
	if not is_grounded:
		return ANIMATION_FALL
	if absf(current_velocity.x) > RUN_ANIMATION_MIN_SPEED:
		return ANIMATION_RUN
	return ANIMATION_IDLE


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


func _play_timed_character_animation(animation_name: StringName, lock_frames: int) -> void:
	_presentation_animation_lock_frames = maxi(lock_frames, 0)
	_play_character_animation(animation_name, true)


func _get_current_sprite_texture() -> Texture2D:
	if _sprite == null or _sprite.sprite_frames == null:
		return null
	if not _sprite.sprite_frames.has_animation(_sprite.animation):
		return null
	var frame_count: int = _sprite.sprite_frames.get_frame_count(_sprite.animation)
	if frame_count <= 0:
		return null
	var frame_index: int = clampi(_sprite.frame, 0, frame_count - 1)
	return _sprite.sprite_frames.get_frame_texture(_sprite.animation, frame_index)


func _ensure_ability_component() -> void:
	if _ability != null and is_instance_valid(_ability):
		return
	_ability = get_node_or_null("AbilityComponent") as AbilityComponent
	if _ability == null:
		_ability = ABILITY_COMPONENT_SCRIPT.new() as AbilityComponent
		_ability.name = "AbilityComponent"
		add_child(_ability)
	if not _ability.ability_unlocked.is_connected(_on_ability_unlocked):
		_ability.ability_unlocked.connect(_on_ability_unlocked)
	if not _ability.ability_activated.is_connected(_on_ability_activated):
		_ability.ability_activated.connect(_on_ability_activated)


func _on_ability_unlocked(ability_id: StringName) -> void:
	ability_unlocked.emit(ability_id)


func _on_ability_activated(ability_id: StringName) -> void:
	ability_activated.emit(ability_id)
