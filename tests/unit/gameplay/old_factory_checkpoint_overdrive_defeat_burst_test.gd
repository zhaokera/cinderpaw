## Player Abilities Story 052: Old Factory checkpoint overdrive defeat burst.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_OVERDRIVE_LEFT_ENTITY_ID: int = 2106
const FACTORY_OVERDRIVE_RIGHT_ENTITY_ID: int = 2107
const OVERDRIVE_DEFEAT_BURST_TEXTURE: String = (
	"res://assets/environment/old_factory_overdrive_defeat_burst/"
	+ "vfx_old_factory_overdrive_defeat_burst_256.png"
)

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


func test_overdrive_spark_rat_defeat_spawns_side_specific_generated_burst() -> void:
	var destination: Node = _factory_scene_with_rear_ambush_cleared()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("get_factory_checkpoint_overdrive_defeat_burst_diagnostics")).is_true()
	if not destination.has_method("get_factory_checkpoint_overdrive_defeat_burst_diagnostics"):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var before: Dictionary = destination.call("get_factory_checkpoint_overdrive_duo_diagnostics")
	player.global_position.x = float(before.get("activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call("try_activate_factory_checkpoint_overdrive_duo", player))).is_true()

	var activated: Dictionary = destination.call("get_factory_checkpoint_overdrive_duo_diagnostics")
	var left_position: Vector2 = activated.get("left_position", Vector2.ZERO) as Vector2
	var right_position: Vector2 = activated.get("right_position", Vector2.ZERO) as Vector2

	assert_bool(destination.call("apply_damage", FACTORY_OVERDRIVE_LEFT_ENTITY_ID, 999, {
		"source": &"unit_test_checkpoint_overdrive_left_burst",
	})).is_true()
	await get_tree().process_frame

	var left_burst: Dictionary = destination.call(
		"get_factory_checkpoint_overdrive_defeat_burst_diagnostics"
	)
	assert_bool(bool(left_burst.get("present", false))).is_true()
	assert_str(String(left_burst.get("texture_path", ""))).is_equal(OVERDRIVE_DEFEAT_BURST_TEXTURE)
	assert_str(String(left_burst.get("last_side", ""))).is_equal("left")
	assert_bool(bool(left_burst.get("left_visible", false))).is_true()
	assert_bool(bool(left_burst.get("right_visible", true))).is_false()
	assert_vector(left_burst.get("left_position", Vector2.ZERO) as Vector2).is_equal(left_position)

	assert_bool(destination.call("apply_damage", FACTORY_OVERDRIVE_RIGHT_ENTITY_ID, 999, {
		"source": &"unit_test_checkpoint_overdrive_right_burst",
	})).is_true()
	await get_tree().process_frame

	var right_burst: Dictionary = destination.call(
		"get_factory_checkpoint_overdrive_defeat_burst_diagnostics"
	)
	assert_str(String(right_burst.get("last_side", ""))).is_equal("right")
	assert_bool(bool(right_burst.get("left_visible", false))).is_true()
	assert_bool(bool(right_burst.get("right_visible", false))).is_true()
	assert_vector(right_burst.get("right_position", Vector2.ZERO) as Vector2).is_equal(right_position)

	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(service_lift).is_not_null()
	if service_lift == null:
		return
	player.global_position = service_lift.global_position
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


func test_restored_overdrive_clear_state_does_not_replay_defeat_bursts() -> void:
	var destination: Node = _factory_scene_with_rear_ambush_cleared()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("get_factory_checkpoint_overdrive_defeat_burst_diagnostics")).is_true()
	if not destination.has_method("get_factory_checkpoint_overdrive_defeat_burst_diagnostics"):
		return

	destination.call("set_local_state", _return_checkpoint_state().merged({
		"factory_checkpoint_forward_patrol_activated": true,
		"factory_checkpoint_forward_patrol_defeated": true,
		"factory_checkpoint_rear_ambush_activated": true,
		"factory_checkpoint_rear_ambush_defeated": true,
		"factory_checkpoint_overdrive_duo_activated": true,
		"factory_checkpoint_overdrive_left_defeated": true,
		"factory_checkpoint_overdrive_right_defeated": true,
		"factory_checkpoint_overdrive_duo_cleared": true,
	}, true))

	var burst: Dictionary = destination.call(
		"get_factory_checkpoint_overdrive_defeat_burst_diagnostics"
	)
	assert_bool(bool(burst.get("present", false))).is_true()
	assert_bool(bool(burst.get("left_visible", true))).is_false()
	assert_bool(bool(burst.get("right_visible", true))).is_false()
	assert_str(String(burst.get("last_side", ""))).is_empty()


func _factory_scene_with_rear_ambush_cleared() -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _return_checkpoint_state().merged({
		"factory_checkpoint_forward_patrol_activated": true,
		"factory_checkpoint_forward_patrol_defeated": true,
		"factory_checkpoint_rear_ambush_activated": true,
		"factory_checkpoint_rear_ambush_defeated": true,
	}, true))
	return destination


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


func _return_checkpoint_state() -> Dictionary:
	return {
		"encounter_cleared": true,
		"factory_cache_claimed": true,
		"factory_deep_guard_activated": true,
		"factory_deep_guard_defeated": true,
		"factory_deep_route_cleared": true,
		"factory_spark_rat_activated": true,
		"factory_spark_rat_defeated": true,
		"factory_return_patrol_activated": true,
		"factory_return_patrol_defeated": true,
		"factory_return_checkpoint_activated": true,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
		"last_return_checkpoint": {
			"id": "old_factory_return_checkpoint",
			"scene_id": "area_03_factory",
			"spawn_point": "return_checkpoint",
			"position": Vector2(704, 380),
		},
	}


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
