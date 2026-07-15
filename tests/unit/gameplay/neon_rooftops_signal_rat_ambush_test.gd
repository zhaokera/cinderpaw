## Player Abilities Story137: first Neon Rooftops ACT combat and reward loop.
extends GdUnitTestSuite

const ROOFTOPS_SCENE_PATH: String = (
	"res://scenes/areas/neon_rooftops_entry.tscn"
)
const CHARACTER_SCENE_PATH: String = (
	"res://scenes/characters/neon_signal_rat.tscn"
)
const RUNTIME_SCENE_PATH: String = (
	"res://src/gameplay/neon_signal_rat.tscn"
)
const CONTROLLER_SCRIPT_PATH: String = (
	"res://src/gameplay/neon_signal_roof_encounter_controller.gd"
)
const SPRITE_FRAMES_PATH: String = (
	"res://assets/characters/neon_signal_rat/"
	+ "neon_signal_rat_sprite_frames.tres"
)
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "env_neon_signal_roof_1280x720.png"
)
const SEAL_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_signal_seal_256x384.png"
)
const CACHE_TEXTURE_PATH: String = (
	"res://assets/environment/neon_rooftops/"
	+ "prop_neon_signal_cache_256x256.png"
)
const ENEMY_STATS_PATH: String = "res://data/combat/enemy_stats.json"
const ENCOUNTER_NODE_PATH: String = "SignalRoofEncounter"
const ENEMY_NODE_PATH: String = "SignalRoofEncounter/NeonSignalRat"
const CACHE_NODE_PATH: String = "SignalRoofEncounter/SignalCache"
const ROUTE_WIDTH_PX: int = 2560
const ACTIVATION_X: float = 1650.0
const BACK_SEAL_X: float = 1540.0
const FORWARD_SEAL_X: float = 2440.0
const CACHE_X: float = 2320.0
const SIGNAL_RAT_ENTITY_ID: int = 2601
const SIGNAL_RAT_MAX_HP: int = 36
const ATTACK_STARTUP_FRAMES: int = 18
const ATTACK_ACTIVE_FRAMES: int = 5
const ATTACK_RECOVERY_FRAMES: int = 18
const ATTACK_DAMAGE: int = 11
const ATTACK_HITBOX_ID: StringName = &"neon_signal_rat_lunge"
const FRAME_SIZE: Vector2i = Vector2i(96, 96)
const REQUIRED_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	get_tree().paused = false
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_authored_expansion_data_and_frame_animation_contract() -> void:
	assert_bool(FileAccess.file_exists(BACKGROUND_TEXTURE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(SEAL_TEXTURE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(CACHE_TEXTURE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(CHARACTER_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(RUNTIME_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(CONTROLLER_SCRIPT_PATH)).is_true()
	assert_bool(FileAccess.file_exists(SPRITE_FRAMES_PATH)).is_true()

	_assert_png_contract(BACKGROUND_TEXTURE_PATH, Vector2i(1280, 720), false)
	_assert_png_contract(SEAL_TEXTURE_PATH, Vector2i(256, 384), true)
	_assert_png_contract(CACHE_TEXTURE_PATH, Vector2i(256, 256), true)
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		for frame_index: int in range(3):
			_assert_png_contract(
				_frame_path(animation_name, frame_index),
				FRAME_SIZE,
				true
			)

	if FileAccess.file_exists(SPRITE_FRAMES_PATH):
		var frames: SpriteFrames = load(SPRITE_FRAMES_PATH) as SpriteFrames
		assert_that(frames).is_not_null()
		if frames != null:
			for animation_name: StringName in REQUIRED_ANIMATIONS:
				assert_bool(frames.has_animation(animation_name)).is_true()
				assert_int(frames.get_frame_count(animation_name)).is_equal(3)

	var stats: Dictionary = _read_json_dictionary(ENEMY_STATS_PATH)
	var entries: Dictionary = Dictionary(stats.get("entries", {}))
	assert_bool(entries.has("neon_signal_rat")).is_true()
	if entries.has("neon_signal_rat"):
		var signal_rat: Dictionary = Dictionary(entries["neon_signal_rat"])
		assert_int(int(signal_rat.get("max_hp", 0))).is_equal(SIGNAL_RAT_MAX_HP)

	var scene: Node = _instantiate_scene(ROOFTOPS_SCENE_PATH)
	assert_that(scene).is_not_null()
	if scene == null:
		return
	assert_bool(scene.has_method("get_signal_roof_diagnostics")).is_true()
	if not scene.has_method("get_signal_roof_diagnostics"):
		return
	var diagnostics: Dictionary = scene.call("get_signal_roof_diagnostics")
	assert_int(int(diagnostics.get("route_width_px", 0))).is_equal(
		ROUTE_WIDTH_PX
	)
	assert_str(String(diagnostics.get("controller_script_path", ""))).is_equal(
		CONTROLLER_SCRIPT_PATH
	)
	assert_str(String(diagnostics.get("background_texture_path", ""))).is_equal(
		BACKGROUND_TEXTURE_PATH
	)
	assert_float(float(diagnostics.get("activation_x", 0.0))).is_equal_approx(
		ACTIVATION_X,
		0.01
	)
	assert_float(float(diagnostics.get("back_seal_x", 0.0))).is_equal_approx(
		BACK_SEAL_X,
		0.01
	)
	assert_float(float(diagnostics.get("forward_seal_x", 0.0))).is_equal_approx(
		FORWARD_SEAL_X,
		0.01
	)
	assert_float(float(diagnostics.get("cache_x", 0.0))).is_equal_approx(
		CACHE_X,
		0.01
	)
	assert_int(int(diagnostics.get("enemy_entity_id", 0))).is_equal(
		SIGNAL_RAT_ENTITY_ID
	)
	assert_str(String(diagnostics.get("enemy_family_id", ""))).is_equal(
		"neon_signal_rat"
	)
	assert_int(int(diagnostics.get("enemy_max_hp", 0))).is_equal(
		SIGNAL_RAT_MAX_HP
	)
	assert_int(int(diagnostics.get("attack_startup_frames", 0))).is_equal(
		ATTACK_STARTUP_FRAMES
	)
	assert_int(int(diagnostics.get("attack_active_frames", 0))).is_equal(
		ATTACK_ACTIVE_FRAMES
	)
	assert_int(int(diagnostics.get("attack_recovery_frames", 0))).is_equal(
		ATTACK_RECOVERY_FRAMES
	)
	assert_int(int(diagnostics.get("attack_damage", 0))).is_equal(ATTACK_DAMAGE)
	var camera: Camera2D = scene.get_node_or_null("Player/Camera2D") as Camera2D
	assert_that(camera).is_not_null()
	if camera != null:
		assert_int(camera.limit_right).is_greater_equal(ROUTE_WIDTH_PX)
	assert_that(scene.get_node_or_null(ENCOUNTER_NODE_PATH)).is_not_null()
	assert_that(scene.get_node_or_null(ENEMY_NODE_PATH)).is_not_null()
	assert_that(scene.get_node_or_null(CACHE_NODE_PATH)).is_not_null()


func test_story136_gate_tell_duplicate_damage_and_real_player_hit() -> void:
	var scene: Node = _instantiate_scene(ROOFTOPS_SCENE_PATH)
	assert_that(scene).is_not_null()
	if scene == null:
		return
	assert_bool(scene.has_method("try_activate_signal_roof_encounter")).is_true()
	assert_bool(scene.has_method("get_signal_roof_diagnostics")).is_true()
	if not scene.has_method("try_activate_signal_roof_encounter"):
		return
	var player: Node2D = scene.get_node_or_null("Player") as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return
	player.global_position.x = ACTIVATION_X
	assert_bool(bool(scene.call(
		"try_activate_signal_roof_encounter",
		player
	))).is_false()

	scene.call("set_local_state", _story136_traversed_state())
	player.global_position.x = ACTIVATION_X - 1.0
	assert_bool(bool(scene.call(
		"try_activate_signal_roof_encounter",
		player
	))).is_false()
	player.global_position.x = ACTIVATION_X
	assert_bool(bool(scene.call(
		"try_activate_signal_roof_encounter",
		player
	))).is_true()
	assert_bool(bool(scene.call(
		"try_activate_signal_roof_encounter",
		player
	))).is_false()
	await get_tree().process_frame

	var active: Dictionary = scene.call("get_signal_roof_diagnostics")
	assert_str(String(active.get("encounter_state", ""))).is_equal("active")
	assert_bool(bool(active.get("back_seal_blocking", false))).is_true()
	assert_bool(bool(active.get("forward_seal_blocking", false))).is_true()
	assert_bool(bool(active.get("enemy_visible", false))).is_true()
	assert_bool(bool(active.get("enemy_has_target", false))).is_true()
	assert_str(String(active.get("objective_text", ""))).is_equal(
		"Break Neon Signal Rat"
	)

	var enemy: CharacterBody2D = scene.get_node_or_null(
		ENEMY_NODE_PATH
	) as CharacterBody2D
	assert_that(enemy).is_not_null()
	if enemy == null:
		return
	enemy.set_physics_process(false)
	assert_bool(bool(enemy.call("request_attack"))).is_true()
	var sprite: AnimatedSprite2D = enemy.get_node_or_null(
		"Sprite"
	) as AnimatedSprite2D
	assert_that(sprite).is_not_null()
	if sprite != null:
		assert_str(String(sprite.animation)).is_equal("attack_tell")
	enemy.call("advance_attack_frames", ATTACK_STARTUP_FRAMES - 1)
	assert_bool(bool(enemy.call("is_enemy_attack_active"))).is_false()
	enemy.call("advance_attack_frames", 1)
	assert_bool(bool(enemy.call("is_enemy_attack_active"))).is_true()

	var hp_before: int = int(player.call("get_current_hp"))
	var enemy_collision: CollisionComponent = enemy.call(
		"get_collision_component"
	) as CollisionComponent
	var player_collision: CollisionComponent = player.call(
		"get_collision_component"
	) as CollisionComponent
	assert_that(enemy_collision).is_not_null()
	assert_that(player_collision).is_not_null()
	if enemy_collision == null or player_collision == null:
		return
	enemy_collision.process_detection_frame({
		ATTACK_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	assert_int(int(player.call("get_current_hp"))).is_equal(
		hp_before - ATTACK_DAMAGE
	)
	enemy_collision.process_detection_frame({
		ATTACK_HITBOX_ID: [player_collision.get_hurtbox()],
	})
	assert_int(int(player.call("get_current_hp"))).is_equal(
		hp_before - ATTACK_DAMAGE
	)
	await _wait_for_scene_hitstop(scene)
	await _wait_for_player_combat_idle(player)

	player.global_position.y = 556.0
	player.call("set_airborne", false)
	var enemy_hp_before: int = int(enemy.call("get_current_hp"))
	assert_bool(bool(player.call("request_attack"))).is_true()
	var player_combat: CombatComponent = player.call(
		"get_combat_component"
	) as CombatComponent
	assert_that(player_combat).is_not_null()
	if player_combat == null:
		return
	var light_frame_data: Dictionary = player_combat.get_light_attack_frame_data(0)
	player_combat.advance_attack_frames(int(light_frame_data.get(
		"startup_frames",
		0
	)))
	assert_bool(player_collision.is_hitbox_active(
		&"cat_claw_light"
	)).is_true()
	player_collision.process_detection_frame({
		&"cat_claw_light": [enemy_collision.get_hurtbox()],
	})
	assert_bool(int(enemy.call("get_current_hp")) < enemy_hp_before).is_true()
	var last_hit: Dictionary = scene.call("get_last_signal_roof_player_hit")
	assert_int(int(last_hit.get("target_id", -1))).is_equal(
		SIGNAL_RAT_ENTITY_ID
	)


func _wait_for_scene_hitstop(scene: Node) -> void:
	var presentation: CombatPresentation = scene.get_node_or_null(
		"CombatPresentation"
	) as CombatPresentation
	while presentation != null and presentation.is_gameplay_hitstop_active():
		await get_tree().process_frame


func _wait_for_player_combat_idle(player: Node2D) -> void:
	var combat: CombatComponent = player.call(
		"get_combat_component"
	) as CombatComponent
	while (
		combat != null
		and combat.get_current_state() != CombatComponent.CombatState.IDLE
	):
		await get_tree().physics_frame


func test_defeat_cache_claim_and_fresh_restore_are_deterministic() -> void:
	var scene: Node = _instantiate_scene(ROOFTOPS_SCENE_PATH)
	assert_that(scene).is_not_null()
	if scene == null:
		return
	assert_bool(scene.has_method("try_activate_signal_roof_encounter")).is_true()
	assert_bool(scene.has_method("try_claim_signal_cache")).is_true()
	assert_bool(scene.has_method("apply_damage")).is_true()
	assert_bool(scene.has_method("get_signal_roof_diagnostics")).is_true()
	if not scene.has_method("try_activate_signal_roof_encounter"):
		return
	scene.call("set_local_state", _story136_traversed_state())
	var player: Node2D = scene.get_node_or_null("Player") as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return
	player.global_position.x = ACTIVATION_X
	assert_bool(bool(scene.call(
		"try_activate_signal_roof_encounter",
		player
	))).is_true()
	await get_tree().process_frame

	assert_bool(bool(scene.call("apply_damage", SIGNAL_RAT_ENTITY_ID, 999, {
		"source": &"story137_test_clear",
	}))).is_true()
	await get_tree().process_frame
	var cleared: Dictionary = scene.call("get_signal_roof_diagnostics")
	assert_str(String(cleared.get("encounter_state", ""))).is_equal("cleared")
	assert_bool(bool(cleared.get("enemy_visible", false))).is_true()
	assert_str(String(cleared.get("enemy_animation", ""))).is_equal("death")
	assert_bool(bool(cleared.get("back_seal_blocking", true))).is_false()
	assert_bool(bool(cleared.get("forward_seal_blocking", true))).is_false()
	assert_bool(bool(cleared.get("cache_available", false))).is_true()
	assert_str(String(cleared.get("objective_text", ""))).is_equal(
		"Claim Signal Cache +20 Gears"
	)

	var cache: Node2D = scene.get_node_or_null(CACHE_NODE_PATH) as Node2D
	assert_that(cache).is_not_null()
	if cache == null:
		return
	player.global_position = cache.global_position
	assert_bool(bool(scene.call("try_claim_signal_cache", player))).is_true()
	assert_bool(bool(scene.call("try_claim_signal_cache", player))).is_false()
	var claimed: Dictionary = scene.call("get_signal_roof_diagnostics")
	assert_bool(bool(claimed.get("cache_claimed", false))).is_true()
	assert_int(int(Dictionary(claimed.get("last_reward", {})).get(
		"gears",
		0
	))).is_equal(20)
	assert_str(String(claimed.get("objective_text", ""))).is_equal(
		"Signal Roof Secured"
	)

	var saved: Dictionary = scene.call("get_local_state")
	assert_bool(bool(saved.get(
		"neon_rooftops_signal_rat_encounter_activated",
		false
	))).is_true()
	assert_bool(bool(saved.get(
		"neon_rooftops_signal_rat_defeated",
		false
	))).is_true()
	assert_bool(bool(saved.get(
		"neon_rooftops_signal_cache_claimed",
		false
	))).is_true()

	var restored_scene: Node = _instantiate_scene(ROOFTOPS_SCENE_PATH)
	assert_that(restored_scene).is_not_null()
	if restored_scene == null:
		return
	restored_scene.call("set_local_state", saved)
	await get_tree().process_frame
	var restored: Dictionary = restored_scene.call("get_signal_roof_diagnostics")
	assert_str(String(restored.get("encounter_state", ""))).is_equal("claimed")
	assert_bool(bool(restored.get("enemy_visible", true))).is_false()
	assert_bool(bool(restored.get("back_seal_blocking", true))).is_false()
	assert_bool(bool(restored.get("forward_seal_blocking", true))).is_false()
	assert_bool(bool(restored.get("cache_claimed", false))).is_true()
	assert_int(int(restored.get("defeat_feedback_count", -1))).is_equal(0)
	assert_int(int(restored.get("reward_feedback_count", -1))).is_equal(0)


func _story136_traversed_state() -> Dictionary:
	return {
		"neon_rooftops_entry_arrived": true,
		"neon_rooftops_entry_traversed": true,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb",
		],
	}


func _frame_path(animation_name: StringName, frame_index: int) -> String:
	return (
		"res://assets/characters/neon_signal_rat/%s/"
		% String(animation_name)
		+ "neon_signal_rat_%s_%03d.png"
		% [String(animation_name), frame_index]
	)


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
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}


func _assert_png_contract(
	path: String,
	expected_size: Vector2i,
	alpha: bool
) -> void:
	assert_bool(FileAccess.file_exists(path)).is_true()
	if not FileAccess.file_exists(path):
		return
	var image := Image.new()
	var load_error: Error = image.load_png_from_buffer(
		FileAccess.get_file_as_bytes(path)
	)
	assert_int(load_error).is_equal(OK)
	if load_error != OK:
		return
	assert_int(image.get_width()).is_equal(expected_size.x)
	assert_int(image.get_height()).is_equal(expected_size.y)
	if alpha:
		assert_int(image.detect_alpha()).is_equal(Image.ALPHA_BLEND)
		assert_float(image.get_pixel(0, 0).a).is_less_equal(0.01)
		assert_float(image.get_pixel(
			expected_size.x - 1,
			expected_size.y - 1
		).a).is_less_equal(0.01)
	else:
		assert_int(image.detect_alpha()).is_equal(Image.ALPHA_NONE)


func _stop_runtime_audio_players() -> void:
	var audio_system: Node = get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			(child as AudioStreamPlayer).stop()
		elif child is AudioStreamPlayer2D:
			(child as AudioStreamPlayer2D).stop()
