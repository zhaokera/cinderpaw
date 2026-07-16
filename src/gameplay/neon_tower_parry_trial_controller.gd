## Owns Story139's Central Tower outer laser timing trial and threshold state.
class_name NeonTowerParryTrialController
extends Node2D

signal objective_changed(objective_text: String)
signal pulse_state_changed(pulse_state: StringName)
signal parry_reflected(successful_parries: int)

const ROUTE_WIDTH_PX: int = 5120
const RIGHT_WALL_X: float = 5100.0
const ACCESS_SEAL_X: float = 3860.0
const LASER_EMITTER_X: float = 4320.0
const TOWER_GATE_X: float = 4740.0
const THRESHOLD_X: float = 4970.0
const PARRY_ABILITY_ID: StringName = &"parry"
const GATE_ID: StringName = &"central_tower_outer_laser_net"
const TARGET_AREA_ID: StringName = &"area_05_central_tower"
const STATE_IDLE: StringName = &"idle"
const STATE_TELEGRAPH: StringName = &"telegraph"
const STATE_STRIKE: StringName = &"strike"
const STATE_RECOVERY: StringName = &"recovery"
const STATE_COMPLETE: StringName = &"complete"
const ACTIVATION_RADIUS_PX: float = 260.0
const STRIKE_EXPOSURE_RADIUS_PX: float = 520.0
const THRESHOLD_RADIUS_PX: float = 112.0
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "env_neon_tower_parry_trial_1280x720.png"
)
const GATE_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_tower_laser_gate_384x512.png"
)
const PULSE_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "vfx_neon_tower_laser_pulse_512x128.png"
)
const PULSE_SPRITE_FRAMES_PATH: String = (
	"res://assets/environment/neon_rooftops/tower_parry_laser/"
	+ "tower_parry_laser_sprite_frames.tres"
)
const PULSE_SPRITE_FRAMES: SpriteFrames = preload(PULSE_SPRITE_FRAMES_PATH)
const ENDPOINT_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_tower_threshold_beacon_256x384.png"
)

@export var telegraph_duration_sec: float = 0.60
@export var strike_duration_sec: float = 0.18
@export var recovery_duration_sec: float = 0.55
@export var required_parries: int = 3
@export var miss_damage: int = 18

@onready var _background: Sprite2D = (
	get_node_or_null("../TowerParryBackground") as Sprite2D
)
@onready var _access_seal: StaticBody2D = (
	get_node_or_null("AccessSeal") as StaticBody2D
)
@onready var _laser_emitter: Node2D = (
	get_node_or_null("LaserEmitter") as Node2D
)
@onready var _trial_zone: Area2D = get_node_or_null("TrialZone") as Area2D
@onready var _pulse_visual: Sprite2D = (
	get_node_or_null("LaserPulseVisual") as Sprite2D
)
@onready var _pulse_animation: AnimatedSprite2D = (
	get_node_or_null("LaserPulseAnimation") as AnimatedSprite2D
)
@onready var _tower_gate: ExplorationGate = (
	get_node_or_null("TowerLaserGate") as ExplorationGate
)
@onready var _threshold: Node2D = (
	get_node_or_null("TowerThresholdEndpoint") as Node2D
)
@onready var _gate_prompt: Label = (
	get_node_or_null("TowerLaserGate/PromptLabel") as Label
)
@onready var _threshold_prompt: Label = (
	get_node_or_null("TowerThresholdEndpoint/PromptLabel") as Label
)

var _route_unlocked: bool = false
var _trial_started: bool = false
var _successful_parries: int = 0
var _gate_unlocked: bool = false
var _threshold_secured: bool = false
var _pulse_state: StringName = STATE_IDLE
var _pulse_remaining_sec: float = 0.0
var _pulse_resolved: bool = false
var _last_pulse_reflected: bool = false
var _player: Node2D = null
var _scene_owner: Object = null
var _start_count: int = 0
var _miss_count: int = 0
var _parry_feedback_count: int = 0
var _gate_unlock_feedback_count: int = 0
var _threshold_feedback_count: int = 0
var _audio_request_count: int = 0
var _last_parry_event: Dictionary = {}
var _last_miss_event: Dictionary = {}
var _last_emitted_objective_text: String = ""


