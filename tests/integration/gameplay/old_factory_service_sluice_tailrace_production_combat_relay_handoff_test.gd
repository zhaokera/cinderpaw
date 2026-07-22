## Story229: production tailrace Coil Rat combat and relay handoff.
extends GdUnitTestSuite

const FACTORY_SCENE := preload("res://scenes/factory_route_transition_shell.tscn")
const ATTACK_ACTION: StringName = &"attack"
const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const TAILRACE_COIL_RAT_ENTITY_ID: int = 2143
const PLAYER_LIGHT_HITBOX_ID: StringName = &"cat_claw_light"
const TAILRACE_COIL_RAT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceCoilRat"
)
const AMBUSH_DIAGNOSTICS: String = (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
)
const RELAY_DIAGNOSTICS: String = (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_diagnostics"
)

var _spawned_nodes: Array[Node] = []


func before_test() -> void:
	_release_gameplay_actions()
	get_tree().paused = false


func after_test() -> void:
	_release_gameplay_actions()
	get_tree().paused = false
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_real_move_and_attack_clear_coil_rat_and_reveal_unactivated_tailrace_relay(
) -> void:
	var factory: Node = FACTORY_SCENE.instantiate()
	add_child(factory)
	_spawned_nodes.append(factory)
	await _wait_process_frames(2)
	factory.set_process(false)
	factory.call("set_local_state", _tailrace_ambush_ready_state())

	var player := factory.get_node_or_null("Player") as PlayerController
	var coil := factory.get_node_or_null(TAILRACE_COIL_RAT) as CharacterBody2D
	assert_that(player).is_not_null()
	assert_that(coil).is_not_null()
	if player == null or coil == null:
		return
	var coil_collision := coil.call("get_collision_component") as CollisionComponent
	assert_that(coil_collision).is_not_null()
	if coil_collision == null:
		return

	var waiting: Dictionary = factory.call(AMBUSH_DIAGNOSTICS)
	var activation_x: float = float(waiting.get("activation_x", 0.0))
	assert_bool(bool(waiting.get("available", false))).is_true()
	assert_bool(bool(waiting.get("active", true))).is_false()
	player.global_position = Vector2(activation_x - 12.0, 482.0)
	player.velocity = Vector2.ZERO
	factory.call("_process", 0.0)

	var start_x: float = player.global_position.x
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(24):
		await get_tree().physics_frame
		factory.call("_process", 0.0)
		waiting = factory.call(AMBUSH_DIAGNOSTICS)
		if bool(waiting.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO

	var active: Dictionary = factory.call(AMBUSH_DIAGNOSTICS)
	assert_float(player.global_position.x).is_greater(start_x)
	assert_bool(bool(active.get("active", false))).override_failure_message(
		"Story229 requires production move_right to activate entity 2143"
	).is_true()
	assert_int(int(active.get("coil_entity_id", 0))).is_equal(
		TAILRACE_COIL_RAT_ENTITY_ID
	)
	assert_bool(bool(active.get("coil_visible", false))).is_true()
	assert_bool(bool(active.get("coil_has_target", false))).is_true()
	assert_bool(bool(active.get("coil_process_enabled", false))).is_true()
	assert_bool(bool(active.get("coil_physics_enabled", false))).is_true()
	assert_int(int(coil.call("get_current_hp"))).is_equal(24)
	assert_str(String(coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_NORMAL)
	)

	assert_bool(bool(factory.call(
		"apply_damage",
		TAILRACE_COIL_RAT_ENTITY_ID,
		12,
		{"source": &"story229_nonlethal_setup"}
	))).is_true()
	assert_int(int(coil.call("get_current_hp"))).is_equal(12)

	coil.set_physics_process(false)
	coil.global_position = Vector2(12920.0, 482.0)
	coil.velocity = Vector2.ZERO
	player.global_position = Vector2(12952.0, 482.0)
	player.velocity = Vector2.ZERO
	await _face_player_left(player)
	player.global_position = Vector2(12952.0, 482.0)
	player.velocity = Vector2.ZERO
	assert_bool(await _hit_with_real_attack_input(
		player,
		[coil_collision.get_hurtbox()]
	)).override_failure_message(
		"Story229 requires Input.attack to finish tailrace entity 2143"
	).is_true()

	var hit: Dictionary = factory.call("get_last_player_hit_metadata")
	assert_int(int(hit.get("target_id", 0))).is_equal(TAILRACE_COIL_RAT_ENTITY_ID)
	assert_str(String(hit.get("attack_type", &""))).is_equal("light")
	assert_str(String(hit.get("hitbox_id", &""))).is_equal(
		String(PLAYER_LIGHT_HITBOX_ID)
	)
	assert_bool(bool(hit.get("damage_was_applied", false))).is_true()
	assert_int(int(hit.get("damage_applied", 0))).is_equal(12)
	assert_int(int(coil.call("get_current_hp"))).is_equal(0)

	await _wait_until_unpaused(30)
	await _wait_process_frames(2)
	factory.call("_process", 0.0)
	var cleared: Dictionary = factory.call(AMBUSH_DIAGNOSTICS)
	var relay: Dictionary = factory.call(RELAY_DIAGNOSTICS)
	assert_bool(bool(cleared.get("active", true))).is_false()
	assert_bool(bool(cleared.get("cleared", false))).is_true()
	assert_bool(bool(cleared.get("coil_visible", false))).is_true()
	assert_bool(bool(cleared.get("coil_process_enabled", false))).is_true()
	assert_bool(bool(cleared.get("coil_physics_enabled", true))).is_false()
	assert_bool(bool(cleared.get("coil_has_target", true))).is_false()
	assert_str(String((coil.get_node("Sprite") as AnimatedSprite2D).animation)).is_equal(
		"death"
	)
	assert_str(String(coil_collision.get_hurtbox_state())).is_equal(
		String(CollisionComponent.HURTBOX_STATE_GONE)
	)
	assert_int(coil.collision_layer).is_equal(0)
	assert_int(coil.collision_mask).is_equal(0)
	assert_bool(bool(relay.get("available", false))).override_failure_message(
		"Real move_right activation plus a real Input.attack lethal hit on entity 2143 "
		+ "must reveal the unactivated Story119 tailrace relay"
	).is_true()
	assert_bool(bool(relay.get("visible", false))).is_true()
	assert_bool(bool(relay.get("activated", true))).is_false()
	assert_str(String(relay.get("route_label_text", ""))).is_equal(
		"Repair Tailrace Relay"
	)

	var local_state: Dictionary = factory.call("get_local_state")
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_activated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_coil_rat_defeated",
		false
	))).is_true()
	assert_bool(bool(local_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared",
		false
	))).is_true()


