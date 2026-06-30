## Main playable scene wiring for the current vertical slice.
extends Node2D

@onready var _player: PlayerController = $Player
@onready var _enemy = $Enemy
@onready var _boss2_echo_guardian: Node = get_node_or_null("Boss2EchoGuardian")
@onready var _boss2_reward_source: Node = get_node_or_null("Boss2DoubleJumpRewardSource")
@onready var _hud = $HUD
@onready var _combat_presentation = $CombatPresentation
@onready var _game_flow = $GameFlowController

const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")
const RUNTIME_DAMAGE_CALCULATOR_ADAPTER_SCRIPT: Script = preload("res://src/gameplay/runtime_damage_calculator_adapter.gd")
const SAVE_TRIGGER_ADAPTER_SCRIPT: Script = preload("res://src/feature/save_trigger_adapter.gd")
const SKILL_TREE_MANAGER_SCRIPT: Script = preload("res://src/feature/skill_tree_manager.gd")
const RAT_MINION_SCENE: PackedScene = preload("res://src/gameplay/rat_minion.tscn")
const GARBAGE_PILE_TEXTURE: Texture2D = preload(
	"res://assets/environment/rat_king_arena/garbage_pile.png"
)
const OVERTURNED_TRASH_CAN_TEXTURE: Texture2D = preload(
	"res://assets/environment/rat_king_arena/overturned_trash_can.png"
)
const ELECTRIC_LEAK_TEXTURE: Texture2D = preload(
	"res://assets/environment/rat_king_arena/electric_leak.png"
)
const ARENA_DEBRIS_DUST_VFX_TEXTURE: Texture2D = preload(
	"res://assets/environment/rat_king_arena/vfx/arena_debris_dust.png"
)
const ELECTRIC_LEAK_HAZARD_GLOW_VFX_TEXTURE: Texture2D = preload(
	"res://assets/environment/rat_king_arena/vfx/electric_leak_hazard_glow.png"
)
const ELECTRIC_LEAK_SPARK_VFX_TEXTURE: Texture2D = preload(
	"res://assets/environment/rat_king_arena/vfx/electric_leak_spark.png"
)
const MAIN_SCENE_SAVE_KEY: StringName = &"main_scene"
const SCENE_MANAGER_SAVE_KEY: StringName = &"scene"
const MAIN_SCENE_ID: String = "main"
const DEFAULT_NEW_GAME_SPAWN_POINT: StringName = &"default"
const RAT_KING_BOSS_ID: String = "boss_01_rat_king"
const RAT_KING_BOSS_DISPLAY_NAME: String = "垃圾桶鼠王"
const RAT_KING_ATTACK_SOURCE: StringName = &"rat_king_claw"
const RAT_MINION_ATTACK_SOURCE: StringName = &"rat_minion_bite"
const BOSS2_ATTACK_SOURCE: StringName = &"boss2_echo_swipe"
const RAT_MINION_SUMMON_ID: StringName = &"summon_minion"
const RAT_MINION_SUMMON_CAP: int = 2
const RAT_MINION_ENTITY_ID_START: int = 2000
const RAT_MINION_SPAWN_OFFSET_X: float = 96.0
const HIDDEN_DOUBLE_JUMP_REWARD_NODE_PATH: NodePath = ^"HiddenDoubleJumpRewardSource"
const HIDDEN_DOUBLE_JUMP_REWARD_ID: StringName = &"hidden_boss_echo_double_jump"
const HIDDEN_DOUBLE_JUMP_REWARD_ABILITY_ID: StringName = &"double_jump"
const HIDDEN_DOUBLE_JUMP_REWARD_CLAIMED_FLAG: StringName = &"hidden_boss_echo_double_jump_claimed"
const HIDDEN_DOUBLE_JUMP_REWARD_NOTIFICATION: String = "Double Jump unlocked"
const BOSS2_DOUBLE_JUMP_REWARD_NODE_PATH: NodePath = ^"Boss2DoubleJumpRewardSource"
const BOSS2_ECHO_GUARDIAN_NODE_PATH: NodePath = ^"Boss2EchoGuardian"
const BOSS2_ECHO_GUARDIAN_ENTITY_ID: int = 2200
const BOSS2_DOUBLE_JUMP_REWARD_ID: StringName = &"boss_02_double_jump"
const BOSS2_DOUBLE_JUMP_REWARD_ABILITY_ID: StringName = &"double_jump"
const BOSS2_DOUBLE_JUMP_REWARD_CLAIMED_FLAG: StringName = &"boss_02_double_jump_claimed"
const BOSS2_ECHO_GUARDIAN_DEFEATED_FLAG: StringName = &"boss_02_echo_guardian_defeated"
const BOSS2_ECHO_GUARDIAN_BOSS_ID: StringName = &"boss_02_echo_guardian"
const BOSS2_DOUBLE_JUMP_REWARD_NOTIFICATION: String = "Double Jump unlocked"
const BOSS2_ECHO_GUARDIAN_DISPLAY_NAME: String = "Echo Guardian"
const BOSS2_CAMERA_PATH: NodePath = ^"Player/Camera2D"
const BOSS2_CAMERA_LOCK_LIMIT_LEFT: int = 0
const BOSS2_CAMERA_LOCK_LIMIT_TOP: int = 0
const BOSS2_CAMERA_LOCK_LIMIT_RIGHT: int = 1040
const BOSS2_CAMERA_LOCK_LIMIT_BOTTOM: int = 720
const BOSS2_CAMERA_LOCK_ZOOM: Vector2 = Vector2(1.15, 1.15)
const BOSS2_CAMERA_LOCK_SMOOTHING_SPEED: float = 10.0
const BOSS2_LEFT_ROOM_SEAL_PATH: NodePath = ^"Boss2LeftRoomSeal"
const BOSS2_RIGHT_ROOM_SEAL_PATH: NodePath = ^"Boss2RightRoomSeal"
const BOSS2_ROOM_SEAL_TEXTURE_PATH: String = (
	"res://assets/environment/boss2_arena/boss2_echo_guardian_room_seal.png"
)
const SAVEPOINT_NOTIFICATION_SUFFIX: String = " saved"
const CAT_CLAW_T1A_SKILL_ID: StringName = &"cat_claw_t1a"
const FACTORY_ROUTE_SHELL_NODE_PATH: NodePath = ^"FactoryRouteTransitionShell"
const SCRAP_ROOST_SAVEPOINT_NODE_PATH: NodePath = ^"ScrapRoostSavepoint"
const FACTORY_ROUTE_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_ROUTE_SPAWN_POINT: StringName = &"factory_gate_entry"
const FACTORY_ROUTE_UNLOCKED_FLAG: StringName = &"area_03_factory_unlocked"
const FACTORY_ROUTE_ENTRY_PROMPT: String = "Enter Factory Route"
const FACTORY_ROUTE_RETURN_PROMPT: String = "Return to Factory Route"
const ARENA_OBSTACLE_LAYER: int = 16
const ARENA_DAMAGE_ZONE_LAYER: int = CollisionComponent.COLLISION_LAYER_ENVIRONMENT
const ARENA_DAMAGE_ZONE_MASK: int = CollisionComponent.COLLISION_MASK_ENVIRONMENT
const ELECTRIC_LEAK_CONTACT_DAMAGE: int = 8
const ELECTRIC_LEAK_CONTACT_COOLDOWN_SEC: float = 1.0
const ARENA_MUTATION_LAYOUTS: Dictionary = {
	"garbage_pile": {
		"position": Vector2(700, 492),
		"size": Vector2(126, 46),
		"color": Color(0.43, 0.53, 0.50, 1.0),
		"texture": GARBAGE_PILE_TEXTURE,
		"vfx_role": &"arena_destruction",
		"vfx": [{
			"name": "DebrisDust",
			"role": &"debris_dust",
			"texture": ARENA_DEBRIS_DUST_VFX_TEXTURE,
			"position": Vector2(0, -36),
			"scale": Vector2(0.50, 0.50),
			"z_index": 2,
			"modulate": Color(1, 1, 1, 0.92),
		}],
	},
	"overturned_trash_can": {
		"position": Vector2(860, 486),
		"size": Vector2(136, 56),
		"color": Color(0.38, 0.47, 0.55, 1.0),
		"texture": OVERTURNED_TRASH_CAN_TEXTURE,
		"vfx_role": &"arena_destruction",
		"vfx": [{
			"name": "DebrisDust",
			"role": &"debris_dust",
			"texture": ARENA_DEBRIS_DUST_VFX_TEXTURE,
			"position": Vector2(0, -38),
			"scale": Vector2(0.52, 0.52),
			"z_index": 2,
			"modulate": Color(1, 1, 1, 0.9),
		}],
	},
	"electric_leak": {
		"position": Vector2(1010, 520),
		"size": Vector2(160, 24),
		"color": Color(0.50, 0.84, 1.0, 0.72),
		"texture": ELECTRIC_LEAK_TEXTURE,
		"vfx_role": &"electric_hazard",
		"vfx": [{
			"name": "HazardGlow",
			"role": &"hazard_glow",
			"texture": ELECTRIC_LEAK_HAZARD_GLOW_VFX_TEXTURE,
			"position": Vector2(0, -18),
			"scale": Vector2(0.56, 0.56),
			"z_index": 2,
			"modulate": Color(1, 1, 1, 0.88),
		}, {
			"name": "ElectricSpark",
			"role": &"electric_spark",
			"texture": ELECTRIC_LEAK_SPARK_VFX_TEXTURE,
			"position": Vector2(0, -54),
			"scale": Vector2(0.38, 0.38),
			"z_index": 3,
			"modulate": Color(1, 1, 1, 1),
		}],
	},
}

var _pause_menu_active: bool = false
var _currency_amount: int = 0
var _skill_points: int = 0
var _unlocked_abilities: Array[StringName] = []
var _inventory_items: Array[StringName] = []
var _acquired_weapons: Array[StringName] = [&"cat_claw"]
var _current_weapon_id: StringName = &"cat_claw"
var _weapon_levels: Dictionary = {"cat_claw": 0}
var _world_progress_flags: Dictionary = {}
var _weapon_component: WeaponComponent = null
var _skill_tree_manager = null
var _damage_calculator_adapter: Object = null
var _last_player_hit_metadata: Dictionary = {}
var _save_system: Object = null
var _registered_save_system: Object = null
var _save_trigger_adapter: SaveTriggerAdapter = null
var _boss_phase_transition_source: Object = null
var _pending_manual_save_slot: int = -1
var _scene_manager: Object = null
var _connected_scene_manager: Object = null
var _audio_system: Object = null
var _boss_music_audio_system: Object = null
var _last_discovered_savepoint: Dictionary = {}
var _summons_container: Node2D = null
var _summoned_minions: Array[Node] = []
var _next_summon_entity_id: int = RAT_MINION_ENTITY_ID_START
var _arena_mutations_container: Node2D = null
var _applied_arena_mutation_keys: Dictionary = {}
var _arena_hazard_elapsed_sec: float = 0.0
var _arena_hazard_contact_cooldowns: Dictionary = {}
var _boss_scene_locked: bool = false
var _boss_reward_collection_active: bool = false
var _last_boss_reward_summary: Dictionary = {}
var _boss2_camera_default_state: Dictionary = {}
var _boss2_camera_lock_enabled: bool = false
var _boss2_camera_lock_reason: StringName = &"not_initialized"
var _boss2_room_seals_enabled: bool = false
var _boss2_room_seal_reason: StringName = &"not_initialized"


func _ready() -> void:
	_setup_skill_tree_manager()
	_setup_weapon_component()
	_ensure_summons_container()
	_ensure_arena_mutations_container()
	_setup_player_attack_core_chain()
	_setup_enemy_attack_core_chain()
	_setup_boss2_attack_core_chain()
	_game_flow.set_no_loss_state_adapter(self)
	_game_flow.set_savepoint_adapter(self)
	_setup_main_scene_savepoints()
	_game_flow.configure_clan_base_respawn(&"hub", &"clan_base", _player.global_position)
	_game_flow.configure_boss_entrance_respawn(
		StringName(MAIN_SCENE_ID),
		&"boss_entrance",
		_player.global_position
	)
	_game_flow.start_boss_encounter(_player.global_position, self)
	_game_flow.respawn_requested.connect(_on_respawn_requested)
	_game_flow.victory_reached.connect(_on_victory_reached)
	_hud.menu_pause_requested.connect(_on_menu_pause_requested)
	_hud.menu_resume_requested.connect(_on_menu_resume_requested)
	_hud.menu_retry_requested.connect(_on_menu_retry_requested)
	_hud.menu_settings_requested.connect(_on_menu_settings_requested)
	_hud.menu_new_game_requested.connect(_on_menu_new_game_requested)
	_hud.menu_continue_requested.connect(_on_menu_continue_requested)
	_hud.menu_load_menu_requested.connect(_on_menu_load_menu_requested)
	_hud.menu_main_menu_requested.connect(_on_menu_main_menu_requested)
	_hud.menu_exit_requested.connect(_on_menu_exit_requested)
	_hud.menu_save_slot_requested.connect(_on_menu_save_slot_requested)
	_hud.menu_load_slot_requested.connect(_on_menu_load_slot_requested)
	_hud.menu_skill_tree_requested.connect(_on_menu_skill_tree_requested)
	_hud.skill_unlock_requested.connect(_on_skill_unlock_requested)
	_hud.colorblind_mode_changed.connect(_on_hud_colorblind_mode_changed)
	_player.player_health_changed.connect(_on_player_health_changed)
	_player.player_died.connect(_on_player_died)
	_player.attack_landed.connect(_on_player_attack_landed)
	_player.attack_started.connect(_on_player_attack_started)
	_player.dodge_started.connect(_on_player_dodge_started)
	_connect_player_parry_signal()
	if _player.has_signal("dash_started"):
		_player.dash_started.connect(_on_player_dash_started)
	if _player.has_signal("double_jump_started"):
		_player.double_jump_started.connect(_on_player_double_jump_started)
	_connect_player_focus_mode_signal()
	_enemy.enemy_health_changed.connect(_on_enemy_health_changed)
	_enemy.enemy_defeated.connect(_on_enemy_defeated)
	_register_enemy_boss_phase_source()
	_combat_presentation.set_camera($Player/Camera2D)
	_capture_boss2_camera_default_state()
	_sync_combat_presentation_accessibility_settings()

	_hud.update_hp(_player.get_current_hp(), _player.get_max_hp())
	_hud.update_currency(_currency_amount)
	_sync_player_unlocked_abilities()
	_sync_exploration_gates()
	_sync_hidden_double_jump_reward_source()
	_setup_boss2_double_jump_payoff()
	refresh_boss2_camera_lock()
	refresh_boss2_room_seals()
	_refresh_boss_hud()
	_sync_factory_route_transition_shell()
	_update_weapon_hud()
	configure_save_system_runtime(get_node_or_null("/root/SaveSystem"))
	configure_scene_manager_runtime(get_node_or_null("/root/SceneManager"))
	configure_audio_system_runtime(get_node_or_null("/root/AudioSystem"))
	_hud.show_notification("Hunt the Rat King", 2.0)


func _exit_tree() -> void:
	cleanup_temporary_summons()
	clear_arena_locks()
	_disconnect_scene_manager_signals()
	_disconnect_boss_phase_transition_source()
	_unregister_main_scene_from_save_system()


func _process(delta: float) -> void:
	_player.set_control_locked(_game_flow.is_player_control_locked())
	advance_arena_hazard_time(delta)
	_process_hidden_double_jump_reward_source_contact()
	_process_boss2_double_jump_reward_source_contact()
	_process_factory_route_transition_shell_contact()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_swap") and not _hud.is_menu_visible():
		request_weapon_swap()
		get_viewport().set_input_as_handled()


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	_hud.update_hp(current_hp, max_hp)


func _on_player_died(death_metadata: Dictionary) -> void:
	_game_flow.handle_player_death()
	if _hud.is_battle_summary_enabled():
		_hud.show_battle_summary(_battle_summary_from_death_metadata(death_metadata))
	_hud.show_notification("Cinderpaw falls - reviving", 1.5)


func _on_player_attack_landed(hit_data: Dictionary) -> void:
	var enriched_hit_data: Dictionary = _apply_weapon_effects_to_player_hit(hit_data)
	enriched_hit_data["show_damage_number"] = _hud.are_damage_numbers_enabled()
	_last_player_hit_metadata = enriched_hit_data.duplicate(true)
	_combat_presentation.on_hit_event(enriched_hit_data)
	_dispatch_audio_event(&"on_hit_event", [enriched_hit_data])


func _on_player_attack_started(attack_data: Dictionary) -> void:
	_combat_presentation.on_weapon_attack_event(attack_data)
	_dispatch_audio_event(&"on_weapon_attack_event", [attack_data])


func _on_player_dodge_started(texture: Texture2D, world_position: Vector2, facing: float) -> void:
	_combat_presentation.on_dodge_event(texture, world_position, facing)
	_dispatch_audio_event(&"on_dodge_event", [texture, world_position, facing])


func _on_player_dash_started(texture: Texture2D, world_position: Vector2, facing: float) -> void:
	_combat_presentation.on_dodge_event(texture, world_position, facing)
	_dispatch_audio_event(&"on_dodge_event", [texture, world_position, facing])


