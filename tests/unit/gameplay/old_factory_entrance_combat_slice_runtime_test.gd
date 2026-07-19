## Player Abilities Story 007: Old Factory entrance combat slice runtime contract.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_SPAWN_POINT: StringName = &"factory_gate_entry"
const FACTORY_BACKDROP_PATH: String = (
	"res://assets/environment/old_factory_entrance_combat/old_factory_entrance_room_backdrop.png"
)
const FACTORY_ENEMY_NAME: String = "FactoryRatMinion"
const FACTORY_PLAYER_NAME: String = "Player"
const RUNTIME_SCENE_NAME: String = "FactoryRouteTransitionShellScene"
const SCENE_MANAGER_PATH: String = "res://src/feature/scene_manager.gd"
const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"
const RAT_MINION_SCRIPT_PATH: String = "res://src/gameplay/rat_minion.gd"
const REQUIRED_ENEMY_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack",
	&"hurt",
	&"death",
]
const MIN_FRAMES_PER_ANIMATION: int = 3
const THREAD_LOAD_LOADED: int = 3

var _spawned_nodes: Array[Node] = []
var _scene_manager_under_test: Node = null


class LoadedResourceAdapter:
	extends RefCounted

	var request_calls: Array[String] = []
	var resource_by_path: Dictionary = {}

	func load_threaded_request(
		path: String,
		_type_hint: String = "",
		_use_sub_threads: bool = false,
		_cache_mode: int = 1
	) -> int:
		request_calls.append(path)
		return OK

	func load_threaded_get_status(path: String, _progress: Array = []) -> int:
		if resource_by_path.has(path):
			return THREAD_LOAD_LOADED
		return 2

	func load_threaded_get(path: String) -> Resource:
		var resource: Variant = resource_by_path.get(path)
		if resource is Resource:
			return resource as Resource
		return null


func after_test() -> void:
	_stop_runtime_audio_players()
	if is_instance_valid(_scene_manager_under_test):
		if _scene_manager_under_test.has_method("get_previous_runtime_scene_node"):
			var previous: Node = _scene_manager_under_test.call("get_previous_runtime_scene_node") as Node
			if previous != null and is_instance_valid(previous) and previous.get_parent() == null:
				previous.free()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()
	_scene_manager_under_test = null


