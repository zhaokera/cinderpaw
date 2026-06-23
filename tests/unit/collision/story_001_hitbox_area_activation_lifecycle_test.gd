## Story 001: HitboxArea activation lifecycle and duplicate tracking.
extends GdUnitTestSuite

const HITBOX_AREA_SCRIPT: Script = preload("res://src/core/hitbox_area.gd")
const COLLISION_COMPONENT_SCRIPT: Script = preload("res://src/core/collision_component.gd")

var collision


func before_test() -> void:
	collision = COLLISION_COMPONENT_SCRIPT.new()
	add_child(collision)


func after_test() -> void:
	if is_instance_valid(collision):
		if collision.get_parent() != null:
			collision.get_parent().remove_child(collision)
		collision.free()
	collision = null


func test_hitbox_area_starts_inactive_and_tracks_hit_targets() -> void:
	var hitbox = HITBOX_AREA_SCRIPT.new()
	add_child(hitbox)

	assert_bool(hitbox.is_active()).is_false()
	assert_bool(hitbox.has_hit(7)).is_false()

	hitbox.mark_hit(7)
	hitbox.mark_hit(7)

	assert_bool(hitbox.has_hit(7)).is_true()
	assert_bool(hitbox.has_hit(8)).is_false()

	hitbox.clear_hits()

	assert_bool(hitbox.has_hit(7)).is_false()

	remove_child(hitbox)
	hitbox.free()


func test_activate_hitbox_applies_lifecycle_data_and_clears_old_hits() -> void:
	collision.activate_hitbox(
		&"slash_1",
		3,
		Vector2(12, -4),
		Vector2(32, 20),
		{"attack_type": &"light", "combo_index": 1}
	)
	var hitbox = collision.get_hitbox(&"slash_1")
	hitbox.mark_hit(7)

	collision.activate_hitbox(
		&"slash_1",
		5,
		Vector2(8, 2),
		Vector2(40, 24),
		{"attack_type": &"heavy"}
	)

	assert_bool(hitbox.is_active()).is_true()
	assert_int(hitbox.get_remaining_frames()).is_equal(5)
	assert_float(hitbox.position.x).is_equal(8.0)
	assert_float(hitbox.position.y).is_equal(2.0)
	assert_float(hitbox.get_hitbox_size().x).is_equal(40.0)
	assert_float(hitbox.get_hitbox_size().y).is_equal(24.0)
	assert_str(String(hitbox.get_attack_metadata()["attack_type"])).is_equal("heavy")
	assert_bool(hitbox.has_hit(7)).is_false()
	assert_int(collision.get_active_hitbox_count()).is_equal(1)


func test_advance_hitbox_frames_auto_deactivates_after_duration() -> void:
	collision.activate_hitbox(&"slash_1", 2, Vector2.ZERO, Vector2(16, 16), {})

	assert_bool(collision.is_hitbox_active(&"slash_1")).is_true()

	collision.advance_hitbox_frames(1)

	assert_bool(collision.is_hitbox_active(&"slash_1")).is_true()
	assert_int(collision.get_hitbox(&"slash_1").get_remaining_frames()).is_equal(1)

	collision.advance_hitbox_frames(1)

	assert_bool(collision.is_hitbox_active(&"slash_1")).is_false()
	assert_int(collision.get_active_hitbox_count()).is_equal(0)


func test_deactivate_hitbox_is_safe_for_active_and_unknown_ids() -> void:
	collision.activate_hitbox(&"slash_1", 3, Vector2.ZERO, Vector2(16, 16), {})

	collision.deactivate_hitbox(&"slash_1")
	collision.deactivate_hitbox(&"missing_hitbox")

	assert_bool(collision.is_hitbox_active(&"slash_1")).is_false()
	assert_int(collision.get_active_hitbox_count()).is_equal(0)


func test_activate_hitbox_clamps_invalid_duration_and_size_to_safe_minimums() -> void:
	collision.activate_hitbox(&"bad_box", -4, Vector2.ZERO, Vector2.ZERO, {})
	var hitbox = collision.get_hitbox(&"bad_box")

	assert_bool(hitbox.is_active()).is_true()
	assert_int(hitbox.get_remaining_frames()).is_equal(1)
	assert_float(hitbox.get_hitbox_size().x).is_equal(4.0)
	assert_float(hitbox.get_hitbox_size().y).is_equal(4.0)