func _on_player_double_jump_started(texture: Texture2D, world_position: Vector2, facing: float) -> void:
	_combat_presentation.on_double_jump_event(texture, world_position, facing)
	_dispatch_audio_event(&"on_double_jump_event", [texture, world_position, facing])


func _on_player_parry_resolved(parry_data: Dictionary) -> void:
	var enriched_parry_data: Dictionary = parry_data.duplicate(true)
	var parry_position: Vector2 = _player.global_position
	var sprite: Node2D = _player.get_node_or_null("Sprite") as Node2D
	if sprite != null:
		parry_position = sprite.global_position
	if not enriched_parry_data.has("position"):
		enriched_parry_data["position"] = parry_position
	enriched_parry_data["source"] = &"player_parry"
	_combat_presentation.on_parry_event(enriched_parry_data)
	_dispatch_audio_event(&"on_parry_event", [enriched_parry_data])


func _on_enemy_attack_landed(damage: int, hit_position: Vector2, is_crit: bool) -> void:
	var hit_data: Dictionary = {
		"damage": damage,
		"hit_position": hit_position,
		"is_crit": is_crit,
		"source": RAT_KING_ATTACK_SOURCE,
		"show_damage_number": _hud.are_damage_numbers_enabled(),
		"focus_mode_active": _is_player_focus_mode_active(),
	}
	_combat_presentation.on_hit_event(hit_data)
	_dispatch_audio_event(&"on_damage_taken_event", [hit_data])


func _on_summon_attack_landed(damage: int, hit_position: Vector2, is_crit: bool) -> void:
	var hit_data: Dictionary = {
		"damage": damage,
		"hit_position": hit_position,
		"is_crit": is_crit,
		"source": RAT_MINION_ATTACK_SOURCE,
		"show_damage_number": _hud.are_damage_numbers_enabled(),
		"focus_mode_active": _is_player_focus_mode_active(),
	}
	_combat_presentation.on_hit_event(hit_data)
	_dispatch_audio_event(&"on_damage_taken_event", [hit_data])


func _on_boss2_attack_landed(damage: int, hit_position: Vector2, is_crit: bool) -> void:
	var hit_data: Dictionary = {
		"damage": damage,
		"hit_position": hit_position,
		"is_crit": is_crit,
		"source": BOSS2_ATTACK_SOURCE,
		"show_damage_number": _hud.are_damage_numbers_enabled(),
		"focus_mode_active": _is_player_focus_mode_active(),
	}
	_combat_presentation.on_hit_event(hit_data)
	_dispatch_audio_event(&"on_damage_taken_event", [hit_data])


func _on_enemy_health_changed(current_hp: int, max_hp: int) -> void:
	_refresh_boss_hud(current_hp, max_hp)


func _on_boss2_health_changed(_current_hp: int, _max_hp: int) -> void:
	_refresh_boss_hud()


func _on_enemy_defeated() -> void:
	cleanup_temporary_summons()
	cleanup_arena_mutations()
	_dispatch_audio_event(&"on_enemy_defeated", [{
		"target_id": RAT_KING_BOSS_ID,
		"position": _enemy.global_position + Vector2(0, -24),
	}])
	var boss_end_metadata: Dictionary = _build_boss_audio_metadata(_get_enemy_phase())
	boss_end_metadata["reason"] = &"defeated"
	_dispatch_audio_event(&"on_boss_encounter_ended", [
		StringName(RAT_KING_BOSS_ID),
		boss_end_metadata,
	])
	_combat_presentation.on_kill_event(2, _enemy.global_position + Vector2(0, -24))
	_game_flow.handle_enemy_defeated()
	set_world_progress_flag(&"boss_rat_king_defeated", true)
	_trigger_runtime_autosave(&"boss_defeat", {
		"boss_id": RAT_KING_BOSS_ID,
	})


func _on_respawn_requested(respawn_position: Vector2, revive_hp_percentage: float) -> void:
	_player.respawn_at(respawn_position, revive_hp_percentage)
	_hud.update_hp(_player.get_current_hp(), _player.get_max_hp())
	_hud.show_notification("Nine lives remain", 2.0)


func _on_victory_reached() -> void:
	_hud.hide_boss_hp()
	_show_victory_reward_feedback()


func _on_menu_pause_requested() -> void:
	if _game_flow.get_flow_state() == &"victory":
		return
	_pause_menu_active = true
	get_tree().paused = true
	_hud.show_pause_menu()
	_dispatch_audio_event(&"on_menu_opened", [{
		"menu_mode": &"pause",
		"source": &"pause_requested",
	}])


func _on_menu_resume_requested() -> void:
	if _pause_menu_active:
		get_tree().paused = false
	_pause_menu_active = false
	_hud.hide_menu()
	_dispatch_audio_event(&"on_menu_closed", [{
		"menu_mode": &"pause",
		"reason": &"resume",
	}])


func _on_menu_retry_requested() -> void:
	_pause_menu_active = false
	get_tree().paused = false
	_dispatch_audio_event(&"on_ui_confirm", [{
		"menu_mode": _hud.get_menu_mode(),
		"action": &"retry",
	}])
	_dispatch_audio_event(&"on_menu_closed", [{
		"menu_mode": _hud.get_menu_mode(),
		"reason": &"retry",
	}])
	get_tree().reload_current_scene()


func _on_menu_settings_requested() -> void:
	_dispatch_audio_event(&"on_ui_navigate", [{
		"from_menu_mode": _hud.get_menu_mode(),
		"to_menu_mode": &"settings",
	}])
	_hud.show_settings_menu(_hud.get_menu_mode())


func _on_menu_skill_tree_requested() -> void:
	_dispatch_audio_event(&"on_ui_navigate", [{
		"from_menu_mode": _hud.get_menu_mode(),
		"to_menu_mode": &"skill_tree",
	}])
	show_skill_tree_menu()


func _on_skill_unlock_requested(skill_id: StringName) -> void:
	if try_unlock_skill(skill_id):
		_dispatch_audio_event(&"on_ui_confirm", [{
			"menu_mode": _hud.get_menu_mode(),
			"skill_id": skill_id,
		}])
		return
	_dispatch_audio_event(&"on_ui_cancel", [{
		"menu_mode": _hud.get_menu_mode(),
		"skill_id": skill_id,
	}])


func _on_menu_new_game_requested() -> void:
	_dispatch_audio_event(&"on_ui_confirm", [{
		"menu_mode": _hud.get_menu_mode(),
		"action": &"new_game",
	}])
	if not _request_scene_manager_transition(StringName(MAIN_SCENE_ID), DEFAULT_NEW_GAME_SPAWN_POINT):
		_dispatch_audio_event(&"on_ui_cancel", [{
			"menu_mode": _hud.get_menu_mode(),
			"action": &"new_game",
			"reason": &"load_failed",
		}])
		_hud.show_notification("Load failed", 2.0)
		_hud.show_main_menu(_collect_save_slot_infos())
		return
	_pause_menu_active = false
	get_tree().paused = false
	_hud.hide_menu()
	_dispatch_audio_event(&"on_menu_closed", [{
		"menu_mode": &"main_menu",
		"reason": &"new_game",
	}])


func _on_menu_continue_requested() -> void:
	if _try_load_first_available_slot():
		_pause_menu_active = false
		get_tree().paused = false
		_hud.hide_menu()
		_dispatch_audio_event(&"on_menu_closed", [{
			"menu_mode": &"main_menu",
			"reason": &"continue",
		}])
		return
	_dispatch_audio_event(&"on_ui_cancel", [{
		"menu_mode": _hud.get_menu_mode(),
		"action": &"continue",
		"reason": &"load_failed",
	}])
	_hud.show_notification("Load failed", 2.0)
	_hud.show_main_menu(_collect_save_slot_infos())


func _on_menu_load_menu_requested() -> void:
	_dispatch_audio_event(&"on_ui_navigate", [{
		"from_menu_mode": _hud.get_menu_mode(),
		"to_menu_mode": &"save_load",
	}])
	_hud.show_save_load_menu(
		_collect_save_slot_infos(),
		false,
		"Saving requires a save point"
	)


func _on_menu_main_menu_requested() -> void:
	_pause_menu_active = false
	get_tree().paused = false
	_dispatch_audio_event(&"on_ui_navigate", [{
		"from_menu_mode": _hud.get_menu_mode(),
		"to_menu_mode": &"main_menu",
	}])
	_dispatch_audio_event(&"on_menu_opened", [{
		"menu_mode": &"main_menu",
		"source": &"main_menu_requested",
	}])
	_hud.show_main_menu(_collect_save_slot_infos())


func _on_menu_exit_requested() -> void:
	_dispatch_audio_event(&"on_ui_cancel", [{
		"menu_mode": _hud.get_menu_mode(),
		"action": &"exit",
		"reason": &"unavailable",
	}])
	_hud.show_notification("Exit is unavailable in this build", 2.0)


func _on_menu_save_slot_requested(slot: int) -> void:
	if _is_manual_save_write_pending():
		_dispatch_audio_event(&"on_ui_cancel", [{
			"menu_mode": _hud.get_menu_mode(),
			"action": &"save",
			"slot": slot,
			"reason": &"write_pending",
		}])
		_hud.show_notification("Saving...", 1.5)
		_hud.show_save_load_menu(
			_collect_save_slot_infos(),
			false,
			"Saving requires a save point"
		)
		return
	_pending_manual_save_slot = slot
	if save_runtime_to_slot(slot):
		if _save_system.has_method("is_save_write_pending") and bool(_save_system.call("is_save_write_pending")):
			_hud.show_notification("Saving...", 1.5)
		elif _pending_manual_save_slot == slot:
			_pending_manual_save_slot = -1
			_hud.show_notification("Game saved", 1.5)
	elif _pending_manual_save_slot == slot:
		_pending_manual_save_slot = -1
	_hud.show_save_load_menu(
		_collect_save_slot_infos(),
		false,
		"Saving requires a save point"
	)


func _on_menu_load_slot_requested(slot: int) -> void:
	if load_runtime_from_slot(slot):
		_pause_menu_active = false
		get_tree().paused = false
		_hud.hide_menu()
		_dispatch_audio_event(&"on_menu_closed", [{
			"menu_mode": &"save_load",
			"reason": &"load_slot",
			"slot": slot,
		}])
		return
	_dispatch_audio_event(&"on_ui_cancel", [{
		"menu_mode": _hud.get_menu_mode(),
		"action": &"load",
		"slot": slot,
		"reason": &"load_failed",
	}])
	_hud.show_notification("Load failed", 2.0)
	_hud.show_save_load_menu(
		_collect_save_slot_infos(),
		false,
		"Saving requires a save point"
	)


func _battle_summary_from_death_metadata(death_metadata: Dictionary) -> Dictionary:
	var battle_stats: Dictionary = Dictionary(death_metadata.get("battle_stats", {})).duplicate(true)
	if battle_stats.has("damage_received") and not battle_stats.has("damage_taken"):
		battle_stats["damage_taken"] = battle_stats["damage_received"]
	return battle_stats


func capture_boss_arena_snapshot() -> Dictionary:
	var snapshot: Dictionary = {
		"enemy": _enemy.capture_respawn_snapshot(),
	}
	var boss2: Node = _get_boss2_echo_guardian()
	if boss2 != null and boss2.has_method("capture_respawn_snapshot"):
		snapshot["boss2_echo_guardian"] = boss2.call("capture_respawn_snapshot")
	return snapshot


func reset_boss_arena_to_snapshot(snapshot: Dictionary) -> void:
	if not is_instance_valid(_enemy):
		return
	cleanup_temporary_summons()
	cleanup_arena_mutations()
	var enemy_snapshot: Dictionary = Dictionary(snapshot.get("enemy", {}))
	_enemy.restore_respawn_snapshot(enemy_snapshot)
	var boss2: Node = _get_boss2_echo_guardian()
	if boss2 != null:
		if _is_boss2_echo_guardian_defeated():
			if boss2.has_method("mark_defeated_from_progress"):
				boss2.call("mark_defeated_from_progress")
		elif boss2.has_method("restore_respawn_snapshot"):
			var boss2_snapshot: Dictionary = Dictionary(snapshot.get("boss2_echo_guardian", {}))
			if not boss2_snapshot.is_empty():
				boss2.call("restore_respawn_snapshot", boss2_snapshot)
	_sync_boss2_double_jump_payoff_state()
	refresh_boss2_camera_lock()
	refresh_boss2_room_seals()
	_refresh_boss_hud()


func cleanup_temporary_summons() -> void:
	cleanup_summons(StringName(RAT_KING_BOSS_ID))


func get_active_summon_count(boss_id: StringName) -> int:
	_prune_summoned_minions()
	var count: int = 0
	for minion: Node in _summoned_minions:
		if _is_live_summon_for_boss(minion, boss_id):
			count += 1
	return count


func request_summon(boss_id: StringName, summon_id: StringName) -> bool:
	if summon_id != RAT_MINION_SUMMON_ID:
		return false
	_prune_summoned_minions()
	if get_active_summon_count(boss_id) >= RAT_MINION_SUMMON_CAP:
		return false

	var minion: Node = RAT_MINION_SCENE.instantiate()
	if minion == null:
		return false
	_ensure_summons_container().add_child(minion)
	if not (
		minion.has_method("configure_summon")
		and minion.has_method("set_attack_target")
		and minion.has_method("set_damage_calculator_adapter")
	):
		minion.queue_free()
		return false
	minion.call("configure_summon", boss_id, _next_summon_entity_id, summon_id)
	_next_summon_entity_id += 1
	minion.global_position = _next_summon_position()
	minion.call("set_attack_target", _player)
	minion.call("set_damage_calculator_adapter", _damage_calculator_adapter)
	if minion.has_signal("enemy_attack_landed"):
		minion.connect("enemy_attack_landed", _on_summon_attack_landed)
	if minion.has_signal("enemy_defeated"):
		minion.connect("enemy_defeated", _on_summon_defeated.bind(minion))
	_summoned_minions.append(minion)

	if is_instance_valid(_enemy) and _enemy.has_method("play_special_attack_animation"):
		_enemy.call("play_special_attack_animation", summon_id)
	return true


func cleanup_summons(boss_id: StringName) -> void:
	for minion: Node in _summoned_minions.duplicate():
		if _is_summon_owned_by_boss(minion, boss_id) and minion.has_method("kill_summon"):
			minion.call("kill_summon", &"boss_cleanup")
	_prune_summoned_minions()


func get_summoned_minion_nodes() -> Array:
	_prune_summoned_minions()
	var minions: Array = []
	for minion: Node in _summoned_minions:
		if _is_live_summon_for_boss(minion, StringName(RAT_KING_BOSS_ID)):
			minions.append(minion)
	return minions


func apply_damage(target_id: int, final_damage: int, metadata: Dictionary = {}) -> bool:
	if final_damage <= 0:
		return false
	if is_instance_valid(_enemy) and _enemy.has_method("get_entity_id") \
			and int(_enemy.call("get_entity_id")) == target_id:
		_enemy.call("apply_damage", final_damage, metadata)
		return true
	if (
		is_instance_valid(_boss2_echo_guardian)
		and _boss2_echo_guardian.has_method("get_entity_id")
		and int(_boss2_echo_guardian.call("get_entity_id")) == target_id
	):
		_boss2_echo_guardian.call("apply_damage", final_damage, metadata)
		return true
	var minion: Node = _find_live_summon_by_entity_id(target_id)
	if minion == null:
		return false
	minion.call("apply_damage", final_damage, metadata)
	return true


func apply_arena_changes(boss_id: StringName, phase: int, changes: Array) -> void:
	for raw_change: Variant in changes:
		if not raw_change is Dictionary:
			continue
		var change: Dictionary = Dictionary(raw_change)
		var change_id: StringName = StringName(String(change.get("id", "")))
		var change_type: StringName = StringName(String(change.get("type", "")))
		if change_id == &"" or change_type == &"":
			continue
		var key: String = _arena_mutation_key(boss_id, phase, change_type, change_id)
		if _applied_arena_mutation_keys.has(key):
			continue
		var mutation: Node2D = _create_arena_mutation_node(boss_id, phase, change_type, change_id)
		if mutation == null:
			continue
		_ensure_arena_mutations_container().add_child(mutation)
		_applied_arena_mutation_keys[key] = true


func get_arena_mutation_nodes() -> Array:
	var nodes: Array = []
	for child: Node in _ensure_arena_mutations_container().get_children():
		if is_instance_valid(child) and not child.is_queued_for_deletion():
			nodes.append(child)
	return nodes


func get_arena_mutation_count() -> int:
	return get_arena_mutation_nodes().size()


## Captures active arena mutations as JSON-safe descriptors for save/load.
func get_arena_mutation_save_state() -> Array[Dictionary]:
	var entries_by_key: Dictionary = {}
	var keys: Array[String] = []
	for mutation: Node in get_arena_mutation_nodes():
		var entry: Dictionary = _build_arena_mutation_save_entry(mutation)
		if entry.is_empty():
			continue
		var key: String = _arena_mutation_key(
			StringName(String(entry.get("boss_id", ""))),
			int(entry.get("phase", 0)),
			StringName(String(entry.get("type", ""))),
			StringName(String(entry.get("id", "")))
		)
		if entries_by_key.has(key):
			continue
		entries_by_key[key] = entry
		keys.append(key)
	keys.sort()
	var result: Array[Dictionary] = []
	for key: String in keys:
		result.append(Dictionary(entries_by_key[key]).duplicate(true))
	return result