func test_factory_entrance_scene_contains_player_spawn_platforms_and_generated_background() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination is Node2D).is_true()
	assert_str(String(destination.get_meta("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_bool(FileAccess.file_exists(FACTORY_BACKDROP_PATH)).is_true()

	var spawn_marker: Marker2D = destination.get_node_or_null("FactoryGateEntrySpawn") as Marker2D
	assert_that(spawn_marker).is_not_null()
	var player: CharacterBody2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as CharacterBody2D
	assert_that(player).is_not_null()
	if player != null and spawn_marker != null:
		assert_bool(player.visible).is_true()
		assert_vector(player.global_position).is_equal(spawn_marker.global_position)

	var backdrop: TextureRect = destination.get_node_or_null("Background") as TextureRect
	assert_that(backdrop).is_not_null()
	if backdrop != null:
		assert_bool(backdrop.visible).is_true()
		assert_float(backdrop.size.x).is_greater_equal(1280.0)
		assert_float(backdrop.size.y).is_equal(720.0)
		assert_that(backdrop.texture).is_not_null()
		if backdrop.texture != null:
			assert_str(backdrop.texture.resource_path).is_equal(FACTORY_BACKDROP_PATH)

	assert_that(destination.get_node_or_null("Ground")).is_not_null()
	assert_that(destination.get_node_or_null("Ground/CollisionShape2D")).is_not_null()
	assert_that(destination.get_node_or_null("LeftWall/CollisionShape2D")).is_not_null()
	assert_that(destination.get_node_or_null("RightWall/CollisionShape2D")).is_not_null()
	assert_bool(_has_visible_color_rect(destination)).is_false()


func test_factory_entrance_contains_visible_animated_combat_object() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var enemy: Node = destination.get_node_or_null(FACTORY_ENEMY_NAME)
	assert_that(enemy).is_not_null()
	if enemy == null:
		return
	assert_bool(enemy.is_visible_in_tree()).is_true()
	assert_str(String(enemy.get_script().resource_path)).is_equal(RAT_MINION_SCRIPT_PATH)
	assert_bool(enemy.has_method("get_entity_id")).is_true()
	assert_bool(enemy.has_method("get_current_hp")).is_true()
	assert_bool(enemy.has_method("get_collision_component")).is_true()
	assert_bool(enemy.has_method("apply_damage")).is_true()

	var sprite: AnimatedSprite2D = enemy.get_node_or_null("Sprite") as AnimatedSprite2D
	assert_that(sprite).is_not_null()
	if sprite == null:
		return
	assert_bool(sprite.visible).is_true()
	assert_that(sprite.sprite_frames).is_not_null()
	if sprite.sprite_frames == null:
		return
	for animation_name: StringName in REQUIRED_ENEMY_ANIMATIONS:
		assert_bool(sprite.sprite_frames.has_animation(animation_name)).is_true()
		if not sprite.sprite_frames.has_animation(animation_name):
			continue
		assert_int(sprite.sprite_frames.get_frame_count(animation_name)).is_greater_equal(
			MIN_FRAMES_PER_ANIMATION
		)


func test_factory_entrance_player_attack_damages_room_combat_object() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node = destination.get_node_or_null(FACTORY_PLAYER_NAME)
	var enemy: Node = destination.get_node_or_null(FACTORY_ENEMY_NAME)
	assert_that(player).is_not_null()
	assert_that(enemy).is_not_null()
	if player == null or enemy == null:
		return
	assert_bool(player.has_method("request_attack")).is_true()
	assert_bool(player.has_method("get_combat_component")).is_true()
	assert_bool(player.has_method("get_collision_component")).is_true()
	assert_bool(enemy.has_method("get_collision_component")).is_true()
	assert_bool(enemy.has_method("get_current_hp")).is_true()
	assert_bool(destination.has_method("try_activate_factory_entry_guard")).is_true()
	var staging: Dictionary = destination.call("get_factory_arrival_staging_diagnostics")
	(player as Node2D).global_position.x = float(staging.get("entry_guard_activation_x", 0.0)) + 1.0
	assert_bool(bool(destination.call("try_activate_factory_entry_guard", player))).is_true()

	var enemy_start_hp: int = int(enemy.call("get_current_hp"))
	player.global_position = (enemy as Node2D).global_position + Vector2(-42, -26)
	assert_bool(bool(player.call("request_attack"))).is_true()
	var player_combat: CombatComponent = player.call(
		"get_combat_component"
	) as CombatComponent
	assert_that(player_combat).is_not_null()
	if player_combat == null:
		return
	player_combat.advance_attack_frames(4)
	var player_collision: Node = player.call("get_collision_component") as Node
	var enemy_collision: Node = enemy.call("get_collision_component") as Node
	assert_that(player_collision).is_not_null()
	assert_that(enemy_collision).is_not_null()
	if player_collision == null or enemy_collision == null:
		return
	player_collision.call("process_detection_frame", {
		&"cat_claw_light": [enemy_collision.call("get_hurtbox")],
	})

	assert_int(int(enemy.call("get_current_hp"))).is_less(enemy_start_hp)


func test_scene_manager_runtime_swap_reaches_old_factory_combat_slice() -> void:
	var scene_manager: Node = _new_scene_manager()
	var runtime_root := Node.new()
	runtime_root.name = "RuntimeRoot"
	add_child(runtime_root)
	_spawned_nodes.append(runtime_root)
	_spawned_nodes.append(scene_manager)

	var hub_scene := Node2D.new()
	hub_scene.name = "RuntimeHub"
	runtime_root.add_child(hub_scene)
	assert_bool(bool(scene_manager.call("configure_runtime_scene_root", runtime_root, hub_scene))).is_true()

	var loader := LoadedResourceAdapter.new()
	loader.resource_by_path[FACTORY_SCENE_PATH] = load(FACTORY_SCENE_PATH)
	scene_manager.call("set_loader_adapter", loader)

	assert_bool(bool(scene_manager.call(
		"request_scene_change",
		FACTORY_SCENE_ID,
		FACTORY_SPAWN_POINT
	))).is_true()
	scene_manager.call("advance_loading", 1.5)

	assert_str(String(scene_manager.call("get_current_scene"))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(scene_manager.call("get_current_spawn_point"))).is_equal(
		String(FACTORY_SPAWN_POINT)
	)
	var current_runtime: Node = scene_manager.call("get_current_runtime_scene_node") as Node
	assert_that(current_runtime).is_not_null()
	if current_runtime == null:
		return
	assert_str(current_runtime.name).is_equal(RUNTIME_SCENE_NAME)
	assert_str(String(current_runtime.get_meta("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_that(current_runtime.get_node_or_null("FactoryGateEntrySpawn")).is_not_null()
	assert_that(current_runtime.get_node_or_null(FACTORY_PLAYER_NAME)).is_not_null()
	assert_that(current_runtime.get_node_or_null(FACTORY_ENEMY_NAME)).is_not_null()
	assert_that(current_runtime.get_node_or_null("%s/Sprite" % FACTORY_ENEMY_NAME)).is_not_null()
	_free_detached_previous_runtime_scene(scene_manager)


func _instantiate_factory_scene() -> Node:
	assert_bool(FileAccess.file_exists(FACTORY_SCENE_PATH)).is_true()
	var packed: PackedScene = load(FACTORY_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var destination: Node = packed.instantiate()
	add_child(destination)
	_spawned_nodes.append(destination)
	return destination


func _new_scene_manager() -> Node:
	var scene_script: Script = load(SCENE_MANAGER_PATH)
	assert_that(scene_script).is_not_null()
	assert_bool(scene_script != null and scene_script.can_instantiate()).is_true()
	if scene_script == null or not scene_script.can_instantiate():
		return Node.new()
	var scene_manager: Node = scene_script.new()
	add_child(scene_manager)
	_scene_manager_under_test = scene_manager
	assert_bool(bool(scene_manager.call("configure_scene_registry", _factory_registry()))).is_true()
	return scene_manager


func _factory_registry() -> Dictionary:
	return {
		"hub": {
			"scene_id": "hub",
			"path": MAIN_SCENE_PATH,
			"type": "hub",
			"preload": true,
			"default_spawn": "clan_base",
		},
		"area_03_factory": {
			"scene_id": String(FACTORY_SCENE_ID),
			"path": FACTORY_SCENE_PATH,
			"type": "route_shell",
			"preload": false,
			"default_spawn": String(FACTORY_SPAWN_POINT),
			"display_name": "Factory Route",
		},
	}


func _has_visible_color_rect(root: Node) -> bool:
	if root is ColorRect and (root as ColorRect).visible:
		return true
	for child: Node in root.get_children():
		if _has_visible_color_rect(child):
			return true
	return false


func _free_detached_previous_runtime_scene(scene_manager: Node) -> void:
	if scene_manager == null or not scene_manager.has_method("get_previous_runtime_scene_node"):
		return
	var previous: Node = scene_manager.call("get_previous_runtime_scene_node") as Node
	if previous == null or not is_instance_valid(previous) or previous.get_parent() != null:
		return
	previous.free()


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var audio_player := child as AudioStreamPlayer
			audio_player.stop()
			audio_player.stream = null
		if child is AudioStreamPlayer2D:
			var spatial_player := child as AudioStreamPlayer2D
			spatial_player.stop()
			spatial_player.stream = null
