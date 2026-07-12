## Heavy Central Tower sentry with a data-driven latch-thrust attack.
class_name CentralTowerThresholdGuard
extends "res://src/gameplay/factory_sluice_leech.gd"

const CONFIG_ID: StringName = &"central_tower_threshold_guard"
const GUARD_ENTITY_FAMILY: StringName = &"central_tower_threshold_guard"
const GUARD_ATTACK_HITBOX_ID: StringName = &"central_tower_guard_latch_thrust"
const DEFAULT_MAX_HP: int = 48
const DEFAULT_PATROL_SPEED: float = 48.0
const DEFAULT_ATTACK_STARTUP_FRAMES: int = 24
const DEFAULT_ATTACK_ACTIVE_FRAMES: int = 6
const DEFAULT_ATTACK_RECOVERY_FRAMES: int = 24
const DEFAULT_ATTACK_DAMAGE: int = 14
const DEFAULT_LUNGE_SPEED: float = 156.0
const DEFAULT_ATTACK_RANGE_PX: float = 104.0
const GUARD_ATTACK_HIT_FRAME: int = 140
const GUARD_HURTBOX_SIZE: Vector2 = Vector2(58.0, 66.0)
const DEFAULT_HITBOX_SIZE: Vector2 = Vector2(64.0, 40.0)
const DEFAULT_HITBOX_OFFSET: Vector2 = Vector2(44.0, -30.0)

var _configured_max_hp: int = DEFAULT_MAX_HP
var _configured_patrol_speed: float = DEFAULT_PATROL_SPEED
var _configured_startup_frames: int = DEFAULT_ATTACK_STARTUP_FRAMES
var _configured_active_frames: int = DEFAULT_ATTACK_ACTIVE_FRAMES
var _configured_recovery_frames: int = DEFAULT_ATTACK_RECOVERY_FRAMES
var _configured_damage: int = DEFAULT_ATTACK_DAMAGE
var _configured_lunge_speed: float = DEFAULT_LUNGE_SPEED
var _configured_attack_range_px: float = DEFAULT_ATTACK_RANGE_PX
var _configured_hitbox_size: Vector2 = DEFAULT_HITBOX_SIZE
var _configured_hitbox_offset: Vector2 = DEFAULT_HITBOX_OFFSET
var _loaded_from_data: bool = false


func _ready() -> void:
	_load_enemy_config()
	super._ready()


func get_enemy_family_id() -> StringName:
	return GUARD_ENTITY_FAMILY


func get_current_hp() -> int:
	return _configured_max_hp if _health == null else _health.get_current_hp()


func get_max_hp() -> int:
	return _configured_max_hp if _health == null else _health.get_max_hp()


func get_attack_active_frames() -> int:
	return _configured_active_frames


func get_attack_recovery_frames() -> int:
	return _configured_recovery_frames


func get_attack_damage() -> int:
	return _configured_damage


func get_config_diagnostics() -> Dictionary:
	return {
		"config_id": String(CONFIG_ID),
		"loaded_from_data": _loaded_from_data,
		"max_hp": _configured_max_hp,
		"patrol_speed": _configured_patrol_speed,
		"startup_frames": _configured_startup_frames,
		"active_frames": _configured_active_frames,
		"recovery_frames": _configured_recovery_frames,
		"damage": _configured_damage,
		"lunge_speed": _configured_lunge_speed,
		"attack_range_px": _configured_attack_range_px,
		"hitbox_size": _configured_hitbox_size,
		"hitbox_offset": _configured_hitbox_offset,
	}


## Restores a failed ordinary encounter attempt without rebuilding the scene.
func reset_for_encounter() -> void:
	_state = State.CHASE
	_hit_timer = 0
	_attack_timer = 0
	_attack_cooldown_timer = 0
	velocity = Vector2.ZERO
	if _collision != null:
		_collision.deactivate_all_hitboxes()
		_collision.set_hurtbox_state(&"normal")
	if _health != null:
		_setup_core_components()
	if _sprite != null:
		_sprite.modulate = NORMAL_MODULATE
		_sprite.modulate.a = 1.0
		_play_character_animation(ANIMATION_IDLE, true)
	collision_layer = 2
	collision_mask = 17


func _setup_core_components() -> void:
	_health.configure(
		_entity_id,
		_configured_max_hp,
		_configured_max_hp,
		0,
		0,
		false
	)
	if not _health.on_hp_changed.is_connected(_on_core_hp_changed):
		_health.on_hp_changed.connect(_on_core_hp_changed)
	if not _health.on_death.is_connected(_on_core_death):
		_health.on_death.connect(_on_core_death)
	_collision.configure_entity(_entity_id, &"enemy")
	_collision.set_hurtbox_size(GUARD_HURTBOX_SIZE)
	_collision.set_health_adapter(_health)
	_combat.set_collision_adapter(_collision)
	if _attack_target != null:
		_combat.set_health_adapter(_attack_target)
	if _damage_calculator_adapter != null:
		_combat.set_damage_calculator_adapter(_damage_calculator_adapter)
	if not _combat.on_attack_hit.is_connected(_on_core_attack_hit):
		_combat.on_attack_hit.connect(_on_core_attack_hit)
	_status_effects.configure_entity(_entity_id, false)
	_status_effects.set_health_adapter(_health)


