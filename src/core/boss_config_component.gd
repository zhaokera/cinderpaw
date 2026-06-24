## Core Boss configuration component backed by the DataManager data pipeline.
extends Node
class_name BossConfigComponent

signal on_boss_phase_transition_started(entity_id: int, phase: int, metadata: Dictionary)

const BOSS_CONFIGS_DOMAIN: StringName = &"boss_configs"
const DEFAULT_TRANSITION_DURATION_SEC: float = 2.5
const DEFAULT_DEFENSE_MODIFIER: float = 1.0
const DEFAULT_PARRY_DAMAGE_MULTIPLIER: float = 1.0
const UNCONFIGURED_ENTITY_ID: int = -1
const ATTACK_PHASE_NONE: StringName = &"none"

var _data_adapter: Object = null
var _ai_adapter: Object = null
var _health_adapter: Object = null
var _summon_adapter: Object = null
var _scene_adapter: Object = null
var _reward_adapter: Object = null
var _entity_id: int = UNCONFIGURED_ENTITY_ID
var _boss_id: StringName = &""
var _display_name: String = ""
var _max_hp: int = 0
var _phases: Array = []
var _defeat_rewards: Dictionary = {}
var _arena_bounds: Rect2 = Rect2()
var _current_phase: int = 1
var _transition_queue: Array = []
var _transition_active: bool = false
var _transition_remaining_sec: float = 0.0
var _summon_phase_id: int = 0
var _summon_id: StringName = &""
var _summon_interval_sec: float = 0.0
var _summon_max_count: int = 0
var _summon_timer_sec: float = 0.0
var _summons_cleanup_requested: bool = false
var _desperation_phase_id: int = 0
var _desperation_hp_threshold: float = 0.0
var _desperation_defense_modifier: float = DEFAULT_DEFENSE_MODIFIER
var _parry_damage_multiplier: float = DEFAULT_PARRY_DAMAGE_MULTIPLIER
var _parry_enter_stun: bool = false
var _rewards_dispatched: bool = false
var _scene_locked_by_boss: bool = false


func _exit_tree() -> void:
	_disconnect_health_adapter()


## Injects a DataManager-compatible adapter with get_entry(domain, entry_id).
func set_data_adapter(data_adapter: Object) -> void:
	_data_adapter = data_adapter


## Injects an AIComponent-compatible adapter for phase and attack state queries.
func set_ai_adapter(ai_adapter: Object) -> void:
	_ai_adapter = ai_adapter


## Injects a summon adapter without coupling to scene instantiation.
func set_summon_adapter(summon_adapter: Object) -> void:
	_summon_adapter = summon_adapter


## Injects a SceneManager-compatible adapter without coupling to scene nodes.
func set_scene_adapter(scene_adapter: Object) -> void:
	_scene_adapter = scene_adapter


## Injects a reward adapter without coupling to ability, currency, or skill systems.
func set_reward_adapter(reward_adapter: Object) -> void:
	_reward_adapter = reward_adapter


## Configures this Boss component's owning entity id for signal filtering.
func set_entity_id(entity_id: int) -> void:
	_entity_id = entity_id


## Returns the configured owning entity id, or -1 if not configured.
func get_entity_id() -> int:
	return _entity_id


## Connects a HealthComponent-compatible boss phase signal.
func set_health_adapter(health_adapter: Object) -> void:
	if _health_adapter == health_adapter:
		return
	_disconnect_health_adapter()
	_health_adapter = health_adapter
	_connect_health_signal(&"on_boss_phase_change", _handle_boss_phase_change)
	_connect_health_signal(&"on_death", _handle_boss_death)


## Loads and normalizes one Boss config from a DataManager-compatible adapter.
func load_boss_config(boss_id: StringName, data_adapter: Object = null) -> bool:
	_clear_config()
	var adapter: Object = data_adapter if data_adapter != null else _data_adapter
	var raw_config: Dictionary = _read_boss_config_entry(boss_id, adapter)
	var normalized: Dictionary = _normalize_boss_config(raw_config)
	if normalized.is_empty():
		return false
	_apply_normalized_config(normalized)
	return true


## Requests scene lock when a Boss encounter begins.
func start_boss_encounter() -> void:
	_request_scene_lock_once()


