## Story 006: AI low-HP adaptation and weighted attack selection.
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


class FakeHealthAdapter:
	extends RefCounted

	var hp_percentage: float = 1.0
	var query_count: int = 0

	func get_hp_percentage() -> float:
		query_count += 1
		return hp_percentage


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
var health


func before_test() -> void:
	AI_COMPONENT_SCRIPT.reset_active_enemy_count()
	ai = AI_COMPONENT_SCRIPT.new()
	health = FakeHealthAdapter.new()
	add_child(ai)
	ai.set_health_adapter(health)
	_load_weighted_patterns()


func after_test() -> void:
	if is_instance_valid(ai):
		if ai.get_parent() != null:
			ai.get_parent().remove_child(ai)
		ai.free()
	ai = null
	health = null
	AI_COMPONENT_SCRIPT.reset_active_enemy_count()


func test_low_hp_queries_health_and_enters_flee_from_chase_when_enabled() -> void:
	health.hp_percentage = 0.19
	ai.configure_low_hp_behavior(true, true)
	ai.change_state(AI_COMPONENT_SCRIPT.AIState.CHASE)

	ai.evaluate_low_hp_behavior()

	assert_int(health.query_count).is_equal(1)
	assert_int(ai.get_current_state()).is_equal(AI_COMPONENT_SCRIPT.AIState.FLEE)


func test_flee_disabled_keeps_combat_state_but_still_queries_health() -> void:
	health.hp_percentage = 0.19
	ai.configure_low_hp_behavior(false, true)
	ai.change_state(AI_COMPONENT_SCRIPT.AIState.CHASE)

	ai.evaluate_low_hp_behavior()

	assert_int(health.query_count).is_equal(1)
	assert_int(ai.get_current_state()).is_equal(AI_COMPONENT_SCRIPT.AIState.CHASE)


func test_berserk_speed_modifier_applies_to_future_pattern_timing() -> void:
	var collision_adapter := FakeCollisionAdapter.new()
	health.hp_percentage = 0.29
	ai.set_collision_adapter(collision_adapter)
	ai.evaluate_low_hp_behavior()

	assert_bool(ai.start_attack(0)).is_true()
	ai.advance_attack_frames(10)

	assert_float(ai.get_berserk_attack_speed_modifier()).is_equal_approx(1.2, 0.001)
	assert_int(collision_adapter.activations.size()).is_equal(1)
	var metadata: Dictionary = collision_adapter.activations[0]["metadata"]
	assert_int(metadata["startup_frames"]).is_equal(10)
	assert_int(metadata["active_frames"]).is_equal(5)
	assert_int(metadata["recovery_frames"]).is_equal(15)


func test_attack_weight_computation_clamps_base_phase_hp_product() -> void:
	var weights: Array = ai.get_attack_selection_weights()

	assert_int(weights.size()).is_equal(4)
	assert_float(_weight_for(weights, "quick")).is_equal_approx(1.0, 0.001)
	assert_float(_weight_for(weights, "heavy")).is_equal_approx(9.0, 0.001)
	assert_float(_weight_for(weights, "tiny")).is_equal_approx(0.05, 0.001)
	assert_float(_weight_for(weights, "huge")).is_equal_approx(40.0, 0.001)


func test_weighted_selection_uses_injected_roll_value() -> void:
	var first_selection: Dictionary = ai.select_attack_pattern(0.01)
	var second_selection: Dictionary = ai.select_attack_pattern(0.1)

	assert_str(String(first_selection["pattern_id"])).is_equal("quick")
	assert_str(String(second_selection["pattern_id"])).is_equal("heavy")


func _load_weighted_patterns() -> void:
	var adapter := FakeEnemyStatsAdapter.new({
		"weighted_enemy": {
			"attack_patterns": [
				_make_pattern("quick", 12, 6, 18, 1.0, 1.0, 1.0),
				_make_pattern("heavy", 18, 8, 24, 3.0, 2.0, 1.5),
				_make_pattern("tiny", 12, 4, 18, -4.0, 0.1, 0.1),
				_make_pattern("huge", 12, 4, 18, 999.0, 2.0, 2.0),
			],
		},
	})
	assert_bool(ai.load_attack_patterns(&"weighted_enemy", adapter)).is_true()


func _make_pattern(
	pattern_id: String,
	startup_frames: int,
	active_frames: int,
	recovery_frames: int,
	base_weight: float,
	phase_modifier: float,
	hp_modifier: float
) -> Dictionary:
	return {
		"pattern_id": pattern_id,
		"startup_frames": startup_frames,
		"active_frames": active_frames,
		"recovery_frames": recovery_frames,
		"damage_type": "physical",
		"phase_modifier": phase_modifier,
		"hp_modifier": hp_modifier,
		"hitbox_config": {
			"hitbox_id": pattern_id,
			"offset": {"x": 18, "y": -14},
			"size": {"x": 30, "y": 18},
		},
		"vulnerability_window": {"start_frame": 1, "size_frames": 2},
		"base_weight": base_weight,
	}


func _weight_for(weights: Array, pattern_id: String) -> float:
	for entry: Dictionary in weights:
		if String(entry["pattern_id"]) == pattern_id:
			return float(entry["weight"])
	return -1.0
