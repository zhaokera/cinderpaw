## Rat King runtime boss shell for the current playable MainScene.
##
## This node preserves the existing MainScene enemy contract while mounting the
## real Rat King AnimatedSprite2D surface and BossConfigComponent phase hooks.
class_name RatKingBoss
extends CharacterBody2D

signal enemy_health_changed(current_hp: int, max_hp: int)
signal enemy_defeated
signal enemy_attack_landed(damage: int, hit_position: Vector2, is_crit: bool)
signal phase_one_intro_started(entity_id: int, metadata: Dictionary)
signal phase_one_intro_finished(entity_id: int, metadata: Dictionary)

const GRAVITY: float = 800.0
const BOSS_ENTITY_ID: int = 2
const BOSS_ID: StringName = &"boss_01_rat_king"
const BOSS_DISPLAY_NAME: String = "垃圾桶鼠王"
const FALLBACK_MAX_HP: int = 300
const HIT_FLASH_FRAMES: int = 6
const CONTACT_DAMAGE_COOLDOWN_FRAMES: int = 45
const ATTACK_RANGE_PX: float = 110.0
const CHARGE_PATTERN_ID: StringName = &"charge"
const DEFAULT_CHARGE_LUNGE_SPEED: float = 720.0
const DEFAULT_CHARGE_ACQUIRE_RANGE_PX: float = 320.0
const ATTACK_TELL_FRAMES: int = 8
const ATTACK_ACTIVE_FRAMES: int = 4
const ATTACK_RECOVERY_FRAMES: int = 14
const ATTACK_COOLDOWN_FRAMES: int = 28
const ATTACK_HITBOX_ID: StringName = &"rat_king_claw"
const ATTACK_HITBOX_SIZE: Vector2 = Vector2(72, 34)
const ATTACK_HITBOX_OFFSET: Vector2 = Vector2(54, -42)
const RAT_KING_CLAW_DAMAGE: int = 12
const RAT_KING_CLAW_HIT_FRAME: int = 99
const BOSS_HURTBOX_SIZE: Vector2 = Vector2(72, 86)
const NORMAL_MODULATE: Color = Color.WHITE
const HIT_MODULATE: Color = Color(1.0, 0.88, 0.88, 1.0)
const ANIMATION_IDLE: StringName = &"idle"
const ANIMATION_PHASE_ONE_INTRO: StringName = &"phase_1_intro"
const ANIMATION_ATTACK_TELL: StringName = &"attack_tell"
const ANIMATION_ATTACK: StringName = &"attack"
const ANIMATION_HURT: StringName = &"hurt"
const ANIMATION_DEATH: StringName = &"death"
const ANIMATION_CHARGE: StringName = &"charge"
const ANIMATION_CLAW_SWIPE: StringName = &"claw_swipe"
const ANIMATION_SUMMON_MINION: StringName = &"summon_minion"
const ANIMATION_SLAM: StringName = &"slam"
const ANIMATION_BERSERK_COMBO: StringName = &"berserk_combo"
const ATTACK_PATTERN_TO_ANIMATION: Dictionary = {
	&"charge": ANIMATION_CHARGE,
	&"claw_swipe": ANIMATION_CLAW_SWIPE,
	&"summon_minion": ANIMATION_SUMMON_MINION,
	&"slam": ANIMATION_SLAM,
	&"berserk_combo": ANIMATION_BERSERK_COMBO,
}
const HEALTH_COMPONENT_SCRIPT_PATH: String = "res://src/core/health_component.gd"
const COLLISION_COMPONENT_SCRIPT_PATH: String = "res://src/core/collision_component.gd"
const COMBAT_COMPONENT_SCRIPT_PATH: String = "res://src/core/combat_component.gd"
const STATUS_EFFECT_COMPONENT_SCRIPT_PATH: String = "res://src/core/status_effect_component.gd"
const BOSS_CONFIG_COMPONENT_SCRIPT_PATH: String = "res://src/core/boss_config_component.gd"
const AI_COMPONENT_SCRIPT_PATH: String = "res://src/core/ai_component.gd"

enum State {
	IDLE,
	INTRO,
	HIT,
	ATTACK_TELL,
	ATTACK_ACTIVE,
	ATTACK_RECOVERY,
	PHASE_TRANSITION,
	DEAD,
}

var _state: State = State.IDLE
var _facing: float = -1.0
var _hit_timer: int = 0
var _attack_timer: int = 0
var _attack_cooldown_timer: int = 0
var _contact_damage_timer: int = 0
var _phase_one_intro_played_this_attempt: bool = false
var _phase_one_intro_duration_sec: float = 0.0
var _phase_one_intro_remaining_sec: float = 0.0
var _phase_one_intro_started_count: int = 0
var _phase_one_intro_completed_count: int = 0
var _phase_one_intro_cancelled_count: int = 0
var _last_enemy_attack_metadata: Dictionary = {}
var _active_attack_metadata: Dictionary = {}
var _attack_target: Node = null
var _charge_lunge_speed: float = DEFAULT_CHARGE_LUNGE_SPEED
var _charge_acquire_range_px: float = DEFAULT_CHARGE_ACQUIRE_RANGE_PX
var _charge_config_loaded_from_data: bool = false
var _charge_locked_direction: float = 0.0
var _charge_motion_active: bool = false
var _charge_blocked: bool = false
var _charge_distance_px: float = 0.0
var _charge_collision_count: int = 0
var _charge_stop_reason: StringName = &"idle"
var _health: HealthComponent = null
var _collision: CollisionComponent = null
var _combat: CombatComponent = null
var _status_effects: StatusEffectComponent = null
var _boss_config: BossConfigComponent = null
var _ai: AIComponent = null
var _damage_calculator_adapter: Object = null
var _summon_adapter: Object = null
var _scene_adapter: Object = null
var _reward_adapter: Object = null
var _health_component_script: Script = load(HEALTH_COMPONENT_SCRIPT_PATH) as Script
var _collision_component_script: Script = load(COLLISION_COMPONENT_SCRIPT_PATH) as Script
var _combat_component_script: Script = load(COMBAT_COMPONENT_SCRIPT_PATH) as Script
var _status_effect_component_script: Script = load(STATUS_EFFECT_COMPONENT_SCRIPT_PATH) as Script
var _boss_config_component_script: Script = load(BOSS_CONFIG_COMPONENT_SCRIPT_PATH) as Script
var _ai_component_script: Script = load(AI_COMPONENT_SCRIPT_PATH) as Script

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _focus_attack_tell: Node = $FocusAttackTell


