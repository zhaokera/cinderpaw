## Rat King specialized attack animation runtime contract.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const SPRITE_FRAMES_PATH: String = "res://assets/characters/rat_king/rat_king_sprite_frames.tres"
const PHASE_TWO_DAMAGE: int = 120
const PHASE_THREE_DAMAGE: int = 220
const SPECIALIZED_ATTACK_ANIMATIONS: Array[StringName] = [
	&"charge",
	&"claw_swipe",
	&"summon_minion",
	&"slam",
	&"berserk_combo",
]
const ATTACK_PATTERN_TO_HITBOX: Dictionary = {
	&"charge": &"rat_king_charge",
	&"claw_swipe": &"rat_king_claw",
	&"slam": &"rat_king_slam",
	&"berserk_combo": &"rat_king_berserk_combo",
}
const MIN_FRAMES_PER_ANIMATION: int = 3

var scene: Node2D


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_rat_king_sprite_frames_include_specialized_attack_sets() -> void:
	var sprite_frames: SpriteFrames = load(SPRITE_FRAMES_PATH) as SpriteFrames
	assert_object(sprite_frames).is_not_null()
	if sprite_frames == null:
		return

	for animation_name: StringName in SPECIALIZED_ATTACK_ANIMATIONS:
		assert_bool(sprite_frames.has_animation(animation_name)).is_true()
		if not sprite_frames.has_animation(animation_name):
			continue
		assert_int(sprite_frames.get_frame_count(animation_name)).is_greater_equal(
			MIN_FRAMES_PER_ANIMATION
		)
		assert_bool(_animation_frames_are_textured_distinct_and_same_size(
			sprite_frames,
			animation_name
		)).is_true()


func test_specialized_attack_assets_follow_project_pipeline_paths() -> void:
	for animation_name: StringName in SPECIALIZED_ATTACK_ANIMATIONS:
		for frame_index: int in range(MIN_FRAMES_PER_ANIMATION):
			var frame_path := "res://assets/characters/rat_king/%s/rat_king_%s_%03d.png" % [
				String(animation_name),
				String(animation_name),
				frame_index,
			]
			assert_bool(FileAccess.file_exists(frame_path)).is_true()


func test_all_rat_king_ai_pattern_ids_have_matching_animation_sets() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)

	var enemy := scene.get_node("Enemy")
	assert_bool(enemy.has_method("get_attack_animation_for_pattern")).is_true()
	if not enemy.has_method("get_attack_animation_for_pattern"):
		return
	for pattern_id: StringName in [&"charge", &"claw_swipe", &"slam", &"berserk_combo"]:
		assert_str(String(enemy.call("get_attack_animation_for_pattern", pattern_id))).is_equal(
			String(pattern_id)
		)

	assert_str(String(enemy.call("get_attack_animation_for_pattern", &"summon_minion"))).is_equal(
		"summon_minion"
	)


func test_charge_pattern_plays_charge_animation_and_preserves_hitbox_metadata() -> void:
	_assert_pattern_plays_animation_and_hitbox(&"charge", &"charge")


func test_claw_swipe_pattern_plays_claw_swipe_animation_and_preserves_hitbox_metadata() -> void:
	_assert_pattern_plays_animation_and_hitbox(&"claw_swipe", &"claw_swipe")


func test_phase_two_slam_pattern_plays_slam_animation_and_preserves_hitbox_metadata() -> void:
	_assert_pattern_plays_animation_and_hitbox(&"slam", &"slam", PHASE_TWO_DAMAGE)


func test_phase_three_berserk_combo_pattern_plays_berserk_combo_animation_and_preserves_hitbox_metadata() -> void:
	_assert_pattern_plays_animation_and_hitbox(&"berserk_combo", &"berserk_combo", PHASE_THREE_DAMAGE)


func test_summon_minion_special_attack_maps_to_animation_without_live_spawn_requirement() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)

	var enemy := scene.get_node("Enemy")
	assert_bool(enemy.has_method("play_special_attack_animation")).is_true()
	if not enemy.has_method("play_special_attack_animation"):
		return
	assert_bool(bool(enemy.call("play_special_attack_animation", &"summon_minion"))).is_true()
	assert_str(String(enemy.get_node("Sprite").get("animation"))).is_equal("summon_minion")


func _assert_pattern_plays_animation_and_hitbox(
	pattern_id: StringName,
	animation_name: StringName,
	damage_to_apply: int = 0
) -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)

	var enemy := scene.get_node("Enemy")
	if pattern_id == &"berserk_combo":
		_advance_enemy_to_phase_three(enemy)
	elif damage_to_apply > 0:
		var health: HealthComponent = enemy.call("get_health_component") as HealthComponent
		health.apply_damage(damage_to_apply, {"source": &"phase_test"})
		enemy.call("advance_boss_runtime", 0.0)
		enemy.call("advance_boss_runtime", 3.0)

	assert_bool(bool(enemy.call("request_attack_pattern", pattern_id))).is_true()
	assert_str(String(enemy.call("get_current_attack_pattern_id"))).is_equal(String(pattern_id))
	assert_str(String(enemy.get_node("Sprite").get("animation"))).is_equal(String(animation_name))

	var startup_frames: int = int(enemy.call("get_current_attack_startup_frames"))
	enemy.call("advance_attack_frames", startup_frames)

	var enemy_collision: CollisionComponent = enemy.call("get_collision_component") as CollisionComponent
	var expected_hitbox: StringName = ATTACK_PATTERN_TO_HITBOX[pattern_id]
	assert_bool(enemy_collision.is_hitbox_active(expected_hitbox)).is_true()
	assert_str(String(enemy.get_node("Sprite").get("animation"))).is_equal(String(animation_name))

	var hitbox := enemy_collision.get_hitbox(expected_hitbox)
	var metadata: Dictionary = hitbox.get_attack_metadata()
	assert_str(String(metadata.get("pattern_id", &""))).is_equal(String(pattern_id))
	assert_int(int(metadata.get("startup_frames", 0))).is_equal(startup_frames)
	assert_bool(metadata.has("vulnerability_window")).is_true()


func _advance_enemy_to_phase_three(enemy: Node) -> void:
	var health: HealthComponent = enemy.call("get_health_component") as HealthComponent
	health.apply_damage(PHASE_TWO_DAMAGE, {"source": &"phase_two_test"})
	enemy.call("advance_boss_runtime", 0.0)
	enemy.call("advance_boss_runtime", 3.0)
	health.apply_damage(100, {"source": &"phase_three_test"})
	enemy.call("advance_boss_runtime", 0.0)
	enemy.call("advance_boss_runtime", 3.0)


func _animation_frames_are_textured_distinct_and_same_size(
	sprite_frames: SpriteFrames,
	animation_name: StringName
) -> bool:
	var expected_size := Vector2.ZERO
	var first_texture: Texture2D = null
	for frame_index: int in range(sprite_frames.get_frame_count(animation_name)):
		var texture := sprite_frames.get_frame_texture(animation_name, frame_index)
		if texture == null:
			return false
		if first_texture == null:
			first_texture = texture
		elif texture == first_texture:
			return false
		var texture_size := texture.get_size()
		if expected_size == Vector2.ZERO:
			expected_size = texture_size
		elif texture_size != expected_size:
			return false
	return true
