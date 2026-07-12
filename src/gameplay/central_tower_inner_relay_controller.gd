## Owns Story141's relay parry, Mantis skirmish, shutters, and reward state.
class_name CentralTowerInnerRelayController
extends Node2D

signal objective_changed(objective_text: String)
signal pulse_state_changed(pulse_state: StringName)
signal relay_reflected

const ACTIVATION_X: float = 1500.0
const BACK_SHUTTER_X: float = 1420.0
const RELAY_X: float = 1640.0
const PULSE_X: float = 1800.0
const MANTIS_X: float = 2140.0
const CACHE_X: float = 2320.0
const FORWARD_SHUTTER_X: float = 2440.0
const PARRY_ABILITY_ID: StringName = &"parry"
const MANTIS_ENTITY_ID: int = 2702
const ENCOUNTER_ID: StringName = &"central_tower_inner_relay_skirmish"
const MANTIS_SUMMON_ID: StringName = &"central_tower_relay_mantis"
const MANTIS_FAMILY_ID: StringName = &"central_tower_relay_mantis"
const CACHE_ID: StringName = &"central_tower_inner_relay_cache"
const CACHE_REWARD_GEARS: int = 20
const STATE_IDLE: StringName = &"idle"
const STATE_TELEGRAPH: StringName = &"telegraph"
const STATE_STRIKE: StringName = &"strike"
const STATE_RECOVERY: StringName = &"recovery"
const STATE_COMPLETE: StringName = &"complete"
const STRIKE_EXPOSURE_RADIUS_PX: float = 420.0
const SPRITE_FRAMES_PATH: String = (
	"res://assets/characters/central_tower_relay_mantis/"
	+ "central_tower_relay_mantis_sprite_frames.tres"
)
const RELAY_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_service_relay_256x512.png"
)
const SHUTTER_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_observation_shutter_384x512.png"
)
const PERCH_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_mantis_perch_256x256.png"
)
const CACHE_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_relay_cache_256x256.png"
)
const PULSE_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "vfx_central_tower_relay_pulse_512x128.png"
)
const REQUIRED_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]

@export var telegraph_duration_sec: float = 0.55
@export var strike_duration_sec: float = 0.18
@export var recovery_duration_sec: float = 0.55
@export var miss_damage: int = 8

@onready var _back_shutter: StaticBody2D = (
	get_node_or_null("BackShutter") as StaticBody2D
)
@onready var _relay_emitter: Sprite2D = (
	get_node_or_null("RelayEmitter") as Sprite2D
)
@onready var _pulse_visual: Sprite2D = (
	get_node_or_null("RelayPulseVisual") as Sprite2D
)
@onready var _mantis_perch: Sprite2D = (
	get_node_or_null("MantisPerch") as Sprite2D
)
@onready var _mantis: CharacterBody2D = (
	get_node_or_null("CentralTowerRelayMantis") as CharacterBody2D
)
@onready var _forward_shutter: StaticBody2D = (
	get_node_or_null("ForwardShutter") as StaticBody2D
)
@onready var _cache: FactoryCombatCache = (
	get_node_or_null("InnerRelayCache") as FactoryCombatCache
)
@onready var _cache_prompt: Label = (
	get_node_or_null("InnerRelayCache/PromptLabel") as Label
)

var _threshold_cleared: bool = false
var _relay_activated: bool = false
var _relay_parried: bool = false
var _mantis_activated: bool = false
var _mantis_defeated: bool = false
var _cache_claimed: bool = false
var _death_animation_pending: bool = false
var _pulse_state: StringName = STATE_IDLE
var _pulse_remaining_sec: float = 0.0
var _pulse_resolved: bool = false
var _last_pulse_reflected: bool = false
var _player: Node2D = null
var _scene_owner: Object = null
var _mantis_start_position: Vector2 = Vector2(MANTIS_X, 576.0)
var _mantis_start_captured: bool = false
var _last_reward: Dictionary = {}
var _last_parry_event: Dictionary = {}
var _last_miss_event: Dictionary = {}
var _activation_feedback_count: int = 0
var _parry_feedback_count: int = 0
var _miss_count: int = 0
var _defeat_feedback_count: int = 0
var _reward_feedback_count: int = 0
var _audio_request_count: int = 0
var _last_emitted_objective_text: String = ""


