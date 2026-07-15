## Player Abilities Story145: Crown Warden arena handoff.
extends GdUnitTestSuite

const TOWER_SCENE_PATH: String = (
	"res://scenes/areas/central_tower_threshold.tscn"
)
const ARENA_SCENE_PATH: String = (
	"res://scenes/bosses/crown_warden_arena.tscn"
)
const ARENA_SCRIPT_PATH: String = (
	"res://src/gameplay/crown_warden_arena.gd"
)
const ARENA_BACKGROUND_PATH: String = (
	"res://assets/environment/crown_warden_arena/"
	+ "env_crown_warden_observatory_1280x720.png"
)
const CROWN_GATE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_crown_gate_256x384.png"
)
const BACKGROUND_SOURCE_PATH: String = (
	"res://assets/generated/source/"
	+ "crown_warden_observatory_background_imagegen_20260712.png"
)
const BACKGROUND_PROMPT_PATH: String = (
	"res://assets/generated/source/"
	+ "crown_warden_observatory_background_imagegen_20260712.prompt.md"
)
const GATE_SOURCE_PATH: String = (
	"res://assets/generated/source/"
	+ "central_tower_crown_gate_imagegen_20260712.png"
)
const GATE_ALPHA_PATH: String = (
	"res://assets/generated/source/"
	+ "central_tower_crown_gate_alpha_20260712.png"
)
const GATE_PROMPT_PATH: String = (
	"res://assets/generated/source/"
	+ "central_tower_crown_gate_imagegen_20260712.prompt.md"
)
const REGISTRY_PATH: String = "res://data/scene_registry.json"
const REGISTRY_SCHEMA_PATH: String = (
	"res://data/schemas/scene_registry.schema.json"
)
const TARGET_SCENE_ID: StringName = &"boss_04_crown_warden_arena"
const TARGET_SPAWN_POINT: StringName = &"boss_entry"
const TOWER_SCENE_ID: StringName = &"area_05_central_tower"
const TOWER_RETURN_SPAWN: StringName = &"apex_approach_return"
const TOWER_RETURN_POSITION: Vector2 = Vector2(6200.0, 296.0)
const TOWER_ROUTE_NODE: String = "CrownWardenArenaRoute"
const TOWER_RETURN_NODE: String = "ApexApproachReturnSpawn"
const ARENA_RETURN_NODE: String = "CentralTowerReturnRoute"

var _spawned_nodes: Array[Node] = []


