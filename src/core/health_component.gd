## Core entity component for HP, shield, and death state.
extends Node
class_name HealthComponent

signal on_hp_changed(entity_id: int, current_hp: int, max_hp: int)
signal on_hp_milestone(entity_id: int, threshold: float)
signal on_boss_phase_change(entity_id: int, phase: int, hp_percentage: float)
signal on_focus_mode_changed(entity_id: int, active: bool, metadata: Dictionary)
signal on_death(entity_id: int, metadata: Dictionary)
signal on_death_in_zone(entity_id: int, zone_id: StringName)

enum EntityState {
	ALIVE,
	DYING,
	DEAD,
}

const DEFAULT_MAX_HP: int = 100
const HEALTH_SAVE_VERSION: int = 1
const DEFAULT_INJURY_PITCH_MAX_SEMITONES: int = 10
const HP_MILESTONES: Array[float] = [0.75, 0.5, 0.25, 0.01]
const FOCUS_ENTER_THRESHOLD: float = 0.25
const FOCUS_EXIT_THRESHOLD: float = 0.28
const FOCUS_WINDUP_EXTENSION_FRAMES: int = 6
const FOCUS_EDGE_FLASH_COLOR: String = "#ECC94B"
const FOCUS_EDGE_FLASH_DURATION_SEC: float = 0.3
const FOCUS_AUDIO_CUE: StringName = &"focus_mode_enter"
const FOCUS_AUDIO_DURATION_SEC: float = 0.5
const FOCUS_ATTACK_TELL_AREA_MULTIPLIER: float = 1.25
const FOCUS_BACKGROUND_PARTICLE_MULTIPLIER: float = 0.3

var _entity_id: int = 0
var _base_hp: int = DEFAULT_MAX_HP
var _skill_hp_flat: int = 0
var _charm_hp_flat: int = 0
var _current_hp: int = DEFAULT_MAX_HP
var _max_hp: int = DEFAULT_MAX_HP
var _shield: int = 0
var _max_shield: int = 0
var _state: EntityState = EntityState.ALIVE
var _triggered_milestones: Array[float] = []
var _phase_thresholds: Array[float] = []
var _next_phase_index: int = 0
var _iframe_remaining: int = 0
var _focus_mode_enabled: bool = false
var _focus_mode_active: bool = false
var _active_enemy_count: int = 0
var _battle_start_msec: int = 0
var _total_damage_received: int = 0
var _total_damage_dealt: int = 0
var _current_zone_id: StringName = &""


## Configures this component for an entity instance.
func configure(
	entity_id: int,
	max_hp: int,
	current_hp: int,
	shield: int,
	max_shield: int,
	focus_mode_enabled: bool = false
) -> void:
	_entity_id = entity_id
	_max_hp = _sanitize_max_hp(max_hp)
	_base_hp = _max_hp
	_skill_hp_flat = 0
	_charm_hp_flat = 0
	_current_hp = clampi(current_hp, 0, _max_hp)
	if max_hp <= 0 and current_hp <= 0:
		_current_hp = _max_hp
	_max_shield = maxi(0, max_shield)
	_shield = clampi(shield, 0, _max_shield)
	_state = EntityState.ALIVE if _current_hp > 0 else EntityState.DEAD
	_triggered_milestones.clear()
	_phase_thresholds.clear()
	_next_phase_index = 0
	_iframe_remaining = 0
	_focus_mode_enabled = focus_mode_enabled
	_focus_mode_active = false
	_active_enemy_count = 0
	_battle_start_msec = 0
	_total_damage_received = 0
	_total_damage_dealt = 0
	_current_zone_id = &""


## Configures boss HP phase thresholds in descending HP-percentage order.
func configure_boss_phases(phase_thresholds: Array) -> void:
	_phase_thresholds.clear()
	for threshold: Variant in phase_thresholds:
		var normalized_threshold: float = clampf(float(threshold), 0.0, 1.0)
		_phase_thresholds.append(normalized_threshold)
	_next_phase_index = 0


