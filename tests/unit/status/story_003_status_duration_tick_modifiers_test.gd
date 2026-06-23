## Story 003: Status durations, DoT ticks, and modifier queries.
extends GdUnitTestSuite

const STATUS_EFFECT_COMPONENT_SCRIPT: Script = preload("res://src/core/status_effect_component.gd")


class FakeHealthAdapter:
	extends RefCounted

	var damage_calls: Array[Dictionary] = []

	func apply_damage(amount: int, metadata: Dictionary) -> void:
		damage_calls.append({
			"amount": amount,
			"metadata": metadata.duplicate(true),
		})


var status_effects
var health_adapter: FakeHealthAdapter
var _expired_events: Array[Dictionary] = []


func before_test() -> void:
	status_effects = STATUS_EFFECT_COMPONENT_SCRIPT.new()
	health_adapter = FakeHealthAdapter.new()
	add_child(status_effects)
	status_effects.configure_entity(7, false)
	status_effects.set_health_adapter(health_adapter)
	_connect_expired_signal()
	_expired_events.clear()


func after_test() -> void:
	if is_instance_valid(status_effects):
		if status_effects.get_parent() != null:
			status_effects.get_parent().remove_child(status_effects)
		status_effects.free()
	status_effects = null
	health_adapter = null
	_expired_events.clear()


func test_advance_time_expires_effect_and_emits_signal() -> void:
	assert_bool(status_effects.apply_status(7, &"slow", 3)).is_true()

	status_effects.advance_time(2.1)

	assert_bool(status_effects.has_status(&"slow")).is_false()
	assert_array(status_effects.get_active_effects()).is_empty()
	assert_int(_expired_events.size()).is_equal(1)
	assert_int(_expired_events[0]["target_id"]).is_equal(7)
	assert_str(String(_expired_events[0]["effect_id"])).is_equal("slow")


func test_poison_ticks_once_per_second_through_health_adapter() -> void:
	assert_bool(status_effects.apply_status(7, &"poison", 3)).is_true()

	status_effects.advance_time(0.5)
	assert_array(health_adapter.damage_calls).is_empty()

	status_effects.advance_time(0.5)

	assert_int(health_adapter.damage_calls.size()).is_equal(1)
	assert_int(health_adapter.damage_calls[0]["amount"]).is_equal(3)
	var metadata: Dictionary = health_adapter.damage_calls[0]["metadata"]
	assert_str(String(metadata["effect_id"])).is_equal("poison")
	assert_int(metadata["source_id"]).is_equal(3)
	assert_str(String(metadata["damage_type"])).is_equal("status_dot")


func test_burn_ticks_damage_and_exposes_movement_modifier() -> void:
	assert_bool(status_effects.apply_status(7, &"burn", 11)).is_true()

	status_effects.advance_time(1.0)

	assert_int(health_adapter.damage_calls.size()).is_equal(1)
	assert_int(health_adapter.damage_calls[0]["amount"]).is_equal(5)
	assert_float(status_effects.get_movement_modifier()).is_equal_approx(0.9, 0.001)


func test_movement_and_damage_modifiers_multiply_active_effects() -> void:
	assert_bool(status_effects.apply_status(7, &"slow", 3)).is_true()
	assert_bool(status_effects.apply_status(7, &"speed_boost", 3)).is_true()
	assert_bool(status_effects.apply_status(7, &"damage_boost", 3)).is_true()

	assert_float(status_effects.get_movement_modifier()).is_equal_approx(0.91, 0.001)
	assert_float(status_effects.get_damage_modifier()).is_equal_approx(1.25, 0.001)


func test_expired_effects_no_longer_contribute_modifiers() -> void:
	assert_bool(status_effects.apply_status(7, &"slow", 3)).is_true()
	assert_bool(status_effects.apply_status(7, &"damage_boost", 3)).is_true()

	status_effects.advance_time(2.1)

	assert_float(status_effects.get_movement_modifier()).is_equal_approx(1.0, 0.001)
	assert_float(status_effects.get_damage_modifier()).is_equal_approx(1.25, 0.001)


func _record_status_expired(target_id: int, effect_id: StringName) -> void:
	_expired_events.append({
		"target_id": target_id,
		"effect_id": effect_id,
	})


func _connect_expired_signal() -> void:
	if not status_effects.has_signal("status_expired"):
		assert_bool(false).override_failure_message(
			"StatusEffectComponent.status_expired signal must exist"
		).is_true()
		return
	var expired_signal: Signal = status_effects.get("status_expired")
	if not expired_signal.is_connected(_record_status_expired):
		expired_signal.connect(_record_status_expired)
