## Owns Story143's moving lift, Counterweight Sentry, shutters, and endpoint.
class_name CentralTowerDeepLiftController
extends Node2D

signal objective_changed(objective_text: String)

const SENTRY_ENTITY_ID: int = 2703
const SENTRY_CONFIG_ID: StringName = &"central_tower_counterweight_sentry"
const SENTRY_SUMMON_ID: StringName = &"central_tower_counterweight_sentry"
const ENCOUNTER_ID: StringName = &"central_tower_deep_lift_ambush"
const ENDPOINT_ID: StringName = &"central_tower_deep_lift_upper_endpoint"
const PLATFORM_START: Vector2 = Vector2(4380.0, 590.0)
const PLATFORM_MID: Vector2 = Vector2(4380.0, 450.0)
const PLATFORM_TOP: Vector2 = Vector2(4380.0, 290.0)
const SENTRY_START: Vector2 = Vector2(4470.0, 436.0)
const PLATFORM_HALF_WIDTH_PX: float = 210.0
const PLATFORM_BOARDING_Y_MIN: float = -78.0
const PLATFORM_BOARDING_Y_MAX: float = -8.0
const ENDPOINT_RADIUS_PX: float = 112.0
const PLATFORM_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_deep_lift_platform_512x160.png"
)
const COUNTERWEIGHT_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_deep_lift_counterweight_256x512.png"
)
const SHUTTER_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_deep_lift_entry_shutter_384x512.png"
)
const CRADLE_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_counterweight_sentry_cradle_256x256.png"
)
const CONSOLE_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_deep_lift_brake_console_256x384.png"
)
const WARNING_TEXTURE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "vfx_central_tower_deep_lift_warning_sweep_512x128.png"
)
const SPRITE_FRAMES_PATH: String = (
	"res://assets/characters/central_tower_counterweight_sentry/"
	+ "central_tower_counterweight_sentry_sprite_frames.tres"
)
const REQUIRED_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]
const PHASE_IDLE: StringName = &"idle"
const PHASE_STARTUP: StringName = &"startup_interlock"
const PHASE_LOWER_RISE: StringName = &"lower_rise"
const PHASE_DEPLOY_GRACE: StringName = &"deploy_grace"
const PHASE_COMBAT: StringName = &"combat"
const PHASE_DEFEAT_LINGER: StringName = &"defeat_linger"
const PHASE_UPPER_RISE: StringName = &"upper_rise"
const PHASE_DOCKED: StringName = &"docked"

@export var startup_delay_sec: float = 0.60
@export var deploy_grace_sec: float = 0.75
@export var lower_travel_speed_px_sec: float = 100.0
@export var upper_travel_speed_px_sec: float = 112.0
@export var post_defeat_linger_sec: float = 0.45

@onready var _platform: AnimatableBody2D = (
	get_node_or_null("DeepLiftPlatform") as AnimatableBody2D
)
@onready var _platform_start: Marker2D = (
	get_node_or_null("PlatformStart") as Marker2D
)
@onready var _platform_mid: Marker2D = (
	get_node_or_null("PlatformAmbushStop") as Marker2D
)
@onready var _platform_top: Marker2D = (
	get_node_or_null("PlatformTop") as Marker2D
)
@onready var _entry_shutter: StaticBody2D = (
	get_node_or_null("EntryShutter") as StaticBody2D
)
@onready var _upper_shutter: StaticBody2D = (
	get_node_or_null("UpperShutter") as StaticBody2D
)
@onready var _counterweight: Sprite2D = (
	get_node_or_null("CounterweightCarriage") as Sprite2D
)
@onready var _sentry_cradle: Sprite2D = (
	get_node_or_null("SentryCradle") as Sprite2D
)
@onready var _warning_sweep: Sprite2D = (
	get_node_or_null("WarningSweep") as Sprite2D
)
@onready var _sentry: CharacterBody2D = (
	get_node_or_null("CentralTowerCounterweightSentry") as CharacterBody2D
)
@onready var _fall_zone: Area2D = (
	get_node_or_null("DeepLiftFallZone") as Area2D
)
@onready var _endpoint: Node2D = get_node_or_null("UpperEndpoint") as Node2D
@onready var _platform_prompt: Label = (
	get_node_or_null("DeepLiftPlatform/PromptLabel") as Label
)
@onready var _endpoint_prompt: Label = (
	get_node_or_null("UpperEndpoint/PromptLabel") as Label
)

