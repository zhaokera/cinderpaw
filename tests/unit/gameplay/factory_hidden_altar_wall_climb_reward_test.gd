## Player Abilities Story 135: hidden-altar reward and playable wall climb.
extends GdUnitTestSuite

const UPPER_SCENE_PATH: String = (
	"res://scenes/areas/factory_upper_altar_approach.tscn"
)
const PLAYER_SCENE_PATH: String = "res://scenes/player.tscn"
const ABILITIES_PATH: String = "res://data/abilities.json"
const ABILITIES_SCHEMA_PATH: String = "res://data/schemas/abilities.schema.json"
const PLAYER_FRAMES_PATH: String = (
	"res://assets/characters/cinderpaw/cinderpaw_sprite_frames.tres"
)
const AWAKENED_ALTAR_PATH: String = (
	"res://assets/environment/factory_upper_altar/"
	+ "prop_factory_hidden_altar_awakened_384x384.png"
)
const MAGNETIC_WALL_PATH: String = (
	"res://assets/environment/factory_upper_altar/"
	+ "prop_factory_magnetic_wall_256x512.png"
)
const CONTACT_GLOW_PATH: String = (
	"res://assets/environment/factory_upper_altar/"
	+ "vfx_wall_climb_contact_glow_192x192.png"
)
const UPPER_SCENE_ID: StringName = &"area_03_factory_upper_altar"
const UNDERGROUND_SCENE_ID: StringName = &"area_04_underground_passage"
const WALL_CLIMB_ABILITY: StringName = &"wall_climb"
const EXPECTED_CLIMB_SPEED: float = 160.0
const EXPECTED_SLIDE_SPEED: float = 72.0
const EXPECTED_WALL_JUMP_HORIZONTAL_SPEED: float = 260.0
const EXPECTED_WALL_JUMP_VERTICAL_SPEED: float = 340.0
const EXPECTED_REGRAB_LOCK_FRAMES: int = 8

var _spawned_nodes: Array[Node] = []


class FakeSceneManager:
	extends RefCounted

	var scene_states: Dictionary = {}
	var current_scene: StringName = UPPER_SCENE_ID
	var current_spawn: StringName = &"cistern_ascender_arrival"

	func has_scene(scene_id: StringName) -> bool:
		return scene_id in [UPPER_SCENE_ID, UNDERGROUND_SCENE_ID]

	func get_current_scene() -> StringName:
		return current_scene

	func get_current_spawn_point() -> StringName:
		return current_spawn

	func is_loading() -> bool:
		return false

	func is_scene_locked() -> bool:
		return false

	func get_scene_state(scene_id: StringName) -> Dictionary:
		return Dictionary(scene_states.get(String(scene_id), {})).duplicate(true)

	func set_scene_state(scene_id: StringName, state: Dictionary) -> bool:
		scene_states[String(scene_id)] = state.duplicate(true)
		return true

	func request_scene_change(
		scene_id: StringName,
		_spawn_point: StringName = &"default"
	) -> bool:
		return has_scene(scene_id)


