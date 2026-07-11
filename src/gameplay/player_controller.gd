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
const NORMAL_MODULATE: Color = Color.WHITE
const ATTACK_MODULATE: Color = Color(1.0, 0.55, 0.45, 1.0)
const DAMAGE_MODULATE: Color = Color(1.0, 0.25, 0.25, 1.0)
const ANIMATION_IDLE: StringName = &"idle"
const ANIMATION_RUN: StringName = &"run"
const ANIMATION_ATTACK: StringName = &"attack"
const ANIMATION_DODGE: StringName = &"dodge"
const ANIMATION_DASH: StringName = &"dash"
const ANIMATION_PARRY: StringName = &"parry"
const ANIMATION_HURT: StringName = &"hurt"
const ANIMATION_DEATH: StringName = &"death"
const ANIMATION_REVIVE: StringName = &"revive"
const ANIMATION_JUMP: StringName = &"jump"
const ANIMATION_FALL: StringName = &"fall"
const ANIMATION_AERIAL_ATTACK: StringName = &"aerial_attack"
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

# ---------------------------------------------------------------------------
# State
# ---------------------------------------------------------------------------

enum State { IDLE, ATTACKING, DODGING, DASHING, PARRYING, AERIAL_ATTACKING }

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

	# Update facing direction
	_update_facing()

	# Coyote time tracking
	if is_on_floor():
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
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * get_physics_process_delta_time())
		return

	var input_dir: float = Input.get_axis("move_left", "move_right")

	# Horizontal movement (disabled during attack/dodge)
	if (
		_state != State.ATTACKING
		and _state != State.DODGING
		and _state != State.DASHING
		and _state != State.PARRYING
		and _state != State.AERIAL_ATTACKING
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
	if _jump_buffer_timer > 0 and _state != State.DODGING:
		if _coyote_timer > 0:
			_start_ground_jump()
		elif request_double_jump():
			_jump_buffer_timer = 0

	# Attack
	if Input.is_action_just_pressed("attack") and _state == State.IDLE:
		request_attack()

	# Dodge
	if Input.is_action_just_pressed("dodge"):
		request_dodge()

	# Dash
	if Input.is_action_just_pressed("dash"):
		request_dash()

	# Parry
	if Input.is_action_just_pressed("parry"):
		request_parry()

# ---------------------------------------------------------------------------
# Physics Helpers
# ---------------------------------------------------------------------------

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
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
		var combo_index: int = _combat.get_combo_index() if _combat != null else 0
		return _request_light_attack_stage(combo_index, false)
	if _state == State.ATTACKING and _combat != null and _combat.is_in_attack_recovery():
		_combat.on_action_triggered(&"attack", {})
		return _request_light_attack_stage(_combat.get_combo_index(), true)
	return false


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
	var skill_lunge_px: float = _resolve_skill_lunge_px(combo_index)
	var core_hitbox_activated: bool = _activate_weapon_hitbox(combo_index, skill_lunge_px)
	if not core_hitbox_activated and _weapon_component != null:
		return false
	_apply_skill_lunge(skill_lunge_px)
	if _combat != null and not combat_already_advanced:
		_combat.on_action_triggered(&"attack", {"combo_index": combo_index})
	_start_attack_visual()
	attack_started.emit(_build_attack_started_metadata(combo_index))
	return true


func _start_attack_visual() -> void:
	_state = State.ATTACKING
	_attack_timer = ATTACK_DURATION_FRAMES
	_hitbox_shape.disabled = false
	# Position hitbox in front of player
	_hitbox_area.position.x = _facing * 20.0
	_play_character_animation(ANIMATION_ATTACK, true)


func _activate_weapon_hitbox(combo_index: int, skill_lunge_px: float = 0.0) -> bool:
	if _weapon_component == null or not _weapon_component.has_method("activate_current_attack_hitbox"):
		return false
	return bool(_weapon_component.call(
		"activate_current_attack_hitbox",
		&"light",
		ATTACK_DURATION_FRAMES,
		combo_index,
		{
			"skill_lunge_px": skill_lunge_px,
			"hitbox_offset_x": skill_lunge_px * _facing,
		}
	))


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
	if _control_locked or _state != State.IDLE or _dodge_cooldown_timer > 0:
		return false
	if _combat != null:
		_combat.on_action_triggered(&"dodge", {})
		if _combat.get_current_state() != CombatComponent.CombatState.DODGING:
			return false
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
	_sprite.modulate = DAMAGE_MODULATE
	var hp_before: int = _health.get_current_hp()
	_health.apply_damage(final_damage, metadata)
	var hp_after: int = _health.get_current_hp()
	if hp_after > 0 and hp_after < hp_before:
		_play_timed_character_animation(ANIMATION_HURT, HURT_ANIMATION_LOCK_FRAMES)


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
		velocity = Vector2.ZERO
		_set_hitbox_shape_disabled(true)
		_parry_timer = 0
		_aerial_attack_timer = 0


func respawn_at(respawn_position: Vector2, revive_hp_percentage: float) -> void:
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
	_play_timed_character_animation(ANIMATION_DEATH, DEATH_ANIMATION_LOCK_FRAMES)
	player_died.emit(metadata.duplicate(true))


func _ensure_core_components() -> void:
	_combat = get_node_or_null("CombatComponent") as CombatComponent
	if _combat == null:
		_combat = COMBAT_COMPONENT_SCRIPT.new() as CombatComponent
		_combat.name = "CombatComponent"
		add_child(_combat)
	_collision = get_node_or_null("CollisionComponent") as CollisionComponent
	if _collision == null:
		_collision = COLLISION_COMPONENT_SCRIPT.new() as CollisionComponent
		_collision.name = "CollisionComponent"
		add_child(_collision)
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
		_play_character_animation(ANIMATION_ATTACK)
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
