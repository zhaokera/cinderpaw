## Story146 Crown Warden encounter controller and Central Tower return handoff.
class_name CrownWardenArena
extends Node2D

const SCENE_ID: StringName = &"boss_04_crown_warden_arena"
const ENTRY_SPAWN_POINT: StringName = &"boss_entry"
const TOWER_SCENE_ID: StringName = &"area_05_central_tower"
const MAIN_SCENE_ID: StringName = &"main"
const TOWER_RETURN_SPAWN_POINT: StringName = &"apex_approach_return"
const MAIN_RETURN_SPAWN_POINT: StringName = &"scrap_roost"
const BOSS_ENTITY_ID: int = 2400
const BOSS_ID: StringName = &"boss_04_crown_warden"
const BOSS_DISPLAY_NAME: String = "Crown Warden"
const BOSS_DEFEATED_STATE_KEY: String = "boss_04_crown_warden_defeated"
const WALL_CLIMB_REWARD_CLAIMED_STATE_KEY: String = (
	"boss_04_wall_climb_reward_claimed"
)
const VICTORY_RECALL_REQUESTED_STATE_KEY: String = (
	"boss_04_victory_recall_requested"
)
const EPILOGUE_CHECKPOINT_STATE_KEY: String = (
	"crown_observatory_epilogue_checkpoint_activated"
)
const EPILOGUE_ASCENT_COMPLETED_STATE_KEY: String = (
	"crown_observatory_epilogue_ascent_completed"
)
const WALL_CLIMB_REWARD_ID: StringName = &"boss_04_wall_climb_reward"
const WALL_CLIMB_ABILITY_ID: StringName = &"wall_climb"
const BOSS_DEATH_PRESENTATION_HOLD_SEC: float = 2.0
const WALL_CLIMB_REWARD_FEEDBACK_DURATION_SEC: float = 1.5
const WALL_CLIMB_REWARD_REVEAL_DURATION_SEC: float = 0.8
const WALL_CLIMB_REWARD_TEXTURE_PATH: String = (
	"res://assets/environment/crown_warden_reward/"
	+ "prop_crown_warden_wall_climb_core_256x256.png"
)
const VICTORY_RECALL_TEXTURE_PATH: String = (
	"res://assets/environment/crown_warden_victory_recall/"
	+ "prop_crown_warden_victory_recall_256x384.png"
)
const WALL_CLIMB_REWARD_VISUAL_BASE_SCALE: Vector2 = Vector2(0.64, 0.64)
const PLAYER_LIGHT_DAMAGE: int = 12
const BOSS_TALON_DIVE_HITBOX_ID: StringName = &"crown_warden_talon_dive"
const BOSS_WING_SWEEP_HITBOX_ID: StringName = &"crown_warden_wing_sweep"
const BOSS_TALON_DIVE_DAMAGE: int = 18
const BOSS_WING_SWEEP_DAMAGE: int = 14
const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")
const BOSS_CONFIG_COMPONENT_SCRIPT: Script = preload(
	"res://src/core/boss_config_component.gd"
)
const COMBAT_PRESENTATION_SCRIPT: Script = preload(
	"res://src/presentation/combat_presentation.gd"
)
const PARRY_COUNTER_BASE_DAMAGE_FALLBACK: int = 10
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/crown_warden_arena/"
	+ "env_crown_warden_observatory_1280x720.png"
)
const EPILOGUE_BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/crown_warden_arena/"
	+ "env_crown_observatory_epilogue_ascent_1280x720.png"
)

@onready var _player: Node2D = get_node_or_null("Player") as Node2D
@onready var _entry_spawn: Marker2D = get_node_or_null("BossEntrySpawn") as Marker2D
@onready var _background: Sprite2D = get_node_or_null("Background") as Sprite2D
@onready var _return_route: Node2D = (
	get_node_or_null("CentralTowerReturnRoute") as Node2D
)
@onready var _victory_recall_route: Node2D = (
	get_node_or_null("CrownVictoryRecallRoute") as Node2D
)
@onready var _objective_label: Label = (
	get_node_or_null("ArenaObjectiveLabel") as Label
)
@onready var _boss: Node2D = get_node_or_null("CrownWardenBoss") as Node2D
@onready var _hud: HUDManager = get_node_or_null("HUD") as HUDManager
@onready var _left_room_seal: StaticBody2D = (
	get_node_or_null("LeftRoomSeal") as StaticBody2D
)
@onready var _right_room_seal: StaticBody2D = (
	get_node_or_null("RightRoomSeal") as StaticBody2D
)
@onready var _wall_climb_reward_source: Node2D = (
	get_node_or_null("WallClimbRewardSource") as Node2D
)
@onready var _combat_presentation: CombatPresentation = (
	get_node_or_null("CombatPresentation") as CombatPresentation
)
@onready var _hitstop_input_bridge = get_node_or_null("HitstopInputBridge")
@onready var _boss_config_component: BossConfigComponent = (
	get_node_or_null("BossConfigComponent") as BossConfigComponent
)
@onready var _epilogue_ascent: CrownObservatoryEpilogueAscentController = (
	get_node_or_null("CrownObservatoryEpilogueAscent")
	as CrownObservatoryEpilogueAscentController
)

var _scene_manager: Object = null
var _return_transition_requested: bool = false
var _last_return_rejected_reason: StringName = &""
var _last_return_request: Dictionary = {}
var _arena_discovered: bool = true
var _boss_defeated: bool = false
var _boss_death_presentation_pending: bool = false
var _boss_death_presentation_remaining_sec: float = 0.0
var _last_player_hit_metadata: Dictionary = {}
var _last_boss_attack_metadata: Dictionary = {}
var _player_retry_pending: bool = false
var _player_death_count: int = 0
var _scene_manager_lock_owned: bool = false
var _weapon_component: WeaponComponent = null
var _wall_climb_reward_claimed: bool = false
var _wall_climb_reward_feedback_remaining_sec: float = 0.0
var _wall_climb_reward_feedback_count: int = 0
var _wall_climb_reward_ability_was_already_unlocked: bool = false
var _wall_climb_reward_reveal_vfx: Sprite2D = null
var _wall_climb_reward_reveal_elapsed_sec: float = 0.0
var _wall_climb_reward_reveal_spawn_count: int = 0
var _victory_recall_proof_persisted: bool = false
var _last_parry_counter_metadata: Dictionary = {}
var _parry_counter_count: int = 0


func _ready() -> void:
	_align_player_to_entry_spawn()
	_setup_weapon_component()
	_setup_boss4_parry_runtime()
	_setup_hitstop_input_buffer()
	_setup_boss4_combat()
	_setup_epilogue_ascent_runtime()
	_sync_boss4_combat_state()
	var root_scene_manager: Node = get_node_or_null("/root/SceneManager")
	if _is_valid_scene_manager(root_scene_manager):
		configure_scene_manager_runtime(root_scene_manager)


func _process(delta: float) -> void:
	advance_boss4_death_presentation(delta)
	advance_wall_climb_reward_feedback(delta)
	_advance_wall_climb_reward_reveal_vfx(delta)
	_process_wall_climb_reward_contact()
	_update_objective_screen_position()
	if Input.is_action_just_pressed(&"interact") and not _return_transition_requested:
		if _is_provider_near_victory_recall(_player):
			try_request_victory_recall(_player)
		elif _is_provider_near_return(_player):
			try_request_central_tower_return(_player)


func _exit_tree() -> void:
	_release_scene_lock()
	_disconnect_scene_manager_failure_signal()


