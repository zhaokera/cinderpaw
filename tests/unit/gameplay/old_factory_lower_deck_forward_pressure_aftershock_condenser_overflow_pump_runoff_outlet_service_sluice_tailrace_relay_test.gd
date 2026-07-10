## Player Abilities Story 119: Old Factory service sluice tailrace relay savepoint.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_GATE_ENTRY_SPAWN_POINT: StringName = &"factory_gate_entry"
const TAILRACE_RELAY_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelaySavepoint"
)
const TAILRACE_RELAY_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
)
const TAILRACE_RELAY_SPAWN_POINT: String = (
	"lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
)
const TAILRACE_RELAY_TEXTURE: String = (
	"res://assets/environment/old_factory_lower_deck_breach_relay/"
	+ "env_old_factory_lower_deck_breach_relay_256.png"
)
const TAILRACE_RELAY_VFX_TEXTURE: String = (
	"res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png"
)

var _spawned_nodes: Array[Node] = []


class FakeFactoryRequestSceneManager:
	extends RefCounted

	var current_scene: StringName = FACTORY_SCENE_ID
	var current_spawn_point: StringName = FACTORY_GATE_ENTRY_SPAWN_POINT
	var request_calls: Array[Dictionary] = []

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == FACTORY_SCENE_ID or scene_id == &"main"

	func request_scene_change(
		scene_id: StringName,
		spawn_point: StringName = &"default"
	) -> bool:
		request_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		var known: bool = has_scene(scene_id)
		if known:
			current_scene = scene_id
			current_spawn_point = spawn_point
		return known

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn_point


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_tailrace_relay_requires_ambush_clear_and_records_respawn_anchor() -> void:
	assert_bool(FileAccess.file_exists(TAILRACE_RELAY_TEXTURE)).is_true()
	assert_bool(FileAccess.file_exists(TAILRACE_RELAY_VFX_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_tailrace_relay_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("tailrace_ambush_cleared", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("activated", true))).is_false()
	assert_bool(bool(locked.get("interaction_monitoring", true))).is_false()
	assert_bool(bool(locked.get("interaction_monitorable", true))).is_false()
	assert_bool(bool(locked.get("collision_disabled", false))).is_true()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
	))).is_false()

	var ready_scene: Node = _factory_scene_with_tailrace_relay_state(true, false)
	assert_that(ready_scene).is_not_null()
	if ready_scene == null:
		return
	var player: Node2D = ready_scene.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var relay: Node2D = ready_scene.get_node_or_null(TAILRACE_RELAY_NODE_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(relay).is_not_null()
	if player == null or relay == null:
		return

	var ready: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("tailrace_ambush_cleared", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("activated", true))).is_false()
	assert_str(String(ready.get("prompt_text", ""))).is_equal("Repair Tailrace Relay")
	assert_str(String(ready.get("texture_path", ""))).is_equal(TAILRACE_RELAY_TEXTURE)
	assert_str(String(ready.get("activation_vfx_texture_path", ""))).is_equal(
		TAILRACE_RELAY_VFX_TEXTURE
	)
	assert_str(String(ready.get("savepoint_id", ""))).is_equal(TAILRACE_RELAY_ID)
	assert_str(String(ready.get("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(ready.get("spawn_point", ""))).is_equal(TAILRACE_RELAY_SPAWN_POINT)
	assert_float(float(ready.get("right_wall_x", 0.0))).is_greater_equal(13720.0)
	assert_int(int(ready.get("camera_limit_right", 0))).is_greater_equal(13740)
	assert_float(float(ready.get("background_width", 0.0))).is_greater_equal(13740.0)
	assert_float(float(ready.get("ground_right_edge_x", 0.0))).is_greater_equal(13840.0)
	assert_int(int(ready.get("floor_tile_count", 0))).is_greater_equal(58)
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Repair Tailrace Relay"
	)

	player.global_position = relay.global_position + Vector2(180.0, 0.0)
	assert_bool(bool(ready_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay",
		player
	))).is_false()
	player.global_position = relay.global_position
	assert_bool(bool(ready_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay",
		player
	))).is_true()
	assert_bool(bool(ready_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay",
		player
	))).is_false()

	var activated: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_diagnostics"
	)
	assert_bool(bool(activated.get("activated", false))).is_true()
	assert_str(String(activated.get("route_label_text", ""))).is_equal(
		"Tailrace Relay Secured"
	)
	assert_int(int(activated.get("activation_vfx_spawn_count", 0))).is_equal(1)
	var last_savepoint: Dictionary = Dictionary(activated.get("last_savepoint", {}))
	assert_str(String(last_savepoint.get("id", ""))).is_equal(TAILRACE_RELAY_ID)
	assert_str(String(last_savepoint.get("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(last_savepoint.get("spawn_point", ""))).is_equal(
		TAILRACE_RELAY_SPAWN_POINT
	)

	var local_state: Dictionary = ready_scene.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated",
		false
	))).is_true()


