## Feature-layer SaveSystem for JSON slot persistence.
extends Node

const SaveInfoResource: Script = preload("res://src/feature/save_info.gd")

signal on_save_written(slot: int)
signal on_save_loaded(slot: int)
signal on_save_corrupted(slot: int, reason: String)
signal on_save_load_failed(slot: int, reason: String)
signal on_save_write_failed(slot: int, reason: String)

const CURRENT_SAVE_VERSION: int = 1
const AUTOSAVE_SLOT: int = 0
const MAX_SLOT: int = 3
const DEFAULT_SAVE_DIRECTORY: String = "user://saves/"

var _save_directory: String = DEFAULT_SAVE_DIRECTORY
var _serializables: Array[Dictionary] = []
var _migrations: Dictionary = {}
var _last_loaded_data: Dictionary = {}
var _last_load_from_backup: bool = false
var _async_write_enabled: bool = true
var _last_save_dispatch_duration_msec: float = 0.0
var _write_thread: Thread
var _write_mutex: Mutex = Mutex.new()
var _write_pending: bool = false
var _write_result_ready: bool = false
var _write_result: Dictionary = {}


func _process(_delta: float) -> void:
	_poll_async_write_result()


func _exit_tree() -> void:
	if not flush_pending_save_write(1000) and _write_thread != null:
		_write_thread.wait_to_finish()
	_poll_async_write_result()


## Configures the save directory used by this SaveSystem instance.
func configure_save_directory(save_directory: String) -> void:
	if save_directory.is_empty():
		_save_directory = DEFAULT_SAVE_DIRECTORY
	else:
		_save_directory = save_directory
	if not _save_directory.ends_with("/"):
		_save_directory += "/"
	_ensure_save_directory()


## Registers a serializable system under a unique save key.
func register_serializable(system: Object, save_key: StringName) -> bool:
	if system == null or save_key == &"":
		return false
	for entry: Dictionary in _serializables:
		if entry["key"] == save_key:
			return false
	_serializables.append({
		"key": save_key,
		"system": system,
	})
	return true


## Unregisters a serializable system by save key.
func unregister_serializable(save_key: StringName) -> bool:
	for index: int in range(_serializables.size()):
		if _serializables[index]["key"] == save_key:
			_serializables.remove_at(index)
			return true
	return false


## Registers a migration callback from one save format version to the next.
func register_migration(from_version: int, migration: Callable) -> bool:
	if from_version < 0 or from_version >= CURRENT_SAVE_VERSION:
		return false
	if not migration.is_valid() or _migrations.has(from_version):
		return false
	_migrations[from_version] = migration
	return true


## Unregisters a previously registered migration callback.
func unregister_migration(from_version: int) -> bool:
	if not _migrations.has(from_version):
		return false
	_migrations.erase(from_version)
	return true


## Enables or disables async save writes. Disabled mode uses the sync fallback.
func set_async_write_enabled(enabled: bool) -> void:
	_async_write_enabled = enabled


## Returns whether an async save write is awaiting main-thread completion.
func is_save_write_pending() -> bool:
	return _write_pending


## Returns the duration of the last save dispatch call in milliseconds.
func get_last_save_dispatch_duration_msec() -> float:
	return _last_save_dispatch_duration_msec


## Waits briefly for a pending async write to finish and emit completion.
func flush_pending_save_write(timeout_msec: int = 500) -> bool:
	var deadline_msec: int = Time.get_ticks_msec() + maxi(0, timeout_msec)
	while _write_pending and Time.get_ticks_msec() <= deadline_msec:
		_poll_async_write_result()
		if _write_pending:
			OS.delay_msec(1)
	_poll_async_write_result()
	return not _write_pending


## Writes a manual save to slots 1-3. Slot 0 is reserved for autosave.
func manual_save(slot: int, player_state: Dictionary = {}, world_state: Dictionary = {}, settings: Dictionary = {}) -> bool:
	if slot == AUTOSAVE_SLOT:
		return false
	return _execute_save(slot, false, player_state, world_state, settings)


## Writes the reserved autosave slot.
func auto_save(player_state: Dictionary = {}, world_state: Dictionary = {}, settings: Dictionary = {}) -> bool:
	return _execute_save(AUTOSAVE_SLOT, true, player_state, world_state, settings)


