# Asset Spec: Factory Aerial Breach And Underground Passage

## Scope

Story130 needs two player-facing environment assets: a cracked floor that
communicates `aerial_attack` gating in Factory, and a complete first-viewport
Underground destination after the breach.

## Runtime Assets

| Asset | Runtime path | Contract |
|-------|--------------|----------|
| Aerial breach floor | `assets/environment/underground_passage/prop_factory_aerial_breach_floor_384x160.png` | Transparent RGBA, exact `384x160`, one wide cracked steel hatch |
| Underground entry | `assets/environment/underground_passage/env_underground_passage_entry_1280x720.png` | Opaque RGB, exact `1280x720`, full-bleed side-view background |

## Visual Direction

- Shared industrial language: corroded steel, masonry, old pressure hardware,
  oxidized red, amber work lights, and pale cyan energy/mineral seams.
- Gate: strong crack silhouette and downward chevrons; readable against the
  existing Factory floor at gameplay scale.
- Underground: broad uncluttered movement lane across the lower viewport,
  broken shaft on the left, deeper tunnel on the right, and enough contrast for
  Cinderpaw/HUD without relying on pure darkness.
- No text, logos, baked UI, characters, enemies, or fake collision markers.

## Godot Integration

- Factory gate uses existing `ExplorationGate` with generated prop as `Visual`.
- The same prop identifies the Underground return route.
- Underground background is a `Sprite2D` at `(640,360)` with nearest filtering.
- Godot 4.7 import metadata must exist for source, alpha, and runtime PNGs.

## Generation Records

- `assets/generated/source/factory_aerial_breach_floor_imagegen_20260711.md`
- `assets/generated/source/underground_passage_entry_imagegen_20260711.md`
