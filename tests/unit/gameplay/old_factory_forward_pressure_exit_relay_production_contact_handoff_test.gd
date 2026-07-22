## Story194: forward-pressure exit relay production contact handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const EXIT_GUARD_ENTITY_ID: int = 2120
const EXIT_RELAY_SAVEPOINT_ID: String = (
	"old_factory_lower_deck_forward_pressure_exit_relay"
)
const FACTORY_SCENE_ID: String = "area_03_factory"
const EXIT_RELAY_SPAWN_POINT: String = "lower_deck_forward_pressure_exit_relay"

var _spawned_nodes: Array[Node] = []


func before_test() -> void:
	Input.action_release(&"move_right")
	Input.action_release(&"interact")


func after_test() -> void:
	Input.action_release(&"move_right")
	Input.action_release(&"interact")
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_real_contact_secures_exit_relay_without_chaining_gate_or_lift() -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	for _frame: int in range(18):
		await get_tree().process_frame
	factory.call("set_local_state", _forward_pressure_exit_guard_active_state())

	var player := factory.get_node_or_null("Player") as CharacterBody2D
	var relay := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureExitRelaySavepoint"
	) as Node2D
	var relay_prompt := relay.get_node_or_null("PromptLabel") as Label if relay != null else null
	assert_that(player).is_not_null()
	assert_that(relay).is_not_null()
	assert_that(relay_prompt).is_not_null()
	if player == null or relay == null or relay_prompt == null:
		return

	player.set_physics_process(false)
	player.global_position = Vector2(relay.global_position.x - 128.0, 456.0)
	player.velocity = Vector2.ZERO
	var locked: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
	)
	assert_bool(bool(locked.get("available", true))).is_false()
	assert_bool(bool(locked.get("visible", true))).is_false()
	assert_bool(bool(locked.get("activated", true))).is_false()

	assert_bool(bool(factory.call(
		"apply_damage",
		EXIT_GUARD_ENTITY_ID,
		999,
		{"source": &"story194_production_contact"}
	))).is_true()
	await get_tree().process_frame
	await get_tree().physics_frame

	var ready: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
	)
	assert_bool(bool(ready.get("exit_guard_defeated", false))).is_true()
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("visible", false))).override_failure_message(
		"Story194: defeating entity 2120 must reveal the production exit relay"
	).is_true()
	assert_bool(bool(ready.get("activated", true))).is_false()
	assert_bool(bool(ready.get("interaction_monitoring", false))).is_true()
	assert_bool(bool(ready.get("interaction_monitorable", false))).is_true()
	assert_bool(bool(ready.get("collision_disabled", true))).is_false()
	assert_str(String(ready.get("prompt_text", ""))).is_equal("Repair Exit Relay")
	assert_bool(relay_prompt.visible).is_true()

	var start_x: float = player.global_position.x
	player.set_physics_process(true)
	Input.action_press(&"move_right")
	for _frame: int in range(80):
		await get_tree().physics_frame
		var current: Dictionary = factory.call(
			"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
		)
		if bool(current.get("activated", false)):
			break
	Input.action_release(&"move_right")
	await get_tree().process_frame
	await get_tree().process_frame

	var activated: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(start_x)
	assert_bool(bool(activated.get("activated", false))).override_failure_message(
		"Story194: real move_right contact must activate the SavepointRuntime relay"
	).is_true()
	assert_bool(bool(activated.get("available", true))).is_false()
	assert_bool(bool(activated.get("interaction_monitoring", true))).is_false()
	assert_bool(bool(activated.get("interaction_monitorable", true))).is_false()
	assert_bool(bool(activated.get("collision_disabled", false))).is_true()
	assert_bool(relay_prompt.visible).override_failure_message(
		"Story194: the secured relay prompt must hide before the gate prompt appears"
	).is_false()
	assert_str(String(activated.get("route_label_text", ""))).is_equal(
		"Forward Pressure Exit Relay Secured"
	)
	var last_savepoint: Dictionary = activated.get("last_savepoint", {}) as Dictionary
	assert_str(String(last_savepoint.get("id", ""))).is_equal(EXIT_RELAY_SAVEPOINT_ID)
	assert_str(String(last_savepoint.get("scene_id", ""))).is_equal(FACTORY_SCENE_ID)
	assert_str(String(last_savepoint.get("spawn_point", ""))).is_equal(
		EXIT_RELAY_SPAWN_POINT
	)
	var activation_vfx: Dictionary = relay.call("get_activation_vfx_snapshot")
	assert_bool(bool(activation_vfx.get("played", false))).is_true()
	assert_int(int(activation_vfx.get("spawn_count", 0))).is_equal(1)
	for _frame: int in range(3):
		await get_tree().physics_frame
	activation_vfx = relay.call("get_activation_vfx_snapshot")
	assert_int(int(activation_vfx.get("spawn_count", 0))).is_equal(1)
	assert_bool(bool(factory.call("get_local_state").get(
		"factory_lower_deck_forward_pressure_exit_relay_activated",
		false
	))).is_true()

	var gate: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_exit_gate_diagnostics"
	)
	assert_bool(bool(gate.get("available", false))).is_true()
	assert_bool(bool(gate.get("visible", false))).is_true()
	assert_bool(bool(gate.get("opened", true))).is_false()
	assert_bool(bool(gate.get("collision_blocking", false))).is_true()
	assert_str(String(gate.get("prompt_text", ""))).is_equal("Open Exit Gate")
	var lift: Dictionary = factory.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift.get("activated", true))).is_false()
	assert_bool(bool(lift.get("exit_requested", true))).is_false()
	assert_str(String(lift.get("prompt_text", ""))).is_equal("Call lift")


func _instantiate_factory_scene() -> Node:
	assert_bool(FileAccess.file_exists(FACTORY_SCENE_PATH)).is_true()
	var packed := load(FACTORY_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var factory: Node = packed.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	return factory


func _forward_pressure_exit_guard_active_state() -> Dictionary:
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
		"factory_lower_deck_forward_pressure_exit_guard_defeated": false,
		"factory_lower_deck_forward_pressure_exit_relay_activated": false,
		"factory_lower_deck_forward_pressure_exit_gate_opened": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
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
