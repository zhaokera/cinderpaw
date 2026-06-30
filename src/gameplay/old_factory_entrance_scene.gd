## Runtime wiring for the first Old Factory entrance combat room.
class_name OldFactoryEntranceScene
extends Node2D

const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_MUSIC_ID: StringName = &"mus_factory"
const FACTORY_AMBIENT_ID: StringName = &"amb_factory"
const FACTORY_AUDIO_FADE_SEC: float = 3.0
const FACTORY_PLAYER_LIGHT_DAMAGE: int = 12
const FACTORY_STEAM_DAMAGE_FALLBACK: int = 8
const FACTORY_STEAM_CONTACT_COOLDOWN_FALLBACK_SEC: float = 1.0
const FACTORY_ENTRY_GUARD_ENTITY_ID: int = 2100
const FACTORY_DEEP_GUARD_ENTITY_ID: int = 2101
const FACTORY_SPARK_RAT_ENTITY_ID: int = 2102
const FACTORY_RETURN_SPARK_RAT_ENTITY_ID: int = 2103
const FACTORY_SPARK_RAT_BITE_DAMAGE_FALLBACK: int = 9
const FACTORY_DEEP_GUARD_ACTIVATION_X: float = 980.0
const FACTORY_SPARK_RAT_ACTIVATION_X: float = 1140.0
const FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES: int = 18
const FACTORY_RAT_MINION_COLLISION_LAYER: int = 2
const FACTORY_RAT_MINION_COLLISION_MASK: int = 17
const FACTORY_OBJECTIVE_CLEAR_ENTRANCE: StringName = &"clear_factory_entrance"
const FACTORY_OBJECTIVE_REACH_DEEP_GUARD: StringName = &"reach_deep_guard"
const FACTORY_OBJECTIVE_OPEN_DEEP_ROUTE: StringName = &"open_deep_route_endpoint"
const FACTORY_OBJECTIVE_DEFEAT_SPARK_RAT: StringName = &"defeat_spark_rat_patrol"
const FACTORY_OBJECTIVE_ROUTE_CLEARED: StringName = &"factory_route_cleared"
const FACTORY_OBJECTIVE_CLEAR_RETURN_PATROL: StringName = &"clear_return_patrol"
const FACTORY_OBJECTIVE_RETURN_PATROL_CLEARED: StringName = &"return_patrol_cleared"
const FACTORY_SERVICE_LIFT_ENDPOINT_ID: StringName = &"old_factory_service_lift"
const FACTORY_SERVICE_LIFT_EXIT_SCENE_ID: StringName = &"main"
const FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT: StringName = &"scrap_roost"
const FACTORY_RETURN_CHECKPOINT_ID: StringName = &"old_factory_return_checkpoint"
const FACTORY_RETURN_CHECKPOINT_SPAWN_POINT: StringName = &"return_checkpoint"
const FACTORY_GATE_ENTRY_SPAWN_POINT: StringName = &"factory_gate_entry"
const FACTORY_RETURN_CHECKPOINT_ACTIVATION_RADIUS: float = 112.0
const FACTORY_RETURN_CHECKPOINT_RESPAWN_LABEL: String = "Returned to Factory Savepoint"
const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")

@onready var _spawn: Marker2D = $FactoryGateEntrySpawn
@onready var _player: Node2D = $Player
@onready var _enemy: Node2D = $FactoryRatMinion
@onready var _deep_guard: Node2D = get_node_or_null("FactoryDeepGuardRatMinion") as Node2D
@onready var _spark_rat: Node2D = get_node_or_null("FactorySparkRat") as Node2D
@onready var _return_spark_rat: Node2D = get_node_or_null("FactoryReturnSparkRat") as Node2D
@onready var _cache: Node = $FactoryCombatCache
@onready var _return_patrol_reward_cache: Node = get_node_or_null(
	"FactoryReturnPatrolRewardCache"
)
@onready var _return_checkpoint: Node = get_node_or_null("FactoryReturnCheckpoint")
@onready var _steam_vent: Area2D = get_node_or_null("FactorySteamVentHazard") as Area2D
@onready var _deep_endpoint: Node = get_node_or_null("FactoryDeepRouteEndpoint")
@onready var _service_lift: Node = get_node_or_null("FactoryServiceLift")

var _last_player_hit_metadata: Dictionary = {}
var _last_cache_reward: Dictionary = {}
var _last_cache_claim_feedback: Dictionary = {}
var _last_return_patrol_reward_cache_reward: Dictionary = {}
var _last_return_patrol_reward_cache_claim_feedback: Dictionary = {}
var _last_hazard_damage: Dictionary = {}
var _last_spark_rat_counter_diagnostics: Dictionary = {}
var _last_spark_rat_bite_sequence_id_resolved: int = -1
var _encounter_cleared: bool = false
var _cache_claimed: bool = false
var _deep_guard_activated: bool = false
var _deep_guard_defeated: bool = false
var _deep_route_cleared: bool = false
var _spark_rat_activated: bool = false
var _spark_rat_defeated: bool = false
var _return_patrol_activated: bool = false
var _return_patrol_defeated: bool = false
var _return_patrol_reward_cache_claimed: bool = false
var _return_checkpoint_activated: bool = false
var _last_return_checkpoint: Dictionary = {}
var _service_lift_activated: bool = false
var _service_lift_exit_requested: bool = false
var _last_service_lift_exit_rejected_reason: StringName = &""
var _last_service_lift_exit_request: Dictionary = {}
var _factory_hazard_elapsed_sec: float = 0.0
var _factory_hazard_contact_cooldowns: Dictionary = {}
var _weapon_component: WeaponComponent = null
var _scene_manager: Object = null


func _ready() -> void:
	_setup_weapon_component()
	_align_player_to_spawn()
	_bind_enemy_to_player()
	_setup_factory_cache()
	_setup_factory_return_patrol_reward_cache()
	_setup_factory_return_checkpoint()
	_setup_factory_hazards()
	_setup_factory_deep_route()
	_setup_factory_spark_rat()
	_setup_factory_service_lift()
	_bind_player_combat_to_room()
	_refresh_factory_route_objective()
	_request_factory_audio()


func calculate_damage(
	_attack_type: StringName,
	_weapon_id: StringName,
	_hit_frame: int,
	combo_index: int,
	_parry_timing: int,
	_attack_power: int,
	_enemy_defense: int,
	_skill_modifiers: Dictionary = {},
	_injected_damage_params: Dictionary = {},
	_data_manager: Object = null
) -> Dictionary:
	return {
		"final_damage": FACTORY_PLAYER_LIGHT_DAMAGE,
		"base_damage": FACTORY_PLAYER_LIGHT_DAMAGE,
		"attack_damage": float(FACTORY_PLAYER_LIGHT_DAMAGE),
		"reduction_factor": 1.0,
		"damage_multiplier": 1.0,
		"is_crit": false,
		"crit_type": &"none",
		"parry_type": &"none",
		"combo_stage": combo_index,
		"damage_category": &"scratch",
	}


func apply_damage(target_id: int, final_damage: int, metadata: Dictionary = {}) -> bool:
	var damage_target: Node = _get_factory_enemy_by_entity_id(target_id)
	if damage_target == null or not damage_target.has_method("apply_damage"):
		return false
	damage_target.call("apply_damage", final_damage, metadata)
	return true


func get_last_player_hit_metadata() -> Dictionary:
	return _last_player_hit_metadata.duplicate(true)


## Returns whether the Factory entrance combat encounter has been cleared.
func is_encounter_cleared() -> bool:
	return _encounter_cleared


## Returns whether the Factory entrance combat cache was already claimed.
func is_factory_cache_claimed() -> bool:
	return _cache_claimed


## Returns whether the deeper Old Factory route endpoint was activated.
func is_factory_deep_route_cleared() -> bool:
	return _deep_route_cleared


## Returns whether the deeper Old Factory guard has been alerted.
func is_factory_deep_guard_activated() -> bool:
	return _deep_guard_activated


## Returns whether the Factory spark rat patrol enemy has been defeated.
func is_factory_spark_rat_defeated() -> bool:
	return _spark_rat_defeated


## Returns whether the authored Factory Route objective chain is complete.
func is_factory_route_objective_complete() -> bool:
	var objective_id: StringName = _get_factory_route_objective_id()
	return (
		objective_id == FACTORY_OBJECTIVE_ROUTE_CLEARED
		or objective_id == FACTORY_OBJECTIVE_RETURN_PATROL_CLEARED
	)


## Returns whether the post-route service lift handoff has been activated.
func is_factory_service_lift_activated() -> bool:
	return _service_lift_activated


## Returns whether the one-time Factory return patrol has been cleared.
func is_factory_return_patrol_defeated() -> bool:
	return _return_patrol_defeated


## Attempts to activate the Old Factory return checkpoint after the return patrol is clear.
func try_activate_factory_return_checkpoint(provider: Node = null) -> bool:
	if _return_checkpoint == null or not _return_patrol_defeated:
		return false
	var activation_provider: Node = provider
	if activation_provider == null:
		activation_provider = _player
	if not _is_return_checkpoint_provider_in_range(activation_provider):
		return false
	if not _return_checkpoint.has_method("try_activate"):
		return false
	if not bool(_return_checkpoint.call("try_activate", activation_provider)):
		return false
	_return_checkpoint_activated = true
	_sync_return_checkpoint_state()
	if _last_return_checkpoint.is_empty():
		_last_return_checkpoint = _build_return_checkpoint_snapshot(
			FACTORY_RETURN_CHECKPOINT_ID,
			FACTORY_SCENE_ID,
			FACTORY_RETURN_CHECKPOINT_SPAWN_POINT,
			(_return_checkpoint as Node2D).global_position
				if _return_checkpoint is Node2D
				else Vector2.ZERO,
			{}
		)
	_update_route_label("Factory Savepoint Secured")
	return true


func get_last_discovered_savepoint() -> Dictionary:
	return _last_return_checkpoint.duplicate(true) if _return_checkpoint_activated else {}


func clear_last_discovered_savepoint() -> bool:
	_return_checkpoint_activated = false
	_last_return_checkpoint.clear()
	_sync_return_checkpoint_state()
	return true


