# Asset Spec: Sluice Matriarch Pressure Geyser Pattern

Date: 2026-07-18
Story: `production/epics/player-abilities/story-173-sluice-matriarch-pressure-geyser-pattern.md`
Status: Implemented

## Role

The pressure geyser breaks up Boss3's repeated horizontal lunge with a planted,
location-targeted ground-control pattern. Its low red/amber warning must give
the player a clear escape decision before the tall cyan column becomes active.

## Visual Contract

| Field | Value |
|-------|-------|
| Boss runtime type | `AnimatedSprite2D + SpriteFrames` |
| Boss additions | `geyser_tell`, `geyser_attack`, `attack_recovery` |
| Boss frames | 3 transparent `192x192` PNGs per animation |
| VFX runtime type | Independent `AnimatedSprite2D + SpriteFrames` |
| VFX animations | `warning`, `active` |
| VFX frames | 3 transparent `192x192` PNGs per animation |
| VFX anchor | Shared center and floor baseline; authored frame bottom `y=188` |
| Facing | Boss authored right-facing; runtime uses `flip_h`; VFX is symmetric |
| Boss resource | `assets/characters/sluice_matriarch/sluice_matriarch_sprite_frames.tres` |
| VFX resource | `assets/environment/sluice_matriarch_arena/pressure_geyser/pressure_geyser_sprite_frames.tres` |

## Readability

- `geyser_tell` keeps the Matriarch planted, compresses the long silhouette,
  and progressively raises signal-red spines without showing a water column.
- `warning` stays below the player's body and grows from bubbles into a broad
  red/amber pressure ring. It is visible only while the hitbox is inactive.
- `geyser_attack` commits the Boss pose as `active` replaces the ring with a
  bright vertical cyan-white column. The column is readable against the dark
  steel Arena without becoming a full-screen flash.
- `attack_recovery` moves through recoil, sag, and return. Both lunge and
  geyser use it instead of freezing on an attack frame.

## Gameplay Contract

| Phase | Startup | Active | Recovery | Damage |
|-------|---------|--------|----------|--------|
| I | 24 frames | 10 frames | 24 frames | 14 |
| II | 18 frames | 10 frames | 18 frames | 14 |

The target X is captured when startup begins. One `144x110` hitbox activates
only during the active window. The warning footprint is at most `176px` wide,
so the `1200px` visible combat floor always leaves more than `160px` of
contiguous safe space.

## Pipeline

- Boss generation and processing:
  `assets/characters/sluice_matriarch/source/sluice_matriarch_geyser_recovery_sheet_imagegen_20260718.md`.
- VFX generation and processing:
  `assets/environment/sluice_matriarch_arena/pressure_geyser/source/pressure_geyser_sheet_imagegen_20260718.md`.
- Both sources use flat magenta removal, shared per-animation scaling, nearest
  normalization, continuous names, and transparent `192x192` runtime canvases.

## Validation

- Every added animation contains exactly three non-empty frames with transparent
  corners and consistent dimensions.
- Godot must show `warning -> active -> hidden recovery` while Boss animation
  shows `geyser_tell -> geyser_attack -> attack_recovery`.
- No hitbox may be active during warning or recovery. Reset, death, and progress
  restore must hide the VFX and deactivate both attack hitboxes.
