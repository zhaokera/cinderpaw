extends SceneTree


const FACTORY_SCENE := "res://scenes/factory_route_transition_shell.tscn"
const ATTACK_ACTION: StringName = &"attack"
const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const FRAME_COUNT := 180
const TAILRACE_COIL_RAT_ENTITY_ID := 2143
const PLAYER_LIGHT_HITBOX_ID: StringName = &"cat_claw_light"
const TAILRACE_COIL_RAT: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceCoilRat"
)
const AMBUSH_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_diagnostics"
)
const RELAY_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_diagnostics"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(FACTORY_SCENE) as PackedScene
	if packed == null:
		push_error("Failed to load factory route transition shell")
		quit(1)
		return

	var scene := packed.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame

	for method_name: String in [AMBUSH_DIAGNOSTICS, RELAY_DIAGNOSTICS]:
		if not scene.has_method(method_name):
			_fail(scene, "Factory scene missing tailrace method: %s" % method_name)
			return

	scene.set_process(false)
	scene.call("set_local_state", _tailrace_ambush_ready_state())

	var player := scene.get_node_or_null("Player") as PlayerController
	var coil := scene.get_node_or_null(TAILRACE_COIL_RAT) as CharacterBody2D
	if player == null or coil == null:
		_fail(scene, "Factory scene missing Player or tailrace Coil Rat")
		return
	var coil_collision := coil.call("get_collision_component") as CollisionComponent
	if coil_collision == null:
		_fail(scene, "Tailrace Coil Rat missing CollisionComponent")
		return

	var waiting: Dictionary = scene.call(AMBUSH_DIAGNOSTICS)
	if not bool(waiting.get("available", false)):
		_fail(scene, "Tailrace ambush is not available after Story117")
		return
	if bool(waiting.get("active", true)) or bool(waiting.get("coil_visible", true)):
		_fail(scene, "Tailrace Coil Rat is active before production movement")
		return

	var activation_x: float = float(waiting.get("activation_x", 0.0))
	player.global_position = Vector2(activation_x - 12.0, 482.0)
	player.velocity = Vector2.ZERO
	scene.call("_process", 0.0)
	var start_x: float = player.global_position.x

	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(24):
		await physics_frame
		scene.call("_process", 0.0)
		waiting = scene.call(AMBUSH_DIAGNOSTICS)
		if bool(waiting.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO

	var active: Dictionary = scene.call(AMBUSH_DIAGNOSTICS)
	if player.global_position.x <= start_x:
		_fail(scene, "move_right did not move Player across the activation line")
		return
	if not bool(active.get("active", false)):
		_fail(scene, "Production move_right did not activate tailrace entity 2143")
		return
	if int(active.get("coil_entity_id", 0)) != TAILRACE_COIL_RAT_ENTITY_ID:
		_fail(scene, "Tailrace Coil Rat entity id mismatch")
		return
	if not bool(active.get("coil_visible", false)):
		_fail(scene, "Tailrace Coil Rat is hidden after production activation")
		return
	if not bool(active.get("coil_has_target", false)):
		_fail(scene, "Tailrace Coil Rat has no target after activation")
		return
	if int(coil.call("get_current_hp")) != 24:
		_fail(scene, "Tailrace Coil Rat did not start at 24 HP")
		return

	if not bool(scene.call(
		"apply_damage",
		TAILRACE_COIL_RAT_ENTITY_ID,
		12,
		{"source": &"story229_smoke_nonlethal_setup"}
	)):
		_fail(scene, "Tailrace Coil Rat nonlethal setup damage failed")
		return
	if int(coil.call("get_current_hp")) != 12:
		_fail(scene, "Tailrace Coil Rat nonlethal setup did not leave 12 HP")
		return

	coil.set_physics_process(false)
	coil.global_position = Vector2(12920.0, 482.0)
	coil.velocity = Vector2.ZERO
	player.global_position = Vector2(12952.0, 482.0)
	player.velocity = Vector2.ZERO
	await _face_player_left(player)
	player.global_position = Vector2(12952.0, 482.0)
	player.velocity = Vector2.ZERO
	if not await _hit_with_real_attack_input(
		player,
		[coil_collision.get_hurtbox()]
	):
		_fail(scene, "Input.attack did not activate cat_claw_light against entity 2143")
		return

	var hit: Dictionary = scene.call("get_last_player_hit_metadata")
	if int(hit.get("target_id", 0)) != TAILRACE_COIL_RAT_ENTITY_ID:
		_fail(scene, "Production attack hit the wrong target")
		return
	if String(hit.get("attack_type", &"")) != "light":
		_fail(scene, "Production attack did not report a light attack")
		return
	if String(hit.get("hitbox_id", &"")) != String(PLAYER_LIGHT_HITBOX_ID):
		_fail(scene, "Production attack did not use cat_claw_light")
		return
	if not bool(hit.get("damage_was_applied", false)):
		_fail(scene, "Production attack damage was not applied")
		return
	if int(hit.get("damage_applied", 0)) != 12:
		_fail(scene, "Production attack did not apply exactly 12 damage")
		return

	await _wait_until_unpaused(30)
	await process_frame
	await process_frame
	scene.call("_process", 0.0)
	var cleared: Dictionary = scene.call(AMBUSH_DIAGNOSTICS)
	var relay: Dictionary = scene.call(RELAY_DIAGNOSTICS)
	var coil_sprite := coil.get_node_or_null("Sprite") as AnimatedSprite2D
	if not bool(cleared.get("cleared", false)):
		_fail(scene, "Tailrace ambush cleared flag missing after production attack")
		return
	if not bool(cleared.get("coil_visible", false)):
		_fail(scene, "Tailrace Coil Rat death animation is not visible")
		return
	if bool(cleared.get("coil_physics_enabled", true)):
		_fail(scene, "Tailrace Coil Rat physics remained active during death")
		return
	if bool(cleared.get("coil_has_target", true)):
		_fail(scene, "Tailrace Coil Rat retained its target during death")
		return
	if coil_sprite == null or String(coil_sprite.animation) != "death":
		_fail(scene, "Tailrace Coil Rat did not enter the death frame animation")
		return
	if String(coil_collision.get_hurtbox_state()) != String(
		CollisionComponent.HURTBOX_STATE_GONE
	):
		_fail(scene, "Tailrace Coil Rat hurtbox remained active during death")
		return
	if not bool(relay.get("available", false)):
		_fail(scene, "Story119 tailrace relay is unavailable after Story118")
		return
	if not bool(relay.get("visible", false)) or bool(relay.get("activated", true)):
		_fail(scene, "Story119 relay is not visible and waiting for player input")
		return
	if String(relay.get("route_label_text", "")) != "Repair Tailrace Relay":
		_fail(scene, "Story119 relay route label mismatch")
		return

	_release_gameplay_actions()
	for _frame: int in range(FRAME_COUNT):
		await process_frame

	var final_state: Dictionary = scene.call("get_local_state")
	relay = scene.call(RELAY_DIAGNOSTICS)
	if not bool(final_state.get(
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared",
		false
	)):
		_fail(scene, "Tailrace ambush cleared flag did not persist for 180 frames")
		return
	if not bool(relay.get("available", false)) or bool(relay.get("activated", true)):
		_fail(scene, "Story119 relay handoff did not remain stable for 180 frames")
		return

	print("story118_production_smoke=passed frames=%d" % FRAME_COUNT)
	_cleanup_and_quit(scene, 0)


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
		await physics_frame


func _wait_until_unpaused(max_frames: int) -> void:
	for _frame: int in range(max_frames):
		if not paused:
			return
		await process_frame


func _release_gameplay_actions() -> void:
	Input.action_release(ATTACK_ACTION)
	Input.action_release(MOVE_LEFT_ACTION)
	Input.action_release(MOVE_RIGHT_ACTION)


func _fail(scene: Node, message: String) -> void:
	push_error(message)
	_release_gameplay_actions()
	_cleanup_and_quit(scene, 1)


func _cleanup_and_quit(scene: Node, exit_code: int) -> void:
	_release_gameplay_actions()
	paused = false
	scene.queue_free()
	await process_frame
	quit(exit_code)
