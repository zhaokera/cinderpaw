## Central Tower threshold, relay, shafts, Deep Lift, and Apex ACT route.
class_name CentralTowerThresholdScene
extends Node2D

const SCENE_ID: StringName = &"area_05_central_tower"
const ENTRY_SPAWN_POINT: StringName = &"neon_rooftops_threshold_arrival"
const ROOFTOPS_SCENE_ID: StringName = &"area_05_neon_rooftops"
const ROOFTOPS_RETURN_SPAWN: StringName = &"central_tower_threshold_return"
const CROWN_WARDEN_ARENA_SCENE_ID: StringName = &"boss_04_crown_warden_arena"
const CROWN_WARDEN_ENTRY_SPAWN: StringName = &"boss_entry"
const APEX_APPROACH_RETURN_SPAWN: StringName = &"apex_approach_return"
const THRESHOLD_ROOST_ID: StringName = &"central_tower_threshold_roost"
const PLAYER_LIGHT_DAMAGE: int = 12
const TOWER_MUSIC_ID: StringName = &"mus_rooftop"
const TOWER_AMBIENT_ID: StringName = &"amb_rooftop"
const AUDIO_FADE_SEC: float = 0.8
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "env_central_tower_threshold_1280x720.png"
)
const ROOST_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_threshold_roost_256x256.png"
)
const SERVICE_SPINE_BACKGROUND_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "env_central_tower_service_spine_1280x720.png"
)
const COOLING_SHAFT_BACKGROUND_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "env_central_tower_cooling_shaft_1280x720.png"
)
const DEEP_LIFT_BACKGROUND_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "env_central_tower_deep_lift_1280x720.png"
)
const APEX_CONDUIT_BACKGROUND_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "env_central_tower_apex_conduit_1280x720.png"
)
const COOLING_SHAFT_SPAWN_POINT: StringName = &"cooling_shaft_roost"
const APEX_ROOST_SPAWN_POINT: StringName = &"apex_roost"
const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")
const PRESENTATION_ENEMY_PATHS: Array[NodePath] = [
	NodePath("ThresholdGuardController/CentralTowerThresholdGuard"),
	NodePath("InnerRelayController/CentralTowerRelayMantis"),
	NodePath("DeepLiftController/CentralTowerCounterweightSentry"),
]

@onready var _background: Sprite2D = get_node_or_null("Background") as Sprite2D
@onready var _service_spine_background: Sprite2D = (
	get_node_or_null("ServiceSpineBackground") as Sprite2D
)
@onready var _cooling_shaft_background: Sprite2D = (
	get_node_or_null("CoolingShaftBackground") as Sprite2D
)
@onready var _deep_lift_background: Sprite2D = (
	get_node_or_null("DeepLiftBackground") as Sprite2D
)
@onready var _apex_conduit_background: Sprite2D = (
	get_node_or_null("ApexConduitBackground") as Sprite2D
)
@onready var _arrival_spawn: Marker2D = (
	get_node_or_null("NeonRooftopsThresholdArrival") as Marker2D
)
@onready var _threshold_roost: SavepointRuntime = (
	get_node_or_null("ThresholdRoost") as SavepointRuntime
)
@onready var _player: Node2D = get_node_or_null("Player") as Node2D
@onready var _camera: Camera2D = get_node_or_null("Player/Camera2D") as Camera2D
@onready var _return_route: Node2D = (
	get_node_or_null("NeonRooftopsReturnRoute") as Node2D
)
@onready var _return_prompt: Label = (
	get_node_or_null("NeonRooftopsReturnRoute/PromptLabel") as Label
)
@onready var _crown_warden_route: Node2D = (
	get_node_or_null("CrownWardenArenaRoute") as Node2D
)
@onready var _apex_approach_return_spawn: Marker2D = (
	get_node_or_null("ApexApproachReturnSpawn") as Marker2D
)
@onready var _objective_label: Label = get_node_or_null("ObjectiveLabel") as Label
@onready var _hud: HUDManager = get_node_or_null("HUD") as HUDManager
@onready var _guard_controller: CentralTowerThresholdGuardController = (
	get_node_or_null("ThresholdGuardController")
	as CentralTowerThresholdGuardController
)
@onready var _inner_relay_controller: CentralTowerInnerRelayController = (
	get_node_or_null("InnerRelayController") as CentralTowerInnerRelayController
)
@onready var _cooling_shaft_controller: CentralTowerCoolingShaftController = (
	get_node_or_null("CoolingShaftController")
	as CentralTowerCoolingShaftController
)
@onready var _deep_lift_controller: CentralTowerDeepLiftController = (
	get_node_or_null("DeepLiftController") as CentralTowerDeepLiftController
)
@onready var _apex_purge_controller: CentralTowerApexPurgeController = (
	get_node_or_null("ApexPurgeController") as CentralTowerApexPurgeController
)
@onready var _game_flow: GameFlowController = (
	get_node_or_null("GameFlowController") as GameFlowController
)
@onready var _combat_presentation: CombatPresentation = (
	get_node_or_null("CombatPresentation") as CombatPresentation
)
@onready var _hitstop_input_bridge = get_node_or_null("HitstopInputBridge")

var _scene_manager: Object = null
var _weapon_component: WeaponComponent = null
var _return_transition_requested: bool = false
var _last_return_rejected_reason: StringName = &""
var _last_return_request: Dictionary = {}
var _crown_warden_transition_requested: bool = false
var _last_crown_warden_rejected_reason: StringName = &""
var _last_crown_warden_request: Dictionary = {}
var _threshold_roost_activated: bool = false
var _last_discovered_savepoint: Dictionary = {}
var _last_player_hit_metadata: Dictionary = {}
var _last_enemy_hit_metadata: Dictionary = {}
var _audio_request_count: int = 0


func _ready() -> void:
	_align_player_to_arrival()
	_setup_weapon_component()
	_bind_player_combat_to_room()
	_setup_player_hud()
	_setup_guard_controller()
	_setup_inner_relay_controller()
	_setup_cooling_shaft_controller()
	_setup_deep_lift_controller()
	_setup_apex_purge_controller()
	_setup_combat_presentation()
	_setup_threshold_roost()
	_setup_game_flow()
	_sync_return_route()
	_sync_crown_warden_route()
	_refresh_objective_text()
	_sync_objective_position()
	_request_threshold_audio()
	var root_scene_manager: Node = get_node_or_null("/root/SceneManager")
	if _is_valid_scene_manager(root_scene_manager):
		configure_scene_manager_runtime(root_scene_manager)


func _process(delta: float) -> void:
	advance_central_tower_respawn_flow(delta)
	_sync_return_prompt_visibility()
	_refresh_objective_text()
	_sync_objective_position()
	if Input.is_action_just_pressed(&"interact"):
		if (
			_inner_relay_controller != null
			and _inner_relay_controller.try_claim_cache(_player)
		):
			_refresh_objective_text()
		elif (
			_cooling_shaft_controller != null
			and _cooling_shaft_controller.try_activate_roost(_player)
		):
			_refresh_objective_text()
		elif (
			_cooling_shaft_controller != null
			and _cooling_shaft_controller.try_activate_endpoint(_player)
		):
			_refresh_objective_text()
		elif (
			_deep_lift_controller != null
			and _deep_lift_controller.try_activate(_player)
		):
			_refresh_objective_text()
		elif (
			_deep_lift_controller != null
			and _deep_lift_controller.try_activate_endpoint(_player)
		):
			_refresh_objective_text()
		elif (
			_apex_purge_controller != null
			and _apex_purge_controller.try_activate_roost(_player)
		):
			_refresh_objective_text()
		elif (
			_apex_purge_controller != null
			and _apex_purge_controller.try_activate_endpoint(_player)
		):
			_refresh_objective_text()
		elif (
			not _crown_warden_transition_requested
			and _is_provider_near_crown_warden_route(_player)
		):
			try_request_crown_warden_arena(_player)
		elif (
			not _return_transition_requested
			and _is_provider_near_return(_player)
		):
			try_request_neon_rooftops_return(_player)