func _ready() -> void:
	_ensure_pulse_animation()
	_connect_trial_zone()
	_sync_state()


func _process(delta: float) -> void:
	advance_time(delta)
	_sync_prompt_visibility()


## Injects the player and rooftop owner without adding another death controller.
func configure_runtime(player: Node2D, scene_owner: Object) -> bool:
	_disconnect_player_signal()
	_player = player
	_scene_owner = scene_owner
	_connect_player_signal()
	_connect_trial_zone()
	_sync_state()
	return _player != null and _scene_owner != null


## Story138 traversal is the bounded proof for every implemented prerequisite.
func set_route_unlocked(unlocked: bool) -> void:
	_route_unlocked = unlocked
	_sync_state()


## Supplies ExplorationGate's three-state ability query without auto-unlocking it.
func has_ability(ability_id: StringName) -> bool:
	return (
		_route_unlocked
		and _player != null
		and _player.has_method("has_ability")
		and bool(_player.call("has_ability", ability_id))
	)


## Starts the first telegraphed pulse for a nearby parry-capable provider.
func try_activate(provider: Node = null) -> bool:
	if (
		not _route_unlocked
		or _trial_started
		or _gate_unlocked
		or _laser_emitter == null
	):
		return false
	var activation_provider: Node = _player if provider == null else provider
	if (
		activation_provider != _player
		or not _provider_has_parry(activation_provider)
		or not _is_provider_near(
			_laser_emitter,
			activation_provider,
			ACTIVATION_RADIUS_PX
		)
	):
		return false
	_trial_started = true
	_start_count += 1
	_enter_telegraph()
	_persist_owner_state()
	return true


## Advances the deterministic telegraph, strike, and recovery state machine.
func advance_time(delta_sec: float) -> void:
	if not _trial_started or _gate_unlocked:
		return
	var remaining: float = maxf(0.0, delta_sec)
	var transitions: int = 0
	while remaining > 0.0 and transitions < 8 and not _gate_unlocked:
		if _pulse_state not in [STATE_TELEGRAPH, STATE_STRIKE, STATE_RECOVERY]:
			return
		if _pulse_remaining_sec > remaining:
			_pulse_remaining_sec -= remaining
			remaining = 0.0
			break
		remaining -= _pulse_remaining_sec
		_pulse_remaining_sec = 0.0
		transitions += 1
		match _pulse_state:
			STATE_TELEGRAPH:
				_enter_strike()
			STATE_STRIKE:
				if not _pulse_resolved:
					_resolve_missed_pulse()
				if not _gate_unlocked:
					_enter_recovery(false)
			STATE_RECOVERY:
				_enter_telegraph()
			_:
				return


## Secures the authored threshold after the outer laser gate is open.
func try_activate_threshold(provider: Node = null) -> bool:
	if not _gate_unlocked or _threshold_secured or _threshold == null:
		return false
	var activation_provider: Node = _player if provider == null else provider
	if not _is_provider_near(
		_threshold,
		activation_provider,
		THRESHOLD_RADIUS_PX
	):
		return false
	_threshold_secured = true
	_threshold_feedback_count += 1
	_sync_state()
	_persist_owner_state()
	return true


## Captures only durable Story139 progression.
func get_local_state() -> Dictionary:
	return {
		"neon_rooftops_central_tower_trial_started": _trial_started,
		"neon_rooftops_central_tower_parry_count": _successful_parries,
		"neon_rooftops_central_tower_gate_unlocked": _gate_unlocked,
		"neon_rooftops_central_tower_threshold_secured": _threshold_secured,
	}


