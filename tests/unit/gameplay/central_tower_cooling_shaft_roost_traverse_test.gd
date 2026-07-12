## Player Abilities Story142: Central Tower Cooling Shaft traversal.
extends GdUnitTestSuite

const TOWER_SCENE_PATH: String = "res://scenes/areas/central_tower_threshold.tscn"
const CONTROLLER_SCRIPT_PATH: String = (
	"res://src/gameplay/central_tower_cooling_shaft_controller.gd"
)
const BACKGROUND_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "env_central_tower_cooling_shaft_1280x720.png"
)
const ROOST_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_cooling_roost_256x256.png"
)
const SPINE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_cooling_spine_256x512.png"
)
const PERCH_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_cooling_perch_384x128.png"
)
const ENDPOINT_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_deep_lift_beacon_256x384.png"
)
const ARC_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "vfx_central_tower_cooling_arc_512x160.png"
)
const CONTACT_SPARK_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "vfx_central_tower_cooling_contact_spark_192x192.png"
)

const ROOST_ID: String = "central_tower_cooling_shaft_roost"
const ROOST_SPAWN: String = "cooling_shaft_roost"
const HAZARD_ID: String = "central_tower_cooling_shaft_arc"
const ENDPOINT_ID: String = "central_tower_cooling_shaft_endpoint"
const ROOST_X: float = 2740.0
const ROUTE_ACTIVATION_X: float = 2920.0
const ARC_X: float = 3220.0
const ENDPOINT_X: float = 3690.0
const EXPECTED_ARC_DAMAGE: int = 10

var _spawned_nodes: Array[Node] = []


class FakeSaveSystem extends Node:
	var auto_save_calls: Array[Dictionary] = []

	func auto_save(
		player_state: Dictionary,
		world_state: Dictionary,
		settings: Dictionary
	) -> bool:
		auto_save_calls.append({
			"player_state": player_state.duplicate(true),
			"world_state": world_state.duplicate(true),
			"settings": settings.duplicate(true),
		})
		return true


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_authored_third_viewport_geometry_asset_and_animation_contract() -> void:
	for path: String in [
		CONTROLLER_SCRIPT_PATH,
		BACKGROUND_PATH,
		ROOST_PATH,
		SPINE_PATH,
		PERCH_PATH,
		ENDPOINT_PATH,
		ARC_PATH,
		CONTACT_SPARK_PATH,
	]:
		assert_bool(FileAccess.file_exists(path)).override_failure_message(
			"Story142 authored contract is missing: %s" % path
		).is_true()

	_assert_png_contract(BACKGROUND_PATH, Vector2i(1280, 720), false)
	_assert_png_contract(ROOST_PATH, Vector2i(256, 256), true)
	_assert_png_contract(SPINE_PATH, Vector2i(256, 512), true)
	_assert_png_contract(PERCH_PATH, Vector2i(384, 128), true)
	_assert_png_contract(ENDPOINT_PATH, Vector2i(256, 384), true)
	_assert_png_contract(ARC_PATH, Vector2i(512, 160), true)
	_assert_png_contract(CONTACT_SPARK_PATH, Vector2i(192, 192), true)

	var tower: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(tower).is_not_null()
	if tower == null:
		return
	for node_path: String in [
		"CoolingShaftBackground",
		"CoolingShaftController",
		"CoolingShaftController/CoolingShaftRoost",
		"CoolingShaftController/CoolingShaftRoostSpawn",
		"CoolingShaftController/CoolingShaftFallZone",
		"CoolingShaftController/CoolingShaftArcHazard",
		"CoolingShaftController/CoolingShaftEndpoint",
		"CoolingShaftApproachGround",
		"CoolingShaftLeftSpine",
		"CoolingShaftMidPerch",
		"CoolingShaftRightSpine",
		"CoolingShaftExitGround",
	]:
		assert_that(tower.get_node_or_null(node_path)).override_failure_message(
			"Story142 scene node is missing: %s" % node_path
		).is_not_null()

	var camera: Camera2D = tower.get_node_or_null("Player/Camera2D") as Camera2D
	var right_boundary: Node2D = tower.get_node_or_null("RightBoundary") as Node2D
	var top_shape: CollisionShape2D = tower.get_node_or_null(
		"TopBoundary/CollisionShape2D"
	) as CollisionShape2D
	assert_that(camera).is_not_null()
	assert_that(right_boundary).is_not_null()
	assert_that(top_shape).is_not_null()
	if camera != null:
		assert_int(camera.limit_right).is_equal(6400)
	if right_boundary != null:
		assert_float(right_boundary.position.x).is_equal_approx(6420.0, 0.01)
	if top_shape != null and top_shape.shape is RectangleShape2D:
		assert_float((top_shape.shape as RectangleShape2D).size.x).is_equal_approx(
			6400.0,
			0.01
		)

	var player_sprite: AnimatedSprite2D = tower.get_node_or_null(
		"Player/Sprite"
	) as AnimatedSprite2D
	assert_that(player_sprite).is_not_null()
	if player_sprite != null and player_sprite.sprite_frames != null:
		for animation_name: StringName in [
			&"run", &"jump", &"fall", &"wall_climb", &"hurt", &"revive",
		]:
			assert_bool(player_sprite.sprite_frames.has_animation(animation_name)).is_true()
			assert_int(player_sprite.sprite_frames.get_frame_count(
				animation_name
			)).is_greater_equal(3)

	var scene_source: String = _read_text(TOWER_SCENE_PATH)
	assert_bool(scene_source.contains("Boss4")).is_false()
	assert_bool(scene_source.contains("[node name=\"Boss")).is_false()


