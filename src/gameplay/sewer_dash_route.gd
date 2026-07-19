## First Sewer traversal room: prove Dash across a real exhaust gap.
extends Node2D

const SEWER_SCENE_ID: StringName = &"area_02_sewer"
const MAIN_SCENE_ID: StringName = &"main"
const MAIN_RETURN_SPAWN: StringName = &"sewer_return"
const DASH_ROUTE_CROSSED_FLAG: String = "sewer_dash_route_crossed"
const SEWER_UNLOCKED_FLAG: String = "area_02_sewer_unlocked"
const ENTRY_SPAWN_POSITION: Vector2 = Vector2(140.0, 417.0)
const RIGHT_RESPAWN_POSITION: Vector2 = Vector2(742.0, 431.0)
const LEFT_PLATFORM_EDGE_X: float = 588.0
const RIGHT_PLATFORM_EDGE_X: float = 680.0
const RIGHT_LANDING_PROOF_X: float = 696.0
const DASH_START_MIN_X: float = 520.0
const DASH_PROOF_FRAMES: int = 18
const FALL_RESET_Y: float = 690.0
const PRESSURE_CHAMBER_ACTIVATION_X: float = 1510.0
const PRESSURE_WARNING_FRAMES: int = 72
const PRESSURE_CHAMBER_RESPAWN_POSITION: Vector2 = Vector2(1420.0, 431.0)
const PRESSURE_AMBUSH_ENTITY_ID: int = 2201
const PRESSURE_AMBUSH_ID: StringName = &"sewer_pressure_ambush"
const PRESSURE_AMBUSH_SUMMON_ID: StringName = &"sewer_sluice_leech"
const PRESSURE_CACHE_ID: StringName = &"sewer_pressure_salvage"
const PRESSURE_AMBUSH_CLEARED_FLAG: String = "sewer_pressure_ambush_cleared"
const PRESSURE_CACHE_CLAIMED_FLAG: String = "sewer_pressure_cache_claimed"
const SEWER_PLAYER_LIGHT_DAMAGE: int = 12
const PRESSURE_REWARD_GEARS: int = 15
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_SPAWN_POINT: StringName = &"factory_gate_entry"
const FACTORY_UNLOCKED_FLAG: String = "area_03_factory_unlocked"
const SEWER_FACTORY_GATE_UNLOCKED_FLAG: String = (
	"sewer_factory_high_platform_unlocked"
)
const SEWER_FACTORY_ROUTE_REACHED_FLAG: String = "sewer_factory_route_reached"
const SEWER_FACTORY_GATE_ID: StringName = &"double_jump_high_platform"
const FACTORY_PLATFORM_TOP_Y: float = 350.0
const FACTORY_PLATFORM_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_route_platform/"
	+ "env_old_factory_route_entry_platform_320x96.png"
)
const FACTORY_GATE_TEXTURE_PATH: String = (
	"res://assets/environment/high_platform_gate/high_platform_gate_marker.png"
)
const FACTORY_ROUTE_TEXTURE_PATH: String = (
	"res://assets/environment/factory_route_transition/"
	+ "factory_route_transition_shell.png"
)
const PRESSURE_BACKGROUND_PATH: String = (
	"res://assets/environment/sewer_pressure_chamber/"
	+ "sewer_pressure_chamber_background_1280x720.png"
)
const SLUICE_LEECH_SCENE: PackedScene = preload(
	"res://src/gameplay/factory_sluice_leech.tscn"
)
const WEAPON_COMPONENT_SCRIPT: Script = preload(
	"res://src/core/weapon_component.gd"
)

@export var auto_configure_runtime_services: bool = true

@onready var _player: PlayerController = $Player
@onready var _camera: Camera2D = $Player/Camera2D
@onready var _hazard: Area2D = $SewerExhaustHazard
@onready var _hazard_shape: CollisionShape2D = $SewerExhaustHazard/CollisionShape2D
@onready var _hazard_animation: AnimatedSprite2D = (
	$SewerExhaustHazard/SteamAnimation as AnimatedSprite2D
)
@onready var _pressure_background: TextureRect = $PressureChamberBackground
@onready var _sluice_leech_spawn: Marker2D = $SluiceLeechSpawn
@onready var _pressure_hazard: Area2D = $PressureBackflowHazard
@onready var _pressure_hazard_shape: CollisionShape2D = (
	$PressureBackflowHazard/CollisionShape2D as CollisionShape2D
)
@onready var _pressure_animation: AnimatedSprite2D = (
	$PressureBackflowHazard/SteamAnimation as AnimatedSprite2D
)
@onready var _pressure_room_seal: StaticBody2D = $PressureRoomSeal
@onready var _pressure_room_seal_shape: CollisionShape2D = (
	$PressureRoomSeal/CollisionShape2D as CollisionShape2D
)
@onready var _pressure_cache: Node = $SewerPressureCache
@onready var _pressure_cache_prompt: Label = (
	$SewerPressureCache/PromptLabel as Label
)
@onready var _factory_high_platform_shape: CollisionShape2D = (
	$SewerFactoryHighPlatform/CollisionShape2D as CollisionShape2D
)
@onready var _factory_high_platform_visual: Sprite2D = (
	$SewerFactoryHighPlatform/Visual as Sprite2D
)
@onready var _factory_double_jump_gate: ExplorationGate = (
	$SewerFactoryDoubleJumpGate as ExplorationGate
)
@onready var _factory_route_shell: RouteTransitionShell = (
	$SewerFactoryRouteShell as RouteTransitionShell
)
@onready var _hud: HUDManager = $HUD
@onready var _combat_presentation: CombatPresentation = $CombatPresentation
@onready var _hitstop_input_bridge: HitstopInputBridge = $HitstopInputBridge