func _ready() -> void:
	_capture_mantis_start_position()
	_connect_mantis_signal()
	_connect_cache_signal()
	_sync_state()


func _process(delta: float) -> void:
	if (
		_player != null
		and _threshold_cleared
		and not _relay_activated
		and not _mantis_defeated
	):
		try_activate(_player)
	advance_time(delta)
	_sync_cache_prompt_visibility()


## Injects the player and scene-local persistence adapter.
func configure_runtime(player: Node2D, scene_owner: Object) -> bool:
	_disconnect_player_signal()
	_player = player
	_scene_owner = scene_owner
	_connect_player_signal()
	_capture_mantis_start_position()
	_configure_mantis()
	_connect_mantis_signal()
	_connect_cache_signal()
	_sync_state()
	return _player != null and _scene_owner != null


## Makes the inner slice available only after Story140's durable clear.
func set_threshold_cleared(cleared: bool) -> void:
	_threshold_cleared = cleared
	if not _threshold_cleared and not _mantis_defeated:
		_reset_transient_state()
	_sync_state()


## Starts the one-pulse relay trial after crossing the authored threshold.
func try_activate(provider: Node = null) -> bool:
	if (
		not _threshold_cleared
		or _relay_activated
		or _relay_parried
		or _mantis_defeated
	):
		return false
	var activation_provider: Node = _player if provider == null else provider
	if (
		activation_provider != _player
		or not activation_provider is Node2D
		or (activation_provider as Node2D).global_position.x < ACTIVATION_X
		or not _provider_has_parry(activation_provider)
	):
		return false
	_relay_activated = true
	_activation_feedback_count += 1
	_enter_telegraph()
	_sync_state()
	_persist_owner_state()
	return true


## Advances the deterministic telegraph, strike, and recovery phases.
func advance_time(delta_sec: float) -> void:
	if not _relay_activated or _relay_parried or _mantis_defeated:
		return
	var remaining: float = maxf(0.0, delta_sec)
	var transitions: int = 0
	while remaining > 0.0 and transitions < 8 and not _relay_parried:
		if _pulse_state not in [STATE_TELEGRAPH, STATE_STRIKE, STATE_RECOVERY]:
			return
		if _pulse_remaining_sec > remaining:
			_pulse_remaining_sec -= remaining
			return
		remaining -= _pulse_remaining_sec
		_pulse_remaining_sec = 0.0
		transitions += 1
		match _pulse_state:
			STATE_TELEGRAPH:
				_enter_strike()
			STATE_STRIKE:
				if not _pulse_resolved:
					_resolve_missed_pulse()
				if not _relay_parried:
					_enter_recovery(false)
			STATE_RECOVERY:
				_enter_telegraph()
			_:
				return


func handles_target_id(target_id: int) -> bool:
	return target_id == MANTIS_ENTITY_ID


## Routes player hit-confirm damage to the live Relay Mantis.
func apply_damage(
	target_id: int,
	final_damage: int,
	metadata: Dictionary = {}
) -> bool:
	if (
		target_id != MANTIS_ENTITY_ID
		or final_damage <= 0
		or not _mantis_activated
		or _mantis_defeated
		or not _is_live_mantis()
		or not _mantis.has_method("apply_damage")
	):
		return false
	_mantis.call("apply_damage", final_damage, metadata)
	if (
		_is_live_mantis()
		and _mantis.has_method("get_current_hp")
		and int(_mantis.call("get_current_hp")) <= 0
		and not _mantis_defeated
	):
		_on_mantis_defeated()
	return true


## Supplies configured Mantis damage through its CombatComponent.
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
	var damage: int = _call_mantis_int("get_attack_damage", 12)
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
		"damage_category": &"relay_scythe_dash",
	}


## Requests the readable Mantis scythe dash for tests and MCP probes.
func request_mantis_attack() -> bool:
	return (
		_mantis_activated
		and not _mantis_defeated
		and _is_live_mantis()
		and _mantis.has_method("request_attack")
		and bool(_mantis.call("request_attack"))
	)


## Attempts the once-only post-combat relay-cache claim.
func try_claim_cache(provider: Node = null) -> bool:
	if _cache == null or not _mantis_defeated or _cache_claimed:
		return false
	var claim_provider: Node = _player if provider == null else provider
	return _cache.try_claim(claim_provider)


