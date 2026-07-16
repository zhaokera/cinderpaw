## Player Abilities Story148: Boss4 victory recall to Scrap Roost.
extends GdUnitTestSuite

const ARENA_SCENE_PATH: String = "res://scenes/bosses/crown_warden_arena.tscn"
const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"
const RECALL_TEXTURE_PATH: String = (
	"res://assets/environment/crown_warden_victory_recall/"
	+ "prop_crown_warden_victory_recall_256x384.png"
)
const RECALL_SOURCE_PATH: String = (
	"res://assets/environment/crown_warden_victory_recall/source/"
	+ "crown_warden_victory_recall_imagegen_20260713.png"
)
const RECALL_ALPHA_PATH: String = (
	"res://assets/environment/crown_warden_victory_recall/source/"
	+ "crown_warden_victory_recall_alpha_20260713.png"
)
const RECALL_PROMPT_PATH: String = (
	"res://assets/environment/crown_warden_victory_recall/source/"
	+ "crown_warden_victory_recall_imagegen_20260713.md"
)
const ARENA_SCENE_ID: StringName = &"boss_04_crown_warden_arena"
const MAIN_SCENE_ID: StringName = &"main"
const MAIN_SPAWN: StringName = &"scrap_roost"
const BOSS_ENTITY_ID: int = 2400
const BOSS_MAX_HP: int = 160
const DEFEATED_KEY: String = "boss_04_crown_warden_defeated"
const REWARD_KEY: String = "boss_04_wall_climb_reward_claimed"
const RECALL_KEY: String = "boss_04_victory_recall_requested"
const EPILOGUE_COMPLETED_KEY: String = (
	"crown_observatory_epilogue_ascent_completed"
)
const HUB_FLAG: String = "boss_04_victory_hub_return_secured"
const RAT_KING_DEFEATED_FLAG: String = "boss_rat_king_defeated"
const BOSS2_DEFEATED_FLAG: String = "boss_02_echo_guardian_defeated"
const BOSS2_REWARD_FLAG: String = "boss_02_double_jump_claimed"

var _spawned_nodes: Array[Node] = []


class RecallSceneManager:
	extends RefCounted

	signal on_scene_load_failed(scene_id: StringName, reason: StringName)
	signal on_scene_changed(old_scene: StringName, new_scene: StringName)
	signal on_scene_load_started(scene_id: StringName, spawn: StringName, metadata: Dictionary)

	var states: Dictionary = {
		String(ARENA_SCENE_ID): {"arena_sentinel": 1},
		String(MAIN_SCENE_ID): {"main_sentinel": 2},
	}
	var current_scene: StringName = ARENA_SCENE_ID
	var current_spawn: StringName = &"boss_entry"
	var locked: bool = false
	var loading: bool = false
	var accept_requests: bool = true
	var request_calls: Array[Dictionary] = []

	func request_scene_change(scene_id: StringName, spawn: StringName) -> bool:
		if locked or loading or not accept_requests:
			return false
		request_calls.append({"scene_id": String(scene_id), "spawn_point": String(spawn)})
		return true

	func has_scene(scene_id: StringName) -> bool:
		return scene_id in [ARENA_SCENE_ID, MAIN_SCENE_ID, &"area_05_central_tower"]

	func is_loading() -> bool:
		return loading

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

	func configure_runtime_scene_root(_root: Node, _current: Node = null) -> bool:
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


