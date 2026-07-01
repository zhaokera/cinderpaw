## Player Abilities Story 051: Old Factory checkpoint overdrive reward cache.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_OVERDRIVE_CACHE_NAME: String = "FactoryCheckpointOverdriveRewardCache"
const FACTORY_OVERDRIVE_CACHE_ID: String = "old_factory_checkpoint_overdrive_cache"
const FACTORY_OVERDRIVE_CACHE_GEARS: int = 25
const FACTORY_OVERDRIVE_CACHE_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_checkpoint_overdrive_reward_cache/"
	+ "env_old_factory_checkpoint_overdrive_reward_cache_claimable_256.png"
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


func test_overdrive_reward_cache_stays_locked_until_duo_is_cleared() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(FileAccess.file_exists(FACTORY_OVERDRIVE_CACHE_TEXTURE_PATH)).is_true()
	assert_bool(destination.has_method(
		"get_factory_checkpoint_overdrive_reward_cache_diagnostics"
	)).is_true()
	assert_bool(destination.has_method(
		"try_claim_factory_checkpoint_overdrive_reward_cache"
	)).is_true()
	if (
		not destination.has_method("get_factory_checkpoint_overdrive_reward_cache_diagnostics")
		or not destination.has_method("try_claim_factory_checkpoint_overdrive_reward_cache")
	):
		return

	destination.call("set_local_state", _overdrive_available_state())
	var cache: Node = destination.get_node_or_null(FACTORY_OVERDRIVE_CACHE_NAME)
	assert_that(cache).is_not_null()
	if cache == null:
		return

	var diagnostics: Dictionary = destination.call(
		"get_factory_checkpoint_overdrive_reward_cache_diagnostics"
	)
	assert_bool(bool(diagnostics.get("present", false))).is_true()
	assert_bool(bool(diagnostics.get("visible", false))).is_true()
	assert_bool(bool(diagnostics.get("available", true))).is_false()
	assert_bool(bool(diagnostics.get("claim_available", true))).is_false()
	assert_bool(bool(diagnostics.get("claimed", true))).is_false()
	assert_str(String(diagnostics.get("cache_id", ""))).is_equal(FACTORY_OVERDRIVE_CACHE_ID)
	assert_str(String(diagnostics.get("texture_path", ""))).is_equal(
		FACTORY_OVERDRIVE_CACHE_TEXTURE_PATH
	)
	assert_str(String(diagnostics.get("prompt_text", ""))).is_equal("Clear overdrive duo")
	assert_bool(bool(diagnostics.get("overdrive_duo_cleared", true))).is_false()
	assert_bool(bool(destination.call(
		"try_claim_factory_checkpoint_overdrive_reward_cache"
	))).is_false()