## Applies final damage after DamageCalculator has resolved all modifiers.
func apply_damage(final_damage: int, metadata: Dictionary) -> void:
	if _state != EntityState.ALIVE or _iframe_remaining > 0 or final_damage <= 0:
		return
	_ensure_battle_started()
	var previous_hp_percentage: float = get_hp_percentage()
	var effective_damage: int = _absorb_shield(final_damage)
	if effective_damage > 0:
		_total_damage_received += effective_damage
		_current_hp = maxi(0, _current_hp - effective_damage)
	on_hp_changed.emit(_entity_id, _current_hp, _max_hp)
	var hp_percentage: float = get_hp_percentage()
	_emit_hp_milestones(previous_hp_percentage, hp_percentage)
	_emit_boss_phase_changes(hp_percentage)
	_check_focus_mode_transition(&"low_hp_combat")
	if _current_hp == 0:
		_state = EntityState.DYING
		var death_metadata: Dictionary = _build_death_metadata(final_damage, metadata)
		if _current_zone_id != &"":
			on_death_in_zone.emit(_entity_id, _current_zone_id)
		on_death.emit(_entity_id, death_metadata.duplicate(true))


## Recalculates max HP from HD-F0 sources and preserves current HP percentage.
func recalculate_max_hp(base_hp: int, skill_hp_flat: int, charm_hp_flat: int) -> void:
	_base_hp = base_hp
	_skill_hp_flat = skill_hp_flat
	_charm_hp_flat = charm_hp_flat
	var new_max_hp: int = _sanitize_max_hp(_base_hp + _skill_hp_flat + _charm_hp_flat)
	var previous_hp: int = _current_hp
	var previous_max_hp: int = _max_hp
	var hp_percentage: float = get_hp_percentage()
	_max_hp = new_max_hp
	_current_hp = clampi(int(round(hp_percentage * float(_max_hp))), 0, _max_hp)
	if _current_hp != previous_hp or _max_hp != previous_max_hp:
		on_hp_changed.emit(_entity_id, _current_hp, _max_hp)
	_check_focus_mode_transition(&"max_hp_recalculated")


## Returns HD-F4 injury pitch offset in semitones.
func get_injury_pitch_offset(
	injury_pitch_max_semitones: int = DEFAULT_INJURY_PITCH_MAX_SEMITONES
) -> float:
	return (1.0 - get_hp_percentage()) * float(maxi(0, injury_pitch_max_semitones))


## Serializes JSON-safe health state for future SaveSystem registration.
func serialize() -> Dictionary:
	return {
		"version": HEALTH_SAVE_VERSION,
		"entity_id": _entity_id,
		"base_hp": _base_hp,
		"skill_hp_flat": _skill_hp_flat,
		"charm_hp_flat": _charm_hp_flat,
		"current_hp": _current_hp,
		"max_hp": _max_hp,
		"shield": _shield,
		"max_shield": _max_shield,
		"state": String(get_entity_state()),
		"focus_mode_enabled": _focus_mode_enabled,
		"focus_mode_active": _focus_mode_active,
		"triggered_milestones": _triggered_milestones.duplicate(),
		"phase_thresholds": _phase_thresholds.duplicate(),
		"next_phase_index": _next_phase_index,
		"current_zone_id": String(_current_zone_id),
	}


