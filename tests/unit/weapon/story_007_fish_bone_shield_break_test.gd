## Story 007: Fish Bone full-charge shield break contract.
extends GdUnitTestSuite

const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")
const HEALTH_COMPONENT_SCRIPT: Script = preload("res://src/core/health_component.gd")
const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")

var data_manager
var weapons
var target_health
var unshielded_target


class FakeChargeCombatAdapter:
	var charge_ratio: float = 0.0

	func _init(initial_charge_ratio: float) -> void:
		charge_ratio = initial_charge_ratio

	func get_charge_ratio() -> float:
		return charge_ratio


func before_test() -> void:
	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)
	weapons = WEAPON_COMPONENT_SCRIPT.new()
	add_child(weapons)
	weapons.set_data_manager(data_manager)
	target_health = HEALTH_COMPONENT_SCRIPT.new()
	add_child(target_health)
	target_health.configure(201, 100, 100, 30, 30)
	unshielded_target = Node.new()
	add_child(unshielded_target)


func after_test() -> void:
	for node in [unshielded_target, target_health, weapons, data_manager]:
		if is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()
	unshielded_target = null
	target_health = null
	weapons = null
	data_manager = null


func test_full_charge_fish_bone_hit_breaks_target_shield() -> void:
	if not _assert_shield_break_contract_api_exists():
		return
	weapons.deserialize({"current_weapon_index": 2})
	weapons.set_combat_adapter(FakeChargeCombatAdapter.new(1.0))

	var metadata: Dictionary = weapons.apply_confirmed_hit_effects(target_health, {
		"attack_type": &"heavy",
		"target_id": 201,
	})

	assert_str(String(weapons.get_current_weapon().weapon_id)).is_equal("fish_bone")
	assert_int(target_health.get_shield()).is_equal(0)
	assert_bool(bool(metadata["shield_break_attempted"])).is_true()
	assert_bool(bool(metadata["shield_broken"])).is_true()
	assert_float(float(metadata["charge_ratio"])).is_equal_approx(1.0, 0.001)


func test_partial_charge_fish_bone_hit_does_not_break_target_shield() -> void:
	if not _assert_shield_break_contract_api_exists():
		return
	weapons.deserialize({"current_weapon_index": 2})
	weapons.set_combat_adapter(FakeChargeCombatAdapter.new(0.66))

	var metadata: Dictionary = weapons.apply_confirmed_hit_effects(target_health, {
		"attack_type": &"heavy",
		"target_id": 201,
	})

	assert_int(target_health.get_shield()).is_equal(30)
	assert_bool(bool(metadata["shield_break_attempted"])).is_false()
	assert_bool(bool(metadata["shield_broken"])).is_false()
	assert_str(String(metadata["shield_break_skipped_reason"])).is_equal("partial_charge")


func test_missing_shield_api_degrades_to_normal_hit_metadata() -> void:
	if not _assert_shield_break_contract_api_exists():
		return
	weapons.deserialize({"current_weapon_index": 2})
	weapons.set_combat_adapter(FakeChargeCombatAdapter.new(1.0))

	var metadata: Dictionary = weapons.apply_confirmed_hit_effects(unshielded_target, {
		"attack_type": &"heavy",
		"target_id": 301,
		"final_damage": 17,
	})

	assert_int(int(metadata["final_damage"])).is_equal(17)
	assert_bool(bool(metadata["shield_break_attempted"])).is_true()
	assert_bool(bool(metadata["shield_broken"])).is_false()
	assert_str(String(metadata["shield_break_skipped_reason"])).is_equal("missing_break_shield")


func _assert_shield_break_contract_api_exists() -> bool:
	var has_api: bool = (
		target_health.has_method("break_shield")
		and weapons.has_method("apply_confirmed_hit_effects")
	)
	assert_bool(has_api).is_true()
	return has_api