func calculate_damage(
	_attack_type: StringName,
	weapon_id: StringName,
	_hit_frame: int,
	combo_index: int,
	_parry_timing: int,
	_attack_power: int,
	_enemy_defense: int,
	_skill_modifiers: Dictionary = {},
	injected_damage_params: Dictionary = {},
	_data_manager: Object = null
) -> Dictionary:
	var damage: int = _resolve_base_damage(weapon_id, injected_damage_params)
	return {
		"final_damage": damage,
		"base_damage": damage,
		"attack_damage": float(damage),
		"reduction_factor": 1.0,
		"damage_multiplier": 1.0,
		"is_crit": false,
		"crit_type": &"none",
		"parry_type": &"none",
		"combo_stage": combo_index,
		"damage_category": &"scratch",
	}


func _resolve_base_damage(weapon_id: StringName, injected_damage_params: Dictionary) -> int:
	var fallback_damage: int = PLAYER_LIGHT_DAMAGE
	if weapon_id == BOSS_TALON_DIVE_HITBOX_ID:
		fallback_damage = BOSS_TALON_DIVE_DAMAGE
	elif weapon_id == BOSS_WING_SWEEP_HITBOX_ID:
		fallback_damage = BOSS_WING_SWEEP_DAMAGE
	var entries: Dictionary = Dictionary(injected_damage_params.get("entries", {}))
	var weapon_entry: Dictionary = Dictionary(entries.get(String(weapon_id), {}))
	var configured_damage: int = int(weapon_entry.get("weapon_base", fallback_damage))
	return configured_damage if configured_damage > 0 else fallback_damage


func apply_damage(target_id: int, final_damage: int, metadata: Dictionary = {}) -> bool:
	if (
		target_id != BOSS_ENTITY_ID
		or _boss == null
		or not _boss.has_method("apply_damage")
		or final_damage <= 0
	):
		return false
	var result: Variant = _boss.call("apply_damage", final_damage, metadata)
	return bool(result) if result is bool else true


func configure_scene_manager_runtime(scene_manager: Object) -> bool:
	if _scene_manager != scene_manager:
		_release_scene_lock()
	_disconnect_scene_manager_failure_signal()
	_scene_manager = scene_manager
	if not _is_valid_scene_manager(_scene_manager):
		return false
	_connect_scene_manager_failure_signal()
	_apply_current_scene_manager_spawn_point()
	_sync_scene_lock()
	return true


## Returns to the secured Apex Approach without mutating the ability set.
func try_request_central_tower_return(provider: Node = null) -> bool:
	if _boss_death_presentation_pending:
		_record_return_rejection(&"victory_presentation_pending")
		return false
	if not _boss_defeated:
		_record_return_rejection(&"boss_active")
		return false
	if _return_route == null or _return_transition_requested:
		_record_return_rejection(&"transition_already_requested")
		return false
	var request_provider: Node = _player if provider == null else provider
	if (
		not _return_route.has_method("can_request_transition")
		or not bool(_return_route.call(
			"can_request_transition",
			request_provider
		))
	):
		_record_return_rejection(&"provider_out_of_range")
		return false
	var manager_rejection: StringName = _scene_manager_rejection_for(
		TOWER_SCENE_ID
	)
	if manager_rejection != &"":
		_record_return_rejection(manager_rejection)
		return false
	if not _ensure_runtime_scene_root():
		_record_return_rejection(&"runtime_root_unavailable")
		return false
	if not _persist_progress():
		_record_return_rejection(&"state_persist_failed")
		return false
	if not _request_scene_change(TOWER_SCENE_ID, TOWER_RETURN_SPAWN_POINT):
		_record_return_rejection(&"request_rejected")
		return false
	_return_transition_requested = true
	_last_return_rejected_reason = &""
	_last_return_request = {
		"scene_id": String(TOWER_SCENE_ID),
		"spawn_point": String(TOWER_RETURN_SPAWN_POINT),
		"pending_scene": _get_pending_scene(),
		"pending_spawn_point": _get_pending_spawn_point(),
	}
	_sync_return_route()
	if _objective_label != null:
		_objective_label.text = "Returning to Apex Approach"
	return true


## Closes the completed Boss4 session at the established Scrap Roost hub.
func try_request_victory_recall(provider: Node = null) -> bool:
	if _boss_death_presentation_pending:
		_record_return_rejection(&"victory_presentation_pending")
		return false
	if not _boss_defeated or not _wall_climb_reward_claimed:
		_record_return_rejection(&"reward_unclaimed")
		return false
	if not _is_epilogue_ascent_completed():
		_record_return_rejection(&"epilogue_ascent_incomplete")
		return false
	if _victory_recall_route == null or _return_transition_requested:
		_record_return_rejection(&"transition_already_requested")
		return false
	var request_provider: Node = _player if provider == null else provider
	if (
		not _victory_recall_route.has_method("can_request_transition")
		or not bool(_victory_recall_route.call(
			"can_request_transition",
			request_provider
		))
	):
		_record_return_rejection(&"provider_out_of_range")
		return false
	var manager_rejection: StringName = _scene_manager_rejection_for(MAIN_SCENE_ID)
	if manager_rejection != &"":
		_record_return_rejection(manager_rejection)
		return false
	if not _ensure_runtime_scene_root():
		_record_return_rejection(&"runtime_root_unavailable")
		return false

	_victory_recall_proof_persisted = true
	if not _persist_progress():
		_victory_recall_proof_persisted = false
		_persist_progress()
		_record_return_rejection(&"state_persist_failed")
		return false
	if not _request_scene_change(MAIN_SCENE_ID, MAIN_RETURN_SPAWN_POINT):
		_victory_recall_proof_persisted = false
		_persist_progress()
		_record_return_rejection(&"request_rejected")
		return false

	_return_transition_requested = true
	_last_return_rejected_reason = &""
	_last_return_request = {
		"route_id": "crown_warden_victory_recall",
		"scene_id": String(MAIN_SCENE_ID),
		"spawn_point": String(MAIN_RETURN_SPAWN_POINT),
		"pending_scene": _get_pending_scene(),
		"pending_spawn_point": _get_pending_spawn_point(),
	}
	_sync_return_route()
	if _objective_label != null:
		_objective_label.text = "Recalling to Scrap Roost"
	return true


func get_local_state() -> Dictionary:
	var epilogue_state: Dictionary = _get_epilogue_ascent_state()
	return {
		"crown_warden_arena_discovered": _arena_discovered,
		BOSS_DEFEATED_STATE_KEY: _boss_defeated,
		WALL_CLIMB_REWARD_CLAIMED_STATE_KEY: _wall_climb_reward_claimed,
		VICTORY_RECALL_REQUESTED_STATE_KEY: _victory_recall_proof_persisted,
		EPILOGUE_CHECKPOINT_STATE_KEY: bool(epilogue_state.get(
			"checkpoint_activated",
			false
		)),
		EPILOGUE_ASCENT_COMPLETED_STATE_KEY: bool(epilogue_state.get(
			"completed",
			false
		)),
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
	}


func set_local_state(state: Dictionary) -> void:
	_arena_discovered = bool(state.get(
		"crown_warden_arena_discovered",
		_arena_discovered
	)) or _arena_discovered
	_return_transition_requested = false
	_last_return_rejected_reason = &""
	_last_return_request.clear()
	_boss_defeated = bool(state.get(BOSS_DEFEATED_STATE_KEY, false))
	_boss_death_presentation_pending = false
	_boss_death_presentation_remaining_sec = 0.0
	_wall_climb_reward_claimed = bool(state.get(
		WALL_CLIMB_REWARD_CLAIMED_STATE_KEY,
		false
	))
	_victory_recall_proof_persisted = bool(state.get(
		VICTORY_RECALL_REQUESTED_STATE_KEY,
		false
	))
	var epilogue_completed: bool = bool(state.get(
		EPILOGUE_ASCENT_COMPLETED_STATE_KEY,
		false
	)) or _victory_recall_proof_persisted
	var epilogue_checkpoint: bool = bool(state.get(
		EPILOGUE_CHECKPOINT_STATE_KEY,
		false
	)) or epilogue_completed
	_wall_climb_reward_feedback_remaining_sec = 0.0
	_wall_climb_reward_feedback_count = 0
	_wall_climb_reward_ability_was_already_unlocked = false
	_wall_climb_reward_reveal_spawn_count = 0
	_clear_wall_climb_reward_reveal_vfx()
	_set_player_reward_control_locked(false)
	_restore_player_unlocked_abilities(state)
	if _epilogue_ascent != null:
		_epilogue_ascent.restore_progress(
			epilogue_checkpoint,
			epilogue_completed
		)
	if _boss != null:
		if _boss_defeated and _boss.has_method("mark_defeated_from_progress"):
			_boss.call("mark_defeated_from_progress")
		elif not _boss_defeated and _boss.has_method("reset_encounter"):
			_boss.call("reset_encounter")
	_sync_boss4_combat_state()
	_align_player_after_state_restore()


