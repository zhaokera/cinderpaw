## Story 007: Hit confirmation, focus bonus, and damage metadata.
extends GdUnitTestSuite

const COMBAT_COMPONENT_SCRIPT: Script = preload("res://src/core/combat_component.gd")

class FakeCollisionAdapter:
	extends Node

	signal on_hit_confirmed(event: Variant)

	func emit_hit(event: Variant) -> void:
		on_hit_confirmed.emit(event)


class FakeDamageResult:
	extends RefCounted

	var final_damage: int = 17
	var base_damage: int = 11
	var attack_damage: float = 22.0
	var reduction_factor: float = 0.75
	var damage_multiplier: float = 1.0
	var is_crit: bool = true
	var crit_type: StringName = &"perfect"
	var is_parry: bool = false
	var parry_type: StringName = &"none"
	var combo_stage: int = 1
	var damage_category: StringName = &"strong"


class FakeDamageCalculatorAdapter:
	extends RefCounted

	var calls: Array[Dictionary] = []

	func calculate_damage(
		attack_type: StringName,
		weapon_id: StringName,
		hit_frame: int,
		combo_index: int,
		parry_timing: int,
		attack_power: int,
		enemy_defense: int,
		skill_modifiers: Dictionary = {},
		injected_params: Dictionary = {},
		data_manager: Node = null
	) -> RefCounted:
		calls.append({
			"attack_type": attack_type,
			"weapon_id": weapon_id,
			"hit_frame": hit_frame,
			"combo_index": combo_index,
			"parry_timing": parry_timing,
			"attack_power": attack_power,
			"enemy_defense": enemy_defense,
			"skill_modifiers": skill_modifiers.duplicate(true),
			"injected_params": injected_params.duplicate(true),
			"data_manager": data_manager,
		})
		return FakeDamageResult.new()


class FakeHealthAdapter:
	extends RefCounted

	var calls: Array[Dictionary] = []

	func apply_damage(final_damage: int, metadata: Dictionary) -> void:
		calls.append({
			"final_damage": final_damage,
			"metadata": metadata.duplicate(true),
		})


var combat
var _collision_adapter: FakeCollisionAdapter
var _attack_events: Array[Dictionary] = []


func before_test() -> void:
	combat = COMBAT_COMPONENT_SCRIPT.new()
	add_child(combat)
	_attack_events.clear()
	combat.on_attack_hit.connect(_on_attack_hit)


func after_test() -> void:
	if is_instance_valid(_collision_adapter):
		if _collision_adapter.get_parent() != null:
			_collision_adapter.get_parent().remove_child(_collision_adapter)
		_collision_adapter.free()
	if is_instance_valid(combat):
		if combat.get_parent() != null:
			combat.get_parent().remove_child(combat)
		combat.free()
	combat = null
	_collision_adapter = null
	_attack_events.clear()


func test_collision_adapter_hit_builds_attack_metadata_and_grants_light_energy() -> void:
	_collision_adapter = FakeCollisionAdapter.new()
	add_child(_collision_adapter)
	combat.set_collision_adapter(_collision_adapter)
	combat.start_light_attack_stage(1)
	combat.advance_attack_frames(7)

	_collision_adapter.emit_hit({
		"target_id": 42,
		"hitbox_id": &"claw_stage_1",
		"hit_position": Vector2(10, 2),
		"attack_metadata": {"attack_type": &"light"},
	})

	assert_int(_attack_events.size()).is_equal(1)
	var metadata: Dictionary = _attack_events[0]
	assert_dict(metadata).contains_keys([
		"attack_type",
		"weapon_id",
		"hit_frame",
		"combo_index",
		"parry_timing",
		"crit_window_bonus",
	])
	assert_str(String(metadata["attack_type"])).is_equal("light")
	assert_str(String(metadata["weapon_id"])).is_equal("cat_claw")
	assert_int(metadata["hit_frame"]).is_equal(7)
	assert_int(metadata["combo_index"]).is_equal(1)
	assert_int(metadata["parry_timing"]).is_equal(-1)
	assert_int(metadata["crit_window_bonus"]).is_equal(0)
	assert_int(metadata["target_id"]).is_equal(42)
	assert_str(String(metadata["hitbox_id"])).is_equal("claw_stage_1")
	assert_float(metadata["hit_position"].x).is_equal(10.0)
	assert_float(metadata["hit_position"].y).is_equal(2.0)
	assert_int(combat.get_cat_energy()).is_equal(8)


