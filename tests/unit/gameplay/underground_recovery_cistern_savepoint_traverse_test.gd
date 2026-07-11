## Player Abilities Story132: Underground recovery cistern savepoint traverse.
extends GdUnitTestSuite

const UNDERGROUND_SCENE_PATH: String = "res://scenes/areas/underground_passage.tscn"
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/underground_passage/"
	+ "env_underground_recovery_cistern_1280x720.png"
)
const RELAY_TEXTURE_PATH: String = (
	"res://assets/environment/underground_passage/"
	+ "prop_underground_recovery_relay_256x256.png"
)
const ENDPOINT_TEXTURE_PATH: String = (
	"res://assets/environment/underground_passage/"
	+ "prop_underground_deep_route_endpoint_256x384.png"
)
const RECOVERY_CONTROLLER_SCRIPT_PATH: String = (
	"res://src/gameplay/underground_recovery_cistern_controller.gd"
)
const SCENE_ID: String = "area_04_underground_passage"
const RELAY_ID: String = "underground_recovery_cistern_relay"
const RELAY_SPAWN_POINT: String = "recovery_cistern_relay"
const RELAY_NODE_PATH: String = "RecoveryCisternController/RecoveryRelay"
const ENDPOINT_NODE_PATH: String = "RecoveryCisternController/DeepRouteEndpoint"
const ROUTE_WIDTH_PX: int = 3840

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


class FakeUndergroundSceneManager:
	extends RefCounted

	var current_scene: StringName = &"area_04_underground_passage"
	var current_spawn_point: StringName = &"recovery_cistern_relay"

	func request_scene_change(
		scene_id: StringName,
		spawn_point: StringName = &"default"
	) -> bool:
		current_scene = scene_id
		current_spawn_point = spawn_point
		return true

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn_point

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == &"area_04_underground_passage" \
			or scene_id == &"area_03_factory"


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_authored_recovery_cistern_route_and_controller_contract() -> void:
	_assert_png_contract(BACKGROUND_TEXTURE_PATH, Vector2i(1280, 720), false)
	_assert_png_contract(RELAY_TEXTURE_PATH, Vector2i(256, 256), true)
	_assert_png_contract(ENDPOINT_TEXTURE_PATH, Vector2i(256, 384), true)
	assert_bool(FileAccess.file_exists(RECOVERY_CONTROLLER_SCRIPT_PATH)).is_true()

	var scene: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	assert_that(scene).is_not_null()
	if scene == null:
		return
	assert_bool(scene.has_method(
		"get_underground_recovery_cistern_diagnostics"
	)).is_true()
	if not scene.has_method("get_underground_recovery_cistern_diagnostics"):
		return

	var diagnostics: Dictionary = scene.call(
		"get_underground_recovery_cistern_diagnostics"
	)
	assert_int(int(diagnostics.get("route_width_px", 0))).is_equal(ROUTE_WIDTH_PX)
	assert_int(int(diagnostics.get("stepping_platform_count", 0))).is_equal(3)
	assert_bool(bool(diagnostics.get("fall_zone_present", false))).is_true()
	assert_bool(bool(diagnostics.get("controller_present", false))).is_true()
	assert_str(String(diagnostics.get("controller_script_path", ""))).is_equal(
		RECOVERY_CONTROLLER_SCRIPT_PATH
	)
	assert_str(String(diagnostics.get("background_texture_path", ""))).is_equal(
		BACKGROUND_TEXTURE_PATH
	)
	assert_str(String(diagnostics.get("relay_texture_path", ""))).is_equal(
		RELAY_TEXTURE_PATH
	)
	assert_str(String(diagnostics.get("endpoint_texture_path", ""))).is_equal(
		ENDPOINT_TEXTURE_PATH
	)
	assert_float(float(diagnostics.get("gap_start_x", 0.0))).is_equal_approx(
		2860.0,
		0.01
	)
	assert_float(float(diagnostics.get("gap_end_x", 0.0))).is_equal_approx(
		3340.0,
		0.01
	)
	assert_float(float(diagnostics.get("right_wall_x", 0.0))).is_equal_approx(
		3820.0,
		0.01
	)
	assert_str(String(diagnostics.get("relay_id", ""))).is_equal(RELAY_ID)
	assert_str(String(diagnostics.get("relay_scene_id", ""))).is_equal(SCENE_ID)
	assert_str(String(diagnostics.get("relay_spawn_point", ""))).is_equal(
		RELAY_SPAWN_POINT
	)

	var camera: Camera2D = scene.get_node_or_null("Player/Camera2D") as Camera2D
	assert_that(camera).is_not_null()
	if camera != null:
		assert_int(camera.limit_right).is_greater_equal(ROUTE_WIDTH_PX)
	var relay: Node = scene.get_node_or_null(RELAY_NODE_PATH)
	var endpoint: Node = scene.get_node_or_null(ENDPOINT_NODE_PATH)
	assert_that(relay).is_not_null()
	assert_that(endpoint).is_not_null()


