## Story 002: AI perception cone and line-of-sight query.
extends GdUnitTestSuite

const AI_COMPONENT_SCRIPT: Script = preload("res://src/core/ai_component.gd")

var host: Node2D
var ai
var _line_of_sight_clear: bool = true
var _target_position: Vector2 = Vector2.ZERO
var _facing_direction: Vector2 = Vector2.RIGHT


func before_test() -> void:
	AI_COMPONENT_SCRIPT.reset_active_enemy_count()
	host = Node2D.new()
	ai = AI_COMPONENT_SCRIPT.new()
	add_child(host)
	host.add_child(ai)
	_line_of_sight_clear = true
	_target_position = Vector2(120, 0)
	_facing_direction = Vector2.RIGHT
	ai.set_line_of_sight_adapter(Callable(self, "_has_clear_line_of_sight"))
	ai.set_perception_providers(
		Callable(self, "_get_target_position"),
		Callable(self, "_get_facing_direction")
	)


func after_test() -> void:
	if is_instance_valid(host):
		if host.get_parent() != null:
			host.get_parent().remove_child(host)
		host.free()
	host = null
	ai = null
	AI_COMPONENT_SCRIPT.reset_active_enemy_count()


func test_detect_target_requires_radius_cone_and_clear_line_of_sight() -> void:
	ai.configure_perception(200.0, 120.0, 3.0)

	var visible_result: Dictionary = ai.detect_target(Vector2(120, 0), Vector2.RIGHT)
	assert_bool(visible_result["can_see"]).is_true()
	assert_float(visible_result["distance"]).is_equal_approx(120.0, 0.001)
	assert_vector(visible_result["direction"]).is_equal(Vector2.RIGHT)

	var outside_radius: Dictionary = ai.detect_target(Vector2(240, 0), Vector2.RIGHT)
	assert_bool(outside_radius["can_see"]).is_false()

	var outside_cone: Dictionary = ai.detect_target(Vector2(0, 120), Vector2.RIGHT)
	assert_bool(outside_cone["can_see"]).is_false()

	_line_of_sight_clear = false
	var blocked_result: Dictionary = ai.detect_target(Vector2(120, 0), Vector2.RIGHT)
	assert_bool(blocked_result["can_see"]).is_false()


func test_perception_radius_clamps_to_gdd_safe_range() -> void:
	ai.configure_perception(10.0, 120.0, 3.0)
	assert_float(ai.get_perception_radius()).is_equal_approx(100.0, 0.001)

	ai.configure_perception(900.0, 120.0, 3.0)
	assert_float(ai.get_perception_radius()).is_equal_approx(500.0, 0.001)


func test_perception_angle_clamps_to_gdd_safe_range() -> void:
	ai.configure_perception(200.0, 10.0, 3.0)
	assert_float(ai.get_perception_angle_degrees()).is_equal_approx(60.0, 0.001)

	ai.configure_perception(200.0, 300.0, 3.0)
	assert_float(ai.get_perception_angle_degrees()).is_equal_approx(180.0, 0.001)


func test_idle_transitions_to_chase_when_target_visible() -> void:
	ai.configure_perception(200.0, 120.0, 3.0)

	ai._physics_process(1.0 / 60.0)

	assert_int(ai.get_current_state()).is_equal(AI_COMPONENT_SCRIPT.AIState.CHASE)
	assert_int(AI_COMPONENT_SCRIPT.get_active_enemy_count()).is_equal(1)


func test_chase_transitions_to_patrol_after_target_lost_delay() -> void:
	ai.configure_perception(200.0, 120.0, 0.25)
	ai.change_state(AI_COMPONENT_SCRIPT.AIState.CHASE)
	_line_of_sight_clear = false

	ai._physics_process(0.1)
	assert_int(ai.get_current_state()).is_equal(AI_COMPONENT_SCRIPT.AIState.CHASE)

	ai._physics_process(0.15)

	assert_int(ai.get_current_state()).is_equal(AI_COMPONENT_SCRIPT.AIState.PATROL)
	assert_int(AI_COMPONENT_SCRIPT.get_active_enemy_count()).is_equal(0)


func _has_clear_line_of_sight(_origin_position: Vector2, _seen_target_position: Vector2) -> bool:
	return _line_of_sight_clear


func _get_target_position() -> Vector2:
	return _target_position


func _get_facing_direction() -> Vector2:
	return _facing_direction
