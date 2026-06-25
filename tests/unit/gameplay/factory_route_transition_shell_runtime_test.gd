## High-platform factory route transition shell runtime contract.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_SPAWN_POINT: StringName = &"factory_gate_entry"
const FACTORY_DISPLAY_NAME: String = "Factory Route"
const DOUBLE_JUMP_ABILITY: StringName = &"double_jump"
const HIGH_PLATFORM_GATE_ID: StringName = &"double_jump_high_platform"
const FACTORY_ROUTE_TRIGGER_NAME: String = "FactoryRouteTransitionShell"
const FACTORY_ROUTE_TEXTURE_PATH: String = "res://assets/environment/factory_route_transition/factory_route_transition_shell.png"
const STATE_UNLOCKED: StringName = &"unlocked"

var scene: Node2D


class FakeFactorySceneManager:
	extends RefCounted

	signal on_scene_load_started(scene_id: StringName, spawn_point: StringName, metadata: Dictionary)
	signal on_scene_changed(old_scene: StringName, new_scene: StringName)
	signal on_scene_load_failed(scene_id: StringName, reason: StringName)

	var request_calls: Array[Dictionary] = []
	var loading: bool = false
	var current_scene: StringName = &"main"
	var runtime_root_configured: bool = false
	var runtime_scene_root: Node = null
	var current_scene_node: Node = null
	var known_scenes: Dictionary = {
		"main": true,
		"area_03_factory": true,
	}

	func has_scene(scene_id: StringName) -> bool:
		return bool(known_scenes.get(String(scene_id), false))

	func get_scene_config(scene_id: StringName) -> Dictionary:
		if scene_id == FACTORY_SCENE_ID:
			return {
				"scene_id": String(FACTORY_SCENE_ID),
				"default_spawn": String(FACTORY_SPAWN_POINT),
				"display_name": FACTORY_DISPLAY_NAME,
			}
		return {
			"scene_id": String(scene_id),
			"default_spawn": "default",
			"display_name": "Scrap Alley",
		}

	func get_current_scene() -> StringName:
		return current_scene

	func is_runtime_scene_swap_enabled() -> bool:
		return runtime_root_configured

	func configure_runtime_scene_root(root: Node, current_scene: Node = null) -> bool:
		runtime_root_configured = root != null and current_scene != null
		runtime_scene_root = root
		current_scene_node = current_scene
		return runtime_root_configured

	func request_scene_change(scene_id: StringName, spawn_point: StringName = &"default") -> bool:
		request_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		if loading or not has_scene(scene_id):
			return false
		loading = true
		var metadata: Dictionary = get_scene_config(scene_id)
		metadata["transition_duration_sec"] = 1.5
		on_scene_load_started.emit(scene_id, spawn_point, metadata)
		return true


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_scene_registry_contains_loadable_factory_route_shell() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/scene_registry.json"))
	assert_bool(parsed is Dictionary).is_true()
	if not parsed is Dictionary:
		return
	var registry: Dictionary = Dictionary(parsed)
	var entries: Dictionary = Dictionary(registry.get("entries", {}))
	assert_bool(entries.has(String(FACTORY_SCENE_ID))).is_true()
	if not entries.has(String(FACTORY_SCENE_ID)):
		return
	var config: Dictionary = Dictionary(entries[String(FACTORY_SCENE_ID)])

	assert_str(String(config.get("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(config.get("path", ""))).is_equal(FACTORY_SCENE_PATH)
	assert_str(String(config.get("type", ""))).is_equal("route_shell")
	assert_bool(bool(config.get("preload", true))).is_false()
	assert_str(String(config.get("default_spawn", ""))).is_equal(String(FACTORY_SPAWN_POINT))
	assert_str(String(config.get("display_name", ""))).is_equal(FACTORY_DISPLAY_NAME)
	assert_bool(FileAccess.file_exists(FACTORY_SCENE_PATH)).is_true()
	assert_bool(load(FACTORY_SCENE_PATH) is PackedScene).is_true()


func test_high_platform_route_trigger_requests_factory_shell_after_gate_unlocked() -> void:
	var scene_manager := FakeFactorySceneManager.new()
	assert_bool(bool(scene.call("configure_scene_manager_runtime", scene_manager))).is_true()
	var route_shell: Node = _get_route_shell(scene)
	assert_that(route_shell).is_not_null()
	if route_shell == null:
		return
	assert_bool(bool(route_shell.call("is_route_available"))).is_false()
	assert_bool(bool(scene.call("request_factory_route_transition", scene.get_node("Player")))).is_false()
	assert_array(scene_manager.request_calls).is_empty()

	scene.call("unlock_ability", DOUBLE_JUMP_ABILITY)
	assert_bool(bool(route_shell.call("is_route_available"))).is_false()
	assert_array(scene_manager.request_calls).is_empty()

	var gate: Node = scene.get_node("DoubleJumpExplorationGate")
	var player := scene.get_node("Player") as PlayerController
	player.global_position = (gate as Node2D).global_position + Vector2(-48, 0)
	player.call("set_airborne", true)
	assert_bool(bool(player.call("request_double_jump"))).is_true()
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKED))
	assert_bool(bool(route_shell.call("is_route_available"))).is_true()

	player.global_position = (route_shell as Node2D).global_position
	assert_bool(bool(scene.call("request_factory_route_transition", player))).is_true()
	assert_bool(scene_manager.runtime_root_configured).is_true()
	assert_that(scene_manager.current_scene_node).is_same(scene)
	assert_int(scene_manager.request_calls.size()).is_equal(1)
	assert_str(String(scene_manager.request_calls[0].get("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(scene_manager.request_calls[0].get("spawn_point", ""))).is_equal(String(FACTORY_SPAWN_POINT))
	var hud: Node = scene.get_node("HUD")
	assert_bool(bool(hud.call("is_scene_transition_visible"))).is_true()
	assert_str(String(hud.call("get_scene_transition_label_text"))).is_equal(FACTORY_DISPLAY_NAME)

	assert_bool(bool(scene.call("request_factory_route_transition", player))).is_false()
	assert_int(scene_manager.request_calls.size()).is_equal(1)


func test_factory_route_shell_scene_is_minimal_visible_destination() -> void:
	assert_bool(FileAccess.file_exists(FACTORY_SCENE_PATH)).is_true()
	var packed: PackedScene = load(FACTORY_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return
	var destination: Node = packed.instantiate()
	add_child(destination)

	assert_bool(destination is Node2D).is_true()
	assert_str(String(destination.get_meta("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	var spawn_marker: Node = destination.get_node_or_null("FactoryGateEntrySpawn")
	assert_that(spawn_marker).is_not_null()
	assert_bool(spawn_marker is Marker2D).is_true()
	var visual: Sprite2D = destination.get_node_or_null("RouteShellVisual") as Sprite2D
	assert_that(visual).is_not_null()
	if visual != null:
		assert_bool(visual.visible).is_true()
		assert_that(visual.texture).is_not_null()
		if visual.texture != null:
			assert_str(visual.texture.resource_path).is_equal(FACTORY_ROUTE_TEXTURE_PATH)
	assert_bool(destination.find_child("*ColorRect*", true, false) == null).is_true()

	destination.queue_free()


func _get_route_shell(target_scene: Node) -> Node:
	return target_scene.get_node_or_null(FACTORY_ROUTE_TRIGGER_NAME)
