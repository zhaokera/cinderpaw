extends Node

const CAPTURE_PATH: String = (
	"res://reports/visual/"
	+ "cinderpaw-mcp-central-tower-apex-purge-run75-20260712.png"
)
const ROOST_SPAWN: Vector2 = Vector2(5260.0, 252.0)

@export var probe_ready: bool = false
@export var probe_stage: String = "boot"
@export var player_position: Vector2 = Vector2.ZERO
@export var roost_activated: bool = false
@export var attempt_triggered: bool = false
@export var purge_active: bool = false
@export var purge_position: Vector2 = Vector2.ZERO
@export var approach_secured: bool = false
@export var objective_text: String = ""
@export var player_animation: String = ""
@export var player_animation_frame: int = 0
@export var screenshot_saved: bool = false

@onready var _tower: Node = get_node_or_null("CentralTowerThreshold")

var _capture_requested: bool = false


func _ready() -> void:
	call_deferred("_prepare_probe")


func _process(_delta: float) -> void:
	if not probe_ready or _tower == null:
		return
	var diagnostics: Dictionary = _tower.call(
		"get_central_tower_apex_diagnostics"
	)
	player_position = Vector2(diagnostics.get("player_position", Vector2.ZERO))
	roost_activated = bool(diagnostics.get("roost_activated", false))
	attempt_triggered = bool(diagnostics.get("attempt_triggered", false))
	purge_active = bool(diagnostics.get("purge_active", false))
	purge_position = Vector2(diagnostics.get("purge_position", Vector2.ZERO))
	approach_secured = bool(diagnostics.get("approach_secured", false))
	objective_text = String(diagnostics.get("objective_text", ""))
	probe_stage = String(diagnostics.get("phase", "unknown"))
	var player: Node = _tower.get_node_or_null("Player")
	var sprite: AnimatedSprite2D = (
		player.get_node_or_null("Sprite") as AnimatedSprite2D
		if player != null
		else null
	)
	if sprite != null:
		player_animation = String(sprite.animation)
		player_animation_frame = sprite.frame
	if attempt_triggered and not _capture_requested:
		_capture_requested = true
		call_deferred("_capture_probe_frame")


func _prepare_probe() -> void:
	if _tower == null:
		push_error("story144_mcp_probe=tower_missing")
		return
	await get_tree().process_frame
	_tower.call("set_local_state", _story143_complete_state())
	var player: CharacterBody2D = _tower.get_node_or_null(
		"Player"
	) as CharacterBody2D
	if player == null:
		push_error("story144_mcp_probe=player_missing")
		return
	player.global_position = ROOST_SPAWN
	player.velocity = Vector2.ZERO
	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
	if camera != null:
		camera.position_smoothing_enabled = false
	probe_ready = true
	probe_stage = "ready_for_roost"
	print("story144_mcp_probe=ready_for_roost")
	print(JSON.stringify(_tower.call(
		"get_central_tower_apex_diagnostics"
	)))


func _capture_probe_frame() -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var capture: Image = get_viewport().get_texture().get_image()
	var capture_error: Error = capture.save_png(CAPTURE_PATH)
	screenshot_saved = capture_error == OK
	print("story144_mcp_probe_capture=%s:%s:%s" % [
		CAPTURE_PATH,
		error_string(capture_error),
		probe_stage,
	])


func _story143_complete_state() -> Dictionary:
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
		"central_tower_counterweight_sentry_defeated": true,
		"central_tower_deep_lift_ascended": true,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb", "parry",
		],
	}
