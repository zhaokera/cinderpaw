## Scene-local trigger that exposes an unlocked route transition to MainScene.
class_name RouteTransitionShell
extends Node2D

const GROUP_NAME: StringName = &"route_transition_shell"

@export var route_id: StringName = &""
@export var target_scene_id: StringName = &""
@export var spawn_point: StringName = &"default"
@export var required_world_flag: StringName = &""
@export var interaction_radius_px: float = 112.0
@export var locked_prompt_text: String = "Route locked"
@export var available_prompt_text: String = "Enter route"

@onready var _visual: Sprite2D = get_node_or_null("Visual") as Sprite2D
@onready var _prompt_label: Label = get_node_or_null("PromptLabel") as Label
@onready var _interaction_area: Area2D = get_node_or_null("InteractionArea") as Area2D

var _route_available: bool = false
var _transition_requested: bool = false


func _ready() -> void:
	add_to_group(GROUP_NAME)
	_sync_visual_state()


func get_route_id() -> StringName:
	if route_id != &"":
		return route_id
	return StringName(name)


func get_target_scene_id() -> StringName:
	return target_scene_id


func get_spawn_point() -> StringName:
	return spawn_point


func get_required_world_flag() -> StringName:
	return required_world_flag


func get_visual_texture_path() -> String:
	if _visual == null or _visual.texture == null:
		return ""
	return _visual.texture.resource_path


func get_visual_modulate() -> Color:
	return _visual.modulate if _visual != null else Color.TRANSPARENT


func get_prompt_text() -> String:
	return available_prompt_text if _route_available else locked_prompt_text


func is_prompt_visible() -> bool:
	return _prompt_label != null and _prompt_label.visible


func is_route_available() -> bool:
	return _route_available


func is_transition_requested() -> bool:
	return _transition_requested


func set_route_available(available: bool) -> void:
	if _route_available == available:
		_sync_visual_state()
		return
	_route_available = available
	if not _route_available:
		_transition_requested = false
	_sync_visual_state()


func set_transition_requested(requested: bool) -> void:
	_transition_requested = requested
	_sync_visual_state()


func is_provider_in_transition_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	var provider_node := provider as Node2D
	return global_position.distance_to(provider_node.global_position) <= maxf(0.0, interaction_radius_px)


func can_request_transition(provider: Node = null) -> bool:
	if not _route_available or _transition_requested:
		return false
	if provider != null and not is_provider_in_transition_range(provider):
		return false
	return target_scene_id != &"" and spawn_point != &""


func _sync_visual_state() -> void:
	visible = true
	if _visual != null:
		_visual.modulate = Color.WHITE if _route_available else Color(0.45, 0.52, 0.62, 0.42)
	if _prompt_label != null:
		_prompt_label.text = available_prompt_text if _route_available else locked_prompt_text
		_prompt_label.visible = _route_available and not _transition_requested
	if _interaction_area != null:
		var interaction_active: bool = (
			_route_available and not _transition_requested
		)
		if Engine.is_in_physics_frame():
			_interaction_area.set_deferred("monitoring", interaction_active)
			_interaction_area.set_deferred("monitorable", interaction_active)
		else:
			_interaction_area.monitoring = interaction_active
			_interaction_area.monitorable = interaction_active
