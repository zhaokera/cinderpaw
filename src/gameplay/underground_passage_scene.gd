## Underground entry, corrosion-channel combat slice, and Factory return route.
extends Node2D

const SCENE_ID: StringName = &"area_04_underground_passage"
const ENTRY_SPAWN_POINT: StringName = &"factory_drop_entry"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_RETURN_SPAWN_POINT: StringName = &"tailrace_underground_return"
const FACTORY_UPPER_ALTAR_SCENE_ID: StringName = &"area_03_factory_upper_altar"
const FACTORY_UPPER_ALTAR_SPAWN_POINT: StringName = &"cistern_ascender_arrival"
const DEEP_CISTERN_ASCENDER_RETURN_SPAWN: StringName = (
	&"deep_cistern_ascender_return"
)
const ROUTE_WIDTH_PX: int = 5120
const ENCOUNTER_ACTIVATION_X: float = 1450.0
const CORROSION_LEFT_ENTITY_ID: int = 2401
const CORROSION_RIGHT_ENTITY_ID: int = 2402
const CORROSION_ENCOUNTER_ID: StringName = &"underground_corrosion_channel"
const CORROSION_LEFT_SUMMON_ID: StringName = &"underground_corrosion_left"
const CORROSION_RIGHT_SUMMON_ID: StringName = &"underground_corrosion_right"
const CORROSION_HAZARD_ID: StringName = &"underground_corrosive_runoff"
const CORROSION_CACHE_ID: StringName = &"underground_corrosion_salvage"
const UNDERGROUND_PLAYER_LIGHT_DAMAGE: int = 12
const UNDERGROUND_MUSIC_ID: StringName = &"mus_sewer"
const UNDERGROUND_AMBIENT_ID: StringName = &"amb_sewer"
const UNDERGROUND_AUDIO_FADE_SEC: float = 0.45
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/underground_passage/"
	+ "env_underground_passage_entry_1280x720.png"
)
const CORROSION_BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/underground_passage/"
	+ "env_underground_corrosion_channel_1280x720.png"
)
const CORROSIVE_RUNOFF_TEXTURE_PATH: String = (
	"res://assets/environment/underground_passage/"
	+ "prop_underground_corrosive_runoff_512x160.png"
)
const CORROSION_SEAL_TEXTURE_PATH: String = (
	"res://assets/environment/underground_passage/"
	+ "prop_underground_seal_gate_256x384.png"
)
const CORROSION_CACHE_TEXTURE_PATH: String = (
	"res://assets/environment/underground_passage/"
	+ "prop_underground_salvage_cache_256x256.png"
)
const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")

@onready var _background: Sprite2D = get_node_or_null("Background") as Sprite2D
@onready var _corrosion_background: Sprite2D = (
	get_node_or_null("CorrosionChannelBackground") as Sprite2D
)
@onready var _entry_spawn: Marker2D = (
	get_node_or_null("UndergroundEntrySpawn") as Marker2D
)
@onready var _player: Node2D = get_node_or_null("Player") as Node2D
@onready var _camera: Camera2D = get_node_or_null("Player/Camera2D") as Camera2D
@onready var _return_route: Node = get_node_or_null("FactoryReturnRoute")
@onready var _corrosive_runoff: Area2D = (
	get_node_or_null("CorrosiveRunoffHazard") as Area2D
)
@onready var _encounter_back_seal: StaticBody2D = (
	get_node_or_null("EncounterBackSeal") as StaticBody2D
)
@onready var _encounter_forward_seal: StaticBody2D = (
	get_node_or_null("EncounterForwardSeal") as StaticBody2D
)
@onready var _corrosion_leech_left: Node2D = (
	get_node_or_null("CorrosionLeechLeft") as Node2D
)
@onready var _corrosion_leech_right: Node2D = (
	get_node_or_null("CorrosionLeechRight") as Node2D
)
@onready var _corrosion_salvage_cache: Node = (
	get_node_or_null("CorrosionSalvageCache")
)
@onready var _corrosion_salvage_prompt: Label = (
	get_node_or_null("CorrosionSalvageCache/PromptLabel") as Label
)
@onready var _objective_label: Label = (
	get_node_or_null("UndergroundObjectiveLabel") as Label
)
@onready var _recovery_cistern: Node = (
	get_node_or_null("RecoveryCisternController")
)
@onready var _deep_cistern_ambush: Node = (
	get_node_or_null("DeepCisternAmbushController")
)
@onready var _deep_cistern_ascender: Node = (
	get_node_or_null("DeepCisternAscenderRouteController")
)
@onready var _hud: HUDManager = get_node_or_null("HUD") as HUDManager
@onready var _combat_presentation: CombatPresentation = (
	get_node_or_null("CombatPresentation") as CombatPresentation
)
@onready var _hitstop_input_bridge: HitstopInputBridge = (
	get_node_or_null("HitstopInputBridge") as HitstopInputBridge
)

var _scene_manager: Object = null
var _weapon_component: WeaponComponent = null
var _return_transition_requested: bool = false
var _last_return_rejected_reason: StringName = &""
var _last_return_request: Dictionary = {}
var _corrosion_channel_activated: bool = false
var _corrosion_left_defeated: bool = false
var _corrosion_right_defeated: bool = false
var _corrosion_channel_cleared: bool = false
var _corrosion_salvage_claimed: bool = false
var _corrosion_elapsed_sec: float = 0.0
var _corrosion_contact_cooldowns: Dictionary = {}
var _hazard_accepted_contacts: int = 0
var _last_hazard_damage: Dictionary = {}
var _last_player_hit_metadata: Dictionary = {}
var _last_enemy_hit_metadata: Dictionary = {}
var _kill_feedback_emitted_by_entity: Dictionary = {}
var _kill_feedback_count: int = 0
var _last_reward: Dictionary = {}
var _reward_audio_request_count: int = 0
var _last_reward_audio_event: Dictionary = {}


func _ready() -> void:
	_align_player_to_entry_spawn()
	_setup_weapon_component()
	_bind_player_combat_to_room()
	_setup_player_hud()
	_setup_corrosive_runoff()
	_setup_corrosion_enemies()
	_setup_corrosion_salvage_cache()
	_setup_recovery_cistern()
	_setup_deep_cistern_ambush()
	_setup_deep_cistern_ascender()
	_setup_combat_presentation()
	_sync_corrosion_slice_state()
	_sync_return_route()
	_request_underground_audio()
	_sync_objective_position()
	var root_scene_manager: Node = get_node_or_null("/root/SceneManager")
	if _is_valid_scene_manager(root_scene_manager):
		configure_scene_manager_runtime(root_scene_manager)


func _process(delta: float) -> void:
	advance_corrosive_runoff_time(delta)
	_auto_activate_corrosion_channel_encounter()
	_process_corrosion_salvage_contact()
	_process_factory_return_contact()
	_sync_corrosion_cache_prompt_visibility()
	_refresh_objective_text()
	_sync_objective_position()


## Injects SceneManager and reapplies the requested Underground spawn.
func configure_scene_manager_runtime(scene_manager: Object) -> bool:
	_scene_manager = scene_manager
	if not _is_valid_scene_manager(_scene_manager):
		return false
	_setup_combat_presentation()
	if (
		_deep_cistern_ascender != null
		and _deep_cistern_ascender.has_method(
			"configure_scene_manager_runtime"
		)
	):
		_deep_cistern_ascender.call(
			"configure_scene_manager_runtime",
			_scene_manager
		)
	_apply_current_scene_manager_spawn_point()
	return true