## Compatibility wrapper for manual save callers.
func save_game(slot: int, player_state: Dictionary = {}, world_state: Dictionary = {}, settings: Dictionary = {}) -> bool:
	return manual_save(slot, player_state, world_state, settings)


## Loads one save slot and deserializes all registered systems.
func load_game(slot: int) -> bool:
	_last_loaded_data = {}
	_last_load_from_backup = false
	if not _is_valid_slot(slot):
		on_save_load_failed.emit(slot, "invalid_slot")
		return false

	var loaded: Dictionary = _read_valid_save(_slot_path(slot))
	if loaded.is_empty():
		loaded = _read_valid_save(_backup_path(slot))
		if loaded.is_empty():
			on_save_load_failed.emit(slot, "unrecoverable_save")
			return false
		_last_load_from_backup = true
		on_save_corrupted.emit(slot, "main_save_recovered_from_backup")

	var original_version: int = int(Dictionary(loaded.get("_meta", {})).get("version", CURRENT_SAVE_VERSION))
	var migrated: Dictionary = _migrate_save_data(loaded, original_version)
	if migrated.is_empty():
		on_save_load_failed.emit(slot, "migration_failed")
		return false

	if original_version < CURRENT_SAVE_VERSION:
		if not _write_slot_file_sync(slot, migrated):
			on_save_load_failed.emit(slot, "migration_write_failed")
			return false

	_deserialize_registered_systems(Dictionary(migrated.get("systems", {})), original_version)
	_last_loaded_data = migrated.duplicate(true)
	on_save_loaded.emit(slot)
	return true


## Returns whether a valid slot file exists.
func has_save(slot: int) -> bool:
	if not _is_valid_slot(slot):
		return false
	return FileAccess.file_exists(_slot_path(slot))


## Returns UI-safe metadata for one slot without owning save-file rules in UI.
func get_save_info(slot: int) -> RefCounted:
	var info: RefCounted = SaveInfoResource.new(slot)
	if not _is_valid_slot(slot):
		return info

	var path: String = _slot_path(slot)
	var data: Dictionary = _read_valid_save(path)
	if data.is_empty():
		path = _backup_path(slot)
		data = _read_valid_save(path)
	if data.is_empty():
		return info

	var meta: Dictionary = Dictionary(data.get("_meta", {}))
	info.exists = true
	info.timestamp = String(meta.get("timestamp", ""))
	info.play_time_sec = float(meta.get("play_time_sec", 0.0))
	info.save_point_name = String(meta.get("save_point_name", ""))
	info.version = int(meta.get("version", 0))
	info.summary = Dictionary(meta.get("summary", {})).duplicate(true)
	info.file_size_bytes = _get_file_size_bytes(path)
	return info


## Reads and migrates a valid save snapshot without mutating runtime systems.
##
## Title/bootstrap callers use this to resolve a scene target before committing
## a real load. The method intentionally emits no signals, does not update
## _last_loaded_data, does not deserialize registered systems, and does not
## rewrite migrated data to disk.
func peek_save_data(slot: int) -> Dictionary:
	if not _is_valid_slot(slot):
		return {}
	var loaded: Dictionary = _read_valid_save(_slot_path(slot))
	if loaded.is_empty():
		loaded = _read_valid_save(_backup_path(slot))
	if loaded.is_empty():
		return {}
	var original_version: int = int(
		Dictionary(loaded.get("_meta", {})).get("version", CURRENT_SAVE_VERSION)
	)
	var migrated: Dictionary = _migrate_save_data(loaded, original_version)
	return migrated.duplicate(true)


## Returns the last successfully loaded save data.
func get_last_loaded_data() -> Dictionary:
	return _last_loaded_data.duplicate(true)


## Returns whether the last load used a backup file.
func was_last_load_from_backup() -> bool:
	return _last_load_from_backup


## Returns the currently configured save directory.
func get_save_directory() -> String:
	return _save_directory