func get_arena_handoff_diagnostics() -> Dictionary:
	return {
		"scene_id": String(SCENE_ID),
		"background_texture_path": _texture_path(_background),
		"background_expected_path": BACKGROUND_TEXTURE_PATH,
		"entry_spawn_position": (
			_entry_spawn.global_position if _entry_spawn != null else Vector2.ZERO
		),
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"return_target_scene_id": String(TOWER_SCENE_ID),
		"return_spawn_point": String(TOWER_RETURN_SPAWN_POINT),
		"return_available": (
			bool(_return_route.call("is_route_available"))
			if _return_route != null
			and _return_route.has_method("is_route_available")
			else false
		),
		"return_transition_requested": _return_transition_requested,
		"last_return_rejected_reason": String(_last_return_rejected_reason),
		"last_return_request": _last_return_request.duplicate(true),
		"objective_text": _objective_label.text if _objective_label != null else "",
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
		"boss_actor_present": get_node_or_null("CrownWardenBoss") != null,
	}


func get_boss4_combat_diagnostics() -> Dictionary:
	var boss_sprite: AnimatedSprite2D = (
		_boss.get_node_or_null("Sprite") as AnimatedSprite2D if _boss != null else null
	)
	var boss_panel: Control = (
		_hud.get_node_or_null("HudRoot/BossHudPanel") as Control if _hud != null else null
	)
	var boss_current_hp: int = (
		int(_boss.call("get_current_hp"))
		if _boss != null and _boss.has_method("get_current_hp")
		else 0
	)
	return {
		"boss_present": _boss != null,
		"boss_entity_id": (
			int(_boss.call("get_entity_id"))
			if _boss != null and _boss.has_method("get_entity_id")
			else -1
		),
		"boss_id": String(BOSS_ID),
		"boss_display_name": BOSS_DISPLAY_NAME,
		"boss_current_hp": boss_current_hp,
		"boss_hp": boss_current_hp,
		"boss_max_hp": (
			int(_boss.call("get_max_hp"))
			if _boss != null and _boss.has_method("get_max_hp")
			else 0
		),
		"boss_phase": (
			int(_boss.call("get_current_phase"))
			if _boss != null and _boss.has_method("get_current_phase")
			else 0
		),
		"boss_defeated": _boss_defeated,
		"death_presentation_pending": _boss_death_presentation_pending,
		"death_presentation_remaining_sec": (
			_boss_death_presentation_remaining_sec
		),
		"boss_visible": _boss != null and _boss.visible,
		"boss_animation": String(boss_sprite.animation) if boss_sprite != null else "",
		"boss_frame_count": (
			boss_sprite.sprite_frames.get_frame_count(boss_sprite.animation)
			if boss_sprite != null and boss_sprite.sprite_frames != null
			else 0
		),
		"boss_hud_visible": boss_panel != null and boss_panel.visible,
		"boss_hud_label": _hud.get_boss_label_text() if _hud != null else "",
		"room_seals_enabled": _are_room_seals_enabled(),
		"left_room_seal_visible": (
			_left_room_seal != null and _left_room_seal.visible
		),
		"right_room_seal_visible": (
			_right_room_seal != null and _right_room_seal.visible
		),
		"return_route_available": (
			bool(_return_route.call("is_route_available"))
			if _return_route != null and _return_route.has_method("is_route_available")
			else false
		),
		"transition_requested": _return_transition_requested,
		"return_transition_requested": _return_transition_requested,
		"scene_manager_locked": _is_scene_manager_locked(),
		"scene_manager_lock_owned": _scene_manager_lock_owned,
		"player_control_locked": (
			_boss_death_presentation_pending
			or _wall_climb_reward_feedback_remaining_sec > 0.0
		),
		"last_player_hit_metadata": _last_player_hit_metadata.duplicate(true),
		"last_boss_attack_metadata": _last_boss_attack_metadata.duplicate(true),
		"player_retry_pending": _player_retry_pending,
		"player_death_count": _player_death_count,
		"last_parry_counter_metadata": _last_parry_counter_metadata.duplicate(true),
		"parry_counter_count": _parry_counter_count,
	}


func get_boss4_parry_counter_diagnostics() -> Dictionary:
	var status_effects: StatusEffectComponent = (
		_boss.call("get_status_effect_component") as StatusEffectComponent
		if _boss != null and _boss.has_method("get_status_effect_component")
		else null
	)
	var result: Dictionary = _last_parry_counter_metadata.duplicate(true)
	result["counter_count"] = _parry_counter_count
	result["config_loaded"] = (
		_boss_config_component != null
		and _boss_config_component.has_boss_config()
	)
	result["boss_has_stun"] = (
		status_effects != null and status_effects.has_status(&"stun")
	)
	result["presentation_present"] = _combat_presentation != null
	result["perfect_afterimage_active"] = (
		_combat_presentation != null
		and _combat_presentation.get_active_perfect_parry_afterimage_count() > 0
	)
	return result


## Claims the visible Boss4 reward while preserving the hidden-altar path.
func claim_wall_climb_reward_source(provider: Node = null) -> bool:
	if (
		_wall_climb_reward_source == null
		or _wall_climb_reward_claimed
		or not _boss_defeated
		or _boss_death_presentation_pending
		or not _wall_climb_reward_source.has_method("try_claim")
	):
		return false
	var claim_provider: Node = _player if provider == null else provider
	if not bool(_wall_climb_reward_source.call("try_claim", claim_provider)):
		return false
	_wall_climb_reward_ability_was_already_unlocked = _has_player_ability(
		WALL_CLIMB_ABILITY_ID
	)
	if not _wall_climb_reward_ability_was_already_unlocked:
		if (
			_player == null
			or not _player.has_method("unlock_ability")
			or not bool(_player.call("unlock_ability", WALL_CLIMB_ABILITY_ID))
		):
			_wall_climb_reward_source.call("set_claimed", false)
			return false
	_wall_climb_reward_claimed = true
	_wall_climb_reward_feedback_remaining_sec = (
		WALL_CLIMB_REWARD_FEEDBACK_DURATION_SEC
	)
	_wall_climb_reward_feedback_count += 1
	_set_player_reward_control_locked(true)
	_sync_wall_climb_reward_payoff()
	_sync_epilogue_ascent_route()
	_sync_victory_recall_route()
	_update_wall_climb_reward_feedback_pulse()
	if _hud != null:
		_hud.show_notification(
			_wall_climb_reward_notification_text(),
			WALL_CLIMB_REWARD_FEEDBACK_DURATION_SEC
		)
	_refresh_wall_climb_reward_objective()
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if _is_valid_scene_manager(scene_manager):
		_persist_progress()
	return true


