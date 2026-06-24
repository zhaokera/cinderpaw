## Feature-layer SceneManager baseline.
##
## Story001 intentionally provides logical scene IDs, spawn tracking, scene-state
## caching, and boss-lock semantics. Story003 adds a threaded load request
## lifecycle with transition timing and timeout fallback. Story005 adds the
## optional runtime scene-root ownership seam that turns loaded PackedScenes into
## real scene-tree swaps when a scene root is configured.
extends Node

signal on_scene_loaded(scene_id: StringName)
signal on_scene_load_started(scene_id: StringName, spawn_point: StringName, metadata: Dictionary)
signal on_scene_changed(old_scene: StringName, new_scene: StringName)
signal on_scene_load_failed(scene_id: StringName, reason: StringName)

const SCENE_REGISTRY_DOMAIN: StringName = &"scene_registry"
const DEFAULT_SCENE_ID: StringName = &"hub"
const DEFAULT_SPAWN_POINT: StringName = &"default"
const SCENE_SAVE_KEY: StringName = &"scene"
const PACKED_SCENE_TYPE_HINT: String = "PackedScene"
const MIN_TRANSITION_SECONDS: float = 1.5
const LOAD_TIMEOUT_SECONDS: float = 10.0
const MAX_LOAD_RETRIES: int = 1
const DEFERRED_UNLOAD_SECONDS: float = 3.0
const MAX_RESIDENT_RUNTIME_SCENES: int = 2
const THREAD_LOAD_INVALID_RESOURCE: int = 0
const THREAD_LOAD_IN_PROGRESS: int = 1
const THREAD_LOAD_FAILED: int = 2
const THREAD_LOAD_LOADED: int = 3

var _scene_registry: Dictionary = {}
var _loaded_scenes: Dictionary = {}
var _scene_states: Dictionary = {}
var _current_scene_id: StringName = &""
var _current_spawn_point: StringName = DEFAULT_SPAWN_POINT
var _scene_locked: bool = false
var _loading: bool = false
var _pending_scene_id: StringName = &""
var _pending_spawn_point: StringName = DEFAULT_SPAWN_POINT
var _pending_scene_path: String = ""
var _loading_elapsed_seconds: float = 0.0
var _transition_elapsed_seconds: float = 0.0
var _load_retry_count: int = 0
var _last_load_error: StringName = &""
var _loader_adapter: Object = null
var _runtime_scene_root: Node = null
var _current_runtime_scene: Node = null
var _previous_runtime_scene: Node = null
var _previous_runtime_scene_id: StringName = &""
var _previous_runtime_scene_unload_seconds: float = 0.0
var _pending_reused_runtime_scene: Node = null


func _ready() -> void:
	load_scene_registry_from_data_manager()
	_register_with_root_save_system()


func _process(delta: float) -> void:
	advance_loading(delta)
	advance_deferred_unload(delta)


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
	_evict_previous_runtime_scene()
	_reset_pending_load()
	for scene_id: StringName in _scene_registry.keys():
		if bool(_scene_registry[scene_id].get("preload", false)):
			_loaded_scenes[scene_id] = true

	_current_scene_id = _select_initial_scene_id()
	_current_spawn_point = StringName(Dictionary(_scene_registry[_current_scene_id]).get(
		"default_spawn",
		String(DEFAULT_SPAWN_POINT)
	))
	return true


## Marks a scene as logically loaded. Async request ownership lives in
## request_scene_change().
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

	return _commit_logical_scene(scene_id, spawn_point)


## Injects a deterministic loader seam for tests. Passing null restores
## ResourceLoader-backed production behavior.
func set_loader_adapter(adapter: Object = null) -> void:
	_loader_adapter = adapter


## Configures the root that owns runtime scene instances. Passing the current
## scene node lets SceneManager save/detach it on the next async swap.
func configure_runtime_scene_root(root: Node, current_scene_node: Node = null) -> bool:
	if root == null or not is_instance_valid(root):
		return false
	if current_scene_node != null:
		if not is_instance_valid(current_scene_node):
			return false
		if current_scene_node.get_parent() != root:
			return false

	_evict_previous_runtime_scene()
	_pending_reused_runtime_scene = null
	_runtime_scene_root = root
	_current_runtime_scene = current_scene_node
	if _current_runtime_scene == null and root.get_child_count() > 0:
		_current_runtime_scene = root.get_child(0)
	return true


func is_runtime_scene_swap_enabled() -> bool:
	return _is_runtime_scene_swap_enabled()


func get_runtime_scene_root_node() -> Node:
	if _is_runtime_scene_swap_enabled():
		return _runtime_scene_root
	return null


