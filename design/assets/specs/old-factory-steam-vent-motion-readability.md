# Asset Spec: Old Factory Steam Vent Motion Readability

> **Story**: Combat Presentation 033
> **Generation policy**: built-in image generation with the existing vent prop
> as reference, chroma-key alpha processing, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Safe steam state | Four transparent sRGBA `256x256` frames with only low vapor wisps | `res://assets/environment/old_factory_steam_vent/safe/factory_steam_vent_safe_000.png` through `_003.png` |
| Warning steam state | Four transparent sRGBA `256x256` buildup frames with compressed steam and brighter lamp | `res://assets/environment/old_factory_steam_vent/warning/factory_steam_vent_warning_000.png` through `_003.png` |
| Active steam state | Four transparent sRGBA `256x256` forceful plume frames with an unchanged vent base | `res://assets/environment/old_factory_steam_vent/active/factory_steam_vent_active_000.png` through `_003.png` |
| Shared SpriteFrames | Looping `safe` at `6 FPS`, `warning` at `12 FPS`, and `active` at `10 FPS` | `res://assets/environment/old_factory_steam_vent/factory_steam_vent_sprite_frames.tres` |
| Retained source | RGB contact sheet, alpha intermediate, preview and prompt record | `res://assets/environment/old_factory_steam_vent/source/factory_steam_vent_motion_*_20260716.*` |

## Visual Direction

Keep the existing squat circular cracked-steel vent, front status lamp, side
pipe silhouette, scale, center and ground baseline fixed. State readability
comes only from plume height, vapor compression and lamp intensity: `safe` is
quiet, `warning` stores pressure, and `active` is a tall dangerous blast.

## Processing And Import

- Generate a strict four-column by three-row contact sheet on uniform magenta,
  using the existing runtime prop as identity and perspective reference.
- Remove `#ff00ff` with soft matte thresholds `28/90`, one-pixel edge contract
  and despill; retain the full alpha intermediate.
- Crop each source cell and downsample it onto an exact transparent `256x256`
  runtime canvas without moving the shared vent base. Active cells use the
  larger source crop required to keep the plume unclipped.
- Import all twelve frames with Godot 4.7 and expose one shared SpriteFrames
  resource to every Factory steam-vent hazard instance.
- MCP acceptance must show the dynamic `AnimatedSprite2D`, phase animation,
  frame movement, unchanged hazard diagnostics, clean logs and a non-empty
  gameplay screenshot.
