## Minimal single-stage Boss2 threat for the mainline Double Jump payoff.
class_name Boss2EchoGuardian
extends CharacterBody2D

signal boss_health_changed(current_hp: int, max_hp: int)
signal boss_defeated
signal enemy_attack_landed(damage: int, hit_position: Vector2, is_crit: bool)
signal boss2_audio_event_requested(event_id: StringName, metadata: Dictionary)
signal on_boss_phase_transition_started(entity_id: int, phase: int, metadata: Dictionary)

const ENTITY_ID: int = 2200
const BOSS_ID: StringName = &"boss_02_echo_guardian"
const DISPLAY_NAME: String = "Echo Guardian"
const MAX_HP: int = 36
const PHASE_ONE: int = 1
const PHASE_TWO: int = 2
const PHASE_TWO_HP_THRESHOLD: float = 0.5
const AGGRO_RANGE_PX: float = 360.0
const ATTACK_RANGE_PX: float = 108.0
const CHASE_STEP_PX: float = 3.0
const PHASE_TWO_CHASE_STEP_PX: float = 3.6
const ARENA_HALF_WIDTH_PX: float = 160.0
const RETURN_STEP_PX: float = 4.0
const ANCHOR_REACHED_EPSILON_PX: float = 0.5
const ATTACK_TELL_FRAMES: int = 8
const ATTACK_ACTIVE_FRAMES: int = 4
const ATTACK_RECOVERY_FRAMES: int = 14
const ATTACK_COOLDOWN_FRAMES: int = 28
const PHASE_TWO_ATTACK_COOLDOWN_FRAMES: int = 24
const FOCUS_WINDUP_EXTENSION_FRAMES: int = 6
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
const ANIMATION_RUN: StringName = &"run"
const ANIMATION_ATTACK_TELL: StringName = &"attack_tell"
const ANIMATION_ATTACK: StringName = &"attack"
const ANIMATION_HURT: StringName = &"hurt"
const ANIMATION_DEATH: StringName = &"death"
const HEALTH_COMPONENT_SCRIPT: Script = preload("res://src/core/health_component.gd")
const COLLISION_COMPONENT_SCRIPT: Script = preload("res://src/core/collision_component.gd")
const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")
const STATUS_EFFECT_COMPONENT_SCRIPT: Script = preload("res://src/core/status_effect_component.gd")

enum State { IDLE, HIT, ATTACK_TELL, ATTACK_ACTIVE, ATTACK_RECOVERY, DEAD }

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _focus_attack_tell: Node = $FocusAttackTell

var _state: State = State.IDLE
var _facing: float = -1.0
var _hit_timer: int = 0
var _attack_timer: int = 0
var _current_attack_startup_frames: int = ATTACK_TELL_FRAMES
var _attack_cooldown_timer: int = 0
var _attack_sequence_id: int = 0
var _behavior_phase: StringName = &"idle"
var _defeated: bool = false
var _encounter_active: bool = true
var _current_phase: int = PHASE_ONE
var _pending_phase_two_hp_percentage: float = -1.0
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
var _arena_anchor_position: Vector2 = Vector2.ZERO
var _audio_chase_active: bool = false
var _last_audio_hp: int = MAX_HP
var _target_focus_mode_active: bool = false
var _focus_windup_extension_frames: int = 0


func _ready() -> void:
	_default_collision_layer = collision_layer
	_default_collision_mask = collision_mask
	_arena_anchor_position = global_position
	_ensure_core_components()
	_setup_core_components()
	_last_audio_hp = get_current_hp()
	_play_animation(ANIMATION_IDLE, true)
	boss_health_changed.emit(get_current_hp(), MAX_HP)


func _physics_process(_delta: float) -> void:
	if not _encounter_active:
		return
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
	return _has_valid_attack_target()


