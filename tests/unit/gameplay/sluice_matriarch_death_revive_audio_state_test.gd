## Audio System Story011: Boss3 death and revive audio state completion.
extends GdUnitTestSuite

const ARENA_SCENE_PATH: String = "res://scenes/bosses/sluice_matriarch_arena.tscn"
const BOSS_ID: StringName = &"boss_03_sluice_matriarch"
const PLAYER_MAX_HP: int = 100
const DEATH_HOLD_SEC: float = 1.5

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system != null:
		if audio_system.has_method("on_boss_encounter_ended"):
			audio_system.call("on_boss_encounter_ended", BOSS_ID, {
				"reason": &"story011_test_cleanup",
			})
		_stop_runtime_audio_players(audio_system)
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_boss3_death_and_revive_complete_audio_state_once() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	assert_that(audio_system).is_not_null()
	if audio_system == null:
		return
	assert_bool(audio_system.has_method("on_player_death")).is_true()
	if not audio_system.has_method("on_player_death"):
		return
	assert_bool(audio_system.has_method("on_player_revived")).is_true()
	assert_bool(audio_system.has_method("get_death_audio_state")).is_true()
	if (
		not audio_system.has_method("on_player_revived")
		or not audio_system.has_method("get_death_audio_state")
	):
		return

	audio_system.call("on_boss_phase_transition_started", 2300, 2, {
		"boss_id": BOSS_ID,
		"world_position": Vector2(930.0, 540.0),
	})
	assert_str(String(audio_system.call("get_audio_state"))).is_equal("BOSS_FIGHT")
	var baseline_state: Dictionary = audio_system.call("get_death_audio_state")
	var baseline_death_count: int = int(baseline_state.get("death_request_count", 0))
	var baseline_revive_count: int = int(baseline_state.get("revive_request_count", 0))

	var arena: Node = _instantiate_arena()
	assert_that(arena).is_not_null()
	if arena == null:
		return
	var player := arena.get_node_or_null("Player") as CharacterBody2D
	var boss := arena.get_node_or_null("SluiceMatriarchBoss") as CharacterBody2D
	assert_that(player).is_not_null()
	assert_that(boss).is_not_null()
	if player == null or boss == null:
		return
	player.set_physics_process(false)
	boss.set_physics_process(false)
	player.global_position = Vector2(680.0, 540.0)
	player.call("apply_damage", PLAYER_MAX_HP, {
		"source": &"story011_player_death_audio",
	})

	var death_state: Dictionary = audio_system.call("get_death_audio_state")
	var death_event: Dictionary = audio_system.call("get_last_gameplay_audio_event")
	assert_str(String(audio_system.call("get_audio_state"))).is_equal("DEATH")
	assert_bool(bool(death_state.get("active", false))).is_true()
	assert_str(String(death_state.get("previous_audio_state", ""))).is_equal("BOSS_FIGHT")
	assert_int(int(death_state.get("death_request_count", 0))).is_equal(
		baseline_death_count + 1
	)
	assert_int(int(death_state.get("revive_request_count", 0))).is_equal(
		baseline_revive_count
	)
	assert_str(String(death_event.get("event_id", ""))).is_equal("player_death")
	assert_str(String(death_event.get("sfx_id", ""))).is_equal("sfx_player_death")
	assert_vector(death_event.get("position", Vector2.ZERO)).is_equal(player.global_position)
	assert_int(int(audio_system.call("get_active_sfx_count"))).is_equal(1)

	arena.call("advance_player_retry_flow", DEATH_HOLD_SEC + 0.01)
	var revive_state: Dictionary = audio_system.call("get_death_audio_state")
	var revive_event: Dictionary = audio_system.call("get_last_gameplay_audio_event")
	assert_str(String(audio_system.call("get_audio_state"))).is_equal("BOSS_FIGHT")
	assert_bool(bool(revive_state.get("active", true))).is_false()
	assert_int(int(revive_state.get("death_request_count", 0))).is_equal(
		baseline_death_count + 1
	)
	assert_int(int(revive_state.get("revive_request_count", 0))).is_equal(
		baseline_revive_count + 1
	)
	assert_str(String(revive_event.get("event_id", ""))).is_equal("player_revived")
	assert_str(String(revive_event.get("sfx_id", ""))).is_equal("sfx_player_revive")
	assert_str(String(
		Dictionary(revive_event.get("metadata", {})).get("boss_id", "")
	)).is_equal(String(BOSS_ID))


func _instantiate_arena() -> Node:
	assert_bool(FileAccess.file_exists(ARENA_SCENE_PATH)).is_true()
	var packed: PackedScene = load(ARENA_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var arena: Node = packed.instantiate()
	add_child(arena)
	_spawned_nodes.append(arena)
	return arena


func _stop_runtime_audio_players(audio_system: Node) -> void:
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var audio_player := child as AudioStreamPlayer
			audio_player.stop()
			audio_player.stream = null
		elif child is AudioStreamPlayer2D:
			var spatial_player := child as AudioStreamPlayer2D
			spatial_player.stop()
			spatial_player.stream = null
