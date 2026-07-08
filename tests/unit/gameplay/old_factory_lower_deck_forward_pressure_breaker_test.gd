## Player Abilities Story 079: Old Factory lower deck forward-pressure breaker.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FACTORY_PLAYER_NAME: String = "Player"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const EXIT_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_forward_pressure_exit_relay"
const EXIT_RELAY_SPAWN_POINT: String = "lower_deck_forward_pressure_exit_relay"
const BREAKER_ENTITY_ID: int = 2123
const BREAKER_HAZARD_ID: String = "old_factory_lower_deck_forward_pressure_breaker"
const BREAKER_NODE_NAME: String = "FactoryLowerDeckForwardPressureBreaker"
const BREAKER_ID: String = "old_factory_lower_deck_forward_pressure_breaker"
const BREAKER_TEXTURE: String = (
	"res://assets/environment/old_factory_forward_pressure_breaker/"
	+ "env_old_factory_forward_pressure_breaker_console_256.png"
)
const STEAM_VENT_TEXTURE: String = (
	"res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png"
)
const REQUIRED_BREAKER_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]
const MIN_CHARACTER_ANIMATION_FRAMES: int = 3

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_breaker_stand_requires_overrun_clear_and_activates_enemy_hazard() -> void:
	assert_bool(FileAccess.file_exists(STEAM_VENT_TEXTURE)).is_true()

	var locked_scene: Node = _factory_scene_with_breaker_state(false, false, false)
	assert_that(locked_scene).is_not_null()
	if locked_scene == null:
		return

	assert_bool(locked_scene.has_method(
		"get_factory_lower_deck_forward_pressure_breaker_stand_diagnostics"
	)).is_true()
	assert_bool(locked_scene.has_method(
		"try_activate_factory_lower_deck_forward_pressure_breaker_stand"
	)).is_true()
	if (
		not locked_scene.has_method(
			"get_factory_lower_deck_forward_pressure_breaker_stand_diagnostics"
		)
		or not locked_scene.has_method(
			"try_activate_factory_lower_deck_forward_pressure_breaker_stand"
		)
	):
		return

	var locked: Dictionary = locked_scene.call(
		"get_factory_lower_deck_forward_pressure_breaker_stand_diagnostics"
	)
	assert_bool(bool(locked.get("present", false))).is_true()
	assert_bool(bool(locked.get("overrun_defeated", true))).is_false()
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("active", true))).is_false()
	assert_bool(bool(locked.get("enemy_visible", true))).is_false()
	assert_bool(bool(locked.get("hazard_active", true))).is_false()
	assert_bool(bool(locked.get("breaker_visible", true))).is_false()
	assert_bool(bool(locked_scene.call(
		"try_activate_factory_lower_deck_forward_pressure_breaker_stand"
	))).is_false()

	var destination: Node = _factory_scene_with_breaker_state(true, false, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_breaker_stand_diagnostics"
	)
	assert_bool(bool(ready.get("present", false))).is_true()
	assert_bool(bool(ready.get("overrun_defeated", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("enemy_visible", true))).is_false()
	assert_bool(bool(ready.get("hazard_active", true))).is_false()
	assert_bool(bool(ready.get("breaker_visible", true))).is_false()
	assert_str(String(ready.get("route_label_text", ""))).is_equal(
		"Forward Pressure Overrun Cleared"
	)

	player.global_position.x = float(ready.get("activation_x", 0.0)) - 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_breaker_stand",
		player
	))).is_false()
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_breaker_stand",
		player
	))).is_true()

	var active: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_breaker_stand_diagnostics"
	)
	assert_bool(bool(active.get("active", false))).is_true()
	assert_bool(bool(active.get("secured", true))).is_false()
	assert_bool(bool(active.get("enemy_visible", false))).is_true()
	assert_bool(bool(active.get("enemy_has_target", false))).is_true()
	assert_bool(bool(active.get("enemy_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("enemy_process_enabled", false))).is_true()
	assert_int(int(active.get("entity_id", 0))).is_equal(BREAKER_ENTITY_ID)
	_assert_breaker_frame_contract(active)
	assert_bool(bool(active.get("hazard_active", false))).is_true()
	assert_bool(bool(active.get("hazard_visible", false))).is_true()
	assert_str(String(active.get("hazard_id", ""))).is_equal(BREAKER_HAZARD_ID)
	assert_int(int(active.get("hazard_damage", 0))).is_equal(8)
	assert_float(float(active.get("hazard_cooldown_sec", 0.0))).is_equal(1.0)
	assert_str(String(active.get("hazard_texture_path", ""))).is_equal(STEAM_VENT_TEXTURE)
	assert_bool(bool(active.get("breaker_visible", true))).is_false()
	assert_str(String(active.get("route_label_text", ""))).is_equal(
		"Secure Forward Pressure Breaker"
	)


func test_breaker_cut_persists_without_replaying_route_chain() -> void:
	var destination: Node = _factory_scene_with_breaker_state(true, false, false)
	assert_that(destination).is_not_null()
	if destination == null:
		return

	var player: Node2D = destination.get_node_or_null(FACTORY_PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return

	var ready: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_breaker_stand_diagnostics"
	)
	player.global_position.x = float(ready.get("activation_x", 0.0)) + 4.0
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_breaker_stand",
		player
	))).is_true()
	assert_bool(destination.call(
		"apply_damage",
		BREAKER_ENTITY_ID,
		999,
		{"source": &"unit_test_forward_pressure_breaker"}
	)).is_true()
	await get_tree().process_frame

	var secured: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_breaker_stand_diagnostics"
	)
	assert_bool(bool(secured.get("active", true))).is_false()
	assert_bool(bool(secured.get("secured", false))).is_true()
	assert_bool(bool(secured.get("enemy_visible", true))).is_false()
	assert_bool(bool(secured.get("hazard_active", true))).is_false()
	assert_bool(bool(secured.get("breaker_visible", false))).is_true()
	assert_str(String(secured.get("prompt_text", ""))).is_equal("Cut Pressure")
	assert_str(String(secured.get("texture_path", ""))).is_equal(BREAKER_TEXTURE)
	assert_bool(FileAccess.file_exists(BREAKER_TEXTURE)).is_true()
	assert_str(String(secured.get("route_label_text", ""))).is_equal(
		"Cut Forward Pressure"
	)

	var breaker_node: Node2D = destination.get_node_or_null(BREAKER_NODE_NAME) as Node2D
	assert_that(breaker_node).is_not_null()
	if breaker_node == null:
		return
	player.global_position = breaker_node.global_position
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_breaker",
		player
	))).is_true()
	assert_bool(bool(destination.call(
		"try_activate_factory_lower_deck_forward_pressure_breaker",
		player
	))).is_false()

	var cut: Dictionary = destination.call(
		"get_factory_lower_deck_forward_pressure_breaker_diagnostics"
	)
	assert_bool(bool(cut.get("cut", false))).is_true()
	assert_bool(bool(cut.get("available", true))).is_false()
	assert_bool(bool(cut.get("visible", false))).is_true()
	assert_str(String(cut.get("prompt_text", ""))).is_equal("Pressure Cut")
	assert_str(String(cut.get("route_label_text", ""))).is_equal(
		"Forward Pressure Breaker Cut"
	)
	assert_bool(bool(cut.get("unlock_feedback_played", false))).is_true()
	assert_int(int(cut.get("unlock_feedback_spawn_count", 0))).is_equal(1)

	var local_state: Dictionary = destination.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_breaker_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_breaker_secured",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_breaker_cut",
		false
	))).is_true()
	var lift: Dictionary = destination.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("available", false))).is_true()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


	var restored: Node = _factory_scene_with_breaker_state(true, true, true)
	assert_that(restored).is_not_null()
	if restored == null:
		return

	assert_bool(restored.has_method(
		"get_factory_lower_deck_forward_pressure_breaker_diagnostics"
	)).is_true()
	if not restored.has_method(
		"get_factory_lower_deck_forward_pressure_breaker_diagnostics"
	):
		return

	var breaker_diagnostics: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_breaker_diagnostics"
	)
	assert_bool(bool(breaker_diagnostics.get("present", false))).is_true()
	assert_bool(bool(breaker_diagnostics.get("overrun_defeated", false))).is_true()
	assert_bool(bool(breaker_diagnostics.get("secured", false))).is_true()
	assert_bool(bool(breaker_diagnostics.get("cut", false))).is_true()
	assert_bool(bool(breaker_diagnostics.get("available", true))).is_false()
	assert_bool(bool(breaker_diagnostics.get("visible", false))).is_true()
	assert_str(String(breaker_diagnostics.get("prompt_text", ""))).is_equal("Pressure Cut")
	assert_str(String(breaker_diagnostics.get("texture_path", ""))).is_equal(BREAKER_TEXTURE)
	assert_str(String(breaker_diagnostics.get("route_label_text", ""))).is_equal(
		"Forward Pressure Breaker Cut"
	)

	var overrun: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_overrun_diagnostics"
	)
	assert_bool(bool(overrun.get("active", true))).is_false()
	assert_bool(bool(overrun.get("defeated", false))).is_true()
	assert_bool(bool(overrun.get("enemy_visible", true))).is_false()
	assert_bool(bool(overrun.get("hazard_active", true))).is_false()
	var marker: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_route_handoff_marker_diagnostics"
	)
	assert_bool(bool(marker.get("lit", false))).is_true()
	var relay: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
	)
	assert_bool(bool(relay.get("activated", false))).is_true()
	assert_str(String(relay.get("savepoint_id", ""))).is_equal(EXIT_RELAY_SAVEPOINT_ID)
	assert_str(String(relay.get("spawn_point", ""))).is_equal(EXIT_RELAY_SPAWN_POINT)
	var cache: Dictionary = restored.call(
		"get_factory_lower_deck_forward_pressure_reward_cache_diagnostics"
	)
	assert_bool(bool(cache.get("claimed", false))).is_true()
	assert_int(int(cache.get("claim_audio_request_count", -1))).is_equal(0)
	var clear_feedback: Dictionary = restored.call(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	)
	assert_int(int(clear_feedback.get("spawn_count", -1))).is_equal(0)
	var restored_lift: Dictionary = restored.call("get_factory_service_lift_diagnostics")
	assert_str(String(restored_lift.get("prompt_text", ""))).is_equal("Call lift")