## Rebuilds arena mutation nodes from JSON-safe save descriptors.
func restore_arena_mutation_save_state(raw_mutations: Variant) -> void:
	cleanup_arena_mutations()
	if not raw_mutations is Array:
		return
	var saved_mutations: Array = raw_mutations
	for raw_entry: Variant in saved_mutations:
		if not raw_entry is Dictionary:
			continue
		var entry: Dictionary = Dictionary(raw_entry)
		var boss_id: StringName = StringName(String(entry.get("boss_id", "")))
		var phase: int = _read_int(entry.get("phase", 0), 0)
		var change_id: StringName = StringName(String(entry.get("id", entry.get("change_id", ""))))
		var change_type: StringName = StringName(String(entry.get("type", entry.get("change_type", ""))))
		if boss_id == &"" or phase <= 0 or change_id == &"" or change_type == &"":
			continue
		apply_arena_changes(boss_id, phase, [{
			"id": String(change_id),
			"type": String(change_type),
		}])


func cleanup_arena_mutations(boss_id: StringName = &"") -> void:
	if not is_instance_valid(_arena_mutations_container):
		_applied_arena_mutation_keys.clear()
		_arena_hazard_contact_cooldowns.clear()
		return
	for child: Node in _arena_mutations_container.get_children():
		if boss_id != &"" and String(child.get_meta(&"boss_id", &"")) != String(boss_id):
			continue
		_arena_mutations_container.remove_child(child)
		child.free()
	if boss_id == &"":
		_applied_arena_mutation_keys.clear()
		_arena_hazard_contact_cooldowns.clear()
	else:
		_clear_arena_mutation_keys_for_boss(boss_id)
		_clear_arena_hazard_cooldowns_for_boss(boss_id)


func advance_arena_hazard_time(delta_sec: float) -> void:
	_arena_hazard_elapsed_sec += maxf(0.0, delta_sec)
	_process_arena_damage_zone_overlaps()


func apply_arena_damage_zone_contact(damage_zone: Area2D, target: Node) -> bool:
	if damage_zone == null or target == null or not is_instance_valid(damage_zone):
		return false
	if target != _player:
		return false
	var change_id: StringName = StringName(String(damage_zone.get_meta(&"change_id", &"")))
	if change_id != &"electric_leak":
		return false
	var boss_id: StringName = StringName(String(damage_zone.get_meta(&"boss_id", &"")))
	var phase: int = int(damage_zone.get_meta(&"phase", 0))
	var target_id: int = PlayerController.PLAYER_ENTITY_ID
	var cooldown_key: String = _arena_hazard_cooldown_key(boss_id, change_id, target_id)
	var next_allowed_sec: float = float(_arena_hazard_contact_cooldowns.get(cooldown_key, -1.0))
	if next_allowed_sec > _arena_hazard_elapsed_sec:
		return false
	var hp_before: int = _player.get_current_hp()
	var damage_data: Dictionary = {
		"damage": ELECTRIC_LEAK_CONTACT_DAMAGE,
		"final_damage": ELECTRIC_LEAK_CONTACT_DAMAGE,
		"hit_position": damage_zone.global_position,
		"is_crit": false,
		"source": change_id,
		"damage_type": &"electric",
		"boss_id": boss_id,
		"phase": phase,
		"change_id": change_id,
		"target_id": target_id,
		"show_damage_number": _hud.are_damage_numbers_enabled(),
		"focus_mode_active": _is_player_focus_mode_active(),
	}
	_player.apply_damage(ELECTRIC_LEAK_CONTACT_DAMAGE, damage_data)
	if _player.get_current_hp() >= hp_before:
		return false
	_arena_hazard_contact_cooldowns[cooldown_key] = (
		_arena_hazard_elapsed_sec + ELECTRIC_LEAK_CONTACT_COOLDOWN_SEC
	)
	_combat_presentation.on_hit_event(damage_data)
	_dispatch_audio_event(&"on_damage_taken_event", [damage_data])
	return true


func lock_scene() -> void:
	_boss_scene_locked = true
	if _scene_manager != null and is_instance_valid(_scene_manager) \
			and _scene_manager.has_method("lock_scene"):
		_scene_manager.call("lock_scene")


func unlock_scene() -> void:
	_boss_scene_locked = false
	if _scene_manager != null and is_instance_valid(_scene_manager) \
			and _scene_manager.has_method("unlock_scene"):
		_scene_manager.call("unlock_scene")


func is_boss_scene_locked() -> bool:
	return _boss_scene_locked


func clear_arena_locks() -> void:
	_boss_scene_locked = false
	cleanup_arena_mutations()
	_restore_boss2_camera_default_state(_get_boss2_camera())
	_boss2_camera_lock_enabled = false
	_boss2_camera_lock_reason = &"arena_locks_cleared"
	var left_room_seal := _get_boss2_room_seal(BOSS2_LEFT_ROOM_SEAL_PATH)
	var right_room_seal := _get_boss2_room_seal(BOSS2_RIGHT_ROOM_SEAL_PATH)
	_set_boss2_room_seal_enabled(left_room_seal, false)
	_set_boss2_room_seal_enabled(right_room_seal, false)
	_boss2_room_seals_enabled = false
	_boss2_room_seal_reason = &"arena_locks_cleared"
	if _scene_manager != null and is_instance_valid(_scene_manager) \
			and _scene_manager.has_method("unlock_scene"):
		_scene_manager.call("unlock_scene")


func clear_combat_adapters() -> void:
	pass


func capture_no_loss_state() -> Dictionary:
	return {
		"currency": _currency_amount,
		"skill_points": _skill_points,
		"unlocked_skills": _string_names_to_strings(_get_unlocked_skills()),
		"unlocked_abilities": _string_names_to_strings(_unlocked_abilities),
		"inventory": _string_names_to_strings(_inventory_items),
		"weapons": {
			"current_weapon": String(_current_weapon_id),
			"acquired": _string_names_to_strings(_acquired_weapons),
			"levels": _weapon_levels.duplicate(true),
		},
		"settings": _hud.capture_settings_state(),
		"world_flags": _world_progress_flags.duplicate(true),
		"last_savepoint": _last_discovered_savepoint.duplicate(true),
	}


func get_local_state() -> Dictionary:
	return capture_no_loss_state()


func restore_no_loss_state(snapshot: Dictionary) -> void:
	_currency_amount = maxi(0, _read_int(snapshot.get("currency", _currency_amount), _currency_amount))
	_skill_points = maxi(0, _read_int(snapshot.get("skill_points", _skill_points), _skill_points))
	_set_unlocked_skills_from_array(snapshot.get("unlocked_skills", _get_unlocked_skills()))
	_unlocked_abilities = _read_string_name_array(
		snapshot.get("unlocked_abilities", _unlocked_abilities)
	)
	_sync_player_unlocked_abilities()
	_sync_exploration_gates()
	_inventory_items = _read_string_name_array(snapshot.get("inventory", _inventory_items))
	var weapon_state: Dictionary = Dictionary(snapshot.get("weapons", {}))
	_current_weapon_id = StringName(String(weapon_state.get("current_weapon", String(_current_weapon_id))))
	_acquired_weapons = _read_string_name_array(weapon_state.get("acquired", _acquired_weapons))
	_weapon_levels = Dictionary(weapon_state.get("levels", _weapon_levels)).duplicate(true)
	_world_progress_flags = Dictionary(snapshot.get("world_flags", _world_progress_flags)).duplicate(true)
	_restore_last_savepoint_from_dictionary(Dictionary(snapshot.get("last_savepoint", {})))
	_sync_weapon_component_from_runtime_state()
	_hud.update_currency(_currency_amount)
	_refresh_skill_tree_hud_if_visible()
	_update_weapon_hud()
	if snapshot.has("settings"):
		_hud.restore_settings_state(Dictionary(snapshot.get("settings", {})))
	_sync_combat_presentation_accessibility_settings()
	_sync_hidden_double_jump_reward_source()
	_sync_boss2_double_jump_payoff_state()
	refresh_boss2_camera_lock()
	refresh_boss2_room_seals()
	_sync_factory_route_transition_shell()


func set_local_state(snapshot: Dictionary) -> void:
	restore_no_loss_state(snapshot)


func grant_currency(amount: int) -> void:
	var safe_amount: int = maxi(0, amount)
	if safe_amount <= 0:
		return
	_currency_amount = maxi(0, _currency_amount + safe_amount)
	_record_boss_reward_currency(safe_amount)
	_hud.update_currency(_currency_amount)
	_refresh_victory_reward_feedback_if_needed()


func grant_skill_points(amount: int) -> void:
	var safe_amount: int = maxi(0, amount)
	if safe_amount <= 0:
		return
	_skill_points += safe_amount
	_record_boss_reward_skill_points(safe_amount)
	_refresh_skill_tree_hud_if_visible()
	_refresh_victory_reward_feedback_if_needed()


func unlock_ability(ability_id: StringName) -> void:
	if ability_id == &"":
		return
	if not _unlocked_abilities.has(ability_id):
		_unlocked_abilities.append(ability_id)
		_record_boss_reward_ability(ability_id)
	_sync_player_unlocked_abilities()
	_sync_exploration_gates()
	_refresh_victory_reward_feedback_if_needed()


func has_unlocked_ability(ability_id: StringName) -> bool:
	return _unlocked_abilities.has(ability_id)


func claim_hidden_double_jump_reward_source(provider: Node = null) -> bool:
	var source: Node = _get_hidden_double_jump_reward_source()
	if source == null:
		return false
	_sync_hidden_double_jump_reward_source()
	if bool(_world_progress_flags.get(String(HIDDEN_DOUBLE_JUMP_REWARD_CLAIMED_FLAG), false)):
		return false
	var claim_provider: Node = _player if provider == null else provider
	if not bool(source.call("try_claim", claim_provider)):
		return false
	set_world_progress_flag(HIDDEN_DOUBLE_JUMP_REWARD_CLAIMED_FLAG, true)
	unlock_ability(HIDDEN_DOUBLE_JUMP_REWARD_ABILITY_ID)
	_hud.show_notification(HIDDEN_DOUBLE_JUMP_REWARD_NOTIFICATION, 2.5)
	_trigger_runtime_autosave(&"ability_reward_claimed", {
		"reward_id": String(HIDDEN_DOUBLE_JUMP_REWARD_ID),
		"ability_id": String(HIDDEN_DOUBLE_JUMP_REWARD_ABILITY_ID),
		"source": &"hidden_boss_echo",
	})
	return true


func claim_boss2_double_jump_reward_source(provider: Node = null) -> bool:
	var source: Node = _get_boss2_double_jump_reward_source()
	if source == null:
		return false
	_sync_boss2_double_jump_payoff_state()
	if bool(_world_progress_flags.get(String(BOSS2_DOUBLE_JUMP_REWARD_CLAIMED_FLAG), false)):
		return false
	var claim_provider: Node = _player if provider == null else provider
	if not bool(source.call("try_claim", claim_provider)):
		return false
	set_world_progress_flag(BOSS2_ECHO_GUARDIAN_DEFEATED_FLAG, true)
	set_world_progress_flag(BOSS2_DOUBLE_JUMP_REWARD_CLAIMED_FLAG, true)
	refresh_boss2_camera_lock()
	refresh_boss2_room_seals()
	unlock_ability(BOSS2_DOUBLE_JUMP_REWARD_ABILITY_ID)
	_dispatch_boss2_audio_event(&"reward_claimed", {
		"reward_id": BOSS2_DOUBLE_JUMP_REWARD_ID,
		"ability_id": BOSS2_DOUBLE_JUMP_REWARD_ABILITY_ID,
		"position": source.global_position,
	})
	_hud.show_notification(BOSS2_DOUBLE_JUMP_REWARD_NOTIFICATION, 2.5)
	_trigger_runtime_autosave(&"ability_reward_claimed", {
		"reward_id": String(BOSS2_DOUBLE_JUMP_REWARD_ID),
		"ability_id": String(BOSS2_DOUBLE_JUMP_REWARD_ABILITY_ID),
		"source": &"boss2_echo_guardian",
	})
	return true


func refresh_boss2_camera_lock() -> bool:
	var camera: Camera2D = _get_boss2_camera()
	if camera == null:
		_boss2_camera_lock_enabled = false
		_boss2_camera_lock_reason = &"camera_missing"
		return false
	if _boss2_camera_default_state.is_empty():
		_capture_boss2_camera_default_state()
	if _should_enable_boss2_camera_lock():
		_apply_boss2_camera_lock(camera)
		_boss2_camera_lock_enabled = true
		_boss2_camera_lock_reason = &"boss2_active"
		return true
	_restore_boss2_camera_default_state(camera)
	_boss2_camera_lock_enabled = false
	_boss2_camera_lock_reason = _boss2_camera_release_reason()
	return false


func get_boss2_camera_lock_diagnostics() -> Dictionary:
	var camera: Camera2D = _get_boss2_camera()
	var boss: Node = _get_boss2_echo_guardian()
	var focus_position: Vector2 = (
		(boss as Node2D).global_position
		if boss is Node2D
		else Vector2.ZERO
	)
	return {
		"camera_found": camera != null,
		"camera_path": String(BOSS2_CAMERA_PATH),
		"enabled": _boss2_camera_lock_enabled,
		"reason": String(_boss2_camera_lock_reason),
		"limit_left": camera.limit_left if camera != null else 0,
		"limit_top": camera.limit_top if camera != null else 0,
		"limit_right": camera.limit_right if camera != null else 0,
		"limit_bottom": camera.limit_bottom if camera != null else 0,
		"zoom": camera.zoom if camera != null else Vector2.ONE,
		"position_smoothing_enabled": (
			camera.position_smoothing_enabled if camera != null else false
		),
		"position_smoothing_speed": (
			camera.position_smoothing_speed if camera != null else 0.0
		),
		"offset": camera.offset if camera != null else Vector2.ZERO,
		"default_state": _boss2_camera_default_state.duplicate(true),
		"focus_position": focus_position,
		"boss_visible": boss.visible if boss != null else false,
		"arena_frame_visible": _is_boss2_arena_frame_visible(),
	}


func refresh_boss2_room_seals() -> bool:
	var should_enable: bool = _should_enable_boss2_room_seals()
	var left_room_seal := _get_boss2_room_seal(BOSS2_LEFT_ROOM_SEAL_PATH)
	var right_room_seal := _get_boss2_room_seal(BOSS2_RIGHT_ROOM_SEAL_PATH)
	_set_boss2_room_seal_enabled(left_room_seal, should_enable)
	_set_boss2_room_seal_enabled(right_room_seal, should_enable)
	_boss2_room_seals_enabled = should_enable
	_boss2_room_seal_reason = (
		&"boss2_active" if should_enable else _boss2_room_seal_release_reason()
	)
	return should_enable


func get_boss2_room_seal_diagnostics() -> Dictionary:
	return {
		"enabled": _boss2_room_seals_enabled,
		"reason": String(_boss2_room_seal_reason),
		"texture_path": BOSS2_ROOM_SEAL_TEXTURE_PATH,
		"left": _get_boss2_room_seal_snapshot(BOSS2_LEFT_ROOM_SEAL_PATH),
		"right": _get_boss2_room_seal_snapshot(BOSS2_RIGHT_ROOM_SEAL_PATH),
	}


func get_boss2_double_jump_payoff_diagnostics() -> Dictionary:
	var boss: Node = _get_boss2_echo_guardian()
	var source: Node = _get_boss2_double_jump_reward_source()
	var sprite: AnimatedSprite2D = (
		boss.get_node_or_null("Sprite") as AnimatedSprite2D
		if boss != null
		else null
	)
	return {
		"boss_present": boss != null,
		"boss_entity_id": (
			int(boss.call("get_entity_id"))
			if boss != null and boss.has_method("get_entity_id")
			else 0
		),
		"boss_defeated": _is_boss2_echo_guardian_defeated(),
		"boss_visible": boss.visible if boss != null else false,
		"sprite_frames_path": (
			sprite.sprite_frames.resource_path
			if sprite != null and sprite.sprite_frames != null
			else ""
		),
		"animation_frame_counts": _get_sprite_animation_frame_counts(sprite),
		"reward_present": source != null,
		"reward_id": (
			String(source.call("get_reward_id"))
			if source != null and source.has_method("get_reward_id")
			else ""
		),
		"reward_available": (
			bool(source.call("is_available"))
			if source != null and source.has_method("is_available")
			else false
		),
		"reward_claim_available": (
			bool(source.call("is_claim_available"))
			if source != null and source.has_method("is_claim_available")
			else false
		),
		"reward_claimed": (
			bool(source.call("is_claimed"))
			if source != null and source.has_method("is_claimed")
			else false
		),
		"reward_texture_path": (
			String(source.call("get_visual_texture_path"))
			if source != null and source.has_method("get_visual_texture_path")
			else ""
		),
		"reward_prompt_text": (
			String(source.call("get_prompt_text"))
			if source != null and source.has_method("get_prompt_text")
			else ""
		),
		"reward_prompt_visible": (
			bool(source.call("is_prompt_visible"))
			if source != null and source.has_method("is_prompt_visible")
			else false
		),
		"reward_visual_modulate": (
			source.call("get_visual_modulate")
			if source != null and source.has_method("get_visual_modulate")
			else Color.TRANSPARENT
		),
	}


