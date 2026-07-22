## Playable Boss3 with alternating pressure-lunge and pressure-geyser attacks.
class_name SluiceMatriarchBoss
extends CharacterBody2D

signal boss_health_changed(current_hp: int, max_hp: int)
signal boss_defeated
signal enemy_attack_landed(damage: int, hit_position: Vector2, is_crit: bool)
signal on_boss_phase_transition_started(entity_id: int, phase: int, metadata: Dictionary)

const ENTITY_ID: int = 2300
const BOSS_ID: StringName = &"boss_03_sluice_matriarch"
const DISPLAY_NAME: String = "Sluice Matriarch"
const MAX_HP: int = 120
const PHASE_ONE: int = 1
const PHASE_TWO: int = 2
const PHASE_TWO_HP_THRESHOLD: float = 0.5
const PHASE_TRANSITION_DURATION_SEC: float = 2.5
const PRESSURE_LUNGE_ID: StringName = &"pressure_lunge"
const PRESSURE_GEYSER_ID: StringName = &"pressure_geyser"
const ATTACK_PATTERN_IDS: Array[StringName] = [
	PRESSURE_LUNGE_ID,
	PRESSURE_GEYSER_ID,
]
const ATTACK_TELL_FRAMES: int = 18
const ATTACK_ACTIVE_FRAMES: int = 6
const ATTACK_RECOVERY_FRAMES: int = 18
const PHASE_ONE_GEYSER_TELL_FRAMES: int = 24
const PHASE_TWO_GEYSER_TELL_FRAMES: int = 18
const GEYSER_ACTIVE_FRAMES: int = 10
const PHASE_ONE_GEYSER_RECOVERY_FRAMES: int = 24
const PHASE_TWO_GEYSER_RECOVERY_FRAMES: int = 18
const PHASE_ONE_ATTACK_COOLDOWN_FRAMES: int = 42
const PHASE_TWO_ATTACK_COOLDOWN_FRAMES: int = 28
const ATTACK_COMMIT_RANGE_PX: float = 300.0
const PHASE_ONE_CHASE_SPEED_PX_SEC: float = 210.0
const PHASE_TWO_CHASE_SPEED_PX_SEC: float = 270.0
const PHASE_ONE_LUNGE_STEP_PX: float = 14.0
const PHASE_TWO_LUNGE_STEP_PX: float = 20.0
const ARENA_MIN_X: float = 320.0
const ARENA_MAX_X: float = 1160.0
const ARENA_VISIBLE_MIN_X: float = 40.0
const ARENA_VISIBLE_MAX_X: float = 1240.0
const ATTACK_HITBOX_ID: StringName = &"sluice_matriarch_pressure_lunge"
const ATTACK_HITBOX_SIZE: Vector2 = Vector2(138, 70)
const ATTACK_HITBOX_OFFSET: Vector2 = Vector2(112, -42)
const ATTACK_DAMAGE: int = 16
const GEYSER_HITBOX_ID: StringName = &"sluice_matriarch_pressure_geyser"
const GEYSER_HITBOX_SIZE: Vector2 = Vector2(144, 110)
const GEYSER_HITBOX_Y_OFFSET: float = -55.0
const GEYSER_WARNING_WIDTH_PX: float = 176.0
const GEYSER_TARGET_MIN_X: float = 128.0
const GEYSER_TARGET_MAX_X: float = 1152.0
const GEYSER_VISUAL_CENTER_Y: float = 496.0
const GEYSER_DAMAGE: int = 14
const ATTACK_HIT_FRAME: int = 99
const BOSS_HURTBOX_SIZE: Vector2 = Vector2(170, 76)
const HIT_FLASH_FRAMES: int = 5
const NORMAL_MODULATE: Color = Color.WHITE
const HIT_MODULATE: Color = Color(1.0, 0.84, 0.78, 1.0)
const PHASE_TWO_MODULATE: Color = Color(0.82, 1.0, 1.0, 1.0)
const ANIMATION_IDLE: StringName = &"idle"
const ANIMATION_RUN: StringName = &"run"
const ANIMATION_ATTACK_TELL: StringName = &"attack_tell"
const ANIMATION_ATTACK: StringName = &"attack"
const ANIMATION_GEYSER_TELL: StringName = &"geyser_tell"
const ANIMATION_GEYSER_ATTACK: StringName = &"geyser_attack"
const ANIMATION_ATTACK_RECOVERY: StringName = &"attack_recovery"
const ANIMATION_PHASE_TRANSITION: StringName = &"phase_transition"
const ANIMATION_HURT: StringName = &"hurt"
const ANIMATION_DEATH: StringName = &"death"
const HEALTH_COMPONENT_SCRIPT: Script = preload("res://src/core/health_component.gd")
const COLLISION_COMPONENT_SCRIPT: Script = preload("res://src/core/collision_component.gd")
const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")
const STATUS_EFFECT_COMPONENT_SCRIPT: Script = preload(
	"res://src/core/status_effect_component.gd"
)

