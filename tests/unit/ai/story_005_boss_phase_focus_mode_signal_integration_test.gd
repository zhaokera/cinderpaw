## Story 005: AI boss phase and focus-mode signal integration.
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

	signal on_focus_mode_changed(entity_id: int, active: bool, metadata: Dictionary)
	signal on_boss_phase_change(entity_id: int, phase: int, hp_percentage: float)

	func emit_focus(entity_id: int, active: bool, windup_extension_frames: int = 6) -> void:
		on_focus_mode_changed.emit(entity_id, active, {
			"windup_extension_frames": windup_extension_frames,
		})

	func emit_boss_phase(entity_id: int, phase: int, hp_percentage: float = 0.5) -> void:
		on_boss_phase_change.emit(entity_id, phase, hp_percentage)


class FakeLegacyFocusAdapter:
	extends RefCounted

	signal on_focus_mode_changed(active: bool)

	func emit_focus(active: bool) -> void:
		on_focus_mode_changed.emit(active)


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
	ai.set_entity_id(9001)
	add_child(ai)
	_load_phase_patterns()


func after_test() -> void:
	if is_instance_valid(ai):
		if ai.get_parent() != null:
			ai.get_parent().remove_child(ai)
		ai.free()
	ai = null
	AI_COMPONENT_SCRIPT.reset_active_enemy_count()


func test_health_focus_signal_adds_windup_to_new_attacks_only() -> void:
	var health := FakeHealthAdapter.new()
	ai.set_health_adapter(health)
	health.emit_focus(9001, true, 6)

	assert_bool(ai.start_attack()).is_true()
	assert_int(ai.get_effective_attack_startup_frames()).is_equal(9)

	health.emit_focus(9001, false, 0)
	assert_int(ai.get_effective_attack_startup_frames()).is_equal(9)


func test_focus_signal_ignores_foreign_entity_metadata_form() -> void:
	var health := FakeHealthAdapter.new()
	ai.set_health_adapter(health)
	health.emit_focus(77, true, 12)

	assert_bool(ai.start_attack()).is_true()

	assert_int(ai.get_effective_attack_startup_frames()).is_equal(3)


func test_legacy_bool_only_focus_signal_uses_default_windup_extension() -> void:
	var legacy_focus := FakeLegacyFocusAdapter.new()
	ai.set_health_adapter(legacy_focus)
	legacy_focus.emit_focus(true)

	assert_bool(ai.start_attack()).is_true()
	assert_int(ai.get_effective_attack_startup_frames()).is_equal(9)


func test_boss_phase_signal_stores_current_phase_and_ignores_foreign_entity() -> void:
	var health := FakeHealthAdapter.new()
	ai.set_health_adapter(health)
	health.emit_boss_phase(77, 3, 0.25)
	health.emit_boss_phase(9001, 2, 0.5)

	assert_int(ai.get_current_boss_phase()).is_equal(2)


func test_boss_phase_switches_future_pattern_sets_when_available() -> void:
	var collision_adapter := FakeCollisionAdapter.new()
	var health := FakeHealthAdapter.new()
	ai.set_collision_adapter(collision_adapter)
	ai.set_health_adapter(health)
	health.emit_boss_phase(9001, 2, 0.5)

	assert_bool(ai.start_attack()).is_true()
	ai.advance_attack_frames(5)

	assert_int(collision_adapter.activations.size()).is_equal(1)
	var metadata: Dictionary = collision_adapter.activations[0]["metadata"]
	assert_str(String(metadata["pattern_id"])).is_equal("phase_two_spark")
	assert_int(metadata["startup_frames"]).is_equal(5)


func _load_phase_patterns() -> void:
	var adapter := FakeEnemyStatsAdapter.new({
		"phase_boss": {
			"attack_patterns": [_make_pattern("phase_one_bite", 3, "bite")],
			"phase_attack_patterns": {
				"2": [_make_pattern("phase_two_spark", 5, "spark")],
			},
		},
	})
	assert_bool(ai.load_attack_patterns(&"phase_boss", adapter)).is_true()


func _make_pattern(pattern_id: String, startup_frames: int, hitbox_id: String) -> Dictionary:
	return {
		"pattern_id": pattern_id,
		"startup_frames": startup_frames,
		"active_frames": 4,
		"recovery_frames": 5,
		"damage_type": "physical",
		"hitbox_config": {
			"hitbox_id": hitbox_id,
			"offset": {"x": 18, "y": -14},
			"size": {"x": 30, "y": 18},
		},
		"vulnerability_window": {"start_frame": 1, "size_frames": 2},
		"base_weight": 1.0,
	}
