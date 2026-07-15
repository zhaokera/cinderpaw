## Core entity component for combat state, input consumption, and battle stats.
extends Node
class_name CombatComponent

signal on_state_changed(old_state: int, new_state: int)
signal on_attack_hit(metadata: Dictionary)
signal on_light_attack_frame_advanced(combo_index: int, attack_frame: int)
signal on_dodge_counter_active(active: bool)
signal on_parry_resolved(metadata: Dictionary)
signal on_heavy_attack_released(metadata: Dictionary)
signal on_aerial_bounce_requested(metadata: Dictionary)

enum CombatState {
	IDLE,
	ATTACKING,
	DODGING,
	PARRYING,
	HIT_STUN,
	CHARGING,
}

const MAX_COMBO_INDEX: int = 2
const COMBO_TIMEOUT_SEC: float = 0.3
const DODGE_IFRAME_START: int = 3
const DODGE_IFRAME_END: int = 10
const DODGE_TOTAL_FRAMES: int = 12
const DODGE_COOLDOWN_SEC: float = 0.5
const DODGE_COUNTER_WINDOW_FRAMES: int = 30
const DODGE_COUNTER_CRIT_BONUS_FRAMES: int = 3
const PARRY_PERFECT_END_FRAME: int = 6
const PARRY_GOOD_END_FRAME: int = 12
const PARRY_LATE_END_FRAME: int = 18
const PARRY_STUN_SECONDS: float = 1.0
const HEAVY_CHARGE_MIN_SEC: float = 0.5
const HEAVY_CHARGE_MAX_SEC: float = 1.5
const HIT_STUN_FRAMES_PER_STACK: int = 12
const HIT_STUN_MAX_STACKS: int = 3
const CAT_ENERGY_MAX: int = 100
const CAT_ENERGY_OUT_OF_COMBAT_RESET_SEC: float = 10.0
const ULTIMATE_CAT_ENERGY_COST: int = 80
const WEAPON_CAT_CLAW: StringName = &"cat_claw"
const WEAPON_LONG_TAIL: StringName = &"long_tail"
const WEAPON_FISH_BONE: StringName = &"fish_bone"
const WEAPON_ELECTRO_BELL: StringName = &"electro_bell"
const LIGHT_ATTACK_FRAME_DATA: Array[Dictionary] = [
	{
		"startup_frames": 4,
		"active_frames": 4,
		"post_active_recovery_frames": 4,
		"recovery_frames": 8,
		"total_frames": 12,
	},
	{
		"startup_frames": 6,
		"active_frames": 6,
		"post_active_recovery_frames": 6,
		"recovery_frames": 12,
		"total_frames": 18,
	},
	{
		"startup_frames": 10,
		"active_frames": 10,
		"post_active_recovery_frames": 10,
		"recovery_frames": 20,
		"total_frames": 30,
	},
]
const CAT_ENERGY_GAIN_BY_EVENT: Dictionary = {
	&"light_0": 5,
	&"light_1": 8,
	&"light_2": 12,
	&"heavy": 10,
	&"aerial": 8,
	&"special": 3,
	&"parry_counter": 15,
	&"perfect_dodge": 15,
	&"perfect_parry": 20,
	&"good_parry": 10,
	&"damage_taken": 3,
}
const SPECIAL_CAT_ENERGY_COST_BY_WEAPON: Dictionary = {
	WEAPON_CAT_CLAW: 30,
	WEAPON_LONG_TAIL: 40,
	WEAPON_FISH_BONE: 50,
	WEAPON_ELECTRO_BELL: 60,
}
const SPECIAL_COOLDOWN_SEC_BY_WEAPON: Dictionary = {
	WEAPON_CAT_CLAW: 8.0,
	WEAPON_LONG_TAIL: 10.0,
	WEAPON_FISH_BONE: 12.0,
	WEAPON_ELECTRO_BELL: 15.0,
}
const ULTIMATE_COOLDOWN_SEC_BY_WEAPON: Dictionary = {
	WEAPON_CAT_CLAW: 60.0,
	WEAPON_LONG_TAIL: 75.0,
	WEAPON_FISH_BONE: 90.0,
	WEAPON_ELECTRO_BELL: 120.0,
}

var _current_state: CombatState = CombatState.IDLE
var _previous_state: CombatState = CombatState.IDLE
var _combo_index: int = 0
var _attack_frame: int = 0
var _combo_elapsed_sec: float = 0.0
var _dodge_frame: int = 0
var _dodge_cooldown_remaining_sec: float = 0.0
var _dodge_counter_window: int = 0
var _parry_frame: int = 0
var _parry_resolved: bool = false
var _charge_elapsed_sec: float = 0.0
var _hit_stun_stack_count: int = 0
var _hit_stun_remaining_frames: int = 0
var _out_of_combat_elapsed_sec: float = 0.0
var _special_cooldowns_remaining: Dictionary = {}
var _ultimate_cooldowns_remaining: Dictionary = {}
var _current_weapon_id: StringName = WEAPON_CAT_CLAW
var _pending_crit_window_bonus_frames: int = 0
var _hurtbox_adapter: Object = null
var _ultimate_provider: Object = null
var _damage_calculator_adapter: Object = null
var _health_adapter: Object = null
var _collision_adapter: Object = null
var _cat_energy: int = 0
var _focus_mode_active: bool = false
var _hits_landed: int = 0
var _total_damage_dealt: int = 0
var _parry_attempts: int = 0
var _parries: int = 0
var _dodge_attempts: int = 0
var _dodges: int = 0
var _input_dispatcher: Object = null


