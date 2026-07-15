## Story 166: Real attack input drives Cinderpaw's three-stage light combo.
extends GdUnitTestSuite

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const ATTACK_ACTION: StringName = &"attack"
const ATTACK_ANIMATIONS: Array[StringName] = [&"attack", &"attack_2", &"attack_3"]
const ATTACK_SPEEDS: Dictionary = {
	&"attack": 15.0,
	&"attack_2": 10.0,
	&"attack_3": 6.0,
}

var player: PlayerController
var combat: CombatComponent
var sprite: AnimatedSprite2D


func before_test() -> void:
	Input.action_release(ATTACK_ACTION)
	player = PLAYER_SCENE.instantiate() as PlayerController
	add_child(player)
	combat = player.get_combat_component()
	sprite = player.get_node("Sprite") as AnimatedSprite2D


func after_test() -> void:
	Input.action_release(ATTACK_ACTION)
	if is_instance_valid(player):
		if player.get_parent() != null:
			player.get_parent().remove_child(player)
		player.free()
	player = null
	combat = null
	sprite = null


func test_real_input_drives_three_distinct_light_attack_stages() -> void:
	_assert_combo_animation_contract()

	await _press_attack_once()
	assert_int(combat.get_combo_index()).is_equal(0)
	assert_str(String(sprite.animation)).is_equal("attack")

	assert_bool(await _wait_for_recovery()).is_true()
	await _press_attack_once()
	assert_bool(await _wait_for_combo_index(1)).is_true()
	assert_int(combat.get_combo_index()).is_equal(1)
	assert_str(String(sprite.animation)).is_equal("attack_2")
	if combat.get_combo_index() != 1:
		return

	for _frame: int in range(8):
		await get_tree().physics_frame
	assert_int(combat.get_current_state()).is_equal(CombatComponent.CombatState.ATTACKING)
	assert_str(String(sprite.animation)).is_equal("attack_2")

	assert_bool(await _wait_for_recovery()).is_true()
	await _press_attack_once()
	assert_bool(await _wait_for_combo_index(2)).is_true()
	assert_int(combat.get_combo_index()).is_equal(2)
	assert_str(String(sprite.animation)).is_equal("attack_3")
	if combat.get_combo_index() != 2:
		return

	assert_bool(await _wait_for_recovery()).is_true()
	var frame_before_fourth_press: int = combat.get_attack_frame()
	await _press_attack_once()
	assert_int(combat.get_combo_index()).is_equal(2)
	assert_int(combat.get_attack_frame()).is_greater(frame_before_fourth_press)
	assert_str(String(sprite.animation)).is_equal("attack_3")

	assert_bool(await _wait_for_attack_end()).is_true()
	for _frame: int in range(20):
		await get_tree().physics_frame
	await _press_attack_once()
	assert_int(combat.get_combo_index()).is_equal(0)
	assert_str(String(sprite.animation)).is_equal("attack")


func test_holding_attack_does_not_auto_chain() -> void:
	Input.action_press(ATTACK_ACTION)
	await get_tree().physics_frame
	for _frame: int in range(35):
		await get_tree().physics_frame
	Input.action_release(ATTACK_ACTION)

	assert_int(combat.get_combo_index()).is_equal(0)
	assert_int(combat.get_current_state()).is_equal(CombatComponent.CombatState.IDLE)


func _assert_combo_animation_contract() -> void:
	assert_bool(sprite != null).is_true()
	assert_bool(sprite.sprite_frames != null).is_true()
	if sprite == null or sprite.sprite_frames == null:
		return
	assert_int(sprite.texture_filter).is_equal(CanvasItem.TEXTURE_FILTER_NEAREST)
	for animation_name: StringName in ATTACK_ANIMATIONS:
		assert_bool(sprite.sprite_frames.has_animation(animation_name)).is_true()
		assert_int(sprite.sprite_frames.get_frame_count(animation_name)).is_equal(3)
		assert_bool(sprite.sprite_frames.get_animation_loop(animation_name)).is_false()
		assert_float(sprite.sprite_frames.get_animation_speed(animation_name)).is_equal_approx(
			float(ATTACK_SPEEDS[animation_name]),
			0.001
		)
		for frame_index: int in range(3):
			var texture: Texture2D = sprite.sprite_frames.get_frame_texture(
				animation_name,
				frame_index
			)
			var expected_path: String = (
				"res://assets/characters/cinderpaw/%s/cinderpaw_%s_%03d.png"
				% [String(animation_name), String(animation_name), frame_index]
			)
			assert_object(texture).is_not_null()
			assert_str(texture.resource_path).is_equal(expected_path)
			assert_vector(texture.get_size()).is_equal(Vector2(96, 96))
			assert_float(texture.get_image().get_pixel(0, 0).a).is_equal(0.0)


func _press_attack_once() -> void:
	Input.action_press(ATTACK_ACTION)
	await get_tree().physics_frame
	Input.action_release(ATTACK_ACTION)
	await get_tree().process_frame


func _wait_for_recovery(max_frames: int = 45) -> bool:
	for _frame: int in range(max_frames):
		if combat.is_in_attack_recovery():
			return true
		await get_tree().physics_frame
	return false


func _wait_for_combo_index(target_index: int, max_frames: int = 45) -> bool:
	for _frame: int in range(max_frames):
		if combat.get_combo_index() == target_index:
			return true
		await get_tree().physics_frame
	return false


func _wait_for_attack_end(max_frames: int = 45) -> bool:
	for _frame: int in range(max_frames):
		if combat.get_current_state() == CombatComponent.CombatState.IDLE:
			return true
		await get_tree().physics_frame
	return false
