## Player Abilities Story184: Crown Warden closes the opening gap before attacking.
extends GdUnitTestSuite

const BOSS_SCENE_PATH: String = "res://src/gameplay/crown_warden_boss.tscn"
const BOSS_OPENING_POSITION: Vector2 = Vector2(900, 540)
const PLAYER_OPENING_POSITION: Vector2 = Vector2(220, 540)
const ATTACK_COMMIT_DISTANCE_PX: float = 190.0
const MAX_APPROACH_FRAMES: int = 360


func test_far_target_is_approached_before_first_autonomous_attack() -> void:
	var packed: PackedScene = load(BOSS_SCENE_PATH) as PackedScene
	assert_that(packed).is_not_null()
	if packed == null:
		return
	var boss: CharacterBody2D = auto_free(packed.instantiate()) as CharacterBody2D
	boss.global_position = BOSS_OPENING_POSITION
	add_child(boss)
	boss.set_physics_process(false)

	var target := Node2D.new()
	target.global_position = PLAYER_OPENING_POSITION
	add_child(auto_free(target))
	boss.call("set_attack_target", target)

	var initial_distance: float = absf(
		boss.global_position.x - target.global_position.x
	)
	boss.call("_process_idle")
	var opening: Dictionary = boss.call("get_attack_diagnostics")
	var entered_approach: bool = (
		String(opening.get("attack_phase", "")) == "idle"
		and String(opening.get("locomotion_state", "")) == "approach"
		and String(opening.get("animation", "")) == "run"
		and absf(boss.global_position.x - target.global_position.x) < initial_distance
		and not bool(opening.get("hitbox_active", true))
	)
	assert_bool(entered_approach).override_failure_message(
		"A far opening target must enter run/approach before attack startup"
	).is_true()
	if not entered_approach:
		return
	assert_float(float(opening.get("target_distance_px", initial_distance))).is_less(
		initial_distance
	)
	assert_float(float(opening.get("attack_commit_distance_px", 0.0))).is_equal(
		ATTACK_COMMIT_DISTANCE_PX
	)
	assert_float(float(opening.get("velocity_x", 0.0))).is_less(0.0)

	var attack_started: bool = false
	var attack_distance: float = initial_distance
	for _frame: int in range(MAX_APPROACH_FRAMES):
		boss.call("_physics_process", 1.0 / 60.0)
		var diagnostics: Dictionary = boss.call("get_attack_diagnostics")
		if String(diagnostics.get("attack_phase", "")) != "startup":
			continue
		attack_started = true
		attack_distance = absf(boss.global_position.x - target.global_position.x)
		break

	assert_bool(attack_started).is_true()
	assert_float(attack_distance).is_less_equal(ATTACK_COMMIT_DISTANCE_PX + 1.0)
	var startup: Dictionary = boss.call("get_attack_diagnostics")
	assert_str(String(startup.get("current_attack_id", ""))).is_equal("talon_dive")
	assert_str(String(startup.get("animation", ""))).is_equal("talon_dive_tell")
	assert_bool(bool(startup.get("hitbox_active", true))).is_false()

	boss.call("reset_encounter")
	boss.call("set_autonomous_attacks_enabled", false)
	assert_bool(bool(boss.call("request_attack", &"wing_sweep"))).is_true()
	var explicit: Dictionary = boss.call("get_attack_diagnostics")
	assert_str(String(explicit.get("attack_phase", ""))).is_equal("startup")
	assert_str(String(explicit.get("current_attack_id", ""))).is_equal("wing_sweep")