## Configures Story132 autosave through a SaveSystem-like runtime adapter.
func configure_underground_save_system_runtime(save_system: Object) -> bool:
	if (
		_recovery_cistern == null
		or not _recovery_cistern.has_method("configure_save_system_runtime")
	):
		return false
	return bool(_recovery_cistern.call(
		"configure_save_system_runtime",
		save_system
	))


## Attempts the one-shot Story132 recovery relay activation.
func try_activate_recovery_cistern_savepoint(provider: Node = null) -> bool:
	if _recovery_cistern == null or not _recovery_cistern.has_method("try_activate_relay"):
		return false
	return bool(_recovery_cistern.call("try_activate_relay", provider))


## Routes Story132's lethal fall through the dedicated controller.
func apply_recovery_cistern_fall(target: Node = null) -> bool:
	if _recovery_cistern == null or not _recovery_cistern.has_method("apply_fall"):
		return false
	return bool(_recovery_cistern.call("apply_fall", target))


## Advances Story132's deterministic death and revive timers.
func advance_underground_recovery_respawn_flow(delta_sec: float) -> void:
	if _recovery_cistern != null and _recovery_cistern.has_method(
		"advance_respawn_flow"
	):
		_recovery_cistern.call("advance_respawn_flow", delta_sec)


## Attempts the one-shot Story132 deep-route endpoint activation.
func try_activate_recovery_cistern_endpoint(provider: Node = null) -> bool:
	if (
		_recovery_cistern == null
		or not _recovery_cistern.has_method("try_activate_endpoint")
	):
		return false
	return bool(_recovery_cistern.call("try_activate_endpoint", provider))


## Attempts the one-shot Story133 deep-cistern ambush activation.
func try_activate_deep_cistern_ambush(provider: Node = null) -> bool:
	if (
		_deep_cistern_ambush == null
		or not _deep_cistern_ambush.has_method("try_activate")
	):
		return false
	return bool(_deep_cistern_ambush.call("try_activate", provider))


## Requests the Story133 Stalker attack for deterministic runtime probes.
func request_deep_cistern_stalker_attack() -> bool:
	if (
		_deep_cistern_ambush == null
		or not _deep_cistern_ambush.has_method("request_stalker_attack")
	):
		return false
	return bool(_deep_cistern_ambush.call("request_stalker_attack"))


## Requests the Story134 ascender handoff after the Stalker is defeated.
func try_request_deep_cistern_ascender(provider: Node = null) -> bool:
	if (
		_deep_cistern_ascender == null
		or not _deep_cistern_ascender.has_method("try_request_transition")
	):
		return false
	return bool(_deep_cistern_ascender.call(
		"try_request_transition",
		provider
	))


## Captures the JSON-safe Underground snapshot used by savepoint autosave.
func capture_save_snapshot() -> Dictionary:
	var last_savepoint: Dictionary = {}
	if _recovery_cistern != null and _recovery_cistern.has_method(
		"get_last_discovered_savepoint"
	):
		last_savepoint = Dictionary(_recovery_cistern.call(
			"get_last_discovered_savepoint"
		)).duplicate(true)
	return {
		"player_state": {
			"current_hp": _get_target_current_hp(_player),
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
			"last_savepoint": last_savepoint,
		},
		"settings": {},
	}


## Starts the corrosion-channel encounter once the provider crosses its threshold.
func try_activate_corrosion_channel_encounter(provider: Node = null) -> bool:
	if (
		_corrosion_channel_activated
		or _corrosion_channel_cleared
		or not _is_provider_past_encounter_threshold(provider)
	):
		return false
	_corrosion_channel_activated = true
	_sync_corrosion_slice_state()
	return true


## Routes player hit-confirm damage to the matching Underground enemy entity.
func apply_damage(
	target_id: int,
	final_damage: int,
	metadata: Dictionary = {}
) -> bool:
	if (
		_deep_cistern_ambush != null
		and _deep_cistern_ambush.has_method("handles_target_id")
		and bool(_deep_cistern_ambush.call("handles_target_id", target_id))
		and _deep_cistern_ambush.has_method("apply_damage")
	):
		return bool(_deep_cistern_ambush.call(
			"apply_damage",
			target_id,
			final_damage,
			metadata
		))
	var damage_target: Node = _get_corrosion_enemy_by_entity_id(target_id)
	if (
		damage_target == null
		or final_damage <= 0
		or not damage_target.has_method("apply_damage")
	):
		return false
	damage_target.call("apply_damage", final_damage, metadata)
	_sync_corrosion_damage_target_defeat(target_id, damage_target)
	return true


## Supplies deterministic room damage through the shared CombatComponent adapter.
func calculate_damage(
	_attack_type: StringName,
	weapon_id: StringName,
	_hit_frame: int,
	combo_index: int,
	_parry_timing: int,
	_attack_power: int,
	_enemy_defense: int,
	_skill_modifiers: Dictionary = {},
	_injected_damage_params: Dictionary = {},
	_data_manager: Object = null
) -> Dictionary:
	var final_damage: int = UNDERGROUND_PLAYER_LIGHT_DAMAGE
	var damage_category: StringName = &"scratch"
	if weapon_id == FactorySluiceLeech.SLUICE_LEECH_ATTACK_HITBOX_ID:
		final_damage = FactorySluiceLeech.SLUICE_LEECH_BITE_DAMAGE
		damage_category = &"bite"
	return {
		"final_damage": final_damage,
		"base_damage": final_damage,
		"attack_damage": float(final_damage),
		"reduction_factor": 1.0,
		"damage_multiplier": 1.0,
		"is_crit": false,
		"crit_type": &"none",
		"parry_type": &"none",
		"combo_stage": combo_index,
		"damage_category": damage_category,
	}


## Returns the most recent player hit-confirm payload observed by this room.
func get_last_player_hit_metadata() -> Dictionary:
	return _last_player_hit_metadata.duplicate(true)


## Returns the most recent applied Underground enemy attack payload.
func get_last_enemy_hit_metadata() -> Dictionary:
	return _last_enemy_hit_metadata.duplicate(true)


## Returns the last action released from Underground hitstop.
func get_last_buffered_input_result() -> Dictionary:
	if _hitstop_input_bridge == null:
		return {}
	return _hitstop_input_bridge.get_last_buffered_input_result()


## Returns focused runtime evidence for Underground combat impact.
func get_underground_combat_presentation_diagnostics() -> Dictionary:
	var bridge_diagnostics: Dictionary = {}
	if _hitstop_input_bridge != null:
		bridge_diagnostics = _hitstop_input_bridge.get_diagnostics()
	var kill_feedback_entity_ids: Array = (
		_kill_feedback_emitted_by_entity.keys()
	)
	kill_feedback_entity_ids.sort()
	return {
		"presentation_present": _combat_presentation != null,
		"bridge_present": _hitstop_input_bridge != null,
		"bridge": bridge_diagnostics,
		"last_player_hit": _last_player_hit_metadata.duplicate(true),
		"last_enemy_hit": _last_enemy_hit_metadata.duplicate(true),
		"kill_feedback_count": _kill_feedback_count,
		"kill_feedback_entity_ids": kill_feedback_entity_ids,
		"hitstop_active": (
			_combat_presentation.is_gameplay_hitstop_active()
			if _combat_presentation != null
			else false
		),
		"hitstop_frames_remaining": (
			_combat_presentation.get_hitstop_frames_remaining()
			if _combat_presentation != null
			else 0
		),
		"last_completed_hitstop_frames": (
			_combat_presentation.get_last_completed_hitstop_frames()
			if _combat_presentation != null
			else 0
		),
		"damage_number_count": (
			_combat_presentation.get_active_damage_number_count()
			if _combat_presentation != null
			else 0
		),
		"spark_count": (
			_combat_presentation.get_active_spark_count()
			if _combat_presentation != null
			else 0
		),
		"debris_count": (
			_combat_presentation.get_active_debris_count()
			if _combat_presentation != null
			else 0
		),
	}


