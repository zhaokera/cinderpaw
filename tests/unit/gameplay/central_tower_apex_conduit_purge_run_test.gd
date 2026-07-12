## Player Abilities Story144: Central Tower Apex Conduit purge chase.
extends GdUnitTestSuite

const TOWER_SCENE_PATH: String = "res://scenes/areas/central_tower_threshold.tscn"
const CONTROLLER_SCRIPT_PATH: String = (
	"res://src/gameplay/central_tower_apex_purge_controller.gd"
)
const BACKGROUND_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "env_central_tower_apex_conduit_1280x720.png"
)
const ROOST_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_apex_roost_256x256.png"
)
const SPINE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_apex_magnetic_spine_256x512.png"
)
const EMITTER_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_apex_purge_emitter_256x384.png"
)
const BEACON_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_apex_beacon_256x384.png"
)
const PURGE_WALL_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "vfx_central_tower_apex_purge_wall_192x640.png"
)
const SOURCE_BACKGROUND_PATH: String = (
	"res://assets/generated/source/"
	+ "central_tower_apex_conduit_background_imagegen_20260712.png"
)
const SOURCE_BACKGROUND_PROMPT_PATH: String = (
	"res://assets/generated/source/"
	+ "central_tower_apex_conduit_background_imagegen_20260712.prompt.md"
)
const SOURCE_PROPS_PATH: String = (
	"res://assets/generated/source/"
	+ "central_tower_apex_conduit_props_imagegen_20260712.png"
)
const SOURCE_PROPS_ALPHA_PATH: String = (
	"res://assets/generated/source/"
	+ "central_tower_apex_conduit_props_alpha_20260712.png"
)
const SOURCE_PROPS_PROMPT_PATH: String = (
	"res://assets/generated/source/"
	+ "central_tower_apex_conduit_props_imagegen_20260712.prompt.md"
)