## Enables or freezes the authored encounter without treating the Boss as defeated.
func set_encounter_active(active: bool, target: Node = null) -> void:
	if active and not _defeated:
		var was_active: bool = _encounter_active
		_encounter_active = true
		visible = true
		set_physics_process(true)
		if not was_active:
			reset_encounter()
		set_attack_target(target)
		return
	_encounter_active = false
	set_attack_target(null)
	velocity = Vector2.ZERO
	_stop_focus_attack_tell()
	_attack_timer = 0
	_attack_cooldown_timer = 0
	_audio_chase_active = false
	if not _defeated:
		_state = State.IDLE
		_behavior_phase = &"inactive"
		_play_animation(ANIMATION_IDLE, true)
	if _collision != null:
		_collision.deactivate_all_hitboxes()
		_collision.set_hurtbox_state(CollisionComponent.HURTBOX_STATE_GONE)
	collision_layer = 0
	collision_mask = 0
	visible = false
	set_physics_process(false)


func is_encounter_active() -> bool:
	return _encounter_active and not _defeated


func set_damage_calculator_adapter(damage_calculator_adapter: Object) -> void:
	_damage_calculator_adapter = damage_calculator_adapter
	if _combat != null:
		_combat.set_damage_calculator_adapter(_damage_calculator_adapter)


func request_attack() -> bool:
	if not _encounter_active \
			or _defeated \
			or _state != State.IDLE \
			or _attack_cooldown_timer > 0 \
			or not _has_valid_attack_target():
		return false
	_face_attack_target()
	_attack_sequence_id += 1
	_current_attack_startup_frames = _next_attack_startup_frames()
	_attack_timer = _current_attack_startup_frames
	_state = State.ATTACK_TELL
	_behavior_phase = &"startup"
	_audio_chase_active = false
	if _collision != null:
		_collision.deactivate_hitbox(ATTACK_HITBOX_ID)
	_play_animation(ANIMATION_ATTACK_TELL, true)
	_begin_focus_attack_tell(ATTACK_TELL_FRAMES)
	_emit_boss2_audio_event(&"attack_startup", {
		"attack_sequence_id": _attack_sequence_id,
		"attack_phase": &"startup",
	})
	return true


func advance_behavior_frames(frames: int) -> void:
	for _index: int in range(maxi(0, frames)):
		if _defeated:
			_behavior_phase = &"defeated"
			return
		if not _encounter_active:
			_behavior_phase = &"inactive"
			return
		if _status_effects != null:
			_status_effects.advance_time(1.0 / 60.0)
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
				_behavior_phase = &"defeated"
				return


func advance_attack_frames(frames: int) -> void:
	for _index: int in range(maxi(0, frames)):
		if not _encounter_active or _defeated:
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
	if not _encounter_active or _defeated or _health == null or final_damage <= 0:
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
	_encounter_active = true
	_defeated = false
	_state = State.IDLE
	_stop_focus_attack_tell()
	_behavior_phase = &"idle"
	global_position = _arena_anchor_position
	velocity = Vector2.ZERO
	_hit_timer = 0
	_attack_timer = 0
	_attack_cooldown_timer = 0
	_current_phase = PHASE_ONE
	_pending_phase_two_hp_percentage = -1.0
	_audio_chase_active = false
	_last_hit_metadata.clear()
	_last_enemy_attack_metadata.clear()
	collision_layer = _default_collision_layer
	collision_mask = _default_collision_mask
	visible = true
	set_physics_process(true)
	_ensure_core_components()
	_setup_core_components()
	_last_audio_hp = get_current_hp()
	if _collision != null:
		_collision.deactivate_all_hitboxes()
		_collision.set_hurtbox_state(CollisionComponent.HURTBOX_STATE_NORMAL)
	_sprite.modulate = NORMAL_MODULATE
	_play_animation(ANIMATION_IDLE, true)
	boss_health_changed.emit(get_current_hp(), MAX_HP)


func mark_defeated_from_progress() -> void:
	_defeated = true
	_state = State.DEAD
	_stop_focus_attack_tell()
	_behavior_phase = &"defeated"
	_attack_timer = 0
	_attack_cooldown_timer = 0
	_pending_phase_two_hp_percentage = -1.0
	_audio_chase_active = false
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


