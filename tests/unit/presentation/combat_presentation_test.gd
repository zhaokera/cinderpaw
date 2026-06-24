## CombatPresentation feedback behavior tests.
extends GdUnitTestSuite

const COMBAT_PRESENTATION_SCRIPT: Script = preload("res://src/presentation/combat_presentation.gd")

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