enum State {
	IDLE,
	CHASE,
	HIT,
	ATTACK_TELL,
	ATTACK_ACTIVE,
	ATTACK_RECOVERY,
	PHASE_TRANSITION,
	DEAD,
}

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _geyser_sprite: AnimatedSprite2D = $PressureGeyser

var _state: State = State.IDLE
var _facing: float = -1.0
var _hit_timer: int = 0
var _attack_timer: int = 0
var _attack_cooldown_timer: int = 0
var _attack_sequence_id: int = 0
var _next_pattern_index: int = 0
var _current_pattern_id: StringName = &""
var _attack_history: Array[StringName] = []
var _geyser_target_x: float = 0.0
var _defeated: bool = false
var _current_phase: int = PHASE_ONE
var _phase_two_pending: bool = false
var _phase_transition_remaining_sec: float = 0.0
var _phase_transition_start_count: int = 0
var _last_phase_transition_metadata: Dictionary = {}
var _attack_target: Node = null
var _damage_calculator_adapter: Object = null
var _last_hit_metadata: Dictionary = {}
var _last_enemy_attack_metadata: Dictionary = {}
var _health: HealthComponent = null
var _collision: CollisionComponent = null
var _combat: CombatComponent = null
var _status_effects: StatusEffectComponent = null
var _default_collision_layer: int = 0
var _default_collision_mask: int = 0
var _arena_anchor_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	_default_collision_layer = collision_layer
	_default_collision_mask = collision_mask
	_arena_anchor_position = global_position
	_ensure_core_components()
	_setup_core_components()
	_reset_geyser_visual()
	_play_animation(ANIMATION_IDLE, true)
	boss_health_changed.emit(get_current_hp(), MAX_HP)


func _physics_process(delta: float) -> void:
	if _status_effects != null:
		_status_effects.advance_time(delta)
	if _defeated:
		return
	if _state == State.PHASE_TRANSITION:
		_process_phase_transition(delta)
		return
	_attack_cooldown_timer = maxi(0, _attack_cooldown_timer - 1)
	match _state:
		State.IDLE:
			_process_idle(delta)
		State.CHASE:
			_process_chase(delta)
		State.HIT:
			_process_hit()
		State.ATTACK_TELL:
			_process_attack_tell()
		State.ATTACK_ACTIVE:
			_process_attack_active()
		State.ATTACK_RECOVERY:
			_process_attack_recovery()
		State.PHASE_TRANSITION:
			return
		State.DEAD:
			return


func set_attack_target(target: Node) -> void:
	_attack_target = target
	if _combat != null:
		_combat.set_health_adapter(_attack_target)


func set_damage_calculator_adapter(damage_calculator_adapter: Object) -> void:
	_damage_calculator_adapter = damage_calculator_adapter
	if _combat != null:
		_combat.set_damage_calculator_adapter(_damage_calculator_adapter)


func request_attack() -> bool:
	return _request_attack_pattern(&"", false)


## Explicit requests bypass cooldown for deterministic tests and runtime probes.
func request_attack_pattern(pattern_id: StringName) -> bool:
	return _request_attack_pattern(pattern_id, true)


