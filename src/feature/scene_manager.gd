## Feature-layer SceneManager baseline.
##
## Story001 intentionally provides logical scene IDs, spawn tracking, scene-state
## caching, and boss-lock semantics without swapping the live scene tree yet.
extends Node

signal on_scene_loaded(scene_id: StringName)
signal on_scene_changed(old_scene: StringName, new_scene: StringName)

const SCENE_REGISTRY_DOMAIN: StringName = &"scene_registry"
const DEFAULT_SCENE_ID: StringName = &"hub"
const DEFAULT_SPAWN_POINT: StringName = &"default"
const SCENE_SAVE_KEY: StringName = &"scene"

var _scene_registry: Dictionary = {}
var _loaded_scenes: Dictionary = {}
var _scene_states: Dictionary = {}
var _current_scene_id: StringName = &""
var _current_spawn_point: StringName = DEFAULT_SPAWN_POINT
var _scene_locked: bool = false
var _loading: bool = false


func _ready() -> void:
	load_scene_registry_from_data_manager()
	_register_with_root_save_system()


## Loads the project scene registry through DataManager or an injected adapter.
func load_scene_registry_from_data_manager(data_manager: Object = null) -> bool:
	var source: Object = data_manager
	if source == null and is_inside_tree():
		source = get_tree().root.get_node_or_null("DataManager")
	if source == null or not source.has_method("get_domain"):
		return false

	var registry_variant: Variant = source.call("get_domain", SCENE_REGISTRY_DOMAIN)
	if not registry_variant is Dictionary:
		return false
	return configure_scene_registry(registry_variant as Dictionary)


## Configures a scene registry dictionary keyed by scene_id.
func configure_scene_registry(registry_data: Dictionary) -> bool:
	var entries_variant: Variant = registry_data.get("entries", registry_data)
	if not entries_variant is Dictionary:
		return false
	var entries: Dictionary = entries_variant as Dictionary
	var normalized: Dictionary = {}

	for key: Variant in entries.keys():
		var scene_id: StringName = StringName(key)
		var config_variant: Variant = entries[key]
		if scene_id == &"" or not config_variant is Dictionary:
			return false
		var config: Dictionary = config_variant as Dictionary
		var config_scene_id: StringName = StringName(config.get("scene_id", String(scene_id)))
		var path: String = String(config.get("path", "")).strip_edges()
		var type_name: String = String(config.get("type", "")).strip_edges()
		if config_scene_id != scene_id or path.is_empty() or type_name.is_empty():
			return false
		if not FileAccess.file_exists(path):
			return false
		normalized[scene_id] = {
			"scene_id": String(scene_id),
			"path": path,
			"type": type_name,
			"preload": bool(config.get("preload", false)),
			"default_spawn": String(config.get("default_spawn", String(DEFAULT_SPAWN_POINT))),
		}

	if normalized.is_empty():
		return false

	_scene_registry = normalized
	_loaded_scenes.clear()
	_scene_states.clear()
	for scene_id: StringName in _scene_registry.keys():
		if bool(_scene_registry[scene_id].get("preload", false)):
			_loaded_scenes[scene_id] = true

	_current_scene_id = _select_initial_scene_id()
	_current_spawn_point = StringName(Dictionary(_scene_registry[_current_scene_id]).get(
		"default_spawn",
		String(DEFAULT_SPAWN_POINT)
	))
	return true


## Marks a scene as logically loaded. Real threaded loading is a later story.
func preload_scene(scene_id: StringName) -> bool:
	if not _scene_registry.has(scene_id):
		return false
	_loaded_scenes[scene_id] = true
	return true


func is_scene_loaded(scene_id: StringName) -> bool:
	return _loaded_scenes.has(scene_id)


## Performs a logical scene transition and emits SceneManager boundary signals.
func change_scene(scene_id: StringName, spawn_point: StringName = DEFAULT_SPAWN_POINT) -> bool:
	if _scene_locked or _loading or not _scene_registry.has(scene_id):
		return false

	var old_scene: StringName = _current_scene_id
	if not preload_scene(scene_id):
		return false

	on_scene_loaded.emit(scene_id)
	_current_scene_id = scene_id
	if spawn_point == &"":
		_current_spawn_point = StringName(Dictionary(_scene_registry[scene_id]).get(
			"default_spawn",
			String(DEFAULT_SPAWN_POINT)
		))
	else:
		_current_spawn_point = spawn_point
	on_scene_changed.emit(old_scene, scene_id)
	return true


func get_current_scene() -> StringName:
	return _current_scene_id


func get_current_spawn_point() -> StringName:
	return _current_spawn_point


func has_scene(scene_id: StringName) -> bool:
	return _scene_registry.has(scene_id)


func get_scene_config(scene_id: StringName) -> Dictionary:
	if not _scene_registry.has(scene_id):
		return {}
	return Dictionary(_scene_registry[scene_id]).duplicate(true)


func set_scene_state(scene_id: StringName, state: Dictionary) -> bool:
	if not _scene_registry.has(scene_id):
		return false
	_scene_states[scene_id] = state.duplicate(true)
	return true


func get_scene_state(scene_id: StringName) -> Dictionary:
	if not _scene_states.has(scene_id):
		return {}
	return Dictionary(_scene_states[scene_id]).duplicate(true)


func lock_scene() -> void:
	_scene_locked = true


func unlock_scene() -> void:
	_scene_locked = false


func is_scene_locked() -> bool:
	return _scene_locked


func is_loading() -> bool:
	return _loading


func serialize() -> Dictionary:
	var serialized_states: Dictionary = {}
	for scene_key: Variant in _scene_states.keys():
		serialized_states[String(scene_key)] = Dictionary(_scene_states[scene_key]).duplicate(true)
	return {
		"current_scene_id": String(_current_scene_id),
		"current_spawn_point": String(_current_spawn_point),
		"scene_states": serialized_states,
	}


func deserialize(data: Dictionary, _version: int = 0) -> void:
	var saved_scene: StringName = StringName(data.get("current_scene_id", String(_current_scene_id)))
	if _scene_registry.has(saved_scene):
		_current_scene_id = saved_scene
		_loaded_scenes[_current_scene_id] = true

	var saved_spawn: StringName = StringName(data.get("current_spawn_point", String(_current_spawn_point)))
	if saved_spawn != &"":
		_current_spawn_point = saved_spawn

	_scene_states.clear()
	var states_variant: Variant = data.get("scene_states", {})
	if not states_variant is Dictionary:
		return
	var states: Dictionary = states_variant as Dictionary
	for key: Variant in states.keys():
		var scene_id: StringName = StringName(key)
		if _scene_registry.has(scene_id) and states[key] is Dictionary:
			_scene_states[scene_id] = Dictionary(states[key]).duplicate(true)


func _select_initial_scene_id() -> StringName:
	if _scene_registry.has(DEFAULT_SCENE_ID):
		return DEFAULT_SCENE_ID
	for scene_id: StringName in _scene_registry.keys():
		return scene_id
	return &""


func _register_with_root_save_system() -> void:
	if not is_inside_tree() or get_parent() != get_tree().root:
		return
	var save_system: Node = get_tree().root.get_node_or_null("SaveSystem")
	if save_system == null or not save_system.has_method("register_serializable"):
		return
	save_system.call("register_serializable", self, SCENE_SAVE_KEY)