func test_reward_claim_reveals_generated_recall_and_requests_main_once() -> void:
	var arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(arena).is_not_null()
	if arena == null:
		return
	var player: Node2D = arena.get_node_or_null("Player") as Node2D
	var reward: Node2D = arena.get_node_or_null("WallClimbRewardSource") as Node2D
	var recall: Node2D = arena.get_node_or_null("CrownVictoryRecallRoute") as Node2D
	var endpoint: Node2D = arena.get_node_or_null(
		"CrownObservatoryEpilogueAscent/AscentEndpoint"
	) as Node2D
	assert_that(recall).override_failure_message(
		"Story148 must author CrownVictoryRecallRoute"
	).is_not_null()
	assert_bool(arena.has_method("try_request_victory_recall")).is_true()
	assert_bool(arena.has_method("get_victory_recall_diagnostics")).is_true()
	if player == null or reward == null or recall == null or endpoint == null:
		return
	assert_bool(recall.visible).is_false()
	assert_bool(bool(recall.call("is_route_available"))).is_false()

	var manager := RecallSceneManager.new()
	assert_bool(bool(arena.call("configure_scene_manager_runtime", manager))).is_true()
	assert_bool(bool(arena.call(
		"apply_damage", BOSS_ENTITY_ID, BOSS_MAX_HP, {"source": &"story148"}
	))).is_true()
	assert_bool(bool(arena.call(
		"advance_boss4_death_presentation", 2.0
	))).is_true()
	player.global_position = reward.global_position
	assert_bool(bool(arena.call("claim_wall_climb_reward_source", player))).is_true()
	assert_bool(recall.visible).is_false()
	assert_bool(bool(recall.call("is_route_available"))).is_false()
	assert_bool(bool(arena.call("try_request_victory_recall", player))).is_false()

	arena.call("advance_wall_climb_reward_feedback", 1.51)
	player.global_position = Vector2(1220, 480)
	assert_bool(bool(player.call(
		"request_wall_climb", Vector2(-1, 0), -1.0, true
	))).is_true()
	player.global_position = endpoint.global_position
	assert_bool(bool(arena.call(
		"try_complete_crown_observatory_epilogue_ascent", player
	))).is_true()
	assert_bool(recall.visible).is_true()
	assert_bool(bool(recall.call("is_route_available"))).is_true()
	player.global_position = reward.global_position
	assert_bool(bool(arena.call("try_request_victory_recall", player))).is_false()
	player.global_position = recall.global_position
	assert_bool(bool(arena.call("try_request_victory_recall", player))).is_true()
	assert_bool(bool(arena.call("try_request_victory_recall", player))).is_false()
	assert_int(manager.request_calls.size()).is_equal(1)
	assert_str(String(manager.request_calls[0].get("scene_id", ""))).is_equal(
		String(MAIN_SCENE_ID)
	)
	assert_str(String(manager.request_calls[0].get("spawn_point", ""))).is_equal(
		String(MAIN_SPAWN)
	)
	var persisted: Dictionary = manager.get_scene_state(ARENA_SCENE_ID)
	assert_bool(bool(persisted.get(RECALL_KEY, false))).is_true()
	assert_bool(bool(persisted.get(DEFEATED_KEY, false))).is_true()
	assert_bool(bool(persisted.get(REWARD_KEY, false))).is_true()
	assert_bool(bool(persisted.get(EPILOGUE_COMPLETED_KEY, false))).is_true()
	assert_int(int(manager.get_scene_state(MAIN_SCENE_ID).get(
		"main_sentinel", 0
	))).is_equal(2)

	var rejected_arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	var rejected_player: Node2D = rejected_arena.get_node_or_null("Player") as Node2D
	var rejected_recall: Node2D = rejected_arena.get_node_or_null(
		"CrownVictoryRecallRoute"
	) as Node2D
	var rejected_manager := RecallSceneManager.new()
	rejected_manager.accept_requests = false
	rejected_arena.call("configure_scene_manager_runtime", rejected_manager)
	rejected_arena.call("set_local_state", {
		DEFEATED_KEY: true,
		REWARD_KEY: true,
		"unlocked_abilities": ["wall_climb"],
	})
	rejected_player.global_position = rejected_recall.global_position
	assert_bool(bool(rejected_arena.call(
		"try_request_victory_recall", rejected_player
	))).is_false()
	assert_bool(bool(rejected_manager.get_scene_state(ARENA_SCENE_ID).get(
		RECALL_KEY, false
	))).is_false()


func test_recall_restore_preserves_proof_without_transient_replay() -> void:
	var arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(arena).is_not_null()
	if arena == null:
		return
	assert_bool(arena.has_method("get_victory_recall_diagnostics")).is_true()
	if not arena.has_method("get_victory_recall_diagnostics"):
		return
	arena.call("set_local_state", {
		DEFEATED_KEY: true,
		REWARD_KEY: true,
		RECALL_KEY: true,
		"unlocked_abilities": [
			"basic_attack", "jump", "dodge", "parry", "wall_climb",
		],
	})
	var diagnostics: Dictionary = arena.call("get_victory_recall_diagnostics")
	assert_bool(bool(diagnostics.get("recall_proof_persisted", false))).is_true()
	assert_bool(bool(diagnostics.get("recall_route_available", false))).is_true()
	assert_bool(bool(diagnostics.get("transition_requested", true))).is_false()
	assert_bool(bool(diagnostics.get("reward_feedback_active", true))).is_false()
	assert_bool(bool(diagnostics.get("player_control_locked", true))).is_false()
	assert_array(Array(diagnostics.get("unlocked_abilities", []))).contains([
		"wall_climb",
	])


