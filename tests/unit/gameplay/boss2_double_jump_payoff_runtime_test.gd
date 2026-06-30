## Mainline Boss2 payoff shell for the Double Jump ability route.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const CHARACTER_SCENE_PATH: String = "res://scenes/characters/boss2_echo_guardian.tscn"
const CHARACTER_SCRIPT_PATH: String = "res://src/characters/boss2_echo_guardian.gd"
const SPRITE_FRAMES_PATH: String = (
	"res://assets/characters/boss2_echo_guardian/boss2_echo_guardian_sprite_frames.tres"
)
const REWARD_TEXTURE_PATH: String = (
	"res://assets/environment/double_jump_reward/boss2_double_jump_reward_source.png"
)
const BOSS_NODE_NAME: String = "Boss2EchoGuardian"
const REWARD_NODE_NAME: String = "Boss2DoubleJumpRewardSource"
const DOUBLE_JUMP_GATE_NAME: String = "DoubleJumpExplorationGate"
const DOUBLE_JUMP_ABILITY: StringName = &"double_jump"
const BOSS2_ENTITY_ID: int = 2200
const REWARD_ID: StringName = &"boss_02_double_jump"
const CLAIMED_FLAG: String = "boss_02_double_jump_claimed"
const HIDDEN_CLAIMED_FLAG: String = "hidden_boss_echo_double_jump_claimed"
const REQUIRED_ANIMATIONS: Array[StringName] = [&"idle", &"run", &"attack", &"hurt", &"death"]
const MIN_ANIMATION_FRAMES: int = 3
const BOSS2_RUN_FRAME_PREFIX: String = "res://assets/characters/boss2_echo_guardian/run/"
const STATE_LOCKED: StringName = &"locked"
const STATE_UNLOCKABLE: StringName = &"unlockable"

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_boss2_echo_guardian_character_assets_follow_frame_animation_rules() -> void:
	assert_bool(FileAccess.file_exists(CHARACTER_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(CHARACTER_SCRIPT_PATH)).is_true()
	assert_bool(FileAccess.file_exists(SPRITE_FRAMES_PATH)).is_true()

	var packed: PackedScene = load(CHARACTER_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return
	var character: Node = packed.instantiate()
	add_child(character)
	_spawned_nodes.append(character)

	assert_bool(character is AnimatedSprite2D).is_true()
	var sprite := character as AnimatedSprite2D
	assert_that(sprite.sprite_frames).is_not_null()
	if sprite.sprite_frames == null:
		return
	assert_str(sprite.sprite_frames.resource_path).is_equal(SPRITE_FRAMES_PATH)
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		assert_bool(sprite.sprite_frames.has_animation(animation_name)).is_true()
		if not sprite.sprite_frames.has_animation(animation_name):
			continue
		assert_int(sprite.sprite_frames.get_frame_count(animation_name)).is_greater_equal(
			MIN_ANIMATION_FRAMES
		)
		assert_bool(_animation_frames_are_textured_and_same_size(
			sprite.sprite_frames,
			animation_name
		)).is_true()
	if not sprite.sprite_frames.has_animation(&"run"):
		return
	assert_bool(sprite.sprite_frames.get_animation_loop(&"run")).is_true()
	assert_float(sprite.sprite_frames.get_animation_speed(&"run")).is_greater(0.0)
	assert_bool(_animation_frames_use_sequential_paths(
		sprite.sprite_frames,
		&"run",
		BOSS2_RUN_FRAME_PREFIX,
		"boss2_echo_guardian_run"
	)).is_true()


func test_boss2_defeat_opens_double_jump_reward_and_syncs_gate_save_state() -> void:
	var scene: Node2D = _instantiate_main_scene()
	assert_that(scene).is_not_null()
	if scene == null:
		return

	assert_bool(scene.has_method("claim_boss2_double_jump_reward_source")).is_true()
	assert_bool(scene.has_method("get_boss2_double_jump_payoff_diagnostics")).is_true()
	var boss: Node = scene.get_node_or_null(BOSS_NODE_NAME)
	var source: Node = scene.get_node_or_null(REWARD_NODE_NAME)
	var player := scene.get_node("Player") as PlayerController
	var gate: Node = scene.get_node(DOUBLE_JUMP_GATE_NAME)
	assert_that(boss).is_not_null()
	assert_that(source).is_not_null()
	if boss == null or source == null:
		return

	assert_int(int(boss.call("get_entity_id"))).is_equal(BOSS2_ENTITY_ID)
	assert_bool(bool(source.call("is_claim_available"))).is_false()
	assert_bool(player.has_ability(DOUBLE_JUMP_ABILITY)).is_false()
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_LOCKED))

	assert_bool(scene.call("apply_damage", BOSS2_ENTITY_ID, int(boss.call("get_current_hp")), {
		"source": &"unit_test_boss2_defeat",
	})).is_true()
	await get_tree().process_frame

	var diagnostics: Dictionary = scene.call("get_boss2_double_jump_payoff_diagnostics")
	assert_bool(bool(diagnostics.get("boss_defeated", false))).is_true()
	assert_bool(bool(diagnostics.get("reward_available", false))).is_true()
	assert_bool(bool(source.call("is_claim_available"))).is_true()

	player.global_position = (source as Node2D).global_position
	assert_bool(bool(scene.call("claim_boss2_double_jump_reward_source", player))).is_true()
	assert_bool(bool(scene.call("claim_boss2_double_jump_reward_source", player))).is_false()
	assert_bool(player.has_ability(DOUBLE_JUMP_ABILITY)).is_true()
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKABLE))

	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var player_state: Dictionary = Dictionary(snapshot.get("player_state", {}))
	var world_state: Dictionary = Dictionary(snapshot.get("world_state", {}))
	assert_int(_ability_count(player_state, DOUBLE_JUMP_ABILITY)).is_equal(1)
	assert_bool(bool(Dictionary(world_state.get("world_flags", {})).get(CLAIMED_FLAG, false))).is_true()


