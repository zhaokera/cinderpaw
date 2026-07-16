## Scene-local Old Factory steam vent contact hazard.
class_name FactorySteamVentHazard
extends Area2D

const STEAM_VENT_FRAMES: SpriteFrames = preload(
	"res://assets/environment/old_factory_steam_vent/factory_steam_vent_sprite_frames.tres"
)
const DEFAULT_VISUAL_PHASE: StringName = &"active"
const SAFE_VISUAL_PHASE: StringName = &"safe"

@export var hazard_id: StringName = &"old_factory_steam_vent"
@export var damage: int = 8
@export var contact_cooldown_sec: float = 1.0

@onready var _visual: Sprite2D = get_node_or_null("Visual") as Sprite2D

var _steam_animation: AnimatedSprite2D
var _visual_phase: StringName = DEFAULT_VISUAL_PHASE


func _ready() -> void:
	add_to_group("factory_hazard")
	collision_layer = CollisionComponent.COLLISION_LAYER_ENVIRONMENT
	collision_mask = CollisionComponent.COLLISION_MASK_ENVIRONMENT
	monitoring = true
	monitorable = false
	_ensure_steam_animation()
	if not visibility_changed.is_connected(_sync_animation_playback):
		visibility_changed.connect(_sync_animation_playback)
	set_visual_phase(_visual_phase)


func _process(_delta: float) -> void:
	_sync_animation_playback()


func _sync_animation_playback() -> void:
	if _steam_animation == null:
		return
	var should_play: bool = is_visible_in_tree() and _visual_phase not in [&"idle", &"crossed"]
	if should_play and not _steam_animation.is_playing():
		_steam_animation.play(_steam_animation.animation)
	elif not should_play and _steam_animation.is_playing():
		_steam_animation.stop()
		_steam_animation.frame = 0


func set_visual_phase(phase: StringName) -> void:
	_visual_phase = phase
	if _steam_animation == null:
		return
	var animation_name: StringName = _map_visual_phase_to_animation(phase)
	if _steam_animation.animation != animation_name:
		_steam_animation.play(animation_name)
	else:
		_steam_animation.play()
	if _visual != null:
		_visual.visible = false
	if phase in [&"idle", &"crossed"]:
		_steam_animation.stop()
		_steam_animation.frame = 0
	_sync_animation_playback()


func get_visual_phase() -> StringName:
	return _visual_phase


func get_visual_animation_name() -> StringName:
	return _steam_animation.animation if _steam_animation != null else &""


func get_visual_animation_frame_count(animation_name: StringName) -> int:
	if _steam_animation == null or _steam_animation.sprite_frames == null:
		return 0
	if not _steam_animation.sprite_frames.has_animation(animation_name):
		return 0
	return _steam_animation.sprite_frames.get_frame_count(animation_name)


func get_visual_sprite_frames_path() -> String:
	if _steam_animation == null or _steam_animation.sprite_frames == null:
		return ""
	return _steam_animation.sprite_frames.resource_path


## Returns the deterministic hazard id used by diagnostics and cooldown keys.
func get_hazard_id() -> StringName:
	return hazard_id


## Returns the imported texture path mounted by the visible hazard sprite.
func get_visual_texture_path() -> String:
	if _visual == null or _visual.texture == null:
		return ""
	return _visual.texture.resource_path


## Returns the resolved contact damage for this hazard.
func get_damage() -> int:
	return damage


## Returns the contact cooldown in seconds for repeated overlap damage.
func get_contact_cooldown_sec() -> float:
	return contact_cooldown_sec


func _ensure_steam_animation() -> void:
	_steam_animation = get_node_or_null("SteamAnimation") as AnimatedSprite2D
	if _steam_animation == null:
		_steam_animation = AnimatedSprite2D.new()
		_steam_animation.name = "SteamAnimation"
		add_child(_steam_animation)
	_steam_animation.sprite_frames = STEAM_VENT_FRAMES
	_steam_animation.centered = true
	if _visual != null:
		_steam_animation.position = _visual.position
		_steam_animation.scale = _visual.scale
		_steam_animation.z_index = _visual.z_index
		_visual.visible = false


func _map_visual_phase_to_animation(phase: StringName) -> StringName:
	if phase == &"active":
		return &"active"
	if phase == &"warning":
		return &"warning"
	return SAFE_VISUAL_PHASE
