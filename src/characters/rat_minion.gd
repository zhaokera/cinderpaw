## Rat King summoned minion character frame animation surface.
class_name RatMinionCharacter
extends AnimatedSprite2D

const IDLE_ANIMATION: StringName = &"idle"


func _ready() -> void:
	if sprite_frames != null and sprite_frames.has_animation(IDLE_ANIMATION):
		play(IDLE_ANIMATION)
