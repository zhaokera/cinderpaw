## Shared signal-red attack warning visual for focus-aware boss startups.
class_name FocusAttackTell
extends Sprite2D

const FOCUS_AREA_MULTIPLIER: float = 1.25
const FOCUS_DURATION_MULTIPLIER: float = 1.10
const NORMAL_MULTIPLIER: float = 1.0
const PULSE_MIN_ALPHA: float = 0.58
const PULSE_PERIOD_FRAMES: int = 6

var _base_scale: Vector2 = Vector2.ONE
var _base_duration_frames: int = 0
var _total_duration_frames: int = 0
var _remaining_frames: int = 0
var _area_multiplier: float = NORMAL_MULTIPLIER
var _duration_multiplier: float = NORMAL_MULTIPLIER
var _focus_active_at_start: bool = false


func _ready() -> void:
	_base_scale = scale
	stop()


## Starts one warning window and freezes its focus multipliers for this attack.
func begin(base_duration_frames: int, focus_active: bool) -> void:
	_base_duration_frames = maxi(1, base_duration_frames)
	_focus_active_at_start = focus_active
	_area_multiplier = FOCUS_AREA_MULTIPLIER if focus_active else NORMAL_MULTIPLIER
	_duration_multiplier = (
		FOCUS_DURATION_MULTIPLIER if focus_active else NORMAL_MULTIPLIER
	)
	_total_duration_frames = maxi(
		1,
		ceili(float(_base_duration_frames) * _duration_multiplier)
	)
	_remaining_frames = _total_duration_frames
	scale = _base_scale * _area_multiplier
	modulate.a = 1.0
	visible = true


## Advances the authored flash deterministically in gameplay frames.
func advance_frames(frames: int = 1) -> void:
	for _index: int in range(maxi(0, frames)):
		if _remaining_frames <= 0:
			return
		_remaining_frames -= 1
		if _remaining_frames <= 0:
			stop()
			return
		var elapsed_frames: int = _total_duration_frames - _remaining_frames
		var pulse_phase: float = (
			float(elapsed_frames % PULSE_PERIOD_FRAMES)
			/ float(PULSE_PERIOD_FRAMES)
		)
		var triangle_wave: float = 1.0 - absf(pulse_phase * 2.0 - 1.0)
		modulate.a = lerpf(PULSE_MIN_ALPHA, 1.0, triangle_wave)


func stop() -> void:
	_remaining_frames = 0
	visible = false
	scale = _base_scale
	modulate.a = 0.0


func get_diagnostics() -> Dictionary:
	return {
		"node_name": String(name),
		"node_type": get_class(),
		"texture_path": texture.resource_path if texture != null else "",
		"visible": visible,
		"focus_active_at_start": _focus_active_at_start,
		"area_multiplier": _area_multiplier,
		"duration_multiplier": _duration_multiplier,
		"base_duration_frames": _base_duration_frames,
		"total_duration_frames": _total_duration_frames,
		"remaining_frames": _remaining_frames,
		"base_scale": _base_scale,
		"current_scale": scale,
		"alpha": modulate.a,
	}