## Attempts to alert the deep-route guard after the entrance encounter is clear.
func try_activate_factory_deep_guard(provider: Node = null) -> bool:
	if _deep_guard == null or _deep_guard_defeated or _deep_guard_activated:
		return false
	if not _encounter_cleared:
		return false
	var activation_provider: Node = provider
	if activation_provider == null:
		activation_provider = _player
	if not _is_deep_guard_activation_provider_in_range(activation_provider):
		return false
	_deep_guard_activated = true
	_sync_deep_route_state()
	_refresh_factory_route_objective()
	return true


## Attempts to activate the Factory spark rat after the deep route endpoint opens.
func try_activate_factory_spark_rat(provider: Node = null) -> bool:
	if _spark_rat == null or _spark_rat_defeated or _spark_rat_activated:
		return false
	if not _deep_route_cleared:
		return false
	var activation_provider: Node = provider
	if activation_provider == null:
		activation_provider = _player
	if not _is_spark_rat_activation_provider_in_range(activation_provider):
		return false
	_spark_rat_activated = true
	_sync_spark_rat_state()
	if activation_provider != null:
		_set_spark_rat_attack_target(activation_provider)
	_begin_spark_rat_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Attempts to request the SceneManager-backed service lift exit after route clear.
func try_activate_factory_service_lift(provider: Node = null) -> bool:
	if _service_lift == null or _service_lift_activated or _service_lift_exit_requested:
		return false
	if not _spark_rat_defeated:
		_record_service_lift_exit_rejection(&"route_not_cleared")
		return false
	if _is_return_patrol_blocking_service_lift():
		_record_service_lift_exit_rejection(&"return_patrol_active")
		_sync_service_lift_state()
		return false
	var activation_provider: Node = provider
	if activation_provider == null:
		activation_provider = _player
	if _service_lift.has_method("set_available"):
		_service_lift.call("set_available", true)
	if not _service_lift.has_method("try_activate"):
		_record_service_lift_exit_rejection(&"missing_service_lift_activation_api")
		return false
	if not _is_service_lift_activation_ready(_is_service_lift_available(), activation_provider):
		_record_service_lift_exit_rejection(&"provider_out_of_range")
		return false
	if not _request_service_lift_scene_exit():
		return false
	var activated: bool = bool(_service_lift.call("try_activate", activation_provider))
	if not activated:
		_record_service_lift_exit_rejection(&"service_lift_activation_rejected")
		return false
	_service_lift_activated = true
	_sync_service_lift_state()
	_update_route_label("Service Lift Departing")
	return true


## Injects or refreshes the SceneManager adapter used by the service lift exit.
func configure_scene_manager_runtime(scene_manager: Object) -> bool:
	_scene_manager = scene_manager
	var valid_scene_manager: bool = _is_valid_scene_manager(_scene_manager)
	if valid_scene_manager:
		_apply_current_scene_manager_spawn_point()
	return valid_scene_manager


## Resolves the active Factory Spark Rat bite against the current player dodge state.
func resolve_factory_spark_rat_bite_against_player() -> Dictionary:
	var result: Dictionary = {
		"resolved": false,
		"dodged": false,
		"damage_applied": false,
		"damage": 0,
		"weapon_id": &"",
		"source": &"",
	}
	if _spark_rat == null or _player == null or not _spark_rat_activated or _spark_rat_defeated:
		_record_spark_rat_counter_result(result)
		return result.duplicate(true)
	var attack_sequence_id: int = _get_spark_rat_attack_sequence_id()
	if (
		not _is_spark_rat_attack_active()
		or attack_sequence_id <= 0
		or attack_sequence_id == _last_spark_rat_bite_sequence_id_resolved
	):
		result["attack_active"] = _is_spark_rat_attack_active()
		result["attack_sequence_id"] = attack_sequence_id
		result["already_resolved"] = attack_sequence_id == _last_spark_rat_bite_sequence_id_resolved
		if bool(result["already_resolved"]) and not _last_spark_rat_counter_diagnostics.is_empty():
			_last_spark_rat_counter_diagnostics["last_bite_already_resolved"] = true
			_last_spark_rat_counter_diagnostics["last_bite_attack_active"] = bool(
				result["attack_active"]
			)
			_last_spark_rat_counter_diagnostics["last_bite_attack_sequence_id"] = attack_sequence_id
		else:
			_record_spark_rat_counter_result(result)
		return result.duplicate(true)

	var bite_metadata: Dictionary = _get_spark_rat_bite_metadata()
	var bite_damage: int = _get_spark_rat_bite_damage(bite_metadata)
	var dodged: bool = _is_player_dodge_iframe_active()
	var hp_before: int = _get_player_hp()
	var hp_after: int = hp_before

	if not dodged and _player.has_method("apply_damage"):
		_player.call("apply_damage", bite_damage, bite_metadata)
		hp_after = _get_player_hp()

	result = {
		"resolved": true,
		"dodged": dodged,
		"damage_applied": hp_after < hp_before,
		"damage": bite_damage,
		"weapon_id": StringName(bite_metadata.get("weapon_id", &"")),
		"source": StringName(bite_metadata.get("source", &"")),
		"player_hp_before": hp_before,
		"player_hp_after": hp_after,
		"counter_window_frames": _get_player_dodge_counter_window(),
		"attack_active": true,
		"attack_sequence_id": attack_sequence_id,
		"already_resolved": false,
	}
	_last_spark_rat_bite_sequence_id_resolved = attack_sequence_id
	_record_spark_rat_counter_result(result)
	_update_route_label("Dodge counter ready" if dodged else "Spark rat bite hit")
	return result.duplicate(true)


## Attempts to claim the room-clear cache with the player or supplied provider.
func try_claim_factory_cache(provider: Node = null) -> bool:
	if not _encounter_cleared or _cache == null:
		return false
	var claim_provider: Node = provider
	if claim_provider == null:
		claim_provider = _player
	if not _cache.has_method("try_claim") or not bool(_cache.call("try_claim", claim_provider)):
		return false
	_cache_claimed = true
	var reward_payload: Dictionary = _get_cache_reward_payload()
	if _last_cache_reward.is_empty():
		_last_cache_reward = reward_payload
	if _last_cache_claim_feedback.is_empty():
		_record_cache_claim_feedback(reward_payload, "Cache Claimed")
	return true


## Attempts to claim the return-patrol reward cache after the ambush is cleared.
func try_claim_factory_return_patrol_reward_cache(provider: Node = null) -> bool:
	if not _return_patrol_defeated or _return_patrol_reward_cache == null:
		return false
	var claim_provider: Node = provider
	if claim_provider == null:
		claim_provider = _player
	if (
		not _return_patrol_reward_cache.has_method("try_claim")
		or not bool(_return_patrol_reward_cache.call("try_claim", claim_provider))
	):
		return false
	_return_patrol_reward_cache_claimed = true
	var reward_payload: Dictionary = _get_return_patrol_reward_cache_payload()
	if _last_return_patrol_reward_cache_reward.is_empty():
		_last_return_patrol_reward_cache_reward = reward_payload
	_sync_return_patrol_reward_cache_state()
	if _last_return_patrol_reward_cache_claim_feedback.is_empty():
		_record_return_patrol_reward_cache_claim_feedback(
			reward_payload,
			"Return Cache Claimed"
		)
	return true


## Attempts to activate the deep route endpoint after its guard is defeated.
func try_activate_factory_deep_route_endpoint(provider: Node = null) -> bool:
	if not _deep_guard_defeated or _deep_endpoint == null:
		return false
	var activation_provider: Node = provider
	if activation_provider == null:
		activation_provider = _player
	if not _deep_endpoint.has_method("try_activate") \
			or not bool(_deep_endpoint.call("try_activate", activation_provider)):
		return false
	_deep_route_cleared = true
	_sync_deep_route_state()
	_refresh_factory_route_objective()
	return true


## Advances scene-local hazard time and applies sustained overlap ticks.
func advance_factory_hazard_time(delta_sec: float) -> void:
	_factory_hazard_elapsed_sec += maxf(0.0, delta_sec)
	_process_factory_hazard_overlaps()


## Advances the Spark Rat pacing loop deterministically for tests and MCP probes.
func advance_factory_spark_rat_pacing_frames(frames: int) -> void:
	if _spark_rat == null or not _spark_rat_activated or _spark_rat_defeated:
		return
	if _spark_rat.has_method("advance_pacing_frames"):
		_spark_rat.call("advance_pacing_frames", frames)


## Applies steam vent contact damage to the player with per-target cooldown.
func apply_factory_steam_vent_contact(hazard: Area2D, target: Node) -> bool:
	if hazard == null or target == null or _player == null or not is_instance_valid(hazard):
		return false
	if target != _player:
		return false
	var hazard_id: StringName = _get_hazard_id(hazard)
	if hazard_id != &"old_factory_steam_vent":
		return false
	var target_id: int = PlayerController.PLAYER_ENTITY_ID
	var cooldown_key: String = _factory_hazard_cooldown_key(hazard_id, target_id)
	var next_allowed_sec: float = float(_factory_hazard_contact_cooldowns.get(cooldown_key, -1.0))
	if next_allowed_sec > _factory_hazard_elapsed_sec:
		return false
	var steam_damage: int = _get_hazard_damage(hazard)
	var hp_before: int = int(_player.call("get_current_hp")) if _player.has_method("get_current_hp") else 0
	var damage_data: Dictionary = {
		"damage": steam_damage,
		"final_damage": steam_damage,
		"hit_position": hazard.global_position,
		"is_crit": false,
		"source": hazard_id,
		"damage_type": &"steam",
		"scene_id": FACTORY_SCENE_ID,
		"target_id": target_id,
	}
	if _player.has_method("apply_damage"):
		_player.call("apply_damage", steam_damage, damage_data)
	var hp_after: int = int(_player.call("get_current_hp")) if _player.has_method("get_current_hp") else hp_before
	if hp_after >= hp_before:
		return false
	_last_hazard_damage = damage_data.duplicate(true)
	_factory_hazard_contact_cooldowns[cooldown_key] = (
		_factory_hazard_elapsed_sec + _get_hazard_cooldown_sec(hazard)
	)
	_update_route_label("Steam vent hit")
	return true


