## Story 002: Boss phase transition adapter + invulnerability window.
extends GdUnitTestSuite

const BOSS_CONFIG_COMPONENT_SCRIPT: Script = preload("res://src/core/boss_config_component.gd")


class FakeBossConfigAdapter:
	extends RefCounted

	var entries: Dictionary = {}

	func _init(initial_entries: Dictionary) -> void:
		entries = initial_entries

	func get_entry(domain: StringName, entry_id: StringName) -> Variant:
		if domain != &"boss_configs":
			return null
		return entries.get(entry_id)


class FakeAIAdapter:
	extends RefCounted

	var attack_phase: StringName = &"none"
	var applied_phases: Array = []

	func get_attack_phase() -> StringName:
		return attack_phase

	func apply_boss_phase(
		phase_id: int,
		attack_patterns: Array,
		attack_speed_modifier: float
	) -> void:
		applied_phases.append({
			"phase_id": phase_id,
			"attack_patterns": attack_patterns.duplicate(true),
			"attack_speed_modifier": attack_speed_modifier,
		})


class FakeHealthAdapter:
	extends Node

	signal on_boss_phase_change(entity_id: int, phase: int, hp_percentage: float)

	func emit_phase(entity_id: int, phase: int, hp_percentage: float) -> void:
		on_boss_phase_change.emit(entity_id, phase, hp_percentage)


var boss_config
var ai_adapter: FakeAIAdapter
var health_adapter: FakeHealthAdapter


func before_test() -> void:
	boss_config = BOSS_CONFIG_COMPONENT_SCRIPT.new()
	ai_adapter = FakeAIAdapter.new()
	health_adapter = FakeHealthAdapter.new()
	add_child(boss_config)
	add_child(health_adapter)
	assert_bool(boss_config.load_boss_config(
		&"boss_01_rat_king",
		FakeBossConfigAdapter.new({"boss_01_rat_king": _make_rat_king_config()})
	)).is_true()


func after_test() -> void:
	for node in [boss_config, health_adapter]:
		if is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()
	boss_config = null
	health_adapter = null
	ai_adapter = null


func test_phase_change_waits_until_current_ai_attack_is_complete() -> void:
	boss_config.set_ai_adapter(ai_adapter)
	boss_config.set_health_adapter(health_adapter)
	ai_adapter.attack_phase = &"active"

	health_adapter.emit_phase(-1, 2, 0.65)
	boss_config.advance_transition(0.25)

	assert_int(boss_config.get_current_phase()).is_equal(1)
	assert_bool(boss_config.is_transition_pending()).is_true()
	assert_bool(boss_config.is_transition_active()).is_false()
	assert_array(ai_adapter.applied_phases).is_empty()

	ai_adapter.attack_phase = &"none"
	boss_config.advance_transition(0.0)

	assert_int(boss_config.get_current_phase()).is_equal(2)
	assert_bool(boss_config.is_transition_active()).is_true()
	assert_bool(boss_config.is_invulnerable()).is_true()
	assert_int(ai_adapter.applied_phases.size()).is_equal(1)


func test_transition_invulnerability_lasts_default_two_point_five_seconds() -> void:
	boss_config.set_ai_adapter(ai_adapter)
	boss_config.queue_phase_transition(2)

	boss_config.advance_transition(0.0)
	boss_config.advance_transition(2.49)

	assert_bool(boss_config.is_transition_active()).is_true()
	assert_bool(boss_config.is_invulnerable()).is_true()

	boss_config.advance_transition(0.01)

	assert_bool(boss_config.is_transition_active()).is_false()
	assert_bool(boss_config.is_invulnerable()).is_false()


func test_completed_transition_applies_phase_patterns_and_speed_to_ai_adapter() -> void:
	boss_config.set_ai_adapter(ai_adapter)
	boss_config.queue_phase_transition(2)

	boss_config.advance_transition(2.5)

	assert_int(ai_adapter.applied_phases.size()).is_equal(1)
	var applied: Dictionary = ai_adapter.applied_phases[0]
	assert_int(applied["phase_id"]).is_equal(2)
	assert_array(applied["attack_patterns"]).is_equal(["charge", "claw_swipe", "slam"])
	assert_float(applied["attack_speed_modifier"]).is_equal_approx(1.2, 0.001)
	assert_int(boss_config.get_current_phase()).is_equal(2)


