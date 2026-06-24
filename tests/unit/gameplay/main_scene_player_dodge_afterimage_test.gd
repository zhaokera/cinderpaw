## Story 004: MainScene routes player dodge-start feedback to CombatPresentation.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")

var scene


func before_test() -> void:
	scene = MAIN_SCENE.instantiate()
	add_child(scene)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_player_dodge_spawns_three_presentation_afterimages_in_main_scene() -> void:
	var player = scene.get_node("Player")
	var combat_presentation = scene.get_node("CombatPresentation")

	assert_bool(player.has_method("request_dodge")).is_true()
	assert_bool(combat_presentation.has_method("get_active_afterimage_count")).is_true()
	assert_bool(combat_presentation.has_method("get_last_afterimage_alphas")).is_true()
	if (
		not player.has_method("request_dodge")
		or not combat_presentation.has_method("get_active_afterimage_count")
		or not combat_presentation.has_method("get_last_afterimage_alphas")
	):
		return

	assert_bool(player.request_dodge()).is_true()

	assert_int(combat_presentation.get_active_afterimage_count()).is_equal(3)
	assert_array(combat_presentation.get_last_afterimage_alphas()).is_equal([
		0.5,
		0.3,
		0.1,
	])
	assert_vector(combat_presentation.get_last_afterimage_positions()[0]).is_equal(
		player.get_node("Sprite").global_position
	)