var _route_unlocked: bool = false
var _attempt_active: bool = false
var _phase: StringName = PHASE_IDLE
var _phase_remaining_sec: float = 0.0
var _sentry_activated: bool = false
var _sentry_defeated: bool = false
var _deep_lift_ascended: bool = false
var _upper_docked: bool = false
var _entry_shutter_blocking: bool = false
var _upper_shutter_blocking: bool = false
var _death_animation_pending: bool = false
var _player: Node2D = null
var _scene_owner: Object = null
var _counterweight_start_position: Vector2 = Vector2(4740.0, 290.0)
var _activation_feedback_count: int = 0
var _defeat_feedback_count: int = 0
var _endpoint_feedback_count: int = 0
var _fall_accept_count: int = 0
var _audio_request_count: int = 0
var _last_emitted_objective_text: String = ""
var _platform_sync_restore_queued: bool = false


func _ready() -> void:
	_capture_authored_positions()
	_configure_sentry()
	_connect_sentry_signal()
	_connect_fall_zone()
	_reset_attempt_runtime(not _sentry_defeated)
	_sync_state()


func _physics_process(delta: float) -> void:
	advance_time(delta)
	_sync_prompt_visibility()


## Injects the player and scene-local persistence adapter.
func configure_runtime(player: Node2D, scene_owner: Object) -> bool:
	_player = player
	_scene_owner = scene_owner
	_capture_authored_positions()
	_configure_sentry()
	_connect_sentry_signal()
	_connect_fall_zone()
	_sync_state()
	return _player != null and _scene_owner != null


## Story142's durable Cooling Shaft traversal is the only prerequisite.
func set_route_unlocked(unlocked: bool) -> void:
	_route_unlocked = unlocked
	if not _route_unlocked and not _attempt_active:
		_phase = PHASE_IDLE
	_sync_state()


## Starts a lift attempt only while the player is standing on the lower platform.
func try_activate(provider: Node = null) -> bool:
	if (
		not _route_unlocked
		or _attempt_active
		or _upper_docked
		or _platform == null
	):
		return false
	var activation_provider: Node = _player if provider == null else provider
	if activation_provider != _player or not _provider_is_boarding_platform(
		activation_provider
	):
		return false
	_attempt_active = true
	_phase = PHASE_STARTUP
	_phase_remaining_sec = maxf(0.01, startup_delay_sec)
	_sentry_activated = false
	_upper_docked = false
	_activation_feedback_count += 1
	_set_shutters(true, true)
	_request_activation_audio()
	_sync_state()
	return true


## Advances the deterministic interlock, travel, deployment, and docking phases.
func advance_time(delta_sec: float) -> void:
	var remaining: float = maxf(0.0, delta_sec)
	var transition_guard: int = 0
	while remaining > 0.0 and transition_guard < 16:
		transition_guard += 1
		match _phase:
			PHASE_STARTUP:
				remaining = _advance_timer_phase(remaining, PHASE_LOWER_RISE)
			PHASE_LOWER_RISE:
				var lower_result: Dictionary = _advance_platform_toward(
					_platform_mid_position(),
					maxf(1.0, lower_travel_speed_px_sec),
					remaining
				)
				remaining = float(lower_result.get("remaining", 0.0))
				if not bool(lower_result.get("arrived", false)):
					return
				if _sentry_defeated:
					_enter_upper_rise()
				else:
					_enter_deploy_grace()
			PHASE_DEPLOY_GRACE:
				remaining = _advance_timer_phase(remaining, PHASE_COMBAT)
			PHASE_DEFEAT_LINGER:
				remaining = _advance_timer_phase(remaining, PHASE_UPPER_RISE)
			PHASE_UPPER_RISE:
				var upper_result: Dictionary = _advance_platform_toward(
					_platform_top_position(),
					maxf(1.0, upper_travel_speed_px_sec),
					remaining
				)
				remaining = float(upper_result.get("remaining", 0.0))
				if not bool(upper_result.get("arrived", false)):
					return
				_enter_docked()
			PHASE_IDLE, PHASE_COMBAT, PHASE_DOCKED:
				return
			_:
				return
	_sync_state()


