## Story 003: HealthComponent i-frames, healing, save-point restore, and revive.
extends GdUnitTestSuite

const HEALTH_COMPONENT_SCRIPT: Script = preload("res://src/core/health_component.gd")

var health
var _hp_events: Array[Dictionary] = []
var _milestone_events: Array[Dictionary] = []
var _death_events: Array[Dictionary] = []


func before_test() -> void:
	health = HEALTH_COMPONENT_SCRIPT.new()
	add_child(health)
	_hp_events.clear()
	_milestone_events.clear()
	_death_events.clear()
	health.on_hp_changed.connect(_on_hp_changed)
	health.on_hp_milestone.connect(_on_hp_milestone)
	health.on_death.connect(_on_death)


func after_test() -> void:
	if is_instance_valid(health):
		if health.get_parent() != null:
			health.get_parent().remove_child(health)
		health.free()
	health = null
	_hp_events.clear()
	_milestone_events.clear()
	_death_events.clear()


func test_grant_iframes_uses_max_take_and_ticks_down_without_stacking() -> void:
	health.configure(42, 100, 100, 0, 0)

	health.grant_iframes(5)
	health.grant_iframes(30)
	health.grant_iframes(10)
	health._physics_process(0.0)

	assert_int(health.get_iframe_remaining()).is_equal(29)


func test_damage_during_iframes_is_ignored_without_hp_or_signals() -> void:
	health.configure(42, 100, 100, 0, 0)
	health.grant_iframes(8)

	health.apply_damage(40, {"source": &"dot_tick"})

	assert_int(health.get_current_hp()).is_equal(100)
	assert_int(_hp_events.size()).is_equal(0)
	assert_int(_milestone_events.size()).is_equal(0)
	assert_int(_death_events.size()).is_equal(0)


func test_heal_clamps_to_max_hp_and_emits_hp_changed() -> void:
	health.configure(42, 100, 80, 0, 0)

	health.heal(30)

	assert_int(health.get_current_hp()).is_equal(100)
	assert_int(_hp_events.size()).is_equal(1)
	assert_int(_hp_events[0].get("current_hp", -1)).is_equal(100)


func test_savepoint_restore_refills_hp_and_shield_to_max_values() -> void:
	health.configure(42, 100, 30, 5, 20)

	health.restore_at_savepoint()

	assert_int(health.get_current_hp()).is_equal(100)
	assert_int(health.get_shield()).is_equal(20)
	assert_int(_hp_events.size()).is_equal(1)
	assert_int(_hp_events[0].get("current_hp", -1)).is_equal(100)


func test_revive_restores_at_least_one_hp_and_returns_to_alive() -> void:
	health.configure(42, 1, 1, 0, 0)
	health.apply_damage(5, {"source": &"lethal"})

	health.revive(0.1)

	assert_int(health.get_current_hp()).is_equal(1)
	assert_bool(health.is_alive()).is_true()
	assert_bool(health.is_dead()).is_false()
	assert_str(String(health.get_entity_state())).is_equal("alive")


func test_revive_resets_milestones_for_next_lifecycle() -> void:
	health.configure(42, 100, 100, 0, 0)
	health.apply_damage(25, {"source": &"first_lifecycle"})
	health.apply_damage(75, {"source": &"lethal"})

	health.revive(1.0)
	_milestone_events.clear()
	health.apply_damage(25, {"source": &"second_lifecycle"})

	assert_array(_milestone_thresholds()).is_equal([0.75])


func _milestone_thresholds() -> Array[float]:
	var thresholds: Array[float] = []
	for event: Dictionary in _milestone_events:
		thresholds.append(float(event.get("threshold", 0.0)))
	return thresholds


func _on_hp_changed(entity_id: int, current_hp: int, max_hp: int) -> void:
	_hp_events.append({
		"entity_id": entity_id,
		"current_hp": current_hp,
		"max_hp": max_hp,
	})


func _on_hp_milestone(entity_id: int, threshold: float) -> void:
	_milestone_events.append({
		"entity_id": entity_id,
		"threshold": threshold,
	})


func _on_death(entity_id: int, metadata: Dictionary) -> void:
	var event: Dictionary = metadata.duplicate(true)
	event["entity_id"] = entity_id
	_death_events.append(event)
