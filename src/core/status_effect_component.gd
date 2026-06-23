## Core entity component for buff/debuff catalog and active status state.
extends Node
class_name StatusEffectComponent

signal status_applied(target_id: int, effect_id: StringName)
signal status_expired(target_id: int, effect_id: StringName)

enum EffectCategory {
	DEBUFF,
	BUFF,
}

const DEFAULT_MAX_EFFECTS: int = 5
const DOT_TICK_INTERVAL_SEC: float = 1.0
const SCENE_CLEANUP_SIGNALS: Array[StringName] = [
	&"on_scene_changed",
	&"on_scene_loaded",
	&"on_scene_transition_started",
	&"on_scene_transition_requested",
]

const EFFECT_POISON: StringName = &"poison"
const EFFECT_SLOW: StringName = &"slow"
const EFFECT_STUN: StringName = &"stun"
const EFFECT_BURN: StringName = &"burn"
const EFFECT_SPEED_BOOST: StringName = &"speed_boost"
const EFFECT_DAMAGE_BOOST: StringName = &"damage_boost"
const EFFECT_INVINCIBLE: StringName = &"invincible"

const EFFECT_IDS: Array[StringName] = [
	EFFECT_POISON,
	EFFECT_SLOW,
	EFFECT_STUN,
	EFFECT_BURN,
	EFFECT_SPEED_BOOST,
	EFFECT_DAMAGE_BOOST,
	EFFECT_INVINCIBLE,
]

const EFFECT_CONFIG: Dictionary = {
	EFFECT_POISON: {
		"category": EffectCategory.DEBUFF,
		"base_duration_sec": 5.0,
		"priority": 30,
		"dot_damage": 3,
		"movement_modifier": 1.0,
		"damage_modifier": 1.0,
	},
	EFFECT_SLOW: {
		"category": EffectCategory.DEBUFF,
		"base_duration_sec": 2.0,
		"priority": 60,
		"dot_damage": 0,
		"movement_modifier": 0.7,
		"damage_modifier": 1.0,
	},
	EFFECT_STUN: {
		"category": EffectCategory.DEBUFF,
		"base_duration_sec": 1.0,
		"priority": 100,
		"dot_damage": 0,
		"movement_modifier": 0.0,
		"damage_modifier": 1.0,
	},
	EFFECT_BURN: {
		"category": EffectCategory.DEBUFF,
		"base_duration_sec": 3.0,
		"priority": 20,
		"dot_damage": 5,
		"movement_modifier": 0.9,
		"damage_modifier": 1.0,
	},
	EFFECT_SPEED_BOOST: {
		"category": EffectCategory.BUFF,
		"base_duration_sec": 3.0,
		"priority": 15,
		"dot_damage": 0,
		"movement_modifier": 1.3,
		"damage_modifier": 1.0,
	},
	EFFECT_DAMAGE_BOOST: {
		"category": EffectCategory.BUFF,
		"base_duration_sec": 5.0,
		"priority": 10,
		"dot_damage": 0,
		"movement_modifier": 1.0,
		"damage_modifier": 1.25,
	},
	EFFECT_INVINCIBLE: {
		"category": EffectCategory.BUFF,
		"base_duration_sec": 0.5,
		"priority": 5,
		"dot_damage": 0,
		"movement_modifier": 1.0,
		"damage_modifier": 1.0,
	},
}

var _active_effects: Array[Dictionary] = []
var _max_effects: int = DEFAULT_MAX_EFFECTS
var _entity_id: int = 0
var _is_boss: bool = false
var _health_adapter: Object = null
var _scene_adapter: Object = null


## Configures the owning entity identity for local status filtering.
func configure_entity(entity_id: int, is_boss: bool = false) -> void:
	_entity_id = entity_id
	_is_boss = is_boss


## Injects a HealthComponent-compatible adapter for status DoT and death cleanup.
func set_health_adapter(health_adapter: Object) -> void:
	if _health_adapter == health_adapter:
		return
	_disconnect_health_adapter()
	_health_adapter = health_adapter
	_connect_health_adapter()


## Injects a SceneManager-compatible adapter for transition cleanup.
func set_scene_adapter(scene_adapter: Object) -> void:
	if _scene_adapter == scene_adapter:
		return
	_disconnect_scene_adapter()
	_scene_adapter = scene_adapter
	_connect_scene_adapter()


## Returns the maximum number of simultaneous effects this component supports.
func get_max_effects() -> int:
	return _max_effects


## Returns a defensive copy of currently active effect instances.
func get_active_effects() -> Array:
	return _active_effects.duplicate(true)


## Returns all supported effect ids in GDD priority-table order.
func get_effect_ids() -> Array[StringName]:
	return EFFECT_IDS.duplicate()


## Returns immutable catalog metadata for an effect id, or an empty dictionary.
func get_effect_config(effect_id: StringName) -> Dictionary:
	if not EFFECT_CONFIG.has(effect_id):
		return {}
	return (EFFECT_CONFIG[effect_id] as Dictionary).duplicate(true)