func configure_scene_manager_runtime(scene_manager: Object) -> bool:
	_disconnect_scene_manager_failure_signal()
	_scene_manager = scene_manager
	if not _is_valid_scene_manager(_scene_manager):
		return false
	_connect_scene_manager_failure_signal()
	_apply_current_scene_manager_spawn_point()
	_sync_crown_warden_route()
	return true


func _connect_scene_manager_failure_signal() -> void:
	if _scene_manager == null or not _scene_manager.has_signal("on_scene_load_failed"):
		return
	var failed_signal: Signal = _scene_manager.get("on_scene_load_failed")
	if not failed_signal.is_connected(_on_scene_load_failed):
		failed_signal.connect(_on_scene_load_failed)


func _disconnect_scene_manager_failure_signal() -> void:
	if (
		_scene_manager == null
		or not is_instance_valid(_scene_manager)
		or not _scene_manager.has_signal("on_scene_load_failed")
	):
		return
	var failed_signal: Signal = _scene_manager.get("on_scene_load_failed")
	if failed_signal.is_connected(_on_scene_load_failed):
		failed_signal.disconnect(_on_scene_load_failed)


func _on_scene_load_failed(scene_id: StringName, reason: StringName) -> void:
	if (
		scene_id == CROWN_WARDEN_ARENA_SCENE_ID
		and _crown_warden_transition_requested
	):
		_crown_warden_transition_requested = false
		_record_crown_warden_rejection(
			reason if reason != &"" else &"load_failed"
		)
		_last_crown_warden_request["load_failed_reason"] = String(reason)
		_sync_crown_warden_route()
		_refresh_objective_text()
		return
	if scene_id != ROOFTOPS_SCENE_ID or not _return_transition_requested:
		return
	_return_transition_requested = false
	_record_return_rejection(reason if reason != &"" else &"load_failed")
	_last_return_request["load_failed_reason"] = String(reason)
	_sync_return_route()
	_refresh_objective_text()


func try_activate_threshold_guard(provider: Node = null) -> bool:
	if _guard_controller == null:
		return false
	return _guard_controller.try_activate(provider)


func request_threshold_guard_attack() -> bool:
	return (
		_guard_controller != null
		and _guard_controller.request_guard_attack()
	)


## Starts Story141's inner relay after the Threshold Guard is durably clear.
func try_activate_inner_relay(provider: Node = null) -> bool:
	if _inner_relay_controller == null:
		return false
	_sync_inner_relay_prerequisite()
	return _inner_relay_controller.try_activate(provider)


## Advances Story141's relay timing deterministically for tests and probes.
func advance_inner_relay_time(delta_sec: float) -> void:
	if _inner_relay_controller != null:
		_inner_relay_controller.advance_time(delta_sec)


## Requests the Relay Mantis scythe dash for tests and MCP probes.
func request_relay_mantis_attack() -> bool:
	return (
		_inner_relay_controller != null
		and _inner_relay_controller.request_mantis_attack()
	)


## Attempts Story141's one-shot Service Spine cache claim.
func try_claim_inner_relay_cache(provider: Node = null) -> bool:
	if _inner_relay_controller == null:
		return false
	var claimed: bool = _inner_relay_controller.try_claim_cache(provider)
	if claimed:
		_refresh_objective_text()
	return claimed


## Configures Story142's local Roost autosave adapter.
func configure_cooling_shaft_save_system_runtime(save_system: Object) -> bool:
	return (
		_cooling_shaft_controller != null
		and _cooling_shaft_controller.configure_save_system_runtime(save_system)
	)


## Attempts Story142's one-shot Cooling Shaft Roost activation.
func try_activate_cooling_shaft_roost(provider: Node = null) -> bool:
	if _cooling_shaft_controller == null:
		return false
	_sync_cooling_shaft_prerequisite()
	return _cooling_shaft_controller.try_activate_roost(provider)


## Starts Story142's deterministic hazard loop at the gap lip.
func try_activate_cooling_shaft(provider: Node = null) -> bool:
	if _cooling_shaft_controller == null:
		return false
	_sync_cooling_shaft_prerequisite()
	return _cooling_shaft_controller.try_activate(provider)


## Advances Story142's arc timing deterministically for tests and probes.
func advance_cooling_shaft_time(delta_sec: float) -> void:
	if _cooling_shaft_controller != null:
		_cooling_shaft_controller.advance_time(delta_sec)


## Applies one active Cooling Shaft arc contact through the real player API.
func apply_cooling_shaft_arc_contact(target: Node = null) -> bool:
	return (
		_cooling_shaft_controller != null
		and _cooling_shaft_controller.apply_arc_contact(target)
	)


## Applies Story142's lethal fall through the shared death/respawn flow.
func apply_cooling_shaft_fall(target: Node = null) -> bool:
	return (
		_cooling_shaft_controller != null
		and _cooling_shaft_controller.apply_fall(target)
	)


## Records Story142's bounded Deep Lift endpoint exactly once.
func try_activate_cooling_shaft_endpoint(provider: Node = null) -> bool:
	return (
		_cooling_shaft_controller != null
		and _cooling_shaft_controller.try_activate_endpoint(provider)
	)


## Starts Story143's Deep Lift from its authored lower platform.
func try_activate_deep_lift(provider: Node = null) -> bool:
	if _deep_lift_controller == null:
		return false
	_sync_deep_lift_prerequisite()
	return _deep_lift_controller.try_activate(provider)


## Advances Story143's moving-platform phases deterministically.
func advance_deep_lift_time(delta_sec: float) -> void:
	if _deep_lift_controller != null:
		_deep_lift_controller.advance_time(delta_sec)


## Requests the Counterweight Sentry's readable ram attack.
func request_counterweight_sentry_attack() -> bool:
	return (
		_deep_lift_controller != null
		and _deep_lift_controller.request_sentry_attack()
	)


## Applies Story143's lethal shaft fall through the shared respawn flow.
func apply_deep_lift_fall(target: Node = null) -> bool:
	return (
		_deep_lift_controller != null
		and _deep_lift_controller.apply_fall(target)
	)


## Records Story143's upper-deck endpoint after the current ride docks.
func try_activate_deep_lift_endpoint(provider: Node = null) -> bool:
	return (
		_deep_lift_controller != null
		and _deep_lift_controller.try_activate_endpoint(provider)
	)


## Configures Story144's local Apex Roost autosave adapter.
func configure_apex_save_system_runtime(save_system: Object) -> bool:
	return (
		_apex_purge_controller != null
		and _apex_purge_controller.configure_save_system_runtime(save_system)
	)


## Attempts Story144's one-shot Apex Roost activation.
func try_activate_apex_roost(provider: Node = null) -> bool:
	if _apex_purge_controller == null:
		return false
	_sync_apex_purge_prerequisite()
	return _apex_purge_controller.try_activate_roost(provider)


## Starts Story144's warning and purge chase at the authored trigger line.
func try_trigger_apex_purge(provider: Node = null) -> bool:
	if _apex_purge_controller == null:
		return false
	_sync_apex_purge_prerequisite()
	return _apex_purge_controller.try_trigger(provider)