class FakeCrownSceneManager:
	extends RefCounted

	signal on_scene_load_failed(scene_id: StringName, reason: StringName)

	var request_calls: Array[Dictionary] = []
	var scene_states: Dictionary = {}
	var loading: bool = false
	var locked: bool = false
	var accept_requests: bool = true
	var current_scene: StringName = TOWER_SCENE_ID
	var current_spawn: StringName = &"neon_rooftops_threshold_arrival"
	var runtime_root_configured: bool = false
	var known_scenes: Dictionary = {
		String(TOWER_SCENE_ID): true,
		"area_05_neon_rooftops": true,
		String(TARGET_SCENE_ID): true,
	}

	func has_scene(scene_id: StringName) -> bool:
		return bool(known_scenes.get(String(scene_id), false))

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn

	func is_loading() -> bool:
		return loading

	func is_scene_locked() -> bool:
		return locked

	func is_runtime_scene_swap_enabled() -> bool:
		return runtime_root_configured

	func configure_runtime_scene_root(
		_root: Node,
		_current_scene_node: Node = null
	) -> bool:
		runtime_root_configured = true
		return true

	func set_scene_state(scene_id: StringName, state: Dictionary) -> bool:
		scene_states[String(scene_id)] = state.duplicate(true)
		return true

	func get_scene_state(scene_id: StringName) -> Dictionary:
		return Dictionary(scene_states.get(String(scene_id), {})).duplicate(true)

	func get_pending_scene() -> StringName:
		if request_calls.is_empty():
			return &""
		return StringName(String(request_calls[-1].get("scene_id", "")))

	func get_pending_spawn_point() -> StringName:
		if request_calls.is_empty():
			return &""
		return StringName(String(request_calls[-1].get("spawn_point", "")))

	func request_scene_change(
		scene_id: StringName,
		spawn_point: StringName = &"default"
	) -> bool:
		if loading or locked or not accept_requests or not has_scene(scene_id):
			return false
		request_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		loading = true
		return true

	func reset_for_scene(
		scene_id: StringName,
		spawn_point: StringName
	) -> void:
		request_calls.clear()
		loading = false
		locked = false
		accept_requests = true
		current_scene = scene_id
		current_spawn = spawn_point


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_registry_authored_arena_and_generated_art_contract() -> void:
	var missing: Array[String] = []
	for path: String in [
		ARENA_SCENE_PATH,
		ARENA_SCRIPT_PATH,
		ARENA_BACKGROUND_PATH,
		CROWN_GATE_PATH,
		BACKGROUND_SOURCE_PATH,
		BACKGROUND_PROMPT_PATH,
		GATE_SOURCE_PATH,
		GATE_ALPHA_PATH,
		GATE_PROMPT_PATH,
	]:
		if not FileAccess.file_exists(path):
			missing.append(path)
	assert_array(missing).override_failure_message(
		"Story145 authored files are missing: %s" % ", ".join(missing)
	).is_empty()

	var registry: Dictionary = _read_json_dictionary(REGISTRY_PATH)
	var entries: Dictionary = Dictionary(registry.get("entries", {}))
	assert_bool(entries.has(String(TARGET_SCENE_ID))).is_true()
	var entry: Dictionary = Dictionary(entries.get(String(TARGET_SCENE_ID), {}))
	assert_str(String(entry.get("path", ""))).is_equal(ARENA_SCENE_PATH)
	assert_str(String(entry.get("type", ""))).is_equal("boss_arena")
	assert_bool(bool(entry.get("preload", true))).is_false()
	assert_str(String(entry.get("default_spawn", ""))).is_equal(
		String(TARGET_SPAWN_POINT)
	)
	assert_str(String(entry.get("display_name", ""))).is_equal(
		"Crown Observatory"
	)
	var schema: Dictionary = _read_json_dictionary(REGISTRY_SCHEMA_PATH)
	assert_bool(Dictionary(schema.get("entries", {})).has(
		String(TARGET_SCENE_ID)
	)).is_true()
	if not missing.is_empty() or not FileAccess.file_exists(ARENA_SCENE_PATH):
		return

	_assert_png(ARENA_BACKGROUND_PATH, Vector2i(1280, 720), false)
	_assert_png(CROWN_GATE_PATH, Vector2i(256, 384), true)
	var arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(arena).is_not_null()
	if arena == null:
		return
	for node_path: String in [
		"Background",
		"Ground",
		"LeftWall",
		"RightWall",
		"BossEntrySpawn",
		"Player",
		"Player/Camera2D",
		"CrownWardenBoss",
		"HUD",
		ARENA_RETURN_NODE,
		"ArenaObjectiveLabel",
	]:
		assert_that(arena.get_node_or_null(node_path)).override_failure_message(
			"Story145 arena node missing: %s" % node_path
		).is_not_null()
	var boss: CharacterBody2D = arena.get_node_or_null(
		"CrownWardenBoss"
	) as CharacterBody2D
	if boss != null:
		assert_that(boss.get_node_or_null("Sprite") as AnimatedSprite2D).is_not_null()
	assert_that(arena.get_node_or_null("CrownWarden")).is_null()
	var source: String = FileAccess.get_file_as_string(ARENA_SCENE_PATH)
	assert_bool(source.contains("ColorRect")).is_false()
	assert_bool(source.contains("Polygon2D")).is_false()
	var objective: Label = arena.get_node_or_null("ArenaObjectiveLabel") as Label
	if objective != null:
		assert_str(objective.text).is_equal("Defeat Crown Warden")