func test_multiple_threshold_crossing_processes_phases_in_order() -> void:
	boss_config.set_ai_adapter(ai_adapter)

	boss_config.queue_phase_transition(2)
	boss_config.queue_phase_transition(3)
	boss_config.advance_transition(2.5)

	assert_int(boss_config.get_current_phase()).is_equal(2)
	assert_bool(boss_config.is_transition_pending()).is_true()
	assert_int(ai_adapter.applied_phases.size()).is_equal(1)
	assert_int(ai_adapter.applied_phases[0]["phase_id"]).is_equal(2)

	boss_config.advance_transition(0.0)
	boss_config.advance_transition(2.5)

	assert_int(boss_config.get_current_phase()).is_equal(3)
	assert_bool(boss_config.is_transition_pending()).is_false()
	assert_int(ai_adapter.applied_phases.size()).is_equal(2)
	assert_int(ai_adapter.applied_phases[1]["phase_id"]).is_equal(3)


func test_health_signal_filters_entity_id_when_configured() -> void:
	boss_config.set_entity_id(42)
	boss_config.set_ai_adapter(ai_adapter)
	boss_config.set_health_adapter(health_adapter)

	health_adapter.emit_phase(7, 2, 0.65)
	boss_config.advance_transition(2.5)

	assert_int(boss_config.get_current_phase()).is_equal(1)
	assert_array(ai_adapter.applied_phases).is_empty()

	health_adapter.emit_phase(42, 2, 0.65)
	boss_config.advance_transition(2.5)

	assert_int(boss_config.get_current_phase()).is_equal(2)
	assert_int(ai_adapter.applied_phases.size()).is_equal(1)


func _make_rat_king_config() -> Dictionary:
	return {
		"boss_id": "boss_01_rat_king",
		"display_name": "垃圾桶鼠王",
		"max_hp": 300,
		"phases": _make_rat_king_phases(),
		"summon_rules": {
			"phase_id": 2,
			"summon_id": "summon_minion",
			"summon_interval_sec": 15.0,
			"summon_max_count": 2,
		},
		"desperation_rules": {
			"phase_id": 3,
			"hp_threshold": 0.1,
			"defense_modifier": 0.7,
		},
		"parry_rules": {
			"damage_multiplier": 5.0,
			"enter_stun": false,
		},
		"defeat_rewards": {
			"ability_unlock": "dash",
			"currency": 50,
			"skill_points": 5,
		},
		"arena_bounds": {
			"position": {"x": 0, "y": 0},
			"size": {"x": 960, "y": 540},
		},
	}


func _make_rat_king_phases() -> Array:
	return [
		_make_phase_config(1, 1.0, ["charge", "claw_swipe"], 1.0, [], "phase_1_intro"),
		_make_phase_config(
			2,
			0.66,
			["charge", "claw_swipe", "slam"],
			1.2,
			["summon_minion", "slam"],
			"phase_2_rebuild",
			[{"type": "obstacle", "id": "garbage_pile"}]
		),
		_make_phase_config(
			3,
			0.33,
			["berserk_combo"],
			1.5,
			["berserk_combo"],
			"phase_3_overload",
			[
				{"type": "obstacle", "id": "overturned_trash_can"},
				{"type": "damage_zone", "id": "electric_leak"},
			]
		),
	]


func _make_phase_config(
	phase_id: int,
	hp_threshold: float,
	attack_patterns: Array,
	attack_speed_modifier: float,
	special_attacks: Array,
	transition_animation: String,
	arena_changes: Array = []
) -> Dictionary:
	return {
		"phase_id": phase_id,
		"hp_threshold": hp_threshold,
		"attack_patterns": attack_patterns,
		"attack_speed_modifier": attack_speed_modifier,
		"special_attacks": special_attacks,
		"transition_animation": transition_animation,
		"arena_changes": arena_changes,
	}
