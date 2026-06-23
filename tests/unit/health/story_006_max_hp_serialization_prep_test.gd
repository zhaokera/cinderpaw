## Story 006: HealthComponent max HP aggregation and serialization prep.
extends GdUnitTestSuite

const HEALTH_COMPONENT_SCRIPT: Script = preload("res://src/core/health_component.gd")

var health
var clone
var _hp_events: Array[Dictionary] = []


func before_test() -> void:
	health = HEALTH_COMPONENT_SCRIPT.new()
	add_child(health)
	_hp_events.clear()
	health.on_hp_changed.connect(_on_hp_changed)


func after_test() -> void:
	if is_instance_valid(health):
		if health.get_parent() != null:
			health.get_parent().remove_child(health)
		health.free()
	if is_instance_valid(clone):
		if clone.get_parent() != null:
			clone.get_parent().remove_child(clone)
		clone.free()
	health = null
	clone = null
	_hp_events.clear()


func test_recalculate_max_hp_uses_hd_f0_base_skill_and_charm_sources() -> void:
	health.configure(42, 100, 100, 0, 0)

	health.recalculate_max_hp(100, 25, 15)

	assert_int(health.get_max_hp()).is_equal(140)
	assert_int(health.get_current_hp()).is_equal(140)


func test_invalid_recalculated_max_hp_uses_safe_default() -> void:
	health.configure(42, 100, 40, 0, 0)

	health.recalculate_max_hp(-200, 50, 20)

	assert_int(health.get_max_hp()).is_equal(100)
	assert_int(health.get_current_hp()).is_equal(40)
	assert_float(health.get_hp_percentage()).is_equal(0.4)


func test_recalculate_max_hp_preserves_current_hp_percentage() -> void:
	health.configure(42, 100, 50, 0, 0)

	health.recalculate_max_hp(120, 20, 10)

	assert_int(health.get_max_hp()).is_equal(150)
	assert_int(health.get_current_hp()).is_equal(75)
	assert_array(_hp_events).is_equal([{
		"entity_id": 42,
		"current_hp": 75,
		"max_hp": 150,
	}])


func test_get_injury_pitch_offset_uses_hd_f4_default_max_semitones() -> void:
	health.configure(42, 100, 25, 0, 0)

	assert_float(health.get_injury_pitch_offset()).is_equal(7.5)


func test_serialize_deserialize_round_trip_preserves_health_state() -> void:
	health.configure(42, 100, 25, 7, 20, true)
	health.set_current_zone_id(&"sewer_01")
	health.set_active_enemy_count(1)
	health.recalculate_max_hp(80, 10, 10)

	var data: Dictionary = health.serialize()
	clone = HEALTH_COMPONENT_SCRIPT.new()
	add_child(clone)
	clone.deserialize(data, 1)

	assert_int(clone.get_entity_id()).is_equal(42)
	assert_int(clone.get_max_hp()).is_equal(100)
	assert_int(clone.get_current_hp()).is_equal(25)
	assert_int(clone.get_shield()).is_equal(7)
	assert_int(clone.get_max_shield()).is_equal(20)
	assert_str(String(clone.get_current_zone_id())).is_equal("sewer_01")
	assert_bool(clone.is_focus_mode_active()).is_true()
	assert_bool(clone.is_alive()).is_true()


func _on_hp_changed(entity_id: int, current_hp: int, max_hp: int) -> void:
	_hp_events.append({
		"entity_id": entity_id,
		"current_hp": current_hp,
		"max_hp": max_hp,
	})
