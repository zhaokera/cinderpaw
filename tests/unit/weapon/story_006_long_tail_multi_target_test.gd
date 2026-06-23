## Story 006: Long Tail multi-target range and CollisionComponent contract.
extends GdUnitTestSuite

const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")
const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")
const COLLISION_COMPONENT_SCRIPT: Script = preload("res://src/core/collision_component.gd")

var data_manager
var weapons
var attacker_collision
var target_a
var target_b
var target_c
var _hit_events: Array = []


func before_test() -> void:
	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)
	weapons = WEAPON_COMPONENT_SCRIPT.new()
	add_child(weapons)
	weapons.set_data_manager(data_manager)
	attacker_collision = _new_collision_component(101, &"player")
	target_a = _new_collision_component(201, &"enemy")
	target_b = _new_collision_component(202, &"enemy")
	target_c = _new_collision_component(203, &"enemy")
	attacker_collision.on_hit_confirmed.connect(_record_hit_event)
	_hit_events.clear()


func after_test() -> void:
	for node in [weapons, data_manager, attacker_collision, target_a, target_b, target_c]:
		if is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()
	weapons = null
	data_manager = null
	attacker_collision = null
	target_a = null
	target_b = null
	target_c = null
	_hit_events.clear()


func test_long_tail_attack_parameters_expose_two_tile_multi_target_contract() -> void:
	weapons.deserialize({"current_weapon_index": 1})

	var params: Dictionary = weapons.get_attack_parameters()
	var mechanism: Dictionary = params["special_mechanism"]

	assert_str(String(params["weapon_id"])).is_equal("long_tail")
	assert_float(float(params["attack_range"])).is_equal_approx(2.0, 0.001)
	assert_str(String(mechanism["type"])).is_equal("multi_target")
	assert_float(float(mechanism["aoe_range"])).is_equal_approx(2.0, 0.001)
	assert_int(int(mechanism["max_targets"])).is_equal(5)


func test_long_tail_hitbox_metadata_marks_multi_target_and_keeps_collision_duplicate_tracking() -> void:
	if not _assert_collision_contract_api_exists():
		return
	weapons.deserialize({"current_weapon_index": 1})
	weapons.set_collision_adapter(attacker_collision)

	assert_bool(weapons.activate_current_attack_hitbox(&"light", 4, 1)).is_true()

	var hitbox = attacker_collision.get_hitbox(&"long_tail_light")
	var metadata: Dictionary = hitbox.get_attack_metadata()
	assert_str(String(metadata["weapon_id"])).is_equal("long_tail")
	assert_str(String(metadata["attack_type"])).is_equal("light")
	assert_int(int(metadata["combo_index"])).is_equal(1)
	assert_bool(bool(metadata["multi_target"])).is_true()
	assert_str(String(metadata["targeting_type"])).is_equal("multi_target")
	assert_int(int(metadata["max_targets"])).is_equal(5)
	assert_float(float(metadata["attack_range"])).is_equal_approx(2.0, 0.001)

	attacker_collision.process_detection_frame({
		&"long_tail_light": [
			target_a.get_hurtbox(),
			target_b.get_hurtbox(),
			target_c.get_hurtbox(),
		]
	})
	attacker_collision.process_detection_frame({&"long_tail_light": [target_a.get_hurtbox()]})

	assert_int(_hit_events.size()).is_equal(3)
	assert_array(_target_ids()).contains_exactly([201, 202, 203])
	assert_dict(_hit_events[0].attack_metadata).contains_keys([
		"multi_target",
		"max_targets",
		"attack_range",
	])


func test_cat_claw_hitbox_metadata_remains_single_target() -> void:
	if not _assert_collision_contract_api_exists():
		return
	weapons.set_collision_adapter(attacker_collision)

	assert_bool(weapons.activate_current_attack_hitbox(&"light", 3, 0)).is_true()

	var metadata: Dictionary = attacker_collision.get_hitbox(&"cat_claw_light").get_attack_metadata()
	assert_str(String(metadata["weapon_id"])).is_equal("cat_claw")
	assert_bool(bool(metadata["multi_target"])).is_false()
	assert_str(String(metadata["targeting_type"])).is_equal("single_target")
	assert_int(int(metadata["max_targets"])).is_equal(1)


func _assert_collision_contract_api_exists() -> bool:
	var has_api: bool = (
		weapons.has_method("set_collision_adapter")
		and weapons.has_method("activate_current_attack_hitbox")
	)
	assert_bool(has_api).is_true()
	return has_api


func _new_collision_component(entity_id: int, allegiance: StringName):
	var component = COLLISION_COMPONENT_SCRIPT.new()
	add_child(component)
	component.configure_entity(entity_id, allegiance)
	return component


func _record_hit_event(event) -> void:
	_hit_events.append(event)


func _target_ids() -> Array:
	var ids: Array = []
	for event in _hit_events:
		ids.append(event.target_id)
	return ids
