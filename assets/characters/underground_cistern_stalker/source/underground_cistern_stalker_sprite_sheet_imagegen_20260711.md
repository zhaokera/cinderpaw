# Underground Cistern Stalker Image Generation Record

- Date: 2026-07-11
- Tool: built-in image generation with local chroma-key removal
- Use case: `stylized-concept`
- Purpose: Story133 new frame-animated deep Underground enemy
- Chroma source dimensions: `887x1774`, opaque RGB
- Alpha source dimensions: `887x1774`, transparent RGBA
- Runtime frames: eighteen transparent `96x96` PNGs

## Prompt

Create one strict three-column by six-row sprite sheet containing exactly 18
full-body frames of the same right-facing Underground Cistern Stalker. The
creature is a low broad mutated salamander/newt with oversized launching
forelimbs, short rear legs, heavy tail, wet charcoal skin, oxidized restraint
bands, cyan mineral tubes, and one toxic-green throat weak point. It is not a
rat, worm, leech, snake, dragon, crocodile, or humanoid. Rows in order: idle,
run, attack tell, horizontal leap attack, hurt, death. The attack-tell row raises
signal-red dorsal spines. Keep scale, cell anchor, anatomy, palette, and padding
consistent. Place all frames on one perfectly uniform flat `#ff00ff` background
without grid lines, shadows, floor, effects, text, UI, logo, or watermark.

## Outputs

- Chroma source:
  `underground_cistern_stalker_sprite_sheet_imagegen_20260711.png`
- Alpha source:
  `underground_cistern_stalker_sprite_sheet_alpha_20260711.png`
- Normalized preview:
  `underground_cistern_stalker_frames_preview_20260711.png`
- Runtime frames:
  `../<animation>/underground_cistern_stalker_<animation>_000.png` through
  `_002.png`

## Processing

- The installed imagegen helper sampled border key `#f702f1`, then applied soft
  matte, despill, transparent threshold `12`, and opaque threshold `220`.
- The alpha result contains `1,165,244` transparent and `37,029` partially
  transparent source pixels out of `1,573,538` total.
- The sheet was sliced by equal `3x6` cell boundaries. Every cell was
  downsampled to `88x88` and centered at `(48,48)` on a transparent `96x96`
  canvas, preserving one common Godot sprite origin while guaranteeing at
  least one transparent pixel of edge padding.
- All 18 runtime files have transparent corners, non-empty alpha bounds, and no
  canvas-edge contact. Godot 4.7 imported source, alpha, preview, and frames.
