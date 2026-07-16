# Rat Minion Attack Tell Image Generation Record

> **Date**: 2026-07-16
> **Generator**: built-in image generation
> **Story**: Combat Presentation Story032
> **Reference**: `rat_minion_frames_preview_20260625.png`

## Generation Prompt

Use case: stylized-concept. Asset type: Godot 2D character animation source
strip. Create exactly three distinct bite-attack anticipation frames for the
referenced Cinderpaw Rat Minion. Preserve its charcoal fur, blackened rusted
scrap armor, orange-red eyes, dorsal metal spikes, long thin segmented tail,
compact low silhouette, scale and painterly 2D game-sprite style. Left to
right: (1) notices target and lowers into a guarded crouch, ears pinned and head
low; (2) compresses hind legs, coils tail, raises shoulders and begins opening
jaw; (3) maximum pre-lunge tension with forepaws planted, bristling spine and
open mouth, ready to spring but not moving forward. Anticipation only: no leap,
bite contact or active attack pose. Render one strict horizontal 3-cell strip
with equal-width cells, exactly one complete rat centered independently in each
cell, same facing direction, ground baseline and anchor, generous padding, no
dividers. Perfectly flat uniform `#ff00ff` chroma-key background with no shadow,
gradient, texture or floor. Do not use `#ff00ff` on the rat. No text, labels,
watermark, border, extra objects or extra characters.

## Files

- Generated RGB strip:
  `rat_minion_attack_tell_strip_imagegen_20260716.png` (`1946x808`).
- Chroma-key alpha strip:
  `rat_minion_attack_tell_strip_alpha_20260716.png` (`1946x808`, sRGBA).
- Runtime frames:
  `../attack_tell/rat_minion_attack_tell_000.png` through `_002.png`
  (transparent sRGBA `96x96`).

## Processing

- Removed the sampled border key `#fa03f9` with the project image-generation
  helper, soft matte thresholds `12/220` and despill.
- Cropped the three isolated cells at `0..648`, `650..1275` and `1275..1946`.
- Trimmed alpha, fit each subject inside `88x71`, centered it horizontally and
  placed the common ground baseline at `y=91` on the exact `96x96` canvas.
- Retained four transparent pixels of horizontal padding at both sides.

Godot 4.7 imported the source, alpha intermediate and all three runtime frames.
