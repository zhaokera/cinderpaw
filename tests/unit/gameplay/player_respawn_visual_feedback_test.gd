## Story 002: Player respawn invincibility visual feedback.
extends GdUnitTestSuite

const GAME_FLOW_SCRIPT: Script = preload("res://src/gameplay/game_flow_controller.gd")
const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")

var player: PlayerController
var flow: GameFlowController


func before_test() -> void:
	player = PLAYER_SCENE.instantiate() as PlayerController
	add_child(player)
	flow = GAME_FLOW_SCRIPT.new()
	add_child(flow)


func after_test() -> void:
	if is_instance_valid(flow):
		if flow.get_parent() != null:
			flow.get_parent().remove_child(flow)
		flow.free()
	if is_instance_valid(player):
		if player.get_parent() != null:
			player.get_parent().remove_child(player)
		player.free()
	flow = null
	player = null


func test_respawn_starts_visible_transparent_flash_for_invincibility_window() -> void:
	player.respawn_at(Vector2(32, 48), 0.5)

	var sprite := player.get_node("Sprite") as Sprite2D

	assert_bool(player.is_respawn_visual_active()).is_true()
	assert_int(player.get_respawn_visual_remaining_frames()).is_equal(120)
	assert_bool(sprite.modulate.a < 1.0).is_true()


func test_respawn_visual_stops_when_game_flow_unlocks() -> void:
	flow.start_encounter(Vector2(32, 48))
	flow.handle_player_death()
	flow.advance_time(1.51)
	player.respawn_at(Vector2(32, 48), 0.5)

	_advance_player_frames(119)

	assert_bool(player.is_respawn_visual_active()).is_true()
	assert_bool(flow.is_player_control_locked()).is_true()

	_advance_player_frames(1)
	flow.advance_time(2.0)

	var sprite := player.get_node("Sprite") as Sprite2D
	assert_bool(player.is_respawn_visual_active()).is_false()
	assert_bool(flow.is_player_control_locked()).is_false()
	assert_float(sprite.modulate.a).is_equal_approx(1.0, 0.001)


func test_respawn_visual_does_not_override_damage_color_after_window() -> void:
	player.respawn_at(Vector2(32, 48), 0.5)
	_advance_player_frames(120)

	player.take_damage()
	player.call("_physics_process", 1.0 / 60.0)

	var sprite := player.get_node("Sprite") as Sprite2D
	assert_str(sprite.modulate.to_html(false)).is_equal("ff4040")


func _advance_player_frames(frame_count: int) -> void:
	for _frame_index: int in range(frame_count):
		player.call("_physics_process", 1.0 / 60.0)
