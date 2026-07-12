## Player Abilities Story143: Central Tower Deep Lift moving-platform ambush.
extends GdUnitTestSuite

const TOWER_SCENE_PATH: String = "res://scenes/areas/central_tower_threshold.tscn"
const CONTROLLER_SCRIPT_PATH: String = (
	"res://src/gameplay/central_tower_deep_lift_controller.gd"
)
const SENTRY_SCRIPT_PATH: String = (
	"res://src/gameplay/central_tower_counterweight_sentry.gd"
)
const SENTRY_RUNTIME_SCENE_PATH: String = (
	"res://src/gameplay/central_tower_counterweight_sentry.tscn"
)
const SENTRY_CHARACTER_SCRIPT_PATH: String = (
	"res://src/characters/central_tower_counterweight_sentry.gd"
)
const SENTRY_CHARACTER_SCENE_PATH: String = (
	"res://scenes/characters/central_tower_counterweight_sentry.tscn"
)
const SENTRY_FRAMES_PATH: String = (
	"res://assets/characters/central_tower_counterweight_sentry/"
	+ "central_tower_counterweight_sentry_sprite_frames.tres"
)
const BACKGROUND_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "env_central_tower_deep_lift_1280x720.png"
)
const PLATFORM_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_deep_lift_platform_512x160.png"
)
const COUNTERWEIGHT_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_deep_lift_counterweight_256x512.png"
)
const SHUTTER_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_deep_lift_entry_shutter_384x512.png"
)
const CRADLE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_counterweight_sentry_cradle_256x256.png"
)
const CONSOLE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_deep_lift_brake_console_256x384.png"
)
const WARNING_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "vfx_central_tower_deep_lift_warning_sweep_512x128.png"
)
const SOURCE_BACKGROUND_PATH: String = (
	"res://assets/generated/source/"
	+ "central_tower_deep_lift_background_imagegen_20260712.png"
)
const SOURCE_PROPS_PATH: String = (
	"res://assets/generated/source/"
	+ "central_tower_deep_lift_props_imagegen_20260712.png"
)
const SOURCE_PROPS_ALPHA_PATH: String = (
	"res://assets/generated/source/"
	+ "central_tower_deep_lift_props_alpha_20260712.png"
)
const ENEMY_STATS_PATH: String = "res://data/combat/enemy_stats.json"
const ENEMY_SCHEMA_PATH: String = "res://data/schemas/enemy_stats.schema.json"

const SENTRY_CONFIG_ID: String = "central_tower_counterweight_sentry"
const SENTRY_ENTITY_ID: int = 2703
const SENTRY_HITBOX_ID: StringName = (
	&"central_tower_counterweight_sentry_ram"
)
const EXPECTED_SENTRY_HP: int = 44
const EXPECTED_SENTRY_DAMAGE: int = 12
const EXPECTED_STARTUP_FRAMES: int = 24
const PLATFORM_START: Vector2 = Vector2(4380.0, 590.0)
const PLATFORM_MID: Vector2 = Vector2(4380.0, 450.0)
const PLATFORM_TOP: Vector2 = Vector2(4380.0, 290.0)
const ENDPOINT_POSITION: Vector2 = Vector2(4980.0, 252.0)

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