func get_boss2_victory_route_handoff_diagnostics() -> Dictionary:
	var payoff: Dictionary = get_boss2_double_jump_payoff_diagnostics()
	var route_shell: Node = _get_factory_route_transition_shell()
	var gate: Node = get_node_or_null("DoubleJumpExplorationGate")
	var room_seals: Dictionary = get_boss2_room_seal_diagnostics()
	return {
		"boss_defeated": bool(payoff.get("boss_defeated", false)),
		"boss_visible": bool(payoff.get("boss_visible", false)),
		"reward_claim_available": bool(payoff.get("reward_claim_available", false)),
		"reward_claimed": bool(payoff.get("reward_claimed", false)),
		"reward_prompt_text": String(payoff.get("reward_prompt_text", "")),
		"reward_prompt_visible": bool(payoff.get("reward_prompt_visible", false)),
		"reward_visual_modulate": payoff.get("reward_visual_modulate", Color.TRANSPARENT),
		"room_seals_enabled": bool(room_seals.get("enabled", false)),
		"room_seal_reason": String(room_seals.get("reason", "")),
		"gate_state": (
			String(gate.call("get_gate_state"))
			if gate != null and gate.has_method("get_gate_state")
			else ""
		),
		"gate_required_ability": (
			String(gate.call("get_required_ability"))
			if gate != null and gate.has_method("get_required_ability")
			else ""
		),
		"gate_target_area": (
			String(gate.call("get_target_area_id"))
			if gate != null and gate.has_method("get_target_area_id")
			else ""
		),
		"factory_route_available": (
			bool(route_shell.call("is_route_available"))
			if route_shell != null and route_shell.has_method("is_route_available")
			else false
		),
		"factory_route_transition_requested": (
			bool(route_shell.call("is_transition_requested"))
			if route_shell != null and route_shell.has_method("is_transition_requested")
			else false
		),
		"factory_route_prompt_text": (
			String(route_shell.call("get_prompt_text"))
			if route_shell != null and route_shell.has_method("get_prompt_text")
			else ""
		),
		"factory_route_target_scene": (
			String(route_shell.call("get_target_scene_id"))
			if route_shell != null and route_shell.has_method("get_target_scene_id")
			else ""
		),
		"factory_route_spawn_point": (
			String(route_shell.call("get_spawn_point"))
			if route_shell != null and route_shell.has_method("get_spawn_point")
			else ""
		),
		"hud_notification_text": (
			String(_hud.call("get_notification_text"))
			if _hud != null and _hud.has_method("get_notification_text")
			else ""
		),
	}


func request_factory_route_transition(provider: Node = null) -> bool:
	var route_shell: Node = _get_factory_route_transition_shell()
	if route_shell == null:
		return false
	_sync_factory_route_transition_shell()
	var request_provider: Node = _player if provider == null else provider
	if not bool(route_shell.call("can_request_transition", request_provider)):
		return false
	var target_scene_id: StringName = StringName(route_shell.call("get_target_scene_id"))
	var spawn_point: StringName = StringName(route_shell.call("get_spawn_point"))
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if not _is_valid_scene_manager(scene_manager):
		return false
	if scene_manager.has_method("is_loading") and bool(scene_manager.call("is_loading")):
		return false
	if scene_manager.has_method("has_scene") and not bool(scene_manager.call("has_scene", target_scene_id)):
		return false
	if not _ensure_factory_route_runtime_scene_root(scene_manager):
		return false
	if not _request_scene_manager_transition(target_scene_id, spawn_point):
		return false
	route_shell.call("set_transition_requested", true)
	return true


func get_skill_points() -> int:
	return _skill_points


## Opens the runtime skill tree menu through the HUD.
func show_skill_tree_menu() -> void:
	_hud.show_skill_tree_menu(_skill_points, _get_skill_tree_hud_entries())


## Attempts to spend SP on a skill node and updates runtime presentation.
func try_unlock_skill(skill_id: StringName) -> bool:
	if _skill_tree_manager == null or not _skill_tree_manager.has_skill_definition(skill_id):
		return false
	if _skill_tree_manager.has_skill(skill_id):
		_refresh_skill_tree_hud_if_visible()
		return false
	var cost: int = _skill_tree_manager.get_skill_cost(skill_id)
	if cost < 0 or _skill_points < cost:
		_hud.show_notification("Not enough SP", 1.5)
		_refresh_skill_tree_hud_if_visible()
		return false
	if not _skill_tree_manager.unlock_skill(skill_id):
		return false
	_skill_points = maxi(0, _skill_points - cost)
	_hud.show_notification("%s learned" % _skill_tree_manager.get_skill_display_name(skill_id), 2.0)
	_refresh_skill_tree_hud_if_visible()
	return true


## Returns whether a skill is currently unlocked.
func has_skill(skill_id: StringName) -> bool:
	return _skill_tree_manager != null and _skill_tree_manager.has_skill(skill_id)


## Returns current skill modifiers for diagnostics and tests.
func get_skill_tree_modifiers(action_id: StringName = &"") -> Array[Dictionary]:
	return _skill_tree_manager.get_modifiers(action_id) if _skill_tree_manager != null else []


func _get_unlocked_skills() -> Array[StringName]:
	return _skill_tree_manager.get_unlocked_skills() if _skill_tree_manager != null else []


func _set_unlocked_skills_from_array(skill_ids: Variant) -> void:
	if _skill_tree_manager == null:
		return
	var restored: Array = []
	if skill_ids is Array:
		restored = skill_ids as Array
	_skill_tree_manager.set_unlocked_skills(restored)
	_sync_skill_modifier_provider()


func _get_skill_tree_hud_entries() -> Array[Dictionary]:
	return _skill_tree_manager.get_hud_entries() if _skill_tree_manager != null else []


func _refresh_skill_tree_hud_if_visible() -> void:
	if _hud != null and _hud.has_method("get_menu_mode") and _hud.get_menu_mode() == &"skill_tree":
		show_skill_tree_menu()


func begin_boss_defeat_rewards(boss_id: StringName, _rewards: Dictionary = {}) -> void:
	if String(boss_id) != RAT_KING_BOSS_ID:
		return
	_begin_boss_reward_summary_if_needed()


func finish_boss_defeat_rewards(boss_id: StringName) -> void:
	if String(boss_id) != RAT_KING_BOSS_ID:
		return
	_boss_reward_collection_active = false


func add_inventory_item(item_id: StringName) -> void:
	if item_id == &"" or _inventory_items.has(item_id):
		return
	_inventory_items.append(item_id)


func acquire_weapon(weapon_id: StringName) -> void:
	if weapon_id == &"":
		return
	if not _acquired_weapons.has(weapon_id):
		_acquired_weapons.append(weapon_id)
	if not _weapon_levels.has(String(weapon_id)):
		_weapon_levels[String(weapon_id)] = 0


func set_current_weapon_id(weapon_id: StringName) -> void:
	if _acquired_weapons.has(weapon_id):
		_current_weapon_id = weapon_id
		_sync_weapon_component_from_runtime_state()
		_update_weapon_hud()


func set_world_progress_flag(flag_id: StringName, enabled: bool = true) -> void:
	if flag_id == &"":
		return
	_world_progress_flags[String(flag_id)] = enabled
	if flag_id == HIDDEN_DOUBLE_JUMP_REWARD_CLAIMED_FLAG:
		_sync_hidden_double_jump_reward_source()
	if flag_id == BOSS2_DOUBLE_JUMP_REWARD_CLAIMED_FLAG \
			or flag_id == BOSS2_ECHO_GUARDIAN_DEFEATED_FLAG:
		_sync_boss2_double_jump_payoff_state()
		refresh_boss2_camera_lock()
		refresh_boss2_room_seals()
	if flag_id == FACTORY_ROUTE_UNLOCKED_FLAG:
		_sync_factory_route_transition_shell()


func get_runtime_progress_state() -> Dictionary:
	return capture_no_loss_state()


func configure_scene_manager_runtime(scene_manager: Object) -> bool:
	_disconnect_scene_manager_signals()
	_scene_manager = scene_manager
	_game_flow.set_scene_transition_adapter(_scene_manager)
	_connect_scene_manager_signals(_scene_manager)
	var valid_scene_manager: bool = _is_valid_scene_manager(_scene_manager)
	if valid_scene_manager:
		_apply_current_scene_manager_spawn_point()
	return valid_scene_manager


func configure_audio_system_runtime(audio_system: Object) -> bool:
	_audio_system = audio_system
	if not _is_valid_audio_system(_audio_system):
		_boss_music_audio_system = null
		return false
	_dispatch_boss_encounter_started_if_supported()
	return true


func _request_scene_manager_transition(scene_id: StringName, spawn_point: StringName) -> bool:
	if scene_id == &"" or spawn_point == &"":
		return false
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if scene_manager == null:
		return true
	if scene_manager.has_method("get_current_scene") \
			and String(scene_manager.call("get_current_scene")) == String(scene_id):
		return true
	if _can_skip_pending_same_main_scene_transition(scene_manager, scene_id):
		return true
	if scene_manager.has_method("has_scene") and not bool(scene_manager.call("has_scene", scene_id)):
		return false
	if scene_manager.has_method("is_scene_locked") and bool(scene_manager.call("is_scene_locked")):
		return false
	if scene_manager.has_method("request_scene_change"):
		return bool(scene_manager.call("request_scene_change", scene_id, spawn_point))
	if not scene_manager.has_method("change_scene"):
		return false
	return bool(scene_manager.call("change_scene", scene_id, spawn_point))


func _can_skip_pending_same_main_scene_transition(scene_manager: Object, scene_id: StringName) -> bool:
	if scene_id != StringName(MAIN_SCENE_ID):
		return false
	if scene_manager == null or not is_instance_valid(scene_manager):
		return false
	if not scene_manager.has_method("is_loading") or not bool(scene_manager.call("is_loading")):
		return false
	if not scene_manager.has_method("get_pending_scene"):
		return false
	return String(scene_manager.call("get_pending_scene")) == MAIN_SCENE_ID


func _handoff_loaded_scene_to_scene_manager(snapshot: Dictionary) -> bool:
	var target: Dictionary = _resolve_scene_target_from_snapshot(snapshot)
	var scene_id: StringName = StringName(target.get("scene_id", ""))
	if _can_restore_loaded_snapshot_in_current_scene(scene_id):
		return true
	return _request_scene_manager_transition(
		scene_id,
		StringName(target.get("spawn_point", ""))
	)


func _can_restore_loaded_snapshot_in_current_scene(scene_id: StringName) -> bool:
	return scene_id == StringName(MAIN_SCENE_ID) and is_inside_tree()


func _resolve_scene_target_from_snapshot(snapshot: Dictionary) -> Dictionary:
	var player_state: Dictionary = Dictionary(snapshot.get("player_state", {}))
	var world_state: Dictionary = Dictionary(snapshot.get("world_state", {}))
	var last_savepoint: Dictionary = Dictionary(world_state.get("last_savepoint", {}))
	var scene_id: String = String(last_savepoint.get("scene_id", "")).strip_edges()
	var spawn_point: String = String(last_savepoint.get("spawn_point", "")).strip_edges()
	if scene_id.is_empty():
		scene_id = String(world_state.get("scene_id", "")).strip_edges()
	if scene_id.is_empty():
		scene_id = String(player_state.get("scene_id", "")).strip_edges()
	if scene_id.is_empty():
		scene_id = MAIN_SCENE_ID
	if spawn_point.is_empty():
		spawn_point = _get_default_spawn_for_scene(StringName(scene_id))
	return {
		"scene_id": scene_id,
		"spawn_point": spawn_point,
	}


func _get_default_spawn_for_scene(scene_id: StringName) -> String:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if scene_manager != null and scene_manager.has_method("get_scene_config"):
		var config: Variant = scene_manager.call("get_scene_config", scene_id)
		if config is Dictionary:
			var configured_spawn: String = String(Dictionary(config).get("default_spawn", "")).strip_edges()
			if not configured_spawn.is_empty():
				return configured_spawn
	return String(DEFAULT_NEW_GAME_SPAWN_POINT)


func _resolve_scene_manager_for_runtime() -> Object:
	if _is_valid_scene_manager(_scene_manager):
		return _scene_manager
	if is_inside_tree() and configure_scene_manager_runtime(get_node_or_null("/root/SceneManager")):
		return _scene_manager
	return null


func _is_valid_scene_manager(scene_manager: Object) -> bool:
	return (
		scene_manager != null
		and is_instance_valid(scene_manager)
		and (
			scene_manager.has_method("change_scene")
			or scene_manager.has_method("request_scene_change")
		)
	)


func _resolve_audio_system_for_runtime() -> Object:
	if _is_valid_audio_system(_audio_system):
		return _audio_system
	if is_inside_tree() and configure_audio_system_runtime(get_node_or_null("/root/AudioSystem")):
		return _audio_system
	return null


func _is_valid_audio_system(audio_system: Object) -> bool:
	return (
		audio_system != null
		and is_instance_valid(audio_system)
		and audio_system.has_method("on_scene_load_started")
	)


func _dispatch_audio_event(method_name: StringName, args: Array = []) -> bool:
	var audio_system: Object = _resolve_audio_system_for_runtime()
	if audio_system == null or not audio_system.has_method(String(method_name)):
		return false
	audio_system.callv(method_name, args)
	return true


func _dispatch_boss2_audio_event(event_id: StringName, metadata: Dictionary = {}) -> bool:
	var event_metadata: Dictionary = _build_boss2_audio_metadata(metadata)
	return _dispatch_audio_event(&"on_boss2_audio_event", [event_id, event_metadata])


func _build_boss2_audio_metadata(metadata: Dictionary = {}) -> Dictionary:
	var event_metadata: Dictionary = metadata.duplicate(true)
	event_metadata["boss_id"] = BOSS2_ECHO_GUARDIAN_BOSS_ID
	if not event_metadata.has("source"):
		event_metadata["source"] = &"boss2_echo_guardian"
	if not event_metadata.has("position") and _boss2_echo_guardian != null:
		event_metadata["position"] = _boss2_echo_guardian.global_position
	if event_metadata.has("position") and not event_metadata.has("world_position"):
		event_metadata["world_position"] = event_metadata.get("position")
	return event_metadata


func _connect_scene_manager_signals(scene_manager: Object) -> void:
	if scene_manager == null or not is_instance_valid(scene_manager):
		return
	_connected_scene_manager = scene_manager
	_connect_scene_manager_signal(
		scene_manager,
		"on_scene_load_started",
		Callable(self, "_on_scene_manager_load_started")
	)
	_connect_scene_manager_signal(
		scene_manager,
		"on_scene_changed",
		Callable(self, "_on_scene_manager_changed")
	)
	_connect_scene_manager_signal(
		scene_manager,
		"on_scene_load_failed",
		Callable(self, "_on_scene_manager_load_failed")
	)


func _connect_scene_manager_signal(scene_manager: Object, signal_name: String, callback: Callable) -> void:
	if scene_manager == null or not is_instance_valid(scene_manager):
		return
	if not scene_manager.has_signal(signal_name):
		return
	var scene_signal: Signal = scene_manager.get(signal_name)
	if not scene_signal.is_connected(callback):
		scene_signal.connect(callback)


func _disconnect_scene_manager_signals() -> void:
	if _connected_scene_manager == null or not is_instance_valid(_connected_scene_manager):
		_connected_scene_manager = null
		return
	_disconnect_scene_manager_signal(
		_connected_scene_manager,
		"on_scene_load_started",
		Callable(self, "_on_scene_manager_load_started")
	)
	_disconnect_scene_manager_signal(
		_connected_scene_manager,
		"on_scene_changed",
		Callable(self, "_on_scene_manager_changed")
	)
	_disconnect_scene_manager_signal(
		_connected_scene_manager,
		"on_scene_load_failed",
		Callable(self, "_on_scene_manager_load_failed")
	)
	_connected_scene_manager = null


func _disconnect_scene_manager_signal(scene_manager: Object, signal_name: String, callback: Callable) -> void:
	if scene_manager == null or not is_instance_valid(scene_manager):
		return
	if not scene_manager.has_signal(signal_name):
		return
	var scene_signal: Signal = scene_manager.get(signal_name)
	if scene_signal.is_connected(callback):
		scene_signal.disconnect(callback)


func _on_scene_manager_load_started(
	scene_id: StringName,
	spawn_point: StringName,
	metadata: Dictionary
) -> void:
	var display_name: String = String(metadata.get("display_name", "")).strip_edges()
	if display_name == "":
		display_name = _display_name_for_scene_id(scene_id)
	var audio_system: Object = _resolve_audio_system_for_runtime()
	if audio_system != null:
		_dispatch_audio_event(&"on_scene_load_started", [scene_id, spawn_point, metadata])
	_hud.show_scene_transition(
		scene_id,
		display_name,
		float(metadata.get("transition_duration_sec", 1.5))
	)


func _on_scene_manager_changed(old_scene: StringName, new_scene: StringName) -> void:
	var audio_system: Object = _resolve_audio_system_for_runtime()
	if audio_system != null:
		_dispatch_audio_event(&"on_scene_changed", [old_scene, new_scene])
	_apply_scene_manager_spawn_point(new_scene)
	_hud.hide_scene_transition()