const ROOST_POSITION: Vector2 = Vector2(5260.0, 276.0)
const ROOST_SPAWN: Vector2 = Vector2(5260.0, 252.0)
const TRIGGER_X: float = 5360.0
const PURGE_START: Vector2 = Vector2(5200.0, 360.0)
const ENDPOINT_POSITION: Vector2 = Vector2(6280.0, 296.0)
const WARNING_DELAY_SEC: float = 0.75
const PURGE_SPEED_PX_SEC: float = 150.0

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_authored_fifth_viewport_assets_geometry_and_bounds_match_contract() -> void:
	var missing_paths: Array[String] = []
	for path: String in [
		CONTROLLER_SCRIPT_PATH,
		BACKGROUND_PATH,
		ROOST_PATH,
		SPINE_PATH,
		EMITTER_PATH,
		BEACON_PATH,
		PURGE_WALL_PATH,
		SOURCE_BACKGROUND_PATH,
		SOURCE_BACKGROUND_PROMPT_PATH,
		SOURCE_PROPS_PATH,
		SOURCE_PROPS_ALPHA_PATH,
		SOURCE_PROPS_PROMPT_PATH,
	]:
		if not FileAccess.file_exists(path):
			missing_paths.append(path)
	assert_array(missing_paths).override_failure_message(
		"Story144 authored paths are missing: %s" % ", ".join(missing_paths)
	).is_empty()
	if not missing_paths.is_empty():
		return

	_assert_png_contract(BACKGROUND_PATH, Vector2i(1280, 720), false)
	_assert_png_contract(ROOST_PATH, Vector2i(256, 256), true)
	_assert_png_contract(SPINE_PATH, Vector2i(256, 512), true)
	_assert_png_contract(EMITTER_PATH, Vector2i(256, 384), true)
	_assert_png_contract(BEACON_PATH, Vector2i(256, 384), true)
	_assert_png_contract(PURGE_WALL_PATH, Vector2i(192, 640), true)

	var tower: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(tower).is_not_null()
	if tower == null:
		return
	for node_path: String in [
		"ApexConduitBackground",
		"ApexEntryGround",
		"ApexLowerCatwalk",
		"ApexMagneticSpine",
		"ApexUpperCatwalk",
		"ApexEndpointGround",
		"ApexPurgeController",
		"ApexPurgeController/ApexRoost",
		"ApexPurgeController/ApexRoostSpawn",
		"ApexPurgeController/PurgeTrigger",
		"ApexPurgeController/PurgeEmitter",
		"ApexPurgeController/PurgeWall",
		"ApexPurgeController/ApexFallZone",
		"ApexPurgeController/ApexEndpoint",
	]:
		assert_that(tower.get_node_or_null(node_path)).override_failure_message(
			"Story144 scene node is missing: %s" % node_path
		).is_not_null()

	var camera: Camera2D = tower.get_node_or_null("Player/Camera2D") as Camera2D
	var top_boundary: StaticBody2D = tower.get_node_or_null(
		"TopBoundary"
	) as StaticBody2D
	var top_shape: CollisionShape2D = tower.get_node_or_null(
		"TopBoundary/CollisionShape2D"
	) as CollisionShape2D
	var right_boundary: StaticBody2D = tower.get_node_or_null(
		"RightBoundary"
	) as StaticBody2D
	var roost: Node2D = tower.get_node_or_null(
		"ApexPurgeController/ApexRoost"
	) as Node2D
	var roost_spawn: Marker2D = tower.get_node_or_null(
		"ApexPurgeController/ApexRoostSpawn"
	) as Marker2D
	var purge_wall: Area2D = tower.get_node_or_null(
		"ApexPurgeController/PurgeWall"
	) as Area2D
	var endpoint: Node2D = tower.get_node_or_null(
		"ApexPurgeController/ApexEndpoint"
	) as Node2D
	assert_that(camera).is_not_null()
	assert_that(top_boundary).is_not_null()
	assert_that(top_shape).is_not_null()
	assert_that(right_boundary).is_not_null()
	assert_that(roost).is_not_null()
	assert_that(roost_spawn).is_not_null()
	assert_that(purge_wall).is_not_null()
	assert_that(endpoint).is_not_null()
	if camera != null:
		assert_int(camera.limit_right).is_equal(6400)
	if top_boundary != null:
		assert_vector(top_boundary.position).is_equal(Vector2(3200.0, -20.0))
	if top_shape != null and top_shape.shape is RectangleShape2D:
		assert_float((top_shape.shape as RectangleShape2D).size.x).is_equal_approx(
			6400.0,
			0.01
		)
	if right_boundary != null:
		assert_vector(right_boundary.position).is_equal(Vector2(6420.0, 360.0))
	if roost != null:
		assert_vector(roost.position).is_equal(ROOST_POSITION)
	if roost_spawn != null:
		assert_vector(roost_spawn.position).is_equal(ROOST_SPAWN)
	if purge_wall != null:
		assert_vector(purge_wall.position).is_equal(PURGE_START)
	if endpoint != null:
		assert_vector(endpoint.position).is_equal(ENDPOINT_POSITION)

	var source_text: String = (
		_read_text(TOWER_SCENE_PATH) + _read_text(CONTROLLER_SCRIPT_PATH)
	)
	assert_bool(source_text.contains("Boss4")).is_false()
	assert_bool(source_text.contains("[node name=\"Boss")).is_false()