func _execute_save(slot: int, is_auto: bool, player_state: Dictionary, world_state: Dictionary, settings: Dictionary) -> bool:
	var dispatch_start_usec: int = Time.get_ticks_usec()
	if not _is_valid_slot(slot):
		_last_save_dispatch_duration_msec = _elapsed_msec(dispatch_start_usec)
		return false
	_ensure_save_directory()
	var save_data: Dictionary = _build_save_data(
		slot,
		is_auto,
		player_state,
		world_state,
		settings
	)
	if not _dispatch_slot_write(slot, save_data):
		_last_save_dispatch_duration_msec = _elapsed_msec(dispatch_start_usec)
		return false
	_last_save_dispatch_duration_msec = _elapsed_msec(dispatch_start_usec)
	if not _async_write_enabled:
		on_save_written.emit(slot)
	return true


func _build_save_data(slot: int, is_auto: bool, player_state: Dictionary, world_state: Dictionary, settings: Dictionary) -> Dictionary:
	return {
		"_meta": {
			"version": CURRENT_SAVE_VERSION,
			"timestamp": Time.get_datetime_string_from_system(true),
			"play_time_sec": 0.0,
			"slot": slot,
			"is_auto": is_auto,
			"save_point_name": "Autosave" if is_auto else "Manual Save",
			"engine_version": Engine.get_version_info().get("string", ""),
			"summary": _build_summary(player_state, world_state),
		},
		"player_state": player_state.duplicate(true),
		"world_state": world_state.duplicate(true),
		"settings": settings.duplicate(true),
		"systems": _serialize_registered_systems(),
	}


func _serialize_registered_systems() -> Dictionary:
	var systems_data: Dictionary = {}
	for entry: Dictionary in _serializables:
		var key: StringName = entry["key"]
		var system: Object = entry["system"]
		if system == null or not is_instance_valid(system) or not system.has_method("serialize"):
			continue
		var payload: Variant = system.call("serialize")
		if payload is Dictionary:
			systems_data[String(key)] = Dictionary(payload).duplicate(true)
	return systems_data


func _migrate_save_data(data: Dictionary, from_version: int) -> Dictionary:
	if from_version > CURRENT_SAVE_VERSION:
		return {}

	var current: Dictionary = data.duplicate(true)
	var version: int = from_version
	while version < CURRENT_SAVE_VERSION:
		if not _migrations.has(version):
			return {}
		var migrated: Variant = Callable(_migrations[version]).call(current.duplicate(true))
		if not migrated is Dictionary:
			return {}
		current = Dictionary(migrated).duplicate(true)
		if not current.has("_meta") or not current["_meta"] is Dictionary:
			return {}
		current["_meta"]["version"] = version + 1
		version += 1
	current["_meta"]["version"] = CURRENT_SAVE_VERSION
	return current


func _deserialize_registered_systems(systems_data: Dictionary, version: int) -> void:
	for entry: Dictionary in _serializables:
		var key: String = String(entry["key"])
		var system: Object = entry["system"]
		if system == null or not is_instance_valid(system) or not system.has_method("deserialize"):
			continue
		if systems_data.has(key) and systems_data[key] is Dictionary:
			system.call("deserialize", Dictionary(systems_data[key]).duplicate(true), version)


func _dispatch_slot_write(slot: int, save_data: Dictionary) -> bool:
	if not _async_write_enabled:
		return _write_slot_file_sync(slot, save_data)
	return _write_slot_file_async(slot, save_data)


func _write_slot_file_sync(slot: int, save_data: Dictionary) -> bool:
	var slot_path: String = _slot_path(slot)
	var backup_path: String = _backup_path(slot)
	var json_string: String = JSON.stringify(save_data, "\t")
	var result: Dictionary = _write_slot_paths_sync(slot_path, backup_path, json_string)
	return bool(result.get("success", false))


func _write_slot_file_async(slot: int, save_data: Dictionary) -> bool:
	if _write_pending:
		on_save_write_failed.emit(slot, "write_pending")
		return false
	var slot_path: String = _slot_path(slot)
	var backup_path: String = _backup_path(slot)
	var json_string: String = JSON.stringify(save_data, "\t")
	_write_pending = true
	_write_result_ready = false
	_write_result = {}
	if OS.has_feature("web"):
		call_deferred("_complete_deferred_slot_write", slot, slot_path, backup_path, json_string)
		return true
	_write_thread = Thread.new()
	var error: Error = _write_thread.start(
		Callable(self, "_write_slot_thread").bind(slot, slot_path, backup_path, json_string)
	)
	if error != OK:
		_write_pending = false
		_write_result = {}
		push_error("SaveSystem: failed to start async write thread: %d" % int(error))
		return false
	return true