## Advances Story144's warning and purge motion deterministically.
func advance_apex_purge_time(delta_sec: float) -> void:
	if _apex_purge_controller != null:
		_apex_purge_controller.advance_time(delta_sec)


## Applies Story144's lethal moving-wall contact through the player API.
func apply_apex_purge_contact(target: Node = null) -> bool:
	return (
		_apex_purge_controller != null
		and _apex_purge_controller.apply_purge_contact(target)
	)


## Applies Story144's lethal bottom fall through shared respawn flow.
func apply_apex_fall(target: Node = null) -> bool:
	return (
		_apex_purge_controller != null
		and _apex_purge_controller.apply_fall(target)
	)


## Records Story144's bounded Apex Approach endpoint exactly once.
func try_activate_apex_endpoint(provider: Node = null) -> bool:
	return (
		_apex_purge_controller != null
		and _apex_purge_controller.try_activate_endpoint(provider)
	)


## Advances the existing death delay and revive protection deterministically.
func advance_central_tower_respawn_flow(delta_sec: float) -> void:
	if _game_flow == null:
		return
	_game_flow.advance_time(delta_sec)
	if _player != null and _player.has_method("set_control_locked"):
		_player.call(
			"set_control_locked",
			_is_room_player_control_locked()
		)


func apply_damage(
	target_id: int,
	final_damage: int,
	metadata: Dictionary = {}
) -> bool:
	if (
		_guard_controller != null
		and _guard_controller.handles_target_id(target_id)
	):
		return _guard_controller.apply_damage(target_id, final_damage, metadata)
	if (
		_inner_relay_controller != null
		and _inner_relay_controller.handles_target_id(target_id)
	):
		return _inner_relay_controller.apply_damage(
			target_id,
			final_damage,
			metadata
		)
	if (
		_deep_lift_controller != null
		and _deep_lift_controller.handles_target_id(target_id)
	):
		return _deep_lift_controller.apply_damage(
			target_id,
			final_damage,
			metadata
		)
	return false


## Supplies deterministic player scratch damage through the shared combat chain.
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
		"final_damage": PLAYER_LIGHT_DAMAGE,
		"base_damage": PLAYER_LIGHT_DAMAGE,
		"attack_damage": float(PLAYER_LIGHT_DAMAGE),
		"reduction_factor": 1.0,
		"damage_multiplier": 1.0,
		"is_crit": false,
		"crit_type": &"none",
		"parry_type": &"none",
		"combo_stage": combo_index,
		"damage_category": &"scratch",
	}


func get_last_player_hit_metadata() -> Dictionary:
	return _last_player_hit_metadata.duplicate(true)


func get_last_enemy_hit_metadata() -> Dictionary:
	return _last_enemy_hit_metadata.duplicate(true)


func get_last_buffered_input_result() -> Dictionary:
	if _hitstop_input_bridge == null:
		return {}
	return _hitstop_input_bridge.get_last_buffered_input_result()


## Returns to the secured outer threshold in Neon Rooftops.
func try_request_neon_rooftops_return(provider: Node = null) -> bool:
	if _return_route == null or _return_transition_requested:
		_record_return_rejection(&"transition_already_requested")
		return false
	var request_provider: Node = _player if provider == null else provider
	if (
		not _return_route.has_method("can_request_transition")
		or not bool(_return_route.call("can_request_transition", request_provider))
	):
		_record_return_rejection(&"provider_out_of_range")
		return false
	if not _can_use_scene_manager_for(ROOFTOPS_SCENE_ID):
		return false
	if not _ensure_runtime_scene_root():
		_record_return_rejection(&"runtime_root_unavailable")
		return false
	if not _persist_progress():
		_record_return_rejection(&"state_persist_failed")
		return false
	if not _request_scene_change(ROOFTOPS_SCENE_ID, ROOFTOPS_RETURN_SPAWN):
		_record_return_rejection(&"request_rejected")
		return false
	_return_transition_requested = true
	_last_return_rejected_reason = &""
	_last_return_request = {
		"scene_id": String(ROOFTOPS_SCENE_ID),
		"spawn_point": String(ROOFTOPS_RETURN_SPAWN),
		"pending_scene": _get_pending_scene(),
		"pending_spawn_point": _get_pending_spawn_point(),
	}
	_sync_return_route()
	_refresh_objective_text()
	return true


## Enters the Crown Observatory only after Story144 secures the Apex Approach.
func try_request_crown_warden_arena(provider: Node = null) -> bool:
	if _crown_warden_route == null or _crown_warden_transition_requested:
		_record_crown_warden_rejection(&"transition_already_requested")
		return false
	_sync_crown_warden_route()
	var request_provider: Node = _player if provider == null else provider
	if (
		not _crown_warden_route.has_method("can_request_transition")
		or not bool(_crown_warden_route.call(
			"can_request_transition",
			request_provider
		))
	):
		_record_crown_warden_rejection(
			&"provider_out_of_range"
			if _is_apex_approach_secured()
			else &"apex_approach_unsecured"
		)
		return false
	var manager_rejection: StringName = _scene_manager_rejection_for(
		CROWN_WARDEN_ARENA_SCENE_ID
	)
	if manager_rejection != &"":
		_record_crown_warden_rejection(manager_rejection)
		return false
	if not _ensure_runtime_scene_root():
		_record_crown_warden_rejection(&"runtime_root_unavailable")
		return false
	if not _persist_progress(CROWN_WARDEN_ARENA_SCENE_ID):
		_record_crown_warden_rejection(&"state_persist_failed")
		return false
	if not _request_scene_change(
		CROWN_WARDEN_ARENA_SCENE_ID,
		CROWN_WARDEN_ENTRY_SPAWN
	):
		_record_crown_warden_rejection(&"request_rejected")
		return false
	_crown_warden_transition_requested = true
	_last_crown_warden_rejected_reason = &""
	_last_crown_warden_request = {
		"scene_id": String(CROWN_WARDEN_ARENA_SCENE_ID),
		"spawn_point": String(CROWN_WARDEN_ENTRY_SPAWN),
		"pending_scene": _get_pending_scene(),
		"pending_spawn_point": _get_pending_spawn_point(),
	}
	_sync_crown_warden_route()
	_refresh_objective_text()
	return true


## Called by the guard controller after activation, reset, or defeat.
func persist_central_tower_threshold_progress() -> bool:
	if not _is_valid_scene_manager(_scene_manager):
		return false
	return _persist_progress()


func get_local_state() -> Dictionary:
	var state: Dictionary = {
		"central_tower_threshold_roost_activated": _threshold_roost_activated,
		"central_tower_threshold_last_savepoint": (
			_last_discovered_savepoint.duplicate(true)
		),
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
	}
	if _guard_controller != null:
		state.merge(_guard_controller.get_local_state(), true)
	if _inner_relay_controller != null:
		state.merge(_inner_relay_controller.get_local_state(), true)
	if _cooling_shaft_controller != null:
		state.merge(_cooling_shaft_controller.get_local_state(), true)
	if _deep_lift_controller != null:
		state.merge(_deep_lift_controller.get_local_state(), true)
	if _apex_purge_controller != null:
		state.merge(_apex_purge_controller.get_local_state(), true)
	return state


