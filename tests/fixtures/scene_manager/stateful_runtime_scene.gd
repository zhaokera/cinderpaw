extends Node2D

var local_state: Dictionary = {}
var applied_states: Array[Dictionary] = []


func get_local_state() -> Dictionary:
	return local_state.duplicate(true)


func set_local_state(state: Dictionary) -> void:
	local_state = state.duplicate(true)
	applied_states.append(state.duplicate(true))