func _ready() -> void:
	var input_manager: Node = get_node_or_null("/root/InputManager")
	if input_manager != null:
		set_input_dispatcher(input_manager)


func _physics_process(delta: float) -> void:
	advance_dodge_cooldown_time(delta)
	advance_special_cooldown_time(delta)
	advance_ultimate_cooldown_time(delta)
	advance_out_of_combat_time(delta)
	if _current_state != CombatState.DODGING:
		advance_dodge_counter_frames(1)
	match _current_state:
		CombatState.IDLE:
			_process_idle()
		CombatState.ATTACKING:
			_process_attacking()
		CombatState.DODGING:
			_process_dodging()
		CombatState.PARRYING:
			_process_parrying()
		CombatState.HIT_STUN:
			_process_hit_stun()
		CombatState.CHARGING:
			_process_charging()


## Injects a source that emits action_triggered(action_id, metadata).
func set_input_dispatcher(input_dispatcher: Object) -> void:
	if _input_dispatcher == input_dispatcher:
		return
	_disconnect_input_dispatcher()
	_input_dispatcher = input_dispatcher
	if _input_dispatcher != null and _input_dispatcher.has_signal("action_triggered"):
		var input_signal: Signal = _input_dispatcher.get("action_triggered")
		if not input_signal.is_connected(on_action_triggered):
			input_signal.connect(on_action_triggered)


## Injects the collision-side hurtbox state adapter.
func set_hurtbox_adapter(hurtbox_adapter: Object) -> void:
	_hurtbox_adapter = hurtbox_adapter


## Injects the skill-tree-side ultimate unlock provider.
func set_ultimate_provider(ultimate_provider: Object) -> void:
	_ultimate_provider = ultimate_provider


## Injects a collision adapter that emits on_hit_confirmed(event).
func set_collision_adapter(collision_adapter: Object) -> void:
	if _collision_adapter == collision_adapter:
		return
	_disconnect_collision_adapter()
	_collision_adapter = collision_adapter
	if _collision_adapter != null and _collision_adapter.has_signal("on_hit_confirmed"):
		var hit_signal: Signal = _collision_adapter.get("on_hit_confirmed")
		if not hit_signal.is_connected(on_hit_confirmed):
			hit_signal.connect(on_hit_confirmed)


## Injects an optional DamageCalculator-compatible adapter.
func set_damage_calculator_adapter(damage_calculator_adapter: Object) -> void:
	_damage_calculator_adapter = damage_calculator_adapter


## Injects an optional HealthComponent-compatible adapter.
func set_health_adapter(health_adapter: Object) -> void:
	_health_adapter = health_adapter


## Consumes normalized InputManager actions.
func on_action_triggered(action_id: StringName, metadata: Dictionary = {}) -> void:
	match _current_state:
		CombatState.IDLE:
			_handle_idle_action(action_id, metadata)
		CombatState.ATTACKING:
			_handle_attacking_action(action_id, metadata)
		CombatState.CHARGING:
			_handle_charging_action(action_id, metadata)


## Returns the current combat FSM state.
func get_current_state() -> int:
	return _current_state


## Updates the active weapon id used by combat-side hit metadata and weapon gates.
func set_current_weapon_id(weapon_id: StringName) -> void:
	if not SPECIAL_CAT_ENERGY_COST_BY_WEAPON.has(weapon_id):
		return
	_current_weapon_id = weapon_id


## Returns the active weapon id currently known by CombatComponent.
func get_current_weapon_id() -> StringName:
	return _current_weapon_id


## Returns the active light combo stage.
func get_combo_index() -> int:
	return _combo_index


## Returns the current frame inside the active attack animation.
func get_attack_frame() -> int:
	return _attack_frame


## Returns the current frame inside the active dodge.
func get_dodge_frame() -> int:
	return _dodge_frame


## Returns the current frame inside the active parry.
func get_parry_frame() -> int:
	return _parry_frame


## Returns frame data for a light attack stage.
func get_light_attack_frame_data(stage: int) -> Dictionary:
	var safe_stage: int = clampi(stage, 0, MAX_COMBO_INDEX)
	return LIGHT_ATTACK_FRAME_DATA[safe_stage].duplicate(true)


## Returns current cat energy.
func get_cat_energy() -> int:
	return _cat_energy


## Adds cat energy for a combat event and returns the amount granted.
func add_cat_energy_for_event(event_id: StringName) -> int:
	var amount: int = int(CAT_ENERGY_GAIN_BY_EVENT.get(event_id, 0))
	if amount <= 0:
		return 0
	_cat_energy = mini(CAT_ENERGY_MAX, _cat_energy + amount)
	_mark_damage_interaction()
	return amount


