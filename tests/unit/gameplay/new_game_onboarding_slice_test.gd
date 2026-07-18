## Scene Management Story 016: New Game teaches movement and ordinary combat first.
extends GdUnitTestSuite

const ONBOARDING_SCENE_PATH: String = (
	"res://scenes/areas/scrap_roost_hunt_initiation.tscn"
)
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const JUMP_ACTION: StringName = &"jump"
const ATTACK_ACTION: StringName = &"attack"

var onboarding: Node2D


class FakeSceneManager:
	extends RefCounted

	var requests: Array[Dictionary] = []

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == &"area_01_scrap_roost_dodge_trial"

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
	if is_instance_valid(onboarding):
		if onboarding.get_parent() != null:
			onboarding.get_parent().remove_child(onboarding)
		onboarding.free()
	onboarding = null


func test_new_game_requires_real_move_jump_and_one_enemy_defeat_before_rat_king_intro() -> void:
	var packed_scene: PackedScene = load(ONBOARDING_SCENE_PATH) as PackedScene
	assert_object(packed_scene).is_not_null()
	if packed_scene == null:
		return

	onboarding = packed_scene.instantiate() as Node2D
	assert_object(onboarding).is_not_null()
	if onboarding == null:
		return
	onboarding.set("auto_configure_runtime_services", false)
	add_child(onboarding)
	var scene_manager := FakeSceneManager.new()
	assert_bool(bool(onboarding.call("configure_scene_manager_runtime", scene_manager))).is_true()
	await _wait_physics_frames(3)

	var player := onboarding.get_node_or_null("Player") as PlayerController
	var enemy: Node2D = onboarding.get_node_or_null("OnboardingRat") as Node2D
	assert_object(player).is_not_null()
	assert_object(enemy).is_not_null()
	if player == null or enemy == null:
		return

	var initial: Dictionary = Dictionary(onboarding.call("get_onboarding_diagnostics"))
	assert_bool(bool(initial.get("enemy_active", true))).is_false()
	assert_bool(bool(initial.get("enemy_defeated", true))).is_false()
	assert_bool(bool(initial.get("exit_unlocked", true))).is_false()
	assert_bool(bool(initial.get("rat_king_present", true))).is_false()
	assert_bool(enemy.is_physics_processing()).is_false()
	assert_array(scene_manager.requests).is_empty()

	var start_position: Vector2 = player.global_position
	var highest_y: float = start_position.y
	Input.action_press(MOVE_RIGHT_ACTION)
	for frame_index: int in range(125):
		if frame_index == 28:
			Input.action_press(JUMP_ACTION)
		elif frame_index == 29:
			Input.action_release(JUMP_ACTION)
		await get_tree().physics_frame
		highest_y = minf(highest_y, player.global_position.y)
	Input.action_release(MOVE_RIGHT_ACTION)

	var activated: Dictionary = Dictionary(onboarding.call("get_onboarding_diagnostics"))
	assert_bool(player.global_position.x > start_position.x + 240.0).is_true()
	assert_bool(highest_y < start_position.y - 36.0).is_true()
	assert_bool(bool(activated.get("safe_runway_crossed", false))).is_true()
	assert_bool(bool(activated.get("enemy_active", false))).is_true()
	assert_bool(enemy.is_physics_processing()).is_true()
	assert_array(scene_manager.requests).is_empty()

	assert_bool(await _move_player_into_attack_range(player, enemy)).is_true()
	assert_bool(await _defeat_enemy_with_real_attack_input(enemy)).is_true()
	var cleared: Dictionary = Dictionary(onboarding.call("get_onboarding_diagnostics"))
	assert_bool(bool(cleared.get("enemy_defeated", false))).is_true()
	assert_bool(bool(cleared.get("exit_unlocked", false))).is_true()
	assert_array(scene_manager.requests).is_empty()

	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(180):
		await get_tree().physics_frame
		if not scene_manager.requests.is_empty():
			break
	Input.action_release(MOVE_RIGHT_ACTION)
	assert_array(scene_manager.requests).is_equal([{
		"scene_id": "area_01_scrap_roost_dodge_trial",
		"spawn_point": "default",
	}])


func _move_player_into_attack_range(player: PlayerController, enemy: Node2D) -> bool:
	for _frame: int in range(90):
		var delta_x: float = enemy.global_position.x - player.global_position.x
		if absf(delta_x) <= 48.0:
			_release_horizontal_actions()
			return true
		Input.action_press(MOVE_RIGHT_ACTION if delta_x > 0.0 else &"move_left")
		Input.action_release(&"move_left" if delta_x > 0.0 else MOVE_RIGHT_ACTION)
		await get_tree().physics_frame
	_release_horizontal_actions()
	return absf(enemy.global_position.x - player.global_position.x) <= 58.0


func _defeat_enemy_with_real_attack_input(enemy: Node2D) -> bool:
	for _attempt: int in range(7):
		if not is_instance_valid(enemy) or int(enemy.call("get_current_hp")) <= 0:
			return true
		Input.action_press(ATTACK_ACTION)
		await get_tree().physics_frame
		Input.action_release(ATTACK_ACTION)
		await _wait_physics_frames(16)
	return not is_instance_valid(enemy) or int(enemy.call("get_current_hp")) <= 0


func _wait_physics_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().physics_frame


func _release_horizontal_actions() -> void:
	Input.action_release(&"move_left")
	Input.action_release(MOVE_RIGHT_ACTION)


func _release_gameplay_actions() -> void:
	_release_horizontal_actions()
	Input.action_release(JUMP_ACTION)
	Input.action_release(ATTACK_ACTION)
