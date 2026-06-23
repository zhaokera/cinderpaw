## Story 005: HealthComponent death metadata and zone hooks.
extends GdUnitTestSuite

const HEALTH_COMPONENT_SCRIPT: Script = preload("res://src/core/health_component.gd")

class FakeCombatComponent:
	extends Node

	var stats: Dictionary = {}

	func _init(initial_stats: Dictionary = {}) -> void:
		stats = initial_stats

	func get_battle_stats() -> Dictionary:
		return stats


var entity: Node
var health
var _death_events: Array[Dictionary] = []
var _zone_events: Array[Dictionary] = []


func before_test() -> void:
	entity = Node.new()
	add_child(entity)
	health = HEALTH_COMPONENT_SCRIPT.new()
	entity.add_child(health)
	_death_events.clear()
	_zone_events.clear()
	health.on_death.connect(_on_death)


func after_test() -> void:
	if is_instance_valid(entity):
		if entity.get_parent() != null:
			entity.get_parent().remove_child(entity)
		entity.free()
	entity = null
	health = null
	_death_events.clear()
	_zone_events.clear()


func test_death_metadata_contains_last_hit_battle_stats_and_context() -> void:
	_add_combat_component({
		"dodge_success_rate": 0.75,
		"parry_success_rate": 0.5,
		"hits_received_by_pattern": {"triple_slash": 2},
	})
	health.configure(42, 100, 10, 0, 0)
	health.set_current_zone_id(&"sewer_01")
	health.observe_damage_dealt(33)

	health.apply_damage(15, {
		"damage_category": &"strong",
		"source_entity": &"rat_skirmisher",
		"source_type": &"rat",
		"is_crit": true,
	})

	assert_int(_death_events.size()).is_equal(1)
	var metadata: Dictionary = _death_events[0].get("metadata", {})
	assert_dict(metadata).contains_keys(["last_hit", "battle_stats", "context"])
	var last_hit: Dictionary = metadata.get("last_hit", {})
	assert_int(last_hit.get("damage", -1)).is_equal(15)
	assert_str(String(last_hit.get("type", &""))).is_equal("strong")
	assert_str(String(last_hit.get("source", &""))).is_equal("rat_skirmisher")
	assert_bool(last_hit.get("is_crit", false)).is_true()
	var battle_stats: Dictionary = metadata.get("battle_stats", {})
	assert_bool(float(battle_stats.get("duration_sec", -1.0)) >= 0.0).is_true()
	assert_int(battle_stats.get("damage_received", -1)).is_equal(15)
	assert_int(battle_stats.get("damage_dealt", -1)).is_equal(33)
	assert_float(float(battle_stats.get("dodge_success_rate", -1.0))).is_equal(0.75)
	assert_float(float(battle_stats.get("parry_success_rate", -1.0))).is_equal(0.5)
	assert_int(Dictionary(battle_stats.get("hits_received_by_pattern", {})).get("triple_slash", 0)).is_equal(2)
	var context: Dictionary = metadata.get("context", {})
	assert_str(String(context.get("zone_id", &""))).is_equal("sewer_01")
	assert_str(String(context.get("enemy_type", &""))).is_equal("rat")
	assert_int(context.get("boss_phase", -99)).is_equal(-1)


func test_missing_combat_component_uses_safe_default_metadata() -> void:
	health.configure(42, 100, 5, 0, 0)

	health.apply_damage(10, {})

	var metadata: Dictionary = _death_events[0].get("metadata", {})
	var last_hit: Dictionary = metadata.get("last_hit", {})
	assert_int(last_hit.get("damage", -1)).is_equal(10)
	assert_str(String(last_hit.get("type", &""))).is_equal("normal")
	assert_str(String(last_hit.get("source", &"fallback"))).is_equal("")
	assert_bool(last_hit.get("is_crit", true)).is_false()
	var battle_stats: Dictionary = metadata.get("battle_stats", {})
	assert_int(battle_stats.get("damage_received", -1)).is_equal(10)
	assert_int(battle_stats.get("damage_dealt", -1)).is_equal(0)
	assert_float(float(battle_stats.get("dodge_success_rate", -1.0))).is_equal(0.0)
	assert_float(float(battle_stats.get("parry_success_rate", -1.0))).is_equal(0.0)
	assert_bool(Dictionary(battle_stats.get("hits_received_by_pattern", {"unsafe": 1})).is_empty()).is_true()
	var context: Dictionary = metadata.get("context", {})
	assert_str(String(context.get("zone_id", &"fallback"))).is_equal("")
	assert_str(String(context.get("enemy_type", &"fallback"))).is_equal("")
	assert_int(context.get("boss_phase", -99)).is_equal(-1)


func test_death_in_zone_signal_emits_when_zone_is_configured() -> void:
	health.configure(42, 100, 5, 0, 0)
	health.set_current_zone_id(&"sewer_01")
	if health.has_signal("on_death_in_zone"):
		health.connect("on_death_in_zone", Callable(self, "_on_death_in_zone"))

	health.apply_damage(10, {"source": &"zone_hit"})

	assert_array(_zone_events).is_equal([{
		"entity_id": 42,
		"zone_id": &"sewer_01",
	}])


func test_death_metadata_deep_copies_battle_stats_before_emission() -> void:
	var combat = _add_combat_component({
		"dodge_success_rate": 0.75,
		"parry_success_rate": 0.5,
		"hits_received_by_pattern": {"triple_slash": 2},
	})
	health.configure(42, 100, 5, 0, 0)
	health.on_death.connect(_mutate_death_metadata)

	health.apply_damage(10, {"source_entity": &"rat_skirmisher"})

	var original_patterns: Dictionary = combat.stats.get("hits_received_by_pattern", {})
	assert_int(original_patterns.get("triple_slash", 0)).is_equal(2)
	assert_float(float(combat.stats.get("dodge_success_rate", 0.0))).is_equal(0.75)


func _add_combat_component(stats: Dictionary) -> FakeCombatComponent:
	var combat := FakeCombatComponent.new(stats)
	combat.name = "CombatComponent"
	entity.add_child(combat)
	return combat


func _on_death(entity_id: int, metadata: Dictionary) -> void:
	_death_events.append({
		"entity_id": entity_id,
		"metadata": metadata.duplicate(true),
	})


func _on_death_in_zone(entity_id: int, zone_id: StringName) -> void:
	_zone_events.append({
		"entity_id": entity_id,
		"zone_id": zone_id,
	})


func _mutate_death_metadata(_entity_id: int, metadata: Dictionary) -> void:
	var battle_stats: Dictionary = metadata.get("battle_stats", {})
	battle_stats["dodge_success_rate"] = 0.0
	var patterns: Dictionary = battle_stats.get("hits_received_by_pattern", {})
	patterns["triple_slash"] = 999
