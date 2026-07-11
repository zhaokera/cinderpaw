## Owns the Story134 ascender route from the secured cistern to Factory upper works.
class_name DeepCisternAscenderRouteController
extends Node2D

signal objective_changed(objective_text: String)

const UNDERGROUND_SCENE_ID: StringName = &"area_04_underground_passage"
const TARGET_SCENE_ID: StringName = &"area_03_factory_upper_altar"
const TARGET_SPAWN_POINT: StringName = &"cistern_ascender_arrival"
const RETURN_SPAWN_POINT: StringName = &"deep_cistern_ascender_return"
const ASCENDER_TEXTURE_PATH: String = (
	"res://assets/environment/factory_upper_altar/"
	+ "prop_deep_cistern_ascender_384x512.png"
)

@onready var _route: Node2D = (
	get_node_or_null("../DeepCisternAscenderRoute") as Node2D
)
@onready var _return_spawn: Marker2D = (
	get_node_or_null("../DeepCisternAscenderReturnSpawn") as Marker2D
)
@onready var _prompt_label: Label = (
	get_node_or_null("../DeepCisternAscenderRoute/PromptLabel") as Label
)

var _player: Node2D = null
var _scene_owner: Object = null
var _scene_manager: Object = null
var _stalker_defeated: bool = false
var _ascender_discovered: bool = false
var _transition_requested: bool = false
var _last_rejected_reason: StringName = &""
var _last_request: Dictionary = {}
var _last_emitted_objective_text: String = ""


func _ready() -> void:
	_sync_state()


func _process(_delta: float) -> void:
	_sync_prompt_visibility()
	if (
		_player != null
		and not _transition_requested
		and Input.is_action_just_pressed(&"interact")
		and _is_provider_in_range(_player)
	):
		try_request_transition(_player)


## Injects scene-local adapters while keeping transition ownership out of the parent.
func configure_runtime(
	player: Node2D,
	scene_owner: Object,
	scene_manager: Object = null
) -> bool:
	_player = player
	_scene_owner = scene_owner
	_scene_manager = scene_manager
	_sync_state()
	return _player != null and _scene_owner != null


func configure_scene_manager_runtime(scene_manager: Object) -> bool:
	_scene_manager = scene_manager
	return _is_valid_scene_manager(_scene_manager)


func set_stalker_defeated(defeated: bool) -> void:
	_stalker_defeated = defeated
	_sync_state()


## Requests the configured scene handoff once per active scene visit.
func try_request_transition(provider: Node = null) -> bool:
	if _route == null or _transition_requested or not _stalker_defeated:
		_record_rejection(&"route_unavailable")
		return false
	var request_provider: Node = _player if provider == null else provider
	if (
		not _route.has_method("can_request_transition")
		or not bool(_route.call("can_request_transition", request_provider))
	):
		_record_rejection(&"provider_out_of_range")
		return false
	if not _is_valid_scene_manager(_scene_manager):
		_record_rejection(&"scene_manager_missing")
		return false
	if _scene_manager.has_method("is_loading") and bool(
		_scene_manager.call("is_loading")
	):
		_record_rejection(&"scene_manager_loading")
		return false
	if _scene_manager.has_method("is_scene_locked") and bool(
		_scene_manager.call("is_scene_locked")
	):
		_record_rejection(&"scene_locked")
		return false
	if _scene_manager.has_method("has_scene") and not bool(
		_scene_manager.call("has_scene", TARGET_SCENE_ID)
	):
		_record_rejection(&"unknown_scene")
		return false
	if not _ensure_runtime_scene_root():
		_record_rejection(&"runtime_root_unavailable")
		return false

	_ascender_discovered = true
	if not _persist_progress():
		_record_rejection(&"state_persist_failed")
		return false
	if not _request_scene_change(TARGET_SCENE_ID, TARGET_SPAWN_POINT):
		_record_rejection(&"request_rejected")
		return false

	_transition_requested = true
	_last_rejected_reason = &""
	_last_request = {
		"scene_id": String(TARGET_SCENE_ID),
		"spawn_point": String(TARGET_SPAWN_POINT),
		"pending_scene": _get_pending_scene(),
		"pending_spawn_point": _get_pending_spawn_point(),
	}
	_sync_state()
	return true


func get_local_state() -> Dictionary:
	return {
		"underground_deep_cistern_ascender_discovered": _ascender_discovered,
	}


func set_local_state(state: Dictionary) -> void:
	_ascender_discovered = bool(state.get(
		"underground_deep_cistern_ascender_discovered",
		false
	))
	_transition_requested = false
	_last_rejected_reason = &""
	_last_request.clear()
	_sync_state()


func align_player_to_return_spawn() -> bool:
	if _player == null or _return_spawn == null:
		return false
	_player.global_position = _return_spawn.global_position
	if _player is CharacterBody2D:
		(_player as CharacterBody2D).velocity = Vector2.ZERO
	return true


func should_own_objective(provider: Node = null) -> bool:
	if not _stalker_defeated:
		return false
	var objective_provider: Node = _player if provider == null else provider
	return (
		objective_provider is Node2D
		and (objective_provider as Node2D).global_position.x >= 3840.0
	)


func get_objective_text() -> String:
	if _transition_requested:
		return "Ascending to Factory Upper Works"
	if _stalker_defeated:
		return "Ride Ascender to Upper Factory"
	return "Defeat Cistern Stalker"