## Captures scene-local state for SceneManager runtime swap persistence.
func get_local_state() -> Dictionary:
	return {
		"encounter_cleared": _encounter_cleared,
		"factory_cache_claimed": _cache_claimed,
		"factory_deep_guard_activated": _deep_guard_activated,
		"factory_deep_guard_defeated": _deep_guard_defeated,
		"factory_deep_route_cleared": _deep_route_cleared,
		"factory_spark_rat_activated": _spark_rat_activated,
		"factory_spark_rat_defeated": _spark_rat_defeated,
		"factory_spark_rat_opening_grace_frames": _get_spark_rat_opening_grace_frames(),
		"factory_return_patrol_activated": _return_patrol_activated,
		"factory_return_patrol_defeated": _return_patrol_defeated,
		"factory_return_patrol_reward_cache_claimed": _return_patrol_reward_cache_claimed,
		"factory_return_checkpoint_activated": _return_checkpoint_activated,
		"factory_route_objective_id": String(_get_factory_route_objective_id()),
		"factory_service_lift_activated": _service_lift_activated,
		"factory_service_lift_exit_requested": _service_lift_exit_requested,
		"factory_service_lift_exit_scene_id": String(FACTORY_SERVICE_LIFT_EXIT_SCENE_ID),
		"factory_service_lift_exit_spawn_point": String(FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT),
		"factory_service_lift_exit_rejected_reason": String(_last_service_lift_exit_rejected_reason),
		"factory_service_lift_exit_request": _last_service_lift_exit_request.duplicate(true),
		"last_cache_reward": _last_cache_reward.duplicate(true),
		"last_cache_claim_feedback": _last_cache_claim_feedback.duplicate(true),
		"last_return_patrol_reward_cache_reward": (
			_last_return_patrol_reward_cache_reward.duplicate(true)
		),
		"last_return_patrol_reward_cache_claim_feedback": (
			_last_return_patrol_reward_cache_claim_feedback.duplicate(true)
		),
		"last_return_checkpoint": _last_return_checkpoint.duplicate(true),
		"last_savepoint": _last_return_checkpoint.duplicate(true),
		"last_hazard_damage": _last_hazard_damage.duplicate(true),
	}


## Restores scene-local state from SceneManager runtime swap persistence.
func set_local_state(state: Dictionary) -> void:
	_encounter_cleared = bool(state.get("encounter_cleared", false))
	_cache_claimed = bool(state.get("factory_cache_claimed", false))
	_deep_guard_activated = bool(state.get("factory_deep_guard_activated", false))
	_deep_guard_defeated = bool(state.get("factory_deep_guard_defeated", false))
	_deep_route_cleared = bool(state.get("factory_deep_route_cleared", false))
	_spark_rat_activated = bool(state.get("factory_spark_rat_activated", false))
	_spark_rat_defeated = bool(state.get("factory_spark_rat_defeated", false))
	_return_patrol_defeated = bool(state.get("factory_return_patrol_defeated", false))
	_return_patrol_activated = bool(state.get(
		"factory_return_patrol_activated",
		_is_service_lift_return_contract_in_state(state) and not _return_patrol_defeated
	))
	_return_patrol_reward_cache_claimed = bool(state.get(
		"factory_return_patrol_reward_cache_claimed",
		false
	))
	_return_checkpoint_activated = bool(state.get("factory_return_checkpoint_activated", false))
	_service_lift_activated = bool(state.get("factory_service_lift_activated", false))
	_service_lift_exit_requested = bool(state.get(
		"factory_service_lift_exit_requested",
		_service_lift_activated
	))
	_last_service_lift_exit_rejected_reason = StringName(String(state.get(
		"factory_service_lift_exit_rejected_reason",
		""
	)))
	var exit_request_variant: Variant = state.get("factory_service_lift_exit_request", {})
	_last_service_lift_exit_request = (
		(exit_request_variant as Dictionary).duplicate(true)
		if exit_request_variant is Dictionary
		else {}
	)
	var spark_rat_opening_grace_frames: int = int(state.get(
		"factory_spark_rat_opening_grace_frames",
		FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES if _spark_rat_activated and not _spark_rat_defeated else 0
	))
	var reward_variant: Variant = state.get("last_cache_reward", {})
	_last_cache_reward = (
		(reward_variant as Dictionary).duplicate(true)
		if reward_variant is Dictionary
		else {}
	)
	var cache_feedback_variant: Variant = state.get("last_cache_claim_feedback", {})
	_last_cache_claim_feedback = (
		(cache_feedback_variant as Dictionary).duplicate(true)
		if cache_feedback_variant is Dictionary
		else {}
	)
	var return_reward_variant: Variant = state.get("last_return_patrol_reward_cache_reward", {})
	_last_return_patrol_reward_cache_reward = (
		(return_reward_variant as Dictionary).duplicate(true)
		if return_reward_variant is Dictionary
		else {}
	)
	var return_feedback_variant: Variant = state.get(
		"last_return_patrol_reward_cache_claim_feedback",
		{}
	)
	_last_return_patrol_reward_cache_claim_feedback = (
		(return_feedback_variant as Dictionary).duplicate(true)
		if return_feedback_variant is Dictionary
		else {}
	)
	var return_checkpoint_variant: Variant = state.get(
		"last_return_checkpoint",
		state.get("last_savepoint", {})
	)
	_last_return_checkpoint = (
		(return_checkpoint_variant as Dictionary).duplicate(true)
		if return_checkpoint_variant is Dictionary
		else {}
	)
	if not _last_return_checkpoint.is_empty():
		_return_checkpoint_activated = true
	var hazard_variant: Variant = state.get("last_hazard_damage", {})
	_last_hazard_damage = (
		(hazard_variant as Dictionary).duplicate(true)
		if hazard_variant is Dictionary
		else {}
	)
	if _is_return_patrol_blocking_service_lift():
		_service_lift_activated = false
		_service_lift_exit_requested = false
		_last_service_lift_exit_rejected_reason = &""
		_last_service_lift_exit_request = {}
	_sync_room_clear_state()
	_sync_deep_route_state()
	_sync_spark_rat_state()
	_sync_return_patrol_state()
	_sync_return_patrol_reward_cache_state()
	_sync_return_checkpoint_state()
	_sync_service_lift_state()
	if _spark_rat_activated and not _spark_rat_defeated:
		_begin_spark_rat_pacing(spark_rat_opening_grace_frames)
	if _return_patrol_activated and not _return_patrol_defeated:
		_begin_return_spark_rat_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	if _service_lift_activated:
		_update_route_label("Service Lift Departing")
	_apply_current_scene_manager_spawn_point()


## Returns deterministic room-clear/cache diagnostics for tests and MCP probes.
func get_factory_room_clear_diagnostics() -> Dictionary:
	return {
		"encounter_cleared": _encounter_cleared,
		"cache_present": _cache != null,
		"cache_id": String(_cache.call("get_cache_id")) if _cache != null and _cache.has_method("get_cache_id") else "",
		"cache_available": bool(_cache.call("is_available")) if _cache != null and _cache.has_method("is_available") else false,
		"cache_claim_available": bool(_cache.call("is_claim_available")) if _cache != null and _cache.has_method("is_claim_available") else false,
		"cache_claimed": _cache_claimed,
		"cache_texture_path": (
			String(_cache.call("get_visual_texture_path"))
			if _cache != null and _cache.has_method("get_visual_texture_path")
			else ""
		),
		"has_cache_platform": get_node_or_null("FactoryCachePlatform/CollisionShape2D") != null,
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"cache_position": _cache.global_position if _cache != null else Vector2.ZERO,
		"last_cache_reward": _last_cache_reward.duplicate(true),
		"last_cache_claim_feedback": _last_cache_claim_feedback.duplicate(true),
	}


## Returns deterministic steam vent hazard diagnostics for tests and MCP probes.
func get_factory_hazard_diagnostics() -> Dictionary:
	return {
		"steam_vent_present": _steam_vent != null,
		"steam_vent_id": String(_get_hazard_id(_steam_vent)),
		"steam_damage": _get_hazard_damage(_steam_vent),
		"steam_cooldown_sec": _get_hazard_cooldown_sec(_steam_vent),
		"steam_vent_texture_path": (
			String(_steam_vent.call("get_visual_texture_path"))
			if _steam_vent != null and _steam_vent.has_method("get_visual_texture_path")
			else ""
		),
		"steam_vent_layer": _steam_vent.collision_layer if _steam_vent != null else 0,
		"steam_vent_mask": _steam_vent.collision_mask if _steam_vent != null else 0,
		"last_hazard_damage": _last_hazard_damage.duplicate(true),
	}


## Returns deterministic deep route diagnostics for tests and MCP probes.
func get_factory_deep_route_diagnostics() -> Dictionary:
	var unlock_vfx_snapshot: Dictionary = _get_deep_route_unlock_vfx_snapshot()
	return {
		"deep_guard_present": _deep_guard != null,
		"deep_guard_entity_id": (
			int(_deep_guard.call("get_entity_id"))
			if _deep_guard != null and _deep_guard.has_method("get_entity_id")
			else 0
		),
		"deep_guard_defeated": _deep_guard_defeated,
		"deep_guard_activated": _deep_guard_activated,
		"deep_guard_activation_x": FACTORY_DEEP_GUARD_ACTIVATION_X,
		"deep_guard_has_target": _does_deep_guard_have_target(),
		"deep_guard_physics_enabled": (
			_deep_guard.is_physics_processing()
			if _deep_guard != null
			else false
		),
		"deep_guard_process_enabled": (
			_deep_guard.is_processing()
			if _deep_guard != null
			else false
		),
		"deep_route_cleared": _deep_route_cleared,
		"endpoint_present": _deep_endpoint != null,
		"endpoint_available": (
			bool(_deep_endpoint.call("is_available"))
			if _deep_endpoint != null and _deep_endpoint.has_method("is_available")
			else false
		),
		"endpoint_activated": (
			bool(_deep_endpoint.call("is_activated"))
			if _deep_endpoint != null and _deep_endpoint.has_method("is_activated")
			else false
		),
		"endpoint_id": (
			String(_deep_endpoint.call("get_endpoint_id"))
			if _deep_endpoint != null and _deep_endpoint.has_method("get_endpoint_id")
			else ""
		),
		"endpoint_texture_path": (
			String(_deep_endpoint.call("get_visual_texture_path"))
			if _deep_endpoint != null and _deep_endpoint.has_method("get_visual_texture_path")
			else ""
		),
		"unlock_feedback_texture_path": String(unlock_vfx_snapshot.get("texture_path", "")),
		"unlock_feedback_active": int(unlock_vfx_snapshot.get("active_count", 0)) > 0,
		"unlock_feedback_played": bool(unlock_vfx_snapshot.get("played", false)),
		"unlock_feedback_spawn_count": int(unlock_vfx_snapshot.get("spawn_count", 0)),
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"deep_guard_position": _deep_guard.global_position if _deep_guard != null else Vector2.ZERO,
		"endpoint_position": (
			(_deep_endpoint as Node2D).global_position
			if _deep_endpoint != null and _deep_endpoint is Node2D
			else Vector2.ZERO
		),
	}