func _ready() -> void:
	_load_charge_locomotion_config()
	_ensure_core_components()
	_setup_core_components()
	_play_character_animation(ANIMATION_IDLE, true)
	enemy_health_changed.emit(get_current_hp(), get_max_hp())


func _physics_process(delta: float) -> void:
	_contact_damage_timer = maxi(_contact_damage_timer - 1, 0)
	_attack_cooldown_timer = maxi(_attack_cooldown_timer - 1, 0)
	if _status_effects != null:
		_status_effects.advance_time(delta)
	advance_boss_runtime(delta)
	match _state:
		State.IDLE:
			_process_idle(delta)
		State.INTRO:
			_process_phase_one_intro(delta)
		State.HIT:
			_process_hit(delta)
		State.ATTACK_TELL:
			_process_attack_tell(delta)
		State.ATTACK_ACTIVE:
			_process_attack_active(delta)
		State.ATTACK_RECOVERY:
			_process_attack_recovery(delta)
		State.PHASE_TRANSITION:
			_process_phase_transition(delta)
		State.DEAD:
			return


## Starts the authored Phase-I entrance once for the current Boss attempt.
func request_phase_one_intro() -> bool:
	if _phase_one_intro_played_this_attempt or _state != State.IDLE:
		return false
	if is_defeated() or get_current_phase() != 1:
		return false
	var duration_sec: float = _get_animation_duration_sec(ANIMATION_PHASE_ONE_INTRO)
	if duration_sec <= 0.0:
		return false
	_phase_one_intro_played_this_attempt = true
	_phase_one_intro_duration_sec = duration_sec
	_phase_one_intro_remaining_sec = duration_sec
	_phase_one_intro_started_count += 1
	_state = State.INTRO
	_stop_focus_attack_tell()
	_hit_timer = 0
	_attack_timer = 0
	_active_attack_metadata.clear()
	velocity = Vector2.ZERO
	if _collision != null:
		_collision.deactivate_all_hitboxes()
	_sprite.modulate = NORMAL_MODULATE
	_play_character_animation(ANIMATION_PHASE_ONE_INTRO, true)
	phase_one_intro_started.emit(BOSS_ENTITY_ID, {
		"boss_id": BOSS_ID,
		"display_name": BOSS_DISPLAY_NAME,
		"animation": ANIMATION_PHASE_ONE_INTRO,
		"duration_sec": duration_sec,
		"frame_count": _sprite.sprite_frames.get_frame_count(ANIMATION_PHASE_ONE_INTRO),
	})
	return true


func request_attack() -> bool:
	if _should_use_charge_gap_closer():
		return request_attack_pattern(CHARGE_PATTERN_ID)
	if _ai != null and _ai.has_attack_patterns():
		var selected_pattern: Dictionary = _ai.select_attack_pattern()
		var pattern_id: StringName = StringName(selected_pattern.get("pattern_id", &""))
		if pattern_id != &"":
			return request_attack_pattern(pattern_id)
	if _state != State.IDLE or _attack_cooldown_timer > 0:
		return false
	_face_attack_target()
	velocity = Vector2.ZERO
	_state = State.ATTACK_TELL
	_attack_timer = ATTACK_TELL_FRAMES
	_play_character_animation(ANIMATION_ATTACK_TELL, true)
	_begin_focus_attack_tell(ATTACK_TELL_FRAMES)
	return true


func request_attack_pattern(pattern_id: StringName) -> bool:
	if _ai == null or _state != State.IDLE or _attack_cooldown_timer > 0:
		return false
	if not _ai.start_attack_by_pattern_id(pattern_id):
		return false
	_face_attack_target()
	_prepare_charge_locomotion(pattern_id)
	velocity = Vector2.ZERO
	_active_attack_metadata.clear()
	_state = State.ATTACK_TELL
	_attack_timer = _ai.get_effective_attack_startup_frames()
	_play_character_animation(get_attack_animation_for_pattern(pattern_id), true)
	_begin_focus_attack_tell(_ai.get_current_attack_base_startup_frames())
	return true


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