var _scene_manager: Object = null
var _dash_crossing_active: bool = false
var _dash_proof_frames_remaining: int = 0
var _dash_crossed: bool = false
var _successful_dash_crossings: int = 0
var _reset_pending: bool = false
var _reset_count: int = 0
var _last_reset_reason: StringName = &""
var _transition_requested: bool = false
var _transition_request_count: int = 0
var _last_transition_target_scene: StringName = &""
var _weapon_component: WeaponComponent = null
var _sluice_leech: Node2D = null
var _pressure_ambush_activated: bool = false
var _pressure_ambush_cleared: bool = false
var _pressure_cache_claimed: bool = false
var _pressure_warning_frames_remaining: int = 0
var _pressure_hazard_active: bool = false
var _leech_runtime_active: bool = false
var _room_seal_blocking: bool = true
var _currency_amount: int = 0
var _reward_claim_count: int = 0
var _last_reward: Dictionary = {}
var _last_player_hit_metadata: Dictionary = {}
var _last_enemy_hit_metadata: Dictionary = {}
var _kill_feedback_emitted: bool = false
var _kill_feedback_count: int = 0
var _factory_gate_unlocked: bool = false
var _factory_route_reached: bool = false


func _ready() -> void:
	process_physics_priority = 100
	_setup_weapon_component()
	_bind_player_combat_to_room()
	_spawn_sluice_leech()
	_setup_pressure_cache()
	_connect_runtime_signals()
	_combat_presentation.set_camera(_camera)
	_hitstop_input_bridge.configure(
		_combat_presentation,
		_player,
		get_node_or_null("/root/InputManager")
	)
	_hud.update_hp(_player.get_current_hp(), _player.get_max_hp())
	_hud.update_currency(_currency_amount)
	_sync_hazard_state()
	_sync_pressure_ambush_state()
	_sync_factory_junction_state()
	if auto_configure_runtime_services:
		configure_scene_manager_runtime(get_node_or_null("/root/SceneManager"))


func _exit_tree() -> void:
	_disconnect_scene_manager_signal()


func _physics_process(_delta: float) -> void:
	if _transition_requested or _reset_pending:
		return
	_auto_activate_pressure_ambush()
	_advance_pressure_warning()
	_process_pressure_cache_contact()
	_sync_pressure_cache_prompt_visibility()
	_process_factory_route_contact()
	if _player.global_position.y > FALL_RESET_Y:
		_queue_reset(&"fall")
		return
	if not _dash_crossing_active:
		return
	if (
		_player.global_position.x >= RIGHT_LANDING_PROOF_X
		and _player.global_position.y <= RIGHT_RESPAWN_POSITION.y + 54.0
	):
		_complete_dash_crossing()
		return
	_dash_proof_frames_remaining = maxi(_dash_proof_frames_remaining - 1, 0)
	if _dash_proof_frames_remaining <= 0:
		_queue_reset(&"dash_missed")


func configure_scene_manager_runtime(scene_manager: Object) -> bool:
	_disconnect_scene_manager_signal()
	if not _is_valid_scene_manager(scene_manager):
		_scene_manager = null
		return false
	_scene_manager = scene_manager
	_connect_scene_manager_signal()
	return true


func get_local_state() -> Dictionary:
	return {
		"unlocked_abilities": _get_player_unlocked_ability_strings(),
		"dash_crossed": _dash_crossed,
		"successful_dash_crossings": _successful_dash_crossings,
		"reset_count": _reset_count,
		"last_reset_reason": String(_last_reset_reason),
		"currency": _currency_amount,
		PRESSURE_AMBUSH_CLEARED_FLAG: _pressure_ambush_cleared,
		PRESSURE_CACHE_CLAIMED_FLAG: _pressure_cache_claimed,
		"sewer_pressure_reward_claim_count": _reward_claim_count,
		SEWER_FACTORY_GATE_UNLOCKED_FLAG: _factory_gate_unlocked,
		SEWER_FACTORY_ROUTE_REACHED_FLAG: _factory_route_reached,
	}


func set_local_state(state: Dictionary) -> void:
	_transition_requested = false
	_transition_request_count = 0
	_last_transition_target_scene = &""
	_dash_crossing_active = false
	_dash_proof_frames_remaining = 0
	_pressure_warning_frames_remaining = 0
	_pressure_hazard_active = false
	_last_reward.clear()
	_last_player_hit_metadata.clear()
	_last_enemy_hit_metadata.clear()
	_kill_feedback_count = 0
	_restore_player_unlocked_abilities(state)
	_dash_crossed = bool(state.get("dash_crossed", false))
	_successful_dash_crossings = maxi(
		0,
		int(state.get("successful_dash_crossings", 1 if _dash_crossed else 0))
	)
	_reset_count = maxi(0, int(state.get("reset_count", 0)))
	_last_reset_reason = StringName(String(state.get("last_reset_reason", "")))
	_currency_amount = maxi(0, int(state.get("currency", 0)))
	_pressure_cache_claimed = bool(state.get(
		PRESSURE_CACHE_CLAIMED_FLAG,
		false
	))
	_pressure_ambush_cleared = bool(state.get(
		PRESSURE_AMBUSH_CLEARED_FLAG,
		_pressure_cache_claimed
	)) or _pressure_cache_claimed
	_pressure_ambush_activated = _pressure_ambush_cleared
	_reward_claim_count = maxi(0, int(state.get(
		"sewer_pressure_reward_claim_count",
		1 if _pressure_cache_claimed else 0
	)))
	_kill_feedback_emitted = _pressure_ambush_cleared
	_factory_route_reached = bool(state.get(
		SEWER_FACTORY_ROUTE_REACHED_FLAG,
		false
	))
	_factory_gate_unlocked = bool(state.get(
		SEWER_FACTORY_GATE_UNLOCKED_FLAG,
		_factory_route_reached
	)) or _factory_route_reached
	_restore_pressure_ambush_enemy()
	_sync_hazard_state()
	_sync_pressure_ambush_state()
	_sync_factory_junction_state()
	_hud.update_currency(_currency_amount)
	if _dash_crossed:
		_player.respawn_at(RIGHT_RESPAWN_POSITION, 1.0)
	_player.set_control_locked(false)


