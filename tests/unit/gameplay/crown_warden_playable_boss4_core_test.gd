## Player Abilities Story146: Crown Warden playable Boss4 core.
extends GdUnitTestSuite

const ARENA_SCENE_PATH: String = "res://scenes/bosses/crown_warden_arena.tscn"
const CHARACTER_SCENE_PATH: String = "res://scenes/characters/crown_warden.tscn"
const CHARACTER_SCRIPT_PATH: String = "res://src/characters/crown_warden.gd"
const BOSS_SCENE_PATH: String = "res://src/gameplay/crown_warden_boss.tscn"
const BOSS_SCRIPT_PATH: String = "res://src/gameplay/crown_warden_boss.gd"
const FRAMES_RESOURCE_PATH: String = (
	"res://assets/characters/crown_warden/crown_warden_sprite_frames.tres"
)
const SOURCE_PATH: String = (
	"res://assets/characters/crown_warden/source/"
	+ "crown_warden_sprite_sheet_imagegen_20260712.png"
)
const ALPHA_SOURCE_PATH: String = (
	"res://assets/characters/crown_warden/source/"
	+ "crown_warden_sprite_sheet_alpha_20260712.png"
)
const PREVIEW_PATH: String = (
	"res://assets/characters/crown_warden/source/"
	+ "crown_warden_frames_preview_20260712.png"
)
const GENERATION_RECORD_PATH: String = (
	"res://assets/characters/crown_warden/source/"
	+ "crown_warden_sprite_sheet_imagegen_20260712.md"
)
const ENEMY_STATS_PATH: String = "res://data/combat/enemy_stats.json"
const ENEMY_SCHEMA_PATH: String = "res://data/schemas/enemy_stats.schema.json"
const BOSS_CONFIG_PATH: String = "res://data/combat/boss_configs.json"
const BOSS_SCHEMA_PATH: String = "res://data/schemas/boss_configs.schema.json"
const BOSS_ID: StringName = &"boss_04_crown_warden"
const BOSS_ENTITY_ID: int = 2400
const BOSS_MAX_HP: int = 160
const DEFEATED_KEY: String = "boss_04_crown_warden_defeated"
const ANIMATIONS: Array[String] = [
	"idle",
	"run",
	"talon_dive_tell",
	"talon_dive",
	"wing_sweep_tell",
	"wing_sweep",
	"hurt",
	"death",
]

var _spawned_nodes: Array[Node] = []


