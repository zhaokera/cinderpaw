## Story191: Forward pressure counter-ambush production movement handoff.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const COUNTER_AMBUSH_ENTITY_ID: int = 2119
const COUNTER_AMBUSH_HAZARD_ID: String = (
	"old_factory_lower_deck_forward_pressure_counter_ambush"
)
const BREACH_RELAY_SAVEPOINT_ID: String = "old_factory_lower_deck_breach_relay"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const BREACH_RELAY_SPAWN_POINT: String = "lower_deck_breach_relay"
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


func test_real_move_right_starts_visible_forward_pressure_counter_ambush() -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	for _frame: int in range(18):
		await get_tree().process_frame
	factory.call("set_local_state", _forward_pressure_traverse_crossed_state())

	var player := factory.get_node_or_null("Player") as CharacterBody2D
	var enemy := factory.get_node_or_null(
		"FactoryLowerDeckForwardCounterSparkRat"
	) as Node2D
	var hazard := factory.get_node_or_null(
		"FactoryLowerDeckForwardCounterPressureVent"
	) as Area2D
	var steam_animation := hazard.get_node_or_null(
		"SteamAnimation"
	) as AnimatedSprite2D if hazard != null else null
	var traverse_vent := factory.get_node_or_null(
		"FactoryLowerDeckForwardPressureVent"
	) as Area2D
	var hatch := factory.get_node_or_null("FactoryLowerDeckForwardHatch") as Node2D
	var lift := factory.get_node_or_null("FactoryServiceLift") as Node2D
	var route_label := factory.get_node_or_null("RouteHud/RouteLabel") as Label
	assert_that(player).is_not_null()
	assert_that(enemy).is_not_null()
	assert_that(hazard).is_not_null()
	assert_that(steam_animation).is_not_null()
	assert_that(traverse_vent).is_not_null()
	assert_that(hatch).is_not_null()
	assert_that(lift).is_not_null()
	assert_that(route_label).is_not_null()
	assert_bool(factory.has_method(
		"get_factory_lower_deck_forward_pressure_counter_ambush_diagnostics"
	)).is_true()
	if (
		player == null
		or enemy == null
		or hazard == null
		or steam_animation == null
		or traverse_vent == null
		or hatch == null
		or lift == null
		or route_label == null
		or not factory.has_method(
			"get_factory_lower_deck_forward_pressure_counter_ambush_diagnostics"
		)
	):
		return

	var before: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_counter_ambush_diagnostics"
	)
	var activation_x: float = float(before.get("activation_x", 0.0))
	assert_float(activation_x).is_equal(1336.0)
	assert_bool(bool(before.get("available", false))).is_true()
	assert_bool(bool(before.get("active", true))).is_false()
	assert_bool(bool(before.get("defeated", true))).is_false()
	assert_bool(bool(before.get("enemy_visible", true))).is_false()
	assert_bool(bool(before.get("hazard_active", true))).is_false()
	assert_bool(bool(before.get("hazard_visible", true))).is_false()
	assert_bool(traverse_vent.visible).is_false()
	assert_that(route_label.get_parent()).is_instanceof(CanvasLayer)
	assert_str(route_label.text).is_equal("Forward Pressure Traverse Crossed")
	var reward_before: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_reward_cache_diagnostics"
	)
	assert_bool(bool(reward_before.get("visible", true))).is_false()
	assert_bool(bool(reward_before.get("claim_available", true))).is_false()

	var start_x: float = activation_x - 36.0
	player.global_position = Vector2(start_x, 456.0)
	player.velocity = Vector2.ZERO
	await get_tree().physics_frame
	Input.action_press(&"move_right")
	var crossed_boundary: bool = false
	for _frame: int in range(45):
		await get_tree().physics_frame
		crossed_boundary = crossed_boundary or player.global_position.x >= activation_x
		var current: Dictionary = factory.call(
			"get_factory_lower_deck_forward_pressure_counter_ambush_diagnostics"
		)
		if bool(current.get("active", false)):
			break
	Input.action_release(&"move_right")
	await get_tree().process_frame

	var active: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_counter_ambush_diagnostics"
	)
	assert_float(player.global_position.x).is_greater(start_x)
	assert_bool(crossed_boundary).is_true()
	assert_bool(bool(active.get("active", false))).override_failure_message(
		"Story191: real move_right crossed x=1336 but production movement did not activate entity 2119"
	).is_true()
	if not bool(active.get("active", false)):
		return
	assert_bool(bool(active.get("defeated", true))).is_false()
	assert_bool(bool(active.get("enemy_visible", false))).is_true()
	assert_bool(bool(active.get("enemy_has_target", false))).is_true()
	assert_bool(bool(active.get("enemy_physics_enabled", false))).is_true()
	assert_bool(bool(active.get("enemy_process_enabled", false))).is_true()
	assert_int(int(active.get("entity_id", 0))).is_equal(COUNTER_AMBUSH_ENTITY_ID)
	var frame_counts: Dictionary = active.get("animation_frame_counts", {}) as Dictionary
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		assert_int(int(frame_counts.get(String(animation_name), 0))).is_greater_equal(3)
	var pacing: Dictionary = active.get("pacing", {}) as Dictionary
	assert_str(String(pacing.get("pacing_state", ""))).is_equal("opening_grace")
	assert_int(int(pacing.get("opening_grace_frames", 0))).is_greater(0)
	assert_int(int(pacing.get("opening_grace_frames", 0))).is_less_equal(18)
	assert_int(int(pacing.get("opening_grace_total_frames", 0))).is_equal(18)
	assert_str(String(pacing.get("current_animation", ""))).is_equal("idle")
	assert_bool(bool(pacing.get("attack_active", true))).is_false()
	assert_bool(bool(active.get("hazard_active", true))).override_failure_message(
		"Story191: the counter vent must stay non-contacting during opening grace"
	).is_false()
	assert_int(int(active.get("hazard_grace_frames", 0))).is_greater(0)
	assert_int(int(active.get("hazard_grace_frames", 0))).is_less_equal(18)
	assert_bool(bool(active.get("hazard_visible", false))).is_true()
	assert_str(String(active.get("hazard_id", ""))).is_equal(
		COUNTER_AMBUSH_HAZARD_ID
	)
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
		"survive_forward_pressure_ambush"
	)
	assert_str(String(objective.get("route_label_text", ""))).is_equal(
		"Survive Forward Pressure Ambush"
	)
	assert_bool(route_label.visible).is_true()
	assert_str(route_label.text).is_equal("Survive Forward Pressure Ambush")
	assert_bool(bool(factory.call("get_local_state").get(
		"factory_lower_deck_forward_pressure_counter_ambush_activated",
		false
	))).is_true()

	var traverse: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_traverse_diagnostics"
	)
	assert_bool(bool(traverse.get("active", true))).is_false()
	assert_bool(bool(traverse.get("crossed", false))).is_true()
	assert_bool(bool(traverse.get("visible", true))).is_false()
	var reward: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_reward_cache_diagnostics"
	)
	assert_bool(bool(reward.get("available", true))).is_false()
	assert_bool(bool(reward.get("visible", true))).is_false()
	assert_bool(bool(reward.get("claim_available", true))).is_false()
	assert_bool(bool(reward.get("claimed", true))).is_false()
	assert_bool(bool(reward.get("claim_audio_requested", true))).is_false()
	assert_int(int(reward.get("claim_audio_request_count", -1))).is_equal(0)
	var exit_guard: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_exit_guard_diagnostics"
	)
	assert_bool(bool(exit_guard.get("available", true))).is_false()
	assert_bool(bool(exit_guard.get("active", true))).is_false()
	assert_bool(bool(exit_guard.get("enemy_visible", true))).is_false()
	assert_bool(bool(exit_guard.get("hazard_visible", true))).is_false()
	var lift_state: Dictionary = factory.call("get_factory_service_lift_diagnostics")
	assert_bool(bool(lift_state.get("available", false))).is_true()
	assert_bool(bool(lift_state.get("activated", true))).is_false()
	assert_bool(bool(lift_state.get("exit_requested", true))).is_false()
	assert_str(String(lift_state.get("prompt_text", ""))).is_equal("Call lift")