func get_sewer_route_diagnostics() -> Dictionary:
	var dash_frames: int = 0
	var player_sprite: AnimatedSprite2D = _player.get_node_or_null("Sprite") as AnimatedSprite2D
	if (
		player_sprite != null
		and player_sprite.sprite_frames != null
		and player_sprite.sprite_frames.has_animation(&"dash")
	):
		dash_frames = player_sprite.sprite_frames.get_frame_count(&"dash")
	return {
		"scene_id": String(SEWER_SCENE_ID),
		"player_position": _player.global_position,
		"player_has_dash": _player.has_ability(&"dash"),
		"player_dash_frames": dash_frames,
		"dash_crossing_active": _dash_crossing_active,
		"dash_proof_frames_remaining": _dash_proof_frames_remaining,
		"dash_crossed": _dash_crossed,
		"successful_dash_crossings": _successful_dash_crossings,
		"reset_pending": _reset_pending,
		"reset_count": _reset_count,
		"last_reset_reason": String(_last_reset_reason),
		"transition_requested": _transition_requested,
		"transition_request_count": _transition_request_count,
		"hazard_animation": String(_hazard_animation.animation),
		"hazard_animation_playing": _hazard_animation.is_playing(),
		"hazard_active_frames": _animation_frame_count(&"active"),
		"left_platform_edge_x": LEFT_PLATFORM_EDGE_X,
		"right_platform_edge_x": RIGHT_PLATFORM_EDGE_X,
		"gap_width_px": RIGHT_PLATFORM_EDGE_X - LEFT_PLATFORM_EDGE_X,
		"background_path": (
			$Background.texture.resource_path
			if $Background.texture != null
			else ""
		),
		}


## Returns stable Story021 room, combat, reward, and gate evidence.
func get_sewer_act_depth_diagnostics() -> Dictionary:
	var enemy_present: bool = is_instance_valid(_sluice_leech)
	var enemy_visible: bool = enemy_present and _sluice_leech.visible
	var active_enemy_count: int = 1 if (
		enemy_visible
		and _sluice_leech.process_mode != Node.PROCESS_MODE_DISABLED
		and not _pressure_ambush_cleared
	) else 0
	var enemy_animation: String = ""
	var enemy_hp: int = 0
	var enemy_max_hp: int = 0
	if enemy_present:
		if _sluice_leech.has_method("get_current_hp"):
			enemy_hp = int(_sluice_leech.call("get_current_hp"))
		if _sluice_leech.has_method("get_max_hp"):
			enemy_max_hp = int(_sluice_leech.call("get_max_hp"))
		var sprite: AnimatedSprite2D = (
			_sluice_leech.get_node_or_null("Sprite") as AnimatedSprite2D
		)
		if sprite != null:
			enemy_animation = String(sprite.animation)
	return {
		"encounter_state": String(_get_pressure_ambush_state()),
		"encounter_activated": _pressure_ambush_activated,
		"encounter_cleared": _pressure_ambush_cleared,
		"activation_x": PRESSURE_CHAMBER_ACTIVATION_X,
		"active_enemy_count": active_enemy_count,
		"enemy_present": enemy_present,
		"enemy_visible": enemy_visible,
		"enemy_entity_id": PRESSURE_AMBUSH_ENTITY_ID,
		"enemy_current_hp": enemy_hp,
		"enemy_max_hp": enemy_max_hp,
		"enemy_animation": enemy_animation,
		"enemy_animation_frames": _get_sluice_leech_frame_counts(),
		"room_seal_blocking": _room_seal_blocking,
		"pressure_state": String(_get_pressure_hazard_state()),
		"pressure_warning_frames_remaining": _pressure_warning_frames_remaining,
		"pressure_hazard_active": _pressure_hazard_active,
		"pressure_animation": String(_pressure_animation.animation),
		"pressure_warning_frames": _pressure_animation_frame_count(&"warning"),
		"pressure_active_frames": _pressure_animation_frame_count(&"active"),
		"reward_available": _is_pressure_cache_available(),
		"reward_claimed": _pressure_cache_claimed,
		"reward_claim_count": _reward_claim_count,
		"reward_gears": PRESSURE_REWARD_GEARS,
		"currency": _currency_amount,
		"last_reward": _last_reward.duplicate(true),
		"kill_feedback_count": _kill_feedback_count,
		"last_player_hit_metadata": _last_player_hit_metadata.duplicate(true),
		"last_enemy_hit_metadata": _last_enemy_hit_metadata.duplicate(true),
		"player_has_double_jump": _player.has_ability(&"double_jump"),
		"background_texture_path": (
			_pressure_background.texture.resource_path
			if _pressure_background.texture != null
			else ""
		),
		"background_expected_path": PRESSURE_BACKGROUND_PATH,
		"cache_texture_path": _get_pressure_cache_texture_path(),
		"transition_requested": _transition_requested,
		"transition_request_count": _transition_request_count,
		"last_transition_target_scene": String(_last_transition_target_scene),
		"factory_transition_requested": (
			_last_transition_target_scene == &"area_03_factory"
		),
	}