## Advances the exact GDD unlock-presentation duration deterministically.
func advance_wall_climb_reward_feedback(delta_sec: float) -> void:
	if _wall_climb_reward_feedback_remaining_sec <= 0.0:
		return
	_wall_climb_reward_feedback_remaining_sec = maxf(
		0.0,
		_wall_climb_reward_feedback_remaining_sec - maxf(0.0, delta_sec)
	)
	_update_wall_climb_reward_feedback_pulse()
	if _wall_climb_reward_feedback_remaining_sec > 0.0:
		_refresh_wall_climb_reward_objective()
		return
	_set_player_reward_control_locked(false)
	_reset_wall_climb_reward_visual_to_claimed_state()
	_refresh_wall_climb_reward_objective()


## Returns reward, alternate-path, feedback and persistence details for QA/MCP.
func get_wall_climb_reward_diagnostics() -> Dictionary:
	var reward_canvas: CanvasItem = _wall_climb_reward_source as CanvasItem
	var reward_texture_path: String = ""
	if (
		_wall_climb_reward_source != null
		and _wall_climb_reward_source.has_method("get_visual_texture_path")
	):
		reward_texture_path = String(_wall_climb_reward_source.call(
			"get_visual_texture_path"
		))
	return {
		"reward_id": String(WALL_CLIMB_REWARD_ID),
		"ability_id": String(WALL_CLIMB_ABILITY_ID),
		"boss_defeated": _boss_defeated,
		"death_presentation_pending": _boss_death_presentation_pending,
		"reward_present": _wall_climb_reward_source != null,
		"reward_visible": reward_canvas != null and reward_canvas.visible,
		"reward_available": (
			bool(_wall_climb_reward_source.call("is_claim_available"))
			if _wall_climb_reward_source != null
			and _wall_climb_reward_source.has_method("is_claim_available")
			else false
		),
		"reward_claimed": _wall_climb_reward_claimed,
		"reward_texture_path": reward_texture_path,
		"ability_unlocked": _has_player_ability(WALL_CLIMB_ABILITY_ID),
		"ability_was_already_unlocked": (
			_wall_climb_reward_ability_was_already_unlocked
		),
		"feedback_active": _wall_climb_reward_feedback_remaining_sec > 0.0,
		"feedback_remaining_sec": _wall_climb_reward_feedback_remaining_sec,
		"feedback_duration_sec": WALL_CLIMB_REWARD_FEEDBACK_DURATION_SEC,
		"feedback_count": _wall_climb_reward_feedback_count,
		"reveal_vfx_active": (
			_wall_climb_reward_reveal_vfx != null
			and is_instance_valid(_wall_climb_reward_reveal_vfx)
		),
		"reveal_vfx_spawn_count": _wall_climb_reward_reveal_spawn_count,
		"hud_notification": _hud.get_notification_text() if _hud != null else "",
		"objective_text": _objective_label.text if _objective_label != null else "",
		"return_route_available": (
			bool(_return_route.call("is_route_available"))
			if _return_route != null
			and _return_route.has_method("is_route_available")
			else false
		),
	}


## Returns the optional hub recall state for focused tests and MCP probes.
func get_victory_recall_diagnostics() -> Dictionary:
	var recall_canvas: CanvasItem = _victory_recall_route as CanvasItem
	var player_control_locked: bool = (
		_boss_death_presentation_pending
		or _wall_climb_reward_feedback_remaining_sec > 0.0
	)
	return {
		"route_present": _victory_recall_route != null,
		"route_id": (
			String(_victory_recall_route.call("get_route_id"))
			if _victory_recall_route != null
			and _victory_recall_route.has_method("get_route_id")
			else ""
		),
		"recall_route_visible": recall_canvas != null and recall_canvas.visible,
		"recall_route_available": (
			bool(_victory_recall_route.call("is_route_available"))
			if _victory_recall_route != null
			and _victory_recall_route.has_method("is_route_available")
			else false
		),
		"recall_texture_path": (
			String(_victory_recall_route.call("get_visual_texture_path"))
			if _victory_recall_route != null
			and _victory_recall_route.has_method("get_visual_texture_path")
			else ""
		),
		"recall_expected_texture_path": VICTORY_RECALL_TEXTURE_PATH,
		"target_scene_id": String(MAIN_SCENE_ID),
		"spawn_point": String(MAIN_RETURN_SPAWN_POINT),
		"recall_proof_persisted": _victory_recall_proof_persisted,
		"transition_requested": _return_transition_requested,
		"last_rejected_reason": String(_last_return_rejected_reason),
		"last_request": _last_return_request.duplicate(true),
		"reward_feedback_active": _wall_climb_reward_feedback_remaining_sec > 0.0,
		"player_control_locked": player_control_locked,
		"tower_return_available": (
			bool(_return_route.call("is_route_available"))
			if _return_route != null and _return_route.has_method("is_route_available")
			else false
		),
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
		"objective_text": _objective_label.text if _objective_label != null else "",
	}


## Attempts the one-shot high-platform proof owned by Story172's controller.
func try_complete_crown_observatory_epilogue_ascent(
	provider: Node = null
) -> bool:
	if _epilogue_ascent == null:
		return false
	return _epilogue_ascent.try_complete(
		_player if provider == null else provider
	)


## Returns traversal, persistence, recall, and visual details for tests and MCP.
func get_crown_observatory_epilogue_ascent_diagnostics() -> Dictionary:
	var diagnostics: Dictionary = _get_epilogue_ascent_state()
	diagnostics.merge({
		"boss_defeated": _boss_defeated,
		"reward_claimed": _wall_climb_reward_claimed,
		"recall_route_available": (
			bool(_victory_recall_route.call("is_route_available"))
			if _victory_recall_route != null
			and _victory_recall_route.has_method("is_route_available")
			else false
		),
		"recall_route_visible": (
			_victory_recall_route != null and _victory_recall_route.visible
		),
		"objective_text": _objective_label.text if _objective_label != null else "",
		"player_position": (
			_player.global_position if _player != null else Vector2.ZERO
		),
		"background_expected_path": EPILOGUE_BACKGROUND_TEXTURE_PATH,
		"camera_limit_right": _get_camera_limit_right(),
	}, true)
	return diagnostics


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
		not _return_transition_requested
		or scene_id not in [TOWER_SCENE_ID, MAIN_SCENE_ID]
	):
		return
	_return_transition_requested = false
	if scene_id == MAIN_SCENE_ID:
		_victory_recall_proof_persisted = false
		_persist_progress()
	_record_return_rejection(reason if reason != &"" else &"load_failed")
	_last_return_request["load_failed_reason"] = String(reason)
	_sync_return_route()
	_refresh_wall_climb_reward_objective()


func _sync_return_route() -> void:
	if _return_route != null and _return_route.has_method("set_route_available"):
		_return_route.call(
			"set_route_available",
			_boss_defeated and not _boss_death_presentation_pending
		)
	if _return_route != null and _return_route.has_method("set_transition_requested"):
		_return_route.call(
			"set_transition_requested",
			_return_transition_requested
		)
	_sync_epilogue_ascent_route()
	_sync_victory_recall_route()


func _sync_victory_recall_route() -> void:
	if _victory_recall_route == null:
		return
	var available: bool = (
		_boss_defeated
		and not _boss_death_presentation_pending
		and _wall_climb_reward_claimed
		and _is_epilogue_ascent_completed()
	)
	if _victory_recall_route.has_method("set_route_available"):
		_victory_recall_route.call("set_route_available", available)
	if _victory_recall_route.has_method("set_transition_requested"):
		_victory_recall_route.call(
			"set_transition_requested",
			_return_transition_requested
		)
	_victory_recall_route.visible = available


