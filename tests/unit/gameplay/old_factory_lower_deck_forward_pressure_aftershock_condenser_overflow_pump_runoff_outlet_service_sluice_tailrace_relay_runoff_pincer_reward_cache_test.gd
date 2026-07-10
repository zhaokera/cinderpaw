## Player Abilities Story 122: Old Factory tailrace relay runoff pincer reward cache.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const PINCER_REWARD_CACHE_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache"
)
const PINCER_REWARD_CACHE_TEXTURE: String = (
	"res://assets/environment/old_factory_lower_deck_skirmish_cache/"
	+ "env_old_factory_lower_deck_skirmish_cache_claimable_256.png"
)
const PINCER_REWARD_CACHE_STATE_KEY: String = (
	"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_claimed"
)
const TAILRACE_RELAY_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
)
const TAILRACE_RELAY_SPAWN_POINT: String = (
	"lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
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


func test_tailrace_relay_runoff_pincer_reward_cache_requires_pincer_clear_and_claims_once(
) -> void:
	assert_bool(FileAccess.file_exists(PINCER_REWARD_CACHE_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_tailrace_relay_runoff_pincer_reward_state(
		false,
		false
	)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_diagnostics"
		)
		or not locked_scene.has_method(
			"try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("pincer_cleared", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("claim_available", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache"
	))).is_false()

	var active_scene: Node = _factory_scene_with_tailrace_relay_runoff_pincer_active_state()
	assert_that(active_scene).is_not_null()
	if active_scene == null:
		return
	var active_cache: Dictionary = active_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_diagnostics"
	)
	assert_bool(bool(active_cache.get("pincer_active", false))).is_true()
	assert_bool(bool(active_cache.get("available", true))).is_false()
	assert_bool(bool(active_cache.get("visible", true))).is_false()
	assert_bool(bool(active_cache.get("claim_available", true))).is_false()

	var half_cleared_scene: Node = (
		_factory_scene_with_tailrace_relay_runoff_pincer_half_cleared_state()
	)
	assert_that(half_cleared_scene).is_not_null()
	if half_cleared_scene == null:
		return
	var half_cleared_cache: Dictionary = half_cleared_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_diagnostics"
	)
	assert_bool(bool(half_cleared_cache.get("pincer_cleared", true))).is_false()
	assert_bool(bool(half_cleared_cache.get("available", true))).is_false()
	assert_bool(bool(half_cleared_cache.get("visible", true))).is_false()

	var destination: Node = _factory_scene_with_tailrace_relay_runoff_pincer_reward_state(
		true,
		false
	)
	assert_that(destination).is_not_null()
	if destination == null:
		return
	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var available: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_diagnostics"
	)
	assert_bool(bool(available.get("pincer_cleared", false))).is_true()
	assert_bool(bool(available.get("available", false))).is_true()
	assert_bool(bool(available.get("visible", false))).is_true()
	assert_bool(bool(available.get("claim_available", false))).is_true()
	assert_bool(bool(available.get("claimed", true))).is_false()
	assert_str(String(available.get("cache_id", ""))).is_equal(PINCER_REWARD_CACHE_ID)
	assert_str(String(available.get("texture_path", ""))).is_equal(
		PINCER_REWARD_CACHE_TEXTURE
	)
	assert_str(String(available.get("prompt_text", ""))).is_equal("+20 Gears")
	assert_vector(available.get("position", Vector2.ZERO) as Vector2).is_equal(
		Vector2(15460, 410)
	)
	assert_float(float(available.get("right_wall_x", 0.0))).is_greater_equal(15580.0)
	assert_int(int(available.get("camera_limit_right", 0))).is_greater_equal(15600)
	assert_float(float(available.get("background_width", 0.0))).is_greater_equal(
		15600.0
	)
	assert_float(float(available.get("ground_right_edge_x", 0.0))).is_greater_equal(
		15700.0
	)
	assert_str(String(available.get("route_label_text", ""))).is_equal(
		"Tailrace Runoff Pincer Cleared"
	)

	player.global_position = available.get("position", Vector2.ZERO) as Vector2
	assert_bool(bool(destination.call(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache",
		player
	))).is_true()
	assert_bool(bool(destination.call(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache",
		player
	))).is_false()

	var claimed: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_diagnostics"
	)
	var reward: Dictionary = claimed.get("last_reward", {}) as Dictionary
	var feedback: Dictionary = claimed.get("last_claim_feedback", {}) as Dictionary
	assert_bool(bool(claimed.get("claimed", false))).is_true()
	assert_bool(bool(claimed.get("claim_available", true))).is_false()
	assert_str(String(reward.get("cache_id", ""))).is_equal(PINCER_REWARD_CACHE_ID)
	assert_int(int(reward.get("gears", 0))).is_equal(20)
	assert_str(String(reward.get("source", ""))).is_equal(PINCER_REWARD_CACHE_ID)
	assert_str(String(feedback.get("text", ""))).is_equal(
		"Tailrace Runoff Pincer Cache Claimed +20 Gears"
	)
	assert_str(String(claimed.get("route_label_text", ""))).is_equal(
		"Tailrace Runoff Pincer Cache Claimed +20 Gears"
	)

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(PINCER_REWARD_CACHE_STATE_KEY, false))).is_true()


