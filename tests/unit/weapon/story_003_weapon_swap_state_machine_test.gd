## Story 003: Weapon swap state machine and combat adapter integration.
extends GdUnitTestSuite

const WEAPON_COMPONENT_PATH: String = "res://src/core/weapon_component.gd"
const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")
const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")

var data_manager
var weapons


class CombatAdapter:
	extends RefCounted

	var state: int = 0
	var notify_weapon_swapping_calls: int = 0
	var reset_combo_calls: int = 0
	var reset_dodge_cooldown_calls: int = 0

	func get_current_state() -> int:
		return state

	func notify_weapon_swapping() -> void:
		notify_weapon_swapping_calls += 1

	func reset_combo() -> void:
		reset_combo_calls += 1

	func reset_dodge_cooldown() -> void:
		reset_dodge_cooldown_calls += 1


class MinimalCombatAdapter:
	extends RefCounted

	func get_current_state() -> int:
		return 0


func before_test() -> void:
	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)
	var script: Script = load(WEAPON_COMPONENT_PATH)
	weapons = script.new()
	add_child(weapons)
	weapons.set_data_manager(data_manager)


func after_test() -> void:
	if is_instance_valid(weapons):
		if weapons.get_parent() != null:
			weapons.get_parent().remove_child(weapons)
		weapons.free()
	weapons = null
	if is_instance_valid(data_manager):
		if data_manager.get_parent() != null:
			data_manager.get_parent().remove_child(data_manager)
		data_manager.free()
	data_manager = null


func test_request_swap_starts_uncancellable_half_second_swap() -> void:
	var combat_adapter := CombatAdapter.new()
	weapons.set_combat_adapter(combat_adapter)

	assert_bool(weapons.request_swap()).is_true()
	assert_bool(weapons.is_swap_active()).is_true()
	assert_float(weapons.get_swap_remaining_time()).is_equal_approx(0.5, 0.001)
	assert_int(combat_adapter.notify_weapon_swapping_calls).is_equal(1)

	weapons.advance_time(0.49)
	assert_bool(weapons.is_swap_active()).is_true()
	assert_str(String(weapons.get_current_weapon().weapon_id)).is_equal("cat_claw")
	assert_bool(weapons.request_swap()).is_false()
	assert_float(weapons.get_swap_remaining_time()).is_equal_approx(0.01, 0.001)

	weapons.advance_time(0.01)
	assert_bool(weapons.is_swap_active()).is_false()
	assert_str(String(weapons.get_current_weapon().weapon_id)).is_equal("long_tail")
	assert_int(combat_adapter.reset_combo_calls).is_equal(1)
	assert_int(combat_adapter.reset_dodge_cooldown_calls).is_equal(1)


func test_request_swap_is_rejected_while_combat_is_attacking() -> void:
	var combat_adapter := CombatAdapter.new()
	combat_adapter.state = COMBAT_COMPONENT_SCRIPT.CombatState.ATTACKING
	weapons.set_combat_adapter(combat_adapter)

	assert_bool(weapons.request_swap()).is_false()

	assert_bool(weapons.is_swap_active()).is_false()
	assert_str(String(weapons.get_current_weapon().weapon_id)).is_equal("cat_claw")
	assert_int(combat_adapter.notify_weapon_swapping_calls).is_equal(0)
	assert_int(combat_adapter.reset_combo_calls).is_equal(0)
	assert_int(combat_adapter.reset_dodge_cooldown_calls).is_equal(0)


func test_completed_swaps_cycle_through_all_weapon_styles() -> void:
	var combat_adapter := CombatAdapter.new()
	var expected_order: Array[String] = ["long_tail", "fish_bone", "electro_bell", "cat_claw"]
	weapons.set_combat_adapter(combat_adapter)

	for weapon_id: String in expected_order:
		assert_bool(weapons.request_swap()).is_true()
		weapons.advance_time(0.5)
		assert_str(String(weapons.get_current_weapon().weapon_id)).is_equal(weapon_id)


func test_completed_swap_emits_changed_weapon_signal() -> void:
	var combat_adapter := CombatAdapter.new()
	var weapon_events: Array[String] = []
	weapons.set_combat_adapter(combat_adapter)
	weapons.on_weapon_changed.connect(func(weapon: Resource) -> void:
		weapon_events.append(String(weapon.weapon_id))
	)

	assert_bool(weapons.request_swap()).is_true()
	weapons.advance_time(0.5)

	assert_array(weapon_events).is_equal(["long_tail"])


func test_missing_optional_combat_hooks_still_completes_swap() -> void:
	var combat_adapter := MinimalCombatAdapter.new()
	weapons.set_combat_adapter(combat_adapter)

	assert_bool(weapons.request_swap()).is_true()
	weapons.advance_time(0.5)

	assert_bool(weapons.is_swap_active()).is_false()
	assert_str(String(weapons.get_current_weapon().weapon_id)).is_equal("long_tail")


func test_completed_swap_resets_real_combat_dodge_cooldown_hook() -> void:
	var combat = COMBAT_COMPONENT_SCRIPT.new()
	add_child(combat)
	combat.on_action_triggered(&"dodge", {})
	combat.advance_dodge_frames(COMBAT_COMPONENT_SCRIPT.DODGE_TOTAL_FRAMES)
	combat.on_action_triggered(&"dodge", {})
	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.IDLE)

	weapons.set_combat_adapter(combat)
	assert_bool(weapons.request_swap()).is_true()
	weapons.advance_time(0.5)
	combat.on_action_triggered(&"dodge", {})

	assert_int(combat.get_current_state()).is_equal(COMBAT_COMPONENT_SCRIPT.CombatState.DODGING)

	combat.queue_free()