## Resets only a failed live attempt; durable clear is never rolled back.
func reset_failed_attempt() -> bool:
	if _mantis_defeated:
		return false
	_reset_transient_state()
	if _is_live_mantis():
		if _mantis_start_captured:
			_mantis.position = _mantis_start_position
		if _mantis.has_method("reset_for_encounter"):
			_mantis.call("reset_for_encounter")
	_sync_state()
	_persist_owner_state()
	return _is_live_mantis()


func get_local_state() -> Dictionary:
	return {
		"central_tower_inner_relay_activated": _relay_activated,
		"central_tower_inner_relay_parried": _relay_parried,
		"central_tower_relay_mantis_activated": _mantis_activated,
		"central_tower_relay_mantis_defeated": _mantis_defeated,
		"central_tower_inner_cache_claimed": _cache_claimed,
	}


## Restores durable clear while deliberately discarding an unfinished attempt.
func set_local_state(state: Dictionary) -> void:
	_death_animation_pending = false
	_cache_claimed = bool(state.get(
		"central_tower_inner_cache_claimed",
		false
	))
	_mantis_defeated = bool(state.get(
		"central_tower_relay_mantis_defeated",
		_cache_claimed
	)) or _cache_claimed
	if _mantis_defeated:
		_relay_activated = true
		_relay_parried = true
		_mantis_activated = true
		_set_pulse_state(STATE_COMPLETE, 0.0)
	else:
		_reset_transient_state()
	_last_reward = (
		{
			"cache_id": String(CACHE_ID),
			"gears": CACHE_REWARD_GEARS,
			"source": "central_tower_inner_relay",
		}
		if _cache_claimed
		else {}
	)
	_activation_feedback_count = 0
	_parry_feedback_count = 0
	_miss_count = 0
	_defeat_feedback_count = 0
	_reward_feedback_count = 0
	_audio_request_count = 0
	_last_parry_event.clear()
	_last_miss_event.clear()
	_sync_state()


## Returns whether this second viewport owns the shared objective label.
func should_own_objective(provider: Node = null) -> bool:
	if not _threshold_cleared:
		return false
	if _relay_activated or _relay_parried or _mantis_defeated or _cache_claimed:
		return true
	var objective_provider: Node = _player if provider == null else provider
	return (
		objective_provider is Node2D
		and (objective_provider as Node2D).global_position.x >= 1280.0
	)


func get_objective_text() -> String:
	if _cache_claimed:
		return "Service Spine Secured"
	if _mantis_defeated:
		return "Claim Relay Cache +20 Gears"
	if _mantis_activated:
		return "Break the Relay Mantis"
	if _relay_activated:
		return "Parry the Service Pulse"
	if _threshold_cleared:
		return "Enter the Service Spine"
	return "Break the Threshold Guard"


func get_last_reward() -> Dictionary:
	return _last_reward.duplicate(true)