func advance_boss_runtime(delta_sec: float) -> void:
	var safe_delta: float = maxf(0.0, delta_sec)
	if _state == State.INTRO:
		_phase_one_intro_remaining_sec = maxf(
			0.0,
			_phase_one_intro_remaining_sec - safe_delta
		)
		if _phase_one_intro_remaining_sec <= 0.0:
			_complete_phase_one_intro()
		return
	if _boss_config == null:
		return
	var was_transition_active: bool = _boss_config.is_transition_active()
	_boss_config.advance_transition(safe_delta)
	_boss_config.advance_time(safe_delta)
	if was_transition_active and not _boss_config.is_transition_active() and _state == State.PHASE_TRANSITION:
		_state = State.IDLE
		_sprite.modulate = NORMAL_MODULATE
		_play_character_animation(ANIMATION_IDLE, true)


func take_damage() -> void:
	apply_damage(RAT_KING_CLAW_DAMAGE, {
		"source": &"legacy_player_hitbox",
		"damage_type": &"slash",
	})


func apply_damage(final_damage: int, metadata: Dictionary = {}) -> void:
	if _state == State.DEAD or _state == State.INTRO or _health == null:
		return
	if _boss_config != null and _boss_config.is_invulnerable():
		return
	_health.apply_damage(final_damage, metadata)


func break_shield() -> bool:
	if _health == null:
		return false
	return _health.break_shield()


func apply_status(target_id: int, effect_id: StringName, source_id: int = 0) -> bool:
	if _status_effects == null:
		return false
	return _status_effects.apply_status(target_id, effect_id, source_id)


func set_attack_target(target: Node) -> void:
	_attack_target = target
	if _combat != null:
		_combat.set_health_adapter(_attack_target)


func set_damage_calculator_adapter(damage_calculator_adapter: Object) -> void:
	_damage_calculator_adapter = damage_calculator_adapter
	if _combat != null:
		_combat.set_damage_calculator_adapter(_damage_calculator_adapter)


func set_summon_adapter(summon_adapter: Object) -> void:
	_summon_adapter = summon_adapter
	if _boss_config != null:
		_boss_config.set_summon_adapter(_summon_adapter)


func set_scene_adapter(scene_adapter: Object) -> void:
	_scene_adapter = scene_adapter
	if _boss_config != null:
		_boss_config.set_scene_adapter(_scene_adapter)


func set_reward_adapter(reward_adapter: Object) -> void:
	_reward_adapter = reward_adapter
	if _boss_config != null:
		_boss_config.set_reward_adapter(_reward_adapter)


func apply_boss_phase(
	phase_id: int,
	attack_patterns: Array,
	attack_speed_modifier: float
) -> void:
	if _ai == null:
		return
	_ai.apply_boss_phase(phase_id, attack_patterns, attack_speed_modifier)


func activate_hitbox(
	hitbox_id: StringName,
	duration_frames: int,
	offset: Vector2,
	size: Vector2,
	attack_metadata: Dictionary = {}
) -> void:
	if _collision == null:
		return
	var oriented_offset: Vector2 = Vector2(_facing * absf(offset.x), offset.y)
	var metadata: Dictionary = _build_attack_metadata(attack_metadata, hitbox_id)
	_active_attack_metadata = metadata.duplicate(true)
	_collision.activate_hitbox(
		hitbox_id,
		duration_frames,
		oriented_offset,
		size,
		metadata
	)


func get_current_hp() -> int:
	if _health == null:
		return FALLBACK_MAX_HP
	return _health.get_current_hp()


func get_max_hp() -> int:
	if _health == null:
		return FALLBACK_MAX_HP
	return _health.get_max_hp()


func get_entity_id() -> int:
	return BOSS_ENTITY_ID


func get_current_boss_id() -> StringName:
	if _boss_config != null and _boss_config.has_boss_config():
		return _boss_config.get_boss_id()
	return BOSS_ID


func get_display_name() -> String:
	if _boss_config != null and _boss_config.has_boss_config():
		return _boss_config.get_display_name()
	return BOSS_DISPLAY_NAME


func get_current_phase() -> int:
	if _boss_config == null:
		return 1
	return _boss_config.get_current_phase()


func get_attack_phase() -> StringName:
	if _ai != null and _ai.get_attack_phase() != &"none":
		return _ai.get_attack_phase()
	match _state:
		State.ATTACK_TELL:
			return &"startup"
		State.ATTACK_ACTIVE:
			return &"active"
		State.ATTACK_RECOVERY:
			return &"recovery"
		_:
			return &"none"


func get_health_component() -> HealthComponent:
	return _health


func get_collision_component() -> CollisionComponent:
	return _collision


func get_combat_component() -> CombatComponent:
	return _combat


func get_status_effect_component() -> StatusEffectComponent:
	return _status_effects


func get_ai_component() -> AIComponent:
	return _ai


func get_boss_config_component() -> BossConfigComponent:
	return _boss_config


func get_available_attack_pattern_ids() -> Array:
	if _ai == null:
		return []
	return _ai.get_current_attack_pattern_ids()


func get_current_attack_pattern_id() -> StringName:
	if _ai == null:
		return &""
	return _ai.get_current_attack_pattern_id()


func get_current_attack_startup_frames() -> int:
	if _ai == null:
		return ATTACK_TELL_FRAMES
	return _ai.get_effective_attack_startup_frames()


func set_target_focus_mode(active: bool, metadata: Dictionary = {}) -> bool:
	if _ai == null:
		return false
	_ai.set_target_focus_mode(active, metadata)
	return true


