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


func test_damage_number_tiers_match_gdd_size_color_and_outline() -> void:
	var cases: Array[Dictionary] = [
		{"damage": 1, "font_size": 12, "color": "ffffff", "outline": 0},
		{"damage": 6, "font_size": 16, "color": "ffffff", "outline": 0},
		{"damage": 16, "font_size": 20, "color": "facc15", "outline": 0},
		{"damage": 31, "font_size": 28, "color": "f59e0b", "outline": 0},
		{"damage": 61, "font_size": 36, "color": "ecc94b", "outline": 0},
		{"damage": 151, "font_size": 48, "color": "ecc94b", "outline": 2},
	]

	for damage_case: Dictionary in cases:
		presentation.on_hit_event({
			"damage": int(damage_case["damage"]),
			"hit_position": Vector2(120, 80),
			"is_crit": false,
		})
		var label := _latest_damage_label()

		assert_object(label).is_not_null()
		assert_int(label.get_theme_font_size("font_size")).is_equal(int(damage_case["font_size"]))
		assert_str(label.get_theme_color("font_color").to_html(false)).is_equal(
			String(damage_case["color"])
		)
		assert_int(label.get_theme_constant("outline_size")).is_equal(int(damage_case["outline"]))
		if int(damage_case["outline"]) > 0:
			assert_str(label.get_theme_color("font_outline_color").to_html(false)).is_equal("ffffff")
		presentation.advance_time(2.0)


func test_damage_number_records_gdd_float_distance_and_lifetime() -> void:
	assert_bool(presentation.has_method("get_last_damage_number_float_distance")).is_true()
	assert_bool(presentation.has_method("get_last_damage_number_lifetime_sec")).is_true()

	presentation.on_hit_event({
		"damage": 31,
		"hit_position": Vector2(140, 120),
		"is_crit": false,
	})

	assert_float(float(presentation.call("get_last_damage_number_float_distance"))).is_equal_approx(
		30.0,
		0.001
	)
	assert_float(float(presentation.call("get_last_damage_number_lifetime_sec"))).is_equal_approx(
		1.5,
		0.001
	)

	presentation.advance_time(1.49)
	assert_int(presentation.get_active_damage_number_count()).is_equal(1)

	presentation.advance_time(0.03)
	assert_int(presentation.get_active_damage_number_count()).is_equal(0)


func test_damage_number_boundary_values_clamp_to_valid_tiers() -> void:
	presentation.on_hit_event({
		"damage": 0,
		"hit_position": Vector2(40, 50),
		"is_crit": false,
	})
	var low_label := _latest_damage_label()

	assert_object(low_label).is_not_null()
	assert_str(presentation.get_last_damage_number_text()).is_equal("1")
	assert_int(low_label.get_theme_font_size("font_size")).is_equal(12)
	assert_str(low_label.get_theme_color("font_color").to_html(false)).is_equal("ffffff")

	presentation.advance_time(2.0)
	presentation.on_hit_event({
		"damage": 1200,
		"hit_position": Vector2(40, 50),
		"is_crit": false,
	})
	var high_label := _latest_damage_label()

	assert_object(high_label).is_not_null()
	assert_str(presentation.get_last_damage_number_text()).is_equal("1200")
	assert_int(high_label.get_theme_font_size("font_size")).is_equal(48)
	assert_int(high_label.get_theme_constant("outline_size")).is_equal(2)


func test_hit_event_prefers_final_damage_metadata_for_runtime_core_chain() -> void:
	presentation.on_hit_event({
		"damage": 1,
		"final_damage": 151,
		"hit_position": Vector2(40, 50),
		"is_crit": false,
	})
	var label := _latest_damage_label()

	assert_object(label).is_not_null()
	assert_str(presentation.get_last_damage_number_text()).is_equal("151")
	assert_int(label.get_theme_font_size("font_size")).is_equal(48)
	assert_int(label.get_theme_constant("outline_size")).is_equal(2)


func test_rapid_damage_numbers_cleanup_without_stale_active_entries() -> void:
	for index: int in range(10):
		presentation.on_hit_event({
			"damage": 1 + index * 17,
			"hit_position": Vector2(40 + index * 4, 50),
			"is_crit": false,
		})

	assert_int(presentation.get_active_damage_number_count()).is_equal(10)

	presentation.advance_time(1.6)

	assert_int(presentation.get_active_damage_number_count()).is_equal(0)


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


