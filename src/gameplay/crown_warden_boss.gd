## Playable Boss4 core with two data-driven telegraphed attacks.
class_name CrownWardenBoss
extends CharacterBody2D

signal boss_health_changed(current_hp: int, max_hp: int)
signal boss_defeated
signal enemy_attack_landed(damage: int, hit_position: Vector2, is_crit: bool)
signal on_boss_phase_transition_started(entity_id: int, phase: int, metadata: Dictionary)

const ENTITY_ID: int = 2400
const BOSS_ID: StringName = &"boss_04_crown_warden"
const DEFAULT_DISPLAY_NAME: String = "Crown Warden"
const DEFAULT_MAX_HP: int = 160
const PHASE_ONE: int = 1
const PHASE_TWO: int = 2
const DEFAULT_PHASE_TWO_HP_THRESHOLD: float = 0.5
const PHASE_ONE_ATTACK_COOLDOWN_FRAMES: int = 48
const PHASE_TWO_ATTACK_COOLDOWN_FRAMES: int = 30
const DEFAULT_DIVE_STEP_PHASE_ONE: float = 8.0
const DEFAULT_DIVE_STEP_PHASE_TWO: float = 12.0
const PHASE_TRANSITION_DURATION_SEC: float = 2.5
const APPROACH_STEP_PX: float = 2.0
const APPROACH_STOP_DISTANCE_PX: float = 190.0
const ARENA_MIN_X: float = 320.0
const ARENA_MAX_X: float = 1160.0
const BOSS_HURTBOX_SIZE: Vector2 = Vector2(154, 170)
const COLLISION_COMPONENT_OFFSET: Vector2 = Vector2(0, -74)
const HIT_FLASH_FRAMES: int = 5
const ATTACK_HIT_FRAME: int = 99
const NORMAL_MODULATE: Color = Color.WHITE
const HIT_MODULATE: Color = Color(1.0, 0.82, 0.76, 1.0)
const PHASE_TWO_MODULATE: Color = Color(0.88, 0.82, 1.0, 1.0)
const TALON_DIVE_ID: StringName = &"talon_dive"
const WING_SWEEP_ID: StringName = &"wing_sweep"
const ANIMATION_IDLE: StringName = &"idle"
const ANIMATION_RUN: StringName = &"run"
const ANIMATION_HURT: StringName = &"hurt"
const ANIMATION_DEATH: StringName = &"death"
const ENEMY_STATS_PATH: String = "res://data/combat/enemy_stats.json"
const BOSS_CONFIG_PATH: String = "res://data/combat/boss_configs.json"
const HEALTH_COMPONENT_SCRIPT: Script = preload("res://src/core/health_component.gd")
const COLLISION_COMPONENT_SCRIPT: Script = preload("res://src/core/collision_component.gd")
const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")
const STATUS_EFFECT_COMPONENT_SCRIPT: Script = preload(
	"res://src/core/status_effect_component.gd"
)

enum State {
	IDLE,
	APPROACH,
	HIT,
	ATTACK_TELL,
	ATTACK_ACTIVE,
	ATTACK_RECOVERY,
	PHASE_TRANSITION,
	DEAD,
}

@onready var _sprite: AnimatedSprite2D = $Sprite

