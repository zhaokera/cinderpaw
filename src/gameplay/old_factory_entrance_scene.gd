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
const FACTORY_CHECKPOINT_FORWARD_SPARK_RAT_ENTITY_ID: int = 2104
const FACTORY_CHECKPOINT_REAR_SPARK_RAT_ENTITY_ID: int = 2105
const FACTORY_CHECKPOINT_OVERDRIVE_LEFT_SPARK_RAT_ENTITY_ID: int = 2106
const FACTORY_CHECKPOINT_OVERDRIVE_RIGHT_SPARK_RAT_ENTITY_ID: int = 2107
const FACTORY_LOWER_DECK_SPARK_RAT_ENTITY_ID: int = 2108
const FACTORY_LOWER_DECK_EXIT_SPARK_RAT_ENTITY_ID: int = 2109
const FACTORY_LOWER_DECK_SHORTCUT_SPARK_RAT_ENTITY_ID: int = 2110
const FACTORY_LOWER_DECK_SHORTCUT_PURSUER_ENTITY_ID: int = 2111
const FACTORY_LOWER_DECK_PRESSURE_GUARD_ENTITY_ID: int = 2112
const FACTORY_LOWER_DECK_STEAM_SLUICE_ENTITY_ID: int = 2113
const FACTORY_SPARK_RAT_BITE_DAMAGE_FALLBACK: int = 9
const FACTORY_DEEP_GUARD_ACTIVATION_X: float = 980.0
const FACTORY_SPARK_RAT_ACTIVATION_X: float = 1140.0
const FACTORY_CHECKPOINT_FORWARD_PATROL_ACTIVATION_X: float = 900.0
const FACTORY_CHECKPOINT_REAR_AMBUSH_ACTIVATION_X: float = 1108.0
const FACTORY_CHECKPOINT_OVERDRIVE_DUO_ACTIVATION_X: float = 1196.0
const FACTORY_LOWER_DECK_SKIRMISH_ACTIVATION_X: float = 780.0
const FACTORY_LOWER_DECK_SHORTCUT_ACTIVATION_X: float = 1136.0
const FACTORY_LOWER_DECK_SHORTCUT_PURSUER_ACTIVATION_X: float = 1218.0
const FACTORY_LOWER_DECK_PRESSURE_VALVE_ACTIVATION_X: float = 1240.0
const FACTORY_LOWER_DECK_STEAM_SLUICE_ACTIVATION_X: float = 1248.0
const FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES: int = 18
const FACTORY_CHECKPOINT_OVERDRIVE_LEFT_OPENING_GRACE_FRAMES: int = 12
const FACTORY_CHECKPOINT_OVERDRIVE_RIGHT_OPENING_GRACE_FRAMES: int = 30
const FACTORY_RESPAWN_HAZARD_GRACE_FRAMES: int = 18
const FACTORY_RETURN_CHECKPOINT_SPAWN_SNAP_FRAMES: int = 18
const FACTORY_RAT_MINION_COLLISION_LAYER: int = 2
const FACTORY_RAT_MINION_COLLISION_MASK: int = 17
const FACTORY_OBJECTIVE_CLEAR_ENTRANCE: StringName = &"clear_factory_entrance"
const FACTORY_OBJECTIVE_REACH_DEEP_GUARD: StringName = &"reach_deep_guard"
const FACTORY_OBJECTIVE_OPEN_DEEP_ROUTE: StringName = &"open_deep_route_endpoint"
const FACTORY_OBJECTIVE_DEFEAT_SPARK_RAT: StringName = &"defeat_spark_rat_patrol"
const FACTORY_OBJECTIVE_ROUTE_CLEARED: StringName = &"factory_route_cleared"
const FACTORY_OBJECTIVE_CLEAR_RETURN_PATROL: StringName = &"clear_return_patrol"
const FACTORY_OBJECTIVE_RETURN_PATROL_CLEARED: StringName = &"return_patrol_cleared"
const FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_FORWARD_PATROL: StringName = &"clear_checkpoint_forward_patrol"
const FACTORY_OBJECTIVE_CHECKPOINT_FORWARD_ROUTE_OPENED: StringName = &"checkpoint_forward_route_opened"
const FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_REAR_AMBUSH: StringName = &"clear_checkpoint_rear_ambush"
const FACTORY_OBJECTIVE_CHECKPOINT_REAR_AMBUSH_CLEARED: StringName = &"checkpoint_rear_ambush_cleared"
const FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_OVERDRIVE_DUO: StringName = &"clear_checkpoint_overdrive_duo"
const FACTORY_OBJECTIVE_CHECKPOINT_OVERDRIVE_DUO_CLEARED: StringName = &"checkpoint_overdrive_duo_cleared"
const FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_SKIRMISH: StringName = &"clear_lower_deck_skirmish"
const FACTORY_OBJECTIVE_LOWER_DECK_CLEARED: StringName = &"lower_deck_cleared"
const FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_EXIT_AMBUSH: StringName = &"clear_lower_deck_exit_ambush"
const FACTORY_OBJECTIVE_LOWER_DECK_EXIT_CLEARED: StringName = &"lower_deck_exit_cleared"
const FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_SHORTCUT_GUARD: StringName = &"clear_lower_deck_shortcut_guard"
const FACTORY_OBJECTIVE_OPEN_LOWER_DECK_SHORTCUT: StringName = &"open_lower_deck_shortcut"
const FACTORY_OBJECTIVE_LOWER_DECK_SHORTCUT_OPENED: StringName = &"lower_deck_shortcut_opened"
const FACTORY_OBJECTIVE_CLEAR_SHORTCUT_PURSUER: StringName = &"clear_shortcut_pursuer"
const FACTORY_OBJECTIVE_SHORTCUT_PURSUER_CLEARED: StringName = &"shortcut_pursuer_cleared"
const FACTORY_OBJECTIVE_CLEAR_PRESSURE_VALVE_GUARD: StringName = &"clear_pressure_valve_guard"
const FACTORY_OBJECTIVE_OPEN_PRESSURE_VALVE: StringName = &"open_pressure_valve"
const FACTORY_OBJECTIVE_PRESSURE_VALVE_OPENED: StringName = &"pressure_valve_opened"
const FACTORY_OBJECTIVE_CLEAR_STEAM_SLUICE_AMBUSH: StringName = &"clear_steam_sluice_ambush"
const FACTORY_OBJECTIVE_STEAM_SLUICE_CLEARED: StringName = &"steam_sluice_cleared"
const FACTORY_LOWER_DECK_PARRY_GATE_ID: StringName = &"old_factory_lower_deck_parry_laser"
const FACTORY_LOWER_DECK_SHORTCUT_SEAL_ID: StringName = &"old_factory_lower_deck_shortcut_seal"
const FACTORY_LOWER_DECK_PRESSURE_VALVE_ID: StringName = &"old_factory_lower_deck_pressure_valve"
const FACTORY_SERVICE_LIFT_ENDPOINT_ID: StringName = &"old_factory_service_lift"
const FACTORY_SERVICE_LIFT_EXIT_SCENE_ID: StringName = &"main"
const FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT: StringName = &"scrap_roost"
const FACTORY_RETURN_CHECKPOINT_ID: StringName = &"old_factory_return_checkpoint"
const FACTORY_RETURN_CHECKPOINT_SPAWN_POINT: StringName = &"return_checkpoint"
const FACTORY_GATE_ENTRY_SPAWN_POINT: StringName = &"factory_gate_entry"
const FACTORY_RETURN_CHECKPOINT_ACTIVATION_RADIUS: float = 112.0
const FACTORY_RETURN_CHECKPOINT_RESPAWN_LABEL: String = "Returned to Factory Savepoint"
const GAME_FLOW_SCRIPT: Script = preload("res://src/gameplay/game_flow_controller.gd")
const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")

@onready var _spawn: Marker2D = $FactoryGateEntrySpawn
@onready var _player: Node2D = $Player
@onready var _enemy: Node2D = $FactoryRatMinion
@onready var _deep_guard: Node2D = get_node_or_null("FactoryDeepGuardRatMinion") as Node2D
@onready var _spark_rat: Node2D = get_node_or_null("FactorySparkRat") as Node2D
@onready var _return_spark_rat: Node2D = get_node_or_null("FactoryReturnSparkRat") as Node2D
@onready var _checkpoint_forward_spark_rat: Node2D = get_node_or_null("FactoryCheckpointForwardSparkRat") as Node2D
@onready var _checkpoint_rear_spark_rat: Node2D = get_node_or_null("FactoryCheckpointRearSparkRat") as Node2D
@onready var _checkpoint_overdrive_left_spark_rat: Node2D = (
	get_node_or_null("FactoryCheckpointOverdriveSparkRatLeft") as Node2D
)
@onready var _checkpoint_overdrive_right_spark_rat: Node2D = (
	get_node_or_null("FactoryCheckpointOverdriveSparkRatRight") as Node2D
)
@onready var _lower_deck_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckSparkRat") as Node2D
)
@onready var _lower_deck_exit_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckExitSparkRat") as Node2D
)
@onready var _lower_deck_shortcut_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckShortcutSparkRat") as Node2D
)
@onready var _lower_deck_shortcut_pursuer_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckShortcutPursuerSparkRat") as Node2D
)
@onready var _lower_deck_pressure_guard_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckPressureValveSparkRat") as Node2D
)
@onready var _lower_deck_steam_sluice_spark_rat: Node2D = (
	get_node_or_null("FactoryLowerDeckSteamSluiceSparkRat") as Node2D
)
@onready var _checkpoint_overdrive_left_defeat_burst: Sprite2D = (
	get_node_or_null("FactoryCheckpointOverdriveLeftDefeatBurst") as Sprite2D
)
@onready var _checkpoint_overdrive_right_defeat_burst: Sprite2D = (
	get_node_or_null("FactoryCheckpointOverdriveRightDefeatBurst") as Sprite2D
)
@onready var _cache: Node = $FactoryCombatCache
@onready var _return_patrol_reward_cache: Node = get_node_or_null(
	"FactoryReturnPatrolRewardCache"
)
@onready var _checkpoint_overdrive_reward_cache: Node = get_node_or_null(
	"FactoryCheckpointOverdriveRewardCache"
)
@onready var _lower_deck_reward_cache: Node = get_node_or_null("FactoryLowerDeckRewardCache")
@onready var _lower_deck_parry_gate: Node = get_node_or_null("FactoryLowerDeckParryLaserGate")
@onready var _lower_deck_shortcut_seal: Node = get_node_or_null("FactoryLowerDeckShortcutSeal")
@onready var _lower_deck_shortcut_reward_cache: Node = get_node_or_null(
	"FactoryLowerDeckShortcutRewardCache"
)
@onready var _lower_deck_pressure_valve: Node = get_node_or_null("FactoryLowerDeckPressureValve")
@onready var _return_checkpoint: Node = get_node_or_null("FactoryReturnCheckpoint")
@onready var _steam_vent: Area2D = get_node_or_null("FactorySteamVentHazard") as Area2D
@onready var _checkpoint_steam_vent: Area2D = (
	get_node_or_null("FactoryCheckpointSteamVentHazard") as Area2D
)
@onready var _lower_deck_steam_vent: Area2D = (
	get_node_or_null("FactoryLowerDeckSteamVentHazard") as Area2D
)
@onready var _lower_deck_steam_sluice_hazard: Area2D = (
	get_node_or_null("FactoryLowerDeckSteamSluiceHazard") as Area2D
)
@onready var _deep_endpoint: Node = get_node_or_null("FactoryDeepRouteEndpoint")
@onready var _service_lift: Node = get_node_or_null("FactoryServiceLift")

var _last_player_hit_metadata: Dictionary = {}
var _last_cache_reward: Dictionary = {}
var _last_cache_claim_feedback: Dictionary = {}
var _last_return_patrol_reward_cache_reward: Dictionary = {}
var _last_return_patrol_reward_cache_claim_feedback: Dictionary = {}
var _last_checkpoint_overdrive_reward_cache_reward: Dictionary = {}
var _last_checkpoint_overdrive_reward_cache_claim_feedback: Dictionary = {}
var _last_lower_deck_reward_cache_reward: Dictionary = {}
var _last_lower_deck_reward_cache_claim_feedback: Dictionary = {}
var _last_lower_deck_shortcut_reward_cache_reward: Dictionary = {}
var _last_lower_deck_shortcut_reward_cache_claim_feedback: Dictionary = {}
var _last_checkpoint_overdrive_defeat_burst_side: StringName = &""
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
var _checkpoint_forward_patrol_activated: bool = false
var _checkpoint_forward_patrol_defeated: bool = false
var _checkpoint_rear_ambush_activated: bool = false
var _checkpoint_rear_ambush_defeated: bool = false
var _checkpoint_overdrive_duo_activated: bool = false
var _checkpoint_overdrive_left_defeated: bool = false
var _checkpoint_overdrive_right_defeated: bool = false
var _return_patrol_reward_cache_claimed: bool = false
var _checkpoint_overdrive_reward_cache_claimed: bool = false
var _lower_deck_skirmish_activated: bool = false
var _lower_deck_skirmish_defeated: bool = false
var _lower_deck_reward_cache_claimed: bool = false
var _lower_deck_parry_gate_unlocked: bool = false
var _lower_deck_exit_ambush_activated: bool = false
var _lower_deck_exit_ambush_defeated: bool = false
var _lower_deck_shortcut_activated: bool = false
var _lower_deck_shortcut_guard_defeated: bool = false
var _lower_deck_shortcut_unlocked: bool = false
var _lower_deck_shortcut_reward_cache_claimed: bool = false
var _lower_deck_shortcut_pursuer_activated: bool = false
var _lower_deck_shortcut_pursuer_defeated: bool = false
var _lower_deck_pressure_guard_activated: bool = false
var _lower_deck_pressure_guard_defeated: bool = false
var _lower_deck_pressure_valve_opened: bool = false
var _lower_deck_steam_sluice_activated: bool = false
var _lower_deck_steam_sluice_defeated: bool = false
var _return_checkpoint_activated: bool = false
var _last_return_checkpoint: Dictionary = {}
var _service_lift_activated: bool = false
var _service_lift_exit_requested: bool = false
var _last_service_lift_exit_rejected_reason: StringName = &""
var _last_service_lift_exit_request: Dictionary = {}
var _factory_hazard_elapsed_sec: float = 0.0
var _factory_hazard_contact_cooldowns: Dictionary = {}
var _factory_hazard_respawn_grace_frames: int = 0
var _factory_return_checkpoint_spawn_snap_frames: int = 0
var _factory_game_flow: GameFlowController = null
var _weapon_component: WeaponComponent = null
var _scene_manager: Object = null


func _ready() -> void:
	_setup_weapon_component()
	_align_player_to_spawn()
	_bind_enemy_to_player()
	_setup_factory_cache()
	_setup_factory_return_patrol_reward_cache()
	_setup_factory_checkpoint_overdrive_reward_cache()
	_setup_factory_lower_deck_reward_cache()
	_setup_factory_lower_deck_parry_gate()
	_setup_factory_lower_deck_shortcut_seal()
	_setup_factory_lower_deck_shortcut_reward_cache()
	_sync_lower_deck_shortcut_pursuer_state()
	_setup_factory_lower_deck_pressure_valve()
	_sync_lower_deck_steam_sluice_state()
	_setup_factory_return_checkpoint()
	_setup_factory_hazards()
	_setup_factory_deep_route()
	_setup_factory_spark_rat()
	_setup_factory_service_lift()
	_setup_factory_respawn_flow()
	_bind_player_combat_to_room()
	_refresh_factory_route_objective()
	_request_factory_audio()


func _process(_delta: float) -> void:
	_factory_hazard_respawn_grace_frames = maxi(_factory_hazard_respawn_grace_frames - 1, 0)
	_snap_return_checkpoint_spawn_if_needed()
	_try_auto_activate_checkpoint_forward_patrol()
	_try_auto_activate_checkpoint_rear_ambush()
	_try_auto_activate_checkpoint_overdrive_duo()
	_sync_factory_player_control_lock()


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
	_sync_factory_damage_target_defeat(target_id, damage_target)
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
		or objective_id == FACTORY_OBJECTIVE_CHECKPOINT_OVERDRIVE_DUO_CLEARED
		or objective_id == FACTORY_OBJECTIVE_LOWER_DECK_CLEARED
		or objective_id == FACTORY_OBJECTIVE_LOWER_DECK_EXIT_CLEARED
		or objective_id == FACTORY_OBJECTIVE_LOWER_DECK_SHORTCUT_OPENED
		or objective_id == FACTORY_OBJECTIVE_PRESSURE_VALVE_OPENED
		or objective_id == FACTORY_OBJECTIVE_STEAM_SLUICE_CLEARED
	)


## Returns whether the post-route service lift handoff has been activated.
func is_factory_service_lift_activated() -> bool:
	return _service_lift_activated


## Returns whether the one-time Factory return patrol has been cleared.
func is_factory_return_patrol_defeated() -> bool:
	return _return_patrol_defeated


## Returns whether the checkpoint-forward patrol has been cleared.
func is_factory_checkpoint_forward_patrol_defeated() -> bool:
	return _checkpoint_forward_patrol_defeated


## Returns whether the checkpoint rear ambush has been cleared.
func is_factory_checkpoint_rear_ambush_defeated() -> bool:
	return _checkpoint_rear_ambush_defeated


## Returns whether the checkpoint overdrive duo has been cleared.
func is_factory_checkpoint_overdrive_duo_cleared() -> bool:
	return _is_checkpoint_overdrive_duo_cleared()


## Returns whether the optional lower-deck skirmish has been cleared.
func is_factory_lower_deck_skirmish_defeated() -> bool:
	return _lower_deck_skirmish_defeated


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


