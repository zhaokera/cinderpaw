## Story 004: Multi-target fan-out and duplicate suppression.
extends GdUnitTestSuite

const COLLISION_COMPONENT_SCRIPT: Script = preload("res://src/core/collision_component.gd")

var attacker
var target_a
var target_b
var target_c
var enemy_attacker
var _attacker_events: Array = []
var _enemy_events: Array = []


func before_test() -> void:
	attacker = _new_collision_component(101, &"player")
	target_a = _new_collision_component(201, &"enemy")
	target_b = _new_collision_component(202, &"enemy")
	target_c = _new_collision_component(203, &"enemy")
	enemy_attacker = _new_collision_component(301, &"enemy")
	_attacker_events.clear()
	_enemy_events.clear()
	attacker.on_hit_confirmed.connect(_record_attacker_event)
	enemy_attacker.on_hit_confirmed.connect(_record_enemy_event)


func after_test() -> void:
	for node in [attacker, target_a, target_b, target_c, enemy_attacker]:
		if is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()
	attacker = null
	target_a = null
	target_b = null
	target_c = null
	enemy_attacker = null
	_attacker_events.clear()
	_enemy_events.clear()


func test_one_hitbox_overlapping_three_hurtboxes_emits_three_events() -> void:
	attacker.activate_hitbox(&"tail_sweep", 3, Vector2.ZERO, Vector2(64, 24), {})

	attacker.process_detection_frame({
		&"tail_sweep": [
			target_a.get_hurtbox(),
			target_b.get_hurtbox(),
			target_c.get_hurtbox(),
		]
	})

	assert_int(_attacker_events.size()).is_equal(3)
	assert_array(_target_ids(_attacker_events)).contains_exactly([201, 202, 203])


func test_same_target_overlapping_for_two_frames_emits_only_first_hit() -> void:
	attacker.activate_hitbox(&"tail_sweep", 3, Vector2.ZERO, Vector2(64, 24), {})

	attacker.process_detection_frame({&"tail_sweep": [target_a.get_hurtbox()]})
	attacker.process_detection_frame({&"tail_sweep": [target_a.get_hurtbox()]})

	assert_int(_attacker_events.size()).is_equal(1)
	assert_int(_attacker_events[0].target_id).is_equal(201)


func test_reactivating_hitbox_clears_previous_target_marks() -> void:
	attacker.activate_hitbox(&"tail_sweep", 3, Vector2.ZERO, Vector2(64, 24), {})
	attacker.process_detection_frame({&"tail_sweep": [target_a.get_hurtbox()]})

	attacker.activate_hitbox(&"tail_sweep", 3, Vector2.ZERO, Vector2(64, 24), {})
	attacker.process_detection_frame({&"tail_sweep": [target_a.get_hurtbox()]})

	assert_int(_attacker_events.size()).is_equal(2)
	assert_int(_attacker_events[0].target_id).is_equal(201)
	assert_int(_attacker_events[1].target_id).is_equal(201)


func test_simultaneous_opposing_attacks_emit_independent_events() -> void:
	attacker.activate_hitbox(&"slash_1", 2, Vector2.ZERO, Vector2(16, 16), {})
	enemy_attacker.activate_hitbox(&"bite", 2, Vector2.ZERO, Vector2(16, 16), {})

	attacker.process_detection_frame({&"slash_1": [enemy_attacker.get_hurtbox()]})
	enemy_attacker.process_detection_frame({&"bite": [attacker.get_hurtbox()]})

	assert_int(_attacker_events.size()).is_equal(1)
	assert_int(_enemy_events.size()).is_equal(1)
	assert_int(_attacker_events[0].attacker_id).is_equal(101)
	assert_int(_attacker_events[0].target_id).is_equal(301)
	assert_int(_enemy_events[0].attacker_id).is_equal(301)
	assert_int(_enemy_events[0].target_id).is_equal(101)


func _new_collision_component(entity_id: int, allegiance: StringName):
	var component = COLLISION_COMPONENT_SCRIPT.new()
	add_child(component)
	component.configure_entity(entity_id, allegiance)
	return component


func _record_attacker_event(event) -> void:
	_attacker_events.append(event)


func _record_enemy_event(event) -> void:
	_enemy_events.append(event)


func _target_ids(events: Array) -> Array:
	var ids: Array = []
	for event in events:
		ids.append(event.target_id)
	return ids
