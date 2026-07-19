## Scene Management Story028: visible Old Factory service-lift frame animation.
extends GdUnitTestSuite

const FACTORY_SCENE: PackedScene = preload(
	"res://scenes/factory_route_transition_shell.tscn"
)
const SERVICE_LIFT_NAME: String = "FactoryServiceLift"
const LIFT_ANIMATION_NAME: String = "LiftAnimation"
const PLAYER_NAME: String = "Player"
const CONSOLE_TEXTURE_PATH: String = (
	"res://assets/environment/old_factory_service_lift/factory_service_lift_console.png"
)
const SPRITE_FRAMES_PATH: String = (
	"res://assets/environment/old_factory_service_lift/"
	+ "factory_service_lift_sprite_frames.tres"
)
const REQUIRED_ANIMATIONS: Array[StringName] = [
	&"arrive",
	&"docked_idle",
	&"depart",
]

var _scene: Node


class FakeSceneManager:
	extends RefCounted

	var request_calls: Array[Dictionary] = []
	var loading: bool = false

	func has_scene(scene_id: StringName) -> bool:
		return scene_id in [&"main", &"area_03_factory"]

	func is_loading() -> bool:
		return loading

	func is_scene_locked() -> bool:
		return false

	func get_pending_scene() -> StringName:
		return &"main" if loading else &""

	func get_pending_spawn_point() -> StringName:
		return &"scrap_roost" if loading else &""

	func request_scene_change(
		scene_id: StringName,
		spawn_point: StringName = &"default"
	) -> bool:
		if loading or not has_scene(scene_id):
			return false
		request_calls.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		loading = true
		return true


func before_test() -> void:
	_scene = FACTORY_SCENE.instantiate()
	add_child(_scene)


func after_test() -> void:
	if is_instance_valid(_scene):
		if _scene.get_parent() != null:
			_scene.get_parent().remove_child(_scene)
		_scene.free()
	_scene = null
	_stop_runtime_audio_players()


func test_service_lift_plays_arrive_idle_and_depart_frame_states() -> void:
	var service_lift: Node2D = _scene.get_node_or_null(SERVICE_LIFT_NAME) as Node2D
	assert_that(service_lift).is_not_null()
	if service_lift == null:
		return
	var animation := service_lift.get_node_or_null(LIFT_ANIMATION_NAME) as AnimatedSprite2D
	assert_that(animation).is_not_null()
	if animation == null:
		return

	assert_that(animation.sprite_frames).is_not_null()
	if animation.sprite_frames == null:
		return
	assert_str(animation.sprite_frames.resource_path).is_equal(SPRITE_FRAMES_PATH)
	var frame_paths: Dictionary = {}
	for animation_name: StringName in REQUIRED_ANIMATIONS:
		assert_bool(animation.sprite_frames.has_animation(animation_name)).is_true()
		assert_int(animation.sprite_frames.get_frame_count(animation_name)).is_equal(3)
		for frame_index: int in range(3):
			var texture := animation.sprite_frames.get_frame_texture(
				animation_name,
				frame_index
			)
			assert_that(texture).is_not_null()
			if texture == null:
				continue
			assert_int(texture.get_width()).is_equal(384)
			assert_int(texture.get_height()).is_equal(384)
			frame_paths[texture.resource_path] = true
	assert_int(frame_paths.size()).is_equal(9)
	assert_bool(animation.sprite_frames.get_animation_loop(&"arrive")).is_false()
	assert_bool(animation.sprite_frames.get_animation_loop(&"docked_idle")).is_true()
	assert_bool(animation.sprite_frames.get_animation_loop(&"depart")).is_false()

	var console := service_lift.get_node_or_null("Visual") as Sprite2D
	assert_that(console).is_not_null()
	if console != null:
		assert_that(console.texture).is_not_null()
		assert_str(console.texture.resource_path).is_equal(CONSOLE_TEXTURE_PATH)
	assert_bool(animation.visible).is_false()

	var scene_manager := FakeSceneManager.new()
	assert_bool(bool(_scene.call("configure_scene_manager_runtime", scene_manager))).is_true()
	_scene.call("set_local_state", _available_service_lift_state())

	var arrived: Dictionary = _scene.call("get_factory_service_lift_diagnostics")
	assert_str(String(arrived.get("visual_state", ""))).is_equal("arrive")
	assert_str(String(arrived.get("visual_animation", ""))).is_equal("arrive")
	assert_bool(bool(arrived.get("visual_visible", false))).is_true()
	assert_bool(bool(arrived.get("visual_playing", false))).is_true()

	animation.emit_signal("animation_finished")
	var docked: Dictionary = _scene.call("get_factory_service_lift_diagnostics")
	assert_str(String(docked.get("visual_state", ""))).is_equal("docked_idle")
	assert_str(String(docked.get("visual_animation", ""))).is_equal("docked_idle")
	assert_bool(bool(docked.get("visual_playing", false))).is_true()

	var player := _scene.get_node_or_null(PLAYER_NAME) as Node2D
	assert_that(player).is_not_null()
	if player == null:
		return
	player.global_position = service_lift.global_position
	assert_bool(bool(_scene.call("try_activate_factory_service_lift", player))).is_true()

	var departing: Dictionary = _scene.call("get_factory_service_lift_diagnostics")
	assert_str(String(departing.get("visual_state", ""))).is_equal("depart")
	assert_str(String(departing.get("visual_animation", ""))).is_equal("depart")
	assert_bool(bool(departing.get("visual_playing", false))).is_true()
	assert_bool(bool(departing.get("exit_requested", false))).is_true()
	assert_str(String(departing.get("scene_manager_pending_scene", ""))).is_equal("main")
	assert_str(String(departing.get("scene_manager_pending_spawn_point", ""))).is_equal(
		"scrap_roost"
	)

	animation.stop()
	animation.frame = 2
	_scene.call("_sync_service_lift_state")
	var completed_departure: Dictionary = _scene.call(
		"get_factory_service_lift_diagnostics"
	)
	assert_str(String(completed_departure.get("visual_state", ""))).is_equal("depart")
	assert_bool(bool(completed_departure.get("visual_playing", true))).is_false()
	assert_int(int(completed_departure.get("visual_frame", -1))).is_equal(2)


func test_restored_exit_holds_depart_final_frame_without_replaying() -> void:
	var restored_state: Dictionary = _available_service_lift_state()
	restored_state["factory_service_lift_activated"] = true
	restored_state["factory_service_lift_exit_requested"] = true
	_scene.call("set_local_state", restored_state)

	var restored: Dictionary = _scene.call("get_factory_service_lift_diagnostics")
	assert_str(String(restored.get("visual_state", ""))).is_equal("depart")
	assert_str(String(restored.get("visual_animation", ""))).is_equal("depart")
	assert_bool(bool(restored.get("visual_playing", true))).is_false()
	assert_int(int(restored.get("visual_frame", -1))).is_equal(2)


func _available_service_lift_state() -> Dictionary:
	return {
		"encounter_cleared": true,
		"factory_deep_guard_activated": true,
		"factory_deep_guard_defeated": true,
		"factory_deep_route_cleared": true,
		"factory_spark_rat_activated": true,
		"factory_spark_rat_defeated": true,
		"factory_service_lift_activated": false,
		"factory_service_lift_exit_requested": false,
	}


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var audio_player := child as AudioStreamPlayer
			audio_player.stop()
			audio_player.stream = null
		if child is AudioStreamPlayer2D:
			var spatial_player := child as AudioStreamPlayer2D
			spatial_player.stop()
			spatial_player.stream = null
