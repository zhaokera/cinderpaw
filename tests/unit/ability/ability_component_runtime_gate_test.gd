## AbilityComponent runtime gate and cooldown contract.
extends GdUnitTestSuite

const ABILITY_COMPONENT_SCRIPT: Script = preload("res://src/core/ability_component.gd")
const DASH_ABILITY: StringName = &"dash"

var ability_component: AbilityComponent
var unlocked_ids: Array[StringName] = []
var activated_ids: Array[StringName] = []


func before_test() -> void:
	ability_component = ABILITY_COMPONENT_SCRIPT.new() as AbilityComponent
	add_child(ability_component)
	ability_component.ability_unlocked.connect(func(ability_id: StringName) -> void:
		unlocked_ids.append(ability_id)
	)
	ability_component.ability_activated.connect(func(ability_id: StringName) -> void:
		activated_ids.append(ability_id)
	)


func after_test() -> void:
	if is_instance_valid(ability_component):
		if ability_component.get_parent() != null:
			ability_component.get_parent().remove_child(ability_component)
		ability_component.free()
	ability_component = null
	unlocked_ids.clear()
	activated_ids.clear()


func test_initial_abilities_are_available_and_dash_starts_locked() -> void:
	assert_bool(ability_component.has_ability(&"basic_attack")).is_true()
	assert_bool(ability_component.has_ability(&"jump")).is_true()
	assert_bool(ability_component.has_ability(&"dodge")).is_true()
	assert_bool(ability_component.has_ability(&"parry")).is_true()
	assert_bool(ability_component.has_ability(DASH_ABILITY)).is_false()
	assert_array(ability_component.get_unlocked_abilities()).not_contains(DASH_ABILITY)


func test_project_abilities_data_domain_loads_eight_registry_entries() -> void:
	var data_manager := get_node_or_null("/root/DataManager")
	assert_that(data_manager).is_not_null()
	if data_manager == null:
		return
	assert_bool(data_manager.has_method("get_domain")).is_true()
	if not data_manager.has_method("get_domain"):
		return
	var ability_domain: Dictionary = data_manager.call("get_domain", &"abilities")
	assert_int(ability_domain.size()).is_equal(8)
	assert_bool(ability_domain.has(DASH_ABILITY)).is_true()
	if not ability_domain.has(DASH_ABILITY):
		return
	var dash_config: Dictionary = ability_domain[DASH_ABILITY]
	assert_float(float(dash_config.get("cooldown_sec", -1.0))).is_equal_approx(
		1.0,
		0.001
	)
	assert_str(String(dash_config.get("unlock_condition", ""))).is_equal(
		"boss_01_rat_king_defeated"
	)


func test_dash_unlock_activation_and_cooldown_are_data_driven() -> void:
	assert_bool(ability_component.try_activate_ability(DASH_ABILITY)).is_false()
	assert_bool(ability_component.unlock_ability(DASH_ABILITY)).is_true()
	assert_bool(ability_component.unlock_ability(DASH_ABILITY)).is_false()
	assert_array(unlocked_ids).is_equal([DASH_ABILITY])

	assert_bool(ability_component.try_activate_ability(DASH_ABILITY)).is_true()
	assert_array(activated_ids).is_equal([DASH_ABILITY])
	assert_bool(ability_component.is_ability_on_cooldown(DASH_ABILITY)).is_true()
	assert_float(ability_component.get_ability_cooldown_remaining(DASH_ABILITY)).is_equal_approx(
		1.0,
		0.001
	)

	assert_bool(ability_component.try_activate_ability(DASH_ABILITY)).is_false()
	ability_component.advance_time(1.0)
	assert_bool(ability_component.is_ability_on_cooldown(DASH_ABILITY)).is_false()
	assert_bool(ability_component.try_activate_ability(DASH_ABILITY)).is_true()