## Attempts to spend cat energy without allowing negative balances.
func consume_cat_energy(amount: int) -> bool:
	if amount <= 0:
		return true
	if _cat_energy < amount:
		return false
	_cat_energy -= amount
	return true


## Returns whether a weapon special passes shared cat-energy and cooldown gates.
func can_use_special(weapon_id: StringName) -> bool:
	var required_energy: int = _get_special_cat_energy_cost(weapon_id)
	if required_energy <= 0:
		return false
	return _cat_energy >= required_energy and get_special_cooldown_remaining(weapon_id) <= 0.0


## Consumes resources and starts cooldown for a weapon special if gates pass.
func try_use_special(weapon_id: StringName) -> bool:
	if not can_use_special(weapon_id):
		return false
	var required_energy: int = _get_special_cat_energy_cost(weapon_id)
	if not consume_cat_energy(required_energy):
		return false
	_special_cooldowns_remaining[weapon_id] = _get_special_cooldown_sec(weapon_id)
	return true


## Returns remaining special cooldown for a weapon.
func get_special_cooldown_remaining(weapon_id: StringName) -> float:
	return maxf(0.0, float(_special_cooldowns_remaining.get(weapon_id, 0.0)))


## Returns whether a weapon ultimate passes shared unlock, energy, and cooldown gates.
func can_use_ultimate(weapon_id: StringName) -> bool:
	return (
		_has_unlocked_ultimate(weapon_id)
		and _cat_energy >= ULTIMATE_CAT_ENERGY_COST
		and get_ultimate_cooldown_remaining(weapon_id) <= 0.0
	)


## Consumes resources and starts cooldown for a weapon ultimate if gates pass.
func try_use_ultimate(weapon_id: StringName) -> bool:
	if not can_use_ultimate(weapon_id):
		return false
	if not consume_cat_energy(ULTIMATE_CAT_ENERGY_COST):
		return false
	_ultimate_cooldowns_remaining[weapon_id] = _get_ultimate_cooldown_sec(weapon_id)
	return true


## Returns remaining ultimate cooldown for a weapon.
func get_ultimate_cooldown_remaining(weapon_id: StringName) -> float:
	return maxf(0.0, float(_ultimate_cooldowns_remaining.get(weapon_id, 0.0)))


## Returns true while HealthComponent focus mode is active.
func is_focus_mode_active() -> bool:
	return _focus_mode_active


## Returns current heavy charge progress for UI and tests.
func get_charge_ratio() -> float:
	if _current_state != CombatState.CHARGING:
		return 0.0
	return clampf(_charge_elapsed_sec / HEAVY_CHARGE_MAX_SEC, 0.0, 1.0)


## Returns current hit-stun stack count.
func get_hit_stun_stack_count() -> int:
	return _hit_stun_stack_count


## Returns remaining hit-stun frames.
func get_hit_stun_remaining_frames() -> int:
	return _hit_stun_remaining_frames


## Returns true while dodge i-frames should block incoming damage.
func is_dodge_iframe_active() -> bool:
	if _current_state != CombatState.DODGING:
		return false
	return _dodge_frame >= DODGE_IFRAME_START and _dodge_frame <= DODGE_IFRAME_END


## Returns true while HealthComponent should treat incoming damage as ignored.
func is_invulnerable_to_damage() -> bool:
	return is_dodge_iframe_active()


## Classifies a parry timing frame for counter metadata.
func classify_parry_timing(frame: int) -> StringName:
	if frame < 0:
		return &"miss"
	if frame <= PARRY_PERFECT_END_FRAME:
		return &"perfect"
	if frame <= PARRY_GOOD_END_FRAME:
		return &"good"
	if frame <= PARRY_LATE_END_FRAME:
		return &"late"
	return &"miss"


## Returns combat statistics for death metadata and diagnostics.
func get_battle_stats() -> Dictionary:
	return {
		"hits_landed": _hits_landed,
		"total_damage_dealt": _total_damage_dealt,
		"parry_attempts": _parry_attempts,
		"parries": _parries,
		"parry_success_rate": _safe_rate(_parries, _parry_attempts),
		"dodge_attempts": _dodge_attempts,
		"dodges": _dodges,
		"dodge_success_rate": _safe_rate(_dodges, _dodge_attempts),
		"cat_energy": _cat_energy,
		"hits_received_by_pattern": {},
	}


## Returns true while the current light attack is in recovery frames.
func is_in_attack_recovery() -> bool:
	if _current_state != CombatState.ATTACKING:
		return false
	return _attack_frame >= _get_current_attack_startup_frames()


## Starts a specific light attack stage.
func start_light_attack_stage(stage: int) -> void:
	_combo_index = clampi(stage, 0, MAX_COMBO_INDEX)
	_attack_frame = 0
	_combo_elapsed_sec = 0.0
	_change_state(CombatState.ATTACKING)


## Advances deterministic attack frames for tests and animation callbacks.
func advance_attack_frames(frames: int) -> void:
	for _index: int in range(maxi(0, frames)):
		_advance_attack_frame()


## Advances deterministic dodge frames for tests and animation callbacks.
func advance_dodge_frames(frames: int) -> void:
	for _index: int in range(maxi(0, frames)):
		_advance_dodge_frame()