func capture_respawn_snapshot() -> Dictionary:
	return {
		"global_position": global_position,
		"hp": get_current_hp(),
		"facing": _facing,
		"collision_layer": collision_layer,
		"collision_mask": collision_mask,
		"sprite_modulate": _sprite.modulate,
		"arena_anchor_position": _arena_anchor_position,
	}


func restore_respawn_snapshot(snapshot: Dictionary) -> void:
	_arena_anchor_position = _read_vector2(
		snapshot.get("arena_anchor_position", _arena_anchor_position),
		_arena_anchor_position
	)
	global_position = _read_vector2(snapshot.get("global_position", global_position), global_position)
	_defeated = false
	_state = State.IDLE
	_stop_focus_attack_tell()
	_behavior_phase = &"idle"
	_current_phase = PHASE_ONE
	_pending_phase_two_hp_percentage = -1.0
	_facing = _read_float(snapshot.get("facing", _facing), _facing)
	_hit_timer = 0
	_attack_timer = 0
	_attack_cooldown_timer = 0
	_audio_chase_active = false
	_last_hit_metadata.clear()
	_last_enemy_attack_metadata.clear()
	velocity = Vector2.ZERO
	collision_layer = _read_int(snapshot.get("collision_layer", collision_layer), collision_layer)
	collision_mask = _read_int(snapshot.get("collision_mask", collision_mask), collision_mask)
	_ensure_core_components()
	_setup_core_components()
	var hp: int = clampi(_read_int(snapshot.get("hp", MAX_HP), MAX_HP), 0, MAX_HP)
	if _health != null:
		_health.configure(ENTITY_ID, MAX_HP, hp, 0, 0, false)
	_last_audio_hp = get_current_hp()
	if _collision != null:
		_collision.deactivate_all_hitboxes()
		_collision.set_hurtbox_state(CollisionComponent.HURTBOX_STATE_NORMAL)
	if _status_effects != null:
		_status_effects.clear_all_effects()
	if _sprite != null:
		_sprite.modulate = _read_color(snapshot.get("sprite_modulate", NORMAL_MODULATE), NORMAL_MODULATE)
	_update_sprite_facing()
	_play_animation(ANIMATION_IDLE, true)
	boss_health_changed.emit(get_current_hp(), MAX_HP)


func is_enemy_attack_active() -> bool:
	return _state == State.ATTACK_ACTIVE


func get_current_attack_sequence_id() -> int:
	return _attack_sequence_id


func get_current_attack_startup_frames() -> int:
	if _is_attack_chain_active():
		return _current_attack_startup_frames
	return _next_attack_startup_frames()


func get_attack_startup_frames() -> int:
	return get_current_attack_startup_frames()


func set_target_focus_mode(active: bool, metadata: Dictionary = {}) -> bool:
	_target_focus_mode_active = active
	_focus_windup_extension_frames = (
		clampi(
			_read_int(
				metadata.get("windup_extension_frames", FOCUS_WINDUP_EXTENSION_FRAMES),
				FOCUS_WINDUP_EXTENSION_FRAMES
			),
			0,
			300
		)
		if active
		else 0
	)
	return true


func get_focus_windup_diagnostics() -> Dictionary:
	return {
		"focus_mode_active": _target_focus_mode_active,
		"base_startup_frames": ATTACK_TELL_FRAMES,
		"windup_extension_frames": _focus_windup_extension_frames,
		"current_attack_startup_frames": get_current_attack_startup_frames(),
		"attack_phase": String(get_attack_phase()),
		"attack_sequence_id": _attack_sequence_id,
	}


func get_focus_attack_tell_diagnostics() -> Dictionary:
	if _focus_attack_tell == null:
		return {}
	return Dictionary(_focus_attack_tell.call("get_diagnostics"))


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


func get_current_phase() -> int:
	return _current_phase


