## QA fixture that parks Story141 in its live relay strike window.
extends Node2D

const TOWER_SCENE: PackedScene = preload(
	"res://scenes/areas/central_tower_threshold.tscn"
)

var tower: Node2D = null


func _ready() -> void:
	tower = TOWER_SCENE.instantiate() as Node2D
	add_child(tower)
	tower.call("set_local_state", {
		"central_tower_threshold_roost_activated": true,
		"central_tower_threshold_guard_activated": true,
		"central_tower_threshold_guard_defeated": true,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb", "parry",
		],
	})
	var player: CharacterBody2D = tower.get_node_or_null(
		"Player"
	) as CharacterBody2D
	if player == null:
		return
	player.global_position = Vector2(1500.0, 552.0)
	tower.call("try_activate_inner_relay", player)
	player.global_position = Vector2(1800.0, 552.0)
	tower.call("advance_inner_relay_time", 0.56)
	var relay_controller: Node = tower.get_node_or_null("InnerRelayController")
	if relay_controller != null:
		relay_controller.set_process(false)
	var camera: Camera2D = player.get_node_or_null("Camera2D") as Camera2D
	if camera != null:
		camera.position_smoothing_enabled = false
		camera.make_current()
