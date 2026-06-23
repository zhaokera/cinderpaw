## Story 002: Weapon upgrade state and serialization prep.
extends GdUnitTestSuite

const WEAPON_COMPONENT_PATH: String = "res://src/core/weapon_component.gd"
const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")

var data_manager
var weapons


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


func test_all_weapons_start_at_level_one_with_next_damage_preview() -> void:
	assert_int(weapons.get_weapon_level(&"cat_claw")).is_equal(0)
	assert_int(weapons.get_weapon_level(&"long_tail")).is_equal(0)
	assert_int(weapons.get_effective_base_damage(&"cat_claw")).is_equal(10)
	assert_int(weapons.get_effective_base_damage(&"long_tail")).is_equal(14)
	assert_int(weapons.get_next_level_damage(&"cat_claw")).is_equal(12)
	assert_int(weapons.get_next_level_damage(&"electro_bell")).is_equal(10)


func test_upgrade_weapon_increments_until_level_five_and_emits_signal() -> void:
	var upgrade_events: Array[Dictionary] = []
	weapons.on_weapon_upgraded.connect(func(weapon_id: StringName, new_level: int) -> void:
		upgrade_events.append({"weapon_id": weapon_id, "new_level": new_level})
	)

	assert_bool(weapons.upgrade_weapon(&"cat_claw")).is_true()
	assert_bool(weapons.upgrade_weapon(&"cat_claw")).is_true()
	assert_bool(weapons.upgrade_weapon(&"cat_claw")).is_true()
	assert_bool(weapons.upgrade_weapon(&"cat_claw")).is_true()
	assert_bool(weapons.upgrade_weapon(&"cat_claw")).is_false()

	assert_int(weapons.get_weapon_level(&"cat_claw")).is_equal(4)
	assert_int(weapons.get_effective_base_damage(&"cat_claw")).is_equal(18)
	assert_int(weapons.get_next_level_damage(&"cat_claw")).is_equal(-1)
	assert_int(upgrade_events.size()).is_equal(4)
	assert_str(String(upgrade_events[0]["weapon_id"])).is_equal("cat_claw")
	assert_int(upgrade_events[0]["new_level"]).is_equal(2)
	assert_int(upgrade_events[3]["new_level"]).is_equal(5)


func test_invalid_upgrade_requests_are_rejected_without_state_change() -> void:
	assert_bool(weapons.upgrade_weapon(&"missing_weapon")).is_false()
	assert_int(weapons.get_weapon_level(&"cat_claw")).is_equal(0)
	assert_int(weapons.get_next_level_damage(&"missing_weapon")).is_equal(-1)


func test_serialize_and_deserialize_restore_current_weapon_and_levels() -> void:
	weapons.deserialize({
		"version": 1,
		"current_weapon_index": 2,
		"weapon_levels": {
			"cat_claw": 2,
			"fish_bone": 4,
		},
	})
	var snapshot: Dictionary = weapons.serialize()
	var restored = load(WEAPON_COMPONENT_PATH).new()
	add_child(restored)
	restored.set_data_manager(data_manager)
	restored.deserialize(snapshot)

	snapshot["weapon_levels"]["cat_claw"] = 0

	assert_str(String(restored.get_current_weapon().weapon_id)).is_equal("fish_bone")
	assert_int(restored.get_weapon_level(&"cat_claw")).is_equal(2)
	assert_int(restored.get_weapon_level(&"fish_bone")).is_equal(4)
	assert_int(restored.get_effective_base_damage(&"fish_bone")).is_equal(40)

	restored.queue_free()


func test_deserialize_clamps_invalid_indices_and_ignores_unknown_weapons() -> void:
	weapons.deserialize({
		"version": 1,
		"current_weapon_index": 99,
		"weapon_levels": {
			"cat_claw": 99,
			"long_tail": -10,
			"unknown": 3,
		},
	})

	assert_str(String(weapons.get_current_weapon().weapon_id)).is_equal("cat_claw")
	assert_int(weapons.get_weapon_level(&"cat_claw")).is_equal(4)
	assert_int(weapons.get_weapon_level(&"long_tail")).is_equal(0)
	assert_bool(weapons.serialize()["weapon_levels"].has("unknown")).is_false()