## Applies corrosive runoff damage with a deterministic per-target cooldown.
func apply_corrosive_runoff_contact(hazard: Area2D, target: Node) -> bool:
	if (
		hazard == null
		or target == null
		or target != _player
		or hazard != _corrosive_runoff
		or not _is_corrosive_runoff_active(hazard)
	):
		return false
	var hazard_id: StringName = _get_hazard_id(hazard)
	if hazard_id != CORROSION_HAZARD_ID:
		return false
	var cooldown_key: String = "%s:%d" % [
		String(hazard_id),
		PlayerController.PLAYER_ENTITY_ID,
	]
	var next_allowed_sec: float = float(
		_corrosion_contact_cooldowns.get(cooldown_key, -1.0)
	)
	if next_allowed_sec > _corrosion_elapsed_sec:
		return false
	var damage: int = _get_hazard_damage(hazard)
	var hp_before: int = _get_target_current_hp(target)
	var damage_data: Dictionary = {
		"damage": damage,
		"final_damage": damage,
		"hit_position": hazard.global_position,
		"is_crit": false,
		"source": hazard_id,
		"damage_type": &"corrosion",
		"scene_id": SCENE_ID,
		"target_id": PlayerController.PLAYER_ENTITY_ID,
	}
	if target.has_method("apply_damage"):
		target.call("apply_damage", damage, damage_data)
	var hp_after: int = _get_target_current_hp(target)
	if hp_after >= hp_before:
		return false
	_corrosion_contact_cooldowns[cooldown_key] = (
		_corrosion_elapsed_sec + _get_hazard_contact_cooldown_sec(hazard)
	)
	_hazard_accepted_contacts += 1
	_last_hazard_damage = damage_data.duplicate(true)
	return true


## Advances only the scene-local hazard clock used by deterministic cooldowns.
func advance_corrosive_runoff_time(delta_sec: float) -> void:
	_corrosion_elapsed_sec += maxf(delta_sec, 0.0)


## Attempts the one-time post-combat salvage claim for a nearby provider.
func try_claim_corrosion_salvage(provider: Node = null) -> bool:
	if (
		_corrosion_salvage_cache == null
		or not _corrosion_salvage_cache.has_method("try_claim")
	):
		return false
	var claim_provider: Node = _player if provider == null else provider
	if claim_provider == null:
		return false
	return bool(_corrosion_salvage_cache.call("try_claim", claim_provider))


## Requests the repeatable Factory return once per Underground visit.
func try_request_factory_return(provider: Node = null) -> bool:
	if _return_route == null or _return_transition_requested:
		_record_return_rejection(&"transition_already_requested")
		return false
	var request_provider: Node = _player if provider == null else provider
	if not _return_route.has_method("can_request_transition") \
			or not bool(_return_route.call("can_request_transition", request_provider)):
		_record_return_rejection(&"provider_out_of_range")
		return false
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if not _is_valid_scene_manager(scene_manager):
		_record_return_rejection(&"scene_manager_missing")
		return false
	if scene_manager.has_method("is_loading") and bool(scene_manager.call("is_loading")):
		_record_return_rejection(&"scene_manager_loading")
		return false
	if scene_manager.has_method("is_scene_locked") \
			and bool(scene_manager.call("is_scene_locked")):
		_record_return_rejection(&"scene_locked")
		return false
	if scene_manager.has_method("has_scene") \
			and not bool(scene_manager.call("has_scene", FACTORY_SCENE_ID)):
		_record_return_rejection(&"unknown_scene")
		return false
	if not _ensure_runtime_scene_root(scene_manager):
		_record_return_rejection(&"runtime_root_unavailable")
		return false
	_persist_progress_to_scene_manager(scene_manager)
	if not _request_scene_change(
		scene_manager,
		FACTORY_SCENE_ID,
		FACTORY_RETURN_SPAWN_POINT
	):
		_record_return_rejection(&"request_rejected")
		return false

	_return_transition_requested = true
	_last_return_rejected_reason = &""
	_last_return_request = {
		"scene_id": String(FACTORY_SCENE_ID),
		"spawn_point": String(FACTORY_RETURN_SPAWN_POINT),
		"pending_scene": _get_pending_scene(scene_manager),
		"pending_spawn_point": _get_pending_spawn_point(scene_manager),
	}
	_return_route.call("set_transition_requested", true)
	if _objective_label != null:
		_objective_label.text = "Returning to Factory Tailrace"
	return true


## Captures durable discovery, encounter, reward, and ability state.
func get_local_state() -> Dictionary:
	var state: Dictionary = {
		"underground_passage_discovered": true,
		"underground_corrosion_channel_activated": _corrosion_channel_activated,
		"underground_corrosion_left_defeated": _corrosion_left_defeated,
		"underground_corrosion_right_defeated": _corrosion_right_defeated,
		"underground_corrosion_channel_cleared": _is_corrosion_channel_cleared(),
		"underground_corrosion_salvage_claimed": _corrosion_salvage_claimed,
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
	}
	if _recovery_cistern != null and _recovery_cistern.has_method("get_local_state"):
		state.merge(
			Dictionary(_recovery_cistern.call("get_local_state")),
			true
		)
	if (
		_deep_cistern_ambush != null
		and _deep_cistern_ambush.has_method("get_local_state")
	):
		state.merge(
			Dictionary(_deep_cistern_ambush.call("get_local_state")),
			true
		)
	if (
		_deep_cistern_ascender != null
		and _deep_cistern_ascender.has_method("get_local_state")
	):
		state.merge(
			Dictionary(_deep_cistern_ascender.call("get_local_state")),
			true
		)
	return state


## Restores durable progress while clearing transient request and cooldown latches.
func set_local_state(state: Dictionary) -> void:
	_return_transition_requested = false
	_last_return_rejected_reason = &""
	_last_return_request.clear()
	_corrosion_elapsed_sec = 0.0
	_corrosion_contact_cooldowns.clear()
	_hazard_accepted_contacts = 0
	_last_hazard_damage.clear()
	_last_player_hit_metadata.clear()
	_last_enemy_hit_metadata.clear()
	_kill_feedback_emitted_by_entity.clear()
	_kill_feedback_count = 0
	_last_reward.clear()
	_corrosion_salvage_claimed = bool(state.get(
		"underground_corrosion_salvage_claimed",
		false
	))
	var saved_cleared: bool = bool(state.get(
		"underground_corrosion_channel_cleared",
		_corrosion_salvage_claimed
	))
	_corrosion_left_defeated = bool(state.get(
		"underground_corrosion_left_defeated",
		saved_cleared
	))
	_corrosion_right_defeated = bool(state.get(
		"underground_corrosion_right_defeated",
		saved_cleared
	))
	_corrosion_channel_cleared = (
		saved_cleared
		or _corrosion_salvage_claimed
		or (_corrosion_left_defeated and _corrosion_right_defeated)
	)
	if _corrosion_channel_cleared:
		_corrosion_left_defeated = true
		_corrosion_right_defeated = true
	if _corrosion_left_defeated:
		_kill_feedback_emitted_by_entity[CORROSION_LEFT_ENTITY_ID] = true
	if _corrosion_right_defeated:
		_kill_feedback_emitted_by_entity[CORROSION_RIGHT_ENTITY_ID] = true
	_corrosion_channel_activated = bool(state.get(
		"underground_corrosion_channel_activated",
		_corrosion_channel_cleared
			or _corrosion_left_defeated
			or _corrosion_right_defeated
	))
	_restore_player_unlocked_abilities(state)
	if _recovery_cistern != null and _recovery_cistern.has_method("set_local_state"):
		_recovery_cistern.call("set_local_state", state)
	if (
		_deep_cistern_ambush != null
		and _deep_cistern_ambush.has_method("set_local_state")
	):
		_deep_cistern_ambush.call("set_local_state", state)
	if bool(state.get(
		"underground_deep_cistern_stalker_defeated",
		false
	)):
		_kill_feedback_emitted_by_entity[
			UndergroundDeepCisternAmbushController.STALKER_ENTITY_ID
		] = true
	if (
		_deep_cistern_ascender != null
		and _deep_cistern_ascender.has_method("set_local_state")
	):
		_deep_cistern_ascender.call("set_local_state", state)
	_sync_corrosion_slice_state()
	_setup_deep_cistern_ambush()
	_setup_deep_cistern_ascender()
	_setup_combat_presentation()
	_sync_return_route()
	_align_player_to_entry_spawn()


