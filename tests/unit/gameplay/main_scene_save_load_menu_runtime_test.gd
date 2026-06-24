## MainScene save/load menu shell runtime wiring tests.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")

var scene: Node2D


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)


func after_test() -> void:
	if scene != null and is_instance_valid(scene):
		if scene.get_tree() != null:
			scene.get_tree().paused = false
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_returning_from_pause_to_main_menu_releases_pause_state_and_focus() -> void:
	if scene == null:
		return
	var hud: Node = scene.get_node("HUD")
	assert_bool(hud.has_signal("menu_main_menu_requested")).is_true()
	assert_bool(hud.has_method("get_menu_button_texts")).is_true()
	if not hud.has_signal("menu_main_menu_requested") or not hud.has_method("get_menu_button_texts"):
		return

	hud.emit_signal("menu_pause_requested")

	assert_bool(scene.get_tree().paused).is_true()
	assert_str(String(hud.call("get_menu_mode"))).is_equal("pause")

	hud.emit_signal("menu_main_menu_requested")

	assert_bool(scene.get_tree().paused).is_false()
	assert_str(String(hud.call("get_menu_mode"))).is_equal("main_menu")
	assert_str(String(hud.call("get_focused_menu_button_text"))).is_equal("New Game")
	assert_array(Array(hud.call("get_menu_button_texts"))).is_equal([
		"New Game",
		"Continue",
		"Load Game",
		"Settings",
		"Exit",
	])