func test_tailrace_relay_restore_backfills_ambush_and_respawns_to_relay() -> void:
	var restored: Node = _factory_scene_with_tailrace_relay_state(false, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return

	var restored_relay: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_diagnostics"
	)
	assert_bool(bool(restored_relay.get("activated", false))).is_true()
	assert_bool(bool(restored_relay.get("available", true))).is_false()
	assert_bool(bool(restored_relay.get("visible", false))).is_true()
	assert_str(String(restored_relay.get("savepoint_id", ""))).is_equal(
		TAILRACE_RELAY_ID
	)
	assert_str(String(restored_relay.get("route_label_text", ""))).is_equal(
		"Tailrace Relay Secured"
	)
	assert_int(int(restored_relay.get("activation_vfx_spawn_count", -1))).is_equal(0)

	var restored_ambush: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
	)
	assert_bool(bool(restored_ambush.get("cleared", false))).is_true()
	assert_bool(bool(restored_ambush.get("coil_visible", true))).is_false()
	assert_bool(bool(restored_ambush.get("tailrace_crossed", false))).is_true()
	var restored_tailrace: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	)
	assert_bool(bool(restored_tailrace.get("crossed", false))).is_true()
	assert_bool(bool(restored_tailrace.get("service_sluice_exit_hatch_opened", false))).is_true()

	var player: Node2D = restored.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var relay_node: Node2D = restored.get_node_or_null(TAILRACE_RELAY_NODE_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(relay_node).is_not_null()
	if player == null or relay_node == null:
		return

	var scene_manager := FakeFactoryRequestSceneManager.new()
	scene_manager.current_spawn_point = StringName(TAILRACE_RELAY_SPAWN_POINT)
	player.global_position = relay_node.global_position + Vector2(-400.0, 0.0)
	assert_bool(bool(restored.call("configure_scene_manager_runtime", scene_manager))).is_true()
	assert_float(player.global_position.distance_to(relay_node.global_position)).is_less_equal(1.0)
	assert_str(String(
		restored.call("get_factory_route_objective_diagnostics").get(
			"route_label_text",
			""
		)
	)).is_equal("Returned to Tailrace Relay")

	var max_hp: int = int(player.call("get_max_hp"))
	player.global_position = relay_node.global_position + Vector2(260.0, 0.0)
	player.call("apply_damage", max_hp, {
		"source": "unit_test_service_sluice_tailrace_relay",
		"damage_type": "lethal_probe",
	})
	restored.call("advance_factory_respawn_flow", 1.51)

	assert_int(scene_manager.request_calls.size()).is_equal(1)
	assert_str(String(scene_manager.request_calls[0]["scene_id"])).is_equal(
		String(FACTORY_SCENE_ID)
	)
	assert_str(String(scene_manager.request_calls[0]["spawn_point"])).is_equal(
		TAILRACE_RELAY_SPAWN_POINT
	)
	assert_float(player.global_position.distance_to(relay_node.global_position)).is_less_equal(1.0)
	assert_int(int(player.call("get_current_hp"))).is_equal(maxi(1, int(round(max_hp * 0.5))))
	assert_bool(bool(player.call("is_respawn_visual_active"))).is_true()
	assert_str(String(
		restored.call("get_factory_route_objective_diagnostics").get(
			"route_label_text",
			""
		)
	)).is_equal("Returned to Tailrace Relay")


func _factory_scene_with_tailrace_relay_state(
	tailrace_ambush_cleared: bool,
	tailrace_relay_activated: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _service_sluice_tailrace_base_state().merged({
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_activated": (
			tailrace_ambush_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_coil_rat_defeated": (
			tailrace_ambush_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared": (
			tailrace_ambush_cleared
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated": (
			tailrace_relay_activated
		),
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


func _service_sluice_tailrace_base_state() -> Dictionary:
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
	}


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