## Advances deterministic parry frames for tests and animation callbacks.
func advance_parry_frames(frames: int) -> void:
	for _index: int in range(maxi(0, frames)):
		_advance_parry_frame()


## Advances deterministic heavy charge time for tests and frame processing.
func advance_charge_time(delta_sec: float) -> void:
	if _current_state != CombatState.CHARGING:
		return
	_charge_elapsed_sec = clampf(
		_charge_elapsed_sec + maxf(0.0, delta_sec),
		0.0,
		HEAVY_CHARGE_MAX_SEC
	)
	if _charge_elapsed_sec >= HEAVY_CHARGE_MAX_SEC:
		_release_heavy_attack()


## Cancels an active charge without releasing an attack.
func cancel_heavy_charge() -> bool:
	if _current_state != CombatState.CHARGING:
		return false
	_reset_charge()
	_change_state(CombatState.IDLE)
	return true


## Advances hit-stun frames for tests and frame processing.
func advance_hit_stun_frames(frames: int) -> void:
	for _index: int in range(maxi(0, frames)):
		_advance_hit_stun_frame()


## Advances combo timeout time without requiring real engine frames.
func advance_combo_time(delta_sec: float) -> void:
	_combo_elapsed_sec = maxf(0.0, _combo_elapsed_sec + delta_sec)


## Advances dodge cooldown time without requiring real engine frames.
func advance_dodge_cooldown_time(delta_sec: float) -> void:
	_dodge_cooldown_remaining_sec = maxf(0.0, _dodge_cooldown_remaining_sec - delta_sec)


## Clears dodge cooldown for weapon-swap completion hooks.
func reset_dodge_cooldown() -> void:
	_dodge_cooldown_remaining_sec = 0.0


## Advances weapon special cooldown timers without requiring real engine frames.
func advance_special_cooldown_time(delta_sec: float) -> void:
	_advance_cooldown_dictionary(_special_cooldowns_remaining, delta_sec)


## Advances weapon ultimate cooldown timers without requiring real engine frames.
func advance_ultimate_cooldown_time(delta_sec: float) -> void:
	_advance_cooldown_dictionary(_ultimate_cooldowns_remaining, delta_sec)


## Advances out-of-combat time and clears cat energy after the reset window.
func advance_out_of_combat_time(delta_sec: float) -> void:
	if _cat_energy <= 0:
		_out_of_combat_elapsed_sec = 0.0
		return
	_out_of_combat_elapsed_sec += maxf(0.0, delta_sec)
	if _out_of_combat_elapsed_sec > CAT_ENERGY_OUT_OF_COMBAT_RESET_SEC:
		_cat_energy = 0
		_out_of_combat_elapsed_sec = 0.0


## Advances cat-claw dodge counter frames without requiring real engine frames.
func advance_dodge_counter_frames(frames: int) -> void:
	for _index: int in range(maxi(0, frames)):
		_advance_dodge_counter_frame()


## Returns remaining cat-claw dodge counter frames.
func get_dodge_counter_window() -> int:
	return _dodge_counter_window


## Queues a one-shot crit-window bonus for the next confirmed qualifying hit.
func set_crit_window_bonus(frames: int) -> void:
	_pending_crit_window_bonus_frames = maxi(_pending_crit_window_bonus_frames, maxi(0, frames))


## Returns the queued one-shot crit-window bonus for diagnostics.
func get_pending_crit_window_bonus() -> int:
	return _pending_crit_window_bonus_frames


## Resolves an incoming hit against the current parry timing.
func resolve_parry_result() -> Dictionary:
	var parry_type: StringName = classify_parry_timing(_parry_frame)
	var is_success: bool = parry_type != &"miss"
	var metadata: Dictionary = {
		"is_success": is_success,
		"parry_type": parry_type,
		"parry_frame": _parry_frame,
		"extra_punishment": false,
	}
	if is_success:
		metadata["stun_seconds"] = PARRY_STUN_SECONDS
		if not _parry_resolved:
			_parries += 1
			_parry_resolved = true
			var energy_event: StringName = _get_parry_energy_event(parry_type)
			if energy_event != &"":
				add_cat_energy_for_event(energy_event)
			_start_parry_counter()
	on_parry_resolved.emit(metadata.duplicate(true))
	return metadata


## Resets the light combo chain to the first attack.
func reset_combo() -> void:
	_combo_index = 0
	_attack_frame = 0
	_combo_elapsed_sec = 0.0


## Handles Health integration damage notification.
func on_damage_taken(damage: int) -> void:
	if damage <= 0:
		return
	add_cat_energy_for_event(&"damage_taken")
	_reset_charge()
	_enter_hit_stun()


## Handles an aerial hit confirmation without depending on PlayerMovement.
func on_aerial_hit_confirmed(metadata: Dictionary = {}) -> void:
	add_cat_energy_for_event(&"aerial")
	var bounce_metadata: Dictionary = metadata.duplicate(true)
	bounce_metadata["attack_type"] = &"aerial"
	bounce_metadata["restore_jump"] = true
	on_aerial_bounce_requested.emit(bounce_metadata)


