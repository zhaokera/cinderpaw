## Player Abilities Story 041: Old Factory return patrol reward cache.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_RETURN_CACHE_NAME: String = "FactoryReturnPatrolRewardCache"
const FACTORY_RETURN_SPARK_RAT_ENTITY_ID: int = 2103
const RETURN_CACHE_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_return_patrol_reward_cache/"
	+ "env_old_factory_return_patrol_reward_cache_claimable_256.png"
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


func test_return_reward_cache_uses_generated_prop_and_stays_locked_until_patrol_clear() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(FileAccess.file_exists(RETURN_CACHE_TEXTURE_PATH)).is_true()
	assert_bool(destination.has_method("get_factory_return_patrol_reward_cache_diagnostics")).is_true()
	if not destination.has_method("get_factory_return_patrol_reward_cache_diagnostics"):
		return

	destination.call("set_local_state", _service_lift_return_state())
	var cache: Node = destination.get_node_or_null(FACTORY_RETURN_CACHE_NAME)
	assert_that(cache).is_not_null()
	if cache == null:
		return

	var diagnostics: Dictionary = destination.call("get_factory_return_patrol_reward_cache_diagnostics")
	assert_bool(bool(diagnostics.get("present", false))).is_true()
	assert_str(String(diagnostics.get("cache_id", ""))).is_equal("old_factory_return_patrol_cache")
	assert_str(String(diagnostics.get("texture_path", ""))).is_equal(RETURN_CACHE_TEXTURE_PATH)
	assert_bool(bool(diagnostics.get("available", true))).is_false()
	assert_bool(bool(diagnostics.get("claim_available", true))).is_false()
	assert_bool(bool(diagnostics.get("claimed", true))).is_false()
	assert_bool(bool(diagnostics.get("visible", false))).is_true()
	assert_str(String(diagnostics.get("prompt_text", ""))).is_equal("Clear patrol")


func test_return_reward_cache_unlocks_after_return_patrol_defeat_and_claims_once() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	destination.call("set_local_state", _service_lift_return_state())
	assert_bool(destination.has_method("try_claim_factory_return_patrol_reward_cache")).is_true()
	assert_bool(destination.has_method("get_factory_return_patrol_reward_cache_diagnostics")).is_true()
	if (
		not destination.has_method("try_claim_factory_return_patrol_reward_cache")
		or not destination.has_method("get_factory_return_patrol_reward_cache_diagnostics")
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var cache: Node2D = destination.get_node_or_null(FACTORY_RETURN_CACHE_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(cache).is_not_null()
	if player == null or cache == null:
		return

	assert_bool(bool(destination.call("try_claim_factory_return_patrol_reward_cache", player))).is_false()
	assert_bool(destination.call("apply_damage", FACTORY_RETURN_SPARK_RAT_ENTITY_ID, 999, {
		"source": &"unit_test_return_reward_cache",
	})).is_true()
	await get_tree().process_frame

	var unlocked: Dictionary = destination.call("get_factory_return_patrol_reward_cache_diagnostics")
	assert_bool(bool(unlocked.get("available", false))).is_true()
	assert_bool(bool(unlocked.get("claim_available", false))).is_true()
	assert_str(String(unlocked.get("prompt_text", ""))).is_equal("+15 Gears")

	player.global_position = cache.global_position
	assert_bool(bool(destination.call("try_claim_factory_return_patrol_reward_cache", player))).is_true()
	assert_bool(bool(destination.call("try_claim_factory_return_patrol_reward_cache", player))).is_false()

	var claimed: Dictionary = destination.call("get_factory_return_patrol_reward_cache_diagnostics")
	var reward: Dictionary = Dictionary(claimed.get("last_reward", {}))
	assert_bool(bool(claimed.get("claimed", false))).is_true()
	assert_bool(bool(claimed.get("claim_available", true))).is_false()
	assert_str(String(reward.get("cache_id", ""))).is_equal("old_factory_return_patrol_cache")
	assert_int(int(reward.get("gears", 0))).is_equal(15)
	assert_str(String(reward.get("source", ""))).is_equal("old_factory_return_patrol_cache")


func test_return_reward_cache_claim_state_persists_without_replaying_reward() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	destination.call("set_local_state", _service_lift_return_state().merged({
		"factory_return_patrol_defeated": true,
		"factory_return_patrol_reward_cache_claimed": true,
		"last_return_patrol_reward_cache_reward": {
			"cache_id": "old_factory_return_patrol_cache",
			"gears": 15,
			"source": "old_factory_return_patrol_cache",
		},
	}, true))

	var diagnostics: Dictionary = destination.call("get_factory_return_patrol_reward_cache_diagnostics")
	assert_bool(bool(diagnostics.get("available", false))).is_true()
	assert_bool(bool(diagnostics.get("claimed", false))).is_true()
	assert_bool(bool(diagnostics.get("claim_available", true))).is_false()
	var state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(state.get("factory_return_patrol_reward_cache_claimed", false))).is_true()
	assert_int(int(Dictionary(state.get("last_return_patrol_reward_cache_reward", {})).get("gears", 0))).is_equal(15)


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