func test_hit_event_can_disable_damage_number_without_suppressing_impact_feedback() -> void:
	presentation.on_hit_event({
		"damage": 12,
		"hit_position": Vector2(80, 90),
		"is_crit": false,
		"show_damage_number": false,
	})

	assert_int(presentation.get_active_damage_number_count()).is_equal(0)
	assert_int(presentation.get_active_spark_count()).is_between(5, 8)
	assert_int(presentation.get_hitstop_frames_remaining()).is_equal(3)
	assert_float(presentation.get_screen_shake_intensity()).is_equal_approx(2.0, 0.001)


func test_colorblind_modes_remap_combat_particle_palette() -> void:
	assert_bool(presentation.has_method("set_colorblind_mode")).is_true()
	assert_bool(presentation.has_method("get_colorblind_mode")).is_true()
	assert_bool(presentation.has_method("get_last_spark_color")).is_true()
	assert_bool(presentation.has_method("get_last_debris_color")).is_true()
	assert_bool(presentation.has_method("get_last_parry_spark_color")).is_true()
	assert_bool(presentation.has_method("get_last_claw_trail_color")).is_true()
	assert_bool(presentation.has_method("get_last_boss_phase_debris_color")).is_true()
	if (
		not presentation.has_method("set_colorblind_mode")
		or not presentation.has_method("get_colorblind_mode")
		or not presentation.has_method("get_last_spark_color")
		or not presentation.has_method("get_last_debris_color")
		or not presentation.has_method("get_last_parry_spark_color")
		or not presentation.has_method("get_last_claw_trail_color")
		or not presentation.has_method("get_last_boss_phase_debris_color")
	):
		return

	presentation.call("set_colorblind_mode", &"red_green")
	assert_str(String(presentation.call("get_colorblind_mode"))).is_equal("red_green")

	presentation.on_hit_event({
		"damage": 12,
		"hit_position": Vector2(80, 90),
		"is_crit": false,
		"show_damage_number": false,
	})
	assert_str(_color_html(presentation.call("get_last_spark_color"))).is_equal("4299e1")

	presentation.on_hit_event({
		"damage": 36,
		"hit_position": Vector2(80, 90),
		"is_crit": true,
		"show_damage_number": false,
	})
	assert_str(_color_html(presentation.call("get_last_spark_color"))).is_equal("f6e05e")

	presentation.on_parry_event({
		"parry_type": &"perfect",
		"position": Vector2(220, 210),
	})
	assert_str(_color_html(presentation.call("get_last_parry_spark_color"))).is_equal("f6e05e")

	presentation.on_weapon_attack_event({
		"weapon_id": &"cat_claw",
		"attack_position": Vector2(100, 120),
		"facing": -1,
	})
	assert_str(_color_html(presentation.call("get_last_claw_trail_color"))).is_equal("f6e05e")

	presentation.on_kill_event(2, Vector2(300, 400))
	assert_str(_color_html(presentation.call("get_last_debris_color"))).is_equal("d69e2e")

	presentation.call("on_boss_phase_transition_started", 42, 2, _make_boss_phase_metadata(2))
	assert_str(_color_html(presentation.call("get_last_boss_phase_debris_color"))).is_equal("2b6cb0")

	presentation.call("on_boss_phase_transition_started", 42, 3, _make_boss_phase_metadata(3))
	assert_str(_color_html(presentation.call("get_last_boss_phase_debris_color"))).is_equal("f6e05e")

	presentation.call("set_colorblind_mode", &"blue_yellow")
	assert_str(String(presentation.call("get_colorblind_mode"))).is_equal("blue_yellow")

	presentation.on_hit_event({
		"damage": 12,
		"hit_position": Vector2(80, 90),
		"is_crit": false,
		"show_damage_number": false,
	})
	assert_str(_color_html(presentation.call("get_last_spark_color"))).is_equal("fed7d7")

	presentation.on_hit_event({
		"damage": 36,
		"hit_position": Vector2(80, 90),
		"is_crit": true,
		"show_damage_number": false,
	})
	assert_str(_color_html(presentation.call("get_last_spark_color"))).is_equal("f97316")

	presentation.on_parry_event({
		"parry_type": &"perfect",
		"position": Vector2(220, 210),
	})
	assert_str(_color_html(presentation.call("get_last_parry_spark_color"))).is_equal("ffffff")

	presentation.on_kill_event(2, Vector2(300, 400))
	assert_str(_color_html(presentation.call("get_last_debris_color"))).is_equal("e53e3e")

	presentation.call("on_boss_phase_transition_started", 42, 2, _make_boss_phase_metadata(2))
	assert_str(_color_html(presentation.call("get_last_boss_phase_debris_color"))).is_equal("f97316")

	presentation.call("on_boss_phase_transition_started", 42, 3, _make_boss_phase_metadata(3))
	assert_str(_color_html(presentation.call("get_last_boss_phase_debris_color"))).is_equal("ffffff")

	presentation.call("set_colorblind_mode", &"invalid")
	assert_str(String(presentation.call("get_colorblind_mode"))).is_equal("none")
	presentation.on_hit_event({
		"damage": 12,
		"hit_position": Vector2(80, 90),
		"is_crit": false,
		"show_damage_number": false,
	})
	assert_str(_color_html(presentation.call("get_last_spark_color"))).is_equal("fff0c2")


