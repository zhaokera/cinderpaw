## Story 005: Boss desperation defense and defeat reward dispatch.
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


class FakeHealthAdapter:
	extends Node

	signal on_death(entity_id: int, metadata: Dictionary)

	var hp_percentage: float = 1.0

	func get_hp_percentage() -> float:
		return hp_percentage

	func emit_death(entity_id: int, metadata: Dictionary = {}) -> void:
		on_death.emit(entity_id, metadata)


class FakeRewardAdapter:
	extends RefCounted

	var ability_unlocks: Array = []
	var currency_grants: Array = []
	var skill_point_grants: Array = []

	func unlock_ability(ability_id: StringName) -> void:
		ability_unlocks.append(ability_id)

	func grant_currency(amount: int) -> void:
		currency_grants.append(amount)

	func grant_skill_points(amount: int) -> void:
		skill_point_grants.append(amount)


var boss_config
var health_adapter: FakeHealthAdapter
var reward_adapter: FakeRewardAdapter


func before_test() -> void:
	boss_config = BOSS_CONFIG_COMPONENT_SCRIPT.new()
	health_adapter = FakeHealthAdapter.new()
	reward_adapter = FakeRewardAdapter.new()
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
	reward_adapter = null


func test_phase_three_below_ten_percent_hp_uses_desperation_defense() -> void:
	boss_config.set_health_adapter(health_adapter)
	_enter_phase(2)
	_enter_phase(3)
	health_adapter.hp_percentage = 0.099

	assert_float(boss_config.get_defense_modifier()).is_equal_approx(0.7, 0.001)


func test_desperation_defense_boundary_and_non_phase_three_remain_normal() -> void:
	boss_config.set_health_adapter(health_adapter)
	health_adapter.hp_percentage = 0.099

	assert_float(boss_config.get_defense_modifier()).is_equal_approx(1.0, 0.001)

	_enter_phase(2)
	_enter_phase(3)
	health_adapter.hp_percentage = 0.1

	assert_float(boss_config.get_defense_modifier()).is_equal_approx(1.0, 0.001)


func test_boss_defeat_dispatches_configured_rewards_for_this_boss() -> void:
	boss_config.set_entity_id(42)
	boss_config.set_health_adapter(health_adapter)
	boss_config.set_reward_adapter(reward_adapter)

	health_adapter.emit_death(7)
	health_adapter.emit_death(42)

	assert_array(reward_adapter.ability_unlocks).is_equal([&"dash"])
	assert_array(reward_adapter.currency_grants).is_equal([50])
	assert_array(reward_adapter.skill_point_grants).is_equal([5])


func test_boss_defeat_reward_dispatch_is_idempotent() -> void:
	boss_config.set_entity_id(42)
	boss_config.set_health_adapter(health_adapter)
	boss_config.set_reward_adapter(reward_adapter)

	health_adapter.emit_death(42)
	health_adapter.emit_death(42)

	assert_array(reward_adapter.ability_unlocks).is_equal([&"dash"])
	assert_array(reward_adapter.currency_grants).is_equal([50])
	assert_array(reward_adapter.skill_point_grants).is_equal([5])


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
		_make_phase_config(
			3,
			0.33,
			["berserk_combo"],
			1.5,
			["berserk_combo"],
			"phase_3_overload"
		),
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