func test_tailrace_relay_runoff_pincer_reward_cache_restore_backfills_pincer_chain(
) -> void:
	var restored: Node = _factory_scene_with_only_pincer_reward_cache_claimed_state()
	assert_that(restored).is_not_null()
	if restored == null:
		return
	assert_bool(restored.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_diagnostics"
	)).is_true()
	if not restored.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_diagnostics"
	):
		return

	var restored_cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_diagnostics"
	)
	assert_bool(bool(restored_cache.get("claimed", false))).is_true()
	assert_bool(bool(restored_cache.get("pincer_cleared", false))).is_true()
	assert_bool(bool(restored_cache.get("claim_available", true))).is_false()
	assert_str(String(restored_cache.get("route_label_text", ""))).is_equal(
		"Tailrace Runoff Pincer Cache Claimed +20 Gears"
	)

	var pincer: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_diagnostics"
	)
	assert_bool(bool(pincer.get("cleared", false))).is_true()
	assert_bool(bool(pincer.get("tailrace_relay_runoff_crossed", false))).is_true()
	assert_bool(bool(pincer.get("spark_visible", true))).is_false()
	assert_bool(bool(pincer.get("coil_visible", true))).is_false()
	var savepoint: Dictionary = pincer.get("last_savepoint", {}) as Dictionary
	assert_str(String(savepoint.get("id", ""))).is_equal(TAILRACE_RELAY_ID)
	assert_str(String(savepoint.get("scene_id", ""))).is_equal("area_03_factory")
	assert_str(String(savepoint.get("spawn_point", ""))).is_equal(
		TAILRACE_RELAY_SPAWN_POINT
	)

	var local_state: Dictionary = restored.call("get_local_state")
	assert_bool(bool(local_state.get(PINCER_REWARD_CACHE_STATE_KEY, false))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_cleared",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_spark_rat_defeated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_coil_rat_defeated",
		false
	))).is_true()


func _factory_scene_with_tailrace_relay_runoff_pincer_reward_state(
	pincer_cleared: bool,
	reward_cache_claimed: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	var state: Dictionary = _tailrace_relay_runoff_crossed_state().merged({
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_activated": (
			pincer_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_spark_rat_defeated": (
			pincer_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_coil_rat_defeated": (
			pincer_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_cleared": (
			pincer_cleared
		),
		PINCER_REWARD_CACHE_STATE_KEY: reward_cache_claimed,
	}, true)
	destination.call("set_local_state", state)
	return destination


func _factory_scene_with_tailrace_relay_runoff_pincer_active_state() -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	var state: Dictionary = _tailrace_relay_runoff_crossed_state().merged({
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_activated": true,
	}, true)
	destination.call("set_local_state", state)
	return destination


func _factory_scene_with_tailrace_relay_runoff_pincer_half_cleared_state() -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	var state: Dictionary = _tailrace_relay_runoff_crossed_state().merged({
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_spark_rat_defeated": true,
	}, true)
	destination.call("set_local_state", state)
	return destination


func _factory_scene_with_only_pincer_reward_cache_claimed_state() -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", {
		PINCER_REWARD_CACHE_STATE_KEY: true,
		"last_return_checkpoint": _tailrace_relay_checkpoint_snapshot(),
	})
	return destination


func _tailrace_relay_runoff_crossed_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_crossed": true,
		"last_return_checkpoint": _tailrace_relay_checkpoint_snapshot(),
	}


func _tailrace_relay_checkpoint_snapshot() -> Dictionary:
	return {
		"id": TAILRACE_RELAY_ID,
		"scene_id": "area_03_factory",
		"spawn_point": TAILRACE_RELAY_SPAWN_POINT,
		"position": Vector2(13480, 382),
	}


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


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