func _write_slot_thread(slot: int, slot_path: String, backup_path: String, json_string: String) -> void:
	var result: Dictionary = _write_slot_paths_sync(slot_path, backup_path, json_string)
	result["slot"] = slot
	_write_mutex.lock()
	_write_result = result
	_write_result_ready = true
	_write_mutex.unlock()


func _complete_deferred_slot_write(slot: int, slot_path: String, backup_path: String, json_string: String) -> void:
	var result: Dictionary = _write_slot_paths_sync(slot_path, backup_path, json_string)
	result["slot"] = slot
	_write_mutex.lock()
	_write_result = result
	_write_result_ready = true
	_write_mutex.unlock()
	_poll_async_write_result()


func _write_slot_paths_sync(slot_path: String, backup_path: String, json_string: String) -> Dictionary:
	if FileAccess.file_exists(slot_path):
		var old_content: String = FileAccess.get_file_as_string(slot_path)
		if not old_content.is_empty():
			if not _write_text_file(backup_path, old_content):
				return {"success": false, "reason": "backup_write_failed"}
	if not _write_text_file(slot_path, json_string):
		return {"success": false, "reason": "slot_write_failed"}
	if _read_valid_save(slot_path).is_empty():
		return {"success": false, "reason": "slot_validation_failed"}
	return {"success": true, "reason": ""}


func _poll_async_write_result() -> void:
	if not _write_pending:
		return
	_write_mutex.lock()
	var has_result: bool = _write_result_ready
	var result: Dictionary = _write_result.duplicate(true)
	if has_result:
		_write_result_ready = false
		_write_result = {}
	_write_mutex.unlock()
	if not has_result:
		return
	if _write_thread != null:
		_write_thread.wait_to_finish()
		_write_thread = null
	_write_pending = false
	var slot: int = int(result.get("slot", -1))
	if bool(result.get("success", false)):
		on_save_written.emit(slot)
	else:
		on_save_write_failed.emit(slot, String(result.get("reason", "write_failed")))


func _read_valid_save(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var content: String = FileAccess.get_file_as_string(path)
	var parser: JSON = JSON.new()
	if parser.parse(content) != OK:
		return {}
	var parsed: Variant = parser.data
	if not parsed is Dictionary:
		return {}
	var data: Dictionary = Dictionary(parsed)
	if not _validate_save_structure(data):
		return {}
	return data


func _validate_save_structure(data: Dictionary) -> bool:
	if not data.has("_meta") or not data["_meta"] is Dictionary:
		return false
	var meta: Dictionary = Dictionary(data["_meta"])
	if not meta.has("version"):
		return false
	if int(meta["version"]) > CURRENT_SAVE_VERSION:
		return false
	return data.has("player_state") and data.has("world_state") and data.has("settings") and data.has("systems")


func _build_summary(player_state: Dictionary, world_state: Dictionary) -> Dictionary:
	var summary: Dictionary = {}
	for key: String in ["current_hp", "max_hp", "current_weapon", "currency", "scene_id"]:
		if player_state.has(key):
			summary[key] = player_state[key]
	if world_state.has("defeated_bosses"):
		summary["defeated_bosses"] = world_state["defeated_bosses"]
	return summary


func _write_text_file(path: String, content: String) -> bool:
	var dir_path: String = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		var err: Error = DirAccess.make_dir_recursive_absolute(dir_path)
		if err != OK:
			return false
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(content)
	file.close()
	return FileAccess.file_exists(path)


func _get_file_size_bytes(path: String) -> int:
	if not FileAccess.file_exists(path):
		return 0
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return 0
	var size: int = int(file.get_length())
	file.close()
	return size


func _ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(_save_directory):
		DirAccess.make_dir_recursive_absolute(_save_directory)


func _is_valid_slot(slot: int) -> bool:
	return slot >= AUTOSAVE_SLOT and slot <= MAX_SLOT


func _slot_path(slot: int) -> String:
	return "%sslot_%d.json" % [_save_directory, slot]


func _backup_path(slot: int) -> String:
	return "%sslot_%d.json.bak" % [_save_directory, slot]


func _elapsed_msec(start_usec: int) -> float:
	return float(Time.get_ticks_usec() - start_usec) / 1000.0
