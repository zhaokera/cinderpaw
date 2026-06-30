## Player Abilities Story 042: Old Factory cache claim feedback.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_CACHE_NAME: String = "FactoryCombatCache"
const FACTORY_RETURN_CACHE_NAME: String = "FactoryReturnPatrolRewardCache"

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


func test_entrance_cache_claim_shows_reward_feedback_once() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("try_claim_factory_cache")).is_true()
	assert_bool(destination.has_method("get_factory_room_clear_diagnostics")).is_true()
	assert_bool(destination.has_method("get_factory_route_objective_diagnostics")).is_true()
	if (
		not destination.has_method("try_claim_factory_cache")
		or not destination.has_method("get_factory_room_clear_diagnostics")
		or not destination.has_method("get_factory_route_objective_diagnostics")
	):
		return

	destination.call("set_local_state", {"encounter_cleared": true})
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var cache: Node2D = destination.get_node_or_null(FACTORY_CACHE_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(cache).is_not_null()
	if player == null or cache == null:
		return

	player.global_position = cache.global_position
	assert_bool(bool(destination.call("try_claim_factory_cache", player))).is_true()
	var diagnostics: Dictionary = destination.call("get_factory_room_clear_diagnostics")
	var route: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	var feedback: Dictionary = Dictionary(diagnostics.get("last_cache_claim_feedback", {}))
	assert_str(String(route.get("route_label_text", ""))).is_equal("Cache Claimed +10 Gears")
	assert_str(String(feedback.get("cache_id", ""))).is_equal("old_factory_entrance_cache")
	assert_str(String(feedback.get("text", ""))).is_equal("Cache Claimed +10 Gears")
	assert_int(int(feedback.get("gears", 0))).is_equal(10)
	assert_str(String(feedback.get("source", ""))).is_equal("old_factory_combat_cache")

	assert_bool(bool(destination.call("try_claim_factory_cache", player))).is_false()
	var duplicate_route: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	var duplicate_diagnostics: Dictionary = destination.call("get_factory_room_clear_diagnostics")
	assert_str(String(duplicate_route.get("route_label_text", ""))).is_equal(
		"Cache Claimed +10 Gears"
	)
	assert_that(Dictionary(duplicate_diagnostics.get("last_cache_claim_feedback", {}))).is_equal(
		feedback
	)


func test_return_patrol_cache_claim_shows_reward_feedback_once() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("try_claim_factory_return_patrol_reward_cache")).is_true()
	assert_bool(destination.has_method("get_factory_return_patrol_reward_cache_diagnostics")).is_true()
	assert_bool(destination.has_method("get_factory_route_objective_diagnostics")).is_true()
	if (
		not destination.has_method("try_claim_factory_return_patrol_reward_cache")
		or not destination.has_method("get_factory_return_patrol_reward_cache_diagnostics")
		or not destination.has_method("get_factory_route_objective_diagnostics")
	):
		return

	destination.call("set_local_state", _service_lift_return_state().merged({
		"factory_return_patrol_defeated": true,
	}, true))
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var cache: Node2D = destination.get_node_or_null(FACTORY_RETURN_CACHE_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(cache).is_not_null()
	if player == null or cache == null:
		return

	player.global_position = cache.global_position
	assert_bool(bool(destination.call("try_claim_factory_return_patrol_reward_cache", player))).is_true()
	var diagnostics: Dictionary = destination.call(
		"get_factory_return_patrol_reward_cache_diagnostics"
	)
	var route: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	var feedback: Dictionary = Dictionary(diagnostics.get("last_claim_feedback", {}))
	assert_str(String(route.get("route_label_text", ""))).is_equal("Return Cache Claimed +15 Gears")
	assert_str(String(feedback.get("cache_id", ""))).is_equal("old_factory_return_patrol_cache")
	assert_str(String(feedback.get("text", ""))).is_equal("Return Cache Claimed +15 Gears")
	assert_int(int(feedback.get("gears", 0))).is_equal(15)
	assert_str(String(feedback.get("source", ""))).is_equal("old_factory_return_patrol_cache")

	assert_bool(bool(destination.call("try_claim_factory_return_patrol_reward_cache", player))).is_false()
	var duplicate_route: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	var duplicate_diagnostics: Dictionary = destination.call(
		"get_factory_return_patrol_reward_cache_diagnostics"
	)
	assert_str(String(duplicate_route.get("route_label_text", ""))).is_equal(
		"Return Cache Claimed +15 Gears"
	)
	assert_that(Dictionary(duplicate_diagnostics.get("last_claim_feedback", {}))).is_equal(
		feedback
	)


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