## Restores JSON health state while tolerating missing older-save fields.
func deserialize(data: Dictionary, _version: int) -> void:
	_entity_id = int(data.get("entity_id", _entity_id))
	_base_hp = int(data.get("base_hp", data.get("max_hp", DEFAULT_MAX_HP)))
	_skill_hp_flat = int(data.get("skill_hp_flat", 0))
	_charm_hp_flat = int(data.get("charm_hp_flat", 0))
	_max_hp = _sanitize_max_hp(int(data.get(
		"max_hp",
		_base_hp + _skill_hp_flat + _charm_hp_flat
	)))
	_current_hp = clampi(int(data.get("current_hp", _max_hp)), 0, _max_hp)
	_max_shield = maxi(0, int(data.get("max_shield", 0)))
	_shield = clampi(int(data.get("shield", 0)), 0, _max_shield)
	_state = _state_from_serialized_value(data.get("state", &"alive"))
	_focus_mode_enabled = bool(data.get("focus_mode_enabled", false))
	_focus_mode_active = bool(data.get("focus_mode_active", false))
	_triggered_milestones = _float_array_from_variant(data.get("triggered_milestones", []))
	_phase_thresholds = _float_array_from_variant(data.get("phase_thresholds", []))
	_next_phase_index = clampi(
		int(data.get("next_phase_index", 0)),
		0,
		_phase_thresholds.size()
	)
	_current_zone_id = StringName(String(data.get("current_zone_id", "")))
	_iframe_remaining = 0
	_battle_start_msec = 0
	_total_damage_received = 0
	_total_damage_dealt = 0
	_active_enemy_count = 0


## Records outbound damage for death summary statistics.
func observe_damage_dealt(amount: int) -> void:
	if amount <= 0:
		return
	_ensure_battle_started()
	_total_damage_dealt += amount


## Sets the current exploration or arena zone used by death hooks.
func set_current_zone_id(zone_id: StringName) -> void:
	_current_zone_id = zone_id


## Grants damage immunity frames using max-take semantics.
func grant_iframes(frames: int) -> void:
	if frames <= 0:
		return
	_iframe_remaining = maxi(_iframe_remaining, frames)


## Heals current HP without exceeding max HP.
func heal(amount: int) -> void:
	if _state != EntityState.ALIVE or amount <= 0:
		return
	var healed_hp: int = mini(_max_hp, _current_hp + amount)
	if healed_hp == _current_hp:
		return
	_current_hp = healed_hp
	on_hp_changed.emit(_entity_id, _current_hp, _max_hp)
	_check_focus_mode_transition(&"hp_recovered")


## Restores save-point recovery values.
func restore_at_savepoint() -> void:
	_current_hp = _max_hp
	_shield = _max_shield
	if _current_hp > 0:
		_state = EntityState.ALIVE
	on_hp_changed.emit(_entity_id, _current_hp, _max_hp)
	_check_focus_mode_transition(&"savepoint_restore")


## Revives an entity with at least one HP and resets per-life health gates.
func revive(revive_hp_percentage: float = 0.5) -> void:
	var normalized_percentage: float = clampf(revive_hp_percentage, 0.0, 1.0)
	var revived_hp: int = int(floor(float(_max_hp) * normalized_percentage))
	_current_hp = clampi(maxi(1, revived_hp), 1, _max_hp)
	_shield = _max_shield
	_state = EntityState.ALIVE
	_triggered_milestones.clear()
	_next_phase_index = 0
	_iframe_remaining = 0
	_battle_start_msec = 0
	_total_damage_received = 0
	_total_damage_dealt = 0
	on_hp_changed.emit(_entity_id, _current_hp, _max_hp)
	if _focus_mode_active:
		_focus_mode_active = false
		_emit_focus_mode_changed(false, &"revive")


## Updates combat gating for focus mode.
func set_active_enemy_count(active_enemy_count: int) -> void:
	_active_enemy_count = maxi(0, active_enemy_count)
	_check_focus_mode_transition(&"active_enemy_count_changed")


## Returns active enemy count used for focus-mode combat gating.
func get_active_enemy_count() -> int:
	return _active_enemy_count


## Returns current zone id used for death metadata.
func get_current_zone_id() -> StringName:
	return _current_zone_id


## Returns this component's owning entity id.
func get_entity_id() -> int:
	return _entity_id