func set_local_state(state: Dictionary) -> void:
	_threshold_roost_activated = bool(state.get(
		"central_tower_threshold_roost_activated",
		_threshold_roost_activated
	)) or _threshold_roost_activated
	var savepoint_value: Variant = state.get(
		"central_tower_threshold_last_savepoint",
		_last_discovered_savepoint
	)
	if savepoint_value is Dictionary:
		_last_discovered_savepoint = Dictionary(savepoint_value).duplicate(true)
	if _threshold_roost_activated and _last_discovered_savepoint.is_empty():
		_last_discovered_savepoint = _build_threshold_roost_state()
	_restore_player_unlocked_abilities(state)
	if _guard_controller != null:
		_guard_controller.set_local_state(state)
	if _inner_relay_controller != null:
		_inner_relay_controller.set_local_state(state)
	_sync_inner_relay_prerequisite()
	if _cooling_shaft_controller != null:
		_cooling_shaft_controller.set_local_state(state)
	_sync_cooling_shaft_prerequisite()
	if _deep_lift_controller != null:
		_deep_lift_controller.set_local_state(state)
	_sync_deep_lift_prerequisite()
	if _apex_purge_controller != null:
		_apex_purge_controller.set_local_state(state)
	_sync_apex_purge_prerequisite()
	_return_transition_requested = false
	_last_return_rejected_reason = &""
	_last_return_request.clear()
	_crown_warden_transition_requested = false
	_last_crown_warden_rejected_reason = &""
	_last_crown_warden_request.clear()
	_last_player_hit_metadata.clear()
	_last_enemy_hit_metadata.clear()
	_sync_return_route()
	_sync_crown_warden_route()
	_refresh_objective_text()
	_apply_current_scene_manager_spawn_point()


## Captures the JSON-safe Central Tower snapshot used by Roost autosave.
func capture_save_snapshot() -> Dictionary:
	return {
		"player_state": {
			"current_hp": int(_player.call("get_current_hp")) if (
				_player != null and _player.has_method("get_current_hp")
			) else 0,
			"max_hp": int(_player.call("get_max_hp")) if (
				_player != null and _player.has_method("get_max_hp")
			) else 0,
			"unlocked_abilities": _get_player_unlocked_ability_strings(),
		},
		"world_state": {
			"scene_id": String(SCENE_ID),
			"scene_states": {
				String(SCENE_ID): get_local_state(),
			},
			"last_savepoint": get_last_discovered_savepoint(),
		},
		"settings": {},
	}


func capture_no_loss_state() -> Dictionary:
	return get_local_state()


func restore_no_loss_state(snapshot: Dictionary) -> void:
	var restored_snapshot: Dictionary = snapshot.duplicate(true)
	var cleared_after_snapshot: bool = (
		_guard_controller != null
		and bool(_guard_controller.get_local_state().get(
			"central_tower_threshold_guard_defeated",
			false
		))
	)
	var inner_state: Dictionary = (
		_inner_relay_controller.get_local_state()
		if _inner_relay_controller != null
		else {}
	)
	var mantis_cleared_after_snapshot: bool = bool(inner_state.get(
		"central_tower_relay_mantis_defeated",
		false
	))
	var cache_claimed_after_snapshot: bool = bool(inner_state.get(
		"central_tower_inner_cache_claimed",
		false
	))
	var cooling_state: Dictionary = (
		_cooling_shaft_controller.get_local_state()
		if _cooling_shaft_controller != null
		else {}
	)
	var cooling_roost_after_snapshot: bool = bool(cooling_state.get(
		"central_tower_cooling_shaft_roost_activated",
		false
	))
	var cooling_activated_after_snapshot: bool = bool(cooling_state.get(
		"central_tower_cooling_shaft_activated",
		false
	))
	var cooling_traversed_after_snapshot: bool = bool(cooling_state.get(
		"central_tower_cooling_shaft_traversed",
		false
	))
	var deep_lift_state: Dictionary = (
		_deep_lift_controller.get_local_state()
		if _deep_lift_controller != null
		else {}
	)
	var sentry_cleared_after_snapshot: bool = bool(deep_lift_state.get(
		"central_tower_counterweight_sentry_defeated",
		false
	))
	var deep_lift_ascended_after_snapshot: bool = bool(deep_lift_state.get(
		"central_tower_deep_lift_ascended",
		false
	))
	var apex_state: Dictionary = (
		_apex_purge_controller.get_local_state()
		if _apex_purge_controller != null
		else {}
	)
	var apex_roost_after_snapshot: bool = bool(apex_state.get(
		"central_tower_apex_roost_activated",
		false
	))
	var apex_secured_after_snapshot: bool = bool(apex_state.get(
		"central_tower_apex_approach_secured",
		false
	))
	if cleared_after_snapshot:
		restored_snapshot["central_tower_threshold_guard_activated"] = true
		restored_snapshot["central_tower_threshold_guard_defeated"] = true
	if mantis_cleared_after_snapshot:
		restored_snapshot["central_tower_inner_relay_activated"] = true
		restored_snapshot["central_tower_inner_relay_parried"] = true
		restored_snapshot["central_tower_relay_mantis_activated"] = true
		restored_snapshot["central_tower_relay_mantis_defeated"] = true
	if cache_claimed_after_snapshot:
		restored_snapshot["central_tower_inner_cache_claimed"] = true
	if cooling_roost_after_snapshot:
		restored_snapshot["central_tower_cooling_shaft_roost_activated"] = true
		restored_snapshot["central_tower_cooling_shaft_last_savepoint"] = (
			cooling_state.get(
				"central_tower_cooling_shaft_last_savepoint",
				{}
			)
		)
	if cooling_activated_after_snapshot:
		restored_snapshot["central_tower_cooling_shaft_activated"] = true
	if cooling_traversed_after_snapshot:
		restored_snapshot["central_tower_cooling_shaft_traversed"] = true
	if sentry_cleared_after_snapshot:
		restored_snapshot["central_tower_counterweight_sentry_defeated"] = true
	if deep_lift_ascended_after_snapshot:
		restored_snapshot["central_tower_counterweight_sentry_defeated"] = true
		restored_snapshot["central_tower_deep_lift_ascended"] = true
	if apex_roost_after_snapshot:
		restored_snapshot["central_tower_apex_roost_activated"] = true
		restored_snapshot["central_tower_apex_last_savepoint"] = apex_state.get(
			"central_tower_apex_last_savepoint",
			{}
		)
	if apex_secured_after_snapshot:
		restored_snapshot["central_tower_apex_roost_activated"] = true
		restored_snapshot["central_tower_apex_approach_secured"] = true
	set_local_state(restored_snapshot)
	if (
		_guard_controller != null
		and not bool(_guard_controller.get_local_state().get(
			"central_tower_threshold_guard_defeated",
			false
		))
	):
		_guard_controller.reset_failed_attempt()
	if (
		_inner_relay_controller != null
		and not bool(_inner_relay_controller.get_local_state().get(
			"central_tower_relay_mantis_defeated",
			false
		))
	):
		_inner_relay_controller.reset_failed_attempt()
	if (
		_deep_lift_controller != null
		and not bool(_deep_lift_controller.get_local_state().get(
			"central_tower_counterweight_sentry_defeated",
			false
		))
	):
		_deep_lift_controller.reset_failed_attempt()
	if (
		_apex_purge_controller != null
		and not bool(_apex_purge_controller.get_local_state().get(
			"central_tower_apex_approach_secured",
			false
		))
	):
		_apex_purge_controller.reset_failed_attempt()
	_persist_progress()


func get_last_discovered_savepoint() -> Dictionary:
	if _apex_purge_controller != null:
		var apex_savepoint: Dictionary = (
			_apex_purge_controller.get_last_discovered_savepoint()
		)
		if not apex_savepoint.is_empty():
			return apex_savepoint
	if _cooling_shaft_controller != null:
		var cooling_savepoint: Dictionary = (
			_cooling_shaft_controller.get_last_discovered_savepoint()
		)
		if not cooling_savepoint.is_empty():
			return cooling_savepoint
	return _last_discovered_savepoint.duplicate(true)


