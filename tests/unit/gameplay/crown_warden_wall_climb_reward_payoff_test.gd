## Player Abilities Story147: Crown Warden wall-climb reward payoff.
extends GdUnitTestSuite

const ARENA_SCENE_PATH: String = "res://scenes/bosses/crown_warden_arena.tscn"
const REWARD_SCRIPT_PATH: String = "res://src/feature/ability_reward_source.gd"
const REWARD_TEXTURE_PATH: String = (
	"res://assets/environment/crown_warden_reward/"
	+ "prop_crown_warden_wall_climb_core_256x256.png"
)
const REWARD_SOURCE_PATH: String = (
	"res://assets/environment/crown_warden_reward/source/"
	+ "crown_warden_wall_climb_core_imagegen_20260713.png"
)
const REWARD_ALPHA_PATH: String = (
	"res://assets/environment/crown_warden_reward/source/"
	+ "crown_warden_wall_climb_core_alpha_20260713.png"
)
const REWARD_PROMPT_PATH: String = (
	"res://assets/environment/crown_warden_reward/source/"
	+ "crown_warden_wall_climb_core_imagegen_20260713.md"
)
const BOSS_ENTITY_ID: int = 2400
const BOSS_MAX_HP: int = 160
const WALL_CLIMB: StringName = &"wall_climb"
const DEFEATED_KEY: String = "boss_04_crown_warden_defeated"
const REWARD_CLAIMED_KEY: String = "boss_04_wall_climb_reward_claimed"
const ARENA_SCENE_ID: StringName = &"boss_04_crown_warden_arena"
const TOWER_SCENE_ID: StringName = &"area_05_central_tower"
const MAIN_SCENE_ID: StringName = &"main"

var _spawned_nodes: Array[Node] = []


class RewardSceneManager:
	extends RefCounted

	signal on_scene_load_failed(scene_id: StringName, reason: StringName)

	var states: Dictionary = {
		String(ARENA_SCENE_ID): {"arena_sentinel": 1},
		String(TOWER_SCENE_ID): {"tower_sentinel": 2},
		String(MAIN_SCENE_ID): {"main_sentinel": 3},
	}
	var locked: bool = false
	var current_scene: StringName = ARENA_SCENE_ID
	var current_spawn: StringName = &"boss_entry"

	func request_scene_change(_scene_id: StringName, _spawn: StringName) -> bool:
		return not locked

	func has_scene(_scene_id: StringName) -> bool:
		return true

	func is_loading() -> bool:
		return false

	func is_scene_locked() -> bool:
		return locked

	func lock_scene() -> void:
		locked = true

	func unlock_scene() -> void:
		locked = false

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn

	func get_scene_state(scene_id: StringName) -> Dictionary:
		return Dictionary(states.get(String(scene_id), {})).duplicate(true)

	func set_scene_state(scene_id: StringName, state: Dictionary) -> bool:
		states[String(scene_id)] = state.duplicate(true)
		return true


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_defeat_reveals_generated_reward_and_claim_unlocks_once() -> void:
	var arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(arena).is_not_null()
	if arena == null:
		return
	var player: Node = arena.get_node_or_null("Player")
	var source: Node = arena.get_node_or_null("WallClimbRewardSource")
	assert_that(player).is_not_null()
	assert_that(source).override_failure_message(
		"Story147 must author WallClimbRewardSource"
	).is_not_null()
	assert_bool(arena.has_method("claim_wall_climb_reward_source")).is_true()
	assert_bool(arena.has_method("get_wall_climb_reward_diagnostics")).is_true()
	if player == null or source == null:
		return
	assert_bool(source.visible).is_false()
	assert_bool(bool(source.call("is_claim_available"))).is_false()
	assert_bool(bool(player.call("has_ability", WALL_CLIMB))).is_false()

	var unlock_events: Array[StringName] = []
	player.ability_unlocked.connect(func(ability_id: StringName) -> void:
		unlock_events.append(ability_id)
	)
	assert_bool(bool(arena.call(
		"apply_damage",
		BOSS_ENTITY_ID,
		BOSS_MAX_HP,
		{"source": &"story147_reward_test"}
	))).is_true()
	var revealed: Dictionary = arena.call("get_wall_climb_reward_diagnostics")
	assert_bool(bool(revealed.get("reward_visible", false))).is_true()
	assert_bool(bool(revealed.get("reward_available", false))).is_true()
	assert_int(int(revealed.get("reveal_vfx_spawn_count", 0))).is_equal(1)

	player.set("global_position", source.get("global_position"))
	assert_bool(bool(arena.call("claim_wall_climb_reward_source", player))).is_true()
	assert_bool(bool(arena.call("claim_wall_climb_reward_source", player))).is_false()
	assert_bool(bool(player.call("has_ability", WALL_CLIMB))).is_true()
	assert_array(unlock_events).contains_exactly([WALL_CLIMB])
	var claimed: Dictionary = arena.call("get_wall_climb_reward_diagnostics")
	assert_bool(bool(claimed.get("reward_claimed", false))).is_true()
	assert_bool(bool(claimed.get("feedback_active", false))).is_true()
	assert_float(float(claimed.get("feedback_remaining_sec", 0.0))).is_equal_approx(1.5, 0.001)
	assert_str(String(claimed.get("hud_notification", ""))).contains("Wall Climb Unlocked")
	assert_str(String(claimed.get("objective_text", ""))).contains("Wall Climb Unlocked")

	arena.call("advance_wall_climb_reward_feedback", 1.51)
	var completed: Dictionary = arena.call("get_wall_climb_reward_diagnostics")
	assert_bool(bool(completed.get("feedback_active", true))).is_false()
	assert_str(String(completed.get("objective_text", ""))).is_equal(
		"Choose Scrap Roost Recall or Apex Return"
	)


