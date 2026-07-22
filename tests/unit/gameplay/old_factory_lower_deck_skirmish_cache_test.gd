## Player Abilities Stories 053/179: Lower Deck cache and production input.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_LOWER_DECK_SPARK_RAT_ENTITY_ID: int = 2108
const LOWER_DECK_CACHE_TEXTURE: String = (
	"res://assets/environment/old_factory_lower_deck_skirmish_cache/"
	+ "env_old_factory_lower_deck_skirmish_cache_claimable_256.png"
)
const REQUIRED_LOWER_DECK_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]
const MIN_CHARACTER_ANIMATION_FRAMES: int = 3

var _spawned_nodes: Array[Node] = []


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


func test_lower_deck_skirmish_requires_overdrive_clear_but_not_cache_claim() -> void:
	var locked_scene: Node = _factory_scene_with_rear_ambush_cleared()
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method("get_factory_lower_deck_skirmish_diagnostics")).is_true()
	assert_bool(locked_scene.has_method("try_activate_factory_lower_deck_skirmish")).is_true()
	if (
		not locked_scene.has_method("get_factory_lower_deck_skirmish_diagnostics")
		or not locked_scene.has_method("try_activate_factory_lower_deck_skirmish")
	):
		return

	var locked: Dictionary = locked_scene.call("get_factory_lower_deck_skirmish_diagnostics")
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked_scene.call("try_activate_factory_lower_deck_skirmish"))).is_false()

	var destination: Node = _factory_scene_with_overdrive_duo_cleared(false)
	assert_that(destination).is_not_null()
	if destination == null:
		return
	assert_bool(destination.has_method("get_factory_lower_deck_skirmish_diagnostics")).is_true()
	assert_bool(destination.has_method("try_activate_factory_lower_deck_skirmish")).is_true()
	if (
		not destination.has_method("get_factory_lower_deck_skirmish_diagnostics")
		or not destination.has_method("try_activate_factory_lower_deck_skirmish")
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(service_lift).is_not_null()
	if player == null or service_lift == null:
		return

	var before: Dictionary = destination.call("get_factory_lower_deck_skirmish_diagnostics")
	assert_bool(bool(before.get("available", false))).is_true()
	assert_bool(bool(before.get("active", true))).is_false()
	assert_bool(bool(before.get("defeated", true))).is_false()
	assert_bool(bool(before.get("cache_claimed", true))).is_false()
	assert_str(String(before.get("cache_texture_path", ""))).is_equal(LOWER_DECK_CACHE_TEXTURE)
	assert_bool(bool(before.get("cache_visible", true))).is_false()
	assert_bool(bool(before.get("pressure_hazard_active", true))).is_false()

	player.global_position.x = float(before.get("activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call("try_activate_factory_lower_deck_skirmish", player))).is_true()

	var active: Dictionary = destination.call("get_factory_lower_deck_skirmish_diagnostics")
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("enemy_visible", false))).is_true()
	assert_bool(bool(active.get("enemy_has_target", false))).is_true()
	assert_bool(bool(active.get("enemy_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("enemy_process_enabled", false))).is_true()
	assert_bool(bool(active.get("pressure_hazard_active", false))).is_true()
	assert_int(int(active.get("entity_id", 0))).is_equal(FACTORY_LOWER_DECK_SPARK_RAT_ENTITY_ID)
	_assert_lower_deck_frame_contract(active)

	var objective: Dictionary = destination.call("get_factory_route_objective_diagnostics")
	assert_str(String(objective.get("objective_id", ""))).is_equal("clear_lower_deck_skirmish")
	assert_str(String(objective.get("route_label_text", ""))).is_equal("Clear Lower Deck Skirmish")

	player.global_position = service_lift.global_position
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


func test_production_process_auto_activates_lower_deck_after_overdrive_clear() -> void:
	var destination: Node = _factory_scene_with_overdrive_duo_cleared(false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var before: Dictionary = destination.call("get_factory_lower_deck_skirmish_diagnostics")
	assert_bool(bool(before.get("available", false))).is_true()
	assert_bool(bool(before.get("active", true))).is_false()
	player.global_position.x = float(before.get("activation_x", 0.0)) - 1.0
	destination.call("_process", 0.0)
	assert_bool(bool(
		destination.call("get_factory_lower_deck_skirmish_diagnostics").get(
			"active",
			true
		)
	)).is_false()
	player.global_position.x = float(before.get("activation_x", 0.0)) + 1.0

	# Exercise the production frame loop; do not call the activation API directly.
	destination.call("_process", 0.0)

	var active: Dictionary = destination.call("get_factory_lower_deck_skirmish_diagnostics")
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("enemy_visible", false))).is_true()
	assert_bool(bool(active.get("enemy_has_target", false))).is_true()
	assert_bool(bool(active.get("enemy_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("enemy_process_enabled", false))).is_true()
	assert_bool(bool(active.get("pressure_hazard_active", false))).is_true()
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get(
			"objective_id",
			""
		)
	)).is_equal("clear_lower_deck_skirmish")
	assert_str(String(
		destination.call("get_factory_service_lift_diagnostics").get(
			"prompt_text",
			""
		)
	)).is_equal("Call lift")


func test_lower_deck_skirmish_defeat_unlocks_independent_reward_cache_and_persists() -> void:
	var destination: Node = _factory_scene_with_overdrive_duo_cleared(false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("try_activate_factory_lower_deck_skirmish")).is_true()
	assert_bool(destination.has_method("try_claim_factory_lower_deck_reward_cache")).is_true()
	assert_bool(destination.has_method("get_factory_lower_deck_skirmish_diagnostics")).is_true()
	if (
		not destination.has_method("try_activate_factory_lower_deck_skirmish")
		or not destination.has_method("try_claim_factory_lower_deck_reward_cache")
		or not destination.has_method("get_factory_lower_deck_skirmish_diagnostics")
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var before: Dictionary = destination.call("get_factory_lower_deck_skirmish_diagnostics")
	player.global_position.x = float(before.get("activation_x", 0.0)) + 8.0
	assert_bool(bool(destination.call("try_activate_factory_lower_deck_skirmish", player))).is_true()

	assert_bool(destination.call("apply_damage", FACTORY_LOWER_DECK_SPARK_RAT_ENTITY_ID, 999, {
		"source": &"unit_test_lower_deck_skirmish",
	})).is_true()
	await get_tree().process_frame

	var cleared: Dictionary = destination.call("get_factory_lower_deck_skirmish_diagnostics")
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("defeated", false))).is_true()
	assert_bool(bool(cleared.get("enemy_visible", true))).is_false()
	assert_bool(bool(cleared.get("pressure_hazard_active", true))).is_false()
	assert_bool(bool(cleared.get("cache_visible", false))).is_true()
	assert_bool(bool(cleared.get("cache_available", false))).is_true()
	assert_bool(bool(cleared.get("cache_claim_available", false))).is_true()

	var cache_position: Vector2 = cleared.get("cache_position", Vector2.ZERO) as Vector2
	player.global_position = cache_position
	assert_bool(bool(destination.call("try_claim_factory_lower_deck_reward_cache", player))).is_true()
	assert_bool(bool(destination.call("try_claim_factory_lower_deck_reward_cache", player))).is_false()

	var claimed: Dictionary = destination.call("get_factory_lower_deck_skirmish_diagnostics")
	var reward: Dictionary = claimed.get("last_reward", {}) as Dictionary
	var feedback: Dictionary = claimed.get("last_claim_feedback", {}) as Dictionary
	assert_bool(bool(claimed.get("cache_claimed", false))).is_true()
	assert_str(String(reward.get("cache_id", ""))).is_equal("old_factory_lower_deck_cache")
	assert_int(int(reward.get("gears", 0))).is_equal(10)
	assert_str(String(reward.get("source", ""))).is_equal("old_factory_lower_deck_cache")
	assert_str(String(feedback.get("text", ""))).is_equal("Lower Deck Cache Claimed +10 Gears")
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Lower Deck Cache Claimed +10 Gears")

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get("factory_lower_deck_skirmish_activated", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_skirmish_defeated", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_reward_cache_claimed", false))).is_true()
	assert_bool(bool(local_state.get("factory_checkpoint_overdrive_reward_cache_claimed", true))).is_false()

	var restored: Node = _instantiate_factory_scene()
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", local_state)
	var restored_diagnostics: Dictionary = restored.call("get_factory_lower_deck_skirmish_diagnostics")
	assert_bool(bool(restored_diagnostics.get("active", true))).is_false()
	assert_bool(bool(restored_diagnostics.get("defeated", false))).is_true()
	assert_bool(bool(restored_diagnostics.get("cache_claimed", false))).is_true()
	assert_bool(bool(restored_diagnostics.get("cache_claim_available", true))).is_false()


func test_real_interact_claims_nearest_lower_deck_cache_and_exposes_parry_gate() -> void:
	var destination: Node = _factory_scene_with_overdrive_duo_cleared(true)
	assert_that(destination).is_not_null()
	if destination == null:
		return
	var local_state: Dictionary = destination.call("get_local_state")
	local_state.merge({
		"factory_return_patrol_reward_cache_claimed": false,
		"factory_lower_deck_skirmish_activated": true,
		"factory_lower_deck_skirmish_defeated": true,
		"factory_lower_deck_reward_cache_claimed": false,
	}, true)
	destination.call("set_local_state", local_state)

	var lower: Dictionary = destination.call("get_factory_lower_deck_skirmish_diagnostics")
	var return_cache: Dictionary = destination.call(
		"get_factory_return_patrol_reward_cache_diagnostics"
	)
	assert_bool(bool(lower.get("cache_claim_available", false))).is_true()
	assert_bool(bool(return_cache.get("claim_available", false))).is_true()
	assert_float(
		(lower.get("cache_position", Vector2.ZERO) as Vector2).distance_to(
			return_cache.get("position", Vector2.ZERO) as Vector2
		)
	).is_less_equal(96.0)

	var player := destination.get_node(FACTORY_PLAYER_NAME) as CharacterBody2D
	player.global_position = lower.get("cache_position", Vector2.ZERO) as Vector2
	Input.action_press(&"interact")
	destination.call("_process", 0.0)
	Input.action_release(&"interact")
	destination.call("_process", 0.0)

	lower = destination.call("get_factory_lower_deck_skirmish_diagnostics")
	return_cache = destination.call("get_factory_return_patrol_reward_cache_diagnostics")
	var gate: Dictionary = destination.call("get_factory_lower_deck_parry_gate_diagnostics")
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	var reward: Dictionary = lower.get("last_reward", {}) as Dictionary
	var feedback: Dictionary = lower.get("last_claim_feedback", {}) as Dictionary
	assert_bool(bool(lower.get("cache_claimed", false))).is_true()
	assert_bool(bool(return_cache.get("claimed", true))).is_false()
	assert_int(int(reward.get("gears", 0))).is_equal(10)
	assert_str(String(reward.get("source", ""))).is_equal("old_factory_lower_deck_cache")
	assert_str(String(feedback.get("text", ""))).is_equal(
		"Lower Deck Cache Claimed +10 Gears"
	)
	assert_bool(bool(gate.get("available", false))).is_true()
	assert_bool(bool(gate.get("visible", false))).is_true()
	assert_bool(bool(gate.get("collision_blocking", false))).is_true()
	assert_bool(bool(lift.get("exit_requested", true))).is_false()
	assert_bool(bool(
		destination.call("get_local_state").get(
			"factory_lower_deck_reward_cache_claimed",
			false
		)
	)).is_true()


func _factory_scene_with_rear_ambush_cleared() -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _overdrive_ready_state().merged({
		"factory_checkpoint_overdrive_duo_activated": false,
		"factory_checkpoint_overdrive_left_defeated": false,
		"factory_checkpoint_overdrive_right_defeated": false,
		"factory_checkpoint_overdrive_duo_cleared": false,
	}, true))
	return destination


func _factory_scene_with_overdrive_duo_cleared(cache_claimed: bool) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _overdrive_ready_state().merged({
		"factory_checkpoint_overdrive_duo_activated": true,
		"factory_checkpoint_overdrive_left_defeated": true,
		"factory_checkpoint_overdrive_right_defeated": true,
		"factory_checkpoint_overdrive_duo_cleared": true,
		"factory_checkpoint_overdrive_reward_cache_claimed": cache_claimed,
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


func _overdrive_ready_state() -> Dictionary:
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


func _assert_lower_deck_frame_contract(diagnostics: Dictionary) -> void:
	var frame_counts: Dictionary = diagnostics.get("animation_frame_counts", {}) as Dictionary
	for animation_name: StringName in REQUIRED_LOWER_DECK_ANIMATIONS:
		var animation_key: String = String(animation_name)
		assert_bool(frame_counts.has(animation_key)).is_true()
		if frame_counts.has(animation_key):
			assert_int(int(frame_counts[animation_key])).is_greater_equal(
				MIN_CHARACTER_ANIMATION_FRAMES
			)


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