func test_authored_fourth_viewport_platform_assets_and_enemy_frame_contract() -> void:
	var missing_paths: Array[String] = []
	for path: String in [
		CONTROLLER_SCRIPT_PATH,
		SENTRY_SCRIPT_PATH,
		SENTRY_RUNTIME_SCENE_PATH,
		SENTRY_CHARACTER_SCRIPT_PATH,
		SENTRY_CHARACTER_SCENE_PATH,
		SENTRY_FRAMES_PATH,
		BACKGROUND_PATH,
		PLATFORM_PATH,
		COUNTERWEIGHT_PATH,
		SHUTTER_PATH,
		CRADLE_PATH,
		CONSOLE_PATH,
		WARNING_PATH,
		SOURCE_BACKGROUND_PATH,
		SOURCE_PROPS_PATH,
		SOURCE_PROPS_ALPHA_PATH,
	]:
		if not FileAccess.file_exists(path):
			missing_paths.append(path)
	assert_array(missing_paths).override_failure_message(
		"Story143 authored paths are missing: %s" % ", ".join(missing_paths)
	).is_empty()
	if not missing_paths.is_empty():
		return

	_assert_png_contract(BACKGROUND_PATH, Vector2i(1280, 720), false)
	_assert_png_contract(PLATFORM_PATH, Vector2i(512, 160), true)
	_assert_png_contract(COUNTERWEIGHT_PATH, Vector2i(256, 512), true)
	_assert_png_contract(SHUTTER_PATH, Vector2i(384, 512), true)
	_assert_png_contract(CRADLE_PATH, Vector2i(256, 256), true)
	_assert_png_contract(CONSOLE_PATH, Vector2i(256, 384), true)
	_assert_png_contract(WARNING_PATH, Vector2i(512, 128), true)

	var enemy_stats: Dictionary = _read_json(ENEMY_STATS_PATH)
	var enemy_schema: Dictionary = _read_json(ENEMY_SCHEMA_PATH)
	var entries: Dictionary = Dictionary(enemy_stats.get("entries", {}))
	var schema_entries: Dictionary = Dictionary(enemy_schema.get("entries", {}))
	assert_bool(entries.has(SENTRY_CONFIG_ID)).is_true()
	assert_bool(schema_entries.has(SENTRY_CONFIG_ID)).is_true()
	if entries.has(SENTRY_CONFIG_ID):
		var config: Dictionary = Dictionary(entries[SENTRY_CONFIG_ID])
		assert_int(int(config.get("max_hp", 0))).is_equal(EXPECTED_SENTRY_HP)
		var patterns: Array = Array(config.get("attack_patterns", []))
		assert_int(patterns.size()).is_equal(1)
		if not patterns.is_empty() and patterns[0] is Dictionary:
			var pattern: Dictionary = Dictionary(patterns[0])
			assert_int(int(pattern.get("startup_frames", 0))).is_equal(24)
			assert_int(int(pattern.get("active_frames", 0))).is_equal(5)
			assert_int(int(pattern.get("recovery_frames", 0))).is_equal(24)
			assert_int(int(pattern.get("damage", 0))).is_equal(
				EXPECTED_SENTRY_DAMAGE
			)
			assert_float(float(pattern.get("lunge_speed", 0.0))).is_equal_approx(
				120.0,
				0.01
			)

	_assert_sentry_frame_contract()

	var tower: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(tower).is_not_null()
	if tower == null:
		return
	for node_path: String in [
		"DeepLiftBackground",
		"DeepLiftEntryGround",
		"DeepLiftUpperGround",
		"DeepLiftController",
		"DeepLiftController/DeepLiftPlatform",
		"DeepLiftController/PlatformStart",
		"DeepLiftController/PlatformAmbushStop",
		"DeepLiftController/PlatformTop",
		"DeepLiftController/EntryShutter",
		"DeepLiftController/UpperShutter",
		"DeepLiftController/CounterweightCarriage",
		"DeepLiftController/SentryCradle",
		"DeepLiftController/WarningSweep",
		"DeepLiftController/CentralTowerCounterweightSentry",
		"DeepLiftController/DeepLiftFallZone",
		"DeepLiftController/UpperEndpoint",
	]:
		assert_that(tower.get_node_or_null(node_path)).override_failure_message(
			"Story143 scene node is missing: %s" % node_path
		).is_not_null()

	var camera: Camera2D = tower.get_node_or_null("Player/Camera2D") as Camera2D
	var right_boundary: Node2D = tower.get_node_or_null("RightBoundary") as Node2D
	var top_shape: CollisionShape2D = tower.get_node_or_null(
		"TopBoundary/CollisionShape2D"
	) as CollisionShape2D
	var platform: AnimatableBody2D = tower.get_node_or_null(
		"DeepLiftController/DeepLiftPlatform"
	) as AnimatableBody2D
	var start: Marker2D = tower.get_node_or_null(
		"DeepLiftController/PlatformStart"
	) as Marker2D
	var mid: Marker2D = tower.get_node_or_null(
		"DeepLiftController/PlatformAmbushStop"
	) as Marker2D
	var top: Marker2D = tower.get_node_or_null(
		"DeepLiftController/PlatformTop"
	) as Marker2D
	assert_that(camera).is_not_null()
	assert_that(right_boundary).is_not_null()
	assert_that(top_shape).is_not_null()
	assert_that(platform).is_not_null()
	assert_that(start).is_not_null()
	assert_that(mid).is_not_null()
	assert_that(top).is_not_null()
	if camera != null:
		assert_int(camera.limit_right).is_equal(6400)
	if right_boundary != null:
		assert_float(right_boundary.position.x).is_equal_approx(6420.0, 0.01)
	if top_shape != null and top_shape.shape is RectangleShape2D:
		assert_float((top_shape.shape as RectangleShape2D).size.x).is_equal_approx(
			6400.0,
			0.01
		)
	if platform != null:
		assert_bool(platform.sync_to_physics).is_true()
		assert_int(platform.collision_layer).is_equal(16)
	if start != null and mid != null and top != null:
		assert_vector(start.position).is_equal(PLATFORM_START)
		assert_vector(mid.position).is_equal(PLATFORM_MID)
		assert_vector(top.position).is_equal(PLATFORM_TOP)

	var source_text: String = (
		_read_text(TOWER_SCENE_PATH)
		+ _read_text(CONTROLLER_SCRIPT_PATH)
		+ _read_text(SENTRY_SCRIPT_PATH)
	)
	assert_bool(source_text.contains("Boss4")).is_false()
	assert_bool(source_text.contains("[node name=\"Boss")).is_false()


