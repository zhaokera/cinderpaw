## Story 007: Boss phase transition start signal contract.
extends GdUnitTestSuite

const BOSS_CONFIG_COMPONENT_SCRIPT: Script = preload("res://src/core/boss_config_component.gd")
const RAT_KING_ID: StringName = &"boss_01_rat_king"
const BOSS_ENTITY_ID: int = 42


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

	func emit_phase_threshold(entity_id: int, threshold_ordinal: int, hp_percentage: float) -> void:
		on_boss_phase_change.emit(entity_id, threshold_ordinal, hp_percentage)


var boss_config
var ai_adapter: FakeAIAdapter
var health_adapter: FakeHealthAdapter
var transition_events: Array[Dictionary] = []


func before_test() -> void:
	transition_events.clear()
	boss_config = BOSS_CONFIG_COMPONENT_SCRIPT.new()
	ai_adapter = FakeAIAdapter.new()
	health_adapter = FakeHealthAdapter.new()
	add_child(boss_config)
	add_child(health_adapter)
	boss_config.on_boss_phase_transition_started.connect(_record_transition_started)
	boss_config.set_entity_id(BOSS_ENTITY_ID)
	boss_config.set_ai_adapter(ai_adapter)
	boss_config.set_health_adapter(health_adapter)
	assert_bool(boss_config.load_boss_config(
		RAT_KING_ID,
		FakeBossConfigAdapter.new({RAT_KING_ID: _make_rat_king_config()})
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
	transition_events.clear()


func test_transition_started_signal_waits_for_ai_idle_and_emits_metadata_once() -> void:
	ai_adapter.attack_phase = &"active"

	health_adapter.emit_phase_threshold(BOSS_ENTITY_ID, 1, 0.65)
	boss_config.advance_transition(0.25)

	assert_array(transition_events).is_empty()
	assert_int(boss_config.get_current_phase()).is_equal(1)
	assert_bool(boss_config.is_transition_pending()).is_true()

	ai_adapter.attack_phase = &"none"
	boss_config.advance_transition(0.0)
	boss_config.advance_transition(0.0)

	assert_int(transition_events.size()).is_equal(1)
	var event: Dictionary = transition_events[0]
	assert_int(event["entity_id"]).is_equal(BOSS_ENTITY_ID)
	assert_int(event["phase"]).is_equal(2)
	assert_int(event["current_phase_when_emitted"]).is_equal(2)
	assert_bool(event["transition_active_when_emitted"]).is_true()
	assert_bool(event["invulnerable_when_emitted"]).is_true()
	assert_int(event["applied_phase_count_when_emitted"]).is_equal(0)
	assert_int(boss_config.get_current_phase()).is_equal(2)
	assert_int(ai_adapter.applied_phases.size()).is_equal(1)
	_assert_phase_two_metadata(event["metadata"])


func test_health_threshold_ordinals_preserve_actual_phase_start_order() -> void:
	health_adapter.emit_phase_threshold(BOSS_ENTITY_ID, 1, 0.2)
	health_adapter.emit_phase_threshold(BOSS_ENTITY_ID, 2, 0.2)

	boss_config.advance_transition(0.0)
	boss_config.advance_transition(2.5)
	boss_config.advance_transition(0.0)

	assert_array(_transition_event_phases()).is_equal([2, 3])
	assert_array(_applied_phase_ids()).is_equal([2, 3])


func test_transition_started_signal_filters_foreign_entity_health_events() -> void:
	health_adapter.emit_phase_threshold(7, 1, 0.65)
	boss_config.advance_transition(2.5)

	assert_array(transition_events).is_empty()
	assert_int(boss_config.get_current_phase()).is_equal(1)
	assert_array(ai_adapter.applied_phases).is_empty()


func _record_transition_started(entity_id: int, phase: int, metadata: Dictionary) -> void:
	transition_events.append({
		"entity_id": entity_id,
		"phase": phase,
		"metadata": metadata.duplicate(true),
		"current_phase_when_emitted": boss_config.get_current_phase(),
		"transition_active_when_emitted": boss_config.is_transition_active(),
		"invulnerable_when_emitted": boss_config.is_invulnerable(),
		"applied_phase_count_when_emitted": ai_adapter.applied_phases.size(),
	})


func _transition_event_phases() -> Array[int]:
	var phases: Array[int] = []
	for event: Dictionary in transition_events:
		phases.append(int(event["phase"]))
	return phases


func _applied_phase_ids() -> Array[int]:
	var phases: Array[int] = []
	for event: Dictionary in ai_adapter.applied_phases:
		phases.append(int(event["phase_id"]))
	return phases


func _assert_phase_two_metadata(metadata: Dictionary) -> void:
	assert_str(String(metadata.get("boss_id", &""))).is_equal(String(RAT_KING_ID))
	assert_str(String(metadata.get("display_name", ""))).is_equal("垃圾桶鼠王")
	assert_int(int(metadata.get("previous_phase", 0))).is_equal(1)
	assert_float(float(metadata.get("hp_threshold", 0.0))).is_equal_approx(0.66, 0.001)
	assert_float(float(metadata.get("hp_percentage", 0.0))).is_equal_approx(0.65, 0.001)
	assert_float(float(metadata.get("trigger_hp_percentage", 0.0))).is_equal_approx(0.65, 0.001)
	assert_float(float(metadata.get("current_hp_percentage", 0.0))).is_equal_approx(0.65, 0.001)
	assert_float(float(metadata.get("transition_duration_sec", 0.0))).is_equal_approx(2.5, 0.001)
	assert_str(String(metadata.get("transition_animation", ""))).is_equal("phase_2_rebuild")
	assert_array(metadata.get("attack_patterns", []) as Array).is_equal([
		"charge",
		"claw_swipe",
		"slam",
	])
	assert_float(float(metadata.get("attack_speed_modifier", 0.0))).is_equal_approx(1.2, 0.001)
	assert_array(metadata.get("special_attacks", []) as Array).is_equal([
		"summon_minion",
		"slam",
	])
	assert_int((metadata.get("arena_changes", []) as Array).size()).is_equal(1)
	assert_int(int(metadata.get("queued_phase_count_after_start", -1))).is_equal(0)


func _make_rat_king_config() -> Dictionary:
	return {
		"boss_id": String(RAT_KING_ID),
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
