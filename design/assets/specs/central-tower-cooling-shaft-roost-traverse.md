# Asset Spec: Central Tower Cooling Shaft Roost Traverse

> **Story**: 142
> **Generation policy**: built-in image generation, retained source, Godot import

## Runtime Assets

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Cooling Shaft background | Opaque RGB `1280x720`; asymmetrical vertical maintenance shaft, left safe ledge, broken central crossing, narrow right endpoint, visible depth; no baked actor, text, Roost, arc, or collision prop | `res://assets/environment/central_tower/env_central_tower_cooling_shaft_1280x720.png` |
| Cooling Roost | Transparent RGBA `256x256`; compact safe cat-nest service cradle with restrained gold core and cyan utility trim | `res://assets/environment/central_tower/prop_central_tower_cooling_roost_256x256.png` |
| Magnetic conduit spine | Transparent RGBA `256x512`; narrow climbable service spine with bright cyan magnetic edge language | `res://assets/environment/central_tower/prop_central_tower_cooling_spine_256x512.png` |
| Maintenance perch | Transparent RGBA `384x128`; broken suspended catwalk segment with readable top surface | `res://assets/environment/central_tower/prop_central_tower_cooling_perch_384x128.png` |
| Deep-lift beacon | Transparent RGBA `256x384`; narrow cyan route endpoint, not a throne, arena gate, or Boss seal | `res://assets/environment/central_tower/prop_central_tower_deep_lift_beacon_256x384.png` |
| Cooling arc | Transparent RGBA `512x160`; crisp horizontal electrical sweep with signal-red warning edge and white/cyan active core, no text | `res://assets/environment/central_tower/vfx_central_tower_cooling_arc_512x160.png` |
| Contact spark | Transparent RGBA `192x192`; compact cyan-white electrical contact burst used for Roost activation and hazard readability | `res://assets/environment/central_tower/vfx_central_tower_cooling_contact_spark_192x192.png` |

## Generation And Processing

- Generate one opaque environment source and one uniform `#ff00ff` keyed sheet
  containing five isolated props/VFX cells.
- Retain source PNG and exact prompt metadata under
  `assets/generated/source/`.
- Remove chroma with border auto-key, soft matte, despill, and edge contraction
  only when needed. Thin arc/spark edges must not retain magenta, gray fringe,
  or opaque rectangular backgrounds.
- Normalize the background to exact opaque RGB `1280x720`; isolate, trim, fit,
  and center each transparent runtime canvas without changing aspect ratio.
- Godot imports use nearest filtering and lossless compression.

## Scene Use

- One spine visual is reused on two authored StaticBody2D climb surfaces.
- One perch visual is reused for the center and exit stepping surfaces over
  authored one-way collision.
- Arc and contact spark are presentation only; Area2D/CollisionShape2D own all
  contact logic.
- Existing Cinderpaw SpriteFrames supply `run`, `jump`, `fall`, `wall_climb`,
  `hurt`, and `revive`; no new character PNG is generated.

## QA Contract

- Exact dimensions, alpha mode, transparent corners, and no baked text/actors.
- Third viewport reads as traversal and visible depth, never a centered arena.
- Cyan climb surfaces separate from the darker background; gold Roost and cyan
  endpoint cannot be confused; signal red is absent outside warning/active.
- MCP screenshot contains generated background, Roost, conduit spine, perch,
  live arc or endpoint, Cinderpaw, readable objective, and HUD without overlap.
