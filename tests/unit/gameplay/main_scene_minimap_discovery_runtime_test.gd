## Story152 acceptance contract for the Main HUD minimap and gate discovery feedback.
extends GdUnitTestSuite

const HUD_MANAGER_SCRIPT_PATH: String = "res://src/presentation/hud_manager.gd"
const MINIMAP_WIDGET_SCRIPT_PATH: String = "res://src/presentation/minimap_widget.gd"
const MAIN_SCENE_PATH: String = "res://scenes/main.tscn"
const MAIN_AREA_ID: StringName = &"main"
const SEWER_AREA_ID: StringName = &"area_02_sewer"
const FACTORY_AREA_ID: StringName = &"area_03_factory"
const TOWER_AREA_ID: StringName = &"area_05_central_tower"
const DASH_ABILITY_ID: StringName = &"dash"
const MINIMAP_PANEL_PATH: NodePath = ^"HudRoot/MinimapHudPanel"

var _nodes_to_free: Array[Node] = []


func after_test() -> void:
	for node: Node in _nodes_to_free:
		if is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()
	_nodes_to_free.clear()
	_clear_audio_system_players()


func _clear_audio_system_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var player := child as AudioStreamPlayer
			player.stop()
			player.stream = null
		elif child is AudioStreamPlayer2D:
			var player_2d := child as AudioStreamPlayer2D
			player_2d.stop()
			player_2d.stream = null


func test_hud_builds_scaled_shape_readable_minimap_and_animates_one_reveal() -> void:
	assert_bool(ResourceLoader.exists(MINIMAP_WIDGET_SCRIPT_PATH)).is_true()
	var hud_script := load(HUD_MANAGER_SCRIPT_PATH) as Script
	assert_object(hud_script).is_not_null()
	if hud_script == null:
		return
	var hud: Node = hud_script.new() as Node
	add_child(hud)
	_nodes_to_free.append(hud)

	var required_methods: Array[StringName] = [
		&"configure_minimap",
		&"reveal_minimap_region",
		&"update_minimap_player_position",
		&"get_minimap_diagnostics",
	]
	for method_name: StringName in required_methods:
		assert_bool(hud.has_method(method_name)).is_true()
	if required_methods.any(func(method_name: StringName) -> bool: return not hud.has_method(method_name)):
		return

	hud.call("configure_minimap", _region_definitions(), MAIN_AREA_ID)
	var panel := hud.get_node_or_null(MINIMAP_PANEL_PATH) as Control
	assert_object(panel).is_not_null()
	if panel == null:
		return
	assert_vector(panel.size).is_equal(Vector2(120, 120))
	var initial: Dictionary = Dictionary(hud.call("get_minimap_diagnostics"))
	assert_bool(bool(initial.get("visible", false))).is_true()
	assert_str(String(initial.get("current_area_id", ""))).is_equal(String(MAIN_AREA_ID))
	assert_bool(bool(initial.get("shape_readable", false))).is_true()
	_assert_region_state(initial, MAIN_AREA_ID, true, 1.0)
	_assert_region_state(initial, FACTORY_AREA_ID, false, 0.0)

	assert_bool(bool(hud.call("reveal_minimap_region", FACTORY_AREA_ID, 1.0))).is_true()
	var started: Dictionary = Dictionary(hud.call("get_minimap_diagnostics"))
	_assert_region_state(started, FACTORY_AREA_ID, true, 0.0)
	assert_int(int(started.get("active_reveal_count", -1))).is_equal(1)

	hud.call("advance_time", 0.5)
	var halfway: Dictionary = Dictionary(hud.call("get_minimap_diagnostics"))
	_assert_region_state(halfway, FACTORY_AREA_ID, true, 0.5)

	hud.call("advance_time", 0.5)
	var completed: Dictionary = Dictionary(hud.call("get_minimap_diagnostics"))
	_assert_region_state(completed, FACTORY_AREA_ID, true, 1.0)
	assert_int(int(completed.get("active_reveal_count", -1))).is_equal(0)
	assert_bool(bool(hud.call("reveal_minimap_region", FACTORY_AREA_ID, 1.0))).is_false()

	hud.call("set_hud_scale", 1.5)
	assert_vector(panel.size).is_equal(Vector2(180, 180))
	assert_bool(bool(hud.call("has_core_hud_overlap"))).is_false()