func test_story141_gate_roost_autosave_and_arc_cooldown_contract() -> void:
	var tower: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(tower).is_not_null()
	if tower == null:
		return
	for method_name: StringName in [
		&"configure_cooling_shaft_save_system_runtime",
		&"try_activate_cooling_shaft_roost",
		&"try_activate_cooling_shaft",
		&"advance_cooling_shaft_time",
		&"apply_cooling_shaft_arc_contact",
		&"get_central_tower_cooling_shaft_diagnostics",
	]:
		assert_bool(tower.has_method(method_name)).override_failure_message(
			"Story142 scene API is missing: %s" % String(method_name)
		).is_true()
	if not tower.has_method("try_activate_cooling_shaft_roost"):
		return

	var player: CharacterBody2D = tower.get_node_or_null("Player") as CharacterBody2D
	assert_that(player).is_not_null()
	if player == null:
		return
	player.global_position = Vector2(ROOST_X, 552.0)
	assert_bool(bool(tower.call(
		"try_activate_cooling_shaft_roost",
		player
	))).is_false()

	tower.call("set_local_state", _story141_clear_state())
	var fake_save_system := FakeSaveSystem.new()
	_spawned_nodes.append(fake_save_system)
	add_child(fake_save_system)
	assert_bool(bool(tower.call(
		"configure_cooling_shaft_save_system_runtime",
		fake_save_system
	))).is_true()
	player.call("apply_damage", 20, {"source": &"story142_roost_recovery"})
	assert_int(int(player.call("get_current_hp"))).is_equal(80)
	player.global_position = Vector2(ROOST_X, 552.0)
	assert_bool(bool(tower.call(
		"try_activate_cooling_shaft_roost",
		player
	))).is_true()
	assert_bool(bool(tower.call(
		"try_activate_cooling_shaft_roost",
		player
	))).is_false()
	assert_int(int(player.call("get_current_hp"))).is_equal(100)
	var roost: Dictionary = tower.call(
		"get_central_tower_cooling_shaft_diagnostics"
	)
	assert_bool(bool(roost.get("route_unlocked", false))).is_true()
	assert_bool(bool(roost.get("roost_activated", false))).is_true()
	assert_str(String(roost.get("roost_id", ""))).is_equal(ROOST_ID)
	assert_str(String(roost.get("roost_spawn_point", ""))).is_equal(ROOST_SPAWN)
	assert_int(int(roost.get("autosave_request_count", 0))).is_equal(1)
	assert_int(int(roost.get("audio_request_count", 0))).is_equal(1)
	assert_int(int(Dictionary(roost.get("roost_vfx", {})).get(
		"spawn_count",
		0
	))).is_equal(1)
	assert_int(fake_save_system.auto_save_calls.size()).is_equal(1)

	player.global_position = Vector2(ROUTE_ACTIVATION_X, 552.0)
	assert_bool(bool(tower.call("try_activate_cooling_shaft", player))).is_true()
	tower.call("advance_cooling_shaft_time", 0.76)
	assert_str(String(tower.call(
		"get_central_tower_cooling_shaft_diagnostics"
	).get("hazard_phase", ""))).is_equal("warning")
	tower.call("advance_cooling_shaft_time", 0.51)
	var hp_before: int = int(player.call("get_current_hp"))
	player.global_position = Vector2(ARC_X, 430.0)
	assert_bool(bool(tower.call(
		"apply_cooling_shaft_arc_contact",
		player
	))).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(
		hp_before - EXPECTED_ARC_DAMAGE
	)
	assert_bool(bool(tower.call(
		"apply_cooling_shaft_arc_contact",
		player
	))).is_false()
	tower.call("advance_cooling_shaft_time", 0.36)
	tower.call("advance_cooling_shaft_time", 0.71)
	tower.call("advance_cooling_shaft_time", 0.51)
	assert_bool(bool(tower.call(
		"apply_cooling_shaft_arc_contact",
		player
	))).is_true()


