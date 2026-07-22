## Frame-animated presentation for the Old Factory lower-deck pressure valve.
class_name FactoryPressureValveAnimation
extends AnimatedSprite2D

const HIDDEN_STATE: StringName = &"hidden"
const CLOSED_IDLE_ANIMATION: StringName = &"closed_idle"
const OPENING_ANIMATION: StringName = &"opening"
const OPENED_IDLE_ANIMATION: StringName = &"opened_idle"
const ASSET_SOURCE_PATH: String = (
	"res://assets/environment/old_factory_pressure_valve/source/"
	+ "factory_pressure_valve_motion_sheet_imagegen_20260720.png"
)
const ASSET_SPEC_PATH: String = (
	"res://design/assets/specs/old-factory-pressure-valve-authored-motion.md"
)
const ASSET_MANIFEST_PATH: String = "res://design/assets/asset-manifest.md"
const LOCKED_MODULATE: Color = Color(0.56, 0.62, 0.72, 0.72)
const AVAILABLE_MODULATE: Color = Color.WHITE
const ACTIVATED_MODULATE: Color = Color(0.85, 1.0, 0.72, 1.0)

var _visual_state: StringName = HIDDEN_STATE


func _ready() -> void:
	visible = false
	stop()
	frame = 0
	if not animation_finished.is_connected(_on_animation_finished):
		animation_finished.connect(_on_animation_finished)


## Mirrors endpoint state without owning interaction or progression.
func sync_endpoint_state(present: bool, available: bool, activated: bool) -> void:
	_sync_endpoint_tint(available, activated)
	if not present:
		_set_hidden()
		return
	if activated:
		_sync_activated_state()
		return
	if _visual_state != CLOSED_IDLE_ANIMATION:
		_play_state(CLOSED_IDLE_ANIMATION)
		return
	visible = true
	if not is_playing():
		play(CLOSED_IDLE_ANIMATION)


func get_diagnostics() -> Dictionary:
	var frame_counts: Dictionary = {}
	var loop_modes: Dictionary = {}
	if sprite_frames != null:
		for animation_name: StringName in [
			CLOSED_IDLE_ANIMATION,
			OPENING_ANIMATION,
			OPENED_IDLE_ANIMATION,
		]:
			frame_counts[String(animation_name)] = (
				sprite_frames.get_frame_count(animation_name)
				if sprite_frames.has_animation(animation_name)
				else 0
			)
			loop_modes[String(animation_name)] = (
				sprite_frames.get_animation_loop(animation_name)
				if sprite_frames.has_animation(animation_name)
				else false
			)
	return {
		"present": true,
		"class": get_class(),
		"state": String(_visual_state),
		"animation": String(animation),
		"visible": visible,
		"visible_in_tree": is_visible_in_tree(),
		"playing": is_playing(),
		"frame": frame,
		"frame_counts": frame_counts,
		"loop_modes": loop_modes,
		"texture_filter": texture_filter,
		"modulate": modulate,
		"sprite_frames_path": (
			sprite_frames.resource_path if sprite_frames != null else ""
		),
		"asset_source": ASSET_SOURCE_PATH,
		"asset_spec_path": ASSET_SPEC_PATH,
		"asset_manifest_path": ASSET_MANIFEST_PATH,
	}


func _sync_activated_state() -> void:
	if _visual_state == HIDDEN_STATE:
		_play_state(OPENED_IDLE_ANIMATION)
		return
	if _visual_state == CLOSED_IDLE_ANIMATION:
		_play_state(OPENING_ANIMATION)
		return
	visible = true
	if _visual_state == OPENED_IDLE_ANIMATION and not is_playing():
		play(OPENED_IDLE_ANIMATION)


func _set_hidden() -> void:
	_visual_state = HIDDEN_STATE
	visible = false
	stop()
	frame = 0


func _play_state(state: StringName) -> void:
	visible = true
	if sprite_frames == null or not sprite_frames.has_animation(state):
		_visual_state = state
		stop()
		return
	if _visual_state == state and animation == state:
		return
	_visual_state = state
	play(state)


func _on_animation_finished() -> void:
	if _visual_state == OPENING_ANIMATION and animation == OPENING_ANIMATION:
		_play_state(OPENED_IDLE_ANIMATION)


func _sync_endpoint_tint(available: bool, activated: bool) -> void:
	if activated:
		modulate = ACTIVATED_MODULATE
	elif available:
		modulate = AVAILABLE_MODULATE
	else:
		modulate = LOCKED_MODULATE