func get_central_tower_threshold_diagnostics() -> Dictionary:
	var diagnostics: Dictionary = (
		_guard_controller.get_diagnostics()
		if _guard_controller != null
		else {
			"controller_present": false,
			"encounter_state": "missing",
		}
	)
	diagnostics.merge({
		"scene_id": String(SCENE_ID),
		"scene_size_px": Vector2i(6400, 720),
		"background_texture_path": _texture_path(_background),
		"background_expected_path": BACKGROUND_TEXTURE_PATH,
		"service_spine_background_texture_path": _texture_path(
			_service_spine_background
		),
		"service_spine_background_expected_path": SERVICE_SPINE_BACKGROUND_PATH,
		"threshold_roost_texture_path": _savepoint_texture_path(),
		"threshold_roost_expected_path": ROOST_TEXTURE_PATH,
		"threshold_roost_activated": _threshold_roost_activated,
		"last_discovered_savepoint": get_last_discovered_savepoint(),
		"arrival_spawn_position": (
			_arrival_spawn.global_position
			if _arrival_spawn != null
			else Vector2.ZERO
		),
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"return_target_scene_id": String(ROOFTOPS_SCENE_ID),
		"return_spawn_point": String(ROOFTOPS_RETURN_SPAWN),
		"return_transition_requested": _return_transition_requested,
		"last_return_rejected_reason": String(_last_return_rejected_reason),
		"last_return_request": _last_return_request.duplicate(true),
		"objective_text": _objective_label.text if _objective_label != null else "",
		"flow_state": String(_game_flow.get_flow_state()) if _game_flow != null else "",
		"player_control_locked": _is_room_player_control_locked(),
		"music_id": String(TOWER_MUSIC_ID),
		"ambient_id": String(TOWER_AMBIENT_ID),
		"audio_request_count": _audio_request_count,
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
	}, true)
	return diagnostics


## Returns Story141's second-viewport diagnostics plus shared scene state.
func get_central_tower_inner_relay_diagnostics() -> Dictionary:
	var diagnostics: Dictionary = (
		_inner_relay_controller.get_diagnostics()
		if _inner_relay_controller != null
		else {
			"controller_present": false,
			"encounter_state": "missing",
		}
	)
	diagnostics.merge({
		"scene_id": String(SCENE_ID),
		"scene_size_px": Vector2i(6400, 720),
		"background_texture_path": _texture_path(_service_spine_background),
		"background_expected_path": SERVICE_SPINE_BACKGROUND_PATH,
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"arrival_spawn_position": (
			_arrival_spawn.global_position
			if _arrival_spawn != null
			else Vector2.ZERO
		),
		"threshold_roost_activated": _threshold_roost_activated,
		"flow_state": String(_game_flow.get_flow_state()) if _game_flow != null else "",
		"player_control_locked": _is_room_player_control_locked(),
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
	}, true)
	return diagnostics


## Returns Story142's third-viewport diagnostics plus shared scene state.
func get_central_tower_cooling_shaft_diagnostics() -> Dictionary:
	var diagnostics: Dictionary = (
		_cooling_shaft_controller.get_diagnostics()
		if _cooling_shaft_controller != null
		else {
			"controller_present": false,
			"hazard_phase": "missing",
		}
	)
	diagnostics.merge({
		"scene_id": String(SCENE_ID),
		"scene_size_px": Vector2i(6400, 720),
		"background_texture_path": _texture_path(_cooling_shaft_background),
		"background_expected_path": COOLING_SHAFT_BACKGROUND_PATH,
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"last_discovered_savepoint": get_last_discovered_savepoint(),
		"flow_state": String(_game_flow.get_flow_state()) if _game_flow != null else "",
		"player_control_locked": _is_room_player_control_locked(),
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
	}, true)
	return diagnostics


## Returns Story143's fourth-viewport diagnostics plus shared scene state.
func get_central_tower_deep_lift_diagnostics() -> Dictionary:
	var diagnostics: Dictionary = (
		_deep_lift_controller.get_diagnostics()
		if _deep_lift_controller != null
		else {
			"controller_present": false,
			"phase": "missing",
		}
	)
	diagnostics.merge({
		"scene_id": String(SCENE_ID),
		"scene_size_px": Vector2i(6400, 720),
		"background_texture_path": _texture_path(_deep_lift_background),
		"background_expected_path": DEEP_LIFT_BACKGROUND_PATH,
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"last_discovered_savepoint": get_last_discovered_savepoint(),
		"flow_state": String(_game_flow.get_flow_state()) if _game_flow != null else "",
		"player_control_locked": _is_room_player_control_locked(),
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
	}, true)
	return diagnostics


## Returns Story144's fifth-viewport diagnostics plus shared scene state.
func get_central_tower_apex_diagnostics() -> Dictionary:
	var diagnostics: Dictionary = (
		_apex_purge_controller.get_diagnostics()
		if _apex_purge_controller != null
		else {
			"controller_present": false,
			"phase": "missing",
		}
	)
	diagnostics.merge({
		"scene_id": String(SCENE_ID),
		"scene_size_px": Vector2i(6400, 720),
		"background_texture_path": _texture_path(_apex_conduit_background),
		"background_expected_path": APEX_CONDUIT_BACKGROUND_PATH,
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"last_discovered_savepoint": get_last_discovered_savepoint(),
		"flow_state": String(_game_flow.get_flow_state()) if _game_flow != null else "",
		"player_control_locked": _is_room_player_control_locked(),
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
	}, true)
	return diagnostics


## Returns Story145's gate, spawn, request, and generated-art evidence.
func get_crown_warden_route_diagnostics() -> Dictionary:
	return {
		"scene_id": String(SCENE_ID),
		"target_scene_id": String(CROWN_WARDEN_ARENA_SCENE_ID),
		"target_spawn_point": String(CROWN_WARDEN_ENTRY_SPAWN),
		"return_spawn_point": String(APEX_APPROACH_RETURN_SPAWN),
		"available": (
			bool(_crown_warden_route.call("is_route_available"))
			if _crown_warden_route != null
			and _crown_warden_route.has_method("is_route_available")
			else false
		),
		"prompt_text": (
			String(_crown_warden_route.call("get_prompt_text"))
			if _crown_warden_route != null
			and _crown_warden_route.has_method("get_prompt_text")
			else ""
		),
		"transition_requested": _crown_warden_transition_requested,
		"last_rejected_reason": String(_last_crown_warden_rejected_reason),
		"last_request": _last_crown_warden_request.duplicate(true),
		"apex_approach_secured": _is_apex_approach_secured(),
		"return_position": (
			_apex_approach_return_spawn.global_position
			if _apex_approach_return_spawn != null
			else Vector2.ZERO
		),
	}


