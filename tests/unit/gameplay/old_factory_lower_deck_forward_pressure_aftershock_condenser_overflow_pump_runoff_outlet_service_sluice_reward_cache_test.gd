## Player Abilities Story 115: Old Factory service sluice reward cache.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const SERVICE_SLUICE_REWARD_CACHE_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache"
)
const SERVICE_SLUICE_REWARD_CACHE_TEXTURE: String = (
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


func test_service_sluice_reward_cache_requires_spark_rat_clear_and_claims_once(
) -> void:
	assert_bool(FileAccess.file_exists(SERVICE_SLUICE_REWARD_CACHE_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_service_sluice_reward_state(
		false,
		false
	)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_diagnostics"
		)
		or not locked_scene.has_method(
			"try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("service_sluice_skirmish_cleared", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("claim_available", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache"
	))).is_false()

	var destination: Node = _factory_scene_with_service_sluice_reward_state(
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
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_diagnostics"
	)
	assert_bool(bool(available.get("service_sluice_skirmish_cleared", false))).is_true()
	assert_bool(bool(available.get("available", false))).is_true()
	assert_bool(bool(available.get("visible", false))).is_true()
	assert_bool(bool(available.get("claim_available", false))).is_true()
	assert_bool(bool(available.get("claimed", true))).is_false()
	assert_str(String(available.get("cache_id", ""))).is_equal(
		SERVICE_SLUICE_REWARD_CACHE_ID
	)
	assert_str(String(available.get("texture_path", ""))).is_equal(
		SERVICE_SLUICE_REWARD_CACHE_TEXTURE
	)
	assert_str(String(available.get("prompt_text", ""))).is_equal("+20 Gears")
	assert_float(float(available.get("right_wall_x", 0.0))).is_greater_equal(11500.0)
	assert_int(int(available.get("camera_limit_right", 0))).is_greater_equal(11520)
	assert_float(float(available.get("background_width", 0.0))).is_greater_equal(
		11520.0
	)
	assert_float(float(available.get("ground_right_edge_x", 0.0))).is_greater_equal(
		11520.0
	)
	assert_str(String(available.get("route_label_text", ""))).is_equal(
		"Service Sluice Spark Rat Cleared"
	)

	player.global_position = available.get("position", Vector2.ZERO) as Vector2
	assert_bool(bool(destination.call(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache",
		player
	))).is_true()
	assert_bool(bool(destination.call(
		"try_claim_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache",
		player
	))).is_false()

	var claimed: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_diagnostics"
	)
	var reward: Dictionary = claimed.get("last_reward", {}) as Dictionary
	var feedback: Dictionary = claimed.get("last_claim_feedback", {}) as Dictionary
	assert_bool(bool(claimed.get("claimed", false))).is_true()
	assert_bool(bool(claimed.get("claim_available", true))).is_false()
	assert_str(String(reward.get("cache_id", ""))).is_equal(
		SERVICE_SLUICE_REWARD_CACHE_ID
	)
	assert_int(int(reward.get("gears", 0))).is_equal(20)
	assert_str(String(reward.get("source", ""))).is_equal(
		SERVICE_SLUICE_REWARD_CACHE_ID
	)
	assert_str(String(feedback.get("text", ""))).is_equal(
		"Service Sluice Cache Claimed +20 Gears"
	)
	assert_str(String(claimed.get("route_label_text", ""))).is_equal(
		"Service Sluice Cache Claimed +20 Gears"
	)

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_claimed",
		false
	))).is_true()


func test_service_sluice_reward_cache_restore_backfills_skirmish_chain(
) -> void:
	var restored: Node = _factory_scene_with_service_sluice_reward_state(
		false,
		true
	)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	assert_bool(restored.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_diagnostics"
	)).is_true()
	if not restored.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_diagnostics"
	):
		return

	var restored_cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_diagnostics"
	)
	assert_bool(bool(restored_cache.get("claimed", false))).is_true()
	assert_bool(bool(restored_cache.get("service_sluice_skirmish_cleared", false))).is_true()
	assert_bool(bool(restored_cache.get("claim_available", true))).is_false()
	assert_str(String(restored_cache.get("route_label_text", ""))).is_equal(
		"Open Service Sluice Exit"
	)

	var restored_skirmish: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_diagnostics"
	)
	assert_bool(bool(restored_skirmish.get("cleared", false))).is_true()
	assert_bool(bool(restored_skirmish.get("spark_visible", true))).is_false()
	var service_sluice: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_diagnostics"
	)
	assert_bool(bool(service_sluice.get("crossed", false))).is_true()
	assert_bool(bool(service_sluice.get("hazard_contact_active", true))).is_false()
	var service_hatch: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_diagnostics"
	)
	assert_bool(bool(service_hatch.get("opened", false))).is_true()
	assert_bool(bool(service_hatch.get("collision_blocking", true))).is_false()

	var local_state: Dictionary = restored.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_claimed",
		false
	))).is_true()


func _factory_scene_with_service_sluice_reward_state(
	service_sluice_skirmish_cleared: bool,
	reward_cache_claimed: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated": service_sluice_skirmish_cleared,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed": service_sluice_skirmish_cleared,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated": service_sluice_skirmish_cleared,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated": service_sluice_skirmish_cleared,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_cleared": service_sluice_skirmish_cleared,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed": service_sluice_skirmish_cleared,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened": service_sluice_skirmish_cleared,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated": service_sluice_skirmish_cleared,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed": service_sluice_skirmish_cleared,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated": service_sluice_skirmish_cleared,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated": service_sluice_skirmish_cleared,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared": service_sluice_skirmish_cleared,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_claimed": reward_cache_claimed,
	})
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


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