var _state: State = State.IDLE
var _facing: float = -1.0
var _hit_timer: int = 0
var _attack_timer: int = 0
var _attack_cooldown_timer: int = 0
var _attack_sequence_id: int = 0
var _next_pattern_index: int = 0
var _current_pattern_id: StringName = &""
var _defeated: bool = false
var _current_phase: int = PHASE_ONE
var _phase_two_pending: bool = false
var _phase_transition_remaining_sec: float = 0.0
var _phase_transition_start_count: int = 0
var _last_phase_transition_metadata: Dictionary = {}
var _autonomous_attacks_enabled: bool = true
var _attack_target: Node = null
var _damage_calculator_adapter: Object = null
var _last_hit_metadata: Dictionary = {}
var _last_enemy_attack_metadata: Dictionary = {}
var _attack_patterns: Dictionary = {}
var _boss_config: Dictionary = {}
var _configured_max_hp: int = DEFAULT_MAX_HP
var _configured_display_name: String = DEFAULT_DISPLAY_NAME
var _configured_phase_two_threshold: float = DEFAULT_PHASE_TWO_HP_THRESHOLD
var _configured_phase_two_transition_animation: StringName = ANIMATION_HURT
var _loaded_enemy_stats: bool = false
var _loaded_boss_config: bool = false
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
	_load_data_config()
	_ensure_core_components()
	_setup_core_components()
	_play_animation(ANIMATION_IDLE, true)
	boss_health_changed.emit(get_current_hp(), get_max_hp())


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
			_process_idle()
		State.APPROACH:
			_process_approach()
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


func set_autonomous_attacks_enabled(enabled: bool) -> void:
	_autonomous_attacks_enabled = enabled
	if not enabled and _state == State.APPROACH:
		_state = State.IDLE
		velocity = Vector2.ZERO
		_play_animation(ANIMATION_IDLE, true)


## Explicit pattern requests bypass the autonomous cooldown for deterministic scripts/tests.
func request_attack(pattern_id: StringName = &"") -> bool:
	var explicit_request: bool = pattern_id != &""
	if (
		_defeated
		or _state != State.IDLE
		or (not explicit_request and _attack_cooldown_timer > 0)
		or not _has_valid_attack_target()
	):
		return false
	var selected_id: StringName = pattern_id if explicit_request else _next_pattern_id()
	if not _attack_patterns.has(String(selected_id)):
		return false
	_current_pattern_id = selected_id
	_face_attack_target()
	_attack_sequence_id += 1
	_attack_timer = _current_pattern_int("startup_frames", 1)
	_attack_cooldown_timer = 0
	_state = State.ATTACK_TELL
	if _collision != null:
		_collision.deactivate_all_hitboxes()
	_play_animation(_tell_animation_for(_current_pattern_id), true)
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
	_current_pattern_id = &""
	_next_pattern_index = 0
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
	boss_health_changed.emit(get_current_hp(), get_max_hp())


func mark_defeated_from_progress() -> void:
	_defeated = true
	_state = State.DEAD
	_phase_two_pending = false
	_phase_transition_remaining_sec = 0.0
	_attack_timer = 0
	_attack_cooldown_timer = 0
	velocity = Vector2.ZERO
	if _health != null:
		_health.configure(ENTITY_ID, get_max_hp(), 0, 0, 0, false)
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
	return _configured_display_name


func get_current_hp() -> int:
	return _health.get_current_hp() if _health != null else get_max_hp()


func get_max_hp() -> int:
	return _configured_max_hp


func get_current_phase() -> int:
	return _current_phase


func get_current_attack_startup_frames() -> int:
	return _current_pattern_int("startup_frames", 0)


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
		"animation": String(_configured_phase_two_transition_animation),
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


func get_config_diagnostics() -> Dictionary:
	return {
		"loaded_from_data": _loaded_enemy_stats and _loaded_boss_config,
		"loaded_enemy_stats": _loaded_enemy_stats,
		"loaded_boss_config": _loaded_boss_config,
		"boss_id": String(BOSS_ID),
		"display_name": _configured_display_name,
		"max_hp": _configured_max_hp,
		"pattern_ids": _ordered_pattern_ids(),
		"phase_count": Array(_boss_config.get("phases", [])).size(),
		"phase_two_threshold": _configured_phase_two_threshold,
		"phase_transition_duration_sec": PHASE_TRANSITION_DURATION_SEC,
		"phase_transition_animation": String(
			_configured_phase_two_transition_animation
		),
		"defeat_reward_ability": String(Dictionary(
			_boss_config.get("defeat_rewards", {})
		).get("ability_unlock", "")),
	}