func after_test() -> void:
	_stop_runtime_audio_players()
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_data_spriteframes_generated_visuals_and_authored_proof_contract() -> void:
	var abilities: Dictionary = _read_json_dictionary(ABILITIES_PATH)
	var entries: Dictionary = Dictionary(abilities.get("entries", {}))
	var wall_climb: Dictionary = Dictionary(entries.get("wall_climb", {}))
	assert_float(float(wall_climb.get("climb_speed_px_sec", -1.0))).is_equal_approx(
		EXPECTED_CLIMB_SPEED,
		0.001
	)
	assert_float(float(wall_climb.get("wall_slide_speed_px_sec", -1.0))).is_equal_approx(
		EXPECTED_SLIDE_SPEED,
		0.001
	)
	assert_float(float(wall_climb.get(
		"wall_jump_horizontal_speed_px_sec",
		-1.0
	))).is_equal_approx(EXPECTED_WALL_JUMP_HORIZONTAL_SPEED, 0.001)
	assert_float(float(wall_climb.get(
		"wall_jump_vertical_speed_px_sec",
		-1.0
	))).is_equal_approx(EXPECTED_WALL_JUMP_VERTICAL_SPEED, 0.001)
	assert_int(int(wall_climb.get("wall_regrab_lock_frames", -1))).is_equal(
		EXPECTED_REGRAB_LOCK_FRAMES
	)

	var schema: Dictionary = _read_json_dictionary(ABILITIES_SCHEMA_PATH)
	var schema_entries: Dictionary = Dictionary(schema.get("entries", {}))
	var wall_schema: Dictionary = Dictionary(schema_entries.get("wall_climb", {}))
	var required: Array = Array(wall_schema.get("required", []))
	var fields: Dictionary = Dictionary(wall_schema.get("fields", {}))
	for field_name: String in [
		"climb_speed_px_sec",
		"wall_slide_speed_px_sec",
		"wall_jump_horizontal_speed_px_sec",
		"wall_jump_vertical_speed_px_sec",
		"wall_regrab_lock_frames",
	]:
		assert_array(required).contains([field_name])
		assert_bool(fields.has(field_name)).is_true()

	assert_bool(FileAccess.file_exists(AWAKENED_ALTAR_PATH)).is_true()
	assert_bool(FileAccess.file_exists(MAGNETIC_WALL_PATH)).is_true()
	assert_bool(FileAccess.file_exists(CONTACT_GLOW_PATH)).is_true()
	_assert_texture_contract(AWAKENED_ALTAR_PATH, Vector2i(384, 384))
	_assert_texture_contract(MAGNETIC_WALL_PATH, Vector2i(256, 512))
	_assert_texture_contract(CONTACT_GLOW_PATH, Vector2i(192, 192))

	assert_bool(FileAccess.file_exists(PLAYER_FRAMES_PATH)).is_true()
	var sprite_frames: SpriteFrames = load(PLAYER_FRAMES_PATH) as SpriteFrames
	assert_that(sprite_frames).is_not_null()
	if sprite_frames != null:
		assert_bool(sprite_frames.has_animation(&"wall_climb")).is_true()
		if sprite_frames.has_animation(&"wall_climb"):
			assert_int(sprite_frames.get_frame_count(&"wall_climb")).is_greater_equal(3)
			for frame_index: int in range(
				sprite_frames.get_frame_count(&"wall_climb")
			):
				var texture: Texture2D = sprite_frames.get_frame_texture(
					&"wall_climb",
					frame_index
				)
				assert_that(texture).is_not_null()
				if texture != null:
					assert_vector(texture.get_size()).is_equal(Vector2(96.0, 96.0))

	var upper: Node = _instantiate_scene(UPPER_SCENE_PATH)
	assert_that(upper).is_not_null()
	if upper == null:
		return
	assert_that(upper.get_node_or_null("MagneticWall/Visual")).is_not_null()
	assert_that(upper.get_node_or_null("MagneticWall/ContactGlow")).is_not_null()
	assert_that(upper.get_node_or_null(
		"RooftopProofPerch/CollisionShape2D"
	)).is_not_null()
	var proof_collision: CollisionShape2D = upper.get_node_or_null(
		"RooftopProofPerch/CollisionShape2D"
	) as CollisionShape2D
	if proof_collision != null:
		assert_bool(proof_collision.one_way_collision).is_true()
	assert_that(upper.get_node_or_null(
		"WallClimbProofArea/CollisionShape2D"
	)).is_not_null()
	assert_that(upper.get_node_or_null(
		"TopBoundary/CollisionShape2D"
	)).is_not_null()
	var approach: Node2D = upper.get_node_or_null("ApproachPlatformC") as Node2D
	var proof_perch: Node2D = upper.get_node_or_null("RooftopProofPerch") as Node2D
	assert_that(approach).is_not_null()
	assert_that(proof_perch).is_not_null()
	if approach != null and proof_perch != null:
		assert_float(approach.position.y - proof_perch.position.y).is_greater(150.0)