## Returns current HP clamped to 0..max_hp.
func get_current_hp() -> int:
	return _current_hp


## Returns maximum HP after safe fallback handling.
func get_max_hp() -> int:
	return _max_hp


## Returns current shield value.
func get_shield() -> int:
	return _shield


## Returns maximum shield value.
func get_max_shield() -> int:
	return _max_shield


## Returns current HP percentage in the range 0.0..1.0.
func get_hp_percentage() -> float:
	if _max_hp <= 0:
		return 0.0
	return float(_current_hp) / float(_max_hp)


## Returns current shield percentage in the range 0.0..1.0.
func get_shield_percentage() -> float:
	if _max_shield <= 0:
		return 0.0
	return float(_shield) / float(_max_shield)


## Returns remaining i-frames.
func get_iframe_remaining() -> int:
	return _iframe_remaining


## Returns true while damage should be ignored by i-frame immunity.
func is_invincible() -> bool:
	return _iframe_remaining > 0


## Returns true while low-HP focus mode is active.
func is_focus_mode_active() -> bool:
	return _focus_mode_active


## Returns true while this entity can still receive damage.
func is_alive() -> bool:
	return _state == EntityState.ALIVE and _current_hp > 0


## Returns true after lethal damage or explicit dead configuration.
func is_dead() -> bool:
	return _state != EntityState.ALIVE or _current_hp <= 0


## Returns the current entity state as a stable string for diagnostics.
func get_entity_state() -> StringName:
	match _state:
		EntityState.DYING:
			return &"dying"
		EntityState.DEAD:
			return &"dead"
		_:
			return &"alive"


func _physics_process(_delta: float) -> void:
	if _iframe_remaining > 0:
		_iframe_remaining -= 1


func _sanitize_max_hp(max_hp: int) -> int:
	if max_hp <= 0:
		return DEFAULT_MAX_HP
	return max_hp


func _state_from_serialized_value(value: Variant) -> EntityState:
	if value is int:
		match int(value):
			EntityState.DYING:
				return EntityState.DYING
			EntityState.DEAD:
				return EntityState.DEAD
			_:
				return EntityState.ALIVE
	match String(value):
		"dying":
			return EntityState.DYING
		"dead":
			return EntityState.DEAD
		_:
			return EntityState.ALIVE


func _float_array_from_variant(value: Variant) -> Array[float]:
	var values: Array[float] = []
	if value is Array:
		for entry: Variant in value:
			values.append(float(entry))
	return values


func _absorb_shield(incoming_damage: int) -> int:
	if _shield <= 0:
		return incoming_damage
	var shield_absorbed: int = mini(_shield, incoming_damage)
	_shield -= shield_absorbed
	return incoming_damage - shield_absorbed


func _emit_hp_milestones(previous_hp_percentage: float, hp_percentage: float) -> void:
	for threshold: float in HP_MILESTONES:
		if (
			previous_hp_percentage > threshold
			and hp_percentage <= threshold
			and not _triggered_milestones.has(threshold)
		):
			_triggered_milestones.append(threshold)
			on_hp_milestone.emit(_entity_id, threshold)


func _emit_boss_phase_changes(hp_percentage: float) -> void:
	while (
		_next_phase_index < _phase_thresholds.size()
		and hp_percentage <= _phase_thresholds[_next_phase_index]
	):
		var phase: int = _next_phase_index + 1
		on_boss_phase_change.emit(_entity_id, phase, hp_percentage)
		_next_phase_index += 1


func _check_focus_mode_transition(reason: StringName) -> void:
	if not _focus_mode_enabled:
		return
	var hp_percentage: float = get_hp_percentage()
	if not _focus_mode_active and _active_enemy_count > 0 and hp_percentage <= FOCUS_ENTER_THRESHOLD:
		_focus_mode_active = true
		_emit_focus_mode_changed(true, reason)
	elif _focus_mode_active and _active_enemy_count == 0:
		_focus_mode_active = false
		_emit_focus_mode_changed(false, &"combat_ended")
	elif _focus_mode_active and hp_percentage > FOCUS_EXIT_THRESHOLD:
		_focus_mode_active = false
		_emit_focus_mode_changed(false, reason)