func test_story143_gate_roost_warning_wall_motion_and_contact_are_real() -> void:
	var tower: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(tower).is_not_null()
	if tower == null:
		return
	for method_name: StringName in [
		&"try_activate_apex_roost",
		&"try_trigger_apex_purge",
		&"advance_apex_purge_time",
		&"apply_apex_purge_contact",
		&"get_central_tower_apex_diagnostics",
	]:
		assert_bool(tower.has_method(method_name)).override_failure_message(
			"Story144 scene API is missing: %s" % String(method_name)
		).is_true()
	if not tower.has_method("try_activate_apex_roost"):
		return

	var player: CharacterBody2D = tower.get_node_or_null("Player") as CharacterBody2D
	var controller: Node = tower.get_node_or_null("ApexPurgeController")
	var purge_wall: Area2D = tower.get_node_or_null(
		"ApexPurgeController/PurgeWall"
	) as Area2D
	assert_that(player).is_not_null()
	assert_that(controller).is_not_null()
	assert_that(purge_wall).is_not_null()
	if player == null or controller == null or purge_wall == null:
		return
	assert_float(float(controller.get("warning_delay_sec"))).is_equal_approx(
		WARNING_DELAY_SEC,
		0.001
	)
	assert_float(float(controller.get("purge_speed_px_sec"))).is_equal_approx(
		PURGE_SPEED_PX_SEC,
		0.001
	)

	player.global_position = ROOST_SPAWN
	assert_bool(bool(tower.call("try_activate_apex_roost", player))).is_false()
	var locked: Dictionary = tower.call("get_central_tower_apex_diagnostics")
	assert_bool(bool(locked.get("route_unlocked", true))).is_false()

	tower.call("set_local_state", _story143_complete_state())
	player.global_position = ROOST_SPAWN
	assert_bool(bool(tower.call("try_activate_apex_roost", player))).is_true()
	assert_bool(bool(tower.call("try_activate_apex_roost", player))).is_false()
	var activated: Dictionary = tower.call("get_central_tower_apex_diagnostics")
	assert_bool(bool(activated.get("route_unlocked", false))).is_true()
	assert_bool(bool(activated.get("roost_activated", false))).is_true()
	assert_int(int(activated.get("roost_feedback_count", 0))).is_equal(1)
	assert_int(int(activated.get("autosave_request_count", 0))).is_equal(1)

	player.global_position = Vector2(TRIGGER_X - 1.0, ROOST_SPAWN.y)
	assert_bool(bool(tower.call("try_trigger_apex_purge", player))).is_false()
	player.global_position = Vector2(TRIGGER_X, ROOST_SPAWN.y)
	assert_bool(bool(tower.call("try_trigger_apex_purge", player))).is_true()
	tower.call("advance_apex_purge_time", WARNING_DELAY_SEC)
	var warning_complete: Dictionary = tower.call(
		"get_central_tower_apex_diagnostics"
	)
	assert_bool(bool(warning_complete.get("purge_active", false))).is_true()
	assert_vector(Vector2(warning_complete.get(
		"purge_position",
		Vector2.ZERO
	))).is_equal(PURGE_START)
	tower.call("advance_apex_purge_time", 1.0)
	var moving: Dictionary = tower.call("get_central_tower_apex_diagnostics")
	assert_float(Vector2(moving.get(
		"purge_position",
		Vector2.ZERO
	)).x).is_equal_approx(PURGE_START.x + PURGE_SPEED_PX_SEC, 0.01)
	await get_tree().physics_frame
	assert_bool(purge_wall.monitoring).is_true()

	var hp_before: int = int(player.call("get_current_hp"))
	assert_int(hp_before).is_greater(0)
	assert_bool(bool(tower.call("apply_apex_purge_contact", player))).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(0)
	var lethal: Dictionary = tower.call("get_central_tower_apex_diagnostics")
	assert_int(int(lethal.get("purge_contact_count", 0))).is_equal(1)


