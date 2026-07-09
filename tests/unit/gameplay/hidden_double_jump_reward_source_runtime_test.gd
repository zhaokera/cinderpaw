## Runtime hidden-boss echo reward source for Double Jump.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const DOUBLE_JUMP_ABILITY: StringName = &"double_jump"
const REWARD_NODE_NAME: String = "HiddenDoubleJumpRewardSource"
const REWARD_ID: StringName = &"hidden_boss_echo_double_jump"
const CLAIMED_FLAG: String = "hidden_boss_echo_double_jump_claimed"
const REWARD_TEXTURE_PATH: String = "res://assets/environment/double_jump_reward/hidden_double_jump_reward_source.png"
const STATE_LOCKED: StringName = &"locked"
const STATE_UNLOCKABLE: StringName = &"unlockable"

var scene: Node2D


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_hidden_double_jump_reward_source_unlocks_double_jump_once_and_syncs_runtime() -> void:
	var source: Node = _get_reward_source(scene)
	assert_that(source).is_not_null()
	if source == null:
		return
	assert_str(String(source.call("get_reward_id"))).is_equal(String(REWARD_ID))
	assert_str(String(source.call("get_ability_id"))).is_equal(String(DOUBLE_JUMP_ABILITY))
	assert_str(String(source.call("get_visual_texture_path"))).is_equal(REWARD_TEXTURE_PATH)
	assert_bool(FileAccess.file_exists(REWARD_TEXTURE_PATH)).is_true()
	assert_bool(bool(source.call("is_claimed"))).is_false()
	assert_bool(bool(source.call("is_claim_available"))).is_true()
	assert_bool(bool(source.call("is_prompt_visible"))).is_false()

	var player := scene.get_node("Player") as PlayerController
	var gate: Node = scene.get_node("DoubleJumpExplorationGate")
	var hud: Node = scene.get_node("HUD")
	assert_bool(player.has_ability(DOUBLE_JUMP_ABILITY)).is_false()
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_LOCKED))
	assert_bool(bool(gate.call("is_collision_blocking"))).is_true()

	player.global_position = (source as Node2D).global_position + Vector2(150, 0)
	await get_tree().process_frame
	assert_bool(bool(source.call("is_provider_in_reward_range", player))).is_false()
	assert_bool(bool(source.call("is_prompt_visible"))).is_true()

	player.global_position = (source as Node2D).global_position
	assert_bool(bool(source.call("is_provider_in_reward_range", player))).is_true()
	assert_bool(bool(scene.call("claim_hidden_double_jump_reward_source"))).is_true()

	var progress: Dictionary = scene.call("get_runtime_progress_state")
	assert_int(_ability_count(progress, DOUBLE_JUMP_ABILITY)).is_equal(1)
	assert_bool(player.has_ability(DOUBLE_JUMP_ABILITY)).is_true()
	assert_str(String(gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKABLE))
	assert_bool(bool(gate.call("is_collision_blocking"))).is_true()
	assert_bool(bool(source.call("is_claimed"))).is_true()
	assert_bool(bool(source.call("is_claim_available"))).is_false()
	assert_bool(String(hud.call("get_notification_text")).contains("Double Jump")).is_true()

	assert_bool(bool(scene.call("claim_hidden_double_jump_reward_source"))).is_false()
	var repeated_progress: Dictionary = scene.call("get_runtime_progress_state")
	assert_int(_ability_count(repeated_progress, DOUBLE_JUMP_ABILITY)).is_equal(1)

	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var player_state: Dictionary = Dictionary(snapshot.get("player_state", {}))
	var world_state: Dictionary = Dictionary(snapshot.get("world_state", {}))
	assert_int(_ability_count(player_state, DOUBLE_JUMP_ABILITY)).is_equal(1)
	assert_bool(bool(Dictionary(world_state.get("world_flags", {})).get(CLAIMED_FLAG, false))).is_true()


func test_hidden_double_jump_reward_source_restore_keeps_reward_claimed_and_playable() -> void:
	var source: Node = _get_reward_source(scene)
	assert_that(source).is_not_null()
	if source == null:
		return
	var player := scene.get_node("Player") as PlayerController
	player.global_position = (source as Node2D).global_position
	assert_bool(bool(scene.call("claim_hidden_double_jump_reward_source"))).is_true()

	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var restored_scene := MAIN_SCENE.instantiate() as Node2D
	add_child(restored_scene)
	restored_scene.call("restore_save_snapshot", snapshot)

	var restored_source: Node = _get_reward_source(restored_scene)
	var restored_player := restored_scene.get_node("Player") as PlayerController
	var restored_gate: Node = restored_scene.get_node("DoubleJumpExplorationGate")
	assert_that(restored_source).is_not_null()
	if restored_source != null:
		assert_bool(bool(restored_source.call("is_claimed"))).is_true()
		assert_bool(bool(restored_source.call("is_claim_available"))).is_false()
		assert_bool(bool(restored_source.call("is_prompt_visible"))).is_false()
	assert_bool(restored_player.has_ability(DOUBLE_JUMP_ABILITY)).is_true()
	assert_str(String(restored_gate.call("get_gate_state"))).is_equal(String(STATE_UNLOCKABLE))

	restored_player.call("set_airborne", true)
	assert_bool(bool(restored_player.call("request_double_jump"))).is_true()
	restored_scene.queue_free()


func _get_reward_source(target_scene: Node) -> Node:
	return target_scene.get_node_or_null(REWARD_NODE_NAME)


func _ability_count(progress: Dictionary, ability_id: StringName) -> int:
	var count: int = 0
	for ability_value: Variant in Array(progress.get("unlocked_abilities", [])):
		if String(ability_value) == String(ability_id):
			count += 1
	return count
