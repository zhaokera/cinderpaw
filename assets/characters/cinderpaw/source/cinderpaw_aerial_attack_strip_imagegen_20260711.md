# Cinderpaw Aerial Attack Image Generation Record

Date: 2026-07-11
Mode: built-in image generation with Cinderpaw reference
Use case: `stylized-concept`
Story: `production/epics/player-abilities/story-129-sluice-matriarch-aerial-attack-reward-payoff.md`

## Prompt

Create a strict horizontal three-frame pixel-art animation strip for the exact
same Cinderpaw character shown in the reference: small black-and-rust feline
warrior, amber eyes, red scarf, dark steel shoulder armor, claw gauntlets, same
proportions, palette, pixel density, outline style, and right-facing identity.
The action is an airborne downward claw strike for a polished 2D side-scrolling
ACT game. Frame 1: tuck and rotate in midair, claws preparing below the torso.
Frame 2: decisive near-vertical downward dive with both claws leading and a
narrow pale-gold slash trail. Frame 3: impact-ready compressed pose with claws
below, short gold-white downward impact streaks, no floor or impact debris.
Place exactly three isolated full-body sprites in one row with equal cell
spacing, identical scale, pivot, and center alignment. Use a perfectly uniform
flat `#00ff00` chroma-key background. Crisp authored pixel art, readable
silhouette at `96x96` runtime size. No text, labels, separators, UI,
environment, cast shadow, floor, crop, overlap, extra character, watermark,
gradient, blur, 3D, or photorealism.

Reference:
`assets/characters/cinderpaw/source/cinderpaw_sprite_sheet_chroma.png`

## Outputs

- Chroma source: `cinderpaw_aerial_attack_strip_imagegen_20260711.png`
- Alpha source: `cinderpaw_aerial_attack_strip_alpha_20260711.png`
- Runtime frames: `../aerial_attack/cinderpaw_aerial_attack_000.png` through
  `_002.png`
- Runtime resource: `../cinderpaw_sprite_frames.tres`

## Processing

- The generated source is `2172x724` RGB with exactly three `724x724` cells.
- Border auto-key selected `#05f40f`; soft matte thresholds `12/220` and
  despill produced the retained RGBA alpha strip.
- Each exact cell was downsampled with Lanczos to one transparent `96x96`
  runtime frame. Whole-cell resizing preserves the generated shared pivot and
  center alignment instead of independently trimming poses.
- Godot 4.7 imported source, alpha source, and all runtime frames through the
  standard texture pipeline.

## Runtime Use

The frames form the non-looping `aerial_attack` animation in
`assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`. PlayerController
selects it only after the Boss3 reward is unlocked and Cinderpaw attacks while
airborne.