func test_focus_mode_reduces_screen_shake_intensity_without_shortening_duration() -> void:
	assert_bool(presentation.has_method("on_focus_mode_changed")).is_true()
	assert_bool(presentation.has_method("is_focus_mode_active")).is_true()
	assert_bool(presentation.has_method("get_screen_shake_frames_remaining")).is_true()
	if (
		not presentation.has_method("on_focus_mode_changed")
		or not presentation.has_method("is_focus_mode_active")
		or not presentation.has_method("get_screen_shake_frames_remaining")
	):
		return

	presentation.call("on_focus_mode_changed", 1, true, {
		"hp_percentage": 0.25,
	})
	assert_bool(bool(presentation.call("is_focus_mode_active"))).is_true()

	presentation.on_hit_event({
		"damage": 12,
		"hit_position": Vector2(80, 90),
		"is_crit": false,
		"show_damage_number": false,
	})

	assert_float(presentation.get_screen_shake_intensity()).is_equal_approx(1.4, 0.001)
	assert_int(int(presentation.call("get_screen_shake_frames_remaining"))).is_equal(3)
	assert_int(presentation.get_hitstop_frames_remaining()).is_equal(3)

	presentation.play_screen_shake(5.0, 6)
	presentation.play_screen_shake(2.0, 3)

	assert_float(presentation.get_screen_shake_intensity()).is_equal_approx(3.5, 0.001)
	assert_int(int(presentation.call("get_screen_shake_frames_remaining"))).is_equal(6)


func test_focus_mode_reduces_parry_boss_and_restores_after_exit() -> void:
	assert_bool(presentation.has_method("on_focus_mode_changed")).is_true()
	assert_bool(presentation.has_method("get_screen_shake_frames_remaining")).is_true()
	if (
		not presentation.has_method("on_focus_mode_changed")
		or not presentation.has_method("get_screen_shake_frames_remaining")
	):
		return

	presentation.call("on_focus_mode_changed", 1, true, {})
	presentation.on_parry_event({
		"parry_type": &"perfect",
		"position": Vector2(220, 210),
	})

	assert_float(presentation.get_screen_shake_intensity()).is_equal_approx(5.6, 0.001)
	assert_int(int(presentation.call("get_screen_shake_frames_remaining"))).is_equal(8)

	_drain_screen_shake_frames()
	presentation.call("on_focus_mode_changed", 1, true, {})
	presentation.call("on_boss_phase_transition_started", 42, 2, _make_boss_phase_metadata(2))

	assert_float(presentation.get_screen_shake_intensity()).is_equal_approx(4.2, 0.001)
	assert_int(int(presentation.call("get_screen_shake_frames_remaining"))).is_equal(4)

	_drain_screen_shake_frames()
	presentation.call("on_focus_mode_changed", 1, false, {})
	presentation.on_hit_event({
		"damage": 12,
		"hit_position": Vector2(80, 90),
		"is_crit": false,
		"show_damage_number": false,
	})

	assert_float(presentation.get_screen_shake_intensity()).is_equal_approx(2.0, 0.001)


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


