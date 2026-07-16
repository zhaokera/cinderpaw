# Cinderpaw Dedicated Dash Image Generation Record

Date: 2026-07-16
Mode: built-in image generation with two Cinderpaw references
Story: `production/epics/combat-presentation/story-030-cinderpaw-dedicated-dash-animation-identity.md`

## 用途

替换 Player Abilities Story001 从 Dodge 逐像素复制的临时 Dash 三帧，为高速
穿越能力建立独立的发射、全速和动量收束动作身份，同时保持现有资源路径。

## Prompt

Create one strict three-frame dedicated DASH animation sheet for exactly the
same Cinderpaw character. This must read as active high-speed traversal,
clearly different from a defensive dodge.

CANVAS AND GRID: exact 1536x512 image, exactly 3 equal columns by 1 row, each
cell exactly 512x512. One full-body right-facing character in each cell. Keep
the same character scale, pelvis/root anchor and baseline, with at least 8%
empty safety margin.

CHARACTER INVARIANTS: small black-and-rust feline warrior; charcoal fur with
rust-orange muzzle, ears, tail tip, limbs and accents; bright amber eyes; dark
brick-red scarf; dark steel shoulder armor and forearm gauntlets; white claws.
Preserve the references' face, ears, armor, proportions, palette and costume.

FRAME 1: immediate launch already moving right, low forward body angle, rear
leg driving and extending, leading shoulder and paw forming an arrow, ears
pinned back, scarf and tail beginning to lag. No stationary crouch.

FRAME 2: maximum speed, spine and torso stretched long and nearly horizontal,
forepaws reaching right, hind legs streamlined backward, scarf and tail
trailing. Add only 2-3 short pale-gold speed-line pixel streaks behind the body.

FRAME 3: controlled momentum carry-through, still moving right, limbs
gathering beneath the torso, head and amber eyes locked forward, torso rising
slightly while scarf overshoots and tail stabilizes. It must transition to run,
jump or fall, never read as a defensive recovery or skid.

STYLE: crisp hard-edged pixel art, stepped pixels, limited high-contrast
palette, no painterly rendering, soft edges, antialiasing, blur or feathering.

BACKGROUND: perfectly uniform flat solid `#FF00FF` chroma key outside the
figures. No shadows, gradients, floor, ground, dust, footprints, scenery,
duplicate character, afterimage, extra limbs/tail, blue cloak/armor, glow,
text, UI, crop, cell overlap or watermark.

## References

- `assets/characters/cinderpaw/source/cinderpaw_sprite_sheet_chroma.png`
- `assets/characters/cinderpaw/source/cinderpaw_jump_fall_sheet_alpha_20260715.png`

## Outputs

- Chroma source: `cinderpaw_dash_strip_imagegen_20260716.png`
- Alpha source: `cinderpaw_dash_strip_alpha_20260716.png`
- Runtime frames: `../dash/cinderpaw_dash_000.png` through `_002.png`
- Runtime resource: `../cinderpaw_sprite_frames.tres`

## Processing

- Built-in generation returned an exact `2172x724` 3x1 sheet, so each fixed
  grid cell is exactly `724x724`; no content-aware slicing was used.
- Border sampling selected magenta near `#fb03f9`. The project imagegen helper
  used auto border keying, despill, transparent threshold `10` and opaque
  threshold `96`; alpha was then hard-thresholded at 50%.
- Each fixed cell was point/Nearest-resized with one shared scale to `88x88`,
  centered on a transparent `96x96` canvas, hard-thresholded again and quantized
  without dithering to at most 64 colors.
- Final frames are PNG-8, `1302-1348` bytes, use only alpha `0/255`, and retain
  at least 6 px horizontal safety margin.
- Nontransparent pixel counts are `908/916/891`; red identity pixels are
  `48/78/69`; amber identity pixels are `71/73/65`.
- Alpha silhouette differences from corresponding Dodge frames are
  `0.7123/0.4989/0.5879`; all three frame hashes are unique.
- Godot 4.7 imported source, alpha source and runtime frames through the normal
  asset pipeline.
