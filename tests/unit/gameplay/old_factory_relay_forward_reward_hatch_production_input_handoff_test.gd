## Story188: relay-forward reward and hatch production interact handoff.
extends GdUnitTestSuite

const FACTORY_SCENE: PackedScene = preload(
	"res://scenes/factory_route_transition_shell.tscn"
)
const FACTORY_PLAYER_NAME: String = "Player"
const RELAY_FORWARD_CACHE_NAME: String = "FactoryLowerDeckRelayForwardRewardCache"
const FORWARD_HATCH_NAME: String = "FactoryLowerDeckForwardHatch"
const SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const BREACH_RELAY_PROMPT_PATH: NodePath = NodePath(
	"FactoryLowerDeckBreachRelaySavepoint/PromptLabel"
)
const PRESSURE_VALVE_PROMPT_PATH: NodePath = NodePath(
	"FactoryLowerDeckPressureValve/PromptLabel"
)
const SHORTCUT_SEAL_PROMPT_PATH: NodePath = NodePath(
	"FactoryLowerDeckShortcutSeal/PromptLabel"
)
const THREE_WAY_OVERLAP_POSITION: Vector2 = Vector2(1184, 350)

var _spawned_nodes: Array[Node] = []


class FakeServiceLiftSceneManager:
	extends RefCounted

	var request_calls: Array[Dictionary] = []
	var loading: bool = false

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == &"main" or scene_id == &"area_03_factory"

	func get_current_scene() -> StringName:
		return &"area_03_factory"

	func is_loading() -> bool:
		return loading

	func is_scene_locked() -> bool:
		return false

	func get_pending_scene() -> StringName:
		if request_calls.is_empty():
			return &""
		return StringName(String(request_calls.back().get("scene_id", "")))

	func get_pending_spawn_point() -> StringName:
		if request_calls.is_empty():
			return &""
		return StringName(String(request_calls.back().get("spawn_point", "")))

	func request_scene_change(
		scene_id: StringName,
		spawn_point: StringName = &"default"
	) -> bool:
		if loading or not has_scene(scene_id):
			return false
		request_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		loading = true
		return true


func before_test() -> void:
	Input.action_release(&"interact")


func after_test() -> void:
	Input.action_release(&"interact")
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_real_interact_claims_relay_cache_then_opens_hatch_on_next_rising_edge() -> void:
	var destination: Node = _instantiate_factory_scene()
	var scene_manager := FakeServiceLiftSceneManager.new()
	assert_bool(bool(destination.call(
		"configure_scene_manager_runtime",
		scene_manager
	))).is_true()
	destination.call("set_local_state", _relay_reward_ready_state())
	var player := destination.get_node(FACTORY_PLAYER_NAME) as CharacterBody2D
	var cache_node := destination.get_node(RELAY_FORWARD_CACHE_NAME) as Node2D
	var hatch_node := destination.get_node(FORWARD_HATCH_NAME) as Node2D
	var lift_node := destination.get_node(SERVICE_LIFT_NAME) as Node2D
	var breach_relay_prompt := destination.get_node(BREACH_RELAY_PROMPT_PATH) as Label
	var pressure_valve_prompt := destination.get_node(PRESSURE_VALVE_PROMPT_PATH) as Label
	var shortcut_seal_prompt := destination.get_node(SHORTCUT_SEAL_PROMPT_PATH) as Label
	assert_bool(breach_relay_prompt.visible).is_false()
	assert_bool(pressure_valve_prompt.visible).is_false()
	assert_bool(shortcut_seal_prompt.visible).is_false()

	var cache: Dictionary = destination.call(
		"get_factory_lower_deck_relay_forward_reward_cache_diagnostics"
	)
	var hatch: Dictionary = destination.call(
		"get_factory_lower_deck_forward_hatch_diagnostics"
	)
	assert_bool(bool(cache.get("claim_available", false))).is_true()
	assert_bool(bool(cache.get("claimed", true))).is_false()
	assert_bool(bool(hatch.get("visible", false))).is_true()
	assert_bool(bool(hatch.get("available", true))).is_false()
	assert_str(String(hatch.get("prompt_text", ""))).is_equal("Claim relay cache")

	player.global_position = THREE_WAY_OVERLAP_POSITION
	assert_bool(bool(cache_node.call("is_provider_in_reward_range", player))).is_true()
	assert_bool(bool(hatch_node.call("is_provider_in_activation_range", player))).is_true()
	assert_bool(bool(lift_node.call("is_provider_in_activation_range", player))).is_true()
	_press_interact(destination)

	cache = destination.call(
		"get_factory_lower_deck_relay_forward_reward_cache_diagnostics"
	)
	hatch = destination.call("get_factory_lower_deck_forward_hatch_diagnostics")
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	var reward: Dictionary = cache.get("last_reward", {}) as Dictionary
	var feedback: Dictionary = cache.get("last_claim_feedback", {}) as Dictionary
	assert_bool(bool(cache.get("claimed", false))).is_true()
	assert_int(int(reward.get("gears", 0))).is_equal(20)
	assert_str(String(reward.get("source", ""))).is_equal(
		"old_factory_lower_deck_relay_forward_cache"
	)
	assert_str(String(feedback.get("text", ""))).is_equal(
		"Relay Forward Cache Claimed +20 Gears"
	)
	assert_bool(bool(hatch.get("available", false))).is_true()
	assert_bool(bool(hatch.get("opened", true))).is_false()
	assert_str(String(hatch.get("prompt_text", ""))).is_equal("Open forward hatch")
	assert_int(scene_manager.request_calls.size()).is_equal(0)
	assert_bool(bool(lift.get("activated", true))).is_false()
	assert_bool(bool(lift.get("exit_requested", true))).is_false()
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get(
			"route_label_text",
			""
		)
	)).is_equal("Relay Forward Cache Claimed +20 Gears")

	# Holding the same press must not chain the newly available hatch action.
	destination.call("_process", 0.0)
	hatch = destination.call("get_factory_lower_deck_forward_hatch_diagnostics")
	assert_bool(bool(hatch.get("opened", true))).is_false()
	assert_int(scene_manager.request_calls.size()).is_equal(0)

	_release_interact(destination)
	_press_interact(destination)
	hatch = destination.call("get_factory_lower_deck_forward_hatch_diagnostics")
	lift = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(hatch.get("opened", false))).is_true()
	assert_bool(bool(hatch.get("available", true))).is_false()
	assert_bool(bool(hatch.get("collision_blocking", true))).is_false()
	assert_int(scene_manager.request_calls.size()).is_equal(0)
	assert_bool(bool(lift.get("activated", true))).is_false()
	assert_bool(bool(lift.get("exit_requested", true))).is_false()
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get(
			"route_label_text",
			""
		)
	)).is_equal("Lower Deck Forward Hatch Opened")

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_relay_forward_reward_cache_claimed",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_hatch_opened",
		false
	))).is_true()

	var restored: Node = _instantiate_factory_scene()
	restored.call("set_local_state", local_state)
	var restored_cache: Dictionary = restored.call(
		"get_factory_lower_deck_relay_forward_reward_cache_diagnostics"
	)
	var restored_hatch: Dictionary = restored.call(
		"get_factory_lower_deck_forward_hatch_diagnostics"
	)
	assert_bool(bool(restored_cache.get("claimed", false))).is_true()
	assert_bool(bool(restored_hatch.get("opened", false))).is_true()
	assert_bool(bool(restored_hatch.get("collision_blocking", true))).is_false()


