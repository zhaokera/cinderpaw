## Player Abilities Story170: Tower parry laser uses state-specific frame motion.
extends GdUnitTestSuite

const ROOFTOPS_SCENE_PATH: String = "res://scenes/areas/neon_rooftops_entry.tscn"
const SPRITE_FRAMES_PATH: String = (
	"res://assets/environment/neon_rooftops/tower_parry_laser/"
	+ "tower_parry_laser_sprite_frames.tres"
)
const FRAME_ROOT: String = (
	"res://assets/environment/neon_rooftops/tower_parry_laser"
)
const CONTROLLER_NODE_PATH: String = "TowerParryTrialController"
const ANIMATION_NODE_PATH: String = (
	"TowerParryTrialController/LaserPulseAnimation"
)
const LEGACY_VISUAL_NODE_PATH: String = (
	"TowerParryTrialController/LaserPulseVisual"
)
const EXPECTED_FRAME_SIZE: Vector2i = Vector2i(512, 128)
const EXPECTED_FRAME_COUNT: int = 3
const EXPECTED_TELEGRAPH_SEC: float = 0.60
const EXPECTED_STRIKE_SEC: float = 0.18
const EXPECTED_RECOVERY_SEC: float = 0.55
const EXPECTED_MISS_DAMAGE: int = 18
const ANIMATION_STATES: Array[StringName] = [
	&"telegraph",
	&"strike",
	&"recovery_reflected",
	&"recovery_missed",
]

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	get_tree().paused = false
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_parry_laser_maps_four_gameplay_states_to_three_frame_animation() -> void:
	assert_bool(FileAccess.file_exists(SPRITE_FRAMES_PATH)).is_true()
	for animation_name: StringName in ANIMATION_STATES:
		for frame_index: int in range(EXPECTED_FRAME_COUNT):
			var frame_path: String = _frame_path(animation_name, frame_index)
			assert_bool(FileAccess.file_exists(frame_path)).is_true()
			_assert_png_contract(frame_path)
	if not FileAccess.file_exists(SPRITE_FRAMES_PATH):
		return
	var frames: SpriteFrames = load(SPRITE_FRAMES_PATH) as SpriteFrames
	assert_that(frames).is_not_null()
	if frames == null:
		return
	for animation_name: StringName in ANIMATION_STATES:
		assert_bool(frames.has_animation(animation_name)).is_true()
		assert_int(frames.get_frame_count(animation_name)).is_equal(
			EXPECTED_FRAME_COUNT
		)
	assert_bool(frames.get_animation_loop(&"telegraph")).is_true()
	assert_bool(frames.get_animation_loop(&"strike")).is_false()
	assert_bool(frames.get_animation_loop(&"recovery_reflected")).is_false()
	assert_bool(frames.get_animation_loop(&"recovery_missed")).is_false()

	var rooftops: Node = _instantiate_scene(ROOFTOPS_SCENE_PATH)
	assert_that(rooftops).is_not_null()
	if rooftops == null:
		return
	var controller: Node = rooftops.get_node_or_null(CONTROLLER_NODE_PATH)
	var animation: AnimatedSprite2D = rooftops.get_node_or_null(
		ANIMATION_NODE_PATH
	) as AnimatedSprite2D
	var legacy_visual: Sprite2D = rooftops.get_node_or_null(
		LEGACY_VISUAL_NODE_PATH
	) as Sprite2D
	var player: Node2D = rooftops.get_node_or_null("Player") as Node2D
	var emitter: Node2D = rooftops.get_node_or_null(
		"TowerParryTrialController/LaserEmitter"
	) as Node2D
	assert_that(controller).is_not_null()
	assert_that(animation).is_not_null()
	assert_that(legacy_visual).is_not_null()
	assert_that(player).is_not_null()
	assert_that(emitter).is_not_null()
	if (
		controller == null
		or animation == null
		or legacy_visual == null
		or player == null
		or emitter == null
	):
		return
	controller.set_process(false)
	assert_bool(legacy_visual.visible).is_false()
	assert_that(animation.sprite_frames).is_same(frames)

	rooftops.call("set_local_state", _prerequisite_state())
	player.global_position = emitter.global_position
	assert_bool(bool(rooftops.call(
		"try_activate_central_tower_parry_trial",
		player
	))).is_true()
	_assert_animation_state(
		rooftops.call("get_central_tower_parry_trial_diagnostics"),
		&"telegraph"
	)

	rooftops.call("advance_central_tower_parry_trial", 0.61)
	_assert_animation_state(
		rooftops.call("get_central_tower_parry_trial_diagnostics"),
		&"strike"
	)
	assert_bool(bool(player.call("request_parry"))).is_true()
	_assert_animation_state(
		rooftops.call("get_central_tower_parry_trial_diagnostics"),
		&"recovery_reflected"
	)

	rooftops.call("advance_central_tower_parry_trial", 0.56)
	rooftops.call("advance_central_tower_parry_trial", 0.61)
	rooftops.call("advance_central_tower_parry_trial", 0.19)
	var missed: Dictionary = rooftops.call(
		"get_central_tower_parry_trial_diagnostics"
	)
	_assert_animation_state(missed, &"recovery_missed")
	assert_int(int(missed.get("miss_count", 0))).is_equal(1)
	assert_int(int(missed.get("successful_parries", 0))).is_equal(1)
	assert_int(int(missed.get("miss_damage", 0))).is_equal(EXPECTED_MISS_DAMAGE)
	assert_float(float(missed.get(
		"telegraph_duration_sec",
		0.0
	))).is_equal_approx(EXPECTED_TELEGRAPH_SEC, 0.001)
	assert_float(float(missed.get(
		"strike_duration_sec",
		0.0
	))).is_equal_approx(EXPECTED_STRIKE_SEC, 0.001)
	assert_float(float(missed.get(
		"recovery_duration_sec",
		0.0
	))).is_equal_approx(EXPECTED_RECOVERY_SEC, 0.001)


