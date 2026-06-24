class_name SaveInfo
extends RefCounted

## Slot number represented by this metadata object.
var slot: int = -1
## Whether this slot is the reserved autosave slot.
var is_auto: bool:
	get:
		return slot == 0
## Whether a valid save file exists for this slot.
var exists: bool = false
## ISO-like timestamp written in the save metadata.
var timestamp: String = ""
## Total play time in seconds.
var play_time_sec: float = 0.0
## Save point name shown by UI surfaces.
var save_point_name: String = ""
## Save data format version.
var version: int = 0
## UI-safe player/world summary data.
var summary: Dictionary = {}
## Backing save file size in bytes.
var file_size_bytes: int = 0


func _init(p_slot: int = -1) -> void:
	slot = p_slot


## Converts this metadata to a JSON-safe dictionary for tests and UI adapters.
func to_dictionary() -> Dictionary:
	return {
		"slot": slot,
		"is_auto": is_auto,
		"exists": exists,
		"timestamp": timestamp,
		"play_time_sec": play_time_sec,
		"save_point_name": save_point_name,
		"version": version,
		"summary": summary.duplicate(true),
		"file_size_bytes": file_size_bytes,
	}
