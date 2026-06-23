## Story 003: AI data-driven attack pattern loading.
extends GdUnitTestSuite

const AI_COMPONENT_SCRIPT: Script = preload("res://src/core/ai_component.gd")
const DATA_MANAGER_SCRIPT: Script = preload("res://src/foundation/data_manager.gd")
const SCHEMA_VALIDATOR_SCRIPT: Script = preload("res://src/foundation/schema_validator.gd")

const ENEMY_STATS_PATH: String = "res://data/combat/enemy_stats.json"
const ENEMY_STATS_SCHEMA_PATH: String = "res://data/schemas/enemy_stats.schema.json"


class FakeEnemyStatsAdapter:
	extends RefCounted

	var entries: Dictionary = {}

	func _init(initial_entries: Dictionary) -> void:
		entries = initial_entries

	func get_entry(domain: StringName, entry_id: StringName) -> Variant:
		if domain != &"enemy_stats":
			return null
		return entries.get(entry_id)


var ai
var data_manager


func before_test() -> void:
	AI_COMPONENT_SCRIPT.reset_active_enemy_count()
	ai = AI_COMPONENT_SCRIPT.new()
	data_manager = DATA_MANAGER_SCRIPT.new()
	add_child(ai)
	add_child(data_manager)


func after_test() -> void:
	for node in [ai, data_manager]:
		if is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()
	ai = null
	data_manager = null
	AI_COMPONENT_SCRIPT.reset_active_enemy_count()


func test_load_attack_patterns_from_data_adapter_preserves_required_fields() -> void:
	var adapter := _make_two_pattern_adapter()

	assert_bool(ai.load_attack_patterns(&"mechanical_rat", adapter)).is_true()
	var patterns: Array = ai.get_attack_patterns()
	var first_pattern: Dictionary = patterns[0]

	assert_bool(ai.has_attack_patterns()).is_true()
	assert_int(patterns.size()).is_equal(2)
	assert_str(String(first_pattern["pattern_id"])).is_equal("quick_bite")
	assert_int(first_pattern["startup_frames"]).is_equal(18)
	assert_int(first_pattern["active_frames"]).is_equal(4)
	assert_int(first_pattern["recovery_frames"]).is_equal(20)
	assert_str(String(first_pattern["damage_type"])).is_equal("physical")
	assert_float(first_pattern["base_weight"]).is_equal_approx(1.25, 0.001)
	assert_vector(first_pattern["hitbox_config"]["offset"]).is_equal(Vector2(18, -14))
	assert_vector(first_pattern["hitbox_config"]["size"]).is_equal(Vector2(30, 18))
	assert_int(first_pattern["vulnerability_window"]["start_frame"]).is_equal(12)
	assert_int(first_pattern["vulnerability_window"]["size_frames"]).is_equal(5)


func test_invalid_or_missing_pattern_fields_use_safe_defaults() -> void:
	var adapter := FakeEnemyStatsAdapter.new({
		"broken_enemy": {
			"attack_patterns": [
				{
					"pattern_id": "broken",
					"startup_frames": "fast",
					"hitbox_config": {},
				},
			],
		},
	})

	assert_bool(ai.load_attack_patterns(&"broken_enemy", adapter)).is_true()
	var pattern: Dictionary = ai.get_attack_patterns()[0]

	assert_int(pattern["startup_frames"]).is_equal(12)
	assert_int(pattern["active_frames"]).is_equal(4)
	assert_int(pattern["recovery_frames"]).is_equal(18)
	assert_float(pattern["base_weight"]).is_equal_approx(1.0, 0.001)
	assert_vector(pattern["hitbox_config"]["offset"]).is_equal(Vector2.ZERO)
	assert_vector(pattern["hitbox_config"]["size"]).is_equal(Vector2(16, 16))
	assert_int(pattern["vulnerability_window"]["size_frames"]).is_equal(4)


func test_empty_pattern_lists_leave_component_in_safe_no_attack_configuration() -> void:
	var adapter := FakeEnemyStatsAdapter.new({
		"passive_bot": {"attack_patterns": []},
	})

	assert_bool(ai.load_attack_patterns(&"passive_bot", adapter)).is_false()
	assert_bool(ai.has_attack_patterns()).is_false()
	assert_array(ai.get_attack_patterns()).is_empty()


func test_project_enemy_stats_data_loads_through_data_manager_and_schema() -> void:
	var data: Dictionary = _load_json(ENEMY_STATS_PATH)
	var schema: Dictionary = _load_json(ENEMY_STATS_SCHEMA_PATH)
	var result: Variant = SCHEMA_VALIDATOR_SCRIPT.validate("enemy_stats", data, schema)
	var entry: Variant = data_manager.get_entry(&"enemy_stats", &"mechanical_rat")

	assert_bool(result.is_valid).is_true()
	assert_bool(entry is Dictionary).is_true()
	assert_array(entry["attack_patterns"]).is_not_empty()
	assert_bool(ai.load_attack_patterns(&"mechanical_rat", data_manager)).is_true()
	assert_bool(ai.has_attack_patterns()).is_true()


func _load_json(path: String) -> Dictionary:
	assert_bool(FileAccess.file_exists(path)).override_failure_message("Missing JSON file: %s" % path).is_true()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	assert_bool(parsed is Dictionary).override_failure_message("Invalid JSON object: %s" % path).is_true()
	return parsed as Dictionary


func _make_two_pattern_adapter() -> FakeEnemyStatsAdapter:
	return FakeEnemyStatsAdapter.new({
		"mechanical_rat": {
			"attack_patterns": [
				_make_quick_bite_pattern(),
				_make_spark_lunge_pattern(),
			],
		},
	})


func _make_quick_bite_pattern() -> Dictionary:
	return {
		"pattern_id": "quick_bite",
		"startup_frames": 18,
		"active_frames": 4,
		"recovery_frames": 20,
		"damage_type": "physical",
		"hitbox_config": {
			"hitbox_id": "bite",
			"offset": {"x": 18, "y": -14},
			"size": {"x": 30, "y": 18},
		},
		"vulnerability_window": {"start_frame": 12, "size_frames": 5},
		"base_weight": 1.25,
	}


func _make_spark_lunge_pattern() -> Dictionary:
	return {
		"pattern_id": "spark_lunge",
		"startup_frames": 30,
		"active_frames": 6,
		"recovery_frames": 28,
		"damage_type": "electric",
		"hitbox_config": {
			"hitbox_id": "spark",
			"offset": {"x": 24, "y": -12},
			"size": {"x": 42, "y": 20},
		},
		"vulnerability_window": {"start_frame": 18, "size_frames": 6},
		"base_weight": 0.75,
	}
