# Pressure Geyser VFX Image Generation Record

Date: 2026-07-18
Mode: built-in image generation with Arena and boss references
Use case: `sprite-sheet`
Story: `production/epics/player-abilities/story-173-sluice-matriarch-pressure-geyser-pattern.md`

## Prompt

Use the attached Sluice Matriarch arena and boss references only for pixel-art
style, palette, and side-view perspective. Create one production VFX sprite
sheet for a PRESSURE GEYSER hazard in the same polished 2D action platformer.
EXACT LAYOUT: 3 columns by 2 rows, exactly six isolated effect sprites, no
drawn gutters and no labels. Row 1 is WARNING, three consecutive non-damaging
frames: a compact floor-level industrial pressure grate/seam with bubbling cyan
droplets and an expanding signal-red to amber warning pulse; keep the center
readable and the effect low to the floor, absolutely no vertical damaging jet.
Row 2 is ACTIVE, three consecutive damaging frames: a tall forceful vertical
cyan-white water-and-steam pressure column erupting from the same rusted grate,
with distinct turbulent silhouettes and a strong readable base. The warning
and active frames must share one center anchor, one floor baseline, one scale,
and consistent crisp authored pixel density. VFX only, no character. Put all
six effects on a perfectly uniform flat #FF00FF chroma-key background. No arena
background, floor plane beyond the small grate, cast shadow, text, labels,
borders, UI, watermark, crop, overlap, extra objects, 3D render, blur,
gradients in the background, or missing/repeated frames.

## References

- `assets/environment/sluice_matriarch_arena/env_sluice_matriarch_arena_backdrop_1280x720.png`
- `assets/characters/sluice_matriarch/idle/sluice_matriarch_idle_000.png`

## Outputs

- RGB source: `pressure_geyser_sheet_imagegen_20260718.png`
- Alpha source: `pressure_geyser_sheet_alpha_20260718.png`
- Runtime preview: `pressure_geyser_runtime_preview_20260718.png`
- Runtime frames: `../warning/pressure_geyser_warning_000.png` through `_002`
  and `../active/pressure_geyser_active_000.png` through `_002`.
- Runtime resource: `../pressure_geyser_sprite_frames.tres`

## Processing

- The generated RGB source is `1536x1024`. Border sampling selected `#fb03fa`.
- Chroma removal used soft matte, despill, transparent threshold `12`, and
  opaque threshold `220`: `1,294,308` pixels became fully transparent and
  `44,879` remained partially transparent.
- Columns are exact `512px` cells. The row boundary is `y=448`: warning art
  ends above it, while the tall active columns begin there and continue to
  `y=1024`, avoiding truncation of the third active frame.
- Warning subjects use one nearest-neighbor scale of `0.438903`, fit inside
  `176x74`, and share baseline `y=188` on `192x192` canvases. Active subjects
  use one scale of `0.381743`, fit inside `140x184`, and use the same baseline.
- Godot 4.7 imported the RGB source, alpha source, preview, and six runtime
  frames. Runtime rendering uses nearest texture filtering.

## Integrity

- RGB SHA-256: `5b3004ee673a1c8b0486279222d5332aacbb9bb63f75991477d8460724a17252`
- Alpha SHA-256: `01126f52abff6e9f899e377409041f0cb16fbc678105b51b3dca6c1a3411efe9`
- Preview SHA-256: `a4469e79052e9ab37c992c5ec64f0501c466022bb8e654b01dcf513bcdf8dfc4`
