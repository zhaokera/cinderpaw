# Asset Spec: Sewer Pressure Chamber Background

> **Story**: Scene Management 021
> **Generation policy**: built-in image generation, retained source and prompt,
> deterministic resize, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Sewer pressure chamber background | Opaque RGB `1280x720`; strict side view; continuous readable combat floor; broad middle combat lane; wet steel-blue machinery, rusted copper and restrained green runoff; high unreachable maintenance ledge at upper right; no baked actor, enemy, reward, gate, hazard, UI, text or collision guide | `res://assets/environment/sewer_pressure_chamber/sewer_pressure_chamber_background_1280x720.png` |

The plate extends `area_02_sewer` from `x=1280..2560`. Authored Godot nodes own
the floor, encounter trigger, animated back-pressure vent, blocking seal,
frame-animated leech, one-shot cache, exit and camera limits.

## Reuse Contract

- Reuse `FactorySluiceLeech` with `AnimatedSprite2D + SpriteFrames` and six
  gameplay animations: `idle`, `run`, `attack_tell`, `attack`, `hurt`, `death`.
  Every animation retains three transparent, common-anchor frames.
- Reuse the four-frame Old Factory steam vent for `safe`, `warning` and
  `active`; reuse the Underground seal and salvage cache as separate props.
- Do not bake the high ledge into a traversable route or grant Double Jump.
  Sewer-to-Factory remains blocked by the GDD ability requirement.

## Processing And Acceptance

- Retain the `1672x941` opaque RGB source and exact prompt under
  `assets/environment/sewer_pressure_chamber/source/`.
- Normalize to exact opaque RGB `1280x720` without alpha or painted actors.
- Godot MCP must confirm the imported plate, production Player, frame-animated
  leech, animated pressure vent, seal/cache visibility, non-empty screenshot and
  clean game/editor logs.
