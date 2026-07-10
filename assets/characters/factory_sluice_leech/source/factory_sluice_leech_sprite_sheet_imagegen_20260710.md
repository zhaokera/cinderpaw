# Factory Sluice Leech Image Generation Record

Date: 2026-07-10
Mode: built-in image generation with local chroma-key removal
Use case: `stylized-concept`
Reference: `assets/characters/factory_coil_rat/source/factory_coil_rat_frames_preview_20260708.png` (style and grid quality only)

## Prompt

Create one coherent Factory Sluice Leech for a polished Godot 4.7 2D action
platformer as a strict three-column by six-row pixel-art sprite sheet. Rows in
order: idle, crawl/run, attack tell, forward lunge attack, hurt, death. Each row
contains three distinct frames of the same right-facing character at the same
scale, pivot, and ground baseline. The creature is a small mutated industrial
leech with a low S-curve silhouette, wet charcoal-purple body, steel-blue
shadows, rusted clamp rings, cracked ceramic insulators, rust-orange grime,
restrained toxic-green mutation seams, and tiny signal-red triangular spines
that become prominent during attack tell. Use chunky readable authored pixel
art with crisp edges and cute-danger contrast. Place exactly eighteen isolated
full-body sprites on a perfectly uniform flat `#ff00ff` chroma-key background,
with generous equal-cell padding, no overlap, crop, labels, separators, floor,
shadow, gradient, texture, reflection, text, UI, watermark, or environment.
Keep identity and proportions consistent. Avoid rat heads, mouse ears, square
bodies, large green areas, cat-eye gold, photorealism, 3D rendering, painterly
blur, extra limbs, cropped tails, and background props.

## Outputs

- Chroma source: `factory_sluice_leech_sprite_sheet_imagegen_20260710.png`
- Alpha source: `factory_sluice_leech_sprite_sheet_alpha_20260710.png`
- Normalized preview: `factory_sluice_leech_frames_preview_20260710.png`
- Runtime frames: `../<animation>/factory_sluice_leech_<animation>_000.png` through `_002.png`

## Processing

- Chroma key sampled from the border as `#fb03f9`.
- Alpha removal used auto-key, soft matte, despill, transparent threshold `12`,
  and opaque threshold `220`.
- Source alpha sheet size: `972x1619` RGBA.
- The sheet was split into equal `3x6` cells. One scale factor (`0.302013`) was
  derived from the largest alpha bounding box (`298x180`) and applied to all
  frames with high-quality offline downsampling.
- Every frame is centered at x `48` on a transparent `96x96` canvas with a
  shared ground baseline at y `88`. Godot imports the runtime PNGs without
  mipmaps and uses nearest texture filtering at runtime.