## Returns the current defense multiplier from HP-derived Boss config rules.
func get_defense_modifier() -> float:
	if _current_phase != _desperation_phase_id:
		return DEFAULT_DEFENSE_MODIFIER
	if _query_health_percentage() < _desperation_hp_threshold:
		return _desperation_defense_modifier
	return DEFAULT_DEFENSE_MODIFIER


## Resolves Boss-specific parry metadata for downstream Damage and AI adapters.
func resolve_parry_outcome(parry_type: StringName) -> Dictionary:
	var normalized_type: StringName = StringName(String(parry_type))
	var is_success: bool = _is_successful_parry_type(normalized_type)
	return {
		"parry_type": normalized_type,
		"is_success": is_success,
		"damage_multiplier": _parry_damage_multiplier if is_success \
			else DEFAULT_PARRY_DAMAGE_MULTIPLIER,
		"enter_stun": _parry_enter_stun if is_success else false,
	}


## Returns whether this component currently holds a valid Boss config.
func has_boss_config() -> bool:
	return _boss_id != &"" and _max_hp > 0 and not _phases.is_empty()


## Returns the loaded Boss id.
func get_boss_id() -> StringName:
	return _boss_id


## Returns the player-facing Boss display name.
func get_display_name() -> String:
	return _display_name


## Returns configured max HP.
func get_max_hp() -> int:
	return _max_hp


## Returns normalized phase configs.
func get_phase_configs() -> Array:
	return _phases.duplicate(true)


## Returns a normalized phase config by phase id, or an empty Dictionary.
func get_phase_config(phase_id: int) -> Dictionary:
	for phase: Dictionary in _phases:
		if int(phase.get("phase_id", 0)) == phase_id:
			return phase.duplicate(true)
	return {}


## Returns HP thresholds that trigger a transition into later phases.
func get_phase_thresholds() -> Array:
	var thresholds: Array = []
	for phase: Dictionary in _phases:
		var threshold: float = float(phase.get("hp_threshold", 1.0))
		if threshold > 0.0 and threshold < 1.0:
			thresholds.append(threshold)
	return thresholds


## Returns attack pattern ids referenced by a phase.
func get_phase_attack_patterns(phase_id: int) -> Array:
	var phase: Dictionary = get_phase_config(phase_id)
	if phase.is_empty():
		return []
	return (phase.get("attack_patterns", []) as Array).duplicate(true)


## Returns the configured attack speed modifier for one phase.
func get_attack_speed_modifier(phase_id: int) -> float:
	var phase: Dictionary = get_phase_config(phase_id)
	if phase.is_empty():
		return 1.0
	return float(phase.get("attack_speed_modifier", 1.0))


## Returns defeat rewards for downstream reward systems.
func get_defeat_rewards() -> Dictionary:
	return _defeat_rewards.duplicate(true)


## Returns configured arena bounds.
func get_arena_bounds() -> Rect2:
	return _arena_bounds


## Returns the active Boss phase id.
func get_current_phase() -> int:
	return _current_phase


## Returns whether a queued phase is waiting for an idle AI window.
func is_transition_pending() -> bool:
	return not _transition_queue.is_empty()


## Returns whether a phase transition window is currently active.
func is_transition_active() -> bool:
	return _transition_active


## Returns whether damage adapters should currently treat the Boss as invulnerable.
func is_invulnerable() -> bool:
	return _transition_active


## Queues a valid future phase transition.
func queue_phase_transition(phase_id: int) -> void:
	_queue_phase_transition(phase_id, _get_phase_threshold(phase_id))


func _queue_phase_transition(phase_id: int, hp_percentage: float) -> void:
	var normalized_phase_id: int = maxi(1, phase_id)
	if normalized_phase_id <= _current_phase or get_phase_config(normalized_phase_id).is_empty():
		return
	if _transition_queue_has_phase(normalized_phase_id):
		return
	_transition_queue.append({
		"phase_id": normalized_phase_id,
		"hp_percentage": clampf(hp_percentage, 0.0, 1.0),
	})


## Advances queued or active phase transitions for deterministic tests and gameplay ticks.
func advance_transition(delta_sec: float) -> void:
	if not _transition_active and _can_start_next_transition():
		_start_next_transition()
	if not _transition_active:
		return
	_transition_remaining_sec = maxf(0.0, _transition_remaining_sec - maxf(0.0, delta_sec))
	if _transition_remaining_sec <= 0.0:
		_transition_active = false


