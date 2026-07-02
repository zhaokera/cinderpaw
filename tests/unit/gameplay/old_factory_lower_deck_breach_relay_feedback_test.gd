# Player Abilities Story 063: Old Factory lower deck breach relay feedback.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const BREACH_RELAY_NODE_NAME: String = "FactoryLowerDeckBreachRelaySavepoint"
const EXPECTED_RELAY_FEEDBACK_TEXTURE: String = (
	"res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png"
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


func test_breach_relay_mounts_generated_activation_feedback_texture() -> void:
	var destination: Node = _factory_scene_with_breach_secured(true)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var relay: Node = destination.get_node_or_null(BREACH_RELAY_NODE_NAME)
	assert_that(relay).is_not_null()
	if relay == null:
		return

	assert_bool(FileAccess.file_exists(EXPECTED_RELAY_FEEDBACK_TEXTURE)).is_true()
	assert_bool(relay.has_method("get_activation_vfx_texture_path")).is_true()
	assert_bool(relay.has_method("get_activation_vfx_snapshot")).is_true()
	assert_str(String(relay.call("get_activation_vfx_texture_path"))).is_equal(
		EXPECTED_RELAY_FEEDBACK_TEXTURE
	)

	var snapshot: Dictionary = relay.call("get_activation_vfx_snapshot")
	assert_str(String(snapshot.get("texture_path", ""))).is_equal(EXPECTED_RELAY_FEEDBACK_TEXTURE)
	assert_int(int(snapshot.get("active_count", -1))).is_equal(0)
	assert_bool(_relay_has_visible_placeholder_feedback(relay)).is_false()


func test_breach_relay_activation_spawns_one_short_lived_feedback_vfx() -> void:
	var destination: Node = _factory_scene_with_breach_secured(true)
	assert_that(destination).is_not_null()
	if destination == null:
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

	var snapshot: Dictionary = relay.call("get_activation_vfx_snapshot")
	assert_int(int(snapshot.get("active_count", 0))).is_equal(1)
	assert_int(int(snapshot.get("spawn_count", 0))).is_equal(1)
	assert_bool(bool(snapshot.get("played", false))).is_true()
	assert_str(String(snapshot.get("texture_path", ""))).is_equal(EXPECTED_RELAY_FEEDBACK_TEXTURE)
	assert_float(float(snapshot.get("duration_sec", 0.0))).is_greater(0.0)

	var last_spawn: Dictionary = Dictionary(snapshot.get("last_spawn", {}))
	assert_str(String(last_spawn.get("asset_source", ""))).is_equal("image_generation")
	assert_str(String(last_spawn.get("vfx_role", ""))).is_equal("savepoint_activation")
	assert_str(String(last_spawn.get("savepoint_id", ""))).is_equal("old_factory_lower_deck_breach_relay")
	assert_str(String(last_spawn.get("texture_path", ""))).is_equal(EXPECTED_RELAY_FEEDBACK_TEXTURE)

	var diagnostics: Dictionary = destination.call("get_factory_lower_deck_breach_relay_diagnostics")
	assert_str(String(diagnostics.get("activation_feedback_texture_path", ""))).is_equal(
		EXPECTED_RELAY_FEEDBACK_TEXTURE
	)
	assert_bool(bool(diagnostics.get("activation_feedback_active", false))).is_true()
	assert_bool(bool(diagnostics.get("activation_feedback_played", false))).is_true()
	assert_int(int(diagnostics.get("activation_feedback_spawn_count", 0))).is_equal(1)

	assert_bool(relay.has_method("advance_activation_vfx_time")).is_true()
	relay.call("advance_activation_vfx_time", float(snapshot.get("duration_sec", 0.0)) + 0.1)
	var expired: Dictionary = relay.call("get_activation_vfx_snapshot")
	assert_int(int(expired.get("active_count", -1))).is_equal(0)
	assert_int(int(expired.get("spawn_count", 0))).is_equal(1)


func test_breach_relay_activation_routes_one_spatial_audio_feedback_event() -> void:
	var destination: Node = _factory_scene_with_breach_secured(true)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	var relay: Node2D = destination.get_node_or_null(BREACH_RELAY_NODE_NAME) as Node2D
	var audio_system := get_node_or_null("/root/AudioSystem")
	assert_that(player).is_not_null()
	assert_that(relay).is_not_null()
	assert_that(audio_system).is_not_null()
	if player == null or relay == null or audio_system == null:
		return

	player.global_position = relay.global_position
	assert_bool(bool(destination.call("try_activate_factory_lower_deck_breach_relay", player))).is_true()

	var diagnostics: Dictionary = destination.call("get_factory_lower_deck_breach_relay_diagnostics")
	assert_int(int(diagnostics.get("activation_audio_request_count", 0))).is_equal(1)
	assert_bool(bool(diagnostics.get("activation_audio_requested", false))).is_true()

	var audio_event: Dictionary = Dictionary(diagnostics.get("activation_audio_event", {}))
	assert_str(String(audio_event.get("event_id", &""))).is_equal("savepoint_activated")
	assert_str(String(audio_event.get("sfx_id", &""))).is_equal("sfx_door_unlock")
	assert_vector(audio_event.get("position", Vector2.ZERO)).is_equal(relay.global_position)
	var event_metadata: Dictionary = Dictionary(audio_event.get("metadata", {}))
	assert_str(String(event_metadata.get("savepoint_id", &""))).is_equal("old_factory_lower_deck_breach_relay")
	assert_str(String(event_metadata.get("scene_id", &""))).is_equal("area_03_factory")
	assert_str(String(event_metadata.get("spawn_point", &""))).is_equal("lower_deck_breach_relay")
	assert_str(String(event_metadata.get("feedback_role", &""))).is_equal("savepoint_activation")
	assert_str(String(event_metadata.get("source", &""))).is_equal("factory_lower_deck_breach_relay")
	assert_vector(event_metadata.get("world_position", Vector2.ZERO)).is_equal(relay.global_position)

	var runtime_event: Dictionary = audio_system.call("get_last_gameplay_audio_event")
	assert_str(String(runtime_event.get("event_id", &""))).is_equal("savepoint_activated")
	assert_str(String(runtime_event.get("sfx_id", &""))).is_equal("sfx_door_unlock")
	assert_vector(runtime_event.get("position", Vector2.ZERO)).is_equal(relay.global_position)
	var runtime_request: Dictionary = audio_system.call("get_last_sfx_request")
	assert_str(String(runtime_request.get("sfx_id", &""))).is_equal("sfx_door_unlock")
	assert_bool(bool(runtime_request.get("stream_found", false))).is_true()

	assert_bool(bool(destination.call("try_activate_factory_lower_deck_breach_relay", player))).is_false()
	diagnostics = destination.call("get_factory_lower_deck_breach_relay_diagnostics")
	assert_int(int(diagnostics.get("activation_audio_request_count", 0))).is_equal(1)


func test_restored_breach_relay_does_not_replay_activation_feedback() -> void:
	var restored: Node = _factory_scene_with_breach_secured(true)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	var local_state: Dictionary = _breach_ready_state(true)
	local_state["factory_lower_deck_breach_relay_activated"] = true
	restored.call("set_local_state", local_state)

	var relay: Node = restored.get_node_or_null(BREACH_RELAY_NODE_NAME)
	assert_that(relay).is_not_null()
	if relay == null:
		return

	var diagnostics: Dictionary = restored.call("get_factory_lower_deck_breach_relay_diagnostics")
	assert_bool(bool(diagnostics.get("activated", false))).is_true()
	assert_bool(bool(diagnostics.get("activation_feedback_active", true))).is_false()
	assert_bool(bool(diagnostics.get("activation_feedback_played", true))).is_false()
	assert_int(int(diagnostics.get("activation_feedback_spawn_count", -1))).is_equal(0)
	assert_bool(bool(diagnostics.get("activation_audio_requested", true))).is_false()
	assert_int(int(diagnostics.get("activation_audio_request_count", -1))).is_equal(0)

	var snapshot: Dictionary = relay.call("get_activation_vfx_snapshot")
	assert_int(int(snapshot.get("active_count", -1))).is_equal(0)
	assert_int(int(snapshot.get("spawn_count", -1))).is_equal(0)


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
		"factory_lower_deck_shortcut_reward_cache_claimed": true,
		"factory_lower_deck_shortcut_pursuer_activated": true,
		"factory_lower_deck_shortcut_pursuer_defeated": true,
		"factory_lower_deck_pressure_valve_guard_activated": true,
		"factory_lower_deck_pressure_valve_guard_defeated": true,
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
		"factory_service_lift_exit_spawn_point": "scrap_roost",
	}


func _relay_has_visible_placeholder_feedback(relay: Node) -> bool:
	for child: Node in relay.get_children():
		if child is ColorRect or child is Polygon2D:
			if child.visible:
				return true
	return false


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
