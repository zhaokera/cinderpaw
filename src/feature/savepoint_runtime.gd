## Scene-local savepoint trigger for runtime discovery and autosave handoff.
class_name SavepointRuntime
extends Node2D

signal savepoint_activated(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2,
	context: Dictionary
)

const GROUP_NAME: StringName = &"savepoint"
const ACTIVATION_VFX_NODE_NAME: String = "ActivationVfx"
const ACTIVATION_VFX_ASSET_SOURCE: String = "image_generation"
const ACTIVATION_VFX_ROLE: String = "savepoint_activation"

@export var savepoint_id: StringName = &""
@export var scene_id: StringName = &""
@export var spawn_point: StringName = &""
@export var display_name: String = "Savepoint"
@export var prompt_text: String = "Savepoint"
@export var activation_vfx_texture: Texture2D
@export var activation_vfx_duration_sec: float = 0.6

@onready var _visual: Sprite2D = get_node_or_null("Visual") as Sprite2D
@onready var _prompt_label: Label = get_node_or_null("PromptLabel") as Label
@onready var _interaction_area: Area2D = get_node_or_null("InteractionArea") as Area2D

var _activation_vfx_elapsed_sec: float = 0.0
var _activation_vfx_nodes: Array[Sprite2D] = []
var _activation_vfx_played: bool = false
var _activation_vfx_spawn_count: int = 0
var _last_activation_vfx_spawn: Dictionary = {}


func _ready() -> void:
	add_to_group(GROUP_NAME)
	_sync_visual_state()
	if _interaction_area != null and not _interaction_area.body_entered.is_connected(_on_body_entered):
		_interaction_area.body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	advance_activation_vfx_time(delta)


func get_savepoint_id() -> StringName:
	if savepoint_id != &"":
		return savepoint_id
	return StringName(name)


func get_scene_id() -> StringName:
	return scene_id


func get_spawn_point() -> StringName:
	return spawn_point


func get_display_name() -> String:
	return display_name


func get_visual_texture_path() -> String:
	if _visual == null or _visual.texture == null:
		return ""
	return _visual.texture.resource_path


func get_activation_vfx_texture_path() -> String:
	if activation_vfx_texture == null:
		return ""
	return activation_vfx_texture.resource_path


func get_activation_vfx_snapshot() -> Dictionary:
	_prune_activation_vfx_nodes()
	return {
		"texture_path": get_activation_vfx_texture_path(),
		"active_count": _activation_vfx_nodes.size(),
		"duration_sec": activation_vfx_duration_sec,
		"elapsed_sec": _activation_vfx_elapsed_sec,
		"played": _activation_vfx_played,
		"spawn_count": _activation_vfx_spawn_count,
		"last_spawn": _last_activation_vfx_spawn.duplicate(true),
	}


func can_activate(body: Node) -> bool:
	if body == null or not is_instance_valid(body):
		return false
	if not body is Node2D:
		return false
	if get_savepoint_id() == &"" or scene_id == &"" or spawn_point == &"":
		return false
	return body.name == "Player" or body.has_method("respawn_at")


func try_activate(body: Node) -> bool:
	if not can_activate(body):
		return false
	var context: Dictionary = {
		"savepoint_id": String(get_savepoint_id()),
		"scene_id": String(scene_id),
		"spawn_point": String(spawn_point),
		"display_name": display_name,
		"position": {
			"x": global_position.x,
			"y": global_position.y,
		},
	}
	_spawn_activation_vfx()
	savepoint_activated.emit(
		get_savepoint_id(),
		scene_id,
		spawn_point,
		global_position,
		context
	)
	return true


func _on_body_entered(body: Node) -> void:
	try_activate(body)


func advance_activation_vfx_time(delta_sec: float) -> void:
	if _activation_vfx_nodes.is_empty():
		return
	_activation_vfx_elapsed_sec = minf(
		activation_vfx_duration_sec,
		_activation_vfx_elapsed_sec + maxf(0.0, delta_sec)
	)
	var progress: float = (
		1.0
		if activation_vfx_duration_sec <= 0.0
		else clampf(_activation_vfx_elapsed_sec / activation_vfx_duration_sec, 0.0, 1.0)
	)
	for vfx_node: Sprite2D in _activation_vfx_nodes:
		if not is_instance_valid(vfx_node):
			continue
		vfx_node.modulate.a = maxf(0.0, 1.0 - progress)
		var pulse_scale: float = 0.78 + (0.2 * progress)
		vfx_node.scale = Vector2(pulse_scale, pulse_scale)
	if progress >= 1.0:
		_clear_activation_vfx_nodes()


func _sync_visual_state() -> void:
	if _visual != null:
		_visual.visible = true
	if _prompt_label != null:
		_prompt_label.text = prompt_text
		_prompt_label.visible = not prompt_text.is_empty()
	if _interaction_area != null:
		_interaction_area.monitoring = true
		_interaction_area.monitorable = true


func _spawn_activation_vfx() -> void:
	if _activation_vfx_played or activation_vfx_texture == null:
		return
	_clear_activation_vfx_nodes()
	var vfx_node := Sprite2D.new()
	vfx_node.name = ACTIVATION_VFX_NODE_NAME
	vfx_node.texture = activation_vfx_texture
	vfx_node.centered = true
	vfx_node.position = Vector2(0.0, -18.0)
	vfx_node.scale = Vector2(0.78, 0.78)
	vfx_node.z_index = 9
	vfx_node.set_meta(&"asset_source", ACTIVATION_VFX_ASSET_SOURCE)
	vfx_node.set_meta(&"vfx_role", ACTIVATION_VFX_ROLE)
	vfx_node.set_meta(&"savepoint_id", String(get_savepoint_id()))
	vfx_node.set_meta(&"texture_path", get_activation_vfx_texture_path())
	add_child(vfx_node)
	_activation_vfx_nodes.append(vfx_node)
	_activation_vfx_elapsed_sec = 0.0
	_activation_vfx_played = true
	_activation_vfx_spawn_count += 1
	_last_activation_vfx_spawn = {
		"node_name": vfx_node.name,
		"asset_source": ACTIVATION_VFX_ASSET_SOURCE,
		"vfx_role": ACTIVATION_VFX_ROLE,
		"savepoint_id": String(get_savepoint_id()),
		"texture_path": get_activation_vfx_texture_path(),
		"duration_sec": activation_vfx_duration_sec,
		"position": vfx_node.position,
	}


func _clear_activation_vfx_nodes() -> void:
	for vfx_node: Sprite2D in _activation_vfx_nodes:
		if not is_instance_valid(vfx_node):
			continue
		if vfx_node.get_parent() == self:
			remove_child(vfx_node)
		vfx_node.free()
	_activation_vfx_nodes.clear()
	_activation_vfx_elapsed_sec = 0.0


func _prune_activation_vfx_nodes() -> void:
	var live_nodes: Array[Sprite2D] = []
	for vfx_node: Sprite2D in _activation_vfx_nodes:
		if is_instance_valid(vfx_node) and vfx_node.get_parent() == self:
			live_nodes.append(vfx_node)
	_activation_vfx_nodes = live_nodes