func test_apex_death_retry_endpoint_and_fresh_restore_are_coherent() -> void:
	var tower: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(tower).is_not_null()
	if tower == null or not tower.has_method("try_activate_apex_roost"):
		assert_bool(false).override_failure_message(
			"Story144 production API is not implemented"
		).is_true()
		return
	tower.call("set_local_state", _story143_complete_state())
	var player: CharacterBody2D = tower.get_node_or_null("Player") as CharacterBody2D
	var roost_spawn: Marker2D = tower.get_node_or_null(
		"ApexPurgeController/ApexRoostSpawn"
	) as Marker2D
	assert_that(player).is_not_null()
	assert_that(roost_spawn).is_not_null()
	if player == null or roost_spawn == null:
		return
	var abilities_before: Array[String] = _ability_strings(player)

	player.global_position = ROOST_SPAWN
	assert_bool(bool(tower.call("try_activate_apex_roost", player))).is_true()
	player.global_position = Vector2(TRIGGER_X, ROOST_SPAWN.y)
	assert_bool(bool(tower.call("try_trigger_apex_purge", player))).is_true()
	tower.call("advance_apex_purge_time", WARNING_DELAY_SEC + 0.5)
	assert_bool(bool(tower.call("apply_apex_purge_contact", player))).is_true()
	tower.call("advance_central_tower_respawn_flow", 1.6)
	assert_int(int(player.call("get_current_hp"))).is_equal(50)
	assert_vector(player.global_position).is_equal(roost_spawn.global_position)
	var health: HealthComponent = player.get_node_or_null(
		"HealthComponent"
	) as HealthComponent
	assert_that(health).is_not_null()
	if health != null:
		assert_bool(health.is_invincible()).is_true()
		assert_int(health.get_iframe_remaining()).is_equal(120)
	assert_array(_ability_strings(player)).is_equal(abilities_before)
	var reset: Dictionary = tower.call("get_central_tower_apex_diagnostics")
	assert_bool(bool(reset.get("roost_activated", false))).is_true()
	assert_bool(bool(reset.get("attempt_triggered", true))).is_false()
	assert_bool(bool(reset.get("purge_active", true))).is_false()
	assert_vector(Vector2(reset.get("purge_position", Vector2.ZERO))).is_equal(
		PURGE_START
	)
	assert_int(int(reset.get("purge_contact_count", -1))).is_equal(0)

	player.global_position = ENDPOINT_POSITION
	assert_bool(bool(tower.call("try_activate_apex_endpoint", player))).is_false()
	player.global_position = Vector2(TRIGGER_X, ROOST_SPAWN.y)
	assert_bool(bool(tower.call("try_trigger_apex_purge", player))).is_true()
	player.global_position = ENDPOINT_POSITION
	assert_bool(bool(tower.call("try_activate_apex_endpoint", player))).is_true()
	assert_bool(bool(tower.call("try_activate_apex_endpoint", player))).is_false()
	var completed: Dictionary = tower.call("get_central_tower_apex_diagnostics")
	assert_bool(bool(completed.get("approach_secured", false))).is_true()
	assert_bool(bool(completed.get("purge_active", true))).is_false()
	assert_str(String(completed.get("objective_text", ""))).is_equal(
		"Apex Approach Secured"
	)

	var saved: Dictionary = tower.call("get_local_state")
	assert_bool(bool(saved.get(
		"central_tower_deep_lift_ascended",
		false
	))).is_true()
	assert_bool(bool(saved.get(
		"central_tower_apex_roost_activated",
		false
	))).is_true()
	assert_bool(bool(saved.get(
		"central_tower_apex_approach_secured",
		false
	))).is_true()

	var fall_tower: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(fall_tower).is_not_null()
	if fall_tower != null:
		fall_tower.call("set_local_state", _story143_complete_state())
		var fall_player: CharacterBody2D = fall_tower.get_node_or_null(
			"Player"
		) as CharacterBody2D
		assert_that(fall_player).is_not_null()
		if fall_player != null:
			var fall_abilities_before: Array[String] = _ability_strings(fall_player)
			fall_player.global_position = ROOST_SPAWN
			assert_bool(bool(fall_tower.call(
				"try_activate_apex_roost",
				fall_player
			))).is_true()
			assert_bool(bool(fall_tower.call(
				"apply_apex_fall",
				fall_player
			))).is_true()
			assert_int(int(fall_player.call("get_current_hp"))).is_equal(0)
			var fallen: Dictionary = fall_tower.call(
				"get_central_tower_apex_diagnostics"
			)
			assert_int(int(fallen.get("fall_accept_count", 0))).is_equal(1)
			fall_tower.call("advance_central_tower_respawn_flow", 1.6)
			assert_int(int(fall_player.call("get_current_hp"))).is_equal(50)
			assert_vector(fall_player.global_position).is_equal(ROOST_SPAWN)
			assert_array(_ability_strings(fall_player)).is_equal(
				fall_abilities_before
			)

	var restored: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", saved)
	var restored_state: Dictionary = restored.call(
		"get_central_tower_apex_diagnostics"
	)
	assert_bool(bool(restored_state.get("route_unlocked", false))).is_true()
	assert_bool(bool(restored_state.get("roost_activated", false))).is_true()
	assert_bool(bool(restored_state.get("approach_secured", false))).is_true()
	assert_bool(bool(restored_state.get("purge_active", true))).is_false()
	for counter_key: String in [
		"roost_feedback_count",
		"trigger_feedback_count",
		"endpoint_feedback_count",
		"purge_contact_count",
		"autosave_request_count",
		"audio_request_count",
		"vfx_request_count",
	]:
		assert_int(int(restored_state.get(counter_key, -1))).override_failure_message(
			"Restore replayed Story144 feedback: %s" % counter_key
		).is_equal(0)
	var latest_savepoint: Dictionary = restored.call(
		"get_last_discovered_savepoint"
	)
	assert_str(String(latest_savepoint.get("id", ""))).is_equal(
		"central_tower_apex_roost"
	)
	var latest_position: Dictionary = Dictionary(latest_savepoint.get(
		"position",
		{}
	))
	assert_float(float(latest_position.get("x", 0.0))).is_equal_approx(
		ROOST_SPAWN.x,
		0.01
	)
	assert_float(float(latest_position.get("y", 0.0))).is_equal_approx(
		ROOST_SPAWN.y,
		0.01
	)
	var restored_player: CharacterBody2D = restored.get_node_or_null(
		"Player"
	) as CharacterBody2D
	assert_array(_ability_strings(restored_player)).is_equal(abilities_before)


