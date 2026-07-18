## Combat Presentation Story 035: Rat King phase-I intro is not idle duplication.
extends GdUnitTestSuite

const SPRITE_FRAMES_PATH: String = (
	"res://assets/characters/rat_king/rat_king_sprite_frames.tres"
)
const GENERATED_SOURCE_PATH: String = (
	"res://assets/characters/rat_king/source/"
	+ "rat_king_phase_1_intro_sheet_imagegen_20260718.png"
)
const PROMPT_RECORD_PATH: String = (
	"res://assets/characters/rat_king/source/"
	+ "rat_king_phase_1_intro_sheet_imagegen_20260718.md"
)
const INTRO_FRAME_PATHS: Array[String] = [
	"res://assets/characters/rat_king/phase_1_intro/rat_king_phase_1_intro_000.png",
	"res://assets/characters/rat_king/phase_1_intro/rat_king_phase_1_intro_001.png",
	"res://assets/characters/rat_king/phase_1_intro/rat_king_phase_1_intro_002.png",
]
const IDLE_FRAME_PATHS: Array[String] = [
	"res://assets/characters/rat_king/idle/rat_king_idle_000.png",
	"res://assets/characters/rat_king/idle/rat_king_idle_001.png",
	"res://assets/characters/rat_king/idle/rat_king_idle_002.png",
]


func test_phase_one_intro_uses_authored_generated_frames_instead_of_idle_copies() -> void:
	assert_bool(FileAccess.file_exists(GENERATED_SOURCE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(PROMPT_RECORD_PATH)).is_true()

	var sprite_frames: SpriteFrames = load(SPRITE_FRAMES_PATH) as SpriteFrames
	assert_that(sprite_frames).is_not_null()
	if sprite_frames == null:
		return
	assert_bool(sprite_frames.has_animation(&"phase_1_intro")).is_true()
	assert_int(sprite_frames.get_frame_count(&"phase_1_intro")).is_equal(3)
	assert_bool(sprite_frames.get_animation_loop(&"phase_1_intro")).is_false()

	var intro_hashes: Array[String] = []
	for index: int in range(INTRO_FRAME_PATHS.size()):
		var intro_path: String = INTRO_FRAME_PATHS[index]
		var idle_path: String = IDLE_FRAME_PATHS[index]
		assert_bool(FileAccess.file_exists(intro_path)).is_true()
		assert_bool(FileAccess.file_exists("%s.import" % intro_path)).is_true()
		if not FileAccess.file_exists(intro_path):
			continue
		var image := Image.new()
		var load_error: Error = image.load_png_from_buffer(
			FileAccess.get_file_as_bytes(intro_path)
		)
		assert_int(load_error).is_equal(OK)
		if load_error != OK:
			continue
		assert_int(image.get_width()).is_equal(192)
		assert_int(image.get_height()).is_equal(192)
		assert_bool(image.detect_alpha() != Image.ALPHA_NONE).is_true()
		var intro_hash: String = _sha256_file(intro_path)
		intro_hashes.append(intro_hash)
		assert_str(intro_hash).is_not_equal(_sha256_file(idle_path))

	var unique_hashes: Dictionary = {}
	for frame_hash: String in intro_hashes:
		unique_hashes[frame_hash] = true
	assert_int(unique_hashes.size()).is_equal(3)


func _sha256_file(path: String) -> String:
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK:
		return ""
	if context.update(FileAccess.get_file_as_bytes(path)) != OK:
		return ""
	return context.finish().hex_encode()