func _on_scene_manager_load_failed(scene_id: StringName, reason: StringName) -> void:
	var audio_system: Object = _resolve_audio_system_for_runtime()
	if audio_system != null:
		_dispatch_audio_event(&"on_scene_load_failed", [scene_id, reason])
	_hud.hide_scene_transition()
	_hud.show_notification("Load failed", 2.0)


func discover_savepoint(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2
) -> bool:
	if savepoint_id == &"" or scene_id == &"" or spawn_point == &"":
		return false
	_last_discovered_savepoint = {
		"id": String(savepoint_id),
		"scene_id": String(scene_id),
		"spawn_point": String(spawn_point),
		"position": _vector2_to_dictionary(world_position),
	}
	return true


func activate_runtime_savepoint(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2,
	context: Dictionary = {}
) -> bool:
	if not discover_savepoint(savepoint_id, scene_id, spawn_point, world_position):
		return false
	var save_context: Dictionary = context.duplicate(true)
	save_context["savepoint_id"] = String(savepoint_id)
	save_context["scene_id"] = String(scene_id)
	save_context["spawn_point"] = String(spawn_point)
	save_context["position"] = _vector2_to_dictionary(world_position)
	var display_name: String = String(save_context.get("display_name", "")).strip_edges()
	if not display_name.is_empty():
		_hud.show_notification("%s%s" % [display_name, SAVEPOINT_NOTIFICATION_SUFFIX], 1.5)
	return _trigger_runtime_autosave(&"savepoint", save_context)


func get_last_discovered_savepoint() -> Dictionary:
	return _last_discovered_savepoint.duplicate(true)


func clear_last_discovered_savepoint() -> bool:
	_last_discovered_savepoint.clear()
	return true


func _apply_current_scene_manager_spawn_point() -> bool:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if scene_manager == null or not scene_manager.has_method("get_current_scene"):
		return false
	return _apply_scene_manager_spawn_point(StringName(scene_manager.call("get_current_scene")))


func _apply_scene_manager_spawn_point(scene_id: StringName) -> bool:
	if String(scene_id) != MAIN_SCENE_ID:
		return false
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if scene_manager == null or not scene_manager.has_method("get_current_spawn_point"):
		return false
	var spawn_point: StringName = StringName(scene_manager.call("get_current_spawn_point"))
	if spawn_point == &"" or spawn_point == DEFAULT_NEW_GAME_SPAWN_POINT:
		return false
	return _move_player_to_spawn_point(spawn_point)


func _move_player_to_spawn_point(spawn_point: StringName) -> bool:
	if _player == null or not is_instance_valid(_player):
		return false
	var spawn_node: Node2D = null
	if spawn_point == &"scrap_roost":
		spawn_node = get_node_or_null(SCRAP_ROOST_SAVEPOINT_NODE_PATH) as Node2D
	if spawn_node == null:
		return false
	_player.global_position = spawn_node.global_position
	return true


## Configures the SaveSystem handoff used by runtime save/load and autosave triggers.
func configure_save_system_runtime(save_system: Object) -> bool:
	_unregister_main_scene_from_save_system()
	_save_system = save_system
	if not _is_valid_save_system(_save_system):
		return false
	if not _ensure_save_trigger_adapter():
		return false
	if not _register_main_scene_with_save_system():
		return false
	_connect_save_system_signals(_save_system)
	_save_trigger_adapter.configure(_save_system, capture_save_snapshot)
	return true


func _register_main_scene_with_save_system() -> bool:
	if not _is_valid_save_system(_save_system):
		return false
	if not _save_system.has_method("register_serializable"):
		return true
	var registered: bool = bool(_save_system.call(
		"register_serializable",
		self,
		MAIN_SCENE_SAVE_KEY
	))
	if not registered:
		return false
	_registered_save_system = _save_system
	return true


func _temporarily_unregister_main_scene_from_save_system() -> bool:
	if _registered_save_system == null or not is_instance_valid(_registered_save_system):
		return false
	if _registered_save_system != _save_system:
		return false
	if not _save_system.has_method("unregister_serializable"):
		return false
	_save_system.call("unregister_serializable", MAIN_SCENE_SAVE_KEY)
	_registered_save_system = null
	return true


func _temporarily_unregister_scene_manager_from_save_system() -> bool:
	if not _is_valid_save_system(_save_system):
		return false
	if not _save_system.has_method("unregister_serializable"):
		return false
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if not _is_valid_scene_manager(scene_manager):
		return false
	return bool(_save_system.call("unregister_serializable", SCENE_MANAGER_SAVE_KEY))


func _register_scene_manager_with_save_system() -> bool:
	if not _is_valid_save_system(_save_system):
		return false
	if not _save_system.has_method("register_serializable"):
		return true
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if not _is_valid_scene_manager(scene_manager):
		return false
	return bool(_save_system.call("register_serializable", scene_manager, SCENE_MANAGER_SAVE_KEY))


## Captures JSON-safe player, world, and settings state for SaveSystem.
func capture_save_snapshot() -> Dictionary:
	return {
		"player_state": _capture_player_state(),
		"world_state": _capture_world_state(),
		"settings": _hud.capture_settings_state(),
	}


## Restores MainScene from a SaveSystem-compatible runtime snapshot.
func restore_save_snapshot(snapshot: Dictionary) -> void:
	var player_state: Dictionary = Dictionary(snapshot.get("player_state", {}))
	var world_state: Dictionary = Dictionary(snapshot.get("world_state", {}))
	var settings: Dictionary = Dictionary(snapshot.get("settings", {}))
	_restore_player_state(player_state)
	_restore_runtime_progress_state(player_state, world_state, settings)
	_restore_exploration_gate_save_state(world_state)
	_restore_arena_mutations_from_world_state(world_state)


## Writes a manual runtime save through SaveSystem slots 1-3.
func save_runtime_to_slot(slot: int) -> bool:
	if (
		not _is_valid_save_system(_save_system)
		and not configure_save_system_runtime(get_node_or_null("/root/SaveSystem"))
	):
		return false
	if not _save_system.has_method("manual_save"):
		return false
	var snapshot: Dictionary = capture_save_snapshot()
	var save_started: bool = bool(_save_system.call(
		"manual_save",
		slot,
		Dictionary(snapshot.get("player_state", {})),
		Dictionary(snapshot.get("world_state", {})),
		Dictionary(snapshot.get("settings", {}))
	))
	if (
		save_started
		and (
			not _save_system.has_method("is_save_write_pending")
			or not bool(_save_system.call("is_save_write_pending"))
		)
	):
		_dispatch_audio_event(&"on_ui_save", [{
			"slot": slot,
			"source": &"manual_save",
		}])
	return save_started


## Loads a runtime save and applies the loaded MainScene state.
func load_runtime_from_slot(slot: int) -> bool:
	if (
		not _is_valid_save_system(_save_system)
		and not configure_save_system_runtime(get_node_or_null("/root/SaveSystem"))
	):
		return false
	if not _save_system.has_method("load_game") or not _save_system.has_method("get_last_loaded_data"):
		return false
	var temporarily_unregistered_main_scene: bool = _temporarily_unregister_main_scene_from_save_system()
	var temporarily_unregistered_scene_manager: bool = _temporarily_unregister_scene_manager_from_save_system()
	if not bool(_save_system.call("load_game", slot)):
		if temporarily_unregistered_main_scene:
			_register_main_scene_with_save_system()
		if temporarily_unregistered_scene_manager:
			_register_scene_manager_with_save_system()
		return false
	var loaded: Dictionary = Dictionary(_save_system.call("get_last_loaded_data"))
	if temporarily_unregistered_main_scene and not _register_main_scene_with_save_system():
		return false
	if temporarily_unregistered_scene_manager and not _register_scene_manager_with_save_system():
		return false
	if not _handoff_loaded_scene_to_scene_manager(loaded):
		return false
	restore_save_snapshot(loaded)
	_dispatch_audio_event(&"on_ui_load", [{
		"slot": slot,
		"source": &"manual_load",
	}])
	return true


## Serializes MainScene as a registered SaveSystem payload.
func serialize() -> Dictionary:
	return capture_save_snapshot()


## Deserializes MainScene when SaveSystem loads registered systems.
func deserialize(data: Dictionary, _version: int = 1) -> void:
	restore_save_snapshot(data)


func set_battle_summary_enabled(enabled: bool) -> void:
	_hud.set_battle_summary_enabled(enabled)


func is_battle_summary_enabled() -> bool:
	return _hud.is_battle_summary_enabled()


func set_damage_numbers_enabled(enabled: bool) -> void:
	_hud.set_damage_numbers_enabled(enabled)


func are_damage_numbers_enabled() -> bool:
	return _hud.are_damage_numbers_enabled()


func set_colorblind_mode(mode: StringName) -> void:
	_hud.set_colorblind_mode(mode)
	_sync_combat_presentation_accessibility_settings()


func get_colorblind_mode() -> StringName:
	return _hud.get_colorblind_mode()


func request_weapon_swap() -> bool:
	if _weapon_component == null:
		return false
	return _weapon_component.request_swap()


func advance_weapon_swap_time(delta_sec: float) -> void:
	if _weapon_component == null:
		return
	_weapon_component.advance_time(delta_sec)


func get_weapon_hud_text() -> String:
	if _hud == null or not _hud.has_method("get_weapon_label_text"):
		return ""
	return _hud.get_weapon_label_text()


func get_last_player_hit_metadata() -> Dictionary:
	return _last_player_hit_metadata.duplicate(true)


func register_boss_phase_transition_source(source: Object) -> bool:
	_disconnect_boss_phase_transition_source()
	if source == null or not source.has_signal("on_boss_phase_transition_started"):
		return false
	var transition_signal: Signal = source.get("on_boss_phase_transition_started")
	if not transition_signal.is_connected(_handle_boss_phase_transition_started):
		transition_signal.connect(_handle_boss_phase_transition_started)
	_boss_phase_transition_source = source
	return true


func _register_enemy_boss_phase_source() -> bool:
	if not is_instance_valid(_enemy) or not _enemy.has_method("get_boss_config_component"):
		return false
	var boss_config: Object = _enemy.call("get_boss_config_component")
	return register_boss_phase_transition_source(boss_config)


func is_boss_phase_transition_source_connected() -> bool:
	if _boss_phase_transition_source == null or not is_instance_valid(_boss_phase_transition_source):
		return false
	if not _boss_phase_transition_source.has_signal("on_boss_phase_transition_started"):
		return false
	var transition_signal: Signal = _boss_phase_transition_source.get("on_boss_phase_transition_started")
	return transition_signal.is_connected(_handle_boss_phase_transition_started)


func _handle_boss_phase_transition_started(entity_id: int, phase: int, metadata: Dictionary) -> void:
	var enriched_metadata: Dictionary = metadata.duplicate(true)
	var is_boss2_phase: bool = entity_id == BOSS2_ECHO_GUARDIAN_ENTITY_ID
	if not enriched_metadata.has("boss_id"):
		if is_boss2_phase:
			enriched_metadata["boss_id"] = BOSS2_ECHO_GUARDIAN_BOSS_ID
		else:
			enriched_metadata["boss_id"] = StringName(RAT_KING_BOSS_ID)
	if not enriched_metadata.has("display_name"):
		if is_boss2_phase:
			enriched_metadata["display_name"] = BOSS2_ECHO_GUARDIAN_DISPLAY_NAME
		else:
			enriched_metadata["display_name"] = _get_enemy_display_name()
	if not enriched_metadata.has("world_position") and is_boss2_phase and is_instance_valid(_boss2_echo_guardian):
		enriched_metadata["world_position"] = _boss2_echo_guardian.global_position + Vector2(0, -56)
	if not enriched_metadata.has("world_position") and is_instance_valid(_enemy):
		enriched_metadata["world_position"] = _enemy.global_position + Vector2(0, -24)
	if is_boss2_phase and is_instance_valid(_hud) and _should_show_boss2_hud():
		_refresh_boss_hud()
	if is_instance_valid(_hud) and is_instance_valid(_enemy) and not _should_show_boss2_hud():
		_hud.update_boss_hp(
			_enemy.get_current_hp(),
			_enemy.get_max_hp(),
			phase,
			String(enriched_metadata.get("display_name", _get_enemy_display_name()))
		)
	_combat_presentation.on_boss_phase_transition_started(entity_id, phase, enriched_metadata)
	_dispatch_audio_event(&"on_boss_phase_transition_started", [entity_id, phase, enriched_metadata])


func _dispatch_boss_encounter_started_if_supported() -> bool:
	if _audio_system == null or not is_instance_valid(_audio_system):
		return false
	if _boss_music_audio_system == _audio_system:
		return true
	if not _audio_system.has_method("on_boss_encounter_started"):
		return false
	_boss_music_audio_system = _audio_system
	_audio_system.call(
		"on_boss_encounter_started",
		StringName(RAT_KING_BOSS_ID),
		_build_boss_audio_metadata(1)
	)
	return true


func _build_boss_audio_metadata(phase: int) -> Dictionary:
	var metadata: Dictionary = {
		"boss_id": RAT_KING_BOSS_ID,
		"display_name": _get_enemy_display_name(),
		"phase": maxi(1, phase),
	}
	if is_instance_valid(_enemy):
		metadata["world_position"] = _enemy.global_position + Vector2(0, -24)
	return metadata


func _on_hud_colorblind_mode_changed(mode: StringName) -> void:
	_combat_presentation.set_colorblind_mode(mode)


func _capture_player_state() -> Dictionary:
	var progress: Dictionary = capture_no_loss_state()
	var weapon_state: Dictionary = Dictionary(progress.get("weapons", {}))
	return {
		"scene_id": MAIN_SCENE_ID,
		"position": _vector2_to_dictionary(_player.global_position),
		"current_hp": _player.get_current_hp(),
		"max_hp": _player.get_max_hp(),
		"current_weapon": String(weapon_state.get("current_weapon", String(_current_weapon_id))),
		"acquired_weapons": Array(
			weapon_state.get("acquired", _string_names_to_strings(_acquired_weapons))
		).duplicate(true),
		"weapon_levels": Dictionary(weapon_state.get("levels", _weapon_levels)).duplicate(true),
		"currency": int(progress.get("currency", _currency_amount)),
		"skill_points": int(progress.get("skill_points", _skill_points)),
		"unlocked_skills": Array(progress.get("unlocked_skills", _string_names_to_strings(_get_unlocked_skills()))).duplicate(true),
		"unlocked_abilities": Array(
			progress.get("unlocked_abilities", _string_names_to_strings(_unlocked_abilities))
		).duplicate(true),
		"inventory": Array(progress.get("inventory", _string_names_to_strings(_inventory_items))).duplicate(true),
	}


func _capture_world_state() -> Dictionary:
	return {
		"scene_id": MAIN_SCENE_ID,
		"defeated_bosses": _get_defeated_bosses(),
		"arena_mutations": get_arena_mutation_save_state(),
		"exploration_gates": _capture_exploration_gate_save_state(),
		"world_flags": _world_progress_flags.duplicate(true),
		"last_savepoint": _last_discovered_savepoint.duplicate(true),
	}


func _restore_player_state(player_state: Dictionary) -> void:
	_player.global_position = _read_vector2_dictionary(
		player_state.get("position", _vector2_to_dictionary(_player.global_position)),
		_player.global_position
	)
	_player.velocity = Vector2.ZERO
	var max_hp: int = maxi(1, _read_int(player_state.get("max_hp", _player.get_max_hp()), _player.get_max_hp()))
	var current_hp: int = clampi(
		_read_int(player_state.get("current_hp", _player.get_current_hp()), _player.get_current_hp()),
		0,
		max_hp
	)
	var health: HealthComponent = _player.get_node_or_null("HealthComponent") as HealthComponent
	if health != null:
		health.deserialize({
			"version": 1,
			"entity_id": 1,
			"base_hp": max_hp,
			"skill_hp_flat": 0,
			"charm_hp_flat": 0,
			"current_hp": current_hp,
			"max_hp": max_hp,
			"shield": 0,
			"max_shield": 0,
			"state": "alive" if current_hp > 0 else "dead",
			"focus_mode_enabled": true,
			"focus_mode_active": false,
		}, 1)
	_hud.update_hp(_player.get_current_hp(), _player.get_max_hp())


func _restore_runtime_progress_state(player_state: Dictionary, world_state: Dictionary, settings: Dictionary) -> void:
	restore_no_loss_state({
		"currency": _read_int(player_state.get("currency", _currency_amount), _currency_amount),
		"skill_points": _read_int(player_state.get("skill_points", _skill_points), _skill_points),
		"unlocked_skills": Array(
			player_state.get("unlocked_skills", _string_names_to_strings(_get_unlocked_skills()))
		).duplicate(true),
		"unlocked_abilities": Array(
			player_state.get("unlocked_abilities", _string_names_to_strings(_unlocked_abilities))
		).duplicate(true),
		"inventory": Array(player_state.get("inventory", _string_names_to_strings(_inventory_items))).duplicate(true),
		"weapons": {
			"current_weapon": String(player_state.get("current_weapon", String(_current_weapon_id))),
			"acquired": Array(
				player_state.get("acquired_weapons", _string_names_to_strings(_acquired_weapons))
			).duplicate(true),
			"levels": Dictionary(player_state.get("weapon_levels", _weapon_levels)).duplicate(true),
		},
		"settings": settings.duplicate(true),
		"world_flags": Dictionary(world_state.get("world_flags", _world_progress_flags)).duplicate(true),
		"last_savepoint": Dictionary(world_state.get("last_savepoint", {})).duplicate(true),
	})
	var defeated_bosses: Variant = world_state.get("defeated_bosses", [])
	if defeated_bosses is Array:
		for boss_id: Variant in defeated_bosses:
			set_world_progress_flag(StringName("boss_%s_defeated" % String(boss_id)), true)


