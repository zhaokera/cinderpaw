# Cinderpaw Wall Climb Image Generation Record

Date: 2026-07-11
Mode: built-in image generation with Cinderpaw reference
Use case: `stylized-concept`
Story: `production/epics/player-abilities/story-135-factory-hidden-altar-wall-climb-reward-traversal.md`

## Prompt

Create a strict horizontal three-frame pixel-art animation strip for the same
Cinderpaw character: small black-and-rust feline warrior, amber eyes, red scarf,
dark steel shoulder armor, claw gauntlets, matching proportions, palette, pixel
density, outline style, and right-facing identity. The action is a readable
magnetic-wall climb for a polished 2D side-scrolling ACT game. Frame 1 plants
both front claws into the wall with the body compressed. Frame 2 pulls the body
up with alternating paws and a stretched torso. Frame 3 resets the lower paws
for the next climbing step. Place exactly three isolated full-body sprites in
one row with equal cell spacing, identical scale, pivot, and center alignment.
Use a perfectly uniform flat magenta chroma-key background. Crisp authored
pixel art readable at `96x96`; no text, labels, separators, UI, environment,
cast shadow, floor, crop, overlap, extra character, watermark, blur, 3D, or
photorealism.

Reference:
`assets/characters/cinderpaw/source/cinderpaw_sprite_sheet_chroma.png`

## Outputs

- Chroma source: `cinderpaw_wall_climb_strip_imagegen_20260711.png`
- Alpha source: `cinderpaw_wall_climb_strip_alpha_20260711.png`
- Runtime frames: `../wall_climb/cinderpaw_wall_climb_000.png` through
  `_002.png`
- Runtime resource: `../cinderpaw_sprite_frames.tres`

## Processing

- The generated source is `2172x724` RGB with exactly three `724x724` cells.
- Border auto-key selected sampled magenta near `#f903f7`; soft matte, despill,
  one-pixel edge contraction, and light feathering produced the retained RGBA
  strip.
- Each exact cell was downsampled with Lanczos to one transparent `96x96`
  runtime frame. Whole-cell resizing preserves the shared pivot and center.
- Godot 4.7 imported source, alpha source, and all runtime frames through the
  standard texture pipeline.

## Runtime Use

The frames form the looping `wall_climb` animation in
`assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`. PlayerController
selects it only while the unlocked wall-climb state owns movement.
