## Story 003: Dodge i-frames, hurtbox adapter, cooldown, and counter window.
extends GdUnitTestSuite

const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")

class FakeHurtboxAdapter:
	extends RefCounted

	var states: Array[StringName] = []

	func set_hurtbox_state(state: StringName) -> void:
		states.append(state)


var combat
var _counter_events: Array[bool] = []


func before_test() -> void:
	combat = COMBAT_COMPONENT_SCRIPT.new()
	add_child(combat)
	_counter_events.clear()
	combat.on_dodge_counter_active.connect(_on_dodge_counter_active)


func after_test() -> void:
	if is_instance_valid(combat):
		if combat.get_parent() != null:
			combat.get_parent().remove_child(combat)
		combat.free()
	combat = null
	_counter_events.clear()


func test_dodge_starts_from_idle_and_attack_recovery() -> void:
	combat.on_action_triggered(&"dodge", {})

	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.DODGING)

	var attacking_combat = COMBAT_COMPONENT_SCRIPT.new()
	add_child(attacking_combat)
	attacking_combat.start_light_attack_stage(0)
	attacking_combat.advance_attack_frames(4)

	attacking_combat.on_action_triggered(&"dodge", {})

	assert_int(attacking_combat.get_current_state()).is_equal(
		COMBAT_COMPONENT_SCRIPT.CombatState.DODGING
	)
	attacking_combat.free()


func test_dodge_iframe_boundaries_are_frames_three_through_ten() -> void:
	combat.on_action_triggered(&"dodge", {})

	assert_bool(combat.is_dodge_iframe_active()).is_false()

	combat.advance_dodge_frames(2)
	assert_int(combat.get_dodge_frame()).is_equal(2)
	assert_bool(combat.is_dodge_iframe_active()).is_false()

	combat.advance_dodge_frames(1)
	assert_int(combat.get_dodge_frame()).is_equal(3)
	assert_bool(combat.is_dodge_iframe_active()).is_true()

	combat.advance_dodge_frames(7)
	assert_int(combat.get_dodge_frame()).is_equal(10)
	assert_bool(combat.is_dodge_iframe_active()).is_true()

	combat.advance_dodge_frames(1)
	assert_int(combat.get_dodge_frame()).is_equal(11)
	assert_bool(combat.is_dodge_iframe_active()).is_false()


func test_hurtbox_adapter_receives_gone_during_iframe_and_normal_on_end() -> void:
	var adapter = FakeHurtboxAdapter.new()
	combat.set_hurtbox_adapter(adapter)

	combat.on_action_triggered(&"dodge", {})
	combat.advance_dodge_frames(3)

	assert_str(String(adapter.states.back())).is_equal("gone")

	combat.advance_dodge_frames(9)

	assert_str(String(adapter.states.back())).is_equal("normal")
	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.IDLE)


func test_dodge_iframe_exposes_invulnerability_for_health_integration() -> void:
	combat.on_action_triggered(&"dodge", {})
	combat.advance_dodge_frames(3)

	assert_bool(combat.is_dodge_iframe_active()).is_true()
	assert_bool(combat.is_invulnerable_to_damage()).is_true()


func test_dodge_cooldown_and_airborne_rejection() -> void:
	combat.on_action_triggered(&"dodge", {})
	combat.advance_dodge_frames(12)

	combat.on_action_triggered(&"dodge", {})
	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.IDLE)

	combat.advance_dodge_cooldown_time(0.5)
	combat.on_action_triggered(&"dodge", {})
	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.DODGING)

	var airborne_combat = COMBAT_COMPONENT_SCRIPT.new()
	add_child(airborne_combat)
	airborne_combat.on_action_triggered(&"dodge", {"is_airborne": true})
	assert_int(airborne_combat.get_current_state()).is_equal(
		COMBAT_COMPONENT_SCRIPT.CombatState.IDLE
	)
	airborne_combat.free()


func test_cat_claw_dodge_end_opens_and_closes_counter_window() -> void:
	combat.on_action_triggered(&"dodge", {})
	combat.advance_dodge_frames(12)

	assert_array(_counter_events).is_equal([true])
	assert_int(combat.get_dodge_counter_window()).is_equal(30)

	combat.advance_dodge_counter_frames(29)
	assert_int(combat.get_dodge_counter_window()).is_equal(1)
	assert_array(_counter_events).is_equal([true])

	combat.advance_dodge_counter_frames(1)
	assert_int(combat.get_dodge_counter_window()).is_equal(0)
	assert_array(_counter_events).is_equal([true, false])


func _on_dodge_counter_active(active: bool) -> void:
	_counter_events.append(active)
