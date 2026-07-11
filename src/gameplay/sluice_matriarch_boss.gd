## Playable Boss3 core with one telegraphed pressure-lunge attack.
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
const ATTACK_TELL_FRAMES: int = 18
const ATTACK_ACTIVE_FRAMES: int = 6
const ATTACK_RECOVERY_FRAMES: int = 18
const PHASE_ONE_ATTACK_COOLDOWN_FRAMES: int = 42
const PHASE_TWO_ATTACK_COOLDOWN_FRAMES: int = 28
const PHASE_ONE_LUNGE_STEP_PX: float = 14.0
const PHASE_TWO_LUNGE_STEP_PX: float = 20.0
const ARENA_MIN_X: float = 320.0
const ARENA_MAX_X: float = 1160.0
const ATTACK_HITBOX_ID: StringName = &"sluice_matriarch_pressure_lunge"
const ATTACK_HITBOX_SIZE: Vector2 = Vector2(138, 70)
const ATTACK_HITBOX_OFFSET: Vector2 = Vector2(112, -42)
const ATTACK_DAMAGE: int = 16
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
const ANIMATION_HURT: StringName = &"hurt"
const ANIMATION_DEATH: StringName = &"death"
const HEALTH_COMPONENT_SCRIPT: Script = preload("res://src/core/health_component.gd")
const COLLISION_COMPONENT_SCRIPT: Script = preload("res://src/core/collision_component.gd")
const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")
const STATUS_EFFECT_COMPONENT_SCRIPT: Script = preload(
	"res://src/core/status_effect_component.gd"
)

enum State { IDLE, HIT, ATTACK_TELL, ATTACK_ACTIVE, ATTACK_RECOVERY, DEAD }

@onready var _sprite: AnimatedSprite2D = $Sprite

var _state: State = State.IDLE
var _facing: float = -1.0
var _hit_timer: int = 0
var _attack_timer: int = 0
var _attack_cooldown_timer: int = 0
var _attack_sequence_id: int = 0
var _defeated: bool = false
var _current_phase: int = PHASE_ONE
var _phase_two_pending: bool = false
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
	_play_animation(ANIMATION_IDLE, true)
	boss_health_changed.emit(get_current_hp(), MAX_HP)


func _physics_process(delta: float) -> void:
	if _status_effects != null:
		_status_effects.advance_time(delta)
	if _defeated:
		return
	_attack_cooldown_timer = maxi(0, _attack_cooldown_timer - 1)
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


func set_damage_calculator_adapter(damage_calculator_adapter: Object) -> void:
	_damage_calculator_adapter = damage_calculator_adapter
	if _combat != null:
		_combat.set_damage_calculator_adapter(_damage_calculator_adapter)


func request_attack() -> bool:
	if (
		_defeated
		or _state != State.IDLE
		or _attack_cooldown_timer > 0
		or not _has_valid_attack_target()
	):
		return false
	_face_attack_target()
	_attack_sequence_id += 1
	_attack_timer = ATTACK_TELL_FRAMES
	_state = State.ATTACK_TELL
	if _collision != null:
		_collision.deactivate_hitbox(ATTACK_HITBOX_ID)
	_play_animation(ANIMATION_ATTACK_TELL, true)
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


func apply_damage(final_damage: int, metadata: Dictionary = {}) -> void:
	if _defeated or _health == null or final_damage <= 0:
		return
	_last_hit_metadata = metadata.duplicate(true)
	_health.apply_damage(final_damage, metadata)


func reset_encounter() -> void:
	_defeated = false
	_state = State.IDLE
	_current_phase = PHASE_ONE
	_phase_two_pending = false
	_hit_timer = 0
	_attack_timer = 0
	_attack_cooldown_timer = 0
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
	_attack_timer = 0
	_attack_cooldown_timer = 0
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
	return ATTACK_TELL_FRAMES


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


func _process_idle() -> void:
	velocity = Vector2.ZERO
	_update_sprite_facing()
	_play_animation(ANIMATION_IDLE)
	if _attack_cooldown_timer <= 0 and _has_valid_attack_target():
		request_attack()


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
	_play_animation(ANIMATION_ATTACK_TELL)
	_attack_timer -= 1
	if _attack_timer <= 0:
		_enter_attack_active()


