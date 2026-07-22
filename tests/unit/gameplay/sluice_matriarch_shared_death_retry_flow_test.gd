## Player Abilities Story180: Boss3 shared death and retry flow.
extends GdUnitTestSuite

const ARENA_SCENE_PATH: String = "res://scenes/bosses/sluice_matriarch_arena.tscn"
const BOSS_ENTITY_ID: int = 2300
const BOSS_MAX_HP: int = 120
const PLAYER_MAX_HP: int = 100
const EXPECTED_REVIVE_HP: int = 50
const DEATH_HOLD_SEC: float = 1.5
const RESPAWN_INVINCIBILITY_SEC: float = 2.0

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_player_death_holds_then_retries_boss3_at_half_hp_with_iframes() -> void:
	var arena: Node = _instantiate_arena()
	assert_that(arena).is_not_null()
	if arena == null:
		return
	assert_bool(arena.has_method("get_player_retry_flow_diagnostics")).is_true()
	assert_bool(arena.has_method("advance_player_retry_flow")).is_true()
	if (
		not arena.has_method("get_player_retry_flow_diagnostics")
		or not arena.has_method("advance_player_retry_flow")
	):
		return

	var player := arena.get_node_or_null("Player") as CharacterBody2D
	var boss := arena.get_node_or_null("SluiceMatriarchBoss") as CharacterBody2D
	var entry_spawn := arena.get_node_or_null("BossEntrySpawn") as Marker2D
	assert_that(player).is_not_null()
	assert_that(boss).is_not_null()
	assert_that(entry_spawn).is_not_null()
	if player == null or boss == null or entry_spawn == null:
		return

	boss.set_physics_process(false)
	player.set_physics_process(false)
	player.global_position = Vector2(680.0, 540.0)
	assert_bool(bool(arena.call(
		"apply_damage",
		BOSS_ENTITY_ID,
		61,
		{"source": &"story180_retry_setup"}
	))).is_true()
	boss.call("advance_phase_transition", 2.5)
	assert_int(int(boss.call("get_current_phase"))).is_equal(2)
	assert_bool(bool(boss.call("request_attack_pattern", &"pressure_lunge"))).is_true()
	boss.call("advance_attack_frames", 19)
	var active_attack: Dictionary = boss.call("get_pressure_lunge_diagnostics")
	assert_str(String(active_attack.get("attack_phase", ""))).is_equal("active")
	assert_bool(bool(active_attack.get("hitbox_active", false))).is_true()
	assert_int(int(boss.call("get_current_hp"))).is_equal(BOSS_MAX_HP - 61)

	player.call("apply_damage", PLAYER_MAX_HP, {
		"source": &"story180_player_death",
	})

	var dying: Dictionary = arena.call("get_player_retry_flow_diagnostics")
	var death_position: Vector2 = player.global_position
	assert_str(String(dying.get("flow_state", ""))).is_equal("dying")
	assert_bool(bool(dying.get("retry_pending", false))).is_true()
	assert_int(int(dying.get("death_count", 0))).is_equal(1)
	assert_bool(bool(dying.get("player_control_locked", false))).is_true()
	assert_float(float(dying.get("death_hold_sec", 0.0))).is_equal(DEATH_HOLD_SEC)
	assert_float(float(dying.get("revive_hp_percentage", 0.0))).is_equal(0.5)
	assert_float(float(dying.get("respawn_invincibility_sec", 0.0))).is_equal(
		RESPAWN_INVINCIBILITY_SEC
	)
	assert_str(String(dying.get("player_animation", ""))).is_equal("death")
	assert_str(String(dying.get("presentation_phase", ""))).is_equal("death_fade_in")
	assert_bool(int(dying.get("death_wisp_count", 0)) > 0).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(0)
	assert_int(int(boss.call("get_current_hp"))).is_equal(BOSS_MAX_HP - 61)
	assert_int(int(boss.call("get_current_phase"))).is_equal(2)
	assert_bool(bool(
		boss.call("get_pressure_lunge_diagnostics").get("hitbox_active", false)
	)).is_true()

	arena.call("advance_player_retry_flow", DEATH_HOLD_SEC - 0.01)
	var still_dying: Dictionary = arena.call("get_player_retry_flow_diagnostics")
	assert_str(String(still_dying.get("flow_state", ""))).is_equal("dying")
	assert_vector(player.global_position).is_equal(death_position)
	assert_int(int(player.call("get_current_hp"))).is_equal(0)
	assert_int(int(boss.call("get_current_hp"))).is_equal(BOSS_MAX_HP - 61)
	assert_int(int(boss.call("get_current_phase"))).is_equal(2)

	arena.call("advance_player_retry_flow", 0.02)
	var revived: Dictionary = arena.call("get_player_retry_flow_diagnostics")
	assert_str(String(revived.get("flow_state", ""))).is_equal("revived")
	assert_bool(bool(revived.get("retry_pending", true))).is_false()
	assert_bool(bool(revived.get("player_control_locked", false))).is_true()
	assert_float(float(revived.get("invincibility_remaining_sec", 0.0))).is_equal(
		RESPAWN_INVINCIBILITY_SEC
	)
	assert_int(int(player.call("get_current_hp"))).is_equal(EXPECTED_REVIVE_HP)
	assert_float(player.global_position.distance_to(entry_spawn.global_position)).is_less(0.5)
	var respawn_point: Dictionary = revived.get("last_respawn_point", {}) as Dictionary
	assert_str(String(respawn_point.get("source", ""))).is_equal("boss_entrance")
	assert_str(String(respawn_point.get("scene_id", ""))).is_equal(
		"boss_03_sluice_matriarch_arena"
	)
	assert_str(String(respawn_point.get("spawn_point", ""))).is_equal("boss_entry")
	assert_int(int(player.call("get_respawn_visual_remaining_frames"))).is_equal(120)
	assert_str(String(revived.get("player_animation", ""))).is_equal("revive")
	assert_str(String(revived.get("presentation_phase", ""))).is_equal("revive_fade_out")
	assert_int(int(revived.get("revive_halo_count", 0))).is_equal(1)
	assert_int(int(boss.call("get_current_hp"))).is_equal(BOSS_MAX_HP)
	assert_int(int(boss.call("get_current_phase"))).is_equal(1)
	assert_float(boss.global_position.distance_to(Vector2(930.0, 540.0))).is_less(0.5)
	var reset_attack: Dictionary = boss.call("get_pressure_lunge_diagnostics")
	assert_str(String(reset_attack.get("attack_phase", ""))).is_equal("idle")
	assert_bool(bool(reset_attack.get("hitbox_active", true))).is_false()
	assert_bool(bool(revived.get("room_seals_enabled", false))).is_true()
	assert_bool(bool(revived.get("return_route_available", true))).is_false()
	assert_int(int(player.call("apply_damage", 10, {
		"source": &"story180_iframe_probe",
	}))).is_equal(0)
	assert_int(int(player.call("get_current_hp"))).is_equal(EXPECTED_REVIVE_HP)

	var player_health := player.get_node_or_null("HealthComponent") as HealthComponent
	assert_that(player_health).is_not_null()
	if player_health == null:
		return
	for _frame: int in range(119):
		player_health.call("_physics_process", 1.0 / 60.0)
	arena.call("advance_player_retry_flow", RESPAWN_INVINCIBILITY_SEC - 0.01)
	var still_revived: Dictionary = arena.call("get_player_retry_flow_diagnostics")
	assert_str(String(still_revived.get("flow_state", ""))).is_equal("revived")
	assert_bool(bool(still_revived.get("player_control_locked", false))).is_true()
	assert_int(player_health.get_iframe_remaining()).is_equal(1)
	assert_int(int(player.call("apply_damage", 10, {
		"source": &"story180_last_iframe_probe",
	}))).is_equal(0)
	player_health.call("_physics_process", 1.0 / 60.0)
	arena.call("advance_player_retry_flow", 0.02)
	var playing: Dictionary = arena.call("get_player_retry_flow_diagnostics")
	assert_str(String(playing.get("flow_state", ""))).is_equal("playing")
	assert_bool(bool(playing.get("player_control_locked", true))).is_false()
	assert_float(float(playing.get("invincibility_remaining_sec", -1.0))).is_equal(0.0)
	assert_int(player_health.get_iframe_remaining()).is_equal(0)
	assert_int(int(player.call("apply_damage", 10, {
		"source": &"story180_post_iframe_probe",
	}))).is_equal(10)
	assert_int(int(player.call("get_current_hp"))).is_equal(EXPECTED_REVIVE_HP - 10)


func _instantiate_arena() -> Node:
	assert_bool(FileAccess.file_exists(ARENA_SCENE_PATH)).is_true()
	var packed := load(ARENA_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var arena: Node = packed.instantiate()
	add_child(arena)
	_spawned_nodes.append(arena)
	return arena


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var audio_player := child as AudioStreamPlayer
			audio_player.stop()
			audio_player.stream = null
		if child is AudioStreamPlayer2D:
			var spatial_player := child as AudioStreamPlayer2D
			spatial_player.stop()
			spatial_player.stream = null