func get_current_runtime_scene_node() -> Node:
	return _get_valid_current_runtime_scene()


func get_previous_runtime_scene_node() -> Node:
	return _get_valid_previous_runtime_scene()


func get_previous_runtime_scene_id() -> StringName:
	if _get_valid_previous_runtime_scene() == null:
		return &""
	return _previous_runtime_scene_id


func get_deferred_unload_remaining_seconds() -> float:
	if _get_valid_previous_runtime_scene() == null:
		return 0.0
	return _previous_runtime_scene_unload_seconds


func get_resident_runtime_scene_count() -> int:
	var resident_count: int = 0
	var current_scene: Node = _get_valid_current_runtime_scene()
	var previous_scene: Node = _get_valid_previous_runtime_scene()
	var reused_scene: Node = _get_valid_pending_reused_runtime_scene()
	if current_scene != null:
		resident_count += 1
	if previous_scene != null and previous_scene != current_scene:
		resident_count += 1
	if reused_scene != null and reused_scene != current_scene and reused_scene != previous_scene:
		resident_count += 1
	return resident_count


## Starts an asynchronous scene load request without immediately committing the
## logical scene. The request is completed by advance_loading().
func request_scene_change(
	scene_id: StringName,
	spawn_point: StringName = DEFAULT_SPAWN_POINT
) -> bool:
	if _scene_locked or _loading or not _scene_registry.has(scene_id):
		return false

	var config: Dictionary = Dictionary(_scene_registry[scene_id])
	var path: String = String(config.get("path", "")).strip_edges()
	if path.is_empty():
		return false

	_pending_scene_id = scene_id
	_pending_spawn_point = _resolve_spawn_point(scene_id, spawn_point)
	_pending_scene_path = path
	_loading_elapsed_seconds = 0.0
	_transition_elapsed_seconds = 0.0
	_load_retry_count = 0
	_last_load_error = &""
	_loading = true

	_pending_reused_runtime_scene = _take_previous_runtime_scene_for(scene_id)
	if _pending_reused_runtime_scene == null:
		var error: int = _issue_load_request(_pending_scene_path)
		if error != OK:
			_fail_pending_load(&"request_failed")
			return false
	on_scene_load_started.emit(scene_id, _pending_spawn_point, {
		"path": _pending_scene_path,
		"display_name": _display_name_for_scene(scene_id),
		"transition_duration_sec": MIN_TRANSITION_SECONDS,
		"cache_hit": _pending_reused_runtime_scene != null,
	})
	return true


## Advances the async loading state machine. Runtime calls this from _process();
## tests can drive it directly with deterministic deltas.
func advance_loading(delta_seconds: float) -> void:
	if not _loading:
		return

	var delta: float = maxf(delta_seconds, 0.0)
	_loading_elapsed_seconds += delta
	_transition_elapsed_seconds += delta

	if _get_valid_pending_reused_runtime_scene() != null:
		if _transition_elapsed_seconds >= MIN_TRANSITION_SECONDS:
			_finish_pending_load()
		return

	var status: int = _get_load_status(_pending_scene_path)
	if status == THREAD_LOAD_LOADED:
		if _transition_elapsed_seconds >= MIN_TRANSITION_SECONDS:
			_finish_pending_load()
		return

	if status == THREAD_LOAD_FAILED or status == THREAD_LOAD_INVALID_RESOURCE:
		_fail_pending_load(&"load_failed")
		return

	if _loading_elapsed_seconds >= LOAD_TIMEOUT_SECONDS:
		_handle_load_timeout()


func advance_deferred_unload(delta_seconds: float) -> void:
	var previous_scene: Node = _get_valid_previous_runtime_scene()
	if previous_scene == null:
		_clear_previous_runtime_scene_reference()
		return

	var delta: float = maxf(delta_seconds, 0.0)
	_previous_runtime_scene_unload_seconds = maxf(
		_previous_runtime_scene_unload_seconds - delta,
		0.0
	)
	if _previous_runtime_scene_unload_seconds <= 0.0:
		_evict_previous_runtime_scene()


func get_pending_scene() -> StringName:
	return _pending_scene_id


func get_pending_spawn_point() -> StringName:
	return _pending_spawn_point


func get_load_retry_count() -> int:
	return _load_retry_count


func get_last_load_error() -> StringName:
	return _last_load_error


func get_transition_elapsed_seconds() -> float:
	return _transition_elapsed_seconds


func get_loading_elapsed_seconds() -> float:
	return _loading_elapsed_seconds