func _build_attack_metadata() -> Dictionary:
	return {
		"source": GUARD_ENTITY_FAMILY,
		"owner_boss_id": get_summon_owner_boss_id(),
		"summon_id": get_current_summon_id(),
		"attack_type": &"light",
		"weapon_id": GUARD_ATTACK_HITBOX_ID,
		"combo_index": 0,
		"hit_frame": GUARD_ATTACK_HIT_FRAME,
		"attack_power": 0,
		"enemy_defense": 0,
		"active_frames": _configured_active_frames,
		"recovery_frames": _configured_recovery_frames,
		"lunge_speed": _configured_lunge_speed,
		"config_id": CONFIG_ID,
		"injected_damage_params": _build_enemy_damage_params(),
	}


func _build_enemy_damage_params() -> Dictionary:
	return {
		"entries": {
			String(GUARD_ATTACK_HITBOX_ID): {
				"weapon_base": _configured_damage,
				"combo_multipliers": {"0": 1.0},
				"special_move": {"multiplier": 1.0, "hits": 1},
			},
		},
	}


func _get_attack_tell_animation() -> StringName:
	return &"attack_tell"


func _get_attack_tell_frames() -> int:
	return _configured_startup_frames


func _can_auto_attack_target() -> bool:
	if _attack_target == null or _attack_cooldown_timer > 0:
		return false
	var to_target: Vector2 = _attack_target.global_position - global_position
	return (
		absf(to_target.x) <= _configured_attack_range_px
		and absf(to_target.y) <= 62.0
	)


func _process_patrol(delta: float) -> void:
	if global_position.x <= _get_patrol_left_x():
		_facing = 1.0
	elif global_position.x >= _get_patrol_right_x():
		_facing = -1.0
	velocity.x = _facing * _configured_patrol_speed * _get_movement_modifier()
	velocity.y += GRAVITY * delta
	move_and_slide()
	_update_sprite_facing()
	_play_character_animation(ANIMATION_RUN)


func _enter_attack_active() -> void:
	_state = State.ATTACK_ACTIVE
	_attack_timer = _configured_active_frames
	_play_character_animation(ANIMATION_ATTACK, true)
	if _collision != null:
		_collision.activate_hitbox(
			GUARD_ATTACK_HITBOX_ID,
			_configured_active_frames,
			Vector2(
				_facing * _configured_hitbox_offset.x,
				_configured_hitbox_offset.y
			),
			_configured_hitbox_size,
			_build_attack_metadata()
		)


func _process_attack_active(delta: float) -> void:
	velocity.x = _facing * _configured_lunge_speed * _get_movement_modifier()
	velocity.y += GRAVITY * delta
	move_and_slide()
	_update_sprite_facing()
	_play_character_animation(ANIMATION_ATTACK)
	_attack_timer -= 1
	if _attack_timer <= 0:
		velocity.x = 0.0
		_state = State.ATTACK_RECOVERY
		_attack_timer = _configured_recovery_frames


func _process_attack_recovery(delta: float) -> void:
	velocity.x = 0.0
	velocity.y += GRAVITY * delta
	move_and_slide()
	_attack_timer -= 1
	if _attack_timer <= 0:
		_state = State.CHASE
		_attack_cooldown_timer = ATTACK_COOLDOWN_FRAMES
		_play_character_animation(ANIMATION_RUN, true)


func _load_enemy_config() -> void:
	var data_manager: Node = get_node_or_null("/root/DataManager")
	if data_manager == null or not data_manager.has_method("get_entry"):
		return
	var entry_value: Variant = data_manager.call("get_entry", &"enemy_stats", CONFIG_ID)
	if not entry_value is Dictionary:
		return
	var entry: Dictionary = Dictionary(entry_value)
	_configured_max_hp = maxi(1, int(entry.get("max_hp", DEFAULT_MAX_HP)))
	_configured_patrol_speed = maxf(0.0, float(entry.get(
		"patrol_speed",
		DEFAULT_PATROL_SPEED
	)))
	for pattern_value: Variant in Array(entry.get("attack_patterns", [])):
		if not pattern_value is Dictionary:
			continue
		var pattern: Dictionary = Dictionary(pattern_value)
		if StringName(String(pattern.get("pattern_id", ""))) != &"latch_thrust":
			continue
		_configured_startup_frames = maxi(1, int(pattern.get(
			"startup_frames",
			DEFAULT_ATTACK_STARTUP_FRAMES
		)))
		_configured_active_frames = maxi(1, int(pattern.get(
			"active_frames",
			DEFAULT_ATTACK_ACTIVE_FRAMES
		)))
		_configured_recovery_frames = maxi(1, int(pattern.get(
			"recovery_frames",
			DEFAULT_ATTACK_RECOVERY_FRAMES
		)))
		_configured_damage = maxi(1, int(pattern.get("damage", DEFAULT_ATTACK_DAMAGE)))
		_configured_lunge_speed = maxf(0.0, float(pattern.get(
			"lunge_speed",
			DEFAULT_LUNGE_SPEED
		)))
		_configured_attack_range_px = maxf(1.0, float(pattern.get(
			"attack_range_px",
			DEFAULT_ATTACK_RANGE_PX
		)))
		var hitbox: Dictionary = Dictionary(pattern.get("hitbox_config", {}))
		_configured_hitbox_size = _read_config_vector2(
			hitbox.get("size", {}),
			DEFAULT_HITBOX_SIZE
		)
		_configured_hitbox_offset = _read_config_vector2(
			hitbox.get("offset", {}),
			DEFAULT_HITBOX_OFFSET
		)
		_loaded_from_data = true
		return


func _read_config_vector2(value: Variant, fallback: Vector2) -> Vector2:
	if not value is Dictionary:
		return fallback
	var data: Dictionary = Dictionary(value)
	return Vector2(
		float(data.get("x", fallback.x)),
		float(data.get("y", fallback.y))
	)