## Returns scene, art, spawn, and return-route details for Story130 verification.
func get_underground_handoff_diagnostics() -> Dictionary:
	var background_path: String = ""
	if _background != null and _background.texture != null:
		background_path = _background.texture.resource_path
	return {
		"scene_id": String(SCENE_ID),
		"background_texture_path": background_path,
		"background_expected_path": BACKGROUND_TEXTURE_PATH,
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"entry_spawn_position": (
			_entry_spawn.global_position if _entry_spawn != null else Vector2.ZERO
		),
		"return_route_present": _return_route != null,
		"return_route_available": (
			bool(_return_route.call("is_route_available"))
			if _return_route != null and _return_route.has_method("is_route_available")
			else false
		),
		"return_target_scene_id": String(FACTORY_SCENE_ID),
		"return_spawn_point": String(FACTORY_RETURN_SPAWN_POINT),
		"return_transition_requested": _return_transition_requested,
		"return_rejected_reason": String(_last_return_rejected_reason),
		"last_return_request": _last_return_request.duplicate(true),
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
		"objective_text": _objective_label.text if _objective_label != null else "",
		"combat_state": String(_get_corrosion_encounter_state()),
	}


## Returns authored layout and live encounter state for tests and MCP probes.
func get_underground_combat_diagnostics() -> Dictionary:
	return {
		"route_width_px": ROUTE_WIDTH_PX,
		"activation_x": ENCOUNTER_ACTIVATION_X,
		"stepping_platform_count": 3,
		"background_texture_path": _get_sprite_texture_path(_corrosion_background),
		"background_expected_path": CORROSION_BACKGROUND_TEXTURE_PATH,
		"runoff_texture_path": _get_hazard_visual_texture_path(_corrosive_runoff),
		"runoff_expected_path": CORROSIVE_RUNOFF_TEXTURE_PATH,
		"seal_texture_path": _get_seal_texture_path(_encounter_forward_seal),
		"seal_expected_path": CORROSION_SEAL_TEXTURE_PATH,
		"cache_texture_path": _get_cache_visual_texture_path(),
		"cache_expected_path": CORROSION_CACHE_TEXTURE_PATH,
		"encounter_state": String(_get_corrosion_encounter_state()),
		"encounter_activated": _corrosion_channel_activated,
		"encounter_cleared": _is_corrosion_channel_cleared(),
		"enemy_count": 2,
		"enemy_entity_ids": [CORROSION_LEFT_ENTITY_ID, CORROSION_RIGHT_ENTITY_ID],
		"active_enemy_count": _get_active_corrosion_enemy_count(),
		"left_defeated": _corrosion_left_defeated,
		"right_defeated": _corrosion_right_defeated,
		"left_has_target": _enemy_has_attack_target(_corrosion_leech_left),
		"right_has_target": _enemy_has_attack_target(_corrosion_leech_right),
		"left_animation": _get_enemy_animation(_corrosion_leech_left),
		"right_animation": _get_enemy_animation(_corrosion_leech_right),
		"weapon_component_present": _weapon_component != null,
		"back_seal_x": (
			_encounter_back_seal.global_position.x
			if _encounter_back_seal != null
			else 0.0
		),
		"forward_seal_x": (
			_encounter_forward_seal.global_position.x
			if _encounter_forward_seal != null
			else 0.0
		),
		"back_seal_blocking": _is_seal_blocking(_encounter_back_seal),
		"forward_seal_blocking": _is_seal_blocking(_encounter_forward_seal),
		"hazard_damage": _get_hazard_damage(_corrosive_runoff),
		"hazard_contact_cooldown_sec": (
			_get_hazard_contact_cooldown_sec(_corrosive_runoff)
		),
		"hazard_accepted_contacts": _hazard_accepted_contacts,
		"last_hazard_damage": _last_hazard_damage.duplicate(true),
		"cache_available": _is_corrosion_cache_available(),
		"cache_claimed": _corrosion_salvage_claimed,
		"cache_prompt_visible": (
			_corrosion_salvage_prompt.visible
			if _corrosion_salvage_prompt != null
			else false
		),
		"last_reward": _last_reward.duplicate(true),
		"reward_audio_request_count": _reward_audio_request_count,
		"last_reward_audio_event": _last_reward_audio_event.duplicate(true),
		"objective_text": _objective_label.text if _objective_label != null else "",
	}


## Returns the dedicated Story132 recovery-cistern diagnostics surface.
func get_underground_recovery_cistern_diagnostics() -> Dictionary:
	if _recovery_cistern != null and _recovery_cistern.has_method("get_diagnostics"):
		return Dictionary(_recovery_cistern.call("get_diagnostics")).duplicate(true)
	return {
		"route_width_px": ROUTE_WIDTH_PX,
		"controller_present": false,
	}


## Returns the dedicated Story133 encounter diagnostics surface.
func get_underground_deep_cistern_diagnostics() -> Dictionary:
	if (
		_deep_cistern_ambush != null
		and _deep_cistern_ambush.has_method("get_diagnostics")
	):
		return Dictionary(_deep_cistern_ambush.call(
			"get_diagnostics"
		)).duplicate(true)
	return {
		"route_width_px": ROUTE_WIDTH_PX,
		"controller_present": false,
	}


## Returns the dedicated Story134 deep-cistern ascender diagnostics surface.
func get_deep_cistern_ascender_diagnostics() -> Dictionary:
	if (
		_deep_cistern_ascender != null
		and _deep_cistern_ascender.has_method("get_diagnostics")
	):
		return Dictionary(_deep_cistern_ascender.call(
			"get_diagnostics"
		)).duplicate(true)
	return {
		"controller_present": false,
		"target_scene_id": String(FACTORY_UPPER_ALTAR_SCENE_ID),
		"target_spawn_point": String(FACTORY_UPPER_ALTAR_SPAWN_POINT),
	}


## Captures durable Underground state across the no-loss death loop.
func capture_no_loss_state() -> Dictionary:
	return get_local_state()


## Restores durable Underground state across the no-loss death loop.
func restore_no_loss_state(snapshot: Dictionary) -> void:
	set_local_state(snapshot)


func _setup_weapon_component() -> void:
	_weapon_component = get_node_or_null("WeaponComponent") as WeaponComponent
	if _weapon_component == null:
		_weapon_component = WEAPON_COMPONENT_SCRIPT.new() as WeaponComponent
		_weapon_component.name = "WeaponComponent"
		add_child(_weapon_component)
	var root_data_manager: Node = get_node_or_null("/root/DataManager")
	if root_data_manager != null:
		_weapon_component.set_data_manager(root_data_manager)


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


