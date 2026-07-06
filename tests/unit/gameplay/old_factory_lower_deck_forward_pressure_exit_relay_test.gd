## Player Abilities Story 074: Old Factory lower deck forward-pressure exit relay.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_GATE_ENTRY_SPAWN_POINT: StringName = &"factory_gate_entry"
const BREACH_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_breach_relay"
const BREACH_RELAY_SPAWN_POINT: String = "lower_deck_breach_relay"
const EXIT_RELAY_NODE_NAME: String = "FactoryLowerDeckForwardPressureExitRelaySavepoint"
const EXIT_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_forward_pressure_exit_relay"
const EXIT_RELAY_SPAWN_POINT: String = "lower_deck_forward_pressure_exit_relay"
const EXIT_RELAY_TEXTURE: String = (
	"res://assets/environment/old_factory_lower_deck_breach_relay/"
	+ "env_old_factory_lower_deck_breach_relay_256.png"
)

var _spawned_nodes: Array[Node] = []


class FakeFactoryRequestSceneManager:
	extends RefCounted

	var current_scene: StringName = FACTORY_SCENE_ID
	var current_spawn_point: StringName = FACTORY_GATE_ENTRY_SPAWN_POINT
	var request_calls: Array[Dictionary] = []

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == FACTORY_SCENE_ID or scene_id == &"main"

	func request_scene_change(scene_id: StringName, spawn_point: StringName = &"default") -> bool:
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


func test_forward_pressure_exit_relay_requires_exit_guard_defeat_and_preserves_lift() -> void:
	assert_bool(FileAccess.file_exists(EXIT_RELAY_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_exit_relay_state(false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_exit_relay"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_exit_relay"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("exit_guard_defeated", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("interaction_monitoring", true))).is_false()
	assert_bool(bool(locked.get("interaction_monitorable", true))).is_false()
	assert_bool(bool(locked.get("collision_disabled", false))).is_true()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_exit_relay"
	))).is_false()

	var destination: Node = _factory_scene_with_exit_relay_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var relay: Node2D = destination.get_node_or_null(EXIT_RELAY_NODE_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(relay).is_not_null()
	if player == null or relay == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("exit_guard_defeated", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("activated", true))).is_false()
	assert_str(String(ready.get("prompt_text", ""))).is_equal("Repair Exit Relay")
	assert_str(String(ready.get("texture_path", ""))).is_equal(EXIT_RELAY_TEXTURE)
	assert_str(String(ready.get("savepoint_id", ""))).is_equal(EXIT_RELAY_SAVEPOINT_ID)
	assert_str(String(ready.get("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(ready.get("spawn_point", ""))).is_equal(EXIT_RELAY_SPAWN_POINT)

	player.global_position = relay.global_position
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_exit_relay",
		player
	))).is_true()
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_exit_relay",
		player
	))).is_false()

	var activated: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
	)
	assert_bool(bool(activated.get("activated", false))).is_true()
	assert_str(String(activated.get("route_label_text", ""))).is_equal(
		"Forward Pressure Exit Relay Secured"
	)
	var last_savepoint: Dictionary = Dictionary(activated.get("last_savepoint", {}))
	assert_str(String(last_savepoint.get("id", ""))).is_equal(EXIT_RELAY_SAVEPOINT_ID)
	assert_str(String(last_savepoint.get("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(last_savepoint.get("spawn_point", ""))).is_equal(EXIT_RELAY_SPAWN_POINT)

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_exit_relay_activated",
		false
	))).is_true()
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


