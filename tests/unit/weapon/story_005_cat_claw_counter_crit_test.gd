## Story 005: Cat Claw dodge-counter crit-window bonus.
extends GdUnitTestSuite

const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")
const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")
const WEAPON_COMPONENT_SCRIPT: Script = preload("res://src/core/weapon_component.gd")
const DAMAGE_CALCULATOR_SCRIPT: Script = preload("res://src/foundation/damage_calculator.gd")

var data_manager
var combat
var weapons
var _attack_events: Array[Dictionary] = []


func before_test() -> void:
	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)
	combat = COMBAT_COMPONENT_SCRIPT.new()
	add_child(combat)
	weapons = WEAPON_COMPONENT_SCRIPT.new()
	add_child(weapons)
	weapons.set_data_manager(data_manager)
	weapons.set_combat_adapter(combat)
	combat.on_attack_hit.connect(_on_attack_hit)
	_attack_events.clear()


func after_test() -> void:
	if is_instance_valid(weapons):
		if weapons.get_parent() != null:
			weapons.get_parent().remove_child(weapons)
		weapons.free()
	if is_instance_valid(combat):
		if combat.get_parent() != null:
			combat.get_parent().remove_child(combat)
		combat.free()
	if is_instance_valid(data_manager):
		if data_manager.get_parent() != null:
			data_manager.get_parent().remove_child(data_manager)
		data_manager.free()
	weapons = null
	combat = null
	data_manager = null
	_attack_events.clear()


func test_cat_claw_dodge_completion_opens_half_second_counter_window() -> void:
	_finish_ground_dodge()

	assert_int(combat.get_dodge_counter_window()).is_equal(30)

	combat.advance_dodge_counter_frames(29)
	assert_int(combat.get_dodge_counter_window()).is_equal(1)

	combat.advance_dodge_counter_frames(1)
	assert_int(combat.get_dodge_counter_window()).is_equal(0)


func test_qualifying_cat_claw_hit_injects_bonus_and_consumes_counter_window() -> void:
	_finish_ground_dodge()

	combat.on_hit_confirmed({
		"hit_frame": 4,
		"attack_metadata": {"attack_type": &"light"},
	})
	combat.on_hit_confirmed({
		"hit_frame": 4,
		"attack_metadata": {"attack_type": &"light"},
	})

	assert_int(_attack_events.size()).is_equal(2)
	assert_int(_attack_events[0]["crit_window_bonus"]).is_equal(3)
	assert_int(int(_attack_events[0]["skill_modifiers"].get("claw_counter_crit_window_bonus_frames", 0))).is_equal(3)
	assert_int(_attack_events[1]["crit_window_bonus"]).is_equal(0)
	assert_int(int(_attack_events[1]["skill_modifiers"].get("claw_counter_crit_window_bonus_frames", 0))).is_equal(0)
	assert_int(combat.get_dodge_counter_window()).is_equal(0)


func test_non_cat_claw_weapon_does_not_open_counter_bonus() -> void:
	weapons.deserialize({"current_weapon_index": 1})

	_finish_ground_dodge()
	combat.on_hit_confirmed({
		"hit_frame": 4,
		"attack_metadata": {"attack_type": &"light", "weapon_id": &"long_tail"},
	})

	assert_str(String(weapons.get_current_weapon().weapon_id)).is_equal("long_tail")
	assert_int(combat.get_dodge_counter_window()).is_equal(0)
	assert_int(_attack_events[0]["crit_window_bonus"]).is_equal(0)
	assert_int(int(_attack_events[0]["skill_modifiers"].get("claw_counter_crit_window_bonus_frames", 0))).is_equal(0)


func test_damage_calculator_treats_claw_counter_bonus_as_perfect_window_extension() -> void:
	var modifiers: Dictionary = {"claw_counter_crit_window_bonus_frames": 3}

	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_crit_type(4, 0))).is_equal("good")
	assert_str(String(DAMAGE_CALCULATOR_SCRIPT.classify_crit_type_with_modifiers(4, 0, modifiers))).is_equal("perfect")
	assert_float(DAMAGE_CALCULATOR_SCRIPT.calculate_crit_multiplier_with_modifiers(4, 0, modifiers)).is_equal(2.5)


func _finish_ground_dodge() -> void:
	combat.on_action_triggered(&"dodge", {})
	combat.advance_dodge_frames(COMBAT_COMPONENT_SCRIPT.DODGE_TOTAL_FRAMES)


func _on_attack_hit(metadata: Dictionary) -> void:
	_attack_events.append(metadata.duplicate(true))