class FakeBoss4SceneManager:
	extends RefCounted

	signal on_scene_load_failed(scene_id: StringName, reason: StringName)

	var locked: bool = false
	var lock_calls: int = 0
	var unlock_calls: int = 0
	var current_scene: StringName = &"boss_04_crown_warden_arena"
	var current_spawn: StringName = &"boss_entry"

	func request_scene_change(_scene_id: StringName, _spawn: StringName) -> bool:
		return not locked

	func has_scene(_scene_id: StringName) -> bool:
		return true

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn

	func is_loading() -> bool:
		return false

	func is_scene_locked() -> bool:
		return locked

	func lock_scene() -> void:
		locked = true
		lock_calls += 1

	func unlock_scene() -> void:
		locked = false
		unlock_calls += 1


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_data_character_frames_and_authored_scene_follow_boss4_contract() -> void:
	var missing: Array[String] = []
	var frame_anchor_bottoms: Array[int] = []
	for path: String in [
		CHARACTER_SCENE_PATH,
		CHARACTER_SCRIPT_PATH,
		BOSS_SCENE_PATH,
		BOSS_SCRIPT_PATH,
		FRAMES_RESOURCE_PATH,
		SOURCE_PATH,
		ALPHA_SOURCE_PATH,
		PREVIEW_PATH,
		GENERATION_RECORD_PATH,
	]:
		if not FileAccess.file_exists(path):
			missing.append(path)
	for animation_name: String in ANIMATIONS:
		for frame_index: int in range(3):
			var frame_path: String = (
				"res://assets/characters/crown_warden/%s/"
				+ "crown_warden_%s_%03d.png"
			) % [animation_name, animation_name, frame_index]
			if not FileAccess.file_exists(frame_path):
				missing.append(frame_path)
				continue
			var frame_image: Image = Image.load_from_file(
				ProjectSettings.globalize_path(frame_path)
			)
			if frame_image != null and not frame_image.is_empty():
				frame_anchor_bottoms.append(frame_image.get_used_rect().end.y)
	assert_array(missing).override_failure_message(
		"Story146 authored animation files are missing: %s" % ", ".join(missing)
	).is_empty()
	assert_int(frame_anchor_bottoms.max() - frame_anchor_bottoms.min()).override_failure_message(
		"Story146 runtime frame ground anchors must stay within two pixels: %s"
		% str(frame_anchor_bottoms)
	).is_less_equal(2)

	var enemy_stats: Dictionary = _read_json_dictionary(ENEMY_STATS_PATH)
	var enemy_entries: Dictionary = Dictionary(enemy_stats.get("entries", {}))
	assert_bool(enemy_entries.has(String(BOSS_ID))).is_true()
	var boss_stats: Dictionary = Dictionary(enemy_entries.get(String(BOSS_ID), {}))
	assert_int(int(boss_stats.get("max_hp", 0))).is_equal(BOSS_MAX_HP)
	var patterns: Array = Array(boss_stats.get("attack_patterns", []))
	assert_int(patterns.size()).is_equal(2)
	assert_array(_pattern_ids(patterns)).contains_exactly([
		"talon_dive", "wing_sweep",
	])
	assert_bool(Dictionary(_read_json_dictionary(ENEMY_SCHEMA_PATH).get(
		"entries", {}
	)).has(String(BOSS_ID))).is_true()
	var invalid_enemy_stats: Dictionary = enemy_stats.duplicate(true)
	var invalid_patterns: Array = Array(Dictionary(invalid_enemy_stats.get(
		"entries", {}
	)).get(String(BOSS_ID), {}).get("attack_patterns", []))
	Dictionary(invalid_patterns[0]).erase("damage")
	var invalid_enemy_result: ValidationResult = SchemaValidator.validate(
		"enemy_stats",
		invalid_enemy_stats,
		_read_json_dictionary(ENEMY_SCHEMA_PATH)
	)
	assert_bool(invalid_enemy_result.is_valid).is_false()
	assert_str(" ".join(invalid_enemy_result.errors)).contains(
		"attack_patterns[0].damage"
	)
	var boss_configs: Dictionary = _read_json_dictionary(BOSS_CONFIG_PATH)
	var config_entries: Dictionary = Dictionary(boss_configs.get("entries", {}))
	assert_bool(config_entries.has(String(BOSS_ID))).is_true()
	var config: Dictionary = Dictionary(config_entries.get(String(BOSS_ID), {}))
	assert_int(int(config.get("max_hp", 0))).is_equal(BOSS_MAX_HP)
	assert_int(Array(config.get("phases", [])).size()).is_equal(2)
	assert_str(String(Dictionary(config.get(
		"defeat_rewards", {}
	)).get("ability_unlock", ""))).is_equal("wall_climb")
	assert_bool(Dictionary(_read_json_dictionary(BOSS_SCHEMA_PATH).get(
		"entries", {}
	)).has(String(BOSS_ID))).is_true()
	if not missing.is_empty() or not FileAccess.file_exists(FRAMES_RESOURCE_PATH):
		return

	var frames: SpriteFrames = load(FRAMES_RESOURCE_PATH) as SpriteFrames
	assert_that(frames).is_not_null()
	if frames == null:
		return
	for animation_name: String in ANIMATIONS:
		assert_bool(frames.has_animation(StringName(animation_name))).is_true()
		assert_int(frames.get_frame_count(StringName(animation_name))).is_equal(3)
		for frame_index: int in range(3):
			var texture: Texture2D = frames.get_frame_texture(
				StringName(animation_name),
				frame_index
			)
			assert_that(texture).is_not_null()
			if texture != null:
				assert_vector(Vector2(texture.get_size())).is_equal(Vector2(192, 192))
	var character: Node = _instantiate_scene(CHARACTER_SCENE_PATH)
	assert_bool(character is AnimatedSprite2D).is_true()
	var arena_source: String = FileAccess.get_file_as_string(ARENA_SCENE_PATH)
	assert_bool(arena_source.contains("CrownWardenBoss")).is_true()