func get_attack_diagnostics() -> Dictionary:
	var hitbox_id: StringName = _current_hitbox_id()
	return {
		"attack_phase": String(get_attack_phase()),
		"current_attack_id": String(_current_pattern_id),
		"animation": String(_sprite.animation) if _sprite != null else "",
		"current_phase": _current_phase,
		"phase_two_pending": _phase_two_pending,
		"phase_transition_active": is_phase_transition_active(),
		"phase_transition_remaining_sec": _phase_transition_remaining_sec,
		"attack_sequence_id": _attack_sequence_id,
		"hitbox_id": String(hitbox_id),
		"hitbox_active": (
			_collision != null
			and hitbox_id != &""
			and _collision.is_hitbox_active(hitbox_id)
		),
		"cooldown_frames": _current_attack_cooldown_frames(),
		"cooldown_timer": _attack_cooldown_timer,
		"dive_step_px": _current_dive_step_px(),
		"facing": _facing,
		"defeated": _defeated,
		"autonomous_attacks_enabled": _autonomous_attacks_enabled,
		"locomotion_state": "approach" if _state == State.APPROACH else "idle",
		"arena_anchor_position": _arena_anchor_position,
	}


func _process_idle() -> void:
	velocity = Vector2.ZERO
	_update_sprite_facing()
	_play_animation(ANIMATION_IDLE)
	if (
		_autonomous_attacks_enabled
		and _attack_cooldown_timer > 0
		and _should_approach_target()
	):
		_state = State.APPROACH
		_process_approach()
		return
	if (
		_autonomous_attacks_enabled
		and _attack_cooldown_timer <= 0
		and _has_valid_attack_target()
	):
		request_attack()


func _process_approach() -> void:
	if (
		not _autonomous_attacks_enabled
		or _attack_cooldown_timer <= 0
		or not _should_approach_target()
	):
		_state = State.IDLE
		velocity = Vector2.ZERO
		_play_animation(ANIMATION_IDLE, true)
		return
	_face_attack_target()
	var start_x: float = global_position.x
	var target_x: float = (_attack_target as Node2D).global_position.x
	global_position.x = clampf(
		move_toward(global_position.x, target_x, APPROACH_STEP_PX),
		ARENA_MIN_X,
		ARENA_MAX_X
	)
	velocity = Vector2((global_position.x - start_x) * 60.0, 0.0)
	_play_animation(ANIMATION_RUN)


func _should_approach_target() -> bool:
	return (
		_has_valid_attack_target()
		and absf(
			(_attack_target as Node2D).global_position.x - global_position.x
		) > APPROACH_STOP_DISTANCE_PX
	)


func _process_hit() -> void:
	velocity = Vector2.ZERO
	_hit_timer -= 1
	if _hit_timer > 0:
		return
	_state = State.IDLE
	if _sprite != null:
		_sprite.modulate = (
			PHASE_TWO_MODULATE if _current_phase == PHASE_TWO else NORMAL_MODULATE
		)
	_play_animation(ANIMATION_IDLE, true)
	_apply_pending_phase_two_if_ready()


func _process_attack_tell() -> void:
	velocity = Vector2.ZERO
	_update_sprite_facing()
	_play_animation(_tell_animation_for(_current_pattern_id))
	_attack_timer -= 1
	if _attack_timer <= 0:
		_enter_attack_active()


func _enter_attack_active() -> void:
	_state = State.ATTACK_ACTIVE
	_attack_timer = _current_pattern_int("active_frames", 1)
	_play_animation(_active_animation_for(_current_pattern_id), true)
	if _collision == null:
		return
	var hitbox_id: StringName = _current_hitbox_id()
	var offset: Vector2 = _current_pattern_vector("hitbox_offset", Vector2.ZERO)
	var component_local_offset: Vector2 = (
		Vector2(_facing * offset.x, offset.y) - _collision.position
	)
	_collision.activate_hitbox(
		hitbox_id,
		_attack_timer,
		component_local_offset,
		_current_pattern_vector("hitbox_size", Vector2(64, 48)),
		_build_attack_metadata()
	)


