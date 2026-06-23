## Story 006: Cat energy, special gates, and ultimate gates.
extends GdUnitTestSuite

const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")

class FakeUltimateProvider:
	extends RefCounted

	var unlocked: Dictionary = {}

	func has_unlocked_ultimate(weapon_id: StringName) -> bool:
		return bool(unlocked.get(weapon_id, false))


var combat


func before_test() -> void:
	combat = COMBAT_COMPONENT_SCRIPT.new()
	add_child(combat)


func after_test() -> void:
	if is_instance_valid(combat):
		if combat.get_parent() != null:
			combat.get_parent().remove_child(combat)
		combat.free()
	combat = null


func test_cat_energy_starts_at_zero_and_gain_table_clamps_at_max() -> void:
	var expected_gains: Dictionary = {
		&"light_0": 5,
		&"light_1": 8,
		&"light_2": 12,
		&"heavy": 10,
		&"aerial": 8,
		&"special": 3,
		&"parry_counter": 15,
		&"perfect_dodge": 15,
		&"perfect_parry": 20,
		&"good_parry": 10,
		&"damage_taken": 3,
	}
	var expected_total: int = 0

	assert_int(combat.get_cat_energy()).is_equal(0)
	for event_id in expected_gains.keys():
		var gained: int = combat.add_cat_energy_for_event(event_id)
		expected_total = mini(100, expected_total + int(expected_gains[event_id]))

		assert_int(gained).is_equal(int(expected_gains[event_id]))
		assert_int(combat.get_cat_energy()).is_equal(expected_total)

	assert_int(combat.add_cat_energy_for_event(&"unknown_event")).is_equal(0)
	assert_int(combat.get_cat_energy()).is_equal(100)


func test_out_of_combat_timer_resets_on_damage_interaction_and_clears_energy_after_ten_seconds() -> void:
	combat.add_cat_energy_for_event(&"light_0")
	combat.advance_out_of_combat_time(9.9)

	assert_int(combat.get_cat_energy()).is_equal(5)

	combat.add_cat_energy_for_event(&"damage_taken")
	combat.advance_out_of_combat_time(9.9)

	assert_int(combat.get_cat_energy()).is_equal(8)

	combat.advance_out_of_combat_time(0.11)

	assert_int(combat.get_cat_energy()).is_equal(0)


func test_special_gate_checks_weapon_cost_and_cooldown() -> void:
	_fill_energy_to_max()
	assert_bool(combat.can_use_special(&"cat_claw")).is_true()

	assert_bool(combat.try_use_special(&"cat_claw")).is_true()
	assert_int(combat.get_cat_energy()).is_equal(70)
	assert_float(combat.get_special_cooldown_remaining(&"cat_claw")).is_equal(8.0)

	combat.add_cat_energy_for_event(&"perfect_parry")
	assert_bool(combat.can_use_special(&"cat_claw")).is_false()
	assert_bool(combat.try_use_special(&"cat_claw")).is_false()
	assert_int(combat.get_cat_energy()).is_equal(90)

	combat.advance_special_cooldown_time(8.0)

	assert_bool(combat.can_use_special(&"cat_claw")).is_true()


func test_special_gate_failed_energy_check_does_not_consume_energy() -> void:
	combat.add_cat_energy_for_event(&"perfect_parry")

	assert_bool(combat.can_use_special(&"fish_bone")).is_false()
	assert_bool(combat.try_use_special(&"fish_bone")).is_false()
	assert_int(combat.get_cat_energy()).is_equal(20)

	_fill_energy_to_max()
	assert_bool(combat.try_use_special(&"fish_bone")).is_true()
	assert_int(combat.get_cat_energy()).is_equal(50)
	assert_float(combat.get_special_cooldown_remaining(&"fish_bone")).is_equal(12.0)


func test_ultimate_requires_provider_unlock_and_eighty_cat_energy() -> void:
	_fill_energy_to_max()
	assert_bool(combat.can_use_ultimate(&"cat_claw")).is_false()
	assert_bool(combat.try_use_ultimate(&"cat_claw")).is_false()
	assert_int(combat.get_cat_energy()).is_equal(100)

	var provider = FakeUltimateProvider.new()
	combat.set_ultimate_provider(provider)
	assert_bool(combat.can_use_ultimate(&"cat_claw")).is_false()
	assert_bool(combat.try_use_ultimate(&"cat_claw")).is_false()
	assert_int(combat.get_cat_energy()).is_equal(100)

	provider.unlocked[&"cat_claw"] = true
	assert_bool(combat.try_use_ultimate(&"cat_claw")).is_true()
	assert_int(combat.get_cat_energy()).is_equal(20)


func test_ultimate_failed_energy_check_does_not_consume_energy() -> void:
	var provider = FakeUltimateProvider.new()
	provider.unlocked[&"long_tail"] = true
	combat.set_ultimate_provider(provider)
	combat.add_cat_energy_for_event(&"perfect_parry")
	combat.add_cat_energy_for_event(&"perfect_parry")
	combat.add_cat_energy_for_event(&"perfect_parry")
	combat.add_cat_energy_for_event(&"good_parry")

	assert_int(combat.get_cat_energy()).is_equal(70)
	assert_bool(combat.can_use_ultimate(&"long_tail")).is_false()
	assert_bool(combat.try_use_ultimate(&"long_tail")).is_false()
	assert_int(combat.get_cat_energy()).is_equal(70)


func _fill_energy_to_max() -> void:
	for _index in range(5):
		combat.add_cat_energy_for_event(&"perfect_parry")