## Advances deterministic Boss runtime scheduling hooks.
func advance_time(delta_sec: float) -> void:
	if _current_phase != _summon_phase_id:
		_reset_summon_timer()
		return
	_advance_summon_schedule(maxf(0.0, delta_sec))


## Returns accumulated phase two summon timer seconds.
func get_summon_timer_sec() -> float:
	return _summon_timer_sec


func _read_boss_config_entry(boss_id: StringName, adapter: Object) -> Dictionary:
	if adapter == null or not adapter.has_method("get_entry"):
		return {}
	var entry: Variant = adapter.call("get_entry", BOSS_CONFIGS_DOMAIN, boss_id)
	if entry is Dictionary:
		return entry as Dictionary
	return {}


func _connect_health_signal(signal_name: StringName, callback: Callable) -> void:
	if _health_adapter == null or not _health_adapter.has_signal(signal_name):
		return
	var adapter_signal: Signal = _health_adapter.get(signal_name)
	if not adapter_signal.is_connected(callback):
		adapter_signal.connect(callback)


func _disconnect_health_adapter() -> void:
	_disconnect_health_signal(&"on_boss_phase_change", _handle_boss_phase_change)
	_disconnect_health_signal(&"on_death", _handle_boss_death)
	_health_adapter = null


func _disconnect_health_signal(signal_name: StringName, callback: Callable) -> void:
	if _health_adapter == null or not _health_adapter.has_signal(signal_name):
		return
	var adapter_signal: Signal = _health_adapter.get(signal_name)
	if adapter_signal.is_connected(callback):
		adapter_signal.disconnect(callback)


func _handle_boss_phase_change(
	entity_or_phase: Variant,
	maybe_phase: Variant = null,
	hp_percentage: float = 0.0
) -> void:
	if maybe_phase == null:
		queue_phase_transition(int(entity_or_phase))
		return
	if not _matches_entity_id(int(entity_or_phase)):
		return
	_queue_phase_transition(
		_resolve_phase_signal_target_phase(int(maybe_phase), hp_percentage),
		hp_percentage
	)


func _handle_boss_death(
	entity_id: int = UNCONFIGURED_ENTITY_ID,
	_metadata: Dictionary = {}
) -> void:
	if not _matches_entity_id(entity_id):
		return
	_request_summon_cleanup_once()
	_request_scene_unlock_once()
	_dispatch_defeat_rewards_once()


func _matches_entity_id(incoming_entity_id: int) -> bool:
	return _entity_id == UNCONFIGURED_ENTITY_ID or incoming_entity_id == _entity_id


func _can_start_next_transition() -> bool:
	return not _transition_queue.is_empty() and _is_ai_attack_complete()


func _is_ai_attack_complete() -> bool:
	if _ai_adapter == null or not _ai_adapter.has_method("get_attack_phase"):
		return true
	var attack_phase: Variant = _ai_adapter.call("get_attack_phase")
	return attack_phase == null or StringName(String(attack_phase)) == ATTACK_PHASE_NONE


func _start_next_transition() -> void:
	var transition_request: Dictionary = _transition_queue.pop_front()
	var next_phase: int = int(transition_request.get("phase_id", 1))
	var hp_percentage: float = float(transition_request.get(
		"hp_percentage",
		_get_phase_threshold(next_phase)
	))
	var previous_phase: int = _current_phase
	if _current_phase == _summon_phase_id and next_phase != _summon_phase_id:
		_reset_summon_timer()
	_current_phase = next_phase
	_transition_active = true
	_transition_remaining_sec = DEFAULT_TRANSITION_DURATION_SEC
	on_boss_phase_transition_started.emit(
		_entity_id,
		next_phase,
		_build_phase_transition_metadata(next_phase, previous_phase, hp_percentage)
	)
	_apply_phase_to_ai(next_phase)
	_apply_arena_changes(next_phase)


func _resolve_phase_signal_target_phase(incoming_phase: int, hp_percentage: float) -> int:
	var normalized_phase: int = maxi(1, incoming_phase)
	var ordinal_target_phase: int = normalized_phase + 1
	if _should_treat_phase_signal_as_threshold_ordinal(
		normalized_phase,
		ordinal_target_phase,
		hp_percentage
	):
		return ordinal_target_phase
	return normalized_phase