func test_production_boundary_is_inclusive_at_exact_counter_ambush_x() -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	for _frame: int in range(18):
		await get_tree().process_frame
	factory.call("set_local_state", _forward_pressure_traverse_crossed_state())

	var player := factory.get_node_or_null("Player") as CharacterBody2D
	assert_that(player).is_not_null()
	if player == null:
		return
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	player.global_position = Vector2(1335.999, 456.0)
	await get_tree().process_frame
	var below: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_counter_ambush_diagnostics"
	)
	assert_bool(bool(below.get("active", true))).is_false()

	player.global_position = Vector2(1336.0, 456.0)
	await get_tree().process_frame
	var exact: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_counter_ambush_diagnostics"
	)
	assert_bool(bool(exact.get("active", false))).override_failure_message(
		"Story191: production boundary must activate entity 2119 at exact x=1336"
	).is_true()
	assert_bool(bool(factory.call("get_local_state").get(
		"factory_lower_deck_forward_pressure_counter_ambush_activated",
		false
	))).is_true()


func test_counter_vent_becomes_damaging_after_grace_and_respects_cooldown() -> void:
	var factory: Node = _instantiate_factory_scene()
	assert_that(factory).is_not_null()
	if factory == null:
		return
	for _frame: int in range(18):
		await get_tree().process_frame
	factory.call("set_local_state", _forward_pressure_traverse_crossed_state())

	var player := factory.get_node_or_null("Player") as CharacterBody2D
	var hazard := factory.get_node_or_null(
		"FactoryLowerDeckForwardCounterPressureVent"
	) as Area2D
	assert_that(player).is_not_null()
	assert_that(hazard).is_not_null()
	if player == null or hazard == null:
		return
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	player.global_position = Vector2(1336.0, 456.0)
	await get_tree().process_frame

	var opening: Dictionary = factory.call(
		"get_factory_lower_deck_forward_pressure_counter_ambush_diagnostics"
	)
	var hp_before: int = int(player.call("get_current_hp"))
	assert_bool(bool(opening.get("active", false))).is_true()
	assert_bool(bool(opening.get("hazard_visible", false))).is_true()
	assert_bool(bool(opening.get("hazard_active", true))).override_failure_message(
		"Story191: the 18-frame opening grace must prevent unavoidable vent damage"
	).is_false()
	assert_int(int(opening.get("hazard_grace_frames", 0))).is_greater(0)
	assert_bool(bool(factory.call(
		"apply_factory_steam_vent_contact",
		hazard,
		player
	))).is_false()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before)

	player.global_position = Vector2(1600.0, 456.0)
	var live: Dictionary = opening
	for _frame: int in range(18):
		await get_tree().process_frame
		live = factory.call(
			"get_factory_lower_deck_forward_pressure_counter_ambush_diagnostics"
		)
		if bool(live.get("hazard_active", false)):
			break
	assert_int(int(live.get("hazard_grace_frames", -1))).is_equal(0)
	assert_bool(bool(live.get("hazard_active", false))).override_failure_message(
		"Story191: the counter vent must become live when opening grace expires"
	).is_true()

	assert_bool(bool(factory.call(
		"apply_factory_steam_vent_contact",
		hazard,
		player
	))).override_failure_message(
		"Story191: the live counter vent must be accepted by Factory hazard damage"
	).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - 8)
	assert_bool(bool(factory.call(
		"apply_factory_steam_vent_contact",
		hazard,
		player
	))).is_false()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - 8)

	factory.call("advance_factory_hazard_time", 0.99)
	assert_bool(bool(factory.call(
		"apply_factory_steam_vent_contact",
		hazard,
		player
	))).is_false()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - 8)
	factory.call("advance_factory_hazard_time", 0.01)
	assert_bool(bool(factory.call(
		"apply_factory_steam_vent_contact",
		hazard,
		player
	))).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(hp_before - 16)
	var last_damage: Dictionary = factory.call("get_local_state").get(
		"last_hazard_damage",
		{}
	) as Dictionary
	assert_str(String(last_damage.get("source", ""))).is_equal(COUNTER_AMBUSH_HAZARD_ID)


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


func _forward_pressure_traverse_crossed_state() -> Dictionary:
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
		"factory_lower_deck_forward_pressure_traverse_crossed": true,
		"factory_lower_deck_forward_pressure_counter_ambush_activated": false,
		"factory_lower_deck_forward_pressure_counter_ambush_defeated": false,
		"factory_lower_deck_forward_pressure_reward_cache_claimed": false,
		"factory_lower_deck_forward_pressure_exit_guard_activated": false,
		"factory_lower_deck_forward_pressure_exit_guard_defeated": false,
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