func test_recovery_relay_restores_hp_and_dispatches_one_autosave() -> void:
	var locked_scene: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return
	assert_bool(locked_scene.has_method(
		"try_activate_recovery_cistern_savepoint"
	)).is_true()
	if not locked_scene.has_method("try_activate_recovery_cistern_savepoint"):
		return
	var locked_player: Node2D = locked_scene.get_node_or_null("Player") as Node2D
	assert_that(locked_player).is_not_null()
	if locked_player == null:
		return
	assert_bool(bool(locked_scene.call(
		"try_activate_recovery_cistern_savepoint",
		locked_player
	))).is_false()

	var scene: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	assert_that(scene).is_not_null()
	if scene == null:
		return
	assert_bool(scene.has_method(
		"configure_underground_save_system_runtime"
	)).is_true()
	assert_bool(scene.has_method(
		"get_underground_recovery_cistern_diagnostics"
	)).is_true()
	if (
		not scene.has_method("configure_underground_save_system_runtime")
		or not scene.has_method("get_underground_recovery_cistern_diagnostics")
	):
		return

	scene.call("set_local_state", {
		"underground_corrosion_channel_activated": true,
		"underground_corrosion_left_defeated": true,
		"underground_corrosion_right_defeated": true,
		"underground_corrosion_channel_cleared": true,
		"underground_corrosion_salvage_claimed": true,
		"unlocked_abilities": ["aerial_attack"],
	})
	var fake_save_system := FakeSaveSystem.new()
	assert_bool(bool(scene.call(
		"configure_underground_save_system_runtime",
		fake_save_system
	))).is_true()
	var player: Node2D = scene.get_node_or_null("Player") as Node2D
	var relay: Node2D = scene.get_node_or_null(RELAY_NODE_PATH) as Node2D
	assert_that(player).is_not_null()
	assert_that(relay).is_not_null()
	if player == null or relay == null:
		return
	var max_hp: int = int(player.call("get_max_hp"))
	player.call("apply_damage", 24, {
		"source": &"story132_relay_test",
		"damage_type": &"setup",
	})
	assert_int(int(player.call("get_current_hp"))).is_less(max_hp)
	var hud: Node = scene.get_node_or_null("HUD")
	assert_that(hud).is_not_null()
	if hud != null and hud.has_method("get_hp_label_text"):
		assert_str(String(hud.call("get_hp_label_text"))).is_equal(
			"%d / %d" % [max_hp - 24, max_hp]
		)

	player.global_position = relay.global_position + Vector2(260.0, 0.0)
	assert_bool(bool(scene.call(
		"try_activate_recovery_cistern_savepoint",
		player
	))).is_false()
	player.global_position = relay.global_position
	assert_bool(bool(scene.call(
		"try_activate_recovery_cistern_savepoint",
		player
	))).is_true()
	assert_bool(bool(scene.call(
		"try_activate_recovery_cistern_savepoint",
		player
	))).is_false()
	assert_int(int(player.call("get_current_hp"))).is_equal(max_hp)
	if hud != null and hud.has_method("get_hp_label_text"):
		assert_str(String(hud.call("get_hp_label_text"))).is_equal(
			"%d / %d" % [max_hp, max_hp]
		)
	assert_int(fake_save_system.auto_save_calls.size()).is_equal(1)

	var diagnostics: Dictionary = scene.call(
		"get_underground_recovery_cistern_diagnostics"
	)
	assert_bool(bool(diagnostics.get("relay_activated", false))).is_true()
	assert_int(int(diagnostics.get("autosave_request_count", 0))).is_equal(1)
	assert_int(int(diagnostics.get("audio_request_count", 0))).is_equal(1)
	assert_str(String(diagnostics.get("objective_text", ""))).is_equal(
		"Cross Recovery Cistern"
	)
	var objective_label: Label = scene.get_node_or_null(
		"UndergroundObjectiveLabel"
	) as Label
	assert_that(objective_label).is_not_null()
	if objective_label != null:
		assert_str(objective_label.text).is_equal("Cross Recovery Cistern")
	var last_savepoint: Dictionary = Dictionary(
		diagnostics.get("last_savepoint", {})
	)
	assert_str(String(last_savepoint.get("id", ""))).is_equal(RELAY_ID)
	assert_str(String(last_savepoint.get("scene_id", ""))).is_equal(SCENE_ID)
	assert_str(String(last_savepoint.get("spawn_point", ""))).is_equal(
		RELAY_SPAWN_POINT
	)
	var saved_world: Dictionary = Dictionary(
		fake_save_system.auto_save_calls[0].get("world_state", {})
	)
	assert_str(String(saved_world.get("autosave_reason", ""))).is_equal(
		"savepoint"
	)


