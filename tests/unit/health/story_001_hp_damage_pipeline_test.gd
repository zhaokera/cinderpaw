## Story 001: HealthComponent HP state, shield, damage, and death guards.
extends GdUnitTestSuite

const HEALTH_COMPONENT_SCRIPT: Script = preload("res://src/core/health_component.gd")

var health
var _hp_events: Array[Dictionary] = []
var _death_events: Array[Dictionary] = []
var _signal_order: Array[StringName] = []


func before_test() -> void:
	health = HEALTH_COMPONENT_SCRIPT.new()
	add_child(health)
	_hp_events.clear()
	_death_events.clear()
	_signal_order.clear()
	health.on_hp_changed.connect(_on_hp_changed)
	health.on_death.connect(_on_death)


func after_test() -> void:
	if is_instance_valid(health):
		if health.get_parent() != null:
			health.get_parent().remove_child(health)
		health.free()
	health = null
	_hp_events.clear()
	_death_events.clear()
	_signal_order.clear()


func test_configure_sets_hp_shield_and_alive_queries() -> void:
	health.configure(42, 100, 80, 10, 20)

	assert_int(health.get_entity_id()).is_equal(42)
	assert_int(health.get_current_hp()).is_equal(80)
	assert_int(health.get_max_hp()).is_equal(100)
	assert_int(health.get_shield()).is_equal(10)
	assert_int(health.get_max_shield()).is_equal(20)
	assert_float(health.get_hp_percentage()).is_equal(0.8)
	assert_float(health.get_shield_percentage()).is_equal(0.5)
	assert_bool(health.is_alive()).is_true()
	assert_bool(health.is_dead()).is_false()


func test_configure_replaces_invalid_max_hp_with_safe_default() -> void:
	health.configure(7, 0, 0, 0, 0)

	assert_int(health.get_max_hp()).is_equal(100)
	assert_int(health.get_current_hp()).is_equal(100)


func test_apply_damage_subtracts_hp_and_emits_changed_once() -> void:
	health.configure(42, 100, 100, 0, 0)
	var metadata: Dictionary = {"source": &"test"}

	health.apply_damage(30, metadata)

	assert_int(health.get_current_hp()).is_equal(70)
	assert_int(_hp_events.size()).is_equal(1)
	assert_int(_hp_events[0].get("entity_id", -1)).is_equal(42)
	assert_int(_hp_events[0].get("current_hp", -1)).is_equal(70)
	assert_int(_hp_events[0].get("max_hp", -1)).is_equal(100)
	assert_str(String(metadata.get("source", &""))).is_equal("test")


func test_shield_absorbs_damage_before_hp() -> void:
	health.configure(42, 100, 80, 20, 20)

	health.apply_damage(50, {"damage_type": &"slash"})

	assert_int(health.get_shield()).is_equal(0)
	assert_int(health.get_current_hp()).is_equal(50)
	assert_int(_hp_events.size()).is_equal(1)


func test_lethal_damage_emits_death_once_and_ignores_later_damage() -> void:
	health.configure(42, 100, 10, 0, 0)

	health.apply_damage(15, {"source": &"first"})
	health.apply_damage(15, {"source": &"second"})

	assert_int(health.get_current_hp()).is_equal(0)
	assert_bool(health.is_alive()).is_false()
	assert_bool(health.is_dead()).is_true()
	assert_int(_hp_events.size()).is_equal(1)
	assert_int(_death_events.size()).is_equal(1)
	assert_int(_death_events[0].get("entity_id", -1)).is_equal(42)
	assert_str(String(_death_events[0].get("source", &""))).is_equal("first")


func test_non_positive_damage_is_ignored() -> void:
	health.configure(42, 100, 50, 0, 0)

	health.apply_damage(0, {})
	health.apply_damage(-5, {})

	assert_int(health.get_current_hp()).is_equal(50)
	assert_int(_hp_events.size()).is_equal(0)
	assert_int(_death_events.size()).is_equal(0)


func test_lethal_damage_emits_hp_changed_before_death() -> void:
	health.configure(42, 100, 10, 0, 0)

	health.apply_damage(15, {"source": &"test"})

	assert_array(_signal_order).is_equal([&"hp_changed", &"death"])


func _on_hp_changed(entity_id: int, current_hp: int, max_hp: int) -> void:
	_signal_order.append(&"hp_changed")
	_hp_events.append({
		"entity_id": entity_id,
		"current_hp": current_hp,
		"max_hp": max_hp,
	})


func _on_death(entity_id: int, metadata: Dictionary) -> void:
	_signal_order.append(&"death")
	var event: Dictionary = metadata.duplicate(true)
	event["entity_id"] = entity_id
	_death_events.append(event)