func _request_attack_pattern(pattern_id: StringName, explicit_request: bool) -> bool:
	if (
		_defeated
		or (
			_state != State.IDLE
			and not (explicit_request and _state == State.CHASE)
		)
		or (not explicit_request and _attack_cooldown_timer > 0)
		or not _has_valid_attack_target()
	):
		return false
	var selected_pattern: StringName = (
		pattern_id if explicit_request else _next_attack_pattern_id()
	)
	if not ATTACK_PATTERN_IDS.has(selected_pattern):
		return false
	_current_pattern_id = selected_pattern
	velocity = Vector2.ZERO
	_next_pattern_index = (
		ATTACK_PATTERN_IDS.find(selected_pattern) + 1
	) % ATTACK_PATTERN_IDS.size()
	_attack_history.append(selected_pattern)
	if _attack_history.size() > 6:
		_attack_history.pop_front()
	_face_attack_target()
	_attack_sequence_id += 1
	_attack_timer = _current_attack_startup_frames()
	_state = State.ATTACK_TELL
	if _collision != null:
		_collision.deactivate_all_hitboxes()
	if _current_pattern_id == PRESSURE_GEYSER_ID:
		_geyser_target_x = clampf(
			(_attack_target as Node2D).global_position.x,
			GEYSER_TARGET_MIN_X,
			GEYSER_TARGET_MAX_X
		)
		_set_geyser_visual(&"warning", true)
	else:
		_reset_geyser_visual()
	_play_animation(_current_tell_animation(), true)
	return true


func advance_attack_frames(frames: int) -> void:
	for _index: int in range(maxi(0, frames)):
		if _defeated:
			return
		_attack_cooldown_timer = maxi(0, _attack_cooldown_timer - 1)
		match _state:
			State.ATTACK_TELL:
				_process_attack_tell()
			State.ATTACK_ACTIVE:
				_process_attack_active()
			State.ATTACK_RECOVERY:
				_process_attack_recovery()
			State.HIT:
				_process_hit()
			_:
				pass


## Advances only idle/chase behavior for focused tests and MCP probes.
func advance_chase_frames(frames: int) -> void:
	for _index: int in range(maxi(0, frames)):
		if _defeated or _state not in [State.IDLE, State.CHASE]:
			return
		_attack_cooldown_timer = maxi(0, _attack_cooldown_timer - 1)
		if _state == State.IDLE:
			_process_idle(1.0 / 60.0)
		else:
			_process_chase(1.0 / 60.0)


func apply_damage(final_damage: int, metadata: Dictionary = {}) -> bool:
	if (
		_defeated
		or _state == State.PHASE_TRANSITION
		or _health == null
		or final_damage <= 0
	):
		return false
	_last_hit_metadata = metadata.duplicate(true)
	_health.apply_damage(final_damage, metadata)
	return true


func reset_encounter() -> void:
	_defeated = false
	_state = State.IDLE
	_current_phase = PHASE_ONE
	_phase_two_pending = false
	_phase_transition_remaining_sec = 0.0
	_phase_transition_start_count = 0
	_last_phase_transition_metadata.clear()
	_hit_timer = 0
	_attack_timer = 0
	_attack_cooldown_timer = 0
	_next_pattern_index = 0
	_current_pattern_id = &""
	_attack_history.clear()
	_reset_geyser_visual()
	_last_hit_metadata.clear()
	_last_enemy_attack_metadata.clear()
	global_position = _arena_anchor_position
	velocity = Vector2.ZERO
	collision_layer = _default_collision_layer
	collision_mask = _default_collision_mask
	_ensure_core_components()
	_setup_core_components()
	if _collision != null:
		_collision.deactivate_all_hitboxes()
		_collision.set_hurtbox_state(CollisionComponent.HURTBOX_STATE_NORMAL)
	if _sprite != null:
		_sprite.modulate = NORMAL_MODULATE
	_play_animation(ANIMATION_IDLE, true)
	boss_health_changed.emit(get_current_hp(), MAX_HP)


func mark_defeated_from_progress() -> void:
	_defeated = true
	_state = State.DEAD
	_phase_two_pending = false
	_phase_transition_remaining_sec = 0.0
	_phase_transition_start_count = 0
	_last_phase_transition_metadata.clear()
	_attack_timer = 0
	_attack_cooldown_timer = 0
	_current_pattern_id = &""
	_reset_geyser_visual()
	velocity = Vector2.ZERO
	if _health != null:
		_health.configure(ENTITY_ID, MAX_HP, 0, 0, 0, false)
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


func get_current_boss_id() -> StringName:
	return BOSS_ID


func get_display_name() -> String:
	return DISPLAY_NAME


