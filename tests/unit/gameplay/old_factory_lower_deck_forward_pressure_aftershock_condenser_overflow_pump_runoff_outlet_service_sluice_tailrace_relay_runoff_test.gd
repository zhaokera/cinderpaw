## Player Abilities Story 120: Old Factory tailrace relay runoff traversal.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const TAILRACE_RELAY_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
)
const TAILRACE_RELAY_SPAWN_POINT: String = (
	"lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
)
const TAILRACE_RELAY_RUNOFF_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff"
)
const TAILRACE_RELAY_RUNOFF_ACTIVATION_X: float = 13760.0
const TAILRACE_RELAY_RUNOFF_EXIT_X: float = 14320.0
const SERVICE_SLUICE_LANDING_TEXTURE: String = (
	"res://assets/environment/old_factory_runoff_service_hatch_landing/"
	+ "env_old_factory_runoff_service_hatch_landing_768.png"
)
const STEAM_VENT_TEXTURE: String = (
	"res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png"
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


func test_tailrace_relay_runoff_requires_relay_and_uses_active_only_contact(
) -> void:
	assert_bool(FileAccess.file_exists(SERVICE_SLUICE_LANDING_TEXTURE)).is_true()
	assert_bool(FileAccess.file_exists(STEAM_VENT_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_tailrace_relay_runoff_state(
		false,
		false
	)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff"
		)
		or not locked_scene.has_method(
			"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("tailrace_relay_activated", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("hazard_contact_active", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff"
	))).is_false()

	var ready_scene: Node = _factory_scene_with_tailrace_relay_runoff_state(
		true,
		false
	)
	assert_that(ready_scene).is_not_null()
	if ready_scene == null:
		return
	var player: Node2D = ready_scene.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("tailrace_relay_activated", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("crossed", true))).is_false()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("hazard_visible", false))).is_true()
	assert_bool(bool(ready.get("hazard_contact_active", true))).is_false()
	assert_str(String(ready.get("phase", ""))).is_equal("idle")
	assert_str(String(ready.get("hazard_id", ""))).is_equal(
		TAILRACE_RELAY_RUNOFF_HAZARD_ID
	)
	assert_int(int(ready.get("hazard_damage", 0))).is_equal(8)
	assert_float(float(ready.get("hazard_cooldown_sec", 0.0))).is_equal(1.0)
	assert_str(String(ready.get("duct_texture_path", ""))).is_equal(
		SERVICE_SLUICE_LANDING_TEXTURE
	)
	assert_str(String(ready.get("hazard_texture_path", ""))).is_equal(
		STEAM_VENT_TEXTURE
	)
	assert_float(float(ready.get("activation_x", 0.0))).is_equal(
		TAILRACE_RELAY_RUNOFF_ACTIVATION_X
	)
	assert_float(float(ready.get("exit_x", 0.0))).is_equal(
		TAILRACE_RELAY_RUNOFF_EXIT_X
	)
	assert_float(float(ready.get("right_wall_x", 0.0))).is_greater_equal(14500.0)
	assert_int(int(ready.get("camera_limit_right", 0))).is_greater_equal(14520)
	assert_float(float(ready.get("background_width", 0.0))).is_greater_equal(14520.0)
	assert_float(float(ready.get("ground_right_edge_x", 0.0))).is_greater_equal(14600.0)
	assert_int(int(ready.get("floor_tile_count", 0))).is_greater_equal(61)
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Tailrace Relay Secured"
	)

	player.global_position.x = TAILRACE_RELAY_RUNOFF_ACTIVATION_X - 4.0
	assert_bool(bool(ready_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff",
		player
	))).is_false()
	player.global_position.x = TAILRACE_RELAY_RUNOFF_ACTIVATION_X + 4.0
	assert_bool(bool(ready_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff",
		player
	))).is_true()

	var active: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_str(String(active.get("phase", ""))).is_equal("grace")
	assert_bool(bool(active.get("hazard_contact_active", true))).is_false()
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Cross Tailrace Relay Runoff"
	)

	ready_scene.call(
		"advance_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_time",
		float(active.get("initial_grace_sec", 0.0))
			+ float(active.get("warning_sec", 0.0))
			+ 0.05
	)
	var contact: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_diagnostics"
	)
	assert_str(String(contact.get("phase", ""))).is_equal("active")
	assert_bool(bool(contact.get("hazard_contact_active", false))).is_true()
	assert_int(int(contact.get("collision_layer", 0))).is_not_equal(0)
	assert_int(int(contact.get("collision_mask", 0))).is_not_equal(0)

	player.global_position.x = TAILRACE_RELAY_RUNOFF_EXIT_X - 4.0
	assert_bool(bool(ready_scene.call(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff",
		player
	))).is_false()
	player.global_position.x = TAILRACE_RELAY_RUNOFF_EXIT_X + 4.0
	assert_bool(bool(ready_scene.call(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff",
		player
	))).is_true()

	var crossed: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_diagnostics"
	)
	assert_bool(bool(crossed.get("active", true))).is_false()
	assert_bool(bool(crossed.get("crossed", false))).is_true()
	assert_str(String(crossed.get("phase", ""))).is_equal("crossed")
	assert_bool(bool(crossed.get("hazard_contact_active", true))).is_false()
	assert_str(String(crossed.get("route_label_text", ""))).is_equal(
		"Tailrace Relay Runoff Crossed"
	)
	var last_savepoint: Dictionary = Dictionary(crossed.get("last_savepoint", {}))
	assert_str(String(last_savepoint.get("id", ""))).is_equal(TAILRACE_RELAY_ID)
	assert_str(String(last_savepoint.get("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(last_savepoint.get("spawn_point", ""))).is_equal(
		TAILRACE_RELAY_SPAWN_POINT
	)

	var local_state: Dictionary = ready_scene.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_crossed",
		false
	))).is_true()