func test_story142_gate_platform_physically_carries_player_and_enemy_combat_is_real() -> void:
	var tower: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(tower).is_not_null()
	if tower == null:
		return
	for method_name: StringName in [
		&"try_activate_deep_lift",
		&"advance_deep_lift_time",
		&"request_counterweight_sentry_attack",
		&"get_central_tower_deep_lift_diagnostics",
	]:
		assert_bool(tower.has_method(method_name)).override_failure_message(
			"Story143 scene API is missing: %s" % String(method_name)
		).is_true()
	if not tower.has_method("try_activate_deep_lift"):
		return

	var player: CharacterBody2D = tower.get_node_or_null("Player") as CharacterBody2D
	var controller: Node = tower.get_node_or_null("DeepLiftController")
	var platform: AnimatableBody2D = tower.get_node_or_null(
		"DeepLiftController/DeepLiftPlatform"
	) as AnimatableBody2D
	var sentry: CharacterBody2D = tower.get_node_or_null(
		"DeepLiftController/CentralTowerCounterweightSentry"
	) as CharacterBody2D
	assert_that(player).is_not_null()
	assert_that(controller).is_not_null()
	assert_that(platform).is_not_null()
	assert_that(sentry).is_not_null()
	if player == null or controller == null or platform == null or sentry == null:
		return
	_configure_fast_lift(controller)

	player.global_position = PLATFORM_START + Vector2(0.0, -38.0)
	assert_bool(bool(tower.call("try_activate_deep_lift", player))).is_false()
	var locked: Dictionary = tower.call(
		"get_central_tower_deep_lift_diagnostics"
	)
	assert_bool(bool(locked.get("route_unlocked", true))).is_false()
	assert_vector(platform.position).is_equal(PLATFORM_START)
	assert_bool(sentry.visible).is_false()

	tower.call("set_local_state", _story142_complete_state())
	player.global_position = PLATFORM_START + Vector2(0.0, -38.0)
	player.velocity = Vector2.ZERO
	await get_tree().physics_frame
	await get_tree().physics_frame
	var relative_before: Vector2 = player.global_position - platform.global_position
	var platform_before: Vector2 = platform.global_position
	assert_bool(bool(tower.call("try_activate_deep_lift", player))).is_true()
	for _frame: int in range(32):
		await get_tree().physics_frame
	var platform_after: Vector2 = platform.global_position
	var relative_after: Vector2 = player.global_position - platform.global_position
	assert_float(platform_before.y - platform_after.y).is_greater_equal(64.0)
	assert_float(relative_after.distance_to(relative_before)).is_less_equal(6.0)
	var active: Dictionary = tower.call(
		"get_central_tower_deep_lift_diagnostics"
	)
	assert_bool(bool(active.get("entry_shutter_blocking", false))).is_true()
	assert_bool(bool(active.get("upper_shutter_blocking", false))).is_true()
	assert_bool(bool(active.get("sentry_activated", false))).is_true()
	assert_bool(sentry.visible).is_true()

	sentry.set_physics_process(false)
	assert_bool(bool(tower.call(
		"request_counterweight_sentry_attack"
	))).is_true()
	var sentry_sprite: AnimatedSprite2D = sentry.get_node_or_null(
		"Sprite"
	) as AnimatedSprite2D
	assert_that(sentry_sprite).is_not_null()
	if sentry_sprite != null:
		assert_str(String(sentry_sprite.animation)).is_equal("attack_tell")
	sentry.call("advance_attack_frames", EXPECTED_STARTUP_FRAMES)
	assert_bool(bool(sentry.call("is_enemy_attack_active"))).is_true()
	if sentry_sprite != null:
		assert_str(String(sentry_sprite.animation)).is_equal("attack")
	var enemy_collision: CollisionComponent = sentry.call(
		"get_collision_component"
	) as CollisionComponent
	var player_collision: CollisionComponent = player.call(
		"get_collision_component"
	) as CollisionComponent
	assert_that(enemy_collision).is_not_null()
	assert_that(player_collision).is_not_null()
	if enemy_collision == null or player_collision == null:
		return
	var hp_before: int = int(player.call("get_current_hp"))
	var overlaps: Dictionary = {
		SENTRY_HITBOX_ID: [player_collision.get_hurtbox()],
	}
	enemy_collision.process_detection_frame(overlaps)
	assert_int(int(player.call("get_current_hp"))).is_equal(
		hp_before - EXPECTED_SENTRY_DAMAGE
	)
	enemy_collision.process_detection_frame(overlaps)
	assert_int(int(player.call("get_current_hp"))).is_equal(
		hp_before - EXPECTED_SENTRY_DAMAGE
	)

	assert_bool(bool(tower.call(
		"apply_damage",
		SENTRY_ENTITY_ID,
		12,
		{"source": &"story143_player_attack"}
	))).is_true()
	var hurt: Dictionary = tower.call(
		"get_central_tower_deep_lift_diagnostics"
	)
	assert_int(int(hurt.get("sentry_current_hp", 0))).is_equal(32)
	if sentry_sprite != null:
		assert_str(String(sentry_sprite.animation)).is_equal("hurt")


