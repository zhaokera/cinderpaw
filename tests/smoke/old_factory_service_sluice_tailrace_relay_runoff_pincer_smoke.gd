extends SceneTree


const FACTORY_SCENE := "res://scenes/factory_route_transition_shell.tscn"
const ATTACK_ACTION: StringName = &"attack"
const INTERACT_ACTION: StringName = &"interact"
const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const FRAME_COUNT := 180
const PINCER_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_diagnostics"
)
const CACHE_DIAGNOSTICS := (
	"get_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_diagnostics"
)
const PINCER_SPARK: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerSparkRat"
)
const PINCER_COIL: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerCoilRat"
)
const PINCER_CACHE: NodePath = (
	^"FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerRewardCache"
)
const PINCER_SPARK_ENTITY_ID := 2144
const PINCER_COIL_ENTITY_ID := 2145
const PLAYER_LIGHT_HITBOX_ID: StringName = &"cat_claw_light"


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
	scene.set_process(false)
	for method_name: String in [PINCER_DIAGNOSTICS, CACHE_DIAGNOSTICS]:
		if not scene.has_method(method_name):
			_fail(scene, "Factory scene missing Story121/122 diagnostics")
			return
	scene.call("set_local_state", _pincer_ready_state())

	var player := scene.get_node_or_null("Player") as PlayerController
	var spark := scene.get_node_or_null(PINCER_SPARK) as CharacterBody2D
	var coil := scene.get_node_or_null(PINCER_COIL) as CharacterBody2D
	var cache := scene.get_node_or_null(PINCER_CACHE) as Node2D
	if player == null or spark == null or coil == null or cache == null:
		_fail(scene, "Factory scene missing Story121/122 runtime nodes")
		return
	var spark_collision := spark.call("get_collision_component") as CollisionComponent
	var coil_collision := coil.call("get_collision_component") as CollisionComponent
	if spark_collision == null or coil_collision == null:
		_fail(scene, "Story121 enemies are missing CollisionComponent")
		return

	var diagnostics: Dictionary = scene.call(PINCER_DIAGNOSTICS)
	var activation_x: float = float(diagnostics.get("activation_x", 0.0))
	player.set_physics_process(false)
	player.global_position = Vector2(activation_x - 8.0, 482.0)
	player.velocity = Vector2.ZERO
	scene.call("_process", 0.0)
	player.set_physics_process(true)
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(24):
		await physics_frame
		scene.call("_process", 0.0)
		diagnostics = scene.call(PINCER_DIAGNOSTICS)
		if bool(diagnostics.get("active", false)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO
	if not bool(diagnostics.get("active", false)):
		_fail(scene, "Real move_right did not activate Story121")
		return
	if (
		not bool(diagnostics.get("spark_visible", false))
		or not bool(diagnostics.get("coil_visible", false))
		or not bool(diagnostics.get("spark_has_target", false))
		or not bool(diagnostics.get("coil_has_target", false))
	):
		_fail(scene, "Story121 did not establish the dual-enemy pincer")
		return
	if not (cache.z_index < spark.z_index and spark.z_index < player.z_index):
		_fail(scene, "Spark Rat z-order does not preserve death readability")
		return
	if not (cache.z_index < coil.z_index and coil.z_index < player.z_index):
		_fail(scene, "Coil Rat z-order does not preserve death readability")
		return

	spark.set_physics_process(false)
	coil.set_physics_process(false)
	if not bool(scene.call("apply_damage", PINCER_SPARK_ENTITY_ID, 12, {
		"source": &"story232_smoke_spark_setup",
	})):
		_fail(scene, "Spark Rat nonlethal setup failed")
		return
	spark.global_position = Vector2(14960.0, 482.0)
	spark.velocity = Vector2.ZERO
	player.global_position = Vector2(14928.0, 482.0)
	player.velocity = Vector2.ZERO
	await _face_player_right(player)
	player.global_position = Vector2(14928.0, 482.0)
	player.velocity = Vector2.ZERO
	if not await _hit_with_real_attack_input(
		player,
		[spark_collision.get_hurtbox()]
	):
		_fail(scene, "Real Input.attack did not finish Spark Rat 2144")
		return
	if not _light_hit_matches(
		scene.call("get_last_player_hit_metadata"),
		PINCER_SPARK_ENTITY_ID,
		1
	):
		_fail(scene, "Spark Rat shared-hit metadata mismatch")
		return
	await _wait_until_unpaused(30)
	if not await _observe_three_frame_death(scene, spark):
		_fail(scene, "Spark Rat did not visibly play death frames 0/1/2")
		return
	await _finish_current_attack(player)
	scene.call("_process", 0.0)
	diagnostics = scene.call(PINCER_DIAGNOSTICS)
	var locked_cache: Dictionary = scene.call(CACHE_DIAGNOSTICS)
	if (
		bool(diagnostics.get("cleared", true))
		or not bool(diagnostics.get("spark_defeated", false))
		or bool(diagnostics.get("coil_defeated", true))
		or not bool(diagnostics.get("spark_visible", false))
		or bool(diagnostics.get("spark_physics_enabled", true))
		or bool(diagnostics.get("spark_has_target", true))
	):
		_fail(scene, "Spark Rat partial-clear live death contract failed")
		return
	if bool(locked_cache.get("available", true)) or bool(locked_cache.get("visible", true)):
		_fail(scene, "Story122 appeared before both enemies were defeated")
		return

	if not bool(scene.call("apply_damage", PINCER_COIL_ENTITY_ID, 12, {
		"source": &"story232_smoke_coil_setup",
	})):
		_fail(scene, "Coil Rat nonlethal setup failed")
		return
	coil.global_position = Vector2(15428.0, 482.0)
	coil.velocity = Vector2.ZERO
	player.global_position = Vector2(15460.0, 482.0)
	player.velocity = Vector2.ZERO
	await _face_player_left(player)
	player.global_position = Vector2(15460.0, 482.0)
	player.velocity = Vector2.ZERO
	Input.action_press(INTERACT_ACTION)
	scene.call("_process", 0.0)
	if not await _hit_with_real_attack_input(
		player,
		[coil_collision.get_hurtbox()]
	):
		_fail(scene, "Real Input.attack did not finish Coil Rat 2145")
		return
	if not _light_hit_matches(
		scene.call("get_last_player_hit_metadata"),
		PINCER_COIL_ENTITY_ID,
		-1
	):
		_fail(scene, "Coil Rat shared-hit metadata mismatch")
		return
	await _wait_until_unpaused(30)
	if not await _observe_three_frame_death(scene, coil):
		_fail(scene, "Coil Rat did not visibly play death frames 0/1/2")
		return
	for _frame: int in range(3):
		scene.call("_process", 0.0)
	Input.action_release(INTERACT_ACTION)
	diagnostics = scene.call(PINCER_DIAGNOSTICS)
	var available_cache: Dictionary = scene.call(CACHE_DIAGNOSTICS)
	if not bool(diagnostics.get("cleared", false)):
		_fail(scene, "Story121 did not clear after both production attacks")
		return
	if (
		not bool(diagnostics.get("coil_visible", false))
		or bool(diagnostics.get("coil_physics_enabled", true))
		or bool(diagnostics.get("coil_has_target", true))
	):
		_fail(scene, "Coil Rat full-clear live death contract failed")
		return
	if (
		not bool(available_cache.get("available", false))
		or not bool(available_cache.get("visible", false))
		or not bool(available_cache.get("claim_available", false))
		or bool(available_cache.get("claimed", true))
	):
		_fail(scene, "Story122 did not enter the unclaimed reward handoff")
		return

	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	_release_gameplay_actions()
	for _frame: int in range(FRAME_COUNT):
		scene.call("_process", 1.0 / 60.0)
		await process_frame

	available_cache = scene.call(CACHE_DIAGNOSTICS)
	if bool(available_cache.get("claimed", true)):
		_fail(scene, "Story122 was claimed during the 180-frame handoff")
		return
	if not (available_cache.get("last_reward", {}) as Dictionary).is_empty():
		_fail(scene, "Story122 produced a reward without fresh interact")
		return
	if not (available_cache.get("last_claim_feedback", {}) as Dictionary).is_empty():
		_fail(scene, "Story122 produced claim feedback without fresh interact")
		return

	print("story121_production_smoke=passed frames=%d" % FRAME_COUNT)
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
	var frame_data: Dictionary = combat.get_light_attack_frame_data(
		combat.get_combo_index()
	)
	for _frame: int in range(int(frame_data.get("total_frames", 0)) + 1):
		if player_collision.is_hitbox_active(PLAYER_LIGHT_HITBOX_ID):
			break
		combat.advance_attack_frames(1)
	if not player_collision.is_hitbox_active(PLAYER_LIGHT_HITBOX_ID):
		return false
	player_collision.process_detection_frame({
		PLAYER_LIGHT_HITBOX_ID: candidates,
	})
	return true


func _light_hit_matches(
	hit: Dictionary,
	expected_target_id: int,
	expected_facing: int
) -> bool:
	return (
		int(hit.get("attacker_id", 0)) == 1
		and int(hit.get("target_id", 0)) == expected_target_id
		and String(hit.get("weapon_id", "")) == "cat_claw"
		and String(hit.get("attack_type", "")) == "light"
		and String(hit.get("hitbox_id", "")) == String(PLAYER_LIGHT_HITBOX_ID)
		and int(hit.get("facing", 0)) == expected_facing
		and int(hit.get("final_damage", 0)) == 12
		and int(hit.get("damage_applied", 0)) == 12
		and bool(hit.get("damage_was_applied", false))
	)


func _observe_three_frame_death(scene: Node, enemy: CharacterBody2D) -> bool:
	var sprite := enemy.get_node_or_null("Sprite") as AnimatedSprite2D
	if sprite == null or sprite.sprite_frames == null:
		return false
	var seen_frames: Dictionary = {}
	for _frame: int in range(50):
		if String(sprite.animation) == "death":
			seen_frames[sprite.frame] = true
		if seen_frames.has(0) and seen_frames.has(1) and seen_frames.has(2):
			return true
		scene.call("_process", 0.0)
		await process_frame
	return false


func _finish_current_attack(player: PlayerController) -> void:
	var combat: CombatComponent = player.get_combat_component()
	if combat == null:
		return
	var frame_data: Dictionary = combat.get_light_attack_frame_data(
		combat.get_combo_index()
	)
	var total_frames: int = int(frame_data.get("total_frames", 0))
	combat.advance_attack_frames(total_frames + 1)
	for _frame: int in range(total_frames + 2):
		await physics_frame
		if not bool(player.get_light_combo_diagnostics().get("active", false)):
			return


func _face_player_left(player: PlayerController) -> void:
	Input.action_press(MOVE_LEFT_ACTION)
	await _wait_physics_frames(2)
	Input.action_release(MOVE_LEFT_ACTION)
	player.velocity = Vector2.ZERO


func _face_player_right(player: PlayerController) -> void:
	Input.action_press(MOVE_RIGHT_ACTION)
	await _wait_physics_frames(2)
	Input.action_release(MOVE_RIGHT_ACTION)
	player.velocity = Vector2.ZERO


func _pincer_ready_state() -> Dictionary:
	return {
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_cleared": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_activated": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_crossed": true,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_activated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_spark_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_coil_rat_defeated": false,
		"factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_claimed": false,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
	}


func _wait_physics_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await physics_frame


func _wait_until_unpaused(max_frames: int) -> void:
	for _frame: int in range(max_frames):
		if not paused:
			return
		await process_frame


func _fail(scene: Node, message: String) -> void:
	push_error(message)
	_release_gameplay_actions()
	_cleanup_and_quit(scene, 1)


func _release_gameplay_actions() -> void:
	Input.action_release(ATTACK_ACTION)
	Input.action_release(INTERACT_ACTION)
	Input.action_release(MOVE_LEFT_ACTION)
	Input.action_release(MOVE_RIGHT_ACTION)


func _cleanup_and_quit(scene: Node, exit_code: int) -> void:
	_release_gameplay_actions()
	paused = false
	scene.queue_free()
	await process_frame
	quit(exit_code)
