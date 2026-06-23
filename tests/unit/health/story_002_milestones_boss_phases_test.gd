## Story 002: HealthComponent HP milestones and boss phase gates.
extends GdUnitTestSuite

const HEALTH_COMPONENT_SCRIPT: Script = preload("res://src/core/health_component.gd")

var health
var _hp_events: Array[Dictionary] = []
var _milestone_events: Array[Dictionary] = []
var _phase_events: Array[Dictionary] = []
var _death_events: Array[Dictionary] = []
var _signal_order: Array[StringName] = []


func before_test() -> void:
	health = HEALTH_COMPONENT_SCRIPT.new()
	add_child(health)
	_hp_events.clear()
	_milestone_events.clear()
	_phase_events.clear()
	_death_events.clear()
	_signal_order.clear()
	health.on_hp_changed.connect(_on_hp_changed)
	health.on_hp_milestone.connect(_on_hp_milestone)
	health.on_boss_phase_change.connect(_on_boss_phase_change)
	health.on_death.connect(_on_death)


func after_test() -> void:
	if is_instance_valid(health):
		if health.get_parent() != null:
			health.get_parent().remove_child(health)
		health.free()
	health = null
	_hp_events.clear()
	_milestone_events.clear()
	_phase_events.clear()
	_death_events.clear()
	_signal_order.clear()


func test_hp_milestones_emit_once_when_thresholds_are_first_crossed() -> void:
	health.configure(42, 100, 100, 0, 0)

	health.apply_damage(25, {"source": &"light_hit"})
	health.apply_damage(25, {"source": &"medium_hit"})
	health.apply_damage(25, {"source": &"heavy_hit"})
	health.apply_damage(24, {"source": &"near_death_hit"})

	assert_array(_milestone_thresholds()).is_equal([0.75, 0.5, 0.25, 0.01])


func test_repeated_crossing_of_triggered_milestone_does_not_emit_duplicate() -> void:
	health.configure(42, 100, 100, 0, 0)

	health.apply_damage(30, {"source": &"first_cross"})
	health.apply_damage(5, {"source": &"still_below_75"})

	assert_array(_milestone_thresholds()).is_equal([0.75])


func test_boss_phase_cross_jump_emits_all_phase_changes_in_order() -> void:
	health.configure(9001, 300, 210, 0, 0)
	health.configure_boss_phases([0.66, 0.33])

	health.apply_damage(150, {"source": &"cross_jump"})

	assert_array(_phase_numbers()).is_equal([1, 2])
	assert_array(_phase_hp_percentages()).is_equal([0.2, 0.2])


func test_lethal_boss_hit_emits_hp_milestone_phase_then_death_order() -> void:
	health.configure(9001, 300, 100, 0, 0)
	health.configure_boss_phases([0.66, 0.33])

	health.apply_damage(100, {"source": &"lethal"})

	assert_array(_phase_numbers()).is_equal([1, 2])
	assert_array(_signal_order).is_equal([
		&"hp_changed",
		&"hp_milestone",
		&"hp_milestone",
		&"boss_phase_change",
		&"boss_phase_change",
		&"death",
	])


func _milestone_thresholds() -> Array[float]:
	var thresholds: Array[float] = []
	for event: Dictionary in _milestone_events:
		thresholds.append(float(event.get("threshold", 0.0)))
	return thresholds


func _phase_numbers() -> Array[int]:
	var phases: Array[int] = []
	for event: Dictionary in _phase_events:
		phases.append(int(event.get("phase", 0)))
	return phases


func _phase_hp_percentages() -> Array[float]:
	var percentages: Array[float] = []
	for event: Dictionary in _phase_events:
		percentages.append(float(event.get("hp_percentage", 0.0)))
	return percentages


func _on_hp_changed(entity_id: int, current_hp: int, max_hp: int) -> void:
	_signal_order.append(&"hp_changed")
	_hp_events.append({
		"entity_id": entity_id,
		"current_hp": current_hp,
		"max_hp": max_hp,
	})


func _on_hp_milestone(entity_id: int, threshold: float) -> void:
	_signal_order.append(&"hp_milestone")
	_milestone_events.append({
		"entity_id": entity_id,
		"threshold": threshold,
	})


func _on_boss_phase_change(entity_id: int, phase: int, hp_percentage: float) -> void:
	_signal_order.append(&"boss_phase_change")
	_phase_events.append({
		"entity_id": entity_id,
		"phase": phase,
		"hp_percentage": hp_percentage,
	})


func _on_death(entity_id: int, metadata: Dictionary) -> void:
	_signal_order.append(&"death")
	var event: Dictionary = metadata.duplicate(true)
	event["entity_id"] = entity_id
	_death_events.append(event)
