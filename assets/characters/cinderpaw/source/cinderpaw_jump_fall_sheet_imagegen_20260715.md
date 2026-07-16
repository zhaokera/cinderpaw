# Cinderpaw Jump/Fall Image Generation Record

Date: 2026-07-15
Mode: built-in image generation with two Cinderpaw references
Story: `production/epics/combat-presentation/story-029-cinderpaw-air-animation-identity-consistency.md`

## 用途

替换 2026-06-24 的跳跃/下落素材。旧素材使用蓝色披风、软绘制边缘和不同
角色比例，与 idle/run 的黑锈猫、红围巾、深钢护甲身份不一致。

## Prompt

Create a strict 3-column by 2-row sprite animation sheet for the exact same
Cinderpaw character shown in the references, for a polished 2D horizontal
action game.

CHARACTER IDENTITY MUST MATCH: small black-and-rust feline warrior, angular
black fur, amber glowing eyes, bright red scarf with readable scarf tails,
dark steel shoulder armor and forearm gauntlets, rust-orange fur accents,
white claws. Do not redesign the costume. Absolutely no blue cloak, blue cape,
blue armor, painterly rendering, soft illustration, or different character.

PIXEL ART: crisp authored pixel art matching the first reference's pixel
density, hard stepped edges, limited palette, high contrast, no antialiasing,
no blur, no soft feathering, no glow outside the sprite. Each sprite must
remain clearly readable after nearest-neighbor reduction to 96x96.

LAYOUT: exactly six isolated, full-body, right-facing sprites in a precise 3x2
grid, equal cell size and spacing, one character per cell, no overlap, no
separators. Identical character scale and consistent pelvis/feet anchor. Keep
at least 8% empty safety margin around every pose.

TOP ROW - JUMP:
1. jump takeoff, legs extending and front paw leading upward;
2. rising jump, body stretched forward/up with scarf trailing;
3. jump apex, compact feline tuck with tail balancing.

BOTTOM ROW - FALL:
1. early fall, body opening from apex, paws forward;
2. stable downward fall, limbs spread for balance and scarf streaming upward;
3. landing preparation, body lowered, legs reaching down, claws ready.

BACKGROUND: perfectly uniform flat magenta chroma key #FF00FF covering every
background pixel. Magenta must not appear on the character. No environment,
ground, cast shadow, labels, text, UI, borders, watermark, extra limbs, extra
tail, duplicate character, crop, or partial sprites.

## References

- `assets/characters/cinderpaw/source/cinderpaw_sprite_sheet_chroma.png`
- `assets/characters/cinderpaw/source/cinderpaw_light_combo_sheet_alpha_20260714.png`

## Outputs

- Chroma source: `cinderpaw_jump_fall_sheet_imagegen_20260715.png`
- Alpha source: `cinderpaw_jump_fall_sheet_alpha_20260715.png`
- Runtime jump frames: `../jump/cinderpaw_jump_000.png` through `_002.png`
- Runtime fall frames: `../fall/cinderpaw_fall_000.png` through `_002.png`
- Runtime resource: `../cinderpaw_sprite_frames.tres`

## Processing

- Source is an exact `1536x1024` 3x2 grid with six `512x512` cells.
- Border sampling selected magenta near `#fb03f5`; the project imagegen helper
  produced the alpha matte and despill result.
- Alpha was hard-thresholded before slicing. Each exact cell was resized with
  point/Nearest filtering to a transparent `96x96` canvas; no Lanczos resize,
  edge feather, or soft runtime alpha was retained.
- Godot 4.7 imported the source, alpha source, and six runtime frames through
  the normal import pipeline.