func test_perfect_parry_flash_uses_textured_overlay_not_color_rect() -> void:
	presentation.on_parry_event({
		"parry_type": &"perfect",
		"position": Vector2(220, 210),
	})

	assert_int(presentation.get_active_flash_count()).is_equal(1)
	assert_int(_count_descendants_of_type(presentation, "ColorRect")).is_equal(0)
	assert_int(_count_descendants_of_type(presentation, "TextureRect")).is_greater_equal(1)
	assert_bool(_all_texture_rect_descendants_have_textures(presentation)).is_true()


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


func test_long_tail_attack_spawns_one_silver_textured_blade_arc() -> void:
	presentation.on_weapon_attack_event({
		"weapon_id": &"long_tail",
		"attack_position": Vector2(100, 120),
		"facing": 1,
	})

	var snapshot: Dictionary = presentation.get_weapon_vfx_snapshot(&"long_tail")

	assert_int(int(snapshot.get("count", 0))).is_equal(1)
	assert_str(_color_html(snapshot.get("color", Color.TRANSPARENT))).is_equal("dde8f2")
	assert_float(float(snapshot.get("lifetime_sec", 0.0))).is_equal_approx(0.5, 0.001)
	assert_str(String(snapshot.get("texture_path", ""))).is_equal(
		"res://assets/generated/combat_long_tail_arc_runtime.png"
	)
	assert_int(presentation.get_active_trail_count()).is_equal(1)
	assert_int(_count_children_of_type("Sprite2D")).is_greater_equal(1)
	assert_int(_count_descendants_of_type(presentation, "ColorRect")).is_equal(0)
	assert_bool(_all_sprite_children_have_textures()).is_true()


func test_fish_bone_attack_spawns_one_white_textured_shockwave() -> void:
	presentation.on_weapon_attack_event({
		"weapon_id": &"fish_bone",
		"attack_position": Vector2(100, 120),
		"facing": -1,
	})

	var snapshot: Dictionary = presentation.get_weapon_vfx_snapshot(&"fish_bone")

	assert_int(int(snapshot.get("count", 0))).is_equal(1)
	assert_str(_color_html(snapshot.get("color", Color.TRANSPARENT))).is_equal("f8f4e8")
	assert_float(float(snapshot.get("lifetime_sec", 0.0))).is_equal_approx(0.3, 0.001)
	assert_str(String(snapshot.get("texture_path", ""))).is_equal(
		"res://assets/generated/combat_fish_bone_wave_runtime.png"
	)
	assert_int(presentation.get_active_trail_count()).is_equal(1)
	assert_int(_count_children_of_type("Sprite2D")).is_greater_equal(1)
	assert_int(_count_descendants_of_type(presentation, "ColorRect")).is_equal(0)
	assert_bool(_all_sprite_children_have_textures()).is_true()


func test_electro_bell_attack_spawns_blue_textured_arcs() -> void:
	presentation.on_weapon_attack_event({
		"weapon_id": &"electro_bell",
		"attack_position": Vector2(100, 120),
		"facing": 1,
	})

	var snapshot: Dictionary = presentation.get_weapon_vfx_snapshot(&"electro_bell")

	assert_int(int(snapshot.get("count", 0))).is_between(5, 8)
	assert_str(_color_html(snapshot.get("color", Color.TRANSPARENT))).is_equal("38bdf8")
	assert_float(float(snapshot.get("lifetime_sec", 0.0))).is_equal_approx(0.4, 0.001)
	assert_str(String(snapshot.get("texture_path", ""))).is_equal(
		"res://assets/generated/combat_electro_bell_arc_runtime.png"
	)
	assert_int(presentation.get_active_trail_count()).is_between(5, 8)
	assert_int(_count_children_of_type("Sprite2D")).is_greater_equal(
		int(snapshot.get("count", 0))
	)
	assert_int(_count_descendants_of_type(presentation, "ColorRect")).is_equal(0)
	assert_bool(_all_sprite_children_have_textures()).is_true()