func _restore_arena_mutations_from_world_state(world_state: Dictionary) -> void:
	var defeated_bosses: Variant = world_state.get("defeated_bosses", [])
	if defeated_bosses is Array and Array(defeated_bosses).has(RAT_KING_BOSS_ID):
		cleanup_arena_mutations()
		return
	restore_arena_mutation_save_state(world_state.get("arena_mutations", []))


func _trigger_runtime_autosave(reason: StringName, context: Dictionary) -> bool:
	if _save_trigger_adapter == null:
		return false
	return _save_trigger_adapter.trigger_auto_save(reason, context)


func _setup_main_scene_savepoints() -> void:
	if not is_inside_tree():
		return
	for node: Node in get_tree().get_nodes_in_group("savepoint"):
		if node == null or not is_instance_valid(node) or not is_ancestor_of(node):
			continue
		if not node.has_signal("savepoint_activated"):
			continue
		var callback: Callable = Callable(self, "_on_runtime_savepoint_activated")
		if not node.is_connected("savepoint_activated", callback):
			node.connect("savepoint_activated", callback)


func _on_runtime_savepoint_activated(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2,
	context: Dictionary
) -> void:
	activate_runtime_savepoint(savepoint_id, scene_id, spawn_point, world_position, context)


func _sync_player_unlocked_abilities() -> void:
	if _player == null:
		return
	if _player.has_method("set_unlocked_abilities"):
		_player.set_unlocked_abilities(_unlocked_abilities)
	elif _player.has_method("unlock_ability"):
		for ability_id: StringName in _unlocked_abilities:
			_player.unlock_ability(ability_id)


func get_exploration_gate_nodes() -> Array:
	var gates: Array = []
	if not is_inside_tree():
		return gates
	for gate: Node in get_tree().get_nodes_in_group("exploration_gate"):
		if gate != null and is_instance_valid(gate) and is_ancestor_of(gate):
			gates.append(gate)
	return gates


func _sync_exploration_gates() -> void:
	for gate: Node in get_exploration_gate_nodes():
		_connect_exploration_gate_signal(gate)
		if gate.has_method("set_ability_provider"):
			gate.call("set_ability_provider", _player)
		elif gate.has_method("refresh_gate_state"):
			gate.call("refresh_gate_state")


func _get_hidden_double_jump_reward_source() -> Node:
	var source: Node = get_node_or_null(HIDDEN_DOUBLE_JUMP_REWARD_NODE_PATH)
	if source == null or not source.has_method("set_claimed") or not source.has_method("try_claim"):
		return null
	return source


func _sync_hidden_double_jump_reward_source() -> void:
	var source: Node = _get_hidden_double_jump_reward_source()
	if source == null:
		return
	source.call("set_claimed", bool(_world_progress_flags.get(
		String(HIDDEN_DOUBLE_JUMP_REWARD_CLAIMED_FLAG),
		false
	)))


func _process_hidden_double_jump_reward_source_contact() -> void:
	var source: Node = _get_hidden_double_jump_reward_source()
	if source == null or not bool(source.call("is_claim_available")):
		return
	if bool(source.call("is_provider_in_reward_range", _player)):
		claim_hidden_double_jump_reward_source(_player)


func _setup_boss2_double_jump_payoff() -> void:
	_boss2_echo_guardian = _get_boss2_echo_guardian()
	_boss2_reward_source = _get_boss2_double_jump_reward_source()
	if _boss2_echo_guardian != null and _boss2_echo_guardian.has_signal("boss_defeated"):
		var defeated_signal: Signal = _boss2_echo_guardian.get("boss_defeated")
		if not defeated_signal.is_connected(_on_boss2_echo_guardian_defeated):
			defeated_signal.connect(_on_boss2_echo_guardian_defeated)
	if _boss2_echo_guardian != null and _boss2_echo_guardian.has_signal("boss_health_changed"):
		var health_signal: Signal = _boss2_echo_guardian.get("boss_health_changed")
		if not health_signal.is_connected(_on_boss2_health_changed):
			health_signal.connect(_on_boss2_health_changed)
	_sync_boss2_double_jump_payoff_state()


func _setup_boss2_attack_core_chain() -> void:
	_boss2_echo_guardian = _get_boss2_echo_guardian()
	if _boss2_echo_guardian == null:
		return
	if _boss2_echo_guardian.has_method("set_damage_calculator_adapter"):
		_boss2_echo_guardian.call("set_damage_calculator_adapter", _damage_calculator_adapter)
	if _boss2_echo_guardian.has_method("set_attack_target"):
		_boss2_echo_guardian.call("set_attack_target", _player)
	if _boss2_echo_guardian.has_signal("enemy_attack_landed"):
		var attack_signal: Signal = _boss2_echo_guardian.get("enemy_attack_landed")
		if not attack_signal.is_connected(_on_boss2_attack_landed):
			attack_signal.connect(_on_boss2_attack_landed)
	if _boss2_echo_guardian.has_signal("boss2_audio_event_requested"):
		var audio_signal: Signal = _boss2_echo_guardian.get("boss2_audio_event_requested")
		if not audio_signal.is_connected(_on_boss2_audio_event_requested):
			audio_signal.connect(_on_boss2_audio_event_requested)
	if _boss2_echo_guardian.has_signal("on_boss_phase_transition_started"):
		var phase_signal: Signal = _boss2_echo_guardian.get("on_boss_phase_transition_started")
		if not phase_signal.is_connected(_handle_boss_phase_transition_started):
			phase_signal.connect(_handle_boss_phase_transition_started)


func _get_boss2_echo_guardian() -> Node:
	var boss: Node = get_node_or_null(BOSS2_ECHO_GUARDIAN_NODE_PATH)
	if boss == null or not boss.has_method("get_entity_id") or not boss.has_method("apply_damage"):
		return null
	return boss


func _get_boss2_camera() -> Camera2D:
	return get_node_or_null(BOSS2_CAMERA_PATH) as Camera2D


func _capture_boss2_camera_default_state() -> void:
	var camera: Camera2D = _get_boss2_camera()
	if camera == null:
		_boss2_camera_default_state.clear()
		return
	_boss2_camera_default_state = {
		"limit_left": camera.limit_left,
		"limit_top": camera.limit_top,
		"limit_right": camera.limit_right,
		"limit_bottom": camera.limit_bottom,
		"zoom": camera.zoom,
		"position_smoothing_enabled": camera.position_smoothing_enabled,
		"position_smoothing_speed": camera.position_smoothing_speed,
	}


func _apply_boss2_camera_lock(camera: Camera2D) -> void:
	camera.limit_left = BOSS2_CAMERA_LOCK_LIMIT_LEFT
	camera.limit_top = BOSS2_CAMERA_LOCK_LIMIT_TOP
	camera.limit_right = BOSS2_CAMERA_LOCK_LIMIT_RIGHT
	camera.limit_bottom = BOSS2_CAMERA_LOCK_LIMIT_BOTTOM
	camera.zoom = BOSS2_CAMERA_LOCK_ZOOM
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = BOSS2_CAMERA_LOCK_SMOOTHING_SPEED
	if not camera.is_current():
		camera.make_current()


func _restore_boss2_camera_default_state(camera: Camera2D) -> void:
	if camera == null or _boss2_camera_default_state.is_empty():
		return
	camera.limit_left = int(_boss2_camera_default_state.get("limit_left", 0))
	camera.limit_top = int(_boss2_camera_default_state.get("limit_top", 0))
	camera.limit_right = int(_boss2_camera_default_state.get("limit_right", 1280))
	camera.limit_bottom = int(_boss2_camera_default_state.get("limit_bottom", 720))
	camera.zoom = _boss2_camera_default_state.get("zoom", Vector2.ONE)
	camera.position_smoothing_enabled = bool(_boss2_camera_default_state.get(
		"position_smoothing_enabled",
		true
	))
	camera.position_smoothing_speed = float(_boss2_camera_default_state.get(
		"position_smoothing_speed",
		8.0
	))


func _should_enable_boss2_camera_lock() -> bool:
	return _should_show_boss2_hud(_get_boss2_echo_guardian())


func _boss2_camera_release_reason() -> StringName:
	var boss: Node = _get_boss2_echo_guardian()
	if boss == null:
		return &"boss2_missing"
	if _is_boss2_echo_guardian_defeated():
		return &"boss2_defeated"
	if not boss.visible:
		return &"boss2_hidden"
	return &"boss2_inactive"


func _is_boss2_arena_frame_visible() -> bool:
	var frame := get_node_or_null("Boss2ArenaFrame") as CanvasItem
	return frame != null and frame.visible


func _get_boss2_room_seal(path: NodePath) -> StaticBody2D:
	return get_node_or_null(path) as StaticBody2D


func _set_boss2_room_seal_enabled(seal: StaticBody2D, enabled: bool) -> void:
	if seal == null:
		return
	seal.visible = enabled
	seal.collision_layer = 16 if enabled else 0
	seal.collision_mask = 0
	var collision_shape := seal.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape != null:
		collision_shape.disabled = not enabled
	var visual := seal.get_node_or_null("Visual") as CanvasItem
	if visual != null:
		visual.visible = enabled


func _should_enable_boss2_room_seals() -> bool:
	return _should_show_boss2_hud(_get_boss2_echo_guardian())


func _boss2_room_seal_release_reason() -> StringName:
	var boss: Node = _get_boss2_echo_guardian()
	if boss == null:
		return &"boss2_missing"
	if _is_boss2_echo_guardian_defeated():
		return &"boss2_defeated"
	if not boss.visible:
		return &"boss2_hidden"
	return &"boss2_inactive"


func _get_boss2_room_seal_snapshot(path: NodePath) -> Dictionary:
	var seal := _get_boss2_room_seal(path)
	if seal == null:
		return {
			"found": false,
			"path": String(path),
			"visible": false,
			"blocking": false,
			"collision_layer": 0,
			"position": Vector2.ZERO,
			"texture_path": "",
		}
	var collision_shape := seal.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var visual := seal.get_node_or_null("Visual") as Sprite2D
	var blocking := (
		seal.collision_layer == 16
		and collision_shape != null
		and not collision_shape.disabled
	)
	return {
		"found": true,
		"path": String(path),
		"visible": visual.visible if visual != null else seal.visible,
		"blocking": blocking,
		"collision_layer": seal.collision_layer,
		"position": seal.global_position,
		"texture_path": visual.texture.resource_path if visual != null and visual.texture != null else "",
	}


func _get_boss2_double_jump_reward_source() -> Node:
	var source: Node = get_node_or_null(BOSS2_DOUBLE_JUMP_REWARD_NODE_PATH)
	if source == null or not source.has_method("set_claimed") or not source.has_method("try_claim"):
		return null
	return source


func _refresh_boss_hud(enemy_current_hp: int = -1, enemy_max_hp: int = -1) -> void:
	if not is_instance_valid(_hud):
		return
	var boss2: Node = _get_boss2_echo_guardian()
	if _should_show_boss2_hud(boss2):
		_hud.update_boss_hp(
			int(boss2.call("get_current_hp")),
			int(boss2.call("get_max_hp")),
			_get_boss2_phase(boss2),
			BOSS2_ECHO_GUARDIAN_DISPLAY_NAME
		)
		return
	if not is_instance_valid(_enemy):
		_hud.hide_boss_hp()
		return
	var current_hp: int = _enemy.get_current_hp() if enemy_current_hp < 0 else enemy_current_hp
	var max_hp: int = _enemy.get_max_hp() if enemy_max_hp < 0 else enemy_max_hp
	if current_hp <= 0:
		_hud.hide_boss_hp()
		return
	_hud.update_boss_hp(current_hp, max_hp, _get_enemy_phase(), _get_enemy_display_name())


func _should_show_boss2_hud(boss: Node = null) -> bool:
	if boss == null:
		boss = _get_boss2_echo_guardian()
	if boss == null:
		return false
	if not boss.visible:
		return false
	if not boss.has_method("is_defeated") or bool(boss.call("is_defeated")):
		return false
	if not boss.has_method("get_current_hp") or int(boss.call("get_current_hp")) <= 0:
		return false
	if bool(_world_progress_flags.get(String(BOSS2_DOUBLE_JUMP_REWARD_CLAIMED_FLAG), false)):
		return false
	if bool(_world_progress_flags.get(String(BOSS2_ECHO_GUARDIAN_DEFEATED_FLAG), false)):
		return false
	return true


func _get_boss2_phase(boss: Node = null) -> int:
	if boss == null:
		boss = _get_boss2_echo_guardian()
	if boss != null and boss.has_method("get_current_phase"):
		return maxi(1, int(boss.call("get_current_phase")))
	return 1


func _sync_boss2_double_jump_payoff_state() -> void:
	var reward_claimed: bool = bool(_world_progress_flags.get(
		String(BOSS2_DOUBLE_JUMP_REWARD_CLAIMED_FLAG),
		false
	))
	var boss_defeated: bool = _is_boss2_echo_guardian_defeated()
	var boss: Node = _get_boss2_echo_guardian()
	if boss != null and boss_defeated and not bool(boss.call("is_defeated")):
		if boss.has_method("mark_defeated_from_progress"):
			boss.call("mark_defeated_from_progress")
		boss.visible = false
		if boss is CollisionObject2D:
			var collision_object := boss as CollisionObject2D
			collision_object.collision_layer = 0
			collision_object.collision_mask = 0
	var source: Node = _get_boss2_double_jump_reward_source()
	if source == null:
		return
	if source.has_method("set_available"):
		source.call("set_available", boss_defeated and not reward_claimed)
	source.call("set_claimed", reward_claimed)
	_refresh_boss_hud()


func _process_boss2_double_jump_reward_source_contact() -> void:
	var source: Node = _get_boss2_double_jump_reward_source()
	if source == null or not bool(source.call("is_claim_available")):
		return
	if bool(source.call("is_provider_in_reward_range", _player)):
		claim_boss2_double_jump_reward_source(_player)


func _on_boss2_echo_guardian_defeated() -> void:
	set_world_progress_flag(BOSS2_ECHO_GUARDIAN_DEFEATED_FLAG, true)
	_combat_presentation.on_kill_event(
		2,
		_boss2_echo_guardian.global_position + Vector2(0, -40)
	)
	_sync_boss2_double_jump_payoff_state()
	refresh_boss2_camera_lock()
	refresh_boss2_room_seals()
	_hud.show_notification("Echo Guardian defeated - Claim Double Jump", 2.5)


func _on_boss2_audio_event_requested(event_id: StringName, metadata: Dictionary) -> void:
	_dispatch_boss2_audio_event(event_id, metadata)


func _is_boss2_echo_guardian_defeated() -> bool:
	if bool(_world_progress_flags.get(String(BOSS2_DOUBLE_JUMP_REWARD_CLAIMED_FLAG), false)):
		return true
	if bool(_world_progress_flags.get(String(BOSS2_ECHO_GUARDIAN_DEFEATED_FLAG), false)):
		return true
	var boss: Node = _get_boss2_echo_guardian()
	return boss != null and boss.has_method("is_defeated") and bool(boss.call("is_defeated"))


func _get_factory_route_transition_shell() -> Node:
	var route_shell: Node = get_node_or_null(FACTORY_ROUTE_SHELL_NODE_PATH)
	if (
		route_shell == null
		or not route_shell.has_method("set_route_available")
		or not route_shell.has_method("can_request_transition")
	):
		return null
	return route_shell


func _sync_factory_route_transition_shell() -> void:
	var route_shell: Node = _get_factory_route_transition_shell()
	if route_shell == null:
		return
	var available: bool = bool(_world_progress_flags.get(String(FACTORY_ROUTE_UNLOCKED_FLAG), false))
	var prompt_text: String = (
		FACTORY_ROUTE_RETURN_PROMPT
		if available and _has_factory_service_lift_returned_to_scrap_roost()
		else FACTORY_ROUTE_ENTRY_PROMPT
	)
	route_shell.set("available_prompt_text", prompt_text)
	route_shell.call("set_route_available", available)


func _process_factory_route_transition_shell_contact() -> void:
	var route_shell: Node = _get_factory_route_transition_shell()
	if route_shell == null or not bool(route_shell.call("is_route_available")):
		return
	if bool(route_shell.call("is_provider_in_transition_range", _player)):
		request_factory_route_transition(_player)


func _ensure_factory_route_runtime_scene_root(scene_manager: Object) -> bool:
	if scene_manager == null or not scene_manager.has_method("configure_runtime_scene_root"):
		return true
	if scene_manager.has_method("is_runtime_scene_swap_enabled") \
			and bool(scene_manager.call("is_runtime_scene_swap_enabled")):
		return true
	if not is_inside_tree():
		return false
	var runtime_root: Node = get_parent()
	if runtime_root == null:
		return false
	return bool(scene_manager.call("configure_runtime_scene_root", runtime_root, self))


