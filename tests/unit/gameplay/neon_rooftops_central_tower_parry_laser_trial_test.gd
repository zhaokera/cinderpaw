## Player Abilities Story139: Central Tower outer parry-laser trial.
extends GdUnitTestSuite

const ROOFTOPS_SCENE_PATH: String = (
	"res://scenes/areas/neon_rooftops_entry.tscn"
)
const CONTROLLER_SCRIPT_PATH: String = (
	"res://src/gameplay/neon_tower_parry_trial_controller.gd"
)
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "env_neon_tower_parry_trial_1280x720.png"
)
const GATE_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_tower_laser_gate_384x512.png"
)
const PULSE_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "vfx_neon_tower_laser_pulse_512x128.png"
)
const ENDPOINT_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_tower_threshold_beacon_256x384.png"
)
const CONTROLLER_NODE_PATH: String = "TowerParryTrialController"
const EMITTER_NODE_PATH: String = "TowerParryTrialController/LaserEmitter"
const GATE_NODE_PATH: String = "TowerParryTrialController/TowerLaserGate"
const ENDPOINT_NODE_PATH: String = (
	"TowerParryTrialController/TowerThresholdEndpoint"
)
const EXPECTED_ROUTE_WIDTH: int = 5120
const EXPECTED_RIGHT_WALL_X: float = 5100.0
const EXPECTED_ACCESS_SEAL_X: float = 3860.0
const EXPECTED_TOWER_GATE_X: float = 4740.0
const EXPECTED_PARRY_COUNT: int = 3
const EXPECTED_MISS_DAMAGE: int = 18
const EXPECTED_TELEGRAPH_SEC: float = 0.60
const EXPECTED_STRIKE_SEC: float = 0.18
const EXPECTED_RECOVERY_SEC: float = 0.55

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