func test_story144_gate_transition_failures_and_roundtrip_are_coherent() -> void:
	var tower: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(tower).is_not_null()
	if tower == null:
		return
	for method_name: StringName in [
		&"try_request_crown_warden_arena",
		&"get_crown_warden_route_diagnostics",
	]:
		assert_bool(tower.has_method(method_name)).override_failure_message(
			"Story145 Tower API missing: %s" % String(method_name)
		).is_true()
	if not tower.has_method("try_request_crown_warden_arena"):
		return
	var route: Node2D = tower.get_node_or_null(TOWER_ROUTE_NODE) as Node2D
	var return_spawn: Marker2D = tower.get_node_or_null(
		TOWER_RETURN_NODE
	) as Marker2D
	var player: CharacterBody2D = tower.get_node_or_null("Player") as CharacterBody2D
	assert_that(route).is_not_null()
	assert_that(return_spawn).is_not_null()
	assert_that(player).is_not_null()
	if route == null or return_spawn == null or player == null:
		return
	assert_vector(return_spawn.position).is_equal(TOWER_RETURN_POSITION)
	var locked: Dictionary = tower.call("get_crown_warden_route_diagnostics")
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_str(String(locked.get("prompt_text", ""))).is_equal(
		"Secure Apex Approach"
	)

	var completed_state: Dictionary = _story144_complete_state()
	tower.call("set_local_state", completed_state)
	var abilities_before: Array[String] = _ability_strings(player)
	assert_bool(bool(tower.call(
		"configure_scene_manager_runtime",
		null
	))).is_false()
	tower.call("set_local_state", completed_state)
	player.global_position = route.global_position
	assert_bool(bool(tower.call(
		"try_request_crown_warden_arena",
		player
	))).is_false()
	var missing_diagnostics: Dictionary = tower.call(
		"get_crown_warden_route_diagnostics"
	)
	assert_str(String(missing_diagnostics.get(
		"last_rejected_reason",
		""
	))).is_equal("scene_manager_missing")
	var manager := FakeCrownSceneManager.new()
	assert_bool(bool(tower.call("configure_scene_manager_runtime", manager))).is_true()
	player.global_position = route.global_position + Vector2(-160.0, 0.0)
	assert_bool(bool(tower.call(
		"try_request_crown_warden_arena",
		player
	))).is_false()
	player.global_position = route.global_position
	manager.loading = true
	assert_bool(bool(tower.call(
		"try_request_crown_warden_arena",
		player
	))).is_false()
	manager.loading = false
	manager.locked = true
	assert_bool(bool(tower.call(
		"try_request_crown_warden_arena",
		player
	))).is_false()
	manager.locked = false
	manager.known_scenes.erase(String(TARGET_SCENE_ID))
	assert_bool(bool(tower.call(
		"try_request_crown_warden_arena",
		player
	))).is_false()
	manager.known_scenes[String(TARGET_SCENE_ID)] = true
	manager.accept_requests = false
	assert_bool(bool(tower.call(
		"try_request_crown_warden_arena",
		player
	))).is_false()
	manager.accept_requests = true
	assert_bool(bool(tower.call(
		"try_request_crown_warden_arena",
		player
	))).is_true()
	assert_int(manager.request_calls.size()).is_equal(1)
	assert_str(String(manager.request_calls[0].get("scene_id", ""))).is_equal(
		String(TARGET_SCENE_ID)
	)
	assert_str(String(manager.request_calls[0].get("spawn_point", ""))).is_equal(
		String(TARGET_SPAWN_POINT)
	)
	assert_bool(bool(tower.call(
		"try_request_crown_warden_arena",
		player
	))).is_false()
	assert_array(_ability_strings(player)).is_equal(abilities_before)
	var persisted: Dictionary = manager.get_scene_state(TOWER_SCENE_ID)
	assert_bool(bool(persisted.get(
		"central_tower_apex_approach_secured",
		false
	))).is_true()

	if not FileAccess.file_exists(ARENA_SCENE_PATH):
		return
	var arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(arena).is_not_null()
	if arena == null:
		return
	manager.reset_for_scene(TARGET_SCENE_ID, TARGET_SPAWN_POINT)
	assert_bool(bool(arena.call("configure_scene_manager_runtime", manager))).is_true()
	var arena_player: CharacterBody2D = arena.get_node_or_null(
		"Player"
	) as CharacterBody2D
	var arena_return: Node2D = arena.get_node_or_null(
		ARENA_RETURN_NODE
	) as Node2D
	assert_that(arena_player).is_not_null()
	assert_that(arena_return).is_not_null()
	if arena_player == null or arena_return == null:
		return
	arena.call("set_local_state", {
		"crown_warden_arena_discovered": true,
		"boss_04_crown_warden_defeated": true,
		"unlocked_abilities": abilities_before,
	})
	arena_player.global_position = arena_return.global_position
	assert_bool(bool(arena.call(
		"try_request_central_tower_return",
		arena_player
	))).is_true()
	assert_int(manager.request_calls.size()).is_equal(1)
	assert_str(String(manager.request_calls[0].get("scene_id", ""))).is_equal(
		String(TOWER_SCENE_ID)
	)
	assert_str(String(manager.request_calls[0].get("spawn_point", ""))).is_equal(
		String(TOWER_RETURN_SPAWN)
	)
	assert_array(_ability_strings(arena_player)).is_equal(abilities_before)

	var returned: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(returned).is_not_null()
	if returned == null:
		return
	returned.call("set_local_state", persisted)
	manager.reset_for_scene(TOWER_SCENE_ID, TOWER_RETURN_SPAWN)
	assert_bool(bool(returned.call(
		"configure_scene_manager_runtime",
		manager
	))).is_true()
	var returned_player: CharacterBody2D = returned.get_node_or_null(
		"Player"
	) as CharacterBody2D
	assert_that(returned_player).is_not_null()
	if returned_player != null:
		assert_vector(returned_player.global_position).is_equal(
			TOWER_RETURN_POSITION
		)
		assert_array(_ability_strings(returned_player)).is_equal(abilities_before)