## Restores durable state while resetting timers and one-shot evidence counts.
func set_local_state(state: Dictionary) -> void:
	_successful_parries = clampi(
		int(state.get("neon_rooftops_central_tower_parry_count", 0)),
		0,
		maxi(1, required_parries)
	)
	_gate_unlocked = bool(state.get(
		"neon_rooftops_central_tower_gate_unlocked",
		false
	)) or _successful_parries >= maxi(1, required_parries)
	_threshold_secured = bool(state.get(
		"neon_rooftops_central_tower_threshold_secured",
		false
	))
	if _threshold_secured:
		_gate_unlocked = true
		_successful_parries = maxi(1, required_parries)
	_trial_started = bool(state.get(
		"neon_rooftops_central_tower_trial_started",
		false
	)) or _successful_parries > 0 or _gate_unlocked
	_start_count = 0
	_miss_count = 0
	_parry_feedback_count = 0
	_gate_unlock_feedback_count = 0
	_threshold_feedback_count = 0
	_audio_request_count = 0
	_last_parry_event.clear()
	_last_miss_event.clear()
	_reset_runtime_pulse()
	if _trial_started and not _gate_unlocked:
		_enter_telegraph()
	elif _gate_unlocked:
		_set_pulse_state(STATE_COMPLETE, 0.0)
	_sync_state()


## Returns current objective text for the parent scene's priority router.
func get_objective_text() -> String:
	if _threshold_secured:
		return "Central Tower Gate Secured"
	if _gate_unlocked:
		return "Enter Central Tower Threshold"
	if _trial_started:
		return "Reflect Tower Laser %d/%d" % [
			_successful_parries,
			maxi(1, required_parries),
		]
	if _route_unlocked:
		return "Parry the Tower Laser"
	return "Secure Tower Approach"


## Claims the shared objective only while the player is in the tower approach.
func should_own_objective(provider: Node = null) -> bool:
	if not _route_unlocked:
		return false
	var objective_provider: Node = _player if provider == null else provider
	return (
		_trial_started
		or _gate_unlocked
		or (
			objective_provider is Node2D
			and (objective_provider as Node2D).global_position.x >= 3740.0
		)
	)


## Returns authored assets, timing, state, feedback, and collision diagnostics.
func get_diagnostics() -> Dictionary:
	return {
		"route_width_px": ROUTE_WIDTH_PX,
		"right_wall_x": RIGHT_WALL_X,
		"access_seal_x": ACCESS_SEAL_X,
		"laser_emitter_x": LASER_EMITTER_X,
		"tower_gate_x": TOWER_GATE_X,
		"threshold_x": THRESHOLD_X,
		"required_parries": maxi(1, required_parries),
		"miss_damage": maxi(0, miss_damage),
		"telegraph_duration_sec": maxf(0.01, telegraph_duration_sec),
		"strike_duration_sec": maxf(0.01, strike_duration_sec),
		"recovery_duration_sec": maxf(0.01, recovery_duration_sec),
		"controller_present": true,
		"controller_script_path": get_script().resource_path,
		"background_texture_path": _get_sprite_texture_path(_background),
		"gate_texture_path": _get_child_sprite_texture_path(
			_tower_gate,
			"Visual"
		),
		"pulse_texture_path": _get_sprite_texture_path(_pulse_visual),
		"pulse_sprite_frames_path": (
			_pulse_animation.sprite_frames.resource_path
			if _pulse_animation != null
			and _pulse_animation.sprite_frames != null
			else ""
		),
		"pulse_animation_name": (
			String(_pulse_animation.animation)
			if _pulse_animation != null
			else ""
		),
		"pulse_animation_frame": (
			_pulse_animation.frame if _pulse_animation != null else -1
		),
		"pulse_animation_frame_count": _get_pulse_animation_frame_count(),
		"pulse_animation_visible": (
			_pulse_animation.visible if _pulse_animation != null else false
		),
		"pulse_animation_playing": (
			_pulse_animation.is_playing()
			if _pulse_animation != null
			else false
		),
		"legacy_pulse_visible": (
			_pulse_visual.visible if _pulse_visual != null else false
		),
		"endpoint_texture_path": _get_child_sprite_texture_path(
			_threshold,
			"Visual"
		),
		"route_unlocked": _route_unlocked,
		"access_seal_blocking": _is_access_seal_blocking(),
		"trial_started": _trial_started,
		"pulse_state": String(_pulse_state),
		"pulse_remaining_sec": _pulse_remaining_sec,
		"successful_parries": _successful_parries,
		"miss_count": _miss_count,
		"gate_state": (
			String(_tower_gate.get_gate_state())
			if _tower_gate != null
			else ""
		),
		"gate_collision_blocking": (
			_tower_gate.is_collision_blocking()
			if _tower_gate != null
			else false
		),
		"gate_unlocked": _gate_unlocked,
		"threshold_secured": _threshold_secured,
		"objective_text": get_objective_text(),
		"start_count": _start_count,
		"parry_feedback_count": _parry_feedback_count,
		"gate_unlock_feedback_count": _gate_unlock_feedback_count,
		"threshold_feedback_count": _threshold_feedback_count,
		"audio_request_count": _audio_request_count,
		"last_parry_event": _last_parry_event.duplicate(true),
		"last_miss_event": _last_miss_event.duplicate(true),
		"gate_unlock_vfx": (
			_tower_gate.get_unlock_feedback_snapshot()
			if _tower_gate != null
			else {}
		),
	}