func _should_treat_phase_signal_as_threshold_ordinal(
	incoming_phase: int,
	ordinal_target_phase: int,
	hp_percentage: float
) -> bool:
	if get_phase_config(ordinal_target_phase).is_empty():
		return false
	var ordinal_threshold: float = _get_phase_threshold(ordinal_target_phase)
	if hp_percentage > 0.0 and ordinal_threshold > 0.0 and hp_percentage > ordinal_threshold:
		return false
	return incoming_phase <= _current_phase or _transition_queue_has_phase(incoming_phase)


func _transition_queue_has_phase(phase_id: int) -> bool:
	for transition_request: Dictionary in _transition_queue:
		if int(transition_request.get("phase_id", 0)) == phase_id:
			return true
	return false


func _get_phase_threshold(phase_id: int) -> float:
	var phase: Dictionary = get_phase_config(phase_id)
	if phase.is_empty():
		return 0.0
	return clampf(float(phase.get("hp_threshold", 0.0)), 0.0, 1.0)


func _build_phase_transition_metadata(
	phase_id: int,
	previous_phase: int,
	trigger_hp_percentage: float
) -> Dictionary:
	var phase: Dictionary = get_phase_config(phase_id)
	return {
		"boss_id": _boss_id,
		"display_name": _display_name,
		"previous_phase": previous_phase,
		"hp_threshold": _get_phase_threshold(phase_id),
		"hp_percentage": clampf(trigger_hp_percentage, 0.0, 1.0),
		"trigger_hp_percentage": clampf(trigger_hp_percentage, 0.0, 1.0),
		"current_hp_percentage": _query_health_percentage_or(trigger_hp_percentage),
		"transition_duration_sec": DEFAULT_TRANSITION_DURATION_SEC,
		"transition_animation": String(phase.get("transition_animation", "")),
		"attack_patterns": get_phase_attack_patterns(phase_id),
		"attack_speed_modifier": get_attack_speed_modifier(phase_id),
		"special_attacks": _read_array(phase.get("special_attacks", [])),
		"arena_changes": _read_array(phase.get("arena_changes", [])),
		"queued_phase_count_after_start": _transition_queue.size(),
	}


func _advance_summon_schedule(delta_sec: float) -> void:
	if _summon_adapter == null or _summon_interval_sec <= 0.0:
		return
	_summon_timer_sec += delta_sec
	while _summon_timer_sec >= _summon_interval_sec:
		_summon_timer_sec -= _summon_interval_sec
		_request_summon_if_below_cap()


func _request_summon_if_below_cap() -> void:
	if not _can_request_summon():
		return
	_summon_adapter.call("request_summon", _boss_id, _summon_id)


func _can_request_summon() -> bool:
	if _boss_id == &"" or not _summon_adapter.has_method("request_summon"):
		return false
	if _summon_id == &"" or _summon_max_count <= 0:
		return false
	return _get_active_summon_count() < _summon_max_count


func _get_active_summon_count() -> int:
	if _summon_adapter == null or not _summon_adapter.has_method("get_active_summon_count"):
		return 0
	var active_count: Variant = _summon_adapter.call("get_active_summon_count", _boss_id)
	if active_count is int or active_count is float:
		return maxi(0, int(active_count))
	return 0


func _request_summon_cleanup_once() -> void:
	if _summons_cleanup_requested or _summon_adapter == null:
		return
	if _boss_id == &"" or not _summon_adapter.has_method("cleanup_summons"):
		return
	_summons_cleanup_requested = true
	_summon_adapter.call("cleanup_summons", _boss_id)


func _request_scene_lock_once() -> void:
	if _scene_locked_by_boss or _scene_adapter == null:
		return
	if not _scene_adapter.has_method("lock_scene"):
		return
	_scene_adapter.call("lock_scene")
	_scene_locked_by_boss = true


func _request_scene_unlock_once() -> void:
	if not _scene_locked_by_boss or _scene_adapter == null:
		return
	if not _scene_adapter.has_method("unlock_scene"):
		return
	_scene_adapter.call("unlock_scene")
	_scene_locked_by_boss = false


func _dispatch_defeat_rewards_once() -> void:
	if _rewards_dispatched or _reward_adapter == null:
		return
	if _boss_id == &"" or _defeat_rewards.is_empty():
		return
	_rewards_dispatched = true
	var ability_id: StringName = StringName(String(_defeat_rewards.get("ability_unlock", "")))
	var currency: int = _read_int(_defeat_rewards.get("currency", 0))
	var skill_points: int = _read_int(_defeat_rewards.get("skill_points", 0))
	if ability_id != &"" and _reward_adapter.has_method("unlock_ability"):
		_reward_adapter.call("unlock_ability", ability_id)
	if currency > 0 and _reward_adapter.has_method("grant_currency"):
		_reward_adapter.call("grant_currency", currency)
	if skill_points > 0 and _reward_adapter.has_method("grant_skill_points"):
		_reward_adapter.call("grant_skill_points", skill_points)


