## Player Abilities Story 138: Relay Spire savepoint and wall-climb traverse.
extends GdUnitTestSuite

const ROOFTOPS_SCENE_PATH: String = (
	"res://scenes/areas/neon_rooftops_entry.tscn"
)
const CONTROLLER_SCRIPT_PATH: String = (
	"res://src/gameplay/neon_relay_spire_controller.gd"
)
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "env_neon_relay_spire_1280x720.png"
)
const ROOST_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_relay_spire_roost_256x256.png"
)
const SPIRE_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_magnetic_relay_spire_256x512.png"
)
const ENDPOINT_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_tower_approach_beacon_256x384.png"
)
const CONTROLLER_NODE_PATH: String = "RelaySpireController"
const ROOST_NODE_PATH: String = "RelaySpireController/RelaySpireRoost"
const ENDPOINT_NODE_PATH: String = "RelaySpireController/TowerApproachEndpoint"
const ACCESS_SEAL_NODE_PATH: String = "RelaySpireController/AccessSeal"
const ROOFTOPS_SCENE_ID: StringName = &"area_05_neon_rooftops"
const ROOST_ID: StringName = &"neon_rooftops_relay_spire_roost"
const ROOST_SPAWN_POINT: StringName = &"relay_spire_roost"
const EXPECTED_ROUTE_WIDTH: int = 3840
const EXPECTED_RIGHT_WALL_X: float = 3820.0
const EXPECTED_GAP_START_X: float = 2860.0
const EXPECTED_GAP_END_X: float = 3460.0

var _spawned_nodes: Array[Node] = []


