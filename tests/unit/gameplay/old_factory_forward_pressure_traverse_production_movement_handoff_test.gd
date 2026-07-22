## Story190: Forward pressure traverse production movement handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const FORWARD_PRESSURE_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_traverse"
)
const BREACH_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_breach_relay"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const BREACH_RELAY_SPAWN_POINT: String = "lower_deck_breach_relay"
const REQUIRED_STEAM_ANIMATIONS: Array[StringName] = [
	&"safe",
	&"warning",
	&"active",
]

var _spawned_nodes: Array[Node] = []


func before_test() -> void:
	Input.action_release(&"move_right")


func after_test() -> void:
	Input.action_release(&"move_right")
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_real_move_right_starts_times_and_completes_forward_pressure_traverse() -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	for _frame: int in range(18):
		await get_tree().process_frame
	factory.call("set_local_state", _forward_conduit_secured_state())

	var player := factory.get_node_or_null("Player") as CharacterBody2D
	var pressure_vent := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureVent"
	) as Area2D
	var steam_animation := pressure_vent.get_node_or_null(
		"SteamAnimation"
	) as AnimatedSprite2D if pressure_vent != null else null
	var hatch := factory.get_node_or_null("FactoryLowerDeckForwardHatch") as Node2D
	var lift := factory.get_node_or_null("FactoryServiceLift") as Node2D
	var hatch_prompt := factory.get_node_or_null(
		"FactoryLowerDeckForwardHatch/PromptLabel"
	) as Label
	var route_label := factory.get_node_or_null("RouteHud/RouteLabel") as Label
	assert_that(player).is_not_null()
	assert_that(pressure_vent).is_not_null()
	assert_that(steam_animation).is_not_null()
	assert_that(hatch).is_not_null()
	assert_that(lift).is_not_null()
	assert_that(hatch_prompt).is_not_null()
	assert_that(route_label).is_not_null()
	assert_bool(factory.has_method(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)).is_true()
	if (
		player == null
		or pressure_vent == null
		or steam_animation == null
		or hatch == null
		or lift == null
		or hatch_prompt == null
		or route_label == null
		or not factory.has_method(
			"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
		)
	):
		return

	var ready: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)
	var activation_x: float = float(ready.get("activation_x", 0.0))
	var exit_x: float = float(ready.get("exit_x", 0.0))
	assert_float(activation_x).is_equal(1284.0)
	assert_float(exit_x).is_equal(1328.0)
	assert_bool(bool(ready.get("available", false))).is_true()
	assert_bool(bool(ready.get("visible", false))).is_true()
	assert_bool(bool(ready.get("active", true))).is_false()
	assert_bool(bool(ready.get("crossed", true))).is_false()
	assert_str(String(ready.get("phase", ""))).is_equal("idle")
	assert_str(String(ready.get("hazard_id", ""))).is_equal(
		FORWARD_PRESSURE_HAZARD_ID
	)
	assert_int(int(ready.get("hazard_damage", 0))).is_equal(8)
	assert_float(float(ready.get("hazard_cooldown_sec", 0.0))).is_equal(1.0)
	assert_bool(bool(ready.get("hazard_contact_active", true))).is_false()
	assert_bool(hatch_prompt.visible).is_false()
	assert_that(route_label.get_parent()).is_instanceof(CanvasLayer)
	assert_str(route_label.text).is_equal("Forward Conduit Secured")
	for animation_name: StringName in REQUIRED_STEAM_ANIMATIONS:
		assert_int(steam_animation.sprite_frames.get_frame_count(animation_name)).is_equal(4)
	var steam_effective_z: int = pressure_vent.z_index + steam_animation.z_index
	assert_int(steam_effective_z).is_greater(hatch.z_index)
	assert_int(steam_effective_z).is_greater(lift.z_index)

	player.global_position = Vector2(activation_x - 36.0, 456.0)
	player.velocity = Vector2.ZERO
	await get_tree().physics_frame
	Input.action_press(&"move_right")
	var crossed_activation: bool = false
	for _frame: int in range(45):
		await get_tree().physics_frame
		crossed_activation = crossed_activation or player.global_position.x >= activation_x
		var current: Dictionary = factory.call(
			"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
		)
		if bool(current.get("active", false)):
			break
	Input.action_release(&"move_right")
	await get_tree().process_frame
	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)
	assert_bool(crossed_activation).is_true()
	assert_bool(bool(active.get("active", false))).override_failure_message(
		"Story190: real move_right crossed x=1284 but production movement did not start Story069"
	).is_true()
	assert_bool(bool(active.get("crossed", true))).is_false()
	assert_str(String(active.get("phase", ""))).is_equal("grace")
	assert_float(float(active.get("elapsed_sec", 0.0))).is_greater(0.0)
	assert_bool(bool(active.get("hazard_contact_active", true))).is_false()
	assert_that(steam_animation.animation).is_equal(&"safe")
	assert_bool(steam_animation.is_playing()).is_true()
	assert_str(String(
		factory.call("get_factory_route_objective_diagnostics").get(
			"route_label_text",
			""
		)
	)).is_equal("Cross Forward Pressure Leak")

	player.set_physics_process(false)
	var left_grace: bool = false
	for _frame: int in range(60):
		await get_tree().process_frame
		var timing: Dictionary = factory.call(
			"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
		)
		if String(timing.get("phase", "")) != "grace":
			left_grace = true
			break
	assert_bool(left_grace).override_failure_message(
		"Story190: production _process did not advance the Story069 pressure cycle"
	).is_true()
	var advanced: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)
	assert_float(float(advanced.get("elapsed_sec", 0.0))).is_greater_equal(0.25)
	assert_str(String(advanced.get("phase", ""))).is_not_equal("grace")

	player.set_physics_process(true)
	player.velocity = Vector2.ZERO
	Input.action_press(&"move_right")
	var crossed_exit: bool = false
	for _frame: int in range(60):
		await get_tree().physics_frame
		crossed_exit = crossed_exit or player.global_position.x >= exit_x
		var current: Dictionary = factory.call(
			"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
		)
		if bool(current.get("crossed", false)):
			break
	Input.action_release(&"move_right")
	await get_tree().process_frame
	var crossed: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)
	assert_bool(crossed_exit).is_true()
	assert_bool(bool(crossed.get("active", true))).is_false()
	assert_bool(bool(crossed.get("crossed", false))).override_failure_message(
		"Story190: real move_right crossed x=1328 but production movement did not complete Story069"
	).is_true()
	assert_str(String(crossed.get("phase", ""))).is_equal("crossed")
	assert_bool(bool(crossed.get("visible", true))).is_false()
	assert_bool(bool(crossed.get("hazard_contact_active", true))).is_false()
	assert_bool(steam_animation.is_playing()).is_false()
	assert_str(String(
		factory.call("get_factory_route_objective_diagnostics").get(
			"route_label_text",
			""
		)
	)).is_equal("Forward Pressure Traverse Crossed")
	assert_bool(bool(factory.call("get_local_state").get(
		"factory_lower_deck_forward_pressure_traverse_crossed",
		false
	))).is_true()

	var counter: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_counter_ambush_diagnostics"
	)
	assert_bool(bool(counter.get("available", false))).is_true()
	assert_bool(bool(counter.get("active", true))).is_false()
	assert_bool(bool(counter.get("enemy_visible", true))).is_false()
	assert_bool(bool(counter.get("hazard_visible", true))).is_false()
	var clear_feedback: Dictionary = factory.call(
		"get_factory_lower_deck_forward_conduit_clear_feedback_diagnostics"
	)
	assert_bool(bool(clear_feedback.get("played", true))).is_false()
	assert_bool(bool(clear_feedback.get("visible", true))).is_false()
	assert_int(int(clear_feedback.get("spawn_count", -1))).is_equal(0)
	var lift_state: Dictionary = factory.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift_state.get("available", false))).is_true()
	assert_bool(bool(lift_state.get("activated", true))).is_false()
	assert_bool(bool(lift_state.get("exit_requested", true))).is_false()
	assert_str(String(lift_state.get("prompt_text", ""))).is_equal("Call lift")


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


func _forward_conduit_secured_state() -> Dictionary:
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
		"factory_return_patrol_reward_cache_claimed": true,
		"factory_return_checkpoint_activated": true,
		"factory_checkpoint_forward_patrol_activated": true,
		"factory_checkpoint_forward_patrol_defeated": true,
		"factory_checkpoint_rear_ambush_activated": true,
		"factory_checkpoint_rear_ambush_defeated": true,
		"factory_checkpoint_overdrive_duo_activated": true,
		"factory_checkpoint_overdrive_left_defeated": true,
		"factory_checkpoint_overdrive_right_defeated": true,
		"factory_checkpoint_overdrive_duo_cleared": true,
		"factory_checkpoint_overdrive_reward_cache_claimed": true,
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
		"factory_lower_deck_forward_pressure_traverse_crossed": false,
		"factory_lower_deck_forward_pressure_counter_ambush_activated": false,
		"factory_lower_deck_forward_pressure_counter_ambush_defeated": false,
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