## Attempts to trigger the checkpoint-forward patrol after the return checkpoint is active.
func try_activate_factory_checkpoint_forward_patrol(provider: Node = null) -> bool:
	if (
		_checkpoint_forward_spark_rat == null
		or not _return_checkpoint_activated
		or _checkpoint_forward_patrol_defeated
		or _checkpoint_forward_patrol_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_checkpoint_forward_patrol_activation_provider_in_range(activation_provider):
		return false
	_checkpoint_forward_patrol_activated = true
	_service_lift_activated = false
	_service_lift_exit_requested = false
	_last_service_lift_exit_request = {}
	_last_service_lift_exit_rejected_reason = &""
	_sync_checkpoint_forward_patrol_state()
	_sync_service_lift_state()
	_set_checkpoint_forward_spark_rat_attack_target(activation_provider)
	_begin_checkpoint_forward_spark_rat_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Attempts to activate the post-vent checkpoint rear ambush.
func try_activate_factory_checkpoint_rear_ambush(provider: Node = null) -> bool:
	if (
		_checkpoint_rear_spark_rat == null
		or not _checkpoint_forward_patrol_defeated
		or _checkpoint_rear_ambush_defeated
		or _checkpoint_rear_ambush_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_checkpoint_rear_ambush_activation_provider_in_range(activation_provider):
		return false
	_checkpoint_rear_ambush_activated = true
	_service_lift_activated = false
	_service_lift_exit_requested = false
	_last_service_lift_exit_request = {}
	_last_service_lift_exit_rejected_reason = &""
	_sync_checkpoint_rear_ambush_state()
	_sync_service_lift_state()
	_set_checkpoint_rear_spark_rat_attack_target(activation_provider)
	_begin_checkpoint_rear_spark_rat_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Attempts to activate the final checkpoint overdrive duo before the service lift.
func try_activate_factory_checkpoint_overdrive_duo(provider: Node = null) -> bool:
	if (
		_checkpoint_overdrive_left_spark_rat == null
		or _checkpoint_overdrive_right_spark_rat == null
		or not _checkpoint_rear_ambush_defeated
		or _is_checkpoint_overdrive_duo_cleared()
		or _checkpoint_overdrive_duo_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_checkpoint_overdrive_duo_activation_provider_in_range(activation_provider):
		return false
	_checkpoint_overdrive_duo_activated = true
	_service_lift_activated = false
	_service_lift_exit_requested = false
	_last_service_lift_exit_request = {}
	_last_service_lift_exit_rejected_reason = &""
	_sync_checkpoint_overdrive_duo_state()
	_sync_service_lift_state()
	_set_checkpoint_overdrive_spark_rat_attack_targets(activation_provider)
	_begin_checkpoint_overdrive_spark_rat_pacing(
		FACTORY_CHECKPOINT_OVERDRIVE_LEFT_OPENING_GRACE_FRAMES,
		FACTORY_CHECKPOINT_OVERDRIVE_RIGHT_OPENING_GRACE_FRAMES
	)
	_refresh_factory_route_objective()
	return true


## Attempts to activate the optional lower-deck skirmish after the overdrive duo is clear.
func try_activate_factory_lower_deck_skirmish(provider: Node = null) -> bool:
	if (
		_lower_deck_spark_rat == null
		or not _is_checkpoint_overdrive_duo_cleared()
		or _lower_deck_skirmish_defeated
		or _lower_deck_skirmish_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_skirmish_activation_provider_in_range(activation_provider):
		return false
	_lower_deck_skirmish_activated = true
	_sync_lower_deck_skirmish_state()
	_sync_lower_deck_pressure_hazard_state()
	_sync_lower_deck_reward_cache_state()
	_set_lower_deck_spark_rat_attack_target(activation_provider)
	_begin_lower_deck_spark_rat_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Activates the optional lower-deck exit ambush after the parry-laser gate opens.
func try_activate_factory_lower_deck_exit_ambush(provider: Node = null) -> bool:
	if (
		_lower_deck_exit_spark_rat == null
		or not _lower_deck_reward_cache_claimed
		or not _lower_deck_parry_gate_unlocked
		or _lower_deck_exit_ambush_defeated
		or _lower_deck_exit_ambush_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	_lower_deck_exit_ambush_activated = true
	_sync_lower_deck_exit_ambush_state()
	_set_lower_deck_exit_spark_rat_attack_target(activation_provider)
	_begin_lower_deck_exit_spark_rat_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Activates the optional lower-deck shortcut guard after the exit ambush is clear.
func try_activate_factory_lower_deck_shortcut_seal(provider: Node = null) -> bool:
	if (
		_lower_deck_shortcut_spark_rat == null
		or _lower_deck_shortcut_seal == null
		or not _lower_deck_exit_ambush_defeated
		or _lower_deck_shortcut_unlocked
		or _lower_deck_shortcut_guard_defeated
		or _lower_deck_shortcut_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_shortcut_activation_provider_in_range(activation_provider):
		return false
	_lower_deck_shortcut_activated = true
	_sync_lower_deck_shortcut_state()
	_set_lower_deck_shortcut_spark_rat_attack_target(activation_provider)
	_begin_lower_deck_shortcut_spark_rat_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Opens the optional lower-deck shortcut seal after its guard is defeated.
func try_open_factory_lower_deck_shortcut_seal(provider: Node = null) -> bool:
	if (
		_lower_deck_shortcut_seal == null
		or not _lower_deck_shortcut_guard_defeated
		or _lower_deck_shortcut_unlocked
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if (
		not _lower_deck_shortcut_seal.has_method("try_activate")
		or not bool(_lower_deck_shortcut_seal.call("try_activate", activation_provider))
	):
		return false
	_lower_deck_shortcut_unlocked = true
	_sync_lower_deck_shortcut_state()
	_sync_lower_deck_shortcut_reward_cache_state()
	_refresh_factory_route_objective()
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
	if _is_checkpoint_forward_patrol_blocking_service_lift():
		_record_service_lift_exit_rejection(&"forward_patrol_active")
		_sync_service_lift_state()
		return false
	if _is_checkpoint_rear_ambush_blocking_service_lift():
		_record_service_lift_exit_rejection(&"rear_ambush_active")
		_sync_service_lift_state()
		return false
	if _is_checkpoint_overdrive_duo_blocking_service_lift():
		_record_service_lift_exit_rejection(&"overdrive_duo_active")
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
	_configure_factory_respawn_scene_transition()
	if valid_scene_manager:
		_apply_current_scene_manager_spawn_point()
	return valid_scene_manager


## Advances the Factory-owned respawn flow deterministically for tests and MCP probes.
func advance_factory_respawn_flow(delta_sec: float) -> void:
	if _factory_game_flow == null or not is_instance_valid(_factory_game_flow):
		return
	_factory_game_flow.advance_time(delta_sec)
	_sync_factory_player_control_lock()


## Returns deterministic Factory respawn-flow diagnostics for tests and MCP probes.
func get_factory_respawn_flow_diagnostics() -> Dictionary:
	if _factory_game_flow == null or not is_instance_valid(_factory_game_flow):
		return {
			"present": false,
			"state": "",
			"control_locked": false,
			"invincibility_remaining": 0.0,
			"last_selected_respawn_point": {},
		}
	return {
		"present": true,
		"state": String(_factory_game_flow.get_flow_state()),
		"control_locked": _factory_game_flow.is_player_control_locked(),
		"invincibility_remaining": _factory_game_flow.get_invincibility_remaining(),
		"last_selected_respawn_point": _factory_game_flow.get_last_selected_respawn_point(),
	}


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


## Attempts to claim the checkpoint overdrive reward cache after the duo is cleared.
func try_claim_factory_checkpoint_overdrive_reward_cache(provider: Node = null) -> bool:
	if not _is_checkpoint_overdrive_duo_cleared() or _checkpoint_overdrive_reward_cache == null:
		return false
	var claim_provider: Node = provider
	if claim_provider == null:
		claim_provider = _player
	if (
		not _checkpoint_overdrive_reward_cache.has_method("try_claim")
		or not bool(_checkpoint_overdrive_reward_cache.call("try_claim", claim_provider))
	):
		return false
	_checkpoint_overdrive_reward_cache_claimed = true
	var reward_payload: Dictionary = _get_checkpoint_overdrive_reward_cache_payload()
	if _last_checkpoint_overdrive_reward_cache_reward.is_empty():
		_last_checkpoint_overdrive_reward_cache_reward = reward_payload
	_sync_checkpoint_overdrive_reward_cache_state()
	if _last_checkpoint_overdrive_reward_cache_claim_feedback.is_empty():
		_record_checkpoint_overdrive_reward_cache_claim_feedback(
			reward_payload,
			"Overdrive Cache Claimed"
		)
	return true


## Attempts to claim the lower-deck reward cache after the optional skirmish is cleared.
func try_claim_factory_lower_deck_reward_cache(provider: Node = null) -> bool:
	if not _lower_deck_skirmish_defeated or _lower_deck_reward_cache == null:
		return false
	var claim_provider: Node = provider
	if claim_provider == null:
		claim_provider = _player
	if (
		not _lower_deck_reward_cache.has_method("try_claim")
		or not bool(_lower_deck_reward_cache.call("try_claim", claim_provider))
	):
		return false
	_lower_deck_reward_cache_claimed = true
	var reward_payload: Dictionary = _get_lower_deck_reward_cache_payload()
	if _last_lower_deck_reward_cache_reward.is_empty():
		_last_lower_deck_reward_cache_reward = reward_payload
	_sync_lower_deck_reward_cache_state()
	if _last_lower_deck_reward_cache_claim_feedback.is_empty():
		_record_lower_deck_reward_cache_claim_feedback(
			reward_payload,
			"Lower Deck Cache Claimed"
		)
	return true


## Attempts to claim the shortcut payoff cache after the shortcut seal is opened.
func try_claim_factory_lower_deck_shortcut_reward_cache(provider: Node = null) -> bool:
	if not _lower_deck_shortcut_unlocked or _lower_deck_shortcut_reward_cache == null:
		return false
	var claim_provider: Node = provider
	if claim_provider == null:
		claim_provider = _player
	if (
		not _lower_deck_shortcut_reward_cache.has_method("try_claim")
		or not bool(_lower_deck_shortcut_reward_cache.call("try_claim", claim_provider))
	):
		return false
	_lower_deck_shortcut_reward_cache_claimed = true
	var reward_payload: Dictionary = _get_lower_deck_shortcut_reward_cache_payload()
	if _last_lower_deck_shortcut_reward_cache_reward.is_empty():
		_last_lower_deck_shortcut_reward_cache_reward = reward_payload
	_sync_lower_deck_shortcut_reward_cache_state()
	if _last_lower_deck_shortcut_reward_cache_claim_feedback.is_empty():
		_record_lower_deck_shortcut_reward_cache_claim_feedback(
			reward_payload,
			"Shortcut Cache Claimed"
		)
	return true


## Attempts to activate the optional pursuer after the shortcut payoff is claimed.
func try_activate_factory_lower_deck_shortcut_pursuer(provider: Node = null) -> bool:
	if (
		_lower_deck_shortcut_pursuer_spark_rat == null
		or not _is_lower_deck_shortcut_pursuer_available()
		or _lower_deck_shortcut_pursuer_activated
	):
		return false
	var activation_provider: Node = provider
	if activation_provider == null:
		activation_provider = _player
	if not _is_lower_deck_shortcut_pursuer_activation_provider_in_range(
		activation_provider
	):
		return false
	_lower_deck_shortcut_pursuer_activated = true
	_sync_lower_deck_shortcut_pursuer_state()
	_set_lower_deck_shortcut_pursuer_attack_target(activation_provider)
	_begin_lower_deck_shortcut_pursuer_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Attempts to activate the pressure valve guard after the shortcut pursuer is clear.
func try_activate_factory_lower_deck_pressure_guard(provider: Node = null) -> bool:
	if (
		_lower_deck_pressure_guard_spark_rat == null
		or not _is_lower_deck_pressure_guard_available()
		or _lower_deck_pressure_guard_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_pressure_guard_activation_provider_in_range(activation_provider):
		return false
	_lower_deck_pressure_guard_activated = true
	_sync_lower_deck_pressure_valve_state()
	_set_lower_deck_pressure_guard_attack_target(activation_provider)
	_begin_lower_deck_pressure_guard_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
	return true


## Opens the deeper lower-deck pressure valve after its guard is defeated.
func try_open_factory_lower_deck_pressure_valve(provider: Node = null) -> bool:
	if (
		_lower_deck_pressure_valve == null
		or not _lower_deck_pressure_guard_defeated
		or _lower_deck_pressure_valve_opened
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if (
		not _lower_deck_pressure_valve.has_method("try_activate")
		or not bool(_lower_deck_pressure_valve.call("try_activate", activation_provider))
	):
		return false
	_lower_deck_pressure_valve_opened = true
	_sync_lower_deck_pressure_valve_state()
	_refresh_factory_route_objective()
	return true


## Attempts to activate the steam sluice ambush after the pressure valve opens.
func try_activate_factory_lower_deck_steam_sluice(provider: Node = null) -> bool:
	if (
		_lower_deck_steam_sluice_spark_rat == null
		or not _is_lower_deck_steam_sluice_available()
		or _lower_deck_steam_sluice_activated
	):
		return false
	var activation_provider: Node = provider if provider != null else _player
	if not _is_lower_deck_steam_sluice_activation_provider_in_range(activation_provider):
		return false
	_lower_deck_steam_sluice_activated = true
	_sync_lower_deck_steam_sluice_state()
	_set_lower_deck_steam_sluice_attack_target(activation_provider)
	_begin_lower_deck_steam_sluice_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	_refresh_factory_route_objective()
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


## Advances the checkpoint overdrive duo pacing loop deterministically for tests and MCP probes.
func advance_factory_checkpoint_overdrive_duo_pacing_frames(frames: int) -> void:
	var safe_frames: int = maxi(0, frames)
	if (
		_checkpoint_overdrive_left_spark_rat != null
		and _checkpoint_overdrive_left_spark_rat.has_method("advance_pacing_frames")
		and _checkpoint_overdrive_duo_activated
		and not _checkpoint_overdrive_left_defeated
	):
		_checkpoint_overdrive_left_spark_rat.call("advance_pacing_frames", safe_frames)
	if (
		_checkpoint_overdrive_right_spark_rat != null
		and _checkpoint_overdrive_right_spark_rat.has_method("advance_pacing_frames")
		and _checkpoint_overdrive_duo_activated
		and not _checkpoint_overdrive_right_defeated
	):
		_checkpoint_overdrive_right_spark_rat.call("advance_pacing_frames", safe_frames)


## Applies steam vent contact damage to the player with per-target cooldown.
func apply_factory_steam_vent_contact(hazard: Area2D, target: Node) -> bool:
	if hazard == null or target == null or _player == null or not is_instance_valid(hazard):
		return false
	if target != _player:
		return false
	if _factory_hazard_respawn_grace_frames > 0:
		return false
	var hazard_id: StringName = _get_hazard_id(hazard)
	if not _is_factory_steam_hazard_id(hazard_id):
		return false
	if not _is_hazard_contact_active(hazard):
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
		"factory_checkpoint_forward_patrol_activated": _checkpoint_forward_patrol_activated,
		"factory_checkpoint_forward_patrol_defeated": _checkpoint_forward_patrol_defeated,
		"factory_checkpoint_forward_patrol_opening_grace_frames": (
			_get_checkpoint_forward_patrol_opening_grace_frames()
		),
		"factory_checkpoint_rear_ambush_activated": _checkpoint_rear_ambush_activated,
		"factory_checkpoint_rear_ambush_defeated": _checkpoint_rear_ambush_defeated,
		"factory_checkpoint_rear_ambush_opening_grace_frames": (
			_get_checkpoint_rear_ambush_opening_grace_frames()
		),
		"factory_checkpoint_overdrive_duo_activated": _checkpoint_overdrive_duo_activated,
		"factory_checkpoint_overdrive_left_defeated": _checkpoint_overdrive_left_defeated,
		"factory_checkpoint_overdrive_right_defeated": _checkpoint_overdrive_right_defeated,
		"factory_checkpoint_overdrive_duo_cleared": _is_checkpoint_overdrive_duo_cleared(),
		"factory_checkpoint_overdrive_duo_opening_grace_frames": (
			_get_checkpoint_overdrive_duo_opening_grace_frames()
		),
		"factory_checkpoint_overdrive_left_opening_grace_frames": (
			_get_checkpoint_overdrive_left_opening_grace_frames()
		),
		"factory_checkpoint_overdrive_right_opening_grace_frames": (
			_get_checkpoint_overdrive_right_opening_grace_frames()
		),
		"factory_lower_deck_skirmish_activated": _lower_deck_skirmish_activated,
		"factory_lower_deck_skirmish_defeated": _lower_deck_skirmish_defeated,
		"factory_lower_deck_skirmish_opening_grace_frames": (
			_get_lower_deck_skirmish_opening_grace_frames()
		),
		"factory_lower_deck_parry_gate_unlocked": _lower_deck_parry_gate_unlocked,
		"factory_lower_deck_exit_ambush_activated": _lower_deck_exit_ambush_activated,
		"factory_lower_deck_exit_ambush_defeated": _lower_deck_exit_ambush_defeated,
		"factory_lower_deck_exit_ambush_opening_grace_frames": (
			_get_lower_deck_exit_ambush_opening_grace_frames()
		),
		"factory_lower_deck_shortcut_activated": _lower_deck_shortcut_activated,
		"factory_lower_deck_shortcut_guard_defeated": (
			_lower_deck_shortcut_guard_defeated
		),
		"factory_lower_deck_shortcut_unlocked": _lower_deck_shortcut_unlocked,
		"factory_lower_deck_shortcut_opening_grace_frames": (
			_get_lower_deck_shortcut_opening_grace_frames()
		),
		"factory_return_patrol_reward_cache_claimed": _return_patrol_reward_cache_claimed,
		"factory_checkpoint_overdrive_reward_cache_claimed": (
			_checkpoint_overdrive_reward_cache_claimed
		),
		"factory_lower_deck_reward_cache_claimed": _lower_deck_reward_cache_claimed,
		"factory_lower_deck_shortcut_reward_cache_claimed": (
			_lower_deck_shortcut_reward_cache_claimed
		),
		"factory_lower_deck_shortcut_pursuer_activated": (
			_lower_deck_shortcut_pursuer_activated
		),
		"factory_lower_deck_shortcut_pursuer_defeated": (
			_lower_deck_shortcut_pursuer_defeated
		),
		"factory_lower_deck_pressure_guard_activated": (
			_lower_deck_pressure_guard_activated
		),
		"factory_lower_deck_pressure_guard_defeated": (
			_lower_deck_pressure_guard_defeated
		),
		"factory_lower_deck_pressure_valve_opened": _lower_deck_pressure_valve_opened,
		"factory_lower_deck_steam_sluice_activated": (
			_lower_deck_steam_sluice_activated
		),
		"factory_lower_deck_steam_sluice_defeated": _lower_deck_steam_sluice_defeated,
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
		"last_checkpoint_overdrive_reward_cache_reward": (
			_last_checkpoint_overdrive_reward_cache_reward.duplicate(true)
		),
		"last_checkpoint_overdrive_reward_cache_claim_feedback": (
			_last_checkpoint_overdrive_reward_cache_claim_feedback.duplicate(true)
		),
		"last_lower_deck_reward_cache_reward": (
			_last_lower_deck_reward_cache_reward.duplicate(true)
		),
		"last_lower_deck_reward_cache_claim_feedback": (
			_last_lower_deck_reward_cache_claim_feedback.duplicate(true)
		),
		"last_lower_deck_shortcut_reward_cache_reward": (
			_last_lower_deck_shortcut_reward_cache_reward.duplicate(true)
		),
		"last_lower_deck_shortcut_reward_cache_claim_feedback": (
			_last_lower_deck_shortcut_reward_cache_claim_feedback.duplicate(true)
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
	_checkpoint_forward_patrol_activated = bool(state.get(
		"factory_checkpoint_forward_patrol_activated",
		false
	))
	_checkpoint_forward_patrol_defeated = bool(state.get(
		"factory_checkpoint_forward_patrol_defeated",
		false
	))
	_checkpoint_rear_ambush_activated = bool(state.get(
		"factory_checkpoint_rear_ambush_activated",
		false
	))
	_checkpoint_rear_ambush_defeated = bool(state.get(
		"factory_checkpoint_rear_ambush_defeated",
		false
	))
	_checkpoint_overdrive_duo_activated = bool(state.get(
		"factory_checkpoint_overdrive_duo_activated",
		false
	))
	_checkpoint_overdrive_left_defeated = bool(state.get(
		"factory_checkpoint_overdrive_left_defeated",
		false
	))
	_checkpoint_overdrive_right_defeated = bool(state.get(
		"factory_checkpoint_overdrive_right_defeated",
		false
	))
	if bool(state.get("factory_checkpoint_overdrive_duo_cleared", false)):
		_checkpoint_overdrive_left_defeated = true
		_checkpoint_overdrive_right_defeated = true
	_lower_deck_skirmish_activated = bool(state.get(
		"factory_lower_deck_skirmish_activated",
		false
	))
	_lower_deck_skirmish_defeated = bool(state.get(
		"factory_lower_deck_skirmish_defeated",
		false
	))
	_lower_deck_parry_gate_unlocked = bool(state.get(
		"factory_lower_deck_parry_gate_unlocked",
		false
	))
	_lower_deck_exit_ambush_activated = bool(state.get(
		"factory_lower_deck_exit_ambush_activated",
		false
	))
	_lower_deck_exit_ambush_defeated = bool(state.get(
		"factory_lower_deck_exit_ambush_defeated",
		false
	))
	_lower_deck_shortcut_activated = bool(state.get(
		"factory_lower_deck_shortcut_activated",
		false
	))
	_lower_deck_shortcut_guard_defeated = bool(state.get(
		"factory_lower_deck_shortcut_guard_defeated",
		false
	))
	_lower_deck_shortcut_unlocked = bool(state.get(
		"factory_lower_deck_shortcut_unlocked",
		false
	))
	_return_patrol_reward_cache_claimed = bool(state.get(
		"factory_return_patrol_reward_cache_claimed",
		false
	))
	_checkpoint_overdrive_reward_cache_claimed = bool(state.get(
		"factory_checkpoint_overdrive_reward_cache_claimed",
		false
	))
	_lower_deck_reward_cache_claimed = bool(state.get(
		"factory_lower_deck_reward_cache_claimed",
		false
	))
	_lower_deck_shortcut_reward_cache_claimed = bool(state.get(
		"factory_lower_deck_shortcut_reward_cache_claimed",
		false
	))
	_lower_deck_shortcut_pursuer_activated = bool(state.get(
		"factory_lower_deck_shortcut_pursuer_activated",
		false
	))
	_lower_deck_shortcut_pursuer_defeated = bool(state.get(
		"factory_lower_deck_shortcut_pursuer_defeated",
		false
	))
	_lower_deck_pressure_guard_activated = bool(state.get(
		"factory_lower_deck_pressure_guard_activated",
		false
	))
	_lower_deck_pressure_guard_defeated = bool(state.get(
		"factory_lower_deck_pressure_guard_defeated",
		false
	))
	_lower_deck_pressure_valve_opened = bool(state.get(
		"factory_lower_deck_pressure_valve_opened",
		false
	))
	_lower_deck_steam_sluice_activated = bool(state.get(
		"factory_lower_deck_steam_sluice_activated",
		false
	))
	_lower_deck_steam_sluice_defeated = bool(state.get(
		"factory_lower_deck_steam_sluice_defeated",
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
	var checkpoint_forward_opening_grace_frames: int = int(state.get(
		"factory_checkpoint_forward_patrol_opening_grace_frames",
		(
			FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
			if _checkpoint_forward_patrol_activated and not _checkpoint_forward_patrol_defeated
			else 0
		)
	))
	var checkpoint_rear_opening_grace_frames: int = int(state.get(
		"factory_checkpoint_rear_ambush_opening_grace_frames",
		(
			FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
			if _checkpoint_rear_ambush_activated and not _checkpoint_rear_ambush_defeated
			else 0
		)
	))
	var checkpoint_overdrive_opening_grace_frames: int = int(state.get(
		"factory_checkpoint_overdrive_duo_opening_grace_frames",
		(
			FACTORY_CHECKPOINT_OVERDRIVE_RIGHT_OPENING_GRACE_FRAMES
			if _checkpoint_overdrive_duo_activated and not _is_checkpoint_overdrive_duo_cleared()
			else 0
		)
	))
	var checkpoint_overdrive_left_opening_grace_frames: int = int(state.get(
		"factory_checkpoint_overdrive_left_opening_grace_frames",
		(
			checkpoint_overdrive_opening_grace_frames
			if state.has("factory_checkpoint_overdrive_duo_opening_grace_frames")
			else (
				FACTORY_CHECKPOINT_OVERDRIVE_LEFT_OPENING_GRACE_FRAMES
				if (
					_checkpoint_overdrive_duo_activated
					and not _is_checkpoint_overdrive_duo_cleared()
				)
				else 0
			)
		)
	))
	var checkpoint_overdrive_right_opening_grace_frames: int = int(state.get(
		"factory_checkpoint_overdrive_right_opening_grace_frames",
		(
			checkpoint_overdrive_opening_grace_frames
			if state.has("factory_checkpoint_overdrive_duo_opening_grace_frames")
			else (
				FACTORY_CHECKPOINT_OVERDRIVE_RIGHT_OPENING_GRACE_FRAMES
				if (
					_checkpoint_overdrive_duo_activated
					and not _is_checkpoint_overdrive_duo_cleared()
				)
				else 0
			)
		)
	))
	var lower_deck_opening_grace_frames: int = int(state.get(
		"factory_lower_deck_skirmish_opening_grace_frames",
		(
			FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
			if _lower_deck_skirmish_activated and not _lower_deck_skirmish_defeated
			else 0
		)
	))
	var lower_deck_exit_opening_grace_frames: int = int(state.get(
		"factory_lower_deck_exit_ambush_opening_grace_frames",
		(
			FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
			if _lower_deck_exit_ambush_activated and not _lower_deck_exit_ambush_defeated
			else 0
		)
	))
	var lower_deck_shortcut_opening_grace_frames: int = int(state.get(
		"factory_lower_deck_shortcut_opening_grace_frames",
		(
			FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES
			if _lower_deck_shortcut_activated and not _lower_deck_shortcut_guard_defeated
			else 0
		)
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
	var overdrive_reward_variant: Variant = state.get(
		"last_checkpoint_overdrive_reward_cache_reward",
		{}
	)
	_last_checkpoint_overdrive_reward_cache_reward = (
		(overdrive_reward_variant as Dictionary).duplicate(true)
		if overdrive_reward_variant is Dictionary
		else {}
	)
	var overdrive_feedback_variant: Variant = state.get(
		"last_checkpoint_overdrive_reward_cache_claim_feedback",
		{}
	)
	_last_checkpoint_overdrive_reward_cache_claim_feedback = (
		(overdrive_feedback_variant as Dictionary).duplicate(true)
		if overdrive_feedback_variant is Dictionary
		else {}
	)
	var lower_deck_reward_variant: Variant = state.get(
		"last_lower_deck_reward_cache_reward",
		{}
	)
	_last_lower_deck_reward_cache_reward = (
		(lower_deck_reward_variant as Dictionary).duplicate(true)
		if lower_deck_reward_variant is Dictionary
		else {}
	)
	var lower_deck_feedback_variant: Variant = state.get(
		"last_lower_deck_reward_cache_claim_feedback",
		{}
	)
	_last_lower_deck_reward_cache_claim_feedback = (
		(lower_deck_feedback_variant as Dictionary).duplicate(true)
		if lower_deck_feedback_variant is Dictionary
		else {}
	)
	var lower_deck_shortcut_reward_variant: Variant = state.get(
		"last_lower_deck_shortcut_reward_cache_reward",
		{}
	)
	_last_lower_deck_shortcut_reward_cache_reward = (
		(lower_deck_shortcut_reward_variant as Dictionary).duplicate(true)
		if lower_deck_shortcut_reward_variant is Dictionary
		else {}
	)
	var lower_deck_shortcut_feedback_variant: Variant = state.get(
		"last_lower_deck_shortcut_reward_cache_claim_feedback",
		{}
	)
	_last_lower_deck_shortcut_reward_cache_claim_feedback = (
		(lower_deck_shortcut_feedback_variant as Dictionary).duplicate(true)
		if lower_deck_shortcut_feedback_variant is Dictionary
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
	if _is_checkpoint_forward_patrol_blocking_service_lift():
		_service_lift_activated = false
		_service_lift_exit_requested = false
		_last_service_lift_exit_rejected_reason = &""
		_last_service_lift_exit_request = {}
	if _is_checkpoint_rear_ambush_blocking_service_lift():
		_service_lift_activated = false
		_service_lift_exit_requested = false
		_last_service_lift_exit_rejected_reason = &""
		_last_service_lift_exit_request = {}
	if _is_checkpoint_overdrive_duo_blocking_service_lift():
		_service_lift_activated = false
		_service_lift_exit_requested = false
		_last_service_lift_exit_rejected_reason = &""
		_last_service_lift_exit_request = {}
	_sync_room_clear_state()
	_sync_deep_route_state()
	_sync_spark_rat_state()
	_sync_return_patrol_state()
	_sync_checkpoint_forward_patrol_state()
	_sync_checkpoint_rear_ambush_state()
	_sync_checkpoint_overdrive_duo_state()
	_sync_checkpoint_steam_vent_state()
	_sync_lower_deck_skirmish_state()
	_sync_lower_deck_pressure_hazard_state()
	_sync_lower_deck_parry_gate_state()
	_sync_lower_deck_exit_ambush_state()
	_sync_lower_deck_shortcut_state()
	_sync_return_patrol_reward_cache_state()
	_sync_checkpoint_overdrive_reward_cache_state()
	_sync_lower_deck_reward_cache_state()
	_sync_lower_deck_shortcut_reward_cache_state()
	_sync_lower_deck_shortcut_pursuer_state()
	_sync_lower_deck_pressure_valve_state()
	_sync_lower_deck_steam_sluice_state()
	_sync_return_checkpoint_state()
	_sync_service_lift_state()
	if _spark_rat_activated and not _spark_rat_defeated:
		_begin_spark_rat_pacing(spark_rat_opening_grace_frames)
	if _return_patrol_activated and not _return_patrol_defeated:
		_begin_return_spark_rat_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	if _checkpoint_forward_patrol_activated and not _checkpoint_forward_patrol_defeated:
		_begin_checkpoint_forward_spark_rat_pacing(checkpoint_forward_opening_grace_frames)
	if _checkpoint_rear_ambush_activated and not _checkpoint_rear_ambush_defeated:
		_begin_checkpoint_rear_spark_rat_pacing(checkpoint_rear_opening_grace_frames)
	if _checkpoint_overdrive_duo_activated and not _is_checkpoint_overdrive_duo_cleared():
		_begin_checkpoint_overdrive_spark_rat_pacing(
			checkpoint_overdrive_left_opening_grace_frames,
			checkpoint_overdrive_right_opening_grace_frames
		)
	if _lower_deck_skirmish_activated and not _lower_deck_skirmish_defeated:
		_begin_lower_deck_spark_rat_pacing(lower_deck_opening_grace_frames)
	if _lower_deck_exit_ambush_activated and not _lower_deck_exit_ambush_defeated:
		_begin_lower_deck_exit_spark_rat_pacing(lower_deck_exit_opening_grace_frames)
	if _lower_deck_shortcut_activated and not _lower_deck_shortcut_guard_defeated:
		_begin_lower_deck_shortcut_spark_rat_pacing(lower_deck_shortcut_opening_grace_frames)
	if _is_lower_deck_shortcut_pursuer_active():
		_begin_lower_deck_shortcut_pursuer_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	if _is_lower_deck_pressure_guard_active():
		_begin_lower_deck_pressure_guard_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
	if _is_lower_deck_steam_sluice_active():
		_begin_lower_deck_steam_sluice_pacing(FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES)
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
		"checkpoint_steam_vent_present": _checkpoint_steam_vent != null,
		"checkpoint_steam_vent_visible": (
			_checkpoint_steam_vent.visible if _checkpoint_steam_vent != null else false
		),
		"checkpoint_steam_vent_active": (
			_is_hazard_contact_active(_checkpoint_steam_vent)
			if _checkpoint_steam_vent != null
			else false
		),
		"checkpoint_steam_vent_id": String(_get_hazard_id(_checkpoint_steam_vent)),
		"checkpoint_steam_damage": _get_hazard_damage(_checkpoint_steam_vent),
		"checkpoint_steam_cooldown_sec": _get_hazard_cooldown_sec(_checkpoint_steam_vent),
		"checkpoint_steam_vent_texture_path": (
			String(_checkpoint_steam_vent.call("get_visual_texture_path"))
			if (
				_checkpoint_steam_vent != null
				and _checkpoint_steam_vent.has_method("get_visual_texture_path")
			)
			else ""
		),
		"checkpoint_steam_vent_layer": (
			_checkpoint_steam_vent.collision_layer if _checkpoint_steam_vent != null else 0
		),
		"checkpoint_steam_vent_mask": (
			_checkpoint_steam_vent.collision_mask if _checkpoint_steam_vent != null else 0
		),
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


## Returns deterministic checkpoint-forward patrol diagnostics for tests and MCP probes.
func get_factory_checkpoint_forward_patrol_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_checkpoint_forward_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _checkpoint_forward_spark_rat != null
		else null
	)
	var pacing_diagnostics: Dictionary = _get_checkpoint_forward_patrol_pacing_diagnostics()
	return {
		"present": _checkpoint_forward_spark_rat != null,
		"visible": (
			_checkpoint_forward_spark_rat.visible
			if _checkpoint_forward_spark_rat != null
			else false
		),
		"available": _return_checkpoint_activated and not _checkpoint_forward_patrol_defeated,
		"active": _checkpoint_forward_patrol_activated and not _checkpoint_forward_patrol_defeated,
		"defeated": _checkpoint_forward_patrol_defeated,
		"activation_x": FACTORY_CHECKPOINT_FORWARD_PATROL_ACTIVATION_X,
		"activation_ready": _is_checkpoint_forward_patrol_activation_provider_in_range(_player),
		"entity_id": (
			int(_checkpoint_forward_spark_rat.call("get_entity_id"))
			if (
				_checkpoint_forward_spark_rat != null
				and _checkpoint_forward_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"has_target": _does_checkpoint_forward_spark_rat_have_target(),
		"physics_enabled": (
			_checkpoint_forward_spark_rat.is_physics_processing()
			if _checkpoint_forward_spark_rat != null
			else false
		),
		"process_enabled": (
			_checkpoint_forward_spark_rat.is_processing()
			if _checkpoint_forward_spark_rat != null
			else false
		),
		"collision_layer": (
			_checkpoint_forward_spark_rat.collision_layer
			if _checkpoint_forward_spark_rat != null
			else 0
		),
		"collision_mask": (
			_checkpoint_forward_spark_rat.collision_mask
			if _checkpoint_forward_spark_rat != null
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": pacing_diagnostics,
		"position": (
			_checkpoint_forward_spark_rat.global_position
			if _checkpoint_forward_spark_rat != null
			else Vector2.ZERO
		),
	}


## Returns deterministic checkpoint rear ambush diagnostics for tests and MCP probes.
func get_factory_checkpoint_rear_ambush_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_checkpoint_rear_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _checkpoint_rear_spark_rat != null
		else null
	)
	var pacing_diagnostics: Dictionary = _get_checkpoint_rear_ambush_pacing_diagnostics()
	return {
		"present": _checkpoint_rear_spark_rat != null,
		"visible": (
			_checkpoint_rear_spark_rat.visible
			if _checkpoint_rear_spark_rat != null
			else false
		),
		"available": _checkpoint_forward_patrol_defeated and not _checkpoint_rear_ambush_defeated,
		"active": _checkpoint_rear_ambush_activated and not _checkpoint_rear_ambush_defeated,
		"defeated": _checkpoint_rear_ambush_defeated,
		"activation_x": FACTORY_CHECKPOINT_REAR_AMBUSH_ACTIVATION_X,
		"activation_ready": _is_checkpoint_rear_ambush_activation_provider_in_range(_player),
		"entity_id": (
			int(_checkpoint_rear_spark_rat.call("get_entity_id"))
			if (
				_checkpoint_rear_spark_rat != null
				and _checkpoint_rear_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"has_target": _does_checkpoint_rear_spark_rat_have_target(),
		"physics_enabled": (
			_checkpoint_rear_spark_rat.is_physics_processing()
			if _checkpoint_rear_spark_rat != null
			else false
		),
		"process_enabled": (
			_checkpoint_rear_spark_rat.is_processing()
			if _checkpoint_rear_spark_rat != null
			else false
		),
		"collision_layer": (
			_checkpoint_rear_spark_rat.collision_layer
			if _checkpoint_rear_spark_rat != null
			else 0
		),
		"collision_mask": (
			_checkpoint_rear_spark_rat.collision_mask
			if _checkpoint_rear_spark_rat != null
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": pacing_diagnostics,
		"position": (
			_checkpoint_rear_spark_rat.global_position
			if _checkpoint_rear_spark_rat != null
			else Vector2.ZERO
		),
	}


## Returns deterministic checkpoint overdrive duo diagnostics for tests and MCP probes.
func get_factory_checkpoint_overdrive_duo_diagnostics() -> Dictionary:
	var left_sprite: AnimatedSprite2D = (
		_checkpoint_overdrive_left_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _checkpoint_overdrive_left_spark_rat != null
		else null
	)
	var right_sprite: AnimatedSprite2D = (
		_checkpoint_overdrive_right_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _checkpoint_overdrive_right_spark_rat != null
		else null
	)
	var pacing_diagnostics: Dictionary = _get_checkpoint_overdrive_duo_pacing_diagnostics()
	return {
		"present": (
			_checkpoint_overdrive_left_spark_rat != null
			and _checkpoint_overdrive_right_spark_rat != null
		),
		"available": _checkpoint_rear_ambush_defeated and not _is_checkpoint_overdrive_duo_cleared(),
		"active": _is_checkpoint_overdrive_duo_active(),
		"cleared": _is_checkpoint_overdrive_duo_cleared(),
		"activation_x": FACTORY_CHECKPOINT_OVERDRIVE_DUO_ACTIVATION_X,
		"activation_ready": _is_checkpoint_overdrive_duo_activation_provider_in_range(_player),
		"left_visible": (
			_checkpoint_overdrive_left_spark_rat.visible
			if _checkpoint_overdrive_left_spark_rat != null
			else false
		),
		"right_visible": (
			_checkpoint_overdrive_right_spark_rat.visible
			if _checkpoint_overdrive_right_spark_rat != null
			else false
		),
		"left_defeated": _checkpoint_overdrive_left_defeated,
		"right_defeated": _checkpoint_overdrive_right_defeated,
		"left_entity_id": (
			int(_checkpoint_overdrive_left_spark_rat.call("get_entity_id"))
			if (
				_checkpoint_overdrive_left_spark_rat != null
				and _checkpoint_overdrive_left_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"right_entity_id": (
			int(_checkpoint_overdrive_right_spark_rat.call("get_entity_id"))
			if (
				_checkpoint_overdrive_right_spark_rat != null
				and _checkpoint_overdrive_right_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"left_has_target": _does_checkpoint_overdrive_left_spark_rat_have_target(),
		"right_has_target": _does_checkpoint_overdrive_right_spark_rat_have_target(),
		"left_physics_enabled": (
			_checkpoint_overdrive_left_spark_rat.is_physics_processing()
			if _checkpoint_overdrive_left_spark_rat != null
			else false
		),
		"right_physics_enabled": (
			_checkpoint_overdrive_right_spark_rat.is_physics_processing()
			if _checkpoint_overdrive_right_spark_rat != null
			else false
		),
		"left_process_enabled": (
			_checkpoint_overdrive_left_spark_rat.is_processing()
			if _checkpoint_overdrive_left_spark_rat != null
			else false
		),
		"right_process_enabled": (
			_checkpoint_overdrive_right_spark_rat.is_processing()
			if _checkpoint_overdrive_right_spark_rat != null
			else false
		),
		"left_collision_layer": (
			_checkpoint_overdrive_left_spark_rat.collision_layer
			if _checkpoint_overdrive_left_spark_rat != null
			else 0
		),
		"right_collision_layer": (
			_checkpoint_overdrive_right_spark_rat.collision_layer
			if _checkpoint_overdrive_right_spark_rat != null
			else 0
		),
		"left_collision_mask": (
			_checkpoint_overdrive_left_spark_rat.collision_mask
			if _checkpoint_overdrive_left_spark_rat != null
			else 0
		),
		"right_collision_mask": (
			_checkpoint_overdrive_right_spark_rat.collision_mask
			if _checkpoint_overdrive_right_spark_rat != null
			else 0
		),
		"left_sprite_frames_path": (
			left_sprite.sprite_frames.resource_path
			if left_sprite != null and left_sprite.sprite_frames != null
			else ""
		),
		"right_sprite_frames_path": (
			right_sprite.sprite_frames.resource_path
			if right_sprite != null and right_sprite.sprite_frames != null
			else ""
		),
		"left_animation_frame_counts": _get_sprite_animation_frame_counts(left_sprite),
		"right_animation_frame_counts": _get_sprite_animation_frame_counts(right_sprite),
		"pacing": pacing_diagnostics,
		"left_position": (
			_checkpoint_overdrive_left_spark_rat.global_position
			if _checkpoint_overdrive_left_spark_rat != null
			else Vector2.ZERO
		),
		"right_position": (
			_checkpoint_overdrive_right_spark_rat.global_position
			if _checkpoint_overdrive_right_spark_rat != null
			else Vector2.ZERO
		),
	}


## Returns deterministic lower-deck skirmish/cache diagnostics for tests and MCP probes.
func get_factory_lower_deck_skirmish_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_spark_rat != null
		else null
	)
	return {
		"present": _lower_deck_spark_rat != null and _lower_deck_reward_cache != null,
		"available": _is_checkpoint_overdrive_duo_cleared() and not _lower_deck_skirmish_defeated,
		"active": _is_lower_deck_skirmish_active(),
		"defeated": _lower_deck_skirmish_defeated,
		"activation_x": FACTORY_LOWER_DECK_SKIRMISH_ACTIVATION_X,
		"activation_ready": _is_lower_deck_skirmish_activation_provider_in_range(_player),
		"enemy_visible": _lower_deck_spark_rat.visible if _lower_deck_spark_rat != null else false,
		"enemy_has_target": _does_lower_deck_spark_rat_have_target(),
		"enemy_physics_enabled": (
			_lower_deck_spark_rat.is_physics_processing()
			if _lower_deck_spark_rat != null
			else false
		),
		"enemy_process_enabled": (
			_lower_deck_spark_rat.is_processing()
			if _lower_deck_spark_rat != null
			else false
		),
		"entity_id": (
			int(_lower_deck_spark_rat.call("get_entity_id"))
			if _lower_deck_spark_rat != null and _lower_deck_spark_rat.has_method("get_entity_id")
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pressure_hazard_present": _lower_deck_steam_vent != null,
		"pressure_hazard_active": _is_hazard_contact_active(_lower_deck_steam_vent),
		"pressure_hazard_id": String(_get_hazard_id(_lower_deck_steam_vent)),
		"pressure_hazard_damage": _get_hazard_damage(_lower_deck_steam_vent),
		"pressure_hazard_cooldown_sec": _get_hazard_cooldown_sec(_lower_deck_steam_vent),
		"cache_present": _lower_deck_reward_cache != null,
		"cache_visible": (
			_lower_deck_reward_cache.visible
			if _lower_deck_reward_cache != null
			else false
		),
		"cache_available": (
			bool(_lower_deck_reward_cache.call("is_available"))
			if (
				_lower_deck_reward_cache != null
				and _lower_deck_reward_cache.has_method("is_available")
			)
			else false
		),
		"cache_claim_available": (
			bool(_lower_deck_reward_cache.call("is_claim_available"))
			if (
				_lower_deck_reward_cache != null
				and _lower_deck_reward_cache.has_method("is_claim_available")
			)
			else false
		),
		"cache_claimed": _lower_deck_reward_cache_claimed,
		"cache_id": (
			String(_lower_deck_reward_cache.call("get_cache_id"))
			if (
				_lower_deck_reward_cache != null
				and _lower_deck_reward_cache.has_method("get_cache_id")
			)
			else ""
		),
		"cache_texture_path": (
			String(_lower_deck_reward_cache.call("get_visual_texture_path"))
			if (
				_lower_deck_reward_cache != null
				and _lower_deck_reward_cache.has_method("get_visual_texture_path")
			)
			else ""
		),
		"cache_position": (
			(_lower_deck_reward_cache as Node2D).global_position
			if _lower_deck_reward_cache != null and _lower_deck_reward_cache is Node2D
			else Vector2.ZERO
		),
		"cache_prompt_text": _get_lower_deck_reward_cache_prompt_text(),
		"last_reward": _last_lower_deck_reward_cache_reward.duplicate(true),
		"last_claim_feedback": _last_lower_deck_reward_cache_claim_feedback.duplicate(true),
	}


## Returns deterministic lower-deck parry-laser gate diagnostics.
func get_factory_lower_deck_parry_gate_diagnostics() -> Dictionary:
	var gate_position: Vector2 = (
		(_lower_deck_parry_gate as Node2D).global_position
		if _lower_deck_parry_gate != null and _lower_deck_parry_gate is Node2D
		else Vector2.ZERO
	)
	return {
		"present": _lower_deck_parry_gate != null,
		"available": _is_lower_deck_parry_gate_available(),
		"unlocked": _lower_deck_parry_gate_unlocked,
		"gate_id": _get_lower_deck_parry_gate_id(),
		"required_ability": _get_lower_deck_parry_gate_required_ability(),
		"gate_state": _get_lower_deck_parry_gate_state(),
		"collision_blocking": _is_lower_deck_parry_gate_collision_blocking(),
		"visual_texture_path": _get_lower_deck_parry_gate_visual_texture_path(),
		"prompt_text": _get_lower_deck_parry_gate_prompt_text(),
		"position": gate_position,
		"visible": _lower_deck_parry_gate.visible if _lower_deck_parry_gate != null else false,
		"provider_in_range": (
			bool(_lower_deck_parry_gate.call("is_provider_in_unlock_range"))
			if (
				_lower_deck_parry_gate != null
				and _lower_deck_parry_gate.has_method("is_provider_in_unlock_range")
			)
			else false
		),
	}


## Returns deterministic lower-deck exit ambush diagnostics.
func get_factory_lower_deck_exit_ambush_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_exit_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_exit_spark_rat != null
		else null
	)
	return {
		"present": _lower_deck_exit_spark_rat != null,
		"available": _lower_deck_reward_cache_claimed and not _lower_deck_exit_ambush_defeated,
		"active": _is_lower_deck_exit_ambush_active(),
		"defeated": _lower_deck_exit_ambush_defeated,
		"gate_unlocked": _lower_deck_parry_gate_unlocked,
		"enemy_visible": (
			_lower_deck_exit_spark_rat.visible if _lower_deck_exit_spark_rat != null else false
		),
		"enemy_has_target": _does_lower_deck_exit_spark_rat_have_target(),
		"enemy_physics_enabled": (
			_lower_deck_exit_spark_rat.is_physics_processing()
			if _lower_deck_exit_spark_rat != null
			else false
		),
		"enemy_process_enabled": (
			_lower_deck_exit_spark_rat.is_processing()
			if _lower_deck_exit_spark_rat != null
			else false
		),
		"entity_id": (
			int(_lower_deck_exit_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_exit_spark_rat != null
				and _lower_deck_exit_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_exit_ambush_pacing_diagnostics(),
		"position": (
			_lower_deck_exit_spark_rat.global_position
			if _lower_deck_exit_spark_rat != null
			else Vector2.ZERO
		),
	}


## Returns deterministic lower-deck shortcut seal diagnostics.
func get_factory_lower_deck_shortcut_seal_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_shortcut_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_shortcut_spark_rat != null
		else null
	)
	return {
		"present": _lower_deck_shortcut_spark_rat != null and _lower_deck_shortcut_seal != null,
		"available": _is_lower_deck_shortcut_available(),
		"active": _is_lower_deck_shortcut_active(),
		"guard_defeated": _lower_deck_shortcut_guard_defeated,
		"unlocked": _lower_deck_shortcut_unlocked,
		"activation_x": FACTORY_LOWER_DECK_SHORTCUT_ACTIVATION_X,
		"guard_visible": (
			_lower_deck_shortcut_spark_rat.visible
			if _lower_deck_shortcut_spark_rat != null
			else false
		),
		"guard_has_target": _does_lower_deck_shortcut_spark_rat_have_target(),
		"guard_physics_enabled": (
			_lower_deck_shortcut_spark_rat.is_physics_processing()
			if _lower_deck_shortcut_spark_rat != null
			else false
		),
		"guard_process_enabled": (
			_lower_deck_shortcut_spark_rat.is_processing()
			if _lower_deck_shortcut_spark_rat != null
			else false
		),
		"guard_entity_id": (
			int(_lower_deck_shortcut_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_shortcut_spark_rat != null
				and _lower_deck_shortcut_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"guard_sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"guard_animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_shortcut_pacing_diagnostics(),
		"seal_id": _get_lower_deck_shortcut_seal_id(),
		"seal_visible": (
			_lower_deck_shortcut_seal.visible
			if _lower_deck_shortcut_seal != null
			else false
		),
		"seal_unlockable": _is_lower_deck_shortcut_seal_unlockable(),
		"seal_activated": _is_lower_deck_shortcut_seal_activated(),
		"collision_blocking": _is_lower_deck_shortcut_collision_blocking(),
		"seal_prompt_text": _get_lower_deck_shortcut_prompt_text(),
		"seal_texture_path": _get_lower_deck_shortcut_visual_texture_path(),
		"seal_position": _get_lower_deck_shortcut_position(),
		"guard_position": (
			_lower_deck_shortcut_spark_rat.global_position
			if _lower_deck_shortcut_spark_rat != null
			else Vector2.ZERO
		),
	}


## Returns deterministic shortcut payoff cache diagnostics for tests and MCP probes.
func get_factory_lower_deck_shortcut_reward_cache_diagnostics() -> Dictionary:
	return {
		"present": _lower_deck_shortcut_reward_cache != null,
		"visible": (
			_lower_deck_shortcut_reward_cache.visible
			if _lower_deck_shortcut_reward_cache != null
			else false
		),
		"cache_id": (
			String(_lower_deck_shortcut_reward_cache.call("get_cache_id"))
			if (
				_lower_deck_shortcut_reward_cache != null
				and _lower_deck_shortcut_reward_cache.has_method("get_cache_id")
			)
			else ""
		),
		"texture_path": (
			String(_lower_deck_shortcut_reward_cache.call("get_visual_texture_path"))
			if (
				_lower_deck_shortcut_reward_cache != null
				and _lower_deck_shortcut_reward_cache.has_method("get_visual_texture_path")
			)
			else ""
		),
		"available": (
			bool(_lower_deck_shortcut_reward_cache.call("is_available"))
			if (
				_lower_deck_shortcut_reward_cache != null
				and _lower_deck_shortcut_reward_cache.has_method("is_available")
			)
			else false
		),
		"claim_available": (
			bool(_lower_deck_shortcut_reward_cache.call("is_claim_available"))
			if (
				_lower_deck_shortcut_reward_cache != null
				and _lower_deck_shortcut_reward_cache.has_method("is_claim_available")
			)
			else false
		),
		"claimed": _lower_deck_shortcut_reward_cache_claimed,
		"prompt_text": _get_lower_deck_shortcut_reward_cache_prompt_text(),
		"shortcut_unlocked": _lower_deck_shortcut_unlocked,
		"shortcut_guard_defeated": _lower_deck_shortcut_guard_defeated,
		"position": (
			(_lower_deck_shortcut_reward_cache as Node2D).global_position
			if (
				_lower_deck_shortcut_reward_cache != null
				and _lower_deck_shortcut_reward_cache is Node2D
			)
			else Vector2.ZERO
		),
		"last_reward": _last_lower_deck_shortcut_reward_cache_reward.duplicate(true),
		"last_claim_feedback": (
			_last_lower_deck_shortcut_reward_cache_claim_feedback.duplicate(true)
		),
	}


## Returns deterministic shortcut pursuer diagnostics for tests and MCP probes.
func get_factory_lower_deck_shortcut_pursuer_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_shortcut_pursuer_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_shortcut_pursuer_spark_rat != null
		else null
	)
	return {
		"present": _lower_deck_shortcut_pursuer_spark_rat != null,
		"available": _is_lower_deck_shortcut_pursuer_available(),
		"active": _is_lower_deck_shortcut_pursuer_active(),
		"defeated": _lower_deck_shortcut_pursuer_defeated,
		"shortcut_unlocked": _lower_deck_shortcut_unlocked,
		"shortcut_cache_claimed": _lower_deck_shortcut_reward_cache_claimed,
		"activation_x": FACTORY_LOWER_DECK_SHORTCUT_PURSUER_ACTIVATION_X,
		"enemy_visible": (
			_lower_deck_shortcut_pursuer_spark_rat.visible
			if _lower_deck_shortcut_pursuer_spark_rat != null
			else false
		),
		"enemy_has_target": _does_lower_deck_shortcut_pursuer_have_target(),
		"enemy_physics_enabled": (
			_lower_deck_shortcut_pursuer_spark_rat.is_physics_processing()
			if _lower_deck_shortcut_pursuer_spark_rat != null
			else false
		),
		"enemy_process_enabled": (
			_lower_deck_shortcut_pursuer_spark_rat.is_processing()
			if _lower_deck_shortcut_pursuer_spark_rat != null
			else false
		),
		"entity_id": (
			int(_lower_deck_shortcut_pursuer_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_shortcut_pursuer_spark_rat != null
				and _lower_deck_shortcut_pursuer_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_shortcut_pursuer_pacing_diagnostics(),
		"position": (
			_lower_deck_shortcut_pursuer_spark_rat.global_position
			if _lower_deck_shortcut_pursuer_spark_rat != null
			else Vector2.ZERO
		),
	}


## Returns deterministic pressure valve diagnostics for tests and MCP probes.
func get_factory_lower_deck_pressure_valve_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_pressure_guard_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_pressure_guard_spark_rat != null
		else null
	)
	return {
		"present": (
			_lower_deck_pressure_guard_spark_rat != null
			and _lower_deck_pressure_valve != null
		),
		"available": _is_lower_deck_pressure_guard_available(),
		"guard_active": _is_lower_deck_pressure_guard_active(),
		"guard_defeated": _lower_deck_pressure_guard_defeated,
		"valve_available": _is_lower_deck_pressure_valve_available(),
		"valve_opened": _lower_deck_pressure_valve_opened,
		"shortcut_pursuer_defeated": _lower_deck_shortcut_pursuer_defeated,
		"activation_x": FACTORY_LOWER_DECK_PRESSURE_VALVE_ACTIVATION_X,
		"guard_visible": (
			_lower_deck_pressure_guard_spark_rat.visible
			if _lower_deck_pressure_guard_spark_rat != null
			else false
		),
		"guard_has_target": _does_lower_deck_pressure_guard_have_target(),
		"guard_physics_enabled": (
			_lower_deck_pressure_guard_spark_rat.is_physics_processing()
			if _lower_deck_pressure_guard_spark_rat != null
			else false
		),
		"guard_process_enabled": (
			_lower_deck_pressure_guard_spark_rat.is_processing()
			if _lower_deck_pressure_guard_spark_rat != null
			else false
		),
		"guard_entity_id": (
			int(_lower_deck_pressure_guard_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_pressure_guard_spark_rat != null
				and _lower_deck_pressure_guard_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"guard_sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"guard_animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_pressure_guard_pacing_diagnostics(),
		"valve_id": _get_lower_deck_pressure_valve_id(),
		"valve_visible": (
			_lower_deck_pressure_valve.visible
			if _lower_deck_pressure_valve != null
			else false
		),
		"valve_prompt_text": _get_lower_deck_pressure_valve_prompt_text(),
		"valve_texture_path": _get_lower_deck_pressure_valve_visual_texture_path(),
		"valve_position": _get_lower_deck_pressure_valve_position(),
		"guard_position": (
			_lower_deck_pressure_guard_spark_rat.global_position
			if _lower_deck_pressure_guard_spark_rat != null
			else Vector2.ZERO
		),
	}


## Returns deterministic steam sluice ambush diagnostics for tests and MCP probes.
func get_factory_lower_deck_steam_sluice_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = (
		_lower_deck_steam_sluice_spark_rat.get_node_or_null("Sprite") as AnimatedSprite2D
		if _lower_deck_steam_sluice_spark_rat != null
		else null
	)
	return {
		"present": (
			_lower_deck_steam_sluice_spark_rat != null
			and _lower_deck_steam_sluice_hazard != null
		),
		"available": _is_lower_deck_steam_sluice_available(),
		"active": _is_lower_deck_steam_sluice_active(),
		"defeated": _lower_deck_steam_sluice_defeated,
		"pressure_valve_opened": _lower_deck_pressure_valve_opened,
		"activation_x": FACTORY_LOWER_DECK_STEAM_SLUICE_ACTIVATION_X,
		"enemy_visible": (
			_lower_deck_steam_sluice_spark_rat.visible
			if _lower_deck_steam_sluice_spark_rat != null
			else false
		),
		"enemy_has_target": _does_lower_deck_steam_sluice_have_target(),
		"enemy_physics_enabled": (
			_lower_deck_steam_sluice_spark_rat.is_physics_processing()
			if _lower_deck_steam_sluice_spark_rat != null
			else false
		),
		"enemy_process_enabled": (
			_lower_deck_steam_sluice_spark_rat.is_processing()
			if _lower_deck_steam_sluice_spark_rat != null
			else false
		),
		"entity_id": (
			int(_lower_deck_steam_sluice_spark_rat.call("get_entity_id"))
			if (
				_lower_deck_steam_sluice_spark_rat != null
				and _lower_deck_steam_sluice_spark_rat.has_method("get_entity_id")
			)
			else 0
		),
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"pacing": _get_lower_deck_steam_sluice_pacing_diagnostics(),
		"hazard_present": _lower_deck_steam_sluice_hazard != null,
		"hazard_active": _is_hazard_contact_active(_lower_deck_steam_sluice_hazard),
		"hazard_visible": (
			_lower_deck_steam_sluice_hazard.visible
			if _lower_deck_steam_sluice_hazard != null
			else false
		),
		"hazard_id": String(_get_hazard_id(_lower_deck_steam_sluice_hazard)),
		"hazard_damage": _get_hazard_damage(_lower_deck_steam_sluice_hazard),
		"hazard_cooldown_sec": _get_hazard_cooldown_sec(_lower_deck_steam_sluice_hazard),
		"hazard_layer": (
			_lower_deck_steam_sluice_hazard.collision_layer
			if _lower_deck_steam_sluice_hazard != null
			else 0
		),
		"hazard_mask": (
			_lower_deck_steam_sluice_hazard.collision_mask
			if _lower_deck_steam_sluice_hazard != null
			else 0
		),
		"hazard_texture_path": (
			String(_lower_deck_steam_sluice_hazard.call("get_visual_texture_path"))
			if (
				_lower_deck_steam_sluice_hazard != null
				and _lower_deck_steam_sluice_hazard.has_method("get_visual_texture_path")
			)
			else ""
		),
		"enemy_position": (
			_lower_deck_steam_sluice_spark_rat.global_position
			if _lower_deck_steam_sluice_spark_rat != null
			else Vector2.ZERO
		),
		"hazard_position": (
			_lower_deck_steam_sluice_hazard.global_position
			if _lower_deck_steam_sluice_hazard != null
			else Vector2.ZERO
		),
	}


## Returns visual defeat burst diagnostics for tests and MCP probes.
func get_factory_checkpoint_overdrive_defeat_burst_diagnostics() -> Dictionary:
	return {
		"present": (
			_checkpoint_overdrive_left_defeat_burst != null
			and _checkpoint_overdrive_right_defeat_burst != null
		),
		"texture_path": _get_checkpoint_overdrive_defeat_burst_texture_path(),
		"last_side": String(_last_checkpoint_overdrive_defeat_burst_side),
		"left_visible": (
			_checkpoint_overdrive_left_defeat_burst.visible
			if _checkpoint_overdrive_left_defeat_burst != null
			else false
		),
		"right_visible": (
			_checkpoint_overdrive_right_defeat_burst.visible
			if _checkpoint_overdrive_right_defeat_burst != null
			else false
		),
		"left_position": (
			_checkpoint_overdrive_left_defeat_burst.global_position
			if _checkpoint_overdrive_left_defeat_burst != null
			else Vector2.ZERO
		),
		"right_position": (
			_checkpoint_overdrive_right_defeat_burst.global_position
			if _checkpoint_overdrive_right_defeat_burst != null
			else Vector2.ZERO
		),
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


## Returns deterministic checkpoint-overdrive reward cache diagnostics.
func get_factory_checkpoint_overdrive_reward_cache_diagnostics() -> Dictionary:
	return {
		"present": _checkpoint_overdrive_reward_cache != null,
		"visible": (
			_checkpoint_overdrive_reward_cache.visible
			if _checkpoint_overdrive_reward_cache != null
			else false
		),
		"cache_id": (
			String(_checkpoint_overdrive_reward_cache.call("get_cache_id"))
			if (
				_checkpoint_overdrive_reward_cache != null
				and _checkpoint_overdrive_reward_cache.has_method("get_cache_id")
			)
			else ""
		),
		"texture_path": (
			String(_checkpoint_overdrive_reward_cache.call("get_visual_texture_path"))
			if (
				_checkpoint_overdrive_reward_cache != null
				and _checkpoint_overdrive_reward_cache.has_method("get_visual_texture_path")
			)
			else ""
		),
		"available": (
			bool(_checkpoint_overdrive_reward_cache.call("is_available"))
			if (
				_checkpoint_overdrive_reward_cache != null
				and _checkpoint_overdrive_reward_cache.has_method("is_available")
			)
			else false
		),
		"claim_available": (
			bool(_checkpoint_overdrive_reward_cache.call("is_claim_available"))
			if (
				_checkpoint_overdrive_reward_cache != null
				and _checkpoint_overdrive_reward_cache.has_method("is_claim_available")
			)
			else false
		),
		"claimed": _checkpoint_overdrive_reward_cache_claimed,
		"prompt_text": _get_checkpoint_overdrive_reward_cache_prompt_text(),
		"overdrive_duo_activated": _checkpoint_overdrive_duo_activated,
		"overdrive_duo_cleared": _is_checkpoint_overdrive_duo_cleared(),
		"position": (
			(_checkpoint_overdrive_reward_cache as Node2D).global_position
			if (
				_checkpoint_overdrive_reward_cache != null
				and _checkpoint_overdrive_reward_cache is Node2D
			)
			else Vector2.ZERO
		),
		"last_reward": _last_checkpoint_overdrive_reward_cache_reward.duplicate(true),
		"last_claim_feedback": (
			_last_checkpoint_overdrive_reward_cache_claim_feedback.duplicate(true)
		),
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
		"checkpoint_forward_patrol_activated": _checkpoint_forward_patrol_activated,
		"checkpoint_forward_patrol_defeated": _checkpoint_forward_patrol_defeated,
		"checkpoint_rear_ambush_activated": _checkpoint_rear_ambush_activated,
		"checkpoint_rear_ambush_defeated": _checkpoint_rear_ambush_defeated,
		"checkpoint_overdrive_duo_activated": _checkpoint_overdrive_duo_activated,
		"checkpoint_overdrive_left_defeated": _checkpoint_overdrive_left_defeated,
		"checkpoint_overdrive_right_defeated": _checkpoint_overdrive_right_defeated,
		"checkpoint_overdrive_duo_cleared": _is_checkpoint_overdrive_duo_cleared(),
		"lower_deck_skirmish_activated": _lower_deck_skirmish_activated,
		"lower_deck_skirmish_defeated": _lower_deck_skirmish_defeated,
		"lower_deck_parry_gate_unlocked": _lower_deck_parry_gate_unlocked,
		"lower_deck_exit_ambush_activated": _lower_deck_exit_ambush_activated,
		"lower_deck_exit_ambush_defeated": _lower_deck_exit_ambush_defeated,
		"lower_deck_shortcut_activated": _lower_deck_shortcut_activated,
		"lower_deck_shortcut_guard_defeated": _lower_deck_shortcut_guard_defeated,
		"lower_deck_shortcut_unlocked": _lower_deck_shortcut_unlocked,
		"lower_deck_pressure_valve_opened": _lower_deck_pressure_valve_opened,
		"lower_deck_steam_sluice_activated": _lower_deck_steam_sluice_activated,
		"lower_deck_steam_sluice_defeated": _lower_deck_steam_sluice_defeated,
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
		"forward_patrol_active": _is_checkpoint_forward_patrol_blocking_service_lift(),
		"rear_ambush_active": _is_checkpoint_rear_ambush_blocking_service_lift(),
		"overdrive_duo_active": _is_checkpoint_overdrive_duo_blocking_service_lift(),
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
		"checkpoint_forward_patrol": get_factory_checkpoint_forward_patrol_diagnostics(),
		"checkpoint_rear_ambush": get_factory_checkpoint_rear_ambush_diagnostics(),
		"checkpoint_overdrive_duo": get_factory_checkpoint_overdrive_duo_diagnostics(),
			"lower_deck_skirmish": get_factory_lower_deck_skirmish_diagnostics(),
			"lower_deck_parry_gate": get_factory_lower_deck_parry_gate_diagnostics(),
			"lower_deck_exit_ambush": get_factory_lower_deck_exit_ambush_diagnostics(),
			"lower_deck_shortcut_seal": get_factory_lower_deck_shortcut_seal_diagnostics(),
			"lower_deck_shortcut_reward_cache": (
				get_factory_lower_deck_shortcut_reward_cache_diagnostics()
			),
			"lower_deck_shortcut_pursuer": (
				get_factory_lower_deck_shortcut_pursuer_diagnostics()
			),
			"lower_deck_pressure_valve": get_factory_lower_deck_pressure_valve_diagnostics(),
			"lower_deck_steam_sluice": get_factory_lower_deck_steam_sluice_diagnostics(),
			"return_patrol_reward_cache": get_factory_return_patrol_reward_cache_diagnostics(),
		"checkpoint_overdrive_reward_cache": (
			get_factory_checkpoint_overdrive_reward_cache_diagnostics()
		),
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
	if spawn_point == FACTORY_RETURN_CHECKPOINT_SPAWN_POINT:
		_grant_factory_hazard_respawn_grace()
	if not _move_player_to_spawn_point(spawn_point):
		return false
	if spawn_point == FACTORY_RETURN_CHECKPOINT_SPAWN_POINT:
		_factory_return_checkpoint_spawn_snap_frames = FACTORY_RETURN_CHECKPOINT_SPAWN_SNAP_FRAMES
		_set_player_physics_pinned_for_return_checkpoint(true)
		_update_route_label(FACTORY_RETURN_CHECKPOINT_RESPAWN_LABEL)
	else:
		_factory_return_checkpoint_spawn_snap_frames = 0
		_set_player_physics_pinned_for_return_checkpoint(false)
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
	if _player is CharacterBody2D:
		(_player as CharacterBody2D).velocity = Vector2.ZERO
	return true


func _snap_return_checkpoint_spawn_if_needed() -> void:
	if _factory_return_checkpoint_spawn_snap_frames <= 0:
		return
	_factory_return_checkpoint_spawn_snap_frames -= 1
	_move_player_to_spawn_point(FACTORY_RETURN_CHECKPOINT_SPAWN_POINT)
	if _factory_return_checkpoint_spawn_snap_frames <= 0:
		_set_player_physics_pinned_for_return_checkpoint(false)


func _set_player_physics_pinned_for_return_checkpoint(pinned: bool) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	_player.set_physics_process(not pinned)


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
	_bind_factory_guard(
		_checkpoint_forward_spark_rat,
		&"old_factory_checkpoint_forward_patrol",
		FACTORY_CHECKPOINT_FORWARD_SPARK_RAT_ENTITY_ID,
		&"factory_checkpoint_forward_spark_rat",
		_on_factory_checkpoint_forward_spark_rat_defeated
	)
	_bind_factory_guard(
		_checkpoint_rear_spark_rat,
		&"old_factory_checkpoint_rear_ambush",
		FACTORY_CHECKPOINT_REAR_SPARK_RAT_ENTITY_ID,
		&"factory_checkpoint_rear_spark_rat",
		_on_factory_checkpoint_rear_spark_rat_defeated
	)
	_bind_factory_guard(
		_checkpoint_overdrive_left_spark_rat,
		&"old_factory_checkpoint_overdrive_duo",
		FACTORY_CHECKPOINT_OVERDRIVE_LEFT_SPARK_RAT_ENTITY_ID,
		&"factory_checkpoint_overdrive_spark_rat_left",
		_on_factory_checkpoint_overdrive_left_spark_rat_defeated
	)
	_bind_factory_guard(
		_checkpoint_overdrive_right_spark_rat,
		&"old_factory_checkpoint_overdrive_duo",
		FACTORY_CHECKPOINT_OVERDRIVE_RIGHT_SPARK_RAT_ENTITY_ID,
		&"factory_checkpoint_overdrive_spark_rat_right",
		_on_factory_checkpoint_overdrive_right_spark_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_spark_rat,
		&"old_factory_lower_deck_skirmish",
		FACTORY_LOWER_DECK_SPARK_RAT_ENTITY_ID,
		&"factory_lower_deck_spark_rat",
		_on_factory_lower_deck_spark_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_exit_spark_rat,
		&"old_factory_lower_deck_exit_ambush",
		FACTORY_LOWER_DECK_EXIT_SPARK_RAT_ENTITY_ID,
		&"factory_lower_deck_exit_spark_rat",
		_on_factory_lower_deck_exit_spark_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_shortcut_spark_rat,
		&"old_factory_lower_deck_shortcut",
		FACTORY_LOWER_DECK_SHORTCUT_SPARK_RAT_ENTITY_ID,
		&"factory_lower_deck_shortcut_spark_rat",
		_on_factory_lower_deck_shortcut_spark_rat_defeated
	)
	_bind_factory_guard(
		_lower_deck_shortcut_pursuer_spark_rat,
		&"old_factory_lower_deck_shortcut_pursuer",
		FACTORY_LOWER_DECK_SHORTCUT_PURSUER_ENTITY_ID,
		&"factory_lower_deck_shortcut_pursuer_spark_rat",
		_on_factory_lower_deck_shortcut_pursuer_defeated
	)
	_bind_factory_guard(
		_lower_deck_pressure_guard_spark_rat,
		&"old_factory_lower_deck_pressure_valve",
		FACTORY_LOWER_DECK_PRESSURE_GUARD_ENTITY_ID,
		&"factory_lower_deck_pressure_valve_spark_rat",
		_on_factory_lower_deck_pressure_guard_defeated
	)
	_bind_factory_guard(
		_lower_deck_steam_sluice_spark_rat,
		&"old_factory_lower_deck_steam_sluice",
		FACTORY_LOWER_DECK_STEAM_SLUICE_ENTITY_ID,
		&"factory_lower_deck_steam_sluice_spark_rat",
		_on_factory_lower_deck_steam_sluice_defeated
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


func _setup_factory_checkpoint_overdrive_reward_cache() -> void:
	_sync_checkpoint_overdrive_reward_cache_state()
	if (
		_checkpoint_overdrive_reward_cache == null
		or not _checkpoint_overdrive_reward_cache.has_signal("cache_claimed")
	):
		return
	var claimed_signal: Signal = _checkpoint_overdrive_reward_cache.get("cache_claimed")
	if not claimed_signal.is_connected(_on_factory_checkpoint_overdrive_reward_cache_claimed):
		claimed_signal.connect(_on_factory_checkpoint_overdrive_reward_cache_claimed)


func _setup_factory_lower_deck_reward_cache() -> void:
	_sync_lower_deck_reward_cache_state()
	if (
		_lower_deck_reward_cache == null
		or not _lower_deck_reward_cache.has_signal("cache_claimed")
	):
		return
	var claimed_signal: Signal = _lower_deck_reward_cache.get("cache_claimed")
	if not claimed_signal.is_connected(_on_factory_lower_deck_reward_cache_claimed):
		claimed_signal.connect(_on_factory_lower_deck_reward_cache_claimed)


func _setup_factory_lower_deck_shortcut_reward_cache() -> void:
	_sync_lower_deck_shortcut_reward_cache_state()
	if (
		_lower_deck_shortcut_reward_cache == null
		or not _lower_deck_shortcut_reward_cache.has_signal("cache_claimed")
	):
		return
	var claimed_signal: Signal = _lower_deck_shortcut_reward_cache.get("cache_claimed")
	if not claimed_signal.is_connected(_on_factory_lower_deck_shortcut_reward_cache_claimed):
		claimed_signal.connect(_on_factory_lower_deck_shortcut_reward_cache_claimed)


func _setup_factory_lower_deck_parry_gate() -> void:
	_sync_lower_deck_parry_gate_state()
	if _lower_deck_parry_gate == null:
		return
	if _lower_deck_parry_gate.has_method("set_ability_provider"):
		_lower_deck_parry_gate.call("set_ability_provider", _player)
	if not _lower_deck_parry_gate.has_signal("gate_state_changed"):
		return
	var gate_signal: Signal = _lower_deck_parry_gate.get("gate_state_changed")
	if not gate_signal.is_connected(_on_factory_lower_deck_parry_gate_state_changed):
		gate_signal.connect(_on_factory_lower_deck_parry_gate_state_changed)


func _setup_factory_lower_deck_shortcut_seal() -> void:
	_sync_lower_deck_shortcut_state()
	if _lower_deck_shortcut_seal == null or not _lower_deck_shortcut_seal.has_signal(
		"endpoint_activated"
	):
		return
	var endpoint_signal: Signal = _lower_deck_shortcut_seal.get("endpoint_activated")
	if not endpoint_signal.is_connected(_on_factory_lower_deck_shortcut_seal_activated):
		endpoint_signal.connect(_on_factory_lower_deck_shortcut_seal_activated)


func _setup_factory_lower_deck_pressure_valve() -> void:
	_sync_lower_deck_pressure_valve_state()
	if _lower_deck_pressure_valve == null or not _lower_deck_pressure_valve.has_signal(
		"endpoint_activated"
	):
		return
	var endpoint_signal: Signal = _lower_deck_pressure_valve.get("endpoint_activated")
	if not endpoint_signal.is_connected(_on_factory_lower_deck_pressure_valve_activated):
		endpoint_signal.connect(_on_factory_lower_deck_pressure_valve_activated)


func _setup_factory_return_checkpoint() -> void:
	_sync_return_checkpoint_state()
	if _return_checkpoint == null or not _return_checkpoint.has_signal("savepoint_activated"):
		return
	var activated_signal: Signal = _return_checkpoint.get("savepoint_activated")
	if not activated_signal.is_connected(_on_factory_return_checkpoint_activated):
		activated_signal.connect(_on_factory_return_checkpoint_activated)


func _setup_factory_respawn_flow() -> void:
	if _factory_game_flow == null or not is_instance_valid(_factory_game_flow):
		var existing_flow := get_node_or_null("FactoryGameFlowController") as GameFlowController
		if existing_flow != null:
			_factory_game_flow = existing_flow
		else:
			_factory_game_flow = GAME_FLOW_SCRIPT.new() as GameFlowController
			_factory_game_flow.name = "FactoryGameFlowController"
			add_child(_factory_game_flow)

	_factory_game_flow.set_savepoint_adapter(self)
	_factory_game_flow.configure_clan_base_respawn(
		FACTORY_SERVICE_LIFT_EXIT_SCENE_ID,
		FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT,
		_spawn.global_position if _spawn != null else Vector2.ZERO
	)
	_factory_game_flow.start_encounter(_spawn.global_position if _spawn != null else Vector2.ZERO)
	_configure_factory_respawn_scene_transition()

	var respawn_callback := Callable(self, "_on_factory_respawn_requested")
	if not _factory_game_flow.respawn_requested.is_connected(respawn_callback):
		_factory_game_flow.respawn_requested.connect(respawn_callback)

	var player_death_callback := Callable(self, "_on_factory_player_died")
	if (
		_player != null
		and _player.has_signal("player_died")
		and not _player.is_connected("player_died", player_death_callback)
	):
		_player.connect("player_died", player_death_callback)


func _configure_factory_respawn_scene_transition() -> void:
	if _factory_game_flow == null or not is_instance_valid(_factory_game_flow):
		return
	_factory_game_flow.set_scene_transition_adapter(_resolve_scene_manager_for_runtime())


func _sync_factory_player_control_lock() -> void:
	if (
		_factory_game_flow == null
		or not is_instance_valid(_factory_game_flow)
		or _player == null
		or not is_instance_valid(_player)
		or not _player.has_method("set_control_locked")
	):
		return
	_player.call("set_control_locked", _factory_game_flow.is_player_control_locked())


func _setup_factory_hazards() -> void:
	_sync_checkpoint_steam_vent_state()
	_sync_lower_deck_pressure_hazard_state()
	for hazard: Area2D in _get_factory_hazards():
		var area_entered_callback := Callable(self, "_on_factory_hazard_area_entered").bind(hazard)
		if not hazard.area_entered.is_connected(area_entered_callback):
			hazard.area_entered.connect(area_entered_callback)
		var body_entered_callback := Callable(self, "_on_factory_hazard_body_entered").bind(hazard)
		if not hazard.body_entered.is_connected(body_entered_callback):
			hazard.body_entered.connect(body_entered_callback)


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
	_sync_checkpoint_forward_patrol_state()
	_sync_checkpoint_rear_ambush_state()
	_sync_checkpoint_overdrive_duo_state()
	_sync_lower_deck_skirmish_state()
	_sync_lower_deck_exit_ambush_state()
	_sync_lower_deck_shortcut_state()
	_sync_lower_deck_steam_sluice_state()


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


func _on_factory_checkpoint_forward_spark_rat_defeated() -> void:
	_checkpoint_forward_patrol_activated = true
	_checkpoint_forward_patrol_defeated = true
	_service_lift_activated = false
	_service_lift_exit_requested = false
	_last_service_lift_exit_request = {}
	_last_service_lift_exit_rejected_reason = &""
	_sync_checkpoint_forward_patrol_state()
	_sync_checkpoint_steam_vent_state()
	_sync_service_lift_state()
	_refresh_factory_route_objective()


func _on_factory_checkpoint_rear_spark_rat_defeated() -> void:
	_checkpoint_rear_ambush_activated = true
	_checkpoint_rear_ambush_defeated = true
	_service_lift_activated = false
	_service_lift_exit_requested = false
	_last_service_lift_exit_request = {}
	_last_service_lift_exit_rejected_reason = &""
	_sync_checkpoint_rear_ambush_state()
	_sync_checkpoint_overdrive_duo_state()
	_sync_service_lift_state()
	_refresh_factory_route_objective()


func _on_factory_checkpoint_overdrive_left_spark_rat_defeated() -> void:
	_show_checkpoint_overdrive_defeat_burst(
		&"left",
		_checkpoint_overdrive_left_spark_rat
	)
	_checkpoint_overdrive_duo_activated = true
	_checkpoint_overdrive_left_defeated = true
	_service_lift_activated = false
	_service_lift_exit_requested = false
	_last_service_lift_exit_request = {}
	_last_service_lift_exit_rejected_reason = &""
	_sync_checkpoint_overdrive_duo_state()
	_sync_checkpoint_overdrive_reward_cache_state()
	_sync_service_lift_state()
	_refresh_factory_route_objective()


func _on_factory_checkpoint_overdrive_right_spark_rat_defeated() -> void:
	_show_checkpoint_overdrive_defeat_burst(
		&"right",
		_checkpoint_overdrive_right_spark_rat
	)
	_checkpoint_overdrive_duo_activated = true
	_checkpoint_overdrive_right_defeated = true
	_service_lift_activated = false
	_service_lift_exit_requested = false
	_last_service_lift_exit_request = {}
	_last_service_lift_exit_rejected_reason = &""
	_sync_checkpoint_overdrive_duo_state()
	_sync_checkpoint_overdrive_reward_cache_state()
	_sync_service_lift_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_spark_rat_defeated() -> void:
	_lower_deck_skirmish_activated = true
	_lower_deck_skirmish_defeated = true
	_sync_lower_deck_skirmish_state()
	_sync_lower_deck_pressure_hazard_state()
	_sync_lower_deck_reward_cache_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_exit_spark_rat_defeated() -> void:
	_lower_deck_parry_gate_unlocked = true
	_lower_deck_exit_ambush_activated = true
	_lower_deck_exit_ambush_defeated = true
	_sync_lower_deck_parry_gate_state()
	_sync_lower_deck_exit_ambush_state()
	_sync_lower_deck_shortcut_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_shortcut_spark_rat_defeated() -> void:
	_lower_deck_shortcut_activated = true
	_lower_deck_shortcut_guard_defeated = true
	_sync_lower_deck_shortcut_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_shortcut_pursuer_defeated() -> void:
	_lower_deck_shortcut_pursuer_activated = true
	_lower_deck_shortcut_pursuer_defeated = true
	_sync_lower_deck_shortcut_pursuer_state()
	_sync_lower_deck_pressure_valve_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_pressure_guard_defeated() -> void:
	_lower_deck_pressure_guard_activated = true
	_lower_deck_pressure_guard_defeated = true
	_sync_lower_deck_pressure_valve_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_steam_sluice_defeated() -> void:
	_lower_deck_steam_sluice_activated = true
	_lower_deck_steam_sluice_defeated = true
	_sync_lower_deck_steam_sluice_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_parry_gate_state_changed(
	gate_id: StringName,
	gate_state: StringName
) -> void:
	if gate_id != FACTORY_LOWER_DECK_PARRY_GATE_ID or gate_state != &"unlocked":
		return
	_lower_deck_parry_gate_unlocked = true
	_sync_lower_deck_parry_gate_state()
	try_activate_factory_lower_deck_exit_ambush(_player)


func _on_factory_lower_deck_shortcut_seal_activated(endpoint_id: StringName) -> void:
	if endpoint_id != FACTORY_LOWER_DECK_SHORTCUT_SEAL_ID:
		return
	_lower_deck_shortcut_unlocked = true
	_sync_lower_deck_shortcut_state()
	_sync_lower_deck_shortcut_reward_cache_state()
	_refresh_factory_route_objective()


func _on_factory_lower_deck_pressure_valve_activated(endpoint_id: StringName) -> void:
	if endpoint_id != FACTORY_LOWER_DECK_PRESSURE_VALVE_ID:
		return
	_lower_deck_pressure_valve_opened = true
	_sync_lower_deck_pressure_valve_state()
	_sync_lower_deck_steam_sluice_state()
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


func _on_factory_checkpoint_overdrive_reward_cache_claimed(
	_cache_id: StringName,
	reward: Dictionary
) -> void:
	_checkpoint_overdrive_reward_cache_claimed = true
	_last_checkpoint_overdrive_reward_cache_reward = reward.duplicate(true)
	_record_checkpoint_overdrive_reward_cache_claim_feedback(
		_last_checkpoint_overdrive_reward_cache_reward,
		"Overdrive Cache Claimed"
	)


func _on_factory_lower_deck_reward_cache_claimed(
	_cache_id: StringName,
	reward: Dictionary
) -> void:
	_lower_deck_reward_cache_claimed = true
	_last_lower_deck_reward_cache_reward = reward.duplicate(true)
	_record_lower_deck_reward_cache_claim_feedback(
		_last_lower_deck_reward_cache_reward,
		"Lower Deck Cache Claimed"
	)
	_sync_lower_deck_parry_gate_state()


func _on_factory_lower_deck_shortcut_reward_cache_claimed(
	_cache_id: StringName,
	reward: Dictionary
) -> void:
	_lower_deck_shortcut_reward_cache_claimed = true
	_last_lower_deck_shortcut_reward_cache_reward = reward.duplicate(true)
	_record_lower_deck_shortcut_reward_cache_claim_feedback(
		_last_lower_deck_shortcut_reward_cache_reward,
		"Shortcut Cache Claimed"
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
	if _is_checkpoint_route_chain_started():
		_refresh_factory_route_objective()
	else:
		_update_route_label("Factory Savepoint Secured")


func _on_factory_player_died(_death_metadata: Dictionary) -> void:
	if _factory_game_flow == null or not is_instance_valid(_factory_game_flow):
		return
	_factory_game_flow.handle_player_death()
	_sync_factory_player_control_lock()


func _on_factory_respawn_requested(respawn_position: Vector2, revive_hp_percentage: float) -> void:
	_grant_factory_hazard_respawn_grace()
	if _player != null and is_instance_valid(_player) and _player.has_method("respawn_at"):
		_player.call("respawn_at", respawn_position, revive_hp_percentage)
	_sync_factory_player_control_lock()

	var selected_respawn_point: Dictionary = _factory_game_flow.get_last_selected_respawn_point()
	if String(selected_respawn_point.get("spawn_point", "")) == String(FACTORY_RETURN_CHECKPOINT_SPAWN_POINT):
		_update_route_label(FACTORY_RETURN_CHECKPOINT_RESPAWN_LABEL)
	_apply_current_scene_manager_spawn_point()


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


func _sync_checkpoint_forward_patrol_state() -> void:
	if _checkpoint_forward_spark_rat == null:
		return
	if (
		_checkpoint_forward_patrol_defeated
		or not _return_checkpoint_activated
		or not _checkpoint_forward_patrol_activated
	):
		_checkpoint_forward_spark_rat.visible = false
		_checkpoint_forward_spark_rat.set_physics_process(false)
		_checkpoint_forward_spark_rat.set_process(false)
		_checkpoint_forward_spark_rat.collision_layer = 0
		_checkpoint_forward_spark_rat.collision_mask = 0
		_set_checkpoint_forward_spark_rat_attack_target(null)
		return
	_checkpoint_forward_spark_rat.visible = true
	_checkpoint_forward_spark_rat.set_physics_process(true)
	_checkpoint_forward_spark_rat.set_process(true)
	_checkpoint_forward_spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
	_checkpoint_forward_spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
	_set_checkpoint_forward_spark_rat_attack_target(_player)


func _sync_checkpoint_rear_ambush_state() -> void:
	if _checkpoint_rear_spark_rat == null:
		return
	if (
		_checkpoint_rear_ambush_defeated
		or not _checkpoint_forward_patrol_defeated
		or not _checkpoint_rear_ambush_activated
	):
		_checkpoint_rear_spark_rat.visible = false
		_checkpoint_rear_spark_rat.set_physics_process(false)
		_checkpoint_rear_spark_rat.set_process(false)
		_checkpoint_rear_spark_rat.collision_layer = 0
		_checkpoint_rear_spark_rat.collision_mask = 0
		_set_checkpoint_rear_spark_rat_attack_target(null)
		return
	_checkpoint_rear_spark_rat.visible = true
	_checkpoint_rear_spark_rat.set_physics_process(true)
	_checkpoint_rear_spark_rat.set_process(true)
	_checkpoint_rear_spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
	_checkpoint_rear_spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
	_set_checkpoint_rear_spark_rat_attack_target(_player)


func _sync_checkpoint_overdrive_duo_state() -> void:
	_sync_checkpoint_overdrive_spark_rat_state(
		_checkpoint_overdrive_left_spark_rat,
		_checkpoint_overdrive_left_defeated
	)
	_sync_checkpoint_overdrive_spark_rat_state(
		_checkpoint_overdrive_right_spark_rat,
		_checkpoint_overdrive_right_defeated
	)


func _sync_checkpoint_overdrive_spark_rat_state(
	spark_rat: Node2D,
	defeated: bool
) -> void:
	if spark_rat == null:
		return
	if (
		defeated
		or not _checkpoint_rear_ambush_defeated
		or not _checkpoint_overdrive_duo_activated
	):
		spark_rat.visible = false
		spark_rat.set_physics_process(false)
		spark_rat.set_process(false)
		spark_rat.collision_layer = 0
		spark_rat.collision_mask = 0
		if spark_rat.has_method("set_attack_target"):
			spark_rat.call("set_attack_target", null)
		return
	spark_rat.visible = true
	spark_rat.set_physics_process(true)
	spark_rat.set_process(true)
	spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
	spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
	if spark_rat.has_method("set_attack_target"):
		spark_rat.call("set_attack_target", _player)


func _sync_checkpoint_steam_vent_state() -> void:
	if _checkpoint_steam_vent == null:
		return
	var active: bool = _checkpoint_forward_patrol_defeated
	_checkpoint_steam_vent.visible = active
	_checkpoint_steam_vent.monitoring = active
	_checkpoint_steam_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if active else 0
	)
	_checkpoint_steam_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if active else 0
	)
	var collision_shape := (
		_checkpoint_steam_vent.get_node_or_null("CollisionShape2D")
		as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not active


func _sync_lower_deck_skirmish_state() -> void:
	if _lower_deck_spark_rat == null:
		return
	if (
		_lower_deck_skirmish_defeated
		or not _is_checkpoint_overdrive_duo_cleared()
		or not _lower_deck_skirmish_activated
	):
		_lower_deck_spark_rat.visible = false
		_lower_deck_spark_rat.set_physics_process(false)
		_lower_deck_spark_rat.set_process(false)
		_lower_deck_spark_rat.collision_layer = 0
		_lower_deck_spark_rat.collision_mask = 0
		_set_lower_deck_spark_rat_attack_target(null)
		return
	_lower_deck_spark_rat.visible = true
	_lower_deck_spark_rat.set_physics_process(true)
	_lower_deck_spark_rat.set_process(true)
	_lower_deck_spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
	_lower_deck_spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
	_set_lower_deck_spark_rat_attack_target(_player)


func _sync_lower_deck_pressure_hazard_state() -> void:
	if _lower_deck_steam_vent == null:
		return
	var active: bool = _is_lower_deck_skirmish_active()
	_lower_deck_steam_vent.visible = active
	_lower_deck_steam_vent.monitoring = active
	_lower_deck_steam_vent.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if active else 0
	)
	_lower_deck_steam_vent.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if active else 0
	)
	var collision_shape := (
		_lower_deck_steam_vent.get_node_or_null("CollisionShape2D")
		as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not active


func _sync_return_patrol_reward_cache_state() -> void:
	if _return_patrol_reward_cache == null:
		return
	_return_patrol_reward_cache.visible = _return_patrol_activated or _return_patrol_defeated
	if _return_patrol_reward_cache.has_method("set_available"):
		_return_patrol_reward_cache.call("set_available", _return_patrol_defeated)
	if _return_patrol_reward_cache.has_method("set_claimed"):
		_return_patrol_reward_cache.call("set_claimed", _return_patrol_reward_cache_claimed)


func _sync_checkpoint_overdrive_reward_cache_state() -> void:
	if _checkpoint_overdrive_reward_cache == null:
		return
	_checkpoint_overdrive_reward_cache.visible = (
		_checkpoint_overdrive_duo_activated
		or _is_checkpoint_overdrive_duo_cleared()
		or _checkpoint_overdrive_reward_cache_claimed
	)
	if _checkpoint_overdrive_reward_cache.has_method("set_available"):
		_checkpoint_overdrive_reward_cache.call(
			"set_available",
			_is_checkpoint_overdrive_duo_cleared()
		)
	if _checkpoint_overdrive_reward_cache.has_method("set_claimed"):
		_checkpoint_overdrive_reward_cache.call(
			"set_claimed",
			_checkpoint_overdrive_reward_cache_claimed
		)


func _sync_lower_deck_reward_cache_state() -> void:
	if _lower_deck_reward_cache == null:
		return
	_lower_deck_reward_cache.visible = (
		_lower_deck_skirmish_defeated
		or _lower_deck_reward_cache_claimed
	)
	if _lower_deck_reward_cache.has_method("set_available"):
		_lower_deck_reward_cache.call("set_available", _lower_deck_skirmish_defeated)
	if _lower_deck_reward_cache.has_method("set_claimed"):
		_lower_deck_reward_cache.call("set_claimed", _lower_deck_reward_cache_claimed)


func _sync_lower_deck_shortcut_reward_cache_state() -> void:
	if _lower_deck_shortcut_reward_cache == null:
		return
	_lower_deck_shortcut_reward_cache.visible = (
		_lower_deck_shortcut_unlocked
		or _lower_deck_shortcut_reward_cache_claimed
	)
	if _lower_deck_shortcut_reward_cache.has_method("set_available"):
		_lower_deck_shortcut_reward_cache.call(
			"set_available",
			_lower_deck_shortcut_unlocked
		)
	if _lower_deck_shortcut_reward_cache.has_method("set_claimed"):
		_lower_deck_shortcut_reward_cache.call(
			"set_claimed",
			_lower_deck_shortcut_reward_cache_claimed
		)


func _sync_lower_deck_shortcut_pursuer_state() -> void:
	if _lower_deck_shortcut_pursuer_spark_rat == null:
		return
	if not _is_lower_deck_shortcut_pursuer_active():
		_lower_deck_shortcut_pursuer_spark_rat.visible = false
		_lower_deck_shortcut_pursuer_spark_rat.set_physics_process(false)
		_lower_deck_shortcut_pursuer_spark_rat.set_process(false)
		_lower_deck_shortcut_pursuer_spark_rat.collision_layer = 0
		_lower_deck_shortcut_pursuer_spark_rat.collision_mask = 0
		_set_lower_deck_shortcut_pursuer_attack_target(null)
		return
	_lower_deck_shortcut_pursuer_spark_rat.visible = true
	_lower_deck_shortcut_pursuer_spark_rat.set_physics_process(true)
	_lower_deck_shortcut_pursuer_spark_rat.set_process(true)
	_lower_deck_shortcut_pursuer_spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
	_lower_deck_shortcut_pursuer_spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
	_set_lower_deck_shortcut_pursuer_attack_target(_player)


func _sync_lower_deck_pressure_valve_state() -> void:
	if _lower_deck_pressure_guard_spark_rat != null:
		if not _is_lower_deck_pressure_guard_active():
			_lower_deck_pressure_guard_spark_rat.visible = false
			_lower_deck_pressure_guard_spark_rat.set_physics_process(false)
			_lower_deck_pressure_guard_spark_rat.set_process(false)
			_lower_deck_pressure_guard_spark_rat.collision_layer = 0
			_lower_deck_pressure_guard_spark_rat.collision_mask = 0
			_set_lower_deck_pressure_guard_attack_target(null)
		else:
			_lower_deck_pressure_guard_spark_rat.visible = true
			_lower_deck_pressure_guard_spark_rat.set_physics_process(true)
			_lower_deck_pressure_guard_spark_rat.set_process(true)
			_lower_deck_pressure_guard_spark_rat.collision_layer = (
				FACTORY_RAT_MINION_COLLISION_LAYER
			)
			_lower_deck_pressure_guard_spark_rat.collision_mask = (
				FACTORY_RAT_MINION_COLLISION_MASK
			)
			_set_lower_deck_pressure_guard_attack_target(_player)
	if _lower_deck_pressure_valve == null:
		return
	var valve_visible: bool = (
		_lower_deck_shortcut_pursuer_defeated
		or _lower_deck_pressure_guard_defeated
		or _lower_deck_pressure_valve_opened
	)
	_lower_deck_pressure_valve.visible = valve_visible
	if _lower_deck_pressure_valve.has_method("set_available"):
		_lower_deck_pressure_valve.call(
			"set_available",
			_is_lower_deck_pressure_valve_available()
		)
	if _lower_deck_pressure_valve.has_method("set_activated"):
		_lower_deck_pressure_valve.call("set_activated", _lower_deck_pressure_valve_opened)


func _sync_lower_deck_steam_sluice_state() -> void:
	if _lower_deck_steam_sluice_spark_rat != null:
		if not _is_lower_deck_steam_sluice_active():
			_lower_deck_steam_sluice_spark_rat.visible = false
			_lower_deck_steam_sluice_spark_rat.set_physics_process(false)
			_lower_deck_steam_sluice_spark_rat.set_process(false)
			_lower_deck_steam_sluice_spark_rat.collision_layer = 0
			_lower_deck_steam_sluice_spark_rat.collision_mask = 0
			_set_lower_deck_steam_sluice_attack_target(null)
		else:
			_lower_deck_steam_sluice_spark_rat.visible = true
			_lower_deck_steam_sluice_spark_rat.set_physics_process(true)
			_lower_deck_steam_sluice_spark_rat.set_process(true)
			_lower_deck_steam_sluice_spark_rat.collision_layer = (
				FACTORY_RAT_MINION_COLLISION_LAYER
			)
			_lower_deck_steam_sluice_spark_rat.collision_mask = (
				FACTORY_RAT_MINION_COLLISION_MASK
			)
			_set_lower_deck_steam_sluice_attack_target(_player)
	if _lower_deck_steam_sluice_hazard == null:
		return
	var hazard_active: bool = _is_lower_deck_steam_sluice_active()
	_lower_deck_steam_sluice_hazard.visible = hazard_active
	_lower_deck_steam_sluice_hazard.monitoring = hazard_active
	_lower_deck_steam_sluice_hazard.collision_layer = (
		CollisionComponent.COLLISION_LAYER_ENVIRONMENT if hazard_active else 0
	)
	_lower_deck_steam_sluice_hazard.collision_mask = (
		CollisionComponent.COLLISION_MASK_ENVIRONMENT if hazard_active else 0
	)
	var collision_shape := (
		_lower_deck_steam_sluice_hazard.get_node_or_null("CollisionShape2D")
		as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.disabled = not hazard_active


func _sync_lower_deck_parry_gate_state() -> void:
	if _lower_deck_parry_gate == null:
		return
	var available: bool = _is_lower_deck_parry_gate_available()
	_lower_deck_parry_gate.visible = available or _lower_deck_parry_gate_unlocked
	if _lower_deck_parry_gate.has_method("set_gate_unlocked"):
		_lower_deck_parry_gate.call("set_gate_unlocked", _lower_deck_parry_gate_unlocked)
	if not available and not _lower_deck_parry_gate_unlocked:
		_set_lower_deck_parry_gate_collision_enabled(false)
	elif _lower_deck_parry_gate_unlocked:
		_set_lower_deck_parry_gate_collision_enabled(false)


func _sync_lower_deck_exit_ambush_state() -> void:
	if _lower_deck_exit_spark_rat == null:
		return
	if not _is_lower_deck_exit_ambush_active():
		_lower_deck_exit_spark_rat.visible = false
		_lower_deck_exit_spark_rat.set_physics_process(false)
		_lower_deck_exit_spark_rat.set_process(false)
		_lower_deck_exit_spark_rat.collision_layer = 0
		_lower_deck_exit_spark_rat.collision_mask = 0
		_set_lower_deck_exit_spark_rat_attack_target(null)
		return
	_lower_deck_exit_spark_rat.visible = true
	_lower_deck_exit_spark_rat.set_physics_process(true)
	_lower_deck_exit_spark_rat.set_process(true)
	_lower_deck_exit_spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
	_lower_deck_exit_spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
	_set_lower_deck_exit_spark_rat_attack_target(_player)


func _sync_lower_deck_shortcut_state() -> void:
	if _lower_deck_shortcut_spark_rat != null:
		if not _is_lower_deck_shortcut_active():
			_lower_deck_shortcut_spark_rat.visible = false
			_lower_deck_shortcut_spark_rat.set_physics_process(false)
			_lower_deck_shortcut_spark_rat.set_process(false)
			_lower_deck_shortcut_spark_rat.collision_layer = 0
			_lower_deck_shortcut_spark_rat.collision_mask = 0
			_set_lower_deck_shortcut_spark_rat_attack_target(null)
		else:
			_lower_deck_shortcut_spark_rat.visible = true
			_lower_deck_shortcut_spark_rat.set_physics_process(true)
			_lower_deck_shortcut_spark_rat.set_process(true)
			_lower_deck_shortcut_spark_rat.collision_layer = FACTORY_RAT_MINION_COLLISION_LAYER
			_lower_deck_shortcut_spark_rat.collision_mask = FACTORY_RAT_MINION_COLLISION_MASK
			_set_lower_deck_shortcut_spark_rat_attack_target(_player)
	if _lower_deck_shortcut_seal == null:
		return
	var seal_visible: bool = _lower_deck_exit_ambush_defeated or _lower_deck_shortcut_unlocked
	_lower_deck_shortcut_seal.visible = seal_visible
	if _lower_deck_shortcut_seal.has_method("set_available"):
		_lower_deck_shortcut_seal.call(
			"set_available",
			_is_lower_deck_shortcut_seal_unlockable()
		)
	if _lower_deck_shortcut_seal.has_method("set_activated"):
		_lower_deck_shortcut_seal.call("set_activated", _lower_deck_shortcut_unlocked)
	_set_lower_deck_shortcut_collision_enabled(not _lower_deck_shortcut_unlocked and seal_visible)


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
	if _service_lift.has_method("set"):
		if _is_checkpoint_overdrive_duo_blocking_service_lift():
			_service_lift.set("locked_prompt_text", "Clear overdrive duo")
		elif _is_checkpoint_rear_ambush_blocking_service_lift():
			_service_lift.set("locked_prompt_text", "Clear rear ambush")
		elif _is_checkpoint_forward_patrol_blocking_service_lift():
			_service_lift.set("locked_prompt_text", "Clear forward patrol")
		else:
			_service_lift.set("locked_prompt_text", "Clear patrol")
	if _service_lift.has_method("set_available"):
		_service_lift.call("set_available", (
			_spark_rat_defeated
			and not _is_return_patrol_blocking_service_lift()
			and not _is_checkpoint_forward_patrol_blocking_service_lift()
			and not _is_checkpoint_rear_ambush_blocking_service_lift()
			and not _is_checkpoint_overdrive_duo_blocking_service_lift()
		))
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
	if _checkpoint_forward_patrol_activated and not _checkpoint_forward_patrol_defeated:
		return FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_FORWARD_PATROL
	if _lower_deck_skirmish_activated and not _lower_deck_skirmish_defeated:
		return FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_SKIRMISH
	if _lower_deck_exit_ambush_activated and not _lower_deck_exit_ambush_defeated:
		return FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_EXIT_AMBUSH
	if _lower_deck_shortcut_activated and not _lower_deck_shortcut_guard_defeated:
		return FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_SHORTCUT_GUARD
	if _lower_deck_shortcut_guard_defeated and not _lower_deck_shortcut_unlocked:
		return FACTORY_OBJECTIVE_OPEN_LOWER_DECK_SHORTCUT
	if (
		_lower_deck_shortcut_pursuer_activated
		and not _lower_deck_shortcut_pursuer_defeated
	):
		return FACTORY_OBJECTIVE_CLEAR_SHORTCUT_PURSUER
	if _lower_deck_pressure_guard_activated and not _lower_deck_pressure_guard_defeated:
		return FACTORY_OBJECTIVE_CLEAR_PRESSURE_VALVE_GUARD
	if _lower_deck_pressure_guard_defeated and not _lower_deck_pressure_valve_opened:
		return FACTORY_OBJECTIVE_OPEN_PRESSURE_VALVE
	if _lower_deck_steam_sluice_activated and not _lower_deck_steam_sluice_defeated:
		return FACTORY_OBJECTIVE_CLEAR_STEAM_SLUICE_AMBUSH
	if _lower_deck_steam_sluice_defeated:
		return FACTORY_OBJECTIVE_STEAM_SLUICE_CLEARED
	if _lower_deck_pressure_valve_opened:
		return FACTORY_OBJECTIVE_PRESSURE_VALVE_OPENED
	if _lower_deck_shortcut_pursuer_defeated:
		return FACTORY_OBJECTIVE_SHORTCUT_PURSUER_CLEARED
	if _lower_deck_shortcut_unlocked:
		return FACTORY_OBJECTIVE_LOWER_DECK_SHORTCUT_OPENED
	if _lower_deck_exit_ambush_defeated:
		return FACTORY_OBJECTIVE_LOWER_DECK_EXIT_CLEARED
	if _lower_deck_skirmish_defeated:
		return FACTORY_OBJECTIVE_LOWER_DECK_CLEARED
	if _is_checkpoint_overdrive_duo_cleared():
		return FACTORY_OBJECTIVE_CHECKPOINT_OVERDRIVE_DUO_CLEARED
	if _checkpoint_overdrive_duo_activated and not _is_checkpoint_overdrive_duo_cleared():
		return FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_OVERDRIVE_DUO
	if _checkpoint_rear_ambush_defeated:
		return FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_OVERDRIVE_DUO
	if _checkpoint_forward_patrol_defeated:
		return FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_REAR_AMBUSH
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
		FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_FORWARD_PATROL:
			return "Clear Forward Patrol"
		FACTORY_OBJECTIVE_CHECKPOINT_FORWARD_ROUTE_OPENED:
			return "Deeper Factory Route Opened"
		FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_REAR_AMBUSH:
			return "Clear Rear Ambush"
		FACTORY_OBJECTIVE_CHECKPOINT_REAR_AMBUSH_CLEARED:
			return "Vent Gauntlet Cleared"
		FACTORY_OBJECTIVE_CLEAR_CHECKPOINT_OVERDRIVE_DUO:
			return "Clear Overdrive Duo"
		FACTORY_OBJECTIVE_CHECKPOINT_OVERDRIVE_DUO_CLEARED:
			return "Factory Lift Secured"
		FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_SKIRMISH:
			return "Clear Lower Deck Skirmish"
		FACTORY_OBJECTIVE_LOWER_DECK_CLEARED:
			return "Lower Deck Cleared"
		FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_EXIT_AMBUSH:
			return "Clear Lower Deck Exit"
		FACTORY_OBJECTIVE_LOWER_DECK_EXIT_CLEARED:
			return "Lower Deck Exit Cleared"
		FACTORY_OBJECTIVE_CLEAR_LOWER_DECK_SHORTCUT_GUARD:
			return "Clear Shortcut Guard"
		FACTORY_OBJECTIVE_OPEN_LOWER_DECK_SHORTCUT:
			return "Open Lower Deck Shortcut"
		FACTORY_OBJECTIVE_LOWER_DECK_SHORTCUT_OPENED:
			return "Lower Deck Shortcut Opened"
		FACTORY_OBJECTIVE_CLEAR_SHORTCUT_PURSUER:
			return "Clear Shortcut Pursuer"
		FACTORY_OBJECTIVE_SHORTCUT_PURSUER_CLEARED:
			return "Shortcut Pursuer Cleared"
		FACTORY_OBJECTIVE_CLEAR_PRESSURE_VALVE_GUARD:
			return "Clear Pressure Valve Guard"
		FACTORY_OBJECTIVE_OPEN_PRESSURE_VALVE:
			return "Open Pressure Valve"
		FACTORY_OBJECTIVE_PRESSURE_VALVE_OPENED:
			return "Pressure Valve Opened"
		FACTORY_OBJECTIVE_CLEAR_STEAM_SLUICE_AMBUSH:
			return "Clear Steam Sluice Ambush"
		FACTORY_OBJECTIVE_STEAM_SLUICE_CLEARED:
			return "Steam Sluice Cleared"
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


func _get_checkpoint_overdrive_reward_cache_payload() -> Dictionary:
	if (
		_checkpoint_overdrive_reward_cache == null
		or not _checkpoint_overdrive_reward_cache.has_method("get_reward_payload")
	):
		return {}
	var reward_variant: Variant = _checkpoint_overdrive_reward_cache.call("get_reward_payload")
	if reward_variant is Dictionary:
		return (reward_variant as Dictionary).duplicate(true)
	return {}


func _get_lower_deck_reward_cache_payload() -> Dictionary:
	if (
		_lower_deck_reward_cache == null
		or not _lower_deck_reward_cache.has_method("get_reward_payload")
	):
		return {}
	var reward_variant: Variant = _lower_deck_reward_cache.call("get_reward_payload")
	if reward_variant is Dictionary:
		return (reward_variant as Dictionary).duplicate(true)
	return {}


func _get_lower_deck_shortcut_reward_cache_payload() -> Dictionary:
	if (
		_lower_deck_shortcut_reward_cache == null
		or not _lower_deck_shortcut_reward_cache.has_method("get_reward_payload")
	):
		return {}
	var reward_variant: Variant = _lower_deck_shortcut_reward_cache.call("get_reward_payload")
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


func _record_checkpoint_overdrive_reward_cache_claim_feedback(
	reward: Dictionary,
	label_prefix: String
) -> void:
	_last_checkpoint_overdrive_reward_cache_claim_feedback = _build_cache_claim_feedback(
		reward,
		label_prefix
	)
	_update_route_label(String(
		_last_checkpoint_overdrive_reward_cache_claim_feedback.get("text", "")
	))


func _record_lower_deck_reward_cache_claim_feedback(
	reward: Dictionary,
	label_prefix: String
) -> void:
	_last_lower_deck_reward_cache_claim_feedback = _build_cache_claim_feedback(
		reward,
		label_prefix
	)
	_update_route_label(String(
		_last_lower_deck_reward_cache_claim_feedback.get("text", "")
	))


func _record_lower_deck_shortcut_reward_cache_claim_feedback(
	reward: Dictionary,
	label_prefix: String
) -> void:
	_last_lower_deck_shortcut_reward_cache_claim_feedback = _build_cache_claim_feedback(
		reward,
		label_prefix
	)
	_update_route_label(String(
		_last_lower_deck_shortcut_reward_cache_claim_feedback.get("text", "")
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


func _get_checkpoint_overdrive_reward_cache_prompt_text() -> String:
	var prompt_label := (
		_checkpoint_overdrive_reward_cache.get_node_or_null("PromptLabel") as Label
		if _checkpoint_overdrive_reward_cache != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_reward_cache_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_reward_cache.get_node_or_null("PromptLabel") as Label
		if _lower_deck_reward_cache != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_shortcut_reward_cache_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_shortcut_reward_cache.get_node_or_null("PromptLabel") as Label
		if _lower_deck_shortcut_reward_cache != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_parry_gate_id() -> String:
	if _lower_deck_parry_gate != null and _lower_deck_parry_gate.has_method("get_gate_id"):
		return String(_lower_deck_parry_gate.call("get_gate_id"))
	return String(FACTORY_LOWER_DECK_PARRY_GATE_ID)


func _get_lower_deck_parry_gate_required_ability() -> String:
	if (
		_lower_deck_parry_gate != null
		and _lower_deck_parry_gate.has_method("get_required_ability")
	):
		return String(_lower_deck_parry_gate.call("get_required_ability"))
	return "parry"


func _get_lower_deck_parry_gate_state() -> String:
	if _lower_deck_parry_gate != null and _lower_deck_parry_gate.has_method("get_gate_state"):
		return String(_lower_deck_parry_gate.call("get_gate_state"))
	return "unlocked" if _lower_deck_parry_gate_unlocked else "locked"


func _is_lower_deck_parry_gate_collision_blocking() -> bool:
	if (
		_lower_deck_parry_gate != null
		and _lower_deck_parry_gate.has_method("is_collision_blocking")
	):
		return bool(_lower_deck_parry_gate.call("is_collision_blocking"))
	var collision_shape := _get_lower_deck_parry_gate_collision_shape()
	return collision_shape != null and not collision_shape.disabled


func _get_lower_deck_parry_gate_visual_texture_path() -> String:
	var visual := (
		_lower_deck_parry_gate.get_node_or_null("Visual") as Sprite2D
		if _lower_deck_parry_gate != null
		else null
	)
	if visual == null or visual.texture == null:
		return ""
	return visual.texture.resource_path


func _get_lower_deck_parry_gate_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_parry_gate.get_node_or_null("PromptLabel") as Label
		if _lower_deck_parry_gate != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_parry_gate_collision_shape() -> CollisionShape2D:
	return (
		_lower_deck_parry_gate.find_child("CollisionShape2D", true, false) as CollisionShape2D
		if _lower_deck_parry_gate != null
		else null
	)


func _set_lower_deck_parry_gate_collision_enabled(enabled: bool) -> void:
	var collision_shape := _get_lower_deck_parry_gate_collision_shape()
	if collision_shape != null:
		collision_shape.disabled = not enabled


func _get_lower_deck_shortcut_seal_id() -> String:
	if (
		_lower_deck_shortcut_seal != null
		and _lower_deck_shortcut_seal.has_method("get_endpoint_id")
	):
		return String(_lower_deck_shortcut_seal.call("get_endpoint_id"))
	return String(FACTORY_LOWER_DECK_SHORTCUT_SEAL_ID)


func _get_lower_deck_shortcut_visual_texture_path() -> String:
	if (
		_lower_deck_shortcut_seal != null
		and _lower_deck_shortcut_seal.has_method("get_visual_texture_path")
	):
		return String(_lower_deck_shortcut_seal.call("get_visual_texture_path"))
	var visual := (
		_lower_deck_shortcut_seal.get_node_or_null("Visual") as Sprite2D
		if _lower_deck_shortcut_seal != null
		else null
	)
	if visual == null or visual.texture == null:
		return ""
	return visual.texture.resource_path


func _get_lower_deck_shortcut_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_shortcut_seal.get_node_or_null("PromptLabel") as Label
		if _lower_deck_shortcut_seal != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_shortcut_position() -> Vector2:
	return (
		(_lower_deck_shortcut_seal as Node2D).global_position
		if _lower_deck_shortcut_seal != null and _lower_deck_shortcut_seal is Node2D
		else Vector2.ZERO
	)


func _get_lower_deck_pressure_valve_id() -> String:
	if (
		_lower_deck_pressure_valve != null
		and _lower_deck_pressure_valve.has_method("get_endpoint_id")
	):
		return String(_lower_deck_pressure_valve.call("get_endpoint_id"))
	return String(FACTORY_LOWER_DECK_PRESSURE_VALVE_ID)


func _get_lower_deck_pressure_valve_visual_texture_path() -> String:
	if (
		_lower_deck_pressure_valve != null
		and _lower_deck_pressure_valve.has_method("get_visual_texture_path")
	):
		return String(_lower_deck_pressure_valve.call("get_visual_texture_path"))
	var visual := (
		_lower_deck_pressure_valve.get_node_or_null("Visual") as Sprite2D
		if _lower_deck_pressure_valve != null
		else null
	)
	if visual == null or visual.texture == null:
		return ""
	return visual.texture.resource_path


func _get_lower_deck_pressure_valve_prompt_text() -> String:
	var prompt_label := (
		_lower_deck_pressure_valve.get_node_or_null("PromptLabel") as Label
		if _lower_deck_pressure_valve != null
		else null
	)
	return prompt_label.text if prompt_label != null else ""


func _get_lower_deck_pressure_valve_position() -> Vector2:
	return (
		(_lower_deck_pressure_valve as Node2D).global_position
		if _lower_deck_pressure_valve != null and _lower_deck_pressure_valve is Node2D
		else Vector2.ZERO
	)


func _is_lower_deck_shortcut_collision_blocking() -> bool:
	var collision_shape := _get_lower_deck_shortcut_collision_shape()
	return collision_shape != null and not collision_shape.disabled


func _get_lower_deck_shortcut_collision_shape() -> CollisionShape2D:
	return (
		_lower_deck_shortcut_seal.find_child("CollisionShape2D", true, false) as CollisionShape2D
		if _lower_deck_shortcut_seal != null
		else null
	)


func _set_lower_deck_shortcut_collision_enabled(enabled: bool) -> void:
	var collision_shape := _get_lower_deck_shortcut_collision_shape()
	if collision_shape != null:
		collision_shape.disabled = not enabled


func _show_checkpoint_overdrive_defeat_burst(side: StringName, spark_rat: Node2D) -> void:
	var burst: Sprite2D = null
	match side:
		&"left":
			burst = _checkpoint_overdrive_left_defeat_burst
		&"right":
			burst = _checkpoint_overdrive_right_defeat_burst
		_:
			return
	if burst == null:
		return
	if spark_rat != null:
		burst.global_position = spark_rat.global_position
	burst.visible = true
	_last_checkpoint_overdrive_defeat_burst_side = side


func _get_checkpoint_overdrive_defeat_burst_texture_path() -> String:
	var burst: Sprite2D = (
		_checkpoint_overdrive_left_defeat_burst
		if _checkpoint_overdrive_left_defeat_burst != null
		else _checkpoint_overdrive_right_defeat_burst
	)
	if burst == null or burst.texture == null:
		return ""
	return burst.texture.resource_path


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
	for hazard: Area2D in _get_factory_hazards():
		if not _is_hazard_contact_active(hazard):
			continue
		for area: Area2D in hazard.get_overlapping_areas():
			var target: Node = _resolve_factory_hazard_target_from_area(area)
			if target != null:
				apply_factory_steam_vent_contact(hazard, target)
		for body: Node2D in hazard.get_overlapping_bodies():
			if body == _player:
				apply_factory_steam_vent_contact(hazard, _player)


func _get_factory_hazards() -> Array[Area2D]:
	var hazards: Array[Area2D] = []
	if _steam_vent != null:
		hazards.append(_steam_vent)
	if _checkpoint_steam_vent != null:
		hazards.append(_checkpoint_steam_vent)
	if _lower_deck_steam_vent != null:
		hazards.append(_lower_deck_steam_vent)
	if _lower_deck_steam_sluice_hazard != null:
		hazards.append(_lower_deck_steam_sluice_hazard)
	return hazards


func _is_hazard_contact_active(hazard: Area2D) -> bool:
	return (
		hazard != null
		and hazard.visible
		and hazard.monitoring
		and hazard.collision_layer != 0
		and hazard.collision_mask != 0
	)


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


func _is_factory_steam_hazard_id(hazard_id: StringName) -> bool:
	return (
		hazard_id == &"old_factory_steam_vent"
		or hazard_id == &"old_factory_checkpoint_steam_vent"
		or hazard_id == &"old_factory_lower_deck_steam_vent"
		or hazard_id == &"old_factory_lower_deck_steam_sluice"
	)


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


func _grant_factory_hazard_respawn_grace() -> void:
	_factory_hazard_respawn_grace_frames = FACTORY_RESPAWN_HAZARD_GRACE_FRAMES
	var target_id: int = PlayerController.PLAYER_ENTITY_ID
	for hazard: Area2D in _get_factory_hazards():
		var hazard_id: StringName = _get_hazard_id(hazard)
		if not _is_factory_steam_hazard_id(hazard_id):
			continue
		_factory_hazard_contact_cooldowns[_factory_hazard_cooldown_key(hazard_id, target_id)] = (
			_factory_hazard_elapsed_sec + _get_hazard_cooldown_sec(hazard)
		)


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


func _set_checkpoint_forward_spark_rat_attack_target(attack_target: Node) -> void:
	if (
		_checkpoint_forward_spark_rat != null
		and _checkpoint_forward_spark_rat.has_method("set_attack_target")
	):
		_checkpoint_forward_spark_rat.call("set_attack_target", attack_target)


func _set_checkpoint_rear_spark_rat_attack_target(attack_target: Node) -> void:
	if (
		_checkpoint_rear_spark_rat != null
		and _checkpoint_rear_spark_rat.has_method("set_attack_target")
	):
		_checkpoint_rear_spark_rat.call("set_attack_target", attack_target)


func _set_checkpoint_overdrive_spark_rat_attack_targets(attack_target: Node) -> void:
	if (
		_checkpoint_overdrive_left_spark_rat != null
		and _checkpoint_overdrive_left_spark_rat.has_method("set_attack_target")
	):
		_checkpoint_overdrive_left_spark_rat.call("set_attack_target", attack_target)
	if (
		_checkpoint_overdrive_right_spark_rat != null
		and _checkpoint_overdrive_right_spark_rat.has_method("set_attack_target")
	):
			_checkpoint_overdrive_right_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_spark_rat_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_spark_rat != null
		and _lower_deck_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_exit_spark_rat_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_exit_spark_rat != null
		and _lower_deck_exit_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_exit_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_shortcut_spark_rat_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_shortcut_spark_rat != null
		and _lower_deck_shortcut_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_shortcut_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_shortcut_pursuer_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_shortcut_pursuer_spark_rat != null
		and _lower_deck_shortcut_pursuer_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_shortcut_pursuer_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_pressure_guard_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_pressure_guard_spark_rat != null
		and _lower_deck_pressure_guard_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_pressure_guard_spark_rat.call("set_attack_target", attack_target)


func _set_lower_deck_steam_sluice_attack_target(attack_target: Node) -> void:
	if (
		_lower_deck_steam_sluice_spark_rat != null
		and _lower_deck_steam_sluice_spark_rat.has_method("set_attack_target")
	):
		_lower_deck_steam_sluice_spark_rat.call("set_attack_target", attack_target)


func _begin_spark_rat_pacing(opening_grace_frames: int) -> void:
	if _spark_rat != null and _spark_rat.has_method("begin_pacing"):
		_spark_rat.call("begin_pacing", maxi(0, opening_grace_frames))


func _begin_return_spark_rat_pacing(opening_grace_frames: int) -> void:
	if _return_spark_rat != null and _return_spark_rat.has_method("begin_pacing"):
		_return_spark_rat.call("begin_pacing", maxi(0, opening_grace_frames))


func _begin_checkpoint_forward_spark_rat_pacing(opening_grace_frames: int) -> void:
	if (
		_checkpoint_forward_spark_rat != null
		and _checkpoint_forward_spark_rat.has_method("begin_pacing")
	):
		_checkpoint_forward_spark_rat.call("begin_pacing", maxi(0, opening_grace_frames))


func _begin_checkpoint_rear_spark_rat_pacing(opening_grace_frames: int) -> void:
	if (
		_checkpoint_rear_spark_rat != null
		and _checkpoint_rear_spark_rat.has_method("begin_pacing")
	):
		_checkpoint_rear_spark_rat.call("begin_pacing", maxi(0, opening_grace_frames))


func _begin_checkpoint_overdrive_spark_rat_pacing(
	left_opening_grace_frames: int,
	right_opening_grace_frames: int = -1
) -> void:
	var left_grace_frames: int = maxi(0, left_opening_grace_frames)
	var right_grace_frames: int = (
		left_grace_frames
		if right_opening_grace_frames < 0
		else maxi(0, right_opening_grace_frames)
	)
	if (
		_checkpoint_overdrive_left_spark_rat != null
		and _checkpoint_overdrive_left_spark_rat.has_method("begin_pacing")
		and not _checkpoint_overdrive_left_defeated
	):
		_checkpoint_overdrive_left_spark_rat.call("begin_pacing", left_grace_frames)
	if (
		_checkpoint_overdrive_right_spark_rat != null
		and _checkpoint_overdrive_right_spark_rat.has_method("begin_pacing")
		and not _checkpoint_overdrive_right_defeated
	):
			_checkpoint_overdrive_right_spark_rat.call("begin_pacing", right_grace_frames)


func _begin_lower_deck_spark_rat_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_spark_rat != null
		and _lower_deck_spark_rat.has_method("begin_pacing")
		and not _lower_deck_skirmish_defeated
	):
		_lower_deck_spark_rat.call("begin_pacing", maxi(0, opening_grace_frames))


func _begin_lower_deck_exit_spark_rat_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_exit_spark_rat != null
		and _lower_deck_exit_spark_rat.has_method("begin_pacing")
		and not _lower_deck_exit_ambush_defeated
	):
		_lower_deck_exit_spark_rat.call("begin_pacing", maxi(0, opening_grace_frames))


func _begin_lower_deck_shortcut_spark_rat_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_shortcut_spark_rat != null
		and _lower_deck_shortcut_spark_rat.has_method("begin_pacing")
		and not _lower_deck_shortcut_guard_defeated
	):
		_lower_deck_shortcut_spark_rat.call("begin_pacing", maxi(0, opening_grace_frames))


func _begin_lower_deck_shortcut_pursuer_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_shortcut_pursuer_spark_rat != null
		and _lower_deck_shortcut_pursuer_spark_rat.has_method("begin_pacing")
		and not _lower_deck_shortcut_pursuer_defeated
	):
		_lower_deck_shortcut_pursuer_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_pressure_guard_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_pressure_guard_spark_rat != null
		and _lower_deck_pressure_guard_spark_rat.has_method("begin_pacing")
		and not _lower_deck_pressure_guard_defeated
	):
		_lower_deck_pressure_guard_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


func _begin_lower_deck_steam_sluice_pacing(opening_grace_frames: int) -> void:
	if (
		_lower_deck_steam_sluice_spark_rat != null
		and _lower_deck_steam_sluice_spark_rat.has_method("begin_pacing")
		and not _lower_deck_steam_sluice_defeated
	):
		_lower_deck_steam_sluice_spark_rat.call(
			"begin_pacing",
			maxi(0, opening_grace_frames)
		)


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


func _get_checkpoint_forward_patrol_pacing_diagnostics() -> Dictionary:
	if (
		_checkpoint_forward_spark_rat != null
		and _checkpoint_forward_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _checkpoint_forward_spark_rat.call("get_pacing_diagnostics")
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_checkpoint_forward_patrol_opening_grace_frames() -> int:
	var pacing: Dictionary = _get_checkpoint_forward_patrol_pacing_diagnostics()
	return int(pacing.get("opening_grace_frames", 0))


func _get_checkpoint_rear_ambush_pacing_diagnostics() -> Dictionary:
	if (
		_checkpoint_rear_spark_rat != null
		and _checkpoint_rear_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _checkpoint_rear_spark_rat.call("get_pacing_diagnostics")
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_checkpoint_rear_ambush_opening_grace_frames() -> int:
	var pacing: Dictionary = _get_checkpoint_rear_ambush_pacing_diagnostics()
	return int(pacing.get("opening_grace_frames", 0))


func _get_checkpoint_overdrive_duo_pacing_diagnostics() -> Dictionary:
	var left_pacing: Dictionary = _get_checkpoint_overdrive_spark_rat_pacing_diagnostics(
		_checkpoint_overdrive_left_spark_rat
	)
	var right_pacing: Dictionary = _get_checkpoint_overdrive_spark_rat_pacing_diagnostics(
		_checkpoint_overdrive_right_spark_rat
	)
	return {
		"left": left_pacing,
		"right": right_pacing,
		"opening_grace_frames": _get_checkpoint_overdrive_duo_opening_grace_frames(),
		"opening_grace_total_frames": maxi(
			int(left_pacing.get("opening_grace_total_frames", 0)),
			int(right_pacing.get("opening_grace_total_frames", 0))
		),
	}


func _get_checkpoint_overdrive_spark_rat_pacing_diagnostics(spark_rat: Node2D) -> Dictionary:
	if spark_rat != null and spark_rat.has_method("get_pacing_diagnostics"):
		var pacing_variant: Variant = spark_rat.call("get_pacing_diagnostics")
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_checkpoint_overdrive_duo_opening_grace_frames() -> int:
	var left_pacing: Dictionary = _get_checkpoint_overdrive_spark_rat_pacing_diagnostics(
		_checkpoint_overdrive_left_spark_rat
	)
	var right_pacing: Dictionary = _get_checkpoint_overdrive_spark_rat_pacing_diagnostics(
		_checkpoint_overdrive_right_spark_rat
	)
	return maxi(
		int(left_pacing.get("opening_grace_frames", 0)),
		int(right_pacing.get("opening_grace_frames", 0))
	)


func _get_checkpoint_overdrive_left_opening_grace_frames() -> int:
	var pacing: Dictionary = _get_checkpoint_overdrive_spark_rat_pacing_diagnostics(
		_checkpoint_overdrive_left_spark_rat
	)
	return int(pacing.get("opening_grace_frames", 0))


func _get_checkpoint_overdrive_right_opening_grace_frames() -> int:
	var pacing: Dictionary = _get_checkpoint_overdrive_spark_rat_pacing_diagnostics(
		_checkpoint_overdrive_right_spark_rat
	)
	return int(pacing.get("opening_grace_frames", 0))


func _get_lower_deck_skirmish_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_spark_rat != null
		and _lower_deck_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_spark_rat.call("get_pacing_diagnostics")
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_skirmish_opening_grace_frames() -> int:
	var pacing: Dictionary = _get_lower_deck_skirmish_pacing_diagnostics()
	return int(pacing.get("opening_grace_frames", 0))


func _get_lower_deck_exit_ambush_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_exit_spark_rat != null
		and _lower_deck_exit_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_exit_spark_rat.call("get_pacing_diagnostics")
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_exit_ambush_opening_grace_frames() -> int:
	var pacing: Dictionary = _get_lower_deck_exit_ambush_pacing_diagnostics()
	return int(pacing.get("opening_grace_frames", 0))


func _get_lower_deck_shortcut_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_shortcut_spark_rat != null
		and _lower_deck_shortcut_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_shortcut_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_shortcut_opening_grace_frames() -> int:
	var pacing: Dictionary = _get_lower_deck_shortcut_pacing_diagnostics()
	return int(pacing.get("opening_grace_frames", 0))


func _get_lower_deck_shortcut_pursuer_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_shortcut_pursuer_spark_rat != null
		and _lower_deck_shortcut_pursuer_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_shortcut_pursuer_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_pressure_guard_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_pressure_guard_spark_rat != null
		and _lower_deck_pressure_guard_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_pressure_guard_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


func _get_lower_deck_steam_sluice_pacing_diagnostics() -> Dictionary:
	if (
		_lower_deck_steam_sluice_spark_rat != null
		and _lower_deck_steam_sluice_spark_rat.has_method("get_pacing_diagnostics")
	):
		var pacing_variant: Variant = _lower_deck_steam_sluice_spark_rat.call(
			"get_pacing_diagnostics"
		)
		if pacing_variant is Dictionary:
			return (pacing_variant as Dictionary).duplicate(true)
	return {
		"pacing_state": "inactive",
		"opening_grace_frames": 0,
		"opening_grace_total_frames": FACTORY_SPARK_RAT_OPENING_GRACE_FRAMES,
	}


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


func _does_checkpoint_forward_spark_rat_have_target() -> bool:
	if _checkpoint_forward_spark_rat == null:
		return false
	if _checkpoint_forward_spark_rat.has_method("has_attack_target"):
		return bool(_checkpoint_forward_spark_rat.call("has_attack_target"))
	return _checkpoint_forward_patrol_activated and not _checkpoint_forward_patrol_defeated


func _does_checkpoint_rear_spark_rat_have_target() -> bool:
	if _checkpoint_rear_spark_rat == null:
		return false
	if _checkpoint_rear_spark_rat.has_method("has_attack_target"):
		return bool(_checkpoint_rear_spark_rat.call("has_attack_target"))
	return _checkpoint_rear_ambush_activated and not _checkpoint_rear_ambush_defeated


func _does_checkpoint_overdrive_left_spark_rat_have_target() -> bool:
	return _does_checkpoint_overdrive_spark_rat_have_target(
		_checkpoint_overdrive_left_spark_rat,
		_checkpoint_overdrive_left_defeated
	)


func _does_checkpoint_overdrive_right_spark_rat_have_target() -> bool:
	return _does_checkpoint_overdrive_spark_rat_have_target(
		_checkpoint_overdrive_right_spark_rat,
		_checkpoint_overdrive_right_defeated
	)


func _does_checkpoint_overdrive_spark_rat_have_target(
	spark_rat: Node2D,
	defeated: bool
) -> bool:
	if spark_rat == null:
		return false
	if spark_rat.has_method("has_attack_target"):
		return bool(spark_rat.call("has_attack_target"))
	return _checkpoint_overdrive_duo_activated and not defeated


func _does_lower_deck_spark_rat_have_target() -> bool:
	if _lower_deck_spark_rat == null:
		return false
	if _lower_deck_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_spark_rat.call("has_attack_target"))
	return _lower_deck_skirmish_activated and not _lower_deck_skirmish_defeated


func _does_lower_deck_exit_spark_rat_have_target() -> bool:
	if _lower_deck_exit_spark_rat == null:
		return false
	if _lower_deck_exit_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_exit_spark_rat.call("has_attack_target"))
	return _lower_deck_exit_ambush_activated and not _lower_deck_exit_ambush_defeated


func _does_lower_deck_shortcut_spark_rat_have_target() -> bool:
	if _lower_deck_shortcut_spark_rat == null:
		return false
	if _lower_deck_shortcut_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_shortcut_spark_rat.call("has_attack_target"))
	return _lower_deck_shortcut_activated and not _lower_deck_shortcut_guard_defeated


func _does_lower_deck_shortcut_pursuer_have_target() -> bool:
	if _lower_deck_shortcut_pursuer_spark_rat == null:
		return false
	if _lower_deck_shortcut_pursuer_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_shortcut_pursuer_spark_rat.call("has_attack_target"))
	return _is_lower_deck_shortcut_pursuer_active()


func _does_lower_deck_pressure_guard_have_target() -> bool:
	if _lower_deck_pressure_guard_spark_rat == null:
		return false
	if _lower_deck_pressure_guard_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_pressure_guard_spark_rat.call("has_attack_target"))
	return _is_lower_deck_pressure_guard_active()


func _does_lower_deck_steam_sluice_have_target() -> bool:
	if _lower_deck_steam_sluice_spark_rat == null:
		return false
	if _lower_deck_steam_sluice_spark_rat.has_method("has_attack_target"):
		return bool(_lower_deck_steam_sluice_spark_rat.call("has_attack_target"))
	return _is_lower_deck_steam_sluice_active()


func _sync_factory_damage_target_defeat(target_id: int, damage_target: Node) -> void:
	if not _is_factory_damage_target_defeated(damage_target):
		return
	match target_id:
		FACTORY_ENTRY_GUARD_ENTITY_ID:
			if not _encounter_cleared:
				_on_factory_enemy_defeated()
		FACTORY_DEEP_GUARD_ENTITY_ID:
			if not _deep_guard_defeated:
				_on_factory_deep_guard_defeated()
		FACTORY_SPARK_RAT_ENTITY_ID:
			if not _spark_rat_defeated:
				_on_factory_spark_rat_defeated()
		FACTORY_RETURN_SPARK_RAT_ENTITY_ID:
			if not _return_patrol_defeated:
				_on_factory_return_spark_rat_defeated()
		FACTORY_CHECKPOINT_FORWARD_SPARK_RAT_ENTITY_ID:
			if not _checkpoint_forward_patrol_defeated:
				_on_factory_checkpoint_forward_spark_rat_defeated()
		FACTORY_CHECKPOINT_REAR_SPARK_RAT_ENTITY_ID:
			if not _checkpoint_rear_ambush_defeated:
				_on_factory_checkpoint_rear_spark_rat_defeated()
		FACTORY_CHECKPOINT_OVERDRIVE_LEFT_SPARK_RAT_ENTITY_ID:
			if not _checkpoint_overdrive_left_defeated:
				_on_factory_checkpoint_overdrive_left_spark_rat_defeated()
		FACTORY_CHECKPOINT_OVERDRIVE_RIGHT_SPARK_RAT_ENTITY_ID:
			if not _checkpoint_overdrive_right_defeated:
				_on_factory_checkpoint_overdrive_right_spark_rat_defeated()
		FACTORY_LOWER_DECK_SPARK_RAT_ENTITY_ID:
			if not _lower_deck_skirmish_defeated:
				_on_factory_lower_deck_spark_rat_defeated()
		FACTORY_LOWER_DECK_EXIT_SPARK_RAT_ENTITY_ID:
			if not _lower_deck_exit_ambush_defeated:
				_on_factory_lower_deck_exit_spark_rat_defeated()
		FACTORY_LOWER_DECK_SHORTCUT_SPARK_RAT_ENTITY_ID:
			if not _lower_deck_shortcut_guard_defeated:
				_on_factory_lower_deck_shortcut_spark_rat_defeated()
		FACTORY_LOWER_DECK_SHORTCUT_PURSUER_ENTITY_ID:
			if not _lower_deck_shortcut_pursuer_defeated:
				_on_factory_lower_deck_shortcut_pursuer_defeated()
		FACTORY_LOWER_DECK_PRESSURE_GUARD_ENTITY_ID:
			if not _lower_deck_pressure_guard_defeated:
				_on_factory_lower_deck_pressure_guard_defeated()
		FACTORY_LOWER_DECK_STEAM_SLUICE_ENTITY_ID:
			if not _lower_deck_steam_sluice_defeated:
				_on_factory_lower_deck_steam_sluice_defeated()


func _is_factory_damage_target_defeated(damage_target: Node) -> bool:
	if damage_target == null or not damage_target.has_method("get_current_hp"):
		return false
	return int(damage_target.call("get_current_hp")) <= 0


func _is_deep_guard_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (provider as Node2D).global_position.x >= FACTORY_DEEP_GUARD_ACTIVATION_X


func _is_spark_rat_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (provider as Node2D).global_position.x >= FACTORY_SPARK_RAT_ACTIVATION_X


func _is_checkpoint_forward_patrol_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (provider as Node2D).global_position.x >= FACTORY_CHECKPOINT_FORWARD_PATROL_ACTIVATION_X


func _is_checkpoint_rear_ambush_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (provider as Node2D).global_position.x >= FACTORY_CHECKPOINT_REAR_AMBUSH_ACTIVATION_X


func _is_checkpoint_overdrive_duo_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (provider as Node2D).global_position.x >= FACTORY_CHECKPOINT_OVERDRIVE_DUO_ACTIVATION_X


func _is_lower_deck_skirmish_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (provider as Node2D).global_position.x >= FACTORY_LOWER_DECK_SKIRMISH_ACTIVATION_X


func _is_lower_deck_shortcut_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (provider as Node2D).global_position.x >= FACTORY_LOWER_DECK_SHORTCUT_ACTIVATION_X


func _is_lower_deck_shortcut_pursuer_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_SHORTCUT_PURSUER_ACTIVATION_X
	)


func _is_lower_deck_pressure_guard_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_PRESSURE_VALVE_ACTIVATION_X
	)


func _is_lower_deck_steam_sluice_activation_provider_in_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	return (
		(provider as Node2D).global_position.x
		>= FACTORY_LOWER_DECK_STEAM_SLUICE_ACTIVATION_X
	)


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
	for guard: Node in [
		_enemy,
		_deep_guard,
		_spark_rat,
		_return_spark_rat,
		_checkpoint_forward_spark_rat,
			_checkpoint_rear_spark_rat,
			_checkpoint_overdrive_left_spark_rat,
			_checkpoint_overdrive_right_spark_rat,
			_lower_deck_spark_rat,
			_lower_deck_exit_spark_rat,
			_lower_deck_shortcut_spark_rat,
			_lower_deck_shortcut_pursuer_spark_rat,
			_lower_deck_pressure_guard_spark_rat,
			_lower_deck_steam_sluice_spark_rat,
		]:
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


func _is_checkpoint_forward_patrol_blocking_service_lift() -> bool:
	return _checkpoint_forward_patrol_activated and not _checkpoint_forward_patrol_defeated


func _is_checkpoint_rear_ambush_blocking_service_lift() -> bool:
	return _checkpoint_forward_patrol_defeated and not _checkpoint_rear_ambush_defeated


func _is_checkpoint_overdrive_duo_blocking_service_lift() -> bool:
	return _checkpoint_rear_ambush_defeated and not _is_checkpoint_overdrive_duo_cleared()


func _is_checkpoint_overdrive_duo_active() -> bool:
	return (
		_checkpoint_overdrive_duo_activated
		and _checkpoint_rear_ambush_defeated
		and not _is_checkpoint_overdrive_duo_cleared()
	)


func _is_lower_deck_skirmish_active() -> bool:
	return (
		_lower_deck_skirmish_activated
		and _is_checkpoint_overdrive_duo_cleared()
		and not _lower_deck_skirmish_defeated
	)


func _is_lower_deck_parry_gate_available() -> bool:
	return _lower_deck_reward_cache_claimed and not _lower_deck_parry_gate_unlocked


func _is_lower_deck_exit_ambush_active() -> bool:
	return (
		_lower_deck_exit_ambush_activated
		and _lower_deck_parry_gate_unlocked
		and not _lower_deck_exit_ambush_defeated
	)


func _is_lower_deck_shortcut_available() -> bool:
	return _lower_deck_exit_ambush_defeated and not _lower_deck_shortcut_unlocked


func _is_lower_deck_shortcut_active() -> bool:
	return (
		_lower_deck_shortcut_activated
		and _lower_deck_exit_ambush_defeated
		and not _lower_deck_shortcut_guard_defeated
		and not _lower_deck_shortcut_unlocked
	)


func _is_lower_deck_shortcut_seal_unlockable() -> bool:
	return _lower_deck_shortcut_guard_defeated and not _lower_deck_shortcut_unlocked


func _is_lower_deck_shortcut_seal_activated() -> bool:
	if _lower_deck_shortcut_seal != null and _lower_deck_shortcut_seal.has_method("is_activated"):
		return bool(_lower_deck_shortcut_seal.call("is_activated"))
	return _lower_deck_shortcut_unlocked


func _is_lower_deck_shortcut_pursuer_available() -> bool:
	return (
		_lower_deck_shortcut_reward_cache_claimed
		and not _lower_deck_shortcut_pursuer_defeated
	)


func _is_lower_deck_shortcut_pursuer_active() -> bool:
	return (
		_lower_deck_shortcut_pursuer_activated
		and not _lower_deck_shortcut_pursuer_defeated
	)


func _is_lower_deck_pressure_guard_available() -> bool:
	return (
		_lower_deck_shortcut_pursuer_defeated
		and not _lower_deck_pressure_guard_defeated
		and not _lower_deck_pressure_valve_opened
	)


func _is_lower_deck_pressure_guard_active() -> bool:
	return (
		_lower_deck_pressure_guard_activated
		and not _lower_deck_pressure_guard_defeated
		and not _lower_deck_pressure_valve_opened
	)


func _is_lower_deck_pressure_valve_available() -> bool:
	return _lower_deck_pressure_guard_defeated and not _lower_deck_pressure_valve_opened


func _is_lower_deck_steam_sluice_available() -> bool:
	return _lower_deck_pressure_valve_opened and not _lower_deck_steam_sluice_defeated


func _is_lower_deck_steam_sluice_active() -> bool:
	return (
		_lower_deck_steam_sluice_activated
		and _lower_deck_pressure_valve_opened
		and not _lower_deck_steam_sluice_defeated
	)


func _is_checkpoint_overdrive_duo_cleared() -> bool:
	return _checkpoint_overdrive_left_defeated and _checkpoint_overdrive_right_defeated


func _is_checkpoint_route_chain_started() -> bool:
	return (
		_checkpoint_forward_patrol_activated
		or _checkpoint_forward_patrol_defeated
		or _checkpoint_rear_ambush_activated
		or _checkpoint_rear_ambush_defeated
		or _checkpoint_overdrive_duo_activated
		or _checkpoint_overdrive_left_defeated
		or _checkpoint_overdrive_right_defeated
	)


func _try_auto_activate_checkpoint_forward_patrol() -> void:
	if _checkpoint_forward_patrol_activated or _checkpoint_forward_patrol_defeated:
		return
	if not _return_checkpoint_activated:
		return
	try_activate_factory_checkpoint_forward_patrol(_player)


func _try_auto_activate_checkpoint_rear_ambush() -> void:
	if _checkpoint_rear_ambush_activated or _checkpoint_rear_ambush_defeated:
		return
	if not _checkpoint_forward_patrol_defeated:
		return
	try_activate_factory_checkpoint_rear_ambush(_player)


func _try_auto_activate_checkpoint_overdrive_duo() -> void:
	if _checkpoint_overdrive_duo_activated or _is_checkpoint_overdrive_duo_cleared():
		return
	if not _checkpoint_rear_ambush_defeated:
		return
	try_activate_factory_checkpoint_overdrive_duo(_player)


func _is_service_lift_return_contract_in_state(state: Dictionary) -> bool:
	return (
		bool(state.get("factory_service_lift_exit_requested", false))
		and String(state.get("factory_service_lift_exit_scene_id", ""))
			== String(FACTORY_SERVICE_LIFT_EXIT_SCENE_ID)
		and String(state.get("factory_service_lift_exit_spawn_point", ""))
			== String(FACTORY_SERVICE_LIFT_EXIT_SPAWN_POINT)
	)