func test_weapon_specific_vfx_expire_at_gdd_lifetimes() -> void:
	_assert_weapon_vfx_expires(&"long_tail", 1, 0.5)
	_assert_weapon_vfx_expires(&"fish_bone", 1, 0.3)
	_assert_weapon_vfx_expires(&"electro_bell", 6, 0.4)


func test_weapon_specific_vfx_count_toward_particle_budget() -> void:
	assert_bool(presentation.has_method("get_active_particle_count")).is_true()
	if not presentation.has_method("get_active_particle_count"):
		return

	presentation.on_weapon_attack_event({
		"weapon_id": &"long_tail",
		"attack_position": Vector2(100, 120),
		"facing": 1,
	})
	presentation.on_weapon_attack_event({
		"weapon_id": &"fish_bone",
		"attack_position": Vector2(140, 120),
		"facing": 1,
	})
	presentation.on_weapon_attack_event({
		"weapon_id": &"electro_bell",
		"attack_position": Vector2(180, 120),
		"facing": 1,
	})

	assert_int(presentation.get_active_trail_count()).is_equal(8)
	assert_int(int(presentation.call("get_active_particle_count"))).is_equal(8)


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


func test_boss_phase_transition_spawns_textured_overlay_and_metal_debris() -> void:
	assert_bool(presentation.has_method("on_boss_phase_transition_started")).is_true()
	assert_bool(presentation.has_method("get_active_boss_phase_debris_count")).is_true()
	assert_bool(presentation.has_method("get_active_boss_phase_overlay_count")).is_true()
	assert_bool(presentation.has_method("get_last_boss_phase_entity_id")).is_true()
	assert_bool(presentation.has_method("get_last_boss_phase")).is_true()
	assert_bool(presentation.has_method("get_last_boss_phase_metadata")).is_true()
	assert_bool(presentation.has_method("get_last_boss_phase_overlay_texture_path")).is_true()
	if (
		not presentation.has_method("on_boss_phase_transition_started")
		or not presentation.has_method("get_active_boss_phase_debris_count")
		or not presentation.has_method("get_active_boss_phase_overlay_count")
		or not presentation.has_method("get_last_boss_phase_entity_id")
		or not presentation.has_method("get_last_boss_phase")
		or not presentation.has_method("get_last_boss_phase_metadata")
		or not presentation.has_method("get_last_boss_phase_overlay_texture_path")
	):
		return

	presentation.call("on_boss_phase_transition_started", 42, 2, _make_boss_phase_metadata(2))

	assert_int(presentation.get_hitstop_frames_remaining()).is_equal(4)
	assert_float(presentation.get_screen_shake_intensity()).is_equal_approx(6.0, 0.001)
	assert_int(int(presentation.call("get_active_boss_phase_overlay_count"))).is_equal(1)
	assert_int(int(presentation.call("get_active_boss_phase_debris_count"))).is_greater_equal(30)
	assert_int(int(presentation.call("get_last_boss_phase_entity_id"))).is_equal(42)
	assert_int(int(presentation.call("get_last_boss_phase"))).is_equal(2)
	assert_str(String(presentation.call("get_last_boss_phase_overlay_texture_path"))).is_equal(
		"res://assets/generated/combat_boss_phase_overlay.png"
	)

	var metadata: Dictionary = Dictionary(presentation.call("get_last_boss_phase_metadata"))
	assert_str(String(metadata.get("boss_id", ""))).is_equal("shadow_beast")
	assert_float(float(metadata.get("trigger_hp_percentage", 0.0))).is_equal_approx(0.65, 0.001)
	assert_str(String(metadata.get("transition_animation", ""))).is_equal("phase_2_rebuild")
	assert_int(_count_descendants_of_type(presentation, "ColorRect")).is_equal(0)
	assert_int(_count_descendants_of_type(presentation, "TextureRect")).is_greater_equal(1)
	assert_bool(_all_texture_rect_descendants_have_textures(presentation)).is_true()
	assert_int(_count_children_of_type("Sprite2D")).is_greater_equal(
		int(presentation.call("get_active_boss_phase_debris_count"))
	)
	assert_bool(_all_sprite_children_have_textures()).is_true()