func _setup_weapon_component() -> void:
	_weapon_component = get_node_or_null("WeaponComponent") as WeaponComponent
	if _weapon_component == null:
		_weapon_component = WEAPON_COMPONENT_SCRIPT.new() as WeaponComponent
		_weapon_component.name = "WeaponComponent"
		add_child(_weapon_component)
	var data_manager: Node = get_node_or_null("/root/DataManager")
	if data_manager != null:
		_weapon_component.set_data_manager(data_manager)


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
			var player_combat: CombatComponent = _player.call(
				"get_combat_component"
			)
			_weapon_component.set_combat_adapter(player_combat)
			if (
				player_combat != null
				and not player_combat.on_parry_resolved.is_connected(
					_on_player_parry_resolved
				)
			):
				player_combat.on_parry_resolved.connect(
					_on_player_parry_resolved
				)
		if _player.has_method("get_collision_component"):
			_weapon_component.set_collision_adapter(_player.call(
				"get_collision_component"
			))
	if _player.has_signal("attack_landed"):
		var attack_signal: Signal = _player.get("attack_landed")
		if not attack_signal.is_connected(_on_player_attack_landed):
			attack_signal.connect(_on_player_attack_landed)


func _on_player_attack_landed(metadata: Dictionary) -> void:
	var presentation_data: Dictionary = metadata.duplicate(true)
	if _hud != null and _hud.has_method("are_damage_numbers_enabled"):
		presentation_data["show_damage_number"] = _hud.are_damage_numbers_enabled()
	_last_player_hit_metadata = presentation_data.duplicate(true)
	if _combat_presentation != null:
		_combat_presentation.on_hit_event(presentation_data)
	_dispatch_combat_audio(&"on_hit_event", presentation_data)


func _setup_combat_presentation() -> void:
	if _combat_presentation == null or _player == null:
		return
	if _camera != null:
		_combat_presentation.set_camera(_camera)
	if _hitstop_input_bridge != null:
		_hitstop_input_bridge.configure(
			_combat_presentation,
			_player as PlayerController,
			get_node_or_null("/root/InputManager")
		)
	for enemy_path: NodePath in PRESENTATION_ENEMY_PATHS:
		var enemy: Node = get_node_or_null(enemy_path)
		if enemy == null or not enemy.has_signal("enemy_attack_landed"):
			continue
		var attack_signal: Signal = enemy.get("enemy_attack_landed")
		if not attack_signal.is_connected(_on_enemy_attack_landed):
			attack_signal.connect(_on_enemy_attack_landed)


func _on_enemy_attack_landed(
	damage: int,
	hit_position: Vector2,
	is_crit: bool
) -> void:
	_last_enemy_hit_metadata = {
		"damage": damage,
		"hit_position": hit_position,
		"is_crit": is_crit,
		"source": &"central_tower_enemy",
	}
	if _hud != null and _hud.has_method("are_damage_numbers_enabled"):
		_last_enemy_hit_metadata["show_damage_number"] = (
			_hud.are_damage_numbers_enabled()
		)
	if _combat_presentation != null:
		_combat_presentation.on_hit_event(_last_enemy_hit_metadata)
	_dispatch_combat_audio(&"on_damage_taken_event", _last_enemy_hit_metadata)


func _on_player_parry_resolved(parry_data: Dictionary) -> void:
	if _combat_presentation == null or _player == null:
		return
	var presentation_data: Dictionary = parry_data.duplicate(true)
	var parry_position: Vector2 = _player.global_position
	var sprite: AnimatedSprite2D = _player.get_node_or_null(
		"Sprite"
	) as AnimatedSprite2D
	if sprite != null:
		parry_position = sprite.global_position
		if sprite.sprite_frames != null:
			var frame_texture: Texture2D = sprite.sprite_frames.get_frame_texture(
				sprite.animation,
				sprite.frame
			)
			if frame_texture != null:
				presentation_data["texture"] = frame_texture
		presentation_data["facing"] = -1.0 if sprite.flip_h else 1.0
		presentation_data["animation"] = sprite.animation
		presentation_data["frame"] = sprite.frame
	if not presentation_data.has("position"):
		presentation_data["position"] = parry_position
	presentation_data["source"] = &"player_parry"
	_combat_presentation.on_parry_event(presentation_data)
	_dispatch_combat_audio(&"on_parry_event", presentation_data)


func _dispatch_combat_audio(method: StringName, metadata: Dictionary) -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method(method):
		audio_system.call(method, metadata)


func _setup_guard_controller() -> void:
	if _guard_controller == null:
		return
	if not _guard_controller.objective_changed.is_connected(
		_on_guard_objective_changed
	):
		_guard_controller.objective_changed.connect(_on_guard_objective_changed)
	_guard_controller.configure_runtime(_player, self)
	_sync_inner_relay_prerequisite()


func _on_guard_objective_changed(_objective_text: String) -> void:
	_sync_inner_relay_prerequisite()
	_refresh_objective_text()


func _setup_inner_relay_controller() -> void:
	if _inner_relay_controller == null:
		return
	if not _inner_relay_controller.objective_changed.is_connected(
		_on_inner_relay_objective_changed
	):
		_inner_relay_controller.objective_changed.connect(
			_on_inner_relay_objective_changed
		)
	_inner_relay_controller.configure_runtime(_player, self)
	_sync_inner_relay_prerequisite()


func _on_inner_relay_objective_changed(_objective_text: String) -> void:
	_sync_cooling_shaft_prerequisite()
	_refresh_objective_text()


func _sync_inner_relay_prerequisite() -> void:
	if _inner_relay_controller == null:
		return
	_inner_relay_controller.set_threshold_cleared(
		_is_threshold_guard_defeated()
	)


func _is_threshold_guard_defeated() -> bool:
	return (
		_guard_controller != null
		and bool(_guard_controller.get_local_state().get(
			"central_tower_threshold_guard_defeated",
			false
		))
	)


func _setup_cooling_shaft_controller() -> void:
	if _cooling_shaft_controller == null:
		return
	if not _cooling_shaft_controller.objective_changed.is_connected(
		_on_cooling_shaft_objective_changed
	):
		_cooling_shaft_controller.objective_changed.connect(
			_on_cooling_shaft_objective_changed
		)
	_cooling_shaft_controller.configure_runtime(_player, self)
	_sync_cooling_shaft_prerequisite()


func _on_cooling_shaft_objective_changed(_objective_text: String) -> void:
	_sync_deep_lift_prerequisite()
	_refresh_objective_text()


func _sync_cooling_shaft_prerequisite() -> void:
	if _cooling_shaft_controller == null:
		return
	_cooling_shaft_controller.set_route_unlocked(
		_is_relay_mantis_defeated()
	)


func _is_relay_mantis_defeated() -> bool:
	return (
		_inner_relay_controller != null
		and bool(_inner_relay_controller.get_local_state().get(
			"central_tower_relay_mantis_defeated",
			false
		))
	)


func _setup_deep_lift_controller() -> void:
	if _deep_lift_controller == null:
		return
	if not _deep_lift_controller.objective_changed.is_connected(
		_on_deep_lift_objective_changed
	):
		_deep_lift_controller.objective_changed.connect(
			_on_deep_lift_objective_changed
		)
	_deep_lift_controller.configure_runtime(_player, self)
	_sync_deep_lift_prerequisite()


func _on_deep_lift_objective_changed(_objective_text: String) -> void:
	_sync_apex_purge_prerequisite()
	_refresh_objective_text()


func _sync_deep_lift_prerequisite() -> void:
	if _deep_lift_controller == null:
		return
	_deep_lift_controller.set_route_unlocked(
		_is_cooling_shaft_traversed()
	)


func _is_cooling_shaft_traversed() -> bool:
	return (
		_cooling_shaft_controller != null
		and bool(_cooling_shaft_controller.get_local_state().get(
			"central_tower_cooling_shaft_traversed",
			false
		))
	)


