## Story157 acceptance coverage for the Main low-HP focus windup advantage.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const FOCUS_DAMAGE: int = 75
const FOCUS_WINDUP_EXTENSION_FRAMES: int = 6

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


func test_real_focus_signal_extends_only_new_main_boss_windups() -> void:
	var player: Node = scene.get_node("Player")
	var health := player.get_node("HealthComponent") as HealthComponent
	var rat_king: Node = scene.get_node("Enemy")
	var echo_guardian: Node = scene.get_node("Boss2EchoGuardian")

	assert_object(health).is_not_null()
	assert_bool(scene.has_method("get_focus_mode_enemy_windup_diagnostics")).is_true()
	assert_bool(rat_king.has_method("set_target_focus_mode")).is_true()
	assert_bool(echo_guardian.has_method("set_target_focus_mode")).is_true()
	if (
		health == null
		or not scene.has_method("get_focus_mode_enemy_windup_diagnostics")
		or not rat_king.has_method("set_target_focus_mode")
		or not echo_guardian.has_method("set_target_focus_mode")
	):
		return

	echo_guardian.call("set_encounter_active", true, player)
	health.set_active_enemy_count(2)
	health.apply_damage(FOCUS_DAMAGE, {"source": &"story157_focus_entry"})

	assert_bool(health.is_focus_mode_active()).is_true()
	assert_bool(bool(rat_king.call("request_attack_pattern", &"claw_swipe"))).is_true()
	assert_bool(bool(echo_guardian.call("request_attack"))).is_true()

	var rat_focus_startup: int = int(rat_king.call("get_current_attack_startup_frames"))
	var echo_focus_startup: int = int(echo_guardian.call("get_current_attack_startup_frames"))
	assert_int(rat_focus_startup).is_equal(21)
	assert_int(echo_focus_startup).is_equal(14)

	var diagnostics: Dictionary = Dictionary(
		scene.call("get_focus_mode_enemy_windup_diagnostics")
	)
	assert_bool(bool(diagnostics.get("player_focus_active", false))).is_true()
	_assert_focus_diagnostics(
		Dictionary(diagnostics.get("rat_king", {})),
		15,
		rat_focus_startup
	)
	_assert_focus_diagnostics(
		Dictionary(diagnostics.get("echo_guardian", {})),
		8,
		echo_focus_startup
	)

	health.heal(10)
	assert_bool(health.is_focus_mode_active()).is_false()
	assert_int(int(rat_king.call("get_current_attack_startup_frames"))).is_equal(
		rat_focus_startup
	)
	assert_int(int(echo_guardian.call("get_current_attack_startup_frames"))).is_equal(
		echo_focus_startup
	)

	diagnostics = Dictionary(scene.call("get_focus_mode_enemy_windup_diagnostics"))
	assert_bool(bool(diagnostics.get("player_focus_active", true))).is_false()
	assert_int(int(Dictionary(diagnostics.get("rat_king", {})).get(
		"windup_extension_frames",
		-1
	))).is_equal(0)
	assert_int(int(Dictionary(diagnostics.get("echo_guardian", {})).get(
		"windup_extension_frames",
		-1
	))).is_equal(0)


func _assert_focus_diagnostics(
	diagnostics: Dictionary,
	base_startup_frames: int,
	current_startup_frames: int
) -> void:
	assert_bool(bool(diagnostics.get("focus_mode_active", false))).is_true()
	assert_int(int(diagnostics.get("base_startup_frames", 0))).is_equal(
		base_startup_frames
	)
	assert_int(int(diagnostics.get("windup_extension_frames", 0))).is_equal(
		FOCUS_WINDUP_EXTENSION_FRAMES
	)
	assert_int(int(diagnostics.get("current_attack_startup_frames", 0))).is_equal(
		current_startup_frames
	)