## Tracks HealthComponent focus-mode transitions for outgoing damage metadata.
func handle_focus_mode_changed(active: bool) -> void:
	_focus_mode_active = active


## Compatibility entry point for focus-mode signal sketches.
func on_focus_mode_changed(active_or_entity: Variant, maybe_active: Variant = null, _metadata: Dictionary = {}) -> void:
	if maybe_active == null:
		handle_focus_mode_changed(bool(active_or_entity))
	else:
		handle_focus_mode_changed(bool(maybe_active))


## Handles provisional CollisionComponent hit confirmations.
func on_hit_confirmed(event: Variant) -> void:
	var metadata: Dictionary = _build_hit_metadata(event)
	_grant_cat_energy_for_hit(metadata)
	var damage_result: Variant = _calculate_hit_damage(metadata)
	if damage_result != null:
		_merge_damage_result_metadata(metadata, damage_result)
	_hits_landed += 1
	_total_damage_dealt += maxi(0, int(metadata.get("final_damage", 0)))
	_mark_damage_interaction()
	_apply_health_damage(metadata)
	on_attack_hit.emit(metadata.duplicate(true))


func _build_hit_metadata(event: Variant) -> Dictionary:
	var attack_metadata: Dictionary = _event_dictionary_value(event, "attack_metadata")
	var combo_index: int = clampi(int(_metadata_value(attack_metadata, event, "combo_index", _combo_index)), 0, MAX_COMBO_INDEX)
	var hit_frame: int = int(_metadata_value(attack_metadata, event, "hit_frame", _attack_frame))
	var parry_timing: int = int(_metadata_value(attack_metadata, event, "parry_timing", -1))
	var skill_modifiers: Dictionary = _metadata_dictionary_value(attack_metadata, event, "skill_modifiers")
	var focus_crit_bonus: int = 1 if _focus_mode_active else 0
	var attack_type: StringName = StringName(_metadata_value(attack_metadata, event, "attack_type", &"light"))
	var weapon_id: StringName = StringName(_metadata_value(attack_metadata, event, "weapon_id", _current_weapon_id))
	var counter_crit_bonus: int = _consume_dodge_counter_bonus_for_hit(weapon_id, attack_type)
	if counter_crit_bonus > 0:
		set_crit_window_bonus(counter_crit_bonus)
	skill_modifiers["focus_crit_window_bonus_frames"] = focus_crit_bonus
	skill_modifiers["claw_counter_crit_window_bonus_frames"] = _take_crit_window_bonus()
	return _compose_hit_metadata(
		event,
		attack_metadata,
		combo_index,
		hit_frame,
		parry_timing,
		skill_modifiers
	)


func _compose_hit_metadata(
	event: Variant,
	attack_metadata: Dictionary,
	combo_index: int,
	hit_frame: int,
	parry_timing: int,
	skill_modifiers: Dictionary
) -> Dictionary:
	var attack_type: StringName = StringName(_metadata_value(attack_metadata, event, "attack_type", &"light"))
	var weapon_id: StringName = StringName(_metadata_value(attack_metadata, event, "weapon_id", _current_weapon_id))
	return {
		"attacker_id": int(_event_value(event, "attacker_id", -1)),
		"target_id": int(_event_value(event, "target_id", -1)),
		"hitbox_id": StringName(_event_value(event, "hitbox_id", &"")),
		"hit_position": _event_value(event, "hit_position", Vector2.ZERO),
		"attack_type": attack_type,
		"weapon_id": weapon_id,
		"hit_frame": hit_frame,
		"combo_index": combo_index,
		"parry_timing": parry_timing,
		"parry_type": classify_parry_timing(parry_timing),
		"crit_window_bonus": (
			int(skill_modifiers["focus_crit_window_bonus_frames"])
			+ int(skill_modifiers["claw_counter_crit_window_bonus_frames"])
		),
		"skill_modifiers": skill_modifiers,
		"charge_seconds": float(_metadata_value(attack_metadata, event, "charge_seconds", 0.0)),
		"charge_ratio": float(_metadata_value(attack_metadata, event, "charge_ratio", 0.0)),
		"charge_multiplier": float(_metadata_value(
			attack_metadata,
			event,
			"charge_multiplier",
			1.0
		)),
		"facing": float(_metadata_value(attack_metadata, event, "facing", 0.0)),
		"skill_knockback_px": float(_metadata_value(
			attack_metadata,
			event,
			"skill_knockback_px",
			0.0
		)),
		"knockback_direction": float(_metadata_value(
			attack_metadata,
			event,
			"knockback_direction",
			0.0
		)),
		"knockback_attempted": bool(_metadata_value(
			attack_metadata,
			event,
			"knockback_attempted",
			false
		)),
		"knockback_applied": bool(_metadata_value(
			attack_metadata,
			event,
			"knockback_applied",
			false
		)),
		"knockback_requested_px": float(_metadata_value(
			attack_metadata,
			event,
			"knockback_requested_px",
			0.0
		)),
		"knockback_applied_px": float(_metadata_value(
			attack_metadata,
			event,
			"knockback_applied_px",
			0.0
		)),
		"knockback_blocked": bool(_metadata_value(
			attack_metadata,
			event,
			"knockback_blocked",
			false
		)),
		"knockback_blocked_reason": StringName(_metadata_value(
			attack_metadata,
			event,
			"knockback_blocked_reason",
			&""
		)),
		"attack_power": int(_metadata_value(attack_metadata, event, "attack_power", 0)),
		"enemy_defense": int(_metadata_value(attack_metadata, event, "enemy_defense", 0)),
		"injected_damage_params": _metadata_dictionary_value(
			attack_metadata,
			event,
			"injected_damage_params"
		),
		"data_manager": _metadata_value(attack_metadata, event, "data_manager", null),
		"final_damage": int(_event_value(event, "final_damage", 0)),
	}