func _setup_epilogue_ascent_runtime() -> void:
	if _epilogue_ascent == null:
		return
	_epilogue_ascent.configure_runtime(_player, self)
	if not _epilogue_ascent.checkpoint_activated.is_connected(
		_on_epilogue_ascent_checkpoint_activated
	):
		_epilogue_ascent.checkpoint_activated.connect(
			_on_epilogue_ascent_checkpoint_activated
		)
	if not _epilogue_ascent.ascent_completed.is_connected(
		_on_epilogue_ascent_completed
	):
		_epilogue_ascent.ascent_completed.connect(_on_epilogue_ascent_completed)
	if not _epilogue_ascent.fall_requested.is_connected(
		_on_epilogue_ascent_fall_requested
	):
		_epilogue_ascent.fall_requested.connect(_on_epilogue_ascent_fall_requested)


func _sync_epilogue_ascent_route() -> void:
	if _epilogue_ascent == null:
		return
	_epilogue_ascent.set_route_available(
		_boss_defeated
		and not _boss_death_presentation_pending
		and _wall_climb_reward_claimed
	)


func _setup_boss4_combat() -> void:
	if _player != null:
		if _player.has_method("set_target_health_adapter"):
			_player.call("set_target_health_adapter", self)
		if _player.has_method("set_damage_calculator_adapter"):
			_player.call("set_damage_calculator_adapter", self)
		if _player.has_method("set_weapon_component"):
			_player.call("set_weapon_component", _weapon_component)
		if _weapon_component != null:
			if _player.has_method("get_combat_component"):
				_weapon_component.set_combat_adapter(
					_player.call("get_combat_component")
				)
			if _player.has_method("get_collision_component"):
				_weapon_component.set_collision_adapter(
					_player.call("get_collision_component")
				)
		if _player.has_signal("attack_landed"):
			var player_attack_signal: Signal = _player.get("attack_landed")
			if not player_attack_signal.is_connected(_on_player_attack_landed):
				player_attack_signal.connect(_on_player_attack_landed)
		if _player.has_signal("player_health_changed"):
			var player_health_signal: Signal = _player.get("player_health_changed")
			if not player_health_signal.is_connected(_on_player_health_changed):
				player_health_signal.connect(_on_player_health_changed)
		if _player.has_signal("player_died"):
			var player_died_signal: Signal = _player.get("player_died")
			if not player_died_signal.is_connected(_on_player_died):
				player_died_signal.connect(_on_player_died)
		if _player.has_method("get_combat_component"):
			var player_combat: CombatComponent = (
				_player.call("get_combat_component") as CombatComponent
			)
			if (
				player_combat != null
				and not player_combat.on_parry_resolved.is_connected(
					_on_player_parry_resolved
				)
			):
				player_combat.on_parry_resolved.connect(_on_player_parry_resolved)
	if _boss == null:
		return
	if _boss.has_method("set_attack_target"):
		_boss.call("set_attack_target", _player)
	if _boss.has_method("set_damage_calculator_adapter"):
		_boss.call("set_damage_calculator_adapter", self)
	if _boss.has_signal("boss_health_changed"):
		var health_signal: Signal = _boss.get("boss_health_changed")
		if not health_signal.is_connected(_on_boss4_health_changed):
			health_signal.connect(_on_boss4_health_changed)
	if _boss.has_signal("boss_defeated"):
		var defeated_signal: Signal = _boss.get("boss_defeated")
		if not defeated_signal.is_connected(_on_boss4_defeated):
			defeated_signal.connect(_on_boss4_defeated)
	if _boss.has_signal("enemy_attack_landed"):
		var attack_signal: Signal = _boss.get("enemy_attack_landed")
		if not attack_signal.is_connected(_on_boss4_attack_landed):
			attack_signal.connect(_on_boss4_attack_landed)
	if _boss.has_signal("on_boss_phase_transition_started"):
		var phase_signal: Signal = _boss.get("on_boss_phase_transition_started")
		if not phase_signal.is_connected(_on_boss4_phase_transition_started):
			phase_signal.connect(_on_boss4_phase_transition_started)


func _setup_weapon_component() -> void:
	_weapon_component = get_node_or_null("WeaponComponent") as WeaponComponent
	if _weapon_component == null:
		_weapon_component = WEAPON_COMPONENT_SCRIPT.new() as WeaponComponent
		_weapon_component.name = "WeaponComponent"
		add_child(_weapon_component)
	var root_data_manager: Node = get_node_or_null("/root/DataManager")
	if root_data_manager != null:
		_weapon_component.set_data_manager(root_data_manager)


func _setup_boss4_parry_runtime() -> void:
	if _boss_config_component == null:
		_boss_config_component = (
			BOSS_CONFIG_COMPONENT_SCRIPT.new() as BossConfigComponent
		)
		_boss_config_component.name = "BossConfigComponent"
		add_child(_boss_config_component)
	if _combat_presentation == null:
		_combat_presentation = (
			COMBAT_PRESENTATION_SCRIPT.new() as CombatPresentation
		)
		_combat_presentation.name = "CombatPresentation"
		add_child(_combat_presentation)
	_boss_config_component.set_entity_id(BOSS_ENTITY_ID)
	var root_data_manager: Node = get_node_or_null("/root/DataManager")
	if root_data_manager != null:
		_boss_config_component.set_data_adapter(root_data_manager)
		_boss_config_component.load_boss_config(BOSS_ID)


func _sync_boss4_combat_state() -> void:
	if (
		_boss != null
		and _boss_defeated
		and _boss.has_method("mark_defeated_from_progress")
	):
		_boss.call("mark_defeated_from_progress")
	_set_room_seals_enabled(
		not _boss_defeated or _boss_death_presentation_pending
	)
	_sync_return_route()
	_sync_scene_lock()
	if _hud != null:
		if _boss_defeated or _boss == null:
			_hud.hide_boss_hp()
		else:
			_hud.update_boss_hp(
				int(_boss.call("get_current_hp")),
				int(_boss.call("get_max_hp")),
				int(_boss.call("get_current_phase")),
				BOSS_DISPLAY_NAME
			)
		if _player != null:
			_hud.update_hp(
				int(_player.call("get_current_hp")),
				int(_player.call("get_max_hp"))
			)
	_sync_wall_climb_reward_payoff()
	_refresh_wall_climb_reward_objective()


func _process_wall_climb_reward_contact() -> void:
	if (
		_player == null
		or _wall_climb_reward_source == null
		or _wall_climb_reward_claimed
		or not _boss_defeated
		or _boss_death_presentation_pending
		or not _wall_climb_reward_source.has_method("is_provider_in_reward_range")
	):
		return
	if bool(_wall_climb_reward_source.call(
		"is_provider_in_reward_range",
		_player
	)):
		claim_wall_climb_reward_source(_player)


func _sync_wall_climb_reward_payoff() -> void:
	if _wall_climb_reward_source == null:
		return
	var reward_revealed: bool = (
		_boss_defeated and not _boss_death_presentation_pending
	)
	_wall_climb_reward_source.visible = reward_revealed
	if _wall_climb_reward_source.has_method("set_prompt_provider"):
		_wall_climb_reward_source.call("set_prompt_provider", _player)
	if _wall_climb_reward_source.has_method("set_claimed"):
		_wall_climb_reward_source.call(
			"set_claimed",
			_wall_climb_reward_claimed
		)
	if _wall_climb_reward_source.has_method("set_available"):
		_wall_climb_reward_source.call(
			"set_available",
			reward_revealed and not _wall_climb_reward_claimed
		)


func _refresh_wall_climb_reward_objective() -> void:
	if _objective_label == null or _return_transition_requested:
		return
	if not _boss_defeated:
		_objective_label.text = "Defeat Crown Warden"
	elif _boss_death_presentation_pending:
		_objective_label.text = "Crown Warden Falling"
	elif not _wall_climb_reward_claimed:
		_objective_label.text = "Claim Wall Climb"
	elif _wall_climb_reward_feedback_remaining_sec > 0.0:
		_objective_label.text = _wall_climb_reward_notification_text()
	elif not _is_epilogue_ascent_completed():
		_objective_label.text = "Climb to the Crown Signal"
	else:
		_objective_label.text = "Recall to Scrap Roost"


