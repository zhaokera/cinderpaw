## Scene Management Story 018: a real ACT encounter bridges onboarding and Rat King.
extends GdUnitTestSuite

const APPROACH_SCENE_PATH: String = (
	"res://scenes/areas/scrap_roost_rat_king_approach.tscn"
)
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const ATTACK_ACTION: StringName = &"attack"
const REQUIRED_ENEMY_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"patrol",
	&"attack_tell",
	&"attack",
	&"hurt",
	&"death",
]

var approach: Node2D


class FakeSceneManager:
	extends RefCounted

	var requests: Array[Dictionary] = []

	func has_scene(scene_id: StringName) -> bool:
		return scene_id == &"main"

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
	if is_instance_valid(approach):
		if approach.get_parent() != null:
			approach.get_parent().remove_child(approach)
		approach.free()
	approach = null


func test_shadow_beast_clear_opens_rat_king_savepoint_handoff() -> void:
	var packed_scene: PackedScene = load(APPROACH_SCENE_PATH) as PackedScene
	assert_object(packed_scene).is_not_null()
	if packed_scene == null:
		return

	approach = packed_scene.instantiate() as Node2D
	assert_object(approach).is_not_null()
	if approach == null:
		return
	approach.set("auto_configure_runtime_services", false)
	add_child(approach)
	var scene_manager := FakeSceneManager.new()
	assert_bool(bool(approach.call("configure_scene_manager_runtime", scene_manager))).is_true()
	await _wait_physics_frames(3)

	var player := approach.get_node_or_null("Player") as PlayerController
	var enemy := approach.get_node_or_null("ApproachShadowBeast") as SimpleEnemy
	var background := approach.get_node_or_null("Background") as TextureRect
	assert_object(player).is_not_null()
	assert_object(enemy).is_not_null()
	assert_object(background).is_not_null()
	if player == null or enemy == null or background == null:
		return
	assert_object(background.texture).is_not_null()
	if background.texture == null:
		return

	var initial: Dictionary = Dictionary(approach.call("get_approach_diagnostics"))
	assert_str(String(initial.get("scene_id", ""))).is_equal(
		"area_01_scrap_roost_rat_king_approach"
	)
	assert_bool(bool(initial.get("enemy_active", true))).is_false()
	assert_bool(bool(initial.get("enemy_defeated", true))).is_false()
	assert_bool(bool(initial.get("exit_unlocked", true))).is_false()
	assert_bool(bool(initial.get("rat_king_present", true))).is_false()
	assert_bool(enemy.is_physics_processing()).is_false()
	assert_array(scene_manager.requests).is_empty()
	assert_str(background.texture.resource_path).is_equal(
		"res://assets/environment/scrap_roost_rat_king_approach/"
		+ "scrap_roost_rat_king_approach_background_1280x720.png"
	)
	_assert_shadow_beast_frame_contract(enemy)

	Input.action_press(MOVE_RIGHT_ACTION)
	for _frame: int in range(110):
		await get_tree().physics_frame
		if bool(Dictionary(approach.call("get_approach_diagnostics")).get(
			"enemy_active",
			false
		)):
			break
	Input.action_release(MOVE_RIGHT_ACTION)

	var activated: Dictionary = Dictionary(approach.call("get_approach_diagnostics"))
	assert_bool(bool(activated.get("enemy_active", false))).is_true()
	assert_bool(enemy.is_physics_processing()).is_true()
	assert_bool(bool(enemy.call("request_attack"))).is_true()
	await get_tree().physics_frame
	var enemy_sprite := enemy.get_node_or_null("Sprite") as AnimatedSprite2D
	assert_object(enemy_sprite).is_not_null()
	if enemy_sprite != null:
		assert_str(String(enemy_sprite.animation)).is_equal("attack_tell")
	assert_bool(bool(activated.get("exit_unlocked", true))).is_false()
	assert_array(scene_manager.requests).is_empty()

	await _wait_physics_frames(30)
	assert_bool(await _move_player_into_attack_range(player, enemy)).is_true()
	var combat_delta_x: float = enemy.global_position.x - player.global_position.x
	assert_float(combat_delta_x).is_greater(0.0)
	assert_float(combat_delta_x).is_less_equal(44.0)
	assert_bool(await _defeat_enemy_with_real_attack_input(enemy)).is_true()
	var cleared: Dictionary = Dictionary(approach.call("get_approach_diagnostics"))
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
		"scene_id": "main",
		"spawn_point": "scrap_roost",
	}])


func _assert_shadow_beast_frame_contract(enemy: SimpleEnemy) -> void:
	var enemy_sprite := enemy.get_node_or_null("Sprite") as AnimatedSprite2D
	assert_object(enemy_sprite).is_not_null()
	if enemy_sprite == null:
		return
	assert_object(enemy_sprite.sprite_frames).is_not_null()
	if enemy_sprite.sprite_frames == null:
		return
	for animation_name: StringName in REQUIRED_ENEMY_ANIMATIONS:
		assert_bool(enemy_sprite.sprite_frames.has_animation(animation_name)).is_true()
		assert_int(enemy_sprite.sprite_frames.get_frame_count(animation_name)).is_greater_equal(3)


func _move_player_into_attack_range(player: PlayerController, enemy: SimpleEnemy) -> bool:
	for _frame: int in range(120):
		if not is_instance_valid(enemy):
			return false
		var delta_x: float = enemy.global_position.x - player.global_position.x
		if absf(delta_x) <= 40.0:
			_release_horizontal_actions()
			return true
		Input.action_press(MOVE_RIGHT_ACTION if delta_x > 0.0 else &"move_left")
		Input.action_release(&"move_left" if delta_x > 0.0 else MOVE_RIGHT_ACTION)
		await get_tree().physics_frame
	_release_horizontal_actions()
	return is_instance_valid(enemy) and absf(
		enemy.global_position.x - player.global_position.x
	) <= 44.0


func _defeat_enemy_with_real_attack_input(enemy: SimpleEnemy) -> bool:
	for _attempt: int in range(8):
		if not is_instance_valid(enemy) or enemy.get_current_hp() <= 0:
			return true
		Input.action_press(ATTACK_ACTION)
		await get_tree().physics_frame
		Input.action_release(ATTACK_ACTION)
		await _wait_physics_frames(16)
	return not is_instance_valid(enemy) or enemy.get_current_hp() <= 0


func _wait_physics_frames(frame_count: int) -> void:
	for _frame: int in range(frame_count):
		await get_tree().physics_frame


func _release_horizontal_actions() -> void:
	Input.action_release(&"move_left")
	Input.action_release(MOVE_RIGHT_ACTION)


func _release_gameplay_actions() -> void:
	_release_horizontal_actions()
	Input.action_release(ATTACK_ACTION)
