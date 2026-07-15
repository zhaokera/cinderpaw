## Story019: Boss phase overlay protects the combat center and clears quickly.
extends GdUnitTestSuite

const COMBAT_PRESENTATION_SCRIPT: Script = preload(
	"res://src/presentation/combat_presentation.gd"
)
const READABLE_OVERLAY_PATH: String = (
	"res://assets/generated/combat_boss_phase_overlay_readable.png"
)
const SAFE_RECT: Rect2i = Rect2i(320, 180, 640, 360)

var _presentation: CombatPresentation = null


func before_test() -> void:
	_presentation = COMBAT_PRESENTATION_SCRIPT.new() as CombatPresentation
	add_child(_presentation)


func after_test() -> void:
	if _presentation == null or not is_instance_valid(_presentation):
		return
	if _presentation.get_parent() != null:
		_presentation.get_parent().remove_child(_presentation)
	_presentation.free()
	_presentation = null


func test_phase_overlay_keeps_center_clear_then_exits_before_debris() -> void:
	assert_bool(FileAccess.file_exists(READABLE_OVERLAY_PATH)).override_failure_message(
		"Story019 requires a dedicated center-clear generated overlay"
	).is_true()
	assert_bool(_presentation.has_method(
		"get_boss_phase_overlay_readability_diagnostics"
	)).override_failure_message(
		"Story019 requires runtime overlay readability diagnostics"
	).is_true()
	if (
		not FileAccess.file_exists(READABLE_OVERLAY_PATH)
		or not _presentation.has_method(
			"get_boss_phase_overlay_readability_diagnostics"
		)
	):
		return

	_presentation.on_boss_phase_transition_started(
		42,
		3,
		{
			"boss_id": &"story019_probe",
			"world_position": Vector2(640.0, 360.0),
		}
	)
	var diagnostics: Dictionary = _presentation.call(
		"get_boss_phase_overlay_readability_diagnostics"
	)
	var overlay_layer: CanvasLayer = diagnostics.get("node", null) as CanvasLayer
	var overlay: TextureRect = (
		overlay_layer.get_node_or_null("BossPhaseOverlay") as TextureRect
		if overlay_layer != null
		else null
	)

	assert_bool(bool(diagnostics.get("active", false))).is_true()
	assert_str(String(diagnostics.get("layer_name", ""))).is_equal(
		"BossPhaseOverlayLayer"
	)
	assert_str(String(diagnostics.get("overlay_name", ""))).is_equal(
		"BossPhaseOverlay"
	)
	assert_str(String(diagnostics.get("overlay_type", ""))).is_equal(
		"TextureRect"
	)
	assert_str(String(diagnostics.get("texture_path", ""))).is_equal(
		READABLE_OVERLAY_PATH
	)
	assert_bool(bool(diagnostics.get("texture_loaded", false))).is_true()
	assert_int(int(diagnostics.get("canvas_layer", -1))).is_equal(0)
	assert_int(int(diagnostics.get("mouse_filter", -1))).is_equal(
		Control.MOUSE_FILTER_IGNORE
	)
	assert_float(float(diagnostics.get("lifetime_sec", 0.0))).is_equal_approx(
		0.4,
		0.001
	)
	assert_bool(
		Rect2(diagnostics.get("center_safe_rect", Rect2()))
		== Rect2(0.25, 0.25, 0.5, 0.5)
	).is_true()
	assert_int(_presentation.get_active_boss_phase_overlay_count()).is_equal(1)
	assert_int(_presentation.get_active_boss_phase_debris_count()).is_equal(32)
	assert_object(overlay).is_not_null()
	if overlay != null:
		assert_vector(overlay.position).is_equal(Vector2.ZERO)
		assert_vector(overlay.size).is_equal(Vector2(1280.0, 720.0))
		assert_vector(overlay.texture.get_size()).is_equal(overlay.size)

	var overlay_image: Image = Image.load_from_file(
		ProjectSettings.globalize_path(READABLE_OVERLAY_PATH)
	)
	assert_object(overlay_image).is_not_null()
	assert_int(overlay_image.get_width()).is_equal(1280)
	assert_int(overlay_image.get_height()).is_equal(720)
	assert_int(_count_nontransparent_pixels(overlay_image, SAFE_RECT)).is_equal(0)

	_presentation.advance_time(0.39)
	assert_int(_presentation.get_active_boss_phase_overlay_count()).is_equal(1)
	assert_int(_presentation.get_active_boss_phase_debris_count()).is_equal(32)

	_presentation.advance_time(0.02)
	assert_int(_presentation.get_active_boss_phase_overlay_count()).is_equal(0)
	assert_int(_presentation.get_active_boss_phase_debris_count()).is_equal(32)
	assert_bool(
		overlay_layer != null and overlay_layer.is_queued_for_deletion()
	).is_true()

	_presentation.advance_time(1.10)
	assert_int(_presentation.get_active_boss_phase_debris_count()).is_equal(0)


func _count_nontransparent_pixels(image: Image, rect: Rect2i) -> int:
	var count: int = 0
	for y: int in range(rect.position.y, rect.end.y):
		for x: int in range(rect.position.x, rect.end.x):
			if image.get_pixel(x, y).a > 0.001:
				count += 1
	return count