func get_focus_windup_diagnostics() -> Dictionary:
	if _ai == null:
		return {
			"focus_mode_active": false,
			"base_startup_frames": ATTACK_TELL_FRAMES,
			"windup_extension_frames": 0,
			"current_attack_startup_frames": ATTACK_TELL_FRAMES,
			"attack_phase": String(get_attack_phase()),
		}
	return {
		"focus_mode_active": _ai.is_target_focus_mode_active(),
		"base_startup_frames": _ai.get_current_attack_base_startup_frames(),
		"windup_extension_frames": _ai.get_focus_windup_extension_frames(),
		"current_attack_startup_frames": get_current_attack_startup_frames(),
		"attack_phase": String(get_attack_phase()),
		"pattern_id": String(get_current_attack_pattern_id()),
	}


func get_focus_attack_tell_diagnostics() -> Dictionary:
	if _focus_attack_tell == null:
		return {}
	return Dictionary(_focus_attack_tell.call("get_diagnostics"))


## Returns the deterministic Phase-I entrance state for tests and MCP inspection.
func get_phase_one_intro_diagnostics() -> Dictionary:
	var frames: SpriteFrames = _sprite.sprite_frames if _sprite != null else null
	var has_intro: bool = frames != null and frames.has_animation(ANIMATION_PHASE_ONE_INTRO)
	return {
		"active": _state == State.INTRO,
		"played_this_attempt": _phase_one_intro_played_this_attempt,
		"animation": String(_sprite.animation) if _sprite != null else "",
		"frame": _sprite.frame if _sprite != null else -1,
		"playing": _sprite.is_playing() if _sprite != null else false,
		"frame_count": frames.get_frame_count(ANIMATION_PHASE_ONE_INTRO) if has_intro else 0,
		"loop": frames.get_animation_loop(ANIMATION_PHASE_ONE_INTRO) if has_intro else false,
		"speed_fps": frames.get_animation_speed(ANIMATION_PHASE_ONE_INTRO) if has_intro else 0.0,
		"duration_sec": _phase_one_intro_duration_sec,
		"remaining_sec": _phase_one_intro_remaining_sec,
		"started_count": _phase_one_intro_started_count,
		"completed_count": _phase_one_intro_completed_count,
		"cancelled_count": _phase_one_intro_cancelled_count,
		"phase": get_current_phase(),
		"state": int(_state),
		"active_hitbox_count": _collision.get_active_hitbox_count() if _collision != null else 0,
	}


## Returns the SpriteFrames animation that presents one AI attack pattern.
func get_attack_animation_for_pattern(pattern_id: StringName) -> StringName:
	var animation_name: StringName = StringName(ATTACK_PATTERN_TO_ANIMATION.get(
		pattern_id,
		ANIMATION_ATTACK
	))
	if _sprite != null and _sprite.sprite_frames != null \
			and _sprite.sprite_frames.has_animation(animation_name):
		return animation_name
	return ANIMATION_ATTACK


## Plays a BossConfig special-attack presentation hook without spawning gameplay entities.
func play_special_attack_animation(special_attack_id: StringName) -> bool:
	var animation_name: StringName = get_attack_animation_for_pattern(special_attack_id)
	if animation_name == ANIMATION_ATTACK and special_attack_id != ANIMATION_ATTACK:
		return false
	_play_character_animation(animation_name, true)
	return StringName(_sprite.animation) == animation_name


func get_attack_speed_modifier() -> float:
	if _ai == null:
		return 1.0
	return _ai.get_attack_speed_modifier()


func get_charge_locomotion_diagnostics() -> Dictionary:
	return {
		"loaded_from_data": _charge_config_loaded_from_data,
		"lunge_speed": _charge_lunge_speed,
		"acquire_range_px": _charge_acquire_range_px,
		"locked_direction": _charge_locked_direction,
		"motion_active": _charge_motion_active,
		"blocked": _charge_blocked,
		"distance_px": _charge_distance_px,
		"collision_count": _charge_collision_count,
		"stop_reason": String(_charge_stop_reason),
		"velocity_x": velocity.x,
		"position": global_position,
		"target_distance_px": (
			absf(_attack_target.global_position.x - global_position.x)
			if is_instance_valid(_attack_target)
			else -1.0
		),
	}


func get_last_enemy_attack_metadata() -> Dictionary:
	return _last_enemy_attack_metadata.duplicate(true)


func capture_respawn_snapshot() -> Dictionary:
	return {
		"global_position": global_position,
		"hp": get_current_hp(),
		"phase": get_current_phase(),
		"facing": _facing,
		"collision_layer": collision_layer,
		"collision_mask": collision_mask,
		"sprite_modulate": _sprite.modulate,
	}


func restore_respawn_snapshot(snapshot: Dictionary) -> void:
	_cancel_phase_one_intro(&"respawn_reset")
	_reset_charge_locomotion(&"respawn_reset")
	global_position = _read_vector2(snapshot.get("global_position", global_position), global_position)
	_state = State.IDLE
	_phase_one_intro_played_this_attempt = false
	_phase_one_intro_remaining_sec = 0.0
	_stop_focus_attack_tell()
	_facing = _read_float(snapshot.get("facing", _facing), _facing)
	_hit_timer = 0
	_attack_timer = 0
	_attack_cooldown_timer = 0
	_contact_damage_timer = 0
	_last_enemy_attack_metadata = {}
	_active_attack_metadata = {}
	velocity = Vector2.ZERO
	collision_layer = _read_int(snapshot.get("collision_layer", collision_layer), collision_layer)
	collision_mask = _read_int(snapshot.get("collision_mask", collision_mask), collision_mask)
	_sprite.modulate = _read_color(snapshot.get("sprite_modulate", NORMAL_MODULATE), NORMAL_MODULATE)
	_reload_boss_config()
	var max_hp: int = _resolved_max_hp()
	var hp: int = clampi(_read_int(snapshot.get("hp", max_hp), max_hp), 0, max_hp)
	if _health != null:
		_health.configure(BOSS_ENTITY_ID, max_hp, hp, 0, 0, false)
		_health.configure_boss_phases(_resolved_phase_thresholds())
	if _collision != null:
		_collision.deactivate_all_hitboxes()
		_collision.set_hurtbox_state(&"normal")
	if _status_effects != null:
		_status_effects.clear_all_effects()
	_setup_ai_component()
	_update_sprite_facing()
	_play_character_animation(ANIMATION_IDLE, true)
	enemy_health_changed.emit(get_current_hp(), get_max_hp())