func _factory_scene_with_breaker_state(
		overrun_defeated: bool,
		breaker_secured: bool,
		breaker_cut: bool
) -> Node:
	var destination: Node = _instantiate_factory_scene()
	if destination == null:
		return null
	destination.call("set_local_state", _forward_pressure_breaker_base_state().merged({
		"factory_lower_deck_forward_pressure_beacon_ambush_activated": true,
		"factory_lower_deck_forward_pressure_beacon_ambush_defeated": true,
		"factory_lower_deck_forward_pressure_overrun_activated": overrun_defeated,
		"factory_lower_deck_forward_pressure_overrun_defeated": overrun_defeated,
		"factory_lower_deck_forward_pressure_breaker_activated": breaker_secured,
		"factory_lower_deck_forward_pressure_breaker_secured": breaker_secured,
		"factory_lower_deck_forward_pressure_breaker_cut": breaker_cut,
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


func _forward_pressure_breaker_base_state() -> Dictionary:
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
		"factory_lower_deck_forward_pressure_exit_guard_activated": true,
		"factory_lower_deck_forward_pressure_exit_guard_defeated": true,
		"factory_lower_deck_forward_pressure_exit_relay_activated": true,
		"factory_lower_deck_forward_pressure_exit_gate_opened": true,
		"factory_lower_deck_forward_pressure_route_handoff_marker_lit": true,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
		"factory_service_lift_exit_scene_id": "main",
		"factory_service_lift_exit_spawn_point": "scrap_roost",
		"last_return_checkpoint": {
			"id": EXIT_RELAY_SAVEPOINT_ID,
			"scene_id": String(FACTORY_SCENE_ID),
			"spawn_point": EXIT_RELAY_SPAWN_POINT,
			"position": Vector2(1508, 382),
		},
	}


func _assert_breaker_frame_contract(diagnostics: Dictionary) -> void:
	var frame_counts: Dictionary = diagnostics.get("animation_frame_counts", {}) as Dictionary
	for animation_name: StringName in REQUIRED_BREAKER_ANIMATIONS:
		assert_int(int(frame_counts.get(String(animation_name), 0))).is_greater_equal(
			MIN_CHARACTER_ANIMATION_FRAMES
		)