func _story143_complete_state() -> Dictionary:
	return {
		"central_tower_threshold_roost_activated": true,
		"central_tower_threshold_guard_activated": true,
		"central_tower_threshold_guard_defeated": true,
		"central_tower_inner_relay_activated": true,
		"central_tower_inner_relay_parried": true,
		"central_tower_relay_mantis_activated": true,
		"central_tower_relay_mantis_defeated": true,
		"central_tower_inner_cache_claimed": false,
		"central_tower_cooling_shaft_roost_activated": true,
		"central_tower_cooling_shaft_activated": true,
		"central_tower_cooling_shaft_traversed": true,
		"central_tower_cooling_shaft_last_savepoint": {
			"id": "central_tower_cooling_shaft_roost",
			"scene_id": "area_05_central_tower",
			"spawn_point": "cooling_shaft_roost",
			"position": {"x": 2740.0, "y": 552.0},
		},
		"central_tower_counterweight_sentry_defeated": true,
		"central_tower_deep_lift_ascended": true,
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
	_spawned_nodes.append(instance)
	add_child(instance)
	return instance


func _read_text(path: String) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	return file.get_as_text() if file != null else ""


func _assert_png_contract(path: String, expected_size: Vector2i, alpha: bool) -> void:
	assert_bool(FileAccess.file_exists(path)).is_true()
	if not FileAccess.file_exists(path):
		return
	var image := Image.new()
	assert_int(image.load(path)).is_equal(OK)
	assert_int(image.get_width()).is_equal(expected_size.x)
	assert_int(image.get_height()).is_equal(expected_size.y)
	assert_int(image.detect_alpha()).is_equal(
		Image.ALPHA_BLEND if alpha else Image.ALPHA_NONE
	)
	if alpha:
		assert_float(image.get_pixel(0, 0).a).is_equal_approx(0.0, 0.01)


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method("stop_all_runtime_audio"):
		audio_system.call("stop_all_runtime_audio")