func _calculate_hit_damage(metadata: Dictionary) -> Variant:
	if _damage_calculator_adapter == null or not _damage_calculator_adapter.has_method("calculate_damage"):
		return null
	return _damage_calculator_adapter.call(
		"calculate_damage",
		metadata["attack_type"],
		metadata["weapon_id"],
		metadata["hit_frame"],
		metadata["combo_index"],
		metadata["parry_timing"],
		metadata["attack_power"],
		metadata["enemy_defense"],
		metadata["skill_modifiers"],
		metadata["injected_damage_params"],
		metadata["data_manager"]
	)


func _merge_damage_result_metadata(metadata: Dictionary, damage_result: Variant) -> void:
	metadata["final_damage"] = int(_variant_value(damage_result, "final_damage", 0))
	metadata["base_damage"] = int(_variant_value(damage_result, "base_damage", 0))
	metadata["attack_damage"] = float(_variant_value(damage_result, "attack_damage", 0.0))
	metadata["reduction_factor"] = float(_variant_value(damage_result, "reduction_factor", 1.0))
	metadata["damage_multiplier"] = float(_variant_value(damage_result, "damage_multiplier", 1.0))
	metadata["is_crit"] = bool(_variant_value(damage_result, "is_crit", false))
	metadata["crit_type"] = StringName(_variant_value(damage_result, "crit_type", &"none"))
	metadata["is_parry"] = bool(_variant_value(damage_result, "is_parry", false))
	metadata["damage_parry_type"] = StringName(_variant_value(damage_result, "parry_type", &"none"))
	metadata["combo_stage"] = int(_variant_value(damage_result, "combo_stage", metadata["combo_index"]))
	metadata["damage_category"] = StringName(_variant_value(damage_result, "damage_category", &"scratch"))


func _apply_health_damage(metadata: Dictionary) -> void:
	metadata["damage_applied"] = 0
	metadata["damage_was_applied"] = false
	if _health_adapter == null or not _health_adapter.has_method("apply_damage"):
		return
	var final_damage: int = int(metadata.get("final_damage", 0))
	if final_damage <= 0:
		return
	var payload: Dictionary = metadata.duplicate(true)
	var result: Variant
	if _method_argument_count(_health_adapter, "apply_damage") >= 3:
		result = _health_adapter.call(
			"apply_damage",
			int(metadata.get("target_id", -1)),
			final_damage,
			payload
		)
	else:
		result = _health_adapter.call("apply_damage", final_damage, payload)
	var damage_applied: int = final_damage
	if result is bool:
		damage_applied = final_damage if bool(result) else 0
	elif result is int or result is float:
		damage_applied = clampi(int(result), 0, final_damage)
	metadata["damage_applied"] = damage_applied
	metadata["damage_was_applied"] = damage_applied > 0


func _grant_cat_energy_for_hit(metadata: Dictionary) -> void:
	var event_id: StringName = _cat_energy_event_for_hit(metadata)
	if event_id != &"":
		add_cat_energy_for_event(event_id)


func _cat_energy_event_for_hit(metadata: Dictionary) -> StringName:
	match StringName(metadata.get("attack_type", &"light")):
		&"light":
			return StringName("light_%d" % int(metadata.get("combo_index", 0)))
		&"heavy", &"heavy_min", &"heavy_max", &"charged":
			return &"heavy"
		&"aerial", &"aerial_dive":
			return &"aerial"
		&"special":
			return &"special"
		&"parry":
			return &"parry_counter"
	return &""


func _handle_idle_action(action_id: StringName, metadata: Dictionary) -> void:
	match action_id:
		&"attack":
			_start_light_attack(metadata)
		&"dodge":
			_start_dodge(metadata)
		&"parry":
			_start_parry()
		&"heavy_attack":
			_start_heavy_charge(metadata)


func _handle_attacking_action(action_id: StringName, metadata: Dictionary) -> void:
	if not is_in_attack_recovery():
		return
	match action_id:
		&"attack":
			_try_chain_light_attack()
		&"dodge":
			_start_dodge(metadata)


func _handle_charging_action(action_id: StringName, metadata: Dictionary) -> void:
	match action_id:
		&"heavy_attack":
			if not bool(metadata.get("pressed", true)):
				_try_release_heavy_attack()
		&"dodge":
			_reset_charge()
			_start_dodge(metadata)


func _start_light_attack(metadata: Dictionary) -> void:
	start_light_attack_stage(int(metadata.get("combo_index", 0)))


