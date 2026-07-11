## Scene controller for the Story127 Sluice Matriarch arena handoff.
class_name SluiceMatriarchArena
extends Node2D

const SCENE_ID: StringName = &"boss_03_sluice_matriarch_arena"
const ENTRY_SPAWN_POINT: StringName = &"boss_entry"
const FACTORY_SCENE_ID: StringName = &"area_03_factory"
const FACTORY_RETURN_SPAWN_POINT: StringName = &"tailrace_matriarch_gate_return"
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/sluice_matriarch_arena/"
	+ "env_sluice_matriarch_arena_backdrop_1280x720.png"
)

@onready var _player: Node2D = get_node_or_null("Player") as Node2D
@onready var _entry_spawn: Marker2D = get_node_or_null("BossEntrySpawn") as Marker2D
@onready var _background: Sprite2D = get_node_or_null("Background") as Sprite2D
@onready var _return_route: Node = get_node_or_null("FactoryReturnRoute")
@onready var _objective_label: Label = get_node_or_null("ArenaObjectiveLabel") as Label

var _scene_manager: Object = null
var _return_transition_requested: bool = false
var _last_return_rejected_reason: StringName = &""
var _last_return_request: Dictionary = {}


func _ready() -> void:
	_align_player_to_entry_spawn()
	_sync_return_route()
	var root_scene_manager: Node = get_node_or_null("/root/SceneManager")
	if _is_valid_scene_manager(root_scene_manager):
		configure_scene_manager_runtime(root_scene_manager)


func _process(_delta: float) -> void:
	_process_factory_return_contact()


## Injects the SceneManager adapter and reapplies the requested arena spawn.
func configure_scene_manager_runtime(scene_manager: Object) -> bool:
	_scene_manager = scene_manager
	if not _is_valid_scene_manager(_scene_manager):
		return false
	_apply_current_scene_manager_spawn_point()
	return true


## Requests the repeatable return route to the Tailrace gate once per scene visit.
func try_request_factory_return(provider: Node = null) -> bool:
	if _return_route == null or _return_transition_requested:
		_record_return_rejection(&"transition_already_requested")
		return false
	var request_provider: Node = _player if provider == null else provider
	if not _return_route.has_method("can_request_transition") \
			or not bool(_return_route.call("can_request_transition", request_provider)):
		_record_return_rejection(&"provider_out_of_range")
		return false
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if not _is_valid_scene_manager(scene_manager):
		_record_return_rejection(&"scene_manager_missing")
		return false
	if scene_manager.has_method("is_loading") and bool(scene_manager.call("is_loading")):
		_record_return_rejection(&"scene_manager_loading")
		return false
	if scene_manager.has_method("is_scene_locked") \
			and bool(scene_manager.call("is_scene_locked")):
		_record_return_rejection(&"scene_locked")
		return false
	if scene_manager.has_method("has_scene") \
			and not bool(scene_manager.call("has_scene", FACTORY_SCENE_ID)):
		_record_return_rejection(&"unknown_scene")
		return false
	if not _ensure_runtime_scene_root(scene_manager):
		_record_return_rejection(&"runtime_root_unavailable")
		return false
	if not _request_scene_change(
		scene_manager,
		FACTORY_SCENE_ID,
		FACTORY_RETURN_SPAWN_POINT
	):
		_record_return_rejection(&"request_rejected")
		return false

	_return_transition_requested = true
	_last_return_rejected_reason = &""
	_last_return_request = {
		"scene_id": String(FACTORY_SCENE_ID),
		"spawn_point": String(FACTORY_RETURN_SPAWN_POINT),
		"pending_scene": _get_pending_scene(scene_manager),
		"pending_spawn_point": _get_pending_spawn_point(scene_manager),
	}
	_return_route.call("set_transition_requested", true)
	if _objective_label != null:
		_objective_label.text = "Returning to Tailrace Spillway"
	return true


## Captures only durable discovery; transition latches intentionally stay transient.
func get_local_state() -> Dictionary:
	return {"sluice_matriarch_arena_discovered": true}


## Restores the reusable arena entry without carrying a stale request latch.
func set_local_state(_state: Dictionary) -> void:
	_return_transition_requested = false
	_last_return_rejected_reason = &""
	_last_return_request.clear()
	_sync_return_route()
	_align_player_to_entry_spawn()


