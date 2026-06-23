## Story 001: AI state machine and active enemy count.
extends GdUnitTestSuite

const AI_COMPONENT_SCRIPT: Script = preload("res://src/core/ai_component.gd")

var ai
var second_ai
var _state_events: Array[Dictionary] = []


func before_test() -> void:
	AI_COMPONENT_SCRIPT.reset_active_enemy_count()
	ai = AI_COMPONENT_SCRIPT.new()
	second_ai = AI_COMPONENT_SCRIPT.new()
	add_child(ai)
	add_child(second_ai)
	_state_events.clear()
	ai.on_state_changed.connect(_record_state_change)


func after_test() -> void:
	for node in [ai, second_ai]:
		if is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()
	ai = null
	second_ai = null
	_state_events.clear()
	AI_COMPONENT_SCRIPT.reset_active_enemy_count()


func test_component_starts_idle_without_active_count_contribution() -> void:
	assert_int(ai.get_current_state()).is_equal(AI_COMPONENT_SCRIPT.AIState.IDLE)
	assert_int(AI_COMPONENT_SCRIPT.get_active_enemy_count()).is_equal(0)


func test_all_ai_states_can_be_entered_without_enemy_scene() -> void:
	var states: Array[int] = [
		AI_COMPONENT_SCRIPT.AIState.IDLE,
		AI_COMPONENT_SCRIPT.AIState.PATROL,
		AI_COMPONENT_SCRIPT.AIState.CHASE,
		AI_COMPONENT_SCRIPT.AIState.ATTACK,
		AI_COMPONENT_SCRIPT.AIState.FLEE,
		AI_COMPONENT_SCRIPT.AIState.STUN,
	]

	for state: int in states:
		ai.change_state(state)
		assert_int(ai.get_current_state()).is_equal(state)


func test_entering_chase_or_attack_counts_each_entity_once() -> void:
	ai.change_state(AI_COMPONENT_SCRIPT.AIState.CHASE)
	ai.change_state(AI_COMPONENT_SCRIPT.AIState.ATTACK)
	second_ai.change_state(AI_COMPONENT_SCRIPT.AIState.ATTACK)

	assert_int(AI_COMPONENT_SCRIPT.get_active_enemy_count()).is_equal(2)


func test_leaving_combat_states_decrements_without_going_negative() -> void:
	ai.change_state(AI_COMPONENT_SCRIPT.AIState.CHASE)
	second_ai.change_state(AI_COMPONENT_SCRIPT.AIState.ATTACK)

	ai.change_state(AI_COMPONENT_SCRIPT.AIState.PATROL)
	second_ai.change_state(AI_COMPONENT_SCRIPT.AIState.IDLE)
	second_ai.change_state(AI_COMPONENT_SCRIPT.AIState.IDLE)

	assert_int(AI_COMPONENT_SCRIPT.get_active_enemy_count()).is_equal(0)


func test_state_changed_signal_emits_for_real_changes_only() -> void:
	ai.change_state(AI_COMPONENT_SCRIPT.AIState.PATROL)
	ai.change_state(AI_COMPONENT_SCRIPT.AIState.PATROL)
	ai.change_state(AI_COMPONENT_SCRIPT.AIState.CHASE)

	assert_int(_state_events.size()).is_equal(2)
	assert_int(_state_events[0]["old_state"]).is_equal(AI_COMPONENT_SCRIPT.AIState.IDLE)
	assert_int(_state_events[0]["new_state"]).is_equal(AI_COMPONENT_SCRIPT.AIState.PATROL)
	assert_int(_state_events[1]["old_state"]).is_equal(AI_COMPONENT_SCRIPT.AIState.PATROL)
	assert_int(_state_events[1]["new_state"]).is_equal(AI_COMPONENT_SCRIPT.AIState.CHASE)


func _record_state_change(old_state: int, new_state: int) -> void:
	_state_events.append({
		"old_state": old_state,
		"new_state": new_state,
	})
