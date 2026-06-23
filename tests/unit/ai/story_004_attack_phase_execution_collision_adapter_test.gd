## Story 004: AI attack phase execution and Collision adapter activation.
extends GdUnitTestSuite

const AI_COMPONENT_SCRIPT: Script = preload("res://src/core/ai_component.gd")


class FakeEnemyStatsAdapter:
	extends RefCounted

	var entries: Dictionary = {}

	func _init(initial_entries: Dictionary) -> void:
		entries = initial_entries

	func get_entry(domain: StringName, entry_id: StringName) -> Variant:
		if domain != &"enemy_stats":
			return null
		return entries.get(entry_id)


class FakeCollisionAdapter:
	extends RefCounted

	var activations: Array[Dictionary] = []

	func activate_hitbox(
		hitbox_id: StringName,
		active_frames: int,
		offset: Vector2,
		size: Vector2,
		metadata: Dictionary = {}
	) -> void:
		activations.append({
			"hitbox_id": hitbox_id,
			"active_frames": active_frames,
			"offset": offset,
			"size": size,
			"metadata": metadata.duplicate(true),
		})


var ai


func before_test() -> void:
	AI_COMPONENT_SCRIPT.reset_active_enemy_count()
	ai = AI_COMPONENT_SCRIPT.new()
	add_child(ai)
	_load_test_pattern()


func after_test() -> void:
	if is_instance_valid(ai):
		if ai.get_parent() != null:
			ai.get_parent().remove_child(ai)
		ai.free()
	ai = null
	AI_COMPONENT_SCRIPT.reset_active_enemy_count()


func test_start_attack_enters_attack_state_and_startup_frame_zero() -> void:
	assert_bool(ai.start_attack()).is_true()

	assert_int(ai.get_current_state()).is_equal(AI_COMPONENT_SCRIPT.AIState.ATTACK)
	assert_str(String(ai.get_attack_phase())).is_equal("startup")
	assert_int(ai.get_attack_frame()).is_equal(0)


func test_startup_boundary_activates_collision_hitbox_once_with_metadata() -> void:
	var collision_adapter := FakeCollisionAdapter.new()
	ai.set_collision_adapter(collision_adapter)

	assert_bool(ai.start_attack()).is_true()
	ai.advance_attack_frames(2)

	assert_array(collision_adapter.activations).is_empty()
	ai.advance_attack_frames(1)
	ai.advance_attack_frames(2)

	assert_int(collision_adapter.activations.size()).is_equal(1)
	var activation: Dictionary = collision_adapter.activations[0]
	assert_str(String(activation["hitbox_id"])).is_equal("bite")
	assert_int(activation["active_frames"]).is_equal(4)
	assert_vector(activation["offset"]).is_equal(Vector2(18, -14))
	assert_vector(activation["size"]).is_equal(Vector2(30, 18))
	assert_str(String(activation["metadata"]["pattern_id"])).is_equal("quick_bite")


func test_active_and_recovery_frames_return_to_idle_deterministically() -> void:
	var collision_adapter := FakeCollisionAdapter.new()
	ai.set_collision_adapter(collision_adapter)
	ai.start_attack()

	ai.advance_attack_frames(3)
	assert_str(String(ai.get_attack_phase())).is_equal("active")

	ai.advance_attack_frames(4)
	assert_str(String(ai.get_attack_phase())).is_equal("recovery")

	ai.advance_attack_frames(5)
	assert_int(ai.get_current_state()).is_equal(AI_COMPONENT_SCRIPT.AIState.IDLE)
	assert_str(String(ai.get_attack_phase())).is_equal("none")


func test_startup_interruption_enters_stun_and_prevents_late_activation() -> void:
	var collision_adapter := FakeCollisionAdapter.new()
	ai.set_collision_adapter(collision_adapter)
	ai.start_attack()

	ai.advance_attack_frames(2)
	ai.interrupt_attack_with_stun()
	ai.advance_attack_frames(5)

	assert_int(ai.get_current_state()).is_equal(AI_COMPONENT_SCRIPT.AIState.STUN)
	assert_str(String(ai.get_attack_phase())).is_equal("none")
	assert_array(collision_adapter.activations).is_empty()


func test_missing_collision_adapter_does_not_crash_attack_lifecycle() -> void:
	assert_bool(ai.start_attack()).is_true()

	ai.advance_attack_frames(12)

	assert_int(ai.get_current_state()).is_equal(AI_COMPONENT_SCRIPT.AIState.IDLE)
	assert_str(String(ai.get_attack_phase())).is_equal("none")


func _load_test_pattern() -> void:
	var adapter := FakeEnemyStatsAdapter.new({
		"mechanical_rat": {"attack_patterns": [_make_quick_bite_pattern()]},
	})
	assert_bool(ai.load_attack_patterns(&"mechanical_rat", adapter)).is_true()


func _make_quick_bite_pattern() -> Dictionary:
	return {
		"pattern_id": "quick_bite",
		"startup_frames": 3,
		"active_frames": 4,
		"recovery_frames": 5,
		"damage_type": "physical",
		"hitbox_config": {
			"hitbox_id": "bite",
			"offset": {"x": 18, "y": -14},
			"size": {"x": 30, "y": 18},
		},
		"vulnerability_window": {"start_frame": 1, "size_frames": 2},
		"base_weight": 1.0,
	}
