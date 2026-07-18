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

@export var auto_configure_runtime_services: bool = true

@onready var _player: PlayerController = $Player
@onready var _camera: Camera2D = $Player/Camera2D
@onready var _hazard: Area2D = $SewerExhaustHazard
@onready var _hazard_shape: CollisionShape2D = $SewerExhaustHazard/CollisionShape2D
@onready var _hazard_animation: AnimatedSprite2D = (
	$SewerExhaustHazard/SteamAnimation as AnimatedSprite2D
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


func _ready() -> void:
	process_physics_priority = 100
	_connect_runtime_signals()
	_combat_presentation.set_camera(_camera)
	_hitstop_input_bridge.configure(
		_combat_presentation,
		_player,
		get_node_or_null("/root/InputManager")
	)
	_hud.update_hp(_player.get_current_hp(), _player.get_max_hp())
	_hud.update_currency(0)
	_sync_hazard_state()
	if auto_configure_runtime_services:
		configure_scene_manager_runtime(get_node_or_null("/root/SceneManager"))


func _exit_tree() -> void:
	_disconnect_scene_manager_signal()


func _physics_process(_delta: float) -> void:
	if _transition_requested or _reset_pending:
		return
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
	}


func set_local_state(state: Dictionary) -> void:
	_transition_requested = false
	_transition_request_count = 0
	_dash_crossing_active = false
	_dash_proof_frames_remaining = 0
	_restore_player_unlocked_abilities(state)
	_dash_crossed = bool(state.get("dash_crossed", false))
	_successful_dash_crossings = maxi(
		0,
		int(state.get("successful_dash_crossings", 1 if _dash_crossed else 0))
	)
	_reset_count = maxi(0, int(state.get("reset_count", 0)))
	_last_reset_reason = StringName(String(state.get("last_reset_reason", "")))
	_sync_hazard_state()
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


func _connect_runtime_signals() -> void:
	_player.player_health_changed.connect(_on_player_health_changed)
	_player.dash_started.connect(_on_player_dash_started)
	$SewerExhaustHazard.body_entered.connect(_on_hazard_body_entered)
	$FallZone.body_entered.connect(_on_fall_zone_body_entered)
	$ExitArea.body_entered.connect(_on_exit_area_body_entered)


func _on_player_health_changed(current_hp: int, max_hp: int) -> void:
	_hud.update_hp(current_hp, max_hp)


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


func _on_hazard_body_entered(body: Node2D) -> void:
	if body != _player or _transition_requested or _dash_crossed:
		return
	if _dash_crossing_active:
		return
	_queue_reset(&"exhaust")


func _on_fall_zone_body_entered(body: Node2D) -> void:
	if body == _player and not _transition_requested:
		_queue_reset(&"fall")


func _on_exit_area_body_entered(body: Node2D) -> void:
	if body == _player and _dash_crossed:
		_request_main_return()


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
	var respawn_position: Vector2 = (
		RIGHT_RESPAWN_POSITION if _dash_crossed else ENTRY_SPAWN_POSITION
	)
	_player.respawn_at(respawn_position, 1.0)
	_player.set_control_locked(false)
	_reset_pending = false


func _request_main_return() -> bool:
	if _transition_requested or not _is_valid_scene_manager(_scene_manager):
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
	var world_flags: Dictionary = Dictionary(main_state.get("world_flags", {})).duplicate(true)
	world_flags[SEWER_UNLOCKED_FLAG] = true
	world_flags[DASH_ROUTE_CROSSED_FLAG] = true
	main_state["world_flags"] = world_flags
	_scene_manager.call("set_scene_state", MAIN_SCENE_ID, main_state)


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