func get_current_hp() -> int:
	return _health.get_current_hp() if _health != null else MAX_HP


func get_max_hp() -> int:
	return MAX_HP


func get_current_phase() -> int:
	return _current_phase


func get_current_attack_startup_frames() -> int:
	return _startup_frames_for(_diagnostic_pattern_id())


func get_current_attack_pattern_id() -> StringName:
	return _current_pattern_id


func get_attack_phase() -> StringName:
	match _state:
		State.ATTACK_TELL:
			return &"startup"
		State.ATTACK_ACTIVE:
			return &"active"
		State.ATTACK_RECOVERY:
			return &"recovery"
		State.PHASE_TRANSITION:
			return &"phase_transition"
		State.HIT:
			return &"hurt"
		State.DEAD:
			return &"dead"
		_:
			return &"idle"


## Advances the active phase window without depending on rendered frames.
func advance_phase_transition(delta_sec: float) -> void:
	if _state != State.PHASE_TRANSITION:
		return
	_process_phase_transition(maxf(0.0, delta_sec))


func is_phase_transition_active() -> bool:
	return _state == State.PHASE_TRANSITION


func get_phase_transition_diagnostics() -> Dictionary:
	return {
		"active": is_phase_transition_active(),
		"remaining_sec": _phase_transition_remaining_sec,
		"duration_sec": PHASE_TRANSITION_DURATION_SEC,
		"start_count": _phase_transition_start_count,
		"animation": String(ANIMATION_PHASE_TRANSITION),
		"metadata": _last_phase_transition_metadata.duplicate(true),
	}


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


func get_pressure_lunge_diagnostics() -> Dictionary:
	return {
		"attack_phase": String(get_attack_phase()),
		"animation": String(_sprite.animation) if _sprite != null else "",
		"current_phase": _current_phase,
		"phase_two_pending": _phase_two_pending,
		"phase_transition_active": is_phase_transition_active(),
		"phase_transition_remaining_sec": _phase_transition_remaining_sec,
		"attack_sequence_id": _attack_sequence_id,
		"attack_startup_frames": ATTACK_TELL_FRAMES,
		"attack_damage": ATTACK_DAMAGE,
		"hitbox_id": String(ATTACK_HITBOX_ID),
		"hitbox_active": (
			_collision != null and _collision.is_hitbox_active(ATTACK_HITBOX_ID)
		),
		"lunge_step_px": _current_lunge_step_px(),
		"attack_cooldown_frames": _current_attack_cooldown_frames(),
		"phase_one_attack_cooldown_frames": PHASE_ONE_ATTACK_COOLDOWN_FRAMES,
		"facing": _facing,
		"defeated": _defeated,
		"arena_anchor_position": _arena_anchor_position,
	}


func get_attack_diagnostics() -> Dictionary:
	var pattern_id: StringName = _diagnostic_pattern_id()
	var hitbox_id: StringName = _hitbox_id_for(_current_pattern_id)
	return {
		"attack_phase": String(get_attack_phase()),
		"current_attack_id": String(_current_pattern_id),
		"next_attack_id": String(_next_attack_pattern_id()),
		"attack_history": _string_attack_history(),
		"animation": String(_sprite.animation) if _sprite != null else "",
		"current_phase": _current_phase,
		"phase_two_pending": _phase_two_pending,
		"phase_transition_active": is_phase_transition_active(),
		"phase_transition_remaining_sec": _phase_transition_remaining_sec,
		"attack_sequence_id": _attack_sequence_id,
		"startup_frames": _startup_frames_for(pattern_id),
		"active_frames": _active_frames_for(pattern_id),
		"recovery_frames": _recovery_frames_for(pattern_id),
		"attack_damage": _damage_for(pattern_id),
		"hitbox_id": String(hitbox_id),
		"hitbox_active": (
			_collision != null
			and hitbox_id != &""
			and _collision.is_hitbox_active(hitbox_id)
		),
		"geyser_visible": _geyser_sprite != null and _geyser_sprite.visible,
		"geyser_animation": (
			String(_geyser_sprite.animation) if _geyser_sprite != null else ""
		),
		"geyser_target_x": _geyser_target_x,
		"safe_space_px": _geyser_safe_space_px(),
		"attack_cooldown_frames": _current_attack_cooldown_frames(),
		"facing": _facing,
		"defeated": _defeated,
		"arena_anchor_position": _arena_anchor_position,
	}


