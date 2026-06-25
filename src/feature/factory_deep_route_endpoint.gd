## Scene-local endpoint switch for the Old Factory deep route micro-slice.
class_name FactoryDeepRouteEndpoint
extends Node2D

signal endpoint_activated(endpoint_id: StringName)

@export var endpoint_id: StringName = &"old_factory_deep_route_endpoint"
@export var activation_radius_px: float = 96.0
@export var locked_prompt_text: String = "Clear guard"
@export var available_prompt_text: String = "Open route"
@export var activated_prompt_text: String = "Route clear"

@onready var _visual: Sprite2D = get_node_or_null("Visual") as Sprite2D
@onready var _prompt_label: Label = get_node_or_null("PromptLabel") as Label
@onready var _interaction_area: Area2D = get_node_or_null("InteractionArea") as Area2D

var _available: bool = false
var _activated: bool = false


func _ready() -> void:
	add_to_group("factory_deep_route_endpoint")
	_sync_state()


## Returns the deterministic endpoint id used by diagnostics and scene state.
func get_endpoint_id() -> StringName:
	return endpoint_id


## Returns the imported texture path mounted by the visible endpoint sprite.
func get_visual_texture_path() -> String:
	if _visual == null or _visual.texture == null:
		return ""
	return _visual.texture.resource_path


## Returns whether the endpoint can currently be activated.
func is_available() -> bool:
	return _available and not _activated


## Returns whether the deep route endpoint was already activated.
func is_activated() -> bool:
	return _activated


## Sets whether the route objective is available after the deep guard is defeated.
func set_available(available: bool) -> void:
	_available = available
	_sync_state()


## Restores or applies the once-only activated state.
func set_activated(activated: bool) -> void:
	_activated = activated
	if _activated:
		_available = true
	_sync_state()


## Checks whether a provider node is close enough to activate the endpoint.
func is_provider_in_activation_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	var provider_node := provider as Node2D
	return global_position.distance_to(provider_node.global_position) <= activation_radius_px


## Attempts to activate the endpoint once for a nearby provider.
func try_activate(provider: Node = null) -> bool:
	if not is_available():
		return false
	if provider != null and not is_provider_in_activation_range(provider):
		return false
	_activated = true
	_sync_state()
	endpoint_activated.emit(endpoint_id)
	return true


func _sync_state() -> void:
	if _visual != null:
		if _activated:
			_visual.modulate = Color(0.85, 1.0, 0.72, 1.0)
		elif _available:
			_visual.modulate = Color.WHITE
		else:
			_visual.modulate = Color(0.56, 0.62, 0.72, 0.72)
	if _prompt_label != null:
		_prompt_label.text = _prompt_text()
		_prompt_label.visible = true
	if _interaction_area != null:
		_interaction_area.monitoring = is_available()
		_interaction_area.monitorable = is_available()


func _prompt_text() -> String:
	if _activated:
		return activated_prompt_text
	if _available:
		return available_prompt_text
	return locked_prompt_text