func _process_attack_active() -> void:
	var step_px: float = _current_pattern_step_px()
	var start_x: float = global_position.x
	if step_px > 0.0:
		global_position.x = clampf(
			global_position.x + _facing * step_px,
			ARENA_MIN_X,
			ARENA_MAX_X
		)
	velocity = Vector2((global_position.x - start_x) * 60.0, 0.0)
	_play_animation(_active_animation_for(_current_pattern_id))
	_attack_timer -= 1
	if _attack_timer <= 0:
		_enter_attack_recovery()


func _enter_attack_recovery() -> void:
	_state = State.ATTACK_RECOVERY
	_attack_timer = _current_pattern_int("recovery_frames", 1)
	velocity = Vector2.ZERO
	if _collision != null:
		_collision.deactivate_hitbox(_current_hitbox_id())


func _process_attack_recovery() -> void:
	velocity = Vector2.ZERO
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
	_health.configure(ENTITY_ID, get_max_hp(), get_max_hp(), 0, 0, false)
	_health.configure_boss_phases([_configured_phase_two_threshold])
	if not _health.on_hp_changed.is_connected(_on_core_hp_changed):
		_health.on_hp_changed.connect(_on_core_hp_changed)
	if not _health.on_death.is_connected(_on_core_death):
		_health.on_death.connect(_on_core_death)
	_collision.position = COLLISION_COMPONENT_OFFSET
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
	if float(current_hp) / float(max_hp) > _configured_phase_two_threshold:
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
	if _collision != null:
		_collision.deactivate_all_hitboxes()
		_collision.set_hurtbox_state(CollisionComponent.HURTBOX_STATE_GONE)
	if _sprite != null:
		_sprite.modulate = PHASE_TWO_MODULATE
	_play_animation(_configured_phase_two_transition_animation, true)
	_last_phase_transition_metadata = {
		"boss_id": BOSS_ID,
		"display_name": _configured_display_name,
		"previous_phase": PHASE_ONE,
		"hp_percentage": float(get_current_hp()) / float(get_max_hp()),
		"transition_duration_sec": PHASE_TRANSITION_DURATION_SEC,
		"transition_animation": String(
			_configured_phase_two_transition_animation
		),
		"world_position": global_position,
		"position": global_position,
		"dive_step_px": _current_dive_step_px(),
		"attack_cooldown_frames": PHASE_TWO_ATTACK_COOLDOWN_FRAMES,
	}
	on_boss_phase_transition_started.emit(
		ENTITY_ID,
		PHASE_TWO,
		_last_phase_transition_metadata.duplicate(true)
	)


func _process_phase_transition(delta_sec: float) -> void:
	velocity = Vector2.ZERO
	_play_animation(_configured_phase_two_transition_animation)
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


