## Core entity component that owns hitbox lifecycle state.
extends Node2D
class_name CollisionComponent

const HITBOX_AREA_SCRIPT: Script = preload("res://src/core/hitbox_area.gd")
const HIT_EVENT_SCRIPT: Script = preload("res://src/core/events/hit_event.gd")
const DEFAULT_HURTBOX_SIZE: Vector2 = Vector2(24, 48)
const MIN_HURTBOX_SIZE: Vector2 = Vector2(4, 4)

const HURTBOX_STATE_NORMAL: StringName = &"normal"
const HURTBOX_STATE_SHRUNK: StringName = &"shrunk"
const HURTBOX_STATE_GONE: StringName = &"gone"

const ALLEGIANCE_PLAYER: StringName = &"player"
const ALLEGIANCE_ENEMY: StringName = &"enemy"
const ALLEGIANCE_ENVIRONMENT: StringName = &"environment"
const ALLEGIANCE_NEUTRAL: StringName = &"neutral"

const COLLISION_LAYER_PLAYER_ATTACK: int = 1
const COLLISION_LAYER_ENEMY_ATTACK: int = 2
const COLLISION_LAYER_PLAYER_HURT: int = 4
const COLLISION_LAYER_ENEMY_HURT: int = 8
const COLLISION_LAYER_ENVIRONMENT: int = 16

const COLLISION_MASK_PLAYER_ATTACK: int = COLLISION_LAYER_ENEMY_HURT
const COLLISION_MASK_ENEMY_ATTACK: int = COLLISION_LAYER_PLAYER_HURT
const COLLISION_MASK_ENVIRONMENT: int = (
	COLLISION_LAYER_PLAYER_HURT | COLLISION_LAYER_ENEMY_HURT
)

signal on_hit_confirmed(event: RefCounted)

var _hitboxes: Dictionary = {}
var _active_hitboxes: Array = []
var _entity_id: int = -1
var _allegiance: StringName = ALLEGIANCE_NEUTRAL
var _hurtbox_state: StringName = HURTBOX_STATE_NORMAL
var _normal_hurtbox_size: Vector2 = DEFAULT_HURTBOX_SIZE
var _health_adapter: Object = null
var _hurtbox: Area2D
var _hurtbox_shape: CollisionShape2D


func _init() -> void:
	_hurtbox = Area2D.new()
	_hurtbox.name = "Hurtbox"
	_hurtbox.monitoring = false
	_hurtbox.monitorable = true
	_hurtbox.add_to_group(&"hurtbox")
	_hurtbox_shape = CollisionShape2D.new()
	_hurtbox_shape.name = "CollisionShape2D"
	var rectangle := RectangleShape2D.new()
	rectangle.size = DEFAULT_HURTBOX_SIZE
	_hurtbox_shape.shape = rectangle
	_hurtbox.add_child(_hurtbox_shape)
	add_child(_hurtbox)


func _physics_process(_delta: float) -> void:
	process_detection_frame()


## Activates or creates a hitbox for a deterministic number of frames.
func activate_hitbox(
	hitbox_id: StringName,
	duration_frames: int,
	offset: Vector2,
	size: Vector2,
	attack_metadata: Dictionary = {}
) -> void:
	var hitbox: Area2D = _get_or_create_hitbox(hitbox_id)
	hitbox.activate(hitbox_id, duration_frames, offset, size, attack_metadata)
	if not _active_hitboxes.has(hitbox):
		_active_hitboxes.append(hitbox)


## Configures entity identity and ADR-0004 collision layers.
func configure_entity(p_entity_id: int, p_allegiance: StringName) -> void:
	_entity_id = p_entity_id
	_allegiance = _normalize_allegiance(p_allegiance)
	_apply_collision_configuration()


## Connects a HealthComponent-compatible adapter that emits on_death(entity_id, metadata).
func set_health_adapter(health_adapter: Object) -> void:
	if _health_adapter == health_adapter:
		return
	_disconnect_health_adapter()
	_health_adapter = health_adapter
	if _health_adapter != null and _health_adapter.has_signal("on_death"):
		var death_signal: Signal = _health_adapter.get("on_death")
		if not death_signal.is_connected(_handle_entity_death):
			death_signal.connect(_handle_entity_death)


## Deactivates a hitbox by id; unknown ids are ignored.
func deactivate_hitbox(hitbox_id: StringName) -> void:
	if not _hitboxes.has(hitbox_id):
		return
	var hitbox: Area2D = _hitboxes[hitbox_id]
	hitbox.deactivate()
	_active_hitboxes.erase(hitbox)


