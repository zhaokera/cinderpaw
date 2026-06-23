## Story 006: Boss parry damage multiplier and STUN immunity.
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


var boss_config


func before_test() -> void:
	boss_config = BOSS_CONFIG_COMPONENT_SCRIPT.new()
	add_child(boss_config)
	assert_bool(boss_config.load_boss_config(
		&"boss_01_rat_king",
		FakeBossConfigAdapter.new({"boss_01_rat_king": _make_rat_king_config()})
	)).is_true()


func after_test() -> void:
	if is_instance_valid(boss_config):
		if boss_config.get_parent() != null:
			boss_config.get_parent().remove_child(boss_config)
		boss_config.free()
	boss_config = null


func test_successful_boss_parry_outcome_uses_five_times_damage() -> void:
	var outcome: Dictionary = boss_config.resolve_parry_outcome(&"perfect")

	assert_bool(outcome["is_success"]).is_true()
	assert_str(String(outcome["parry_type"])).is_equal("perfect")
	assert_float(float(outcome["damage_multiplier"])).is_equal_approx(5.0, 0.001)


func test_successful_boss_parry_outcome_suppresses_stun() -> void:
	var outcome: Dictionary = boss_config.resolve_parry_outcome(&"good")

	assert_bool(outcome["is_success"]).is_true()
	assert_float(float(outcome["damage_multiplier"])).is_equal_approx(5.0, 0.001)
	assert_bool(outcome["enter_stun"]).is_false()


func test_missed_or_none_parry_outcomes_are_neutral() -> void:
	for parry_type: StringName in [&"none", &"miss"]:
		var outcome: Dictionary = boss_config.resolve_parry_outcome(parry_type)

		assert_bool(outcome["is_success"]).is_false()
		assert_str(String(outcome["parry_type"])).is_equal(String(parry_type))
		assert_float(float(outcome["damage_multiplier"])).is_equal_approx(1.0, 0.001)
		assert_bool(outcome["enter_stun"]).is_false()


func test_parry_rules_are_loaded_from_boss_config_data() -> void:
	var config: Dictionary = _make_rat_king_config()
	config["parry_rules"] = {
		"damage_multiplier": 4.25,
		"enter_stun": false,
	}

	assert_bool(boss_config.load_boss_config(
		&"boss_01_rat_king",
		FakeBossConfigAdapter.new({"boss_01_rat_king": config})
	)).is_true()

	var outcome: Dictionary = boss_config.resolve_parry_outcome(&"late")

	assert_bool(outcome["is_success"]).is_true()
	assert_float(float(outcome["damage_multiplier"])).is_equal_approx(4.25, 0.001)
	assert_bool(outcome["enter_stun"]).is_false()


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
