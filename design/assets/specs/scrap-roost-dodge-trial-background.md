# Asset Spec: Scrap Roost Dodge Trial Background

> **Story**: Scene Management 017
> **Generation policy**: built-in image generation, retained source and exact
> prompt, deterministic resize, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Scrap Roost dodge-trial background | Opaque RGB `1280x720`; safe lower-left entry, central exhaust trench, low overhead scrap-beam ceiling, clear far-right exit and readable lower gameplay lane; no baked actor, enemy, UI, text, steam, hazard effect or collision guide | `res://assets/environment/scrap_roost_dodge_trial/scrap_roost_dodge_trial_background_1280x720.png` |

The runtime hazard reuses the existing image-generated Old Factory
`factory_steam_vent_sprite_frames.tres`. Its separate `AnimatedSprite2D` owns
four-frame `safe`, `warning` and `active` states; the new opaque plate does not
bake any steam into the environment.

## Visual Direction

The chamber continues the Scrap Roost's ruined masonry, welded steel, cables and
distant smokestacks while narrowing the composition around one readable floor
exhaust. Cool blue-grey structure and restrained amber dawn lights preserve the
50% dangerous mechanical-wasteland half of the art direction without hiding
Cinderpaw's warm silhouette. The open right arch communicates forward motion
without tutorial text, arrows or a Boss-arena composition.

## Processing And Import

- Retain the generated `1672x941` RGB source and exact prompt under
  `assets/environment/scrap_roost_dodge_trial/source/`.
- Resize to exact opaque `1280x720`; do not add alpha, actors, labels, UI, baked
  steam, a closed gate leaf or collision guides.
- This full-screen environment plate follows the project's established
  `1280x720` authored-background pipeline and is an explicit exception to the
  older generic `256x256` background budget.
- Authored Godot nodes own ground, walls, exhaust collision/damage, gate state,
  player, HUD and CombatPresentation. The background is presentation only.
- Godot MCP acceptance must confirm the imported background is visible, the
  production Cinderpaw `AnimatedSprite2D` and four-frame steam animation render
  above it, the screenshot is non-empty, and no UI overlaps the traversal lane.
