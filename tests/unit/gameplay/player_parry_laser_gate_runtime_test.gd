## Runtime parry ability and laser exploration gate contract.
extends GdUnitTestSuite

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const PARRY_ABILITY: StringName = &"parry"
const PARRY_ANIMATION: StringName = &"parry"
const REQUIRED_PARRY_FRAME_COUNT: int = 3
const PARRY_GATE_NODE_NAME: String = "ParryLaserExplorationGate"
const PARRY_GATE_ID: StringName = &"parry_laser_central_tower"
const TARGET_AREA_ID: StringName = &"area_05_central_tower"
const PARRY_LASER_GATE_TEXTURE_PATH: String = (
	"res://assets/environment/parry_laser_gate/parry_laser_gate_marker.png"
)
const REPLACED_RAT_KING_ELECTRIC_LEAK_PATH: String = (
	"res://assets/environment/rat_king_arena/electric_leak.png"
)
const STATE_UNLOCKABLE: StringName = &"unlockable"
const STATE_UNLOCKED: StringName = &"unlocked"

var player: PlayerController
var activated_ids: Array[StringName] = []


func before_test() -> void:
	player = PLAYER_SCENE.instantiate() as PlayerController
	add_child(player)
	activated_ids.clear()
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
	activated_ids.clear()


func test_parry_animation_frames_are_imported_through_character_asset_pipeline() -> void:
	var sprite := player.get_node("Sprite") as AnimatedSprite2D
	assert_bool(sprite.sprite_frames.has_animation(PARRY_ANIMATION)).is_true()
	if not sprite.sprite_frames.has_animation(PARRY_ANIMATION):
		return
	assert_int(sprite.sprite_frames.get_frame_count(PARRY_ANIMATION)).is_equal(
		REQUIRED_PARRY_FRAME_COUNT
	)
	assert_bool(_animation_frames_are_textured_and_same_size(
		sprite.sprite_frames,
		PARRY_ANIMATION
	)).is_true()

	for frame_index: int in range(REQUIRED_PARRY_FRAME_COUNT):
		var frame_path := "res://assets/characters/cinderpaw/parry/cinderpaw_parry_%03d.png" % frame_index
		assert_bool(FileAccess.file_exists(frame_path)).is_true()
		var texture := sprite.sprite_frames.get_frame_texture(PARRY_ANIMATION, frame_index)
		assert_that(texture).is_not_null()
		if texture == null:
			return
		assert_str(texture.resource_path).is_equal(frame_path)


func test_request_parry_uses_initial_ability_cooldown_and_combat_state() -> void:
	var sprite := player.get_node("Sprite") as AnimatedSprite2D
	assert_bool(player.has_method("request_parry")).is_true()
	assert_bool(player.has_method("has_ability")).is_true()
	assert_bool(player.has_method("is_ability_on_cooldown")).is_true()
	assert_bool(player.has_method("get_ability_cooldown_remaining")).is_true()
	if (
		not player.has_method("request_parry")
		or not player.has_method("has_ability")
		or not player.has_method("is_ability_on_cooldown")
		or not player.has_method("get_ability_cooldown_remaining")
	):
		return

	assert_bool(player.has_ability(PARRY_ABILITY)).is_true()
	assert_bool(player.call("request_parry")).is_true()
	assert_array(activated_ids).is_equal([PARRY_ABILITY])
	assert_str(String(sprite.animation)).is_equal(String(PARRY_ANIMATION))
	assert_bool(sprite.is_playing()).is_true()
	assert_bool(player.is_ability_on_cooldown(PARRY_ABILITY)).is_true()
	assert_float(player.get_ability_cooldown_remaining(PARRY_ABILITY)).is_equal_approx(
		0.3,
		0.001
	)

	var combat: CombatComponent = player.get_node_or_null("CombatComponent") as CombatComponent
	assert_that(combat).is_not_null()
	if combat != null:
		assert_int(combat.get_current_state()).is_equal(CombatComponent.CombatState.PARRYING)
	assert_bool(player.call("request_parry")).is_false()