func _try_chain_light_attack() -> void:
	if _combo_elapsed_sec > COMBO_TIMEOUT_SEC:
		start_light_attack_stage(0)
	elif _combo_index < MAX_COMBO_INDEX:
		start_light_attack_stage(_combo_index + 1)


func _start_dodge(metadata: Dictionary = {}) -> void:
	if bool(metadata.get("is_airborne", false)) or _dodge_cooldown_remaining_sec > 0.0:
		return
	_dodge_attempts += 1
	_dodge_frame = 0
	_change_state(CombatState.DODGING)


func _start_parry() -> void:
	_parry_attempts += 1
	_parry_frame = 0
	_parry_resolved = false
	_change_state(CombatState.PARRYING)


func _start_parry_counter() -> void:
	_combo_index = 0
	_attack_frame = 0
	_combo_elapsed_sec = 0.0
	_change_state(CombatState.ATTACKING)


func _start_heavy_charge(metadata: Dictionary) -> void:
	if not bool(metadata.get("pressed", true)):
		return
	_charge_elapsed_sec = 0.0
	_change_state(CombatState.CHARGING)


func _try_release_heavy_attack() -> void:
	if _charge_elapsed_sec < HEAVY_CHARGE_MIN_SEC:
		_reset_charge()
		_change_state(CombatState.IDLE)
		return
	_release_heavy_attack()


func _release_heavy_attack() -> void:
	var charge_seconds: float = _charge_elapsed_sec
	var metadata: Dictionary = {
		"attack_type": &"heavy",
		"charge_seconds": charge_seconds,
		"charge_ratio": clampf(charge_seconds / HEAVY_CHARGE_MAX_SEC, 0.0, 1.0),
	}
	_reset_charge()
	start_light_attack_stage(0)
	on_heavy_attack_released.emit(metadata)


func _reset_charge() -> void:
	_charge_elapsed_sec = 0.0


func _mark_damage_interaction() -> void:
	_out_of_combat_elapsed_sec = 0.0


func _get_parry_energy_event(parry_type: StringName) -> StringName:
	match parry_type:
		&"perfect":
			return &"perfect_parry"
		&"good":
			return &"good_parry"
	return &""


func _enter_hit_stun() -> void:
	_hit_stun_stack_count = mini(_hit_stun_stack_count + 1, HIT_STUN_MAX_STACKS)
	_hit_stun_remaining_frames = HIT_STUN_FRAMES_PER_STACK * _hit_stun_stack_count
	_change_state(CombatState.HIT_STUN)


func _change_state(new_state: CombatState) -> void:
	if _current_state == new_state:
		return
	var old_state: CombatState = _current_state
	_previous_state = _current_state
	_current_state = new_state
	on_state_changed.emit(old_state, new_state)


func _disconnect_input_dispatcher() -> void:
	if _input_dispatcher == null or not _input_dispatcher.has_signal("action_triggered"):
		return
	var input_signal: Signal = _input_dispatcher.get("action_triggered")
	if input_signal.is_connected(on_action_triggered):
		input_signal.disconnect(on_action_triggered)


func _disconnect_collision_adapter() -> void:
	if _collision_adapter == null or not _collision_adapter.has_signal("on_hit_confirmed"):
		return
	var hit_signal: Signal = _collision_adapter.get("on_hit_confirmed")
	if hit_signal.is_connected(on_hit_confirmed):
		hit_signal.disconnect(on_hit_confirmed)


func _metadata_value(metadata: Dictionary, event: Variant, key: String, default_value: Variant) -> Variant:
	if metadata.has(key):
		return metadata[key]
	var string_name_key: StringName = StringName(key)
	if metadata.has(string_name_key):
		return metadata[string_name_key]
	return _event_value(event, key, default_value)


func _metadata_dictionary_value(metadata: Dictionary, event: Variant, key: String) -> Dictionary:
	var value: Variant = _metadata_value(metadata, event, key, {})
	if value is Dictionary:
		return value.duplicate(true)
	return {}


func _event_dictionary_value(event: Variant, key: String) -> Dictionary:
	var value: Variant = _event_value(event, key, {})
	if value is Dictionary:
		return value.duplicate(true)
	return {}


func _event_value(event: Variant, key: String, default_value: Variant) -> Variant:
	if event is Dictionary:
		return _dictionary_value(event, key, default_value)
	if event is Object:
		var object_value: Variant = event.get(key)
		if object_value != null:
			return object_value
	return default_value


func _dictionary_value(dictionary: Dictionary, key: String, default_value: Variant) -> Variant:
	if dictionary.has(key):
		return dictionary[key]
	var string_name_key: StringName = StringName(key)
	if dictionary.has(string_name_key):
		return dictionary[string_name_key]
	return default_value


func _variant_value(value: Variant, key: String, default_value: Variant) -> Variant:
	if value is Dictionary:
		return _dictionary_value(value, key, default_value)
	if value is Object:
		var object_value: Variant = value.get(key)
		if object_value != null:
			return object_value
	return default_value


func _method_argument_count(target: Object, method_name: String) -> int:
	for method: Dictionary in target.get_method_list():
		if String(method.get("name", "")) == method_name:
			return Array(method.get("args", [])).size()
	return 0


