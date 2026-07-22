## Player Abilities Story182: Sluice Matriarch chase spacing before attacks.
extends GdUnitTestSuite

const BOSS_SCENE_PATH: String = "res://src/gameplay/sluice_matriarch_boss.tscn"
const ATTACK_COMMIT_RANGE_PX: float = 300.0
const MAX_CHASE_FRAMES: int = 180


func test_far_target_is_chased_with_run_frames_before_attack_commit() -> void:
	var packed: PackedScene = load(BOSS_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return
	var boss: Node2D = auto_free(packed.instantiate()) as Node2D
	add_child(boss)
	boss.set_physics_process(false)
	boss.global_position = Vector2(930, 540)

	var target := Node2D.new()
	target.global_position = Vector2(260, 540)
	add_child(auto_free(target))
	boss.call("set_attack_target", target)

	var chase_api_ready: bool = (
		boss.has_method("advance_chase_frames")
		and boss.has_method("get_chase_diagnostics")
	)
	assert_bool(chase_api_ready).is_true()
	if not chase_api_ready:
		return

	var initial_distance: float = absf(boss.global_position.x - target.global_position.x)
	boss.call("advance_chase_frames", 1)
	var chase: Dictionary = boss.call("get_chase_diagnostics")
	assert_str(String(chase.get("behavior_state", ""))).is_equal("chase")
	assert_str(String(chase.get("animation", ""))).is_equal("run")
	assert_float(float(chase.get("target_distance_px", initial_distance))).is_less(
		initial_distance
	)
	assert_float(float(chase.get("velocity_x", 0.0))).is_less(0.0)
	assert_str(String(boss.call("get_attack_phase"))).is_equal("idle")

	var attack_started: bool = false
	var attack_distance: float = initial_distance
	for _frame: int in range(MAX_CHASE_FRAMES):
		boss.call("advance_chase_frames", 1)
		if String(boss.call("get_attack_phase")) != "startup":
			continue
		attack_started = true
		attack_distance = absf(boss.global_position.x - target.global_position.x)
		break

	assert_bool(attack_started).is_true()
	assert_float(attack_distance).is_less_equal(ATTACK_COMMIT_RANGE_PX + 1.0)
	var startup: Dictionary = boss.call("get_attack_diagnostics")
	assert_str(String(startup.get("current_attack_id", ""))).is_equal("pressure_lunge")
	assert_str(String(startup.get("animation", ""))).is_equal("attack_tell")
	assert_bool(bool(startup.get("hitbox_active", true))).is_false()

	boss.call("reset_encounter")
	boss.call("apply_damage", 61, {"source": &"story182_phase_two"})
	boss.call("advance_phase_transition", 2.5)
	boss.global_position = Vector2(930, 540)
	boss.call("advance_chase_frames", 1)
	var phase_two_chase: Dictionary = boss.call("get_chase_diagnostics")
	assert_str(String(phase_two_chase.get("behavior_state", ""))).is_equal("chase")
	assert_float(float(phase_two_chase.get("chase_speed_px_sec", 0.0))).is_greater(
		float(phase_two_chase.get("phase_one_chase_speed_px_sec", 0.0))
	)