func test_main_arrival_secures_existing_scrap_roost_and_asset_contract() -> void:
	for path: String in [
		RECALL_TEXTURE_PATH,
		RECALL_SOURCE_PATH,
		RECALL_ALPHA_PATH,
		RECALL_PROMPT_PATH,
	]:
		assert_bool(FileAccess.file_exists(path)).override_failure_message(
			"Story148 recall artifact missing: %s" % path
		).is_true()
	if FileAccess.file_exists(RECALL_TEXTURE_PATH):
		var image: Image = Image.load_from_file(
			ProjectSettings.globalize_path(RECALL_TEXTURE_PATH)
		)
		assert_that(image).is_not_null()
		if image != null:
			assert_vector(Vector2(image.get_size())).is_equal(Vector2(256, 384))
			assert_bool(image.detect_alpha() != Image.ALPHA_NONE).is_true()
			assert_int(image.get_pixel(0, 0).a8).is_equal(0)

	var main: Node = _instantiate_scene(MAIN_SCENE_PATH)
	assert_that(main).is_not_null()
	if main == null:
		return
	assert_bool(main.has_method("get_crown_warden_victory_return_diagnostics")).is_true()
	if not main.has_method("get_crown_warden_victory_return_diagnostics"):
		return
	var manager := RecallSceneManager.new()
	manager.current_scene = MAIN_SCENE_ID
	manager.current_spawn = MAIN_SPAWN
	manager.states[String(ARENA_SCENE_ID)] = {
		DEFEATED_KEY: true,
		REWARD_KEY: true,
		RECALL_KEY: true,
	}
	main.call("set_local_state", {
		"unlocked_abilities": [
			"basic_attack", "jump", "dodge", "dash", "double_jump",
			"aerial_attack", "parry", "wall_climb",
		],
		"world_flags": {
			RAT_KING_DEFEATED_FLAG: true,
			BOSS2_DEFEATED_FLAG: true,
			BOSS2_REWARD_FLAG: true,
		},
	})
	assert_bool(bool(main.call("configure_scene_manager_runtime", manager))).is_true()
	var diagnostics: Dictionary = main.call(
		"get_crown_warden_victory_return_diagnostics"
	)
	assert_bool(bool(diagnostics.get("secured", false))).is_true()
	assert_bool(bool(diagnostics.get("valid_recall_proof", false))).is_true()
	assert_str(String(diagnostics.get("current_scene", ""))).is_equal("main")
	assert_str(String(diagnostics.get("current_spawn_point", ""))).is_equal(
		"scrap_roost"
	)
	assert_str(String(Dictionary(diagnostics.get("last_savepoint", {})).get(
		"id", ""
	))).is_equal("scrap_roost")
	assert_str(String(diagnostics.get("hud_notification_text", ""))).contains(
		"Crown secured"
	)
	assert_float(float(diagnostics.get(
		"player_savepoint_distance", 999.0
	))).is_less_equal(1.0)
	var local_state: Dictionary = main.call("get_local_state")
	var world_flags: Dictionary = Dictionary(local_state.get("world_flags", {}))
	assert_bool(bool(world_flags.get(HUB_FLAG, false))).is_true()
	var rat_king := main.get_node("Enemy") as CollisionObject2D
	var echo_guardian := main.get_node("Boss2EchoGuardian") as CollisionObject2D
	var boss_hud := main.get_node("HUD/HudRoot/BossHudPanel") as Control
	assert_bool(rat_king.visible).override_failure_message(
		"Returning after Boss4 must not respawn the defeated Rat King"
	).is_false()
	assert_int(rat_king.collision_layer).is_equal(0)
	assert_int(rat_king.collision_mask).is_equal(0)
	assert_bool(echo_guardian.visible).is_false()
	assert_bool(boss_hud.visible).override_failure_message(
		"Scrap Roost arrival must not show a defeated boss HUD"
	).is_false()


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
