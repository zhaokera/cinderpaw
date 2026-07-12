## Player Abilities Story141: Central Tower inner relay ACT slice.
extends GdUnitTestSuite

const TOWER_SCENE_PATH: String = "res://scenes/areas/central_tower_threshold.tscn"
const CONTROLLER_SCRIPT_PATH: String = (
	"res://src/gameplay/central_tower_inner_relay_controller.gd"
)
const MANTIS_GAMEPLAY_SCRIPT_PATH: String = (
	"res://src/gameplay/central_tower_relay_mantis.gd"
)
const MANTIS_GAMEPLAY_SCENE_PATH: String = (
	"res://src/gameplay/central_tower_relay_mantis.tscn"
)
const MANTIS_CHARACTER_SCRIPT_PATH: String = (
	"res://src/characters/central_tower_relay_mantis.gd"
)
const MANTIS_CHARACTER_SCENE_PATH: String = (
	"res://scenes/characters/central_tower_relay_mantis.tscn"
)
const MANTIS_FRAMES_PATH: String = (
	"res://assets/characters/central_tower_relay_mantis/"
	+ "central_tower_relay_mantis_sprite_frames.tres"
)
const BACKGROUND_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "env_central_tower_service_spine_1280x720.png"
)
const RELAY_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_service_relay_256x512.png"
)
const SHUTTER_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_observation_shutter_384x512.png"
)
const PERCH_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_mantis_perch_256x256.png"
)
const CACHE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "prop_central_tower_relay_cache_256x256.png"
)
const PULSE_PATH: String = (
	"res://assets/environment/central_tower/"
	+ "vfx_central_tower_relay_pulse_512x128.png"
)
const ENEMY_STATS_PATH: String = "res://data/combat/enemy_stats.json"
const ENEMY_SCHEMA_PATH: String = "res://data/schemas/enemy_stats.schema.json"

const MANTIS_ENTITY_ID: int = 2702
const MANTIS_CONFIG_ID: StringName = &"central_tower_relay_mantis"
const MANTIS_HITBOX_ID: StringName = &"central_tower_relay_mantis_scythe_dash"
const ACTIVATION_X: float = 1500.0
const RELAY_X: float = 1640.0
const PULSE_X: float = 1800.0
const MANTIS_X: float = 2140.0
const CACHE_X: float = 2320.0
const EXPECTED_MAX_HP: int = 40
const EXPECTED_DAMAGE: int = 12
const EXPECTED_STARTUP_FRAMES: int = 20
const EXPECTED_CACHE_GEARS: int = 20
const REQUIRED_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]

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