func mark_defeated_from_progress() -> void:
	_cancel_phase_one_intro(&"progress_defeated")
	_reset_charge_locomotion(&"progress_defeated")
	_state = State.DEAD
	_stop_focus_attack_tell()
	_hit_timer = 0
	_attack_timer = 0
	_attack_cooldown_timer = 0
	_contact_damage_timer = 0
	_last_enemy_attack_metadata.clear()
	_active_attack_metadata.clear()
	velocity = Vector2.ZERO
	if _collision != null:
		_collision.deactivate_all_hitboxes()
		_collision.set_hurtbox_state(CollisionComponent.HURTBOX_STATE_GONE)
	if _status_effects != null:
		_status_effects.clear_all_effects()
	if _sprite != null:
		_sprite.modulate = NORMAL_MODULATE
	_play_character_animation(ANIMATION_DEATH, true)
	collision_layer = 0
	collision_mask = 0


func is_defeated() -> bool:
	return _state == State.DEAD


func _process_idle(delta: float) -> void:
	if _can_auto_attack_target():
		request_attack()
		return
	velocity.x = 0.0
	velocity.y += GRAVITY * delta
	move_and_slide()
	_update_sprite_facing()
	_play_character_animation(ANIMATION_IDLE)


func _process_phase_one_intro(delta: float) -> void:
	velocity.x = 0.0
	velocity.y += GRAVITY * delta
	move_and_slide()
	_update_sprite_facing()
	_play_character_animation(ANIMATION_PHASE_ONE_INTRO)


func _process_hit(delta: float) -> void:
	velocity.x = 0.0
	velocity.y += GRAVITY * delta
	move_and_slide()
	_hit_timer -= 1
	if _hit_timer <= 0:
		_sprite.modulate = NORMAL_MODULATE
		_state = State.IDLE
		_play_character_animation(ANIMATION_IDLE, true)


func _process_attack_tell(_delta: float) -> void:
	velocity.x = 0.0
	_update_sprite_facing()
	_play_character_animation(_current_attack_animation())
	_advance_focus_attack_tell()
	_process_ai_attack(_delta)


func _enter_attack_active() -> void:
	_stop_focus_attack_tell()
	_state = State.ATTACK_ACTIVE
	_attack_timer = ATTACK_ACTIVE_FRAMES
	_play_character_animation(ANIMATION_ATTACK, true)
	if _collision != null:
		_collision.activate_hitbox(
			ATTACK_HITBOX_ID,
			ATTACK_ACTIVE_FRAMES,
			Vector2(_facing * ATTACK_HITBOX_OFFSET.x, ATTACK_HITBOX_OFFSET.y),
			ATTACK_HITBOX_SIZE,
			_build_attack_metadata()
		)


func _process_attack_active(delta: float) -> void:
	if _is_current_charge_pattern():
		_process_charge_motion(delta)
	else:
		velocity.x = 0.0
	_play_character_animation(_current_attack_animation())
	_process_ai_attack(delta)


func _process_charge_motion(delta: float) -> void:
	if not _charge_motion_active:
		_charge_motion_active = true
		_charge_stop_reason = &"active"
	var previous_x: float = global_position.x
	if _charge_blocked:
		velocity.x = 0.0
	else:
		velocity.x = _charge_locked_direction * _charge_lunge_speed
	velocity.y += GRAVITY * delta
	move_and_slide()
	var horizontal_step: float = absf(global_position.x - previous_x)
	_charge_distance_px += horizontal_step
	var expected_step: float = absf(_charge_lunge_speed * delta)
	if (
		not _charge_blocked
		and expected_step > 0.0
		and horizontal_step + 0.5 < expected_step
		and _has_horizontal_slide_collision()
	):
		_charge_blocked = true
		_charge_collision_count += 1
		_charge_stop_reason = &"collision"
		velocity.x = 0.0
	_update_sprite_facing()


func _process_attack_recovery(_delta: float) -> void:
	_end_charge_motion(&"recovery")
	velocity.x = 0.0
	_process_ai_attack(_delta)


func _prepare_charge_locomotion(pattern_id: StringName) -> void:
	if pattern_id != CHARGE_PATTERN_ID:
		_reset_charge_locomotion(&"different_pattern")
		return
	_charge_locked_direction = _facing
	_charge_motion_active = false
	_charge_blocked = false
	_charge_distance_px = 0.0
	_charge_collision_count = 0
	_charge_stop_reason = &"startup"


func _end_charge_motion(reason: StringName) -> void:
	if not _charge_motion_active:
		return
	_charge_motion_active = false
	velocity.x = 0.0
	if _charge_stop_reason != &"collision":
		_charge_stop_reason = reason


