## Shape-readable schematic minimap view. Gameplay state remains owned by its caller.
class_name MinimapWidget
extends Control

const LOCKED_COLOR: Color = Color("#64748B")
const DISCOVERED_COLOR: Color = Color("#67E8F9")
const CURRENT_COLOR: Color = Color("#ECC94B")
const PLAYER_COLOR: Color = Color("#FFFFFF")
const MAP_BACKGROUND_COLOR: Color = Color(0.03, 0.03, 0.06, 0.38)
const ROUTE_WIDTH: float = 2.0
const REGION_RADIUS: float = 4.5
const MAP_PADDING: float = 8.0

var _regions: Dictionary = {}
var _region_order: Array[String] = []
var _active_reveals: Dictionary = {}
var _current_area_id: StringName = &""
var _player_normalized_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	queue_redraw()


## Replaces the map presentation model with normalized, JSON-safe region definitions.
func configure_regions(region_definitions: Array, current_area_id: StringName) -> void:
	_regions.clear()
	_region_order.clear()
	_active_reveals.clear()
	_current_area_id = current_area_id
	for region_value: Variant in region_definitions:
		if not region_value is Dictionary:
			continue
		var definition: Dictionary = Dictionary(region_value)
		var region_id: String = String(definition.get("id", "")).strip_edges()
		if region_id.is_empty() or _regions.has(region_id):
			continue
		var discovered: bool = bool(definition.get("discovered", false))
		if region_id == String(_current_area_id):
			discovered = true
		var normalized_position: Vector2 = _normalized_position(
			definition.get("position", Vector2.ZERO)
		)
		var connections: Array[String] = []
		for connection_value: Variant in Array(definition.get("connects_to", [])):
			var connection_id: String = String(connection_value).strip_edges()
			if not connection_id.is_empty() and not connections.has(connection_id):
				connections.append(connection_id)
		_regions[region_id] = {
			"id": region_id,
			"display_name": String(definition.get("display_name", region_id)),
			"position": normalized_position,
			"connects_to": connections,
			"discovered": discovered,
			"reveal_progress": 1.0 if discovered else 0.0,
		}
		_region_order.append(region_id)
	queue_redraw()


## Starts a one-shot discovery reveal. Already discovered regions do not replay.
func reveal_region(region_id: StringName, duration_sec: float = 1.0) -> bool:
	var key: String = String(region_id)
	if not _regions.has(key):
		return false
	var region: Dictionary = Dictionary(_regions.get(key, {}))
	if bool(region.get("discovered", false)):
		return false
	region["discovered"] = true
	region["reveal_progress"] = 0.0
	_regions[key] = region
	_active_reveals[key] = {
		"elapsed_sec": 0.0,
		"duration_sec": maxf(0.01, duration_sec),
	}
	queue_redraw()
	return true


## Synchronizes persistence without replaying discovery feedback.
func set_region_discovered(region_id: StringName, discovered: bool) -> bool:
	var key: String = String(region_id)
	if not _regions.has(key):
		return false
	var region: Dictionary = Dictionary(_regions.get(key, {}))
	var changed: bool = (
		bool(region.get("discovered", false)) != discovered
		or not is_equal_approx(
			float(region.get("reveal_progress", 0.0)),
			1.0 if discovered else 0.0
		)
	)
	region["discovered"] = discovered
	region["reveal_progress"] = 1.0 if discovered else 0.0
	_regions[key] = region
	_active_reveals.erase(key)
	if changed:
		queue_redraw()
	return changed


func set_player_world_position(world_position: Vector2, world_bounds: Rect2) -> void:
	var safe_width: float = maxf(0.001, world_bounds.size.x)
	var safe_height: float = maxf(0.001, world_bounds.size.y)
	_player_normalized_position = Vector2(
		clampf((world_position.x - world_bounds.position.x) / safe_width, 0.0, 1.0),
		clampf((world_position.y - world_bounds.position.y) / safe_height, 0.0, 1.0)
	)
	queue_redraw()


func advance_time(delta_sec: float) -> void:
	if _active_reveals.is_empty():
		return
	var safe_delta: float = maxf(0.0, delta_sec)
	for key_value: Variant in _active_reveals.keys():
		var key: String = String(key_value)
		var reveal: Dictionary = Dictionary(_active_reveals.get(key, {}))
		var duration_sec: float = maxf(0.01, float(reveal.get("duration_sec", 1.0)))
		var elapsed_sec: float = minf(
			duration_sec,
			float(reveal.get("elapsed_sec", 0.0)) + safe_delta
		)
		reveal["elapsed_sec"] = elapsed_sec
		_active_reveals[key] = reveal
		var region: Dictionary = Dictionary(_regions.get(key, {}))
		region["reveal_progress"] = clampf(elapsed_sec / duration_sec, 0.0, 1.0)
		_regions[key] = region
		if elapsed_sec >= duration_sec:
			_active_reveals.erase(key)
	queue_redraw()