## Returns stable Story022 physical gate, route, and persistence evidence.
func get_sewer_factory_junction_diagnostics() -> Dictionary:
	var gate_visual: Sprite2D = _factory_double_jump_gate.get_node_or_null(
		"Visual"
	) as Sprite2D
	return {
		"gate_id": String(SEWER_FACTORY_GATE_ID),
		"gate_state": String(_factory_double_jump_gate.get_gate_state()),
		"gate_unlocked": _factory_gate_unlocked,
		"gate_collision_blocking": (
			_factory_double_jump_gate.is_collision_blocking()
		),
		"gate_texture_path": (
			gate_visual.texture.resource_path
			if gate_visual != null and gate_visual.texture != null
			else ""
		),
		"platform_top_y": FACTORY_PLATFORM_TOP_Y,
		"platform_collision_enabled": (
			_factory_high_platform_shape != null
			and not _factory_high_platform_shape.disabled
		),
		"platform_texture_path": (
			_factory_high_platform_visual.texture.resource_path
			if _factory_high_platform_visual.texture != null
			else ""
		),
		"route_available": _factory_route_shell.is_route_available(),
		"route_reached": _factory_route_reached,
		"route_texture_path": _factory_route_shell.get_visual_texture_path(),
		"target_scene_id": String(FACTORY_SCENE_ID),
		"spawn_point": String(FACTORY_SPAWN_POINT),
		"transition_requested": _transition_requested,
		"transition_request_count": _transition_request_count,
		"last_transition_target_scene": String(_last_transition_target_scene),
		"currency": _currency_amount,
		"player_position": _player.global_position,
		"player_has_double_jump": _player.has_ability(&"double_jump"),
		"platform_expected_texture_path": FACTORY_PLATFORM_TEXTURE_PATH,
		"gate_expected_texture_path": FACTORY_GATE_TEXTURE_PATH,
		"route_expected_texture_path": FACTORY_ROUTE_TEXTURE_PATH,
	}


## Activates the one-enemy pressure ambush after the Dash landing.
func try_activate_pressure_ambush(provider: Node = null) -> bool:
	var activation_provider: Node = _player if provider == null else provider
	if (
		_pressure_ambush_activated
		or _pressure_ambush_cleared
		or not _dash_crossed
		or not activation_provider is Node2D
	):
		return false
	var provider_node: Node2D = activation_provider as Node2D
	if provider_node.global_position.x < PRESSURE_CHAMBER_ACTIVATION_X:
		return false
	_pressure_ambush_activated = true
	_pressure_warning_frames_remaining = PRESSURE_WARNING_FRAMES
	_pressure_hazard_active = false
	_sync_pressure_ambush_state()
	return true


## Attempts the once-only post-combat Sewer salvage claim.
func try_claim_pressure_cache(provider: Node = null) -> bool:
	if _pressure_cache == null or not _pressure_cache.has_method("try_claim"):
		return false
	var claim_provider: Node = _player if provider == null else provider
	if claim_provider == null:
		return false
	return bool(_pressure_cache.call("try_claim", claim_provider))


## Routes production player hit confirmations to the Sewer leech.
func apply_damage(
	target_id: int,
	final_damage: int,
	metadata: Dictionary = {}
) -> bool:
	if (
		target_id != PRESSURE_AMBUSH_ENTITY_ID
		or final_damage <= 0
		or not is_instance_valid(_sluice_leech)
		or _pressure_ambush_cleared
		or not _sluice_leech.has_method("apply_damage")
	):
		return false
	_sluice_leech.call("apply_damage", final_damage, metadata)
	return true


## Supplies deterministic room damage through the shared combat pipeline.
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
	var final_damage: int = SEWER_PLAYER_LIGHT_DAMAGE
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


func _connect_runtime_signals() -> void:
	_player.player_health_changed.connect(_on_player_health_changed)
	_player.player_died.connect(_on_player_died)
	_player.attack_landed.connect(_on_player_attack_landed)
	_player.dash_started.connect(_on_player_dash_started)
	_player.double_jump_started.connect(_on_player_double_jump_started)
	_factory_double_jump_gate.gate_state_changed.connect(
		_on_factory_gate_state_changed
	)
	$SewerExhaustHazard.body_entered.connect(_on_hazard_body_entered)
	$FallZone.body_entered.connect(_on_fall_zone_body_entered)
	$PressureBackflowHazard.body_entered.connect(
		_on_pressure_hazard_body_entered
	)
	$ExitArea.body_entered.connect(_on_exit_area_body_entered)


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	_hud.update_hp(current_hp, max_hp)


func _on_player_died(_death_metadata: Dictionary) -> void:
	_queue_reset(&"defeated")


func _on_player_attack_landed(metadata: Dictionary) -> void:
	var presentation_data: Dictionary = metadata.duplicate(true)
	if _hud.has_method("are_damage_numbers_enabled"):
		presentation_data["show_damage_number"] = (
			_hud.are_damage_numbers_enabled()
		)
	_last_player_hit_metadata = presentation_data.duplicate(true)
	_combat_presentation.on_hit_event(presentation_data)
	_dispatch_combat_audio(&"on_hit_event", presentation_data)
	if (
		_pressure_ambush_cleared
		and int(presentation_data.get("target_id", -1))
			== PRESSURE_AMBUSH_ENTITY_ID
		and not _kill_feedback_emitted
	):
		_kill_feedback_emitted = true
		_kill_feedback_count += 1
		var impact_position: Vector2 = _read_vector2(
			presentation_data.get("hit_position", Vector2.ZERO),
			_sluice_leech_spawn.global_position
		)
		_combat_presentation.on_kill_event(
			PRESSURE_AMBUSH_ENTITY_ID,
			impact_position
		)