func get_diagnostics() -> Dictionary:
	return {
		"controller_present": true,
		"controller_script_path": get_script().resource_path,
		"route_present": _route != null,
		"route_available": _is_route_available(),
		"route_position": _route.global_position if _route != null else Vector2.ZERO,
		"return_spawn_position": (
			_return_spawn.global_position if _return_spawn != null else Vector2.ZERO
		),
		"target_scene_id": String(TARGET_SCENE_ID),
		"target_spawn_point": String(TARGET_SPAWN_POINT),
		"return_spawn_point": String(RETURN_SPAWN_POINT),
		"ascender_texture_path": _get_ascender_texture_path(),
		"ascender_expected_path": ASCENDER_TEXTURE_PATH,
		"stalker_defeated": _stalker_defeated,
		"ascender_discovered": _ascender_discovered,
		"transition_requested": _transition_requested,
		"last_rejected_reason": String(_last_rejected_reason),
		"last_request": _last_request.duplicate(true),
		"prompt_visible": _prompt_label != null and _prompt_label.visible,
		"prompt_text": _prompt_label.text if _prompt_label != null else "",
		"objective_text": get_objective_text(),
	}


func _sync_state() -> void:
	if _route != null:
		if _route.has_method("set_route_available"):
			_route.call("set_route_available", _stalker_defeated)
		if _route.has_method("set_transition_requested"):
			_route.call("set_transition_requested", _transition_requested)
	_sync_prompt_visibility()
	_emit_objective_if_changed()


func _sync_prompt_visibility() -> void:
	if _prompt_label == null:
		return
	_prompt_label.visible = (
		_stalker_defeated
		and not _transition_requested
		and _is_provider_in_range(_player)
	)


func _is_provider_in_range(provider: Node) -> bool:
	return (
		_route != null
		and provider != null
		and _route.has_method("is_provider_in_transition_range")
		and bool(_route.call("is_provider_in_transition_range", provider))
	)


func _is_route_available() -> bool:
	return (
		_route != null
		and _route.has_method("is_route_available")
		and bool(_route.call("is_route_available"))
	)


func _persist_progress() -> bool:
	if (
		_scene_owner == null
		or not _scene_owner.has_method("get_local_state")
		or not _scene_manager.has_method("set_scene_state")
	):
		return false
	var underground_state: Dictionary = Dictionary(
		_scene_owner.call("get_local_state")
	).duplicate(true)
	var persisted: bool = bool(_scene_manager.call(
		"set_scene_state",
		UNDERGROUND_SCENE_ID,
		underground_state
	))
	var target_state: Dictionary = {}
	if _scene_manager.has_method("get_scene_state"):
		target_state = Dictionary(_scene_manager.call(
			"get_scene_state",
			TARGET_SCENE_ID
		)).duplicate(true)
	var target_abilities: Array = Array(target_state.get("unlocked_abilities", []))
	for ability_id: Variant in Array(underground_state.get("unlocked_abilities", [])):
		if not target_abilities.has(ability_id):
			target_abilities.append(ability_id)
	target_state["unlocked_abilities"] = target_abilities
	return bool(_scene_manager.call(
		"set_scene_state",
		TARGET_SCENE_ID,
		target_state
	)) and persisted


func _ensure_runtime_scene_root() -> bool:
	if not _scene_manager.has_method("configure_runtime_scene_root"):
		return true
	if _scene_manager.has_method("is_runtime_scene_swap_enabled") and bool(
		_scene_manager.call("is_runtime_scene_swap_enabled")
	):
		return true
	if not _scene_owner is Node:
		return false
	var owner_node := _scene_owner as Node
	return bool(_scene_manager.call(
		"configure_runtime_scene_root",
		owner_node.get_parent(),
		owner_node
	))


func _request_scene_change(
	scene_id: StringName,
	spawn_point: StringName
) -> bool:
	if _scene_manager.has_method("request_scene_change"):
		return bool(_scene_manager.call(
			"request_scene_change",
			scene_id,
			spawn_point
		))
	if _scene_manager.has_method("change_scene"):
		return bool(_scene_manager.call("change_scene", scene_id, spawn_point))
	return false


func _get_ascender_texture_path() -> String:
	if _route == null:
		return ""
	var visual: Sprite2D = _route.get_node_or_null("Visual") as Sprite2D
	if visual == null or visual.texture == null:
		return ""
	return visual.texture.resource_path


func _record_rejection(reason: StringName) -> void:
	_last_rejected_reason = reason


func _emit_objective_if_changed() -> void:
	var objective_text: String = get_objective_text()
	if objective_text == _last_emitted_objective_text:
		return
	_last_emitted_objective_text = objective_text
	objective_changed.emit(objective_text)


func _get_pending_scene() -> String:
	return (
		String(_scene_manager.call("get_pending_scene"))
		if _scene_manager.has_method("get_pending_scene")
		else ""
	)


func _get_pending_spawn_point() -> String:
	return (
		String(_scene_manager.call("get_pending_spawn_point"))
		if _scene_manager.has_method("get_pending_spawn_point")
		else ""
	)


func _is_valid_scene_manager(scene_manager: Object) -> bool:
	return (
		scene_manager != null
		and is_instance_valid(scene_manager)
		and (
			scene_manager.has_method("request_scene_change")
			or scene_manager.has_method("change_scene")
		)
	)