func _setup_apex_purge_controller() -> void:
	if _apex_purge_controller == null:
		return
	if not _apex_purge_controller.objective_changed.is_connected(
		_on_apex_purge_objective_changed
	):
		_apex_purge_controller.objective_changed.connect(
			_on_apex_purge_objective_changed
		)
	var save_system: Node = get_node_or_null("/root/SaveSystem")
	_apex_purge_controller.configure_runtime(_player, self, save_system)
	_sync_apex_purge_prerequisite()


func _on_apex_purge_objective_changed(_objective_text: String) -> void:
	_sync_crown_warden_route()
	_refresh_objective_text()


func _sync_apex_purge_prerequisite() -> void:
	if _apex_purge_controller == null:
		return
	_apex_purge_controller.set_route_unlocked(_is_deep_lift_ascended())


func _is_deep_lift_ascended() -> bool:
	return (
		_deep_lift_controller != null
		and bool(_deep_lift_controller.get_local_state().get(
			"central_tower_deep_lift_ascended",
			false
		))
	)


func _setup_threshold_roost() -> void:
	if _threshold_roost == null:
		return
	if not _threshold_roost.savepoint_activated.is_connected(
		_on_threshold_roost_activated
	):
		_threshold_roost.savepoint_activated.connect(_on_threshold_roost_activated)
	call_deferred("_activate_threshold_roost_on_first_entry")


func _activate_threshold_roost_on_first_entry() -> void:
	if _threshold_roost_activated or _threshold_roost == null:
		return
	_threshold_roost.try_activate(_player)


func _on_threshold_roost_activated(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2,
	context: Dictionary
) -> void:
	if savepoint_id != THRESHOLD_ROOST_ID or scene_id != SCENE_ID:
		return
	_threshold_roost_activated = true
	_last_discovered_savepoint = context.duplicate(true)
	var respawn_position: Vector2 = (
		_arrival_spawn.global_position
		if _arrival_spawn != null
		else world_position
	)
	_last_discovered_savepoint["id"] = String(savepoint_id)
	_last_discovered_savepoint["scene_id"] = String(scene_id)
	_last_discovered_savepoint["spawn_point"] = String(spawn_point)
	_last_discovered_savepoint["position"] = {
		"x": respawn_position.x,
		"y": respawn_position.y,
	}
	_persist_progress()


func _setup_game_flow() -> void:
	if _game_flow == null or _arrival_spawn == null:
		return
	_game_flow.set_process(false)
	_game_flow.start_encounter(_arrival_spawn.global_position)
	_game_flow.configure_clan_base_respawn(
		SCENE_ID,
		ENTRY_SPAWN_POINT,
		_arrival_spawn.global_position
	)
	_game_flow.set_savepoint_adapter(self)
	_game_flow.set_no_loss_state_adapter(self)
	if not _game_flow.respawn_requested.is_connected(_on_respawn_requested):
		_game_flow.respawn_requested.connect(_on_respawn_requested)
	if _player != null and _player.has_signal("player_died"):
		var death_signal: Signal = _player.get("player_died")
		if not death_signal.is_connected(_on_player_died):
			death_signal.connect(_on_player_died)


func _on_player_died(_metadata: Dictionary) -> void:
	if _game_flow == null:
		return
	_game_flow.handle_player_death()
	if _player != null and _player.has_method("set_control_locked"):
		_player.call("set_control_locked", true)


func _on_respawn_requested(
	respawn_position: Vector2,
	revive_hp_percentage: float
) -> void:
	if _player != null and _player.has_method("respawn_at"):
		_player.call("respawn_at", respawn_position, revive_hp_percentage)
	if _hud != null and _player != null:
		_hud.update_hp(
			int(_player.call("get_current_hp")),
			int(_player.call("get_max_hp"))
		)


func _is_room_player_control_locked() -> bool:
	return _game_flow != null and _game_flow.get_flow_state() == &"dying"


func _setup_player_hud() -> void:
	if _player == null or _hud == null:
		return
	if _player.has_signal("player_health_changed"):
		var health_signal: Signal = _player.get("player_health_changed")
		if not health_signal.is_connected(_on_player_health_changed):
			health_signal.connect(_on_player_health_changed)
	if _player.has_method("get_current_hp") and _player.has_method("get_max_hp"):
		_hud.update_hp(
			int(_player.call("get_current_hp")),
			int(_player.call("get_max_hp"))
		)


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	if _hud != null:
		_hud.update_hp(current_hp, max_hp)


func _sync_return_route() -> void:
	if _return_route == null:
		return
	if _return_route.has_method("set_route_available"):
		_return_route.call("set_route_available", true)
	if _return_route.has_method("set_transition_requested"):
		_return_route.call(
			"set_transition_requested",
			_return_transition_requested
		)
	_sync_return_prompt_visibility()


func _sync_crown_warden_route() -> void:
	if _crown_warden_route == null:
		return
	if _crown_warden_route.has_method("set_route_available"):
		_crown_warden_route.call(
			"set_route_available",
			_is_apex_approach_secured()
		)
	if _crown_warden_route.has_method("set_transition_requested"):
		_crown_warden_route.call(
			"set_transition_requested",
			_crown_warden_transition_requested
		)


func _sync_return_prompt_visibility() -> void:
	if _return_prompt != null:
		_return_prompt.visible = (
			not _return_transition_requested
			and _is_provider_near_return(_player)
		)


func _refresh_objective_text() -> void:
	if _objective_label == null:
		return
	if _crown_warden_transition_requested:
		_objective_label.text = "Entering Crown Observatory"
	elif _return_transition_requested:
		_objective_label.text = "Returning to Neon Rooftops"
	elif (
		_apex_purge_controller != null
		and _apex_purge_controller.should_own_objective(_player)
	):
		_objective_label.text = _apex_purge_controller.get_objective_text()
	elif (
		_deep_lift_controller != null
		and _deep_lift_controller.should_own_objective(_player)
	):
		_objective_label.text = _deep_lift_controller.get_objective_text()
	elif (
		_cooling_shaft_controller != null
		and _cooling_shaft_controller.should_own_objective(_player)
	):
		_objective_label.text = _cooling_shaft_controller.get_objective_text()
	elif (
		_inner_relay_controller != null
		and _inner_relay_controller.should_own_objective(_player)
	):
		_objective_label.text = _inner_relay_controller.get_objective_text()
	elif _guard_controller != null:
		_objective_label.text = _guard_controller.get_objective_text()
	else:
		_objective_label.text = "Cross the Tower Threshold"


func _sync_objective_position() -> void:
	if _objective_label == null or _camera == null or not _camera.is_inside_tree():
		return
	_objective_label.position = (
		_camera.get_screen_center_position() + Vector2(-250.0, -288.0)
	)


func _request_threshold_audio() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	if audio_system.has_method("play_music"):
		audio_system.call("play_music", TOWER_MUSIC_ID, AUDIO_FADE_SEC)
		_audio_request_count += 1
	if audio_system.has_method("play_ambient"):
		audio_system.call("play_ambient", TOWER_AMBIENT_ID, AUDIO_FADE_SEC)
		_audio_request_count += 1


func _align_player_to_arrival() -> bool:
	if _player == null or _arrival_spawn == null:
		return false
	_player.global_position = _arrival_spawn.global_position
	if _player is CharacterBody2D:
		(_player as CharacterBody2D).velocity = Vector2.ZERO
	return true


