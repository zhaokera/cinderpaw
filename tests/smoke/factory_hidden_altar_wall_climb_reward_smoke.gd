extends SceneTree

const UPPER_SCENE_PATH: String = (
	"res://scenes/areas/factory_upper_altar_approach.tscn"
)
const UPPER_SCENE_ID: StringName = &"area_03_factory_upper_altar"
const UNDERGROUND_SCENE_ID: StringName = &"area_04_underground_passage"


class SmokeSceneManager:
	extends RefCounted

	var scene_states: Dictionary = {}

	func has_scene(scene_id: StringName) -> bool:
		return scene_id in [UPPER_SCENE_ID, UNDERGROUND_SCENE_ID]

	func get_current_scene() -> StringName:
		return UPPER_SCENE_ID

	func get_current_spawn_point() -> StringName:
		return &"cistern_ascender_arrival"

	func is_loading() -> bool:
		return false

	func is_scene_locked() -> bool:
		return false

	func get_scene_state(scene_id: StringName) -> Dictionary:
		return Dictionary(scene_states.get(String(scene_id), {})).duplicate(true)

	func set_scene_state(scene_id: StringName, state: Dictionary) -> bool:
		scene_states[String(scene_id)] = state.duplicate(true)
		return true

	func request_scene_change(
		scene_id: StringName,
		_spawn_point: StringName = &"default"
	) -> bool:
		return has_scene(scene_id)


func _initialize() -> void:
	call_deferred("_run_smoke")


func _run_smoke() -> void:
	var upper: Node = _instantiate(UPPER_SCENE_PATH)
	if not _require(upper != null, "Factory upper scene failed to load"):
		return
	root.add_child(upper)
	var manager := SmokeSceneManager.new()
	if not _require(bool(upper.call(
		"configure_scene_manager_runtime",
		manager
	)), "SceneManager setup failed"):
		return
	upper.call("set_local_state", {
		"factory_upper_hidden_altar_discovered": true,
		"unlocked_abilities": ["dash", "double_jump", "aerial_attack"],
	})
	var player: CharacterBody2D = upper.get_node_or_null(
		"Player"
	) as CharacterBody2D
	var altar: Node2D = upper.get_node_or_null("DormantHiddenAltar") as Node2D
	if not _require(player != null and altar != null, "Player/altar missing"):
		return
	player.global_position = altar.global_position
	if not _require(bool(upper.call(
		"try_claim_wall_climb_reward",
		player
	)), "Wall Climb claim failed"):
		return
	var persisted: Dictionary = manager.get_scene_state(UPPER_SCENE_ID)
	if not _require(
		bool(persisted.get("factory_upper_wall_climb_reward_claimed", false))
		and Array(persisted.get("unlocked_abilities", [])).has("wall_climb"),
		"Reward state or unlocked ability was not persisted"
	):
		return
	upper.call("advance_wall_climb_reward_feedback", 1.5)

	player.global_position = Vector2(1218.0, 470.0)
	player.velocity = Vector2.ZERO
	Input.action_press("move_right")
	Input.action_press("move_up")
	var climb_started: bool = false
	var climb_start_y: float = player.global_position.y
	for _frame: int in range(90):
		await physics_frame
		var wall_state: Dictionary = player.call("get_wall_climb_diagnostics")
		if bool(wall_state.get("active", false)):
			if not climb_started:
				climb_started = true
				climb_start_y = player.global_position.y
			if player.global_position.y < climb_start_y - 20.0:
				break
	Input.action_release("move_right")
	Input.action_release("move_up")
	if not _require(climb_started, "Real wall contact never entered Wall Climb"):
		return
	if not _require(
		player.global_position.y < climb_start_y - 20.0,
		"Wall Climb did not move Cinderpaw upward"
	):
		return
	var active_state: Dictionary = player.call("get_wall_climb_diagnostics")
	if not _require(
		String(active_state.get("animation", "")) == "wall_climb",
		"Wall Climb animation did not activate"
	):
		return
	if not _require(bool(player.call("request_wall_jump")), "Wall jump failed"):
		return
	if not _require(
		player.velocity.x < -200.0 and player.velocity.y < -300.0,
		"Wall jump velocity was not directed away/up"
	):
		return

	var proof: Node2D = upper.get_node_or_null("WallClimbProofArea") as Node2D
	if not _require(proof != null, "Wall Climb proof area missing"):
		return
	player.global_position = proof.global_position
	player.velocity = Vector2.ZERO
	if not _require(bool(upper.call(
		"try_prove_wall_climb_route",
		player
	)), "High route proof failed"):
		return
	var diagnostics: Dictionary = upper.call(
		"get_factory_upper_altar_diagnostics"
	)
	if not _require(
		bool(diagnostics.get("wall_climb_route_proven", false))
		and String(diagnostics.get("objective_text", "")) == "Rooftop Route Reached"
		and int(diagnostics.get("wall_contact_feedback_count", 0)) >= 1,
		"Proof objective or generated contact feedback failed"
	):
		return

	print("factory_hidden_altar_wall_climb_reward_smoke=passed")
	upper.queue_free()
	await process_frame
	quit(0)


func _instantiate(path: String) -> Node:
	var packed: PackedScene = load(path) as PackedScene
	return packed.instantiate() if packed != null else null


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error(message)
	quit(1)
	return false
