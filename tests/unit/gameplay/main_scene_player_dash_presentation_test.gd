## Story 031: MainScene gives a successful Dash dedicated visual and audio feedback.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const DASH_ABILITY: StringName = &"dash"
const DASH_SPEED_LINE_TEXTURE_PATH: String = (
	"res://assets/generated/combat_dash_speed_lines.png"
)

var scene: Node2D


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	_clear_audio_system_players()
	scene = null


func test_successful_dash_routes_dedicated_afterimages_speed_lines_and_wind_sfx() -> void:
	var player := scene.get_node("Player") as PlayerController
	var sprite := player.get_node("Sprite") as AnimatedSprite2D
	var presentation := scene.get_node("CombatPresentation")
	var audio_system := get_node_or_null("/root/AudioSystem")

	assert_that(player).is_not_null()
	assert_that(sprite).is_not_null()
	assert_that(presentation).is_not_null()
	assert_that(audio_system).is_not_null()
	if player == null or sprite == null or presentation == null or audio_system == null:
		return

	scene.call("unlock_ability", DASH_ABILITY)
	assert_bool(player.request_dash()).is_true()
	assert_str(String(sprite.animation)).is_equal("dash")

	# The current generic bucket proves that Dash no longer falls through to Dodge.
	assert_int(presentation.get_active_afterimage_count()).is_equal(2)
	assert_array(presentation.get_last_afterimage_alphas()).is_equal([0.45, 0.25])
	var positions: Array[Vector2] = presentation.get_last_afterimage_positions()
	assert_int(positions.size()).is_equal(2)
	if positions.size() == 2:
		assert_bool(positions[0].x < sprite.global_position.x).is_true()
		assert_bool(positions[1].x < positions[0].x).is_true()

	var gameplay_audio: Dictionary = audio_system.get_last_gameplay_audio_event()
	assert_str(String(gameplay_audio.get("event_id", &""))).is_equal("dash")
	assert_str(String(gameplay_audio.get("sfx_id", &""))).is_equal("sfx_dash")
	assert_vector(gameplay_audio.get("position", Vector2.ZERO)).is_equal(sprite.global_position)
	var sfx_request: Dictionary = audio_system.get_last_sfx_request()
	assert_bool(bool(sfx_request.get("stream_found", false))).is_true()
	assert_str(audio_system.get_audio_stream_path(&"sfx_dash")).is_equal(
		"res://assets/audio/sfx/sfx_dash.wav"
	)
	assert_bool(
		audio_system.get_audio_stream_path(&"sfx_dash")
		!= audio_system.get_audio_stream_path(&"sfx_dodge")
	).is_true()

	for method_name: String in [
		"get_active_dash_afterimage_count",
		"get_active_dodge_afterimage_count",
		"get_active_dash_speed_line_count",
		"get_last_dash_speed_line_diagnostics",
	]:
		assert_bool(presentation.has_method(method_name)).is_true()
		if not presentation.has_method(method_name):
			return

	assert_int(presentation.call("get_active_dash_afterimage_count")).is_equal(2)
	assert_int(presentation.call("get_active_dodge_afterimage_count")).is_equal(0)
	assert_int(presentation.call("get_active_dash_speed_line_count")).is_equal(1)
	var speed_line: Dictionary = presentation.call("get_last_dash_speed_line_diagnostics")
	assert_str(String(speed_line.get("texture_path", ""))).is_equal(
		DASH_SPEED_LINE_TEXTURE_PATH
	)
	assert_bool(bool(speed_line.get("visible", false))).is_true()
	assert_float(float(speed_line.get("lifetime_sec", 0.0))).is_equal_approx(0.1, 0.001)
	assert_bool(bool(speed_line.get("flip_h", true))).is_false()
	assert_bool(float(speed_line.get("position", Vector2.ZERO).x) < sprite.global_position.x).is_true()

	presentation.advance_time(0.101)
	assert_int(presentation.call("get_active_dash_speed_line_count")).is_equal(0)
	await get_tree().process_frame
	var expired_speed_line: Dictionary = presentation.call(
		"get_last_dash_speed_line_diagnostics"
	)
	assert_bool(bool(expired_speed_line.get("visible", true))).is_false()
	assert_int(presentation.call("get_active_dash_afterimage_count")).is_equal(2)
	presentation.advance_time(0.067)
	assert_int(presentation.call("get_active_dash_afterimage_count")).is_equal(0)


func _clear_audio_system_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var audio_player := child as AudioStreamPlayer
			audio_player.stop()
			audio_player.stream = null
		elif child is AudioStreamPlayer2D:
			var audio_player_2d := child as AudioStreamPlayer2D
			audio_player_2d.stop()
			audio_player_2d.stream = null
