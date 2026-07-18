# Asset Spec: Sewer Dash Route Background

> **Story**: Scene Management 020
> **Generation policy**: built-in image generation, retained source and prompts,
> deterministic resize, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Sewer Dash route background | Opaque RGB `1280x720`; strict side view; cracked commercial-street concrete and brick on the left, a centered dark drain gap, riveted factory steel and a circular hatch on the right; readable amber edge lights; no baked actor, enemy, UI, text, collision guide or bridge | `res://assets/environment/sewer_dash_route/sewer_dash_route_background_1280x720.png` |

The production Player, the real `92px` collision gap, the animated exhaust
hazard, reset zones, exit and HUD remain separate Godot nodes. The plate is
presentation only and cannot authorize a successful crossing.

## Visual Direction

The room should read as a short industrial threshold between the ruined city
and the Old Factory. Wet charcoal masonry and broken concrete establish the
Sewer side, oxidized copper pipes lead the eye across the center, and riveted
steel plus cyan hatch light foreshadow the Factory. Warm edge lamps clearly
separate the two safe surfaces from the open drain without tutorial text.

## Processing And Import

- Retain the final generated `1672x941` opaque RGB source and all generation/edit
  prompts under `assets/environment/sewer_dash_route/source/`.
- Resize deterministically to exact opaque RGB `1280x720`; do not add alpha,
  actors, labels, UI, collision guides or a painted bridge.
- Author runtime platform edges at `x=588` and `x=680`, producing a real `92px`
  gap aligned with the generated dark opening.
- The final image does not visually lower its overhead pipe enough to reject a
  jump. Reuse the existing four-frame steam-vent `SpriteFrames` as the visible
  active contact volume rather than relying on invisible ceiling collision.
- Godot MCP acceptance must confirm the imported plate is visible, Player/Sprite
  and the exhaust are `AnimatedSprite2D`, Dash has at least three frames,
  exhaust `active` has four frames, the screenshot is non-empty and logs are
  clean.
