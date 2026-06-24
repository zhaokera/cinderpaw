## Story 008: Electro Bell slow status application contract.
extends GdUnitTestSuite

const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")
const STATUS_EFFECT_COMPONENT_SCRIPT: Script = preload("res://src/core/status_effect_component.gd")
const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")

var data_manager
var weapons
var target_status
var target_without_status_api


func before_test() -> void:
	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)
	weapons = WEAPON_COMPONENT_SCRIPT.new()
	add_child(weapons)
	weapons.set_data_manager(data_manager)
	target_status = STATUS_EFFECT_COMPONENT_SCRIPT.new()
	add_child(target_status)
	target_status.configure_entity(301, false)
	target_without_status_api = Node.new()
	add_child(target_without_status_api)


func after_test() -> void:
	for node in [target_without_status_api, target_status, weapons, data_manager]:
		if is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()
	target_without_status_api = null
	target_status = null
	weapons = null
	data_manager = null


func test_electro_bell_hit_applies_slow_status_to_target() -> void:
	weapons.deserialize({"current_weapon_index": 3})

	var metadata: Dictionary = weapons.apply_confirmed_hit_effects(target_status, {
		"attacker_id": 101,
		"target_id": 301,
		"attack_type": &"light",
	})

	assert_str(String(weapons.get_current_weapon().weapon_id)).is_equal("electro_bell")
	assert_bool(target_status.has_status(&"slow")).is_true()
	assert_bool(bool(metadata.get("slow_status_attempted", false))).is_true()
	assert_bool(bool(metadata.get("slow_status_applied", false))).is_true()
	assert_str(String(metadata.get("status_effect_id", &""))).is_equal("slow")
	var active_effects: Array = target_status.get_active_effects()
	var first_effect: Dictionary = active_effects[0] if active_effects.size() > 0 else {}
	assert_int(active_effects.size()).is_equal(1)
	assert_int(int(first_effect.get("target_id", 0))).is_equal(301)
	assert_int(int(first_effect.get("source_id", 0))).is_equal(101)


func test_electro_bell_slow_metadata_matches_gdd_values() -> void:
	weapons.deserialize({"current_weapon_index": 3})

	var metadata: Dictionary = weapons.apply_confirmed_hit_effects(target_status, {
		"attacker_id": 101,
		"target_id": 301,
		"attack_type": &"light",
	})

	assert_float(float(metadata.get("slow_duration_sec", 0.0))).is_equal_approx(2.0, 0.001)
	assert_float(float(metadata.get("slow_percentage", 0.0))).is_equal_approx(0.3, 0.001)
	assert_float(float(metadata.get("slow_movement_modifier", 0.0))).is_equal_approx(0.7, 0.001)
	assert_float(target_status.get_remaining_duration(&"slow")).is_equal_approx(2.0, 0.001)
	assert_float(target_status.get_movement_modifier()).is_equal_approx(0.7, 0.001)


func test_repeated_electro_bell_hits_refresh_slow_without_duplicate_effects() -> void:
	weapons.deserialize({"current_weapon_index": 3})

	assert_bool(bool(weapons.apply_confirmed_hit_effects(target_status, {
		"attacker_id": 101,
		"target_id": 301,
		"attack_type": &"light",
	}).get("slow_status_applied", false))).is_true()
	target_status.advance_time(1.2)
	assert_float(target_status.get_remaining_duration(&"slow")).is_less(2.0)

	var metadata: Dictionary = weapons.apply_confirmed_hit_effects(target_status, {
		"attacker_id": 101,
		"target_id": 301,
		"attack_type": &"light",
	})

	assert_bool(bool(metadata.get("slow_status_applied", false))).is_true()
	assert_int(target_status.get_active_effects().size()).is_equal(1)
	assert_float(target_status.get_remaining_duration(&"slow")).is_equal_approx(2.0, 0.001)


func test_missing_status_api_preserves_hit_metadata_without_error() -> void:
	weapons.deserialize({"current_weapon_index": 3})

	var metadata: Dictionary = weapons.apply_confirmed_hit_effects(target_without_status_api, {
		"attacker_id": 101,
		"target_id": 401,
		"attack_type": &"light",
		"final_damage": 11,
	})

	assert_int(int(metadata["final_damage"])).is_equal(11)
	assert_bool(bool(metadata.get("slow_status_attempted", false))).is_true()
	assert_bool(bool(metadata.get("slow_status_applied", false))).is_false()
	assert_str(String(metadata.get("slow_status_skipped_reason", &""))).is_equal("missing_apply_status")
