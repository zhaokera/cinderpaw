## Story 029: Cinderpaw air animation identity consistency.
extends GdUnitTestSuite

const ANIMATIONS: Array[String] = ["jump", "fall"]
const FRAME_COUNT: int = 3
const FRAME_SIZE: Vector2i = Vector2i(96, 96)
const MIN_RED_SCARF_PIXELS: int = 30
const MIN_AMBER_IDENTITY_PIXELS: int = 30
const MAX_SOFT_EDGE_RATIO: float = 0.08


func test_jump_and_fall_frames_preserve_cinderpaw_identity_and_pixel_edges() -> void:
	for animation_name: String in ANIMATIONS:
		for frame_index: int in range(FRAME_COUNT):
			var frame_path := (
				"res://assets/characters/cinderpaw/%s/cinderpaw_%s_%03d.png"
				% [animation_name, animation_name, frame_index]
			)
			var image := Image.load_from_file(ProjectSettings.globalize_path(frame_path))
			assert_object(image).is_not_null()
			if image == null:
				continue
			assert_vector(image.get_size()).is_equal(FRAME_SIZE)

			var metrics := _measure_identity_pixels(image)
			assert_int(int(metrics.red_scarf_pixels)).is_greater_equal(
				MIN_RED_SCARF_PIXELS
			)
			assert_int(int(metrics.amber_identity_pixels)).is_greater_equal(
				MIN_AMBER_IDENTITY_PIXELS
			)
			assert_float(float(metrics.soft_edge_ratio)).is_less_equal(
				MAX_SOFT_EDGE_RATIO
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
