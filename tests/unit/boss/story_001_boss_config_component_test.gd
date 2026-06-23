## Story 001: BossConfigComponent + Rat King data domain.
extends GdUnitTestSuite

const BOSS_CONFIG_COMPONENT_PATH: String = "res://src/core/boss_config_component.gd"
const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")
const SCHEMA_VALIDATOR_SCRIPT: Script = preload("res://src/foundation/schema_validator.gd")

const BOSS_CONFIGS_PATH: String = "res://data/combat/boss_configs.json"
const BOSS_CONFIGS_SCHEMA_PATH: String = "res://data/schemas/boss_configs.schema.json"


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
var data_manager


func before_test() -> void:
	var script: Script = load(BOSS_CONFIG_COMPONENT_PATH)
	if script != null:
		boss_config = script.new()
		add_child(boss_config)
	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(data_manager)


func after_test() -> void:
	for node in [boss_config, data_manager]:
		if is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()
	boss_config = null
	data_manager = null


func test_load_boss_config_exposes_rat_king_required_values() -> void:
	if not _assert_component_exists():
		return
	var adapter := FakeBossConfigAdapter.new({
		"boss_01_rat_king": _make_rat_king_config(),
	})

	assert_bool(boss_config.load_boss_config(&"boss_01_rat_king", adapter)).is_true()

	assert_bool(boss_config.has_boss_config()).is_true()
	assert_str(String(boss_config.get_boss_id())).is_equal("boss_01_rat_king")
	assert_str(boss_config.get_display_name()).is_equal("垃圾桶鼠王")
	assert_int(boss_config.get_max_hp()).is_equal(300)
	assert_int(boss_config.get_phase_configs().size()).is_equal(3)
	assert_dict(boss_config.get_defeat_rewards()).contains_keys(
		["ability_unlock", "currency", "skill_points"]
	)
	assert_str(String(boss_config.get_defeat_rewards()["ability_unlock"])).is_equal("dash")
	assert_int(boss_config.get_defeat_rewards()["currency"]).is_equal(50)
	assert_int(boss_config.get_defeat_rewards()["skill_points"]).is_equal(5)


func test_phase_queries_expose_patterns_speed_modifiers_and_arena_bounds() -> void:
	if not _assert_component_exists():
		return
	var adapter := FakeBossConfigAdapter.new({
		"boss_01_rat_king": _make_rat_king_config(),
	})

	assert_bool(boss_config.load_boss_config(&"boss_01_rat_king", adapter)).is_true()

	assert_array(boss_config.get_phase_thresholds()).is_equal([0.66, 0.33])
	assert_array(boss_config.get_phase_attack_patterns(1)).is_equal(["charge", "claw_swipe"])
	assert_array(boss_config.get_phase_attack_patterns(2)).is_equal(["charge", "claw_swipe", "slam"])
	assert_float(boss_config.get_attack_speed_modifier(1)).is_equal_approx(1.0, 0.001)
	assert_float(boss_config.get_attack_speed_modifier(2)).is_equal_approx(1.2, 0.001)
	assert_float(boss_config.get_attack_speed_modifier(3)).is_equal_approx(1.5, 0.001)
	assert_dict(boss_config.get_phase_config(2)).contains_keys(
		["special_attacks", "transition_animation", "arena_changes"]
	)
	assert_array(boss_config.get_phase_config(2)["special_attacks"]).is_equal(
		["summon_minion", "slam"]
	)
	assert_that(boss_config.get_arena_bounds()).is_equal(Rect2(0, 0, 960, 540))


func test_missing_or_malformed_config_fails_safely() -> void:
	if not _assert_component_exists():
		return
	var adapter := FakeBossConfigAdapter.new({
		"broken_boss": {
			"boss_id": "broken_boss",
			"display_name": "Broken",
			"max_hp": "large",
			"phases": "not an array",
		},
	})

	assert_bool(boss_config.load_boss_config(&"missing_boss", adapter)).is_false()
	assert_bool(boss_config.has_boss_config()).is_false()

	assert_bool(boss_config.load_boss_config(&"broken_boss", adapter)).is_false()
	assert_int(boss_config.get_max_hp()).is_equal(0)
	assert_array(boss_config.get_phase_configs()).is_empty()
	assert_dict(boss_config.get_defeat_rewards()).is_empty()
	assert_that(boss_config.get_arena_bounds()).is_equal(Rect2())