## Returns authored assets, timing, combat, animation, and durable state.
func get_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = _get_mantis_sprite()
	var frames: SpriteFrames = sprite.sprite_frames if sprite != null else null
	var attack_metadata: Dictionary = {}
	var config_diagnostics: Dictionary = {}
	if _is_live_mantis() and _mantis.has_method("get_current_enemy_attack_metadata"):
		attack_metadata = Dictionary(_mantis.call(
			"get_current_enemy_attack_metadata"
		)).duplicate(true)
	if _is_live_mantis() and _mantis.has_method("get_config_diagnostics"):
		config_diagnostics = Dictionary(_mantis.call(
			"get_config_diagnostics"
		)).duplicate(true)
	return {
		"controller_present": true,
		"controller_script_path": get_script().resource_path,
		"activation_x": ACTIVATION_X,
		"relay_x": _node_x(_relay_emitter, RELAY_X),
		"pulse_x": _node_x(_pulse_visual, PULSE_X),
		"mantis_x": _node_x(_mantis, MANTIS_X),
		"cache_x": _node_x(_cache, CACHE_X),
		"back_shutter_x": _node_x(_back_shutter, BACK_SHUTTER_X),
		"forward_shutter_x": _node_x(
			_forward_shutter,
			FORWARD_SHUTTER_X
		),
		"relay_texture_path": _texture_path(_relay_emitter),
		"relay_expected_path": RELAY_TEXTURE_PATH,
		"shutter_texture_path": _child_texture_path(_back_shutter, "Visual"),
		"shutter_expected_path": SHUTTER_TEXTURE_PATH,
		"perch_texture_path": _texture_path(_mantis_perch),
		"perch_expected_path": PERCH_TEXTURE_PATH,
		"pulse_texture_path": _texture_path(_pulse_visual),
		"pulse_expected_path": PULSE_TEXTURE_PATH,
		"cache_texture_path": (
			_cache.get_visual_texture_path() if _cache != null else ""
		),
		"cache_expected_path": CACHE_TEXTURE_PATH,
		"threshold_cleared": _threshold_cleared,
		"encounter_state": String(_encounter_state()),
		"relay_activated": _relay_activated,
		"relay_parried": _relay_parried,
		"pulse_state": String(_pulse_state),
		"pulse_remaining_sec": _pulse_remaining_sec,
		"miss_damage": maxi(0, miss_damage),
		"miss_count": _miss_count,
		"mantis_activated": _mantis_activated,
		"mantis_defeated": _mantis_defeated,
		"mantis_entity_id": MANTIS_ENTITY_ID,
		"mantis_family_id": _mantis_family_id(),
		"mantis_current_hp": _mantis_hp(false),
		"mantis_max_hp": _mantis_hp(true),
		"mantis_position": _mantis.position if _is_live_mantis() else Vector2.ZERO,
		"mantis_start_position": _mantis_start_position,
		"mantis_visible": _mantis_visible(),
		"mantis_has_target": _mantis_has_target(),
		"mantis_animation": String(sprite.animation) if sprite != null else "",
		"sprite_frames_path": frames.resource_path if frames != null else "",
		"sprite_frames_expected_path": SPRITE_FRAMES_PATH,
		"animation_frames": _animation_frame_counts(frames),
		"attack_startup_frames": _call_mantis_int("get_attack_startup_frames", 0),
		"attack_active_frames": _call_mantis_int("get_attack_active_frames", 0),
		"attack_recovery_frames": _call_mantis_int(
			"get_attack_recovery_frames",
			0
		),
		"attack_damage": _call_mantis_int("get_attack_damage", 0),
		"attack_active": (
			bool(_mantis.call("is_enemy_attack_active"))
			if _is_live_mantis() and _mantis.has_method("is_enemy_attack_active")
			else false
		),
		"attack_metadata": attack_metadata,
		"config_diagnostics": config_diagnostics,
		"back_shutter_blocking": _shutter_blocking(_back_shutter),
		"forward_shutter_blocking": _shutter_blocking(_forward_shutter),
		"cache_available": _cache != null and _cache.is_available(),
		"cache_claimed": _cache_claimed,
		"last_reward": _last_reward.duplicate(true),
		"last_parry_event": _last_parry_event.duplicate(true),
		"last_miss_event": _last_miss_event.duplicate(true),
		"activation_feedback_count": _activation_feedback_count,
		"parry_feedback_count": _parry_feedback_count,
		"defeat_feedback_count": _defeat_feedback_count,
		"reward_feedback_count": _reward_feedback_count,
		"audio_request_count": _audio_request_count,
		"objective_text": get_objective_text(),
	}


func _connect_player_signal() -> void:
	if _player == null or not _player.has_signal("ability_activated"):
		return
	var activated_signal: Signal = _player.get("ability_activated")
	if not activated_signal.is_connected(_on_player_ability_activated):
		activated_signal.connect(_on_player_ability_activated)


func _disconnect_player_signal() -> void:
	if (
		_player == null
		or not is_instance_valid(_player)
		or not _player.has_signal("ability_activated")
	):
		return
	var activated_signal: Signal = _player.get("ability_activated")
	if activated_signal.is_connected(_on_player_ability_activated):
		activated_signal.disconnect(_on_player_ability_activated)


func _on_player_ability_activated(ability_id: StringName) -> void:
	if (
		ability_id != PARRY_ABILITY_ID
		or _pulse_state != STATE_STRIKE
		or _pulse_resolved
		or not _player_in_strike_lane()
	):
		return
	_resolve_reflected_pulse()