func _load_data_config() -> void:
	_attack_patterns = _build_default_attack_patterns()
	var enemy_entry: Dictionary = _read_data_entry(
		&"enemy_stats",
		BOSS_ID,
		ENEMY_STATS_PATH
	)
	if not enemy_entry.is_empty():
		var parsed_patterns: Dictionary = {}
		for pattern_value: Variant in Array(enemy_entry.get("attack_patterns", [])):
			if not pattern_value is Dictionary:
				continue
			var normalized: Dictionary = _normalize_attack_pattern(
				Dictionary(pattern_value)
			)
			var pattern_id: String = String(normalized.get("pattern_id", ""))
			if pattern_id != "":
				parsed_patterns[pattern_id] = normalized
		if (
			parsed_patterns.has(String(TALON_DIVE_ID))
			and parsed_patterns.has(String(WING_SWEEP_ID))
		):
			_attack_patterns = parsed_patterns
			_configured_max_hp = maxi(1, int(enemy_entry.get(
				"max_hp",
				DEFAULT_MAX_HP
			)))
			_loaded_enemy_stats = true
	_boss_config = _read_data_entry(&"boss_configs", BOSS_ID, BOSS_CONFIG_PATH)
	if (
		StringName(String(_boss_config.get("boss_id", ""))) == BOSS_ID
		and Array(_boss_config.get("phases", [])).size() == 2
	):
		_configured_max_hp = maxi(1, int(_boss_config.get(
			"max_hp",
			_configured_max_hp
		)))
		_configured_display_name = String(_boss_config.get(
			"display_name",
			DEFAULT_DISPLAY_NAME
		))
		for phase_value: Variant in Array(_boss_config.get("phases", [])):
			if not phase_value is Dictionary:
				continue
			var phase: Dictionary = Dictionary(phase_value)
			if int(phase.get("phase_id", 0)) == PHASE_TWO:
				_configured_phase_two_threshold = clampf(
					float(phase.get(
						"hp_threshold",
						DEFAULT_PHASE_TWO_HP_THRESHOLD
					)),
					0.01,
					0.99
				)
				var transition_animation := StringName(String(phase.get(
					"transition_animation",
					String(ANIMATION_HURT)
				)))
				if transition_animation != &"":
					_configured_phase_two_transition_animation = transition_animation
		_loaded_boss_config = true


func _read_data_entry(
	domain: StringName,
	entry_id: StringName,
	fallback_path: String
) -> Dictionary:
	var data_manager: Node = get_node_or_null("/root/DataManager")
	if data_manager != null and data_manager.has_method("get_entry"):
		var entry_value: Variant = data_manager.call("get_entry", domain, entry_id)
		if entry_value is Dictionary:
			return Dictionary(entry_value).duplicate(true)
	if not FileAccess.file_exists(fallback_path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(fallback_path))
	if not parsed is Dictionary:
		return {}
	return Dictionary(Dictionary(parsed).get("entries", {})).get(
		String(entry_id),
		{}
	) as Dictionary


func _normalize_attack_pattern(raw: Dictionary) -> Dictionary:
	var hitbox: Dictionary = Dictionary(raw.get("hitbox_config", {}))
	return {
		"pattern_id": String(raw.get("pattern_id", "")),
		"startup_frames": maxi(1, int(raw.get("startup_frames", 1))),
		"active_frames": maxi(1, int(raw.get("active_frames", 1))),
		"recovery_frames": maxi(1, int(raw.get("recovery_frames", 1))),
		"damage": maxi(1, int(raw.get("damage", 1))),
		"hitbox_id": String(hitbox.get("hitbox_id", "")),
		"hitbox_offset": _read_config_vector2(hitbox.get("offset", {}), Vector2.ZERO),
		"hitbox_size": _read_config_vector2(hitbox.get("size", {}), Vector2(64, 48)),
		"active_step_px_phase_1": maxf(0.0, float(raw.get(
			"active_step_px_phase_1",
			0.0
		))),
		"active_step_px_phase_2": maxf(0.0, float(raw.get(
			"active_step_px_phase_2",
			0.0
		))),
	}


func _build_default_attack_patterns() -> Dictionary:
	return {
		String(TALON_DIVE_ID): {
			"pattern_id": String(TALON_DIVE_ID),
			"startup_frames": 20,
			"active_frames": 8,
			"recovery_frames": 20,
			"damage": 18,
			"hitbox_id": "crown_warden_talon_dive",
			"hitbox_offset": Vector2(92, -34),
			"hitbox_size": Vector2(140, 78),
			"active_step_px_phase_1": DEFAULT_DIVE_STEP_PHASE_ONE,
			"active_step_px_phase_2": DEFAULT_DIVE_STEP_PHASE_TWO,
		},
		String(WING_SWEEP_ID): {
			"pattern_id": String(WING_SWEEP_ID),
			"startup_frames": 24,
			"active_frames": 10,
			"recovery_frames": 18,
			"damage": 14,
			"hitbox_id": "crown_warden_wing_sweep",
			"hitbox_offset": Vector2(74, -50),
			"hitbox_size": Vector2(220, 120),
			"active_step_px_phase_1": 0.0,
			"active_step_px_phase_2": 0.0,
		},
	}


