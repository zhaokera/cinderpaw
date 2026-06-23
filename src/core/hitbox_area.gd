## Attack hitbox area with activation lifetime and duplicate-hit tracking.
extends Area2D
class_name HitboxArea

const MIN_HITBOX_SIZE: Vector2 = Vector2(4, 4)

var hitbox_id: StringName = &""
var remaining_frames: int = 0
var attack_metadata: Dictionary = {}

var _hit_targets: Dictionary = {}
var _shape: CollisionShape2D


func _init() -> void:
	monitoring = false
	monitorable = false
	_shape = CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = MIN_HITBOX_SIZE
	_shape.shape = rectangle
	add_child(_shape)


## Activates this hitbox for a deterministic number of physics frames.
func activate(
	p_hitbox_id: StringName,
	duration_frames: int,
	offset: Vector2,
	size: Vector2,
	metadata: Dictionary = {}
) -> void:
	hitbox_id = p_hitbox_id
	position = offset
	remaining_frames = maxi(1, duration_frames)
	attack_metadata = metadata.duplicate(true)
	clear_hits()
	_set_size(size)
	monitoring = true


## Deactivates this hitbox without clearing configuration data.
func deactivate() -> void:
	monitoring = false
	remaining_frames = 0


## Advances this hitbox's active lifetime by one frame.
func advance_frame() -> void:
	if not is_active():
		return
	remaining_frames = maxi(0, remaining_frames - 1)
	if remaining_frames == 0:
		deactivate()


## Returns true while this hitbox participates in detection.
func is_active() -> bool:
	return monitoring and remaining_frames > 0


## Records that this hitbox already hit a target during the current activation.
func mark_hit(target_id: int) -> void:
	_hit_targets[target_id] = true


## Returns true when the target was already hit by the current activation.
func has_hit(target_id: int) -> bool:
	return bool(_hit_targets.get(target_id, false))


## Clears duplicate-hit tracking for a fresh activation.
func clear_hits() -> void:
	_hit_targets.clear()


## Returns remaining active frames.
func get_remaining_frames() -> int:
	return remaining_frames


## Returns a copy of attack metadata associated with this activation.
func get_attack_metadata() -> Dictionary:
	return attack_metadata.duplicate(true)


## Returns the current rectangle hitbox size.
func get_hitbox_size() -> Vector2:
	var rectangle: RectangleShape2D = _shape.shape as RectangleShape2D
	if rectangle == null:
		return MIN_HITBOX_SIZE
	return rectangle.size


func _set_size(size: Vector2) -> void:
	var safe_size: Vector2 = Vector2(
		maxf(MIN_HITBOX_SIZE.x, size.x),
		maxf(MIN_HITBOX_SIZE.y, size.y)
	)
	var rectangle: RectangleShape2D = _shape.shape as RectangleShape2D
	if rectangle == null:
		rectangle = RectangleShape2D.new()
		_shape.shape = rectangle
	rectangle.size = safe_size