func _on_player_dash_started(
	texture: Texture2D,
	world_position: Vector2,
	facing: float
) -> void:
	_combat_presentation.on_dodge_event(texture, world_position, facing)
	var valid_start: bool = (
		not _dash_crossed
		and facing > 0.0
		and world_position.x >= DASH_START_MIN_X
		and world_position.x < LEFT_PLATFORM_EDGE_X
		and world_position.y <= ENTRY_SPAWN_POSITION.y + 40.0
	)
	_dash_crossing_active = valid_start
	_dash_proof_frames_remaining = DASH_PROOF_FRAMES if valid_start else 0


func _on_player_double_jump_started(
	texture: Texture2D,
	world_position: Vector2,
	facing: float
) -> void:
	_combat_presentation.on_double_jump_event(texture, world_position, facing)
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method("on_double_jump_event"):
		audio_system.call(
			"on_double_jump_event",
			texture,
			world_position,
			facing
		)


func _on_factory_gate_state_changed(
	gate_id: StringName,
	state: StringName
) -> void:
	if gate_id != SEWER_FACTORY_GATE_ID or state != ExplorationGate.STATE_UNLOCKED:
		return
	_factory_gate_unlocked = true
	_sync_factory_junction_state()


func _on_hazard_body_entered(body: Node2D) -> void:
	if body != _player or _transition_requested or _dash_crossed:
		return
	if _dash_crossing_active:
		return
	_queue_reset(&"exhaust")


func _on_fall_zone_body_entered(body: Node2D) -> void:
	if body == _player and not _transition_requested:
		_queue_reset(&"fall")


func _on_pressure_hazard_body_entered(body: Node2D) -> void:
	if body == _player and _pressure_hazard_active and not _pressure_ambush_cleared:
		_queue_reset(&"pressure_backflow")


func _on_exit_area_body_entered(body: Node2D) -> void:
	if body == _player and _dash_crossed and _pressure_ambush_cleared:
		_request_main_return()


func _on_sluice_leech_defeated() -> void:
	if _pressure_ambush_cleared:
		return
	_pressure_ambush_activated = true
	_pressure_ambush_cleared = true
	_pressure_warning_frames_remaining = 0
	_pressure_hazard_active = false
	_sync_pressure_ambush_state()
	_sync_factory_junction_state()


func _on_sluice_leech_attack_landed(
	damage: int,
	hit_position: Vector2,
	is_crit: bool
) -> void:
	_last_enemy_hit_metadata = {
		"damage": damage,
		"hit_position": hit_position,
		"is_crit": is_crit,
		"source": &"factory_sluice_leech",
	}
	if _hud.has_method("are_damage_numbers_enabled"):
		_last_enemy_hit_metadata["show_damage_number"] = (
			_hud.are_damage_numbers_enabled()
		)
	_combat_presentation.on_hit_event(_last_enemy_hit_metadata)
	_dispatch_combat_audio(
		&"on_damage_taken_event",
		_last_enemy_hit_metadata
	)


func _on_pressure_cache_claimed(
	cache_id: StringName,
	reward: Dictionary
) -> void:
	if cache_id != PRESSURE_CACHE_ID or _pressure_cache_claimed:
		return
	_pressure_cache_claimed = true
	_reward_claim_count += 1
	_last_reward = reward.duplicate(true)
	_currency_amount += maxi(0, int(reward.get("gears", PRESSURE_REWARD_GEARS)))
	_hud.update_currency(_currency_amount)
	_request_pressure_reward_audio(reward)
	_sync_pressure_ambush_state()


func _complete_dash_crossing() -> void:
	if _dash_crossed:
		return
	_dash_crossing_active = false
	_dash_proof_frames_remaining = 0
	_dash_crossed = true
	_successful_dash_crossings += 1
	_sync_hazard_state()


func _queue_reset(reason: StringName) -> void:
	if _reset_pending or _transition_requested:
		return
	_reset_pending = true
	_last_reset_reason = reason
	_player.set_control_locked(true)
	call_deferred("_reset_attempt")


func _reset_attempt() -> void:
	if not is_inside_tree() or _transition_requested:
		_reset_pending = false
		return
	_reset_count += 1
	_dash_crossing_active = false
	_dash_proof_frames_remaining = 0
	var reset_pressure_ambush: bool = (
		_pressure_ambush_activated and not _pressure_ambush_cleared
	)
	if reset_pressure_ambush:
		_reset_pressure_ambush_attempt()
	var respawn_position: Vector2 = ENTRY_SPAWN_POSITION
	if _dash_crossed:
		respawn_position = (
			PRESSURE_CHAMBER_RESPAWN_POSITION
			if reset_pressure_ambush
			else RIGHT_RESPAWN_POSITION
		)
	_player.respawn_at(respawn_position, 1.0)
	_player.set_control_locked(false)
	_reset_pending = false


func _sync_factory_junction_state() -> void:
	if not is_node_ready():
		return
	_factory_double_jump_gate.set_ability_provider(_player)
	_factory_double_jump_gate.set_gate_unlocked(_factory_gate_unlocked)
	_factory_route_shell.set_route_available(
		_pressure_ambush_cleared and _factory_gate_unlocked
	)


func _process_factory_route_contact() -> void:
	if (
		not _pressure_ambush_cleared
		or not _factory_gate_unlocked
		or not _factory_route_shell.is_route_available()
	):
		return
	if _factory_route_shell.is_provider_in_transition_range(_player):
		_request_factory_transition()