## Returns deterministic spark-rat diagnostics for tests and MCP probes.
func get_factory_spark_rat_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _spark_rat != null
		else null
	)
	var pacing_diagnostics: Dictionary = _get_spark_rat_pacing_diagnostics()
	return {
		"present": _spark_rat != null,
		"visible": _spark_rat.visible if _spark_rat != null else false,
		"active": _spark_rat_activated and not _spark_rat_defeated,
		"defeated": _spark_rat_defeated,
		"activation_x": FACTORY_SPARK_RAT_ACTIVATION_X,
		"activation_ready": _is_spark_rat_activation_provider_in_range(_player),
		"distance_to_player": _get_spark_rat_distance_to_provider(_player),
		"entity_id": (
			int(_spark_rat.call("get_entity_id"))
			if _spark_rat != null and _spark_rat.has_method("get_entity_id")
			else 0
		),
		"has_target": _does_spark_rat_have_target(),
		"physics_enabled": _spark_rat.is_physics_processing() if _spark_rat != null else false,
		"process_enabled": _spark_rat.is_processing() if _spark_rat != null else false,
		"collision_layer": _spark_rat.collision_layer if _spark_rat != null else 0,
		"collision_mask": _spark_rat.collision_mask if _spark_rat != null else 0,
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"counter": get_factory_spark_rat_counter_diagnostics(),
		"pacing": pacing_diagnostics,
		"position": _spark_rat.global_position if _spark_rat != null else Vector2.ZERO,
	}


## Returns deterministic return patrol diagnostics for tests and MCP probes.
func get_factory_return_patrol_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_return_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _return_spark_rat != null
		else null
	)
	return {
		"present": _return_spark_rat != null,
		"visible": _return_spark_rat.visible if _return_spark_rat != null else false,
		"active": _return_patrol_activated and not _return_patrol_defeated,
		"defeated": _return_patrol_defeated,
		"entity_id": (
			int(_return_spark_rat.call("get_entity_id"))
			if _return_spark_rat != null and _return_spark_rat.has_method("get_entity_id")
			else 0
		),
		"has_target": _does_return_spark_rat_have_target(),
		"physics_enabled": (
			_return_spark_rat.is_physics_processing()
			if _return_spark_rat != null
			else false
		),
		"process_enabled": _return_spark_rat.is_processing() if _return_spark_rat != null else false,
		"collision_layer": _return_spark_rat.collision_layer if _return_spark_rat != null else 0,
		"collision_mask": _return_spark_rat.collision_mask if _return_spark_rat != null else 0,
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"position": _return_spark_rat.global_position if _return_spark_rat != null else Vector2.ZERO,
	}


## Returns deterministic return-patrol reward cache diagnostics for tests and MCP probes.
func get_factory_return_patrol_reward_cache_diagnostics() -> Dictionary:
	return {
		"present": _return_patrol_reward_cache != null,
		"visible": (
			_return_patrol_reward_cache.visible
			if _return_patrol_reward_cache != null
			else false
		),
		"cache_id": (
			String(_return_patrol_reward_cache.call("get_cache_id"))
			if (
				_return_patrol_reward_cache != null
				and _return_patrol_reward_cache.has_method("get_cache_id")
			)
			else ""
		),
		"texture_path": (
			String(_return_patrol_reward_cache.call("get_visual_texture_path"))
			if (
				_return_patrol_reward_cache != null
				and _return_patrol_reward_cache.has_method("get_visual_texture_path")
			)
			else ""
		),
		"available": (
			bool(_return_patrol_reward_cache.call("is_available"))
			if (
				_return_patrol_reward_cache != null
				and _return_patrol_reward_cache.has_method("is_available")
			)
			else false
		),
		"claim_available": (
			bool(_return_patrol_reward_cache.call("is_claim_available"))
			if (
				_return_patrol_reward_cache != null
				and _return_patrol_reward_cache.has_method("is_claim_available")
			)
			else false
		),
		"claimed": _return_patrol_reward_cache_claimed,
		"prompt_text": _get_return_patrol_reward_cache_prompt_text(),
		"return_patrol_active": _return_patrol_activated and not _return_patrol_defeated,
		"return_patrol_defeated": _return_patrol_defeated,
		"position": (
			(_return_patrol_reward_cache as Node2D).global_position
			if _return_patrol_reward_cache != null and _return_patrol_reward_cache is Node2D
			else Vector2.ZERO
		),
		"last_reward": _last_return_patrol_reward_cache_reward.duplicate(true),
		"last_claim_feedback": _last_return_patrol_reward_cache_claim_feedback.duplicate(true),
	}


## Returns deterministic return checkpoint diagnostics for tests and MCP probes.
func get_factory_return_checkpoint_diagnostics() -> Dictionary:
	var checkpoint_position: Vector2 = (
		(_return_checkpoint as Node2D).global_position
		if _return_checkpoint != null and _return_checkpoint is Node2D
		else Vector2.ZERO
	)
	return {
		"present": _return_checkpoint != null,
		"visible": _return_checkpoint.visible if _return_checkpoint != null else false,
		"available": _return_patrol_defeated,
		"activated": _return_checkpoint_activated,
		"savepoint_id": _get_return_checkpoint_savepoint_id(),
		"scene_id": _get_return_checkpoint_scene_id(),
		"spawn_point": _get_return_checkpoint_spawn_point(),
		"display_name": _get_return_checkpoint_display_name(),
		"prompt_text": _get_return_checkpoint_prompt_text(),
		"texture_path": _get_return_checkpoint_texture_path(),
		"position": checkpoint_position,
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"last_checkpoint": _last_return_checkpoint.duplicate(true),
	}


## Returns deterministic Spark Rat dodge-counter diagnostics for tests and MCP probes.
func get_factory_spark_rat_counter_diagnostics() -> Dictionary:
	var diagnostics: Dictionary = {
		"last_bite_resolved": false,
		"last_bite_dodged": false,
		"last_bite_damage_applied": false,
		"last_bite_damage": 0,
		"last_bite_weapon_id": "",
		"last_bite_source": "",
	}
	if not _last_spark_rat_counter_diagnostics.is_empty():
		diagnostics.merge(_last_spark_rat_counter_diagnostics, true)
	diagnostics["counter_window_frames"] = _get_player_dodge_counter_window()
	diagnostics["counter_ready"] = int(diagnostics["counter_window_frames"]) > 0
	diagnostics["player_dodge_iframe_active"] = _is_player_dodge_iframe_active()
	diagnostics["spark_rat_active"] = _spark_rat_activated and not _spark_rat_defeated
	return diagnostics


## Returns deterministic Factory Route objective diagnostics for tests and MCP probes.
func get_factory_route_objective_diagnostics() -> Dictionary:
	var route_label := get_node_or_null("RouteLabel") as Label
	var objective_id: StringName = _get_factory_route_objective_id()
	return {
		"objective_id": String(objective_id),
		"objective_text": _get_factory_route_objective_text(objective_id),
		"complete": is_factory_route_objective_complete(),
		"scene_id": String(get_meta("scene_id", String(FACTORY_SCENE_ID))),
		"arrival_spawn_present": _spawn != null,
		"player_present": _player != null,
		"encounter_cleared": _encounter_cleared,
		"deep_guard_activated": _deep_guard_activated,
		"deep_guard_defeated": _deep_guard_defeated,
		"deep_route_cleared": _deep_route_cleared,
		"spark_rat_activated": _spark_rat_activated,
		"spark_rat_defeated": _spark_rat_defeated,
		"return_patrol_activated": _return_patrol_activated,
		"return_patrol_defeated": _return_patrol_defeated,
		"route_label_visible": route_label.visible if route_label != null else false,
		"route_label_text": route_label.text if route_label != null else "",
	}


## Returns deterministic service-lift handoff diagnostics for tests and MCP probes.
func get_factory_service_lift_diagnostics() -> Dictionary:
	var route_label := get_node_or_null("RouteLabel") as Label
	var unlock_vfx_snapshot: Dictionary = _get_service_lift_unlock_vfx_snapshot()
	var available: bool = _is_service_lift_available()
	return {
		"present": _service_lift != null,
		"available": available,
		"activated": _service_lift_activated,
		"activation_ready": _is_service_lift_activation_ready(available),
		"return_patrol_active": _is_return_patrol_blocking_service_lift(),
		"endpoint_id": _get_service_lift_endpoint_id(),
		"expected_endpoint_id": String(FACTORY_SERVICE_LIFT_ENDPOINT_ID),
		"texture_path": _get_service_lift_texture_path(),
		"prompt_text": _get_service_lift_prompt_text(),
		"route_cleared": is_factory_route_objective_complete(),
		"route_label_text": route_label.text if route_label != null else "",
		"exit_requested": _service_lift_exit_requested,
		"exit_target_scene_id": String(FACTORY_SERVICE_LIFT_EXIT_SCENE_ID),
		"exit_spawn_point": String(FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT),
		"exit_rejected_reason": String(_last_service_lift_exit_rejected_reason),
		"scene_manager_present": _is_valid_scene_manager(_resolve_scene_manager_for_runtime()),
		"scene_manager_loading": _is_scene_manager_loading(),
		"scene_manager_pending_scene": _get_scene_manager_pending_scene(),
		"scene_manager_pending_spawn_point": _get_scene_manager_pending_spawn_point(),
		"last_exit_request": _last_service_lift_exit_request.duplicate(true),
		"position": _get_service_lift_position(),
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"unlock_feedback_texture_path": String(unlock_vfx_snapshot.get("texture_path", "")),
		"unlock_feedback_active": int(unlock_vfx_snapshot.get("active_count", 0)) > 0,
		"unlock_feedback_played": bool(unlock_vfx_snapshot.get("played", false)),
		"unlock_feedback_spawn_count": int(unlock_vfx_snapshot.get("spawn_count", 0)),
	}


