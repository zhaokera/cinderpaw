## Story016 acceptance: a real Main perfect parry leaves one gold player silhouette.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const CAT_EYE_GOLD_HEX: String = "ecc94b"

var scene: Node


func before_test() -> void:
	scene = MAIN_SCENE.instantiate()
	add_child(scene)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_real_main_perfect_parry_spawns_one_gold_current_frame_afterimage() -> void:
	var player: PlayerController = scene.get_node("Player") as PlayerController
	var presentation: Node = scene.get_node("CombatPresentation")
	var combat: CombatComponent = player.get_combat_component()
	var sprite: AnimatedSprite2D = player.get_node("Sprite") as AnimatedSprite2D

	assert_bool(presentation.has_method("get_active_perfect_parry_afterimage_count")).is_true()
	assert_bool(presentation.has_method("get_last_perfect_parry_afterimage_diagnostics")).is_true()
	if (
		not presentation.has_method("get_active_perfect_parry_afterimage_count")
		or not presentation.has_method("get_last_perfect_parry_afterimage_diagnostics")
	):
		return

	assert_bool(player.request_parry()).is_true()
	var metadata: Dictionary = combat.resolve_parry_result()

	assert_str(String(metadata.get("parry_type", &""))).is_equal("perfect")
	assert_int(int(presentation.call("get_active_perfect_parry_afterimage_count"))).is_equal(1)
	var diagnostics: Dictionary = Dictionary(
		presentation.call("get_last_perfect_parry_afterimage_diagnostics")
	)
	assert_str(String(diagnostics.get("color_hex", ""))).is_equal(CAT_EYE_GOLD_HEX)
	assert_vector(diagnostics.get("source_position", Vector2.ZERO)).is_equal(
		sprite.global_position
	)
	assert_vector(diagnostics.get("position", Vector2.ZERO)).is_equal(
		sprite.global_position - Vector2(12.0, 0.0)
	)
	assert_bool(bool(diagnostics.get("flip_h", not sprite.flip_h))).is_equal(sprite.flip_h)
	assert_int(int(diagnostics.get("frame", -1))).is_equal(sprite.frame)
	assert_str(String(diagnostics.get("animation", &""))).is_equal(String(sprite.animation))

	var afterimage: Sprite2D = presentation.get_node_or_null(
		"PerfectParryGoldAfterimage"
	) as Sprite2D
	assert_that(afterimage).is_not_null()
	if afterimage == null:
		return
	assert_that(afterimage.material).is_not_null()
	assert_bool(afterimage.material is ShaderMaterial).is_true()
	assert_vector(afterimage.global_position).is_equal(
		sprite.global_position - Vector2(12.0, 0.0)
	)
	assert_that(afterimage.texture).is_same(sprite.sprite_frames.get_frame_texture(
		sprite.animation,
		sprite.frame
	))

	presentation.call("advance_time", 0.35)
	assert_int(int(presentation.call("get_active_perfect_parry_afterimage_count"))).is_equal(0)