func _reset_summon_timer() -> void:
	_summon_timer_sec = 0.0


func _apply_phase_to_ai(phase_id: int) -> void:
	if _ai_adapter == null or not _ai_adapter.has_method("apply_boss_phase"):
		return
	_ai_adapter.call(
		"apply_boss_phase",
		phase_id,
		get_phase_attack_patterns(phase_id),
		get_attack_speed_modifier(phase_id)
	)


func _apply_arena_changes(phase_id: int) -> void:
	if _scene_adapter == null or not _scene_adapter.has_method("apply_arena_changes"):
		return
	var phase: Dictionary = get_phase_config(phase_id)
	if phase.is_empty():
		return
	var arena_changes: Array = _read_array(phase.get("arena_changes", []))
	if arena_changes.is_empty():
		return
	_scene_adapter.call("apply_arena_changes", _boss_id, phase_id, arena_changes)


func _query_health_percentage() -> float:
	return _query_health_percentage_or(1.0)


func _query_health_percentage_or(fallback: float) -> float:
	if _health_adapter == null or not _health_adapter.has_method("get_hp_percentage"):
		return clampf(fallback, 0.0, 1.0)
	var hp_percentage: Variant = _health_adapter.call("get_hp_percentage")
	if _is_number(hp_percentage):
		return clampf(float(hp_percentage), 0.0, 1.0)
	return clampf(fallback, 0.0, 1.0)


func _is_successful_parry_type(parry_type: StringName) -> bool:
	return parry_type == &"perfect" or parry_type == &"good" or parry_type == &"late"


func _normalize_boss_config(source: Dictionary) -> Dictionary:
	if not _has_required_boss_fields(source):
		return {}
	var normalized_phases: Array = _normalize_phases(source.get("phases", []))
	var summon_rules: Dictionary = _normalize_summon_rules(source.get("summon_rules", {}))
	var desperation_rules: Dictionary = _normalize_desperation_rules(
		source.get("desperation_rules", {})
	)
	var parry_rules: Dictionary = _normalize_parry_rules(source.get("parry_rules", {}))
	if normalized_phases.is_empty():
		return {}
	if summon_rules.is_empty():
		return {}
	if desperation_rules.is_empty():
		return {}
	if parry_rules.is_empty():
		return {}
	return {
		"boss_id": StringName(String(source.get("boss_id", ""))),
		"display_name": String(source.get("display_name", "")),
		"max_hp": _read_int(source.get("max_hp", 0)),
		"phases": normalized_phases,
		"summon_rules": summon_rules,
		"desperation_rules": desperation_rules,
		"parry_rules": parry_rules,
		"defeat_rewards": (source.get("defeat_rewards", {}) as Dictionary).duplicate(true),
		"arena_bounds": _read_rect2(source.get("arena_bounds", {})),
	}


func _has_required_boss_fields(source: Dictionary) -> bool:
	var max_hp: int = _read_int(source.get("max_hp", 0))
	var required_fields: Array = [
		"boss_id",
		"display_name",
		"max_hp",
		"phases",
		"summon_rules",
		"desperation_rules",
		"parry_rules",
		"defeat_rewards",
		"arena_bounds",
	]
	return source.has_all(required_fields) \
		and source.get("boss_id", "") is String \
		and not String(source.get("boss_id", "")).is_empty() \
		and source.get("display_name", "") is String \
		and max_hp > 0 \
		and source.get("phases", []) is Array \
		and _is_valid_summon_rules(source.get("summon_rules", {})) \
		and _is_valid_desperation_rules(source.get("desperation_rules", {})) \
		and _is_valid_parry_rules(source.get("parry_rules", {})) \
		and _is_valid_rewards(source.get("defeat_rewards", {})) \
		and source.get("arena_bounds", {}) is Dictionary


func _normalize_phases(source_value: Variant) -> Array:
	if not (source_value is Array):
		return []
	var normalized: Array = []
	for phase_value: Variant in source_value:
		if phase_value is Dictionary:
			var phase: Dictionary = _normalize_phase(phase_value as Dictionary)
			if not phase.is_empty():
				normalized.append(phase)
	return normalized


