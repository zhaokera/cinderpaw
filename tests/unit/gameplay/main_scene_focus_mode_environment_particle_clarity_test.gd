## Story159 acceptance coverage for Main focus-mode environment clarity.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const DUST_MOTE_TEXTURE_PATH: String = (
	"res://assets/generated/combat_focus_environment_dust_mote.png"
)
const NORMAL_ALPHA: float = 1.0
const FOCUS_ALPHA: float = 0.30

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


func test_real_focus_signal_reduces_only_environment_particle_alpha() -> void:
	var player: Node = scene.get_node("Player")
	var health := player.get_node("HealthComponent") as HealthComponent
	var camera := player.get_node("Camera2D") as Camera2D
	var particles := scene.get_node_or_null(
		"FocusEnvironmentParticles"
	) as CPUParticles2D
	var camera_zoom: Vector2 = camera.zoom
	var camera_limits: Array[int] = [
		camera.limit_left,
		camera.limit_top,
		camera.limit_right,
		camera.limit_bottom,
	]

	assert_bool(ResourceLoader.exists(DUST_MOTE_TEXTURE_PATH)).is_true()
	assert_object(particles).is_not_null()
	assert_bool(
		particles != null
		and particles.has_method("get_focus_environment_diagnostics")
	).is_true()
	if (
		not ResourceLoader.exists(DUST_MOTE_TEXTURE_PATH)
		or particles == null
		or not particles.has_method("get_focus_environment_diagnostics")
	):
		return

	_assert_environment_diagnostics(
		Dictionary(particles.call("get_focus_environment_diagnostics")),
		false,
		NORMAL_ALPHA
	)
	health.set_active_enemy_count(2)
	health.apply_damage(75, {"source": &"story159_focus_entry"})

	assert_bool(health.is_focus_mode_active()).is_true()
	_assert_environment_diagnostics(
		Dictionary(particles.call("get_focus_environment_diagnostics")),
		true,
		FOCUS_ALPHA
	)
	_assert_camera_unchanged(camera, camera_zoom, camera_limits)

	health.heal(10)
	assert_bool(health.is_focus_mode_active()).is_false()
	_assert_environment_diagnostics(
		Dictionary(particles.call("get_focus_environment_diagnostics")),
		false,
		NORMAL_ALPHA
	)
	_assert_camera_unchanged(camera, camera_zoom, camera_limits)


func _assert_environment_diagnostics(
	diagnostics: Dictionary,
	focus_active: bool,
	expected_alpha: float
) -> void:
	assert_str(String(diagnostics.get("node_name", ""))).is_equal(
		"FocusEnvironmentParticles"
	)
	assert_str(String(diagnostics.get("node_type", ""))).is_equal(
		"CPUParticles2D"
	)
	assert_str(String(diagnostics.get("texture_path", ""))).is_equal(
		DUST_MOTE_TEXTURE_PATH
	)
	assert_bool(bool(diagnostics.get("focus_active", not focus_active))).is_equal(
		focus_active
	)
	assert_bool(bool(diagnostics.get("emitting", false))).is_true()
	assert_bool(bool(diagnostics.get("fixed_seed", false))).is_true()
	assert_int(int(diagnostics.get("amount", 0))).is_between(16, 32)
	assert_float(float(diagnostics.get("current_alpha", -1.0))).is_equal_approx(
		expected_alpha,
		0.001
	)
	assert_float(float(diagnostics.get("focus_alpha", -1.0))).is_equal_approx(
		FOCUS_ALPHA,
		0.001
	)


func _assert_camera_unchanged(
	camera: Camera2D,
	expected_zoom: Vector2,
	expected_limits: Array[int]
) -> void:
	assert_vector(camera.zoom).is_equal(expected_zoom)
	assert_array([
		camera.limit_left,
		camera.limit_top,
		camera.limit_right,
		camera.limit_bottom,
	]).is_equal(expected_limits)
