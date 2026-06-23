## Story 004: Boss arena change adapter and scene lock hooks.
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


class FakeSceneAdapter:
	extends RefCounted

	var lock_calls: int = 0
	var unlock_calls: int = 0
	var arena_change_requests: Array = []

	func lock_scene() -> void:
		lock_calls += 1

	func unlock_scene() -> void:
		unlock_calls += 1

	func apply_arena_changes(boss_id: StringName, phase: int, changes: Array) -> void:
		arena_change_requests.append({
			"boss_id": boss_id,
			"phase": phase,
			"changes": changes.duplicate(true),
		})


class FakeHealthAdapter:
	extends Node

	signal on_death(entity_id: int, metadata: Dictionary)

	func emit_death(entity_id: int, metadata: Dictionary = {}) -> void:
		on_death.emit(entity_id, metadata)


var boss_config
var scene_adapter: FakeSceneAdapter
var health_adapter: FakeHealthAdapter


func before_test() -> void:
	boss_config = BOSS_CONFIG_COMPONENT_SCRIPT.new()
	scene_adapter = FakeSceneAdapter.new()
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
	scene_adapter = null


func test_boss_encounter_start_requests_scene_lock_once() -> void:
	boss_config.set_scene_adapter(scene_adapter)

	boss_config.start_boss_encounter()
	boss_config.start_boss_encounter()

	assert_int(scene_adapter.lock_calls).is_equal(1)
	assert_int(scene_adapter.unlock_calls).is_equal(0)


func test_phase_two_transition_applies_garbage_pile_arena_change() -> void:
	boss_config.set_scene_adapter(scene_adapter)

	_enter_phase(2)

	assert_int(scene_adapter.arena_change_requests.size()).is_equal(1)
	var request: Dictionary = scene_adapter.arena_change_requests[0]
	assert_str(String(request["boss_id"])).is_equal("boss_01_rat_king")
	assert_int(request["phase"]).is_equal(2)
	assert_array(request["changes"]).is_equal([
		{"type": "obstacle", "id": "garbage_pile"},
	])


func test_phase_three_transition_applies_obstacle_and_damage_zone_changes() -> void:
	boss_config.set_scene_adapter(scene_adapter)

	_enter_phase(2)
	_enter_phase(3)

	assert_int(scene_adapter.arena_change_requests.size()).is_equal(2)
	var request: Dictionary = scene_adapter.arena_change_requests[1]
	assert_str(String(request["boss_id"])).is_equal("boss_01_rat_king")
	assert_int(request["phase"]).is_equal(3)
	assert_array(request["changes"]).is_equal([
		{"type": "obstacle", "id": "overturned_trash_can"},
		{"type": "damage_zone", "id": "electric_leak"},
	])


func test_boss_death_unlocks_scene_locked_by_encounter_once() -> void:
	boss_config.set_entity_id(42)
	boss_config.set_scene_adapter(scene_adapter)
	boss_config.set_health_adapter(health_adapter)

	boss_config.start_boss_encounter()
	health_adapter.emit_death(7)
	health_adapter.emit_death(42)
	health_adapter.emit_death(42)

	assert_int(scene_adapter.lock_calls).is_equal(1)
	assert_int(scene_adapter.unlock_calls).is_equal(1)


func _enter_phase(phase_id: int) -> void:
	boss_config.queue_phase_transition(phase_id)
	boss_config.advance_transition(2.5)


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
