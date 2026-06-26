## Minimal single-stage Boss2 shell for the mainline Double Jump payoff.
class_name Boss2EchoGuardian
extends CharacterBody2D

signal boss_health_changed(current_hp: int, max_hp: int)
signal boss_defeated

const ENTITY_ID: int = 2200
const MAX_HP: int = 36
const ANIMATION_IDLE: StringName = &"idle"
const ANIMATION_ATTACK: StringName = &"attack"
const ANIMATION_HURT: StringName = &"hurt"
const ANIMATION_DEATH: StringName = &"death"

@onready var _sprite: AnimatedSprite2D = $Sprite

var _current_hp: int = MAX_HP
var _defeated: bool = false
var _last_hit_metadata: Dictionary = {}


func _ready() -> void:
	_play_animation(ANIMATION_IDLE)
	boss_health_changed.emit(_current_hp, MAX_HP)


func get_entity_id() -> int:
	return ENTITY_ID


func get_current_hp() -> int:
	return _current_hp


func get_max_hp() -> int:
	return MAX_HP


func is_defeated() -> bool:
	return _defeated


func get_last_hit_metadata() -> Dictionary:
	return _last_hit_metadata.duplicate(true)


func request_attack() -> bool:
	if _defeated:
		return false
	_play_animation(ANIMATION_ATTACK)
	return true


func apply_damage(final_damage: int, metadata: Dictionary = {}) -> void:
	if _defeated or final_damage <= 0:
		return
	_last_hit_metadata = metadata.duplicate(true)
	_current_hp = maxi(0, _current_hp - final_damage)
	boss_health_changed.emit(_current_hp, MAX_HP)
	if _current_hp <= 0:
		_defeated = true
		_play_animation(ANIMATION_DEATH)
		collision_layer = 0
		collision_mask = 0
		boss_defeated.emit()
		return
	_play_animation(ANIMATION_HURT)


func reset_encounter() -> void:
	_current_hp = MAX_HP
	_defeated = false
	_last_hit_metadata.clear()
	_play_animation(ANIMATION_IDLE)
	boss_health_changed.emit(_current_hp, MAX_HP)


func _play_animation(animation_name: StringName) -> void:
	if _sprite == null or _sprite.sprite_frames == null:
		return
	if _sprite.sprite_frames.has_animation(animation_name):
		_sprite.play(animation_name)