## Returns an effect's priority, where larger numbers have higher priority.
func get_effect_priority(effect_id: StringName) -> int:
	var config: Dictionary = get_effect_config(effect_id)
	return int(config.get("priority", 0))


## Applies or refreshes a status effect on this component's owning entity.
func apply_status(target_id: int, effect_id: StringName, source_id: int = 0) -> bool:
	if _entity_id != 0 and target_id != _entity_id:
		return false
	if not EFFECT_CONFIG.has(effect_id) or _is_immune_to_effect(effect_id):
		return false
	var existing_index: int = _find_effect_index(effect_id)
	if existing_index >= 0:
		_refresh_existing_effect(existing_index, effect_id)
		return true
	if _active_effects.size() >= _max_effects:
		_evict_oldest_effect()
	_active_effects.append(_make_effect_instance(target_id, effect_id, source_id))
	status_applied.emit(target_id, effect_id)
	if effect_id == EFFECT_INVINCIBLE:
		_grant_invincible_iframes()
	return true


## Returns whether this component currently has the requested effect.
func has_status(effect_id: StringName) -> bool:
	return _find_effect_index(effect_id) >= 0


## Returns remaining duration in seconds for an active effect.
func get_remaining_duration(effect_id: StringName) -> float:
	var index: int = _find_effect_index(effect_id)
	if index < 0:
		return 0.0
	return float(_active_effects[index].get("remaining_duration_sec", 0.0))


## Advances active status durations and applies deterministic DoT ticks.
func advance_time(delta_seconds: float) -> void:
	if delta_seconds <= 0.0 or _active_effects.is_empty():
		return
	var expired_indices: Array[int] = []
	for index: int in range(_active_effects.size()):
		var effect: Dictionary = _active_effects[index]
		effect["remaining_duration_sec"] = (
			float(effect.get("remaining_duration_sec", 0.0)) - delta_seconds
		)
		_process_dot_ticks(effect, delta_seconds)
		_active_effects[index] = effect
		if float(effect["remaining_duration_sec"]) <= 0.0:
			expired_indices.append(index)
	_remove_expired_effects(expired_indices)


## Returns the product of all active movement modifiers.
func get_movement_modifier() -> float:
	var modifier: float = 1.0
	for effect: Dictionary in _active_effects:
		modifier *= float(effect.get("movement_modifier", 1.0))
	return modifier


## Returns the product of all active damage modifiers.
func get_damage_modifier() -> float:
	var modifier: float = 1.0
	for effect: Dictionary in _active_effects:
		modifier *= float(effect.get("damage_modifier", 1.0))
	return modifier


## Clears all active effects and emits one expiration per removed effect.
func clear_all_effects() -> void:
	if _active_effects.is_empty():
		return
	for effect: Dictionary in _active_effects:
		status_expired.emit(
			int(effect.get("target_id", _entity_id)),
			StringName(effect.get("effect_id", &""))
		)
	_active_effects.clear()


## SceneManager-compatible hook for scene transition cleanup signals.
func handle_scene_transition_cleanup(
	_old_scene: Variant = null,
	_new_scene: Variant = null
) -> void:
	clear_all_effects()


func _find_effect_index(effect_id: StringName) -> int:
	for index: int in range(_active_effects.size()):
		if _active_effects[index].get("effect_id", &"") == effect_id:
			return index
	return -1


func _is_immune_to_effect(effect_id: StringName) -> bool:
	if _is_boss and effect_id == EFFECT_STUN:
		return true
	if _is_debuff(effect_id) and _is_target_invulnerable():
		return true
	return false


func _is_debuff(effect_id: StringName) -> bool:
	if not EFFECT_CONFIG.has(effect_id):
		return false
	return int((EFFECT_CONFIG[effect_id] as Dictionary).get("category", EffectCategory.BUFF)) == (
		EffectCategory.DEBUFF
	)


func _is_target_invulnerable() -> bool:
	if has_status(EFFECT_INVINCIBLE):
		return true
	if _health_adapter == null:
		return false
	if _health_adapter.has_method("is_invincible"):
		return bool(_health_adapter.call("is_invincible"))
	if _health_adapter.has_method("is_invulnerable"):
		return bool(_health_adapter.call("is_invulnerable"))
	if _health_adapter.has_method("is_invulnerable_to_damage"):
		return bool(_health_adapter.call("is_invulnerable_to_damage"))
	if _health_adapter.has_method("get_iframe_remaining"):
		return int(_health_adapter.call("get_iframe_remaining")) > 0
	return false


