# Asset Spec: Neon Rooftops Magnetic Wall Gate Handoff

## Purpose

Story136 must make the first Neon Rooftops arrival read as a new area and an
immediate ACT traversal challenge. The generated environment carries the actual
ruined rooftop world, while generated route props make the Factory connection
and magnetic-wall affordance visible without exposing collision primitives.

## Runtime Assets

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Neon Rooftops entry background | Opaque RGB `1280x720`; readable lower roof, vertical climb break, one-way high roof, moonlit ruined cat-city depth | `res://assets/environment/neon_rooftops/env_neon_rooftops_entry_1280x720.png` |
| Neon magnetic tower | Transparent RGBA `256x512`; tall cat-ear steel climb panel, cyan magnetic seams, claw grips, safe alpha padding | `res://assets/environment/neon_rooftops/prop_neon_magnetic_tower_256x512.png` |
| Factory bridge beacon | Transparent RGBA `256x384`; cat-paw route core, cyan/violet signal lights, grated industrial base | `res://assets/environment/neon_rooftops/prop_neon_factory_bridge_beacon_256x384.png` |

## Scene Use

- Factory Upper Altar places the bridge beacon on the Story135 proof perch as
  the registered Neon Rooftops route landmark and return spawn.
- Neon Rooftops reuses the beacon at the lower Factory return point and overlays
  the generated magnetic tower on authored StaticBody2D wall collision.
- Lower/upper roofs, side/top bounds, proof Area2D, and route interaction areas
  are invisible authored collision. The generated art remains the only visible
  environment surface.
- Cinderpaw reuses the Story135 three-frame `wall_climb` SpriteFrames animation
  and generated contact glow; no new character sheet is required.

## Acceptance

- Godot imports source, alpha, and all three runtime PNGs without resource errors.
- Background is exact opaque `1280x720`; both props preserve alpha, safe padding,
  consistent scale, and clean keyed edges.
- MCP gameplay shows Cinderpaw visibly climbing the generated tower against the
  actual generated rooftop scene, with bridge beacon, HUD, and readable objective.
- No visible ColorRect, debug collision shape, flat rectangle, floating primitive,
  baked text, or single-frame character substitute is accepted.
