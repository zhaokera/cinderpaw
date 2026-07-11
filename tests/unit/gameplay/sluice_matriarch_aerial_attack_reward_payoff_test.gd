## Player Abilities Story129: Boss3 aerial-attack reward and immediate payoff.
extends GdUnitTestSuite

const ARENA_SCENE_PATH: String = "res://scenes/bosses/sluice_matriarch_arena.tscn"
const PLAYER_SCENE_PATH: String = "res://scenes/player.tscn"
const SPRITE_FRAMES_PATH: String = (
	"res://assets/characters/cinderpaw/cinderpaw_sprite_frames.tres"
)
const REWARD_TEXTURE_PATH: String = (
	"res://assets/environment/aerial_attack_reward/"
	+ "boss3_aerial_attack_reward_source.png"
)
const AERIAL_ATTACK: StringName = &"aerial_attack"
const BOSS_ENTITY_ID: int = 2300
const BOSS_MAX_HP: int = 120
const DEFEATED_STATE_KEY: String = "boss_03_sluice_matriarch_defeated"
const REWARD_CLAIMED_STATE_KEY: String = "boss_03_aerial_attack_reward_claimed"

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


func test_reward_claim_unlocks_and_restores_aerial_attack() -> void:
	var arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(arena).is_not_null()
	if arena == null:
		return
	var player: Node = arena.get_node_or_null("Player")
	var source: Node = arena.get_node_or_null("AerialAttackRewardSource")
	assert_that(player).is_not_null()
	assert_that(source).is_not_null()
	assert_bool(arena.has_method("claim_aerial_attack_reward_source")).is_true()
	assert_bool(arena.has_method("get_aerial_attack_payoff_diagnostics")).is_true()
	if player == null or source == null:
		return
	assert_bool(bool(source.call("is_claim_available"))).is_false()
	assert_bool(bool(player.call("has_ability", AERIAL_ATTACK))).is_false()
	var scene_manager: Node = get_node_or_null("/root/SceneManager")
	var factory_state_before: Dictionary = {}
	var main_state_before: Dictionary = {}
	if scene_manager != null:
		factory_state_before = scene_manager.call("get_scene_state", &"area_03_factory")
		main_state_before = scene_manager.call("get_scene_state", &"main")

	assert_bool(bool(arena.call(
		"apply_damage",
		BOSS_ENTITY_ID,
		BOSS_MAX_HP,
		{"source": &"story129_reward_test"}
	))).is_true()
	assert_bool(bool(source.call("is_claim_available"))).is_true()
	var reveal: Dictionary = arena.call("get_aerial_attack_payoff_diagnostics")
	assert_int(int(reveal.get("reveal_vfx_spawn_count", 0))).is_equal(1)
	player.set("global_position", source.get("global_position"))
	if not arena.has_method("claim_aerial_attack_reward_source"):
		return
	assert_bool(bool(arena.call("claim_aerial_attack_reward_source", player))).is_true()
	assert_bool(bool(arena.call("claim_aerial_attack_reward_source", player))).is_false()
	assert_bool(bool(player.call("has_ability", AERIAL_ATTACK))).is_true()
	var local_state: Dictionary = arena.call("get_local_state")
	assert_bool(bool(local_state.get(DEFEATED_STATE_KEY, false))).is_true()
	assert_bool(bool(local_state.get(REWARD_CLAIMED_STATE_KEY, false))).is_true()
	assert_array(Array(local_state.get("unlocked_abilities", []))).contains([
		String(AERIAL_ATTACK)
	])
	var hud: Node = arena.get_node_or_null("HUD")
	assert_that(hud).is_not_null()
	if hud != null:
		assert_str(String(hud.call("get_notification_text"))).contains("Aerial Attack")
	if scene_manager != null:
		var factory_state: Dictionary = scene_manager.call(
			"get_scene_state",
			&"area_03_factory"
		)
		var main_state: Dictionary = scene_manager.call("get_scene_state", &"main")
		assert_array(Array(factory_state.get("unlocked_abilities", []))).contains([
			String(AERIAL_ATTACK)
		])
		assert_array(Array(main_state.get("unlocked_abilities", []))).contains([
			String(AERIAL_ATTACK)
		])

	var restored: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(restored).is_not_null()
	if restored == null:
		return
	restored.call("set_local_state", local_state)
	var restored_player: Node = restored.get_node_or_null("Player")
	var restored_source: Node = restored.get_node_or_null("AerialAttackRewardSource")
	assert_bool(bool(restored_player.call("has_ability", AERIAL_ATTACK))).is_true()
	assert_bool(bool(restored_source.call("is_claimed"))).is_true()
	assert_bool(bool(restored_source.call("is_claim_available"))).is_false()
	if scene_manager != null:
		scene_manager.call("set_scene_state", &"area_03_factory", factory_state_before)
		scene_manager.call("set_scene_state", &"main", main_state_before)