## Returns deterministic scene, art, spawn, and transition evidence for tests/MCP.
func get_arena_handoff_diagnostics() -> Dictionary:
	var background_path: String = ""
	if _background != null and _background.texture != null:
		background_path = _background.texture.resource_path
	return {
		"scene_id": String(SCENE_ID),
		"background_texture_path": background_path,
		"player_position": _player.global_position if _player != null else Vector2.ZERO,
		"entry_spawn_position": (
			_entry_spawn.global_position if _entry_spawn != null else Vector2.ZERO
		),
		"return_route_present": _return_route != null,
		"return_route_available": (
			bool(_return_route.call("is_route_available"))
			if _return_route != null and _return_route.has_method("is_route_available")
			else false
		),
		"return_prompt_text": (
			String(_return_route.call("get_prompt_text"))
			if _return_route != null and _return_route.has_method("get_prompt_text")
			else ""
		),
		"return_target_scene_id": String(FACTORY_SCENE_ID),
		"return_spawn_point": String(FACTORY_RETURN_SPAWN_POINT),
		"return_transition_requested": _return_transition_requested,
		"return_rejected_reason": String(_last_return_rejected_reason),
		"last_return_request": _last_return_request.duplicate(true),
		"scene_manager_loading": _is_scene_manager_loading(),
		"objective_text": _objective_label.text if _objective_label != null else "",
	}


func _process_factory_return_contact() -> void:
	if (
		_player == null
		or _return_route == null
		or _return_transition_requested
		or not _return_route.has_method("is_provider_in_transition_range")
	):
		return
	if bool(_return_route.call("is_provider_in_transition_range", _player)):
		try_request_factory_return(_player)


func _sync_return_route() -> void:
	if _return_route == null:
		return
	if _return_route.has_method("set_route_available"):
		_return_route.call("set_route_available", true)
	if _return_route.has_method("set_transition_requested"):
		_return_route.call("set_transition_requested", _return_transition_requested)
	if _objective_label != null and not _return_transition_requested:
		_objective_label.text = "Sluice Matriarch Lair"


func _align_player_to_entry_spawn() -> bool:
	if _player == null or _entry_spawn == null:
		return false
	_player.global_position = _entry_spawn.global_position
	if _player is CharacterBody2D:
		(_player as CharacterBody2D).velocity = Vector2.ZERO
	return true


func _apply_current_scene_manager_spawn_point() -> bool:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	if scene_manager == null or not scene_manager.has_method("get_current_scene"):
		return false
	if StringName(scene_manager.call("get_current_scene")) != SCENE_ID:
		return false
	if not scene_manager.has_method("get_current_spawn_point"):
		return false
	var spawn_point: StringName = StringName(scene_manager.call("get_current_spawn_point"))
	if spawn_point != ENTRY_SPAWN_POINT:
		return false
	return _align_player_to_entry_spawn()


func _resolve_scene_manager_for_runtime() -> Object:
	if _is_valid_scene_manager(_scene_manager):
		return _scene_manager
	if not is_inside_tree():
		return null
	var root_scene_manager: Node = get_node_or_null("/root/SceneManager")
	if _is_valid_scene_manager(root_scene_manager):
		_scene_manager = root_scene_manager
		return _scene_manager
	return null


func _is_valid_scene_manager(scene_manager: Object) -> bool:
	return (
		scene_manager != null
		and is_instance_valid(scene_manager)
		and (
			scene_manager.has_method("request_scene_change")
			or scene_manager.has_method("change_scene")
		)
	)


func _ensure_runtime_scene_root(scene_manager: Object) -> bool:
	if not scene_manager.has_method("configure_runtime_scene_root"):
		return true
	if scene_manager.has_method("is_runtime_scene_swap_enabled") \
			and bool(scene_manager.call("is_runtime_scene_swap_enabled")):
		return true
	if not is_inside_tree() or get_parent() == null:
		return false
	return bool(scene_manager.call("configure_runtime_scene_root", get_parent(), self))


func _request_scene_change(
	scene_manager: Object,
	scene_id: StringName,
	spawn_point: StringName
) -> bool:
	if scene_manager.has_method("request_scene_change"):
		return bool(scene_manager.call("request_scene_change", scene_id, spawn_point))
	if scene_manager.has_method("change_scene"):
		return bool(scene_manager.call("change_scene", scene_id, spawn_point))
	return false


func _record_return_rejection(reason: StringName) -> void:
	_last_return_rejected_reason = reason
	_last_return_request.clear()


func _is_scene_manager_loading() -> bool:
	var scene_manager: Object = _resolve_scene_manager_for_runtime()
	return (
		bool(scene_manager.call("is_loading"))
		if scene_manager != null and scene_manager.has_method("is_loading")
		else false
	)


func _get_pending_scene(scene_manager: Object) -> String:
	return (
		String(scene_manager.call("get_pending_scene"))
		if scene_manager.has_method("get_pending_scene")
		else ""
	)


func _get_pending_spawn_point(scene_manager: Object) -> String:
	return (
		String(scene_manager.call("get_pending_spawn_point"))
		if scene_manager.has_method("get_pending_spawn_point")
		else ""
	)