func _request_factory_transition() -> bool:
	if (
		_transition_requested
		or not _pressure_ambush_cleared
		or not _factory_gate_unlocked
		or not _factory_route_shell.can_request_transition(_player)
		or not _is_valid_scene_manager(_scene_manager)
	):
		return false
	if _scene_manager.has_method("is_loading") \
			and bool(_scene_manager.call("is_loading")):
		return false
	if not bool(_scene_manager.call("has_scene", FACTORY_SCENE_ID)):
		return false
	if not _ensure_runtime_scene_root():
		return false
	var accepted: bool = bool(_scene_manager.call(
		"request_scene_change",
		FACTORY_SCENE_ID,
		FACTORY_SPAWN_POINT,
	))
	_transition_requested = accepted
	if not accepted:
		return false
	_seed_factory_handoff_state()
	_factory_route_reached = true
	_transition_request_count += 1
	_last_transition_target_scene = FACTORY_SCENE_ID
	_factory_route_shell.set_transition_requested(true)
	_seed_main_factory_handoff_state()
	_player.set_control_locked(true)
	return true


func _seed_factory_handoff_state() -> void:
	if not _scene_manager.has_method("set_scene_state"):
		return
	var factory_state: Dictionary = {}
	if _scene_manager.has_method("get_scene_state"):
		factory_state = Dictionary(_scene_manager.call(
			"get_scene_state",
			FACTORY_SCENE_ID,
		))
	_merge_current_player_progress(factory_state)
	_scene_manager.call("set_scene_state", FACTORY_SCENE_ID, factory_state)


func _seed_main_factory_handoff_state() -> void:
	if (
		not _scene_manager.has_method("get_scene_state")
		or not _scene_manager.has_method("set_scene_state")
	):
		return
	var main_state: Dictionary = Dictionary(_scene_manager.call(
		"get_scene_state",
		MAIN_SCENE_ID,
	))
	_merge_current_player_progress(main_state)
	var world_flags: Dictionary = Dictionary(
		main_state.get("world_flags", {})
	).duplicate(true)
	world_flags[SEWER_UNLOCKED_FLAG] = true
	world_flags[DASH_ROUTE_CROSSED_FLAG] = _dash_crossed
	world_flags[PRESSURE_AMBUSH_CLEARED_FLAG] = _pressure_ambush_cleared
	world_flags[PRESSURE_CACHE_CLAIMED_FLAG] = _pressure_cache_claimed
	world_flags[FACTORY_UNLOCKED_FLAG] = true
	world_flags[SEWER_FACTORY_ROUTE_REACHED_FLAG] = true
	main_state["world_flags"] = world_flags
	_scene_manager.call("set_scene_state", MAIN_SCENE_ID, main_state)


func _merge_current_player_progress(target_state: Dictionary) -> void:
	var unlocked_abilities: Array = Array(
		target_state.get("unlocked_abilities", [])
	)
	for ability_id: String in _get_player_unlocked_ability_strings():
		if not unlocked_abilities.has(ability_id):
			unlocked_abilities.append(ability_id)
	target_state["unlocked_abilities"] = unlocked_abilities
	target_state["currency"] = _currency_amount


func _request_main_return() -> bool:
	if (
		_transition_requested
		or not _pressure_ambush_cleared
		or not _is_valid_scene_manager(_scene_manager)
	):
		return false
	if _scene_manager.has_method("is_loading") \
			and bool(_scene_manager.call("is_loading")):
		return false
	if not bool(_scene_manager.call("has_scene", MAIN_SCENE_ID)):
		return false
	if not _ensure_runtime_scene_root():
		return false
	_seed_main_return_state()
	var accepted: bool = bool(_scene_manager.call(
		"request_scene_change",
		MAIN_SCENE_ID,
		MAIN_RETURN_SPAWN,
	))
	_transition_requested = accepted
	if accepted:
		_transition_request_count += 1
		_last_transition_target_scene = MAIN_SCENE_ID
		_player.set_control_locked(true)
	return accepted


func _seed_main_return_state() -> void:
	if (
		not _scene_manager.has_method("get_scene_state")
		or not _scene_manager.has_method("set_scene_state")
	):
		return
	var main_state: Dictionary = Dictionary(_scene_manager.call(
		"get_scene_state",
		MAIN_SCENE_ID,
	))
	var unlocked_abilities: Array = Array(main_state.get("unlocked_abilities", []))
	for ability_id: String in _get_player_unlocked_ability_strings():
		if not unlocked_abilities.has(ability_id):
			unlocked_abilities.append(ability_id)
	main_state["unlocked_abilities"] = unlocked_abilities
	main_state["currency"] = _currency_amount
	var world_flags: Dictionary = Dictionary(main_state.get("world_flags", {})).duplicate(true)
	world_flags[SEWER_UNLOCKED_FLAG] = true
	world_flags[DASH_ROUTE_CROSSED_FLAG] = true
	world_flags[PRESSURE_AMBUSH_CLEARED_FLAG] = _pressure_ambush_cleared
	world_flags[PRESSURE_CACHE_CLAIMED_FLAG] = _pressure_cache_claimed
	main_state["world_flags"] = world_flags
	_scene_manager.call("set_scene_state", MAIN_SCENE_ID, main_state)


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
	_player.set_target_health_adapter(self)
	_player.set_damage_calculator_adapter(self)
	_player.set_weapon_component(_weapon_component)
	_weapon_component.set_combat_adapter(_player.get_combat_component())
	_weapon_component.set_collision_adapter(_player.get_collision_component())