func _instantiate_factory_scene() -> Node:
	var destination: Node = FACTORY_SCENE.instantiate()
	add_child(destination)
	_spawned_nodes.append(destination)
	return destination


func _press_interact(destination: Node) -> void:
	Input.action_press(&"interact")
	destination.call("_process", 0.0)


func _release_interact(destination: Node) -> void:
	Input.action_release(&"interact")
	destination.call("_process", 0.0)


func _relay_reward_ready_state() -> Dictionary:
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
		"factory_return_patrol_reward_cache_claimed": true,
		"factory_checkpoint_forward_patrol_activated": true,
		"factory_checkpoint_forward_patrol_defeated": true,
		"factory_checkpoint_rear_ambush_activated": true,
		"factory_checkpoint_rear_ambush_defeated": true,
		"factory_checkpoint_overdrive_duo_activated": true,
		"factory_checkpoint_overdrive_left_defeated": true,
		"factory_checkpoint_overdrive_right_defeated": true,
		"factory_checkpoint_overdrive_duo_cleared": true,
		"factory_checkpoint_overdrive_reward_cache_claimed": true,
		"factory_lower_deck_skirmish_activated": true,
		"factory_lower_deck_skirmish_defeated": true,
		"factory_lower_deck_reward_cache_claimed": true,
		"factory_lower_deck_parry_gate_unlocked": true,
		"factory_lower_deck_exit_ambush_activated": true,
		"factory_lower_deck_exit_ambush_defeated": true,
		"factory_lower_deck_shortcut_activated": true,
		"factory_lower_deck_shortcut_guard_defeated": true,
		"factory_lower_deck_shortcut_unlocked": true,
		"factory_lower_deck_shortcut_reward_cache_claimed": true,
		"factory_lower_deck_shortcut_pursuer_activated": true,
		"factory_lower_deck_shortcut_pursuer_defeated": true,
		"factory_lower_deck_pressure_guard_activated": true,
		"factory_lower_deck_pressure_guard_defeated": true,
		"factory_lower_deck_pressure_valve_opened": true,
		"factory_lower_deck_steam_sluice_activated": true,
		"factory_lower_deck_steam_sluice_defeated": true,
		"factory_lower_deck_deep_bulkhead_guard_activated": true,
		"factory_lower_deck_deep_bulkhead_guard_defeated": true,
		"factory_lower_deck_deep_bulkhead_opened": true,
		"factory_lower_deck_breach_corridor_activated": true,
		"factory_lower_deck_breach_front_guard_defeated": true,
		"factory_lower_deck_breach_rear_ambusher_activated": true,
		"factory_lower_deck_breach_rear_ambusher_defeated": true,
		"factory_lower_deck_breach_corridor_secured": true,
		"factory_lower_deck_breach_relay_activated": true,
		"factory_lower_deck_post_relay_trial_activated": true,
		"factory_lower_deck_post_relay_trial_defeated": true,
		"factory_lower_deck_relay_forward_reward_cache_claimed": false,
		"factory_lower_deck_forward_hatch_opened": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
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
