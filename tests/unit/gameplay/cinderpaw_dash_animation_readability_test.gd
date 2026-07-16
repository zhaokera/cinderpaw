## Story 030: Cinderpaw dedicated dash animation readability.
extends GdUnitTestSuite

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const DASH_ABILITY: StringName = &"dash"
const DASH_ANIMATION: StringName = &"dash"
const DODGE_ANIMATION: StringName = &"dodge"
const FRAME_COUNT: int = 3
const FRAME_SIZE: Vector2i = Vector2i(96, 96)
const MIN_RED_SCARF_PIXELS: int = 30
const MIN_AMBER_IDENTITY_PIXELS: int = 30
const MAX_SOFT_EDGE_RATIO: float = 0.08
const MIN_SILHOUETTE_DIFFERENCE_RATIO: float = 0.15

var player: PlayerController
var sprite: AnimatedSprite2D


func before_test() -> void:
	player = PLAYER_SCENE.instantiate() as PlayerController
	add_child(player)
	sprite = player.get_node("Sprite") as AnimatedSprite2D


func after_test() -> void:
	if is_instance_valid(player):
		if player.get_parent() != null:
			player.get_parent().remove_child(player)
		player.free()
	player = null
	sprite = null


func test_dash_frames_are_authored_independently_and_keep_cinderpaw_identity() -> void:
	assert_bool(player.unlock_ability(DASH_ABILITY)).is_true()
	assert_bool(player.request_dash()).is_true()
	assert_str(String(sprite.animation)).is_equal(String(DASH_ANIMATION))
	assert_int(sprite.sprite_frames.get_frame_count(DASH_ANIMATION)).is_equal(
		FRAME_COUNT
	)
	assert_bool(sprite.sprite_frames.get_animation_loop(DASH_ANIMATION)).is_false()
	assert_float(sprite.sprite_frames.get_animation_speed(DASH_ANIMATION)).is_equal_approx(
		18.0,
		0.001
	)

	var previous_dash_data := PackedByteArray()
	for frame_index: int in range(FRAME_COUNT):
		var dash_texture := sprite.sprite_frames.get_frame_texture(
			DASH_ANIMATION,
			frame_index
		)
		var dodge_texture := sprite.sprite_frames.get_frame_texture(
			DODGE_ANIMATION,
			frame_index
		)
		assert_object(dash_texture).is_not_null()
		assert_object(dodge_texture).is_not_null()
		if dash_texture == null or dodge_texture == null:
			continue
		var dash_image := dash_texture.get_image()
		var dodge_image := dodge_texture.get_image()
		assert_object(dash_image).is_not_null()
		assert_object(dodge_image).is_not_null()
		if dash_image == null or dodge_image == null:
			continue

		assert_vector(dash_image.get_size()).is_equal(FRAME_SIZE)
		assert_bool(dash_image.get_data() != dodge_image.get_data()).is_true()
		assert_float(_silhouette_difference_ratio(
			dash_image,
			dodge_image
		)).is_greater_equal(MIN_SILHOUETTE_DIFFERENCE_RATIO)
		if not previous_dash_data.is_empty():
			assert_bool(dash_image.get_data() != previous_dash_data).is_true()
		previous_dash_data = dash_image.get_data()

		var metrics := _measure_identity_pixels(dash_image)
		assert_int(int(metrics.red_scarf_pixels)).is_greater_equal(
			MIN_RED_SCARF_PIXELS
		)
		assert_int(int(metrics.amber_identity_pixels)).is_greater_equal(
			MIN_AMBER_IDENTITY_PIXELS
		)
		assert_float(float(metrics.soft_edge_ratio)).is_less_equal(
			MAX_SOFT_EDGE_RATIO
		)


func _silhouette_difference_ratio(first: Image, second: Image) -> float:
	var union_pixels: int = 0
	var different_pixels: int = 0
	for y: int in range(first.get_height()):
		for x: int in range(first.get_width()):
			var first_visible := first.get_pixel(x, y).a > 0.0
			var second_visible := second.get_pixel(x, y).a > 0.0
			if first_visible or second_visible:
				union_pixels += 1
			if first_visible != second_visible:
				different_pixels += 1
	return (
		float(different_pixels) / float(union_pixels)
		if union_pixels > 0
		else 0.0
	)


func _measure_identity_pixels(image: Image) -> Dictionary:
	var nontransparent_pixels: int = 0
	var soft_edge_pixels: int = 0
	var red_scarf_pixels: int = 0
	var amber_identity_pixels: int = 0
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			if pixel.a <= 0.0:
				continue
			nontransparent_pixels += 1
			if pixel.a < 1.0:
				soft_edge_pixels += 1
			if _is_red_scarf_pixel(pixel):
				red_scarf_pixels += 1
			if _is_amber_identity_pixel(pixel):
				amber_identity_pixels += 1

	return {
		"red_scarf_pixels": red_scarf_pixels,
		"amber_identity_pixels": amber_identity_pixels,
		"soft_edge_ratio": (
			float(soft_edge_pixels) / float(nontransparent_pixels)
			if nontransparent_pixels > 0
			else 1.0
		),
	}


func _is_red_scarf_pixel(pixel: Color) -> bool:
	return (
		pixel.r8 >= 100
		and pixel.g8 <= 65
		and pixel.b8 <= 80
		and float(pixel.r8) >= float(pixel.g8) * 1.6
	)


func _is_amber_identity_pixel(pixel: Color) -> bool:
	return (
		pixel.r8 >= 180
		and pixel.g8 >= 70
		and pixel.g8 <= 200
		and pixel.b8 <= 90
		and float(pixel.r8) >= float(pixel.g8) * 1.15
	)
