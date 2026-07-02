## Player Abilities Story 056: Old Factory lower deck shortcut reward cache.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const SHORTCUT_CACHE_ID: String = "old_factory_lower_deck_shortcut_cache"
const SHORTCUT_CACHE_TEXTURE: String = (
	"res://assets/environment/old_factory_lower_deck_skirmish_cache/"
	+ "env_old_factory_lower_deck_skirmish_cache_claimable_256.png"
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


func test_shortcut_reward_cache_requires_open_shortcut_and_keeps_service_lift_optional() -> void:
	var locked_scene: Node = _factory_scene_with_shortcut_open(false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method("get_factory_lower_deck_shortcut_reward_cache_diagnostics")).is_true()
	assert_bool(locked_scene.has_method("try_claim_factory_lower_deck_shortcut_reward_cache")).is_true()
	if (
		not locked_scene.has_method("get_factory_lower_deck_shortcut_reward_cache_diagnostics")
		or not locked_scene.has_method("try_claim_factory_lower_deck_shortcut_reward_cache")
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_shortcut_reward_cache_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("claim_available", true))).is_false()
	assert_bool(bool(locked_scene.call("try_claim_factory_lower_deck_shortcut_reward_cache"))).is_false()

	var destination: Node = _factory_scene_with_shortcut_open(true)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(service_lift).is_not_null()
	if player == null or service_lift == null:
		return

	var available: Dictionary = destination.call(
		"get_factory_lower_deck_shortcut_reward_cache_diagnostics"
	)
	assert_bool(bool(available.get("present", false))).is_true()
	assert_bool(bool(available.get("available", false))).is_true()
	assert_bool(bool(available.get("visible", false))).is_true()
	assert_bool(bool(available.get("claim_available", false))).is_true()
	assert_bool(bool(available.get("claimed", true))).is_false()
	assert_str(String(available.get("cache_id", ""))).is_equal(SHORTCUT_CACHE_ID)
	assert_str(String(available.get("texture_path", ""))).is_equal(SHORTCUT_CACHE_TEXTURE)
	assert_str(String(available.get("prompt_text", ""))).is_equal("+15 Gears")

	player.global_position = service_lift.global_position
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


func test_shortcut_reward_cache_claims_once_and_persists_independently() -> void:
	var destination: Node = _factory_scene_with_shortcut_open(true)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("try_claim_factory_lower_deck_shortcut_reward_cache")).is_true()
	assert_bool(destination.has_method("get_factory_lower_deck_shortcut_reward_cache_diagnostics")).is_true()
	if (
		not destination.has_method("try_claim_factory_lower_deck_shortcut_reward_cache")
		or not destination.has_method("get_factory_lower_deck_shortcut_reward_cache_diagnostics")
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var before: Dictionary = destination.call(
		"get_factory_lower_deck_shortcut_reward_cache_diagnostics"
	)
	player.global_position = before.get("position", Vector2.ZERO) as Vector2
	assert_bool(bool(destination.call(
		"try_claim_factory_lower_deck_shortcut_reward_cache",
		player
	))).is_true()
	assert_bool(bool(destination.call(
		"try_claim_factory_lower_deck_shortcut_reward_cache",
		player
	))).is_false()

	var claimed: Dictionary = destination.call(
		"get_factory_lower_deck_shortcut_reward_cache_diagnostics"
	)
	var reward: Dictionary = claimed.get("last_reward", {}) as Dictionary
	var feedback: Dictionary = claimed.get("last_claim_feedback", {}) as Dictionary
	assert_bool(bool(claimed.get("claimed", false))).is_true()
	assert_bool(bool(claimed.get("claim_available", true))).is_false()
	assert_str(String(reward.get("cache_id", ""))).is_equal(SHORTCUT_CACHE_ID)
	assert_int(int(reward.get("gears", 0))).is_equal(15)
	assert_str(String(reward.get("source", ""))).is_equal(SHORTCUT_CACHE_ID)
	assert_str(String(feedback.get("text", ""))).is_equal(
		"Shortcut Cache Claimed +15 Gears"
	)
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Shortcut Cache Claimed +15 Gears")

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get("factory_lower_deck_shortcut_unlocked", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_shortcut_reward_cache_claimed", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_reward_cache_claimed", false))).is_true()

	var restored: Node = _instantiate_factory_scene()
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", local_state)

	var restored_cache: Dictionary = restored.call(
		"get_factory_lower_deck_shortcut_reward_cache_diagnostics"
	)
	assert_bool(bool(restored_cache.get("available", false))).is_true()
	assert_bool(bool(restored_cache.get("claimed", false))).is_true()
	assert_bool(bool(restored_cache.get("claim_available", true))).is_false()
	var restored_shortcut: Dictionary = restored.call(
		"get_factory_lower_deck_shortcut_seal_diagnostics"
	)
	assert_bool(bool(restored_shortcut.get("unlocked", false))).is_true()
	assert_bool(bool(restored_shortcut.get("collision_blocking", true))).is_false()


func _factory_scene_with_shortcut_open(shortcut_open: bool) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _shortcut_ready_state(shortcut_open))
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


func _shortcut_ready_state(shortcut_open: bool) -> Dictionary:
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
		"factory_checkpoint_forward_patrol_activated": true,
		"factory_checkpoint_forward_patrol_defeated": true,
		"factory_checkpoint_rear_ambush_activated": true,
		"factory_checkpoint_rear_ambush_defeated": true,
		"factory_checkpoint_overdrive_duo_activated": true,
		"factory_checkpoint_overdrive_left_defeated": true,
		"factory_checkpoint_overdrive_right_defeated": true,
		"factory_checkpoint_overdrive_duo_cleared": true,
		"factory_lower_deck_skirmish_activated": true,
		"factory_lower_deck_skirmish_defeated": true,
		"factory_lower_deck_reward_cache_claimed": true,
		"factory_lower_deck_parry_gate_unlocked": true,
		"factory_lower_deck_exit_ambush_activated": true,
		"factory_lower_deck_exit_ambush_defeated": true,
		"factory_lower_deck_shortcut_activated": shortcut_open,
		"factory_lower_deck_shortcut_guard_defeated": shortcut_open,
		"factory_lower_deck_shortcut_unlocked": shortcut_open,
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