func _resolve_reflected_pulse() -> void:
	_pulse_resolved = true
	_last_pulse_reflected = true
	_relay_parried = true
	_mantis_activated = true
	_parry_feedback_count += 1
	_last_parry_event = {
		"ability_id": String(PARRY_ABILITY_ID),
		"parry_type": "perfect",
		"world_position": _player.global_position if _player != null else Vector2.ZERO,
	}
	_set_pulse_state(STATE_COMPLETE, 0.0)
	_request_parry_feedback()
	relay_reflected.emit()
	_sync_state()
	_persist_owner_state()


func _resolve_missed_pulse() -> void:
	_pulse_resolved = true
	_last_pulse_reflected = false
	if not _player_in_strike_lane():
		return
	_miss_count += 1
	_last_miss_event = {
		"damage": maxi(0, miss_damage),
		"source": "central_tower_inner_relay",
		"world_position": _player.global_position if _player != null else Vector2.ZERO,
	}
	if (
		_player != null
		and _player.has_method("apply_damage")
		and maxi(0, miss_damage) > 0
	):
		_player.call("apply_damage", maxi(0, miss_damage), {
			"source": &"central_tower_inner_relay",
			"damage_type": &"electric",
			"scene_id": &"area_05_central_tower",
		})


func _enter_telegraph() -> void:
	_pulse_resolved = false
	_last_pulse_reflected = false
	_set_pulse_state(STATE_TELEGRAPH, maxf(0.01, telegraph_duration_sec))


func _enter_strike() -> void:
	_pulse_resolved = false
	_set_pulse_state(STATE_STRIKE, maxf(0.01, strike_duration_sec))


func _enter_recovery(reflected: bool) -> void:
	_last_pulse_reflected = reflected
	_set_pulse_state(STATE_RECOVERY, maxf(0.01, recovery_duration_sec))


func _set_pulse_state(state: StringName, duration_sec: float) -> void:
	_pulse_state = state
	_pulse_remaining_sec = maxf(0.0, duration_sec)
	_sync_pulse_visual()
	pulse_state_changed.emit(_pulse_state)
	_emit_objective_if_changed()


func _reset_transient_state() -> void:
	_relay_activated = false
	_relay_parried = false
	_mantis_activated = false
	_death_animation_pending = false
	_pulse_state = STATE_IDLE
	_pulse_remaining_sec = 0.0
	_pulse_resolved = false
	_last_pulse_reflected = false


func _configure_mantis() -> void:
	if not _is_live_mantis():
		return
	if _mantis.has_method("configure_summon"):
		_mantis.call(
			"configure_summon",
			ENCOUNTER_ID,
			MANTIS_ENTITY_ID,
			MANTIS_SUMMON_ID
		)
	if _mantis.has_method("set_damage_calculator_adapter"):
		_mantis.call("set_damage_calculator_adapter", self)


func _capture_mantis_start_position() -> void:
	if _mantis_start_captured or not _is_live_mantis():
		return
	_mantis_start_position = (
		_mantis_perch.position if _mantis_perch != null else _mantis.position
	)
	_mantis_start_captured = true


func _connect_mantis_signal() -> void:
	if not _is_live_mantis() or not _mantis.has_signal("enemy_defeated"):
		return
	var defeated_signal: Signal = _mantis.get("enemy_defeated")
	if not defeated_signal.is_connected(_on_mantis_defeated):
		defeated_signal.connect(_on_mantis_defeated)


func _connect_cache_signal() -> void:
	if _cache != null and not _cache.cache_claimed.is_connected(_on_cache_claimed):
		_cache.cache_claimed.connect(_on_cache_claimed)


func _on_mantis_defeated() -> void:
	if _mantis_defeated:
		return
	_relay_activated = true
	_relay_parried = true
	_mantis_activated = true
	_mantis_defeated = true
	_death_animation_pending = true
	_defeat_feedback_count += 1
	_set_pulse_state(STATE_COMPLETE, 0.0)
	_request_mantis_defeat_audio()
	_sync_state()
	_persist_owner_state()


func _on_cache_claimed(cache_id: StringName, reward: Dictionary) -> void:
	if cache_id != CACHE_ID or _cache_claimed:
		return
	_cache_claimed = true
	_last_reward = reward.duplicate(true)
	_reward_feedback_count += 1
	_request_reward_audio(cache_id, reward)
	_sync_state()
	_persist_owner_state()


