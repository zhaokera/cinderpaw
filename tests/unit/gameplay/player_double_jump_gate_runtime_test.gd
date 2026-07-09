## Runtime double-jump ability and high-platform gate contract.
extends GdUnitTestSuite

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const DOUBLE_JUMP_ABILITY: StringName = &"double_jump"
const JUMP_ANIMATION: StringName = &"jump"
const REQUIRED_JUMP_FRAME_COUNT: int = 3
const HIGH_PLATFORM_GATE_ID: StringName = &"double_jump_high_platform"
const TARGET_AREA_ID: StringName = &"area_03_factory"
const STATE_LOCKED: StringName = &"locked"
const STATE_UNLOCKABLE: StringName = &"unlockable"
const STATE_UNLOCKED: StringName = &"unlocked"

var player: PlayerController
var received_double_jump_texture: Texture2D = null
var received_double_jump_position: Vector2 = Vector2.ZERO
var received_double_jump_facing: float = 0.0
var activated_ids: Array[StringName] = []


func before_test() -> void:
	player = PLAYER_SCENE.instantiate() as PlayerController
	add_child(player)
	received_double_jump_texture = null
	received_double_jump_position = Vector2.ZERO
	received_double_jump_facing = 0.0
	activated_ids.clear()
	if player.has_signal("double_jump_started"):
		player.double_jump_started.connect(func(texture: Texture2D, world_position: Vector2, facing: float) -> void:
			received_double_jump_texture = texture
			received_double_jump_position = world_position
			received_double_jump_facing = facing
		)
	if player.has_signal("ability_activated"):
		player.ability_activated.connect(func(ability_id: StringName) -> void:
			activated_ids.append(ability_id)
		)


func after_test() -> void:
	if is_instance_valid(player):
		if player.get_parent() != null:
			player.get_parent().remove_child(player)
		player.free()
	player = null
	received_double_jump_texture = null
	received_double_jump_position = Vector2.ZERO
	received_double_jump_facing = 0.0
	activated_ids.clear()


func test_double_jump_reuses_imported_jump_frames_for_runtime_activation() -> void:
	var sprite := player.get_node("Sprite") as AnimatedSprite2D
	assert_bool(sprite.sprite_frames.has_animation(JUMP_ANIMATION)).is_true()
	assert_int(sprite.sprite_frames.get_frame_count(JUMP_ANIMATION)).is_equal(
		REQUIRED_JUMP_FRAME_COUNT
	)
	for frame_index: int in range(REQUIRED_JUMP_FRAME_COUNT):
		var frame_path := "res://assets/characters/cinderpaw/jump/cinderpaw_jump_%03d.png" % frame_index
		assert_bool(FileAccess.file_exists(frame_path)).is_true()
		var texture := sprite.sprite_frames.get_frame_texture(JUMP_ANIMATION, frame_index)
		assert_that(texture).is_not_null()
		if texture == null:
			return
		assert_str(texture.resource_path).is_equal(frame_path)


