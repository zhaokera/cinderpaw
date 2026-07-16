## Owns Story172's post-Boss wall-climb proof, checkpoint, endpoint, and fall zone.
class_name CrownObservatoryEpilogueAscentController
extends Node2D

signal checkpoint_activated
signal ascent_completed
signal fall_requested(provider: Node2D)

const WALL_CLIMB_ABILITY_ID: StringName = &"wall_climb"
const ROUTE_MIN_X: float = 1180.0
const ROUTE_MAX_X: float = 2200.0
const ROUTE_MIN_Y: float = 64.0
const ROUTE_MAX_Y: float = 680.0
const ENDPOINT_RADIUS_PX: float = 132.0
const BACKGROUND_TEXTURE_PATH: String = (
	"res://assets/environment/crown_warden_arena/"
	+ "env_crown_observatory_epilogue_ascent_1280x720.png"
)

@onready var _background: Sprite2D = get_node_or_null("Background") as Sprite2D
@onready var _completion_area: Area2D = (
	get_node_or_null("CompletionArea") as Area2D
)
@onready var _fall_zone: Area2D = get_node_or_null("FallZone") as Area2D
@onready var _endpoint: Marker2D = get_node_or_null("AscentEndpoint") as Marker2D
@onready var _checkpoint_spawn: Marker2D = (
	get_node_or_null("AscentCheckpointSpawn") as Marker2D
)

var _player: Node2D = null
var _scene_owner: Object = null
var _route_available: bool = false
var _wall_climb_proof: bool = false
var _checkpoint_activated: bool = false
var _completed: bool = false
var _wall_climb_event_count: int = 0
var _checkpoint_activation_count: int = 0
var _completion_count: int = 0
var _fall_request_count: int = 0


func _ready() -> void:
	_connect_route_triggers()
	var parent: Node = get_parent()
	if parent != null:
		configure_runtime(
			parent.get_node_or_null("Player") as Node2D,
			parent
		)


func _exit_tree() -> void:
	_disconnect_player_wall_climb_signal()


func configure_runtime(player: Node2D, scene_owner: Object) -> bool:
	if _player != player:
		_disconnect_player_wall_climb_signal()
	_player = player
	_scene_owner = scene_owner
	_connect_player_wall_climb_signal()
	_connect_route_triggers()
	return _player != null and _scene_owner != null


func set_route_available(available: bool) -> void:
	_route_available = available


func restore_progress(checkpoint_active: bool, completed: bool) -> void:
	_completed = completed
	_checkpoint_activated = checkpoint_active or _completed
	_wall_climb_proof = _completed
	_wall_climb_event_count = 0
	_checkpoint_activation_count = 0
	_completion_count = 0
	_fall_request_count = 0


func try_complete(provider: Node = null) -> bool:
	var completion_provider: Node2D = (
		_player if provider == null else provider as Node2D
	)
	if (
		not _route_available
		or _completed
		or not _wall_climb_proof
		or not _has_wall_climb(completion_provider)
		or not _is_provider_near_endpoint(completion_provider)
	):
		return false
	_completed = true
	_checkpoint_activated = true
	_completion_count += 1
	ascent_completed.emit()
	return true


func is_completed() -> bool:
	return _completed


func is_checkpoint_activated() -> bool:
	return _checkpoint_activated


func get_respawn_position() -> Vector2:
	if _completed and _endpoint != null:
		return _endpoint.global_position
	if _checkpoint_activated and _checkpoint_spawn != null:
		return _checkpoint_spawn.global_position
	return Vector2.ZERO


func get_diagnostics() -> Dictionary:
	return {
		"route_available": _route_available,
		"wall_climb_proof": _wall_climb_proof,
		"checkpoint_activated": _checkpoint_activated,
		"completed": _completed,
		"wall_climb_event_count": _wall_climb_event_count,
		"checkpoint_activation_count": _checkpoint_activation_count,
		"completion_count": _completion_count,
		"fall_request_count": _fall_request_count,
		"background_present": _background != null,
		"background_texture_path": _texture_path(_background),
		"background_expected_path": BACKGROUND_TEXTURE_PATH,
		"completion_area_present": _completion_area != null,
		"fall_zone_present": _fall_zone != null,
		"endpoint_position": (
			_endpoint.global_position if _endpoint != null else Vector2.ZERO
		),
		"checkpoint_position": (
			_checkpoint_spawn.global_position
			if _checkpoint_spawn != null
			else Vector2.ZERO
		),
	}


func _connect_player_wall_climb_signal() -> void:
	if _player == null or not _player.has_signal("wall_climb_started"):
		return
	var climb_signal: Signal = _player.get("wall_climb_started")
	if not climb_signal.is_connected(_on_player_wall_climb_started):
		climb_signal.connect(_on_player_wall_climb_started)


func _disconnect_player_wall_climb_signal() -> void:
	if (
		_player == null
		or not is_instance_valid(_player)
		or not _player.has_signal("wall_climb_started")
	):
		return
	var climb_signal: Signal = _player.get("wall_climb_started")
	if climb_signal.is_connected(_on_player_wall_climb_started):
		climb_signal.disconnect(_on_player_wall_climb_started)


func _connect_route_triggers() -> void:
	if (
		_completion_area != null
		and not _completion_area.body_entered.is_connected(
			_on_completion_area_body_entered
		)
	):
		_completion_area.body_entered.connect(_on_completion_area_body_entered)
	if (
		_fall_zone != null
		and not _fall_zone.body_entered.is_connected(_on_fall_zone_body_entered)
	):
		_fall_zone.body_entered.connect(_on_fall_zone_body_entered)


func _on_player_wall_climb_started(
	_texture: Texture2D,
	world_position: Vector2,
	_wall_normal: Vector2
) -> void:
	if (
		not _route_available
		or _completed
		or not _has_wall_climb(_player)
		or world_position.x < ROUTE_MIN_X
		or world_position.x > ROUTE_MAX_X
		or world_position.y < ROUTE_MIN_Y
		or world_position.y > ROUTE_MAX_Y
	):
		return
	_wall_climb_event_count += 1
	_wall_climb_proof = true
	if _checkpoint_activated:
		return
	_checkpoint_activated = true
	_checkpoint_activation_count += 1
	checkpoint_activated.emit()


func _on_completion_area_body_entered(body: Node2D) -> void:
	if body == _player:
		try_complete(body)


func _on_fall_zone_body_entered(body: Node2D) -> void:
	if body != _player or not _route_available:
		return
	_fall_request_count += 1
	fall_requested.emit(body)


func _is_provider_near_endpoint(provider: Node2D) -> bool:
	return (
		provider != null
		and _endpoint != null
		and provider.global_position.distance_to(_endpoint.global_position)
		<= ENDPOINT_RADIUS_PX
	)


func _has_wall_climb(provider: Node) -> bool:
	return (
		provider != null
		and provider.has_method("has_ability")
		and bool(provider.call("has_ability", WALL_CLIMB_ABILITY_ID))
	)


func _texture_path(sprite: Sprite2D) -> String:
	if sprite == null or sprite.texture == null:
		return ""
	return sprite.texture.resource_path
