## Story 003: Frame-level hit detection and HitEvent payload signal.
extends GdUnitTestSuite

const COLLISION_COMPONENT_SCRIPT: Script = preload("res://src/core/collision_component.gd")
const HIT_EVENT_SCRIPT: Script = preload("res://src/core/events/hit_event.gd")

var attacker
var target
var _hit_events: Array = []


func before_test() -> void:
	attacker = COLLISION_COMPONENT_SCRIPT.new()
	target = COLLISION_COMPONENT_SCRIPT.new()
	add_child(attacker)
	add_child(target)
	attacker.configure_entity(101, &"player")
	target.configure_entity(202, &"enemy")
	_hit_events.clear()
	attacker.on_hit_confirmed.connect(_record_hit_event)


func after_test() -> void:
	for node in [attacker, target]:
		if is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()
	attacker = null
	target = null
	_hit_events.clear()


func test_hit_event_exposes_all_payload_fields() -> void:
	var event = HIT_EVENT_SCRIPT.new(
		101,
		202,
		&"slash_1",
		Vector2(12, 4),
		2,
		{"attack_type": &"light"}
	)

	assert_int(event.attacker_id).is_equal(101)
	assert_int(event.target_id).is_equal(202)
	assert_str(String(event.hitbox_id)).is_equal("slash_1")
	assert_float(event.hit_position.x).is_equal(12.0)
	assert_float(event.hit_position.y).is_equal(4.0)
	assert_int(event.hit_frame).is_equal(2)
	assert_str(String(event.attack_metadata["attack_type"])).is_equal("light")


func test_valid_opposing_hurtbox_overlap_emits_one_hit_event() -> void:
	attacker.activate_hitbox(
		&"slash_1",
		2,
		Vector2(10, 0),
		Vector2(16, 16),
		{"attack_type": &"light", "combo_index": 1}
	)
	target.get_hurtbox().position = Vector2(14, 0)

	attacker.process_detection_frame({&"slash_1": [target.get_hurtbox()]})

	assert_int(_hit_events.size()).is_equal(1)
	var event = _hit_events[0]
	assert_bool(event.get_script() == HIT_EVENT_SCRIPT).is_true()
	assert_int(event.attacker_id).is_equal(101)
	assert_int(event.target_id).is_equal(202)
	assert_str(String(event.hitbox_id)).is_equal("slash_1")
	assert_float(event.hit_position.x).is_equal(12.0)
	assert_float(event.hit_position.y).is_equal(0.0)
	assert_int(event.hit_frame).is_equal(2)
	assert_str(String(event.attack_metadata["attack_type"])).is_equal("light")
	assert_int(event.attack_metadata["combo_index"]).is_equal(1)
	assert_int(attacker.get_hitbox(&"slash_1").get_remaining_frames()).is_equal(1)


func test_hitbox_vs_own_hurtbox_does_not_emit() -> void:
	attacker.activate_hitbox(&"slash_1", 2, Vector2.ZERO, Vector2(16, 16), {})

	attacker.process_detection_frame({&"slash_1": [attacker.get_hurtbox()]})

	assert_int(_hit_events.size()).is_equal(0)
	assert_int(attacker.get_hitbox(&"slash_1").get_remaining_frames()).is_equal(1)


func test_gone_target_hurtbox_does_not_emit() -> void:
	target.set_hurtbox_state(&"gone")
	attacker.activate_hitbox(&"slash_1", 2, Vector2.ZERO, Vector2(16, 16), {})

	attacker.process_detection_frame({&"slash_1": [target.get_hurtbox()]})

	assert_int(_hit_events.size()).is_equal(0)
	assert_int(attacker.get_hitbox(&"slash_1").get_remaining_frames()).is_equal(1)


func test_physics_process_decrements_active_hitboxes_once_per_frame() -> void:
	attacker.activate_hitbox(&"slash_1", 2, Vector2.ZERO, Vector2(16, 16), {})

	attacker._physics_process(1.0 / 60.0)

	assert_int(attacker.get_hitbox(&"slash_1").get_remaining_frames()).is_equal(1)


func _record_hit_event(event) -> void:
	_hit_events.append(event)
