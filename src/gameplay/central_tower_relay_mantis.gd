## Data-driven Central Tower maintenance Mantis with a scythe-dash attack.
class_name CentralTowerRelayMantis
extends "res://src/gameplay/neon_signal_rat.gd"

const MANTIS_CONFIG_ID: StringName = &"central_tower_relay_mantis"
const MANTIS_ENTITY_FAMILY: StringName = &"central_tower_relay_mantis"
const MANTIS_ATTACK_HITBOX_ID: StringName = (
	&"central_tower_relay_mantis_scythe_dash"
)
const MANTIS_PATTERN_ID: StringName = &"relay_scythe_dash"
const MANTIS_ATTACK_HIT_FRAME: int = 141
const MANTIS_HURTBOX_SIZE: Vector2 = Vector2(40.0, 72.0)
const MANTIS_DEFAULT_MAX_HP: int = 40
const MANTIS_DEFAULT_PATROL_SPEED: float = 68.0
const MANTIS_DEFAULT_STARTUP_FRAMES: int = 20
const MANTIS_DEFAULT_ACTIVE_FRAMES: int = 6
const MANTIS_DEFAULT_RECOVERY_FRAMES: int = 20
const MANTIS_DEFAULT_DAMAGE: int = 12
const MANTIS_DEFAULT_LUNGE_SPEED: float = 210.0
const MANTIS_DEFAULT_ATTACK_RANGE_PX: float = 128.0
const MANTIS_DEFAULT_HITBOX_SIZE: Vector2 = Vector2(72.0, 44.0)
const MANTIS_DEFAULT_HITBOX_OFFSET: Vector2 = Vector2(46.0, -34.0)


func get_enemy_family_id() -> StringName:
	return MANTIS_ENTITY_FAMILY


func get_config_diagnostics() -> Dictionary:
	return {
		"config_id": String(MANTIS_CONFIG_ID),
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


## Restores a failed Service Spine attempt without rebuilding the scene.
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
	_collision.set_hurtbox_size(MANTIS_HURTBOX_SIZE)
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
		"source": MANTIS_ENTITY_FAMILY,
		"owner_boss_id": get_summon_owner_boss_id(),
		"summon_id": get_current_summon_id(),
		"attack_type": &"light",
		"weapon_id": MANTIS_ATTACK_HITBOX_ID,
		"combo_index": 0,
		"hit_frame": MANTIS_ATTACK_HIT_FRAME,
		"attack_power": 0,
		"enemy_defense": 0,
		"active_frames": _configured_active_frames,
		"recovery_frames": _configured_recovery_frames,
		"lunge_speed": _configured_lunge_speed,
		"config_id": MANTIS_CONFIG_ID,
		"injected_damage_params": _build_enemy_damage_params(),
	}


func _build_enemy_damage_params() -> Dictionary:
	return {
		"entries": {
			String(MANTIS_ATTACK_HITBOX_ID): {
				"weapon_base": _configured_damage,
				"combo_multipliers": {"0": 1.0},
				"special_move": {"multiplier": 1.0, "hits": 1},
			},
		},
	}


func _enter_attack_active() -> void:
	_state = State.ATTACK_ACTIVE
	_attack_timer = _configured_active_frames
	_play_character_animation(ANIMATION_ATTACK, true)
	if _collision != null:
		_collision.activate_hitbox(
			MANTIS_ATTACK_HITBOX_ID,
			_configured_active_frames,
			Vector2(
				_facing * _configured_hitbox_offset.x,
				_configured_hitbox_offset.y
			),
			_configured_hitbox_size,
			_build_attack_metadata()
		)


func _load_enemy_config() -> void:
	_configured_max_hp = MANTIS_DEFAULT_MAX_HP
	_configured_patrol_speed = MANTIS_DEFAULT_PATROL_SPEED
	_configured_startup_frames = MANTIS_DEFAULT_STARTUP_FRAMES
	_configured_active_frames = MANTIS_DEFAULT_ACTIVE_FRAMES
	_configured_recovery_frames = MANTIS_DEFAULT_RECOVERY_FRAMES
	_configured_damage = MANTIS_DEFAULT_DAMAGE
	_configured_lunge_speed = MANTIS_DEFAULT_LUNGE_SPEED
	_configured_attack_range_px = MANTIS_DEFAULT_ATTACK_RANGE_PX
	_configured_hitbox_size = MANTIS_DEFAULT_HITBOX_SIZE
	_configured_hitbox_offset = MANTIS_DEFAULT_HITBOX_OFFSET
	_loaded_from_data = false
	var data_manager: Node = get_node_or_null("/root/DataManager")
	if data_manager == null or not data_manager.has_method("get_entry"):
		return
	var entry_value: Variant = data_manager.call(
		"get_entry",
		&"enemy_stats",
		MANTIS_CONFIG_ID
	)
	if not entry_value is Dictionary:
		return
	var entry: Dictionary = Dictionary(entry_value)
	_configured_max_hp = maxi(
		1,
		int(entry.get("max_hp", MANTIS_DEFAULT_MAX_HP))
	)
	_configured_patrol_speed = maxf(
		0.0,
		float(entry.get("patrol_speed", MANTIS_DEFAULT_PATROL_SPEED))
	)
	for pattern_value: Variant in Array(entry.get("attack_patterns", [])):
		if not pattern_value is Dictionary:
			continue
		var pattern: Dictionary = Dictionary(pattern_value)
		if StringName(String(pattern.get("pattern_id", ""))) != MANTIS_PATTERN_ID:
			continue
		_configured_startup_frames = maxi(1, int(pattern.get(
			"startup_frames",
			MANTIS_DEFAULT_STARTUP_FRAMES
		)))
		_configured_active_frames = maxi(1, int(pattern.get(
			"active_frames",
			MANTIS_DEFAULT_ACTIVE_FRAMES
		)))
		_configured_recovery_frames = maxi(1, int(pattern.get(
			"recovery_frames",
			MANTIS_DEFAULT_RECOVERY_FRAMES
		)))
		_configured_damage = maxi(1, int(pattern.get(
			"damage",
			MANTIS_DEFAULT_DAMAGE
		)))
		_configured_lunge_speed = maxf(0.0, float(pattern.get(
			"lunge_speed",
			MANTIS_DEFAULT_LUNGE_SPEED
		)))
		_configured_attack_range_px = maxf(1.0, float(pattern.get(
			"attack_range_px",
			MANTIS_DEFAULT_ATTACK_RANGE_PX
		)))
		var hitbox: Dictionary = Dictionary(pattern.get("hitbox_config", {}))
		_configured_hitbox_size = _read_config_vector2(
			hitbox.get("size", {}),
			MANTIS_DEFAULT_HITBOX_SIZE
		)
		_configured_hitbox_offset = _read_config_vector2(
			hitbox.get("offset", {}),
			MANTIS_DEFAULT_HITBOX_OFFSET
		)
		_loaded_from_data = true
		return
