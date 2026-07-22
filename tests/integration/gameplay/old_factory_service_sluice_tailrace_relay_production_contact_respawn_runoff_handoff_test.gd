## Story230: production Tailrace Relay contact, respawn and runoff handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_GATE_ENTRY_SPAWN_POINT: StringName = &"factory_gate_entry"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const RELAY_ID: String = (
	"old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
)
const RELAY_SPAWN_POINT: String = (
	"lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay"
)
const RELAY_NODE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelaySavepoint"
)
const RELAY_DIAGNOSTICS: String = (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_diagnostics"
)
const RUNOFF_DIAGNOSTICS: String = (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_diagnostics"
)

var _spawned_nodes: Array[Node] = []


class FakeFactorySceneManager:
	extends RefCounted

	var current_scene: StringName = FACTORY_SCENE_ID
	var current_spawn_point: StringName = FACTORY_GATE_ENTRY_SPAWN_POINT
	var pending_scene: StringName = &""
	var pending_spawn_point: StringName = &""
	var loading: bool = false
	var request_calls: Array[Dictionary] = []

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == FACTORY_SCENE_ID or scene_id == &"main"

	func request_scene_change(
		scene_id: StringName,
		spawn_point: StringName = &"default"
	) -> bool:
		request_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		if not has_scene(scene_id):
			return false
		pending_scene = scene_id
		pending_spawn_point = spawn_point
		loading = true
		return true

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn_point

	func get_pending_scene() -> StringName:
		return pending_scene

	func get_pending_spawn_point() -> StringName:
		return pending_spawn_point

	func is_loading() -> bool:
		return loading


func before_test() -> void:
	Input.action_release(MOVE_RIGHT_ACTION)
	get_tree().paused = false


