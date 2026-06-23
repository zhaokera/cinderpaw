## Story 002: Status application, refresh, and Boss STUN immunity.
extends GdUnitTestSuite

const STATUS_EFFECT_COMPONENT_SCRIPT: Script = preload("res://src/core/status_effect_component.gd")

var status_effects
var _applied_events: Array[Dictionary] = []


func before_test() -> void:
	status_effects = STATUS_EFFECT_COMPONENT_SCRIPT.new()
	add_child(status_effects)
	_applied_events.clear()


func after_test() -> void:
	if is_instance_valid(status_effects):
		if status_effects.get_parent() != null:
			status_effects.get_parent().remove_child(status_effects)
		status_effects.free()
	status_effects = null
	_applied_events.clear()


func test_apply_status_adds_effect_and_emits_signal() -> void:
	if not _connect_applied_signal() or not _configure_entity(7, false):
		return

	assert_bool(status_effects.apply_status(7, &"slow", 3)).is_true()

	var active_effects: Array = status_effects.get_active_effects()
	assert_bool(status_effects.has_status(&"slow")).is_true()
	assert_int(active_effects.size()).is_equal(1)
	assert_str(String(active_effects[0]["effect_id"])).is_equal("slow")
	assert_int(active_effects[0]["target_id"]).is_equal(7)
	assert_int(active_effects[0]["source_id"]).is_equal(3)
	assert_int(_applied_events.size()).is_equal(1)
	assert_int(_applied_events[0]["target_id"]).is_equal(7)
	assert_str(String(_applied_events[0]["effect_id"])).is_equal("slow")


func test_reapplying_same_effect_refreshes_without_duplicate() -> void:
	if not _connect_applied_signal() or not _configure_entity(7, false):
		return

	assert_bool(status_effects.apply_status(7, &"poison", 3)).is_true()
	assert_bool(status_effects.apply_status(7, &"poison", 3)).is_true()

	assert_int(status_effects.get_active_effects().size()).is_equal(1)
	assert_float(status_effects.get_remaining_duration(&"poison")).is_equal_approx(5.0, 0.001)
	assert_int(_applied_events.size()).is_equal(1)


func test_boss_rejects_stun_without_emitting_signal() -> void:
	if not _connect_applied_signal() or not _configure_entity(99, true):
		return

	assert_bool(status_effects.apply_status(99, &"stun", 3)).is_false()

	assert_bool(status_effects.has_status(&"stun")).is_false()
	assert_array(status_effects.get_active_effects()).is_empty()
	assert_int(_applied_events.size()).is_equal(0)


func test_non_boss_can_receive_stun() -> void:
	if not _connect_applied_signal() or not _configure_entity(7, false):
		return

	assert_bool(status_effects.apply_status(7, &"stun", 3)).is_true()

	assert_bool(status_effects.has_status(&"stun")).is_true()
	assert_int(_applied_events.size()).is_equal(1)


func test_unknown_effect_is_rejected_safely() -> void:
	if not _connect_applied_signal() or not _configure_entity(7, false):
		return

	assert_bool(status_effects.apply_status(7, &"unknown", 3)).is_false()

	assert_array(status_effects.get_active_effects()).is_empty()
	assert_int(_applied_events.size()).is_equal(0)


func _record_status_applied(target_id: int, effect_id: StringName) -> void:
	_applied_events.append({
		"target_id": target_id,
		"effect_id": effect_id,
	})


func _connect_applied_signal() -> bool:
	if not status_effects.has_signal("status_applied"):
		assert_bool(false).override_failure_message(
			"StatusEffectComponent.status_applied signal must exist"
		).is_true()
		return false
	var applied_signal: Signal = status_effects.get("status_applied")
	if not applied_signal.is_connected(_record_status_applied):
		applied_signal.connect(_record_status_applied)
	return true


func _configure_entity(entity_id: int, is_boss: bool) -> bool:
	if not status_effects.has_method("configure_entity"):
		assert_bool(false).override_failure_message(
			"StatusEffectComponent.configure_entity() must exist"
		).is_true()
		return false
	status_effects.configure_entity(entity_id, is_boss)
	return true
