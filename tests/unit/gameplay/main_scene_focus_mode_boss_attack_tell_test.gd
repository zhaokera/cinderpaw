## Story158 acceptance coverage for focus-amplified Main boss attack tells.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const ATTACK_TELL_TEXTURE_PATH: String = (
	"res://assets/generated/combat_focus_mode_boss_attack_tell.png"
)
const FOCUS_DAMAGE: int = 75
const FOCUS_AREA_MULTIPLIER: float = 1.25
const FOCUS_DURATION_MULTIPLIER: float = 1.10

var scene: Node2D


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_real_focus_signal_amplifies_boss_tells_without_scaling_characters() -> void:
	var player: Node = scene.get_node("Player")
	var health := player.get_node("HealthComponent") as HealthComponent
	var rat_king: Node = scene.get_node("Enemy")
	var echo_guardian: Node = scene.get_node("Boss2EchoGuardian")
	var rat_sprite := rat_king.get_node("Sprite") as AnimatedSprite2D
	var echo_sprite := echo_guardian.get_node("Sprite") as AnimatedSprite2D
	var rat_character_scale: Vector2 = rat_sprite.scale
	var echo_character_scale: Vector2 = echo_sprite.scale

	assert_bool(ResourceLoader.exists(ATTACK_TELL_TEXTURE_PATH)).is_true()
	assert_bool(rat_king.has_method("get_focus_attack_tell_diagnostics")).is_true()
	assert_bool(echo_guardian.has_method("get_focus_attack_tell_diagnostics")).is_true()
	if (
		not ResourceLoader.exists(ATTACK_TELL_TEXTURE_PATH)
		or not rat_king.has_method("get_focus_attack_tell_diagnostics")
		or not echo_guardian.has_method("get_focus_attack_tell_diagnostics")
	):
		return

	echo_guardian.call("set_encounter_active", true, player)
	health.configure(1, 100, 100, 0, 0, true)
	health.set_active_enemy_count(2)
	health.apply_damage(FOCUS_DAMAGE, {"source": &"story158_focus_entry"})

	assert_bool(health.is_focus_mode_active()).is_true()
	assert_bool(bool(rat_king.call("request_attack_pattern", &"claw_swipe"))).is_true()
	assert_bool(bool(echo_guardian.call("request_attack"))).is_true()
	assert_vector(rat_sprite.scale).is_equal(rat_character_scale)
	assert_vector(echo_sprite.scale).is_equal(echo_character_scale)
	assert_int(int(rat_king.call("get_current_attack_startup_frames"))).is_equal(21)
	assert_int(int(echo_guardian.call("get_current_attack_startup_frames"))).is_equal(14)
	assert_int(rat_sprite.sprite_frames.get_frame_count(rat_sprite.animation)).is_greater_equal(3)
	assert_int(echo_sprite.sprite_frames.get_frame_count(echo_sprite.animation)).is_greater_equal(3)

	_assert_focus_tell(rat_king, 15, 17)
	_assert_focus_tell(echo_guardian, 8, 9)
	rat_king.call("advance_attack_frames", 16)
	echo_guardian.call("advance_attack_frames", 8)
	_assert_tell_remaining(rat_king, 1, true)
	_assert_tell_remaining(echo_guardian, 1, true)
	rat_king.call("advance_attack_frames", 1)
	echo_guardian.call("advance_attack_frames", 1)
	_assert_tell_remaining(rat_king, 0, false)
	_assert_tell_remaining(echo_guardian, 0, false)


func _assert_focus_tell(boss: Node, base_duration_frames: int, total_frames: int) -> void:
	var diagnostics: Dictionary = Dictionary(
		boss.call("get_focus_attack_tell_diagnostics")
	)
	var tell := boss.get_node_or_null("FocusAttackTell") as Sprite2D
	assert_object(tell).is_not_null()
	assert_bool(bool(diagnostics.get("visible", false))).is_true()
	assert_str(String(diagnostics.get("node_type", ""))).is_equal("Sprite2D")
	assert_str(String(diagnostics.get("texture_path", ""))).is_equal(
		ATTACK_TELL_TEXTURE_PATH
	)
	assert_float(float(diagnostics.get("area_multiplier", 0.0))).is_equal_approx(
		FOCUS_AREA_MULTIPLIER,
		0.001
	)
	assert_float(float(diagnostics.get("duration_multiplier", 0.0))).is_equal_approx(
		FOCUS_DURATION_MULTIPLIER,
		0.001
	)
	assert_int(int(diagnostics.get("base_duration_frames", 0))).is_equal(
		base_duration_frames
	)
	assert_int(int(diagnostics.get("total_duration_frames", 0))).is_equal(total_frames)
	assert_int(int(diagnostics.get("remaining_frames", 0))).is_equal(total_frames)
	if tell == null:
		return
	assert_object(tell.texture).is_not_null()
	assert_vector(tell.texture.get_size()).is_equal(Vector2(256, 128))
	var base_scale: Vector2 = diagnostics.get("base_scale", Vector2.ZERO)
	assert_vector(tell.scale).is_equal(base_scale * FOCUS_AREA_MULTIPLIER)


func _assert_tell_remaining(boss: Node, remaining_frames: int, visible: bool) -> void:
	var diagnostics: Dictionary = Dictionary(
		boss.call("get_focus_attack_tell_diagnostics")
	)
	assert_int(int(diagnostics.get("remaining_frames", -1))).is_equal(
		remaining_frames
	)
	assert_bool(bool(diagnostics.get("visible", not visible))).is_equal(visible)