func test_boss_phase_debris_expires_after_gdd_lifetime() -> void:
	assert_bool(presentation.has_method("on_boss_phase_transition_started")).is_true()
	assert_bool(presentation.has_method("get_active_boss_phase_debris_count")).is_true()
	assert_bool(presentation.has_method("get_boss_phase_debris_lifetime_sec")).is_true()
	if (
		not presentation.has_method("on_boss_phase_transition_started")
		or not presentation.has_method("get_active_boss_phase_debris_count")
		or not presentation.has_method("get_boss_phase_debris_lifetime_sec")
	):
		return

	presentation.call("on_boss_phase_transition_started", 42, 3, _make_boss_phase_metadata(3))

	assert_float(float(presentation.call("get_boss_phase_debris_lifetime_sec"))).is_equal_approx(
		1.5,
		0.001
	)
	assert_int(int(presentation.call("get_active_boss_phase_debris_count"))).is_greater_equal(30)

	presentation.advance_time(1.49)

	assert_int(int(presentation.call("get_active_boss_phase_debris_count"))).is_greater_equal(30)

	presentation.advance_time(0.03)

	assert_int(int(presentation.call("get_active_boss_phase_debris_count"))).is_equal(0)


func test_effects_expire_after_their_lifetime() -> void:
	presentation.on_hit_event({
		"damage": 7,
		"hit_position": Vector2(40, 50),
	})

	presentation.advance_time(1.49)

	assert_int(presentation.get_active_damage_number_count()).is_equal(1)

	presentation.advance_time(0.03)

	assert_int(presentation.get_active_damage_number_count()).is_equal(0)


func test_particle_budget_caps_active_sprite_particles_and_evicts_oldest() -> void:
	assert_bool(presentation.has_method("get_particle_cap")).is_true()
	assert_bool(presentation.has_method("get_active_particle_count")).is_true()
	assert_bool(presentation.has_method("get_particle_eviction_count")).is_true()
	if (
		not presentation.has_method("get_particle_cap")
		or not presentation.has_method("get_active_particle_count")
		or not presentation.has_method("get_particle_eviction_count")
	):
		return

	assert_int(int(presentation.call("get_particle_cap"))).is_equal(200)
	assert_int(int(presentation.call("get_active_particle_count"))).is_equal(0)

	presentation.on_hit_event({
		"damage": 12,
		"hit_position": Vector2(80, 90),
		"is_crit": false,
		"show_damage_number": false,
	})
	assert_int(presentation.get_active_spark_count()).is_equal(6)

	for index: int in range(7):
		presentation.call("on_boss_phase_transition_started", 42, 2, _make_boss_phase_metadata(2 + index))

	assert_int(int(presentation.call("get_active_particle_count"))).is_equal(200)
	assert_int(presentation.get_active_spark_count()).is_equal(0)
	assert_int(int(presentation.call("get_active_boss_phase_debris_count"))).is_equal(200)
	assert_int(int(presentation.call("get_particle_eviction_count"))).is_equal(30)
	assert_int(_count_children_of_type("Sprite2D")).is_equal(200)


func test_particle_budget_counts_sprite_particles_without_overlays_or_damage_numbers() -> void:
	assert_bool(presentation.has_method("get_active_particle_count")).is_true()
	if not presentation.has_method("get_active_particle_count"):
		return

	presentation.on_hit_event({
		"damage": 12,
		"hit_position": Vector2(80, 90),
		"is_crit": false,
	})
	presentation.on_parry_event({
		"parry_type": &"perfect",
		"position": Vector2(220, 210),
	})
	presentation.on_weapon_attack_event({
		"weapon_id": &"cat_claw",
		"attack_position": Vector2(100, 120),
		"facing": -1,
	})
	presentation.on_dodge_event(CINDERPAW_IDLE_TEXTURE, Vector2(180, 220), -1.0)
	presentation.call("on_boss_phase_transition_started", 42, 2, _make_boss_phase_metadata(2))

	var expected_particle_count: int = (
		presentation.get_active_spark_count()
		+ presentation.get_active_parry_spark_count()
		+ presentation.get_active_trail_count()
		+ presentation.get_active_afterimage_count()
		+ int(presentation.call("get_active_boss_phase_debris_count"))
	)

	assert_int(presentation.get_active_damage_number_count()).is_equal(1)
	assert_int(presentation.get_active_flash_count()).is_equal(1)
	assert_int(int(presentation.call("get_active_boss_phase_overlay_count"))).is_equal(1)
	assert_int(int(presentation.call("get_active_particle_count"))).is_equal(expected_particle_count)