func _commit_logical_scene(
	scene_id: StringName,
	spawn_point: StringName = DEFAULT_SPAWN_POINT
) -> bool:
	var old_scene: StringName = _current_scene_id
	if not preload_scene(scene_id):
		return false

	on_scene_loaded.emit(scene_id)
	_current_scene_id = scene_id
	_current_spawn_point = _resolve_spawn_point(scene_id, spawn_point)
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


func _finish_pending_load() -> void:
	var scene_id: StringName = _pending_scene_id
	var spawn_point: StringName = _pending_spawn_point
	var new_runtime_scene: Node = _consume_pending_reused_runtime_scene()
	var loaded_resource: Resource = null
	if new_runtime_scene == null:
		loaded_resource = _get_loaded_resource(_pending_scene_path)
	if _is_runtime_scene_swap_enabled():
		if new_runtime_scene == null:
			if not loaded_resource is PackedScene:
				_fail_pending_load(&"invalid_packed_scene", false)
				return
			var packed_scene: PackedScene = loaded_resource as PackedScene
			new_runtime_scene = packed_scene.instantiate()
		if new_runtime_scene == null:
			_fail_pending_load(&"instantiate_failed", false)
			return
		if not _swap_runtime_scene(scene_id, new_runtime_scene):
			new_runtime_scene.queue_free()
			_fail_pending_load(&"scene_swap_failed", false)
			return
	_reset_pending_load()
	_commit_logical_scene(scene_id, spawn_point)


func _handle_load_timeout() -> void:
	if _load_retry_count < MAX_LOAD_RETRIES:
		_load_retry_count += 1
		_loading_elapsed_seconds = 0.0
		var error: int = _issue_load_request(_pending_scene_path)
		if error != OK:
			_fail_pending_load(&"request_failed")
		return
	_fail_pending_load(&"timeout")


func _fail_pending_load(reason: StringName, fallback_to_default: bool = true) -> void:
	var failed_scene_id: StringName = _pending_scene_id
	_last_load_error = reason
	_reset_pending_load(false)
	on_scene_load_failed.emit(failed_scene_id, reason)
	if fallback_to_default:
		_fallback_to_default_scene()


func _fallback_to_default_scene() -> void:
	if not _scene_registry.has(DEFAULT_SCENE_ID):
		return
	var fallback_spawn: StringName = _get_default_spawn(DEFAULT_SCENE_ID)
	if _current_scene_id == DEFAULT_SCENE_ID and _current_spawn_point == fallback_spawn:
		return
	_commit_logical_scene(DEFAULT_SCENE_ID, fallback_spawn)


func _reset_pending_load(clear_last_error: bool = true) -> void:
	_loading = false
	_pending_scene_id = &""
	_pending_spawn_point = DEFAULT_SPAWN_POINT
	_pending_scene_path = ""
	_loading_elapsed_seconds = 0.0
	_transition_elapsed_seconds = 0.0
	_load_retry_count = 0
	_pending_reused_runtime_scene = null
	if clear_last_error:
		_last_load_error = &""


func _issue_load_request(path: String) -> int:
	if _loader_adapter != null and _loader_adapter.has_method("load_threaded_request"):
		return int(_loader_adapter.call(
			"load_threaded_request",
			path,
			PACKED_SCENE_TYPE_HINT,
			false,
			ResourceLoader.CACHE_MODE_REUSE
		))
	return ResourceLoader.load_threaded_request(
		path,
		PACKED_SCENE_TYPE_HINT,
		false,
		ResourceLoader.CACHE_MODE_REUSE
	)


func _get_load_status(path: String) -> int:
	var progress: Array = []
	if _loader_adapter != null and _loader_adapter.has_method("load_threaded_get_status"):
		return int(_loader_adapter.call("load_threaded_get_status", path, progress))
	return ResourceLoader.load_threaded_get_status(path, progress)


func _get_loaded_resource(path: String) -> Resource:
	if _loader_adapter != null and _loader_adapter.has_method("load_threaded_get"):
		var loaded_variant: Variant = _loader_adapter.call("load_threaded_get", path)
		if loaded_variant is Resource:
			return loaded_variant as Resource
		return null
	return ResourceLoader.load_threaded_get(path)


func _swap_runtime_scene(scene_id: StringName, new_runtime_scene: Node) -> bool:
	if not _is_runtime_scene_swap_enabled():
		return true
	if new_runtime_scene == null or not is_instance_valid(new_runtime_scene):
		return false

	_save_current_runtime_scene_state()
	var old_scene_id: StringName = _current_scene_id
	var old_runtime_scene: Node = _get_valid_current_runtime_scene()
	if old_runtime_scene != null and old_runtime_scene.get_parent() == _runtime_scene_root:
		_runtime_scene_root.remove_child(old_runtime_scene)
		_queue_previous_runtime_scene(old_scene_id, old_runtime_scene)

	_runtime_scene_root.add_child(new_runtime_scene)
	_current_runtime_scene = new_runtime_scene
	_restore_runtime_scene_state(scene_id, new_runtime_scene)
	return true