func get_chase_diagnostics() -> Dictionary:
	return {
		"behavior_state": "chase" if _state == State.CHASE else String(get_attack_phase()),
		"animation": String(_sprite.animation) if _sprite != null else "",
		"target_valid": _has_valid_attack_target(),
		"target_distance_px": _target_distance_px(),
		"attack_commit_range_px": ATTACK_COMMIT_RANGE_PX,
		"velocity_x": velocity.x,
		"facing": _facing,
		"current_phase": _current_phase,
		"chase_speed_px_sec": _current_chase_speed_px_sec(),
		"phase_one_chase_speed_px_sec": PHASE_ONE_CHASE_SPEED_PX_SEC,
		"phase_two_chase_speed_px_sec": PHASE_TWO_CHASE_SPEED_PX_SEC,
		"position": global_position,
	}


func _process_idle(delta: float) -> void:
	velocity = Vector2.ZERO
	_update_sprite_facing()
	_play_animation(ANIMATION_IDLE)
	if not _has_valid_attack_target():
		return
	if _target_distance_px() > ATTACK_COMMIT_RANGE_PX:
		_state = State.CHASE
		_process_chase(delta)
		return
	if _attack_cooldown_timer <= 0:
		request_attack()


func _process_chase(_delta: float) -> void:
	if not _has_valid_attack_target():
		_state = State.IDLE
		velocity = Vector2.ZERO
		_play_animation(ANIMATION_IDLE, true)
		return
	_face_attack_target()
	if _target_distance_px() <= ATTACK_COMMIT_RANGE_PX:
		_state = State.IDLE
		velocity = Vector2.ZERO
		_play_animation(ANIMATION_IDLE, true)
		if _attack_cooldown_timer <= 0:
			request_attack()
		return
	velocity = Vector2(_facing * _current_chase_speed_px_sec(), 0.0)
	move_and_slide()
	global_position.x = clampf(global_position.x, ARENA_MIN_X, ARENA_MAX_X)
	_play_animation(ANIMATION_RUN)


func _process_hit() -> void:
	velocity = Vector2.ZERO
	_hit_timer -= 1
	if _hit_timer > 0:
		return
	_state = State.IDLE
	if _sprite != null:
		_sprite.modulate = PHASE_TWO_MODULATE if _current_phase == PHASE_TWO else NORMAL_MODULATE
	_play_animation(ANIMATION_IDLE, true)
	_apply_pending_phase_two_if_ready()


func _process_attack_tell() -> void:
	velocity = Vector2.ZERO
	_update_sprite_facing()
	_play_animation(_current_tell_animation())
	_attack_timer -= 1
	if _attack_timer <= 0:
		_enter_attack_active()


func _enter_attack_active() -> void:
	_state = State.ATTACK_ACTIVE
	_attack_timer = _active_frames_for(_current_pattern_id)
	_play_animation(_current_active_animation(), true)
	if _current_pattern_id == PRESSURE_GEYSER_ID:
		_set_geyser_visual(&"active", true)
	if _collision != null:
		var hitbox_id: StringName = _hitbox_id_for(_current_pattern_id)
		_collision.activate_hitbox(
			hitbox_id,
			_attack_timer,
			_current_hitbox_offset(),
			_hitbox_size_for(_current_pattern_id),
			_build_attack_metadata()
		)


func _process_attack_active() -> void:
	var start_x: float = global_position.x
	if _current_pattern_id == PRESSURE_LUNGE_ID:
		global_position.x = clampf(
			global_position.x + _facing * _current_lunge_step_px(),
			ARENA_MIN_X,
			ARENA_MAX_X
		)
	velocity = Vector2((global_position.x - start_x) * 60.0, 0.0)
	_play_animation(_current_active_animation())
	_attack_timer -= 1
	if _attack_timer <= 0:
		_enter_attack_recovery()


func _enter_attack_recovery() -> void:
	_state = State.ATTACK_RECOVERY
	_attack_timer = _recovery_frames_for(_current_pattern_id)
	velocity = Vector2.ZERO
	if _collision != null:
		_collision.deactivate_all_hitboxes()
	_set_geyser_visual(&"warning", false)
	_play_animation(ANIMATION_ATTACK_RECOVERY, true)