func _setup_corrosive_runoff() -> void:
	if _corrosive_runoff == null:
		return
	if not _corrosive_runoff.area_entered.is_connected(
		_on_corrosive_runoff_area_entered
	):
		_corrosive_runoff.area_entered.connect(_on_corrosive_runoff_area_entered)
	if not _corrosive_runoff.body_entered.is_connected(
		_on_corrosive_runoff_body_entered
	):
		_corrosive_runoff.body_entered.connect(_on_corrosive_runoff_body_entered)


func _setup_corrosion_enemies() -> void:
	_configure_corrosion_enemy(
		_corrosion_leech_left,
		CORROSION_LEFT_ENTITY_ID,
		CORROSION_LEFT_SUMMON_ID,
		_on_corrosion_left_defeated
	)
	_configure_corrosion_enemy(
		_corrosion_leech_right,
		CORROSION_RIGHT_ENTITY_ID,
		CORROSION_RIGHT_SUMMON_ID,
		_on_corrosion_right_defeated
	)


func _setup_corrosion_salvage_cache() -> void:
	if (
		_corrosion_salvage_cache == null
		or not _corrosion_salvage_cache.has_signal("cache_claimed")
	):
		return
	var claimed_signal: Signal = _corrosion_salvage_cache.get("cache_claimed")
	if not claimed_signal.is_connected(_on_corrosion_salvage_claimed):
		claimed_signal.connect(_on_corrosion_salvage_claimed)


func _setup_recovery_cistern() -> void:
	if _recovery_cistern == null:
		return
	if _recovery_cistern.has_signal("objective_changed"):
		var objective_signal: Signal = _recovery_cistern.get("objective_changed")
		if not objective_signal.is_connected(
			_on_recovery_cistern_objective_changed
		):
			objective_signal.connect(_on_recovery_cistern_objective_changed)
	if _recovery_cistern.has_method("configure_runtime"):
		_recovery_cistern.call(
			"configure_runtime",
			_player,
			self,
			get_node_or_null("/root/SaveSystem")
		)
	if _recovery_cistern.has_method("set_route_unlocked"):
		_recovery_cistern.call(
			"set_route_unlocked",
			_is_corrosion_channel_cleared()
		)


func _setup_deep_cistern_ambush() -> void:
	if _deep_cistern_ambush == null:
		return
	if _deep_cistern_ambush.has_signal("objective_changed"):
		var objective_signal: Signal = _deep_cistern_ambush.get(
			"objective_changed"
		)
		if not objective_signal.is_connected(
			_on_deep_cistern_objective_changed
		):
			objective_signal.connect(_on_deep_cistern_objective_changed)
	if _deep_cistern_ambush.has_method("configure_runtime"):
		_deep_cistern_ambush.call("configure_runtime", _player, self)
	if _deep_cistern_ambush.has_method("set_route_unlocked"):
		_deep_cistern_ambush.call(
			"set_route_unlocked",
			_is_recovery_cistern_traversed()
		)
	_setup_deep_cistern_ascender()


func _setup_deep_cistern_ascender() -> void:
	if _deep_cistern_ascender == null:
		return
	if _deep_cistern_ascender.has_signal("objective_changed"):
		var objective_signal: Signal = _deep_cistern_ascender.get(
			"objective_changed"
		)
		if not objective_signal.is_connected(
			_on_deep_cistern_ascender_objective_changed
		):
			objective_signal.connect(
				_on_deep_cistern_ascender_objective_changed
			)
	if _deep_cistern_ascender.has_method("configure_runtime"):
		_deep_cistern_ascender.call(
			"configure_runtime",
			_player,
			self,
			_scene_manager
		)
	if _deep_cistern_ascender.has_method("set_stalker_defeated"):
		_deep_cistern_ascender.call(
			"set_stalker_defeated",
			_is_deep_cistern_stalker_defeated()
		)


func _on_recovery_cistern_objective_changed(_objective_text: String) -> void:
	_setup_deep_cistern_ambush()
	_refresh_objective_text()


func _on_deep_cistern_objective_changed(_objective_text: String) -> void:
	_setup_deep_cistern_ascender()
	_refresh_objective_text()


func _on_deep_cistern_ascender_objective_changed(
	_objective_text: String
) -> void:
	_refresh_objective_text()


func _configure_corrosion_enemy(
	enemy: Node,
	entity_id: int,
	summon_id: StringName,
	defeated_callback: Callable
) -> void:
	if enemy == null:
		return
	if enemy.has_method("configure_summon"):
		enemy.call(
			"configure_summon",
			CORROSION_ENCOUNTER_ID,
			entity_id,
			summon_id
		)
	if enemy.has_method("set_damage_calculator_adapter"):
		enemy.call("set_damage_calculator_adapter", self)
	if enemy.has_signal("enemy_defeated"):
		var defeated_signal: Signal = enemy.get("enemy_defeated")
		if not defeated_signal.is_connected(defeated_callback):
			defeated_signal.connect(defeated_callback)


func _sync_corrosion_slice_state() -> void:
	_corrosion_channel_cleared = _is_corrosion_channel_cleared()
	_set_corrosion_enemy_active(
		_corrosion_leech_left,
		_corrosion_channel_activated and not _corrosion_left_defeated
	)
	_set_corrosion_enemy_active(
		_corrosion_leech_right,
		_corrosion_channel_activated and not _corrosion_right_defeated
	)
	_set_seal_blocking(
		_encounter_back_seal,
		_corrosion_channel_activated and not _corrosion_channel_cleared
	)
	_set_seal_blocking(_encounter_forward_seal, not _corrosion_channel_cleared)
	if _corrosion_salvage_cache != null:
		if _corrosion_salvage_cache.has_method("set_available"):
			_corrosion_salvage_cache.call(
				"set_available",
				_corrosion_channel_cleared
			)
		if _corrosion_salvage_cache.has_method("set_claimed"):
			_corrosion_salvage_cache.call(
				"set_claimed",
				_corrosion_salvage_claimed
			)
	_sync_corrosion_cache_prompt_visibility()
	_setup_recovery_cistern()
	_setup_deep_cistern_ambush()
	_refresh_objective_text()


func _set_corrosion_enemy_active(enemy: Node2D, active: bool) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return
	var was_active: bool = (
		enemy.visible and enemy.process_mode != Node.PROCESS_MODE_DISABLED
	)
	if active:
		enemy.visible = true
		enemy.process_mode = Node.PROCESS_MODE_INHERIT
		enemy.set_physics_process(true)
		enemy.collision_layer = 2
		enemy.collision_mask = 17
		if enemy.has_method("set_attack_target"):
			enemy.call("set_attack_target", _player)
		if not was_active and enemy.has_method("begin_pacing"):
			enemy.call("begin_pacing")
		return
	if enemy.has_method("set_attack_target"):
		enemy.call("set_attack_target", null)
	enemy.set_physics_process(false)
	enemy.process_mode = Node.PROCESS_MODE_DISABLED
	enemy.collision_layer = 0
	enemy.collision_mask = 0
	enemy.visible = false


func _set_seal_blocking(seal: StaticBody2D, blocking: bool) -> void:
	if seal == null:
		return
	seal.visible = blocking
	seal.collision_layer = 16 if blocking else 0
	seal.collision_mask = 0
	var collision_shape: CollisionShape2D = (
		seal.get_node_or_null("CollisionShape2D") as CollisionShape2D
	)
	if collision_shape != null:
		collision_shape.set_deferred("disabled", not blocking)


