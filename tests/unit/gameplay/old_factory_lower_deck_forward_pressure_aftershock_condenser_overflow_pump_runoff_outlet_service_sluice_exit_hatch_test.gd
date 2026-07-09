## Player Abilities Story 116: Old Factory service sluice exit hatch handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const SERVICE_EXIT_HATCH_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceExitHatch"
)
const SERVICE_EXIT_HATCH_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch"
)
const SERVICE_EXIT_HATCH_TEXTURE: String = (
	"res://assets/environment/old_factory_lower_deck_deep_bulkhead/"
	+ "env_old_factory_lower_deck_deep_bulkhead_closed_256.png"
)
const UNLOCK_VFX_TEXTURE: String = (
	"res://assets/environment/old_factory_deep_route/vfx/"
	+ "factory_deep_route_unlock_spark.png"
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


func test_service_sluice_exit_hatch_requires_cache_claim_and_opens_once() -> void:
	assert_bool(FileAccess.file_exists(SERVICE_EXIT_HATCH_TEXTURE)).is_true()
	assert_bool(FileAccess.file_exists(UNLOCK_VFX_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_service_exit_hatch_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics"
		)
		or not locked_scene.has_method(
			"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("service_sluice_cache_claimed", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("opened", true))).is_false()
	assert_bool(bool(locked.get("collision_blocking", true))).is_false()
	assert_str(String(locked.get("prompt_text", ""))).is_equal(
		"Claim service sluice cache"
	)
	assert_bool(bool(locked_scene.call(
		"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch"
	))).is_false()

	var destination: Node = _factory_scene_with_service_exit_hatch_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var hatch: Node2D = destination.get_node_or_null(SERVICE_EXIT_HATCH_NODE_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(hatch).is_not_null()
	if player == null or hatch == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("service_sluice_cache_claimed", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("opened", true))).is_false()
	assert_str(String(ready.get("hatch_id", ""))).is_equal(SERVICE_EXIT_HATCH_ID)
	assert_str(String(ready.get("prompt_text", ""))).is_equal("Open Service Exit")
	assert_str(String(ready.get("texture_path", ""))).is_equal(SERVICE_EXIT_HATCH_TEXTURE)
	assert_str(String(ready.get("unlock_feedback_texture_path", ""))).is_equal(
		UNLOCK_VFX_TEXTURE
	)
	assert_bool(bool(ready.get("interaction_monitoring", false))).is_true()
	assert_bool(bool(ready.get("interaction_monitorable", false))).is_true()
	assert_bool(bool(ready.get("collision_blocking", false))).is_true()
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Open Service Sluice Exit"
	)
	assert_float(float(ready.get("right_wall_x", 0.0))).is_greater_equal(11900.0)
	assert_int(int(ready.get("camera_limit_right", 0))).is_greater_equal(11920)
	assert_float(float(ready.get("background_width", 0.0))).is_greater_equal(11920.0)
	assert_float(float(ready.get("ground_right_edge_x", 0.0))).is_greater_equal(
		11920.0
	)

	var hatch_position: Vector2 = ready.get("position", Vector2.ZERO) as Vector2
	player.global_position = hatch_position
	assert_bool(bool(destination.call(
		"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch",
		player
	))).is_true()

	var opened: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics"
	)
	assert_bool(bool(opened.get("opened", false))).is_true()
	assert_bool(bool(opened.get("available", true))).is_false()
	assert_bool(bool(opened.get("visible", false))).is_true()
	assert_bool(bool(opened.get("collision_blocking", true))).is_false()
	assert_str(String(opened.get("prompt_text", ""))).is_equal("Service Exit Open")
	assert_str(String(opened.get("route_label_text", ""))).is_equal(
		"Service Sluice Exit Opened"
	)
	assert_bool(bool(opened.get("unlock_feedback_played", false))).is_true()
	assert_int(int(opened.get("unlock_feedback_spawn_count", 0))).is_equal(1)
	assert_bool(bool(destination.call(
		"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch",
		player
	))).is_false()

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_opened",
		false
	))).is_true()


func test_service_sluice_exit_hatch_restore_backfills_service_sluice_chain(
) -> void:
	var restored: Node = _factory_scene_with_service_exit_hatch_state(false, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return

	assert_bool(restored.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics"
	)).is_true()
	if not restored.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics"
	):
		return

	var restored_hatch: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_diagnostics"
	)
	assert_bool(bool(restored_hatch.get("present", false))).is_true()
	assert_bool(bool(restored_hatch.get("service_sluice_cache_claimed", false))).is_true()
	assert_bool(bool(restored_hatch.get("opened", false))).is_true()
	assert_bool(bool(restored_hatch.get("available", true))).is_false()
	assert_bool(bool(restored_hatch.get("visible", false))).is_true()
	assert_bool(bool(restored_hatch.get("collision_blocking", true))).is_false()
	assert_str(String(restored_hatch.get("prompt_text", ""))).is_equal(
		"Service Exit Open"
	)
	assert_str(String(restored_hatch.get("route_label_text", ""))).is_equal(
		"Service Sluice Exit Opened"
	)
	assert_int(int(restored_hatch.get("unlock_feedback_spawn_count", -1))).is_equal(0)
	assert_bool(bool(restored.call(
		"try_open_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch"
	))).is_false()

	var cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_diagnostics"
	)
	assert_bool(bool(cache.get("claimed", false))).is_true()
	var skirmish: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_diagnostics"
	)
	assert_bool(bool(skirmish.get("cleared", false))).is_true()
	var sluice: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_diagnostics"
	)
	assert_bool(bool(sluice.get("crossed", false))).is_true()
	assert_bool(bool(sluice.get("hazard_contact_active", true))).is_false()
	var service_hatch: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_diagnostics"
	)
	assert_bool(bool(service_hatch.get("opened", false))).is_true()
	assert_bool(bool(service_hatch.get("collision_blocking", true))).is_false()

	var local_state: Dictionary = restored.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_claimed",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_opened",
		false
	))).is_true()


func _factory_scene_with_service_exit_hatch_state(
	service_sluice_cache_claimed: bool,
	exit_hatch_opened: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_reward_cache_claimed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_exit_gate_opened": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_activated": service_sluice_cache_claimed,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_crossed": service_sluice_cache_claimed,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_activated": service_sluice_cache_claimed,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_spark_rat_defeated": service_sluice_cache_claimed,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_skirmish_cleared": service_sluice_cache_claimed,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_reward_cache_claimed": service_sluice_cache_claimed,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_hatch_opened": service_sluice_cache_claimed,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_activated": service_sluice_cache_claimed,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed": service_sluice_cache_claimed,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_activated": service_sluice_cache_claimed,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_spark_rat_defeated": service_sluice_cache_claimed,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared": service_sluice_cache_claimed,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_claimed": service_sluice_cache_claimed,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_opened": exit_hatch_opened,
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
		elif child is AudioStreamPlayer2D:
			(child as AudioStreamPlayer2D).stop()
