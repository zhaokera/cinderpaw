# Cinderpaw Heavy Charge + Heavy Attack Image Generation

> **Date**: 2026-07-14
> **Tool**: Built-in image generation
> **Use**: Feline Combat Story010 grounded heavy-charge runtime

## Prompt

Use the existing Cinderpaw sprite sheet as the identity and pixel-art style
reference. Preserve the black-and-orange feline face, amber eyes, red scarf,
dark scavenger armor, body proportions, and right-facing orientation.

Create exactly six full-body frames in a strict 3-column by 2-row grid:

- Row 1 `heavy_charge`: plant feet and lower stance; brace while gathering
  amber energy; reach full charge with the strongest amber glow.
- Row 2 `heavy_attack`: grounded wind-up; wide forceful forward heavy slash;
  low stable follow-through.

Use crisp pixel art with one centered character per equal cell, consistent feet
baseline, anchor and scale, generous padding, no overlap, and no cropping. Use a
perfectly flat `#00ff00` chroma-key background with no shadow, floor, grid,
text, labels, watermark, or green in the character/effects. Avoid extra limbs,
extra tails, disconnected weapons, inconsistent costume/face, gradients, and
background texture.

## Pipeline

- Generated source:
  `cinderpaw_heavy_charge_attack_sheet_imagegen_20260714.png`
- Chroma-key alpha intermediate:
  `cinderpaw_heavy_charge_attack_sheet_alpha_20260714.png`
- Background removal: project-standard imagegen `remove_chroma_key.py` helper,
  auto border key, soft matte, despill.
- Slicing: fixed `418x418` cells from the source grid; no per-frame trim or
  independent scaling.
- Runtime normalization: nearest-neighbor resize to transparent `96x96` PNGs,
  preserving shared scale and anchor.
- Runtime destinations:
  `assets/characters/cinderpaw/heavy_charge/` and
  `assets/characters/cinderpaw/heavy_attack/`.
