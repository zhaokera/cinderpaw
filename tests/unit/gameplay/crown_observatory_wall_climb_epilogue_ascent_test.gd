## Player Abilities Story172: Crown Observatory wall-climb epilogue ascent.
extends GdUnitTestSuite

const ARENA_SCENE_PATH: String = "res://scenes/bosses/crown_warden_arena.tscn"
const CONTROLLER_SCRIPT_PATH: String = (
	"res://src/gameplay/crown_observatory_epilogue_ascent_controller.gd"
)
const BACKGROUND_PATH: String = (
	"res://assets/environment/crown_warden_arena/"
	+ "env_crown_observatory_epilogue_ascent_1280x720.png"
)
const SOURCE_PATH: String = (
	"res://assets/generated/source/"
	+ "crown_observatory_epilogue_ascent_imagegen_20260717.png"
)
const PROMPT_PATH: String = (
	"res://assets/generated/source/"
	+ "crown_observatory_epilogue_ascent_imagegen_20260717.md"
)
const DEFEATED_KEY: String = "boss_04_crown_warden_defeated"
const REWARD_KEY: String = "boss_04_wall_climb_reward_claimed"
const RECALL_KEY: String = "boss_04_victory_recall_requested"
const CHECKPOINT_KEY: String = "crown_observatory_epilogue_checkpoint_activated"
const COMPLETED_KEY: String = "crown_observatory_epilogue_ascent_completed"

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


func test_real_wall_climb_ascent_checkpoints_completion_and_recall() -> void:
	for path: String in [CONTROLLER_SCRIPT_PATH, BACKGROUND_PATH, SOURCE_PATH, PROMPT_PATH]:
		assert_bool(FileAccess.file_exists(path)).override_failure_message(
			"Story172 artifact missing: %s" % path
		).is_true()
	if not FileAccess.file_exists(CONTROLLER_SCRIPT_PATH):
		return
	if FileAccess.file_exists(BACKGROUND_PATH):
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(BACKGROUND_PATH))
		assert_that(image).is_not_null()
		if image != null:
			assert_vector(Vector2(image.get_size())).is_equal(Vector2(1280, 720))

	var arena: Node = _instantiate_scene(ARENA_SCENE_PATH)
	assert_that(arena).is_not_null()
	if arena == null:
		return
	for node_path: String in [
		"CrownObservatoryEpilogueAscent",
		"CrownObservatoryEpilogueAscent/Background",
		"CrownObservatoryEpilogueAscent/EntryWall/CollisionShape2D",
		"CrownObservatoryEpilogueAscent/MidPerch/CollisionShape2D",
		"CrownObservatoryEpilogueAscent/SignalSpine/CollisionShape2D",
		"CrownObservatoryEpilogueAscent/CompletionArea/CollisionShape2D",
		"CrownObservatoryEpilogueAscent/FallZone/CollisionShape2D",
		"CrownObservatoryEpilogueAscent/AscentCheckpointSpawn",
	]:
		assert_that(arena.get_node_or_null(node_path)).override_failure_message(
			"Story172 scene node missing: %s" % node_path
		).is_not_null()
	assert_bool(arena.has_method("get_crown_observatory_epilogue_ascent_diagnostics")).is_true()
	assert_bool(arena.has_method("try_complete_crown_observatory_epilogue_ascent")).is_true()
	if not arena.has_method("get_crown_observatory_epilogue_ascent_diagnostics"):
		return

	var camera: Camera2D = arena.get_node_or_null("Player/Camera2D") as Camera2D
	assert_that(camera).is_not_null()
	if camera != null:
		assert_int(camera.limit_right).is_equal(2560)
	var player: Node2D = arena.get_node_or_null("Player") as Node2D
	var endpoint: Node2D = arena.get_node_or_null(
		"CrownObservatoryEpilogueAscent/AscentEndpoint"
	) as Node2D
	var checkpoint: Node2D = arena.get_node_or_null(
		"CrownObservatoryEpilogueAscent/AscentCheckpointSpawn"
	) as Node2D
	assert_that(player).is_not_null()
	assert_that(endpoint).is_not_null()
	assert_that(checkpoint).is_not_null()
	if player == null or endpoint == null or checkpoint == null:
		return

	arena.call("set_local_state", {
		DEFEATED_KEY: true,
		REWARD_KEY: true,
		"unlocked_abilities": ["basic_attack", "jump", "dodge", "wall_climb"],
	})
	var gated: Dictionary = arena.call(
		"get_crown_observatory_epilogue_ascent_diagnostics"
	)
	assert_bool(bool(gated.get("route_available", false))).is_true()
	assert_bool(bool(gated.get("completed", true))).is_false()
	assert_bool(bool(gated.get("recall_route_available", true))).is_false()
	assert_str(String(gated.get("objective_text", ""))).is_equal(
		"Climb to the Crown Signal"
	)
	player.global_position = Vector2(1220, 480)
	assert_bool(bool(player.call("request_wall_climb", Vector2(-1, 0), -1.0, true))).is_true()
	var climbed: Dictionary = arena.call(
		"get_crown_observatory_epilogue_ascent_diagnostics"
	)
	assert_bool(bool(climbed.get("wall_climb_proof", false))).is_true()
	assert_bool(bool(climbed.get("checkpoint_activated", false))).is_true()

	var max_hp: int = int(player.call("get_max_hp"))
	assert_int(int(player.call("apply_damage", max_hp, {
		"source": &"story172_ascent_fall",
		"damage_type": &"fall",
	}))).is_greater(0)
	await get_tree().process_frame
	await get_tree().process_frame
	assert_float(player.global_position.distance_to(checkpoint.global_position)).is_less_equal(16.0)

	player.global_position = endpoint.global_position
	assert_bool(bool(arena.call(
		"try_complete_crown_observatory_epilogue_ascent", player
	))).is_true()
	assert_bool(bool(arena.call(
		"try_complete_crown_observatory_epilogue_ascent", player
	))).is_false()
	var completed: Dictionary = arena.call(
		"get_crown_observatory_epilogue_ascent_diagnostics"
	)
	assert_bool(bool(completed.get("completed", false))).is_true()
	assert_int(int(completed.get("completion_count", 0))).is_equal(1)
	assert_bool(bool(completed.get("recall_route_available", false))).is_true()
	assert_str(String(completed.get("objective_text", ""))).is_equal(
		"Recall to Scrap Roost"
	)
	var state: Dictionary = arena.call("get_local_state")
	assert_bool(bool(state.get(CHECKPOINT_KEY, false))).is_true()
	assert_bool(bool(state.get(COMPLETED_KEY, false))).is_true()

	var legacy: Node = _instantiate_scene(ARENA_SCENE_PATH)
	legacy.call("set_local_state", {
		DEFEATED_KEY: true,
		REWARD_KEY: true,
		RECALL_KEY: true,
		"unlocked_abilities": ["wall_climb"],
	})
	var legacy_diagnostics: Dictionary = legacy.call(
		"get_crown_observatory_epilogue_ascent_diagnostics"
	)
	assert_bool(bool(legacy_diagnostics.get("completed", false))).is_true()
	assert_int(int(legacy_diagnostics.get("completion_count", -1))).is_equal(0)
	assert_bool(bool(legacy_diagnostics.get("recall_route_available", false))).is_true()


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