func test_performance_budget_sample_reports_gdd_budget_without_mutating_state() -> void:
	assert_bool(presentation.has_method("capture_performance_budget_sample")).is_true()
	assert_bool(presentation.has_method("get_active_particle_count")).is_true()
	if (
		not presentation.has_method("capture_performance_budget_sample")
		or not presentation.has_method("get_active_particle_count")
	):
		return

	for index: int in range(7):
		presentation.call("on_boss_phase_transition_started", 42, 2, _make_boss_phase_metadata(2 + index))
	presentation.play_hitstop(6)
	presentation.play_screen_shake(5.0, 6)
	var before_particles: int = int(presentation.call("get_active_particle_count"))
	var before_hitstop: int = presentation.get_hitstop_frames_remaining()
	var before_shake: float = presentation.get_screen_shake_intensity()
	var before_shake_frames: int = int(presentation.call("get_screen_shake_frames_remaining"))

	var sample: Dictionary = Dictionary(presentation.call("capture_performance_budget_sample", 120))

	assert_int(int(sample.get("sample_frames", 0))).is_equal(120)
	assert_int(int(sample.get("active_particle_count", 0))).is_equal(before_particles)
	assert_int(int(sample.get("particle_cap", 0))).is_equal(200)
	assert_float(float(sample.get("particle_budget_ms", 0.0))).is_equal_approx(2.0, 0.001)
	assert_float(float(sample.get("shake_hitstop_budget_ms", 0.0))).is_equal_approx(0.1, 0.001)
	assert_float(float(sample.get("total_budget_ms", 0.0))).is_equal_approx(3.0, 0.001)
	assert_bool(bool(sample.get("within_budget", false))).is_true()
	assert_float(float(sample.get("particle_frame_ms", -1.0))).is_greater_equal(0.0)
	assert_float(float(sample.get("shake_hitstop_frame_ms", -1.0))).is_greater_equal(0.0)
	assert_float(float(sample.get("total_frame_ms", -1.0))).is_greater_equal(0.0)
	assert_int(int(presentation.call("get_active_particle_count"))).is_equal(before_particles)
	assert_int(presentation.get_hitstop_frames_remaining()).is_equal(before_hitstop)
	assert_float(presentation.get_screen_shake_intensity()).is_equal_approx(before_shake, 0.001)
	assert_int(int(presentation.call("get_screen_shake_frames_remaining"))).is_equal(before_shake_frames)


func test_performance_budget_sample_clamps_non_positive_sample_frames() -> void:
	assert_bool(presentation.has_method("capture_performance_budget_sample")).is_true()
	if not presentation.has_method("capture_performance_budget_sample"):
		return

	var zero_sample: Dictionary = Dictionary(presentation.call("capture_performance_budget_sample", 0))
	var negative_sample: Dictionary = Dictionary(presentation.call("capture_performance_budget_sample", -12))

	assert_int(int(zero_sample.get("sample_frames", 0))).is_equal(1)
	assert_int(int(negative_sample.get("sample_frames", 0))).is_equal(1)
	assert_bool(zero_sample.has("within_budget")).is_true()
	assert_bool(negative_sample.has("within_budget")).is_true()