func _sync_state() -> void:
	if _mantis_defeated and _death_animation_pending:
		_hold_mantis_death_animation()
	else:
		_set_mantis_active(_mantis_activated and not _mantis_defeated)
	var blocking: bool = _relay_activated and not _mantis_defeated
	_set_shutter_blocking(_back_shutter, blocking)
	_set_shutter_blocking(_forward_shutter, blocking)
	if _cache != null:
		_cache.visible = _mantis_defeated
		_cache.set_available(_mantis_defeated)
		_cache.set_claimed(_cache_claimed)
	_sync_pulse_visual()
	_sync_cache_prompt_visibility()
	_emit_objective_if_changed()
	set_process(_threshold_cleared and not _cache_claimed)


func _hold_mantis_death_animation() -> void:
	if not _is_live_mantis():
		return
	if _mantis.has_method("set_attack_target"):
		_mantis.call("set_attack_target", null)
	_mantis.visible = true
	_mantis.process_mode = Node.PROCESS_MODE_INHERIT
	_mantis.set_physics_process(false)
	_mantis.collision_layer = 0
	_mantis.collision_mask = 0


func _set_mantis_active(active: bool) -> void:
	if not _is_live_mantis():
		return
	var was_active: bool = (
		_mantis.visible and _mantis.process_mode != Node.PROCESS_MODE_DISABLED
	)
	if active:
		_mantis.visible = true
		_mantis.process_mode = Node.PROCESS_MODE_INHERIT
		_mantis.set_physics_process(true)
		_mantis.collision_layer = 2
		_mantis.collision_mask = 17
		if _mantis.has_method("set_attack_target"):
			_mantis.call("set_attack_target", _player)
		if not was_active and _mantis.has_method("begin_pacing"):
			_mantis.call("begin_pacing", 22)
		return
	if _mantis.has_method("set_attack_target"):
		_mantis.call("set_attack_target", null)
	_mantis.set_physics_process(false)
	_mantis.process_mode = Node.PROCESS_MODE_DISABLED
	_mantis.collision_layer = 0
	_mantis.collision_mask = 0
	_mantis.visible = false


func _set_shutter_blocking(shutter: StaticBody2D, blocking: bool) -> void:
	if shutter == null:
		return
	shutter.visible = blocking
	shutter.collision_layer = 16 if blocking else 0
	shutter.collision_mask = 0
	var shape: CollisionShape2D = shutter.get_node_or_null(
		"CollisionShape2D"
	) as CollisionShape2D
	if shape != null:
		shape.set_deferred("disabled", not blocking)


func _sync_pulse_visual() -> void:
	if _pulse_visual == null:
		return
	match _pulse_state:
		STATE_TELEGRAPH:
			_pulse_visual.visible = true
			_pulse_visual.modulate = Color(1.0, 0.32, 0.28, 0.40)
			_pulse_visual.scale = Vector2(0.88, 0.76)
		STATE_STRIKE:
			_pulse_visual.visible = true
			_pulse_visual.modulate = Color.WHITE
			_pulse_visual.scale = Vector2.ONE
		STATE_RECOVERY:
			_pulse_visual.visible = true
			_pulse_visual.modulate = (
				Color(0.40, 1.0, 0.96, 0.70)
				if _last_pulse_reflected
				else Color(1.0, 0.16, 0.16, 0.20)
			)
			_pulse_visual.scale = Vector2(1.02, 0.80)
		_:
			_pulse_visual.visible = false


func _sync_cache_prompt_visibility() -> void:
	if _cache_prompt == null or _cache == null:
		return
	_cache_prompt.visible = (
		_mantis_defeated
		and not _cache_claimed
		and _player != null
		and _cache.is_provider_in_reward_range(_player)
	)


func _emit_objective_if_changed() -> void:
	var objective_text: String = get_objective_text()
	if objective_text == _last_emitted_objective_text:
		return
	_last_emitted_objective_text = objective_text
	objective_changed.emit(objective_text)


func _request_parry_feedback() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method("on_parry_event"):
		if bool(audio_system.call("on_parry_event", _last_parry_event.duplicate(true))):
			_audio_request_count += 1


