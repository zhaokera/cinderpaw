## Player Abilities Story 123: Old Factory pincer reward exit hatch handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const PINCER_EXIT_HATCH_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerExitHatch"
)
const PINCER_EXIT_HATCH_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch"
)
const PINCER_EXIT_HATCH_TEXTURE: String = (
	"res://assets/environment/old_factory_lower_deck_deep_bulkhead/"
	+ "env_old_factory_lower_deck_deep_bulkhead_closed_256.png"
)
const UNLOCK_VFX_TEXTURE: String = (
	"res://assets/environment/old_factory_deep_route/vfx/"
	+ "factory_deep_route_unlock_spark.png"
)
const PINCER_REWARD_CACHE_STATE_KEY: String = (
	"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_claimed"
)
const PINCER_EXIT_HATCH_STATE_KEY: String = (
	"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened"
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


func test_tailrace_relay_runoff_pincer_exit_hatch_requires_reward_cache_and_opens_once(
) -> void:
	assert_bool(FileAccess.file_exists(PINCER_EXIT_HATCH_TEXTURE)).is_true()
	assert_bool(FileAccess.file_exists(UNLOCK_VFX_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_pincer_exit_hatch_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_diagnostics"
		)
		or not locked_scene.has_method(
			"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("pincer_reward_cache_claimed", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("opened", true))).is_false()
	assert_bool(bool(locked.get("collision_blocking", true))).is_false()
	assert_str(String(locked.get("prompt_text", ""))).is_equal("Claim pincer cache")
	assert_bool(bool(locked_scene.call(
		"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch"
	))).is_false()

	var destination: Node = _factory_scene_with_pincer_exit_hatch_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var hatch: Node2D = destination.get_node_or_null(PINCER_EXIT_HATCH_NODE_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(hatch).is_not_null()
	if player == null or hatch == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("pincer_reward_cache_claimed", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("opened", true))).is_false()
	assert_str(String(ready.get("hatch_id", ""))).is_equal(PINCER_EXIT_HATCH_ID)
	assert_str(String(ready.get("prompt_text", ""))).is_equal("Open Tailrace Exit")
	assert_str(String(ready.get("texture_path", ""))).is_equal(PINCER_EXIT_HATCH_TEXTURE)
	assert_str(String(ready.get("unlock_feedback_texture_path", ""))).is_equal(
		UNLOCK_VFX_TEXTURE
	)
	assert_bool(bool(ready.get("interaction_monitoring", false))).is_true()
	assert_bool(bool(ready.get("interaction_monitorable", false))).is_true()
	assert_bool(bool(ready.get("collision_blocking", false))).is_true()
	assert_vector(ready.get("position", Vector2.ZERO) as Vector2).is_equal(
		Vector2(16080, 392)
	)
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Open Tailrace Runoff Exit"
	)
	assert_float(float(ready.get("right_wall_x", 0.0))).is_greater_equal(16480.0)
	assert_int(int(ready.get("camera_limit_right", 0))).is_greater_equal(16500)
	assert_float(float(ready.get("background_width", 0.0))).is_greater_equal(
		16500.0
	)
	assert_float(float(ready.get("ground_right_edge_x", 0.0))).is_greater_equal(
		16600.0
	)
	assert_int(int(ready.get("floor_tile_count", 0))).is_greater_equal(66)

	player.global_position = ready.get("position", Vector2.ZERO) as Vector2
	assert_bool(bool(destination.call(
		"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch",
		player
	))).is_true()

	var opened: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_diagnostics"
	)
	assert_bool(bool(opened.get("opened", false))).is_true()
	assert_bool(bool(opened.get("available", true))).is_false()
	assert_bool(bool(opened.get("visible", false))).is_true()
	assert_bool(bool(opened.get("collision_blocking", true))).is_false()
	assert_str(String(opened.get("prompt_text", ""))).is_equal("Tailrace Exit Open")
	assert_str(String(opened.get("route_label_text", ""))).is_equal(
		"Tailrace Runoff Exit Opened"
	)
	assert_bool(bool(opened.get("unlock_feedback_played", false))).is_true()
	assert_int(int(opened.get("unlock_feedback_spawn_count", 0))).is_equal(1)
	assert_bool(bool(destination.call(
		"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch",
		player
	))).is_false()

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(PINCER_EXIT_HATCH_STATE_KEY, false))).is_true()


func test_tailrace_relay_runoff_pincer_exit_hatch_restore_backfills_reward_chain(
) -> void:
	var restored: Node = _factory_scene_with_only_pincer_exit_hatch_opened_state()
	assert_that(restored).is_not_null()
	if restored == null:
		return
	assert_bool(restored.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_diagnostics"
	)).is_true()
	if not restored.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_diagnostics"
	):
		return

	var restored_hatch: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_diagnostics"
	)
	assert_bool(bool(restored_hatch.get("opened", false))).is_true()
	assert_bool(bool(restored_hatch.get("pincer_reward_cache_claimed", false))).is_true()
	assert_bool(bool(restored_hatch.get("available", true))).is_false()
	assert_bool(bool(restored_hatch.get("collision_blocking", true))).is_false()
	assert_str(String(restored_hatch.get("route_label_text", ""))).is_equal(
		"Tailrace Runoff Exit Opened"
	)
	assert_int(int(restored_hatch.get("unlock_feedback_spawn_count", -1))).is_equal(0)

	var reward_cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_diagnostics"
	)
	assert_bool(bool(reward_cache.get("claimed", false))).is_true()
	var pincer: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_diagnostics"
	)
	assert_bool(bool(pincer.get("cleared", false))).is_true()
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
	assert_bool(bool(local_state.get(PINCER_EXIT_HATCH_STATE_KEY, false))).is_true()


func _factory_scene_with_pincer_exit_hatch_state(
	pincer_reward_cache_claimed: bool,
	exit_hatch_opened: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	var state: Dictionary = _pincer_cleared_state().merged({
		PINCER_REWARD_CACHE_STATE_KEY: pincer_reward_cache_claimed,
		PINCER_EXIT_HATCH_STATE_KEY: exit_hatch_opened,
	}, true)
	destination.call("set_local_state", state)
	return destination


func _factory_scene_with_only_pincer_exit_hatch_opened_state() -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", {
		PINCER_EXIT_HATCH_STATE_KEY: true,
		"last_return_checkpoint": _tailrace_relay_checkpoint_snapshot(),
	})
	return destination


func _pincer_cleared_state() -> Dictionary:
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
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_spark_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_coil_rat_defeated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_cleared": true,
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
		elif child is AudioStreamPlayer2D:
			(child as AudioStreamPlayer2D).stop()
