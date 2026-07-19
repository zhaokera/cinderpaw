# Asset Spec: Sewer Double-Jump Factory Junction

> **Story**: Scene Management 022
> **Generation policy**: reuse imported image-generation outputs; no new visual
> generation required; Godot 4.7 import and MCP runtime verification

## Runtime Composition

| Purpose | Runtime asset | Contract |
|---------|---------------|----------|
| Room plate | `res://assets/environment/sewer_pressure_chamber/sewer_pressure_chamber_background_1280x720.png` | Opaque `1280x720` pressure chamber with the upper-right maintenance ledge kept free of baked actors and UI. |
| Traversable landing | `res://assets/environment/old_factory_route_platform/env_old_factory_route_entry_platform_320x96.png` | Transparent generated factory platform aligned over authored `StaticBody2D` collision. |
| Ability marker | `res://assets/environment/high_platform_gate/high_platform_gate_marker.png` | Transparent upward claw/paw marker, readable at character scale and mounted separately from collision. |
| Route entrance | `res://assets/environment/factory_route_transition/factory_route_transition_shell.png` | Transparent circular Factory pipe shell mounted on the high route as the transition affordance. |

## Layout Contract

- The landing top is `y=350`, above the Dash-only route but reachable with the
  production Double Jump from the pressure-room floor.
- The gate gameplay anchor sits over the landing so the second jump can unlock
  it; the marker and blocking body remain offset to the landing's right edge.
- The pipe shell, claw marker and platform form one left-to-right visual line.
  Authored collision remains invisible and never substitutes for generated art.
- The existing low `main/sewer_return` path stays visually and physically
  distinct from the high `area_03_factory/factory_gate_entry` path.

## Pipeline And Acceptance

- All four visual assets already have retained image-generation sources in the
  project manifest; Story022 records a new use site instead of regenerating
  near-duplicate art.
- Godot MCP must confirm all three junction nodes load, the production
  `AnimatedSprite2D` Player is visible, the route state changes after real
  Double Jump input, the screenshot is non-empty and game/editor logs are clean.
