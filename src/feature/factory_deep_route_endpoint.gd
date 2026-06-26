## Scene-local endpoint switch for the Old Factory deep route micro-slice.
class_name FactoryDeepRouteEndpoint
extends Node2D

signal endpoint_activated(endpoint_id: StringName)

const DEFAULT_UNLOCK_VFX_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png"
)
const UNLOCK_VFX_NODE_NAME: String = "UnlockVfx"
const UNLOCK_VFX_ASSET_SOURCE: String = "image_generation"
const UNLOCK_VFX_ROLE: String = "deep_route_unlock"

@export var endpoint_id: StringName = &"old_factory_deep_route_endpoint"
@export var activation_radius_px: float = 96.0
@export var locked_prompt_text: String = "Clear guard"
@export var available_prompt_text: String = "Open route"
@export var activated_prompt_text: String = "Route clear"
@export var unlock_vfx_texture: Texture2D
@export var unlock_vfx_duration_sec: float = 0.6

@onready var _visual: Sprite2D = get_node_or_null("Visual") as Sprite2D
@onready var _prompt_label: Label = get_node_or_null("PromptLabel") as Label
@onready var _interaction_area: Area2D = get_node_or_null("InteractionArea") as Area2D

var _available: bool = false
var _activated: bool = false
var _unlock_vfx_elapsed_sec: float = 0.0
var _unlock_vfx_nodes: Array[Sprite2D] = []
var _unlock_vfx_played: bool = false
var _unlock_vfx_spawn_count: int = 0
var _last_unlock_vfx_spawn: Dictionary = {}


func _ready() -> void:
	add_to_group("factory_deep_route_endpoint")
	_ensure_unlock_vfx_texture()
	_sync_state()


func _process(delta: float) -> void:
	advance_unlock_vfx_time(delta)


## Returns the deterministic endpoint id used by diagnostics and scene state.
func get_endpoint_id() -> StringName:
	return endpoint_id


## Returns the imported texture path mounted by the visible endpoint sprite.
func get_visual_texture_path() -> String:
	if _visual == null or _visual.texture == null:
		return ""
	return _visual.texture.resource_path


## Returns the imported image-generated unlock feedback texture path.
func get_unlock_vfx_texture_path() -> String:
	_ensure_unlock_vfx_texture()
	if unlock_vfx_texture == null:
		return ""
	return unlock_vfx_texture.resource_path


## Returns deterministic unlock VFX diagnostics for tests and MCP probes.
func get_unlock_vfx_snapshot() -> Dictionary:
	_prune_unlock_vfx_nodes()
	return {
		"texture_path": get_unlock_vfx_texture_path(),
		"active_count": _unlock_vfx_nodes.size(),
		"duration_sec": unlock_vfx_duration_sec,
		"elapsed_sec": _unlock_vfx_elapsed_sec,
		"played": _unlock_vfx_played,
		"spawn_count": _unlock_vfx_spawn_count,
		"last_spawn": _last_unlock_vfx_spawn.duplicate(true),
	}


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
	_spawn_unlock_vfx()
	_sync_state()
	endpoint_activated.emit(endpoint_id)
	return true


## Advances the one-shot unlock VFX without relying on wall-clock test waits.
func advance_unlock_vfx_time(delta_sec: float) -> void:
	if _unlock_vfx_nodes.is_empty():
		return
	_unlock_vfx_elapsed_sec = minf(
		unlock_vfx_duration_sec,
		_unlock_vfx_elapsed_sec + maxf(0.0, delta_sec)
	)
	var progress: float = (
		1.0
		if unlock_vfx_duration_sec <= 0.0
		else clampf(_unlock_vfx_elapsed_sec / unlock_vfx_duration_sec, 0.0, 1.0)
	)
	for vfx_node: Sprite2D in _unlock_vfx_nodes:
		if not is_instance_valid(vfx_node):
			continue
		vfx_node.modulate.a = maxf(0.0, 1.0 - progress)
		var pulse_scale: float = 0.72 + (0.18 * progress)
		vfx_node.scale = Vector2(pulse_scale, pulse_scale)
	if progress >= 1.0:
		_clear_unlock_vfx_nodes()


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


func _ensure_unlock_vfx_texture() -> void:
	if unlock_vfx_texture != null:
		return
	var loaded_texture: Resource = load(DEFAULT_UNLOCK_VFX_TEXTURE_PATH)
	if loaded_texture is Texture2D:
		unlock_vfx_texture = loaded_texture as Texture2D


func _spawn_unlock_vfx() -> void:
	if _unlock_vfx_played:
		return
	_ensure_unlock_vfx_texture()
	if unlock_vfx_texture == null:
		return
	_clear_unlock_vfx_nodes()
	var vfx_node := Sprite2D.new()
	vfx_node.name = UNLOCK_VFX_NODE_NAME
	vfx_node.texture = unlock_vfx_texture
	vfx_node.centered = true
	vfx_node.position = Vector2(0.0, -24.0)
	vfx_node.scale = Vector2(0.72, 0.72)
	vfx_node.z_index = 8
	vfx_node.set_meta(&"asset_source", UNLOCK_VFX_ASSET_SOURCE)
	vfx_node.set_meta(&"vfx_role", UNLOCK_VFX_ROLE)
	vfx_node.set_meta(&"texture_path", get_unlock_vfx_texture_path())
	add_child(vfx_node)
	_unlock_vfx_nodes.append(vfx_node)
	_unlock_vfx_elapsed_sec = 0.0
	_unlock_vfx_played = true
	_unlock_vfx_spawn_count += 1
	_last_unlock_vfx_spawn = {
		"node_name": vfx_node.name,
		"asset_source": UNLOCK_VFX_ASSET_SOURCE,
		"vfx_role": UNLOCK_VFX_ROLE,
		"texture_path": get_unlock_vfx_texture_path(),
		"duration_sec": unlock_vfx_duration_sec,
		"position": vfx_node.position,
	}


func _clear_unlock_vfx_nodes() -> void:
	for vfx_node: Sprite2D in _unlock_vfx_nodes:
		if not is_instance_valid(vfx_node):
			continue
		if vfx_node.get_parent() == self:
			remove_child(vfx_node)
		vfx_node.free()
	_unlock_vfx_nodes.clear()
	_unlock_vfx_elapsed_sec = 0.0


func _prune_unlock_vfx_nodes() -> void:
	var live_nodes: Array[Sprite2D] = []
	for vfx_node: Sprite2D in _unlock_vfx_nodes:
		if is_instance_valid(vfx_node) and vfx_node.get_parent() == self:
			live_nodes.append(vfx_node)
	_unlock_vfx_nodes = live_nodes