func test_aerial_attack_frames_follow_cinderpaw_contract() -> void:
	assert_bool(FileAccess.file_exists(REWARD_TEXTURE_PATH)).is_true()
	var frames: SpriteFrames = load(SPRITE_FRAMES_PATH) as SpriteFrames
	assert_that(frames).is_not_null()
	if frames == null:
		return
	assert_bool(frames.has_animation(AERIAL_ATTACK)).is_true()
	if not frames.has_animation(AERIAL_ATTACK):
		return
	assert_int(frames.get_frame_count(AERIAL_ATTACK)).is_equal(3)
	for frame_index: int in range(3):
		var texture: Texture2D = frames.get_frame_texture(AERIAL_ATTACK, frame_index)
		assert_that(texture).is_not_null()
		if texture == null:
			continue
		assert_vector(texture.get_size()).is_equal(Vector2(96, 96))
		var image: Image = texture.get_image()
		assert_that(image).is_not_null()
		if image != null:
			assert_bool(image.detect_alpha() != Image.ALPHA_NONE).is_true()
			assert_int(image.get_pixel(0, 0).a8).is_equal(0)


func test_aerial_attack_requires_airborne_unlock_and_bounces_on_hit() -> void:
	var arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(arena).is_not_null()
	if arena == null:
		return
	var player: CharacterBody2D = arena.get_node_or_null("Player") as CharacterBody2D
	var boss: Node = arena.get_node_or_null("SluiceMatriarchBoss")
	assert_that(player).is_not_null()
	assert_that(boss).is_not_null()
	assert_bool(player.has_method("request_aerial_attack")).is_true()
	assert_bool(player.has_method("get_aerial_attack_diagnostics")).is_true()
	if player == null or boss == null or not player.has_method("request_aerial_attack"):
		return
	boss.set_physics_process(false)
	player.call("set_airborne", true)
	assert_bool(bool(player.call("request_aerial_attack"))).is_false()
	assert_bool(bool(player.call("unlock_ability", AERIAL_ATTACK))).is_true()
	player.call("set_airborne", false)
	assert_bool(bool(player.call("request_aerial_attack"))).is_false()
	assert_bool(bool(player.call("unlock_ability", &"double_jump"))).is_true()
	player.call("set_airborne", true)
	assert_bool(bool(player.call("request_double_jump"))).is_true()
	player.position.y -= 96.0
	assert_bool(bool(player.call("request_attack"))).is_true()
	var started: Dictionary = player.call("get_aerial_attack_diagnostics")
	assert_bool(bool(started.get("active", false))).is_true()
	assert_str(String(started.get("animation", ""))).is_equal("aerial_attack")
	assert_str(String(started.get("hitbox_id", ""))).is_equal("cat_claw_aerial")
	assert_bool(player.velocity.y > 0.0).is_true()

	var player_combat: CombatComponent = player.call("get_combat_component")
	var player_collision: CollisionComponent = player.call("get_collision_component")
	var boss_collision: CollisionComponent = boss.call("get_collision_component")
	var hp_before: int = int(boss.call("get_current_hp"))
	var energy_before: int = player_combat.get_cat_energy()
	player_collision.process_detection_frame({
		&"cat_claw_aerial": [boss_collision.get_hurtbox()],
	})
	assert_int(int(boss.call("get_current_hp"))).is_equal(hp_before - 12)
	assert_int(player_combat.get_cat_energy()).is_equal(energy_before + 8)
	assert_bool(player.velocity.y < 0.0).is_true()
	var bounced: Dictionary = player.call("get_aerial_attack_diagnostics")
	assert_bool(bool(bounced.get("bounce_consumed", false))).is_true()
	assert_bool(bool(bounced.get("air_jump_restored", false))).is_true()


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