func _spawn_sluice_leech() -> void:
	if is_instance_valid(_sluice_leech):
		if _sluice_leech.get_parent() != null:
			_sluice_leech.get_parent().remove_child(_sluice_leech)
		_sluice_leech.free()
	_sluice_leech = SLUICE_LEECH_SCENE.instantiate() as Node2D
	if _sluice_leech == null:
		return
	_sluice_leech.name = "SewerSluiceLeech"
	_sluice_leech.position = _sluice_leech_spawn.position
	add_child(_sluice_leech)
	_sluice_leech.call(
		"configure_summon",
		PRESSURE_AMBUSH_ID,
		PRESSURE_AMBUSH_ENTITY_ID,
		PRESSURE_AMBUSH_SUMMON_ID
	)
	_sluice_leech.call("set_damage_calculator_adapter", self)
	var defeated_signal: Signal = _sluice_leech.get("enemy_defeated")
	if not defeated_signal.is_connected(_on_sluice_leech_defeated):
		defeated_signal.connect(_on_sluice_leech_defeated)
	var attack_signal: Signal = _sluice_leech.get("enemy_attack_landed")
	if not attack_signal.is_connected(_on_sluice_leech_attack_landed):
		attack_signal.connect(_on_sluice_leech_attack_landed)
	_leech_runtime_active = false
	_set_sluice_leech_active(false)


func _restore_pressure_ambush_enemy() -> void:
	_spawn_sluice_leech()


func _setup_pressure_cache() -> void:
	if _pressure_cache == null or not _pressure_cache.has_signal("cache_claimed"):
		return
	var claimed_signal: Signal = _pressure_cache.get("cache_claimed")
	if not claimed_signal.is_connected(_on_pressure_cache_claimed):
		claimed_signal.connect(_on_pressure_cache_claimed)


func _auto_activate_pressure_ambush() -> void:
	if _pressure_ambush_activated or _pressure_ambush_cleared:
		return
	try_activate_pressure_ambush(_player)


func _advance_pressure_warning() -> void:
	if (
		not _pressure_ambush_activated
		or _pressure_ambush_cleared
		or _pressure_hazard_active
		or _pressure_warning_frames_remaining <= 0
	):
		return
	_pressure_warning_frames_remaining -= 1
	if _pressure_warning_frames_remaining <= 0:
		_pressure_hazard_active = true
		_sync_pressure_hazard_state()


func _process_pressure_cache_contact() -> void:
	if (
		_pressure_cache == null
		or not _pressure_cache.has_method("is_claim_available")
		or not bool(_pressure_cache.call("is_claim_available"))
		or not _pressure_cache.has_method("is_provider_in_reward_range")
	):
		return
	if bool(_pressure_cache.call("is_provider_in_reward_range", _player)):
		try_claim_pressure_cache(_player)


func _sync_pressure_cache_prompt_visibility() -> void:
	if _pressure_cache_prompt == null:
		return
	var in_prompt_range: bool = false
	if _pressure_cache is Node2D:
		in_prompt_range = _player.global_position.distance_to(
			(_pressure_cache as Node2D).global_position
		) <= 192.0
	_pressure_cache_prompt.visible = (
		_is_pressure_cache_available()
		and not _pressure_cache_claimed
		and in_prompt_range
	)


func _sync_pressure_ambush_state() -> void:
	_set_room_seal_blocking(not _pressure_ambush_cleared)
	_set_sluice_leech_active(
		_pressure_ambush_activated and not _pressure_ambush_cleared
	)
	if _pressure_cache != null:
		if _pressure_cache.has_method("set_available"):
			_pressure_cache.call("set_available", _pressure_ambush_cleared)
		if _pressure_cache.has_method("set_claimed"):
			_pressure_cache.call("set_claimed", _pressure_cache_claimed)
	_sync_pressure_hazard_state()
	_sync_pressure_cache_prompt_visibility()


func _set_sluice_leech_active(active: bool) -> void:
	if not is_instance_valid(_sluice_leech):
		_leech_runtime_active = false
		return
	if active:
		var was_active: bool = _leech_runtime_active
		_sluice_leech.visible = true
		_sluice_leech.process_mode = Node.PROCESS_MODE_INHERIT
		_sluice_leech.set_physics_process(true)
		_sluice_leech.collision_layer = 2
		_sluice_leech.collision_mask = 17
		_sluice_leech.call("set_attack_target", _player)
		_leech_runtime_active = true
		if not was_active:
			_sluice_leech.call("begin_pacing")
		return
	_sluice_leech.call("set_attack_target", null)
	_leech_runtime_active = false
	if (
		_pressure_ambush_cleared
		and _sluice_leech.has_method("get_current_hp")
		and int(_sluice_leech.call("get_current_hp")) <= 0
	):
		return
	_sluice_leech.set_physics_process(false)
	_sluice_leech.process_mode = Node.PROCESS_MODE_DISABLED
	_sluice_leech.collision_layer = 0
	_sluice_leech.collision_mask = 0
	_sluice_leech.visible = false


func _set_room_seal_blocking(blocking: bool) -> void:
	_room_seal_blocking = blocking
	_pressure_room_seal.visible = blocking
	_pressure_room_seal.collision_layer = 16 if blocking else 0
	_pressure_room_seal_shape.set_deferred("disabled", not blocking)


func _sync_pressure_hazard_state() -> void:
	var state: StringName = _get_pressure_hazard_state()
	_pressure_animation.play(state)
	var active: bool = state == &"active"
	_pressure_hazard_active = active
	_pressure_hazard_shape.set_deferred("disabled", not active)
	_pressure_hazard.set_deferred("monitoring", active)


func _reset_pressure_ambush_attempt() -> void:
	_pressure_ambush_activated = false
	_pressure_warning_frames_remaining = 0
	_pressure_hazard_active = false
	_last_player_hit_metadata.clear()
	_last_enemy_hit_metadata.clear()
	_kill_feedback_emitted = false
	_kill_feedback_count = 0
	_spawn_sluice_leech()
	_sync_pressure_ambush_state()