func _normalize_phase(source: Dictionary) -> Dictionary:
	if not _has_required_phase_fields(source):
		return {}
	return {
		"phase_id": maxi(1, _read_int(source.get("phase_id", 1))),
		"hp_threshold": clampf(float(source.get("hp_threshold", 1.0)), 0.0, 1.0),
		"attack_patterns": (source.get("attack_patterns", []) as Array).duplicate(true),
		"attack_speed_modifier": maxf(0.1, float(source.get("attack_speed_modifier", 1.0))),
		"special_attacks": _read_array(source.get("special_attacks", [])),
		"transition_animation": String(source.get("transition_animation", "")),
		"arena_changes": _read_array(source.get("arena_changes", [])),
	}


func _normalize_summon_rules(source_value: Variant) -> Dictionary:
	if not _is_valid_summon_rules(source_value):
		return {}
	var source: Dictionary = source_value
	return {
		"phase_id": maxi(1, _read_int(source.get("phase_id", 1))),
		"summon_id": StringName(String(source.get("summon_id", ""))),
		"summon_interval_sec": maxf(0.01, float(source.get("summon_interval_sec", 0.0))),
		"summon_max_count": maxi(1, _read_int(source.get("summon_max_count", 1))),
	}


func _normalize_desperation_rules(source_value: Variant) -> Dictionary:
	if not _is_valid_desperation_rules(source_value):
		return {}
	var source: Dictionary = source_value
	return {
		"phase_id": maxi(1, _read_int(source.get("phase_id", 1))),
		"hp_threshold": clampf(float(source.get("hp_threshold", 0.0)), 0.0, 1.0),
		"defense_modifier": maxf(0.01, float(source.get("defense_modifier", 1.0))),
	}


func _normalize_parry_rules(source_value: Variant) -> Dictionary:
	if not _is_valid_parry_rules(source_value):
		return {}
	var source: Dictionary = source_value
	return {
		"damage_multiplier": maxf(
			DEFAULT_PARRY_DAMAGE_MULTIPLIER,
			float(source.get("damage_multiplier", DEFAULT_PARRY_DAMAGE_MULTIPLIER))
		),
		"enter_stun": bool(source.get("enter_stun", false)),
	}


func _has_required_phase_fields(source: Dictionary) -> bool:
	var required_fields: Array = [
		"phase_id",
		"hp_threshold",
		"attack_patterns",
		"attack_speed_modifier",
		"transition_animation",
	]
	return source.has_all(required_fields) \
		and _read_int(source.get("phase_id", 0)) > 0 \
		and (source.get("hp_threshold", 0.0) is int or source.get("hp_threshold", 0.0) is float) \
		and source.get("attack_patterns", []) is Array \
		and (source.get("attack_speed_modifier", 0.0) is int \
			or source.get("attack_speed_modifier", 0.0) is float) \
		and source.get("transition_animation", "") is String


func _is_valid_summon_rules(source_value: Variant) -> bool:
	if not (source_value is Dictionary):
		return false
	var source: Dictionary = source_value
	var required_fields: Array = [
		"phase_id",
		"summon_id",
		"summon_interval_sec",
		"summon_max_count",
	]
	return source.has_all(required_fields) \
		and _read_int(source.get("phase_id", 0)) > 0 \
		and source.get("summon_id", "") is String \
		and not String(source.get("summon_id", "")).is_empty() \
		and _is_number(source.get("summon_interval_sec", 0.0)) \
		and float(source.get("summon_interval_sec", 0.0)) > 0.0 \
		and _read_int(source.get("summon_max_count", 0)) > 0


func _is_valid_desperation_rules(source_value: Variant) -> bool:
	if not (source_value is Dictionary):
		return false
	var source: Dictionary = source_value
	var required_fields: Array = [
		"phase_id",
		"hp_threshold",
		"defense_modifier",
	]
	return source.has_all(required_fields) \
		and _read_int(source.get("phase_id", 0)) > 0 \
		and _is_number(source.get("hp_threshold", 0.0)) \
		and float(source.get("hp_threshold", 0.0)) > 0.0 \
		and float(source.get("hp_threshold", 0.0)) <= 1.0 \
		and _is_number(source.get("defense_modifier", 0.0)) \
		and float(source.get("defense_modifier", 0.0)) > 0.0