func test_tailrace_relay_runoff_restore_backfills_relay_chain_without_replay(
) -> void:
	var restored: Node = _factory_scene_with_tailrace_relay_runoff_state(false, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return

	var runoff: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_diagnostics"
	)
	assert_bool(bool(runoff.get("present", false))).is_true()
	assert_bool(bool(runoff.get("tailrace_relay_activated", false))).is_true()
	assert_bool(bool(runoff.get("active", true))).is_false()
	assert_bool(bool(runoff.get("crossed", false))).is_true()
	assert_bool(bool(runoff.get("visible", false))).is_true()
	assert_bool(bool(runoff.get("hazard_contact_active", true))).is_false()
	assert_str(String(runoff.get("phase", ""))).is_equal("crossed")
	assert_str(String(runoff.get("route_label_text", ""))).is_equal(
		"Tailrace Relay Runoff Crossed"
	)

	var relay: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_diagnostics"
	)
	assert_bool(bool(relay.get("activated", false))).is_true()
	assert_bool(bool(relay.get("tailrace_ambush_cleared", false))).is_true()
	assert_int(int(relay.get("activation_vfx_spawn_count", -1))).is_equal(0)
	var ambush: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
	)
	assert_bool(bool(ambush.get("cleared", false))).is_true()
	assert_bool(bool(ambush.get("coil_visible", true))).is_false()
	var tailrace: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_diagnostics"
	)
	assert_bool(bool(tailrace.get("crossed", false))).is_true()
	assert_bool(bool(tailrace.get("hazard_contact_active", true))).is_false()
	var local_state: Dictionary = restored.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_crossed",
		false
	))).is_true()


func _factory_scene_with_tailrace_relay_runoff_state(
	tailrace_relay_activated: bool,
	runoff_crossed: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	var state: Dictionary = _service_sluice_tailrace_base_state().merged({
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_activated": (
			tailrace_relay_activated or runoff_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_coil_rat_defeated": (
			tailrace_relay_activated or runoff_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared": (
			tailrace_relay_activated or runoff_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated": (
			tailrace_relay_activated
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_activated": (
			runoff_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_crossed": (
			runoff_crossed
		),
	}, true)
	if tailrace_relay_activated or runoff_crossed:
		state["last_return_checkpoint"] = _tailrace_relay_checkpoint_snapshot()
	destination.call("set_local_state", state)
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


func _tailrace_relay_checkpoint_snapshot() -> Dictionary:
	return {
		"id": TAILRACE_RELAY_ID,
		"scene_id": String(FACTORY_SCENE_ID),
		"spawn_point": TAILRACE_RELAY_SPAWN_POINT,
		"position": Vector2(13480, 382),
	}


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