func _request_mantis_defeat_audio() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null or not audio_system.has_method("on_enemy_defeated"):
		return
	audio_system.call("on_enemy_defeated", {
		"enemy_id": String(MANTIS_SUMMON_ID),
		"entity_id": MANTIS_ENTITY_ID,
		"world_position": (
			_mantis.global_position if _is_live_mantis() else Vector2(MANTIS_X, 520.0)
		),
	})
	_audio_request_count += 1


func _request_reward_audio(cache_id: StringName, reward: Dictionary) -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null or not audio_system.has_method("on_reward_cache_claimed"):
		return
	audio_system.call(
		"on_reward_cache_claimed",
		cache_id,
		reward,
		_cache.global_position if _cache != null else Vector2(CACHE_X, 520.0),
		{"scene_id": &"area_05_central_tower"}
	)
	_audio_request_count += 1


func _persist_owner_state() -> void:
	if (
		_scene_owner != null
		and is_instance_valid(_scene_owner)
		and _scene_owner.has_method("persist_central_tower_threshold_progress")
	):
		_scene_owner.call("persist_central_tower_threshold_progress")


func _provider_has_parry(provider: Node) -> bool:
	return (
		provider != null
		and provider.has_method("has_ability")
		and bool(provider.call("has_ability", PARRY_ABILITY_ID))
	)


func _player_in_strike_lane() -> bool:
	return (
		_pulse_visual != null
		and _player != null
		and _player.global_position.distance_to(_pulse_visual.global_position)
		<= STRIKE_EXPOSURE_RADIUS_PX
	)


func _encounter_state() -> StringName:
	if _cache_claimed:
		return &"claimed"
	if _mantis_defeated:
		return &"cleared"
	if _mantis_activated:
		return &"active"
	if _relay_activated:
		return &"relay"
	if _threshold_cleared:
		return &"ready"
	return &"locked"


func _get_mantis_sprite() -> AnimatedSprite2D:
	return (
		_mantis.get_node_or_null("Sprite") as AnimatedSprite2D
		if _is_live_mantis()
		else null
	)


func _mantis_family_id() -> String:
	if _is_live_mantis() and _mantis.has_method("get_enemy_family_id"):
		return String(_mantis.call("get_enemy_family_id"))
	return String(MANTIS_FAMILY_ID)


func _mantis_hp(maximum: bool) -> int:
	var method_name: StringName = &"get_max_hp" if maximum else &"get_current_hp"
	return _call_mantis_int(method_name, 40 if maximum else 0)


func _call_mantis_int(method_name: StringName, fallback: int) -> int:
	if not _is_live_mantis() or not _mantis.has_method(method_name):
		return fallback
	return int(_mantis.call(method_name))


func _mantis_visible() -> bool:
	return (
		_is_live_mantis()
		and _mantis.visible
		and _mantis.process_mode != Node.PROCESS_MODE_DISABLED
	)


func _mantis_has_target() -> bool:
	return (
		_is_live_mantis()
		and _mantis.has_method("has_attack_target")
		and bool(_mantis.call("has_attack_target"))
	)


func _shutter_blocking(shutter: StaticBody2D) -> bool:
	if shutter == null:
		return false
	var shape: CollisionShape2D = shutter.get_node_or_null(
		"CollisionShape2D"
	) as CollisionShape2D
	return (
		shutter.visible
		and shutter.collision_layer == 16
		and shape != null
		and not shape.disabled
	)


func _animation_frame_counts(frames: SpriteFrames) -> Dictionary:
	var counts: Dictionary = {}
	if frames == null:
		return counts
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		counts[String(animation_name)] = (
			frames.get_frame_count(animation_name)
			if frames.has_animation(animation_name)
			else 0
		)
	return counts


func _node_x(node: Node2D, fallback: float) -> float:
	return node.global_position.x if node != null else fallback


func _child_texture_path(parent: Node, child_name: String) -> String:
	if parent == null:
		return ""
	return _texture_path(parent.get_node_or_null(child_name) as Sprite2D)


func _texture_path(sprite: Sprite2D) -> String:
	return (
		sprite.texture.resource_path
		if sprite != null and sprite.texture != null
		else ""
	)


func _is_live_mantis() -> bool:
	return _mantis != null and is_instance_valid(_mantis)