func handles_target_id(target_id: int) -> bool:
	return target_id == SENTRY_ENTITY_ID


## Routes player hit-confirm damage to the live Counterweight Sentry.
func apply_damage(
	target_id: int,
	final_damage: int,
	metadata: Dictionary = {}
) -> bool:
	if (
		target_id != SENTRY_ENTITY_ID
		or final_damage <= 0
		or not _sentry_activated
		or _sentry_defeated
		or not _is_live_sentry()
		or not _sentry.has_method("apply_damage")
	):
		return false
	_sentry.call("apply_damage", final_damage, metadata)
	if (
		_is_live_sentry()
		and _sentry.has_method("get_current_hp")
		and int(_sentry.call("get_current_hp")) <= 0
		and not _sentry_defeated
	):
		_on_sentry_defeated()
	return true


## Supplies configured ram damage through the Sentry CombatComponent.
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
	var damage: int = _call_sentry_int("get_attack_damage", 12)
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
		"damage_category": &"counterweight_ram",
	}


## Requests the readable Sentry ram for tests and the final MCP probe.
func request_sentry_attack() -> bool:
	return (
		_phase == PHASE_COMBAT
		and _sentry_activated
		and not _sentry_defeated
		and _is_live_sentry()
		and _sentry.has_method("request_attack")
		and bool(_sentry.call("request_attack"))
	)


## Applies lethal shaft fall damage through the real player API.
func apply_fall(target: Node = null) -> bool:
	var fall_target: Node = _player if target == null else target
	if (
		not _route_unlocked
		or fall_target == null
		or fall_target != _player
		or not fall_target.has_method("apply_damage")
		or not fall_target.has_method("get_current_hp")
		or int(fall_target.call("get_current_hp")) <= 0
	):
		return false
	var lethal_damage: int = (
		int(fall_target.call("get_max_hp"))
		if fall_target.has_method("get_max_hp")
		else int(fall_target.call("get_current_hp"))
	)
	fall_target.call("apply_damage", lethal_damage, {
		"source": &"central_tower_deep_lift_fall",
		"damage_type": &"fall",
		"scene_id": &"area_05_central_tower",
	})
	if int(fall_target.call("get_current_hp")) > 0:
		return false
	_fall_accept_count += 1
	return true


## Records the upper endpoint once, after a completed current-session ride.
func try_activate_endpoint(provider: Node = null) -> bool:
	if (
		not _route_unlocked
		or not _sentry_defeated
		or not _upper_docked
		or _deep_lift_ascended
	):
		return false
	var activation_provider: Node = _player if provider == null else provider
	if not _is_provider_near(_endpoint, activation_provider, ENDPOINT_RADIUS_PX):
		return false
	_deep_lift_ascended = true
	_endpoint_feedback_count += 1
	_request_endpoint_audio()
	_sync_state()
	_persist_owner_state()
	return true


## Resets an uncleared attempt without rolling back durable outcomes.
func reset_failed_attempt() -> bool:
	_reset_attempt_runtime(not _sentry_defeated)
	_sync_state()
	return true


## Captures only the two durable Story143 outcomes.
func get_local_state() -> Dictionary:
	return {
		"central_tower_counterweight_sentry_defeated": _sentry_defeated,
		"central_tower_deep_lift_ascended": _deep_lift_ascended,
	}


## Restores durable outcomes while always returning the lift to its lower dock.
func set_local_state(state: Dictionary) -> void:
	_deep_lift_ascended = bool(state.get(
		"central_tower_deep_lift_ascended",
		false
	))
	_sentry_defeated = bool(state.get(
		"central_tower_counterweight_sentry_defeated",
		_deep_lift_ascended
	)) or _deep_lift_ascended
	_activation_feedback_count = 0
	_defeat_feedback_count = 0
	_endpoint_feedback_count = 0
	_fall_accept_count = 0
	_audio_request_count = 0
	_reset_attempt_runtime(not _sentry_defeated)
	_sync_state()