func _connect_player_signal() -> void:
	if _player == null or not _player.has_signal("ability_activated"):
		return
	var callback := Callable(self, "_on_player_ability_activated")
	if not _player.is_connected("ability_activated", callback):
		_player.connect("ability_activated", callback)


func _disconnect_player_signal() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var callback := Callable(self, "_on_player_ability_activated")
	if _player.has_signal("ability_activated") and _player.is_connected(
		"ability_activated",
		callback
	):
		_player.disconnect("ability_activated", callback)


func _connect_trial_zone() -> void:
	if _trial_zone != null and not _trial_zone.body_entered.is_connected(
		_on_trial_zone_body_entered
	):
		_trial_zone.body_entered.connect(_on_trial_zone_body_entered)
	if _threshold != null:
		var endpoint_area: Area2D = _threshold.get_node_or_null(
			"InteractionArea"
		) as Area2D
		if endpoint_area != null and not endpoint_area.body_entered.is_connected(
			_on_threshold_body_entered
		):
			endpoint_area.body_entered.connect(_on_threshold_body_entered)


func _on_trial_zone_body_entered(body: Node2D) -> void:
	try_activate(body)


func _on_threshold_body_entered(body: Node2D) -> void:
	try_activate_threshold(body)


func _on_player_ability_activated(ability_id: StringName) -> void:
	if (
		ability_id != PARRY_ABILITY_ID
		or _pulse_state != STATE_STRIKE
		or _pulse_resolved
		or not _is_player_in_strike_lane()
	):
		return
	_resolve_reflected_pulse()


func _resolve_reflected_pulse() -> void:
	_pulse_resolved = true
	_last_pulse_reflected = true
	_successful_parries = mini(
		_successful_parries + 1,
		maxi(1, required_parries)
	)
	_parry_feedback_count += 1
	_last_parry_event = {
		"ability_id": String(PARRY_ABILITY_ID),
		"parry_type": "perfect",
		"pulse_index": _successful_parries,
		"world_position": (
			_player.global_position if _player != null else Vector2.ZERO
		),
	}
	_request_parry_feedback()
	parry_reflected.emit(_successful_parries)
	if _successful_parries >= maxi(1, required_parries):
		_unlock_tower_gate()
	else:
		_enter_recovery(true)
	_persist_owner_state()


func _resolve_missed_pulse() -> void:
	_pulse_resolved = true
	_last_pulse_reflected = false
	if not _is_player_in_strike_lane():
		return
	_miss_count += 1
	_last_miss_event = {
		"damage": maxi(0, miss_damage),
		"source": "central_tower_laser_trial",
		"world_position": (
			_player.global_position if _player != null else Vector2.ZERO
		),
	}
	if (
		_player != null
		and _player.has_method("apply_damage")
		and maxi(0, miss_damage) > 0
	):
		_player.call("apply_damage", maxi(0, miss_damage), {
			"source": &"central_tower_laser_trial",
			"damage_type": &"laser",
			"scene_id": &"area_05_neon_rooftops",
		})


