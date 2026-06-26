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

@export var savepoint_id: StringName = &""
@export var scene_id: StringName = &""
@export var spawn_point: StringName = &""
@export var display_name: String = "Savepoint"
@export var prompt_text: String = "Savepoint"

@onready var _visual: Sprite2D = get_node_or_null("Visual") as Sprite2D
@onready var _prompt_label: Label = get_node_or_null("PromptLabel") as Label
@onready var _interaction_area: Area2D = get_node_or_null("InteractionArea") as Area2D


func _ready() -> void:
	add_to_group(GROUP_NAME)
	_sync_visual_state()
	if _interaction_area != null and not _interaction_area.body_entered.is_connected(_on_body_entered):
		_interaction_area.body_entered.connect(_on_body_entered)


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


func _sync_visual_state() -> void:
	if _visual != null:
		_visual.visible = true
	if _prompt_label != null:
		_prompt_label.text = prompt_text
		_prompt_label.visible = not prompt_text.is_empty()
	if _interaction_area != null:
		_interaction_area.monitoring = true
		_interaction_area.monitorable = true