## Deactivates every currently active hitbox for terminal cleanup.
func deactivate_all_hitboxes() -> void:
	for hitbox: Area2D in _active_hitboxes.duplicate():
		hitbox.deactivate()
	_active_hitboxes.clear()


## Advances all active hitboxes without relying on engine physics timing.
func advance_hitbox_frames(frames: int) -> void:
	for _index: int in range(maxi(0, frames)):
		_advance_hitboxes_one_frame()


## Runs one frame of hit detection, then advances active hitbox lifetimes.
func process_detection_frame(overlaps_by_hitbox_id: Dictionary = {}) -> void:
	_detect_active_hitboxes(overlaps_by_hitbox_id)
	_advance_hitboxes_one_frame()


## Returns a managed hitbox by id, creating it if needed for deterministic tests.
func get_hitbox(hitbox_id: StringName) -> Area2D:
	return _get_or_create_hitbox(hitbox_id)


## Returns true while a hitbox id is active.
func is_hitbox_active(hitbox_id: StringName) -> bool:
	if not _hitboxes.has(hitbox_id):
		return false
	return bool(_hitboxes[hitbox_id].is_active())


## Returns how many hitboxes are active.
func get_active_hitbox_count() -> int:
	return _active_hitboxes.size()


## Returns the managed hurtbox Area2D for this entity.
func get_hurtbox() -> Area2D:
	return _hurtbox


## Returns the configured entity id.
func get_entity_id() -> int:
	return _entity_id


## Returns normalized allegiance used for layer configuration.
func get_allegiance() -> StringName:
	return _allegiance


## Stores the full-size hurtbox rectangle and reapplies the current state.
func set_hurtbox_size(size: Vector2) -> void:
	_normal_hurtbox_size = Vector2(
		maxf(MIN_HURTBOX_SIZE.x, size.x),
		maxf(MIN_HURTBOX_SIZE.y, size.y)
	)
	_apply_hurtbox_state()


## Applies normal, shrunk, or gone hurtbox state.
func set_hurtbox_state(state: StringName) -> void:
	match state:
		HURTBOX_STATE_NORMAL, HURTBOX_STATE_SHRUNK, HURTBOX_STATE_GONE:
			_hurtbox_state = state
		_:
			_hurtbox_state = HURTBOX_STATE_NORMAL
	_apply_hurtbox_state()


## Returns the normalized hurtbox state.
func get_hurtbox_state() -> StringName:
	return _hurtbox_state


## Returns the currently applied hurtbox rectangle size.
func get_hurtbox_size() -> Vector2:
	var rectangle: RectangleShape2D = _hurtbox_shape.shape as RectangleShape2D
	if rectangle == null:
		return _normal_hurtbox_size
	return rectangle.size


func _get_or_create_hitbox(hitbox_id: StringName) -> Area2D:
	if _hitboxes.has(hitbox_id):
		return _hitboxes[hitbox_id]
	var hitbox: Area2D = HITBOX_AREA_SCRIPT.new()
	hitbox.name = String(hitbox_id)
	_hitboxes[hitbox_id] = hitbox
	_apply_hitbox_collision(hitbox)
	add_child(hitbox)
	return hitbox


func _handle_entity_death(entity_id: int = -1, _metadata: Dictionary = {}) -> void:
	if entity_id != -1 and entity_id != _entity_id:
		return
	deactivate_all_hitboxes()
	set_hurtbox_state(HURTBOX_STATE_GONE)


func _disconnect_health_adapter() -> void:
	if _health_adapter == null or not _health_adapter.has_signal("on_death"):
		return
	var death_signal: Signal = _health_adapter.get("on_death")
	if death_signal.is_connected(_handle_entity_death):
		death_signal.disconnect(_handle_entity_death)


func _advance_hitboxes_one_frame() -> void:
	for hitbox: Area2D in _active_hitboxes.duplicate():
		hitbox.advance_frame()
		if not hitbox.is_active():
			_active_hitboxes.erase(hitbox)


func _detect_active_hitboxes(overlaps_by_hitbox_id: Dictionary) -> void:
	for hitbox: Area2D in _active_hitboxes.duplicate():
		if not hitbox.is_active():
			continue
		for area in _get_overlapping_areas(hitbox, overlaps_by_hitbox_id):
			_try_emit_hit(hitbox, area)


func _get_overlapping_areas(hitbox: Area2D, overlaps_by_hitbox_id: Dictionary) -> Array:
	var hitbox_id: StringName = hitbox.hitbox_id
	if overlaps_by_hitbox_id.has(hitbox_id):
		return overlaps_by_hitbox_id[hitbox_id]
	var string_id := String(hitbox_id)
	if overlaps_by_hitbox_id.has(string_id):
		return overlaps_by_hitbox_id[string_id]
	return hitbox.get_overlapping_areas()


