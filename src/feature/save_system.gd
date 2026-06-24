## Feature-layer SaveSystem for JSON slot persistence.
extends Node

signal on_save_written(slot: int)
signal on_save_loaded(slot: int)
signal on_save_corrupted(slot: int, reason: String)
signal on_save_load_failed(slot: int, reason: String)

const CURRENT_SAVE_VERSION: int = 1
const AUTOSAVE_SLOT: int = 0
const MAX_SLOT: int = 3
const DEFAULT_SAVE_DIRECTORY: String = "user://saves/"

var _save_directory: String = DEFAULT_SAVE_DIRECTORY
var _serializables: Array[Dictionary] = []
var _last_loaded_data: Dictionary = {}
var _last_load_from_backup: bool = false


func configure_save_directory(save_directory: String) -> void:
	if save_directory.is_empty():
		_save_directory = DEFAULT_SAVE_DIRECTORY
	else:
		_save_directory = save_directory
	if not _save_directory.ends_with("/"):
		_save_directory += "/"
	_ensure_save_directory()


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


func unregister_serializable(save_key: StringName) -> bool:
	for index: int in range(_serializables.size()):
		if _serializables[index]["key"] == save_key:
			_serializables.remove_at(index)
			return true
	return false


func manual_save(slot: int, player_state: Dictionary = {}, world_state: Dictionary = {}, settings: Dictionary = {}) -> bool:
	if slot == AUTOSAVE_SLOT:
		return false
	return _execute_save(slot, false, player_state, world_state, settings)


func auto_save(player_state: Dictionary = {}, world_state: Dictionary = {}, settings: Dictionary = {}) -> bool:
	return _execute_save(AUTOSAVE_SLOT, true, player_state, world_state, settings)


func save_game(slot: int, player_state: Dictionary = {}, world_state: Dictionary = {}, settings: Dictionary = {}) -> bool:
	return manual_save(slot, player_state, world_state, settings)


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

	var version: int = int(Dictionary(loaded.get("_meta", {})).get("version", CURRENT_SAVE_VERSION))
	_deserialize_registered_systems(Dictionary(loaded.get("systems", {})), version)
	_last_loaded_data = loaded.duplicate(true)
	on_save_loaded.emit(slot)
	return true


func has_save(slot: int) -> bool:
	if not _is_valid_slot(slot):
		return false
	return FileAccess.file_exists(_slot_path(slot))


func get_last_loaded_data() -> Dictionary:
	return _last_loaded_data.duplicate(true)


func was_last_load_from_backup() -> bool:
	return _last_load_from_backup


func get_save_directory() -> String:
	return _save_directory


func _execute_save(slot: int, is_auto: bool, player_state: Dictionary, world_state: Dictionary, settings: Dictionary) -> bool:
	if not _is_valid_slot(slot):
		return false
	_ensure_save_directory()
	var save_data: Dictionary = _build_save_data(
		slot,
		is_auto,
		player_state,
		world_state,
		settings
	)
	if not _write_slot_file(slot, save_data):
		return false
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


func _deserialize_registered_systems(systems_data: Dictionary, version: int) -> void:
	for entry: Dictionary in _serializables:
		var key: String = String(entry["key"])
		var system: Object = entry["system"]
		if system == null or not is_instance_valid(system) or not system.has_method("deserialize"):
			continue
		if systems_data.has(key) and systems_data[key] is Dictionary:
			system.call("deserialize", Dictionary(systems_data[key]).duplicate(true), version)


func _write_slot_file(slot: int, save_data: Dictionary) -> bool:
	var slot_path: String = _slot_path(slot)
	var backup_path: String = _backup_path(slot)
	if FileAccess.file_exists(slot_path):
		var old_content: String = FileAccess.get_file_as_string(slot_path)
		if not old_content.is_empty():
			if not _write_text_file(backup_path, old_content):
				return false
	var json_string: String = JSON.stringify(save_data, "\t")
	if not _write_text_file(slot_path, json_string):
		return false
	return not _read_valid_save(slot_path).is_empty()


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


func _ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(_save_directory):
		DirAccess.make_dir_recursive_absolute(_save_directory)


func _is_valid_slot(slot: int) -> bool:
	return slot >= AUTOSAVE_SLOT and slot <= MAX_SLOT


func _slot_path(slot: int) -> String:
	return "%sslot_%d.json" % [_save_directory, slot]


func _backup_path(slot: int) -> String:
	return "%sslot_%d.json.bak" % [_save_directory, slot]