func _process_attack_recovery() -> void:
	velocity = Vector2.ZERO
	_play_animation(ANIMATION_ATTACK_RECOVERY)
	_attack_timer -= 1
	if _attack_timer > 0:
		return
	_state = State.IDLE
	_attack_cooldown_timer = _current_attack_cooldown_frames()
	_current_pattern_id = &""
	_play_animation(ANIMATION_IDLE, true)
	_apply_pending_phase_two_if_ready()


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
	_health.configure_boss_phases([PHASE_TWO_HP_THRESHOLD])
	if not _health.on_hp_changed.is_connected(_on_core_hp_changed):
		_health.on_hp_changed.connect(_on_core_hp_changed)
	if not _health.on_death.is_connected(_on_core_death):
		_health.on_death.connect(_on_core_death)
	_collision.configure_entity(ENTITY_ID, &"enemy")
	_collision.set_hurtbox_size(BOSS_HURTBOX_SIZE)
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


func _on_core_hp_changed(_entity_id: int, current_hp: int, max_hp: int) -> void:
	boss_health_changed.emit(current_hp, max_hp)
	if current_hp <= 0 or _defeated:
		return
	_maybe_enter_phase_two(current_hp, max_hp)
	if _state == State.PHASE_TRANSITION:
		return
	if _sprite != null:
		_sprite.modulate = HIT_MODULATE
	if _is_attack_chain_active():
		return
	velocity = Vector2.ZERO
	_hit_timer = HIT_FLASH_FRAMES
	_state = State.HIT
	_play_animation(ANIMATION_HURT, true)


func _on_core_death(_entity_id: int, _metadata: Dictionary) -> void:
	_die()


func _die() -> void:
	if _defeated:
		return
	_defeated = true
	_state = State.DEAD
	_phase_two_pending = false
	_phase_transition_remaining_sec = 0.0
	_attack_timer = 0
	_attack_cooldown_timer = 0
	_current_pattern_id = &""
	_reset_geyser_visual()
	velocity = Vector2.ZERO
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
		metadata["source"] = BOSS_ID
	_last_enemy_attack_metadata = metadata.duplicate(true)
	if not bool(metadata.get("damage_was_applied", true)):
		return
	var hit_position: Vector2 = metadata.get("hit_position", global_position)
	enemy_attack_landed.emit(
		int(metadata.get("damage_applied", metadata.get("final_damage", 0))),
		hit_position,
		bool(metadata.get("is_crit", false))
	)


func _maybe_enter_phase_two(current_hp: int, max_hp: int) -> void:
	if _current_phase >= PHASE_TWO or max_hp <= 0:
		return
	if float(current_hp) / float(max_hp) > PHASE_TWO_HP_THRESHOLD:
		return
	if _is_attack_chain_active():
		_phase_two_pending = true
		return
	_enter_phase_two()


func _apply_pending_phase_two_if_ready() -> void:
	if not _phase_two_pending or _is_attack_chain_active():
		return
	_enter_phase_two()


func _enter_phase_two() -> void:
	if _current_phase >= PHASE_TWO:
		_phase_two_pending = false
		return
	_current_phase = PHASE_TWO
	_phase_two_pending = false
	_phase_transition_remaining_sec = PHASE_TRANSITION_DURATION_SEC
	_phase_transition_start_count += 1
	_attack_timer = 0
	_attack_cooldown_timer = 0
	_current_pattern_id = &""
	_state = State.PHASE_TRANSITION
	velocity = Vector2.ZERO
	_reset_geyser_visual()
	if _collision != null:
		_collision.deactivate_all_hitboxes()
		_collision.set_hurtbox_state(CollisionComponent.HURTBOX_STATE_GONE)
	if _sprite != null:
		_sprite.modulate = PHASE_TWO_MODULATE
	_play_animation(ANIMATION_PHASE_TRANSITION, true)
	_last_phase_transition_metadata = {
		"boss_id": BOSS_ID,
		"display_name": "Sluice Matriarch",
		"previous_phase": PHASE_ONE,
		"hp_percentage": float(get_current_hp()) / float(MAX_HP),
		"transition_duration_sec": PHASE_TRANSITION_DURATION_SEC,
		"transition_animation": String(ANIMATION_PHASE_TRANSITION),
		"world_position": global_position,
		"position": global_position,
		"next_attack_id": String(_next_attack_pattern_id()),
		"lunge_step_px": PHASE_TWO_LUNGE_STEP_PX,
		"chase_speed_px_sec": PHASE_TWO_CHASE_SPEED_PX_SEC,
		"attack_cooldown_frames": PHASE_TWO_ATTACK_COOLDOWN_FRAMES,
	}
	on_boss_phase_transition_started.emit(
		ENTITY_ID,
		PHASE_TWO,
		_last_phase_transition_metadata.duplicate(true)
	)