func test_forward_pressure_exit_relay_persists_and_respawns_without_replaying_chain() -> void:
	var destination: Node = _factory_scene_with_exit_relay_state(true, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var relay: Node2D = destination.get_node_or_null(EXIT_RELAY_NODE_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(relay).is_not_null()
	if player == null or relay == null:
		return

	player.global_position = relay.global_position
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_exit_relay",
		player
	))).is_true()

	var scene_manager := FakeFactoryRequestSceneManager.new()
	scene_manager.current_scene = FACTORY_SCENE_ID
	scene_manager.current_spawn_point = FACTORY_GATE_ENTRY_SPAWN_POINT
	assert_bool(bool(destination.call("configure_scene_manager_runtime", scene_manager))).is_true()

	var max_hp: int = int(player.call("get_max_hp"))
	player.global_position = relay.global_position + Vector2(220.0, 0.0)
	player.call("apply_damage", max_hp, {
		"source": "unit_test_forward_pressure_exit_relay",
		"damage_type": "lethal_probe",
	})
	destination.call("advance_factory_respawn_flow", 1.51)

	assert_int(scene_manager.request_calls.size()).is_equal(1)
	assert_str(String(scene_manager.request_calls[0]["scene_id"])).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(scene_manager.request_calls[0]["spawn_point"])).is_equal(EXIT_RELAY_SPAWN_POINT)
	assert_float(player.global_position.distance_to(relay.global_position)).is_less_equal(1.0)
	assert_int(int(player.call("get_current_hp"))).is_equal(maxi(1, int(round(max_hp * 0.5))))
	assert_bool(bool(player.call("is_respawn_visual_active"))).is_true()
	assert_str(String(
		destination.call("get_factory_route_objective_diagnostics").get("route_label_text", "")
	)).is_equal("Returned to Forward Pressure Exit Relay")

	var restored: Node = _factory_scene_with_exit_relay_state(true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	var restored_relay: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
	)
	assert_bool(bool(restored_relay.get("activated", false))).is_true()
	assert_str(String(restored_relay.get("savepoint_id", ""))).is_equal(EXIT_RELAY_SAVEPOINT_ID)
	assert_str(String(restored_relay.get("route_label_text", ""))).is_equal(
		"Forward Pressure Exit Relay Secured"
	)

	var restored_guard: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
	)
	assert_bool(bool(restored_guard.get("active", true))).is_false()
	assert_bool(bool(restored_guard.get("defeated", false))).is_true()
	var restored_cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_reward_cache_diagnostics"
	)
	assert_bool(bool(restored_cache.get("claimed", false))).is_true()
	assert_int(int(restored_cache.get("claim_audio_request_count", -1))).is_equal(0)
	var restored_clear: Dictionary = restored.call(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	)
	assert_int(int(restored_clear.get("spawn_count", -1))).is_equal(0)

	var restored_player: Node2D = restored.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var restored_relay_node: Node2D = restored.get_node_or_null(EXIT_RELAY_NODE_NAME) as Node2D
	assert_that(restored_player).is_not_null()
	assert_that(restored_relay_node).is_not_null()
	if restored_player == null or restored_relay_node == null:
		return
	var restored_scene_manager := FakeFactoryRequestSceneManager.new()
	restored_scene_manager.current_scene = FACTORY_SCENE_ID
	restored_scene_manager.current_spawn_point = FACTORY_GATE_ENTRY_SPAWN_POINT
	assert_bool(bool(restored.call(
		"configure_scene_manager_runtime",
		restored_scene_manager
	))).is_true()
	var restored_max_hp: int = int(restored_player.call("get_max_hp"))
	restored_player.global_position = restored_relay_node.global_position + Vector2(220.0, 0.0)
	restored_player.call("apply_damage", restored_max_hp, {
		"source": "unit_test_restored_forward_pressure_exit_relay",
		"damage_type": "lethal_probe",
	})
	restored.call("advance_factory_respawn_flow", 1.51)
	assert_int(restored_scene_manager.request_calls.size()).is_equal(1)
	assert_str(String(restored_scene_manager.request_calls[0]["scene_id"])).is_equal(
		String(FACTORY_SCENE_ID)
	)
	assert_str(String(restored_scene_manager.request_calls[0]["spawn_point"])).is_equal(
		EXIT_RELAY_SPAWN_POINT
	)
	assert_float(restored_player.global_position.distance_to(
		restored_relay_node.global_position
	)).is_less_equal(1.0)


func _factory_scene_with_exit_relay_state(
		exit_guard_defeated: bool,
		exit_relay_activated: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _forward_pressure_exit_base_state().merged({
		"factory_lower_deck_forward_pressure_exit_guard_activated": exit_guard_defeated,
		"factory_lower_deck_forward_pressure_exit_guard_defeated": exit_guard_defeated,
		"factory_lower_deck_forward_pressure_exit_relay_activated": exit_relay_activated,
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