func test_fall_revive_endpoint_and_fresh_restore_preserve_progress() -> void:
	var scene: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	assert_that(scene).is_not_null()
	if scene == null:
		return
	for required_method: String in [
		"try_activate_recovery_cistern_savepoint",
		"apply_recovery_cistern_fall",
		"advance_underground_recovery_respawn_flow",
		"try_activate_recovery_cistern_endpoint",
		"get_underground_recovery_cistern_diagnostics",
	]:
		assert_bool(scene.has_method(required_method)).is_true()
		if not scene.has_method(required_method):
			return

	scene.call("set_local_state", {
		"underground_corrosion_channel_activated": true,
		"underground_corrosion_left_defeated": true,
		"underground_corrosion_right_defeated": true,
		"underground_corrosion_channel_cleared": true,
		"underground_corrosion_salvage_claimed": true,
		"unlocked_abilities": ["aerial_attack"],
	})
	var fake_save_system := FakeSaveSystem.new()
	assert_bool(bool(scene.call(
		"configure_underground_save_system_runtime",
		fake_save_system
	))).is_true()
	var player: Node2D = scene.get_node_or_null("Player") as Node2D
	var relay: Node2D = scene.get_node_or_null(RELAY_NODE_PATH) as Node2D
	var endpoint: Node2D = scene.get_node_or_null(ENDPOINT_NODE_PATH) as Node2D
	assert_that(player).is_not_null()
	assert_that(relay).is_not_null()
	assert_that(endpoint).is_not_null()
	if player == null or relay == null or endpoint == null:
		return

	player.global_position = relay.global_position
	assert_bool(bool(scene.call(
		"try_activate_recovery_cistern_savepoint",
		player
	))).is_true()
	assert_bool(bool(scene.call("apply_recovery_cistern_fall", player))).is_true()
	var dying: Dictionary = scene.call(
		"get_underground_recovery_cistern_diagnostics"
	)
	assert_str(String(dying.get("respawn_state", ""))).is_equal("dying")
	assert_bool(bool(dying.get("player_control_locked", false))).is_true()

	scene.call("advance_underground_recovery_respawn_flow", 1.51)
	var max_hp: int = int(player.call("get_max_hp"))
	assert_int(int(player.call("get_current_hp"))).is_equal(
		maxi(1, int(floor(float(max_hp) * 0.5)))
	)
	var hud: Node = scene.get_node_or_null("HUD")
	assert_that(hud).is_not_null()
	if hud != null and hud.has_method("get_hp_label_text"):
		assert_str(String(hud.call("get_hp_label_text"))).is_equal(
			"%d / %d" % [maxi(1, int(floor(float(max_hp) * 0.5))), max_hp]
		)
	assert_float(player.global_position.distance_to(relay.global_position)).is_less_equal(
		1.0
	)
	var revived: Dictionary = scene.call(
		"get_underground_recovery_cistern_diagnostics"
	)
	assert_str(String(revived.get("respawn_state", ""))).is_equal("revived")
	assert_bool(bool(revived.get("player_control_locked", false))).is_true()
	assert_str(String(
		Dictionary(revived.get("last_selected_respawn_point", {})).get(
			"spawn_point",
			""
		)
	)).is_equal(RELAY_SPAWN_POINT)

	scene.call("advance_underground_recovery_respawn_flow", 2.01)
	var playing: Dictionary = scene.call(
		"get_underground_recovery_cistern_diagnostics"
	)
	assert_str(String(playing.get("respawn_state", ""))).is_equal("playing")
	assert_bool(bool(playing.get("player_control_locked", true))).is_false()

	player.global_position = endpoint.global_position
	await get_tree().physics_frame
	await get_tree().process_frame
	var automatic_endpoint: Dictionary = scene.call(
		"get_underground_recovery_cistern_diagnostics"
	)
	assert_bool(bool(automatic_endpoint.get("traversed", false))).is_true()
	assert_bool(bool(scene.call(
		"try_activate_recovery_cistern_endpoint",
		player
	))).is_false()
	var secured: Dictionary = scene.call(
		"get_underground_recovery_cistern_diagnostics"
	)
	assert_bool(bool(secured.get("traversed", false))).is_true()
	assert_str(String(secured.get("objective_text", ""))).is_equal(
		"Recovery Cistern Secured"
	)
	var secured_objective: Label = scene.get_node_or_null(
		"UndergroundObjectiveLabel"
	) as Label
	assert_that(secured_objective).is_not_null()
	if secured_objective != null:
		assert_str(secured_objective.text).is_equal("Recovery Cistern Secured")
	assert_int(fake_save_system.auto_save_calls.size()).is_equal(1)

	var state: Dictionary = scene.call("get_local_state")
	assert_bool(bool(state.get(
		"underground_recovery_cistern_relay_activated",
		false
	))).is_true()
	assert_bool(bool(state.get(
		"underground_recovery_cistern_traversed",
		false
	))).is_true()
	assert_bool(Array(state.get("unlocked_abilities", [])).has("aerial_attack")).is_true()
	assert_bool(bool(state.get(
		"underground_corrosion_salvage_claimed",
		false
	))).is_true()

	var restored_scene: Node = _instantiate_scene(UNDERGROUND_SCENE_PATH)
	assert_that(restored_scene).is_not_null()
	if restored_scene == null:
		return
	restored_scene.call("set_local_state", state)
	var scene_manager := FakeUndergroundSceneManager.new()
	assert_bool(bool(restored_scene.call(
		"configure_scene_manager_runtime",
		scene_manager
	))).is_true()
	var restored_player: Node2D = restored_scene.get_node_or_null("Player") as Node2D
	var restored_relay: Node2D = restored_scene.get_node_or_null(
		RELAY_NODE_PATH
	) as Node2D
	assert_that(restored_player).is_not_null()
	assert_that(restored_relay).is_not_null()
	if restored_player == null or restored_relay == null:
		return
	assert_float(
		restored_player.global_position.distance_to(restored_relay.global_position)
	).is_less_equal(1.0)
	var restored: Dictionary = restored_scene.call(
		"get_underground_recovery_cistern_diagnostics"
	)
	assert_bool(bool(restored.get("relay_activated", false))).is_true()
	assert_bool(bool(restored.get("traversed", false))).is_true()
	assert_int(int(restored.get("autosave_request_count", -1))).is_equal(0)
	assert_int(int(restored.get("audio_request_count", -1))).is_equal(0)
	assert_str(String(restored.get("objective_text", ""))).is_equal(
		"Recovery Cistern Secured"
	)
	var restored_objective: Label = restored_scene.get_node_or_null(
		"UndergroundObjectiveLabel"
	) as Label
	assert_that(restored_objective).is_not_null()
	if restored_objective != null:
		assert_str(restored_objective.text).is_equal("Recovery Cistern Secured")


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


func _assert_png_contract(
	path: String,
	expected_size: Vector2i,
	alpha: bool
) -> void:
	var image: Image = _load_png(path)
	assert_that(image).is_not_null()
	if image == null:
		return
	assert_int(image.get_width()).is_equal(expected_size.x)
	assert_int(image.get_height()).is_equal(expected_size.y)
	if alpha:
		assert_int(image.detect_alpha()).is_equal(Image.ALPHA_BLEND)
	else:
		assert_int(image.detect_alpha()).is_equal(Image.ALPHA_NONE)


func _load_png(path: String) -> Image:
	if not FileAccess.file_exists(path):
		return null
	var image := Image.new()
	if image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) != OK:
		return null
	return image


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
		elif child is AudioStreamPlayer2D:
			(child as AudioStreamPlayer2D).stop()