func test_death_resets_uncleared_attempt_but_defeat_endpoint_and_restore_are_durable() -> void:
	var tower: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(tower).is_not_null()
	if tower == null or not tower.has_method("try_activate_deep_lift"):
		assert_bool(false).override_failure_message(
			"Story143 production API is not implemented"
		).is_true()
		return
	tower.call("set_local_state", _story142_complete_state())
	var player: CharacterBody2D = tower.get_node_or_null("Player") as CharacterBody2D
	var controller: Node = tower.get_node_or_null("DeepLiftController")
	var platform: AnimatableBody2D = tower.get_node_or_null(
		"DeepLiftController/DeepLiftPlatform"
	) as AnimatableBody2D
	var sentry: CharacterBody2D = tower.get_node_or_null(
		"DeepLiftController/CentralTowerCounterweightSentry"
	) as CharacterBody2D
	assert_that(player).is_not_null()
	assert_that(controller).is_not_null()
	assert_that(platform).is_not_null()
	assert_that(sentry).is_not_null()
	if player == null or controller == null or platform == null or sentry == null:
		return
	_configure_fast_lift(controller)
	var abilities_before: Array[String] = _ability_strings(player)

	player.global_position = PLATFORM_START + Vector2(0.0, -38.0)
	assert_bool(bool(tower.call("try_activate_deep_lift", player))).is_true()
	tower.call("advance_deep_lift_time", 0.5)
	assert_bool(bool(tower.call(
		"apply_damage",
		SENTRY_ENTITY_ID,
		10,
		{"source": &"story143_partial_damage"}
	))).is_true()
	assert_vector(platform.position).is_not_equal(PLATFORM_START)
	player.call("apply_damage", 999, {"source": &"story143_uncleared_death"})
	tower.call("advance_central_tower_respawn_flow", 1.6)
	var reset: Dictionary = tower.call(
		"get_central_tower_deep_lift_diagnostics"
	)
	assert_int(int(player.call("get_current_hp"))).is_equal(50)
	assert_vector(player.global_position).is_equal(Vector2(2740.0, 552.0))
	var health: HealthComponent = player.get_node_or_null(
		"HealthComponent"
	) as HealthComponent
	assert_that(health).is_not_null()
	if health != null:
		assert_int(health.get_iframe_remaining()).is_equal(120)
	assert_vector(Vector2(reset.get("platform_position", Vector2.ZERO))).is_equal(
		PLATFORM_START
	)
	assert_bool(bool(reset.get("attempt_active", true))).is_false()
	assert_bool(bool(reset.get("entry_shutter_blocking", true))).is_false()
	assert_bool(bool(reset.get("upper_shutter_blocking", true))).is_false()
	assert_bool(bool(reset.get("sentry_activated", true))).is_false()
	assert_int(int(reset.get("sentry_current_hp", 0))).is_equal(
		EXPECTED_SENTRY_HP
	)
	assert_array(_ability_strings(player)).is_equal(abilities_before)

	if health != null:
		for _frame: int in range(120):
			health.call("_physics_process", 1.0 / 60.0)
	tower.call("advance_central_tower_respawn_flow", 2.1)
	player.global_position = PLATFORM_START + Vector2(0.0, -38.0)
	assert_bool(bool(tower.call("try_activate_deep_lift", player))).is_true()
	tower.call("advance_deep_lift_time", 0.5)
	player.call("apply_damage", 999, {"source": &"story143_death_window"})
	assert_bool(bool(tower.call(
		"apply_damage",
		SENTRY_ENTITY_ID,
		999,
		{"source": &"story143_death_window_clear"}
	))).is_true()
	var death_window_clear: Dictionary = tower.call(
		"get_central_tower_deep_lift_diagnostics"
	)
	assert_bool(bool(death_window_clear.get("sentry_defeated", false))).is_true()
	assert_bool(bool(death_window_clear.get("sentry_visible", false))).is_true()
	assert_str(String(death_window_clear.get("sentry_animation", ""))).is_equal(
		"death"
	)
	tower.call("advance_central_tower_respawn_flow", 1.6)
	var durable_retry: Dictionary = tower.call(
		"get_central_tower_deep_lift_diagnostics"
	)
	assert_bool(bool(durable_retry.get("sentry_defeated", false))).is_true()
	assert_bool(bool(durable_retry.get("sentry_visible", true))).is_false()
	assert_vector(Vector2(durable_retry.get(
		"platform_position",
		Vector2.ZERO
	))).is_equal(PLATFORM_START)

	player.global_position = PLATFORM_START + Vector2(0.0, -38.0)
	assert_bool(bool(tower.call("try_activate_deep_lift", player))).is_true()
	tower.call("advance_deep_lift_time", 1.0)
	var docked: Dictionary = tower.call(
		"get_central_tower_deep_lift_diagnostics"
	)
	assert_bool(bool(docked.get("upper_docked", false))).is_true()
	assert_vector(Vector2(docked.get("platform_position", Vector2.ZERO))).is_equal(
		PLATFORM_TOP
	)
	player.global_position = ENDPOINT_POSITION
	assert_bool(bool(tower.call(
		"try_activate_deep_lift_endpoint",
		player
	))).is_true()
	assert_bool(bool(tower.call(
		"try_activate_deep_lift_endpoint",
		player
	))).is_false()
	var complete: Dictionary = tower.call(
		"get_central_tower_deep_lift_diagnostics"
	)
	assert_bool(bool(complete.get("deep_lift_ascended", false))).is_true()
	assert_str(String(complete.get("objective_text", ""))).is_equal(
		"Deep Lift Secured"
	)

	var saved: Dictionary = tower.call("get_local_state")
	assert_bool(bool(saved.get(
		"central_tower_counterweight_sentry_defeated",
		false
	))).is_true()
	assert_bool(bool(saved.get(
		"central_tower_deep_lift_ascended",
		false
	))).is_true()
	var restored: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", saved)
	var restored_controller: Node = restored.get_node_or_null("DeepLiftController")
	if restored_controller != null:
		_configure_fast_lift(restored_controller)
	var restored_state: Dictionary = restored.call(
		"get_central_tower_deep_lift_diagnostics"
	)
	var restored_player: CharacterBody2D = restored.get_node_or_null(
		"Player"
	) as CharacterBody2D
	assert_bool(bool(restored_state.get("sentry_defeated", false))).is_true()
	assert_bool(bool(restored_state.get("deep_lift_ascended", false))).is_true()
	assert_bool(bool(restored_state.get("sentry_visible", true))).is_false()
	assert_vector(Vector2(restored_state.get(
		"platform_position",
		Vector2.ZERO
	))).is_equal(PLATFORM_START)
	assert_int(int(restored_state.get("activation_feedback_count", -1))).is_equal(0)
	assert_int(int(restored_state.get("defeat_feedback_count", -1))).is_equal(0)
	assert_int(int(restored_state.get("endpoint_feedback_count", -1))).is_equal(0)
	assert_array(_ability_strings(restored_player)).is_equal(abilities_before)
	if restored_player != null:
		restored_player.global_position = PLATFORM_START + Vector2(0.0, -38.0)
		assert_bool(bool(restored.call(
			"try_activate_deep_lift",
			restored_player
		))).is_true()