func _wall_climb_reward_notification_text() -> String:
	return (
		"Wall Climb Path Confirmed"
		if _wall_climb_reward_ability_was_already_unlocked
		else "Wall Climb Unlocked"
	)


func _update_wall_climb_reward_feedback_pulse() -> void:
	var visual: Sprite2D = _get_wall_climb_reward_visual()
	if visual == null:
		return
	var progress: float = clampf(
		1.0 - (
			_wall_climb_reward_feedback_remaining_sec
			/ WALL_CLIMB_REWARD_FEEDBACK_DURATION_SEC
		),
		0.0,
		1.0
	)
	var pulse: float = sin(progress * PI)
	visual.scale = WALL_CLIMB_REWARD_VISUAL_BASE_SCALE * (1.0 + pulse * 0.22)
	visual.modulate = Color(1.0, 0.92, 0.55, 0.64 + pulse * 0.36)


func _reset_wall_climb_reward_visual_to_claimed_state() -> void:
	if (
		_wall_climb_reward_source != null
		and _wall_climb_reward_source.has_method("set_claimed")
	):
		_wall_climb_reward_source.call("set_claimed", true)
	var visual: Sprite2D = _get_wall_climb_reward_visual()
	if visual != null:
		visual.scale = WALL_CLIMB_REWARD_VISUAL_BASE_SCALE


func _get_wall_climb_reward_visual() -> Sprite2D:
	return (
		_wall_climb_reward_source.get_node_or_null("Visual") as Sprite2D
		if _wall_climb_reward_source != null
		else null
	)


func _set_player_reward_control_locked(locked: bool) -> void:
	if _player != null and _player.has_method("set_control_locked"):
		_player.call("set_control_locked", locked)


func _spawn_wall_climb_reward_reveal_vfx() -> void:
	if _wall_climb_reward_source == null or _wall_climb_reward_claimed:
		return
	_clear_wall_climb_reward_reveal_vfx()
	var texture: Texture2D = load(WALL_CLIMB_REWARD_TEXTURE_PATH) as Texture2D
	if texture == null:
		return
	var vfx := Sprite2D.new()
	vfx.name = "WallClimbRewardRevealVfx"
	vfx.z_index = 29
	vfx.position = _wall_climb_reward_source.position
	vfx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	vfx.texture = texture
	vfx.scale = Vector2(0.34, 0.34)
	vfx.modulate = Color(0.55, 0.95, 1.0, 0.82)
	vfx.set_meta(&"vfx_role", &"boss4_wall_climb_reward_reveal")
	add_child(vfx)
	_wall_climb_reward_reveal_vfx = vfx
	_wall_climb_reward_reveal_elapsed_sec = 0.0
	_wall_climb_reward_reveal_spawn_count += 1


func _advance_wall_climb_reward_reveal_vfx(delta_sec: float) -> void:
	if (
		_wall_climb_reward_reveal_vfx == null
		or not is_instance_valid(_wall_climb_reward_reveal_vfx)
	):
		return
	_wall_climb_reward_reveal_elapsed_sec += maxf(0.0, delta_sec)
	var progress: float = clampf(
		_wall_climb_reward_reveal_elapsed_sec
		/ WALL_CLIMB_REWARD_REVEAL_DURATION_SEC,
		0.0,
		1.0
	)
	_wall_climb_reward_reveal_vfx.scale = Vector2.ONE * (0.34 + progress * 0.72)
	_wall_climb_reward_reveal_vfx.modulate.a = 0.82 * (1.0 - progress)
	if progress >= 1.0:
		_clear_wall_climb_reward_reveal_vfx()


func _clear_wall_climb_reward_reveal_vfx() -> void:
	if (
		_wall_climb_reward_reveal_vfx != null
		and is_instance_valid(_wall_climb_reward_reveal_vfx)
	):
		_wall_climb_reward_reveal_vfx.queue_free()
	_wall_climb_reward_reveal_vfx = null
	_wall_climb_reward_reveal_elapsed_sec = 0.0


func _set_room_seals_enabled(enabled: bool) -> void:
	for seal: StaticBody2D in [_left_room_seal, _right_room_seal]:
		if seal == null:
			continue
		seal.visible = enabled
		seal.collision_layer = 16 if enabled else 0
		var collision_shape: CollisionShape2D = (
			seal.get_node_or_null("CollisionShape2D") as CollisionShape2D
		)
		if collision_shape != null:
			collision_shape.disabled = not enabled


func _are_room_seals_enabled() -> bool:
	for seal: StaticBody2D in [_left_room_seal, _right_room_seal]:
		if seal == null or not seal.visible or seal.collision_layer == 0:
			return false
		var collision_shape: CollisionShape2D = (
			seal.get_node_or_null("CollisionShape2D") as CollisionShape2D
		)
		if collision_shape == null or collision_shape.disabled:
			return false
	return true


func _sync_scene_lock() -> void:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if not _is_valid_scene_manager(scene_manager):
		return
	if _boss_defeated and not _boss_death_presentation_pending:
		_release_scene_lock()
		return
	if _scene_manager_lock_owned:
		return
	if (
		scene_manager.has_method("is_scene_locked")
		and bool(scene_manager.call("is_scene_locked"))
	):
		return
	if scene_manager.has_method("lock_scene"):
		scene_manager.call("lock_scene")
		_scene_manager_lock_owned = true


func _release_scene_lock() -> void:
	if not _scene_manager_lock_owned:
		return
	if (
		_scene_manager != null
		and is_instance_valid(_scene_manager)
		and _scene_manager.has_method("unlock_scene")
	):
		_scene_manager.call("unlock_scene")
	_scene_manager_lock_owned = false


func _on_player_attack_landed(metadata: Dictionary) -> void:
	var presentation_data: Dictionary = metadata.duplicate(true)
	if _hud != null and _hud.has_method("are_damage_numbers_enabled"):
		presentation_data["show_damage_number"] = _hud.are_damage_numbers_enabled()
	_last_player_hit_metadata = presentation_data.duplicate(true)
	if _combat_presentation != null:
		_combat_presentation.on_hit_event(presentation_data)
	_dispatch_combat_audio(&"on_hit_event", presentation_data)


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	if _hud != null:
		_hud.update_hp(current_hp, max_hp)


func _on_epilogue_ascent_checkpoint_activated() -> void:
	if _hud != null:
		_hud.show_notification("Crown Signal Checkpoint", 1.2)
	if _is_valid_scene_manager(_resolve_scene_manager_for_runtime()):
		_persist_progress()


func _on_epilogue_ascent_completed() -> void:
	_sync_victory_recall_route()
	_refresh_wall_climb_reward_objective()
	if _hud != null:
		_hud.show_notification("Crown Signal Linked", 1.5)
	if _is_valid_scene_manager(_resolve_scene_manager_for_runtime()):
		_persist_progress()


func _on_epilogue_ascent_fall_requested(provider: Node2D) -> void:
	if (
		provider != _player
		or _player == null
		or not _boss_defeated
		or not _player.has_method("apply_damage")
	):
		return
	_player.call("apply_damage", 9999, {
		"source": &"crown_observatory_epilogue_fall",
		"damage_type": &"fall",
	})


func _on_player_died(_death_metadata: Dictionary) -> void:
	if _player_retry_pending:
		return
	_player_retry_pending = true
	_player_death_count += 1
	if _boss_defeated:
		call_deferred("_reset_epilogue_ascent_after_player_death")
	else:
		call_deferred("_reset_active_boss4_encounter_after_player_death")


