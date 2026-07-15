## Story 014: Rat King arena camera choreography acceptance.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const PHASE_TWO_DAMAGE: int = 120
const PHASE_THREE_DAMAGE: int = 100
const PHASE_TRANSITION_BUFFER_SEC: float = 3.0

var scene: Node2D


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_rat_king_camera_tightens_by_phase_then_releases_for_victory_hold() -> void:
	var camera := scene.get_node_or_null("Player/Camera2D") as Camera2D
	var enemy: Node = scene.get_node("Enemy")
	assert_that(camera).is_not_null()
	assert_bool(scene.has_method("refresh_rat_king_camera_choreography")).is_true()
	assert_bool(scene.has_method("get_rat_king_camera_choreography_diagnostics")).is_true()
	if (
		camera == null
		or not scene.has_method("refresh_rat_king_camera_choreography")
		or not scene.has_method("get_rat_king_camera_choreography_diagnostics")
	):
		return

	var phase_one: Dictionary = scene.call("get_rat_king_camera_choreography_diagnostics")
	assert_bool(bool(phase_one.get("enabled", false))).is_true()
	assert_str(String(phase_one.get("reason", ""))).is_equal("rat_king_phase_1")
	assert_int(int(phase_one.get("limit_right", 1280))).is_less(1280)
	assert_float(camera.zoom.x).is_greater(1.0)
	assert_vector(camera.offset).is_equal(Vector2.ZERO)

	var health := enemy.call("get_health_component") as HealthComponent
	assert_that(health).is_not_null()
	if health == null:
		return
	health.apply_damage(PHASE_TWO_DAMAGE, {"source": &"camera_choreography_test"})
	enemy.call("advance_boss_runtime", 0.0)
	var phase_two: Dictionary = scene.call("get_rat_king_camera_choreography_diagnostics")
	assert_int(int(phase_two.get("phase", 0))).is_equal(2)
	assert_float(float(phase_two.get("zoom", Vector2.ONE).x)).is_greater(
		float(phase_one.get("zoom", Vector2.ONE).x)
	)

	enemy.call("advance_boss_runtime", PHASE_TRANSITION_BUFFER_SEC)
	health.apply_damage(PHASE_THREE_DAMAGE, {"source": &"camera_choreography_test"})
	enemy.call("advance_boss_runtime", 0.0)
	var phase_three: Dictionary = scene.call("get_rat_king_camera_choreography_diagnostics")
	assert_int(int(phase_three.get("phase", 0))).is_equal(3)
	assert_float(float(phase_three.get("zoom", Vector2.ONE).x)).is_greater(
		float(phase_two.get("zoom", Vector2.ONE).x)
	)

	enemy.call("advance_boss_runtime", PHASE_TRANSITION_BUFFER_SEC)
	enemy.call("apply_damage", int(enemy.call("get_current_hp")), {
		"source": &"camera_choreography_test",
	})
	var released: Dictionary = scene.call("get_rat_king_camera_choreography_diagnostics")
	assert_bool(bool(released.get("enabled", true))).is_false()
	assert_str(String(released.get("reason", ""))).is_equal("rat_king_defeated")
	assert_int(camera.limit_right).is_equal(1280)
	assert_vector(camera.zoom).is_equal(Vector2.ONE)
	var handoff: Dictionary = scene.call("get_boss2_encounter_handoff_diagnostics")
	assert_str(String(handoff.get("game_flow_state", ""))).is_equal("victory_pending")
	assert_bool(bool(handoff.get("boss2_encounter_active", true))).is_false()
	assert_bool(bool(handoff.get("boss2_camera_lock_enabled", true))).is_false()