func test_particle_budget_preserves_event_counts_when_under_cap() -> void:
	assert_bool(presentation.has_method("get_active_particle_count")).is_true()
	if not presentation.has_method("get_active_particle_count"):
		return

	presentation.on_hit_event({
		"damage": 12,
		"hit_position": Vector2(80, 90),
		"is_crit": false,
		"show_damage_number": false,
	})
	assert_int(presentation.get_active_spark_count()).is_equal(6)
	assert_int(int(presentation.call("get_active_particle_count"))).is_equal(6)
	presentation.advance_time(2.0)

	presentation.on_hit_event({
		"damage": 36,
		"hit_position": Vector2(80, 90),
		"is_crit": true,
		"show_damage_number": false,
	})
	assert_int(presentation.get_active_spark_count()).is_equal(12)
	presentation.advance_time(2.0)

	presentation.on_parry_event({
		"parry_type": &"perfect",
		"position": Vector2(220, 210),
	})
	assert_int(presentation.get_active_parry_spark_count()).is_equal(22)
	presentation.advance_time(2.0)

	presentation.on_weapon_attack_event({
		"weapon_id": &"cat_claw",
		"attack_position": Vector2(100, 120),
		"facing": -1,
	})
	assert_int(presentation.get_active_trail_count()).is_equal(3)
	presentation.advance_time(2.0)

	presentation.on_kill_event(7, Vector2(180, 200))
	assert_int(presentation.get_active_debris_count()).is_equal(18)
	presentation.advance_time(2.0)

	presentation.call("on_boss_phase_transition_started", 42, 2, _make_boss_phase_metadata(2))
	assert_int(int(presentation.call("get_active_boss_phase_debris_count"))).is_equal(32)
	assert_int(int(presentation.call("get_active_particle_count"))).is_equal(32)


func _count_children_of_type(type_name: String) -> int:
	var count: int = 0
	for child: Node in presentation.get_children():
		if child.is_class(type_name):
			count += 1
	return count


func _count_descendants_of_type(root: Node, type_name: String) -> int:
	var count: int = 0
	for child: Node in root.get_children():
		if child.is_class(type_name):
			count += 1
		count += _count_descendants_of_type(child, type_name)
	return count


func _all_sprite_children_have_textures() -> bool:
	for child: Node in presentation.get_children():
		var sprite: Sprite2D = child as Sprite2D
		if sprite != null and sprite.texture == null:
			return false
	return true


func _all_texture_rect_descendants_have_textures(root: Node) -> bool:
	for child: Node in root.get_children():
		var texture_rect: TextureRect = child as TextureRect
		if texture_rect != null and texture_rect.texture == null:
			return false
		if not _all_texture_rect_descendants_have_textures(child):
			return false
	return true


func _assert_weapon_vfx_expires(
	weapon_id: StringName,
	expected_count: int,
	lifetime_sec: float
) -> void:
	presentation.on_weapon_attack_event({
		"weapon_id": weapon_id,
		"attack_position": Vector2(100, 120),
		"facing": 1,
	})

	var active_snapshot: Dictionary = presentation.get_weapon_vfx_snapshot(weapon_id)
	assert_int(int(active_snapshot.get("count", 0))).is_equal(expected_count)

	presentation.advance_time(lifetime_sec - 0.01)
	var before_expire_snapshot: Dictionary = presentation.get_weapon_vfx_snapshot(weapon_id)
	assert_int(int(before_expire_snapshot.get("count", 0))).is_equal(expected_count)

	presentation.advance_time(0.03)
	var expired_snapshot: Dictionary = presentation.get_weapon_vfx_snapshot(weapon_id)
	assert_int(int(expired_snapshot.get("count", 0))).is_equal(0)


func _latest_damage_label() -> Label:
	var labels: Array[Label] = []
	for child: Node in presentation.get_children():
		var label: Label = child as Label
		if label != null:
			labels.append(label)
	if labels.is_empty():
		return null
	return labels[labels.size() - 1]


func _color_html(value: Variant) -> String:
	if value is Color:
		return (value as Color).to_html(false)
	return Color(value).to_html(false)


func _drain_screen_shake_frames() -> void:
	for _frame: int in range(12):
		presentation.call("_physics_process", 0.0)


func _make_boss_phase_metadata(phase: int) -> Dictionary:
	var threshold: float = 0.66 if phase == 2 else 0.33
	var trigger_hp: float = 0.65 if phase == 2 else 0.32
	return {
		"boss_id": "shadow_beast",
		"display_name": "Shadow Beast",
		"previous_phase": phase - 1,
		"hp_threshold": threshold,
		"trigger_hp_percentage": trigger_hp,
		"transition_duration_sec": 2.5,
		"transition_animation": "phase_%d_rebuild" % phase,
		"attack_patterns": PackedStringArray(["bite", "lunge"]),
		"attack_speed_modifier": 1.15,
		"special_attacks": PackedStringArray(["overload_pounce"]),
		"arena_changes": {
			"debris_density": "high",
		},
		"world_position": Vector2(420, 260),
	}