func _auto_activate_corrosion_channel_encounter() -> void:
	if _player == null or _corrosion_channel_activated or _corrosion_channel_cleared:
		return
	try_activate_corrosion_channel_encounter(_player)


func _process_corrosion_salvage_contact() -> void:
	if (
		_player == null
		or _corrosion_salvage_cache == null
		or not _corrosion_salvage_cache.has_method("is_claim_available")
		or not bool(_corrosion_salvage_cache.call("is_claim_available"))
		or not _corrosion_salvage_cache.has_method("is_provider_in_reward_range")
	):
		return
	if bool(_corrosion_salvage_cache.call(
		"is_provider_in_reward_range",
		_player
	)):
		try_claim_corrosion_salvage(_player)


func _sync_corrosion_cache_prompt_visibility() -> void:
	if _corrosion_salvage_prompt == null:
		return
	var provider_in_prompt_range: bool = false
	if _player != null and _corrosion_salvage_cache is Node2D:
		provider_in_prompt_range = _player.global_position.distance_to(
			(_corrosion_salvage_cache as Node2D).global_position
		) <= 192.0
	_corrosion_salvage_prompt.visible = (
		_is_corrosion_cache_available()
		and not _corrosion_salvage_claimed
		and provider_in_prompt_range
	)


func _process_factory_return_contact() -> void:
	if (
		_player == null
		or _return_route == null
		or _return_transition_requested
		or not _return_route.has_method("is_provider_in_transition_range")
	):
		return
	if bool(_return_route.call("is_provider_in_transition_range", _player)):
		try_request_factory_return(_player)


func _on_player_attack_landed(metadata: Dictionary) -> void:
	var presentation_data: Dictionary = metadata.duplicate(true)
	if _hud != null and _hud.has_method("are_damage_numbers_enabled"):
		presentation_data["show_damage_number"] = (
			_hud.are_damage_numbers_enabled()
		)
	_last_player_hit_metadata = presentation_data.duplicate(true)
	if _combat_presentation != null:
		_combat_presentation.on_hit_event(presentation_data)
	_dispatch_combat_audio(&"on_hit_event", presentation_data)
	var target_id: int = int(presentation_data.get("target_id", -1))
	if (
		_is_underground_enemy_defeated(target_id)
		and not _kill_feedback_emitted_by_entity.has(target_id)
	):
		_kill_feedback_emitted_by_entity[target_id] = true
		_kill_feedback_count += 1
		if _combat_presentation != null:
			_combat_presentation.on_kill_event(
				target_id,
				_get_underground_enemy_impact_position(
					target_id,
					presentation_data
				)
			)


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
	if _player.has_method("get_combat_component"):
		var player_combat: CombatComponent = _player.call(
			"get_combat_component"
		) as CombatComponent
		if (
			player_combat != null
			and not player_combat.on_parry_resolved.is_connected(
				_on_player_parry_resolved
			)
		):
			player_combat.on_parry_resolved.connect(
				_on_player_parry_resolved
			)
	_connect_enemy_presentation_signal(
		_corrosion_leech_left,
		_on_left_leech_attack_landed
	)
	_connect_enemy_presentation_signal(
		_corrosion_leech_right,
		_on_right_leech_attack_landed
	)
	var stalker: Node = get_node_or_null(
		"DeepCisternAmbushController/CisternStalker"
	)
	_connect_enemy_presentation_signal(
		stalker,
		_on_cistern_stalker_attack_landed
	)


func _connect_enemy_presentation_signal(
	enemy: Variant,
	callback: Callable
) -> void:
	if not is_instance_valid(enemy):
		return
	var enemy_node: Node = enemy as Node
	if enemy_node == null or not enemy_node.has_signal("enemy_attack_landed"):
		return
	var attack_signal: Signal = enemy_node.get("enemy_attack_landed")
	if not attack_signal.is_connected(callback):
		attack_signal.connect(callback)


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


func _on_left_leech_attack_landed(
	damage: int,
	hit_position: Vector2,
	is_crit: bool
) -> void:
	_on_underground_enemy_attack_landed(
		damage,
		hit_position,
		is_crit,
		&"factory_sluice_leech"
	)


func _on_right_leech_attack_landed(
	damage: int,
	hit_position: Vector2,
	is_crit: bool
) -> void:
	_on_underground_enemy_attack_landed(
		damage,
		hit_position,
		is_crit,
		&"factory_sluice_leech"
	)


func _on_cistern_stalker_attack_landed(
	damage: int,
	hit_position: Vector2,
	is_crit: bool
) -> void:
	_on_underground_enemy_attack_landed(
		damage,
		hit_position,
		is_crit,
		&"underground_cistern_stalker"
	)


func _on_underground_enemy_attack_landed(
	damage: int,
	hit_position: Vector2,
	is_crit: bool,
	source: StringName
) -> void:
	_last_enemy_hit_metadata = {
		"damage": damage,
		"hit_position": hit_position,
		"is_crit": is_crit,
		"source": source,
	}
	if _hud != null and _hud.has_method("are_damage_numbers_enabled"):
		_last_enemy_hit_metadata["show_damage_number"] = (
			_hud.are_damage_numbers_enabled()
		)
	if _combat_presentation != null:
		_combat_presentation.on_hit_event(_last_enemy_hit_metadata)
	_dispatch_combat_audio(
		&"on_damage_taken_event",
		_last_enemy_hit_metadata
	)


func _is_underground_enemy_defeated(target_id: int) -> bool:
	match target_id:
		CORROSION_LEFT_ENTITY_ID:
			return _corrosion_left_defeated
		CORROSION_RIGHT_ENTITY_ID:
			return _corrosion_right_defeated
		UndergroundDeepCisternAmbushController.STALKER_ENTITY_ID:
			return _is_deep_cistern_stalker_defeated()
		_:
			return false


func _get_underground_enemy_impact_position(
	target_id: int,
	metadata: Dictionary
) -> Vector2:
	var hit_position: Variant = metadata.get("hit_position", null)
	if hit_position is Vector2:
		return hit_position as Vector2
	var target: Node2D = null
	match target_id:
		CORROSION_LEFT_ENTITY_ID:
			target = _corrosion_leech_left
		CORROSION_RIGHT_ENTITY_ID:
			target = _corrosion_leech_right
		UndergroundDeepCisternAmbushController.STALKER_ENTITY_ID:
			target = get_node_or_null(
				"DeepCisternAmbushController/CisternStalker"
			) as Node2D
	return target.global_position if target != null else Vector2.ZERO


func _dispatch_combat_audio(
	method: StringName,
	metadata: Dictionary
) -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method(method):
		audio_system.call(method, metadata)


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	if _hud != null:
		_hud.update_hp(current_hp, max_hp)


func _on_corrosion_left_defeated() -> void:
	_corrosion_channel_activated = true
	_corrosion_left_defeated = true
	_sync_corrosion_slice_state()


func _on_corrosion_right_defeated() -> void:
	_corrosion_channel_activated = true
	_corrosion_right_defeated = true
	_sync_corrosion_slice_state()


func _on_corrosion_salvage_claimed(
	cache_id: StringName,
	reward: Dictionary
) -> void:
	if cache_id != CORROSION_CACHE_ID:
		return
	_corrosion_salvage_claimed = true
	_last_reward = reward.duplicate(true)
	_request_corrosion_reward_audio(reward)
	_sync_corrosion_slice_state()


