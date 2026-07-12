extends Node

const CAPTURE_PATH: String = (
	"res://reports/visual/"
	+ "cinderpaw-mcp-central-tower-deep-lift-run69-20260712.png"
)
const PLATFORM_START: Vector2 = Vector2(4380.0, 590.0)

@export var probe_ready: bool = false
@export var probe_stage: String = "boot"
@export var platform_position: Vector2 = Vector2.ZERO
@export var player_position: Vector2 = Vector2.ZERO
@export var sentry_visible: bool = false
@export var sentry_animation: String = ""
@export var sentry_current_hp: int = 0
@export var sentry_max_hp: int = 0
@export var screenshot_saved: bool = false

@onready var _tower: Node = get_node_or_null("CentralTowerThreshold")

var _capture_rank: int = 0
var _capture_pending: bool = false


func _ready() -> void:
	call_deferred("_prepare_probe")


func _process(_delta: float) -> void:
	if not probe_ready or _tower == null:
		return
	var diagnostics: Dictionary = _tower.call(
		"get_central_tower_deep_lift_diagnostics"
	)
	platform_position = Vector2(diagnostics.get(
		"platform_position",
		Vector2.ZERO
	))
	player_position = Vector2(diagnostics.get(
		"player_position",
		Vector2.ZERO
	))
	sentry_visible = bool(diagnostics.get("sentry_visible", false))
	sentry_animation = String(diagnostics.get("sentry_animation", ""))
	sentry_current_hp = int(diagnostics.get("sentry_current_hp", 0))
	sentry_max_hp = int(diagnostics.get("sentry_max_hp", 0))
	probe_stage = String(diagnostics.get("phase", "unknown"))
	var rank: int = _animation_capture_rank(sentry_animation)
	if sentry_visible and rank > _capture_rank and not _capture_pending:
		_capture_rank = rank
		_capture_pending = true
		call_deferred("_capture_probe_frame")


func _prepare_probe() -> void:
	if _tower == null:
		push_error("story143_mcp_probe=tower_missing")
		return
	await get_tree().process_frame
	_tower.call("set_local_state", _story142_complete_state())
	var player: CharacterBody2D = _tower.get_node_or_null(
		"Player"
	) as CharacterBody2D
	if player == null:
		push_error("story143_mcp_probe=player_missing")
		return
	player.global_position = PLATFORM_START + Vector2(0.0, -38.0)
	player.velocity = Vector2.ZERO
	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
	if camera != null:
		camera.position_smoothing_enabled = false
	probe_ready = true
	probe_stage = "ready_for_interact"
	print("story143_mcp_probe=ready_for_interact")
	print(JSON.stringify(_tower.call(
		"get_central_tower_deep_lift_diagnostics"
	)))


func _capture_probe_frame() -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var capture: Image = get_viewport().get_texture().get_image()
	var capture_error: Error = capture.save_png(CAPTURE_PATH)
	screenshot_saved = capture_error == OK
	_capture_pending = false
	print("story143_mcp_probe_capture=%s:%s:%s" % [
		CAPTURE_PATH,
		error_string(capture_error),
		sentry_animation,
	])


func _animation_capture_rank(animation_name: String) -> int:
	match animation_name:
		"idle", "run":
			return 1
		"attack_tell", "attack":
			return 2
		"hurt", "death":
			return 3
	return 0


func _story142_complete_state() -> Dictionary:
	return {
		"central_tower_threshold_roost_activated": true,
		"central_tower_threshold_guard_activated": true,
		"central_tower_threshold_guard_defeated": true,
		"central_tower_inner_relay_activated": true,
		"central_tower_inner_relay_parried": true,
		"central_tower_relay_mantis_activated": true,
		"central_tower_relay_mantis_defeated": true,
		"central_tower_inner_cache_claimed": false,
		"central_tower_cooling_shaft_roost_activated": true,
		"central_tower_cooling_shaft_activated": true,
		"central_tower_cooling_shaft_traversed": true,
		"central_tower_cooling_shaft_last_savepoint": {
			"id": "central_tower_cooling_shaft_roost",
			"scene_id": "area_05_central_tower",
			"spawn_point": "cooling_shaft_roost",
			"position": {"x": 2740.0, "y": 552.0},
		},
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb", "parry",
		],
	}