func get_auto_pressure_diagnostics() -> Dictionary:
	var distance_x: float = INF
	var distance_y: float = INF
	if _has_valid_attack_target():
		var to_target: Vector2 = _attack_target.global_position - global_position
		distance_x = absf(to_target.x)
		distance_y = absf(to_target.y)
	return {
		"encounter_active": is_encounter_active(),
		"behavior_phase": _behavior_phase,
		"current_phase": _current_phase,
		"is_chasing": _behavior_phase == &"chase",
		"aggro_range_px": AGGRO_RANGE_PX,
		"attack_range_px": ATTACK_RANGE_PX,
		"chase_step_px": _current_chase_step_px(),
		"attack_cooldown_target_frames": _current_attack_cooldown_frames(),
		"target_distance_x": distance_x,
		"target_distance_y": distance_y,
		"has_target": _has_valid_attack_target(),
		"cooldown_frames": _attack_cooldown_timer,
		"attack_phase": get_attack_phase(),
		"defeated": _defeated,
		"arena_anchor_position": _arena_anchor_position,
		"arena_min_x": _arena_min_x(),
		"arena_max_x": _arena_max_x(),
		"is_returning_to_anchor": _behavior_phase == &"return",
		"is_at_anchor": global_position.distance_to(_arena_anchor_position) <= ANCHOR_REACHED_EPSILON_PX,
	}


func _process_idle(auto_attack: bool = true) -> void:
	velocity = Vector2.ZERO
	_update_sprite_facing()
	if not auto_attack:
		_behavior_phase = &"idle"
		_audio_chase_active = false
		_play_animation(ANIMATION_IDLE)
		return
	if _can_auto_attack_target():
		request_attack()
		return
	if _can_chase_attack_target():
		_chase_attack_target()
		if _can_auto_attack_target():
			request_attack()
		return
	if _should_return_to_anchor():
		_return_to_anchor()
		return
	_behavior_phase = &"idle"
	_audio_chase_active = false
	_play_animation(ANIMATION_IDLE)


func _process_hit() -> void:
	_behavior_phase = &"hurt"
	_audio_chase_active = false
	_hit_timer -= 1
	if _hit_timer <= 0:
		_state = State.IDLE
		if _sprite != null:
			_sprite.modulate = NORMAL_MODULATE
		_play_animation(ANIMATION_IDLE, true)


func _process_attack_tell() -> void:
	_behavior_phase = &"startup"
	velocity = Vector2.ZERO
	_update_sprite_facing()
	_advance_focus_attack_tell()
	_attack_timer -= 1
	if _attack_timer <= 0:
		_enter_attack_active()


func _enter_attack_active() -> void:
	_stop_focus_attack_tell()
	_state = State.ATTACK_ACTIVE
	_behavior_phase = &"active"
	_attack_timer = ATTACK_ACTIVE_FRAMES
	_audio_chase_active = false
	_play_animation(ANIMATION_ATTACK, true)
	_emit_boss2_audio_event(&"attack_active", {
		"attack_sequence_id": _attack_sequence_id,
		"attack_phase": &"active",
		"hitbox_id": ATTACK_HITBOX_ID,
	})
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
	_behavior_phase = &"active"
	velocity = Vector2.ZERO
	_play_animation(ANIMATION_ATTACK)
	_attack_timer -= 1
	if _attack_timer <= 0:
		_enter_attack_recovery()


func _enter_attack_recovery() -> void:
	_state = State.ATTACK_RECOVERY
	_behavior_phase = &"recovery"
	_attack_timer = ATTACK_RECOVERY_FRAMES
	if _collision != null:
		_collision.deactivate_hitbox(ATTACK_HITBOX_ID)


