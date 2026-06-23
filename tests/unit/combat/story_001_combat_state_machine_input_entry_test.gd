## Story 001: CombatComponent base FSM and input entry points.
extends GdUnitTestSuite

const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")

var combat
var _extra_combat: Array = []
var _state_events: Array[Dictionary] = []


func before_test() -> void:
	combat = COMBAT_COMPONENT_SCRIPT.new()
	add_child(combat)
	_state_events.clear()
	combat.on_state_changed.connect(_on_state_changed)


func after_test() -> void:
	if is_instance_valid(combat):
		if combat.get_parent() != null:
			combat.get_parent().remove_child(combat)
		combat.free()
	for node: Variant in _extra_combat:
		if is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()
	combat = null
	_extra_combat.clear()
	_state_events.clear()


func test_component_instantiates_with_idle_defaults() -> void:
	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.IDLE)
	assert_int(combat.get_combo_index()).is_equal(0)
	assert_int(combat.get_cat_energy()).is_equal(0)
	assert_bool(combat.is_focus_mode_active()).is_false()

	var stats: Dictionary = combat.get_battle_stats()

	assert_dict(stats).contains_keys([
		"hits_landed",
		"total_damage_dealt",
		"parries",
		"dodges",
		"cat_energy",
	])
	assert_int(stats["cat_energy"]).is_equal(0)


func test_attack_from_idle_enters_attacking_and_stage_zero() -> void:
	combat.on_action_triggered(&"attack", {})

	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.ATTACKING)
	assert_int(combat.get_combo_index()).is_equal(0)


func test_defensive_and_heavy_actions_enter_base_states() -> void:
	var dodge_combat = _fresh_combat()
	dodge_combat.on_action_triggered(&"dodge", {})
	assert_int(dodge_combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.DODGING)

	var parry_combat = _fresh_combat()
	parry_combat.on_action_triggered(&"parry", {})
	assert_int(parry_combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.PARRYING)

	var charge_combat = _fresh_combat()
	charge_combat.on_action_triggered(&"heavy_attack", {"pressed": true})
	assert_int(charge_combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.CHARGING)


func test_unknown_action_is_ignored() -> void:
	combat.on_action_triggered(&"missing", {})

	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.IDLE)
	assert_int(_state_events.size()).is_equal(0)


func test_state_changed_signal_emits_once_for_valid_transition() -> void:
	combat.on_action_triggered(&"attack", {})

	assert_int(_state_events.size()).is_equal(1)
	assert_int(_state_events[0]["old_state"]).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.IDLE)
	assert_int(_state_events[0]["new_state"]).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.ATTACKING)


func _fresh_combat():
	var fresh = COMBAT_COMPONENT_SCRIPT.new()
	add_child(fresh)
	_extra_combat.append(fresh)
	return fresh


func _on_state_changed(old_state: int, new_state: int) -> void:
	_state_events.append({
		"old_state": old_state,
		"new_state": new_state,
	})