func test_request_double_jump_requires_airborne_unlock_and_resets_after_landing() -> void:
	assert_bool(player.has_signal("double_jump_started")).is_true()
	assert_bool(player.has_method("request_double_jump")).is_true()
	assert_bool(player.has_method("set_airborne")).is_true()
	assert_bool(player.has_method("reset_air_abilities")).is_true()
	if (
		not player.has_signal("double_jump_started")
		or not player.has_method("request_double_jump")
		or not player.has_method("set_airborne")
		or not player.has_method("reset_air_abilities")
	):
		return

	assert_bool(player.has_ability(DOUBLE_JUMP_ABILITY)).is_false()
	assert_bool(player.call("request_double_jump")).is_false()
	assert_bool(player.unlock_ability(DOUBLE_JUMP_ABILITY)).is_true()
	assert_bool(player.has_ability(DOUBLE_JUMP_ABILITY)).is_true()
	assert_bool(player.call("request_double_jump")).is_false()

	player.call("set_airborne", true)
	assert_bool(player.call("request_double_jump")).is_true()
	assert_array(activated_ids).is_equal([DOUBLE_JUMP_ABILITY])
	assert_float(player.velocity.y).is_less(0.0)
	assert_bool(received_double_jump_texture is Texture2D).is_true()
	assert_vector(received_double_jump_position).is_equal((player.get_node("Sprite") as AnimatedSprite2D).global_position)
	assert_float(received_double_jump_facing).is_equal_approx(1.0, 0.001)
	assert_str(String((player.get_node("Sprite") as AnimatedSprite2D).animation)).is_equal(String(JUMP_ANIMATION))
	assert_bool(player.is_ability_on_cooldown(DOUBLE_JUMP_ABILITY)).is_true()
	assert_bool(player.call("request_double_jump")).is_false()

	player.call("reset_air_abilities")
	player.call("set_airborne", true)
	assert_bool(player.call("request_double_jump")).is_true()


func test_main_scene_double_jump_high_platform_gate_unlocks_and_persists() -> void:
	var scene := MAIN_SCENE.instantiate() as Node2D
	add_child(scene)

	var gate: Node = scene.get_node_or_null("DoubleJumpExplorationGate")
	assert_that(gate).is_not_null()
	if gate == null:
		scene.queue_free()
		return
	assert_str(String(gate.call("get_gate_id"))).is_equal(String(HIGH_PLATFORM_GATE_ID))
	assert_str(String(gate.call("get_required_ability"))).is_equal(String(DOUBLE_JUMP_ABILITY))
	assert_str(String(gate.call("get_target_area_id"))).is_equal(String(TARGET_AREA_ID))
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_LOCKED))
	assert_bool(bool(gate.call("is_collision_blocking"))).is_true()
	assert_bool(bool(gate.call("is_prompt_visible"))).is_false()

	scene.call("unlock_ability", DOUBLE_JUMP_ABILITY)
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKABLE))
	assert_bool(bool(gate.call("is_collision_blocking"))).is_true()
	assert_bool(bool(gate.call("is_prompt_visible"))).is_false()

	var scene_player := scene.get_node("Player") as PlayerController
	scene_player.global_position = (gate as Node2D).global_position + Vector2(-160, 0)
	gate.call("refresh_gate_state")
	assert_bool(bool(gate.call("is_provider_in_unlock_range"))).is_false()
	assert_bool(bool(gate.call("is_prompt_visible"))).is_true()

	scene_player.global_position = (gate as Node2D).global_position + Vector2(-48, 0)
	scene_player.call("set_airborne", true)
	assert_bool(scene_player.call("request_double_jump")).is_true()
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKED))
	assert_bool(bool(gate.call("is_collision_blocking"))).is_false()

	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var world_state: Dictionary = Dictionary(snapshot.get("world_state", {}))
	var gate_state: Dictionary = Dictionary(world_state.get("exploration_gates", {}))
	assert_array(Array(gate_state.get("unlocked", []))).contains(String(HIGH_PLATFORM_GATE_ID))
	var world_flags: Dictionary = Dictionary(world_state.get("world_flags", {}))
	assert_bool(bool(world_flags.get("gate_%s_unlocked" % String(HIGH_PLATFORM_GATE_ID), false))).is_true()
	assert_bool(bool(world_flags.get("area_03_factory_unlocked", false))).is_true()

	var restored_scene := MAIN_SCENE.instantiate() as Node2D
	add_child(restored_scene)
	restored_scene.call("restore_save_snapshot", snapshot)
	var restored_gate: Node = restored_scene.get_node_or_null("DoubleJumpExplorationGate")
	assert_that(restored_gate).is_not_null()
	if restored_gate != null:
		assert_str(String(restored_gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKED))
		assert_bool(bool(restored_gate.call("is_collision_blocking"))).is_false()

	scene.queue_free()
	restored_scene.queue_free()
