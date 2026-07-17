# Asset Spec: Old Factory Environment Cohesion

> **Story**: Combat Presentation 034
> **Generation policy**: built-in image generation with the existing Old
> Factory entrance backdrop as style reference, Godot 4.7 import

## Runtime Contract

| Variant | Runtime path | Role |
|---------|--------------|------|
| Entry | `res://assets/environment/old_factory_route/background/env_old_factory_route_entry_1280x720.png` | Assembly hall and early route |
| Furnace | `res://assets/environment/old_factory_route/background/env_old_factory_route_furnace_1280x720.png` | Boiler and pressure machinery |
| Condenser | `res://assets/environment/old_factory_route/background/env_old_factory_route_condenser_1280x720.png` | Cooling and drain machinery |
| Tailrace | `res://assets/environment/old_factory_route/background/env_old_factory_route_tailrace_1280x720.png` | Sluice output and late-route exit depth |

All four runtime files are opaque RGB PNGs at exact `1280x720`. The retained
`1672x941` sources and complete prompts live under
`res://assets/generated/source/` and are indexed by
`old_factory_environment_cohesion_imagegen_20260717.md`.

## Shared Composition

- Strict orthographic side view with no perspective floor vanishing point.
- Traversable deck top at `69.4%` image height, targeting runtime `y=500`.
- Dark under-deck structure below the line and readable actor space above it.
- Dark vertical outer columns and compatible pipe/catwalk heights at both
  edges for hard-seam tolerance.
- Painterly pixel-art metal detail with navy steel, rust, brass, restrained
  amber practicals and localized cool accents.
- No characters, UI, text, logos, portals, rewards, combat effects, flat
  blocks, gradients, fog columns or baked collision guides.

## Processing And Import

- Keep each generated source unchanged for traceability.
- Resize one copy directly to exact `1280x720` RGB for runtime use.
- Import through Godot 4.7 and render with nearest texture filtering.
- Cycle the four variants across 24 `Sprite2D` plates at `Vector2.ONE` scale.
- Render the cohesion layer above legacy stretched backgrounds at `z=-98`
  and below existing floor, props, hazards, actors, VFX and UI.
- MCP acceptance must inspect runtime nodes, logs and a non-empty screenshot.
