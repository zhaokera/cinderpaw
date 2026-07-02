## Player Abilities Story 062: Old Factory lower deck breach relay savepoint.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_GATE_ENTRY_SPAWN_POINT: StringName = &"factory_gate_entry"
const BREACH_RELAY_NODE_NAME: String = "FactoryLowerDeckBreachRelaySavepoint"
const BREACH_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_breach_relay"
const BREACH_RELAY_SPAWN_POINT: String = "lower_deck_breach_relay"
const BREACH_RELAY_TEXTURE: String = (
	"res://assets/environment/old_factory_lower_deck_breach_relay/"
	+ "env_old_factory_lower_deck_breach_relay_256.png"
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


func test_breach_relay_requires_secured_corridor_and_keeps_lift_optional() -> void:
	var locked_scene: Node = _factory_scene_with_breach_secured(false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method("get_factory_lower_deck_breach_relay_diagnostics")).is_true()
	assert_bool(locked_scene.has_method("try_activate_factory_lower_deck_breach_relay")).is_true()
	if (
		not locked_scene.has_method("get_factory_lower_deck_breach_relay_diagnostics")
		or not locked_scene.has_method("try_activate_factory_lower_deck_breach_relay")
	):
		return

	var locked: Dictionary = locked_scene.call("get_factory_lower_deck_breach_relay_diagnostics")
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("activated", true))).is_false()
	assert_bool(bool(locked.get("interaction_monitoring", true))).is_false()
	assert_bool(bool(locked_scene.call("try_activate_factory_lower_deck_breach_relay"))).is_false()

	var destination: Node = _factory_scene_with_breach_secured(true)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var service_lift: Node2D = destination.get_node_or_null(FACTORY_SERVICE_LIFT_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(service_lift).is_not_null()
	if player == null or service_lift == null:
		return

	var available: Dictionary = destination.call("get_factory_lower_deck_breach_relay_diagnostics")
	assert_bool(bool(available.get("present", false))).is_true()
	assert_bool(bool(available.get("available", false))).is_true()
	assert_bool(bool(available.get("visible", false))).is_true()
	assert_bool(bool(available.get("activated", true))).is_false()
	assert_bool(bool(available.get("interaction_monitoring", false))).is_true()
	assert_str(String(available.get("savepoint_id", ""))).is_equal(BREACH_RELAY_SAVEPOINT_ID)
	assert_str(String(available.get("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(available.get("spawn_point", ""))).is_equal(BREACH_RELAY_SPAWN_POINT)
	assert_str(String(available.get("prompt_text", ""))).is_equal("Repair Relay")
	assert_str(String(available.get("texture_path", ""))).is_equal(BREACH_RELAY_TEXTURE)

	var breach: Dictionary = destination.call("get_factory_lower_deck_breach_corridor_diagnostics")
	assert_bool(bool(breach.get("secured", false))).is_true()
	assert_bool(bool(breach.get("active", true))).is_false()
	assert_bool(bool(breach.get("front_visible", true))).is_false()
	assert_bool(bool(breach.get("rear_visible", true))).is_false()
	assert_bool(bool(breach.get("hazard_active", true))).is_false()

	player.global_position = service_lift.global_position
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


func test_breach_relay_activates_once_and_becomes_non_boss_respawn_point() -> void:
	var destination: Node = _factory_scene_with_breach_secured(true)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	assert_bool(destination.has_method("try_activate_factory_lower_deck_breach_relay")).is_true()
	assert_bool(destination.has_method("get_factory_lower_deck_breach_relay_diagnostics")).is_true()
	if (
		not destination.has_method("try_activate_factory_lower_deck_breach_relay")
		or not destination.has_method("get_factory_lower_deck_breach_relay_diagnostics")
	):
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var relay: Node2D = destination.get_node_or_null(BREACH_RELAY_NODE_NAME) as Node2D
	assert_that(player).is_not_null()
	assert_that(relay).is_not_null()
	if player == null or relay == null:
		return

	player.global_position = relay.global_position
	assert_bool(bool(destination.call("try_activate_factory_lower_deck_breach_relay", player))).is_true()
	assert_bool(bool(destination.call("try_activate_factory_lower_deck_breach_relay", player))).is_false()

	var activated: Dictionary = destination.call("get_factory_lower_deck_breach_relay_diagnostics")
	var last_savepoint: Dictionary = destination.call("get_last_discovered_savepoint")
	assert_bool(bool(activated.get("activated", false))).is_true()
	assert_bool(bool(activated.get("available", false))).is_true()
	assert_bool(bool(activated.get("interaction_monitoring", false))).is_true()
	assert_str(String(activated.get("route_label_text", ""))).is_equal("Lower Deck Relay Secured")
	assert_str(String(last_savepoint.get("id", ""))).is_equal(BREACH_RELAY_SAVEPOINT_ID)
	assert_str(String(last_savepoint.get("scene_id", ""))).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(last_savepoint.get("spawn_point", ""))).is_equal(BREACH_RELAY_SPAWN_POINT)
	assert_vector(_position_from_snapshot(last_savepoint)).is_equal(relay.global_position)

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get("factory_lower_deck_breach_corridor_secured", false))).is_true()
	assert_bool(bool(local_state.get("factory_lower_deck_breach_relay_activated", false))).is_true()
	assert_str(String(Dictionary(local_state.get("last_return_checkpoint", {})).get(
		"id",
		""
	))).is_equal(BREACH_RELAY_SAVEPOINT_ID)

	var restored: Node = _instantiate_factory_scene()
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", local_state)

	var restored_relay: Dictionary = restored.call("get_factory_lower_deck_breach_relay_diagnostics")
	var restored_breach: Dictionary = restored.call("get_factory_lower_deck_breach_corridor_diagnostics")
	assert_bool(bool(restored_relay.get("activated", false))).is_true()
	assert_bool(bool(restored_relay.get("available", false))).is_true()
	assert_bool(bool(restored_breach.get("secured", false))).is_true()
	assert_bool(bool(restored_breach.get("active", true))).is_false()
	assert_bool(bool(restored_breach.get("front_visible", true))).is_false()
	assert_bool(bool(restored_breach.get("rear_visible", true))).is_false()

	var scene_manager := FakeFactoryRequestSceneManager.new()
	scene_manager.current_scene = FACTORY_SCENE_ID
	scene_manager.current_spawn_point = FACTORY_GATE_ENTRY_SPAWN_POINT
	assert_bool(bool(restored.call("configure_scene_manager_runtime", scene_manager))).is_true()

	var restored_player: Node2D = restored.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var restored_relay_node: Node2D = restored.get_node_or_null(BREACH_RELAY_NODE_NAME) as Node2D
	assert_that(restored_player).is_not_null()
	assert_that(restored_relay_node).is_not_null()
	if restored_player == null or restored_relay_node == null:
		return

	var max_hp: int = int(restored_player.call("get_max_hp"))
	restored_player.call("apply_damage", max_hp, {
		"source": "breach_relay_respawn_test",
		"damage_type": "lethal_probe",
	})
	restored.call("advance_factory_respawn_flow", 1.51)

	var flow: Dictionary = restored.call("get_factory_respawn_flow_diagnostics")
	var route: Dictionary = restored.call("get_factory_route_objective_diagnostics")
	assert_int(scene_manager.request_calls.size()).is_equal(1)
	assert_str(String(scene_manager.request_calls[0]["scene_id"])).is_equal(String(FACTORY_SCENE_ID))
	assert_str(String(scene_manager.request_calls[0]["spawn_point"])).is_equal(BREACH_RELAY_SPAWN_POINT)
	assert_str(String(Dictionary(flow.get("last_selected_respawn_point", {})).get(
		"spawn_point",
		""
	))).is_equal(BREACH_RELAY_SPAWN_POINT)
	assert_float(
		restored_player.global_position.distance_to(restored_relay_node.global_position)
	).is_less_equal(1.0)
	assert_str(String(route.get("route_label_text", ""))).is_equal("Returned to Lower Deck Relay")


func _factory_scene_with_breach_secured(breach_secured: bool) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _breach_ready_state(breach_secured))
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


