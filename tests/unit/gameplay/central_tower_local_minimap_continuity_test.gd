## Story171 acceptance contract for Central Tower's five-segment local minimap.
extends GdUnitTestSuite

const TOWER_SCENE_PATH: String = (
	"res://scenes/areas/central_tower_threshold.tscn"
)
const THRESHOLD_ID: StringName = &"central_tower_threshold"
const SERVICE_SPINE_ID: StringName = &"central_tower_service_spine"
const COOLING_SHAFT_ID: StringName = &"central_tower_cooling_shaft"
const DEEP_LIFT_ID: StringName = &"central_tower_deep_lift"
const APEX_CONDUIT_ID: StringName = &"central_tower_apex_conduit"

var _nodes_to_free: Array[Node] = []


func after_test() -> void:
	for node: Node in _nodes_to_free:
		if is_instance_valid(node):
			if node.get_parent() != null:
				node.get_parent().remove_child(node)
			node.free()
	_nodes_to_free.clear()
	_clear_audio_system_players()


func test_tower_tracks_five_segments_and_restores_discovery_without_replay() -> void:
	var scene := _instantiate_tower_scene()
	assert_object(scene).is_not_null()
	if scene == null:
		return
	assert_bool(scene.has_method("get_central_tower_minimap_diagnostics")).is_true()
	if not scene.has_method("get_central_tower_minimap_diagnostics"):
		return

	var initial: Dictionary = Dictionary(
		scene.call("get_central_tower_minimap_diagnostics")
	)
	assert_bool(bool(initial.get("visible", false))).is_true()
	assert_vector(Vector2(initial.get("panel_size", Vector2.ZERO))).is_equal(
		Vector2(120, 120)
	)
	assert_bool(bool(initial.get("shape_readable", false))).is_true()
	assert_str(String(initial.get("current_area_id", ""))).is_equal(
		String(THRESHOLD_ID)
	)
	assert_int(Dictionary(initial.get("regions", {})).size()).is_equal(5)
	_assert_region_state(initial, THRESHOLD_ID, true, 1.0)
	_assert_region_state(initial, SERVICE_SPINE_ID, false, 0.0)
	_assert_region_state(initial, COOLING_SHAFT_ID, false, 0.0)
	_assert_region_state(initial, DEEP_LIFT_ID, false, 0.0)
	_assert_region_state(initial, APEX_CONDUIT_ID, false, 0.0)

	var guard: Node = scene.get_node("ThresholdGuardController")
	guard.call("set_local_state", {
		"central_tower_threshold_guard_defeated": true,
	})
	var revealing: Dictionary = Dictionary(
		scene.call("get_central_tower_minimap_diagnostics")
	)
	_assert_region_state(revealing, SERVICE_SPINE_ID, true, 0.0)
	assert_int(int(revealing.get("active_reveal_count", -1))).is_equal(1)
	var hud: Node = scene.get_node("HUD")
	assert_str(String(hud.call("get_notification_text"))).is_equal(
		"Service Spine discovered"
	)
	hud.call("advance_time", 2.0)
	var revealed: Dictionary = Dictionary(
		scene.call("get_central_tower_minimap_diagnostics")
	)
	_assert_region_state(revealed, SERVICE_SPINE_ID, true, 1.0)
	assert_bool(bool(hud.call("is_notification_visible"))).is_false()
	guard.call("set_local_state", {
		"central_tower_threshold_guard_defeated": true,
	})
	assert_int(int(Dictionary(
		scene.call("get_central_tower_minimap_diagnostics")
	).get("active_reveal_count", -1))).is_equal(0)
	assert_bool(bool(hud.call("is_notification_visible"))).is_false()

	var player := scene.get_node("Player") as Node2D
	player.global_position.x = 1280.0
	scene.call("_process", 0.0)
	var service: Dictionary = Dictionary(
		scene.call("get_central_tower_minimap_diagnostics")
	)
	assert_str(String(service.get("current_area_id", ""))).is_equal(
		String(SERVICE_SPINE_ID)
	)
	assert_float(float(service.get("player_normalized_x", -1.0))).is_equal_approx(
		0.0,
		0.001
	)
	player.global_position.x = 1279.0
	scene.call("_process", 0.0)
	var returned: Dictionary = Dictionary(
		scene.call("get_central_tower_minimap_diagnostics")
	)
	assert_str(String(returned.get("current_area_id", ""))).is_equal(
		String(THRESHOLD_ID)
	)
	assert_float(float(returned.get("player_normalized_x", -1.0))).is_equal_approx(
		1279.0 / 1280.0,
		0.001
	)

	var restored_scene := _instantiate_tower_scene()
	assert_object(restored_scene).is_not_null()
	if restored_scene == null:
		return
	restored_scene.call("set_local_state", _completed_route_state())
	var restored: Dictionary = Dictionary(
		restored_scene.call("get_central_tower_minimap_diagnostics")
	)
	for region_id: StringName in [
		THRESHOLD_ID,
		SERVICE_SPINE_ID,
		COOLING_SHAFT_ID,
		DEEP_LIFT_ID,
		APEX_CONDUIT_ID,
	]:
		_assert_region_state(restored, region_id, true, 1.0)
	assert_int(int(restored.get("active_reveal_count", -1))).is_equal(0)
	assert_str(String(restored_scene.get_node("HUD").call(
		"get_notification_text"
	))).is_empty()
	assert_bool(restored_scene.call("get_local_state").has(
		"central_tower_explored_segment_max"
	)).is_false()
	var restored_player := restored_scene.get_node("Player") as Node2D
	restored_player.global_position.x = 6400.0
	restored_scene.call("_process", 0.0)
	var right_clamped: Dictionary = Dictionary(
		restored_scene.call("get_central_tower_minimap_diagnostics")
	)
	assert_str(String(right_clamped.get("current_area_id", ""))).is_equal(
		String(APEX_CONDUIT_ID)
	)
	assert_float(float(right_clamped.get("player_normalized_x", -1.0))).is_equal(
		1.0
	)
	restored_player.global_position.x = -1.0
	restored_scene.call("_process", 0.0)
	var left_clamped: Dictionary = Dictionary(
		restored_scene.call("get_central_tower_minimap_diagnostics")
	)
	assert_str(String(left_clamped.get("current_area_id", ""))).is_equal(
		String(THRESHOLD_ID)
	)
	assert_float(float(left_clamped.get("player_normalized_x", -1.0))).is_equal(
		0.0
	)


func _instantiate_tower_scene() -> Node2D:
	var packed := load(TOWER_SCENE_PATH) as PackedScene
	if packed == null:
		return null
	var scene := packed.instantiate() as Node2D
	add_child(scene)
	_nodes_to_free.append(scene)
	return scene


func _completed_route_state() -> Dictionary:
	return {
		"central_tower_threshold_guard_defeated": true,
		"central_tower_relay_mantis_defeated": true,
		"central_tower_cooling_shaft_traversed": true,
		"central_tower_deep_lift_ascended": true,
	}


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