func _reset_charge_locomotion(reason: StringName) -> void:
	_charge_locked_direction = 0.0
	_charge_motion_active = false
	_charge_blocked = false
	_charge_distance_px = 0.0
	_charge_collision_count = 0
	_charge_stop_reason = reason
	velocity.x = 0.0


func _is_current_charge_pattern() -> bool:
	return (
		_ai != null
		and _ai.get_current_attack_pattern_id() == CHARGE_PATTERN_ID
	)


func _has_horizontal_slide_collision() -> bool:
	for collision_index: int in range(get_slide_collision_count()):
		var collision: KinematicCollision2D = get_slide_collision(collision_index)
		if collision != null and absf(collision.get_normal().x) >= 0.5:
			return true
	return false


func _process_ai_attack(_delta: float) -> void:
	if _ai == null or _ai.get_current_state() != AIComponent.AIState.ATTACK:
		_finish_ai_attack_if_needed()
		return
	_ai.advance_attack_frames(1)
	_sync_state_from_ai_attack()


func _sync_state_from_ai_attack() -> void:
	if _ai == null or _ai.get_current_state() != AIComponent.AIState.ATTACK:
		_finish_ai_attack_if_needed()
		return
	var attack_phase: StringName = _ai.get_attack_phase()
	var previous_state: State = _state
	match attack_phase:
		&"startup":
			_state = State.ATTACK_TELL
			_attack_timer = maxi(1, _ai.get_effective_attack_startup_frames() - _ai.get_attack_frame())
			_play_character_animation(_current_attack_animation())
		&"active":
			_state = State.ATTACK_ACTIVE
			_attack_timer = ATTACK_ACTIVE_FRAMES
			_play_character_animation(
				_current_attack_animation(),
				previous_state != State.ATTACK_ACTIVE
			)
		&"recovery":
			_state = State.ATTACK_RECOVERY
			_attack_timer = ATTACK_RECOVERY_FRAMES
			_end_charge_motion(&"recovery")
			_play_character_animation(_current_attack_animation())
		_:
			_finish_ai_attack_if_needed()


func _finish_ai_attack_if_needed() -> void:
	if _state != State.ATTACK_TELL and _state != State.ATTACK_ACTIVE and _state != State.ATTACK_RECOVERY:
		return
	_end_charge_motion(&"complete")
	_state = State.IDLE
	_stop_focus_attack_tell()
	_attack_timer = 0
	_attack_cooldown_timer = ATTACK_COOLDOWN_FRAMES
	_sprite.modulate = NORMAL_MODULATE
	_play_character_animation(ANIMATION_IDLE, true)


func _begin_focus_attack_tell(base_duration_frames: int) -> void:
	if _focus_attack_tell == null:
		return
	var focus_active: bool = (
		_ai != null and _ai.is_target_focus_mode_active()
	)
	_focus_attack_tell.call("begin", base_duration_frames, focus_active)


func _advance_focus_attack_tell() -> void:
	if _focus_attack_tell != null:
		_focus_attack_tell.call("advance_frames")


func _stop_focus_attack_tell() -> void:
	if _focus_attack_tell != null:
		_focus_attack_tell.call("stop")


func _process_phase_transition(_delta: float) -> void:
	velocity.x = 0.0
	velocity.y = 0.0


func _ensure_core_components() -> void:
	_health = get_node_or_null("HealthComponent") as HealthComponent
	if _health == null:
		_health = _health_component_script.new() as HealthComponent
		_health.name = "HealthComponent"
		add_child(_health)
	_collision = get_node_or_null("CollisionComponent") as CollisionComponent
	if _collision == null:
		_collision = _collision_component_script.new() as CollisionComponent
		_collision.name = "CollisionComponent"
		add_child(_collision)
	_combat = get_node_or_null("CombatComponent") as CombatComponent
	if _combat == null:
		_combat = _combat_component_script.new() as CombatComponent
		_combat.name = "CombatComponent"
		add_child(_combat)
	_status_effects = get_node_or_null("StatusEffectComponent") as StatusEffectComponent
	if _status_effects == null:
		_status_effects = _status_effect_component_script.new() as StatusEffectComponent
		_status_effects.name = "StatusEffectComponent"
		add_child(_status_effects)
	_boss_config = get_node_or_null("BossConfigComponent") as BossConfigComponent
	if _boss_config == null:
		_boss_config = _boss_config_component_script.new() as BossConfigComponent
		_boss_config.name = "BossConfigComponent"
		add_child(_boss_config)
	_ai = get_node_or_null("AIComponent") as AIComponent
	if _ai == null:
		_ai = _ai_component_script.new() as AIComponent
		_ai.name = "AIComponent"
		add_child(_ai)