func get_factory_entrance_diagnostics() -> Dictionary:
	var backdrop := get_node_or_null("Background") as TextureRect
	var enemy_sprite := get_node_or_null("FactoryRatMinion/Sprite") as AnimatedSprite2D
	return {
		"scene_id": String(get_meta("scene_id", String(FACTORY_SCENE_ID))),
		"has_spawn": _spawn != null,
		"has_player": _player != null,
		"has_enemy": _enemy != null,
		"backdrop_texture_path": (
			backdrop.texture.resource_path
			if backdrop != null and backdrop.texture != null
			else ""
		),
		"enemy_sprite_frames_path": (
			enemy_sprite.sprite_frames.resource_path
			if enemy_sprite != null and enemy_sprite.sprite_frames != null
			else ""
		),
		"room_clear": get_factory_room_clear_diagnostics(),
		"hazards": get_factory_hazard_diagnostics(),
		"deep_route": get_factory_deep_route_diagnostics(),
		"spark_rat": get_factory_spark_rat_diagnostics(),
		"return_patrol": get_factory_return_patrol_diagnostics(),
		"return_patrol_reward_cache": get_factory_return_patrol_reward_cache_diagnostics(),
		"return_checkpoint": get_factory_return_checkpoint_diagnostics(),
		"route_objective": get_factory_route_objective_diagnostics(),
		"service_lift": get_factory_service_lift_diagnostics(),
		"last_player_hit_metadata": get_last_player_hit_metadata(),
	}


func _get_deep_route_unlock_vfx_snapshot() -> Dictionary:
	if _deep_endpoint == null or not _deep_endpoint.has_method("get_unlock_vfx_snapshot"):
		return {}
	var snapshot_variant: Variant = _deep_endpoint.call("get_unlock_vfx_snapshot")
	if snapshot_variant is Dictionary:
		return (snapshot_variant as Dictionary).duplicate(true)
	return {}


func _get_service_lift_unlock_vfx_snapshot() -> Dictionary:
	if _service_lift == null or not _service_lift.has_method("get_unlock_vfx_snapshot"):
		return {}
	var snapshot_variant: Variant = _service_lift.call("get_unlock_vfx_snapshot")
	if snapshot_variant is Dictionary:
		return (snapshot_variant as Dictionary).duplicate(true)
	return {}


func _is_service_lift_available() -> bool:
	return (
		bool(_service_lift.call("is_available"))
		if _service_lift != null and _service_lift.has_method("is_available")
		else false
	)