func test_alternate_path_claim_is_safe_and_persists_without_replay() -> void:
	var arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(arena).is_not_null()
	if arena == null:
		return
	var player: Node = arena.get_node_or_null("Player")
	var source: Node = arena.get_node_or_null("WallClimbRewardSource")
	if player == null or source == null or not arena.has_method(
		"claim_wall_climb_reward_source"
	):
		assert_that(source).is_not_null()
		return
	player.call("set_unlocked_abilities", [
		"basic_attack", "jump", "dodge", "parry", "wall_climb",
	])
	var unlock_events: Array[StringName] = []
	player.ability_unlocked.connect(func(ability_id: StringName) -> void:
		unlock_events.append(ability_id)
	)
	assert_bool(bool(arena.call("apply_damage", BOSS_ENTITY_ID, BOSS_MAX_HP, {}))).is_true()
	player.set("global_position", source.get("global_position"))
	assert_bool(bool(arena.call("claim_wall_climb_reward_source", player))).is_true()
	assert_array(unlock_events).is_empty()
	var alternate: Dictionary = arena.call("get_wall_climb_reward_diagnostics")
	assert_bool(bool(alternate.get("ability_was_already_unlocked", false))).is_true()
	assert_str(String(alternate.get("hud_notification", ""))).contains(
		"Path Confirmed"
	)

	var local_state: Dictionary = arena.call("get_local_state")
	assert_bool(bool(local_state.get(DEFEATED_KEY, false))).is_true()
	assert_bool(bool(local_state.get(REWARD_CLAIMED_KEY, false))).is_true()
	assert_array(Array(local_state.get("unlocked_abilities", []))).contains([
		String(WALL_CLIMB)
	])
	var restored: Node = _instantiate_scene(ARENA_SCENE_PATH)
	restored.call("set_local_state", local_state)
	var restored_player: Node = restored.get_node_or_null("Player")
	var restored_source: Node = restored.get_node_or_null("WallClimbRewardSource")
	assert_bool(bool(restored_player.call("has_ability", WALL_CLIMB))).is_true()
	assert_bool(bool(restored_source.call("is_claimed"))).is_true()
	var restored_diagnostics: Dictionary = restored.call(
		"get_wall_climb_reward_diagnostics"
	)
	assert_bool(bool(restored_diagnostics.get("feedback_active", true))).is_false()
	assert_int(int(restored_diagnostics.get("feedback_count", -1))).is_equal(0)
	assert_int(int(restored_diagnostics.get("reveal_vfx_spawn_count", -1))).is_equal(0)
	assert_str(String(restored_diagnostics.get("hud_notification", "stale"))).is_empty()


func test_reward_asset_and_scene_manager_handoff_contract() -> void:
	for path: String in [
		REWARD_SCRIPT_PATH,
		REWARD_TEXTURE_PATH,
		REWARD_SOURCE_PATH,
		REWARD_ALPHA_PATH,
		REWARD_PROMPT_PATH,
	]:
		assert_bool(FileAccess.file_exists(path)).override_failure_message(
			"Story147 reward artifact missing: %s" % path
		).is_true()
	if FileAccess.file_exists(REWARD_TEXTURE_PATH):
		var image: Image = Image.load_from_file(
			ProjectSettings.globalize_path(REWARD_TEXTURE_PATH)
		)
		assert_that(image).is_not_null()
		if image != null:
			assert_vector(Vector2(image.get_size())).is_equal(Vector2(256, 256))
			assert_bool(image.detect_alpha() != Image.ALPHA_NONE).is_true()
			assert_int(image.get_pixel(0, 0).a8).is_equal(0)

	var arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(arena).is_not_null()
	if arena == null:
		return
	var player: Node = arena.get_node_or_null("Player")
	var source: Node = arena.get_node_or_null("WallClimbRewardSource")
	if player == null or source == null or not arena.has_method(
		"claim_wall_climb_reward_source"
	):
		assert_that(source).is_not_null()
		return
	var scene_manager := RewardSceneManager.new()
	assert_bool(bool(arena.call("configure_scene_manager_runtime", scene_manager))).is_true()
	assert_bool(bool(arena.call("apply_damage", BOSS_ENTITY_ID, BOSS_MAX_HP, {}))).is_true()
	player.set("global_position", source.get("global_position"))
	assert_bool(bool(arena.call("claim_wall_climb_reward_source", player))).is_true()
	for target_id: StringName in [ARENA_SCENE_ID, TOWER_SCENE_ID, MAIN_SCENE_ID]:
		var state: Dictionary = scene_manager.get_scene_state(target_id)
		assert_array(Array(state.get("unlocked_abilities", []))).contains([
			String(WALL_CLIMB)
		])
	assert_int(int(scene_manager.get_scene_state(TOWER_SCENE_ID).get(
		"tower_sentinel", 0
	))).is_equal(2)
	assert_int(int(scene_manager.get_scene_state(MAIN_SCENE_ID).get(
		"main_sentinel", 0
	))).is_equal(3)


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