func test_main_gate_reveal_updates_notification_marker_and_restores_without_replay() -> void:
	var main_scene := load(MAIN_SCENE_PATH) as PackedScene
	assert_object(main_scene).is_not_null()
	if main_scene == null:
		return
	var scene := main_scene.instantiate() as Node2D
	add_child(scene)
	_nodes_to_free.append(scene)
	var hud: Node = scene.get_node("HUD")
	assert_bool(hud.has_method("get_minimap_diagnostics")).is_true()
	if not hud.has_method("get_minimap_diagnostics"):
		return

	var initial: Dictionary = Dictionary(hud.call("get_minimap_diagnostics"))
	_assert_region_state(initial, MAIN_AREA_ID, true, 1.0)
	_assert_region_state(initial, SEWER_AREA_ID, false, 0.0)
	_assert_region_state(initial, FACTORY_AREA_ID, false, 0.0)
	_assert_region_state(initial, TOWER_AREA_ID, false, 0.0)

	var player := scene.get_node("Player") as PlayerController
	player.global_position.x = 1280.0
	scene.call("_process", 0.0)
	var marker: Dictionary = Dictionary(hud.call("get_minimap_diagnostics"))
	assert_float(float(marker.get("player_normalized_x", -1.0))).is_equal_approx(1.0, 0.001)

	var gate: Node = scene.get_node("DashExplorationGate")
	scene.call("unlock_ability", DASH_ABILITY_ID)
	player.global_position = (gate as Node2D).global_position + Vector2(-48, 0)
	assert_bool(player.request_dash()).is_true()
	var revealing: Dictionary = Dictionary(hud.call("get_minimap_diagnostics"))
	_assert_region_state(revealing, SEWER_AREA_ID, true, 0.0)
	assert_str(String(hud.call("get_notification_text"))).is_equal("Sewer Access discovered")

	hud.call("advance_time", 1.0)
	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var world_flags: Dictionary = Dictionary(
		Dictionary(snapshot.get("world_state", {})).get("world_flags", {})
	)
	assert_bool(bool(world_flags.get("area_02_sewer_unlocked", false))).is_true()

	var restored_scene := main_scene.instantiate() as Node2D
	add_child(restored_scene)
	_nodes_to_free.append(restored_scene)
	restored_scene.call("restore_save_snapshot", snapshot)
	var restored_hud: Node = restored_scene.get_node("HUD")
	var restored: Dictionary = Dictionary(restored_hud.call("get_minimap_diagnostics"))
	_assert_region_state(restored, SEWER_AREA_ID, true, 1.0)
	assert_int(int(restored.get("active_reveal_count", -1))).is_equal(0)


func _region_definitions() -> Array[Dictionary]:
	return [
		{
			"id": MAIN_AREA_ID,
			"display_name": "Scrap Roost",
			"position": Vector2(0.14, 0.76),
			"discovered": true,
			"connects_to": [SEWER_AREA_ID],
		},
		{
			"id": SEWER_AREA_ID,
			"display_name": "Sewer Access",
			"position": Vector2(0.40, 0.67),
			"discovered": false,
			"connects_to": [FACTORY_AREA_ID],
		},
		{
			"id": FACTORY_AREA_ID,
			"display_name": "Factory Route",
			"position": Vector2(0.66, 0.45),
			"discovered": false,
			"connects_to": [TOWER_AREA_ID],
		},
		{
			"id": TOWER_AREA_ID,
			"display_name": "Central Tower",
			"position": Vector2(0.87, 0.22),
			"discovered": false,
			"connects_to": [],
		},
	]


func _assert_region_state(
	diagnostics: Dictionary,
	region_id: StringName,
	discovered: bool,
	reveal_progress: float
) -> void:
	var regions: Dictionary = Dictionary(diagnostics.get("regions", {}))
	assert_bool(regions.has(String(region_id))).is_true()
	if not regions.has(String(region_id)):
		return
	var region: Dictionary = Dictionary(regions.get(String(region_id), {}))
	assert_bool(bool(region.get("discovered", not discovered))).is_equal(discovered)
	assert_float(float(region.get("reveal_progress", -1.0))).is_equal_approx(
		reveal_progress,
		0.001
	)