func test_phase_data_normalizes_required_fields_and_defaults_optional_lists() -> void:
	if not _assert_component_exists():
		return
	var config: Dictionary = _make_rat_king_config()
	config["phases"] = [
		{
			"phase_id": 1,
			"hp_threshold": 0.66,
			"attack_patterns": ["charge"],
			"attack_speed_modifier": 1.0,
			"transition_animation": "phase_1_intro",
		},
	]
	var adapter := FakeBossConfigAdapter.new({"boss_01_rat_king": config})

	assert_bool(boss_config.load_boss_config(&"boss_01_rat_king", adapter)).is_true()
	var phase: Dictionary = boss_config.get_phase_config(1)

	assert_array(phase["special_attacks"]).is_empty()
	assert_array(phase["arena_changes"]).is_empty()
	assert_str(String(phase["transition_animation"])).is_equal("phase_1_intro")


func test_project_boss_config_data_loads_through_data_manager_and_schema() -> void:
	var data: Dictionary = _load_json(BOSS_CONFIGS_PATH)
	var schema: Dictionary = _load_json(BOSS_CONFIGS_SCHEMA_PATH)
	var result: Variant = SCHEMA_VALIDATOR_SCRIPT.validate("boss_configs", data, schema)
	var entry: Variant = data_manager.get_entry(&"boss_configs", &"boss_01_rat_king")

	assert_bool(result.is_valid).is_true()
	assert_bool(entry is Dictionary).is_true()
	assert_int(int((entry as Dictionary)["max_hp"])).is_equal(300)
	if not _assert_component_exists():
		return
	assert_bool(boss_config.load_boss_config(&"boss_01_rat_king", data_manager)).is_true()
	assert_array(boss_config.get_phase_thresholds()).is_equal([0.66, 0.33])


func _assert_component_exists() -> bool:
	assert_that(boss_config).override_failure_message(
		"BossConfigComponent script must exist at %s" % BOSS_CONFIG_COMPONENT_PATH
	).is_not_null()
	return boss_config != null


func _load_json(path: String) -> Dictionary:
	assert_bool(FileAccess.file_exists(path)).override_failure_message(
		"Missing JSON file: %s" % path
	).is_true()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	assert_bool(parsed is Dictionary).override_failure_message(
		"Invalid JSON object: %s" % path
	).is_true()
	return parsed as Dictionary


func _make_rat_king_config() -> Dictionary:
	return {
		"boss_id": "boss_01_rat_king",
		"display_name": "垃圾桶鼠王",
		"max_hp": 300,
		"phases": [
			{
				"phase_id": 1,
				"hp_threshold": 1.0,
				"attack_patterns": ["charge", "claw_swipe"],
				"attack_speed_modifier": 1.0,
				"special_attacks": [],
				"transition_animation": "phase_1_intro",
				"arena_changes": [],
			},
			{
				"phase_id": 2,
				"hp_threshold": 0.66,
				"attack_patterns": ["charge", "claw_swipe", "slam"],
				"attack_speed_modifier": 1.2,
				"special_attacks": ["summon_minion", "slam"],
				"transition_animation": "phase_2_rebuild",
				"arena_changes": [{"type": "obstacle", "id": "garbage_pile"}],
			},
			{
				"phase_id": 3,
				"hp_threshold": 0.33,
				"attack_patterns": ["berserk_combo"],
				"attack_speed_modifier": 1.5,
				"special_attacks": ["berserk_combo"],
				"transition_animation": "phase_3_overload",
				"arena_changes": [
					{"type": "obstacle", "id": "overturned_trash_can"},
					{"type": "damage_zone", "id": "electric_leak"},
				],
			},
		],
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