func _is_service_lift_activation_ready(available: bool, provider: Node = null) -> bool:
	if (
		not available
		or _service_lift == null
		or not _service_lift.has_method("is_provider_in_activation_range")
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	return bool(_service_lift.call("is_provider_in_activation_range", activation_provider))


func _get_service_lift_endpoint_id() -> String:
	return (
		String(_service_lift.call("get_endpoint_id"))
		if _service_lift != null and _service_lift.has_method("get_endpoint_id")
		else ""
	)


func _get_service_lift_texture_path() -> String:
	return (
		String(_service_lift.call("get_visual_texture_path"))
		if _service_lift != null and _service_lift.has_method("get_visual_texture_path")
		else ""
	)


func _get_service_lift_prompt_text() -> String:
	var prompt_label := (
		_service_lift.get_node_or_null("PromptLabel") as Label
		if _service_lift != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_service_lift_position() -> Vector2:
	return (
		(_service_lift as Node2D).global_position
		if _service_lift != null and _service_lift is Node2D
		else Vector2.ZERO
	)


func _request_service_lift_scene_exit() -> bool:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if not _is_valid_scene_manager(scene_manager):
		_record_service_lift_exit_rejection(&"scene_manager_missing")
		return false
	if scene_manager.has_method("is_loading") and bool(scene_manager.call("is_loading")):
		_record_service_lift_exit_rejection(&"scene_manager_loading")
		return false
	if scene_manager.has_method("is_scene_locked") and bool(scene_manager.call("is_scene_locked")):
		_record_service_lift_exit_rejection(&"scene_locked")
		return false
	if scene_manager.has_method("has_scene") \
			and not bool(scene_manager.call("has_scene", FACTORY_SERVICE_LIFT_EXIT_SCENE_ID)):
		_record_service_lift_exit_rejection(&"unknown_scene")
		return false

	var request_started: bool = false
	if scene_manager.has_method("request_scene_change"):
		request_started = bool(scene_manager.call(
			"request_scene_change",
			FACTORY_SERVICE_LIFT_EXIT_SCENE_ID,
			FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT
		))
	elif scene_manager.has_method("change_scene"):
		request_started = bool(scene_manager.call(
			"change_scene",
			FACTORY_SERVICE_LIFT_EXIT_SCENE_ID,
			FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT
		))
	if not request_started:
		_record_service_lift_exit_rejection(&"request_rejected")
		return false

	_service_lift_exit_requested = true
	_last_service_lift_exit_rejected_reason = &""
	_last_service_lift_exit_request = {
		"scene_id": String(FACTORY_SERVICE_LIFT_EXIT_SCENE_ID),
		"spawn_point": String(FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT),
		"scene_manager_loading": _is_scene_manager_loading(),
		"pending_scene": _get_scene_manager_pending_scene(),
		"pending_spawn_point": _get_scene_manager_pending_spawn_point(),
	}
	return true


func _record_service_lift_exit_rejection(reason: StringName) -> void:
	_last_service_lift_exit_rejected_reason = reason
	_last_service_lift_exit_request = {}


func _resolve_scene_manager_for_runtime() -> Object:
	if _is_valid_scene_manager(_scene_manager):
		return _scene_manager
	if not is_inside_tree():
		return null
	var root_scene_manager: Node = get_node_or_null("/root/SceneManager")
	if _is_valid_scene_manager(root_scene_manager):
		_scene_manager = root_scene_manager
		return _scene_manager
	return null


func _is_valid_scene_manager(scene_manager: Object) -> bool:
	return (
		scene_manager != null
		and is_instance_valid(scene_manager)
		and (
			scene_manager.has_method("request_scene_change")
			or scene_manager.has_method("change_scene")
		)
	)


func _is_scene_manager_loading() -> bool:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	return (
		bool(scene_manager.call("is_loading"))
		if scene_manager != null and scene_manager.has_method("is_loading")
		else false
	)


func _apply_current_scene_manager_spawn_point() -> bool:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if scene_manager == null or not scene_manager.has_method("get_current_scene"):
		return false
	return _apply_scene_manager_spawn_point(StringName(scene_manager.call("get_current_scene")))


func _apply_scene_manager_spawn_point(scene_id: StringName) -> bool:
	if scene_id != FACTORY_SCENE_ID:
		return false
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if scene_manager == null or not scene_manager.has_method("get_current_spawn_point"):
		return false
	var spawn_point: StringName = StringName(scene_manager.call("get_current_spawn_point"))
	if not _move_player_to_spawn_point(spawn_point):
		return false
	if spawn_point == FACTORY_RETURN_CHECKPOINT_SPAWN_POINT:
		_update_route_label(FACTORY_RETURN_CHECKPOINT_RESPAWN_LABEL)
	return true


func _move_player_to_spawn_point(spawn_point: StringName) -> bool:
	if _player == null or not is_instance_valid(_player):
		return false
	var spawn_node: Node2D = null
	if spawn_point == FACTORY_GATE_ENTRY_SPAWN_POINT:
		spawn_node = _spawn
	elif spawn_point == FACTORY_RETURN_CHECKPOINT_SPAWN_POINT:
		spawn_node = _return_checkpoint as Node2D
	if spawn_node == null:
		return false
	_player.global_position = spawn_node.global_position
	return true


func _get_scene_manager_pending_scene() -> String:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	return (
		String(scene_manager.call("get_pending_scene"))
		if scene_manager != null and scene_manager.has_method("get_pending_scene")
		else ""
	)


func _get_scene_manager_pending_spawn_point() -> String:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	return (
		String(scene_manager.call("get_pending_spawn_point"))
		if scene_manager != null and scene_manager.has_method("get_pending_spawn_point")
		else ""
	)


func _align_player_to_spawn() -> void:
	if _spawn == null or _player == null:
		return
	_player.global_position = _spawn.global_position


func _bind_enemy_to_player() -> void:
	if _player == null:
		return
	_bind_factory_guard(
		_enemy,
		&"old_factory_entrance",
		FACTORY_ENTRY_GUARD_ENTITY_ID,
		&"factory_patrol",
		_on_factory_enemy_defeated,
		_player
	)
	_bind_factory_guard(
		_deep_guard,
		&"old_factory_deep_route",
		FACTORY_DEEP_GUARD_ENTITY_ID,
		&"factory_deep_guard",
		_on_factory_deep_guard_defeated
	)
	_bind_factory_guard(
		_spark_rat,
		&"old_factory_spark_rat_patrol",
		FACTORY_SPARK_RAT_ENTITY_ID,
		&"factory_spark_rat_patrol",
		_on_factory_spark_rat_defeated
	)
	_bind_factory_guard(
		_return_spark_rat,
		&"old_factory_return_patrol",
		FACTORY_RETURN_SPARK_RAT_ENTITY_ID,
		&"factory_return_spark_rat",
		_on_factory_return_spark_rat_defeated
	)


func _setup_factory_cache() -> void:
	_sync_room_clear_state()
	if _cache == null or not _cache.has_signal("cache_claimed"):
		return
	var claimed_signal: Signal = _cache.get("cache_claimed")
	if not claimed_signal.is_connected(_on_factory_cache_claimed):
		claimed_signal.connect(_on_factory_cache_claimed)


func _setup_factory_return_patrol_reward_cache() -> void:
	_sync_return_patrol_reward_cache_state()
	if _return_patrol_reward_cache == null or not _return_patrol_reward_cache.has_signal(
		"cache_claimed"
	):
		return
	var claimed_signal: Signal = _return_patrol_reward_cache.get("cache_claimed")
	if not claimed_signal.is_connected(_on_factory_return_patrol_reward_cache_claimed):
		claimed_signal.connect(_on_factory_return_patrol_reward_cache_claimed)


func _setup_factory_return_checkpoint() -> void:
	_sync_return_checkpoint_state()
	if _return_checkpoint == null or not _return_checkpoint.has_signal("savepoint_activated"):
		return
	var activated_signal: Signal = _return_checkpoint.get("savepoint_activated")
	if not activated_signal.is_connected(_on_factory_return_checkpoint_activated):
		activated_signal.connect(_on_factory_return_checkpoint_activated)


func _setup_factory_hazards() -> void:
	if _steam_vent == null:
		return
	var area_entered_callback := Callable(self, "_on_factory_hazard_area_entered").bind(_steam_vent)
	if not _steam_vent.area_entered.is_connected(area_entered_callback):
		_steam_vent.area_entered.connect(area_entered_callback)
	var body_entered_callback := Callable(self, "_on_factory_hazard_body_entered").bind(_steam_vent)
	if not _steam_vent.body_entered.is_connected(body_entered_callback):
		_steam_vent.body_entered.connect(body_entered_callback)


func _setup_factory_deep_route() -> void:
	_sync_deep_route_state()
	if _deep_endpoint == null or not _deep_endpoint.has_signal("endpoint_activated"):
		return
	var endpoint_signal: Signal = _deep_endpoint.get("endpoint_activated")
	if not endpoint_signal.is_connected(_on_factory_deep_route_endpoint_activated):
		endpoint_signal.connect(_on_factory_deep_route_endpoint_activated)


func _setup_factory_spark_rat() -> void:
	_sync_spark_rat_state()
	_sync_return_patrol_state()


func _setup_factory_service_lift() -> void:
	_sync_service_lift_state()
	if _service_lift == null or not _service_lift.has_signal("endpoint_activated"):
		return
	var endpoint_signal: Signal = _service_lift.get("endpoint_activated")
	if not endpoint_signal.is_connected(_on_factory_service_lift_activated):
		endpoint_signal.connect(_on_factory_service_lift_activated)


func _bind_player_combat_to_room() -> void:
	if _player == null:
		return
	if _player.has_method("set_target_health_adapter"):
		_player.call("set_target_health_adapter", self)
	if _player.has_method("set_damage_calculator_adapter"):
		_player.call("set_damage_calculator_adapter", self)
	if _player.has_method("set_weapon_component"):
		_player.call("set_weapon_component", _weapon_component)
	if _weapon_component != null:
		if _player.has_method("get_combat_component"):
			_weapon_component.set_combat_adapter(_player.call("get_combat_component"))
		if _player.has_method("get_collision_component"):
			_weapon_component.set_collision_adapter(_player.call("get_collision_component"))
	if _player.has_signal("attack_landed"):
		var attack_signal: Signal = _player.get("attack_landed")
		if not attack_signal.is_connected(_on_player_attack_landed):
			attack_signal.connect(_on_player_attack_landed)


func _on_player_attack_landed(metadata: Dictionary) -> void:
	_last_player_hit_metadata = metadata.duplicate(true)


func _on_factory_enemy_defeated() -> void:
	_encounter_cleared = true
	_sync_room_clear_state()
	_refresh_factory_route_objective()


func _on_factory_deep_guard_defeated() -> void:
	_deep_guard_activated = true
	_deep_guard_defeated = true
	_sync_deep_route_state()
	_refresh_factory_route_objective()


func _on_factory_spark_rat_defeated() -> void:
	_spark_rat_activated = true
	_spark_rat_defeated = true
	_sync_spark_rat_state()
	_sync_service_lift_state()
	_refresh_factory_route_objective()


func _on_factory_return_spark_rat_defeated() -> void:
	_return_patrol_activated = true
	_return_patrol_defeated = true
	_service_lift_activated = false
	_service_lift_exit_requested = false
	_last_service_lift_exit_request = {}
	_last_service_lift_exit_rejected_reason = &""
	_sync_return_patrol_state()
	_sync_return_patrol_reward_cache_state()
	_sync_service_lift_state()
	_refresh_factory_route_objective()


func _on_factory_cache_claimed(_cache_id: StringName, reward: Dictionary) -> void:
	_cache_claimed = true
	_last_cache_reward = reward.duplicate(true)
	_record_cache_claim_feedback(_last_cache_reward, "Cache Claimed")


func _on_factory_return_patrol_reward_cache_claimed(
	_cache_id: StringName,
	reward: Dictionary
) -> void:
	_return_patrol_reward_cache_claimed = true
	_last_return_patrol_reward_cache_reward = reward.duplicate(true)
	_record_return_patrol_reward_cache_claim_feedback(
		_last_return_patrol_reward_cache_reward,
		"Return Cache Claimed"
	)


func _on_factory_return_checkpoint_activated(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2,
	context: Dictionary
) -> void:
	_return_checkpoint_activated = true
	_last_return_checkpoint = _build_return_checkpoint_snapshot(
		savepoint_id,
		scene_id,
		spawn_point,
		world_position,
		context
	)
	_sync_return_checkpoint_state()
	_update_route_label("Factory Savepoint Secured")


func _on_factory_deep_route_endpoint_activated(_endpoint_id: StringName) -> void:
	_deep_route_cleared = true
	_sync_deep_route_state()
	_sync_spark_rat_state()
	_sync_service_lift_state()
	_refresh_factory_route_objective()


func _on_factory_service_lift_activated(endpoint_id: StringName) -> void:
	if endpoint_id != FACTORY_SERVICE_LIFT_ENDPOINT_ID:
		return
	_service_lift_activated = true
	_sync_service_lift_state()
	_update_route_label("Service Lift Departing")


func _on_factory_hazard_area_entered(area: Area2D, hazard: Area2D) -> void:
	var target: Node = _resolve_factory_hazard_target_from_area(area)
	if target != null:
		apply_factory_steam_vent_contact(hazard, target)


func _on_factory_hazard_body_entered(body: Node2D, hazard: Area2D) -> void:
	if body == _player:
		apply_factory_steam_vent_contact(hazard, _player)


func _setup_weapon_component() -> void:
	_weapon_component = get_node_or_null("WeaponComponent") as WeaponComponent
	if _weapon_component == null:
		_weapon_component = WEAPON_COMPONENT_SCRIPT.new() as WeaponComponent
		_weapon_component.name = "WeaponComponent"
		add_child(_weapon_component)
	var root_data_manager: Node = get_node_or_null("/root/DataManager")
	if root_data_manager != null:
		_weapon_component.set_data_manager(root_data_manager)


func _request_factory_audio() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	if audio_system.has_method("play_music"):
		audio_system.call("play_music", FACTORY_MUSIC_ID, FACTORY_AUDIO_FADE_SEC)
	if audio_system.has_method("play_ambient"):
		audio_system.call("play_ambient", FACTORY_AMBIENT_ID, FACTORY_AUDIO_FADE_SEC)


func _sync_room_clear_state() -> void:
	if _cache != null:
		if _cache.has_method("set_available"):
			_cache.call("set_available", _encounter_cleared)
		if _cache.has_method("set_claimed"):
			_cache.call("set_claimed", _cache_claimed)
	if _encounter_cleared:
		_refresh_factory_route_objective()
	if _enemy != null and _encounter_cleared and _cache_claimed:
		_enemy.visible = false
		_enemy.set_physics_process(false)
		_enemy.set_process(false)
		_enemy.set_deferred("collision_layer", 0)
		_enemy.set_deferred("collision_mask", 0)


func _sync_deep_route_state() -> void:
	if _deep_endpoint != null:
		if _deep_endpoint.has_method("set_available"):
			_deep_endpoint.call("set_available", _deep_guard_defeated)
		if _deep_endpoint.has_method("set_activated"):
			_deep_endpoint.call("set_activated", _deep_route_cleared)
	if _deep_guard != null and _deep_guard_defeated:
		_deep_guard.visible = false
		_deep_guard.set_physics_process(false)
		_deep_guard.set_process(false)
		_deep_guard.set_deferred("collision_layer", 0)
		_deep_guard.set_deferred("collision_mask", 0)
	elif _deep_guard != null:
		_deep_guard.visible = true
		_deep_guard.set_physics_process(_deep_guard_activated)
		_deep_guard.set_process(_deep_guard_activated)
		if _deep_guard_activated:
			_deep_guard.set_deferred("collision_layer", FACTORY_RAT_MINION_COLLISION_LAYER)
			_deep_guard.set_deferred("collision_mask", FACTORY_RAT_MINION_COLLISION_MASK)
			_set_deep_guard_attack_target(_player)
		else:
			_deep_guard.set_deferred("collision_layer", 0)
			_deep_guard.set_deferred("collision_mask", 0)
			_set_deep_guard_attack_target(null)


func _sync_spark_rat_state() -> void:
	if _spark_rat == null:
		return
	if _spark_rat_defeated:
		_spark_rat.visible = false
		_spark_rat.set_physics_process(false)
		_spark_rat.set_process(false)
		_spark_rat.collision_layer = 0
		_spark_rat.collision_mask = 0
		_set_spark_rat_attack_target(null)
		return
	_spark_rat.visible = true
	var active: bool = _deep_route_cleared and _spark_rat_activated
	_spark_rat.set_physics_process(active)
	_spark_rat.set_process(active)
	if active:
		_spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
		_spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
		_set_spark_rat_attack_target(_player)
	else:
		_spark_rat.collision_layer = 0
		_spark_rat.collision_mask = 0
		_set_spark_rat_attack_target(null)


func _sync_return_patrol_state() -> void:
	if _return_spark_rat == null:
		return
	if _return_patrol_defeated or not _return_patrol_activated:
		_return_spark_rat.visible = false
		_return_spark_rat.set_physics_process(false)
		_return_spark_rat.set_process(false)
		_return_spark_rat.collision_layer = 0
		_return_spark_rat.collision_mask = 0
		_set_return_spark_rat_attack_target(null)
		return
	_return_spark_rat.visible = true
	_return_spark_rat.set_physics_process(true)
	_return_spark_rat.set_process(true)
	_return_spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
	_return_spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
	_set_return_spark_rat_attack_target(_player)


func _sync_return_patrol_reward_cache_state() -> void:
	if _return_patrol_reward_cache == null:
		return
	_return_patrol_reward_cache.visible = _return_patrol_activated or _return_patrol_defeated
	if _return_patrol_reward_cache.has_method("set_available"):
		_return_patrol_reward_cache.call("set_available", _return_patrol_defeated)
	if _return_patrol_reward_cache.has_method("set_claimed"):
		_return_patrol_reward_cache.call("set_claimed", _return_patrol_reward_cache_claimed)


func _sync_return_checkpoint_state() -> void:
	if _return_checkpoint == null:
		return
	var available: bool = _return_patrol_defeated
	_return_checkpoint.visible = available or _return_checkpoint_activated
	var interaction_area := _return_checkpoint.get_node_or_null("InteractionArea") as Area2D
	if interaction_area != null:
		if interaction_area.monitoring != available:
			interaction_area.monitoring = available
		if interaction_area.monitorable != available:
			interaction_area.monitorable = available
	var collision_shape := (
		_return_checkpoint.get_node_or_null("InteractionArea/CollisionShape2D")
		as CollisionShape2D
	)
	if collision_shape != null:
		var should_disable: bool = not available
		if collision_shape.disabled != should_disable:
			collision_shape.disabled = should_disable


func _sync_service_lift_state() -> void:
	if _service_lift == null:
		return
	if _service_lift.has_method("set_available"):
		_service_lift.call("set_available", _spark_rat_defeated and not _is_return_patrol_blocking_service_lift())
	if _service_lift.has_method("set_activated"):
		_service_lift.call("set_activated", _service_lift_activated)


func _update_route_label(text_value: String) -> void:
	var route_label := get_node_or_null("RouteLabel") as Label
	if route_label == null:
		return
	route_label.text = text_value
	route_label.visible = true


func _refresh_factory_route_objective() -> void:
	var objective_id: StringName = _get_factory_route_objective_id()
	_update_route_label(_get_factory_route_objective_text(objective_id))


func _get_factory_route_objective_id() -> StringName:
	if _return_patrol_activated and not _return_patrol_defeated:
		return FACTORY_OBJECTIVE_CLEAR_RETURN_PATROL
	if _return_patrol_defeated:
		return FACTORY_OBJECTIVE_RETURN_PATROL_CLEARED
	if _spark_rat_defeated:
		return FACTORY_OBJECTIVE_ROUTE_CLEARED
	if _deep_route_cleared:
		return FACTORY_OBJECTIVE_DEFEAT_SPARK_RAT
	if _deep_guard_defeated:
		return FACTORY_OBJECTIVE_OPEN_DEEP_ROUTE
	if _encounter_cleared:
		return FACTORY_OBJECTIVE_REACH_DEEP_GUARD
	return FACTORY_OBJECTIVE_CLEAR_ENTRANCE


func _get_factory_route_objective_text(objective_id: StringName) -> String:
	match objective_id:
		FACTORY_OBJECTIVE_CLEAR_ENTRANCE:
			return "Clear Factory Entrance"
		FACTORY_OBJECTIVE_REACH_DEEP_GUARD:
			return "Reach Deep Guard"
		FACTORY_OBJECTIVE_OPEN_DEEP_ROUTE:
			return "Open Deep Route Endpoint"
		FACTORY_OBJECTIVE_DEFEAT_SPARK_RAT:
			return "Defeat Spark Rat Patrol"
		FACTORY_OBJECTIVE_ROUTE_CLEARED:
			return "Factory Route Cleared"
		FACTORY_OBJECTIVE_CLEAR_RETURN_PATROL:
			return "Clear Return Patrol"
		FACTORY_OBJECTIVE_RETURN_PATROL_CLEARED:
			return "Return Patrol Cleared"
		_:
			return "Clear Factory Entrance"


func _get_cache_reward_payload() -> Dictionary:
	if _cache == null or not _cache.has_method("get_reward_payload"):
		return {}
	var reward_variant: Variant = _cache.call("get_reward_payload")
	if reward_variant is Dictionary:
		return (reward_variant as Dictionary).duplicate(true)
	return {}


func _get_return_patrol_reward_cache_payload() -> Dictionary:
	if (
		_return_patrol_reward_cache == null
		or not _return_patrol_reward_cache.has_method("get_reward_payload")
	):
		return {}
	var reward_variant: Variant = _return_patrol_reward_cache.call("get_reward_payload")
	if reward_variant is Dictionary:
		return (reward_variant as Dictionary).duplicate(true)
	return {}


func _record_cache_claim_feedback(reward: Dictionary, label_prefix: String) -> void:
	_last_cache_claim_feedback = _build_cache_claim_feedback(reward, label_prefix)
	_update_route_label(String(_last_cache_claim_feedback.get("text", "")))


func _record_return_patrol_reward_cache_claim_feedback(
	reward: Dictionary,
	label_prefix: String
) -> void:
	_last_return_patrol_reward_cache_claim_feedback = _build_cache_claim_feedback(
		reward,
		label_prefix
	)
	_update_route_label(String(
		_last_return_patrol_reward_cache_claim_feedback.get("text", "")
	))


func _build_cache_claim_feedback(reward: Dictionary, label_prefix: String) -> Dictionary:
	var gears: int = int(reward.get("gears", 0))
	var text: String = "%s +%d Gears" % [label_prefix, gears]
	return {
		"cache_id": String(reward.get("cache_id", "")),
		"gears": gears,
		"source": String(reward.get("source", "")),
		"text": text,
	}


func _get_return_patrol_reward_cache_prompt_text() -> String:
	var prompt_label := (
		_return_patrol_reward_cache.get_node_or_null("PromptLabel") as Label
		if _return_patrol_reward_cache != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_return_checkpoint_savepoint_id() -> String:
	if _return_checkpoint != null and _return_checkpoint.has_method("get_savepoint_id"):
		return String(_return_checkpoint.call("get_savepoint_id"))
	return String(FACTORY_RETURN_CHECKPOINT_ID)


func _get_return_checkpoint_scene_id() -> String:
	if _return_checkpoint != null and _return_checkpoint.has_method("get_scene_id"):
		return String(_return_checkpoint.call("get_scene_id"))
	return String(FACTORY_SCENE_ID)


func _get_return_checkpoint_spawn_point() -> String:
	if _return_checkpoint != null and _return_checkpoint.has_method("get_spawn_point"):
		return String(_return_checkpoint.call("get_spawn_point"))
	return String(FACTORY_RETURN_CHECKPOINT_SPAWN_POINT)


func _get_return_checkpoint_display_name() -> String:
	if _return_checkpoint != null and _return_checkpoint.has_method("get_display_name"):
		return String(_return_checkpoint.call("get_display_name"))
	return "Factory Repair Station"


func _get_return_checkpoint_texture_path() -> String:
	if _return_checkpoint != null and _return_checkpoint.has_method("get_visual_texture_path"):
		return String(_return_checkpoint.call("get_visual_texture_path"))
	return ""


func _get_return_checkpoint_prompt_text() -> String:
	var prompt_label := (
		_return_checkpoint.get_node_or_null("PromptLabel") as Label
		if _return_checkpoint != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _build_return_checkpoint_snapshot(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2,
	context: Dictionary
) -> Dictionary:
	var snapshot: Dictionary = context.duplicate(true)
	snapshot["id"] = String(savepoint_id)
	snapshot["savepoint_id"] = String(savepoint_id)
	snapshot["scene_id"] = String(scene_id)
	snapshot["spawn_point"] = String(spawn_point)
	if not snapshot.has("display_name") or String(snapshot["display_name"]).strip_edges().is_empty():
		snapshot["display_name"] = _get_return_checkpoint_display_name()
	snapshot["position"] = {
		"x": world_position.x,
		"y": world_position.y,
	}
	return snapshot


func _process_factory_hazard_overlaps() -> void:
	if _steam_vent == null:
		return
	for area: Area2D in _steam_vent.get_overlapping_areas():
		var target: Node = _resolve_factory_hazard_target_from_area(area)
		if target != null:
			apply_factory_steam_vent_contact(_steam_vent, target)
	for body: Node2D in _steam_vent.get_overlapping_bodies():
		if body == _player:
			apply_factory_steam_vent_contact(_steam_vent, _player)


func _resolve_factory_hazard_target_from_area(area: Area2D) -> Node:
	if area == null:
		return null
	var parent: Node = area.get_parent()
	if parent == _player:
		return _player
	if parent != null and parent.has_method("get_entity_id") \
			and int(parent.call("get_entity_id")) == PlayerController.PLAYER_ENTITY_ID:
		return _player
	return null


func _get_hazard_id(hazard: Area2D) -> StringName:
	if hazard != null and hazard.has_method("get_hazard_id"):
		return StringName(String(hazard.call("get_hazard_id")))
	return &""


func _get_hazard_damage(hazard: Area2D) -> int:
	if hazard != null and hazard.has_method("get_damage"):
		return int(hazard.call("get_damage"))
	return FACTORY_STEAM_DAMAGE_FALLBACK


func _get_hazard_cooldown_sec(hazard: Area2D) -> float:
	if hazard != null and hazard.has_method("get_contact_cooldown_sec"):
		return float(hazard.call("get_contact_cooldown_sec"))
	return FACTORY_STEAM_CONTACT_COOLDOWN_FALLBACK_SEC


func _record_spark_rat_counter_result(result: Dictionary) -> void:
	_last_spark_rat_counter_diagnostics = {
		"last_bite_resolved": bool(result.get("resolved", false)),
		"last_bite_dodged": bool(result.get("dodged", false)),
		"last_bite_damage_applied": bool(result.get("damage_applied", false)),
		"last_bite_damage": int(result.get("damage", 0)),
		"last_bite_weapon_id": String(result.get("weapon_id", "")),
		"last_bite_source": String(result.get("source", "")),
		"last_bite_attack_active": bool(result.get("attack_active", false)),
		"last_bite_already_resolved": bool(result.get("already_resolved", false)),
		"last_bite_attack_sequence_id": int(result.get("attack_sequence_id", 0)),
		"last_player_hp_before": int(result.get("player_hp_before", _get_player_hp())),
		"last_player_hp_after": int(result.get("player_hp_after", _get_player_hp())),
	}


func _get_spark_rat_bite_metadata() -> Dictionary:
	var metadata: Dictionary = {}
	if _spark_rat != null and _spark_rat.has_method("get_current_enemy_attack_metadata"):
		var metadata_variant: Variant = _spark_rat.call("get_current_enemy_attack_metadata")
		if metadata_variant is Dictionary:
			metadata = (metadata_variant as Dictionary).duplicate(true)
	if metadata.is_empty():
		metadata = {
			"source": &"factory_spark_rat",
			"weapon_id": &"factory_spark_rat_bite",
			"attack_type": &"light",
		}
	metadata["attacker_id"] = FACTORY_SPARK_RAT_ENTITY_ID
	metadata["target_id"] = PlayerController.PLAYER_ENTITY_ID
	metadata["hit_position"] = _spark_rat.global_position if _spark_rat != null else Vector2.ZERO
	metadata["scene_id"] = FACTORY_SCENE_ID
	metadata["final_damage"] = _get_spark_rat_bite_damage(metadata)
	metadata["damage"] = int(metadata["final_damage"])
	return metadata


func _get_spark_rat_bite_damage(metadata: Dictionary) -> int:
	var weapon_id: String = String(metadata.get("weapon_id", "factory_spark_rat_bite"))
	var damage_params: Dictionary = _dictionary_from_variant(metadata.get("injected_damage_params", {}))
	var entries: Dictionary = _dictionary_from_variant(damage_params.get("entries", {}))
	var bite_entry: Dictionary = _dictionary_from_variant(entries.get(weapon_id, {}))
	return int(bite_entry.get("weapon_base", FACTORY_SPARK_RAT_BITE_DAMAGE_FALLBACK))


func _dictionary_from_variant(value: Variant) -> Dictionary:
	return (value as Dictionary).duplicate(true) if value is Dictionary else {}


func _get_player_hp() -> int:
	if _player != null and _player.has_method("get_current_hp"):
		return int(_player.call("get_current_hp"))
	return 0


func _is_player_dodge_iframe_active() -> bool:
	if _player != null and _player.has_method("is_dodge_iframe_active"):
		return bool(_player.call("is_dodge_iframe_active"))
	var combat: CombatComponent = _get_player_combat_component()
	return combat != null and combat.is_dodge_iframe_active()


func _get_player_dodge_counter_window() -> int:
	if _player != null and _player.has_method("get_dodge_counter_window"):
		return int(_player.call("get_dodge_counter_window"))
	var combat: CombatComponent = _get_player_combat_component()
	return combat.get_dodge_counter_window() if combat != null else 0


func _get_player_combat_component() -> CombatComponent:
	if _player == null or not _player.has_method("get_combat_component"):
		return null
	return _player.call("get_combat_component") as CombatComponent


func _is_spark_rat_attack_active() -> bool:
	if _spark_rat != null and _spark_rat.has_method("is_enemy_attack_active"):
		return bool(_spark_rat.call("is_enemy_attack_active"))
	return false


func _get_spark_rat_attack_sequence_id() -> int:
	if _spark_rat != null and _spark_rat.has_method("get_current_attack_sequence_id"):
		return int(_spark_rat.call("get_current_attack_sequence_id"))
	return 0


func _factory_hazard_cooldown_key(hazard_id: StringName, target_id: int) -> String:
	return "%s:%d" % [String(hazard_id), target_id]


func _bind_factory_guard(
	guard: Node,
	owner_id: StringName,
	entity_id: int,
	summon_id: StringName,
	defeated_callback: Callable,
	attack_target: Node = null
) -> void:
	if guard == null:
		return
	if guard.has_method("set_attack_target"):
		guard.call("set_attack_target", attack_target)
	if guard.has_method("configure_summon"):
		guard.call("configure_summon", owner_id, entity_id, summon_id)
	if guard.has_signal("enemy_defeated"):
		var defeated_signal: Signal = guard.get("enemy_defeated")
		if not defeated_signal.is_connected(defeated_callback):
			defeated_signal.connect(defeated_callback)


func _set_deep_guard_attack_target(attack_target: Node) -> void:
	if _deep_guard != null and _deep_guard.has_method("set_attack_target"):
		_deep_guard.call("set_attack_target", attack_target)


func _set_spark_rat_attack_target(attack_target: Node) -> void:
	if _spark_rat != null and _spark_rat.has_method("set_attack_target"):
		_spark_rat.call("set_attack_target", attack_target)


func _set_return_spark_rat_attack_target(attack_target: Node) -> void:
	if _return_spark_rat != null and _return_spark_rat.has_method("set_attack_target"):
		_return_spark_rat.call("set_attack_target", attack_target)


func _begin_spark_rat_pacing(opening_grace_frames: int) -> void:
	if _spark_rat != null and _spark_rat.has_method("begin_pacing"):
		_spark_rat.call("begin_pacing", maxi(0, opening_grace_frames))


func _begin_return_spark_rat_pacing(opening_grace_frames: int) -> void:
	if _return_spark_rat != null and _return_spark_rat.has_method("begin_pacing"):
		_return_spark_rat.call("begin_pacing", maxi(0, opening_grace_frames))


func _get_spark_rat_pacing_diagnostics() -> Dictionary:
	if _spark_rat != null and _spark_rat.has_method("get_pacing_diagnostics"):
		var pacing_variant: Variant = _spark_rat.call("get_pacing_diagnostics")
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
		"alert_radius_px": 0.0,
		"target_distance": _get_spark_rat_distance_to_provider(_player),
		"target_in_alert_radius": false,
		"patrol_center_x": _spark_rat.global_position.x if _spark_rat != null else 0.0,
		"patrol_left_x": _spark_rat.global_position.x if _spark_rat != null else 0.0,
		"patrol_right_x": _spark_rat.global_position.x if _spark_rat != null else 0.0,
		"attack_startup_frames": (
			int(_spark_rat.call("get_attack_startup_frames"))
			if _spark_rat != null and _spark_rat.has_method("get_attack_startup_frames")
			else 0
		),
		"attack_sequence_id": _get_spark_rat_attack_sequence_id(),
		"attack_active": _is_spark_rat_attack_active(),
		"current_animation": "",
	}


func _get_spark_rat_opening_grace_frames() -> int:
	var pacing: Dictionary = _get_spark_rat_pacing_diagnostics()
	return int(pacing.get("opening_grace_frames", 0))


func _does_deep_guard_have_target() -> bool:
	if _deep_guard == null:
		return false
	if _deep_guard.has_method("has_attack_target"):
		return bool(_deep_guard.call("has_attack_target"))
	return _deep_guard_activated and not _deep_guard_defeated


func _does_spark_rat_have_target() -> bool:
	if _spark_rat == null:
		return false
	if _spark_rat.has_method("has_attack_target"):
		return bool(_spark_rat.call("has_attack_target"))
	return _spark_rat_activated and not _spark_rat_defeated


func _does_return_spark_rat_have_target() -> bool:
	if _return_spark_rat == null:
		return false
	if _return_spark_rat.has_method("has_attack_target"):
		return bool(_return_spark_rat.call("has_attack_target"))
	return _return_patrol_activated and not _return_patrol_defeated


func _is_deep_guard_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (provider as Node2D).global_position.x >= FACTORY_DEEP_GUARD_ACTIVATION_X


func _is_spark_rat_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (provider as Node2D).global_position.x >= FACTORY_SPARK_RAT_ACTIVATION_X


func _is_return_checkpoint_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	if _return_checkpoint == null or not _return_checkpoint is Node2D:
		return false
	return (
		(provider as Node2D).global_position.distance_to(
			(_return_checkpoint as Node2D).global_position
		)
		<= FACTORY_RETURN_CHECKPOINT_ACTIVATION_RADIUS
	)


func _get_spark_rat_distance_to_provider(provider: Node) -> float:
	if _spark_rat == null or provider == null or not provider is Node2D:
		return INF
	return _spark_rat.global_position.distance_to((provider as Node2D).global_position)


func _get_factory_enemy_by_entity_id(target_id: int) -> Node:
	for guard: Node in [_enemy, _deep_guard, _spark_rat, _return_spark_rat]:
		if guard == null or not guard.has_method("get_entity_id"):
			continue
		if int(guard.call("get_entity_id")) == target_id:
			return guard
	return null


func _get_sprite_animation_frame_counts(sprite: AnimatedSprite2D) -> Dictionary:
	if sprite == null or sprite.sprite_frames == null:
		return {}
	var frame_counts: Dictionary = {}
	for animation_name: StringName in sprite.sprite_frames.get_animation_names():
		frame_counts[String(animation_name)] = sprite.sprite_frames.get_frame_count(animation_name)
	return frame_counts


func _is_return_patrol_blocking_service_lift() -> bool:
	return _return_patrol_activated and not _return_patrol_defeated


func _is_service_lift_return_contract_in_state(state: Dictionary) -> bool:
	return (
		bool(state.get("factory_service_lift_exit_requested", false))
		and String(state.get("factory_service_lift_exit_scene_id", ""))
			== String(FACTORY_SERVICE_LIFT_EXIT_SCENE_ID)
		and String(state.get("factory_service_lift_exit_spawn_point", ""))
			== String(FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT)
	)