func test_request_parry_rejects_blocked_combat_without_consuming_cooldown() -> void:
	var combat: CombatComponent = player.get_node_or_null("CombatComponent") as CombatComponent
	assert_that(combat).is_not_null()
	if combat == null:
		return
	combat.on_action_triggered(&"heavy_attack", {"pressed": true})
	assert_int(combat.get_current_state()).is_equal(CombatComponent.CombatState.CHARGING)

	assert_bool(player.call("request_parry")).is_false()
	assert_array(activated_ids).is_empty()
	assert_bool(player.is_ability_on_cooldown(PARRY_ABILITY)).is_false()
	assert_float(player.get_ability_cooldown_remaining(PARRY_ABILITY)).is_equal_approx(
		0.0,
		0.001
	)


func test_main_scene_parry_laser_gate_unlocks_when_parry_is_used_in_range() -> void:
	var scene := MAIN_SCENE.instantiate() as Node2D
	add_child(scene)

	var gate: Node = scene.get_node_or_null(PARRY_GATE_NODE_NAME)
	assert_that(gate).is_not_null()
	if gate == null:
		scene.queue_free()
		return
	assert_str(String(gate.call("get_gate_id"))).is_equal(String(PARRY_GATE_ID))
	assert_str(String(gate.call("get_required_ability"))).is_equal(String(PARRY_ABILITY))
	assert_str(String(gate.call("get_target_area_id"))).is_equal(String(TARGET_AREA_ID))
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKABLE))
	assert_bool(bool(gate.call("is_collision_blocking"))).is_true()

	var scene_player := scene.get_node("Player") as PlayerController
	scene_player.global_position = (gate as Node2D).global_position + Vector2(-48, 0)
	assert_bool(scene_player.call("request_parry")).is_true()
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKED))
	assert_bool(bool(gate.call("is_collision_blocking"))).is_false()

	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var world_state: Dictionary = Dictionary(snapshot.get("world_state", {}))
	var gate_state: Dictionary = Dictionary(world_state.get("exploration_gates", {}))
	assert_array(Array(gate_state.get("unlocked", []))).contains(String(PARRY_GATE_ID))
	var world_flags: Dictionary = Dictionary(world_state.get("world_flags", {}))
	assert_bool(bool(world_flags.get("gate_%s_unlocked" % String(PARRY_GATE_ID), false))).is_true()
	assert_bool(bool(world_flags.get("area_05_central_tower_unlocked", false))).is_true()

	var restored_scene := MAIN_SCENE.instantiate() as Node2D
	add_child(restored_scene)
	restored_scene.call("restore_save_snapshot", snapshot)
	var restored_gate: Node = restored_scene.get_node_or_null(PARRY_GATE_NODE_NAME)
	assert_that(restored_gate).is_not_null()
	if restored_gate != null:
		assert_str(String(restored_gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKED))
		assert_bool(bool(restored_gate.call("is_collision_blocking"))).is_false()

	scene.queue_free()
	restored_scene.queue_free()


func test_main_scene_parry_laser_gate_uses_authored_laser_visual_asset() -> void:
	var scene := MAIN_SCENE.instantiate() as Node2D
	add_child(scene)

	var gate: Node = scene.get_node_or_null(PARRY_GATE_NODE_NAME)
	assert_that(gate).is_not_null()
	if gate == null:
		scene.queue_free()
		return

	var visual := gate.get_node_or_null("Visual") as Sprite2D
	assert_that(visual).is_not_null()
	if visual == null:
		scene.queue_free()
		return

	assert_that(visual.texture).is_not_null()
	if visual.texture == null:
		scene.queue_free()
		return

	assert_str(visual.texture.resource_path).is_equal(PARRY_LASER_GATE_TEXTURE_PATH)
	assert_str(visual.texture.resource_path).is_not_equal(REPLACED_RAT_KING_ELECTRIC_LEAK_PATH)
	assert_bool(FileAccess.file_exists(PARRY_LASER_GATE_TEXTURE_PATH)).is_true()
	assert_bool(FileAccess.file_exists("%s.import" % PARRY_LASER_GATE_TEXTURE_PATH)).is_true()
	assert_vector(visual.texture.get_size()).is_equal(Vector2(256, 256))
	assert_float(visual.rotation).is_equal_approx(0.0, 0.001)

	scene.queue_free()


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
