## Player Abilities Story 124: Old Factory tailrace runoff pincer exit spillway.
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
const PINCER_EXIT_SPILLWAY_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway"
)
const PINCER_EXIT_SPILLWAY_ACTIVATION_X: float = 16560.0
const PINCER_EXIT_SPILLWAY_EXIT_X: float = 17040.0
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


func test_pincer_exit_spillway_requires_hatch_and_uses_active_only_contact() -> void:
	assert_bool(FileAccess.file_exists(SERVICE_SLUICE_LANDING_TEXTURE)).is_true()
	assert_bool(FileAccess.file_exists(STEAM_VENT_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_pincer_exit_spillway_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway"
		)
		or not locked_scene.has_method(
			"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("pincer_exit_hatch_opened", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("hazard_contact_active", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway"
	))).is_false()

	var ready_scene: Node = _factory_scene_with_pincer_exit_spillway_state(true, false)
	assert_that(ready_scene).is_not_null()
	if ready_scene == null:
		return
	var player: Node2D = ready_scene.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("pincer_exit_hatch_opened", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("crossed", true))).is_false()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("hazard_visible", false))).is_true()
	assert_bool(bool(ready.get("hazard_contact_active", true))).is_false()
	assert_str(String(ready.get("phase", ""))).is_equal("idle")
	assert_str(String(ready.get("hazard_id", ""))).is_equal(PINCER_EXIT_SPILLWAY_HAZARD_ID)
	assert_int(int(ready.get("hazard_damage", 0))).is_equal(8)
	assert_float(float(ready.get("hazard_cooldown_sec", 0.0))).is_equal(1.0)
	assert_str(String(ready.get("duct_texture_path", ""))).is_equal(
		SERVICE_SLUICE_LANDING_TEXTURE
	)
	assert_str(String(ready.get("hazard_texture_path", ""))).is_equal(
		STEAM_VENT_TEXTURE
	)
	assert_float(float(ready.get("activation_x", 0.0))).is_equal(
		PINCER_EXIT_SPILLWAY_ACTIVATION_X
	)
	assert_float(float(ready.get("exit_x", 0.0))).is_equal(PINCER_EXIT_SPILLWAY_EXIT_X)
	assert_float(float(ready.get("right_wall_x", 0.0))).is_greater_equal(17280.0)
	assert_int(int(ready.get("camera_limit_right", 0))).is_greater_equal(17300)
	assert_float(float(ready.get("background_width", 0.0))).is_greater_equal(17300.0)
	assert_float(float(ready.get("ground_right_edge_x", 0.0))).is_greater_equal(17400.0)
	assert_int(int(ready.get("floor_tile_count", 0))).is_greater_equal(69)
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Tailrace Runoff Exit Opened"
	)

	player.global_position.x = PINCER_EXIT_SPILLWAY_ACTIVATION_X - 4.0
	assert_bool(bool(ready_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway",
		player
	))).is_false()
	player.global_position.x = PINCER_EXIT_SPILLWAY_ACTIVATION_X + 4.0
	assert_bool(bool(ready_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway",
		player
	))).is_true()

	var active: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_str(String(active.get("phase", ""))).is_equal("grace")
	assert_bool(bool(active.get("hazard_contact_active", true))).is_false()
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Cross Tailrace Exit Spillway"
	)

	ready_scene.call(
		"advance_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_time",
		float(active.get("initial_grace_sec", 0.0))
			+ float(active.get("warning_sec", 0.0))
			+ 0.05
	)
	var contact: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
	)
	assert_str(String(contact.get("phase", ""))).is_equal("active")
	assert_bool(bool(contact.get("hazard_contact_active", false))).is_true()
	assert_int(int(contact.get("collision_layer", 0))).is_not_equal(0)
	assert_int(int(contact.get("collision_mask", 0))).is_not_equal(0)

	player.global_position.x = PINCER_EXIT_SPILLWAY_EXIT_X - 4.0
	assert_bool(bool(ready_scene.call(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway",
		player
	))).is_false()
	player.global_position.x = PINCER_EXIT_SPILLWAY_EXIT_X + 4.0
	assert_bool(bool(ready_scene.call(
		"try_complete_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway",
		player
	))).is_true()

	var crossed: Dictionary = ready_scene.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
	)
	assert_bool(bool(crossed.get("active", true))).is_false()
	assert_bool(bool(crossed.get("crossed", false))).is_true()
	assert_str(String(crossed.get("phase", ""))).is_equal("crossed")
	assert_bool(bool(crossed.get("hazard_contact_active", true))).is_false()
	assert_str(String(crossed.get("route_label_text", ""))).is_equal(
		"Tailrace Exit Spillway Crossed"
	)
	var last_savepoint: Dictionary = Dictionary(crossed.get("last_savepoint", {}))
	assert_str(String(last_savepoint.get("id", ""))).is_equal(TAILRACE_RELAY_ID)
	assert_str(String(last_savepoint.get("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(last_savepoint.get("spawn_point", ""))).is_equal(
		TAILRACE_RELAY_SPAWN_POINT
	)

	var local_state: Dictionary = ready_scene.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_crossed",
		false
	))).is_true()


func test_pincer_exit_spillway_restore_backfills_hatch_without_replay() -> void:
	var restored: Node = _factory_scene_with_pincer_exit_spillway_state(false, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return

	var spillway: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_diagnostics"
	)
	assert_bool(bool(spillway.get("present", false))).is_true()
	assert_bool(bool(spillway.get("pincer_exit_hatch_opened", false))).is_true()
	assert_bool(bool(spillway.get("active", true))).is_false()
	assert_bool(bool(spillway.get("crossed", false))).is_true()
	assert_bool(bool(spillway.get("visible", false))).is_true()
	assert_bool(bool(spillway.get("hazard_contact_active", true))).is_false()
	assert_str(String(spillway.get("phase", ""))).is_equal("crossed")
	assert_str(String(spillway.get("route_label_text", ""))).is_equal(
		"Tailrace Exit Spillway Crossed"
	)

	var hatch: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_diagnostics"
	)
	assert_bool(bool(hatch.get("opened", false))).is_true()
	assert_bool(bool(hatch.get("pincer_reward_cache_claimed", false))).is_true()
	assert_int(int(hatch.get("unlock_feedback_spawn_count", -1))).is_equal(0)
	var pincer: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_diagnostics"
	)
	assert_bool(bool(pincer.get("cleared", false))).is_true()
	assert_bool(bool(pincer.get("spark_visible", true))).is_false()
	assert_bool(bool(pincer.get("coil_visible", true))).is_false()
	var relay: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_diagnostics"
	)
	assert_bool(bool(relay.get("activated", false))).is_true()
	assert_int(int(relay.get("activation_vfx_spawn_count", -1))).is_equal(0)
	var local_state: Dictionary = restored.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_crossed",
		false
	))).is_true()


func _factory_scene_with_pincer_exit_spillway_state(
	pincer_exit_hatch_opened: bool,
	spillway_crossed: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	var chain_complete: bool = pincer_exit_hatch_opened or spillway_crossed
	var state: Dictionary = _service_sluice_tailrace_base_state().merged({
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
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_claimed": (
			chain_complete
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened": (
			chain_complete
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_activated": (
			spillway_crossed
		),
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_crossed": (
			spillway_crossed
		),
	}, true)
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