func _on_corrosive_runoff_area_entered(area: Area2D) -> void:
	var target: Node = _resolve_corrosion_target_from_area(area)
	if target != null:
		apply_corrosive_runoff_contact(_corrosive_runoff, target)


func _on_corrosive_runoff_body_entered(body: Node2D) -> void:
	if body == _player:
		apply_corrosive_runoff_contact(_corrosive_runoff, _player)


func _sync_corrosion_damage_target_defeat(
	target_id: int,
	damage_target: Node
) -> void:
	if (
		damage_target == null
		or not damage_target.has_method("get_current_hp")
		or int(damage_target.call("get_current_hp")) > 0
	):
		return
	if target_id == CORROSION_LEFT_ENTITY_ID and not _corrosion_left_defeated:
		_on_corrosion_left_defeated()
	elif target_id == CORROSION_RIGHT_ENTITY_ID and not _corrosion_right_defeated:
		_on_corrosion_right_defeated()


func _refresh_objective_text() -> void:
	if _objective_label == null:
		return
	if (
		_deep_cistern_ascender != null
		and _deep_cistern_ascender.has_method("should_own_objective")
		and bool(_deep_cistern_ascender.call(
			"should_own_objective",
			_player
		))
		and _deep_cistern_ascender.has_method("get_objective_text")
	):
		_objective_label.text = String(_deep_cistern_ascender.call(
			"get_objective_text"
		))
	elif (
		_deep_cistern_ambush != null
		and _deep_cistern_ambush.has_method("should_own_objective")
		and bool(_deep_cistern_ambush.call(
			"should_own_objective",
			_player
		))
		and _deep_cistern_ambush.has_method("get_objective_text")
	):
		_objective_label.text = String(_deep_cistern_ambush.call(
			"get_objective_text"
		))
	elif (
		_recovery_cistern != null
		and _recovery_cistern.has_method("should_own_objective")
		and bool(_recovery_cistern.call("should_own_objective", _player))
		and _recovery_cistern.has_method("get_objective_text")
	):
		_objective_label.text = String(_recovery_cistern.call("get_objective_text"))
	elif _corrosion_salvage_claimed:
		_objective_label.text = "Corrosion Channel Secured"
	elif _is_corrosion_channel_cleared():
		_objective_label.text = "Claim Underground Salvage"
	elif _corrosion_channel_activated:
		_objective_label.text = "Clear Corrosion Channel"
	else:
		_objective_label.text = "Cross Corrosion Runoff"


func _sync_objective_position() -> void:
	if _objective_label == null or _camera == null or not _camera.is_inside_tree():
		return
	_objective_label.position = (
		_camera.get_screen_center_position() + Vector2(-220.0, -288.0)
	)


func _sync_return_route() -> void:
	if _return_route == null:
		return
	if _return_route.has_method("set_route_available"):
		_return_route.call("set_route_available", true)
	if _return_route.has_method("set_transition_requested"):
		_return_route.call("set_transition_requested", _return_transition_requested)


func _align_player_to_entry_spawn() -> void:
	if _player == null or _entry_spawn == null:
		return
	_player.global_position = _entry_spawn.global_position
	if _player is CharacterBody2D:
		(_player as CharacterBody2D).velocity = Vector2.ZERO


func _apply_current_scene_manager_spawn_point() -> void:
	if not _is_valid_scene_manager(_scene_manager):
		return
	if _scene_manager.has_method("get_current_scene") \
			and StringName(_scene_manager.call("get_current_scene")) != SCENE_ID:
		return
	var spawn_point: StringName = ENTRY_SPAWN_POINT
	if _scene_manager.has_method("get_current_spawn_point"):
		spawn_point = StringName(_scene_manager.call("get_current_spawn_point"))
	if spawn_point == ENTRY_SPAWN_POINT or spawn_point == &"default":
		_align_player_to_entry_spawn()
	elif (
		spawn_point == &"recovery_cistern_relay"
		and _recovery_cistern != null
		and _recovery_cistern.has_method("align_player_to_relay")
	):
		_recovery_cistern.call("align_player_to_relay")
	elif (
		spawn_point == DEEP_CISTERN_ASCENDER_RETURN_SPAWN
		and _deep_cistern_ascender != null
		and _deep_cistern_ascender.has_method(
			"align_player_to_return_spawn"
		)
	):
		_deep_cistern_ascender.call("align_player_to_return_spawn")


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
	var fallback: Array[String] = _get_player_unlocked_ability_strings()
	_player.call(
		"set_unlocked_abilities",
		Array(state.get("unlocked_abilities", fallback))
	)


func _persist_progress_to_scene_manager(scene_manager: Object) -> bool:
	if not scene_manager.has_method("set_scene_state"):
		return true
	var persisted: bool = bool(scene_manager.call(
		"set_scene_state",
		SCENE_ID,
		get_local_state()
	))
	if not scene_manager.has_method("get_scene_state"):
		return persisted
	var factory_state: Dictionary = Dictionary(
		scene_manager.call("get_scene_state", FACTORY_SCENE_ID)
	)
	var factory_unlocked: Array = Array(factory_state.get("unlocked_abilities", []))
	for ability_id: String in _get_player_unlocked_ability_strings():
		if not factory_unlocked.has(ability_id):
			factory_unlocked.append(ability_id)
	factory_state["unlocked_abilities"] = factory_unlocked
	return bool(scene_manager.call(
		"set_scene_state",
		FACTORY_SCENE_ID,
		factory_state
	)) and persisted


func _request_underground_audio() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	if audio_system.has_method("play_music"):
		audio_system.call(
			"play_music",
			UNDERGROUND_MUSIC_ID,
			UNDERGROUND_AUDIO_FADE_SEC
		)
	if audio_system.has_method("play_ambient"):
		audio_system.call(
			"play_ambient",
			UNDERGROUND_AMBIENT_ID,
			UNDERGROUND_AUDIO_FADE_SEC
		)


func _request_corrosion_reward_audio(reward: Dictionary) -> void:
	var world_position: Vector2 = Vector2.ZERO
	if _corrosion_salvage_cache is Node2D:
		world_position = (_corrosion_salvage_cache as Node2D).global_position
	var metadata: Dictionary = {
		"cache_id": CORROSION_CACHE_ID,
		"display_name": "Underground Corrosion Salvage",
		"feedback_role": &"reward_cache_claim",
		"gears": int(reward.get("gears", 0)),
		"reward_gears": int(reward.get("gears", 0)),
		"route_label": "Corrosion Channel Secured +20 Gears",
		"scene_id": SCENE_ID,
		"source": CORROSION_CACHE_ID,
		"world_position": world_position,
	}
	_reward_audio_request_count += 1
	_last_reward_audio_event = {
		"event_id": &"reward_cache_claimed",
		"sfx_id": &"sfx_door_unlock",
		"position": world_position,
		"priority": 90,
		"metadata": metadata.duplicate(true),
	}
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null or not audio_system.has_method("on_reward_cache_claimed"):
		return
	audio_system.call(
		"on_reward_cache_claimed",
		CORROSION_CACHE_ID,
		reward,
		world_position,
		metadata
	)
	if audio_system.has_method("get_last_gameplay_audio_event"):
		var runtime_event: Variant = audio_system.call("get_last_gameplay_audio_event")
		if runtime_event is Dictionary:
			_last_reward_audio_event = (runtime_event as Dictionary).duplicate(true)


func _get_corrosion_enemy_by_entity_id(entity_id: int) -> Node:
	if entity_id == CORROSION_LEFT_ENTITY_ID and not _corrosion_left_defeated:
		return _get_valid_node(_corrosion_leech_left)
	if entity_id == CORROSION_RIGHT_ENTITY_ID and not _corrosion_right_defeated:
		return _get_valid_node(_corrosion_leech_right)
	return null


