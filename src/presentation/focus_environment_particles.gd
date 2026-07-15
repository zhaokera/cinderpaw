## Sparse Main ambience that becomes less intrusive during focus mode.
class_name FocusEnvironmentParticles
extends CPUParticles2D

const NORMAL_ALPHA: float = 1.0
const FOCUS_ALPHA: float = 0.30

var _focus_active: bool = false


func _ready() -> void:
	emitting = true
	_set_environment_alpha(NORMAL_ALPHA)


## Applies only the GDD environment-interference opacity change.
func set_focus_mode(active: bool) -> void:
	_focus_active = active
	_set_environment_alpha(FOCUS_ALPHA if active else NORMAL_ALPHA)


func get_focus_environment_diagnostics() -> Dictionary:
	return {
		"node_name": String(name),
		"node_type": get_class(),
		"texture_path": texture.resource_path if texture != null else "",
		"focus_active": _focus_active,
		"normal_alpha": NORMAL_ALPHA,
		"focus_alpha": FOCUS_ALPHA,
		"current_alpha": modulate.a,
		"emitting": emitting,
		"amount": amount,
		"fixed_seed": use_fixed_seed,
		"seed": seed,
		"z_index": z_index,
		"persistent_screen_overlay": false,
	}


func _set_environment_alpha(alpha: float) -> void:
	var next_modulate: Color = modulate
	next_modulate.a = clampf(alpha, 0.0, 1.0)
	modulate = next_modulate