func should_own_objective(provider: Node = null) -> bool:
	if not _route_unlocked:
		return false
	if _attempt_active or _sentry_defeated or _deep_lift_ascended:
		return true
	var objective_provider: Node = _player if provider == null else provider
	return (
		objective_provider is Node2D
		and (objective_provider as Node2D).global_position.x >= 3840.0
	)


func get_objective_text() -> String:
	if _deep_lift_ascended:
		return "Deep Lift Secured"
	if _upper_docked:
		return "Reach Upper Deck"
	if _phase == PHASE_UPPER_RISE or _sentry_defeated:
		return "Ride to Upper Deck"
	if _phase == PHASE_COMBAT or _phase == PHASE_DEFEAT_LINGER:
		return "Break the Counterweight Sentry"
	if _phase == PHASE_DEPLOY_GRACE:
		return "Hold the Lift"
	if _attempt_active:
		return "Hold the Lift"
	return "Board Deep Lift"


## Returns authored geometry, physics, combat, animation, and durable state.
func get_diagnostics() -> Dictionary:
	var sprite: AnimatedSprite2D = _get_sentry_sprite()
	var frames: SpriteFrames = sprite.sprite_frames if sprite != null else null
	var config_diagnostics: Dictionary = {}
	if _is_live_sentry() and _sentry.has_method("get_config_diagnostics"):
		config_diagnostics = Dictionary(_sentry.call(
			"get_config_diagnostics"
		)).duplicate(true)
	return {
		"controller_present": true,
		"controller_script_path": get_script().resource_path,
		"route_unlocked": _route_unlocked,
		"attempt_active": _attempt_active,
		"phase": String(_phase),
		"phase_remaining_sec": _phase_remaining_sec,
		"platform_position": _platform.position if _platform != null else Vector2.ZERO,
		"platform_start_position": _platform_start_position(),
		"platform_mid_position": _platform_mid_position(),
		"platform_top_position": _platform_top_position(),
		"platform_sync_to_physics": (
			_platform.sync_to_physics if _platform != null else false
		),
		"upper_docked": _upper_docked,
		"entry_shutter_blocking": _entry_shutter_blocking,
		"upper_shutter_blocking": _upper_shutter_blocking,
		"sentry_activated": _sentry_activated,
		"sentry_defeated": _sentry_defeated,
		"deep_lift_ascended": _deep_lift_ascended,
		"sentry_entity_id": SENTRY_ENTITY_ID,
		"sentry_config_id": String(SENTRY_CONFIG_ID),
		"sentry_current_hp": _sentry_hp(false),
		"sentry_max_hp": _sentry_hp(true),
		"sentry_visible": _sentry_visible(),
		"sentry_animation": String(sprite.animation) if sprite != null else "",
		"sprite_frames_path": frames.resource_path if frames != null else "",
		"sprite_frames_expected_path": SPRITE_FRAMES_PATH,
		"animation_frames": _animation_frame_counts(frames),
		"config_diagnostics": config_diagnostics,
		"platform_texture_path": _child_texture_path(_platform, "Visual"),
		"platform_expected_path": PLATFORM_TEXTURE_PATH,
		"counterweight_texture_path": _texture_path(_counterweight),
		"counterweight_expected_path": COUNTERWEIGHT_TEXTURE_PATH,
		"entry_shutter_texture_path": _child_texture_path(
			_entry_shutter,
			"Visual"
		),
		"shutter_expected_path": SHUTTER_TEXTURE_PATH,
		"cradle_texture_path": _texture_path(_sentry_cradle),
		"cradle_expected_path": CRADLE_TEXTURE_PATH,
		"console_texture_path": _child_texture_path(_endpoint, "Visual"),
		"console_expected_path": CONSOLE_TEXTURE_PATH,
		"warning_texture_path": _texture_path(_warning_sweep),
		"warning_expected_path": WARNING_TEXTURE_PATH,
		"endpoint_id": String(ENDPOINT_ID),
		"activation_feedback_count": _activation_feedback_count,
		"defeat_feedback_count": _defeat_feedback_count,
		"endpoint_feedback_count": _endpoint_feedback_count,
		"fall_accept_count": _fall_accept_count,
		"audio_request_count": _audio_request_count,
		"objective_text": get_objective_text(),
	}