func test_hidden_altar_claim_is_one_shot_persistent_and_alternate_path_safe() -> void:
	var upper: Node = _instantiate_scene(UPPER_SCENE_PATH)
	assert_that(upper).is_not_null()
	if upper == null:
		return
	assert_bool(upper.has_method("try_claim_wall_climb_reward")).is_true()
	assert_bool(upper.has_method("advance_wall_climb_reward_feedback")).is_true()
	assert_bool(upper.has_method("try_prove_wall_climb_route")).is_true()
	if not upper.has_method("try_claim_wall_climb_reward"):
		return

	var manager := FakeSceneManager.new()
	assert_bool(bool(upper.call("configure_scene_manager_runtime", manager))).is_true()
	upper.call("set_local_state", {
		"factory_upper_hidden_altar_discovered": true,
		"unlocked_abilities": ["dash", "double_jump", "aerial_attack"],
	})
	var player: Node2D = upper.get_node_or_null("Player") as Node2D
	var altar: Node2D = upper.get_node_or_null("DormantHiddenAltar") as Node2D
	assert_that(player).is_not_null()
	assert_that(altar).is_not_null()
	if player == null or altar == null:
		return
	player.global_position = altar.global_position
	assert_bool(bool(upper.call("try_claim_wall_climb_reward", player))).is_true()
	assert_bool(bool(upper.call("try_claim_wall_climb_reward", player))).is_false()
	var claimed: Dictionary = upper.call("get_factory_upper_altar_diagnostics")
	assert_bool(bool(claimed.get("wall_climb_reward_claimed", false))).is_true()
	assert_int(int(claimed.get("wall_climb_reward_feedback_count", 0))).is_equal(1)
	assert_float(float(claimed.get(
		"wall_climb_reward_feedback_duration_sec",
		0.0
	))).is_equal_approx(1.5, 0.001)
	assert_array(Array(claimed.get("unlocked_abilities", []))).contains([
		"wall_climb",
	])
	assert_str(String(claimed.get("objective_text", ""))).is_equal(
		"Wall Climb Unlocked"
	)

	var persisted: Dictionary = manager.get_scene_state(UPPER_SCENE_ID)
	assert_bool(bool(persisted.get(
		"factory_upper_wall_climb_reward_claimed",
		false
	))).is_true()
	assert_array(Array(persisted.get("unlocked_abilities", []))).contains([
		"wall_climb",
	])
	upper.call("advance_wall_climb_reward_feedback", 1.5)
	claimed = upper.call("get_factory_upper_altar_diagnostics")
	assert_str(String(claimed.get("objective_text", ""))).is_equal(
		"Climb the Magnetic Wall"
	)

	var proof_area: Node2D = upper.get_node_or_null("WallClimbProofArea") as Node2D
	assert_that(proof_area).is_not_null()
	if proof_area != null:
		player.global_position = proof_area.global_position
		assert_bool(bool(upper.call("try_prove_wall_climb_route", player))).is_true()
		assert_bool(bool(upper.call("try_prove_wall_climb_route", player))).is_false()
		var proven: Dictionary = upper.call("get_factory_upper_altar_diagnostics")
		assert_bool(bool(proven.get("wall_climb_route_proven", false))).is_true()
		assert_str(String(proven.get("objective_text", ""))).is_equal(
			"Rooftop Route Reached"
		)

	var saved: Dictionary = upper.call("get_local_state")
	var restored: Node = _instantiate_scene(UPPER_SCENE_PATH)
	assert_that(restored).is_not_null()
	if restored != null:
		restored.call("set_local_state", saved)
		var restored_diagnostics: Dictionary = restored.call(
			"get_factory_upper_altar_diagnostics"
		)
		assert_bool(bool(restored_diagnostics.get(
			"wall_climb_reward_claimed",
			false
		))).is_true()
		assert_bool(bool(restored_diagnostics.get(
			"wall_climb_route_proven",
			false
		))).is_true()
		assert_int(int(restored_diagnostics.get(
			"wall_climb_reward_feedback_count",
			-1
		))).is_equal(0)
		assert_array(Array(restored_diagnostics.get(
			"unlocked_abilities",
			[]
		))).contains(["wall_climb"])

	var alternate: Node = _instantiate_scene(UPPER_SCENE_PATH)
	assert_that(alternate).is_not_null()
	if alternate == null:
		return
	alternate.call("set_local_state", {
		"factory_upper_hidden_altar_discovered": true,
		"unlocked_abilities": ["wall_climb"],
	})
	var alternate_player: Node2D = alternate.get_node_or_null("Player") as Node2D
	var alternate_altar: Node2D = alternate.get_node_or_null(
		"DormantHiddenAltar"
	) as Node2D
	assert_that(alternate_player).is_not_null()
	assert_that(alternate_altar).is_not_null()
	if alternate_player == null or alternate_altar == null:
		return
	var duplicate_unlocks: Array[StringName] = []
	if alternate_player.has_signal("ability_unlocked"):
		var unlock_signal: Signal = alternate_player.get("ability_unlocked")
		unlock_signal.connect(func(ability_id: StringName) -> void:
			duplicate_unlocks.append(ability_id)
		)
	alternate_player.global_position = alternate_altar.global_position
	assert_bool(bool(alternate.call(
		"try_claim_wall_climb_reward",
		alternate_player
	))).is_true()
	assert_array(duplicate_unlocks).is_empty()