func _process_phase_transition(delta_sec: float) -> void:
	velocity = Vector2.ZERO
	_play_animation(ANIMATION_PHASE_TRANSITION)
	_phase_transition_remaining_sec = maxf(
		0.0,
		_phase_transition_remaining_sec - maxf(0.0, delta_sec)
	)
	if _phase_transition_remaining_sec > 0.0:
		return
	_finish_phase_two_transition()


func _finish_phase_two_transition() -> void:
	_state = State.IDLE
	_attack_cooldown_timer = PHASE_TWO_ATTACK_COOLDOWN_FRAMES
	if _collision != null:
		_collision.deactivate_all_hitboxes()
		_collision.set_hurtbox_state(CollisionComponent.HURTBOX_STATE_NORMAL)
	if _sprite != null:
		_sprite.modulate = PHASE_TWO_MODULATE
	_play_animation(ANIMATION_IDLE, true)


func _is_attack_chain_active() -> bool:
	return _state in [State.ATTACK_TELL, State.ATTACK_ACTIVE, State.ATTACK_RECOVERY]


func _has_valid_attack_target() -> bool:
	return (
		_attack_target != null
		and is_instance_valid(_attack_target)
		and _attack_target is Node2D
	)


func _target_distance_px() -> float:
	if not _has_valid_attack_target():
		return -1.0
	return absf((_attack_target as Node2D).global_position.x - global_position.x)


func _face_attack_target() -> void:
	if not _has_valid_attack_target():
		return
	_facing = -1.0 if (_attack_target as Node2D).global_position.x < global_position.x else 1.0
	_update_sprite_facing()


func _update_sprite_facing() -> void:
	if _sprite != null:
		_sprite.flip_h = _facing < 0.0


func _play_animation(animation_name: StringName, restart: bool = false) -> void:
	if _sprite == null or _sprite.sprite_frames == null:
		return
	if not _sprite.sprite_frames.has_animation(animation_name):
		return
	if restart or StringName(_sprite.animation) != animation_name:
		_sprite.play(animation_name)


func _current_lunge_step_px() -> float:
	return (
		PHASE_TWO_LUNGE_STEP_PX
		if _current_phase == PHASE_TWO
		else PHASE_ONE_LUNGE_STEP_PX
	)


func _current_chase_speed_px_sec() -> float:
	return (
		PHASE_TWO_CHASE_SPEED_PX_SEC
		if _current_phase == PHASE_TWO
		else PHASE_ONE_CHASE_SPEED_PX_SEC
	)


func _current_attack_cooldown_frames() -> int:
	return (
		PHASE_TWO_ATTACK_COOLDOWN_FRAMES
		if _current_phase == PHASE_TWO
		else PHASE_ONE_ATTACK_COOLDOWN_FRAMES
	)


func _build_attack_metadata() -> Dictionary:
	var hitbox_id: StringName = _hitbox_id_for(_current_pattern_id)
	return {
		"source": BOSS_ID,
		"attack_type": (
			&"special" if _current_pattern_id == PRESSURE_GEYSER_ID else &"light"
		),
		"weapon_id": hitbox_id,
		"combo_index": 0,
		"hit_frame": ATTACK_HIT_FRAME,
		"attack_power": 0,
		"enemy_defense": 0,
		"attack_sequence_id": _attack_sequence_id,
		"phase": _current_phase,
		"injected_damage_params": _build_enemy_damage_params(),
	}


func _build_enemy_damage_params() -> Dictionary:
	var hitbox_id: StringName = _hitbox_id_for(_current_pattern_id)
	return {
		"entries": {
			String(hitbox_id): {
				"weapon_base": _damage_for(_current_pattern_id),
				"combo_multipliers": {"0": 1.0},
				"special_move": {"multiplier": 1.0, "hits": 1},
			},
		},
	}


