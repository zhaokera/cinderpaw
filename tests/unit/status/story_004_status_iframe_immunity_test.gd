## Story 004: Status i-frame and invincible debuff immunity.
extends GdUnitTestSuite

const STATUS_EFFECT_COMPONENT_SCRIPT: Script = preload("res://src/core/status_effect_component.gd")


class FakeHealthAdapter:
	extends RefCounted

	var invincible: bool = false
	var granted_iframes: Array[int] = []

	func is_invincible() -> bool:
		return invincible

	func grant_iframes(frames: int) -> void:
		granted_iframes.append(frames)


var status_effects
var health_adapter: FakeHealthAdapter
var _applied_events: Array[Dictionary] = []


func before_test() -> void:
	status_effects = STATUS_EFFECT_COMPONENT_SCRIPT.new()
	health_adapter = FakeHealthAdapter.new()
	add_child(status_effects)
	status_effects.configure_entity(7, false)
	status_effects.set_health_adapter(health_adapter)
	_connect_applied_signal()
	_applied_events.clear()


func after_test() -> void:
	if is_instance_valid(status_effects):
		if status_effects.get_parent() != null:
			status_effects.get_parent().remove_child(status_effects)
		status_effects.free()
	status_effects = null
	health_adapter = null
	_applied_events.clear()


func test_health_adapter_invincible_rejects_debuff_before_application() -> void:
	health_adapter.invincible = true

	assert_bool(status_effects.apply_status(7, &"poison", 3)).is_false()

	assert_bool(status_effects.has_status(&"poison")).is_false()
	assert_array(status_effects.get_active_effects()).is_empty()
	assert_int(_applied_events.size()).is_equal(0)


func test_buff_can_apply_while_health_adapter_is_invincible() -> void:
	health_adapter.invincible = true

	assert_bool(status_effects.apply_status(7, &"speed_boost", 3)).is_true()

	assert_bool(status_effects.has_status(&"speed_boost")).is_true()
	assert_int(_applied_events.size()).is_equal(1)
	assert_str(String(_applied_events[0]["effect_id"])).is_equal("speed_boost")


func test_active_invincible_status_rejects_later_debuffs() -> void:
	assert_bool(status_effects.apply_status(7, &"invincible", 3)).is_true()

	assert_bool(status_effects.apply_status(7, &"slow", 3)).is_false()

	assert_bool(status_effects.has_status(&"invincible")).is_true()
	assert_bool(status_effects.has_status(&"slow")).is_false()
	assert_int(status_effects.get_active_effects().size()).is_equal(1)


func test_invincible_status_is_queryable_for_health_integration() -> void:
	assert_bool(status_effects.apply_status(7, &"invincible", 3)).is_true()

	assert_bool(status_effects.has_status(&"invincible")).is_true()
	assert_float(status_effects.get_remaining_duration(&"invincible")).is_greater(0.0)


func _record_status_applied(target_id: int, effect_id: StringName) -> void:
	_applied_events.append({
		"target_id": target_id,
		"effect_id": effect_id,
	})


func _connect_applied_signal() -> void:
	if not status_effects.has_signal("status_applied"):
		assert_bool(false).override_failure_message(
			"StatusEffectComponent.status_applied signal must exist"
		).is_true()
		return
	var applied_signal: Signal = status_effects.get("status_applied")
	if not applied_signal.is_connected(_record_status_applied):
		applied_signal.connect(_record_status_applied)
