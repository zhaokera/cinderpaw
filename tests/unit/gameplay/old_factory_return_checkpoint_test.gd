## Player Abilities Story 043: Old Factory return checkpoint.
extends GdUnitTestSuite

const GAME_FLOW_SCRIPT: Script = preload("res://src/gameplay/game_flow_controller.gd")
const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_RETURN_CHECKPOINT_NAME: String = "FactoryReturnCheckpoint"
const FACTORY_RETURN_CHECKPOINT_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_return_checkpoint/"
	+ "old_factory_return_checkpoint.png"
)

var _spawned_nodes: Array[Node] = []
var _respawn_events: Array[Dictionary] = []


class FakeFactorySceneManager:
	extends RefCounted

	var change_calls: Array[Dictionary] = []

	func has_scene(scene_id: StringName) -> bool:
		return String(scene_id) in ["area_03_factory", "hub"]

	func change_scene(scene_id: StringName, spawn_point: StringName = &"default") -> bool:
		change_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		return has_scene(scene_id)


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()
	_respawn_events.clear()


func test_return_checkpoint_stays_hidden_until_return_patrol_clear() -> void:
	assert_bool(FileAccess.file_exists(FACTORY_RETURN_CHECKPOINT_TEXTURE_PATH)).is_true()
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("get_factory_return_checkpoint_diagnostics")).is_true()
	assert_bool(destination.has_method("try_activate_factory_return_checkpoint")).is_true()
	if (
		not destination.has_method("get_factory_return_checkpoint_diagnostics")
		or not destination.has_method("try_activate_factory_return_checkpoint")
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	destination.call("set_local_state", _service_lift_return_state())
	var locked: Dictionary = destination.call("get_factory_return_checkpoint_diagnostics")
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(destination.call("try_activate_factory_return_checkpoint", player))).is_false()

	destination.call("set_local_state", _service_lift_return_state().merged({
		"factory_return_patrol_defeated": true,
	}, true))
	var available: Dictionary = destination.call("get_factory_return_checkpoint_diagnostics")
	assert_bool(bool(available.get("present", false))).is_true()
	assert_bool(bool(available.get("visible", false))).is_true()
	assert_bool(bool(available.get("available", false))).is_true()
	assert_bool(bool(available.get("activated", true))).is_false()
	assert_str(String(available.get("savepoint_id", ""))).is_equal("old_factory_return_checkpoint")
	assert_str(String(available.get("scene_id", ""))).is_equal("area_03_factory")
	assert_str(String(available.get("spawn_point", ""))).is_equal("return_checkpoint")
	assert_str(String(available.get("prompt_text", ""))).is_equal("Repair Savepoint")
	assert_str(String(available.get("texture_path", ""))).is_equal(
		FACTORY_RETURN_CHECKPOINT_TEXTURE_PATH
	)


func test_return_checkpoint_activation_records_scene_local_checkpoint() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	destination.call("set_local_state", _service_lift_return_state().merged({
		"factory_return_patrol_defeated": true,
	}, true))

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var checkpoint: Node2D = destination.get_node_or_null(FACTORY_RETURN_CHECKPOINT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(checkpoint).is_not_null()
	if player == null or checkpoint == null:
		return

	player.global_position = checkpoint.global_position
	assert_bool(bool(destination.call("try_activate_factory_return_checkpoint", player))).is_true()

	var diagnostics: Dictionary = destination.call("get_factory_return_checkpoint_diagnostics")
	var route: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	var last_checkpoint: Dictionary = Dictionary(diagnostics.get("last_checkpoint", {}))
	assert_bool(bool(diagnostics.get("activated", false))).is_true()
	assert_str(String(route.get("route_label_text", ""))).is_equal("Factory Savepoint Secured")
	assert_str(String(last_checkpoint.get("id", ""))).is_equal("old_factory_return_checkpoint")
	assert_str(String(last_checkpoint.get("scene_id", ""))).is_equal("area_03_factory")
	assert_str(String(last_checkpoint.get("spawn_point", ""))).is_equal("return_checkpoint")
	assert_str(String(last_checkpoint.get("display_name", ""))).is_equal("Factory Repair Station")
	assert_float(float(last_checkpoint.get("position", {}).get("x", 0.0))).is_equal_approx(
		checkpoint.global_position.x,
		0.001
	)

	var state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(state.get("factory_return_checkpoint_activated", false))).is_true()
	assert_str(String(Dictionary(state.get("last_return_checkpoint", {})).get("id", ""))).is_equal(
		"old_factory_return_checkpoint"
	)

	var restored: Node = _instantiate_factory_scene()
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", state)
	var restored_diagnostics: Dictionary = restored.call("get_factory_return_checkpoint_diagnostics")
	assert_bool(bool(restored_diagnostics.get("visible", false))).is_true()
	assert_bool(bool(restored_diagnostics.get("available", false))).is_true()
	assert_bool(bool(restored_diagnostics.get("activated", false))).is_true()
	assert_str(String(Dictionary(restored_diagnostics.get(
		"last_checkpoint",
		{}
	)).get("id", ""))).is_equal("old_factory_return_checkpoint")


func test_return_checkpoint_drives_non_boss_respawn_scene_selection() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	destination.call("set_local_state", _service_lift_return_state().merged({
		"factory_return_patrol_defeated": true,
	}, true))

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var checkpoint: Node2D = destination.get_node_or_null(FACTORY_RETURN_CHECKPOINT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(checkpoint).is_not_null()
	if player == null or checkpoint == null:
		return

	player.global_position = checkpoint.global_position
	assert_bool(bool(destination.call("try_activate_factory_return_checkpoint", player))).is_true()

	var scene_manager := FakeFactorySceneManager.new()
	var flow: Node = GAME_FLOW_SCRIPT.new()
	add_child(flow)
	_spawned_nodes.append(flow)
	flow.respawn_requested.connect(_on_respawn_requested)
	flow.call("set_savepoint_adapter", destination)
	flow.call("set_scene_transition_adapter", scene_manager)
	flow.call("configure_clan_base_respawn", &"hub", &"clan_base", Vector2(24, 42))
	flow.call("start_encounter", Vector2(24, 42))

	flow.call("handle_player_death")
	flow.call("advance_time", 1.51)

	assert_int(scene_manager.change_calls.size()).is_equal(1)
	assert_str(String(scene_manager.change_calls[0]["scene_id"])).is_equal("area_03_factory")
	assert_str(String(scene_manager.change_calls[0]["spawn_point"])).is_equal("return_checkpoint")
	assert_int(_respawn_events.size()).is_equal(1)
	assert_vector(_respawn_events[0]["position"]).is_equal(checkpoint.global_position)
	assert_str(String(Dictionary(flow.call("get_last_selected_respawn_point")).get(
		"source",
		""
	))).is_equal("savepoint")


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


func _service_lift_return_state() -> Dictionary:
	return {
		"encounter_cleared": true,
		"factory_cache_claimed": true,
		"factory_deep_guard_activated": true,
		"factory_deep_guard_defeated": true,
		"factory_deep_route_cleared": true,
		"factory_spark_rat_activated": true,
		"factory_spark_rat_defeated": true,
		"factory_service_lift_activated": true,
		"factory_service_lift_exit_requested": true,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
	}


func _on_respawn_requested(position: Vector2, revive_hp_percentage: float) -> void:
	_respawn_events.append({
		"position": position,
		"revive_hp_percentage": revive_hp_percentage,
	})


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