func test_overdrive_reward_cache_claims_once_and_persists_after_duo_clear() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method(
		"get_factory_checkpoint_overdrive_reward_cache_diagnostics"
	)).is_true()
	assert_bool(destination.has_method(
		"try_claim_factory_checkpoint_overdrive_reward_cache"
	)).is_true()
	if (
		not destination.has_method("get_factory_checkpoint_overdrive_reward_cache_diagnostics")
		or not destination.has_method("try_claim_factory_checkpoint_overdrive_reward_cache")
	):
		return

	destination.call("set_local_state", _overdrive_cleared_state())
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var cache: Node2D = destination.get_node_or_null(FACTORY_OVERDRIVE_CACHE_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(cache).is_not_null()
	if player == null or cache == null:
		return

	var unlocked: Dictionary = destination.call(
		"get_factory_checkpoint_overdrive_reward_cache_diagnostics"
	)
	assert_bool(bool(unlocked.get("available", false))).is_true()
	assert_bool(bool(unlocked.get("claim_available", false))).is_true()
	assert_str(String(unlocked.get("prompt_text", ""))).is_equal("+25 Gears")
	assert_bool(bool(unlocked.get("overdrive_duo_cleared", false))).is_true()

	player.global_position = cache.global_position
	assert_bool(bool(destination.call(
		"try_claim_factory_checkpoint_overdrive_reward_cache",
		player
	))).is_true()
	assert_bool(bool(destination.call(
		"try_claim_factory_checkpoint_overdrive_reward_cache",
		player
	))).is_false()

	var claimed: Dictionary = destination.call(
		"get_factory_checkpoint_overdrive_reward_cache_diagnostics"
	)
	var reward: Dictionary = Dictionary(claimed.get("last_reward", {}))
	var feedback: Dictionary = Dictionary(claimed.get("last_claim_feedback", {}))
	var route: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_bool(bool(claimed.get("claimed", false))).is_true()
	assert_bool(bool(claimed.get("claim_available", true))).is_false()
	assert_str(String(reward.get("cache_id", ""))).is_equal(FACTORY_OVERDRIVE_CACHE_ID)
	assert_int(int(reward.get("gears", 0))).is_equal(FACTORY_OVERDRIVE_CACHE_GEARS)
	assert_str(String(reward.get("source", ""))).is_equal(FACTORY_OVERDRIVE_CACHE_ID)
	assert_str(String(feedback.get("cache_id", ""))).is_equal(FACTORY_OVERDRIVE_CACHE_ID)
	assert_str(String(feedback.get("text", ""))).is_equal(
		"Overdrive Cache Claimed +25 Gears"
	)
	assert_str(String(route.get("route_label_text", ""))).is_equal(
		"Overdrive Cache Claimed +25 Gears"
	)

	var state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(state.get("factory_checkpoint_overdrive_reward_cache_claimed", false))).is_true()
	assert_int(int(Dictionary(state.get(
		"last_checkpoint_overdrive_reward_cache_reward",
		{}
	)).get("gears", 0))).is_equal(FACTORY_OVERDRIVE_CACHE_GEARS)
	assert_str(String(Dictionary(state.get(
		"last_checkpoint_overdrive_reward_cache_claim_feedback",
		{}
	)).get("text", ""))).is_equal("Overdrive Cache Claimed +25 Gears")

	var restored: Node = _instantiate_factory_scene()
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", state)
	var restored_diagnostics: Dictionary = restored.call(
		"get_factory_checkpoint_overdrive_reward_cache_diagnostics"
	)
	assert_bool(bool(restored_diagnostics.get("claimed", false))).is_true()
	assert_bool(bool(restored_diagnostics.get("claim_available", true))).is_false()
	assert_int(int(Dictionary(restored_diagnostics.get(
		"last_reward",
		{}
	)).get("gears", 0))).is_equal(FACTORY_OVERDRIVE_CACHE_GEARS)


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


func _overdrive_available_state() -> Dictionary:
	return _return_checkpoint_state().merged({
		"factory_checkpoint_forward_patrol_activated": true,
		"factory_checkpoint_forward_patrol_defeated": true,
		"factory_checkpoint_rear_ambush_activated": true,
		"factory_checkpoint_rear_ambush_defeated": true,
		"factory_checkpoint_overdrive_duo_activated": true,
		"factory_checkpoint_overdrive_left_defeated": false,
		"factory_checkpoint_overdrive_right_defeated": false,
		"factory_checkpoint_overdrive_duo_cleared": false,
	}, true)


func _overdrive_cleared_state() -> Dictionary:
	return _return_checkpoint_state().merged({
		"factory_checkpoint_forward_patrol_activated": true,
		"factory_checkpoint_forward_patrol_defeated": true,
		"factory_checkpoint_rear_ambush_activated": true,
		"factory_checkpoint_rear_ambush_defeated": true,
		"factory_checkpoint_overdrive_duo_activated": true,
		"factory_checkpoint_overdrive_left_defeated": true,
		"factory_checkpoint_overdrive_right_defeated": true,
		"factory_checkpoint_overdrive_duo_cleared": true,
	}, true)


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