func _safe_rate(successes: int, attempts: int) -> float:
	if attempts <= 0:
		return 0.0
	return float(successes) / float(attempts)


func _advance_attack_frame() -> void:
	if _current_state != CombatState.ATTACKING:
		return
	_attack_frame += 1
	var advanced_stage: int = _combo_index
	var advanced_frame: int = _attack_frame
	on_light_attack_frame_advanced.emit(advanced_stage, advanced_frame)
	if _attack_frame >= _get_current_attack_total_frames():
		_change_state(CombatState.IDLE)


func _advance_dodge_frame() -> void:
	if _current_state != CombatState.DODGING:
		return
	_dodge_frame += 1
	if is_dodge_iframe_active():
		_set_hurtbox_state(&"gone")
	if _dodge_frame >= DODGE_TOTAL_FRAMES:
		_finish_dodge()


func _advance_parry_frame() -> void:
	if _current_state != CombatState.PARRYING:
		return
	_parry_frame += 1
	if _parry_frame > PARRY_LATE_END_FRAME and not _parry_resolved:
		_change_state(CombatState.IDLE)


func _advance_hit_stun_frame() -> void:
	if _current_state != CombatState.HIT_STUN:
		return
	_hit_stun_remaining_frames = maxi(0, _hit_stun_remaining_frames - 1)
	if _hit_stun_remaining_frames == 0:
		_hit_stun_stack_count = 0
		_change_state(CombatState.IDLE)


func _advance_cooldown_dictionary(cooldowns: Dictionary, delta_sec: float) -> void:
	var safe_delta: float = maxf(0.0, delta_sec)
	for key in cooldowns.keys():
		cooldowns[key] = maxf(0.0, float(cooldowns[key]) - safe_delta)


func _finish_dodge() -> void:
	_set_hurtbox_state(&"normal")
	_dodge_cooldown_remaining_sec = DODGE_COOLDOWN_SEC
	_dodges += 1
	_change_state(CombatState.IDLE)
	if _current_weapon_id == WEAPON_CAT_CLAW:
		_open_dodge_counter_window()


func _open_dodge_counter_window() -> void:
	_dodge_counter_window = DODGE_COUNTER_WINDOW_FRAMES
	on_dodge_counter_active.emit(true)


func _advance_dodge_counter_frame() -> void:
	if _dodge_counter_window <= 0:
		return
	_dodge_counter_window -= 1
	if _dodge_counter_window == 0:
		on_dodge_counter_active.emit(false)


func _consume_dodge_counter_bonus_for_hit(weapon_id: StringName, attack_type: StringName) -> int:
	if (
		_dodge_counter_window <= 0
		or weapon_id != WEAPON_CAT_CLAW
		or not _is_qualifying_dodge_counter_hit(attack_type)
	):
		return 0
	_dodge_counter_window = 0
	on_dodge_counter_active.emit(false)
	return DODGE_COUNTER_CRIT_BONUS_FRAMES


func _is_qualifying_dodge_counter_hit(attack_type: StringName) -> bool:
	match attack_type:
		&"light", &"heavy", &"heavy_min", &"heavy_max", &"charged", &"aerial", &"aerial_dive", &"special":
			return true
		_:
			return false


func _take_crit_window_bonus() -> int:
	var bonus: int = _pending_crit_window_bonus_frames
	_pending_crit_window_bonus_frames = 0
	return bonus


func _set_hurtbox_state(state: StringName) -> void:
	if _hurtbox_adapter == null or not _hurtbox_adapter.has_method("set_hurtbox_state"):
		return
	_hurtbox_adapter.call("set_hurtbox_state", state)


func _get_current_attack_startup_frames() -> int:
	return int(get_light_attack_frame_data(_combo_index)["startup_frames"])


func _get_current_attack_total_frames() -> int:
	return int(get_light_attack_frame_data(_combo_index)["total_frames"])


func _get_special_cat_energy_cost(weapon_id: StringName) -> int:
	return int(SPECIAL_CAT_ENERGY_COST_BY_WEAPON.get(weapon_id, 0))


func _get_special_cooldown_sec(weapon_id: StringName) -> float:
	return float(SPECIAL_COOLDOWN_SEC_BY_WEAPON.get(weapon_id, 0.0))


func _get_ultimate_cooldown_sec(weapon_id: StringName) -> float:
	return float(ULTIMATE_COOLDOWN_SEC_BY_WEAPON.get(weapon_id, 0.0))


func _has_unlocked_ultimate(weapon_id: StringName) -> bool:
	if _ultimate_provider == null or not _ultimate_provider.has_method("has_unlocked_ultimate"):
		return false
	return bool(_ultimate_provider.call("has_unlocked_ultimate", weapon_id))


func _process_idle() -> void:
	pass


func _process_attacking() -> void:
	advance_combo_time(get_physics_process_delta_time())
	_advance_attack_frame()


func _process_dodging() -> void:
	advance_dodge_frames(1)


func _process_parrying() -> void:
	advance_parry_frames(1)


func _process_hit_stun() -> void:
	advance_hit_stun_frames(1)


func _process_charging() -> void:
	advance_charge_time(get_physics_process_delta_time())