func test_player_wall_climb_slide_jump_and_blocking_state_contract() -> void:
	var locked_player: CharacterBody2D = _instantiate_scene(
		PLAYER_SCENE_PATH
	) as CharacterBody2D
	assert_that(locked_player).is_not_null()
	if locked_player == null:
		return
	assert_bool(locked_player.has_method("request_wall_climb")).is_true()
	assert_bool(locked_player.has_method("request_wall_jump")).is_true()
	assert_bool(locked_player.has_method("get_wall_climb_diagnostics")).is_true()
	if not locked_player.has_method("request_wall_climb"):
		return
	assert_bool(bool(locked_player.call(
		"request_wall_climb",
		Vector2(-1.0, 0.0),
		-1.0,
		true
	))).is_false()

	var player: CharacterBody2D = _instantiate_scene(
		PLAYER_SCENE_PATH
	) as CharacterBody2D
	assert_that(player).is_not_null()
	if player == null:
		return
	player.call("set_unlocked_abilities", ["wall_climb"])
	var climb_starts: Array[Vector2] = []
	if player.has_signal("wall_climb_started"):
		var climb_signal: Signal = player.get("wall_climb_started")
		climb_signal.connect(func(
			_texture: Texture2D,
			_position: Vector2,
			wall_normal: Vector2
		) -> void:
			climb_starts.append(wall_normal)
		)
	assert_bool(bool(player.call(
		"request_wall_climb",
		Vector2(-1.0, 0.0),
		-1.0,
		true
	))).is_true()
	assert_float(player.velocity.y).is_equal_approx(-EXPECTED_CLIMB_SPEED, 0.001)
	var climbing: Dictionary = player.call("get_wall_climb_diagnostics")
	assert_bool(bool(climbing.get("active", false))).is_true()
	assert_str(String(climbing.get("animation", ""))).is_equal("wall_climb")
	assert_int(climb_starts.size()).is_equal(1)
	assert_bool(bool(player.call(
		"request_wall_climb",
		Vector2(-1.0, 0.0),
		0.0,
		true
	))).is_true()
	assert_float(player.velocity.y).is_equal_approx(EXPECTED_SLIDE_SPEED, 0.001)
	assert_int(climb_starts.size()).is_equal(1)
	assert_bool(bool(player.call(
		"request_wall_climb",
		Vector2(-1.0, 0.0),
		1.0,
		true
	))).is_true()
	assert_float(player.velocity.y).is_equal_approx(EXPECTED_CLIMB_SPEED, 0.001)

	assert_bool(bool(player.call("request_wall_jump"))).is_true()
	assert_float(player.velocity.x).is_equal_approx(
		-EXPECTED_WALL_JUMP_HORIZONTAL_SPEED,
		0.001
	)
	assert_float(player.velocity.y).is_equal_approx(
		-EXPECTED_WALL_JUMP_VERTICAL_SPEED,
		0.001
	)
	var jumped: Dictionary = player.call("get_wall_climb_diagnostics")
	assert_bool(bool(jumped.get("active", true))).is_false()
	assert_int(int(jumped.get("regrab_lock_frames", 0))).is_equal(
		EXPECTED_REGRAB_LOCK_FRAMES
	)
	assert_bool(bool(player.call(
		"request_wall_climb",
		Vector2(-1.0, 0.0),
		-1.0,
		true
	))).is_false()

	player.call("clear_wall_climb_regrab_lock")
	assert_bool(bool(player.call(
		"request_wall_climb",
		Vector2(-1.0, 0.0),
		-1.0,
		true
	))).is_true()
	player.call("set_control_locked", true)
	var locked: Dictionary = player.call("get_wall_climb_diagnostics")
	assert_bool(bool(locked.get("active", true))).is_false()
	player.call("set_control_locked", false)
	assert_bool(bool(player.call(
		"request_wall_climb",
		Vector2.ZERO,
		-1.0,
		true
	))).is_false()
	assert_bool(bool(player.call(
		"request_wall_climb",
		Vector2(-1.0, 0.0),
		-1.0,
		false
	))).is_false()


func _assert_texture_contract(path: String, expected_size: Vector2i) -> void:
	if not FileAccess.file_exists(path):
		return
	var texture: Texture2D = load(path) as Texture2D
	assert_that(texture).is_not_null()
	if texture == null:
		return
	assert_vector(texture.get_size()).is_equal(Vector2(expected_size))
	var image: Image = texture.get_image()
	assert_that(image).is_not_null()
	if image != null:
		assert_bool(image.detect_alpha() != Image.ALPHA_NONE).is_true()


func _instantiate_scene(path: String) -> Node:
	if not FileAccess.file_exists(path):
		return null
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		return null
	var instance: Node = packed.instantiate()
	_spawned_nodes.append(instance)
	add_child(instance)
	return instance


func _read_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed if parsed is Dictionary else {}


func _stop_runtime_audio_players() -> void:
	for player: AudioStreamPlayer in get_tree().get_nodes_in_group(
		"audio_music_player"
	):
		player.stop()
	for player: AudioStreamPlayer in get_tree().get_nodes_in_group(
		"audio_ambient_player"
	):
		player.stop()