func test_boss2_payoff_is_idempotent_with_hidden_double_jump_path_and_restore() -> void:
	var scene: Node2D = _instantiate_main_scene()
	assert_that(scene).is_not_null()
	if scene == null:
		return

	var hidden_source := scene.get_node("HiddenDoubleJumpRewardSource") as Node2D
	var player := scene.get_node("Player") as PlayerController
	player.global_position = hidden_source.global_position
	assert_bool(bool(scene.call("claim_hidden_double_jump_reward_source", player))).is_true()

	var boss: Node = scene.get_node_or_null(BOSS_NODE_NAME)
	var boss2_source: Node2D = scene.get_node_or_null(REWARD_NODE_NAME) as Node2D
	assert_that(boss).is_not_null()
	assert_that(boss2_source).is_not_null()
	if boss == null or boss2_source == null:
		return

	assert_bool(scene.call("apply_damage", BOSS2_ENTITY_ID, int(boss.call("get_current_hp")), {
		"source": &"unit_test_boss2_after_hidden_path",
	})).is_true()
	await get_tree().process_frame
	player.global_position = boss2_source.global_position
	assert_bool(bool(scene.call("claim_boss2_double_jump_reward_source", player))).is_true()

	var progress: Dictionary = scene.call("get_runtime_progress_state")
	assert_int(_ability_count(progress, DOUBLE_JUMP_ABILITY)).is_equal(1)
	var flags: Dictionary = Dictionary(progress.get("world_flags", {}))
	assert_bool(bool(flags.get(HIDDEN_CLAIMED_FLAG, false))).is_true()
	assert_bool(bool(flags.get(CLAIMED_FLAG, false))).is_true()

	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var restored_scene := MAIN_SCENE.instantiate() as Node2D
	add_child(restored_scene)
	_spawned_nodes.append(restored_scene)
	restored_scene.call("restore_save_snapshot", snapshot)

	var restored_source: Node = restored_scene.get_node_or_null(REWARD_NODE_NAME)
	var restored_player := restored_scene.get_node("Player") as PlayerController
	var restored_gate: Node = restored_scene.get_node(DOUBLE_JUMP_GATE_NAME)
	assert_that(restored_source).is_not_null()
	if restored_source != null:
		assert_bool(bool(restored_source.call("is_claimed"))).is_true()
		assert_bool(bool(restored_source.call("is_claim_available"))).is_false()
	assert_bool(restored_player.has_ability(DOUBLE_JUMP_ABILITY)).is_true()
	assert_str(String(restored_gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKABLE))
	restored_player.call("set_airborne", true)
	assert_bool(bool(restored_player.call("request_double_jump"))).is_true()


func _instantiate_main_scene() -> Node2D:
	var scene := MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	_spawned_nodes.append(scene)
	return scene


func _ability_count(progress: Dictionary, ability_id: StringName) -> int:
	var count: int = 0
	for ability_value: Variant in Array(progress.get("unlocked_abilities", [])):
		if String(ability_value) == String(ability_id):
			count += 1
	return count


func _animation_frames_are_textured_and_same_size(
	sprite_frames: SpriteFrames,
	animation_name: StringName
) -> bool:
	var expected_size := Vector2.ZERO
	for frame_index: int in range(sprite_frames.get_frame_count(animation_name)):
		var texture := sprite_frames.get_frame_texture(animation_name, frame_index)
		if texture == null:
			return false
		var texture_size := texture.get_size()
		if expected_size == Vector2.ZERO:
			expected_size = texture_size
		elif texture_size != expected_size:
			return false
	return true


func _animation_frames_use_sequential_paths(
	sprite_frames: SpriteFrames,
	animation_name: StringName,
	expected_prefix: String,
	expected_basename: String
) -> bool:
	for frame_index: int in range(sprite_frames.get_frame_count(animation_name)):
		var texture := sprite_frames.get_frame_texture(animation_name, frame_index)
		if texture == null:
			return false
		var expected_path := "%s%s_%03d.png" % [expected_prefix, expected_basename, frame_index]
		if texture.resource_path != expected_path:
			return false
		if not FileAccess.file_exists(expected_path):
			return false
	return true