func _setup_core_components() -> void:
	_reload_boss_config()
	var max_hp: int = _resolved_max_hp()
	_health.configure(BOSS_ENTITY_ID, max_hp, max_hp, 0, 0, false)
	_health.configure_boss_phases(_resolved_phase_thresholds())
	_boss_config.set_entity_id(BOSS_ENTITY_ID)
	_boss_config.set_health_adapter(_health)
	_boss_config.set_ai_adapter(self)
	if _summon_adapter != null:
		_boss_config.set_summon_adapter(_summon_adapter)
	if _scene_adapter != null:
		_boss_config.set_scene_adapter(_scene_adapter)
	if _reward_adapter != null:
		_boss_config.set_reward_adapter(_reward_adapter)
	if not _health.on_hp_changed.is_connected(_on_core_hp_changed):
		_health.on_hp_changed.connect(_on_core_hp_changed)
	if not _health.on_death.is_connected(_on_core_death):
		_health.on_death.connect(_on_core_death)
	_collision.configure_entity(BOSS_ENTITY_ID, &"enemy")
	_collision.set_hurtbox_size(BOSS_HURTBOX_SIZE)
	_collision.set_health_adapter(_health)
	_combat.set_collision_adapter(_collision)
	if _attack_target != null:
		_combat.set_health_adapter(_attack_target)
	if _damage_calculator_adapter != null:
		_combat.set_damage_calculator_adapter(_damage_calculator_adapter)
	if not _combat.on_attack_hit.is_connected(_on_core_attack_hit):
		_combat.on_attack_hit.connect(_on_core_attack_hit)
	_status_effects.configure_entity(BOSS_ENTITY_ID, false)
	_status_effects.set_health_adapter(_health)
	if not _boss_config.on_boss_phase_transition_started.is_connected(_on_boss_phase_transition_started):
		_boss_config.on_boss_phase_transition_started.connect(_on_boss_phase_transition_started)
	_setup_ai_component()


func _setup_ai_component() -> void:
	if _ai == null:
		return
	var root_data_manager: Node = get_node_or_null("/root/DataManager")
	_ai.set_physics_process(false)
	_ai.set_entity_id(BOSS_ENTITY_ID)
	_ai.set_data_adapter(root_data_manager)
	_ai.set_collision_adapter(self)
	_ai.load_attack_patterns(BOSS_ID, root_data_manager)
	_apply_current_boss_phase_to_ai()


func _load_charge_locomotion_config() -> void:
	var data_manager: Node = get_node_or_null("/root/DataManager")
	if data_manager == null or not data_manager.has_method("get_entry"):
		return
	var entry_variant: Variant = data_manager.call(
		"get_entry",
		&"enemy_stats",
		BOSS_ID
	)
	if not entry_variant is Dictionary:
		return
	var patterns: Array = Array((entry_variant as Dictionary).get(
		"attack_patterns",
		[]
	))
	for pattern_variant: Variant in patterns:
		if not pattern_variant is Dictionary:
			continue
		var pattern: Dictionary = pattern_variant as Dictionary
		if StringName(String(pattern.get("pattern_id", ""))) != CHARGE_PATTERN_ID:
			continue
		_charge_lunge_speed = maxf(
			1.0,
			float(pattern.get("lunge_speed", DEFAULT_CHARGE_LUNGE_SPEED))
		)
		_charge_acquire_range_px = maxf(
			ATTACK_RANGE_PX,
			float(pattern.get(
				"attack_range_px",
				DEFAULT_CHARGE_ACQUIRE_RANGE_PX
			))
		)
		_charge_config_loaded_from_data = true
		return


func _apply_current_boss_phase_to_ai() -> void:
	if _ai == null or _boss_config == null or not _boss_config.has_boss_config():
		return
	var phase_id: int = _boss_config.get_current_phase()
	apply_boss_phase(
		phase_id,
		_boss_config.get_phase_attack_patterns(phase_id),
		_boss_config.get_attack_speed_modifier(phase_id)
	)


func _reload_boss_config() -> bool:
	if _boss_config == null:
		return false
	var root_data_manager: Node = get_node_or_null("/root/DataManager")
	if root_data_manager != null:
		_boss_config.set_data_adapter(root_data_manager)
	return _boss_config.load_boss_config(BOSS_ID, root_data_manager)


func _resolved_max_hp() -> int:
	if _boss_config != null and _boss_config.has_boss_config():
		return _boss_config.get_max_hp()
	return FALLBACK_MAX_HP


func _resolved_phase_thresholds() -> Array:
	if _boss_config != null and _boss_config.has_boss_config():
		return _boss_config.get_phase_thresholds()
	return [0.66, 0.33]


func _on_core_hp_changed(_entity_id: int, current_hp: int, max_hp: int) -> void:
	enemy_health_changed.emit(current_hp, max_hp)
	if current_hp <= 0 or _state == State.DEAD or _state == State.PHASE_TRANSITION:
		return
	if _state == State.ATTACK_TELL or _state == State.ATTACK_ACTIVE or _state == State.ATTACK_RECOVERY:
		_sprite.modulate = HIT_MODULATE
		return
	_hit_timer = HIT_FLASH_FRAMES
	_state = State.HIT
	_sprite.modulate = HIT_MODULATE
	_play_character_animation(ANIMATION_HURT, true)


func _on_core_death(_entity_id: int, _metadata: Dictionary) -> void:
	if _state == State.DEAD:
		return
	_cancel_phase_one_intro(&"death")
	_reset_charge_locomotion(&"death")
	_state = State.DEAD
	_stop_focus_attack_tell()
	if _collision != null:
		_collision.deactivate_all_hitboxes()
		_collision.set_hurtbox_state(&"gone")
	_play_character_animation(ANIMATION_DEATH, true)
	enemy_defeated.emit()
	_sprite.modulate.a = 0.85
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)


func _on_boss_phase_transition_started(
	_entity_id: int,
	_phase: int,
	metadata: Dictionary
) -> void:
	if _state == State.DEAD:
		return
	_cancel_phase_one_intro(&"phase_transition")
	_reset_charge_locomotion(&"phase_transition")
	var animation_name: StringName = StringName(String(metadata.get("transition_animation", "")))
	if animation_name == &"" or _sprite.sprite_frames == null:
		return
	if _sprite.sprite_frames.has_animation(animation_name):
		_state = State.PHASE_TRANSITION
		_stop_focus_attack_tell()
		_sprite.modulate = NORMAL_MODULATE
		_play_character_animation(animation_name, true)