func _next_attack_pattern_id() -> StringName:
	return ATTACK_PATTERN_IDS[_next_pattern_index % ATTACK_PATTERN_IDS.size()]


func _diagnostic_pattern_id() -> StringName:
	return _current_pattern_id if _current_pattern_id != &"" else _next_attack_pattern_id()


func _current_attack_startup_frames() -> int:
	return _startup_frames_for(_current_pattern_id)


func _startup_frames_for(pattern_id: StringName) -> int:
	if pattern_id != PRESSURE_GEYSER_ID:
		return ATTACK_TELL_FRAMES
	return (
		PHASE_TWO_GEYSER_TELL_FRAMES
		if _current_phase == PHASE_TWO
		else PHASE_ONE_GEYSER_TELL_FRAMES
	)


func _active_frames_for(pattern_id: StringName) -> int:
	return GEYSER_ACTIVE_FRAMES if pattern_id == PRESSURE_GEYSER_ID else ATTACK_ACTIVE_FRAMES


func _recovery_frames_for(pattern_id: StringName) -> int:
	if pattern_id != PRESSURE_GEYSER_ID:
		return ATTACK_RECOVERY_FRAMES
	return (
		PHASE_TWO_GEYSER_RECOVERY_FRAMES
		if _current_phase == PHASE_TWO
		else PHASE_ONE_GEYSER_RECOVERY_FRAMES
	)


func _damage_for(pattern_id: StringName) -> int:
	return GEYSER_DAMAGE if pattern_id == PRESSURE_GEYSER_ID else ATTACK_DAMAGE


func _hitbox_id_for(pattern_id: StringName) -> StringName:
	match pattern_id:
		PRESSURE_LUNGE_ID:
			return ATTACK_HITBOX_ID
		PRESSURE_GEYSER_ID:
			return GEYSER_HITBOX_ID
		_:
			return &""


func _hitbox_size_for(pattern_id: StringName) -> Vector2:
	return GEYSER_HITBOX_SIZE if pattern_id == PRESSURE_GEYSER_ID else ATTACK_HITBOX_SIZE


func _current_hitbox_offset() -> Vector2:
	if _current_pattern_id == PRESSURE_GEYSER_ID:
		return Vector2(
			_geyser_target_x - global_position.x,
			GEYSER_HITBOX_Y_OFFSET
		)
	return Vector2(_facing * ATTACK_HITBOX_OFFSET.x, ATTACK_HITBOX_OFFSET.y)


func _current_tell_animation() -> StringName:
	return (
		ANIMATION_GEYSER_TELL
		if _current_pattern_id == PRESSURE_GEYSER_ID
		else ANIMATION_ATTACK_TELL
	)


func _current_active_animation() -> StringName:
	return (
		ANIMATION_GEYSER_ATTACK
		if _current_pattern_id == PRESSURE_GEYSER_ID
		else ANIMATION_ATTACK
	)


func _set_geyser_visual(animation_name: StringName, should_show: bool) -> void:
	if _geyser_sprite == null:
		return
	_geyser_sprite.visible = should_show
	if not should_show:
		_geyser_sprite.stop()
		return
	_geyser_sprite.global_position = Vector2(
		_geyser_target_x,
		GEYSER_VISUAL_CENTER_Y
	)
	_geyser_sprite.play(animation_name)


func _reset_geyser_visual() -> void:
	_geyser_target_x = 0.0
	_set_geyser_visual(&"warning", false)


func _geyser_safe_space_px() -> float:
	if _geyser_target_x <= 0.0:
		return ARENA_VISIBLE_MAX_X - ARENA_VISIBLE_MIN_X
	var half_width: float = GEYSER_WARNING_WIDTH_PX * 0.5
	var left_space: float = _geyser_target_x - half_width - ARENA_VISIBLE_MIN_X
	var right_space: float = ARENA_VISIBLE_MAX_X - _geyser_target_x - half_width
	return maxf(0.0, maxf(left_space, right_space))


func _string_attack_history() -> Array[String]:
	var result: Array[String] = []
	for pattern_id: StringName in _attack_history:
		result.append(String(pattern_id))
	return result