func test_focus_mode_adds_one_crit_window_bonus_without_stacking() -> void:
	combat.handle_focus_mode_changed(true)
	combat.handle_focus_mode_changed(true)

	combat.on_hit_confirmed({
		"hit_frame": 3,
		"attack_metadata": {"attack_type": &"light"},
	})

	assert_int(_attack_events[0]["crit_window_bonus"]).is_equal(1)
	assert_int(_attack_events[0]["skill_modifiers"]["focus_crit_window_bonus_frames"]).is_equal(1)

	combat.handle_focus_mode_changed(false)
	combat.on_hit_confirmed({
		"hit_frame": 3,
		"attack_metadata": {"attack_type": &"light"},
	})

	assert_int(_attack_events[1]["crit_window_bonus"]).is_equal(0)
	assert_int(_attack_events[1]["skill_modifiers"]["focus_crit_window_bonus_frames"]).is_equal(0)


func test_missing_adapters_still_emit_hit_metadata_safely() -> void:
	combat.on_hit_confirmed({})

	assert_int(_attack_events.size()).is_equal(1)
	assert_str(String(_attack_events[0]["attack_type"])).is_equal("light")
	assert_str(String(_attack_events[0]["weapon_id"])).is_equal("cat_claw")
	assert_int(_attack_events[0]["final_damage"]).is_equal(0)


func test_damage_and_health_adapters_receive_confirmed_hit_payload() -> void:
	var damage_adapter = FakeDamageCalculatorAdapter.new()
	var health_adapter = FakeHealthAdapter.new()
	combat.set_damage_calculator_adapter(damage_adapter)
	combat.set_health_adapter(health_adapter)

	combat.on_hit_confirmed({
		"target_id": 7,
		"hit_frame": 4,
		"attack_power": 5,
		"enemy_defense": 2,
		"attack_metadata": {"attack_type": &"heavy", "weapon_id": &"fish_bone"},
		"injected_damage_params": {"entries": {}},
	})

	assert_int(damage_adapter.calls.size()).is_equal(1)
	assert_str(String(damage_adapter.calls[0]["attack_type"])).is_equal("heavy")
	assert_str(String(damage_adapter.calls[0]["weapon_id"])).is_equal("fish_bone")
	assert_int(damage_adapter.calls[0]["hit_frame"]).is_equal(4)
	assert_int(damage_adapter.calls[0]["attack_power"]).is_equal(5)
	assert_int(damage_adapter.calls[0]["enemy_defense"]).is_equal(2)
	assert_int(health_adapter.calls.size()).is_equal(1)
	assert_int(health_adapter.calls[0]["final_damage"]).is_equal(17)

	var metadata: Dictionary = health_adapter.calls[0]["metadata"]
	assert_int(metadata["final_damage"]).is_equal(17)
	assert_int(metadata["base_damage"]).is_equal(11)
	assert_str(String(metadata["damage_category"])).is_equal("strong")
	assert_int(metadata["target_id"]).is_equal(7)


func test_battle_stats_track_hit_damage_parry_dodge_and_cat_energy_snapshot() -> void:
	var damage_adapter = FakeDamageCalculatorAdapter.new()
	combat.set_damage_calculator_adapter(damage_adapter)

	combat.on_action_triggered(&"dodge", {})
	combat.advance_dodge_frames(COMBAT_COMPONENT_SCRIPT.DODGE_TOTAL_FRAMES)
	combat.advance_dodge_cooldown_time(COMBAT_COMPONENT_SCRIPT.DODGE_COOLDOWN_SEC)
	combat.on_action_triggered(&"parry", {})
	combat.advance_parry_frames(3)
	combat.resolve_parry_result()
	combat.on_hit_confirmed({
		"hit_frame": 3,
		"parry_timing": 3,
		"attack_metadata": {"attack_type": &"parry"},
	})

	var stats: Dictionary = combat.get_battle_stats()

	assert_int(stats["hits_landed"]).is_equal(1)
	assert_int(stats["total_damage_dealt"]).is_equal(17)
	assert_int(stats["parries"]).is_equal(1)
	assert_int(stats["dodges"]).is_equal(1)
	assert_int(stats["cat_energy"]).is_equal(35)


func _on_attack_hit(metadata: Dictionary) -> void:
	_attack_events.append(metadata.duplicate(true))