func _get_pressure_ambush_state() -> StringName:
	if _pressure_ambush_cleared:
		return &"cleared"
	if not _dash_crossed:
		return &"locked"
	if not _pressure_ambush_activated:
		return &"ready"
	if _pressure_warning_frames_remaining > 0:
		return &"warning"
	return &"active"


func _get_pressure_hazard_state() -> StringName:
	if _pressure_ambush_cleared or not _pressure_ambush_activated:
		return &"safe"
	if _pressure_warning_frames_remaining > 0:
		return &"warning"
	return &"active"


func _is_pressure_cache_available() -> bool:
	return (
		_pressure_cache != null
		and _pressure_cache.has_method("is_claim_available")
		and bool(_pressure_cache.call("is_claim_available"))
	)


func _get_sluice_leech_frame_counts() -> Dictionary:
	var frame_counts: Dictionary = {}
	if not is_instance_valid(_sluice_leech):
		return frame_counts
	var sprite: AnimatedSprite2D = (
		_sluice_leech.get_node_or_null("Sprite") as AnimatedSprite2D
	)
	if sprite == null or sprite.sprite_frames == null:
		return frame_counts
	for animation_name: StringName in [
		&"idle", &"run", &"attack_tell", &"attack", &"hurt", &"death"
	]:
		frame_counts[String(animation_name)] = (
			sprite.sprite_frames.get_frame_count(animation_name)
			if sprite.sprite_frames.has_animation(animation_name)
			else 0
		)
	return frame_counts


func _get_pressure_cache_texture_path() -> String:
	if _pressure_cache != null and _pressure_cache.has_method(
		"get_visual_texture_path"
	):
		return String(_pressure_cache.call("get_visual_texture_path"))
	return ""


func _request_pressure_reward_audio(reward: Dictionary) -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null or not audio_system.has_method(
		"on_reward_cache_claimed"
	):
		return
	var world_position: Vector2 = (
		(_pressure_cache as Node2D).global_position
		if _pressure_cache is Node2D
		else Vector2.ZERO
	)
	audio_system.call(
		"on_reward_cache_claimed",
		PRESSURE_CACHE_ID,
		reward,
		world_position,
		{
			"scene_id": SEWER_SCENE_ID,
			"feedback_role": &"reward_cache_claim",
			"route_label": "Pressure Chamber Secured +15 Gears",
		}
	)


func _dispatch_combat_audio(
	method: StringName,
	metadata: Dictionary
) -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method(method):
		audio_system.call(method, metadata)


func _read_vector2(value: Variant, fallback: Vector2) -> Vector2:
	return value as Vector2 if value is Vector2 else fallback


func _sync_hazard_state() -> void:
	if not is_node_ready():
		return
	_hazard_shape.set_deferred("disabled", _dash_crossed)
	_hazard.set_deferred("monitoring", not _dash_crossed)
	_hazard_animation.play(&"safe" if _dash_crossed else &"active")


func _animation_frame_count(animation_name: StringName) -> int:
	if (
		_hazard_animation.sprite_frames == null
		or not _hazard_animation.sprite_frames.has_animation(animation_name)
	):
		return 0
	return _hazard_animation.sprite_frames.get_frame_count(animation_name)


func _pressure_animation_frame_count(animation_name: StringName) -> int:
	if (
		_pressure_animation.sprite_frames == null
		or not _pressure_animation.sprite_frames.has_animation(animation_name)
	):
		return 0
	return _pressure_animation.sprite_frames.get_frame_count(animation_name)


func _get_player_unlocked_ability_strings() -> Array[String]:
	var unlocked: Array[String] = []
	for value: Variant in _player.get_unlocked_abilities():
		var ability_id: String = String(value)
		if not unlocked.has(ability_id):
			unlocked.append(ability_id)
	return unlocked


func _restore_player_unlocked_abilities(state: Dictionary) -> void:
	_player.set_unlocked_abilities(Array(state.get(
		"unlocked_abilities",
		_get_player_unlocked_ability_strings(),
	)))


func _connect_scene_manager_signal() -> void:
	if not _scene_manager.has_signal("on_scene_changed"):
		return
	var changed: Signal = _scene_manager.get("on_scene_changed")
	if not changed.is_connected(_on_scene_manager_changed):
		changed.connect(_on_scene_manager_changed)


func _disconnect_scene_manager_signal() -> void:
	if (
		_scene_manager == null
		or not is_instance_valid(_scene_manager)
		or not _scene_manager.has_signal("on_scene_changed")
	):
		return
	var changed: Signal = _scene_manager.get("on_scene_changed")
	if changed.is_connected(_on_scene_manager_changed):
		changed.disconnect(_on_scene_manager_changed)


func _on_scene_manager_changed(old_scene: StringName, new_scene: StringName) -> void:
	if new_scene != SEWER_SCENE_ID:
		return
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method("on_scene_changed"):
		audio_system.call("on_scene_changed", old_scene, new_scene)


func _ensure_runtime_scene_root() -> bool:
	if not _scene_manager.has_method("configure_runtime_scene_root"):
		return true
	if _scene_manager.has_method("is_runtime_scene_swap_enabled") \
			and bool(_scene_manager.call("is_runtime_scene_swap_enabled")):
		return true
	var runtime_root: Node = get_parent()
	if runtime_root == null:
		return false
	return bool(_scene_manager.call("configure_runtime_scene_root", runtime_root, self))


func _is_valid_scene_manager(scene_manager: Object) -> bool:
	return (
		scene_manager != null
		and scene_manager.has_method("has_scene")
		and scene_manager.has_method("request_scene_change")
	)