func _apply_current_scene_manager_spawn_point() -> void:
	if not _is_valid_scene_manager(_scene_manager):
		_align_player_to_arrival()
		return
	if _scene_manager.has_method("get_current_scene") and StringName(
		_scene_manager.call("get_current_scene")
	) != SCENE_ID:
		return
	var spawn_point: StringName = ENTRY_SPAWN_POINT
	if _scene_manager.has_method("get_current_spawn_point"):
		spawn_point = StringName(_scene_manager.call("get_current_spawn_point"))
	if spawn_point in [ENTRY_SPAWN_POINT, &"default"]:
		_align_player_to_arrival()
	elif (
		spawn_point == COOLING_SHAFT_SPAWN_POINT
		and _cooling_shaft_controller != null
	):
		_cooling_shaft_controller.align_player_to_roost()
	elif (
		spawn_point == APEX_ROOST_SPAWN_POINT
		and _apex_purge_controller != null
	):
		_apex_purge_controller.align_player_to_roost()
	elif (
		spawn_point == APEX_APPROACH_RETURN_SPAWN
		and _apex_approach_return_spawn != null
		and _player != null
	):
		_player.global_position = _apex_approach_return_spawn.global_position
		if _player is CharacterBody2D:
			(_player as CharacterBody2D).velocity = Vector2.ZERO


func _build_threshold_roost_state() -> Dictionary:
	var spawn_position: Vector2 = (
		_arrival_spawn.global_position
		if _arrival_spawn != null
		else (_threshold_roost.global_position if _threshold_roost != null else Vector2.ZERO)
	)
	return {
		"id": String(THRESHOLD_ROOST_ID),
		"scene_id": String(SCENE_ID),
		"spawn_point": String(ENTRY_SPAWN_POINT),
		"display_name": "Threshold Roost",
		"position": {"x": spawn_position.x, "y": spawn_position.y},
	}


func _is_provider_near_return(provider: Node) -> bool:
	return (
		_return_route != null
		and provider != null
		and _return_route.has_method("is_provider_in_transition_range")
		and bool(_return_route.call("is_provider_in_transition_range", provider))
	)


func _is_provider_near_crown_warden_route(provider: Node) -> bool:
	return (
		_crown_warden_route != null
		and provider != null
		and _crown_warden_route.has_method(
			"is_provider_in_transition_range"
		)
		and bool(_crown_warden_route.call(
			"is_provider_in_transition_range",
			provider
		))
	)


func _is_apex_approach_secured() -> bool:
	return (
		_apex_purge_controller != null
		and bool(_apex_purge_controller.get_local_state().get(
			"central_tower_apex_approach_secured",
			false
		))
	)


func _persist_progress(
	target_scene_id: StringName = ROOFTOPS_SCENE_ID
) -> bool:
	if (
		not _is_valid_scene_manager(_scene_manager)
		or not _scene_manager.has_method("set_scene_state")
	):
		return false
	var persisted: bool = bool(_scene_manager.call(
		"set_scene_state",
		SCENE_ID,
		get_local_state()
	))
	return _merge_player_abilities_into_scene_state(target_scene_id) and persisted


func _scene_manager_rejection_for(scene_id: StringName) -> StringName:
	if not _is_valid_scene_manager(_scene_manager):
		return &"scene_manager_missing"
	if _scene_manager.has_method("is_loading") and bool(
		_scene_manager.call("is_loading")
	):
		return &"scene_manager_loading"
	if _scene_manager.has_method("is_scene_locked") and bool(
		_scene_manager.call("is_scene_locked")
	):
		return &"scene_locked"
	if _scene_manager.has_method("has_scene") and not bool(
		_scene_manager.call("has_scene", scene_id)
	):
		return &"unknown_scene"
	return &""


func _merge_player_abilities_into_scene_state(scene_id: StringName) -> bool:
	if (
		_scene_manager.has_method("has_scene")
		and not bool(_scene_manager.call("has_scene", scene_id))
	):
		return false
	var state: Dictionary = {}
	if _scene_manager.has_method("get_scene_state"):
		state = Dictionary(_scene_manager.call("get_scene_state", scene_id)).duplicate(true)
	var abilities: Array = Array(state.get("unlocked_abilities", []))
	for ability_id: String in _get_player_unlocked_ability_strings():
		if not abilities.has(ability_id):
			abilities.append(ability_id)
	state["unlocked_abilities"] = abilities
	return bool(_scene_manager.call("set_scene_state", scene_id, state))


func _can_use_scene_manager_for(scene_id: StringName) -> bool:
	if not _is_valid_scene_manager(_scene_manager):
		_record_return_rejection(&"scene_manager_missing")
		return false
	if _scene_manager.has_method("is_loading") and bool(
		_scene_manager.call("is_loading")
	):
		_record_return_rejection(&"scene_manager_loading")
		return false
	if _scene_manager.has_method("is_scene_locked") and bool(
		_scene_manager.call("is_scene_locked")
	):
		_record_return_rejection(&"scene_locked")
		return false
	if _scene_manager.has_method("has_scene") and not bool(
		_scene_manager.call("has_scene", scene_id)
	):
		_record_return_rejection(&"unknown_scene")
		return false
	return true


func _ensure_runtime_scene_root() -> bool:
	if not _scene_manager.has_method("configure_runtime_scene_root"):
		return true
	if _scene_manager.has_method("is_runtime_scene_swap_enabled") and bool(
		_scene_manager.call("is_runtime_scene_swap_enabled")
	):
		return true
	return bool(_scene_manager.call(
		"configure_runtime_scene_root",
		get_parent(),
		self
	))


func _request_scene_change(scene_id: StringName, spawn_point: StringName) -> bool:
	if _scene_manager.has_method("request_scene_change"):
		return bool(_scene_manager.call(
			"request_scene_change",
			scene_id,
			spawn_point
		))
	if _scene_manager.has_method("change_scene"):
		return bool(_scene_manager.call("change_scene", scene_id, spawn_point))
	return false


func _get_player_unlocked_ability_strings() -> Array[String]:
	var unlocked: Array[String] = []
	if _player == null or not _player.has_method("get_unlocked_abilities"):
		return unlocked
	var values: Variant = _player.call("get_unlocked_abilities")
	if not values is Array:
		return unlocked
	for value: Variant in values:
		var ability_id: String = String(value)
		if not unlocked.has(ability_id):
			unlocked.append(ability_id)
	return unlocked


func _restore_player_unlocked_abilities(state: Dictionary) -> void:
	if _player == null or not _player.has_method("set_unlocked_abilities"):
		return
	_player.call(
		"set_unlocked_abilities",
		Array(state.get(
			"unlocked_abilities",
			_get_player_unlocked_ability_strings()
		))
	)


func _savepoint_texture_path() -> String:
	return (
		_threshold_roost.get_visual_texture_path()
		if _threshold_roost != null
		else ""
	)


func _texture_path(sprite: Sprite2D) -> String:
	return (
		sprite.texture.resource_path
		if sprite != null and sprite.texture != null
		else ""
	)


func _record_return_rejection(reason: StringName) -> void:
	_last_return_rejected_reason = reason


func _record_crown_warden_rejection(reason: StringName) -> void:
	_last_crown_warden_rejected_reason = reason
	_last_crown_warden_request.clear()


func _get_pending_scene() -> String:
	return (
		String(_scene_manager.call("get_pending_scene"))
		if _scene_manager.has_method("get_pending_scene")
		else ""
	)


func _get_pending_spawn_point() -> String:
	return (
		String(_scene_manager.call("get_pending_spawn_point"))
		if _scene_manager.has_method("get_pending_spawn_point")
		else ""
	)


func _is_valid_scene_manager(scene_manager: Object) -> bool:
	return (
		scene_manager != null
		and is_instance_valid(scene_manager)
		and (
			scene_manager.has_method("request_scene_change")
			or scene_manager.has_method("change_scene")
		)
	)