class FakeSaveSystem:
	extends RefCounted

	var auto_save_calls: Array[Dictionary] = []

	func auto_save(
		player_state: Dictionary = {},
		world_state: Dictionary = {},
		settings: Dictionary = {}
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


func test_authored_relay_spire_route_assets_and_controller_contract() -> void:
	assert_bool(FileAccess.file_exists(CONTROLLER_SCRIPT_PATH)).is_true()
	assert_bool(FileAccess.file_exists(BACKGROUND_TEXTURE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(ROOST_TEXTURE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(SPIRE_TEXTURE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(ENDPOINT_TEXTURE_PATH)).is_true()
	_assert_png_contract(
		BACKGROUND_TEXTURE_PATH,
		Vector2i(1280, 720),
		Image.ALPHA_NONE
	)
	_assert_png_contract(
		ROOST_TEXTURE_PATH,
		Vector2i(256, 256),
		Image.ALPHA_BLEND
	)
	_assert_png_contract(
		SPIRE_TEXTURE_PATH,
		Vector2i(256, 512),
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
	assert_bool(rooftops.has_method(
		"get_neon_relay_spire_diagnostics"
	)).is_true()
	var controller: Node = rooftops.get_node_or_null(CONTROLLER_NODE_PATH)
	assert_that(controller).is_not_null()
	assert_that(rooftops.get_node_or_null(ROOST_NODE_PATH)).is_not_null()
	assert_that(rooftops.get_node_or_null(ENDPOINT_NODE_PATH)).is_not_null()
	assert_that(rooftops.get_node_or_null(ACCESS_SEAL_NODE_PATH)).is_not_null()
	assert_that(rooftops.get_node_or_null(
		"RelaySpireMagneticWall/CollisionShape2D"
	)).is_not_null()
	assert_that(rooftops.get_node_or_null(
		"RelaySpireController/FallZone/CollisionShape2D"
	)).is_not_null()
	assert_that(rooftops.get_node_or_null(
		"RelaySpireUpperPerch/CollisionShape2D"
	)).is_not_null()
	assert_that(rooftops.get_node_or_null(
		"RelaySpireExitRoof/CollisionShape2D"
	)).is_not_null()
	var camera: Camera2D = rooftops.get_node_or_null(
		"Player/Camera2D"
	) as Camera2D
	assert_that(camera).is_not_null()
	if camera != null:
		assert_int(camera.limit_right).is_greater_equal(EXPECTED_ROUTE_WIDTH)
	var top_shape: CollisionShape2D = rooftops.get_node_or_null(
		"TopBoundary/CollisionShape2D"
	) as CollisionShape2D
	assert_that(top_shape).is_not_null()
	if top_shape != null and top_shape.shape is RectangleShape2D:
		assert_float((top_shape.shape as RectangleShape2D).size.x).is_greater_equal(
			float(EXPECTED_ROUTE_WIDTH),
		)
	if not rooftops.has_method("get_neon_relay_spire_diagnostics"):
		return
	var diagnostics: Dictionary = rooftops.call(
		"get_neon_relay_spire_diagnostics"
	)
	assert_int(int(diagnostics.get("route_width_px", 0))).is_equal(
		EXPECTED_ROUTE_WIDTH
	)
	assert_float(float(diagnostics.get("right_wall_x", 0.0))).is_equal_approx(
		EXPECTED_RIGHT_WALL_X,
		0.001
	)
	assert_float(float(diagnostics.get("gap_start_x", 0.0))).is_equal_approx(
		EXPECTED_GAP_START_X,
		0.001
	)
	assert_float(float(diagnostics.get("gap_end_x", 0.0))).is_equal_approx(
		EXPECTED_GAP_END_X,
		0.001
	)
	assert_str(String(diagnostics.get("controller_script_path", ""))).is_equal(
		CONTROLLER_SCRIPT_PATH
	)
	assert_str(String(diagnostics.get("background_texture_path", ""))).is_equal(
		BACKGROUND_TEXTURE_PATH
	)
	assert_str(String(diagnostics.get("roost_texture_path", ""))).is_equal(
		ROOST_TEXTURE_PATH
	)
	assert_str(String(diagnostics.get("spire_texture_path", ""))).is_equal(
		SPIRE_TEXTURE_PATH
	)
	assert_str(String(diagnostics.get("endpoint_texture_path", ""))).is_equal(
		ENDPOINT_TEXTURE_PATH
	)


func test_cache_claim_opens_route_and_roost_autosaves_once() -> void:
	var rooftops: Node = _instantiate_scene(ROOFTOPS_SCENE_PATH)
	assert_that(rooftops).is_not_null()
	if rooftops == null:
		return
	for method_name: String in [
		"configure_neon_relay_spire_save_system_runtime",
		"try_activate_neon_relay_spire_roost",
		"get_neon_relay_spire_diagnostics",
	]:
		assert_bool(rooftops.has_method(method_name)).is_true()
	if not rooftops.has_method("try_activate_neon_relay_spire_roost"):
		return
	var save_system := FakeSaveSystem.new()
	assert_bool(bool(rooftops.call(
		"configure_neon_relay_spire_save_system_runtime",
		save_system
	))).is_true()
	var player: Node2D = rooftops.get_node_or_null("Player") as Node2D
	var roost: Node2D = rooftops.get_node_or_null(ROOST_NODE_PATH) as Node2D
	assert_that(player).is_not_null()
	assert_that(roost).is_not_null()
	if player == null or roost == null:
		return

	rooftops.call("set_local_state", {
		"neon_rooftops_entry_traversed": true,
		"neon_rooftops_signal_rat_encounter_activated": true,
		"neon_rooftops_signal_rat_defeated": true,
		"neon_rooftops_signal_cache_claimed": false,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb",
		],
	})
	player.global_position = roost.global_position
	assert_bool(bool(rooftops.call(
		"try_activate_neon_relay_spire_roost",
		player
	))).is_false()
	var locked: Dictionary = rooftops.call("get_neon_relay_spire_diagnostics")
	assert_bool(bool(locked.get("route_unlocked", true))).is_false()
	assert_bool(bool(locked.get("access_seal_blocking", false))).is_true()

	rooftops.call("set_local_state", {
		"neon_rooftops_entry_traversed": true,
		"neon_rooftops_signal_rat_encounter_activated": true,
		"neon_rooftops_signal_rat_defeated": true,
		"neon_rooftops_signal_cache_claimed": true,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb",
		],
	})
	player.call("apply_damage", 35, {"source": &"story138_test_setup"})
	var max_hp: int = int(player.call("get_max_hp"))
	player.global_position = roost.global_position + Vector2(220.0, 0.0)
	assert_bool(bool(rooftops.call(
		"try_activate_neon_relay_spire_roost",
		player
	))).is_false()
	player.global_position = roost.global_position
	assert_bool(bool(rooftops.call(
		"try_activate_neon_relay_spire_roost",
		player
	))).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(max_hp)
	assert_bool(bool(rooftops.call(
		"try_activate_neon_relay_spire_roost",
		player
	))).is_false()
	var active: Dictionary = rooftops.call("get_neon_relay_spire_diagnostics")
	assert_bool(bool(active.get("route_unlocked", false))).is_true()
	assert_bool(bool(active.get("access_seal_blocking", true))).is_false()
	assert_bool(bool(active.get("roost_activated", false))).is_true()
	assert_str(String(active.get("roost_id", ""))).is_equal(String(ROOST_ID))
	assert_str(String(active.get("roost_scene_id", ""))).is_equal(
		String(ROOFTOPS_SCENE_ID)
	)
	assert_str(String(active.get("roost_spawn_point", ""))).is_equal(
		String(ROOST_SPAWN_POINT)
	)
	assert_int(int(active.get("autosave_request_count", 0))).is_equal(1)
	assert_int(int(active.get("audio_request_count", 0))).is_equal(1)
	assert_int(save_system.auto_save_calls.size()).is_equal(1)
	assert_str(String(active.get("objective_text", ""))).is_equal(
		"Climb Relay Spire"
	)


func test_fall_revive_endpoint_and_restore_preserve_rooftop_progress() -> void:
	var rooftops: Node = _instantiate_scene(ROOFTOPS_SCENE_PATH)
	assert_that(rooftops).is_not_null()
	if rooftops == null:
		return
	for method_name: String in [
		"try_activate_neon_relay_spire_roost",
		"apply_neon_relay_spire_fall",
		"advance_neon_relay_spire_respawn_flow",
		"try_activate_neon_relay_spire_endpoint",
		"get_neon_relay_spire_diagnostics",
	]:
		assert_bool(rooftops.has_method(method_name)).is_true()
	if not rooftops.has_method("apply_neon_relay_spire_fall"):
		return
	rooftops.call("set_local_state", {
		"neon_rooftops_entry_traversed": true,
		"neon_rooftops_signal_rat_encounter_activated": true,
		"neon_rooftops_signal_rat_defeated": true,
		"neon_rooftops_signal_cache_claimed": true,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb",
		],
	})
	var player: Node2D = rooftops.get_node_or_null("Player") as Node2D
	var roost: Node2D = rooftops.get_node_or_null(ROOST_NODE_PATH) as Node2D
	var endpoint: Node2D = rooftops.get_node_or_null(
		ENDPOINT_NODE_PATH
	) as Node2D
	assert_that(player).is_not_null()
	assert_that(roost).is_not_null()
	assert_that(endpoint).is_not_null()
	if player == null or roost == null or endpoint == null:
		return
	player.global_position = roost.global_position
	assert_bool(bool(rooftops.call(
		"try_activate_neon_relay_spire_roost",
		player
	))).is_true()
	assert_bool(bool(rooftops.call(
		"apply_neon_relay_spire_fall",
		player
	))).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(0)
	rooftops.call("advance_neon_relay_spire_respawn_flow", 1.51)
	var expected_hp: int = maxi(
		1,
		int(floor(float(player.call("get_max_hp")) * 0.5))
	)
	assert_int(int(player.call("get_current_hp"))).is_equal(expected_hp)
	assert_vector(player.global_position).is_equal(roost.global_position)
	var revived: Dictionary = rooftops.call("get_neon_relay_spire_diagnostics")
	assert_str(String(revived.get("respawn_state", ""))).is_equal("revived")
	assert_bool(bool(revived.get("player_control_locked", false))).is_true()
	assert_float(float(revived.get(
		"invincibility_remaining_sec",
		0.0
	))).is_equal_approx(2.0, 0.001)
	assert_str(String(Dictionary(revived.get(
		"last_selected_respawn_point",
		{}
	)).get("spawn_point", ""))).is_equal(String(ROOST_SPAWN_POINT))
	rooftops.call("advance_neon_relay_spire_respawn_flow", 2.01)
	var playing: Dictionary = rooftops.call("get_neon_relay_spire_diagnostics")
	assert_str(String(playing.get("respawn_state", ""))).is_equal("playing")
	assert_bool(bool(playing.get("player_control_locked", true))).is_false()

	player.global_position = endpoint.global_position
	assert_bool(bool(rooftops.call(
		"try_activate_neon_relay_spire_endpoint",
		player
	))).is_true()
	assert_bool(bool(rooftops.call(
		"try_activate_neon_relay_spire_endpoint",
		player
	))).is_false()
	var secured: Dictionary = rooftops.call("get_neon_relay_spire_diagnostics")
	assert_bool(bool(secured.get("traversed", false))).is_true()
	assert_str(String(secured.get("objective_text", ""))).is_equal(
		"Tower Approach Reached"
	)
	var saved: Dictionary = rooftops.call("get_local_state")
	assert_bool(bool(saved.get(
		"neon_rooftops_signal_cache_claimed",
		false
	))).is_true()
	assert_bool(bool(saved.get(
		"neon_rooftops_relay_spire_roost_activated",
		false
	))).is_true()
	assert_bool(bool(saved.get(
		"neon_rooftops_relay_spire_traversed",
		false
	))).is_true()
	assert_array(Array(saved.get("unlocked_abilities", []))).contains([
		"wall_climb",
	])

	var restored: Node = _instantiate_scene(ROOFTOPS_SCENE_PATH)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", saved)
	var restored_diagnostics: Dictionary = restored.call(
		"get_neon_relay_spire_diagnostics"
	)
	assert_bool(bool(restored_diagnostics.get("roost_activated", false))).is_true()
	assert_bool(bool(restored_diagnostics.get("traversed", false))).is_true()
	assert_int(int(restored_diagnostics.get(
		"autosave_request_count",
		-1
	))).is_equal(0)
	assert_int(int(restored_diagnostics.get("audio_request_count", -1))).is_equal(0)
	assert_int(int(Dictionary(restored_diagnostics.get(
		"roost_vfx",
		{}
	)).get("spawn_count", -1))).is_equal(0)
	assert_bool(bool(restored_diagnostics.get(
		"access_seal_blocking",
		true
	))).is_false()


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