func _advance_timer_phase(remaining: float, next_phase: StringName) -> float:
	if _phase_remaining_sec > remaining:
		_phase_remaining_sec -= remaining
		return 0.0
	var leftover: float = remaining - _phase_remaining_sec
	_phase_remaining_sec = 0.0
	match next_phase:
		PHASE_LOWER_RISE:
			_phase = PHASE_LOWER_RISE
		PHASE_COMBAT:
			_enter_combat()
		PHASE_UPPER_RISE:
			_hide_defeated_sentry()
			_enter_upper_rise()
		_:
			_phase = next_phase
	_sync_state()
	return leftover


func _advance_platform_toward(
	target_position: Vector2,
	speed_px_sec: float,
	delta_sec: float
) -> Dictionary:
	if _platform == null:
		return {"remaining": 0.0, "arrived": false}
	var distance: float = _platform.position.distance_to(target_position)
	if distance <= 0.01:
		_set_platform_position(target_position)
		_sync_counterweight_position()
		return {"remaining": delta_sec, "arrived": true}
	var travel_time: float = distance / speed_px_sec
	if delta_sec + 0.000001 < travel_time:
		_set_platform_position(_platform.position.move_toward(
			target_position,
			speed_px_sec * delta_sec
		))
		_sync_counterweight_position()
		return {"remaining": 0.0, "arrived": false}
	_set_platform_position(target_position)
	_sync_counterweight_position()
	return {"remaining": maxf(0.0, delta_sec - travel_time), "arrived": true}


func _enter_deploy_grace() -> void:
	_phase = PHASE_DEPLOY_GRACE
	_phase_remaining_sec = maxf(0.01, deploy_grace_sec)
	_sentry_activated = true
	_set_sentry_active(true)
	_sync_state()


func _enter_combat() -> void:
	_phase = PHASE_COMBAT
	_phase_remaining_sec = 0.0
	_sentry_activated = true
	_set_sentry_active(true)
	_sync_state()


func _enter_upper_rise() -> void:
	_phase = PHASE_UPPER_RISE
	_phase_remaining_sec = 0.0
	_sync_state()


func _enter_docked() -> void:
	_phase = PHASE_DOCKED
	_phase_remaining_sec = 0.0
	_upper_docked = true
	_attempt_active = false
	_set_shutters(false, false)
	_sync_state()


func _on_sentry_defeated() -> void:
	if _sentry_defeated:
		return
	_sentry_activated = true
	_sentry_defeated = true
	_death_animation_pending = true
	_phase = PHASE_DEFEAT_LINGER
	_phase_remaining_sec = maxf(0.01, post_defeat_linger_sec)
	_defeat_feedback_count += 1
	_request_sentry_defeat_audio()
	_sync_state()
	_persist_owner_state()


func _reset_attempt_runtime(reset_sentry: bool) -> void:
	_attempt_active = false
	_phase = PHASE_IDLE
	_phase_remaining_sec = 0.0
	_sentry_activated = false
	_upper_docked = false
	_death_animation_pending = false
	if _platform != null:
		_set_platform_position(_platform_start_position())
		_platform.constant_linear_velocity = Vector2.ZERO
	_set_shutters(false, false)
	_sync_counterweight_position()
	if reset_sentry:
		_reset_live_sentry()
	else:
		_hide_defeated_sentry()


func _reset_live_sentry() -> void:
	if not _is_live_sentry():
		return
	_sentry.position = SENTRY_START
	if _sentry.has_method("reset_for_encounter"):
		_sentry.call("reset_for_encounter")
	_set_sentry_active(false)


func _configure_sentry() -> void:
	if not _is_live_sentry():
		return
	if _sentry.has_method("configure_summon"):
		_sentry.call(
			"configure_summon",
			ENCOUNTER_ID,
			SENTRY_ENTITY_ID,
			SENTRY_SUMMON_ID
		)
	if _sentry.has_method("set_damage_calculator_adapter"):
		_sentry.call("set_damage_calculator_adapter", self)


func _connect_sentry_signal() -> void:
	if not _is_live_sentry() or not _sentry.has_signal("enemy_defeated"):
		return
	var defeated_signal: Signal = _sentry.get("enemy_defeated")
	if not defeated_signal.is_connected(_on_sentry_defeated):
		defeated_signal.connect(_on_sentry_defeated)


