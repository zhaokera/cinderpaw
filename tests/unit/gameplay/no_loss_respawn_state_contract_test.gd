## Story 006: Death respawn no-loss state contract.
extends GdUnitTestSuite

const GAME_FLOW_SCRIPT: Script = preload("res://src/gameplay/game_flow_controller.gd")

var flow
var _respawn_events: Array[Dictionary] = []


class FakeNoLossStateAdapter:
	extends RefCounted

	var state: Dictionary = {
		"currency": 42,
		"inventory": ["rust_key", "sun_lens"],
		"weapons": {
			"current_weapon": "long_tail",
			"acquired": ["cat_claw", "long_tail"],
			"levels": {"cat_claw": 2, "long_tail": 1},
		},
		"world_flags": {
			"gate_a_open": true,
			"rat_king_seen": true,
		},
	}
	var capture_count: int = 0
	var restore_count: int = 0
	var restored_snapshots: Array[Dictionary] = []

	func capture_no_loss_state() -> Dictionary:
		capture_count += 1
		return state.duplicate(true)

	func restore_no_loss_state(snapshot: Dictionary) -> void:
		restore_count += 1
		restored_snapshots.append(snapshot.duplicate(true))
		state = snapshot.duplicate(true)


func before_test() -> void:
	flow = GAME_FLOW_SCRIPT.new()
	add_child(flow)
	_respawn_events.clear()
	flow.respawn_requested.connect(_on_respawn_requested)


func after_test() -> void:
	if is_instance_valid(flow):
		if flow.get_parent() != null:
			flow.get_parent().remove_child(flow)
		flow.free()
	flow = null
	_respawn_events.clear()


func test_death_respawn_restores_currency_inventory_weapons_and_world_flags() -> void:
	var no_loss_adapter := FakeNoLossStateAdapter.new()
	var expected_state: Dictionary = no_loss_adapter.state.duplicate(true)
	flow.set_no_loss_state_adapter(no_loss_adapter)
	flow.start_encounter(Vector2(300, 456))

	flow.handle_player_death()
	no_loss_adapter.state = {
		"currency": 0,
		"inventory": [],
		"weapons": {
			"current_weapon": "cat_claw",
			"acquired": ["cat_claw"],
			"levels": {"cat_claw": 0},
		},
		"world_flags": {
			"gate_a_open": false,
			"rat_king_seen": false,
		},
	}
	flow.advance_time(1.51)

	assert_int(no_loss_adapter.capture_count).is_equal(1)
	assert_int(no_loss_adapter.restore_count).is_equal(1)
	assert_dict(no_loss_adapter.state).is_equal(expected_state)
	assert_dict(no_loss_adapter.restored_snapshots[0]).is_equal(expected_state)


func test_no_loss_contract_keeps_health_restore_owned_by_revive_percentage() -> void:
	var no_loss_adapter := FakeNoLossStateAdapter.new()
	flow.set_no_loss_state_adapter(no_loss_adapter)
	flow.start_encounter(Vector2(300, 456))

	flow.handle_player_death()
	flow.advance_time(1.51)

	assert_int(_respawn_events.size()).is_equal(1)
	assert_float(_respawn_events[0]["revive_hp_percentage"]).is_equal_approx(0.5, 0.001)


func _on_respawn_requested(position: Vector2, revive_hp_percentage: float) -> void:
	_respawn_events.append({
		"position": position,
		"revive_hp_percentage": revive_hp_percentage,
	})