func test_authored_service_spine_asset_and_animation_contract() -> void:
	for path: String in [
		CONTROLLER_SCRIPT_PATH,
		MANTIS_GAMEPLAY_SCRIPT_PATH,
		MANTIS_GAMEPLAY_SCENE_PATH,
		MANTIS_CHARACTER_SCRIPT_PATH,
		MANTIS_CHARACTER_SCENE_PATH,
		MANTIS_FRAMES_PATH,
		BACKGROUND_PATH,
		RELAY_PATH,
		SHUTTER_PATH,
		PERCH_PATH,
		CACHE_PATH,
		PULSE_PATH,
	]:
		assert_bool(FileAccess.file_exists(path)).override_failure_message(
			"Story141 authored contract is missing: %s" % path
		).is_true()

	var enemy_stats: Dictionary = _read_json_dictionary(ENEMY_STATS_PATH)
	var entries: Dictionary = Dictionary(enemy_stats.get("entries", {}))
	assert_bool(entries.has(String(MANTIS_CONFIG_ID))).is_true()
	var mantis_entry: Dictionary = Dictionary(entries.get(
		String(MANTIS_CONFIG_ID),
		{}
	))
	assert_int(int(mantis_entry.get("max_hp", 0))).is_equal(EXPECTED_MAX_HP)
	var patterns: Array = Array(mantis_entry.get("attack_patterns", []))
	assert_int(patterns.size()).is_equal(1)
	if not patterns.is_empty() and patterns[0] is Dictionary:
		var pattern: Dictionary = Dictionary(patterns[0])
		assert_str(String(pattern.get("pattern_id", ""))).is_equal(
			"relay_scythe_dash"
		)
		assert_int(int(pattern.get("startup_frames", 0))).is_equal(
			EXPECTED_STARTUP_FRAMES
		)
		assert_int(int(pattern.get("damage", 0))).is_equal(EXPECTED_DAMAGE)
	var enemy_schema: Dictionary = _read_json_dictionary(ENEMY_SCHEMA_PATH)
	assert_bool(Dictionary(enemy_schema.get("entries", {})).has(
		String(MANTIS_CONFIG_ID)
	)).is_true()

	_assert_png_contract(BACKGROUND_PATH, Vector2i(1280, 720), false)
	_assert_png_contract(RELAY_PATH, Vector2i(256, 512), true)
	_assert_png_contract(SHUTTER_PATH, Vector2i(384, 512), true)
	_assert_png_contract(PERCH_PATH, Vector2i(256, 256), true)
	_assert_png_contract(CACHE_PATH, Vector2i(256, 256), true)
	_assert_png_contract(PULSE_PATH, Vector2i(512, 128), true)
	var common_bottom: int = -1
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		for frame_index: int in range(3):
			var frame_path: String = _frame_path(animation_name, frame_index)
			_assert_png_contract(frame_path, Vector2i(96, 96), true)
			if not FileAccess.file_exists(frame_path):
				continue
			var frame_bottom: int = _get_used_image_bottom(frame_path)
			if common_bottom < 0:
				common_bottom = frame_bottom
			assert_int(frame_bottom).is_equal(common_bottom)

	if FileAccess.file_exists(MANTIS_FRAMES_PATH):
		var frames: SpriteFrames = load(MANTIS_FRAMES_PATH) as SpriteFrames
		assert_that(frames).is_not_null()
		if frames != null:
			for animation_name: StringName in REQUIRED_ANIMATIONS:
				assert_bool(frames.has_animation(animation_name)).is_true()
				assert_int(frames.get_frame_count(animation_name)).is_equal(3)

	var tower: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(tower).is_not_null()
	if tower == null:
		return
	for node_path: String in [
		"ServiceSpineBackground",
		"InnerRelayController",
		"InnerRelayController/BackShutter",
		"InnerRelayController/RelayEmitter",
		"InnerRelayController/RelayPulseVisual",
		"InnerRelayController/MantisPerch",
		"InnerRelayController/CentralTowerRelayMantis",
		"InnerRelayController/ForwardShutter",
		"InnerRelayController/InnerRelayCache",
	]:
		assert_that(tower.get_node_or_null(node_path)).override_failure_message(
			"Story141 scene node is missing: %s" % node_path
		).is_not_null()
	var camera: Camera2D = tower.get_node_or_null("Player/Camera2D") as Camera2D
	var right_boundary: Node2D = tower.get_node_or_null("RightBoundary") as Node2D
	var ground_shape: CollisionShape2D = tower.get_node_or_null(
		"Ground/CollisionShape2D"
	) as CollisionShape2D
	assert_that(camera).is_not_null()
	assert_that(right_boundary).is_not_null()
	assert_that(ground_shape).is_not_null()
	if camera != null:
		assert_int(camera.limit_right).is_equal(6400)
	if right_boundary != null:
		assert_float(right_boundary.position.x).is_equal_approx(6420.0, 0.01)
	if ground_shape != null and ground_shape.shape is RectangleShape2D:
		# Story141 still owns the contiguous first two viewports.
		assert_float((ground_shape.shape as RectangleShape2D).size.x).is_equal_approx(
			2560.0,
			0.01
		)
	var scene_source: String = _read_text(TOWER_SCENE_PATH)
	assert_bool(scene_source.contains("Boss4")).is_false()
	assert_bool(scene_source.contains("[node name=\"Boss")).is_false()