func _get_valid_node(node: Node) -> Node:
	return node if node != null and is_instance_valid(node) else null


func _is_provider_past_encounter_threshold(provider: Node) -> bool:
	return (
		provider != null
		and provider is Node2D
		and (provider as Node2D).global_position.x >= ENCOUNTER_ACTIVATION_X
	)


func _is_corrosion_channel_cleared() -> bool:
	return (
		_corrosion_channel_cleared
		or (_corrosion_left_defeated and _corrosion_right_defeated)
	)


func _is_recovery_cistern_traversed() -> bool:
	if (
		_recovery_cistern == null
		or not _recovery_cistern.has_method("get_local_state")
	):
		return false
	var recovery_state: Dictionary = Dictionary(_recovery_cistern.call(
		"get_local_state"
	))
	return bool(recovery_state.get(
		"underground_recovery_cistern_traversed",
		false
	))


func _is_deep_cistern_stalker_defeated() -> bool:
	if (
		_deep_cistern_ambush == null
		or not _deep_cistern_ambush.has_method("get_local_state")
	):
		return false
	var deep_state: Dictionary = Dictionary(_deep_cistern_ambush.call(
		"get_local_state"
	))
	return bool(deep_state.get(
		"underground_deep_cistern_stalker_defeated",
		false
	))


func _get_corrosion_encounter_state() -> StringName:
	if _corrosion_salvage_claimed:
		return &"claimed"
	if _is_corrosion_channel_cleared():
		return &"cleared"
	if _corrosion_channel_activated:
		return &"active"
	return &"ready"


func _get_active_corrosion_enemy_count() -> int:
	var count: int = 0
	if _is_enemy_active(_corrosion_leech_left, _corrosion_left_defeated):
		count += 1
	if _is_enemy_active(_corrosion_leech_right, _corrosion_right_defeated):
		count += 1
	return count


func _is_enemy_active(enemy: Node2D, defeated: bool) -> bool:
	return (
		not defeated
		and enemy != null
		and is_instance_valid(enemy)
		and enemy.visible
		and enemy.process_mode != Node.PROCESS_MODE_DISABLED
	)


func _enemy_has_attack_target(enemy: Node) -> bool:
	return (
		enemy != null
		and is_instance_valid(enemy)
		and enemy.has_method("has_attack_target")
		and bool(enemy.call("has_attack_target"))
	)


func _get_enemy_animation(enemy: Node) -> String:
	if enemy == null or not is_instance_valid(enemy):
		return ""
	var sprite: AnimatedSprite2D = enemy.get_node_or_null("Sprite") as AnimatedSprite2D
	return String(sprite.animation) if sprite != null else ""


func _is_seal_blocking(seal: StaticBody2D) -> bool:
	if seal == null or not seal.visible or seal.collision_layer == 0:
		return false
	var collision_shape: CollisionShape2D = (
		seal.get_node_or_null("CollisionShape2D") as CollisionShape2D
	)
	return collision_shape != null and not collision_shape.disabled


func _is_corrosive_runoff_active(hazard: Area2D) -> bool:
	return (
		hazard != null
		and hazard.visible
		and hazard.monitoring
		and hazard.collision_layer != 0
		and hazard.collision_mask != 0
	)


func _resolve_corrosion_target_from_area(area: Area2D) -> Node:
	if area == null:
		return null
	var parent: Node = area.get_parent()
	if parent == _player:
		return _player
	if (
		parent != null
		and parent.has_method("get_entity_id")
		and int(parent.call("get_entity_id")) == PlayerController.PLAYER_ENTITY_ID
	):
		return _player
	return null


func _get_target_current_hp(target: Node) -> int:
	return (
		int(target.call("get_current_hp"))
		if target != null and target.has_method("get_current_hp")
		else 0
	)


func _get_hazard_id(hazard: Area2D) -> StringName:
	if hazard != null and hazard.has_method("get_hazard_id"):
		return StringName(String(hazard.call("get_hazard_id")))
	return &""


func _get_hazard_damage(hazard: Area2D) -> int:
	if hazard != null and hazard.has_method("get_damage"):
		return int(hazard.call("get_damage"))
	return 0


func _get_hazard_contact_cooldown_sec(hazard: Area2D) -> float:
	if hazard != null and hazard.has_method("get_contact_cooldown_sec"):
		return float(hazard.call("get_contact_cooldown_sec"))
	return 0.0


func _get_hazard_visual_texture_path(hazard: Area2D) -> String:
	if hazard != null and hazard.has_method("get_visual_texture_path"):
		return String(hazard.call("get_visual_texture_path"))
	return ""


func _get_sprite_texture_path(sprite: Sprite2D) -> String:
	return (
		sprite.texture.resource_path
		if sprite != null and sprite.texture != null
		else ""
	)


func _get_seal_texture_path(seal: StaticBody2D) -> String:
	if seal == null:
		return ""
	var visual: Sprite2D = seal.get_node_or_null("Visual") as Sprite2D
	return _get_sprite_texture_path(visual)


func _get_cache_visual_texture_path() -> String:
	if _corrosion_salvage_cache == null:
		return ""
	var visual: Sprite2D = (
		_corrosion_salvage_cache.get_node_or_null("Visual") as Sprite2D
	)
	return _get_sprite_texture_path(visual)


func _is_corrosion_cache_available() -> bool:
	return (
		_corrosion_salvage_cache != null
		and _corrosion_salvage_cache.has_method("is_claim_available")
		and bool(_corrosion_salvage_cache.call("is_claim_available"))
	)


func _resolve_scene_manager_for_runtime() -> Object:
	if _is_valid_scene_manager(_scene_manager):
		return _scene_manager
	var root_scene_manager: Node = get_node_or_null("/root/SceneManager")
	return root_scene_manager if _is_valid_scene_manager(root_scene_manager) else null


func _is_valid_scene_manager(scene_manager: Object) -> bool:
	return scene_manager != null and (
		scene_manager.has_method("request_scene_change")
		or scene_manager.has_method("change_scene")
	)


func _ensure_runtime_scene_root(scene_manager: Object) -> bool:
	if not scene_manager.has_method("configure_runtime_scene_root"):
		return true
	if scene_manager.has_method("is_runtime_scene_swap_enabled") \
			and bool(scene_manager.call("is_runtime_scene_swap_enabled")):
		return true
	var runtime_root: Node = get_parent()
	if runtime_root == null or runtime_root == get_tree().root:
		return false
	return bool(scene_manager.call("configure_runtime_scene_root", runtime_root, self))


func _request_scene_change(
	scene_manager: Object,
	scene_id: StringName,
	spawn_point: StringName
) -> bool:
	if scene_manager.has_method("request_scene_change"):
		return bool(scene_manager.call("request_scene_change", scene_id, spawn_point))
	if scene_manager.has_method("change_scene"):
		return bool(scene_manager.call("change_scene", scene_id, spawn_point))
	return false


func _get_pending_scene(scene_manager: Object) -> String:
	return (
		String(scene_manager.call("get_pending_scene"))
		if scene_manager.has_method("get_pending_scene")
		else ""
	)


func _get_pending_spawn_point(scene_manager: Object) -> String:
	return (
		String(scene_manager.call("get_pending_spawn_point"))
		if scene_manager.has_method("get_pending_spawn_point")
		else ""
	)


func _record_return_rejection(reason: StringName) -> void:
	_last_return_rejected_reason = reason
	_last_return_request.clear()