func _story144_complete_state() -> Dictionary:
	return {
		"central_tower_threshold_roost_activated": true,
		"central_tower_threshold_guard_activated": true,
		"central_tower_threshold_guard_defeated": true,
		"central_tower_inner_relay_activated": true,
		"central_tower_inner_relay_parried": true,
		"central_tower_relay_mantis_activated": true,
		"central_tower_relay_mantis_defeated": true,
		"central_tower_cooling_shaft_roost_activated": true,
		"central_tower_cooling_shaft_activated": true,
		"central_tower_cooling_shaft_traversed": true,
		"central_tower_counterweight_sentry_defeated": true,
		"central_tower_deep_lift_ascended": true,
		"central_tower_apex_roost_activated": true,
		"central_tower_apex_approach_secured": true,
		"central_tower_apex_last_savepoint": {
			"id": "central_tower_apex_roost",
			"scene_id": "area_05_central_tower",
			"spawn_point": "apex_roost",
			"position": {"x": 5260.0, "y": 252.0},
		},
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb", "parry",
		],
	}


func _ability_strings(player: Node) -> Array[String]:
	var result: Array[String] = []
	if player == null or not player.has_method("get_unlocked_abilities"):
		return result
	for value: Variant in Array(player.call("get_unlocked_abilities")):
		result.append(String(value))
	result.sort()
	return result


func _instantiate_scene(path: String) -> Node:
	if not FileAccess.file_exists(path):
		return null
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		return null
	var instance: Node = packed.instantiate()
	add_child(instance)
	_spawned_nodes.append(instance)
	return instance


func _read_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _assert_png(path: String, size: Vector2i, alpha: bool) -> void:
	assert_bool(FileAccess.file_exists(path)).is_true()
	if not FileAccess.file_exists(path):
		return
	var image := Image.new()
	assert_int(image.load_png_from_buffer(
		FileAccess.get_file_as_bytes(path)
	)).is_equal(OK)
	assert_vector(Vector2(image.get_width(), image.get_height())).is_equal(
		Vector2(size)
	)
	assert_int(image.detect_alpha()).is_equal(
		Image.ALPHA_BLEND if alpha else Image.ALPHA_NONE
	)
	if alpha:
		assert_float(image.get_pixel(0, 0).a).is_equal_approx(0.0, 0.01)


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var player := child as AudioStreamPlayer
			player.stop()
			player.stream = null
		elif child is AudioStreamPlayer2D:
			var spatial := child as AudioStreamPlayer2D
			spatial.stop()
			spatial.stream = null