func _emit_focus_mode_changed(active: bool, reason: StringName) -> void:
	on_focus_mode_changed.emit(_entity_id, active, _build_focus_mode_metadata(active, reason))


func _build_focus_mode_metadata(active: bool, reason: StringName) -> Dictionary:
	return {
		"hp_percentage": get_hp_percentage(),
		"active_enemy_count": _active_enemy_count,
		"enter_threshold": FOCUS_ENTER_THRESHOLD,
		"exit_threshold": FOCUS_EXIT_THRESHOLD,
		"windup_extension_frames": FOCUS_WINDUP_EXTENSION_FRAMES if active else 0,
		"edge_flash_color": FOCUS_EDGE_FLASH_COLOR,
		"edge_flash_duration_sec": FOCUS_EDGE_FLASH_DURATION_SEC if active else 0.0,
		"audio_cue": FOCUS_AUDIO_CUE if active else &"",
		"audio_duration_sec": FOCUS_AUDIO_DURATION_SEC if active else 0.0,
		"attack_tell_area_multiplier": FOCUS_ATTACK_TELL_AREA_MULTIPLIER if active else 1.0,
		"background_particle_multiplier": FOCUS_BACKGROUND_PARTICLE_MULTIPLIER if active else 1.0,
		"low_frequency_reverb": active,
		"transition_reason": reason,
	}


func _ensure_battle_started() -> void:
	if _battle_start_msec == 0:
		_battle_start_msec = Time.get_ticks_msec()


func _build_death_metadata(final_damage: int, last_hit_metadata: Dictionary) -> Dictionary:
	var battle_stats: Dictionary = _get_combat_battle_stats()
	var damage_type: StringName = last_hit_metadata.get(
		"damage_category",
		last_hit_metadata.get("damage_type", &"normal")
	)
	var damage_source: StringName = last_hit_metadata.get(
		"source_entity",
		last_hit_metadata.get("source", &"")
	)
	var death_metadata: Dictionary = {
		"last_hit": {
			"damage": int(last_hit_metadata.get("final_damage", final_damage)),
			"type": damage_type,
			"source": damage_source,
			"is_crit": bool(last_hit_metadata.get("is_crit", false)),
		},
		"battle_stats": {
			"duration_sec": _get_battle_duration_sec(),
			"damage_received": _total_damage_received,
			"damage_dealt": _total_damage_dealt,
			"dodge_success_rate": float(battle_stats.get("dodge_success_rate", 0.0)),
			"parry_success_rate": float(battle_stats.get("parry_success_rate", 0.0)),
			"hits_received_by_pattern": Dictionary(
				battle_stats.get("hits_received_by_pattern", {})
			).duplicate(true),
		},
		"context": {
			"zone_id": _current_zone_id,
			"enemy_type": last_hit_metadata.get("source_type", &""),
			"boss_phase": _next_phase_index if _phase_thresholds.size() > 0 else -1,
		},
		"source": damage_source,
	}
	return death_metadata.duplicate(true)


func _get_combat_battle_stats() -> Dictionary:
	var owner_node: Node = get_parent()
	if owner_node == null:
		return {}
	var combat: Node = owner_node.get_node_or_null("CombatComponent")
	if combat == null or not combat.has_method("get_battle_stats"):
		return {}
	var stats: Variant = combat.call("get_battle_stats")
	if stats is Dictionary:
		return Dictionary(stats).duplicate(true)
	return {}


func _get_battle_duration_sec() -> float:
	if _battle_start_msec == 0:
		return 0.0
	return maxf(0.0, float(Time.get_ticks_msec() - _battle_start_msec) / 1000.0)