func test_arena_damage_uses_injected_boss_pattern_value() -> void:
	var arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(arena).is_not_null()
	if arena == null:
		return
	var result: Dictionary = arena.call(
		"calculate_damage",
		&"light",
		&"crown_warden_talon_dive",
		99,
		0,
		0,
		0,
		0,
		{},
		{
			"entries": {
				"crown_warden_talon_dive": {"weapon_base": 23},
			}
		},
		null
	)
	assert_int(int(result.get("final_damage", 0))).is_equal(23)


func test_two_data_driven_attacks_phase_two_and_shared_components_are_real() -> void:
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
	for method_name: StringName in [
		&"set_autonomous_attacks_enabled",
		&"request_attack",
		&"advance_attack_frames",
		&"get_attack_diagnostics",
		&"get_config_diagnostics",
	]:
		assert_bool(boss.has_method(method_name)).override_failure_message(
			"Story146 boss API missing: %s" % String(method_name)
		).is_true()
	if not boss.has_method("request_attack"):
		return
	boss.call("set_autonomous_attacks_enabled", false)
	assert_int(int(boss.call("get_entity_id"))).is_equal(BOSS_ENTITY_ID)
	assert_str(String(boss.call("get_current_boss_id"))).is_equal(String(BOSS_ID))
	assert_int(int(boss.call("get_max_hp"))).is_equal(BOSS_MAX_HP)
	for component_path: String in [
		"HealthComponent", "CollisionComponent", "CombatComponent", "StatusEffectComponent",
	]:
		assert_that(boss.get_node_or_null(component_path)).is_not_null()
	var config_diagnostics: Dictionary = boss.call("get_config_diagnostics")
	assert_bool(bool(config_diagnostics.get("loaded_from_data", false))).is_true()
	assert_array(Array(config_diagnostics.get("pattern_ids", []))).contains_exactly([
		"talon_dive", "wing_sweep",
	])

	assert_bool(bool(boss.call("request_attack", &"talon_dive"))).is_true()
	var dive_start: Dictionary = boss.call("get_attack_diagnostics")
	assert_str(String(dive_start.get("attack_phase", ""))).is_equal("startup")
	assert_bool(bool(dive_start.get("hitbox_active", true))).is_false()
	boss.call("advance_attack_frames", 20)
	var dive_active: Dictionary = boss.call("get_attack_diagnostics")
	assert_str(String(dive_active.get("attack_phase", ""))).is_equal("active")
	assert_bool(bool(dive_active.get("hitbox_active", false))).is_true()
	var dive_start_x: float = boss.global_position.x
	boss.call("advance_attack_frames", 1)
	assert_float(absf(boss.global_position.x - dive_start_x)).is_greater(0.0)
	boss.call("advance_attack_frames", 27)
	assert_str(String(boss.call(
		"get_attack_diagnostics"
	).get("attack_phase", ""))).is_equal("idle")
	boss.call("set_autonomous_attacks_enabled", true)
	boss.call("_process_idle")
	assert_str(String(boss.call(
		"get_attack_diagnostics"
	).get("locomotion_state", ""))).is_equal("approach")
	assert_str(String(boss.call(
		"get_attack_diagnostics"
	).get("animation", ""))).is_equal("run")
	boss.call("set_autonomous_attacks_enabled", false)

	var phase_transitions: Array[Dictionary] = []
	boss.on_boss_phase_transition_started.connect(func(
		entity_id: int,
		phase: int,
		metadata: Dictionary
	) -> void:
		phase_transitions.append({
			"entity_id": entity_id,
			"phase": phase,
			"metadata": metadata.duplicate(true),
		})
	)
	var abilities_before: Array[String] = _ability_strings(player)
	assert_bool(bool(boss.call("request_attack", &"wing_sweep"))).is_true()
	boss.call("advance_attack_frames", 24)
	var sweep_active: Dictionary = boss.call("get_attack_diagnostics")
	assert_str(String(sweep_active.get("attack_phase", ""))).is_equal("active")
	assert_bool(bool(sweep_active.get("hitbox_active", false))).is_true()
	var sweep_start: Vector2 = boss.global_position
	boss.call("advance_attack_frames", 1)
	assert_vector(boss.global_position).is_equal(sweep_start)
	assert_bool(bool(arena.call("apply_damage", BOSS_ENTITY_ID, 80, {}))).is_true()
	var pending_phase: Dictionary = boss.call("get_attack_diagnostics")
	assert_int(int(boss.call("get_current_phase"))).is_equal(1)
	assert_bool(bool(pending_phase.get("phase_two_pending", false))).is_true()
	boss.call("advance_attack_frames", 27)
	assert_int(int(boss.call("get_current_phase"))).is_equal(2)
	assert_int(phase_transitions.size()).is_equal(1)
	assert_int(int(phase_transitions[0].get("entity_id", 0))).is_equal(BOSS_ENTITY_ID)
	assert_array(_ability_strings(player)).is_equal(abilities_before)
	var phase_two: Dictionary = boss.call("get_attack_diagnostics")
	assert_int(int(phase_two.get("cooldown_frames", 0))).is_equal(30)
	assert_float(float(phase_two.get("dive_step_px", 0.0))).is_equal(12.0)
	assert_str(String(arena.call(
		"get_boss4_combat_diagnostics"
	).get("boss_hud_label", ""))).contains("Phase II")


