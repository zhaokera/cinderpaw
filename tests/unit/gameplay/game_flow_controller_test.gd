## GameFlowController runtime loop tests.
extends GdUnitTestSuite

const GAME_FLOW_SCRIPT: Script = preload("res://src/gameplay/game_flow_controller.gd")

var flow
var _respawn_events: Array[Dictionary] = []
var _victory_count: int = 0


class FakeBossArenaAdapter:
	extends RefCounted

	var captured_snapshot: Dictionary = {
		"boss_hp": 9,
		"phase": 2,
	}
	var capture_count: int = 0
	var reset_snapshots: Array[Dictionary] = []
	var summon_cleanup_count: int = 0
	var arena_lock_clear_count: int = 0
	var combat_adapter_clear_count: int = 0

	func capture_boss_arena_snapshot() -> Dictionary:
		capture_count += 1
		return captured_snapshot.duplicate(true)

	func reset_boss_arena_to_snapshot(snapshot: Dictionary) -> void:
		reset_snapshots.append(snapshot.duplicate(true))

	func cleanup_temporary_summons() -> void:
		summon_cleanup_count += 1

	func clear_arena_locks() -> void:
		arena_lock_clear_count += 1

	func clear_combat_adapters() -> void:
		combat_adapter_clear_count += 1


func before_test() -> void:
	flow = GAME_FLOW_SCRIPT.new()
	add_child(flow)
	_respawn_events.clear()
	_victory_count = 0
	flow.respawn_requested.connect(_on_respawn_requested)
	flow.victory_reached.connect(_on_victory_reached)


func after_test() -> void:
	if is_instance_valid(flow):
		if flow.get_parent() != null:
			flow.get_parent().remove_child(flow)
		flow.free()
	flow = null
	_respawn_events.clear()
	_victory_count = 0


func test_enemy_defeat_holds_then_enters_victory_once() -> void:
	flow.start_encounter(Vector2(300, 456))

	flow.handle_enemy_defeated()
	flow.handle_enemy_defeated()

	assert_str(String(flow.get_flow_state())).is_equal("victory_pending")
	assert_float(flow.get_victory_presentation_remaining_sec()).is_equal_approx(3.0, 0.001)
	assert_int(_victory_count).is_equal(0)
	assert_bool(flow.is_player_control_locked()).is_true()

	flow.advance_time(2.99)
	assert_str(String(flow.get_flow_state())).is_equal("victory_pending")
	assert_int(_victory_count).is_equal(0)

	flow.advance_time(0.02)
	flow.handle_enemy_defeated()
	assert_str(String(flow.get_flow_state())).is_equal("victory")
	assert_int(_victory_count).is_equal(1)


func test_player_death_delays_respawn_until_animation_time() -> void:
	flow.start_encounter(Vector2(300, 456))

	flow.handle_player_death()
	flow.advance_time(1.49)

	assert_str(String(flow.get_flow_state())).is_equal("dying")
	assert_int(_respawn_events.size()).is_equal(0)
	assert_bool(flow.is_player_control_locked()).is_true()

	flow.advance_time(0.02)

	assert_str(String(flow.get_flow_state())).is_equal("revived")
	assert_int(_respawn_events.size()).is_equal(1)
	assert_vector(_respawn_events[0]["position"]).is_equal(Vector2(300, 456))
	assert_float(_respawn_events[0]["revive_hp_percentage"]).is_equal_approx(0.5, 0.001)


func test_revived_state_unlocks_after_invincibility_window() -> void:
	flow.start_encounter(Vector2(300, 456))
	flow.handle_player_death()
	flow.advance_time(1.51)

	assert_bool(flow.is_player_control_locked()).is_true()
	assert_float(flow.get_invincibility_remaining()).is_equal_approx(2.0, 0.001)

	flow.advance_time(2.01)

	assert_str(String(flow.get_flow_state())).is_equal("playing")
	assert_bool(flow.is_player_control_locked()).is_false()
	assert_float(flow.get_invincibility_remaining()).is_equal(0.0)


func test_boss_death_respawns_at_arena_entrance_and_resets_entry_snapshot() -> void:
	var boss_adapter := FakeBossArenaAdapter.new()
	flow.start_boss_encounter(Vector2(640, 384), boss_adapter)

	assert_int(boss_adapter.capture_count).is_equal(1)

	flow.handle_player_death()
	flow.advance_time(1.51)

	assert_int(_respawn_events.size()).is_equal(1)
	assert_vector(_respawn_events[0]["position"]).is_equal(Vector2(640, 384))
	assert_int(boss_adapter.reset_snapshots.size()).is_equal(1)
	assert_dict(boss_adapter.reset_snapshots[0]).is_equal({
		"boss_hp": 9,
		"phase": 2,
	})
	assert_int(boss_adapter.summon_cleanup_count).is_equal(1)
	assert_int(boss_adapter.arena_lock_clear_count).is_equal(1)
	assert_int(boss_adapter.combat_adapter_clear_count).is_equal(1)


func test_boss_victory_does_not_reset_arena_or_emit_second_reward_path() -> void:
	var boss_adapter := FakeBossArenaAdapter.new()
	flow.start_boss_encounter(Vector2(640, 384), boss_adapter)

	flow.handle_enemy_defeated()
	flow.handle_player_death()
	flow.advance_time(3.01)

	assert_str(String(flow.get_flow_state())).is_equal("victory")
	assert_int(_victory_count).is_equal(1)
	assert_int(_respawn_events.size()).is_equal(0)
	assert_int(boss_adapter.reset_snapshots.size()).is_equal(0)
	assert_int(boss_adapter.summon_cleanup_count).is_equal(0)
	assert_int(boss_adapter.arena_lock_clear_count).is_equal(0)
	assert_int(boss_adapter.combat_adapter_clear_count).is_equal(0)


func _on_respawn_requested(position: Vector2, revive_hp_percentage: float) -> void:
	_respawn_events.append({
		"position": position,
		"revive_hp_percentage": revive_hp_percentage,
	})


func _on_victory_reached() -> void:
	_victory_count += 1
