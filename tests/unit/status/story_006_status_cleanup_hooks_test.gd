## Story 006: Status cleanup hooks for death and scene transitions.
extends GdUnitTestSuite

const STATUS_EFFECT_COMPONENT_SCRIPT: Script = preload("res://src/core/status_effect_component.gd")


class FakeHealthAdapter:
	extends Node

	signal on_death(entity_id: int, metadata: Dictionary)

	func emit_death(entity_id: int) -> void:
		on_death.emit(entity_id, {"source": &"test"})


class FakeSceneAdapter:
	extends Node

	signal on_scene_changed(old_scene: StringName, new_scene: StringName)

	func emit_scene_changed() -> void:
		on_scene_changed.emit(&"street", &"hub")


var status_effects
var health_adapter: FakeHealthAdapter
var scene_adapter: FakeSceneAdapter
var _expired_events: Array[Dictionary] = []


func before_test() -> void:
	status_effects = STATUS_EFFECT_COMPONENT_SCRIPT.new()
	health_adapter = FakeHealthAdapter.new()
	scene_adapter = FakeSceneAdapter.new()
	add_child(status_effects)
	add_child(health_adapter)
	add_child(scene_adapter)
	status_effects.configure_entity(7, false)
	_connect_expired_signal()
	_expired_events.clear()


func after_test() -> void:
	for node in [status_effects, health_adapter, scene_adapter]:
		if is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()
	status_effects = null
	health_adapter = null
	scene_adapter = null
	_expired_events.clear()


func test_owner_death_clears_all_effects_and_emits_expiration_once() -> void:
	status_effects.set_health_adapter(health_adapter)
	_apply_two_effects()

	health_adapter.emit_death(7)
	health_adapter.emit_death(7)

	assert_array(status_effects.get_active_effects()).is_empty()
	assert_int(_expired_events.size()).is_equal(2)
	var expired_ids: Array[String] = _expired_effect_ids()
	assert_bool(expired_ids.has("poison")).is_true()
	assert_bool(expired_ids.has("slow")).is_true()


func test_foreign_death_does_not_clear_this_component() -> void:
	status_effects.set_health_adapter(health_adapter)
	_apply_two_effects()

	health_adapter.emit_death(8)

	assert_int(status_effects.get_active_effects().size()).is_equal(2)
	assert_bool(status_effects.has_status(&"poison")).is_true()
	assert_bool(status_effects.has_status(&"slow")).is_true()
	assert_array(_expired_events).is_empty()


func test_scene_transition_signal_clears_all_effects_once() -> void:
	status_effects.set_scene_adapter(scene_adapter)
	_apply_two_effects()

	scene_adapter.emit_scene_changed()
	scene_adapter.emit_scene_changed()

	assert_array(status_effects.get_active_effects()).is_empty()
	assert_int(_expired_events.size()).is_equal(2)
	var expired_ids: Array[String] = _expired_effect_ids()
	assert_bool(expired_ids.has("poison")).is_true()
	assert_bool(expired_ids.has("slow")).is_true()


func test_direct_cleanup_is_idempotent() -> void:
	_apply_two_effects()

	status_effects.clear_all_effects()
	status_effects.clear_all_effects()

	assert_array(status_effects.get_active_effects()).is_empty()
	assert_int(_expired_events.size()).is_equal(2)


func _apply_two_effects() -> void:
	assert_bool(status_effects.apply_status(7, &"poison", 3)).is_true()
	assert_bool(status_effects.apply_status(7, &"slow", 3)).is_true()
	assert_int(status_effects.get_active_effects().size()).is_equal(2)


func _expired_effect_ids() -> Array[String]:
	var effect_ids: Array[String] = []
	for event: Dictionary in _expired_events:
		effect_ids.append(String(event["effect_id"]))
	return effect_ids


func _record_status_expired(target_id: int, effect_id: StringName) -> void:
	_expired_events.append({
		"target_id": target_id,
		"effect_id": effect_id,
	})


func _connect_expired_signal() -> void:
	var expired_signal: Signal = status_effects.get("status_expired")
	if not expired_signal.is_connected(_record_status_expired):
		expired_signal.connect(_record_status_expired)