func _has_factory_service_lift_returned_to_scrap_roost() -> bool:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if scene_manager == null or not scene_manager.has_method("get_scene_state"):
		return false
	var factory_state_variant: Variant = scene_manager.call("get_scene_state", FACTORY_ROUTE_SCENE_ID)
	if not factory_state_variant is Dictionary:
		return false
	var factory_state: Dictionary = factory_state_variant as Dictionary
	return (
		bool(factory_state.get("factory_service_lift_exit_requested", false))
		and String(factory_state.get("factory_service_lift_exit_scene_id", "")) == MAIN_SCENE_ID
		and String(factory_state.get("factory_service_lift_exit_spawn_point", "")) == "scrap_roost"
	)


func _connect_exploration_gate_signal(gate: Node) -> void:
	if gate == null or not is_instance_valid(gate) or not gate.has_signal("gate_state_changed"):
		return
	var state_changed: Signal = gate.get("gate_state_changed")
	var callback := Callable(self, "_on_exploration_gate_state_changed").bind(gate)
	if not state_changed.is_connected(callback):
		state_changed.connect(callback)


func _on_exploration_gate_state_changed(
	gate_id: StringName,
	state: StringName,
	gate: Node
) -> void:
	if state != &"unlocked":
		return
	set_world_progress_flag(StringName("gate_%s_unlocked" % String(gate_id)), true)
	var target_area: StringName = _exploration_gate_target_area_id(gate)
	if target_area != &"":
		var area_flag: String = String(target_area)
		if not area_flag.begins_with("area_"):
			area_flag = "area_%s" % area_flag
		set_world_progress_flag(StringName("%s_unlocked" % area_flag), true)
	var required_ability: StringName = _exploration_gate_required_ability_id(gate)
	var world_position: Vector2 = (gate as Node2D).global_position if gate is Node2D else Vector2.ZERO
	_dispatch_audio_event(&"on_exploration_gate_unlocked", [
		gate_id,
		required_ability,
		target_area,
		world_position,
		{
			"gate_id": gate_id,
			"required_ability": required_ability,
			"target_area_id": target_area,
			"world_position": world_position,
		},
	])


func _capture_exploration_gate_save_state() -> Dictionary:
	var unlocked_gate_ids: Array[String] = []
	for gate: Node in get_exploration_gate_nodes():
		if not gate.has_method("is_unlocked") or not bool(gate.call("is_unlocked")):
			continue
		var gate_id: String = _exploration_gate_id(gate)
		if not gate_id.is_empty() and not unlocked_gate_ids.has(gate_id):
			unlocked_gate_ids.append(gate_id)
	unlocked_gate_ids.sort()
	return {
		"unlocked": unlocked_gate_ids,
	}


func _restore_exploration_gate_save_state(world_state: Dictionary) -> void:
	_sync_exploration_gates()
	if not world_state.has("exploration_gates"):
		return
	var gate_state: Dictionary = Dictionary(world_state.get("exploration_gates", {}))
	var unlocked_gate_ids: Array = Array(gate_state.get("unlocked", []))
	for gate: Node in get_exploration_gate_nodes():
		if not gate.has_method("set_gate_unlocked"):
			continue
		gate.call("set_gate_unlocked", unlocked_gate_ids.has(_exploration_gate_id(gate)))


func _exploration_gate_id(gate: Node) -> String:
	if gate != null and gate.has_method("get_gate_id"):
		return String(gate.call("get_gate_id"))
	return String(gate.name) if gate != null else ""


func _exploration_gate_target_area_id(gate: Node) -> StringName:
	if gate != null and gate.has_method("get_target_area_id"):
		return StringName(String(gate.call("get_target_area_id")))
	return &""


func _exploration_gate_required_ability_id(gate: Node) -> StringName:
	if gate != null and gate.has_method("get_required_ability"):
		return StringName(String(gate.call("get_required_ability")))
	return &""


func _record_boss_reward_ability(ability_id: StringName) -> void:
	if not _boss_reward_collection_active:
		return
	var abilities: Array[String] = []
	for ability_value: Variant in Array(_last_boss_reward_summary.get("abilities", [])):
		var existing_ability_id: String = String(ability_value)
		if not abilities.has(existing_ability_id):
			abilities.append(existing_ability_id)
	var ability_text: String = String(ability_id)
	if not abilities.has(ability_text):
		abilities.append(ability_text)
	_last_boss_reward_summary["abilities"] = abilities


func _record_boss_reward_currency(amount: int) -> void:
	if not _boss_reward_collection_active:
		return
	_last_boss_reward_summary["currency"] = (
		int(_last_boss_reward_summary.get("currency", 0)) + maxi(0, amount)
	)


func _record_boss_reward_skill_points(amount: int) -> void:
	if not _boss_reward_collection_active:
		return
	_last_boss_reward_summary["skill_points"] = (
		int(_last_boss_reward_summary.get("skill_points", 0)) + maxi(0, amount)
	)


func _begin_boss_reward_summary_if_needed() -> void:
	if _boss_reward_collection_active:
		return
	_boss_reward_collection_active = true
	_last_boss_reward_summary.clear()


func _format_boss_reward_summary() -> String:
	var parts: Array[String] = []
	for ability_value: Variant in Array(_last_boss_reward_summary.get("abilities", [])):
		var ability_id: StringName = StringName(String(ability_value))
		if ability_id != &"":
			parts.append("%s unlocked" % _display_name_for_ability(ability_id))
	var currency: int = int(_last_boss_reward_summary.get("currency", 0))
	if currency > 0:
		parts.append("+%d Gears" % currency)
	var skill_points: int = int(_last_boss_reward_summary.get("skill_points", 0))
	if skill_points > 0:
		parts.append("+%d SP" % skill_points)
	return " ".join(parts)


func _show_victory_reward_feedback() -> void:
	var reward_text: String = _format_boss_reward_summary()
	if reward_text.is_empty():
		_hud.show_notification("Rat King defeated", 3.0)
		_hud.show_retry_menu("Rat King defeated", "Retry the encounter or stay with your prize.")
		_boss_reward_collection_active = false
		return
	_hud.show_notification(reward_text, 3.0)
	_hud.show_retry_menu(
		"Rat King defeated",
		"Rewards claimed: %s. Retry the encounter or stay with your prize." % reward_text
	)
	_boss_reward_collection_active = false


func _refresh_victory_reward_feedback_if_needed() -> void:
	if _game_flow.get_flow_state() != &"victory":
		return
	_show_victory_reward_feedback()


func _collect_save_slot_infos() -> Array[Dictionary]:
	var infos: Array[Dictionary] = []
	var save_system: Object = _resolve_save_system_for_menu()
	for slot: int in range(4):
		infos.append(_get_save_slot_info_dictionary(save_system, slot))
	return infos


func _try_load_first_available_slot() -> bool:
	for slot_info: Dictionary in _collect_save_slot_infos():
		if bool(slot_info.get("exists", false)):
			return load_runtime_from_slot(int(slot_info.get("slot", 0)))
	return false


func _resolve_save_system_for_menu() -> Object:
	if _is_valid_save_system(_save_system):
		return _save_system
	var root_save_system: Object = get_node_or_null("/root/SaveSystem")
	if configure_save_system_runtime(root_save_system):
		return _save_system
	return null


func _get_save_slot_info_dictionary(save_system: Object, slot: int) -> Dictionary:
	var info: Dictionary = _empty_save_slot_info(slot)
	if save_system == null or not is_instance_valid(save_system):
		return info
	if save_system.has_method("get_save_info"):
		var raw_info: Variant = save_system.call("get_save_info", slot)
		if raw_info is Dictionary:
			info = Dictionary(raw_info).duplicate(true)
		elif raw_info != null and raw_info.has_method("to_dictionary"):
			info = Dictionary(raw_info.call("to_dictionary")).duplicate(true)
	elif save_system.has_method("has_save"):
		info["exists"] = bool(save_system.call("has_save", slot))
	info["slot"] = slot
	info["is_auto"] = slot == 0
	if not info.has("summary"):
		info["summary"] = {}
	return info


func _empty_save_slot_info(slot: int) -> Dictionary:
	return {
		"slot": slot,
		"is_auto": slot == 0,
		"exists": false,
		"timestamp": "",
		"play_time_sec": 0.0,
		"save_point_name": "",
		"version": 0,
		"summary": {},
		"file_size_bytes": 0,
	}


func _ensure_save_trigger_adapter() -> bool:
	var existing: Node = get_node_or_null("SaveTriggerAdapter")
	if existing is SaveTriggerAdapter:
		_save_trigger_adapter = existing as SaveTriggerAdapter
		return true
	if _save_trigger_adapter != null and is_instance_valid(_save_trigger_adapter):
		return true
	_save_trigger_adapter = SAVE_TRIGGER_ADAPTER_SCRIPT.new() as SaveTriggerAdapter
	if _save_trigger_adapter == null:
		return false
	_save_trigger_adapter.name = "SaveTriggerAdapter"
	add_child(_save_trigger_adapter)
	return true


func _is_valid_save_system(save_system: Object) -> bool:
	return save_system != null and is_instance_valid(save_system) and save_system.has_method("manual_save")


func _connect_save_system_signals(save_system: Object) -> void:
	if save_system == null or not is_instance_valid(save_system):
		return
	if save_system.has_signal("on_save_written"):
		var written_callback := Callable(self, "_on_save_system_written")
		if not save_system.is_connected("on_save_written", written_callback):
			save_system.connect("on_save_written", written_callback)
	if save_system.has_signal("on_save_write_failed"):
		var failed_callback := Callable(self, "_on_save_system_write_failed")
		if not save_system.is_connected("on_save_write_failed", failed_callback):
			save_system.connect("on_save_write_failed", failed_callback)


func _disconnect_save_system_signals(save_system: Variant) -> void:
	if save_system == null or not is_instance_valid(save_system):
		return
	if save_system.has_signal("on_save_written"):
		var written_callback := Callable(self, "_on_save_system_written")
		if save_system.is_connected("on_save_written", written_callback):
			save_system.disconnect("on_save_written", written_callback)
	if save_system.has_signal("on_save_write_failed"):
		var failed_callback := Callable(self, "_on_save_system_write_failed")
		if save_system.is_connected("on_save_write_failed", failed_callback):
			save_system.disconnect("on_save_write_failed", failed_callback)


func _on_save_system_written(slot: int) -> void:
	if slot > 0 and slot == _pending_manual_save_slot:
		_pending_manual_save_slot = -1
		_dispatch_audio_event(&"on_ui_save", [{
			"slot": slot,
			"source": &"manual_save_completed",
		}])
		_hud.show_notification("Game saved", 1.5)
	_refresh_save_menu_if_visible()


func _on_save_system_write_failed(slot: int, _reason: String) -> void:
	if slot > 0 and slot == _pending_manual_save_slot:
		_pending_manual_save_slot = -1
		_dispatch_audio_event(&"on_ui_cancel", [{
			"slot": slot,
			"source": &"manual_save_failed",
			"reason": _reason,
		}])
		_hud.show_notification("Save failed", 2.0)
	_refresh_save_menu_if_visible()


func _refresh_save_menu_if_visible() -> void:
	var menu_mode: StringName = _hud.get_menu_mode()
	if menu_mode == &"save_load":
		_hud.show_save_load_menu(
			_collect_save_slot_infos(),
			false,
			"Saving requires a save point"
		)
	elif menu_mode == &"main_menu":
		_hud.show_main_menu(_collect_save_slot_infos())


func _is_manual_save_write_pending() -> bool:
	if _pending_manual_save_slot < 0:
		return false
	if not _is_valid_save_system(_save_system):
		return false
	if not _save_system.has_method("is_save_write_pending"):
		return false
	return bool(_save_system.call("is_save_write_pending"))


func _unregister_main_scene_from_save_system() -> void:
	_disconnect_save_system_signals(_save_system)
	_pending_manual_save_slot = -1
	_save_system = null
	if _registered_save_system == null or not is_instance_valid(_registered_save_system):
		_registered_save_system = null
		return
	if _registered_save_system.has_method("unregister_serializable"):
		_registered_save_system.call("unregister_serializable", MAIN_SCENE_SAVE_KEY)
	_registered_save_system = null


func _disconnect_boss_phase_transition_source() -> void:
	if _boss_phase_transition_source == null or not is_instance_valid(_boss_phase_transition_source):
		_boss_phase_transition_source = null
		return
	if _boss_phase_transition_source.has_signal("on_boss_phase_transition_started"):
		var transition_signal: Signal = _boss_phase_transition_source.get("on_boss_phase_transition_started")
		if transition_signal.is_connected(_handle_boss_phase_transition_started):
			transition_signal.disconnect(_handle_boss_phase_transition_started)
	_boss_phase_transition_source = null


func _get_defeated_bosses() -> Array[String]:
	var defeated: Array[String] = []
	if bool(_world_progress_flags.get("boss_rat_king_defeated", false)):
		defeated.append(RAT_KING_BOSS_ID)
	return defeated


func _get_enemy_display_name() -> String:
	if is_instance_valid(_enemy) and _enemy.has_method("get_display_name"):
		var display_name: String = String(_enemy.call("get_display_name")).strip_edges()
		if display_name != "":
			return display_name
	return RAT_KING_BOSS_DISPLAY_NAME


func _get_enemy_phase() -> int:
	if is_instance_valid(_enemy) and _enemy.has_method("get_current_phase"):
		return maxi(1, int(_enemy.call("get_current_phase")))
	return 1


func _vector2_to_dictionary(value: Vector2) -> Dictionary:
	return {
		"x": value.x,
		"y": value.y,
	}


func _read_vector2_dictionary(value: Variant, fallback: Vector2) -> Vector2:
	if not value is Dictionary:
		return fallback
	var data: Dictionary = Dictionary(value)
	return Vector2(
		float(data.get("x", fallback.x)),
		float(data.get("y", fallback.y))
	)


func _read_vector2(value: Variant, fallback: Vector2) -> Vector2:
	if value is Vector2:
		return value
	if value is Dictionary:
		return _read_vector2_dictionary(value, fallback)
	return fallback


func _read_color(value: Variant, fallback: Color) -> Color:
	if value is Color:
		return value
	if value is String:
		return Color(String(value))
	if value is Dictionary:
		var data: Dictionary = Dictionary(value)
		return Color(
			float(data.get("r", fallback.r)),
			float(data.get("g", fallback.g)),
			float(data.get("b", fallback.b)),
			float(data.get("a", fallback.a))
		)
	return fallback


func _restore_last_savepoint_from_dictionary(savepoint: Dictionary) -> void:
	if savepoint.is_empty():
		_last_discovered_savepoint.clear()
		return
	var savepoint_id: StringName = StringName(savepoint.get("id", ""))
	var scene_id: StringName = StringName(savepoint.get("scene_id", ""))
	var spawn_point: StringName = StringName(savepoint.get("spawn_point", ""))
	var savepoint_position: Vector2 = _read_vector2_dictionary(
		savepoint.get("position", {}),
		_player.global_position
	)
	if not discover_savepoint(savepoint_id, scene_id, spawn_point, savepoint_position):
		_last_discovered_savepoint.clear()


func _setup_skill_tree_manager() -> void:
	_skill_tree_manager = get_node_or_null("SkillTreeManager")
	if _skill_tree_manager == null:
		var skill_tree_node: Node = SKILL_TREE_MANAGER_SCRIPT.new() as Node
		skill_tree_node.name = "SkillTreeManager"
		add_child(skill_tree_node)
		_skill_tree_manager = skill_tree_node
	var root_data_manager: Node = get_node_or_null("/root/DataManager")
	if root_data_manager != null and _skill_tree_manager.has_method("set_data_manager"):
		_skill_tree_manager.call("set_data_manager", root_data_manager)
	_sync_skill_modifier_provider()


func _sync_skill_modifier_provider() -> void:
	if _player != null and _player.has_method("set_skill_modifier_provider"):
		_player.set_skill_modifier_provider(_skill_tree_manager)


func _setup_weapon_component() -> void:
	_weapon_component = WEAPON_COMPONENT_SCRIPT.new() as WeaponComponent
	_weapon_component.name = "WeaponComponent"
	add_child(_weapon_component)
	var root_data_manager: Node = get_node_or_null("/root/DataManager")
	if root_data_manager != null:
		_weapon_component.set_data_manager(root_data_manager)
	_weapon_component.on_weapon_changed.connect(_on_weapon_changed)
	_acquired_weapons = _weapon_component.get_weapon_ids()
	_sync_weapon_component_from_runtime_state()


func _setup_player_attack_core_chain() -> void:
	var root_data_manager: Node = get_node_or_null("/root/DataManager")
	_damage_calculator_adapter = RUNTIME_DAMAGE_CALCULATOR_ADAPTER_SCRIPT.new(root_data_manager)
	_sync_skill_modifier_provider()
	if _player.has_method("set_damage_calculator_adapter"):
		_player.set_damage_calculator_adapter(_damage_calculator_adapter)
	if _player.has_method("set_target_health_adapter"):
		_player.set_target_health_adapter(self)
	if _player.has_method("set_weapon_component"):
		_player.set_weapon_component(_weapon_component)
	if _weapon_component != null:
		if _player.has_method("get_combat_component"):
			_weapon_component.set_combat_adapter(_player.get_combat_component())
		if _player.has_method("get_collision_component"):
			_weapon_component.set_collision_adapter(_player.get_collision_component())


