# Asset Spec: Crown Warden Four-Boss ACT Complete

> **Story**: 168
> **Generation policy**: built-in image generation, retained source,
> deterministic opaque processing, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| ACT Complete Scrap Roost backdrop | Opaque RGB `1280x720`; sunrise settlement, broken mechanical owl crown and glowing paw lantern; no baked text, UI or characters | `res://assets/ui/act_complete/act_complete_scrap_roost_1280x720.png` |
| Retained source and prompt | RGB `1672x941` generated source plus prompt and processing record | `res://assets/ui/act_complete/source/` |

## Visual Direction

The image closes the implemented three-region hunt with a quiet return-home
beat. Rusted steel and cool teal shadows preserve the mechanical-wasteland
identity, while sunrise gold and the paw lantern signal safety and completion.
The broken owl crown references the defeated Crown Warden without displaying a
static character or replacing gameplay animation.

## Processing And Import

- Retain the original `1672x941` RGB source and its recorded prompt.
- Resize to cover `1280x720`, center-crop to the exact runtime canvas, force
  sRGB RGB output and strip incidental metadata.
- Import both source and runtime PNGs through Godot 4.7. Runtime presentation
  preloads only the normalized `1280x720` texture.
- MCP must show the texture filling the game viewport behind a readable menu,
  with no overlap, blank frame or primitive placeholder.

## Character Animation Impact

No character, animation or gameplay state is introduced. Existing Cinderpaw
and Boss actors retain their validated `AnimatedSprite2D + SpriteFrames`
contracts.
