# Asset Spec: Scrap Roost Hunt Initiation Background

> **Story**: Scene Management 016
> **Generation policy**: built-in image generation, retained source and exact
> prompt, deterministic resize, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Scrap Roost initiation background | Opaque RGB `1280x720`; calm left runway, low middle scrap step, readable far-right mechanical exit, clear lower gameplay lane; no baked actor, enemy, UI, text or collision guide | `res://assets/environment/scrap_roost_hunt_initiation/scrap_roost_hunt_initiation_background_1280x720.png` |

## Visual Direction

The first playable viewport is a quieter Scrap Roost edge rather than a Boss
arena. Layered ruined masonry, patched metal, cables and distant smokestacks
establish the mechanical wasteland while cool blue-grey shadows and restrained
amber dawn light keep Cinderpaw and the Rat Minion readable. The left side is a
safe runway, the center step prompts a jump, and the right arch communicates
forward direction without explicit tutorial text.

## Processing And Import

- Retain the generated `1672x941` source and exact prompt under
  `assets/environment/scrap_roost_hunt_initiation/source/`.
- Resize to exact opaque `1280x720`; do not add alpha, baked collision guides,
  actors, labels or UI.
- Authored Godot nodes own ground, step, walls, gate collision and the unlock
  pulse. The background is presentation only.
- Godot MCP acceptance must confirm the imported background is visible, the
  production AnimatedSprite2D player and Rat Minion render above it, the first
  viewport is non-empty, and no duplicate locked gate obscures the route.