func _on_core_attack_hit(metadata: Dictionary) -> void:
	var merged_metadata: Dictionary = _active_attack_metadata.duplicate(true)
	for key: Variant in metadata.keys():
		merged_metadata[key] = metadata[key]
	_last_enemy_attack_metadata = merged_metadata.duplicate(true)
	var hit_position: Vector2 = _read_vector2(
		merged_metadata.get("hit_position", global_position),
		global_position
	)
	enemy_attack_landed.emit(
		int(merged_metadata.get("final_damage", 0)),
		hit_position,
		bool(merged_metadata.get("is_crit", false))
	)


func _build_attack_metadata(
	ai_metadata: Dictionary = {},
	hitbox_id: StringName = ATTACK_HITBOX_ID
) -> Dictionary:
	var damage: int = int(ai_metadata.get("damage", _damage_for_hitbox(hitbox_id)))
	var metadata: Dictionary = {
		"source": &"rat_king",
		"attack_type": &"light",
		"weapon_id": hitbox_id,
		"combo_index": 0,
		"hit_frame": RAT_KING_CLAW_HIT_FRAME,
		"attack_power": 0,
		"enemy_defense": 0,
		"injected_damage_params": _build_enemy_damage_params(hitbox_id, damage),
	}
	for key: Variant in ai_metadata.keys():
		metadata[key] = ai_metadata[key]
	return metadata


func _build_enemy_damage_params(hitbox_id: StringName, damage: int) -> Dictionary:
	return {
		"entries": {
			String(hitbox_id): {
				"weapon_base": maxi(0, damage),
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


func _damage_for_hitbox(hitbox_id: StringName) -> int:
	match hitbox_id:
		&"rat_king_claw":
			return RAT_KING_CLAW_DAMAGE
		&"rat_king_charge":
			return 14
		&"rat_king_slam":
			return 16
		&"rat_king_berserk_combo":
			return 14
		_:
			return RAT_KING_CLAW_DAMAGE


func _can_auto_attack_target() -> bool:
	if _should_use_charge_gap_closer():
		return true
	if not is_instance_valid(_attack_target) or _attack_cooldown_timer > 0:
		return false
	var to_target: Vector2 = _attack_target.global_position - global_position
	return absf(to_target.x) <= ATTACK_RANGE_PX and absf(to_target.y) <= 70.0


func _should_use_charge_gap_closer() -> bool:
	if (
		_ai == null
		or _state != State.IDLE
		or _attack_cooldown_timer > 0
		or not is_instance_valid(_attack_target)
		or not _ai.get_current_attack_pattern_ids().has(CHARGE_PATTERN_ID)
	):
		return false
	var to_target: Vector2 = _attack_target.global_position - global_position
	return (
		absf(to_target.x) > ATTACK_RANGE_PX
		and absf(to_target.x) <= _charge_acquire_range_px
		and absf(to_target.y) <= 70.0
	)


func _face_attack_target() -> void:
	if is_instance_valid(_attack_target):
		var delta_x: float = _attack_target.global_position.x - global_position.x
		if absf(delta_x) > 1.0:
			_facing = signf(delta_x)
	_update_sprite_facing()


func _update_sprite_facing() -> void:
	if _sprite == null:
		return
	_sprite.flip_h = _facing < 0.0


func _current_attack_animation() -> StringName:
	if _ai == null:
		return ANIMATION_ATTACK
	return get_attack_animation_for_pattern(_ai.get_current_attack_pattern_id())


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


func _complete_phase_one_intro() -> void:
	if _state != State.INTRO:
		return
	_phase_one_intro_remaining_sec = 0.0
	_phase_one_intro_completed_count += 1
	_state = State.IDLE
	_sprite.modulate = NORMAL_MODULATE
	_play_character_animation(ANIMATION_IDLE, true)
	phase_one_intro_finished.emit(BOSS_ENTITY_ID, {
		"animation": ANIMATION_PHASE_ONE_INTRO,
		"completed": true,
		"reason": &"completed",
	})


func _cancel_phase_one_intro(reason: StringName) -> void:
	if _state != State.INTRO:
		return
	_phase_one_intro_remaining_sec = 0.0
	_phase_one_intro_cancelled_count += 1
	_state = State.IDLE
	_sprite.modulate = NORMAL_MODULATE
	_play_character_animation(ANIMATION_IDLE, true)
	phase_one_intro_finished.emit(BOSS_ENTITY_ID, {
		"animation": ANIMATION_PHASE_ONE_INTRO,
		"completed": false,
		"reason": reason,
	})


func _get_animation_duration_sec(animation_name: StringName) -> float:
	if _sprite == null or _sprite.sprite_frames == null:
		return 0.0
	var frames: SpriteFrames = _sprite.sprite_frames
	if not frames.has_animation(animation_name):
		return 0.0
	var speed_fps: float = frames.get_animation_speed(animation_name)
	if speed_fps <= 0.0:
		return 0.0
	var duration_sec: float = 0.0
	for frame_index: int in range(frames.get_frame_count(animation_name)):
		duration_sec += frames.get_frame_duration(animation_name, frame_index) / speed_fps
	return duration_sec


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