func _save_current_runtime_scene_state() -> void:
	var current_scene: Node = _get_valid_current_runtime_scene()
	if current_scene == null or _current_scene_id == &"":
		return
	if not current_scene.has_method("get_local_state"):
		return
	var state_variant: Variant = current_scene.call("get_local_state")
	if state_variant is Dictionary:
		_scene_states[_current_scene_id] = Dictionary(state_variant).duplicate(true)


func _restore_runtime_scene_state(scene_id: StringName, runtime_scene: Node) -> void:
	if runtime_scene == null or not is_instance_valid(runtime_scene):
		return
	if not runtime_scene.has_method("set_local_state"):
		return
	if not _scene_states.has(scene_id):
		return
	runtime_scene.call("set_local_state", Dictionary(_scene_states[scene_id]).duplicate(true))


func _is_runtime_scene_swap_enabled() -> bool:
	return _runtime_scene_root != null and is_instance_valid(_runtime_scene_root)


func _is_runtime_scene_node_valid(scene: Variant) -> bool:
	if scene == null:
		return false
	if not is_instance_valid(scene):
		return false
	if not scene is Node:
		return false
	var node: Node = scene as Node
	return not node.is_queued_for_deletion()


func _get_valid_current_runtime_scene() -> Node:
	if _is_runtime_scene_node_valid(_current_runtime_scene):
		return _current_runtime_scene
	return null


func _get_valid_previous_runtime_scene() -> Node:
	if _is_runtime_scene_node_valid(_previous_runtime_scene):
		return _previous_runtime_scene
	return null


func _get_valid_pending_reused_runtime_scene() -> Node:
	if _is_runtime_scene_node_valid(_pending_reused_runtime_scene):
		return _pending_reused_runtime_scene
	return null


func _queue_previous_runtime_scene(scene_id: StringName, scene: Node) -> void:
	if not _is_runtime_scene_node_valid(scene):
		return
	_evict_previous_runtime_scene()
	_previous_runtime_scene = scene
	_previous_runtime_scene_id = scene_id
	_previous_runtime_scene_unload_seconds = DEFERRED_UNLOAD_SECONDS


func _take_previous_runtime_scene_for(scene_id: StringName) -> Node:
	var previous_scene: Node = _get_valid_previous_runtime_scene()
	if previous_scene == null:
		_clear_previous_runtime_scene_reference()
		return null
	if _previous_runtime_scene_id != scene_id:
		return null

	_previous_runtime_scene = null
	_previous_runtime_scene_id = &""
	_previous_runtime_scene_unload_seconds = 0.0
	return previous_scene


func _consume_pending_reused_runtime_scene() -> Node:
	var reused_scene: Node = _get_valid_pending_reused_runtime_scene()
	_pending_reused_runtime_scene = null
	return reused_scene


func _evict_previous_runtime_scene() -> void:
	var previous_scene: Node = _get_valid_previous_runtime_scene()
	if previous_scene != null:
		previous_scene.queue_free()
	_clear_previous_runtime_scene_reference()


func _clear_previous_runtime_scene_reference() -> void:
	_previous_runtime_scene = null
	_previous_runtime_scene_id = &""
	_previous_runtime_scene_unload_seconds = 0.0


func _resolve_spawn_point(scene_id: StringName, spawn_point: StringName) -> StringName:
	if spawn_point != &"":
		return spawn_point
	return _get_default_spawn(scene_id)


func _get_default_spawn(scene_id: StringName) -> StringName:
	if not _scene_registry.has(scene_id):
		return DEFAULT_SPAWN_POINT
	return StringName(Dictionary(_scene_registry[scene_id]).get(
		"default_spawn",
		String(DEFAULT_SPAWN_POINT)
	))


func _display_name_for_scene(scene_id: StringName) -> String:
	match scene_id:
		&"hub":
			return "Clan Base"
		&"main":
			return "Scrap Alley"
		_:
			var words: PackedStringArray = String(scene_id).replace("_", " ").split(" ", false)
			for index: int in range(words.size()):
				words[index] = words[index].capitalize()
			return " ".join(words)


func _register_with_root_save_system() -> void:
	if not is_inside_tree() or get_parent() != get_tree().root:
		return
	var save_system: Node = get_tree().root.get_node_or_null("SaveSystem")
	if save_system == null or not save_system.has_method("register_serializable"):
		return
	save_system.call("register_serializable", self, SCENE_SAVE_KEY)