func _breach_ready_state(breach_secured: bool) -> Dictionary:
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
		"factory_lower_deck_breach_corridor_activated": breach_secured,
		"factory_lower_deck_breach_front_guard_defeated": breach_secured,
		"factory_lower_deck_breach_rear_ambusher_activated": breach_secured,
		"factory_lower_deck_breach_rear_ambusher_defeated": breach_secured,
		"factory_lower_deck_breach_corridor_secured": breach_secured,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
		"last_return_checkpoint": {
			"id": "old_factory_return_checkpoint",
			"scene_id": String(FACTORY_SCENE_ID),
			"spawn_point": "return_checkpoint",
			"position": Vector2(704, 380),
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


func _position_from_snapshot(snapshot: Dictionary) -> Vector2:
	var value: Variant = snapshot.get("position", Vector2.ZERO)
	if value is Vector2:
		return value
	if value is Dictionary:
		var position_data: Dictionary = value as Dictionary
		return Vector2(
			float(position_data.get("x", 0.0)),
			float(position_data.get("y", 0.0))
		)
	return Vector2.ZERO


class FakeFactoryRequestSceneManager:
	extends RefCounted

	var current_scene: StringName = FACTORY_SCENE_ID
	var current_spawn_point: StringName = FACTORY_GATE_ENTRY_SPAWN_POINT
	var request_calls: Array[Dictionary] = []

	func request_scene_change(scene_id: StringName, spawn_point: StringName) -> bool:
		request_calls.append({
			"scene_id": scene_id,
			"spawn_point": spawn_point,
		})
		current_scene = scene_id
		current_spawn_point = spawn_point
		return true

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn_point

	func get_pending_spawn_point() -> StringName:
		return current_spawn_point