func _try_emit_hit(hitbox: Area2D, area: Variant) -> void:
	var hurtbox: Area2D = area as Area2D
	if not _is_valid_target_hurtbox(hitbox, hurtbox):
		return
	var target_component: Node = hurtbox.get_parent()
	var target_id: int = int(target_component.get_entity_id())
	if hitbox.has_hit(target_id):
		return
	hitbox.mark_hit(target_id)
	_emit_hit_confirmed(hitbox, hurtbox, target_id)


func _is_valid_target_hurtbox(hitbox: Area2D, hurtbox: Area2D) -> bool:
	if hurtbox == null or hurtbox == _hurtbox:
		return false
	if not hurtbox.monitorable or not hurtbox.is_in_group(&"hurtbox"):
		return false
	if (hitbox.collision_mask & hurtbox.collision_layer) == 0:
		return false
	var target_component: Node = hurtbox.get_parent()
	if target_component == self or not target_component.has_method("get_entity_id"):
		return false
	return int(target_component.get_entity_id()) != _entity_id


func _emit_hit_confirmed(hitbox: Area2D, hurtbox: Area2D, target_id: int) -> void:
	var hit_position := (hitbox.global_position + hurtbox.global_position) * 0.5
	var event: RefCounted = HIT_EVENT_SCRIPT.new(
		_entity_id,
		target_id,
		hitbox.hitbox_id,
		hit_position,
		hitbox.get_remaining_frames(),
		hitbox.get_attack_metadata()
	)
	on_hit_confirmed.emit(event)


func _apply_collision_configuration() -> void:
	_hurtbox.collision_layer = _hurtbox_layer_for_allegiance()
	_hurtbox.collision_mask = 0
	for hitbox: Area2D in _hitboxes.values():
		_apply_hitbox_collision(hitbox)


func _apply_hitbox_collision(hitbox: Area2D) -> void:
	hitbox.collision_layer = _hitbox_layer_for_allegiance()
	hitbox.collision_mask = _hitbox_mask_for_allegiance()


func _apply_hurtbox_state() -> void:
	match _hurtbox_state:
		HURTBOX_STATE_SHRUNK:
			_hurtbox.monitorable = true
			_set_hurtbox_rectangle_size(_normal_hurtbox_size * 0.5)
		HURTBOX_STATE_GONE:
			_hurtbox.monitorable = false
			_set_hurtbox_rectangle_size(_normal_hurtbox_size)
		_:
			_hurtbox.monitorable = true
			_hurtbox_state = HURTBOX_STATE_NORMAL
			_set_hurtbox_rectangle_size(_normal_hurtbox_size)


func _set_hurtbox_rectangle_size(size: Vector2) -> void:
	var rectangle: RectangleShape2D = _hurtbox_shape.shape as RectangleShape2D
	if rectangle == null:
		rectangle = RectangleShape2D.new()
		_hurtbox_shape.shape = rectangle
	rectangle.size = size


func _normalize_allegiance(p_allegiance: StringName) -> StringName:
	match p_allegiance:
		ALLEGIANCE_PLAYER, ALLEGIANCE_ENEMY, ALLEGIANCE_ENVIRONMENT:
			return p_allegiance
		_:
			return ALLEGIANCE_NEUTRAL


func _hitbox_layer_for_allegiance() -> int:
	match _allegiance:
		ALLEGIANCE_PLAYER:
			return COLLISION_LAYER_PLAYER_ATTACK
		ALLEGIANCE_ENEMY:
			return COLLISION_LAYER_ENEMY_ATTACK
		ALLEGIANCE_ENVIRONMENT:
			return COLLISION_LAYER_ENVIRONMENT
		_:
			return 0


func _hitbox_mask_for_allegiance() -> int:
	match _allegiance:
		ALLEGIANCE_PLAYER:
			return COLLISION_MASK_PLAYER_ATTACK
		ALLEGIANCE_ENEMY:
			return COLLISION_MASK_ENEMY_ATTACK
		ALLEGIANCE_ENVIRONMENT:
			return COLLISION_MASK_ENVIRONMENT
		_:
			return 0


func _hurtbox_layer_for_allegiance() -> int:
	match _allegiance:
		ALLEGIANCE_PLAYER:
			return COLLISION_LAYER_PLAYER_HURT
		ALLEGIANCE_ENEMY:
			return COLLISION_LAYER_ENEMY_HURT
		_:
			return 0
