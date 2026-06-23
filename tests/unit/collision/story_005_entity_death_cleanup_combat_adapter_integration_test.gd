## Story 005: Death cleanup and Combat adapter integration.
extends GdUnitTestSuite

const COLLISION_COMPONENT_SCRIPT: Script = preload("res://src/core/collision_component.gd")
const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")

class FakeHealthAdapter:
	extends Node

	signal on_death(entity_id: int, metadata: Dictionary)

	func emit_death(entity_id: int) -> void:
		on_death.emit(entity_id, {"source": &"test"})


var collision
var target
var combat
var health_adapter: FakeHealthAdapter
var _hit_events: Array = []
var _attack_events: Array[Dictionary] = []


func before_test() -> void:
	collision = COLLISION_COMPONENT_SCRIPT.new()
	target = COLLISION_COMPONENT_SCRIPT.new()
	combat = COMBAT_COMPONENT_SCRIPT.new()
	health_adapter = FakeHealthAdapter.new()
	add_child(collision)
	add_child(target)
	add_child(combat)
	add_child(health_adapter)
	collision.configure_entity(101, &"player")
	target.configure_entity(202, &"enemy")
	_hit_events.clear()
	_attack_events.clear()
	collision.on_hit_confirmed.connect(_record_hit_event)
	combat.on_attack_hit.connect(_record_attack_event)


func after_test() -> void:
	for node in [collision, target, combat, health_adapter]:
		if is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()
	collision = null
	target = null
	combat = null
	health_adapter = null
	_hit_events.clear()
	_attack_events.clear()


func test_health_adapter_death_signal_deactivates_all_active_hitboxes() -> void:
	collision.set_health_adapter(health_adapter)
	collision.activate_hitbox(&"slash_1", 3, Vector2.ZERO, Vector2(16, 16), {})
	collision.activate_hitbox(&"tail_sweep", 3, Vector2.ZERO, Vector2(64, 16), {})

	health_adapter.emit_death(101)

	assert_bool(collision.is_hitbox_active(&"slash_1")).is_false()
	assert_bool(collision.is_hitbox_active(&"tail_sweep")).is_false()
	assert_int(collision.get_active_hitbox_count()).is_equal(0)


func test_death_cleanup_sets_hurtbox_safe_and_blocks_late_hit_events() -> void:
	collision.set_health_adapter(health_adapter)
	collision.activate_hitbox(&"slash_1", 3, Vector2.ZERO, Vector2(16, 16), {})

	health_adapter.emit_death(101)
	collision.process_detection_frame({&"slash_1": [target.get_hurtbox()]})

	assert_int(_hit_events.size()).is_equal(0)
	assert_str(String(collision.get_hurtbox_state())).is_equal("gone")
	assert_bool(collision.get_hurtbox().monitorable).is_false()


func test_repeated_or_foreign_death_signals_are_safe() -> void:
	collision.set_health_adapter(health_adapter)
	collision.activate_hitbox(&"slash_1", 3, Vector2.ZERO, Vector2(16, 16), {})

	health_adapter.emit_death(999)
	assert_bool(collision.is_hitbox_active(&"slash_1")).is_true()

	health_adapter.emit_death(101)
	health_adapter.emit_death(101)

	assert_bool(collision.is_hitbox_active(&"slash_1")).is_false()
	assert_int(collision.get_active_hitbox_count()).is_equal(0)


func test_combat_can_use_collision_as_hurtbox_and_hit_adapter() -> void:
	combat.set_hurtbox_adapter(collision)
	combat.set_collision_adapter(collision)
	combat.on_action_triggered(&"dodge", {})
	combat.advance_dodge_frames(COMBAT_COMPONENT_SCRIPT.DODGE_IFRAME_START)

	assert_str(String(collision.get_hurtbox_state())).is_equal("gone")

	collision.activate_hitbox(
		&"slash_1",
		2,
		Vector2.ZERO,
		Vector2(16, 16),
		{"attack_type": &"light", "combo_index": 0}
	)
	collision.process_detection_frame({&"slash_1": [target.get_hurtbox()]})

	assert_int(_attack_events.size()).is_equal(1)
	assert_int(_attack_events[0]["attacker_id"]).is_equal(101)
	assert_int(_attack_events[0]["target_id"]).is_equal(202)
	assert_str(String(_attack_events[0]["hitbox_id"])).is_equal("slash_1")


func _record_hit_event(event) -> void:
	_hit_events.append(event)


func _record_attack_event(metadata: Dictionary) -> void:
	_attack_events.append(metadata.duplicate(true))
