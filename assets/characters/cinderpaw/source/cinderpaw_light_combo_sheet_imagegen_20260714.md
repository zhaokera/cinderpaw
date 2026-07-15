# Cinderpaw Light Combo Image Generation Record

> Date: 2026-07-14
> Story: Player Abilities 166
> Generator: built-in image generation
> Reference: `assets/characters/cinderpaw/source/cinderpaw_sprite_sheet_chroma.png`

## Purpose

Replace the single shared light-attack presentation with three readable
three-frame combo stages while preserving Cinderpaw's established pixel-art
identity, runtime pivot, and `96x96` character canvas contract.

## Prompt

```text
Create a production-ready pixel-art sprite sheet for the exact same Cinderpaw
character shown in the reference: black and rust-orange feline fur, amber eyes,
red scarf, dark shoulder armor and bracers, facing right. Preserve the character
design, proportions, color palette, pixel-art rendering, and silhouette exactly.
Output one square image arranged as an exact 3 columns by 3 rows grid with nine
equal cells, no gutters, no borders, no labels, no text. Every cell has a flat
chroma green background.

Row 1: fast low horizontal right-claw slash, anticipation/contact/recovery.
Row 2: stronger rising cross-claw slash with body rotation,
anticipation/contact/recovery.
Row 3: slow powerful turning double-claw finisher,
anticipation/contact/recovery.

Keep one complete character per cell, a shared foot baseline, stable body scale
and anchor, safe edge margins, and no scenery, UI, shadows, cropped anatomy, or
overlap. Produce crisp hard-edged pixel art suitable for nearest-neighbor
downscaling to 96x96.
```

## Retained Sources

- Generated RGB sheet:
  `cinderpaw_light_combo_sheet_imagegen_20260714.png` (`1254x1254`).
- Alpha-matted sheet:
  `cinderpaw_light_combo_sheet_alpha_20260714.png` (`1254x1254` RGBA).
- Chroma removal sampled border key `#0def16`, with soft matte, thresholds
  `12/220`, and despill.

## Runtime Processing

- Split the source into exact `3x3` cells of `418x418`.
- Resize each cell to `96x96` with nearest-neighbor filtering.
- Preserve horizontal cell registration and translate only vertically so every
  visible alpha bound ends at `y=88`, leaving an 8px bottom safety margin.
- Runtime outputs are continuous transparent PNGs under `attack/`, `attack_2/`,
  and `attack_3/`, three frames per directory.
- Godot `SpriteFrames` speeds are `15`, `10`, and `6` FPS, matching the Core
  stage durations of `12`, `18`, and `30` frames at 60Hz.

## Verification

- All nine runtime files are RGBA `96x96`; transparent corner checks pass.
- Alpha bounds end at the same `y=88` baseline; the widest frame is 90px and
  remains inside the canvas.
- Godot 4.7 EditorFileSystem imported all six new stage-2/stage-3 frames.
- Focused GdUnit validates paths, dimensions, transparency, frame counts,
  speeds, non-looping flags, and Nearest texture filtering.
