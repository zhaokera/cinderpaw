## Player Abilities Story128: playable Sluice Matriarch Boss3 core.
extends GdUnitTestSuite

const ARENA_SCENE_PATH: String = "res://scenes/bosses/sluice_matriarch_arena.tscn"
const CHARACTER_SCENE_PATH: String = "res://scenes/characters/sluice_matriarch.tscn"
const CHARACTER_SCRIPT_PATH: String = "res://src/characters/sluice_matriarch.gd"
const BOSS_SCENE_PATH: String = "res://src/gameplay/sluice_matriarch_boss.tscn"
const BOSS_SCRIPT_PATH: String = "res://src/gameplay/sluice_matriarch_boss.gd"
const SPRITE_FRAMES_PATH: String = (
	"res://assets/characters/sluice_matriarch/sluice_matriarch_sprite_frames.tres"
)
const ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack_tell",
	&"attack",
	&"geyser_tell",
	&"geyser_attack",
	&"attack_recovery",
	&"phase_transition",
	&"hurt",
	&"death",
]
const BOSS_ENTITY_ID: int = 2300
const BOSS_MAX_HP: int = 120
const DEFEATED_STATE_KEY: String = "boss_03_sluice_matriarch_defeated"

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


func test_character_frames_follow_boss3_animation_contract() -> void:
	assert_bool(FileAccess.file_exists(CHARACTER_SCRIPT_PATH)).is_true()
	assert_bool(FileAccess.file_exists(CHARACTER_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(BOSS_SCRIPT_PATH)).is_true()
	assert_bool(FileAccess.file_exists(BOSS_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(SPRITE_FRAMES_PATH)).is_true()
	if not FileAccess.file_exists(SPRITE_FRAMES_PATH):
		return

	var sprite_frames: SpriteFrames = load(SPRITE_FRAMES_PATH) as SpriteFrames
	assert_that(sprite_frames).is_not_null()
	if sprite_frames == null:
		return
	assert_int(sprite_frames.get_animation_names().size()).is_equal(ANIMATIONS.size())
	for animation_name: StringName in ANIMATIONS:
		assert_bool(sprite_frames.has_animation(animation_name)).is_true()
		assert_int(sprite_frames.get_frame_count(animation_name)).is_equal(3)
		for frame_index: int in range(3):
			var texture: Texture2D = sprite_frames.get_frame_texture(
				animation_name,
				frame_index
			)
			assert_that(texture).is_not_null()
			if texture == null:
				continue
			assert_vector(texture.get_size()).is_equal(Vector2(192, 192))
			var image: Image = texture.get_image()
			assert_that(image).is_not_null()
			if image != null:
				assert_bool(image.detect_alpha() != Image.ALPHA_NONE).is_true()
				assert_int(image.get_pixel(0, 0).a8).is_equal(0)

	var character: Node = _instantiate_scene(CHARACTER_SCENE_PATH)
	assert_that(character).is_not_null()
	assert_bool(character is AnimatedSprite2D).is_true()
	if character is AnimatedSprite2D:
		assert_that((character as AnimatedSprite2D).sprite_frames).is_same(sprite_frames)


func test_pressure_lunge_phase_two_and_arena_defeat_restore_contract() -> void:
	assert_bool(FileAccess.file_exists(BOSS_SCENE_PATH)).is_true()
	if not FileAccess.file_exists(BOSS_SCENE_PATH):
		return
	var boss: Node2D = _instantiate_scene(BOSS_SCENE_PATH) as Node2D
	assert_that(boss).is_not_null()
	if boss == null:
		return
	assert_int(int(boss.call("get_entity_id"))).is_equal(BOSS_ENTITY_ID)
	assert_int(int(boss.call("get_max_hp"))).is_equal(BOSS_MAX_HP)
	assert_int(int(boss.call("get_current_phase"))).is_equal(1)
	assert_int(int(boss.call("get_current_attack_startup_frames"))).is_equal(18)
	boss.global_position = Vector2(800, 540)

	var target := Node2D.new()
	target.name = "Boss3TestTarget"
	target.position = boss.position + Vector2(-240, 0)
	add_child(target)
	_spawned_nodes.append(target)
	boss.call("set_attack_target", target)
	var start_x: float = boss.global_position.x
	assert_bool(bool(boss.call("request_attack"))).is_true()
	assert_str(String(boss.call("get_attack_phase"))).is_equal("startup")
	var startup: Dictionary = boss.call("get_pressure_lunge_diagnostics")
	assert_bool(bool(startup.get("hitbox_active", true))).is_false()
	boss.call("advance_attack_frames", 19)
	var active: Dictionary = boss.call("get_pressure_lunge_diagnostics")
	assert_str(String(active.get("attack_phase", ""))).is_equal("active")
	assert_bool(bool(active.get("hitbox_active", false))).is_true()
	assert_float(boss.global_position.x).is_less(start_x)
	assert_int(int(active.get("attack_damage", 0))).is_equal(16)
	boss.call("advance_attack_frames", 32)
	boss.call("apply_damage", 61, {"source": &"story128_test"})
	assert_int(int(boss.call("get_current_phase"))).is_equal(2)
	var phase_two: Dictionary = boss.call("get_pressure_lunge_diagnostics")
	assert_bool(float(phase_two.get("lunge_step_px", 0.0)) > 0.0).is_true()
	assert_bool(
		int(phase_two.get("attack_cooldown_frames", 99))
		< int(phase_two.get("phase_one_attack_cooldown_frames", 0))
	).is_true()

	var arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(arena).is_not_null()
	if arena == null:
		return
	assert_bool(arena.has_method("get_boss3_combat_diagnostics")).is_true()
	assert_bool(arena.has_method("apply_damage")).is_true()
	if not arena.has_method("get_boss3_combat_diagnostics"):
		return
	var active_arena: Dictionary = arena.call("get_boss3_combat_diagnostics")
	assert_bool(bool(active_arena.get("boss_present", false))).is_true()
	assert_bool(bool(active_arena.get("boss_defeated", true))).is_false()
	assert_bool(bool(active_arena.get("room_seals_enabled", false))).is_true()
	assert_bool(bool(active_arena.get("return_route_available", true))).is_false()
	assert_bool(bool(active_arena.get("boss_hud_visible", false))).is_true()
	var arena_player: Node = arena.get_node_or_null("Player")
	var arena_boss: Node = arena.get_node_or_null("SluiceMatriarchBoss")
	assert_that(arena_player).is_not_null()
	assert_that(arena_boss).is_not_null()
	if arena_player != null and arena_boss != null:
		arena_boss.set_physics_process(false)
		var player_collision: CollisionComponent = arena_player.call(
			"get_collision_component"
		)
		var boss_collision: CollisionComponent = arena_boss.call(
			"get_collision_component"
		)
		var boss_hp_before_player_hit: int = int(arena_boss.call("get_current_hp"))
		assert_bool(bool(arena_player.call("request_attack"))).is_true()
		var player_combat: CombatComponent = arena_player.call("get_combat_component")
		player_combat.advance_attack_frames(4)
		assert_bool(player_collision.is_hitbox_active(&"cat_claw_light")).is_true()
		player_collision.process_detection_frame({
			&"cat_claw_light": [boss_collision.get_hurtbox()],
		})
		assert_int(int(arena_boss.call("get_current_hp"))).is_equal(
			boss_hp_before_player_hit - 12
		)
		var player_hit: Dictionary = arena.call("get_boss3_combat_diagnostics")
		assert_int(int(Dictionary(player_hit.get(
			"last_player_hit_metadata",
			{}
		)).get("target_id", -1))).is_equal(BOSS_ENTITY_ID)
	assert_bool(bool(arena.call(
		"apply_damage",
		BOSS_ENTITY_ID,
		BOSS_MAX_HP,
		{"source": &"story128_arena_test"}
	))).is_true()
	var defeated: Dictionary = arena.call("get_boss3_combat_diagnostics")
	assert_bool(bool(defeated.get("boss_defeated", false))).is_true()
	assert_bool(bool(defeated.get("room_seals_enabled", true))).is_false()
	assert_bool(bool(defeated.get("return_route_available", false))).is_true()
	assert_bool(bool(defeated.get("boss_hud_visible", true))).is_false()
	var local_state: Dictionary = arena.call("get_local_state")
	assert_bool(bool(local_state.get(DEFEATED_STATE_KEY, false))).is_true()

	var restored_arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(restored_arena).is_not_null()
	if restored_arena == null:
		return
	restored_arena.call("set_local_state", {DEFEATED_STATE_KEY: true})
	var restored: Dictionary = restored_arena.call("get_boss3_combat_diagnostics")
	assert_bool(bool(restored.get("boss_defeated", false))).is_true()
	assert_bool(bool(restored.get("room_seals_enabled", true))).is_false()
	assert_bool(bool(restored.get("return_route_available", false))).is_true()
	assert_bool(bool(restored.get("return_transition_requested", true))).is_false()


func test_phase_two_transition_refreshes_arena_boss_hud() -> void:
	var arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(arena).is_not_null()
	if arena == null:
		return
	var boss: Node = arena.get_node_or_null("SluiceMatriarchBoss")
	assert_that(boss).is_not_null()
	if boss == null:
		return
	boss.set_physics_process(false)
	boss.call("reset_encounter")
	assert_bool(bool(arena.call(
		"apply_damage",
		BOSS_ENTITY_ID,
		61,
		{"source": &"story128_phase_hud_test"}
	))).is_true()
	await get_tree().process_frame
	var diagnostics: Dictionary = arena.call("get_boss3_combat_diagnostics")
	assert_int(int(diagnostics.get("boss_phase", 0))).is_equal(2)
	assert_str(String(diagnostics.get("boss_hud_label", ""))).contains("Phase II")


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
