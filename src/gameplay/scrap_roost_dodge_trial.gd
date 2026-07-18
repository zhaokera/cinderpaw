## Third New Game onboarding room: cross an active exhaust with real dodge i-frames.
extends Node2D

const DODGE_TRIAL_SCENE_ID: StringName = &"area_01_scrap_roost_dodge_trial"
const NEXT_SCENE_ID: StringName = &"area_01_scrap_roost_rat_king_approach"
const NEXT_SPAWN_POINT: StringName = &"default"
const PLAYER_SPAWN_POSITION: Vector2 = Vector2(150.0, 456.0)
const FALL_RESET_Y: float = 780.0
const SAFE_FRAMES: int = 30
const WARNING_FRAMES: int = 24
const ACTIVE_FRAMES: int = 18
const RECOVERY_FRAMES: int = 30
const EXHAUST_DAMAGE: int = 8
const BODY_COLLISION_LAYER: int = 1
const HAZARD_HALF_WIDTH: float = 24.0

@export var auto_configure_runtime_services: bool = true

@onready var _player: PlayerController = $Player
@onready var _camera: Camera2D = $Player/Camera2D
@onready var _hazard: Area2D = $DodgeExhaust
@onready var _hazard_shape: CollisionShape2D = $DodgeExhaust/CollisionShape2D
@onready var _hud: HUDManager = $HUD
@onready var _combat_presentation: CombatPresentation = $CombatPresentation
@onready var _hitstop_input_bridge: HitstopInputBridge = $HitstopInputBridge
@onready var _gate_blocker_shape: CollisionShape2D = $ExitGateBlocker/CollisionShape2D
@onready var _exit_gate: Sprite2D = $ExitGate
@onready var _exit_pulse: Sprite2D = $ExitGate/ExitPulse

var _scene_manager: Object = null
var _hazard_phase: StringName = &"safe"
var _phase_frames_remaining: int = SAFE_FRAMES
var _active_sequence_id: int = 0
var _dodge_sequence_id: int = -1
var _last_damage_sequence_id: int = -1
var _trial_complete: bool = false
var _dodge_overlap_confirmed: bool = false
var _exit_unlocked: bool = false
var _transition_requested: bool = false
var _reset_pending: bool = false
var _elapsed_sec: float = 0.0
var _damage_events: int = 0


func _ready() -> void:
	_hazard.collision_mask |= BODY_COLLISION_LAYER
	_connect_runtime_signals()
	_combat_presentation.set_camera(_camera)
	_hitstop_input_bridge.configure(
		_combat_presentation,
		_player,
		get_node_or_null("/root/InputManager")
	)
	_hud.update_hp(_player.get_current_hp(), _player.get_max_hp())
	_hud.update_currency(0)
	_set_hazard_phase(&"safe")
	_sync_exit_gate()
	if auto_configure_runtime_services:
		configure_scene_manager_runtime(get_node_or_null("/root/SceneManager"))


func _physics_process(delta: float) -> void:
	_elapsed_sec += maxf(delta, 0.0)
	_update_exit_pulse()
	if _transition_requested or _reset_pending:
		return
	if _player.global_position.y > FALL_RESET_Y:
		_reset_attempt()
		return
	if not _trial_complete:
		_advance_hazard_cycle()
		_process_hazard_contact()


func configure_scene_manager_runtime(scene_manager: Object) -> bool:
	if not _is_valid_scene_manager(scene_manager):
		_scene_manager = null
		return false
	_scene_manager = scene_manager
	return true


func get_dodge_trial_diagnostics() -> Dictionary:
	var steam_animation := _hazard.get_node_or_null("SteamAnimation") as AnimatedSprite2D
	return {
		"scene_id": String(DODGE_TRIAL_SCENE_ID),
		"hazard_phase": String(_hazard_phase),
		"phase_frames_remaining": _phase_frames_remaining,
		"active_sequence_id": _active_sequence_id,
		"dodge_sequence_id": _dodge_sequence_id,
		"trial_complete": _trial_complete,
		"dodge_overlap_confirmed": _dodge_overlap_confirmed,
		"exit_unlocked": _exit_unlocked,
		"transition_requested": _transition_requested,
		"damage_events": _damage_events,
		"player_hp": _player.get_current_hp(),
		"player_position": _player.global_position,
		"player_dodge_iframe": _player.is_dodge_iframe_active(),
		"player_hurtbox_state": String(
			_player.get_collision_component().get_hurtbox_state()
		),
		"hazard_animation": String(steam_animation.animation) if steam_animation != null else "",
		"hazard_animation_playing": (
			steam_animation.is_playing() if steam_animation != null else false
		),
		"safe_frames": _get_hazard_animation_frame_count(&"safe"),
		"warning_frames": _get_hazard_animation_frame_count(&"warning"),
		"active_frames": _get_hazard_animation_frame_count(&"active"),
		"rat_king_present": find_child("*RatKing*", true, false) != null,
	}


func _connect_runtime_signals() -> void:
	_player.player_health_changed.connect(_on_player_health_changed)
	_player.player_died.connect(_on_player_died)
	_player.dodge_started.connect(_on_player_dodge_started)
	$ExitArea.body_entered.connect(_on_exit_area_body_entered)


func _advance_hazard_cycle() -> void:
	_phase_frames_remaining = maxi(_phase_frames_remaining - 1, 0)
	if _phase_frames_remaining > 0:
		return
	match _hazard_phase:
		&"safe":
			_set_hazard_phase(&"warning")
		&"warning":
			_active_sequence_id += 1
			_set_hazard_phase(&"active")
		&"active":
			_set_hazard_phase(&"recovery")
		_:
			_set_hazard_phase(&"safe")


