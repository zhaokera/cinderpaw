## Builds an unscaled, generated backdrop run behind the Old Factory route.
class_name OldFactoryEnvironmentCohesion
extends Node2D

const TILE_SIZE: Vector2 = Vector2(1280.0, 720.0)
const TILE_COUNT: int = 24
const GAMEPLAY_WIDTH: float = 30080.0
const BACKGROUND_PATHS: Array[String] = [
	"res://assets/environment/old_factory_route/background/"
	+ "env_old_factory_route_entry_1280x720.png",
	"res://assets/environment/old_factory_route/background/"
	+ "env_old_factory_route_furnace_1280x720.png",
	"res://assets/environment/old_factory_route/background/"
	+ "env_old_factory_route_condenser_1280x720.png",
	"res://assets/environment/old_factory_route/background/"
	+ "env_old_factory_route_tailrace_1280x720.png",
]
const TILE_SEQUENCE: Array[int] = [
	0, 1, 0, 2, 1, 2, 3, 2, 1, 3, 3, 3,
	2, 0, 3, 1, 2, 3, 0, 2, 1, 3, 2, 3,
]

var _textures: Array[Texture2D] = []


func _ready() -> void:
	_load_textures()
	_build_tiles()


## Returns the authored tiling and legacy-cover contract for tests and MCP.
func get_diagnostics() -> Dictionary:
	var tile_nodes: Array[Sprite2D] = _get_tile_nodes()
	var unique_texture_paths: Dictionary = {}
	var all_tiles_unscaled: bool = tile_nodes.size() == TILE_COUNT
	var all_tiles_opaque: bool = tile_nodes.size() == TILE_COUNT
	for tile: Sprite2D in tile_nodes:
		all_tiles_unscaled = (
			all_tiles_unscaled
			and tile.scale.is_equal_approx(Vector2.ONE)
			and tile.texture != null
			and Vector2(tile.texture.get_size()).is_equal_approx(TILE_SIZE)
		)
		all_tiles_opaque = (
			all_tiles_opaque and _is_texture_opaque(tile.texture)
		)
		if tile.texture != null:
			unique_texture_paths[tile.texture.resource_path] = true
	var coverage_width: float = float(tile_nodes.size()) * TILE_SIZE.x
	return {
		"variant_count": BACKGROUND_PATHS.size(),
		"tile_count": tile_nodes.size(),
		"unique_texture_count": unique_texture_paths.size(),
		"tile_size": TILE_SIZE,
		"coverage_width": coverage_width,
		"all_tiles_unscaled": all_tiles_unscaled,
		"all_tiles_opaque": all_tiles_opaque,
		"legacy_background_covered": _covers_legacy_background(
			coverage_width
		),
		"texture_paths": BACKGROUND_PATHS.duplicate(),
	}


func _load_textures() -> void:
	_textures.clear()
	for texture_path: String in BACKGROUND_PATHS:
		var texture: Texture2D = load(texture_path) as Texture2D
		if texture != null:
			_textures.append(texture)


func _build_tiles() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.free()
	if _textures.size() != BACKGROUND_PATHS.size():
		return
	for tile_index: int in range(TILE_COUNT):
		var tile := Sprite2D.new()
		tile.name = "FactoryBackdropTile%02d" % tile_index
		tile.texture = _textures[TILE_SEQUENCE[tile_index]]
		tile.position = Vector2(
			TILE_SIZE.x * (float(tile_index) + 0.5),
			TILE_SIZE.y * 0.5
		)
		tile.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tile.centered = true
		tile.scale = Vector2.ONE
		add_child(tile)


func _get_tile_nodes() -> Array[Sprite2D]:
	var tiles: Array[Sprite2D] = []
	for child: Node in get_children():
		var tile: Sprite2D = child as Sprite2D
		if tile != null and String(tile.name).begins_with("FactoryBackdropTile"):
			tiles.append(tile)
	return tiles


func _is_texture_opaque(texture: Texture2D) -> bool:
	if texture == null:
		return false
	var image: Image = texture.get_image()
	return image != null and image.detect_alpha() == Image.ALPHA_NONE


func _covers_legacy_background(coverage_width: float) -> bool:
	var scene_root: Node = get_parent()
	if scene_root == null or coverage_width < GAMEPLAY_WIDTH:
		return false
	var background: CanvasItem = (
		scene_root.get_node_or_null("Background") as CanvasItem
	)
	var post_background: CanvasItem = (
		scene_root.get_node_or_null("PostBulkheadBackground") as CanvasItem
	)
	return (
		background != null
		and post_background != null
		and z_index > background.z_index
		and z_index > post_background.z_index
	)