func _process_attack_recovery() -> void:
	_behavior_phase = &"recovery"
	velocity = Vector2.ZERO
	_attack_timer -= 1
	if _attack_timer <= 0:
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
		_last_audio_hp = current_hp
		return
	if current_hp < _last_audio_hp:
		_emit_boss2_audio_event(&"hurt", {
			"damage": _last_audio_hp - current_hp,
			"hp_before": _last_audio_hp,
			"hp_after": current_hp,
		})
	_last_audio_hp = current_hp
	if _sprite != null:
		_sprite.modulate = HIT_MODULATE
	_maybe_enter_phase_two(current_hp, max_hp)
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
	_stop_focus_attack_tell()
	_behavior_phase = &"defeated"
	_attack_timer = 0
	_attack_cooldown_timer = 0
	_pending_phase_two_hp_percentage = -1.0
	if _collision != null:
		_collision.deactivate_all_hitboxes()
		_collision.set_hurtbox_state(CollisionComponent.HURTBOX_STATE_GONE)
	if _sprite != null:
		_sprite.modulate = NORMAL_MODULATE
	_play_animation(ANIMATION_DEATH, true)
	collision_layer = 0
	collision_mask = 0
	_audio_chase_active = false
	_emit_boss2_audio_event(&"defeated", {
		"hp_after": 0,
	})
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


func _emit_boss2_audio_event(event_id: StringName, metadata: Dictionary = {}) -> void:
	var event_metadata: Dictionary = metadata.duplicate(true)
	event_metadata["boss_id"] = BOSS_ID
	event_metadata["entity_id"] = ENTITY_ID
	event_metadata["source"] = &"boss2_echo_guardian"
	event_metadata["position"] = global_position
	event_metadata["behavior_phase"] = _behavior_phase
	event_metadata["attack_phase"] = get_attack_phase()
	event_metadata["phase"] = _current_phase
	event_metadata["facing"] = _facing
	boss2_audio_event_requested.emit(event_id, event_metadata)


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
	if not _has_valid_attack_target() or _attack_cooldown_timer > 0:
		return false
	var to_target: Vector2 = _attack_target.global_position - global_position
	return absf(to_target.x) <= ATTACK_RANGE_PX and absf(to_target.y) <= 72.0


func _can_chase_attack_target() -> bool:
	if not _has_valid_attack_target():
		return false
	var to_target: Vector2 = _attack_target.global_position - global_position
	if absf(to_target.y) > 72.0:
		return false
	return absf(to_target.x) <= AGGRO_RANGE_PX and absf(to_target.x) > ATTACK_RANGE_PX


func _chase_attack_target() -> void:
	var direction: float = _direction_to_target()
	var distance_x: float = absf(_attack_target.global_position.x - global_position.x)
	var step_px: float = minf(_current_chase_step_px(), maxf(0.0, distance_x - ATTACK_RANGE_PX))
	var start_x: float = global_position.x
	global_position.x = clampf(global_position.x + direction * step_px, _arena_min_x(), _arena_max_x())
	velocity = Vector2((global_position.x - start_x) * 60.0, 0.0)
	_behavior_phase = &"chase"
	_update_sprite_facing()
	_play_animation(ANIMATION_RUN)
	if not _audio_chase_active:
		_audio_chase_active = true
		_emit_boss2_audio_event(&"chase_start", {
			"target_distance_x": distance_x,
			"arena_min_x": _arena_min_x(),
			"arena_max_x": _arena_max_x(),
		})


func _maybe_enter_phase_two(current_hp: int, max_hp: int) -> void:
	if _current_phase >= PHASE_TWO or max_hp <= 0:
		return
	var hp_percentage: float = float(current_hp) / float(max_hp)
	if hp_percentage > PHASE_TWO_HP_THRESHOLD:
		return
	if _is_attack_chain_active():
		_pending_phase_two_hp_percentage = hp_percentage
		return
	_enter_phase_two(hp_percentage)


func _apply_pending_phase_two_if_ready() -> void:
	if _pending_phase_two_hp_percentage < 0.0 or _current_phase >= PHASE_TWO or _is_attack_chain_active():
		return
	var hp_percentage: float = _pending_phase_two_hp_percentage
	_pending_phase_two_hp_percentage = -1.0
	_enter_phase_two(hp_percentage)


func _enter_phase_two(hp_percentage: float) -> void:
	var previous_phase: int = _current_phase
	_current_phase = PHASE_TWO
	_emit_boss2_audio_event(&"phase_transition", {
		"previous_phase": previous_phase,
		"phase": PHASE_TWO,
		"hp_percentage": hp_percentage,
	})
	on_boss_phase_transition_started.emit(
		ENTITY_ID,
		PHASE_TWO,
		_build_phase_transition_metadata(previous_phase, hp_percentage)
	)


