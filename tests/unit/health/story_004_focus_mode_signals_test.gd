## Story 004: HealthComponent focus mode state and transition signals.
extends GdUnitTestSuite

const HEALTH_COMPONENT_SCRIPT: Script = preload("res://src/core/health_component.gd")

var health
var _focus_events: Array[Dictionary] = []
var _signal_order: Array[StringName] = []


func before_test() -> void:
	health = HEALTH_COMPONENT_SCRIPT.new()
	add_child(health)
	_focus_events.clear()
	_signal_order.clear()
	health.on_hp_changed.connect(_on_hp_changed)
	health.on_hp_milestone.connect(_on_hp_milestone)
	health.on_focus_mode_changed.connect(_on_focus_mode_changed)
	health.on_death.connect(_on_death)


func after_test() -> void:
	if is_instance_valid(health):
		if health.get_parent() != null:
			health.get_parent().remove_child(health)
		health.free()
	health = null
	_focus_events.clear()
	_signal_order.clear()


func test_focus_activates_at_25_percent_when_combat_is_active() -> void:
	_configure_player(30)
	health.set_active_enemy_count(1)

	health.apply_damage(5, {"source": &"combat_hit"})

	assert_bool(health.is_focus_mode_active()).is_true()
	assert_array(_focus_active_values()).is_equal([true])
	assert_int(_focus_metadata_int(0, "windup_extension_frames")).is_equal(6)
	assert_int(_focus_metadata_hp_percent(0)).is_equal(25)
	assert_str(_focus_metadata_string(0, "edge_flash_color")).is_equal("#ECC94B")


func test_focus_does_not_activate_at_low_hp_without_active_combat() -> void:
	_configure_player(30)

	health.apply_damage(5, {"source": &"safe_area_hit"})

	assert_bool(health.is_focus_mode_active()).is_false()
	assert_int(_focus_events.size()).is_equal(0)


func test_focus_hysteresis_holds_at_28_percent_and_exits_above_it() -> void:
	_configure_player(25)
	health.set_active_enemy_count(1)
	_focus_events.clear()

	health.heal(3)

	assert_bool(health.is_focus_mode_active()).is_true()
	assert_int(_focus_events.size()).is_equal(0)

	health.heal(1)

	assert_bool(health.is_focus_mode_active()).is_false()
	assert_array(_focus_active_values()).is_equal([false])


func test_focus_exits_when_active_enemy_count_reaches_zero() -> void:
	_configure_player(25)
	health.set_active_enemy_count(1)
	_focus_events.clear()

	health.set_active_enemy_count(0)

	assert_bool(health.is_focus_mode_active()).is_false()
	assert_array(_focus_active_values()).is_equal([false])
	assert_str(_focus_metadata_string(0, "transition_reason")).is_equal("combat_ended")


func test_focus_signal_emits_only_on_state_transitions() -> void:
	_configure_player(25)
	health.set_active_enemy_count(1)
	health.set_active_enemy_count(3)
	health.apply_damage(1, {"source": &"still_low"})
	health.heal(1)

	assert_bool(health.is_focus_mode_active()).is_true()
	assert_array(_focus_active_values()).is_equal([true])


func test_revive_resets_focus_mode_and_emits_false_transition() -> void:
	_configure_player(25)
	health.set_active_enemy_count(1)
	health.apply_damage(25, {"source": &"lethal"})
	_focus_events.clear()

	health.revive(0.5)

	assert_bool(health.is_focus_mode_active()).is_false()
	assert_array(_focus_active_values()).is_equal([false])
	assert_str(_focus_metadata_string(0, "transition_reason")).is_equal("revive")


func test_apply_damage_emits_focus_after_milestones_and_before_death() -> void:
	_configure_player(30)
	health.set_active_enemy_count(1)

	health.apply_damage(30, {"source": &"lethal_focus"})

	assert_array(_signal_order).is_equal([
		&"hp_changed",
		&"hp_milestone",
		&"hp_milestone",
		&"focus_mode_changed",
		&"death",
	])


func _configure_player(current_hp: int) -> void:
	health.configure(42, 100, current_hp, 0, 0, true)


func _focus_active_values() -> Array[bool]:
	var values: Array[bool] = []
	for event: Dictionary in _focus_events:
		values.append(bool(event.get("active", false)))
	return values


func _focus_metadata_int(index: int, key: String) -> int:
	var metadata: Dictionary = _focus_events[index].get("metadata", {})
	return int(metadata.get(key, -1))


func _focus_metadata_hp_percent(index: int) -> int:
	var metadata: Dictionary = _focus_events[index].get("metadata", {})
	return int(round(float(metadata.get("hp_percentage", -1.0)) * 100.0))


func _focus_metadata_string(index: int, key: String) -> String:
	var metadata: Dictionary = _focus_events[index].get("metadata", {})
	return String(metadata.get(key, ""))


func _on_hp_changed(entity_id: int, current_hp: int, max_hp: int) -> void:
	_signal_order.append(&"hp_changed")


func _on_hp_milestone(entity_id: int, threshold: float) -> void:
	_signal_order.append(&"hp_milestone")


func _on_focus_mode_changed(entity_id: int, active: bool, metadata: Dictionary) -> void:
	_signal_order.append(&"focus_mode_changed")
	_focus_events.append({
		"entity_id": entity_id,
		"active": active,
		"metadata": metadata.duplicate(true),
	})


func _on_death(entity_id: int, metadata: Dictionary) -> void:
	_signal_order.append(&"death")
