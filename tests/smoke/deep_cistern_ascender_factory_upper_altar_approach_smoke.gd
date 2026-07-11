extends SceneTree

const UNDERGROUND_SCENE_PATH: String = "res://scenes/areas/underground_passage.tscn"
const UPPER_SCENE_PATH: String = (
	"res://scenes/areas/factory_upper_altar_approach.tscn"
)
const UNDERGROUND_SCENE_ID: StringName = &"area_04_underground_passage"
const UPPER_SCENE_ID: StringName = &"area_03_factory_upper_altar"
const UPPER_SPAWN_POINT: StringName = &"cistern_ascender_arrival"
const UNDERGROUND_RETURN_SPAWN: StringName = &"deep_cistern_ascender_return"


class SmokeSceneManager:
	extends RefCounted

	var request_calls: Array[Dictionary] = []
	var scene_states: Dictionary = {}
	var current_scene: StringName = UNDERGROUND_SCENE_ID
	var current_spawn: StringName = &"factory_drop_entry"
	var loading: bool = false
	var runtime_root_configured: bool = false

	func has_scene(scene_id: StringName) -> bool:
		return scene_id in [UNDERGROUND_SCENE_ID, UPPER_SCENE_ID]

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn

	func is_loading() -> bool:
		return loading

	func is_scene_locked() -> bool:
		return false

	func is_runtime_scene_swap_enabled() -> bool:
		return runtime_root_configured

	func configure_runtime_scene_root(
		_root: Node,
		_current_scene_node: Node = null
	) -> bool:
		runtime_root_configured = true
		return true

	func get_scene_state(scene_id: StringName) -> Dictionary:
		return Dictionary(scene_states.get(String(scene_id), {})).duplicate(true)

	func set_scene_state(scene_id: StringName, state: Dictionary) -> bool:
		scene_states[String(scene_id)] = state.duplicate(true)
		return true

	func get_pending_scene() -> StringName:
		return (
			StringName(String(request_calls[-1].get("scene_id", "")))
			if not request_calls.is_empty()
			else &""
		)

	func get_pending_spawn_point() -> StringName:
		return (
			StringName(String(request_calls[-1].get("spawn_point", "")))
			if not request_calls.is_empty()
			else &""
		)

	func request_scene_change(
		scene_id: StringName,
		spawn_point: StringName = &"default"
	) -> bool:
		if loading or not has_scene(scene_id):
			return false
		request_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		loading = true
		return true

	func reset_for_scene(
		scene_id: StringName,
		spawn_point: StringName
	) -> void:
		request_calls.clear()
		current_scene = scene_id
		current_spawn = spawn_point
		loading = false


func _initialize() -> void:
	call_deferred("_run_smoke")


func _run_smoke() -> void:
	var manager := SmokeSceneManager.new()
	var underground: Node = _instantiate(UNDERGROUND_SCENE_PATH)
	if not _require(underground != null, "Underground scene failed to load"):
		return
	root.add_child(underground)
	underground.call("set_local_state", _story133_cleared_state())
	if not _require(bool(underground.call(
		"configure_scene_manager_runtime",
		manager
	)), "Underground SceneManager setup failed"):
		return
	var route: Node2D = underground.get_node_or_null(
		"DeepCisternAscenderRoute"
	) as Node2D
	var player: Node2D = underground.get_node_or_null("Player") as Node2D
	if not _require(route != null and player != null, "Ascender route/player missing"):
		return
	player.global_position = route.global_position
	if not _require(bool(underground.call(
		"try_request_deep_cistern_ascender",
		player
	)), "Ascender request failed"):
		return
	if not _require(
		manager.get_pending_scene() == UPPER_SCENE_ID
		and manager.get_pending_spawn_point() == UPPER_SPAWN_POINT,
		"Ascender requested the wrong target"
	):
		return
	underground.queue_free()
	await process_frame

	manager.reset_for_scene(UPPER_SCENE_ID, UPPER_SPAWN_POINT)
	var upper: Node = _instantiate(UPPER_SCENE_PATH)
	if not _require(upper != null, "Factory upper altar scene failed to load"):
		return
	root.add_child(upper)
	if not _require(bool(upper.call(
		"configure_scene_manager_runtime",
		manager
	)), "Upper scene SceneManager setup failed"):
		return
	upper.call("set_local_state", {
		"unlocked_abilities": ["dash", "double_jump", "aerial_attack"],
	})
	var upper_player: Node2D = upper.get_node_or_null("Player") as Node2D
	var altar: Node2D = upper.get_node_or_null("DormantHiddenAltar") as Node2D
	if not _require(
		upper_player != null and altar != null,
		"Upper player/altar missing"
	):
		return
	upper_player.global_position = altar.global_position
	if not _require(bool(upper.call(
		"try_discover_hidden_altar",
		upper_player
	)), "Dormant altar discovery failed"):
		return
	var diagnostics: Dictionary = upper.call(
		"get_factory_upper_altar_diagnostics"
	)
	if not _require(
		bool(diagnostics.get("altar_discovered", false))
		and String(diagnostics.get("objective_text", "")) == "Dormant Altar Found"
		and not Array(diagnostics.get("unlocked_abilities", [])).has("wall_climb"),
		"Dormant altar state or ability boundary failed"
	):
		return
	var return_route: Node2D = upper.get_node_or_null(
		"UndergroundReturnRoute"
	) as Node2D
	if not _require(return_route != null, "Upper return route missing"):
		return
	upper_player.global_position = return_route.global_position
	if not _require(bool(upper.call(
		"try_request_underground_return",
		upper_player
	)), "Underground return request failed"):
		return
	if not _require(
		manager.get_pending_scene() == UNDERGROUND_SCENE_ID
		and manager.get_pending_spawn_point() == UNDERGROUND_RETURN_SPAWN,
		"Return route requested the wrong target"
	):
		return

	print("deep_cistern_ascender_factory_upper_altar_approach_smoke=passed")
	upper.queue_free()
	await process_frame
	quit(0)


func _story133_cleared_state() -> Dictionary:
	return {
		"underground_corrosion_channel_activated": true,
		"underground_corrosion_left_defeated": true,
		"underground_corrosion_right_defeated": true,
		"underground_corrosion_channel_cleared": true,
		"underground_corrosion_salvage_claimed": true,
		"underground_recovery_cistern_relay_activated": true,
		"underground_recovery_cistern_traversed": true,
		"underground_deep_cistern_ambush_activated": true,
		"underground_deep_cistern_stalker_defeated": true,
		"unlocked_abilities": ["dash", "double_jump", "aerial_attack"],
	}


func _instantiate(path: String) -> Node:
	var packed: PackedScene = load(path) as PackedScene
	return packed.instantiate() if packed != null else null


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	push_error(message)
	quit(1)
	return false