func _set_hazard_phase(phase: StringName) -> void:
	_hazard_phase = phase
	match phase:
		&"safe":
			_phase_frames_remaining = SAFE_FRAMES
		&"warning":
			_phase_frames_remaining = WARNING_FRAMES
		&"active":
			_phase_frames_remaining = ACTIVE_FRAMES
		&"recovery":
			_phase_frames_remaining = RECOVERY_FRAMES
		_:
			_phase_frames_remaining = 0
	if _hazard.has_method("set_visual_phase"):
		_hazard.call("set_visual_phase", phase)


func _process_hazard_contact() -> void:
	if _hazard_phase != &"active" or not _is_player_overlapping_hazard():
		return
	var collision_component: CollisionComponent = _player.get_collision_component()
	var core_iframe_active: bool = _player.is_dodge_iframe_active()
	var hurtbox_gone: bool = (
		collision_component != null
		and collision_component.get_hurtbox_state() == CollisionComponent.HURTBOX_STATE_GONE
	)
	if (
		core_iframe_active
		and hurtbox_gone
		and _dodge_sequence_id == _active_sequence_id
		and _player.velocity.x > 0.0
	):
		_complete_dodge_trial()
		return
	if _last_damage_sequence_id == _active_sequence_id:
		return
	_last_damage_sequence_id = _active_sequence_id
	var damage_applied: int = _player.apply_damage(EXHAUST_DAMAGE, {
		"source": &"scrap_roost_dodge_exhaust",
		"hazard_id": &"scrap_roost_dodge_exhaust",
		"damage_type": &"environment",
		"hit_position": _hazard.global_position,
	})
	if damage_applied <= 0:
		return
	_damage_events += 1
	_combat_presentation.on_hit_event({
		"source": &"scrap_roost_dodge_exhaust",
		"damage": damage_applied,
		"final_damage": damage_applied,
		"hit_position": _player.global_position,
		"is_crit": false,
		"show_damage_number": true,
	})


func _on_player_dodge_started(
	texture: Texture2D,
	world_position: Vector2,
	facing: float
) -> void:
	_combat_presentation.on_dodge_event(texture, world_position, facing)
	var started_left_of_hazard: bool = (
		world_position.x < _hazard.global_position.x - HAZARD_HALF_WIDTH
	)
	if _hazard_phase == &"active" and started_left_of_hazard and facing > 0.0:
		_dodge_sequence_id = _active_sequence_id
	else:
		_dodge_sequence_id = -1


func _complete_dodge_trial() -> void:
	if _trial_complete:
		return
	_trial_complete = true
	_dodge_overlap_confirmed = true
	_exit_unlocked = true
	_set_hazard_phase(&"crossed")
	_hazard.set_deferred("monitoring", false)
	_hazard_shape.set_deferred("disabled", true)
	_sync_exit_gate()


func _is_player_overlapping_hazard() -> bool:
	for body: Node2D in _hazard.get_overlapping_bodies():
		if body == _player:
			return true
	for area: Area2D in _hazard.get_overlapping_areas():
		if _player.is_ancestor_of(area):
			return true
	return false


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	_hud.update_hp(current_hp, max_hp)


func _on_player_died(_metadata: Dictionary) -> void:
	if _reset_pending:
		return
	_reset_pending = true
	_player.set_control_locked(true)
	await get_tree().create_timer(0.7).timeout
	if is_inside_tree():
		_reset_attempt()


func _reset_attempt() -> void:
	_trial_complete = false
	_dodge_overlap_confirmed = false
	_exit_unlocked = false
	_transition_requested = false
	_active_sequence_id = 0
	_dodge_sequence_id = -1
	_last_damage_sequence_id = -1
	_damage_events = 0
	_player.respawn_at(PLAYER_SPAWN_POSITION, 1.0)
	_player.set_control_locked(false)
	_hazard.set_deferred("monitoring", true)
	_hazard_shape.set_deferred("disabled", false)
	_set_hazard_phase(&"safe")
	_reset_pending = false
	_sync_exit_gate()


func _on_exit_area_body_entered(body: Node2D) -> void:
	if body == _player and _exit_unlocked:
		_request_next_handoff()


func _request_next_handoff() -> bool:
	if _transition_requested or not _is_valid_scene_manager(_scene_manager):
		return false
	if not bool(_scene_manager.call("has_scene", NEXT_SCENE_ID)):
		return false
	var accepted: bool = bool(
		_scene_manager.call("request_scene_change", NEXT_SCENE_ID, NEXT_SPAWN_POINT)
	)
	_transition_requested = accepted
	if accepted:
		_player.set_control_locked(true)
	return accepted


func _sync_exit_gate() -> void:
	_gate_blocker_shape.set_deferred("disabled", _exit_unlocked)
	_exit_gate.visible = _exit_unlocked
	_exit_gate.modulate = Color(0.42, 0.92, 1.0, 0.28)
	_exit_pulse.visible = _exit_unlocked


func _update_exit_pulse() -> void:
	if not _exit_pulse.visible:
		return
	var pulse_alpha: float = 0.12 + 0.1 * (0.5 + 0.5 * sin(_elapsed_sec * 5.0))
	_exit_pulse.modulate.a = pulse_alpha


func _get_hazard_animation_frame_count(animation_name: StringName) -> int:
	if _hazard.has_method("get_visual_animation_frame_count"):
		return int(_hazard.call("get_visual_animation_frame_count", animation_name))
	return 0


func _is_valid_scene_manager(scene_manager: Object) -> bool:
	return (
		scene_manager != null
		and scene_manager.has_method("has_scene")
		and scene_manager.has_method("request_scene_change")
	)