func test_grounded_cat_claw_attack_reaches_crown_warden_hurtbox() -> void:
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
	player.global_position = Vector2(430.0, 552.0)
	boss.global_position = Vector2(515.0, 540.0)
	await get_tree().physics_frame
	await get_tree().physics_frame

	var hp_before: int = int(boss.call("get_current_hp"))
	assert_bool(bool(player.call("request_attack"))).is_true()
	for _frame: int in range(4):
		await get_tree().physics_frame
	assert_int(int(boss.call("get_current_hp"))).is_equal(hp_before - 12)
	var landed: Dictionary = arena.call("get_boss4_combat_diagnostics")
	var hit_metadata: Dictionary = Dictionary(landed.get("last_player_hit_metadata", {}))
	assert_int(int(hit_metadata.get("attacker_id", 0))).is_equal(1)
	assert_int(int(hit_metadata.get("target_id", 0))).is_equal(BOSS_ENTITY_ID)
	assert_str(String(hit_metadata.get("hitbox_id", ""))).is_equal("cat_claw_light")
	assert_int(int(hit_metadata.get("final_damage", 0))).is_equal(12)


func test_boss_attack_hitboxes_reach_grounded_player() -> void:
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

	var expected_damage: Dictionary = {
		&"talon_dive": 18,
		&"wing_sweep": 14,
	}
	var expected_hitbox: Dictionary = {
		&"talon_dive": "crown_warden_talon_dive",
		&"wing_sweep": "crown_warden_wing_sweep",
	}
	for pattern_id: StringName in [&"talon_dive", &"wing_sweep"]:
		boss.call("reset_encounter")
		player.call("restore_at_savepoint")
		player.global_position = Vector2(430.0, 552.0)
		boss.global_position = Vector2(515.0, 540.0)
		await get_tree().physics_frame
		await get_tree().physics_frame
		var hp_before: int = int(player.call("get_current_hp"))
		assert_bool(bool(boss.call("request_attack", pattern_id))).is_true()
		var startup_frames: int = int(boss.call(
			"get_current_attack_startup_frames"
		))
		for _frame: int in range(startup_frames + 5):
			await get_tree().physics_frame
		assert_int(int(player.call("get_current_hp"))).override_failure_message(
			"%s must overlap and deal its configured damage" % String(pattern_id)
		).is_equal(hp_before - int(expected_damage[pattern_id]))
		var metadata: Dictionary = boss.call("get_last_enemy_attack_metadata")
		assert_str(String(metadata.get("weapon_id", ""))).is_equal(
			String(expected_hitbox[pattern_id])
		)
		assert_int(int(metadata.get("final_damage", 0))).is_equal(
			int(expected_damage[pattern_id])
		)


