## Story193: forward-pressure exit guard production movement handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const EXIT_GUARD_ENTITY_ID: int = 2120
const EXIT_GUARD_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_exit_guard"
)
const REQUIRED_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]

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


func test_real_move_right_starts_visible_forward_pressure_exit_guard() -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	for _frame: int in range(18):
		await get_tree().process_frame
	factory.call("set_local_state", _forward_pressure_exit_guard_ready_state())

	var player := factory.get_node_or_null("Player") as CharacterBody2D
	var enemy := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureExitGuardSparkRat"
	) as Node2D
	var hazard := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureExitGuardVent"
	) as Area2D
	var steam_animation := hazard.get_node_or_null(
		"SteamAnimation"
	) as AnimatedSprite2D if hazard != null else null
	var hatch := factory.get_node_or_null("FactoryLowerDeckForwardHatch") as Node2D
	var lift := factory.get_node_or_null("FactoryServiceLift") as Node2D
	var route_label := factory.get_node_or_null("RouteHud/RouteLabel") as Label
	assert_that(player).is_not_null()
	assert_that(enemy).is_not_null()
	assert_that(hazard).is_not_null()
	assert_that(steam_animation).is_not_null()
	assert_that(hatch).is_not_null()
	assert_that(lift).is_not_null()
	assert_that(route_label).is_not_null()
	if (
		player == null
		or enemy == null
		or hazard == null
		or steam_animation == null
		or hatch == null
		or lift == null
		or route_label == null
	):
		return

	var before: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
	)
	var reward_before: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_reward_cache_diagnostics"
	)
	var activation_x: float = float(before.get("activation_x", 0.0))
	assert_float(activation_x).is_equal(1352.0)
	assert_bool(bool(before.get("available", true))).is_false()
	assert_bool(bool(before.get("active", true))).is_false()
	assert_bool(bool(before.get("enemy_visible", true))).is_false()
	assert_bool(bool(before.get("hazard_active", true))).is_false()
	assert_bool(bool(reward_before.get("claim_available", false))).is_true()
	assert_bool(bool(reward_before.get("claimed", true))).is_false()
	var relay_before: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
	)
	assert_bool(bool(relay_before.get("available", true))).is_false()
	assert_bool(bool(relay_before.get("visible", true))).is_false()
	assert_bool(bool(relay_before.get("activated", true))).is_false()

	var reward_position: Vector2 = reward_before.get("position", Vector2.ZERO) as Vector2
	player.set_physics_process(false)
	player.global_position = Vector2(activation_x, reward_position.y)
	player.velocity = Vector2.ZERO
	Input.action_press(&"interact")
	factory.call("_process", 0.0)
	var claimed: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_reward_cache_diagnostics"
	)
	var armed: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
	)
	assert_bool(bool(claimed.get("claimed", false))).is_true()
	assert_int(int(claimed.get("claim_audio_request_count", 0))).is_equal(1)
	assert_bool(bool(armed.get("available", false))).is_true()
	assert_bool(bool(armed.get("active", true))).is_false()
	for _frame: int in range(3):
		factory.call("_process", 0.0)
	armed = factory.call(
		"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
	)
	assert_bool(bool(armed.get("active", true))).override_failure_message(
		"Story193: a held cache claim must not activate entity 2120 while stationary at x=1352"
	).is_false()
	Input.action_release(&"interact")
	factory.call("_process", 0.0)

	var start_x: float = activation_x
	player.global_position = Vector2(start_x, 456.0)
	player.set_physics_process(true)
	player.velocity = Vector2.ZERO
	Input.action_press(&"move_right")
	var crossed_boundary: bool = false
	for _frame: int in range(45):
		await get_tree().physics_frame
		crossed_boundary = crossed_boundary or player.global_position.x >= activation_x
		var current: Dictionary = factory.call(
			"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
		)
		if bool(current.get("active", false)):
			break
	Input.action_release(&"move_right")
	await get_tree().process_frame

	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(start_x)
	assert_bool(crossed_boundary).is_true()
	assert_bool(bool(active.get("active", false))).override_failure_message(
		"Story193: real move_right crossed x=1352 but production movement did not activate entity 2120"
	).is_true()
	if not bool(active.get("active", false)):
		return

	assert_bool(bool(active.get("defeated", true))).is_false()
	assert_bool(bool(active.get("enemy_visible", false))).is_true()
	assert_bool(bool(active.get("enemy_has_target", false))).is_true()
	assert_bool(bool(active.get("enemy_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("enemy_process_enabled", false))).is_true()
	assert_int(int(active.get("entity_id", 0))).is_equal(EXIT_GUARD_ENTITY_ID)
	var frame_counts: Dictionary = active.get("animation_frame_counts", {}) as Dictionary
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		assert_int(int(frame_counts.get(String(animation_name), 0))).is_greater_equal(3)
	var pacing: Dictionary = active.get("pacing", {}) as Dictionary
	assert_str(String(pacing.get("pacing_state", ""))).is_equal("opening_grace")
	assert_int(int(pacing.get("opening_grace_frames", 0))).is_greater(0)
	assert_int(int(pacing.get("opening_grace_frames", 0))).is_less_equal(18)
	assert_str(String(pacing.get("current_animation", ""))).is_equal("idle")
	assert_bool(bool(pacing.get("attack_active", true))).is_false()
	assert_bool(bool(active.get("hazard_active", false))).is_true()
	assert_bool(bool(active.get("hazard_visible", false))).is_true()
	assert_str(String(active.get("hazard_id", ""))).is_equal(EXIT_GUARD_HAZARD_ID)
	assert_int(int(active.get("hazard_damage", 0))).is_equal(8)
	assert_float(float(active.get("hazard_cooldown_sec", 0.0))).is_equal(1.0)
	assert_that(steam_animation.animation).is_equal(&"active")
	assert_int(steam_animation.sprite_frames.get_frame_count(&"active")).is_equal(4)
	assert_bool(steam_animation.is_playing()).is_true()
	assert_int(enemy.z_index).is_greater(hatch.z_index)
	assert_int(enemy.z_index).is_greater(lift.z_index)
	var steam_effective_z: int = hazard.z_index + steam_animation.z_index
	assert_int(steam_effective_z).is_greater(hatch.z_index)
	assert_int(steam_effective_z).is_greater(lift.z_index)

	var objective: Dictionary = factory.call("get_factory_route_objective_diagnostics")
	assert_str(String(objective.get("objective_id", ""))).is_equal(
		"clear_forward_pressure_exit_guard"
	)
	assert_str(String(objective.get("route_label_text", ""))).is_equal(
		"Clear Forward Pressure Exit Guard"
	)
	assert_bool(route_label.visible).is_true()
	assert_str(route_label.text).is_equal("Clear Forward Pressure Exit Guard")
	var reward: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_reward_cache_diagnostics"
	)
	assert_bool(bool(reward.get("claimed", false))).is_true()
	assert_int(int(reward.get("claim_audio_request_count", -1))).is_equal(1)
	var relay: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_exit_relay_diagnostics"
	)
	assert_bool(bool(relay.get("available", true))).is_false()
	assert_bool(bool(relay.get("visible", true))).is_false()
	assert_bool(bool(relay.get("activated", true))).is_false()
	var lift_state: Dictionary = factory.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift_state.get("activated", true))).is_false()
	assert_bool(bool(lift_state.get("exit_requested", true))).is_false()
	assert_bool(bool(factory.call("get_local_state").get(
		"factory_lower_deck_forward_pressure_exit_guard_activated",
		false
	))).is_true()


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


func _forward_pressure_exit_guard_ready_state() -> Dictionary:
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
		"factory_lower_deck_forward_pressure_reward_cache_claimed": false,
		"factory_lower_deck_forward_pressure_exit_guard_activated": false,
		"factory_lower_deck_forward_pressure_exit_guard_defeated": false,
		"factory_lower_deck_forward_pressure_exit_relay_activated": false,
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
