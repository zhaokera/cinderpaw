## Cinderpaw player character frame animation surface.
##
## Gameplay authority stays in PlayerController; this node owns only the
## AnimatedSprite2D/SpriteFrames presentation contract.
class_name CinderpawCharacter
extends AnimatedSprite2D

const IDLE_ANIMATION: StringName = &"idle"


func _ready() -> void:
	if sprite_frames != null and sprite_frames.has_animation(IDLE_ANIMATION):
		play(IDLE_ANIMATION)