func _connect_fall_zone() -> void:
	if _fall_zone != null and not _fall_zone.body_entered.is_connected(
		_on_fall_zone_body_entered
	):
		_fall_zone.body_entered.connect(_on_fall_zone_body_entered)


func _on_fall_zone_body_entered(body: Node2D) -> void:
	if body == _player:
		apply_fall(body)


func _set_sentry_active(active: bool) -> void:
	if not _is_live_sentry():
		return
	if active:
		_sentry.visible = true
		_sentry.process_mode = Node.PROCESS_MODE_INHERIT
		_sentry.set_physics_process(true)
		_sentry.collision_layer = 2
		_sentry.collision_mask = 17
		if _sentry.has_method("set_attack_target"):
			_sentry.call("set_attack_target", _player)
		if _sentry.has_method("begin_pacing"):
			_sentry.call("begin_pacing", 24)
		return
	if _sentry.has_method("set_attack_target"):
		_sentry.call("set_attack_target", null)
	_sentry.set_physics_process(false)
	_sentry.process_mode = Node.PROCESS_MODE_DISABLED
	_sentry.collision_layer = 0
	_sentry.collision_mask = 0
	_sentry.visible = false


func _hold_sentry_death_animation() -> void:
	if not _is_live_sentry():
		return
	if _sentry.has_method("set_attack_target"):
		_sentry.call("set_attack_target", null)
	_sentry.visible = true
	_sentry.process_mode = Node.PROCESS_MODE_INHERIT
	_sentry.set_physics_process(false)
	_sentry.collision_layer = 0
	_sentry.collision_mask = 0


func _hide_defeated_sentry() -> void:
	_death_animation_pending = false
	if not _is_live_sentry():
		return
	_set_sentry_active(false)


func _sync_state() -> void:
	if _sentry_defeated and _death_animation_pending:
		_hold_sentry_death_animation()
	elif _sentry_defeated:
		_hide_defeated_sentry()
	elif not _sentry_activated:
		_set_sentry_active(false)
	_set_shutters(
		_attempt_active and not _upper_docked,
		_attempt_active and not _upper_docked
	)
	if _fall_zone != null:
		_fall_zone.set_deferred("monitoring", _route_unlocked)
		_fall_zone.set_deferred("monitorable", _route_unlocked)
	_sync_warning_visual()
	_sync_prompt_visibility()
	_emit_objective_if_changed()


func _set_shutters(entry_blocking: bool, upper_blocking: bool) -> void:
	_entry_shutter_blocking = entry_blocking
	_upper_shutter_blocking = upper_blocking
	_set_shutter_blocking(_entry_shutter, entry_blocking)
	_set_shutter_blocking(_upper_shutter, upper_blocking)


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


func _sync_warning_visual() -> void:
	if _warning_sweep == null:
		return
	_warning_sweep.visible = _phase in [
		PHASE_STARTUP,
		PHASE_DEPLOY_GRACE,
		PHASE_COMBAT,
	]
	_warning_sweep.modulate = (
		Color(1.0, 0.28, 0.18, 0.42)
		if _phase != PHASE_COMBAT
		else Color(1.0, 0.58, 0.18, 0.28)
	)


func _sync_prompt_visibility() -> void:
	if _platform_prompt != null:
		_platform_prompt.text = (
			"Ride to Upper Deck" if _sentry_defeated else "Board Deep Lift"
		)
		_platform_prompt.visible = (
			_route_unlocked
			and not _attempt_active
			and not _upper_docked
			and _is_provider_near(_platform, _player, 240.0)
		)
	if _endpoint_prompt != null:
		_endpoint_prompt.text = (
			"Deep Lift Secured"
			if _deep_lift_ascended
			else "Reach Upper Deck"
		)
		_endpoint_prompt.visible = (
			_route_unlocked
			and _upper_docked
			and _is_provider_near(_endpoint, _player, 192.0)
		)


func _sync_counterweight_position() -> void:
	if _counterweight == null or _platform == null:
		return
	var platform_rise: float = _platform_start_position().y - _platform.position.y
	_counterweight.position = _counterweight_start_position + Vector2(
		0.0,
		platform_rise
	)