func test_relay_parry_mantis_combat_and_cache_contract() -> void:
	var tower: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(tower).is_not_null()
	if tower == null:
		return
	for method_name: StringName in [
		&"try_activate_inner_relay",
		&"advance_inner_relay_time",
		&"request_relay_mantis_attack",
		&"try_claim_inner_relay_cache",
		&"get_central_tower_inner_relay_diagnostics",
	]:
		assert_bool(tower.has_method(method_name)).override_failure_message(
			"Story141 scene API is missing: %s" % String(method_name)
		).is_true()
	if not tower.has_method("try_activate_inner_relay"):
		return

	tower.call("set_local_state", _threshold_clear_state())
	var player: CharacterBody2D = tower.get_node_or_null("Player") as CharacterBody2D
	var mantis: CharacterBody2D = tower.get_node_or_null(
		"InnerRelayController/CentralTowerRelayMantis"
	) as CharacterBody2D
	var pulse: Sprite2D = tower.get_node_or_null(
		"InnerRelayController/RelayPulseVisual"
	) as Sprite2D
	var cache: Node2D = tower.get_node_or_null(
		"InnerRelayController/InnerRelayCache"
	) as Node2D
	assert_that(player).is_not_null()
	assert_that(mantis).is_not_null()
	assert_that(pulse).is_not_null()
	assert_that(cache).is_not_null()
	if player == null or mantis == null or pulse == null or cache == null:
		return

	var abilities_before: Array[String] = _ability_strings(player)
	player.global_position = Vector2(ACTIVATION_X, 552.0)
	assert_bool(bool(tower.call("try_activate_inner_relay", player))).is_true()
	await get_tree().process_frame
	var active: Dictionary = tower.call(
		"get_central_tower_inner_relay_diagnostics"
	)
	assert_str(String(active.get("encounter_state", ""))).is_equal("relay")
	assert_bool(bool(active.get("back_shutter_blocking", false))).is_true()
	assert_bool(bool(active.get("forward_shutter_blocking", false))).is_true()
	assert_str(String(active.get("pulse_state", ""))).is_equal("telegraph")

	player.global_position = Vector2(PULSE_X, 552.0)
	tower.call("advance_inner_relay_time", 0.56)
	assert_str(String(tower.call(
		"get_central_tower_inner_relay_diagnostics"
	).get("pulse_state", ""))).is_equal("strike")
	assert_bool(bool(player.call("request_parry"))).is_true()
	var reflected: Dictionary = tower.call(
		"get_central_tower_inner_relay_diagnostics"
	)
	assert_bool(bool(reflected.get("relay_parried", false))).is_true()
	assert_str(String(reflected.get("encounter_state", ""))).is_equal("active")
	assert_bool(bool(reflected.get("mantis_visible", false))).is_true()
	assert_bool(bool(reflected.get("mantis_has_target", false))).is_true()
	assert_str(String(reflected.get("pulse_state", ""))).is_equal("complete")
	assert_vector(mantis.global_position).is_equal(Vector2(MANTIS_X, 576.0))

	for _frame: int in range(19):
		player.call("_physics_process", 1.0 / 60.0)
	mantis.set_physics_process(false)
	assert_bool(bool(tower.call("request_relay_mantis_attack"))).is_true()
	mantis.call("advance_attack_frames", EXPECTED_STARTUP_FRAMES)
	assert_bool(bool(mantis.call("is_enemy_attack_active"))).is_true()
	var enemy_collision: CollisionComponent = mantis.call(
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
	enemy_collision.process_detection_frame({
		MANTIS_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	assert_int(int(player.call("get_current_hp"))).is_equal(
		hp_before - EXPECTED_DAMAGE
	)

	assert_bool(bool(tower.call(
		"apply_damage",
		MANTIS_ENTITY_ID,
		999,
		{"source": &"story141_test"}
	))).is_true()
	await get_tree().process_frame
	var defeated: Dictionary = tower.call(
		"get_central_tower_inner_relay_diagnostics"
	)
	assert_str(String(defeated.get("encounter_state", ""))).is_equal("cleared")
	assert_bool(bool(defeated.get("back_shutter_blocking", true))).is_false()
	assert_bool(bool(defeated.get("forward_shutter_blocking", true))).is_false()
	assert_bool(bool(defeated.get("cache_available", false))).is_true()

	player.global_position = Vector2(CACHE_X, 552.0)
	assert_bool(bool(tower.call("try_claim_inner_relay_cache", player))).is_true()
	assert_bool(bool(tower.call("try_claim_inner_relay_cache", player))).is_false()
	var claimed: Dictionary = tower.call(
		"get_central_tower_inner_relay_diagnostics"
	)
	assert_str(String(claimed.get("encounter_state", ""))).is_equal("claimed")
	assert_bool(bool(claimed.get("cache_claimed", false))).is_true()
	assert_int(int(Dictionary(claimed.get("last_reward", {})).get(
		"gears",
		0
	))).is_equal(EXPECTED_CACHE_GEARS)
	assert_array(_ability_strings(player)).is_equal(abilities_before)


func test_miss_respawn_reset_and_death_window_clear_are_coherent() -> void:
	var tower: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(tower).is_not_null()
	if tower == null or not tower.has_method("try_activate_inner_relay"):
		assert_bool(false).override_failure_message(
			"Story141 production API is not implemented"
		).is_true()
		return
	tower.call("set_local_state", _threshold_clear_state())
	var player: CharacterBody2D = tower.get_node_or_null("Player") as CharacterBody2D
	var arrival: Marker2D = tower.get_node_or_null(
		"NeonRooftopsThresholdArrival"
	) as Marker2D
	var mantis: CharacterBody2D = tower.get_node_or_null(
		"InnerRelayController/CentralTowerRelayMantis"
	) as CharacterBody2D
	assert_that(player).is_not_null()
	assert_that(arrival).is_not_null()
	assert_that(mantis).is_not_null()
	if player == null or arrival == null or mantis == null:
		return

	player.global_position = Vector2(ACTIVATION_X, 552.0)
	assert_bool(bool(tower.call("try_activate_inner_relay", player))).is_true()
	player.global_position = Vector2(PULSE_X, 552.0)
	var hp_before_miss: int = int(player.call("get_current_hp"))
	tower.call("advance_inner_relay_time", 0.56)
	tower.call("advance_inner_relay_time", 0.19)
	var missed: Dictionary = tower.call(
		"get_central_tower_inner_relay_diagnostics"
	)
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before_miss - 8)
	assert_int(int(missed.get("miss_count", 0))).is_equal(1)
	assert_bool(bool(missed.get("relay_parried", true))).is_false()

	tower.call("advance_inner_relay_time", 0.56)
	tower.call("advance_inner_relay_time", 0.56)
	assert_bool(bool(player.call("request_parry"))).is_true()
	assert_bool(bool(tower.call(
		"get_central_tower_inner_relay_diagnostics"
	).get("relay_parried", false))).is_true()
	var mantis_start: Vector2 = mantis.position
	assert_bool(bool(tower.call(
		"apply_damage",
		MANTIS_ENTITY_ID,
		12,
		{"source": &"story141_partial_damage"}
	))).is_true()
	player.call("apply_damage", 999, {"source": &"story141_respawn"})
	tower.call("advance_central_tower_respawn_flow", 1.6)
	await get_tree().process_frame
	var reset: Dictionary = tower.call(
		"get_central_tower_inner_relay_diagnostics"
	)
	assert_int(int(player.call("get_current_hp"))).is_equal(50)
	assert_vector(player.global_position).is_equal(arrival.global_position)
	assert_str(String(reset.get("encounter_state", ""))).is_equal("ready")
	assert_bool(bool(reset.get("relay_activated", true))).is_false()
	assert_bool(bool(reset.get("relay_parried", true))).is_false()
	assert_bool(bool(reset.get("mantis_activated", true))).is_false()
	assert_int(int(reset.get("mantis_current_hp", 0))).is_equal(EXPECTED_MAX_HP)
	assert_vector(Vector2(reset.get("mantis_position", Vector2.ZERO))).is_equal(
		mantis_start
	)
	assert_bool(bool(reset.get("back_shutter_blocking", true))).is_false()
	assert_bool(bool(reset.get("forward_shutter_blocking", true))).is_false()

	tower.call("advance_central_tower_respawn_flow", 2.1)
	player.global_position = Vector2(ACTIVATION_X, 552.0)
	assert_bool(bool(tower.call("try_activate_inner_relay", player))).is_true()
	player.global_position = Vector2(PULSE_X, 552.0)
	tower.call("advance_inner_relay_time", 0.56)
	var retry_combat: CombatComponent = player.call(
		"get_combat_component"
	) as CombatComponent
	assert_that(retry_combat).is_not_null()
	if retry_combat == null:
		return
	# The deterministic GameFlow clock does not tick child physics components.
	retry_combat.advance_parry_frames(
		CombatComponent.PARRY_LATE_END_FRAME + 1
	)
	assert_int(retry_combat.get_current_state()).override_failure_message(
		"Respawn retry must begin from the Core combat IDLE state."
	).is_equal(CombatComponent.CombatState.IDLE)
	assert_float(float(player.call(
		"get_ability_cooldown_remaining",
		&"parry"
	))).is_equal(0.0)
	assert_bool(bool(player.call("request_parry"))).is_true()
	player.call("apply_damage", 999, {"source": &"story141_death_window"})
	assert_bool(bool(tower.call(
		"apply_damage",
		MANTIS_ENTITY_ID,
		999,
		{"source": &"story141_death_window_clear"}
	))).is_true()
	tower.call("advance_central_tower_respawn_flow", 1.6)
	await get_tree().process_frame
	var durable: Dictionary = tower.call(
		"get_central_tower_inner_relay_diagnostics"
	)
	assert_str(String(durable.get("encounter_state", ""))).is_equal("cleared")
	assert_bool(bool(durable.get("mantis_defeated", false))).is_true()
	assert_bool(bool(durable.get("cache_available", false))).is_true()

	var saved: Dictionary = tower.call("get_local_state")
	var restored: Node = _instantiate_scene(TOWER_SCENE_PATH)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", saved)
	var restored_diagnostics: Dictionary = restored.call(
		"get_central_tower_inner_relay_diagnostics"
	)
	assert_str(String(restored_diagnostics.get(
		"encounter_state",
		""
	))).is_equal("cleared")
	assert_int(int(restored_diagnostics.get(
		"activation_feedback_count",
		-1
	))).is_equal(0)
	assert_int(int(restored_diagnostics.get(
		"defeat_feedback_count",
		-1
	))).is_equal(0)
	assert_int(int(restored_diagnostics.get(
		"reward_feedback_count",
		-1
	))).is_equal(0)


func _threshold_clear_state() -> Dictionary:
	return {
		"central_tower_threshold_roost_activated": true,
		"central_tower_threshold_guard_activated": true,
		"central_tower_threshold_guard_defeated": true,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb", "parry",
		],
	}


func _frame_path(animation_name: StringName, frame_index: int) -> String:
	return (
		"res://assets/characters/central_tower_relay_mantis/%s/"
		% String(animation_name)
		+ "central_tower_relay_mantis_%s_%03d.png"
		% [String(animation_name), frame_index]
	)


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


func _read_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}


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


func _get_used_image_bottom(path: String) -> int:
	var image := Image.new()
	if image.load(path) != OK:
		return -1
	var used_rect: Rect2i = image.get_used_rect()
	return used_rect.position.y + used_rect.size.y


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method("stop_all_runtime_audio"):
		audio_system.call("stop_all_runtime_audio")
