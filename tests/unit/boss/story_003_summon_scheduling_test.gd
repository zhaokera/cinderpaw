## Story 003: Boss phase two summon scheduling and death cleanup hooks.
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


class FakeSummonAdapter:
	extends RefCounted

	var active_count: int = 0
	var summon_requests: Array = []
	var cleanup_requests: Array = []

	func get_active_summon_count(_boss_id: StringName) -> int:
		return active_count

	func request_summon(boss_id: StringName, summon_id: StringName) -> void:
		summon_requests.append({"boss_id": boss_id, "summon_id": summon_id})

	func cleanup_summons(boss_id: StringName) -> void:
		cleanup_requests.append(boss_id)


class FakeHealthAdapter:
	extends Node

	signal on_boss_phase_change(entity_id: int, phase: int, hp_percentage: float)
	signal on_death(entity_id: int, metadata: Dictionary)

	func emit_phase(entity_id: int, phase: int, hp_percentage: float) -> void:
		on_boss_phase_change.emit(entity_id, phase, hp_percentage)

	func emit_death(entity_id: int, metadata: Dictionary = {}) -> void:
		on_death.emit(entity_id, metadata)


var boss_config
var summon_adapter: FakeSummonAdapter
var health_adapter: FakeHealthAdapter


func before_test() -> void:
	boss_config = BOSS_CONFIG_COMPONENT_SCRIPT.new()
	summon_adapter = FakeSummonAdapter.new()
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
	summon_adapter = null


func test_phase_two_summon_interval_requests_one_minion_below_cap() -> void:
	boss_config.set_summon_adapter(summon_adapter)
	_enter_phase(2)

	boss_config.advance_time(14.99)

	assert_array(summon_adapter.summon_requests).is_empty()

	boss_config.advance_time(0.01)

	assert_int(summon_adapter.summon_requests.size()).is_equal(1)
	var request: Dictionary = summon_adapter.summon_requests[0]
	assert_str(String(request["boss_id"])).is_equal("boss_01_rat_king")
	assert_str(String(request["summon_id"])).is_equal("summon_minion")


func test_phase_two_summon_cap_suppresses_additional_requests() -> void:
	summon_adapter.active_count = 2
	boss_config.set_summon_adapter(summon_adapter)
	_enter_phase(2)

	boss_config.advance_time(15.0)

	assert_array(summon_adapter.summon_requests).is_empty()


func test_leaving_phase_two_resets_summon_timer_state() -> void:
	boss_config.set_summon_adapter(summon_adapter)
	_enter_phase(2)
	boss_config.advance_time(7.5)

	assert_float(boss_config.get_summon_timer_sec()).is_equal_approx(7.5, 0.001)

	_enter_phase(3)

	assert_int(boss_config.get_current_phase()).is_equal(3)
	assert_float(boss_config.get_summon_timer_sec()).is_equal_approx(0.0, 0.001)

	boss_config.advance_time(15.0)

	assert_array(summon_adapter.summon_requests).is_empty()


func test_boss_death_requests_cleanup_for_this_boss_once() -> void:
	boss_config.set_entity_id(42)
	boss_config.set_summon_adapter(summon_adapter)
	boss_config.set_health_adapter(health_adapter)
	_enter_phase(2)
	boss_config.advance_time(15.0)

	health_adapter.emit_death(7)
	health_adapter.emit_death(42)
	health_adapter.emit_death(42)

	assert_array(summon_adapter.cleanup_requests).is_equal([&"boss_01_rat_king"])


func test_summon_rules_are_loaded_from_boss_config_data() -> void:
	var config: Dictionary = _make_rat_king_config()
	config["summon_rules"] = {
		"phase_id": 2,
		"summon_id": "custom_minion",
		"summon_interval_sec": 5.0,
		"summon_max_count": 1,
	}

	assert_bool(boss_config.load_boss_config(
		&"boss_01_rat_king",
		FakeBossConfigAdapter.new({"boss_01_rat_king": config})
	)).is_true()
	boss_config.set_summon_adapter(summon_adapter)
	_enter_phase(2)

	boss_config.advance_time(5.0)

	assert_int(summon_adapter.summon_requests.size()).is_equal(1)
	if summon_adapter.summon_requests.is_empty():
		return
	var request: Dictionary = summon_adapter.summon_requests[0]
	assert_str(String(request["summon_id"])).is_equal("custom_minion")

	summon_adapter.active_count = 1
	boss_config.advance_time(5.0)

	assert_int(summon_adapter.summon_requests.size()).is_equal(1)


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
			"phase_2_rebuild"
		),
		_make_phase_config(3, 0.33, ["berserk_combo"], 1.5, [], "phase_3_overload"),
	]


func _make_phase_config(
	phase_id: int,
	hp_threshold: float,
	attack_patterns: Array,
	attack_speed_modifier: float,
	special_attacks: Array,
	transition_animation: String
) -> Dictionary:
	return {
		"phase_id": phase_id,
		"hp_threshold": hp_threshold,
		"attack_patterns": attack_patterns,
		"attack_speed_modifier": attack_speed_modifier,
		"special_attacks": special_attacks,
		"transition_animation": transition_animation,
		"arena_changes": [],
	}