func test_fall_roost_revive_endpoint_and_fresh_restore_are_coherent() -> void:
	var tower: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(tower).is_not_null()
	if tower == null or not tower.has_method("apply_cooling_shaft_fall"):
		assert_bool(false).override_failure_message(
			"Story142 fall/respawn production API is missing"
		).is_true()
		return
	tower.call("set_local_state", _story141_clear_state())
	var player: CharacterBody2D = tower.get_node_or_null("Player") as CharacterBody2D
	var roost_spawn: Marker2D = tower.get_node_or_null(
		"CoolingShaftController/CoolingShaftRoostSpawn"
	) as Marker2D
	assert_that(player).is_not_null()
	assert_that(roost_spawn).is_not_null()
	if player == null or roost_spawn == null:
		return
	var abilities_before: Array[String] = _ability_strings(player)
	player.global_position = Vector2(ROOST_X, 552.0)
	assert_bool(bool(tower.call(
		"try_activate_cooling_shaft_roost",
		player
	))).is_true()
	player.global_position = Vector2(ROUTE_ACTIVATION_X, 552.0)
	assert_bool(bool(tower.call("try_activate_cooling_shaft", player))).is_true()
	assert_bool(bool(tower.call("apply_cooling_shaft_fall", player))).is_true()
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

	player.global_position = Vector2(ENDPOINT_X, 552.0)
	assert_bool(bool(tower.call(
		"try_activate_cooling_shaft_endpoint",
		player
	))).is_true()
	assert_bool(bool(tower.call(
		"try_activate_cooling_shaft_endpoint",
		player
	))).is_false()
	var completed: Dictionary = tower.call(
		"get_central_tower_cooling_shaft_diagnostics"
	)
	assert_bool(bool(completed.get("traversed", false))).is_true()
	assert_str(String(completed.get("endpoint_id", ""))).is_equal(ENDPOINT_ID)
	assert_str(String(completed.get("objective_text", ""))).is_equal(
		"Cooling Shaft Secured"
	)

	var saved: Dictionary = tower.call("get_local_state")
	assert_bool(bool(saved.get(
		"central_tower_relay_mantis_defeated",
		false
	))).is_true()
	assert_bool(bool(saved.get(
		"central_tower_cooling_shaft_traversed",
		false
	))).is_true()
	var restored: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", saved)
	var restored_state: Dictionary = restored.call(
		"get_central_tower_cooling_shaft_diagnostics"
	)
	assert_bool(bool(restored_state.get("roost_activated", false))).is_true()
	assert_bool(bool(restored_state.get("traversed", false))).is_true()
	assert_int(int(restored_state.get("roost_feedback_count", -1))).is_equal(0)
	assert_int(int(restored_state.get("endpoint_feedback_count", -1))).is_equal(0)
	assert_int(int(restored_state.get("autosave_request_count", -1))).is_equal(0)
	assert_int(int(restored_state.get("audio_request_count", -1))).is_equal(0)
	var restored_player: CharacterBody2D = restored.get_node_or_null(
		"Player"
	) as CharacterBody2D
	assert_array(_ability_strings(restored_player)).is_equal(
		abilities_before
	)
	var restored_fall_zone: Area2D = restored.get_node_or_null(
		"CoolingShaftController/CoolingShaftFallZone"
	) as Area2D
	var restored_roost_spawn: Marker2D = restored.get_node_or_null(
		"CoolingShaftController/CoolingShaftRoostSpawn"
	) as Marker2D
	assert_that(restored_player).is_not_null()
	assert_that(restored_fall_zone).is_not_null()
	assert_that(restored_roost_spawn).is_not_null()
	await get_tree().physics_frame
	if restored_fall_zone != null:
		assert_bool(restored_fall_zone.monitoring).is_true()
	if restored_player != null and restored_roost_spawn != null:
		restored_player.global_position = Vector2(3200.0, 680.0)
		assert_bool(bool(restored.call(
			"apply_cooling_shaft_fall",
			restored_player
		))).is_true()
		restored.call("advance_central_tower_respawn_flow", 1.6)
		assert_vector(restored_player.global_position).is_equal(
			restored_roost_spawn.global_position
		)


func _story141_clear_state() -> Dictionary:
	return {
		"central_tower_threshold_roost_activated": true,
		"central_tower_threshold_guard_activated": true,
		"central_tower_threshold_guard_defeated": true,
		"central_tower_inner_relay_activated": true,
		"central_tower_inner_relay_parried": true,
		"central_tower_relay_mantis_activated": true,
		"central_tower_relay_mantis_defeated": true,
		"central_tower_inner_cache_claimed": false,
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
