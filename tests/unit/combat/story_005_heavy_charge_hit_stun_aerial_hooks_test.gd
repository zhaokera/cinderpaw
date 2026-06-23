## Story 005: Heavy charge, hit stun stacking, and aerial bounce hooks.
extends GdUnitTestSuite

const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")

var combat
var _heavy_events: Array[Dictionary] = []
var _bounce_events: Array[Dictionary] = []


func before_test() -> void:
	combat = COMBAT_COMPONENT_SCRIPT.new()
	add_child(combat)
	_heavy_events.clear()
	_bounce_events.clear()
	combat.on_heavy_attack_released.connect(_on_heavy_attack_released)
	combat.on_aerial_bounce_requested.connect(_on_aerial_bounce_requested)


func after_test() -> void:
	if is_instance_valid(combat):
		if combat.get_parent() != null:
			combat.get_parent().remove_child(combat)
		combat.free()
	combat = null
	_heavy_events.clear()
	_bounce_events.clear()


func test_heavy_release_after_minimum_charge_starts_attack() -> void:
	combat.on_action_triggered(&"heavy_attack", {"pressed": true})
	combat.advance_charge_time(1.0)

	combat.on_action_triggered(&"heavy_attack", {"pressed": false})

	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.ATTACKING)
	assert_array(_heavy_events).has_size(1)
	assert_str(String(_heavy_events[0]["attack_type"])).is_equal("heavy")
	assert_float(float(_heavy_events[0]["charge_seconds"])).is_equal(1.0)
	assert_float(float(_heavy_events[0]["charge_ratio"])).is_equal_approx(0.6666, 0.001)


func test_full_charge_auto_releases_at_maximum() -> void:
	combat.on_action_triggered(&"heavy_attack", {"pressed": true})

	combat.advance_charge_time(1.5)

	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.ATTACKING)
	assert_array(_heavy_events).has_size(1)
	assert_float(float(_heavy_events[0]["charge_seconds"])).is_equal(1.5)
	assert_float(float(_heavy_events[0]["charge_ratio"])).is_equal(1.0)


func test_releasing_before_minimum_charge_returns_to_idle_without_attack() -> void:
	combat.on_action_triggered(&"heavy_attack", {"pressed": true})
	combat.advance_charge_time(0.49)

	combat.on_action_triggered(&"heavy_attack", {"pressed": false})

	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.IDLE)
	assert_float(combat.get_charge_ratio()).is_equal(0.0)
	assert_array(_heavy_events).is_empty()


func test_dodge_cancels_charging_into_dodging() -> void:
	combat.on_action_triggered(&"heavy_attack", {"pressed": true})
	combat.advance_charge_time(0.75)

	combat.on_action_triggered(&"dodge", {})

	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.DODGING)
	assert_float(combat.get_charge_ratio()).is_equal(0.0)
	assert_array(_heavy_events).is_empty()


func test_damage_taken_interrupts_charging_into_hit_stun() -> void:
	combat.on_action_triggered(&"heavy_attack", {"pressed": true})
	combat.advance_charge_time(0.75)

	combat.on_damage_taken(5)

	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.HIT_STUN)
	assert_float(combat.get_charge_ratio()).is_equal(0.0)
	assert_int(combat.get_hit_stun_stack_count()).is_equal(1)


func test_hit_stun_duration_stacks_and_clamps_at_three() -> void:
	combat.on_damage_taken(1)
	var one_stack_frames: int = combat.get_hit_stun_remaining_frames()

	combat.on_damage_taken(1)
	combat.on_damage_taken(1)
	combat.on_damage_taken(1)

	assert_int(combat.get_hit_stun_stack_count()).is_equal(3)
	assert_int(combat.get_hit_stun_remaining_frames()).is_equal(one_stack_frames * 3)


func test_aerial_hit_confirmation_emits_bounce_request() -> void:
	combat.on_aerial_hit_confirmed({"target_id": 7})

	assert_array(_bounce_events).has_size(1)
	assert_bool(bool(_bounce_events[0]["restore_jump"])).is_true()
	assert_int(int(_bounce_events[0]["target_id"])).is_equal(7)


func _on_heavy_attack_released(metadata: Dictionary) -> void:
	_heavy_events.append(metadata)


func _on_aerial_bounce_requested(metadata: Dictionary) -> void:
	_bounce_events.append(metadata)
