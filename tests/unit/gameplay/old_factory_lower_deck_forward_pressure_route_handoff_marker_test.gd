## Player Abilities Story 076: Old Factory lower deck forward-pressure route handoff marker.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const BREACH_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_breach_relay"
const BREACH_RELAY_SPAWN_POINT: String = "lower_deck_breach_relay"
const EXIT_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_forward_pressure_exit_relay"
const EXIT_RELAY_SPAWN_POINT: String = "lower_deck_forward_pressure_exit_relay"
const ROUTE_HANDOFF_NODE_NAME: String = (
	"FactoryLowerDeckForwardPressureRouteHandoffMarker"
)
const ROUTE_HANDOFF_ID: String = (
	"old_factory_lower_deck_forward_pressure_route_handoff_marker"
)
const ROUTE_HANDOFF_TEXTURE: String = (
	"res://assets/environment/old_factory_deep_route/factory_deep_route_endpoint.png"
)

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_route_handoff_marker_requires_exit_gate_open_and_becomes_visible() -> void:
	assert_bool(FileAccess.file_exists(ROUTE_HANDOFF_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_route_handoff_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_route_handoff_marker_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_route_handoff_marker"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_route_handoff_marker_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_route_handoff_marker"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_route_handoff_marker_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("exit_gate_opened", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("lit", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_route_handoff_marker"
	))).is_false()

	var destination: Node = _factory_scene_with_route_handoff_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var marker: Node2D = destination.get_node_or_null(ROUTE_HANDOFF_NODE_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(marker).is_not_null()
	if player == null or marker == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_route_handoff_marker_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("exit_gate_opened", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("lit", true))).is_false()
	assert_str(String(ready.get("marker_id", ""))).is_equal(ROUTE_HANDOFF_ID)
	assert_str(String(ready.get("prompt_text", ""))).is_equal("Light Route Beacon")
	assert_str(String(ready.get("texture_path", ""))).is_equal(ROUTE_HANDOFF_TEXTURE)
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Forward Pressure Exit Gate Opened"
	)

	var lift_ready: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift_ready.get("available", false))).is_true()
	assert_str(String(lift_ready.get("prompt_text", ""))).is_equal("Call lift")

	player.global_position = marker.global_position
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_route_handoff_marker",
		player
	))).is_true()
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_route_handoff_marker",
		player
	))).is_false()

	var lit: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_route_handoff_marker_diagnostics"
	)
	assert_bool(bool(lit.get("lit", false))).is_true()
	assert_bool(bool(lit.get("available", true))).is_false()
	assert_bool(bool(lit.get("visible", false))).is_true()
	assert_str(String(lit.get("prompt_text", ""))).is_equal("Route Beacon Lit")
	assert_str(String(lit.get("route_label_text", ""))).is_equal(
		"Forward Pressure Route Beacon Lit"
	)

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_route_handoff_marker_lit",
		false
	))).is_true()


func test_route_handoff_marker_persists_without_replaying_completed_chain() -> void:
	var restored: Node = _factory_scene_with_route_handoff_state(true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return

	assert_bool(restored.has_method(
		"get_factory_lower_deck_forward_pressure_route_handoff_marker_diagnostics"
	)).is_true()
	if not restored.has_method(
		"get_factory_lower_deck_forward_pressure_route_handoff_marker_diagnostics"
	):
		return

	var marker: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_route_handoff_marker_diagnostics"
	)
	assert_bool(bool(marker.get("present", false))).is_true()
	assert_bool(bool(marker.get("exit_gate_opened", false))).is_true()
	assert_bool(bool(marker.get("lit", false))).is_true()
	assert_bool(bool(marker.get("available", true))).is_false()
	assert_bool(bool(marker.get("visible", false))).is_true()
	assert_str(String(marker.get("prompt_text", ""))).is_equal("Route Beacon Lit")
	assert_str(String(marker.get("route_label_text", ""))).is_equal(
		"Forward Pressure Route Beacon Lit"
	)

	var exit_gate: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_exit_gate_diagnostics"
	)
	assert_bool(bool(exit_gate.get("opened", false))).is_true()
	assert_bool(bool(exit_gate.get("collision_blocking", true))).is_false()

	var relay: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
	)
	assert_bool(bool(relay.get("activated", false))).is_true()
	assert_str(String(relay.get("savepoint_id", ""))).is_equal(EXIT_RELAY_SAVEPOINT_ID)
	assert_str(String(relay.get("spawn_point", ""))).is_equal(EXIT_RELAY_SPAWN_POINT)

	var guard: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
	)
	assert_bool(bool(guard.get("active", true))).is_false()
	assert_bool(bool(guard.get("defeated", false))).is_true()
	var cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_reward_cache_diagnostics"
	)
	assert_bool(bool(cache.get("claimed", false))).is_true()
	assert_int(int(cache.get("claim_audio_request_count", -1))).is_equal(0)
	var clear_feedback: Dictionary = restored.call(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	)
	assert_int(int(clear_feedback.get("spawn_count", -1))).is_equal(0)
	var lift: Dictionary = restored.call("get_factory_service_lift_diagnostics")
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


func _factory_scene_with_route_handoff_state(
		exit_gate_opened: bool,
		route_handoff_marker_lit: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _forward_pressure_exit_base_state().merged({
		"factory_lower_deck_forward_pressure_exit_guard_activated": true,
		"factory_lower_deck_forward_pressure_exit_guard_defeated": true,
		"factory_lower_deck_forward_pressure_exit_relay_activated": true,
		"factory_lower_deck_forward_pressure_exit_gate_opened": exit_gate_opened,
		"factory_lower_deck_forward_pressure_route_handoff_marker_lit": (
			route_handoff_marker_lit
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


func _forward_pressure_exit_base_state() -> Dictionary:
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
		"factory_lower_deck_relay_forward_reward_cache_claimed": true,
		"factory_lower_deck_forward_hatch_opened": true,
		"factory_lower_deck_forward_conduit_activated": true,
		"factory_lower_deck_forward_conduit_defeated": true,
		"factory_lower_deck_forward_pressure_traverse_crossed": true,
		"factory_lower_deck_forward_pressure_counter_ambush_activated": true,
		"factory_lower_deck_forward_pressure_counter_ambush_defeated": true,
		"factory_lower_deck_forward_pressure_reward_cache_claimed": true,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
		"last_return_checkpoint": {
			"id": BREACH_RELAY_SAVEPOINT_ID,
			"scene_id": String(FACTORY_SCENE_ID),
			"spawn_point": BREACH_RELAY_SPAWN_POINT,
			"position": Vector2(1218, 382),
		},
	}