func _ordered_pattern_ids() -> Array[String]:
	var result: Array[String] = []
	for pattern_id: StringName in [TALON_DIVE_ID, WING_SWEEP_ID]:
		if _attack_patterns.has(String(pattern_id)):
			result.append(String(pattern_id))
	return result


func _next_pattern_id() -> StringName:
	var ids: Array[String] = _ordered_pattern_ids()
	if ids.is_empty():
		return &""
	var selected := StringName(ids[_next_pattern_index % ids.size()])
	_next_pattern_index = (_next_pattern_index + 1) % ids.size()
	return selected


func _current_pattern() -> Dictionary:
	return Dictionary(_attack_patterns.get(String(_current_pattern_id), {}))


func _current_pattern_int(field: String, fallback: int) -> int:
	return maxi(0, int(_current_pattern().get(field, fallback)))


func _current_pattern_vector(field: String, fallback: Vector2) -> Vector2:
	var value: Variant = _current_pattern().get(field, fallback)
	return value as Vector2 if value is Vector2 else fallback


func _current_pattern_step_px() -> float:
	if _current_pattern_id != TALON_DIVE_ID:
		return 0.0
	return _current_dive_step_px()


func _current_dive_step_px() -> float:
	var dive: Dictionary = Dictionary(_attack_patterns.get(String(TALON_DIVE_ID), {}))
	return float(dive.get(
		"active_step_px_phase_2"
		if _current_phase == PHASE_TWO
		else "active_step_px_phase_1",
		DEFAULT_DIVE_STEP_PHASE_TWO
		if _current_phase == PHASE_TWO
		else DEFAULT_DIVE_STEP_PHASE_ONE
	))


func _current_hitbox_id() -> StringName:
	return StringName(String(_current_pattern().get("hitbox_id", "")))


func _current_attack_cooldown_frames() -> int:
	return (
		PHASE_TWO_ATTACK_COOLDOWN_FRAMES
		if _current_phase == PHASE_TWO
		else PHASE_ONE_ATTACK_COOLDOWN_FRAMES
	)


func _tell_animation_for(pattern_id: StringName) -> StringName:
	return &"wing_sweep_tell" if pattern_id == WING_SWEEP_ID else &"talon_dive_tell"


func _active_animation_for(pattern_id: StringName) -> StringName:
	return &"wing_sweep" if pattern_id == WING_SWEEP_ID else &"talon_dive"


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
	_facing = (
		-1.0
		if (_attack_target as Node2D).global_position.x < global_position.x
		else 1.0
	)
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


func _build_attack_metadata() -> Dictionary:
	var pattern: Dictionary = _current_pattern()
	var hitbox_id: StringName = _current_hitbox_id()
	return {
		"source": BOSS_ID,
		"attack_type": &"light",
		"weapon_id": hitbox_id,
		"combo_index": 0,
		"hit_frame": ATTACK_HIT_FRAME,
		"attack_power": 0,
		"enemy_defense": 0,
		"attack_sequence_id": _attack_sequence_id,
		"phase": _current_phase,
		"injected_damage_params": {
			"entries": {
				String(hitbox_id): {
					"weapon_base": int(pattern.get("damage", 1)),
					"combo_multipliers": {"0": 1.0},
					"special_move": {"multiplier": 1.0, "hits": 1},
				},
			},
		},
	}


func _read_config_vector2(value: Variant, fallback: Vector2) -> Vector2:
	if not value is Dictionary:
		return fallback
	var data: Dictionary = Dictionary(value)
	return Vector2(
		float(data.get("x", fallback.x)),
		float(data.get("y", fallback.y))
	)