func _reset_epilogue_ascent_after_player_death() -> void:
	_player_retry_pending = false
	if not _boss_defeated or _player == null:
		return
	var respawn_position: Vector2 = (
		_epilogue_ascent.get_respawn_position()
		if _epilogue_ascent != null
		else Vector2.ZERO
	)
	if respawn_position == Vector2.ZERO and _entry_spawn != null:
		respawn_position = _entry_spawn.global_position
	if _player.has_method("respawn_at"):
		_player.call("respawn_at", respawn_position, 1.0)
	_sync_boss4_combat_state()


func _reset_active_boss4_encounter_after_player_death() -> void:
	_player_retry_pending = false
	if _boss_defeated:
		return
	_return_transition_requested = false
	_last_return_rejected_reason = &""
	_last_return_request.clear()
	_last_boss_attack_metadata.clear()
	_last_parry_counter_metadata.clear()
	_parry_counter_count = 0
	if _boss != null and _boss.has_method("reset_encounter"):
		_boss.call("reset_encounter")
	if _player != null and _entry_spawn != null and _player.has_method("respawn_at"):
		_player.call("respawn_at", _entry_spawn.global_position, 1.0)
	_sync_boss4_combat_state()


func _on_boss4_health_changed(current_hp: int, max_hp: int) -> void:
	if _hud == null or _boss_defeated or _boss == null:
		return
	_hud.update_boss_hp(
		current_hp,
		max_hp,
		int(_boss.call("get_current_phase")),
		BOSS_DISPLAY_NAME
	)


## Advances the transient Boss4 death hold without persisting timer state.
func advance_boss4_death_presentation(delta_sec: float) -> bool:
	if not _boss_death_presentation_pending:
		return false
	_boss_death_presentation_remaining_sec = maxf(
		0.0,
		_boss_death_presentation_remaining_sec - maxf(0.0, delta_sec)
	)
	if _boss_death_presentation_remaining_sec > 0.0:
		return false
	_boss_death_presentation_pending = false
	_set_player_reward_control_locked(false)
	_sync_boss4_combat_state()
	_spawn_wall_climb_reward_reveal_vfx()
	return true


## Returns the complete Story025 hold contract for tests and MCP probes.
func get_boss4_death_presentation_diagnostics() -> Dictionary:
	var boss_sprite: AnimatedSprite2D = (
		_boss.get_node_or_null("Sprite") as AnimatedSprite2D
		if _boss != null
		else null
	)
	var boss_collision: CollisionComponent = (
		_boss.call("get_collision_component") as CollisionComponent
		if _boss != null and _boss.has_method("get_collision_component")
		else null
	)
	var reward_canvas: CanvasItem = _wall_climb_reward_source as CanvasItem
	return {
		"pending": _boss_death_presentation_pending,
		"remaining_sec": _boss_death_presentation_remaining_sec,
		"hold_duration_sec": BOSS_DEATH_PRESENTATION_HOLD_SEC,
		"boss_defeated": _boss_defeated,
		"boss_visible": _boss != null and _boss.visible,
		"animation": String(boss_sprite.animation) if boss_sprite != null else "",
		"death_frame_count": (
			boss_sprite.sprite_frames.get_frame_count(&"death")
			if boss_sprite != null and boss_sprite.sprite_frames != null
			else 0
		),
		"active_hitbox_count": (
			boss_collision.get_active_hitbox_count()
			if boss_collision != null
			else -1
		),
		"reward_visible": reward_canvas != null and reward_canvas.visible,
		"reward_available": (
			bool(_wall_climb_reward_source.call("is_claim_available"))
			if _wall_climb_reward_source != null
			and _wall_climb_reward_source.has_method("is_claim_available")
			else false
		),
		"room_seals_enabled": _are_room_seals_enabled(),
		"return_route_available": (
			bool(_return_route.call("is_route_available"))
			if _return_route != null and _return_route.has_method("is_route_available")
			else false
		),
		"recall_route_available": (
			bool(_victory_recall_route.call("is_route_available"))
			if _victory_recall_route != null
			and _victory_recall_route.has_method("is_route_available")
			else false
		),
		"scene_manager_locked": _is_scene_manager_locked(),
		"player_control_locked": (
			_boss_death_presentation_pending
			or _wall_climb_reward_feedback_remaining_sec > 0.0
		),
		"reveal_vfx_spawn_count": _wall_climb_reward_reveal_spawn_count,
		"objective_text": _objective_label.text if _objective_label != null else "",
	}


func _on_boss4_defeated() -> void:
	if _boss_defeated:
		return
	_boss_defeated = true
	_boss_death_presentation_pending = true
	_boss_death_presentation_remaining_sec = BOSS_DEATH_PRESENTATION_HOLD_SEC
	_set_player_reward_control_locked(true)
	if _combat_presentation != null:
		_combat_presentation.on_kill_event(
			BOSS_ENTITY_ID,
			_boss.global_position if _boss != null else Vector2.ZERO
		)
	_sync_boss4_combat_state()
	if _is_valid_scene_manager(_resolve_scene_manager_for_runtime()):
		_persist_progress()


func _on_boss4_phase_transition_started(
	entity_id: int,
	phase: int,
	metadata: Dictionary
) -> void:
	if _boss == null or _boss_defeated or entity_id != BOSS_ENTITY_ID:
		return
	var presentation_metadata: Dictionary = metadata.duplicate(true)
	if not presentation_metadata.has("world_position"):
		presentation_metadata["world_position"] = _boss.global_position
	if not presentation_metadata.has("position"):
		presentation_metadata["position"] = _boss.global_position
	if _combat_presentation != null:
		_combat_presentation.on_boss_phase_transition_started(
			entity_id,
			phase,
			presentation_metadata
		)
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method(
		"on_boss_phase_transition_started"
	):
		audio_system.call(
			"on_boss_phase_transition_started",
			entity_id,
			phase,
			presentation_metadata
		)
	if _hud != null:
		_hud.update_boss_hp(
			int(_boss.call("get_current_hp")),
			int(_boss.call("get_max_hp")),
			phase,
			BOSS_DISPLAY_NAME
		)


func _on_boss4_attack_landed(
	damage: int,
	hit_position: Vector2,
	is_crit: bool
) -> void:
	_last_boss_attack_metadata = {
		"damage": damage,
		"hit_position": hit_position,
		"is_crit": is_crit,
		"source": BOSS_ID,
	}
	if _hud != null and _hud.has_method("are_damage_numbers_enabled"):
		_last_boss_attack_metadata["show_damage_number"] = (
			_hud.are_damage_numbers_enabled()
		)
	if _combat_presentation != null:
		_combat_presentation.on_hit_event(_last_boss_attack_metadata)
	_dispatch_combat_audio(&"on_damage_taken_event", _last_boss_attack_metadata)


func _setup_hitstop_input_buffer() -> void:
	if _combat_presentation == null or _player == null:
		return
	var camera: Camera2D = _player.get_node_or_null("Camera2D") as Camera2D
	if camera != null:
		_combat_presentation.set_camera(camera)
	if _hitstop_input_bridge != null:
		_hitstop_input_bridge.configure(
			_combat_presentation,
			_player as PlayerController,
			get_node_or_null("/root/InputManager")
		)


func get_last_buffered_input_result() -> Dictionary:
	if _hitstop_input_bridge == null:
		return {}
	return _hitstop_input_bridge.get_last_buffered_input_result()


func _dispatch_combat_audio(method: StringName, metadata: Dictionary) -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method(method):
		audio_system.call(method, metadata)


