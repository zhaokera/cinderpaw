# Neon Signal Rat Image Generation Record

- Generated: 2026-07-12
- Tool: built-in image generation with local chroma-key removal
- Use case: `stylized-concept`
- Purpose: Story137 frame-animated Neon Rooftops ordinary enemy
- Chroma source dimensions: `887x1774`, opaque RGB
- Alpha source dimensions: `887x1774`, transparent RGBA
- Runtime frames: eighteen transparent `96x96` PNGs

## Prompt

Create one strict three-column by six-row sprite sheet containing exactly 18
full-body frames of the same right-facing Neon Signal Rat. It is a small lean
mechanical rooftop scavenger with angular feline-rat posture, dark scrap-metal
armor, a broken billboard antenna on its back, cyan cable seams, violet signal
lights, and a readable tail. Rows in order: idle, run, attack tell, magnetic
lunge attack, hurt, death. The attack-tell row switches the antenna and eyes to
signal red. Keep scale, anchor, anatomy, palette, and padding consistent. Place
all frames on one perfectly uniform flat `#ff00ff` background without grid
lines, shadows, floor, effects, text, UI, logo, or watermark.

## Outputs

- Chroma source: `neon_signal_rat_sprite_sheet_imagegen_20260712.png`
- Alpha source: `neon_signal_rat_sprite_sheet_alpha_20260712.png`
- Normalized preview: `neon_signal_rat_frames_preview_20260712.png`
- Runtime frames: `../<animation>/neon_signal_rat_<animation>_000.png` through
  `_002.png`

## Processing

- The installed imagegen helper auto-sampled border key `#fa03f9`, then applied
  soft matte thresholds `12/220`, despill, one-pixel edge contraction, and
  `0.25` edge feathering.
- The sheet was sliced by equal `3x6` cell boundaries. Each non-empty alpha
  result was proportionally normalized and bottom-centered on one transparent
  `96x96` canvas, preserving a common Godot sprite origin.
- All 18 runtime files have transparent corners, consistent dimensions,
  non-empty alpha, continuous `_000.._002` names, and no canvas-edge contact.
- Godot 4.7 imported source, alpha, preview, frames, and SpriteFrames resource.