func _refresh_existing_effect(effect_index: int, effect_id: StringName) -> void:
	var config: Dictionary = EFFECT_CONFIG[effect_id]
	var effect: Dictionary = _active_effects[effect_index]
	var base_duration_sec: float = float(config["base_duration_sec"])
	var current_duration_sec: float = float(effect.get("remaining_duration_sec", 0.0))
	effect["remaining_duration_sec"] = maxf(current_duration_sec, base_duration_sec)
	effect["tick_elapsed_sec"] = 0.0
	_active_effects[effect_index] = effect


func _make_effect_instance(target_id: int, effect_id: StringName, source_id: int) -> Dictionary:
	var config: Dictionary = EFFECT_CONFIG[effect_id]
	return {
		"effect_id": effect_id,
		"target_id": target_id,
		"source_id": source_id,
		"remaining_duration_sec": float(config["base_duration_sec"]),
		"base_duration_sec": float(config["base_duration_sec"]),
		"tick_elapsed_sec": 0.0,
		"category": int(config["category"]),
		"priority": int(config["priority"]),
		"dot_damage": int(config["dot_damage"]),
		"movement_modifier": float(config["movement_modifier"]),
		"damage_modifier": float(config["damage_modifier"]),
	}


func _process_dot_ticks(effect: Dictionary, delta_seconds: float) -> void:
	var dot_damage: int = int(effect.get("dot_damage", 0))
	if dot_damage <= 0:
		return
	var tick_elapsed_sec: float = float(effect.get("tick_elapsed_sec", 0.0))
	tick_elapsed_sec += delta_seconds
	while tick_elapsed_sec >= DOT_TICK_INTERVAL_SEC:
		tick_elapsed_sec -= DOT_TICK_INTERVAL_SEC
		_apply_dot_damage(effect, dot_damage)
	effect["tick_elapsed_sec"] = tick_elapsed_sec


func _apply_dot_damage(effect: Dictionary, dot_damage: int) -> void:
	if _health_adapter == null or not _health_adapter.has_method("apply_damage"):
		return
	var metadata: Dictionary = {
		"effect_id": effect.get("effect_id", &""),
		"source_id": int(effect.get("source_id", 0)),
		"target_id": int(effect.get("target_id", _entity_id)),
		"damage_type": &"status_dot",
	}
	_health_adapter.call("apply_damage", dot_damage, metadata)


func _grant_invincible_iframes() -> void:
	if _health_adapter == null or not _health_adapter.has_method("grant_iframes"):
		return
	var base_duration_sec: float = float(EFFECT_CONFIG[EFFECT_INVINCIBLE]["base_duration_sec"])
	var iframe_count: int = maxi(1, int(round(base_duration_sec * 60.0)))
	_health_adapter.call("grant_iframes", iframe_count)


func _remove_expired_effects(expired_indices: Array[int]) -> void:
	for offset: int in range(expired_indices.size() - 1, -1, -1):
		var index: int = expired_indices[offset]
		var effect: Dictionary = _active_effects[index]
		_active_effects.remove_at(index)
		status_expired.emit(
			int(effect.get("target_id", _entity_id)),
			StringName(effect.get("effect_id", &""))
		)


func _evict_oldest_effect() -> void:
	if _active_effects.is_empty():
		return
	var effect: Dictionary = _active_effects[0]
	_active_effects.remove_at(0)
	status_expired.emit(
		int(effect.get("target_id", _entity_id)),
		StringName(effect.get("effect_id", &""))
	)


func _handle_owner_death(entity_id: int = -1, _metadata: Dictionary = {}) -> void:
	if entity_id != -1 and entity_id != _entity_id:
		return
	clear_all_effects()


func _connect_health_adapter() -> void:
	if _health_adapter == null or not _health_adapter.has_signal("on_death"):
		return
	var death_signal: Signal = _health_adapter.get("on_death")
	if not death_signal.is_connected(_handle_owner_death):
		death_signal.connect(_handle_owner_death)


func _disconnect_health_adapter() -> void:
	if _health_adapter == null or not _health_adapter.has_signal("on_death"):
		return
	var death_signal: Signal = _health_adapter.get("on_death")
	if death_signal.is_connected(_handle_owner_death):
		death_signal.disconnect(_handle_owner_death)


func _connect_scene_adapter() -> void:
	if _scene_adapter == null:
		return
	for signal_name: StringName in SCENE_CLEANUP_SIGNALS:
		if not _scene_adapter.has_signal(signal_name):
			continue
		var scene_signal: Signal = _scene_adapter.get(signal_name)
		if not scene_signal.is_connected(handle_scene_transition_cleanup):
			scene_signal.connect(handle_scene_transition_cleanup)


func _disconnect_scene_adapter() -> void:
	if _scene_adapter == null:
		return
	for signal_name: StringName in SCENE_CLEANUP_SIGNALS:
		if not _scene_adapter.has_signal(signal_name):
			continue
		var scene_signal: Signal = _scene_adapter.get(signal_name)
		if scene_signal.is_connected(handle_scene_transition_cleanup):
			scene_signal.disconnect(handle_scene_transition_cleanup)
