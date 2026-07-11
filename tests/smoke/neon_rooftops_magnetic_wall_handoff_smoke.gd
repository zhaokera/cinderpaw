extends SceneTree

const UPPER_SCENE_PATH: String = (
	"res://scenes/areas/factory_upper_altar_approach.tscn"
)
const UPPER_SCENE_ID: StringName = &"area_03_factory_upper_altar"
const ROOFTOPS_SCENE_ID: StringName = &"area_05_neon_rooftops"
const ROOFTOPS_ARRIVAL: StringName = &"factory_rooftop_arrival"
const FACTORY_RETURN_SPAWN: StringName = &"neon_rooftops_return"
const MAX_TRANSITION_STEPS: int = 64


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene_manager: Node = root.get_node_or_null("SceneManager")
	if scene_manager == null:
		_fail("scene_manager_missing")
		return
	var packed_upper: PackedScene = load(UPPER_SCENE_PATH) as PackedScene
	if packed_upper == null:
		_fail("factory_upper_scene_missing")
		return
	var runtime_root := Node.new()
	runtime_root.name = "Story136RuntimeRoot"
	root.add_child(runtime_root)
	var upper: Node = packed_upper.instantiate()
	runtime_root.add_child(upper)
	if not bool(scene_manager.call(
		"configure_runtime_scene_root",
		runtime_root,
		upper
	)):
		_fail("runtime_root_configuration_failed")
		return
	if not bool(scene_manager.call(
		"change_scene",
		UPPER_SCENE_ID,
		&"cistern_ascender_arrival"
	)):
		_fail("factory_upper_logical_scene_setup_failed")
		return
	upper.call("configure_scene_manager_runtime", scene_manager)
	upper.call("set_local_state", {
		"factory_upper_hidden_altar_discovered": true,
		"factory_upper_wall_climb_reward_claimed": true,
		"factory_upper_wall_climb_route_proven": true,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb",
		],
	})
	await process_frame

	var upper_player: Node2D = upper.get_node_or_null("Player") as Node2D
	var rooftop_route: Node2D = upper.get_node_or_null(
		"NeonRooftopsRoute"
	) as Node2D
	if upper_player == null or rooftop_route == null:
		_fail("factory_upper_player_or_route_missing")
		return
	upper_player.global_position = rooftop_route.global_position
	if not bool(upper.call("try_request_neon_rooftops", upper_player)):
		_fail("factory_to_rooftops_request_failed")
		return
	if not await _advance_until_scene(scene_manager, ROOFTOPS_SCENE_ID):
		_fail("rooftops_transition_timeout")
		return

	var rooftops: Node = scene_manager.call("get_current_runtime_scene_node") as Node
	if rooftops == null or not rooftops.has_method(
		"get_neon_rooftops_entry_diagnostics"
	):
		_fail("rooftops_runtime_scene_missing")
		return
	if String(scene_manager.call("get_current_spawn_point")) != String(
		ROOFTOPS_ARRIVAL
	):
		_fail("rooftops_spawn_id_mismatch")
		return
	var rooftop_player: CharacterBody2D = rooftops.get_node_or_null(
		"Player"
	) as CharacterBody2D
	if rooftop_player == null:
		_fail("rooftop_player_missing")
		return
	var arrival: Marker2D = rooftops.get_node_or_null(
		"FactoryRooftopArrival"
	) as Marker2D
	if arrival == null or rooftop_player.global_position.distance_to(
		arrival.global_position
	) > 0.5:
		_fail("rooftop_arrival_position_mismatch")
		return

	rooftop_player.global_position = Vector2(838.0, 500.0)
	rooftop_player.velocity = Vector2.ZERO
	Input.action_press("move_right")
	Input.action_press("move_up")
	var climb_started: bool = false
	var climb_start_y: float = rooftop_player.global_position.y
	for _frame: int in range(150):
		await physics_frame
		var wall_state: Dictionary = rooftop_player.call(
			"get_wall_climb_diagnostics"
		)
		if bool(wall_state.get("active", false)):
			if not climb_started:
				climb_started = true
				climb_start_y = rooftop_player.global_position.y
			if rooftop_player.global_position.y < 178.0:
				break
	Input.action_release("move_right")
	Input.action_release("move_up")
	if not climb_started:
		_fail("real_wall_contact_never_started_climb")
		return
	if rooftop_player.global_position.y >= climb_start_y - 80.0:
		_fail("wall_climb_did_not_gain_rooftop_height")
		return
	var active_state: Dictionary = rooftop_player.call(
		"get_wall_climb_diagnostics"
	)
	if String(active_state.get("animation", "")) != "wall_climb":
		_fail("wall_climb_animation_missing")
		return
	if not bool(rooftop_player.call("request_wall_jump")):
		_fail("rooftop_wall_jump_failed")
		return
	for _frame: int in range(10):
		await physics_frame
	Input.action_press("move_right")
	var route_proven: bool = false
	for _frame: int in range(180):
		await physics_frame
		var diagnostics: Dictionary = rooftops.call(
			"get_neon_rooftops_entry_diagnostics"
		)
		if bool(diagnostics.get("entry_traversed", false)):
			route_proven = true
			break
	Input.action_release("move_right")
	if not route_proven:
		_fail("physical_rooftop_route_not_proven")
		return
	var proven: Dictionary = rooftops.call(
		"get_neon_rooftops_entry_diagnostics"
	)
	if String(proven.get("objective_text", "")) != "Neon Rooftops Reached" \
			or int(proven.get("wall_contact_feedback_count", 0)) < 1 \
			or int(proven.get("audio_request_count", 0)) < 2:
		_fail("rooftop_feedback_audio_or_objective_failed")
		return

	var return_route: Node2D = rooftops.get_node_or_null(
		"FactoryReturnRoute"
	) as Node2D
	if return_route == null:
		_fail("factory_return_route_missing")
		return
	rooftop_player.global_position = return_route.global_position
	rooftop_player.velocity = Vector2.ZERO
	if not bool(rooftops.call(
		"try_request_factory_return",
		rooftop_player
	)):
		_fail("rooftops_to_factory_request_failed")
		return
	if not await _advance_until_scene(scene_manager, UPPER_SCENE_ID):
		_fail("factory_return_timeout")
		return

	var restored_upper: Node = scene_manager.call(
		"get_current_runtime_scene_node"
	) as Node
	if restored_upper == null or not restored_upper.has_method(
		"get_factory_upper_altar_diagnostics"
	):
		_fail("restored_factory_upper_missing")
		return
	if String(scene_manager.call("get_current_spawn_point")) != String(
		FACTORY_RETURN_SPAWN
	):
		_fail("factory_return_spawn_id_mismatch")
		return
	var restored: Dictionary = restored_upper.call(
		"get_factory_upper_altar_diagnostics"
	)
	if not bool(restored.get("neon_route_opened", false)) \
			or bool(restored.get("neon_transition_requested", true)) \
			or not Array(restored.get("unlocked_abilities", [])).has("wall_climb"):
		_fail("restored_factory_route_or_ability_state_failed")
		return
	var restored_player: Node2D = restored_upper.get_node_or_null(
		"Player"
	) as Node2D
	var return_spawn: Marker2D = restored_upper.get_node_or_null(
		"NeonRooftopsReturn"
	) as Marker2D
	if restored_player == null or return_spawn == null \
			or restored_player.global_position.distance_to(
				return_spawn.global_position
			) > 0.5:
		_fail("factory_high_perch_return_position_failed")
		return

	scene_manager.call("advance_deferred_unload", 4.0)
	if runtime_root.get_parent() != null:
		runtime_root.get_parent().remove_child(runtime_root)
	runtime_root.free()
	await process_frame
	print("neon_rooftops_magnetic_wall_handoff_smoke=passed")
	quit(0)


func _advance_until_scene(
	scene_manager: Node,
	target_scene_id: StringName
) -> bool:
	for _step: int in range(MAX_TRANSITION_STEPS):
		scene_manager.call("advance_loading", 0.1)
		await process_frame
		if StringName(scene_manager.call("get_current_scene")) == target_scene_id \
				and not bool(scene_manager.call("is_loading")):
			return true
	return false


func _fail(reason: String) -> void:
	Input.action_release("move_right")
	Input.action_release("move_up")
	push_error("neon_rooftops_magnetic_wall_handoff_smoke=" + reason)
	quit(1)
