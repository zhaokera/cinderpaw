## QA fixture that boots MainScene with Rat King arena VFX active.
extends Node2D

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const RAT_KING_BOSS_ID: StringName = &"boss_01_rat_king"

var main_scene: Node2D = null


func _ready() -> void:
	main_scene = MAIN_SCENE.instantiate() as Node2D
	add_child(main_scene)
	main_scene.call("apply_arena_changes", RAT_KING_BOSS_ID, 2, [{
		"id": "garbage_pile",
		"type": "obstacle",
	}])
	main_scene.call("apply_arena_changes", RAT_KING_BOSS_ID, 3, [{
		"id": "overturned_trash_can",
		"type": "obstacle",
	}, {
		"id": "electric_leak",
		"type": "damage_zone",
	}])
	var player := main_scene.get_node_or_null("Player") as Node2D
	if player != null:
		player.global_position = Vector2(900, 456)
		var camera := player.get_node_or_null("Camera2D") as Camera2D
		if camera != null:
			camera.position_smoothing_enabled = false
			camera.make_current()