func _assert_animation_state(diagnostics: Dictionary, expected: StringName) -> void:
	assert_str(String(diagnostics.get("pulse_state", ""))).is_equal(
		"recovery" if expected in [&"recovery_reflected", &"recovery_missed"] else String(expected)
	)
	assert_str(String(diagnostics.get("pulse_animation_name", ""))).is_equal(
		String(expected)
	)
	assert_int(int(diagnostics.get("pulse_animation_frame_count", 0))).is_equal(
		EXPECTED_FRAME_COUNT
	)
	assert_bool(bool(diagnostics.get("pulse_animation_visible", false))).is_true()
	assert_bool(bool(diagnostics.get("legacy_pulse_visible", true))).is_false()
	assert_str(String(diagnostics.get("pulse_sprite_frames_path", ""))).is_equal(
		SPRITE_FRAMES_PATH
	)


func _frame_path(animation_name: StringName, frame_index: int) -> String:
	return "%s/%s/tower_parry_laser_%s_%03d.png" % [
		FRAME_ROOT,
		String(animation_name),
		String(animation_name),
		frame_index,
	]


func _assert_png_contract(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	var image := Image.new()
	assert_int(image.load(ProjectSettings.globalize_path(path))).is_equal(OK)
	assert_int(image.get_width()).is_equal(EXPECTED_FRAME_SIZE.x)
	assert_int(image.get_height()).is_equal(EXPECTED_FRAME_SIZE.y)
	assert_int(image.detect_alpha()).is_equal(Image.ALPHA_BLEND)


func _instantiate_scene(path: String) -> Node:
	var packed: PackedScene = load(path) as PackedScene
	if packed == null:
		return null
	var instance: Node = packed.instantiate()
	_spawned_nodes.append(instance)
	add_child(instance)
	return instance


func _prerequisite_state() -> Dictionary:
	return {
		"neon_rooftops_entry_arrived": true,
		"neon_rooftops_entry_traversed": true,
		"neon_rooftops_signal_rat_encounter_activated": true,
		"neon_rooftops_signal_rat_defeated": true,
		"neon_rooftops_signal_cache_claimed": true,
		"neon_rooftops_relay_spire_roost_activated": true,
		"neon_rooftops_relay_spire_traversed": true,
		"unlocked_abilities": [
			"dash", "double_jump", "aerial_attack", "wall_climb", "parry",
		],
	}
