# Image Generation Record: Central Tower Counterweight Sentry Sprite Sheet

- **Tool**: OpenAI built-in image generation (`image2`)
- **Date**: 2026-07-12
- **Use**: Story143 ordinary Tower moving-platform enemy
- **Source**: `central_tower_counterweight_sentry_sprite_sheet_imagegen_20260712.png`
- **Source size**: `887x1774`
- **Alpha source**: `central_tower_counterweight_sentry_sprite_sheet_alpha_20260712.png`
- **Preview**: `central_tower_counterweight_sentry_frames_preview_20260712.png`
- **Detected border key**: `#f703f6`

## Exact Prompt

Generate exactly one portrait 1:2 sprite source sheet with 3 equal columns and
6 equal rows: exactly 18 isolated right-facing frames of the same ordinary
Central Tower Counterweight Sentry on perfectly uniform flat `#FF00FF`. Design:
compact top-heavy trapezoid automaton, hanging ballast abdomen, two short clawed
legs, one forward telescoping ram arm, dark steel-blue and black iron, small
cyan status slit, no gold, not Boss-sized, no rat or mantis anatomy. Rows in
exact order: idle weight sway; run heavy steps; attack_tell compression and red
warning; attack ram extension/impact/follow-through; hurt recoil/compression/
recovery; death stagger/kneel/collapse. Signal red only in attack_tell and
attack. Keep anatomy, scale, facing, lighting, and bottom-center registration
identical. Entire body and extended ram remain inside a 12% safety margin.
Exclude detached parts, particles, impact VFX, shadows, text, labels, grid
lines, extra poses, perspective changes, cropping, magenta inside the character,
and background variation.

## Processing

The installed imagegen chroma helper used border auto-key, soft matte, despill,
and one-pixel edge contraction. It produced `1,201,145` fully transparent and
`39,343` partially transparent pixels. The alpha sheet was divided by exact
proportional `3x6` boundaries because `887x1774` is not evenly divisible by
three or six. Small keyed islands were removed with an area threshold while
preserving source alpha on retained silhouettes.

All cells use one global scale (`0.28378`), fit within `84x84`, and are centered
on transparent `96x96` canvases with common bottom y `87` / anchor `(48,88)`.
Runtime rows are `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death`,
with continuous `_000.._002` names and no per-frame scale drift.