func _unlock_tower_gate() -> void:
	if _gate_unlocked:
		return
	_gate_unlocked = true
	_gate_unlock_feedback_count += 1
	_set_pulse_state(STATE_COMPLETE, 0.0)
	if _tower_gate != null:
		_tower_gate.unlock_gate(true)
	_request_gate_unlock_audio()
	_sync_state()


func _enter_telegraph() -> void:
	_pulse_resolved = false
	_last_pulse_reflected = false
	_set_pulse_state(
		STATE_TELEGRAPH,
		maxf(0.01, telegraph_duration_sec)
	)


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
	_notify_objective_changed()


func _reset_runtime_pulse() -> void:
	_pulse_state = STATE_IDLE
	_pulse_remaining_sec = 0.0
	_pulse_resolved = false
	_last_pulse_reflected = false


func _sync_state() -> void:
	_set_access_seal_blocking(not _route_unlocked)
	if _tower_gate != null:
		if _gate_unlocked:
			_tower_gate.set_gate_unlocked(true)
		elif _route_unlocked:
			_tower_gate.set_ability_provider(self)
			_tower_gate.set_gate_unlocked(false)
		else:
			_tower_gate.set_ability_provider(null)
			_tower_gate.set_gate_unlocked(false)
	if _threshold != null:
		_threshold.visible = _gate_unlocked
	if _trial_zone != null:
		_trial_zone.monitoring = _route_unlocked and not _gate_unlocked
		_trial_zone.monitorable = _route_unlocked and not _gate_unlocked
	_sync_pulse_visual()
	_sync_prompt_visibility()
	_notify_objective_changed()
	set_process(_route_unlocked and not _threshold_secured)


func _set_access_seal_blocking(blocking: bool) -> void:
	if _access_seal == null:
		return
	_access_seal.visible = blocking
	var shape: CollisionShape2D = _access_seal.get_node_or_null(
		"CollisionShape2D"
	) as CollisionShape2D
	if shape != null:
		shape.set_deferred("disabled", not blocking)


func _sync_pulse_visual() -> void:
	_ensure_pulse_animation()
	if _pulse_visual != null:
		_pulse_visual.visible = false
	if _pulse_animation == null:
		return
	var animation_name: StringName = &""
	match _pulse_state:
		STATE_TELEGRAPH:
			animation_name = &"telegraph"
		STATE_STRIKE:
			animation_name = &"strike"
		STATE_RECOVERY:
			animation_name = (
				&"recovery_reflected"
				if _last_pulse_reflected
				else &"recovery_missed"
			)
		_:
			_hide_pulse_animation()
			return
	_show_pulse_animation(animation_name)


func _ensure_pulse_animation() -> void:
	if _pulse_animation == null:
		_pulse_animation = get_node_or_null(
			"LaserPulseAnimation"
		) as AnimatedSprite2D
	if _pulse_animation == null:
		_pulse_animation = AnimatedSprite2D.new()
		_pulse_animation.name = "LaserPulseAnimation"
		if _pulse_visual != null:
			_pulse_animation.position = _pulse_visual.position
			_pulse_animation.rotation = _pulse_visual.rotation
			_pulse_animation.z_index = _pulse_visual.z_index
			_pulse_animation.texture_filter = _pulse_visual.texture_filter
			_pulse_animation.centered = _pulse_visual.centered
			_pulse_animation.offset = _pulse_visual.offset
		add_child(_pulse_animation)
	_pulse_animation.sprite_frames = PULSE_SPRITE_FRAMES
	_pulse_animation.modulate = Color.WHITE
	_pulse_animation.self_modulate = Color.WHITE
	_pulse_animation.scale = Vector2.ONE
	if _pulse_visual != null:
		_pulse_visual.visible = false


