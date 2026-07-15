## Player Abilities Story155: real Crown Warden parry counter runtime.
extends GdUnitTestSuite

const ARENA_SCENE_PATH: String = "res://scenes/bosses/crown_warden_arena.tscn"
const BOSS_CONFIG_PATH: String = "res://data/combat/boss_configs.json"
const BOSS_ID: String = "boss_04_crown_warden"
const BOSS_MAX_HP: int = 160
const EXPECTED_COUNTER_DAMAGE: int = 50
const PLAYER_COMBAT_POSITION: Vector2 = Vector2(430.0, 552.0)
const BOSS_COMBAT_POSITION: Vector2 = Vector2(515.0, 540.0)

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


func test_crown_warden_config_matches_approved_boss_parry_rule() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(
		BOSS_CONFIG_PATH
	))
	assert_bool(parsed is Dictionary).is_true()
	if not parsed is Dictionary:
		return
	var entries: Dictionary = Dictionary(Dictionary(parsed).get("entries", {}))
	var config: Dictionary = Dictionary(entries.get(BOSS_ID, {}))
	var parry_rules: Dictionary = Dictionary(config.get("parry_rules", {}))

	assert_float(float(parry_rules.get("damage_multiplier", 0.0))).is_equal(5.0)
	assert_bool(bool(parry_rules.get("enter_stun", true))).is_false()


func test_real_talon_dive_perfect_parry_blocks_damage_and_counters_once() -> void:
	var arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(arena).is_not_null()
	if arena == null:
		return
	var boss: CharacterBody2D = arena.get_node_or_null(
		"CrownWardenBoss"
	) as CharacterBody2D
	var player: CharacterBody2D = arena.get_node_or_null("Player") as CharacterBody2D
	assert_that(boss).is_not_null()
	assert_that(player).is_not_null()
	if boss == null or player == null:
		return
	boss.call("set_autonomous_attacks_enabled", false)
	boss.call("reset_encounter")
	player.call("restore_at_savepoint")
	player.global_position = PLAYER_COMBAT_POSITION
	boss.global_position = BOSS_COMBAT_POSITION
	await get_tree().physics_frame
	await get_tree().physics_frame

	var player_hp_before: int = int(player.call("get_current_hp"))
	assert_bool(bool(boss.call("request_attack", &"talon_dive"))).is_true()
	var startup_frames: int = int(boss.call("get_current_attack_startup_frames"))
	for _frame: int in range(startup_frames - 1):
		await get_tree().physics_frame
	assert_str(String(boss.call("get_attack_phase"))).is_equal("startup")
	assert_bool(bool(player.call("request_parry"))).is_true()
	for _frame: int in range(3):
		await get_tree().physics_frame

	assert_int(int(player.call("get_current_hp"))).is_equal(player_hp_before)
	assert_int(int(boss.call("get_current_hp"))).is_equal(
		BOSS_MAX_HP - EXPECTED_COUNTER_DAMAGE
	)
	assert_bool(arena.has_method("get_boss4_parry_counter_diagnostics")).is_true()
	if not arena.has_method("get_boss4_parry_counter_diagnostics"):
		return
	var parry: Dictionary = arena.call("get_boss4_parry_counter_diagnostics")
	assert_str(String(parry.get("parry_type", ""))).is_equal("perfect")
	assert_float(float(parry.get("damage_multiplier", 0.0))).is_equal(5.0)
	assert_int(int(parry.get("counter_damage", 0))).is_equal(
		EXPECTED_COUNTER_DAMAGE
	)
	assert_bool(bool(parry.get("enter_stun", true))).is_false()
	assert_int(int(parry.get("counter_count", 0))).is_equal(1)
	assert_bool(bool(parry.get("boss_has_stun", true))).is_false()
	assert_bool(bool(parry.get("perfect_afterimage_active", false))).is_true()
	assert_that(arena.get_node_or_null("CombatPresentation")).is_not_null()

	await get_tree().physics_frame
	await get_tree().physics_frame
	assert_int(int(boss.call("get_current_hp"))).is_equal(
		BOSS_MAX_HP - EXPECTED_COUNTER_DAMAGE
	)
	assert_int(int(arena.call(
		"get_boss4_parry_counter_diagnostics"
	).get("counter_count", 0))).is_equal(1)


func _instantiate_scene(path: String) -> Node:
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		return null
	var instance: Node = packed.instantiate()
	add_child(instance)
	_spawned_nodes.append(instance)
	return instance


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	if audio_system.has_method("stop_music"):
		audio_system.call("stop_music", 0.0)
	if audio_system.has_method("stop_ambient"):
		audio_system.call("stop_ambient", 0.0)
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
		elif child is AudioStreamPlayer2D:
			(child as AudioStreamPlayer2D).stop()