func _story142_complete_state() -> Dictionary:
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
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb", "parry",
		],
	}


func _configure_fast_lift(controller: Node) -> void:
	controller.set("startup_delay_sec", 0.05)
	controller.set("deploy_grace_sec", 0.05)
	controller.set("lower_travel_speed_px_sec", 480.0)
	controller.set("upper_travel_speed_px_sec", 480.0)
	controller.set("post_defeat_linger_sec", 0.05)


func _assert_sentry_frame_contract() -> void:
	if not FileAccess.file_exists(SENTRY_FRAMES_PATH):
		return
	var frames: SpriteFrames = load(SENTRY_FRAMES_PATH) as SpriteFrames
	assert_that(frames).is_not_null()
	if frames == null:
		return
	for animation_name: StringName in [
		&"idle", &"run", &"attack_tell", &"attack", &"hurt", &"death",
	]:
		assert_bool(frames.has_animation(animation_name)).is_true()
		assert_int(frames.get_frame_count(animation_name)).is_equal(3)
		for frame_index: int in range(3):
			var frame_path: String = (
				"res://assets/characters/central_tower_counterweight_sentry/%s/"
				% String(animation_name)
				+ "central_tower_counterweight_sentry_%s_%03d.png"
				% [String(animation_name), frame_index]
			)
			_assert_png_contract(frame_path, Vector2i(96, 96), true)


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


func _read_json(path: String) -> Dictionary:
	var text: String = _read_text(path)
	if text.is_empty():
		return {}
	var parsed: Variant = JSON.parse_string(text)
	return Dictionary(parsed) if parsed is Dictionary else {}


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
