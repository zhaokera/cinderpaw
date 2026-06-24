## MainScene runtime wiring for SceneManager async transition UI.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")

var scene: Node2D


class FakeAsyncSceneManager:
	extends RefCounted

	signal on_scene_load_started(scene_id: StringName, spawn_point: StringName, metadata: Dictionary)
	signal on_scene_changed(old_scene: StringName, new_scene: StringName)
	signal on_scene_load_failed(scene_id: StringName, reason: StringName)

	var request_calls: Array[Dictionary] = []
	var change_calls: Array[Dictionary] = []
	var reject_requests: bool = false
	var locked: bool = false
	var known_scenes: Dictionary = {"main": true, "hub": true}

	func has_scene(scene_id: StringName) -> bool:
		return bool(known_scenes.get(String(scene_id), false))

	func get_scene_config(scene_id: StringName) -> Dictionary:
		return {
			"scene_id": String(scene_id),
			"default_spawn": "clan_base" if scene_id == &"hub" else "default",
			"display_name": "Scrap Alley" if scene_id == &"main" else "Clan Base",
		}

	func is_scene_locked() -> bool:
		return locked

	func request_scene_change(scene_id: StringName, spawn_point: StringName = &"default") -> bool:
		request_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		if reject_requests or locked or not has_scene(scene_id):
			return false
		on_scene_load_started.emit(scene_id, spawn_point, {
			"display_name": String(get_scene_config(scene_id).get("display_name", "")),
			"transition_duration_sec": 1.5,
		})
		return true

	func change_scene(scene_id: StringName, spawn_point: StringName = &"default") -> bool:
		change_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		return not reject_requests and not locked and has_scene(scene_id)

	func emit_changed(old_scene: StringName = &"hub", new_scene: StringName = &"main") -> void:
		on_scene_changed.emit(old_scene, new_scene)

	func emit_failed(scene_id: StringName = &"main", reason: StringName = &"timeout") -> void:
		on_scene_load_failed.emit(scene_id, reason)


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


func test_new_game_prefers_async_scene_request_and_shows_transition_shell() -> void:
	var scene_manager := FakeAsyncSceneManager.new()
	assert_bool(bool(scene.call("configure_scene_manager_runtime", scene_manager))).is_true()
	var hud: Node = scene.get_node("HUD")
	hud.call("show_main_menu", [])
	scene.get_tree().paused = true

	hud.emit_signal("menu_new_game_requested")

	assert_int(scene_manager.request_calls.size()).is_equal(1)
	assert_int(scene_manager.change_calls.size()).is_equal(0)
	assert_bool(hud.call("is_menu_visible")).is_false()
	assert_bool(bool(hud.call("is_scene_transition_visible"))).is_true()
	assert_str(String(hud.call("get_scene_transition_label_text"))).is_equal("Scrap Alley")
	assert_bool(scene.get_tree().paused).is_false()

	scene_manager.emit_changed()

	assert_bool(bool(hud.call("is_scene_transition_visible"))).is_false()


func test_async_scene_failure_hides_transition_and_reports_failure() -> void:
	var scene_manager := FakeAsyncSceneManager.new()
	assert_bool(bool(scene.call("configure_scene_manager_runtime", scene_manager))).is_true()
	var hud: Node = scene.get_node("HUD")
	hud.call("show_main_menu", [])

	hud.emit_signal("menu_new_game_requested")
	assert_bool(bool(hud.call("is_scene_transition_visible"))).is_true()

	scene_manager.emit_failed(&"main", &"timeout")

	assert_bool(bool(hud.call("is_scene_transition_visible"))).is_false()
	assert_str(String(hud.call("get_notification_text"))).is_equal("Load failed")
