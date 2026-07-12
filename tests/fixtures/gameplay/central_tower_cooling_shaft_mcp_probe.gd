extends Node

const CAPTURE_PATH: String = (
	"res://reports/visual/"
	+ "cinderpaw-mcp-central-tower-cooling-shaft-run68-20260712.png"
)

@onready var _tower: Node = get_node_or_null("CentralTowerThreshold")


func _ready() -> void:
	call_deferred("_prepare_probe")


func _prepare_probe() -> void:
	if _tower == null:
		push_error("story142_mcp_probe=tower_missing")
		return
	await get_tree().process_frame
	_tower.call("set_local_state", {
		"central_tower_threshold_roost_activated": true,
		"central_tower_threshold_guard_activated": true,
		"central_tower_threshold_guard_defeated": true,
		"central_tower_inner_relay_activated": true,
		"central_tower_inner_relay_parried": true,
		"central_tower_relay_mantis_activated": true,
		"central_tower_relay_mantis_defeated": true,
		"central_tower_inner_cache_claimed": false,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb", "parry",
		],
	})
	var player: CharacterBody2D = _tower.get_node_or_null(
		"Player"
	) as CharacterBody2D
	var roost: Node2D = _tower.get_node_or_null(
		"CoolingShaftController/CoolingShaftRoost"
	) as Node2D
	var controller: Node = _tower.get_node_or_null("CoolingShaftController")
	if player == null or roost == null or controller == null:
		push_error("story142_mcp_probe=runtime_nodes_missing")
		return
	player.global_position = roost.global_position
	_tower.call("try_activate_cooling_shaft_roost", player)
	player.global_position = Vector2(2920.0, 552.0)
	_tower.call("try_activate_cooling_shaft", player)
	_tower.call("advance_cooling_shaft_time", 0.76)
	_tower.call("advance_cooling_shaft_time", 0.51)
	var arc_hazard: Area2D = _tower.get_node_or_null(
		"CoolingShaftController/CoolingShaftArcHazard"
	) as Area2D
	if arc_hazard != null:
		arc_hazard.monitoring = false
	controller.set_process(false)
	player.global_position = Vector2(3225.0, 402.0)
	player.velocity = Vector2.ZERO
	print("story142_mcp_probe=ready")
	print(JSON.stringify(_tower.call(
		"get_central_tower_cooling_shaft_diagnostics"
	)))
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var capture: Image = get_viewport().get_texture().get_image()
	var capture_error: Error = capture.save_png(CAPTURE_PATH)
	print("story142_mcp_probe_capture=%s:%s" % [
		CAPTURE_PATH,
		error_string(capture_error),
	])
