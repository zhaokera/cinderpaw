## Scene Management Story 017: the third onboarding room requires a real dodge.
extends GdUnitTestSuite

const DODGE_TRIAL_SCENE_PATH: String = (
	"res://scenes/areas/scrap_roost_dodge_trial.tscn"
)
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const DODGE_ACTION: StringName = &"dodge"

var dodge_trial: Node2D


class FakeSceneManager:
	extends RefCounted

	var requests: Array[Dictionary] = []

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == &"area_01_scrap_roost_rat_king_approach"

	func request_scene_change(scene_id: StringName, spawn_point: StringName) -> bool:
		if not has_scene(scene_id):
			return false
		requests.append({
			"scene_id": String(scene_id),
			"spawn_point": String(spawn_point),
		})
		return true


func after_test() -> void:
	_release_gameplay_actions()
	if is_instance_valid(dodge_trial):
		if dodge_trial.get_parent() != null:
			dodge_trial.get_parent().remove_child(dodge_trial)
		dodge_trial.free()
	dodge_trial = null


func test_real_dodge_through_active_exhaust_unlocks_main_handoff() -> void:
	var packed_scene: PackedScene = load(DODGE_TRIAL_SCENE_PATH) as PackedScene
	assert_object(packed_scene).is_not_null()
	if packed_scene == null:
		return

	dodge_trial = packed_scene.instantiate() as Node2D
	assert_object(dodge_trial).is_not_null()
	if dodge_trial == null:
		return
	dodge_trial.set("auto_configure_runtime_services", false)
	add_child(dodge_trial)
	var scene_manager := FakeSceneManager.new()
	assert_bool(bool(dodge_trial.call(
		"configure_scene_manager_runtime",
		scene_manager,
	))).is_true()
	await _wait_physics_frames(3)

	var player := dodge_trial.get_node_or_null("Player") as PlayerController
	var hazard := dodge_trial.get_node_or_null("DodgeExhaust") as Area2D
	assert_object(player).is_not_null()
	assert_object(hazard).is_not_null()
	if player == null or hazard == null:
		return
	var animation := hazard.get_node_or_null("SteamAnimation") as AnimatedSprite2D
	assert_object(animation).is_not_null()
	if animation == null:
		return

	var initial: Dictionary = Dictionary(dodge_trial.call("get_dodge_trial_diagnostics"))
	assert_bool(bool(initial.get("trial_complete", true))).is_false()
	assert_bool(bool(initial.get("exit_unlocked", true))).is_false()
	assert_bool(bool(initial.get("rat_king_present", true))).is_false()
	assert_int(int(initial.get("safe_frames", 0))).is_greater_equal(3)
	assert_int(int(initial.get("warning_frames", 0))).is_greater_equal(3)
	assert_int(int(initial.get("active_frames", 0))).is_greater_equal(3)
	assert_array(scene_manager.requests).is_empty()

	assert_bool(await _move_player_to_staging_position(player)).is_true()
	var staged: Dictionary = Dictionary(
		dodge_trial.call("get_dodge_trial_diagnostics")
	)
	assert_bool(await _wait_for_new_active_sequence(
		int(staged.get("active_sequence_id", -1)),
		240,
	)).is_true()
	var hp_before_walk: int = player.get_current_hp()
	var walk_damage_observed: bool = false
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(30):
		await get_tree().physics_frame
		if player.get_current_hp() < hp_before_walk:
			walk_damage_observed = true
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	assert_bool(walk_damage_observed).is_true()
	assert_int(player.get_current_hp()).is_equal(hp_before_walk - 8)
	var failed_crossing: Dictionary = Dictionary(
		dodge_trial.call("get_dodge_trial_diagnostics")
	)
	assert_int(int(failed_crossing.get("damage_events", 0))).is_equal(1)
	assert_bool(bool(failed_crossing.get("trial_complete", true))).is_false()
	assert_bool(bool(failed_crossing.get("exit_unlocked", true))).is_false()
	assert_array(scene_manager.requests).is_empty()

	var failed_sequence_id: int = int(
		failed_crossing.get("active_sequence_id", -1)
	)
	assert_bool(await _move_player_left_of_hazard(player)).is_true()
	assert_bool(await _wait_for_new_active_sequence(failed_sequence_id, 240)).is_true()
	var hp_before_dodge: int = player.get_current_hp()
	Input.action_press(MOVE_RIGHT_ACTION)
	Input.action_press(DODGE_ACTION)
	await get_tree().physics_frame
	Input.action_release(DODGE_ACTION)

	var trial_complete: bool = false
	for _frame: int in range(45):
		await get_tree().physics_frame
		var diagnostics: Dictionary = Dictionary(
			dodge_trial.call("get_dodge_trial_diagnostics")
		)
		if bool(diagnostics.get("trial_complete", false)):
			trial_complete = true
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	assert_bool(trial_complete).is_true()
	assert_int(player.get_current_hp()).is_equal(hp_before_dodge)

	var cleared: Dictionary = Dictionary(dodge_trial.call("get_dodge_trial_diagnostics"))
	assert_bool(bool(cleared.get("dodge_overlap_confirmed", false))).is_true()
	assert_bool(bool(cleared.get("exit_unlocked", false))).is_true()
	assert_str(String(cleared.get("hazard_phase", ""))).is_equal("crossed")
	assert_array(scene_manager.requests).is_empty()

	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(180):
		await get_tree().physics_frame
		if not scene_manager.requests.is_empty():
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	assert_array(scene_manager.requests).is_equal([{
		"scene_id": "area_01_scrap_roost_rat_king_approach",
		"spawn_point": "default",
	}])


func _move_player_to_staging_position(player: PlayerController) -> bool:
	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(150):
		await get_tree().physics_frame
		if player.global_position.x >= 590.0:
			Input.action_release(MOVE_RIGHT_ACTION)
			return true
	Input.action_release(MOVE_RIGHT_ACTION)
	return player.global_position.x >= 590.0


func _move_player_left_of_hazard(player: PlayerController) -> bool:
	Input.action_press(&"move_left")
	for _frame: int in range(60):
		await get_tree().physics_frame
		if player.global_position.x <= 570.0:
			Input.action_release(&"move_left")
			return true
	Input.action_release(&"move_left")
	return player.global_position.x <= 570.0


func _wait_for_hazard_phase(expected_phase: String, max_frames: int) -> bool:
	for _frame: int in range(max_frames):
		var diagnostics: Dictionary = Dictionary(
			dodge_trial.call("get_dodge_trial_diagnostics")
		)
		if String(diagnostics.get("hazard_phase", "")) == expected_phase:
			return true
		await get_tree().physics_frame
	return false


func _wait_for_new_active_sequence(
	previous_sequence_id: int,
	max_frames: int
) -> bool:
	for _frame: int in range(max_frames):
		var diagnostics: Dictionary = Dictionary(
			dodge_trial.call("get_dodge_trial_diagnostics")
		)
		if (
			String(diagnostics.get("hazard_phase", "")) == "active"
			and int(diagnostics.get("active_sequence_id", -1)) > previous_sequence_id
		):
			return true
		await get_tree().physics_frame
	return false


func _wait_physics_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().physics_frame


func _release_gameplay_actions() -> void:
	Input.action_release(&"move_left")
	Input.action_release(MOVE_RIGHT_ACTION)
	Input.action_release(DODGE_ACTION)