func _enter_attack_active() -> void:
	_state = State.ATTACK_ACTIVE
	_attack_timer = ATTACK_ACTIVE_FRAMES
	_play_animation(ANIMATION_ATTACK, true)
	if _collision != null:
		_collision.activate_hitbox(
			ATTACK_HITBOX_ID,
			ATTACK_ACTIVE_FRAMES,
			Vector2(_facing * ATTACK_HITBOX_OFFSET.x, ATTACK_HITBOX_OFFSET.y),
			ATTACK_HITBOX_SIZE,
			_build_attack_metadata()
		)


func _process_attack_active() -> void:
	var start_x: float = global_position.x
	global_position.x = clampf(
		global_position.x + _facing * _current_lunge_step_px(),
		ARENA_MIN_X,
		ARENA_MAX_X
	)
	velocity = Vector2((global_position.x - start_x) * 60.0, 0.0)
	_play_animation(ANIMATION_ATTACK)
	_attack_timer -= 1
	if _attack_timer <= 0:
		_enter_attack_recovery()


func _enter_attack_recovery() -> void:
	_state = State.ATTACK_RECOVERY
	_attack_timer = ATTACK_RECOVERY_FRAMES
	velocity = Vector2.ZERO
	if _collision != null:
		_collision.deactivate_hitbox(ATTACK_HITBOX_ID)


func _process_attack_recovery() -> void:
	velocity = Vector2.ZERO
	_attack_timer -= 1
	if _attack_timer > 0:
		return
	_state = State.IDLE
	_attack_cooldown_timer = _current_attack_cooldown_frames()
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
	if _sprite != null:
		_sprite.modulate = HIT_MODULATE
	if _is_attack_chain_active():
		return
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
	_attack_timer = 0
	_attack_cooldown_timer = 0
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
	var hit_position: Vector2 = metadata.get("hit_position", global_position)
	enemy_attack_landed.emit(
		int(metadata.get("final_damage", 0)),
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
	_attack_cooldown_timer = mini(
		_attack_cooldown_timer,
		PHASE_TWO_ATTACK_COOLDOWN_FRAMES
	)
	if _sprite != null:
		_sprite.modulate = PHASE_TWO_MODULATE
	on_boss_phase_transition_started.emit(ENTITY_ID, PHASE_TWO, {
		"boss_id": BOSS_ID,
		"hp_percentage": float(get_current_hp()) / float(MAX_HP),
		"lunge_step_px": PHASE_TWO_LUNGE_STEP_PX,
		"attack_cooldown_frames": PHASE_TWO_ATTACK_COOLDOWN_FRAMES,
	})


func _is_attack_chain_active() -> bool:
	return _state in [State.ATTACK_TELL, State.ATTACK_ACTIVE, State.ATTACK_RECOVERY]


func _has_valid_attack_target() -> bool:
	return (
		_attack_target != null
		and is_instance_valid(_attack_target)
		and _attack_target is Node2D
	)


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


func _current_attack_cooldown_frames() -> int:
	return (
		PHASE_TWO_ATTACK_COOLDOWN_FRAMES
		if _current_phase == PHASE_TWO
		else PHASE_ONE_ATTACK_COOLDOWN_FRAMES
	)


func _build_attack_metadata() -> Dictionary:
	return {
		"source": BOSS_ID,
		"attack_type": &"light",
		"weapon_id": ATTACK_HITBOX_ID,
		"combo_index": 0,
		"hit_frame": ATTACK_HIT_FRAME,
		"attack_power": 0,
		"enemy_defense": 0,
		"attack_sequence_id": _attack_sequence_id,
		"phase": _current_phase,
		"injected_damage_params": _build_enemy_damage_params(),
	}


func _build_enemy_damage_params() -> Dictionary:
	return {
		"entries": {
			String(ATTACK_HITBOX_ID): {
				"weapon_base": ATTACK_DAMAGE,
				"combo_multipliers": {"0": 1.0},
				"special_move": {"multiplier": 1.0, "hits": 1},
			},
		},
	}