func test_authored_tower_parry_trial_assets_geometry_and_animation_contract() -> void:
	assert_bool(FileAccess.file_exists(CONTROLLER_SCRIPT_PATH)).is_true()
	assert_bool(FileAccess.file_exists(BACKGROUND_TEXTURE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(GATE_TEXTURE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(PULSE_TEXTURE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(ENDPOINT_TEXTURE_PATH)).is_true()
	_assert_png_contract(
		BACKGROUND_TEXTURE_PATH,
		Vector2i(1280, 720),
		Image.ALPHA_NONE
	)
	_assert_png_contract(
		GATE_TEXTURE_PATH,
		Vector2i(384, 512),
		Image.ALPHA_BLEND
	)
	_assert_png_contract(
		PULSE_TEXTURE_PATH,
		Vector2i(512, 128),
		Image.ALPHA_BLEND
	)
	_assert_png_contract(
		ENDPOINT_TEXTURE_PATH,
		Vector2i(256, 384),
		Image.ALPHA_BLEND
	)

	var rooftops: Node = _instantiate_scene(ROOFTOPS_SCENE_PATH)
	assert_that(rooftops).is_not_null()
	if rooftops == null:
		return
	for node_path: String in [
		CONTROLLER_NODE_PATH,
		EMITTER_NODE_PATH,
		GATE_NODE_PATH,
		ENDPOINT_NODE_PATH,
		"TowerParryTrialController/AccessSeal",
		"TowerParryTrialController/TrialZone/CollisionShape2D",
		"TowerParryTrialController/LaserPulseVisual",
		"TowerParryTrialFloor/CollisionShape2D",
	]:
		assert_that(rooftops.get_node_or_null(node_path)).is_not_null()
	assert_bool(rooftops.has_method(
		"get_central_tower_parry_trial_diagnostics"
	)).is_true()
	var camera: Camera2D = rooftops.get_node_or_null(
		"Player/Camera2D"
	) as Camera2D
	assert_that(camera).is_not_null()
	if camera != null:
		assert_int(camera.limit_right).is_equal(EXPECTED_ROUTE_WIDTH)
	var top_shape: CollisionShape2D = rooftops.get_node_or_null(
		"TopBoundary/CollisionShape2D"
	) as CollisionShape2D
	assert_that(top_shape).is_not_null()
	if top_shape != null and top_shape.shape is RectangleShape2D:
		assert_float((top_shape.shape as RectangleShape2D).size.x).is_equal_approx(
			float(EXPECTED_ROUTE_WIDTH),
			0.001
		)
	var right_boundary: Node2D = rooftops.get_node_or_null(
		"RightBoundary"
	) as Node2D
	assert_that(right_boundary).is_not_null()
	if right_boundary != null:
		assert_float(right_boundary.position.x).is_equal_approx(
			EXPECTED_RIGHT_WALL_X,
			0.001
		)
	var player_sprite: AnimatedSprite2D = rooftops.get_node_or_null(
		"Player/Sprite"
	) as AnimatedSprite2D
	assert_that(player_sprite).is_not_null()
	if player_sprite != null and player_sprite.sprite_frames != null:
		assert_bool(player_sprite.sprite_frames.has_animation(&"parry")).is_true()
		assert_int(player_sprite.sprite_frames.get_frame_count(&"parry")).is_greater_equal(3)
	if not rooftops.has_method("get_central_tower_parry_trial_diagnostics"):
		return
	var diagnostics: Dictionary = rooftops.call(
		"get_central_tower_parry_trial_diagnostics"
	)
	assert_int(int(diagnostics.get("route_width_px", 0))).is_equal(
		EXPECTED_ROUTE_WIDTH
	)
	assert_float(float(diagnostics.get("right_wall_x", 0.0))).is_equal_approx(
		EXPECTED_RIGHT_WALL_X,
		0.001
	)
	assert_float(float(diagnostics.get("access_seal_x", 0.0))).is_equal_approx(
		EXPECTED_ACCESS_SEAL_X,
		0.001
	)
	assert_float(float(diagnostics.get("tower_gate_x", 0.0))).is_equal_approx(
		EXPECTED_TOWER_GATE_X,
		0.001
	)
	assert_int(int(diagnostics.get("required_parries", 0))).is_equal(
		EXPECTED_PARRY_COUNT
	)
	assert_int(int(diagnostics.get("miss_damage", 0))).is_equal(
		EXPECTED_MISS_DAMAGE
	)
	assert_float(float(diagnostics.get(
		"telegraph_duration_sec",
		0.0
	))).is_equal_approx(EXPECTED_TELEGRAPH_SEC, 0.001)
	assert_float(float(diagnostics.get(
		"strike_duration_sec",
		0.0
	))).is_equal_approx(EXPECTED_STRIKE_SEC, 0.001)
	assert_float(float(diagnostics.get(
		"recovery_duration_sec",
		0.0
	))).is_equal_approx(EXPECTED_RECOVERY_SEC, 0.001)
	assert_str(String(diagnostics.get("controller_script_path", ""))).is_equal(
		CONTROLLER_SCRIPT_PATH
	)
	assert_str(String(diagnostics.get("background_texture_path", ""))).is_equal(
		BACKGROUND_TEXTURE_PATH
	)
	assert_str(String(diagnostics.get("gate_texture_path", ""))).is_equal(
		GATE_TEXTURE_PATH
	)
	assert_str(String(diagnostics.get("pulse_texture_path", ""))).is_equal(
		PULSE_TEXTURE_PATH
	)
	assert_str(String(diagnostics.get("endpoint_texture_path", ""))).is_equal(
		ENDPOINT_TEXTURE_PATH
	)


func test_story138_route_proof_starts_trial_and_missed_pulse_deals_damage() -> void:
	var rooftops: Node = _instantiate_scene(ROOFTOPS_SCENE_PATH)
	assert_that(rooftops).is_not_null()
	if rooftops == null:
		return
	for method_name: String in [
		"try_activate_central_tower_parry_trial",
		"advance_central_tower_parry_trial",
		"get_central_tower_parry_trial_diagnostics",
	]:
		assert_bool(rooftops.has_method(method_name)).is_true()
	if not rooftops.has_method("try_activate_central_tower_parry_trial"):
		return
	var controller: Node = rooftops.get_node_or_null(CONTROLLER_NODE_PATH)
	var player: Node2D = rooftops.get_node_or_null("Player") as Node2D
	var emitter: Node2D = rooftops.get_node_or_null(EMITTER_NODE_PATH) as Node2D
	assert_that(controller).is_not_null()
	assert_that(player).is_not_null()
	assert_that(emitter).is_not_null()
	if controller == null or player == null or emitter == null:
		return
	controller.set_process(false)
	var prior_state: Dictionary = _prerequisite_state(false)
	rooftops.call("set_local_state", prior_state)
	player.global_position = emitter.global_position
	assert_bool(bool(rooftops.call(
		"try_activate_central_tower_parry_trial",
		player
	))).is_false()
	var locked: Dictionary = rooftops.call(
		"get_central_tower_parry_trial_diagnostics"
	)
	assert_bool(bool(locked.get("route_unlocked", true))).is_false()
	assert_bool(bool(locked.get("access_seal_blocking", false))).is_true()

	rooftops.call("set_local_state", _prerequisite_state(true))
	player.global_position = emitter.global_position
	assert_bool(bool(rooftops.call(
		"try_activate_central_tower_parry_trial",
		player
	))).is_true()
	var hp_before: int = int(player.call("get_current_hp"))
	rooftops.call("advance_central_tower_parry_trial", 0.61)
	var strike: Dictionary = rooftops.call(
		"get_central_tower_parry_trial_diagnostics"
	)
	assert_str(String(strike.get("pulse_state", ""))).is_equal("strike")
	rooftops.call("advance_central_tower_parry_trial", 0.19)
	var missed: Dictionary = rooftops.call(
		"get_central_tower_parry_trial_diagnostics"
	)
	assert_int(int(player.call("get_current_hp"))).is_equal(
		hp_before - EXPECTED_MISS_DAMAGE
	)
	assert_int(int(missed.get("miss_count", 0))).is_equal(1)
	assert_int(int(missed.get("successful_parries", -1))).is_equal(0)
	assert_str(String(missed.get("gate_state", ""))).is_equal("unlockable")
	assert_bool(bool(missed.get("gate_collision_blocking", false))).is_true()


func test_three_real_parries_unlock_threshold_and_restore_without_replay() -> void:
	var rooftops: Node = _instantiate_scene(ROOFTOPS_SCENE_PATH)
	assert_that(rooftops).is_not_null()
	if rooftops == null:
		return
	for method_name: String in [
		"try_activate_central_tower_parry_trial",
		"advance_central_tower_parry_trial",
		"try_activate_central_tower_threshold",
		"get_central_tower_parry_trial_diagnostics",
	]:
		assert_bool(rooftops.has_method(method_name)).is_true()
	if not rooftops.has_method("try_activate_central_tower_parry_trial"):
		return
	var controller: Node = rooftops.get_node_or_null(CONTROLLER_NODE_PATH)
	var player: Node2D = rooftops.get_node_or_null("Player") as Node2D
	var emitter: Node2D = rooftops.get_node_or_null(EMITTER_NODE_PATH) as Node2D
	var endpoint: Node2D = rooftops.get_node_or_null(
		ENDPOINT_NODE_PATH
	) as Node2D
	assert_that(controller).is_not_null()
	assert_that(player).is_not_null()
	assert_that(emitter).is_not_null()
	assert_that(endpoint).is_not_null()
	if controller == null or player == null or emitter == null or endpoint == null:
		return
	rooftops.call("set_local_state", _prerequisite_state(true))
	controller.set_process(false)
	player.global_position = emitter.global_position
	assert_bool(bool(rooftops.call(
		"try_activate_central_tower_parry_trial",
		player
	))).is_true()

	for parry_index: int in range(EXPECTED_PARRY_COUNT):
		rooftops.call("advance_central_tower_parry_trial", 0.61)
		var strike: Dictionary = rooftops.call(
			"get_central_tower_parry_trial_diagnostics"
		)
		assert_str(String(strike.get("pulse_state", ""))).is_equal("strike")
		assert_bool(bool(player.call("request_parry"))).is_true()
		var reflected: Dictionary = rooftops.call(
			"get_central_tower_parry_trial_diagnostics"
		)
		assert_int(int(reflected.get("successful_parries", 0))).is_equal(
			parry_index + 1
		)
		for _frame: int in range(20):
			await get_tree().physics_frame
		if parry_index < EXPECTED_PARRY_COUNT - 1:
			rooftops.call("advance_central_tower_parry_trial", 0.56)

	var unlocked: Dictionary = rooftops.call(
		"get_central_tower_parry_trial_diagnostics"
	)
	assert_int(int(unlocked.get("successful_parries", 0))).is_equal(
		EXPECTED_PARRY_COUNT
	)
	assert_str(String(unlocked.get("gate_state", ""))).is_equal("unlocked")
	assert_bool(bool(unlocked.get("gate_collision_blocking", true))).is_false()
	assert_int(int(unlocked.get("parry_feedback_count", 0))).is_equal(
		EXPECTED_PARRY_COUNT
	)
	assert_int(int(unlocked.get("gate_unlock_feedback_count", 0))).is_equal(1)
	assert_str(String(unlocked.get("objective_text", ""))).is_equal(
		"Enter Central Tower Threshold"
	)

	player.global_position = endpoint.global_position
	assert_bool(bool(rooftops.call(
		"try_activate_central_tower_threshold",
		player
	))).is_true()
	assert_bool(bool(rooftops.call(
		"try_activate_central_tower_threshold",
		player
	))).is_false()
	var saved: Dictionary = rooftops.call("get_local_state")
	assert_bool(bool(saved.get(
		"neon_rooftops_central_tower_gate_unlocked",
		false
	))).is_true()
	assert_bool(bool(saved.get(
		"neon_rooftops_central_tower_threshold_secured",
		false
	))).is_true()
	assert_int(int(saved.get(
		"neon_rooftops_central_tower_parry_count",
		0
	))).is_equal(EXPECTED_PARRY_COUNT)
	assert_bool(bool(saved.get(
		"neon_rooftops_relay_spire_traversed",
		false
	))).is_true()

	var restored: Node = _instantiate_scene(ROOFTOPS_SCENE_PATH)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", saved)
	var restored_state: Dictionary = restored.call(
		"get_central_tower_parry_trial_diagnostics"
	)
	assert_bool(bool(restored_state.get("route_unlocked", false))).is_true()
	assert_bool(bool(restored_state.get("threshold_secured", false))).is_true()
	assert_str(String(restored_state.get("gate_state", ""))).is_equal("unlocked")
	assert_int(int(restored_state.get("successful_parries", 0))).is_equal(
		EXPECTED_PARRY_COUNT
	)
	assert_int(int(restored_state.get("parry_feedback_count", -1))).is_equal(0)
	assert_int(int(restored_state.get(
		"gate_unlock_feedback_count",
		-1
	))).is_equal(0)
	assert_int(int(restored_state.get("threshold_feedback_count", -1))).is_equal(0)
	assert_str(String(restored_state.get("objective_text", ""))).is_equal(
		"Central Tower Gate Secured"
	)


func _prerequisite_state(route_complete: bool) -> Dictionary:
	return {
		"neon_rooftops_entry_arrived": true,
		"neon_rooftops_entry_traversed": true,
		"neon_rooftops_signal_rat_encounter_activated": true,
		"neon_rooftops_signal_rat_defeated": true,
		"neon_rooftops_signal_cache_claimed": true,
		"neon_rooftops_relay_spire_roost_activated": true,
		"neon_rooftops_relay_spire_traversed": route_complete,
		"neon_rooftops_relay_spire_last_savepoint": {
			"id": "neon_rooftops_relay_spire_roost",
			"scene_id": "area_05_neon_rooftops",
			"spawn_point": "relay_spire_roost",
			"position": {"x": 2760.0, "y": 413.0},
		},
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb", "parry",
		],
	}


func _assert_png_contract(
	path: String,
	expected_size: Vector2i,
	expected_alpha: Image.AlphaMode
) -> void:
	if not FileAccess.file_exists(path):
		return
	var image := Image.new()
	assert_int(image.load(path)).is_equal(OK)
	assert_int(image.get_width()).is_equal(expected_size.x)
	assert_int(image.get_height()).is_equal(expected_size.y)
	assert_int(image.detect_alpha()).is_equal(expected_alpha)


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


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null and audio_system.has_method("stop_all_runtime_audio"):
		audio_system.call("stop_all_runtime_audio")