func _show_pulse_animation(animation_name: StringName) -> void:
	var should_restart: bool = (
		not _pulse_animation.visible
		or _pulse_animation.animation != animation_name
	)
	_pulse_animation.visible = true
	if should_restart:
		_pulse_animation.play(animation_name)


func _hide_pulse_animation() -> void:
	_pulse_animation.visible = false
	_pulse_animation.stop()
	_pulse_animation.frame = 0


func _get_pulse_animation_frame_count() -> int:
	if (
		_pulse_animation == null
		or _pulse_animation.sprite_frames == null
		or not _pulse_animation.sprite_frames.has_animation(
			_pulse_animation.animation
		)
	):
		return 0
	return _pulse_animation.sprite_frames.get_frame_count(
		_pulse_animation.animation
	)


func _sync_prompt_visibility() -> void:
	if _gate_prompt != null:
		_gate_prompt.text = (
			"Reflect Tower Laser %d/%d" % [
				_successful_parries,
				maxi(1, required_parries),
			]
			if _route_unlocked and not _gate_unlocked
			else ""
		)
		_gate_prompt.visible = (
			_route_unlocked
			and not _gate_unlocked
			and _is_provider_near(_tower_gate, _player, 420.0)
		)
	if _threshold_prompt != null:
		_threshold_prompt.text = "Secure Central Tower Gate"
		_threshold_prompt.visible = (
			_gate_unlocked
			and not _threshold_secured
			and _is_provider_near(_threshold, _player, 220.0)
		)


func _request_parry_feedback() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method("on_parry_event"):
		if bool(audio_system.call(
			"on_parry_event",
			_last_parry_event.duplicate(true)
		)):
			_audio_request_count += 1


func _request_gate_unlock_audio() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method(
		"on_exploration_gate_unlocked"
	):
		if bool(audio_system.call(
			"on_exploration_gate_unlocked",
			GATE_ID,
			PARRY_ABILITY_ID,
			TARGET_AREA_ID,
			_tower_gate.global_position if _tower_gate != null else Vector2.ZERO,
			{"source": &"neon_tower_parry_trial"}
		)):
			_audio_request_count += 1


func _persist_owner_state() -> void:
	if _scene_owner != null and _scene_owner.has_method(
		"persist_central_tower_parry_trial_progress"
	):
		_scene_owner.call("persist_central_tower_parry_trial_progress")


func _notify_objective_changed() -> void:
	var objective_text: String = get_objective_text()
	if objective_text == _last_emitted_objective_text:
		return
	_last_emitted_objective_text = objective_text
	objective_changed.emit(objective_text)


func _provider_has_parry(provider: Node) -> bool:
	return (
		provider != null
		and provider.has_method("has_ability")
		and bool(provider.call("has_ability", PARRY_ABILITY_ID))
	)


func _is_player_in_strike_lane() -> bool:
	return _is_provider_near(
		_pulse_visual,
		_player,
		STRIKE_EXPOSURE_RADIUS_PX
	)


func _is_provider_near(
	anchor: Node2D,
	provider: Node,
	radius_px: float
) -> bool:
	return (
		anchor != null
		and provider is Node2D
		and (provider as Node2D).global_position.distance_to(
			anchor.global_position
		) <= maxf(0.0, radius_px)
	)


func _is_access_seal_blocking() -> bool:
	if _access_seal == null:
		return false
	var shape: CollisionShape2D = _access_seal.get_node_or_null(
		"CollisionShape2D"
	) as CollisionShape2D
	return shape != null and not shape.disabled


func _get_sprite_texture_path(sprite: Sprite2D) -> String:
	if sprite == null or sprite.texture == null:
		return ""
	return sprite.texture.resource_path


func _get_child_sprite_texture_path(parent: Node, path: String) -> String:
	if parent == null:
		return ""
	return _get_sprite_texture_path(parent.get_node_or_null(path) as Sprite2D)