func _build_phase_transition_metadata(previous_phase: int, hp_percentage: float) -> Dictionary:
	return {
		"boss_id": BOSS_ID,
		"display_name": DISPLAY_NAME,
		"previous_phase": previous_phase,
		"hp_threshold": PHASE_TWO_HP_THRESHOLD,
		"hp_percentage": clampf(hp_percentage, 0.0, 1.0),
		"world_position": global_position + Vector2(0, -56),
		"position": global_position,
		"source": &"boss2_echo_guardian",
		"attack_speed_modifier": 1.2,
		"chase_step_px": _current_chase_step_px(),
		"attack_cooldown_frames": _current_attack_cooldown_frames(),
	}


func _current_chase_step_px() -> float:
	if _current_phase >= PHASE_TWO:
		return PHASE_TWO_CHASE_STEP_PX
	return CHASE_STEP_PX


func _current_attack_cooldown_frames() -> int:
	if _current_phase >= PHASE_TWO:
		return PHASE_TWO_ATTACK_COOLDOWN_FRAMES
	return ATTACK_COOLDOWN_FRAMES


func _begin_focus_attack_tell(base_duration_frames: int) -> void:
	if _focus_attack_tell != null:
		_focus_attack_tell.call(
			"begin",
			base_duration_frames,
			_target_focus_mode_active
		)


func _advance_focus_attack_tell() -> void:
	if _focus_attack_tell != null:
		_focus_attack_tell.call("advance_frames")


func _stop_focus_attack_tell() -> void:
	if _focus_attack_tell != null:
		_focus_attack_tell.call("stop")


func _next_attack_startup_frames() -> int:
	return ATTACK_TELL_FRAMES + _focus_windup_extension_frames


func _is_attack_chain_active() -> bool:
	return (
		_state == State.ATTACK_TELL
		or _state == State.ATTACK_ACTIVE
		or _state == State.ATTACK_RECOVERY
	)


func _should_return_to_anchor() -> bool:
	return global_position.distance_to(_arena_anchor_position) > ANCHOR_REACHED_EPSILON_PX


func _return_to_anchor() -> void:
	var to_anchor: Vector2 = _arena_anchor_position - global_position
	if to_anchor.length() <= RETURN_STEP_PX:
		global_position = _arena_anchor_position
		velocity = Vector2.ZERO
		_behavior_phase = &"idle"
		_audio_chase_active = false
		_play_animation(ANIMATION_IDLE)
		return
	var direction: Vector2 = to_anchor.normalized()
	global_position += direction * RETURN_STEP_PX
	global_position.x = clampf(global_position.x, _arena_min_x(), _arena_max_x())
	velocity = direction * RETURN_STEP_PX * 60.0
	_facing = signf(direction.x) if absf(direction.x) > 0.01 else _facing
	_behavior_phase = &"return"
	_audio_chase_active = false
	_update_sprite_facing()
	_play_animation(ANIMATION_RUN)


func _arena_min_x() -> float:
	return _arena_anchor_position.x - ARENA_HALF_WIDTH_PX


func _arena_max_x() -> float:
	return _arena_anchor_position.x + ARENA_HALF_WIDTH_PX


func _direction_to_target() -> float:
	if not _has_valid_attack_target():
		return _facing
	var delta_x: float = _attack_target.global_position.x - global_position.x
	if absf(delta_x) > 1.0:
		_facing = signf(delta_x)
	return _facing


func _has_valid_attack_target() -> bool:
	return _encounter_active and _attack_target != null and is_instance_valid(_attack_target)


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
		return
	if _sprite.animation == animation_name and _sprite.is_playing():
		return
	_sprite.play(animation_name)


func _read_vector2(value: Variant, fallback: Vector2) -> Vector2:
	if value is Vector2:
		return value
	return fallback


func _read_int(value: Variant, fallback: int) -> int:
	if value is int or value is float:
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
