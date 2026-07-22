## Player Abilities Story 181: authored Old Factory pressure valve presentation.
extends GdUnitTestSuite

const FACTORY_SCENE_PATH: String = "res://scenes/factory_route_transition_shell.tscn"
const EXPECTED_SPRITE_FRAMES_PATH: String = (
	"res://assets/environment/old_factory_pressure_valve/"
	+ "factory_pressure_valve_sprite_frames.tres"
)
const EXPECTED_SOURCE_PATH: String = (
	"res://assets/environment/old_factory_pressure_valve/source/"
	+ "factory_pressure_valve_motion_sheet_imagegen_20260720.png"
)
const REQUIRED_ANIMATIONS: Array[StringName] = [
	&"closed_idle",
	&"opening",
	&"opened_idle",
]

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_pressure_valve_uses_authored_three_state_frame_animation() -> void:
	var destination: Node = _instantiate_factory_scene()
	assert_that(destination).is_not_null()
	if destination == null:
		return

	destination.call("set_local_state", {
		"factory_lower_deck_shortcut_pursuer_activated": true,
		"factory_lower_deck_shortcut_pursuer_defeated": true,
	})
	var closed: Dictionary = destination.call(
		"get_factory_lower_deck_pressure_valve_diagnostics"
	)
	assert_bool(bool(closed.get("valve_animation_present", false))).is_true()
	if not bool(closed.get("valve_animation_present", false)):
		return
	assert_str(String(closed.get("valve_animation_class", ""))).is_equal("AnimatedSprite2D")
	assert_str(String(closed.get("valve_sprite_frames_path", ""))).is_equal(
		EXPECTED_SPRITE_FRAMES_PATH
	)
	assert_str(String(closed.get("valve_asset_source", ""))).is_equal(
		EXPECTED_SOURCE_PATH
	)
	assert_str(String(closed.get("valve_visual_state", ""))).is_equal("closed_idle")
	assert_str(String(closed.get("valve_animation", ""))).is_equal("closed_idle")
	assert_bool(bool(closed.get("valve_animation_visible", false))).is_true()
	_assert_frame_contract(closed)

	var player: Node2D = destination.get_node_or_null("Player") as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return
	destination.call("set_local_state", {
		"factory_lower_deck_shortcut_pursuer_activated": true,
		"factory_lower_deck_shortcut_pursuer_defeated": true,
		"factory_lower_deck_pressure_guard_activated": true,
		"factory_lower_deck_pressure_guard_defeated": true,
	})
	var available: Dictionary = destination.call(
		"get_factory_lower_deck_pressure_valve_diagnostics"
	)
	player.global_position = available.get("valve_position", Vector2.ZERO)
	assert_bool(bool(destination.call(
		"try_open_factory_lower_deck_pressure_valve",
		player
	))).is_true()
	var opening: Dictionary = destination.call(
		"get_factory_lower_deck_pressure_valve_diagnostics"
	)
	assert_str(String(opening.get("valve_visual_state", ""))).is_equal("opening")
	assert_str(String(opening.get("valve_animation", ""))).is_equal("opening")

	var animation := destination.get_node_or_null(
		"FactoryLowerDeckPressureValve/ValveAnimation"
	) as AnimatedSprite2D
	assert_that(animation).is_not_null()
	if animation == null:
		return
	animation.animation_finished.emit()
	var opened: Dictionary = destination.call(
		"get_factory_lower_deck_pressure_valve_diagnostics"
	)
	assert_str(String(opened.get("valve_visual_state", ""))).is_equal("opened_idle")
	assert_str(String(opened.get("valve_animation", ""))).is_equal("opened_idle")


func _instantiate_factory_scene() -> Node:
	assert_bool(FileAccess.file_exists(FACTORY_SCENE_PATH)).is_true()
	var packed: PackedScene = load(FACTORY_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return null
	var destination: Node = packed.instantiate()
	add_child(destination)
	_spawned_nodes.append(destination)
	return destination


func _assert_frame_contract(diagnostics: Dictionary) -> void:
	var frame_counts: Dictionary = diagnostics.get("valve_animation_frame_counts", {})
	var loop_modes: Dictionary = diagnostics.get("valve_animation_loop_modes", {})
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		var key: String = String(animation_name)
		assert_int(int(frame_counts.get(key, 0))).is_equal(3)
	assert_bool(bool(loop_modes.get("closed_idle", false))).is_true()
	assert_bool(bool(loop_modes.get("opening", true))).is_false()
	assert_bool(bool(loop_modes.get("opened_idle", false))).is_true()
