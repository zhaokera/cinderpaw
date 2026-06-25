extends Node2D

var local_state: Dictionary = {}
var applied_states: Array[Dictionary] = []
var estimated_memory_bytes: int = 0


func get_local_state() -> Dictionary:
	return local_state.duplicate(true)


func set_local_state(state: Dictionary) -> void:
	local_state = state.duplicate(true)
	applied_states.append(state.duplicate(true))


func get_estimated_memory_bytes() -> int:
	return estimated_memory_bytes