func _is_valid_parry_rules(source_value: Variant) -> bool:
	if not (source_value is Dictionary):
		return false
	var source: Dictionary = source_value
	var required_fields: Array = [
		"damage_multiplier",
		"enter_stun",
	]
	return source.has_all(required_fields) \
		and _is_number(source.get("damage_multiplier", 0.0)) \
		and float(source.get("damage_multiplier", 0.0)) >= DEFAULT_PARRY_DAMAGE_MULTIPLIER \
		and source.get("enter_stun", false) is bool


func _is_valid_rewards(source_value: Variant) -> bool:
	if not (source_value is Dictionary):
		return false
	var rewards: Dictionary = source_value
	return rewards.get("ability_unlock", "") is String \
		and _read_int(rewards.get("currency", -1)) >= 0 \
		and _read_int(rewards.get("skill_points", -1)) >= 0


func _read_array(source_value: Variant) -> Array:
	if source_value is Array:
		return (source_value as Array).duplicate(true)
	return []


func _read_int(source_value: Variant) -> int:
	if source_value is int:
		return int(source_value)
	if source_value is float and float(source_value) == floorf(float(source_value)):
		return int(source_value)
	return 0


func _is_number(source_value: Variant) -> bool:
	return source_value is int or source_value is float


func _read_rect2(source_value: Variant) -> Rect2:
	if not (source_value is Dictionary):
		return Rect2()
	var source: Dictionary = source_value
	return Rect2(
		_read_vector2(source.get("position", {})),
		_read_vector2(source.get("size", {}))
	)


func _read_vector2(source_value: Variant) -> Vector2:
	if not (source_value is Dictionary):
		return Vector2.ZERO
	var source: Dictionary = source_value
	return Vector2(float(source.get("x", 0.0)), float(source.get("y", 0.0)))


func _apply_normalized_config(normalized: Dictionary) -> void:
	_boss_id = normalized["boss_id"]
	_display_name = normalized["display_name"]
	_max_hp = normalized["max_hp"]
	_phases = normalized["phases"]
	_apply_summon_rules(normalized["summon_rules"])
	_apply_desperation_rules(normalized["desperation_rules"])
	_apply_parry_rules(normalized["parry_rules"])
	_defeat_rewards = normalized["defeat_rewards"]
	_arena_bounds = normalized["arena_bounds"]


func _apply_summon_rules(summon_rules: Dictionary) -> void:
	_summon_phase_id = int(summon_rules["phase_id"])
	_summon_id = StringName(String(summon_rules["summon_id"]))
	_summon_interval_sec = float(summon_rules["summon_interval_sec"])
	_summon_max_count = int(summon_rules["summon_max_count"])


func _apply_desperation_rules(desperation_rules: Dictionary) -> void:
	_desperation_phase_id = int(desperation_rules["phase_id"])
	_desperation_hp_threshold = float(desperation_rules["hp_threshold"])
	_desperation_defense_modifier = float(desperation_rules["defense_modifier"])


func _apply_parry_rules(parry_rules: Dictionary) -> void:
	_parry_damage_multiplier = float(parry_rules["damage_multiplier"])
	_parry_enter_stun = bool(parry_rules["enter_stun"])


func _clear_config() -> void:
	_boss_id = &""
	_display_name = ""
	_max_hp = 0
	_phases.clear()
	_defeat_rewards.clear()
	_arena_bounds = Rect2()
	_reset_summon_config()
	_reset_desperation_config()
	_reset_parry_config()
	_reset_transition_state()
	_reset_summon_state()
	_reset_reward_state()


func _reset_transition_state() -> void:
	_current_phase = 1
	_transition_queue.clear()
	_transition_active = false
	_transition_remaining_sec = 0.0


func _reset_summon_state() -> void:
	_reset_summon_timer()
	_summons_cleanup_requested = false


func _reset_summon_config() -> void:
	_summon_phase_id = 0
	_summon_id = &""
	_summon_interval_sec = 0.0
	_summon_max_count = 0


func _reset_desperation_config() -> void:
	_desperation_phase_id = 0
	_desperation_hp_threshold = 0.0
	_desperation_defense_modifier = DEFAULT_DEFENSE_MODIFIER


func _reset_parry_config() -> void:
	_parry_damage_multiplier = DEFAULT_PARRY_DAMAGE_MULTIPLIER
	_parry_enter_stun = false


func _reset_reward_state() -> void:
	_rewards_dispatched = false
