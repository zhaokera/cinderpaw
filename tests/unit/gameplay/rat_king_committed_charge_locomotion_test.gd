## Player Abilities Story178: Rat King charge closes space with committed motion.
extends GdUnitTestSuite

const RAT_KING_BOSS_SCENE: PackedScene = preload(
	"res://src/gameplay/rat_king_boss.tscn"
)
const CHARGE_PATTERN_ID: StringName = &"charge"
const CHARGE_HITBOX_ID: StringName = &"rat_king_charge"
const AUTHORED_OPENING_DISTANCE_PX: float = 260.0
const MIN_FOUR_FRAME_DISPLACEMENT_PX: float = 24.0

var _boss: CharacterBody2D
var _target: Node2D


func before_test() -> void:
	_boss = RAT_KING_BOSS_SCENE.instantiate() as CharacterBody2D
	_target = Node2D.new()
	add_child(_boss)
	add_child(_target)
	_boss.global_position = Vector2(560.0, 456.0)
	_target.global_position = Vector2(
		_boss.global_position.x - AUTHORED_OPENING_DISTANCE_PX,
		_boss.global_position.y
	)
	_boss.call("set_attack_target", _target)


func after_test() -> void:
	if is_instance_valid(_target):
		_target.free()
	if is_instance_valid(_boss):
		_boss.free()
	_target = null
	_boss = null
	_stop_runtime_audio_players()


func test_charge_acquires_distant_target_and_commits_forward_motion() -> void:
	var opening_delta_x: float = _target.global_position.x - _boss.global_position.x
	assert_float(absf(opening_delta_x)).is_equal_approx(
		AUTHORED_OPENING_DISTANCE_PX,
		0.01
	)

	_boss.call("_process_idle", 1.0 / 60.0)
	var auto_pattern: StringName = StringName(
		_boss.call("get_current_attack_pattern_id")
	)
	assert_str(String(auto_pattern)).is_equal(String(CHARGE_PATTERN_ID))
	if auto_pattern != CHARGE_PATTERN_ID:
		assert_bool(bool(_boss.call(
			"request_attack_pattern",
			CHARGE_PATTERN_ID
		))).is_true()

	var start_position: Vector2 = _boss.global_position
	var startup_frames: int = int(_boss.call("get_current_attack_startup_frames"))
	assert_int(startup_frames).is_equal(20)

	# The charge commits left at startup; moving the target right cannot retarget it.
	_target.global_position = Vector2(
		_boss.global_position.x + AUTHORED_OPENING_DISTANCE_PX,
		_boss.global_position.y
	)
	_boss.call("advance_attack_frames", startup_frames + 4)

	var displacement_x: float = _boss.global_position.x - start_position.x
	assert_float(displacement_x).is_less_equal(-MIN_FOUR_FRAME_DISPLACEMENT_PX)
	assert_str(String(_boss.call("get_attack_phase"))).is_equal("active")
	assert_float(_boss.velocity.x).is_less(0.0)

	var collision: CollisionComponent = (
		_boss.call("get_collision_component") as CollisionComponent
	)
	assert_object(collision).is_not_null()
	if collision != null:
		assert_bool(collision.is_hitbox_active(CHARGE_HITBOX_ID)).is_true()

	assert_bool(_boss.has_method("get_charge_locomotion_diagnostics")).is_true()
	if _boss.has_method("get_charge_locomotion_diagnostics"):
		var diagnostics: Dictionary = _boss.call(
			"get_charge_locomotion_diagnostics"
		)
		assert_bool(bool(diagnostics.get("loaded_from_data", false))).is_true()
		assert_float(float(diagnostics.get("lunge_speed", 0.0))).is_greater(0.0)
		assert_float(float(diagnostics.get("acquire_range_px", 0.0))).is_greater_equal(
			AUTHORED_OPENING_DISTANCE_PX
		)
		assert_float(float(diagnostics.get("locked_direction", 0.0))).is_equal(-1.0)
		assert_float(float(diagnostics.get("distance_px", 0.0))).is_greater_equal(
			MIN_FOUR_FRAME_DISPLACEMENT_PX
		)


func _stop_runtime_audio_players() -> void:
	var audio_system := get_node_or_null("/root/AudioSystem")
	if audio_system == null:
		return
	for child: Node in audio_system.get_children():
		if child is AudioStreamPlayer:
			var audio_player := child as AudioStreamPlayer
			audio_player.stop()
			audio_player.stream = null
		elif child is AudioStreamPlayer2D:
			var spatial_player := child as AudioStreamPlayer2D
			spatial_player.stop()
			spatial_player.stream = null
