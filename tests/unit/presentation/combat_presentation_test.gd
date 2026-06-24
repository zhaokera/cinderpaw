## CombatPresentation feedback behavior tests.
extends GdUnitTestSuite

const COMBAT_PRESENTATION_SCRIPT: Script = preload("res://src/presentation/combat_presentation.gd")
const CINDERPAW_IDLE_TEXTURE: Texture2D = preload("res://assets/characters/cinderpaw/idle/cinderpaw_idle_000.png")

var presentation


func before_test() -> void:
	presentation = COMBAT_PRESENTATION_SCRIPT.new()
	add_child(presentation)


func after_test() -> void:
	if is_instance_valid(presentation):
		if presentation.get_parent() != null:
			presentation.get_parent().remove_child(presentation)
		presentation.free()
	presentation = null


func test_normal_hit_spawns_damage_number_sparks_hitstop_and_shake() -> void:
	presentation.on_hit_event({
		"damage": 12,
		"hit_position": Vector2(40, 50),
		"is_crit": false,
	})

	assert_int(presentation.get_active_damage_number_count()).is_equal(1)
	assert_int(presentation.get_active_spark_count()).is_between(5, 8)
	assert_int(presentation.get_hitstop_frames_remaining()).is_equal(3)
	assert_float(presentation.get_screen_shake_intensity()).is_equal_approx(2.0, 0.001)
	assert_str(presentation.get_last_damage_number_text()).is_equal("12")


func test_crit_hit_uses_larger_gold_feedback() -> void:
	presentation.on_hit_event({
		"damage": 36,
		"hit_position": Vector2(120, 80),
		"is_crit": true,
	})

	assert_int(presentation.get_active_spark_count()).is_between(10, 15)
	assert_int(presentation.get_hitstop_frames_remaining()).is_equal(6)
	assert_float(presentation.get_screen_shake_intensity()).is_equal_approx(5.0, 0.001)
	assert_str(presentation.get_last_damage_number_color().to_html(false)).is_equal("ecc94b")


func test_kill_event_uses_stronger_hitstop_and_debris() -> void:
	presentation.on_kill_event(2, Vector2(300, 400))

	assert_int(presentation.get_hitstop_frames_remaining()).is_equal(6)
	assert_float(presentation.get_screen_shake_intensity()).is_equal_approx(5.0, 0.001)
	assert_int(presentation.get_active_debris_count()).is_between(15, 20)


func test_hit_feedback_uses_textured_sprite_vfx_not_color_rect_blocks() -> void:
	presentation.on_hit_event({
		"damage": 12,
		"hit_position": Vector2(80, 90),
		"is_crit": false,
	})

	assert_int(presentation.get_active_spark_count()).is_between(5, 8)
	assert_int(_count_children_of_type("Sprite2D")).is_greater_equal(presentation.get_active_spark_count())
	assert_int(_count_children_of_type("ColorRect")).is_equal(0)
	assert_bool(_all_sprite_children_have_textures()).is_true()


func test_kill_debris_uses_textured_sprite_vfx_not_color_rect_blocks() -> void:
	presentation.on_kill_event(2, Vector2(300, 400))

	assert_int(presentation.get_active_debris_count()).is_between(15, 20)
	assert_int(_count_children_of_type("Sprite2D")).is_greater_equal(presentation.get_active_debris_count())
	assert_int(_count_children_of_type("ColorRect")).is_equal(0)
	assert_bool(_all_sprite_children_have_textures()).is_true()


func test_perfect_parry_spawns_flash_and_radial_textured_sparks() -> void:
	presentation.on_parry_event({
		"parry_type": &"perfect",
		"position": Vector2(220, 210),
	})

	assert_int(presentation.get_hitstop_frames_remaining()).is_equal(8)
	assert_float(presentation.get_screen_shake_intensity()).is_equal_approx(8.0, 0.001)
	assert_int(presentation.get_active_flash_count()).is_equal(1)
	assert_float(presentation.get_last_flash_alpha()).is_equal_approx(0.8, 0.001)
	assert_int(presentation.get_active_parry_spark_count()).is_between(20, 25)
	assert_int(_count_children_of_type("Sprite2D")).is_greater_equal(
		presentation.get_active_parry_spark_count()
	)
	assert_bool(_all_sprite_children_have_textures()).is_true()


func test_cat_claw_attack_spawns_three_textured_slash_trails() -> void:
	presentation.on_weapon_attack_event({
		"weapon_id": &"cat_claw",
		"attack_position": Vector2(100, 120),
		"facing": -1,
	})

	assert_int(presentation.get_active_trail_count()).is_equal(3)
	assert_int(_count_children_of_type("Sprite2D")).is_greater_equal(
		presentation.get_active_trail_count()
	)
	assert_bool(_all_sprite_children_have_textures()).is_true()


func test_non_cat_claw_attack_does_not_spawn_claw_trails() -> void:
	presentation.on_weapon_attack_event({
		"weapon_id": &"long_tail",
		"attack_position": Vector2(100, 120),
		"facing": 1,
	})

	assert_int(presentation.get_active_trail_count()).is_equal(0)


func test_dodge_event_spawns_three_textured_afterimages_with_gdd_alpha_steps() -> void:
	assert_bool(presentation.has_method("on_dodge_event")).is_true()
	assert_bool(presentation.has_method("get_active_afterimage_count")).is_true()
	assert_bool(presentation.has_method("get_last_afterimage_alphas")).is_true()
	assert_bool(presentation.has_method("get_last_afterimage_positions")).is_true()
	if (
		not presentation.has_method("on_dodge_event")
		or not presentation.has_method("get_active_afterimage_count")
		or not presentation.has_method("get_last_afterimage_alphas")
		or not presentation.has_method("get_last_afterimage_positions")
	):
		return

	presentation.on_dodge_event(CINDERPAW_IDLE_TEXTURE, Vector2(180, 220), -1.0)

	assert_int(presentation.get_active_afterimage_count()).is_equal(3)
	assert_array(presentation.get_last_afterimage_alphas()).is_equal([
		0.5,
		0.3,
		0.1,
	])
	assert_vector(presentation.get_last_afterimage_positions()[0]).is_equal(Vector2(180, 220))
	assert_int(_count_children_of_type("Sprite2D")).is_greater_equal(
		presentation.get_active_afterimage_count()
	)
	assert_bool(_all_sprite_children_have_textures()).is_true()


func test_effects_expire_after_their_lifetime() -> void:
	presentation.on_hit_event({
		"damage": 7,
		"hit_position": Vector2(40, 50),
	})

	presentation.advance_time(1.49)

	assert_int(presentation.get_active_damage_number_count()).is_equal(1)

	presentation.advance_time(0.03)

	assert_int(presentation.get_active_damage_number_count()).is_equal(0)


func _count_children_of_type(type_name: String) -> int:
	var count: int = 0
	for child: Node in presentation.get_children():
		if child.is_class(type_name):
			count += 1
	return count


func _all_sprite_children_have_textures() -> bool:
	for child: Node in presentation.get_children():
		var sprite: Sprite2D = child as Sprite2D
		if sprite != null and sprite.texture == null:
			return false
	return true