func get_diagnostics() -> Dictionary:
	var region_snapshots: Dictionary = {}
	for region_id: String in _region_order:
		var region: Dictionary = Dictionary(_regions.get(region_id, {}))
		var discovered: bool = bool(region.get("discovered", false))
		region_snapshots[region_id] = {
			"display_name": String(region.get("display_name", region_id)),
			"position": region.get("position", Vector2.ZERO),
			"connects_to": Array(region.get("connects_to", [])).duplicate(),
			"discovered": discovered,
			"reveal_progress": float(region.get("reveal_progress", 0.0)),
			"shape": "filled" if discovered else "hollow",
		}
	return {
		"current_area_id": String(_current_area_id),
		"regions": region_snapshots,
		"active_reveal_count": _active_reveals.size(),
		"player_normalized_x": _player_normalized_position.x,
		"player_normalized_y": _player_normalized_position.y,
		"player_draw_position": _player_draw_position(),
		"shape_readable": true,
		"render_mode": "code_drawn_schematic",
	}


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var map_rect := Rect2(
		Vector2(MAP_PADDING, MAP_PADDING),
		Vector2(
			maxf(1.0, size.x - MAP_PADDING * 2.0),
			maxf(1.0, size.y - MAP_PADDING * 2.0)
		)
	)
	draw_rect(Rect2(Vector2.ZERO, size), MAP_BACKGROUND_COLOR, true)
	_draw_connections(map_rect)
	_draw_regions(map_rect)
	_draw_player_marker()


func _draw_connections(map_rect: Rect2) -> void:
	for region_id: String in _region_order:
		var region: Dictionary = Dictionary(_regions.get(region_id, {}))
		var start: Vector2 = _map_point(region.get("position", Vector2.ZERO), map_rect)
		for connection_value: Variant in Array(region.get("connects_to", [])):
			var target_id: String = String(connection_value)
			if not _regions.has(target_id):
				continue
			var target: Dictionary = Dictionary(_regions.get(target_id, {}))
			var end: Vector2 = _map_point(target.get("position", Vector2.ZERO), map_rect)
			var connection_progress: float = minf(
				float(region.get("reveal_progress", 0.0)),
				float(target.get("reveal_progress", 0.0))
			)
			draw_line(
				start,
				end,
				LOCKED_COLOR.lerp(DISCOVERED_COLOR, connection_progress),
				ROUTE_WIDTH,
				true
			)


func _draw_regions(map_rect: Rect2) -> void:
	for region_id: String in _region_order:
		var region: Dictionary = Dictionary(_regions.get(region_id, {}))
		var point: Vector2 = _map_point(region.get("position", Vector2.ZERO), map_rect)
		var progress: float = clampf(float(region.get("reveal_progress", 0.0)), 0.0, 1.0)
		if region_id == String(_current_area_id):
			_draw_diamond(point, CURRENT_COLOR)
			continue
		draw_circle(point, REGION_RADIUS, LOCKED_COLOR, false, 1.5, true)
		if bool(region.get("discovered", false)):
			var reveal_color: Color = LOCKED_COLOR.lerp(DISCOVERED_COLOR, progress)
			draw_circle(point, maxf(1.0, REGION_RADIUS * progress), reveal_color, true)


func _draw_diamond(point: Vector2, color: Color) -> void:
	var radius: float = REGION_RADIUS + 1.0
	var points := PackedVector2Array([
		point + Vector2(0, -radius),
		point + Vector2(radius, 0),
		point + Vector2(0, radius),
		point + Vector2(-radius, 0),
	])
	draw_colored_polygon(points, color)


func _draw_player_marker() -> void:
	var point: Vector2 = _player_draw_position()
	var points := PackedVector2Array([
		point + Vector2(0, -4.0),
		point + Vector2(3.5, 3.0),
		point + Vector2(-3.5, 3.0),
	])
	draw_colored_polygon(points, PLAYER_COLOR)
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[0]]), CURRENT_COLOR, 1.0, true)


func _player_draw_position() -> Vector2:
	var current: Dictionary = Dictionary(_regions.get(String(_current_area_id), {}))
	var map_rect := Rect2(
		Vector2(MAP_PADDING, MAP_PADDING),
		Vector2(
			maxf(1.0, size.x - MAP_PADDING * 2.0),
			maxf(1.0, size.y - MAP_PADDING * 2.0)
		)
	)
	var current_point: Vector2 = _map_point(current.get("position", Vector2(0.5, 0.5)), map_rect)
	return current_point + Vector2(lerpf(-6.0, 6.0, _player_normalized_position.x), 9.0)


func _map_point(normalized_value: Variant, map_rect: Rect2) -> Vector2:
	var normalized: Vector2 = _normalized_position(normalized_value)
	return map_rect.position + normalized * map_rect.size


func _normalized_position(value: Variant) -> Vector2:
	var position_value: Vector2 = value if value is Vector2 else Vector2.ZERO
	return Vector2(
		clampf(position_value.x, 0.0, 1.0),
		clampf(position_value.y, 0.0, 1.0)
	)