func after_test() -> void:
	Input.action_release(MOVE_RIGHT_ACTION)
	get_tree().paused = false
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_real_contact_secures_relay_respawns_and_leaves_runoff_waiting(
) -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.call("set_local_state", _relay_ready_state())
	var scene_manager := FakeFactorySceneManager.new()
	assert_bool(bool(factory.call(
		"configure_scene_manager_runtime",
		scene_manager
	))).is_true()

	var player := factory.get_node_or_null("Player") as PlayerController
	var relay := factory.get_node_or_null(RELAY_NODE) as Node2D
	var interaction_area := relay.get_node_or_null("InteractionArea") as Area2D
	var prompt := relay.get_node_or_null("PromptLabel") as Label
	assert_that(player).is_not_null()
	assert_that(relay).is_not_null()
	assert_that(interaction_area).is_not_null()
	assert_that(prompt).is_not_null()
	if player == null or relay == null or interaction_area == null or prompt == null:
		return

	player.global_position = Vector2(relay.global_position.x - 176.0, 482.0)
	player.velocity = Vector2.ZERO
	await _wait_physics_frames(2)
	var waiting: Dictionary = factory.call(RELAY_DIAGNOSTICS)
	assert_bool(bool(waiting.get("available", false))).is_true()
	assert_bool(bool(waiting.get("visible", false))).is_true()
	assert_bool(bool(waiting.get("activated", true))).is_false()
	assert_bool(bool(waiting.get("interaction_monitoring", false))).is_true()
	assert_bool(interaction_area.get_overlapping_bodies().has(player)).is_false()
	assert_bool(prompt.visible).is_true()
	var initial_vfx: Dictionary = relay.call("get_activation_vfx_snapshot")
	assert_int(int(initial_vfx.get("spawn_count", -1))).is_equal(0)
	var locked_runoff: Dictionary = factory.call(RUNOFF_DIAGNOSTICS)
	assert_bool(bool(locked_runoff.get("available", true))).is_false()
	assert_bool(bool(locked_runoff.get("visible", true))).is_false()
	assert_bool(bool(locked_runoff.get("active", true))).is_false()

	var start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(60):
		await get_tree().physics_frame
		await get_tree().process_frame
		var current: Dictionary = factory.call(RELAY_DIAGNOSTICS)
		if bool(current.get("activated", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	await get_tree().process_frame

	var activated: Dictionary = factory.call(RELAY_DIAGNOSTICS)
	assert_float(player.global_position.x - start_x).is_greater_equal(40.0)
	assert_bool(bool(activated.get("activated", false))).override_failure_message(
		"Story230 requires SavepointRuntime body_entered activation from real movement"
	).is_true()
	assert_bool(bool(activated.get("interaction_monitoring", true))).is_false()
	assert_bool(bool(activated.get("collision_disabled", false))).is_true()
	assert_bool(prompt.visible).is_false()
	assert_str(String(activated.get("route_label_text", ""))).is_equal(
		"Tailrace Relay Secured"
	)
	var activated_vfx: Dictionary = relay.call("get_activation_vfx_snapshot")
	assert_int(int(activated_vfx.get("spawn_count", 0))).is_equal(1)
	var last_savepoint: Dictionary = Dictionary(activated.get("last_savepoint", {}))
	assert_str(String(last_savepoint.get("id", ""))).is_equal(RELAY_ID)
	assert_str(String(last_savepoint.get("scene_id", ""))).is_equal(
		String(FACTORY_SCENE_ID)
	)
	assert_str(String(last_savepoint.get("spawn_point", ""))).is_equal(
		RELAY_SPAWN_POINT
	)

	var ready_runoff: Dictionary = factory.call(RUNOFF_DIAGNOSTICS)
	assert_bool(bool(ready_runoff.get("available", false))).is_true()
	assert_bool(bool(ready_runoff.get("visible", false))).is_true()
	assert_bool(bool(ready_runoff.get("active", true))).is_false()
	assert_str(String(ready_runoff.get("phase", ""))).is_equal("idle")
	assert_bool(bool(ready_runoff.get("hazard_contact_active", true))).is_false()

	var runoff_activation_x: float = float(ready_runoff.get("activation_x", 0.0))
	factory.call("_process", 0.0)
	player.global_position = Vector2(runoff_activation_x + 4.0, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	var stationary_runoff: Dictionary = factory.call(RUNOFF_DIAGNOSTICS)
	var runoff_started_without_input: bool = bool(stationary_runoff.get("active", false))
	assert_bool(runoff_started_without_input).override_failure_message(
		"Story120 must require fresh positive-x movement after the relay handoff"
	).is_false()
	if runoff_started_without_input:
		return

	player.global_position = Vector2(relay.global_position.x, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)
	var max_hp: int = player.get_max_hp()
	player.apply_damage(max_hp, {
		"source": &"story230_production_lethal_probe",
		"damage_type": &"lethal_probe",
	})
	var sprite := player.get_node_or_null("Sprite") as AnimatedSprite2D
	assert_that(sprite).is_not_null()
	if sprite == null:
		return
	assert_str(String(sprite.animation)).is_equal("death")
	assert_str(String(factory.call(
		"get_factory_respawn_flow_diagnostics"
	).get("state", ""))).is_equal("dying")

	factory.call("advance_factory_respawn_flow", 1.51)
	assert_int(scene_manager.request_calls.size()).is_equal(1)
	assert_str(String(scene_manager.request_calls[0].get("scene_id", ""))).is_equal(
		String(FACTORY_SCENE_ID)
	)
	assert_str(String(scene_manager.request_calls[0].get("spawn_point", ""))).is_equal(
		RELAY_SPAWN_POINT
	)
	assert_str(String(scene_manager.get_pending_spawn_point())).is_equal(
		RELAY_SPAWN_POINT
	)
	assert_float(player.global_position.distance_to(relay.global_position)).is_less_equal(1.0)
	assert_int(player.get_current_hp()).is_equal(maxi(1, int(round(max_hp * 0.5))))
	assert_str(String(sprite.animation)).is_equal("revive")
	assert_bool(player.is_respawn_visual_active()).is_true()
	var respawn_flow: Dictionary = factory.call("get_factory_respawn_flow_diagnostics")
	assert_str(String(respawn_flow.get("state", ""))).is_equal("revived")
	assert_bool(bool(respawn_flow.get("control_locked", false))).is_true()
	assert_str(String(factory.call(
		"get_factory_route_objective_diagnostics"
	).get("route_label_text", ""))).is_equal("Returned to Tailrace Relay")

	var respawn_runoff: Dictionary = factory.call(RUNOFF_DIAGNOSTICS)
	assert_bool(bool(respawn_runoff.get("available", false))).is_true()
	assert_bool(bool(respawn_runoff.get("visible", false))).is_true()
	assert_bool(bool(respawn_runoff.get("active", true))).is_false()
	assert_bool(bool(respawn_runoff.get("crossed", true))).is_false()
	assert_bool(bool(respawn_runoff.get("hazard_contact_active", true))).is_false()
	assert_int(int(relay.call(
		"get_activation_vfx_snapshot"
	).get("spawn_count", 0))).is_equal(1)

	var local_state: Dictionary = factory.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_activated",
		true
	))).is_false()

	factory.call("advance_factory_respawn_flow", 2.01)
	respawn_flow = factory.call("get_factory_respawn_flow_diagnostics")
	assert_str(String(respawn_flow.get("state", ""))).is_equal("playing")
	assert_bool(bool(respawn_flow.get("control_locked", true))).is_false()


func _relay_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_crossed": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
	}


func _wait_physics_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().physics_frame


func _wait_process_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().process_frame


func _stop_runtime_audio_players() -> void:
	for audio_player: AudioStreamPlayer in _find_nodes_of_type(
		get_tree().root,
		AudioStreamPlayer
	):
		audio_player.stop()
	for audio_player_2d: AudioStreamPlayer2D in _find_nodes_of_type(
		get_tree().root,
		AudioStreamPlayer2D
	):
		audio_player_2d.stop()


func _find_nodes_of_type(root: Node, expected_type: Variant) -> Array[Node]:
	var matches: Array[Node] = []
	if is_instance_of(root, expected_type):
		matches.append(root)
	for child: Node in root.get_children():
		matches.append_array(_find_nodes_of_type(child, expected_type))
	return matches