func _connect_player_parry_signal() -> void:
	if _player == null or not _player.has_method("get_combat_component"):
		return
	var combat: CombatComponent = _player.get_combat_component() as CombatComponent
	if combat == null:
		return
	if not combat.on_parry_resolved.is_connected(_on_player_parry_resolved):
		combat.on_parry_resolved.connect(_on_player_parry_resolved)


func _setup_enemy_attack_core_chain() -> void:
	if _enemy.has_method("set_damage_calculator_adapter"):
		_enemy.set_damage_calculator_adapter(_damage_calculator_adapter)
	if _enemy.has_method("set_attack_target"):
		_enemy.set_attack_target(_player)
	if _enemy.has_method("set_reward_adapter"):
		_enemy.set_reward_adapter(self)
	if _enemy.has_method("set_summon_adapter"):
		_enemy.set_summon_adapter(self)
	if _enemy.has_method("set_scene_adapter"):
		_enemy.set_scene_adapter(self)
	if not _enemy.enemy_attack_landed.is_connected(_on_enemy_attack_landed):
		_enemy.enemy_attack_landed.connect(_on_enemy_attack_landed)


func _ensure_summons_container() -> Node2D:
	if is_instance_valid(_summons_container):
		return _summons_container
	_summons_container = get_node_or_null("Summons") as Node2D
	if _summons_container == null:
		_summons_container = Node2D.new()
		_summons_container.name = "Summons"
		add_child(_summons_container)
	return _summons_container


func _ensure_arena_mutations_container() -> Node2D:
	if is_instance_valid(_arena_mutations_container):
		return _arena_mutations_container
	_arena_mutations_container = get_node_or_null("ArenaMutations") as Node2D
	if _arena_mutations_container == null:
		_arena_mutations_container = Node2D.new()
		_arena_mutations_container.name = "ArenaMutations"
		add_child(_arena_mutations_container)
	return _arena_mutations_container


func _create_arena_mutation_node(
	boss_id: StringName,
	phase: int,
	change_type: StringName,
	change_id: StringName
) -> Node2D:
	var layout: Dictionary = Dictionary(ARENA_MUTATION_LAYOUTS.get(String(change_id), {}))
	if layout.is_empty():
		return null
	var mutation: Node2D = _instantiate_arena_mutation_root(change_type)
	if mutation == null:
		return null
	var size: Vector2 = _read_vector2(layout.get("size", Vector2(96, 32)), Vector2(96, 32))
	mutation.name = "ArenaMutation_%s" % String(change_id)
	mutation.position = _read_vector2(layout.get("position", Vector2.ZERO), Vector2.ZERO)
	mutation.z_index = 30
	mutation.set_meta(&"boss_id", boss_id)
	mutation.set_meta(&"phase", phase)
	mutation.set_meta(&"change_type", change_type)
	mutation.set_meta(&"change_id", change_id)
	_add_arena_mutation_collision(mutation, size)
	_add_arena_mutation_visual(
		mutation,
		size,
		_read_color(layout.get("color", Color.WHITE), Color.WHITE)
	)
	_add_arena_mutation_sprite(mutation, layout.get("texture", null))
	_add_arena_mutation_vfx(
		mutation,
		change_id,
		layout.get("vfx_role", &""),
		layout.get("vfx", [])
	)
	if mutation is Area2D and change_type == &"damage_zone":
		_configure_arena_damage_zone(mutation as Area2D)
	return mutation


func _instantiate_arena_mutation_root(change_type: StringName) -> Node2D:
	match change_type:
		&"obstacle":
			var body := StaticBody2D.new()
			body.collision_layer = ARENA_OBSTACLE_LAYER
			body.collision_mask = 0
			return body
		&"damage_zone":
			var area := Area2D.new()
			area.collision_layer = ARENA_DAMAGE_ZONE_LAYER
			area.collision_mask = ARENA_DAMAGE_ZONE_MASK
			area.monitoring = true
			area.monitorable = false
			return area
		_:
			return null


func _add_arena_mutation_collision(parent: Node2D, size: Vector2) -> void:
	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	collision.shape = shape
	parent.add_child(collision)


func _add_arena_mutation_visual(_parent: Node2D, _size: Vector2, _color: Color) -> void:
	# Arena mutations are now represented by generated textures and VFX only.
	pass


func _add_arena_mutation_sprite(parent: Node2D, texture_value: Variant) -> void:
	if not texture_value is Texture2D:
		return
	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture = texture_value
	sprite.centered = true
	sprite.position = Vector2(0, -42)
	sprite.z_index = 1
	parent.add_child(sprite)


func _add_arena_mutation_vfx(
	parent: Node2D,
	change_id: StringName,
	container_role_value: Variant,
	vfx_specs_value: Variant
) -> void:
	if not vfx_specs_value is Array:
		return
	var vfx_specs: Array = vfx_specs_value
	if vfx_specs.is_empty():
		return
	var container := Node2D.new()
	container.name = "Vfx"
	container.z_index = 10
	container.set_meta(&"change_id", change_id)
	container.set_meta(&"asset_source", &"image_generation")
	container.set_meta(&"vfx_role", StringName(String(container_role_value)))
	for raw_spec: Variant in vfx_specs:
		if not raw_spec is Dictionary:
			continue
		var spec: Dictionary = Dictionary(raw_spec)
		var texture_value: Variant = spec.get("texture", null)
		if not texture_value is Texture2D:
			continue
		var sprite := Sprite2D.new()
		sprite.name = String(spec.get("name", "VfxSprite"))
		sprite.texture = texture_value
		sprite.centered = true
		sprite.position = _read_vector2(spec.get("position", Vector2.ZERO), Vector2.ZERO)
		sprite.scale = _read_vector2(spec.get("scale", Vector2.ONE), Vector2.ONE)
		sprite.z_index = int(spec.get("z_index", 2))
		sprite.modulate = _read_color(spec.get("modulate", Color.WHITE), Color.WHITE)
		sprite.set_meta(&"change_id", change_id)
		sprite.set_meta(&"asset_source", &"image_generation")
		sprite.set_meta(&"vfx_role", StringName(String(spec.get("role", ""))))
		container.add_child(sprite)
	if container.get_child_count() == 0:
		container.free()
		return
	parent.add_child(container)


func _configure_arena_damage_zone(damage_zone: Area2D) -> void:
	var area_entered_callback := Callable(
		self,
		"_on_arena_damage_zone_area_entered"
	).bind(damage_zone)
	if not damage_zone.area_entered.is_connected(area_entered_callback):
		damage_zone.area_entered.connect(area_entered_callback)
	var body_entered_callback := Callable(
		self,
		"_on_arena_damage_zone_body_entered"
	).bind(damage_zone)
	if not damage_zone.body_entered.is_connected(body_entered_callback):
		damage_zone.body_entered.connect(body_entered_callback)


func _process_arena_damage_zone_overlaps() -> void:
	for mutation: Node in get_arena_mutation_nodes():
		if not mutation is Area2D:
			continue
		var damage_zone := mutation as Area2D
		if StringName(String(damage_zone.get_meta(&"change_id", &""))) != &"electric_leak":
			continue
		for area: Area2D in damage_zone.get_overlapping_areas():
			var target: Node = _resolve_arena_hazard_target_from_area(area)
			if target != null:
				apply_arena_damage_zone_contact(damage_zone, target)
		for body: Node2D in damage_zone.get_overlapping_bodies():
			if body == _player:
				apply_arena_damage_zone_contact(damage_zone, _player)


func _on_arena_damage_zone_area_entered(area: Area2D, damage_zone: Area2D) -> void:
	var target: Node = _resolve_arena_hazard_target_from_area(area)
	if target != null:
		apply_arena_damage_zone_contact(damage_zone, target)


func _on_arena_damage_zone_body_entered(body: Node2D, damage_zone: Area2D) -> void:
	if body == _player:
		apply_arena_damage_zone_contact(damage_zone, _player)


func _resolve_arena_hazard_target_from_area(area: Area2D) -> Node:
	if area == null:
		return null
	var parent: Node = area.get_parent()
	if parent == _player:
		return _player
	if parent != null and parent.has_method("get_entity_id") \
			and int(parent.call("get_entity_id")) == PlayerController.PLAYER_ENTITY_ID:
		return _player
	return null


func _arena_mutation_key(
	boss_id: StringName,
	phase: int,
	change_type: StringName,
	change_id: StringName
) -> String:
	return "%s:%d:%s:%s" % [String(boss_id), phase, String(change_type), String(change_id)]


func _build_arena_mutation_save_entry(mutation: Node) -> Dictionary:
	if mutation == null or not is_instance_valid(mutation):
		return {}
	var boss_id: String = String(mutation.get_meta(&"boss_id", ""))
	var phase: int = int(mutation.get_meta(&"phase", 0))
	var change_type: String = String(mutation.get_meta(&"change_type", ""))
	var change_id: String = String(mutation.get_meta(&"change_id", ""))
	if boss_id.is_empty() or phase <= 0 or change_type.is_empty() or change_id.is_empty():
		return {}
	return {
		"boss_id": boss_id,
		"phase": phase,
		"id": change_id,
		"type": change_type,
	}


func _clear_arena_mutation_keys_for_boss(boss_id: StringName) -> void:
	var prefix: String = "%s:" % String(boss_id)
	for key: String in _applied_arena_mutation_keys.keys():
		if key.begins_with(prefix):
			_applied_arena_mutation_keys.erase(key)


func _arena_hazard_cooldown_key(
	boss_id: StringName,
	change_id: StringName,
	target_id: int
) -> String:
	return "%s:%s:%d" % [String(boss_id), String(change_id), target_id]


func _clear_arena_hazard_cooldowns_for_boss(boss_id: StringName) -> void:
	var prefix: String = "%s:" % String(boss_id)
	for key: String in _arena_hazard_contact_cooldowns.keys():
		if key.begins_with(prefix):
			_arena_hazard_contact_cooldowns.erase(key)


func _on_summon_defeated(minion: Node) -> void:
	_summoned_minions.erase(minion)
	_prune_summoned_minions()


func _prune_summoned_minions() -> void:
	var live_minions: Array[Node] = []
	for minion: Node in _summoned_minions:
		if is_instance_valid(minion) and not minion.is_queued_for_deletion():
			live_minions.append(minion)
	_summoned_minions = live_minions


func _is_live_summon_for_boss(minion: Node, boss_id: StringName) -> bool:
	if not _is_summon_owned_by_boss(minion, boss_id):
		return false
	if not minion.has_method("get_current_hp"):
		return false
	return int(minion.call("get_current_hp")) > 0


func _is_summon_owned_by_boss(minion: Node, boss_id: StringName) -> bool:
	if not is_instance_valid(minion) or minion.is_queued_for_deletion():
		return false
	if not minion.has_method("get_summon_owner_boss_id"):
		return false
	return String(minion.call("get_summon_owner_boss_id")) == String(boss_id)


func _find_live_summon_by_entity_id(target_id: int) -> Node:
	_prune_summoned_minions()
	for minion: Node in _summoned_minions:
		if not minion.has_method("get_entity_id") or not minion.has_method("get_current_hp"):
			continue
		if int(minion.call("get_entity_id")) == target_id and int(minion.call("get_current_hp")) > 0:
			return minion
	return null


func _resolve_player_hit_target(hit_data: Dictionary) -> Node:
	var target_id: int = _read_int(hit_data.get("target_id", -1), -1)
	if target_id == BOSS2_ECHO_GUARDIAN_ENTITY_ID:
		var boss2: Node = _get_boss2_echo_guardian()
		if (
			boss2 != null
			and boss2.has_method("get_current_hp")
			and int(boss2.call("get_current_hp")) > 0
		):
			return boss2
	var minion: Node = _find_live_summon_by_entity_id(target_id)
	if minion != null:
		return minion
	return _enemy


func _next_summon_position() -> Vector2:
	if not is_instance_valid(_enemy):
		return _player.global_position + Vector2(RAT_MINION_SPAWN_OFFSET_X, 0.0)
	var current_count: int = get_active_summon_count(StringName(RAT_KING_BOSS_ID))
	var side: float = -1.0 if current_count % 2 == 0 else 1.0
	return _enemy.global_position + Vector2(side * RAT_MINION_SPAWN_OFFSET_X, 0.0)


func _connect_player_focus_mode_signal() -> void:
	var health: Node = _player.get_node_or_null("HealthComponent")
	if health == null or not health.has_signal("on_focus_mode_changed"):
		return
	var focus_signal: Signal = health.get("on_focus_mode_changed")
	var audio_focus_callback := Callable(self, "_on_player_focus_mode_changed")
	if not focus_signal.is_connected(audio_focus_callback):
		focus_signal.connect(audio_focus_callback)


func _on_player_focus_mode_changed(entity_id: int, active: bool, metadata: Dictionary) -> void:
	_combat_presentation.on_focus_mode_changed(entity_id, active, metadata)
	_dispatch_audio_event(&"on_focus_mode_changed", [entity_id, active, metadata])


func _is_player_focus_mode_active() -> bool:
	var health: Node = _player.get_node_or_null("HealthComponent")
	if health == null or not health.has_method("is_focus_mode_active"):
		return false
	return bool(health.call("is_focus_mode_active"))


func _sync_combat_presentation_accessibility_settings() -> void:
	_combat_presentation.set_colorblind_mode(_hud.get_colorblind_mode())


func _on_weapon_changed(weapon: Resource) -> void:
	if weapon == null:
		return
	_current_weapon_id = weapon.weapon_id
	acquire_weapon(_current_weapon_id)
	_weapon_levels[String(_current_weapon_id)] = _weapon_component.get_weapon_level(_current_weapon_id)
	_update_weapon_hud_with_resource(weapon)


func _sync_weapon_component_from_runtime_state() -> void:
	if _weapon_component == null:
		return
	var weapon_ids: Array[StringName] = _weapon_component.get_weapon_ids()
	var current_index: int = weapon_ids.find(_current_weapon_id)
	if current_index < 0:
		current_index = 0
		_current_weapon_id = weapon_ids[current_index]
	_weapon_component.deserialize({
		"version": 1,
		"current_weapon_index": current_index,
		"weapon_levels": _weapon_levels.duplicate(true),
	})


func _update_weapon_hud() -> void:
	if _weapon_component != null:
		var current_weapon: Resource = _weapon_component.get_current_weapon()
		if current_weapon != null:
			_update_weapon_hud_with_resource(current_weapon)
			return
	_hud.update_weapon(_display_name_for_weapon(_current_weapon_id), 0.0)


func _update_weapon_hud_with_resource(weapon: Resource) -> void:
	var display_name: StringName = _display_name_for_weapon(weapon.weapon_id)
	if String(weapon.display_name).strip_edges() != "":
		display_name = StringName(weapon.display_name)
	_hud.update_weapon(display_name, 0.0)


func _apply_weapon_effects_to_player_hit(hit_data: Dictionary) -> Dictionary:
	if _weapon_component == null:
		return hit_data.duplicate(true)
	return _weapon_component.apply_confirmed_hit_effects(_resolve_player_hit_target(hit_data), hit_data)


func _string_names_to_strings(values: Array[StringName]) -> Array[String]:
	var result: Array[String] = []
	for value: StringName in values:
		result.append(String(value))
	return result


func _read_string_name_array(value: Variant) -> Array[StringName]:
	var result: Array[StringName] = []
	if not value is Array:
		return result
	for entry: Variant in value:
		var entry_id: StringName = StringName(String(entry))
		if entry_id != &"" and not result.has(entry_id):
			result.append(entry_id)
	return result


func _get_sprite_animation_frame_counts(sprite: AnimatedSprite2D) -> Dictionary:
	var counts: Dictionary = {}
	if sprite == null or sprite.sprite_frames == null:
		return counts
	for animation_name: StringName in sprite.sprite_frames.get_animation_names():
		counts[String(animation_name)] = sprite.sprite_frames.get_frame_count(animation_name)
	return counts


func _read_int(value: Variant, fallback: int) -> int:
	if value is int:
		return value
	if value is float:
		return int(value)
	return fallback


func _display_name_for_weapon(weapon_id: StringName) -> StringName:
	match weapon_id:
		&"long_tail":
			return &"Long Tail"
		&"fish_bone":
			return &"Fish Bone"
		&"electro_bell":
			return &"Electro Bell"
		_:
			return &"Cat Claw"


func _display_name_for_ability(ability_id: StringName) -> String:
	match ability_id:
		&"dash":
			return "Dash"
		_:
			return String(ability_id).capitalize()


func _display_name_for_scene_id(scene_id: StringName) -> String:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if scene_manager != null and scene_manager.has_method("get_scene_config"):
		var config_variant: Variant = scene_manager.call("get_scene_config", scene_id)
		if config_variant is Dictionary:
			var display_name: String = String(Dictionary(config_variant).get("display_name", "")).strip_edges()
			if display_name != "":
				return display_name
	match scene_id:
		&"hub":
			return "Clan Base"
		&"main":
			return "Scrap Alley"
		_:
			var words: PackedStringArray = String(scene_id).replace("_", " ").split(" ", false)
			for index: int in range(words.size()):
				words[index] = words[index].capitalize()
			return " ".join(words)
