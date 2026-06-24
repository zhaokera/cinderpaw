## Rat King runtime boss contract for MainScene integration.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const RAT_KING_BOSS_SCENE_PATH: String = "res://src/gameplay/rat_king_boss.tscn"
const RAT_KING_BOSS_SCRIPT_PATH: String = "res://src/gameplay/rat_king_boss.gd"
const RAT_KING_SPRITE_FRAMES_PATH: String = "res://assets/characters/rat_king/rat_king_sprite_frames.tres"
const RAT_KING_BOSS_ID: StringName = &"boss_01_rat_king"
const EXPECTED_MAX_HP: int = 300

var scene: Node2D


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_rat_king_boss_scene_exposes_main_scene_enemy_contract() -> void:
	assert_bool(FileAccess.file_exists(RAT_KING_BOSS_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(RAT_KING_BOSS_SCRIPT_PATH)).is_true()
	if not FileAccess.file_exists(RAT_KING_BOSS_SCENE_PATH):
		return

	var boss_scene: PackedScene = load(RAT_KING_BOSS_SCENE_PATH) as PackedScene
	assert_object(boss_scene).is_not_null()
	if boss_scene == null:
		return
	var boss := boss_scene.instantiate()
	add_child(boss)

	assert_str(String(boss.get_script().resource_path)).is_equal(RAT_KING_BOSS_SCRIPT_PATH)
	assert_bool(boss.has_signal("enemy_health_changed")).is_true()
	assert_bool(boss.has_signal("enemy_defeated")).is_true()
	assert_bool(boss.has_signal("enemy_attack_landed")).is_true()
	assert_bool(boss.has_method("request_attack")).is_true()
	assert_bool(boss.has_method("advance_attack_frames")).is_true()
	assert_bool(boss.has_method("advance_boss_runtime")).is_true()
	assert_bool(boss.has_method("get_boss_config_component")).is_true()
	assert_bool(boss.has_method("get_current_boss_id")).is_true()
	assert_bool(boss.has_method("get_current_phase")).is_true()
	assert_int(int(boss.call("get_current_hp"))).is_equal(EXPECTED_MAX_HP)
	assert_int(int(boss.call("get_max_hp"))).is_equal(EXPECTED_MAX_HP)
	assert_str(String(boss.call("get_current_boss_id"))).is_equal(String(RAT_KING_BOSS_ID))
	_assert_rat_king_sprite(boss)

	boss.queue_free()


func test_main_scene_uses_rat_king_runtime_boss_as_visible_enemy() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	assert_bool(scene_text.contains("res://src/gameplay/rat_king_boss.tscn")).is_true()
	assert_bool(scene_text.contains("res://src/gameplay/simple_enemy.tscn")).is_false()

	var enemy := scene.get_node("Enemy")
	assert_str(String(enemy.get_script().resource_path)).is_equal(RAT_KING_BOSS_SCRIPT_PATH)
	assert_int(int(enemy.call("get_current_hp"))).is_equal(EXPECTED_MAX_HP)
	assert_int(int(enemy.call("get_max_hp"))).is_equal(EXPECTED_MAX_HP)
	assert_str(String(enemy.call("get_current_boss_id"))).is_equal(String(RAT_KING_BOSS_ID))
	_assert_rat_king_sprite(enemy)


func test_main_scene_routes_real_rat_king_phase_transition_to_presentation() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)

	var enemy := scene.get_node("Enemy")
	var presentation := scene.get_node("CombatPresentation")
	assert_bool(scene.has_method("is_boss_phase_transition_source_connected")).is_true()
	assert_bool(bool(scene.call("is_boss_phase_transition_source_connected"))).is_true()
	assert_bool(enemy.has_method("get_health_component")).is_true()
	assert_bool(enemy.has_method("advance_boss_runtime")).is_true()
	if not (
		enemy.has_method("get_health_component")
		and enemy.has_method("advance_boss_runtime")
	):
		return

	var health: HealthComponent = enemy.call("get_health_component") as HealthComponent
	assert_object(health).is_not_null()
	if health == null:
		return

	health.apply_damage(120, {"source": &"phase_test"})
	enemy.call("advance_boss_runtime", 0.0)

	assert_int(int(enemy.call("get_current_phase"))).is_equal(2)
	assert_str(String(enemy.get_node("Sprite").get("animation"))).is_equal("phase_2_rebuild")
	assert_int(int(presentation.call("get_last_boss_phase"))).is_equal(2)
	assert_int(presentation.get_hitstop_frames_remaining()).is_equal(4)
	assert_int(int(presentation.call("get_active_boss_phase_debris_count"))).is_greater_equal(30)


func _assert_rat_king_sprite(boss: Node) -> void:
	var sprite: Node = boss.get_node_or_null("Sprite")
	assert_bool(sprite is AnimatedSprite2D).is_true()
	if not sprite is AnimatedSprite2D:
		return
	var animated_sprite := sprite as AnimatedSprite2D
	assert_bool(animated_sprite.sprite_frames != null).is_true()
	if animated_sprite.sprite_frames == null:
		return
	assert_str(animated_sprite.sprite_frames.resource_path).is_equal(RAT_KING_SPRITE_FRAMES_PATH)
	for animation_name: StringName in [
		&"idle",
		&"attack_tell",
		&"attack",
		&"hurt",
		&"death",
		&"phase_1_intro",
		&"phase_2_rebuild",
		&"phase_3_overload",
	]:
		assert_bool(animated_sprite.sprite_frames.has_animation(animation_name)).is_true()
		if animated_sprite.sprite_frames.has_animation(animation_name):
			assert_int(animated_sprite.sprite_frames.get_frame_count(animation_name)).is_greater_equal(3)
