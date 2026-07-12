# Central Tower Threshold Guard Image Generation Record

- Generated: 2026-07-12
- Tool: built-in image generation with local chroma-key removal
- Use case: `stylized-concept`
- Purpose: Story140 unique ordinary elite guard
- Reference: Neon Signal Rat normalized frame preview
- Chroma source dimensions: `887x1773`, opaque RGB
- Alpha source dimensions: `887x1773`, transparent RGBA
- Runtime frames: eighteen transparent `96x96` PNGs

## Prompt Summary

Create one strict `3x6` sheet with exactly 18 frames of the same right-facing,
upright heavy mechanical rat sentry. Give it square armor, low stable legs, an
integrated latch-blade shield, dark steel-blue plating, cyan status lights, and
signal red only in attack warning/active rows. Rows are `idle`, `run`,
`attack_tell`, `attack`, `hurt`, and `death`, with consistent anatomy, scale,
padding, and bottom-center registration on uniform `#ff00ff`.

## Outputs

- Chroma source: `central_tower_threshold_guard_sprite_sheet_imagegen_20260712.png`
- Alpha source: `central_tower_threshold_guard_sprite_sheet_alpha_20260712.png`
- Normalized preview: `central_tower_threshold_guard_frames_preview_20260712.png`
- Runtime frames: `../<animation>/central_tower_threshold_guard_<animation>_000.png`
  through `_002.png`

## Processing

- The helper sampled border key `#f803f8`, applied soft matte thresholds
  `12/220`, despill, one-pixel edge contraction, and `0.25` feathering.
- The alpha sheet was split by equal `3x6` cells. Every non-empty pose was
  proportionally fitted inside `84x80`, horizontally centered, and aligned to a
  shared bottom baseline at y `88` on a transparent `96x96` canvas.
- All 18 frames have transparent corners, continuous names, and no canvas-edge
  contact.
