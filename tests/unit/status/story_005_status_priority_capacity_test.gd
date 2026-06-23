## Story 005: Status priority metadata and capacity eviction.
extends GdUnitTestSuite

const STATUS_EFFECT_COMPONENT_SCRIPT: Script = preload("res://src/core/status_effect_component.gd")

var status_effects
var _expired_events: Array[Dictionary] = []
var _applied_events: Array[Dictionary] = []


func before_test() -> void:
	status_effects = STATUS_EFFECT_COMPONENT_SCRIPT.new()
	add_child(status_effects)
	status_effects.configure_entity(7, false)
	_connect_status_signals()
	_expired_events.clear()
	_applied_events.clear()


func after_test() -> void:
	if is_instance_valid(status_effects):
		if status_effects.get_parent() != null:
			status_effects.get_parent().remove_child(status_effects)
		status_effects.free()
	status_effects = null
	_expired_events.clear()
	_applied_events.clear()


func test_effect_priority_matches_gdd_order() -> void:
	var ordered_effects: Array[StringName] = [
		&"stun",
		&"slow",
		&"poison",
		&"burn",
		&"speed_boost",
		&"damage_boost",
		&"invincible",
	]

	for index: int in range(ordered_effects.size() - 1):
		var higher_priority: int = status_effects.get_effect_priority(ordered_effects[index])
		var lower_priority: int = status_effects.get_effect_priority(ordered_effects[index + 1])
		assert_int(higher_priority).is_greater(lower_priority)


func test_sixth_distinct_effect_keeps_capacity_at_five() -> void:
	_apply_five_distinct_effects()

	assert_bool(status_effects.apply_status(7, &"stun", 3)).is_true()

	assert_int(status_effects.get_active_effects().size()).is_equal(5)
	assert_bool(status_effects.has_status(&"stun")).is_true()


func test_sixth_distinct_effect_evicts_oldest_and_emits_expired() -> void:
	_apply_five_distinct_effects()

	assert_bool(status_effects.apply_status(7, &"stun", 3)).is_true()

	assert_bool(status_effects.has_status(&"poison")).is_false()
	assert_bool(status_effects.has_status(&"slow")).is_true()
	assert_bool(status_effects.has_status(&"stun")).is_true()
	assert_int(_expired_events.size()).is_equal(1)
	assert_int(_expired_events[0]["target_id"]).is_equal(7)
	assert_str(String(_expired_events[0]["effect_id"])).is_equal("poison")


func _apply_five_distinct_effects() -> void:
	assert_bool(status_effects.apply_status(7, &"poison", 3)).is_true()
	assert_bool(status_effects.apply_status(7, &"slow", 3)).is_true()
	assert_bool(status_effects.apply_status(7, &"burn", 3)).is_true()
	assert_bool(status_effects.apply_status(7, &"speed_boost", 3)).is_true()
	assert_bool(status_effects.apply_status(7, &"damage_boost", 3)).is_true()
	assert_int(status_effects.get_active_effects().size()).is_equal(5)


func _record_status_applied(target_id: int, effect_id: StringName) -> void:
	_applied_events.append({
		"target_id": target_id,
		"effect_id": effect_id,
	})


func _record_status_expired(target_id: int, effect_id: StringName) -> void:
	_expired_events.append({
		"target_id": target_id,
		"effect_id": effect_id,
	})


func _connect_status_signals() -> void:
	var applied_signal: Signal = status_effects.get("status_applied")
	if not applied_signal.is_connected(_record_status_applied):
		applied_signal.connect(_record_status_applied)
	var expired_signal: Signal = status_effects.get("status_expired")
	if not expired_signal.is_connected(_record_status_expired):
		expired_signal.connect(_record_status_expired)