func _set_platform_position(target_position: Vector2) -> void:
	if _platform == null:
		return
	if _platform.position.is_equal_approx(target_position):
		return
	var restore_sync: bool = (
		_platform.sync_to_physics and not Engine.is_in_physics_frame()
	)
	if restore_sync:
		_platform.sync_to_physics = false
	_platform.position = target_position
	_platform.force_update_transform()
	if restore_sync:
		PhysicsServer2D.body_set_state(
			_platform.get_rid(),
			PhysicsServer2D.BODY_STATE_TRANSFORM,
			_platform.global_transform
		)
		_queue_platform_sync_restore()


func _queue_platform_sync_restore() -> void:
	if _platform_sync_restore_queued:
		return
	_platform_sync_restore_queued = true
	call_deferred("_restore_platform_sync_to_physics")


func _restore_platform_sync_to_physics() -> void:
	_platform_sync_restore_queued = false
	if _platform == null or not is_instance_valid(_platform):
		return
	_platform.force_update_transform()
	PhysicsServer2D.body_set_state(
		_platform.get_rid(),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		_platform.global_transform
	)
	_platform.sync_to_physics = true


func _capture_authored_positions() -> void:
	if _counterweight != null:
		_counterweight_start_position = _counterweight.position


func _provider_is_boarding_platform(provider: Node) -> bool:
	if provider == null or not provider is Node2D or _platform == null:
		return false
	var relative: Vector2 = (
		(provider as Node2D).global_position - _platform.global_position
	)
	return (
		absf(relative.x) <= PLATFORM_HALF_WIDTH_PX
		and relative.y >= PLATFORM_BOARDING_Y_MIN
		and relative.y <= PLATFORM_BOARDING_Y_MAX
	)


func _is_provider_near(target: Node2D, provider: Node, radius_px: float) -> bool:
	return (
		target != null
		and provider != null
		and provider is Node2D
		and target.global_position.distance_to(
			(provider as Node2D).global_position
		) <= radius_px
	)


func _emit_objective_if_changed() -> void:
	var objective_text: String = get_objective_text()
	if objective_text == _last_emitted_objective_text:
		return
	_last_emitted_objective_text = objective_text
	objective_changed.emit(objective_text)


func _request_activation_audio() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method("play_sfx"):
		audio_system.call("play_sfx", &"sfx_door_lock")
		_audio_request_count += 1


func _request_sentry_defeat_audio() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null or not audio_system.has_method("on_enemy_defeated"):
		return
	audio_system.call("on_enemy_defeated", {
		"enemy_id": String(SENTRY_SUMMON_ID),
		"entity_id": SENTRY_ENTITY_ID,
		"world_position": (
			_sentry.global_position if _is_live_sentry() else SENTRY_START
		),
	})
	_audio_request_count += 1


func _request_endpoint_audio() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method("play_sfx"):
		audio_system.call("play_sfx", &"sfx_door_unlock")
		_audio_request_count += 1


func _persist_owner_state() -> void:
	if (
		_scene_owner != null
		and is_instance_valid(_scene_owner)
		and _scene_owner.has_method("persist_central_tower_threshold_progress")
	):
		_scene_owner.call("persist_central_tower_threshold_progress")


func _platform_start_position() -> Vector2:
	return _platform_start.position if _platform_start != null else PLATFORM_START


func _platform_mid_position() -> Vector2:
	return _platform_mid.position if _platform_mid != null else PLATFORM_MID


func _platform_top_position() -> Vector2:
	return _platform_top.position if _platform_top != null else PLATFORM_TOP


func _get_sentry_sprite() -> AnimatedSprite2D:
	return (
		_sentry.get_node_or_null("Sprite") as AnimatedSprite2D
		if _is_live_sentry()
		else null
	)


func _sentry_hp(maximum: bool) -> int:
	var method_name: StringName = &"get_max_hp" if maximum else &"get_current_hp"
	return _call_sentry_int(method_name, 44 if maximum else 0)


func _call_sentry_int(method_name: StringName, fallback: int) -> int:
	if not _is_live_sentry() or not _sentry.has_method(method_name):
		return fallback
	return int(_sentry.call(method_name))


func _sentry_visible() -> bool:
	return _is_live_sentry() and _sentry.visible


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


func _is_live_sentry() -> bool:
	return _sentry != null and is_instance_valid(_sentry)