func test_arena_lock_player_retry_defeat_and_fresh_restore_form_complete_loop() -> void:
	var arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(arena).is_not_null()
	if arena == null:
		return
	for method_name: StringName in [
		&"get_boss4_combat_diagnostics",
		&"configure_scene_manager_runtime",
		&"apply_damage",
	]:
		assert_bool(arena.has_method(method_name)).override_failure_message(
			"Story146 arena API missing: %s" % String(method_name)
		).is_true()
	if not arena.has_method("get_boss4_combat_diagnostics"):
		return
	var manager := FakeBoss4SceneManager.new()
	assert_bool(bool(arena.call("configure_scene_manager_runtime", manager))).is_true()
	var boss: Node = arena.get_node_or_null("CrownWardenBoss")
	var player: CharacterBody2D = arena.get_node_or_null("Player") as CharacterBody2D
	var entry: Marker2D = arena.get_node_or_null("BossEntrySpawn") as Marker2D
	assert_that(boss).is_not_null()
	assert_that(player).is_not_null()
	assert_that(entry).is_not_null()
	if boss == null or player == null or entry == null:
		return
	if boss.has_method("set_autonomous_attacks_enabled"):
		boss.call("set_autonomous_attacks_enabled", false)
	var abilities_before: Array[String] = _ability_strings(player)
	var active: Dictionary = arena.call("get_boss4_combat_diagnostics")
	assert_bool(bool(active.get("boss_defeated", true))).is_false()
	assert_bool(bool(active.get("room_seals_enabled", false))).is_true()
	assert_bool(bool(active.get("boss_hud_visible", false))).is_true()
	assert_bool(bool(active.get("return_route_available", true))).is_false()
	assert_bool(manager.locked).is_true()

	assert_bool(bool(arena.call("apply_damage", BOSS_ENTITY_ID, 40, {}))).is_true()
	player.call("apply_damage", 999, {"source": "story146_test"})
	await get_tree().process_frame
	await get_tree().process_frame
	for _frame: int in range(30):
		await get_tree().physics_frame
	var retried: Dictionary = arena.call("get_boss4_combat_diagnostics")
	assert_int(int(retried.get("player_death_count", 0))).is_equal(1)
	assert_int(int(retried.get("boss_current_hp", 0))).is_equal(BOSS_MAX_HP)
	assert_int(int(retried.get("boss_phase", 0))).is_equal(1)
	assert_float(player.global_position.x).is_equal_approx(entry.global_position.x, 0.01)
	assert_bool(player.is_on_floor()).is_true()
	assert_int(int(player.call("get_current_hp"))).is_equal(int(player.call("get_max_hp")))
	var player_collision: CollisionComponent = player.call("get_collision_component")
	assert_str(String(player_collision.get_hurtbox_state())).is_equal("normal")
	assert_bool(player_collision.get_hurtbox().monitorable).is_true()
	assert_array(_ability_strings(player)).is_equal(abilities_before)

	assert_bool(bool(arena.call(
		"apply_damage", BOSS_ENTITY_ID, BOSS_MAX_HP, {}
	))).is_true()
	var defeated: Dictionary = arena.call("get_boss4_combat_diagnostics")
	assert_bool(bool(defeated.get("boss_defeated", false))).is_true()
	assert_bool(bool(defeated.get("room_seals_enabled", true))).is_false()
	assert_bool(bool(defeated.get("boss_hud_visible", true))).is_false()
	assert_bool(bool(defeated.get("return_route_available", false))).is_true()
	assert_bool(manager.locked).is_false()
	assert_bool(bool(arena.call("get_local_state").get(DEFEATED_KEY, false))).is_true()

	var restored: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", {
		DEFEATED_KEY: true,
		"unlocked_abilities": abilities_before,
	})
	var restored_state: Dictionary = restored.call("get_boss4_combat_diagnostics")
	assert_bool(bool(restored_state.get("boss_defeated", false))).is_true()
	assert_bool(bool(restored_state.get("return_route_available", false))).is_true()
	assert_bool(bool(restored_state.get("transition_requested", true))).is_false()


func _pattern_ids(patterns: Array) -> Array[String]:
	var ids: Array[String] = []
	for value: Variant in patterns:
		if value is Dictionary:
			ids.append(String(Dictionary(value).get("pattern_id", "")))
	return ids


func _ability_strings(player: Node) -> Array[String]:
	var result: Array[String] = []
	if player == null or not player.has_method("get_unlocked_abilities"):
		return result
	for value: Variant in Array(player.call("get_unlocked_abilities")):
		result.append(String(value))
	result.sort()
	return result


func _instantiate_scene(path: String) -> Node:
	if not FileAccess.file_exists(path):
		return null
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		return null
	var instance: Node = packed.instantiate()
	add_child(instance)
	_spawned_nodes.append(instance)
	return instance


func _read_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var player := child as AudioStreamPlayer
			player.stop()
			player.stream = null
		elif child is AudioStreamPlayer2D:
			var spatial := child as AudioStreamPlayer2D
			spatial.stop()
			spatial.stream = null
