# Sluice Matriarch Geyser and Recovery Image Generation Record

Date: 2026-07-18
Mode: built-in image generation with three local character references
Use case: `sprite-sheet`
Story: `production/epics/player-abilities/story-173-sluice-matriarch-pressure-geyser-pattern.md`

## Prompt

Use the attached Sluice Matriarch reference frames as the exact character
identity and pixel-art rendering reference. Create one production sprite sheet
for the same right-facing giant mutated industrial leech boss in a polished
side-view 2D action platformer. EXACT LAYOUT: 3 columns by 3 rows, exactly nine
isolated full-body sprites, no gutters drawn and no labels. Row 1 is GEYSER
TELL, three consecutive frames: the low heavy leech braces its steel pressure
clamps against the ground, compresses its charcoal-purple wet body, cracked
ceramic armor tightens, signal-red warning spines flare progressively,
restrained cyan seams charge; no water column and no detached effect. Row 2 is
GEYSER ATTACK, three consecutive frames: it slams the pressure apparatus
downward and vents cyan pressure through its front hardware while staying
planted; preserve the same body proportions and face. Row 3 is ATTACK RECOVERY,
three consecutive frames: recoil, exhausted sag, then controlled return toward
the low neutral stance. Keep the exact existing silhouette language:
charcoal-purple segmented wet body, steel clamps, cracked ivory ceramic plates,
rust-orange hardware, cyan mutation seams, signal-red accents. All nine sprites
must use one scale, one pivot, one ground baseline, consistent pixel density,
and right-facing orientation. Crisp authored pixel art with strong ACT pose
readability. Put everything on a perfectly uniform flat #FF00FF chroma-key
background. No environment, floor, cast shadow, text, labels, borders, UI,
watermark, crop, overlap, extra creatures, rat ears, 3D render, blur, gradients,
or missing/repeated frames.

## References

- `assets/characters/sluice_matriarch/idle/sluice_matriarch_idle_000.png`
- `assets/characters/sluice_matriarch/attack_tell/sluice_matriarch_attack_tell_001.png`
- `assets/characters/sluice_matriarch/attack/sluice_matriarch_attack_001.png`

## Outputs

- RGB source: `sluice_matriarch_geyser_recovery_sheet_imagegen_20260718.png`
- Alpha source: `sluice_matriarch_geyser_recovery_sheet_alpha_20260718.png`
- Runtime preview: `sluice_matriarch_geyser_recovery_runtime_preview_20260718.png`
- Runtime frames: `../geyser_tell/`, `../geyser_attack/`, and
  `../attack_recovery/`, three continuous `192x192` PNGs each.
- Runtime resource: `../sluice_matriarch_sprite_frames.tres`

## Processing

- The generated RGB source is `1254x1254`. Border sampling selected `#f803f8`.
- Chroma removal used soft matte, despill, transparent threshold `12`, and
  opaque threshold `220`: `1,187,707` pixels became fully transparent and
  `27,232` remained partially transparent.
- The alpha sheet was split into exact `418x418` cells in a `3x3` grid.
- One shared nearest-neighbor scale of `0.458537` fits every subject inside
  `188x94`; every frame is centered on a transparent `192x192` canvas with the
  common ground baseline at `y=192`.
- Godot 4.7 imported the RGB source, alpha source, preview, and nine runtime
  frames. Runtime rendering uses nearest texture filtering.

## Integrity

- RGB SHA-256: `2c088ec7ee2c62f4255739e003003aefc60d55dfa9df6af72b73742bb126af0b`
- Alpha SHA-256: `c6a09ac989a4660132a203572f0cc06739a1f0ebdd5fd75bf5e441bf832c20c9`
- Preview SHA-256: `4a6e7341f064b535ea8074dc918f961b9fe250ce2667e4c8a8a5c23bb7b1496b`