func _on_player_parry_resolved(parry_data: Dictionary) -> void:
	if (
		not bool(parry_data.get("is_success", false))
		or _boss == null
		or _boss_defeated
		or _boss_config_component == null
		or not _boss_config_component.has_boss_config()
		or not _boss.has_method("get_attack_phase")
		or StringName(String(_boss.call("get_attack_phase"))) != &"active"
	):
		return
	var parry_type := StringName(String(parry_data.get("parry_type", &"miss")))
	var boss_outcome: Dictionary = _boss_config_component.resolve_parry_outcome(
		parry_type
	)
	if not bool(boss_outcome.get("is_success", false)):
		return
	var base_damage: int = PARRY_COUNTER_BASE_DAMAGE_FALLBACK
	if _weapon_component != null:
		base_damage = maxi(
			1,
			_weapon_component.get_effective_base_damage()
		)
	var damage_multiplier: float = float(boss_outcome.get(
		"damage_multiplier",
		1.0
	))
	var counter_damage: int = maxi(1, roundi(float(base_damage) * damage_multiplier))
	var presentation_data: Dictionary = _build_boss4_parry_presentation_data(
		parry_data
	)
	_last_parry_counter_metadata = boss_outcome.duplicate(true)
	_last_parry_counter_metadata.merge({
		"source": &"crown_warden_parry_counter",
		"attacker_id": 1,
		"target_id": BOSS_ENTITY_ID,
		"attack_type": &"parry",
		"base_damage": base_damage,
		"counter_damage": counter_damage,
		"parry_frame": int(parry_data.get("parry_frame", -1)),
		"hit_position": presentation_data.get("position", _player.global_position),
	}, true)
	_parry_counter_count += 1
	_boss.call(
		"apply_damage",
		counter_damage,
		_last_parry_counter_metadata.duplicate(true)
	)
	if _combat_presentation != null:
		_combat_presentation.on_parry_event(presentation_data)
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method("on_parry_event"):
		audio_system.call("on_parry_event", presentation_data)


func _build_boss4_parry_presentation_data(parry_data: Dictionary) -> Dictionary:
	var enriched: Dictionary = parry_data.duplicate(true)
	var parry_position: Vector2 = _player.global_position
	var sprite: AnimatedSprite2D = (
		_player.get_node_or_null("Sprite") as AnimatedSprite2D
	)
	if sprite != null:
		parry_position = sprite.global_position
		var frame_texture: Texture2D = sprite.sprite_frames.get_frame_texture(
			sprite.animation,
			sprite.frame
		)
		if frame_texture != null:
			enriched["texture"] = frame_texture
		enriched["facing"] = -1.0 if sprite.flip_h else 1.0
		enriched["animation"] = sprite.animation
		enriched["frame"] = sprite.frame
	enriched["position"] = parry_position
	enriched["source"] = &"crown_warden_parry_counter"
	return enriched


func _get_epilogue_ascent_state() -> Dictionary:
	if _epilogue_ascent == null:
		return {
			"checkpoint_activated": false,
			"completed": false,
		}
	return _epilogue_ascent.get_diagnostics()


func _is_epilogue_ascent_completed() -> bool:
	return _epilogue_ascent != null and _epilogue_ascent.is_completed()


func _get_camera_limit_right() -> int:
	if _player == null:
		return 0
	var camera: Camera2D = _player.get_node_or_null("Camera2D") as Camera2D
	return camera.limit_right if camera != null else 0


func _update_objective_screen_position() -> void:
	if _objective_label == null or _player == null:
		return
	var camera: Camera2D = _player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		return
	var screen_center: Vector2 = camera.get_screen_center_position()
	_objective_label.position = screen_center + Vector2(-244.0, -280.0)


func _align_player_after_state_restore() -> bool:
	if _player == null:
		return false
	var restore_position: Vector2 = (
		_epilogue_ascent.get_respawn_position()
		if _epilogue_ascent != null
		else Vector2.ZERO
	)
	if restore_position == Vector2.ZERO:
		return _align_player_to_entry_spawn()
	_player.global_position = restore_position
	if _player is CharacterBody2D:
		(_player as CharacterBody2D).velocity = Vector2.ZERO
	return true


func _align_player_to_entry_spawn() -> bool:
	if _player == null or _entry_spawn == null:
		return false
	_player.global_position = _entry_spawn.global_position
	if _player is CharacterBody2D:
		(_player as CharacterBody2D).velocity = Vector2.ZERO
	return true


func _apply_current_scene_manager_spawn_point() -> bool:
	if not _is_valid_scene_manager(_scene_manager):
		return false
	if (
		_scene_manager.has_method("get_current_scene")
		and StringName(_scene_manager.call("get_current_scene")) != SCENE_ID
	):
		return false
	if not _scene_manager.has_method("get_current_spawn_point"):
		return false
	var spawn_point := StringName(_scene_manager.call("get_current_spawn_point"))
	if spawn_point not in [ENTRY_SPAWN_POINT, &"default"]:
		return false
	return _align_player_to_entry_spawn()


func _is_provider_near_return(provider: Node) -> bool:
	return (
		_return_route != null
		and provider != null
		and _return_route.has_method("is_provider_in_transition_range")
		and bool(_return_route.call(
			"is_provider_in_transition_range",
			provider
		))
	)


func _is_provider_near_victory_recall(provider: Node) -> bool:
	return (
		_victory_recall_route != null
		and provider != null
		and _victory_recall_route.has_method("is_provider_in_transition_range")
		and bool(_victory_recall_route.call(
			"is_provider_in_transition_range",
			provider
		))
	)


func _persist_progress() -> bool:
	if not _scene_manager.has_method("set_scene_state"):
		return false
	var arena_persisted: bool = bool(_scene_manager.call(
		"set_scene_state",
		SCENE_ID,
		get_local_state()
	))
	var all_persisted: bool = arena_persisted
	for target_scene_id: StringName in [TOWER_SCENE_ID, MAIN_SCENE_ID]:
		if (
			_scene_manager.has_method("has_scene")
			and not bool(_scene_manager.call("has_scene", target_scene_id))
		):
			continue
		var target_state: Dictionary = {}
		if _scene_manager.has_method("get_scene_state"):
			target_state = Dictionary(_scene_manager.call(
				"get_scene_state",
				target_scene_id
			)).duplicate(true)
		target_state["unlocked_abilities"] = (
			_get_player_unlocked_ability_strings()
		)
		all_persisted = bool(_scene_manager.call(
			"set_scene_state",
			target_scene_id,
			target_state
		)) and all_persisted
	return all_persisted


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


func _ensure_runtime_scene_root() -> bool:
	if not _scene_manager.has_method("configure_runtime_scene_root"):
		return true
	if _scene_manager.has_method("is_runtime_scene_swap_enabled") and bool(
		_scene_manager.call("is_runtime_scene_swap_enabled")
	):
		return true
	if not is_inside_tree() or get_parent() == null:
		return false
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
	var unlocked: Array = Array(state.get(
		"unlocked_abilities",
		_get_player_unlocked_ability_strings()
	))
	if (
		_wall_climb_reward_claimed
		and not unlocked.has(String(WALL_CLIMB_ABILITY_ID))
	):
		unlocked.append(String(WALL_CLIMB_ABILITY_ID))
	_player.call("set_unlocked_abilities", unlocked)


func _has_player_ability(ability_id: StringName) -> bool:
	return (
		_player != null
		and _player.has_method("has_ability")
		and bool(_player.call("has_ability", ability_id))
	)


func _record_return_rejection(reason: StringName) -> void:
	_last_return_rejected_reason = reason
	_last_return_request.clear()


func _texture_path(sprite: Sprite2D) -> String:
	return (
		sprite.texture.resource_path
		if sprite != null and sprite.texture != null
		else ""
	)


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


func _is_scene_manager_locked() -> bool:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	return (
		bool(scene_manager.call("is_scene_locked"))
		if scene_manager != null and scene_manager.has_method("is_scene_locked")
		else false
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