func _hit_with_real_attack_input(
	player: PlayerController,
	candidates: Array[Area2D]
) -> bool:
	var combat: CombatComponent = player.get_combat_component()
	var player_collision: CollisionComponent = player.get_collision_component()
	if combat == null or player_collision == null:
		return false
	Input.action_press(ATTACK_ACTION)
	await _wait_physics_frames(2)
	Input.action_release(ATTACK_ACTION)
	var attack_frame_data: Dictionary = combat.get_light_attack_frame_data(
		combat.get_combo_index()
	)
	for _frame: int in range(int(attack_frame_data.get("total_frames", 0)) + 1):
		if player_collision.is_hitbox_active(PLAYER_LIGHT_HITBOX_ID):
			break
		combat.advance_attack_frames(1)
	if not player_collision.is_hitbox_active(PLAYER_LIGHT_HITBOX_ID):
		return false
	player_collision.process_detection_frame({
		PLAYER_LIGHT_HITBOX_ID: candidates,
	})
	return true


func _face_player_left(player: PlayerController) -> void:
	Input.action_press(MOVE_LEFT_ACTION)
	await _wait_physics_frames(2)
	Input.action_release(MOVE_LEFT_ACTION)
	player.velocity = Vector2.ZERO


func _tailrace_ambush_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_coil_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated": false,
	}


func _wait_physics_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().physics_frame


func _wait_process_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().process_frame


func _wait_until_unpaused(max_frames: int) -> void:
	for _frame: int in range(max_frames):
		if not get_tree().paused:
			return
		await get_tree().process_frame


func _release_gameplay_actions() -> void:
	Input.action_release(ATTACK_ACTION)
	Input.action_release(MOVE_LEFT_ACTION)
	Input.action_release(MOVE_RIGHT_ACTION)


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
