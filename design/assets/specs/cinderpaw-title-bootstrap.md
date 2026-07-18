# Asset Spec: Cinderpaw Title Bootstrap

> **Story**: Scene Management 015
> **Generation policy**: built-in image generation, retained sources,
> deterministic alpha processing, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Title threshold background | Opaque RGB `1280x720`; cold dark left field, warm industrial threshold and empty right platform; no baked actor, text or UI | `res://assets/ui/title/cinderpaw_title_threshold_background_1280x720.png` |
| Seated Cinderpaw title idle | Six transparent sRGBA `512x512` frames with common anchor/baseline, continuous names and subtle breathing, tail and ear motion | `res://assets/characters/cinderpaw/title_idle/` |
| Title animation resource | `SpriteFrames` with looping six-frame `title_idle`, consumed by a visible `AnimatedSprite2D` | `res://assets/characters/cinderpaw/cinderpaw_title_sprite_frames.tres` |

## Visual Direction

The first viewport follows the Art Bible's threshold identity: Cinderpaw sits
on the warm side of a cold/warm industrial boundary while the left side remains
quiet enough for the brand and entry actions. Character and background are
separate runtime layers so the title never relies on a baked static hero.

## Processing And Import

- Retain the background edit source and exact prompt under
  `assets/generated/source/`.
- Retain the keyed sprite sheet, alpha intermediate and exact prompt under
  `assets/characters/cinderpaw/source/`.
- Isolate all six complete connected components and align them to one right edge
  and ground line before import; reject cross-cell fragments or magenta fringe.
- The scene must use `AnimatedSprite2D + SpriteFrames`, keep the menu within the
  `1280x720` safe area, and expose keyboard and gamepad focus.
- Godot MCP acceptance must confirm six imported frames, active playback,
  non-empty screenshot, title-only boot, clean logs and New Game transition.
