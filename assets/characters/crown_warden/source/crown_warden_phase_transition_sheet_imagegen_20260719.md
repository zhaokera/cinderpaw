# Crown Warden Phase Transition Image Generation Record

Date: 2026-07-19
Tool: OpenAI image generation
Story: `production/epics/player-abilities/story-176-crown-warden-dedicated-phase-transition-frame-animation.md`

## Purpose

Generate a dedicated three-pose Crown Warden Phase II pulse that can loop for
the complete `2.5s` invulnerable transition instead of freezing on `hurt`.

## Reference

`assets/characters/crown_warden/source/crown_warden_frames_preview_20260712.png`

## Exact Prompt

```text
Create one strict horizontal three-cell pixel-art animation strip for the EXACT SAME Crown Warden shown in the reference: the same giant right-facing mechanical owl, charcoal steel armor, restrained brass crown and trim, bright cyan optics, violet chest coil, amber feather-edge highlights, proportions, lighting, pixel density, full-body scale, center pivot, and ground baseline. This is a dedicated Phase II transformation pulse for a polished horizontal 2D action game, not a hit reaction and not an attack. Exactly three equal cells, one full-body sprite per cell: frame 1 stands tall and braces symmetrically while crown and chest plates draw inward and the violet coil begins to charge; frame 2 reaches the transformation crest with both segmented wings lifted in a broad balanced royal silhouette, crown plates slightly separated, cyan optics bright and compact violet-cyan energy arcs hugging the body; frame 3 settles into a stable empowered hover/stance with wings halfway folded and energy receding, visually close enough to frame 1 for a smooth looping pulse. Keep the body centered and at identical scale in every cell, with one shared baseline and no translation. Use crisp authored pixel art and strong ACT readability. Place the three isolated sprites on a perfectly uniform flat #ff00ff chroma-key background. No red attack tell vanes, forward lunge, talon strike, wing sweep, recoil, injury, collapse, death pose, projectile, explosion, floor, cast shadow, environment, text, labels, separators, frame borders, watermark, crop, overlap, glow spilling into the background, blur, gradients, or 3D rendering.
```

## Retained Files

| File | Properties | SHA-256 |
|------|------------|---------|
| `crown_warden_phase_transition_sheet_imagegen_20260719.png` | RGB `2172x724` source | `119d9a071fd811df57b3f365bd6b6dfca6a91cdfdc76c24d1584ac904a3cbeba` |
| `crown_warden_phase_transition_sheet_alpha_20260719.png` | RGBA `2172x724` alpha intermediate | `aac378746ddae3f60f6d05138517627ad7672c69786e3de41f981842224ba002` |
| `../phase_transition/crown_warden_phase_transition_000.png` | RGBA `192x192` runtime frame | `5d60da616ce86a42d92e0ec260e98c2fe91279562dee8bbae5fb3d9b6a47a705` |
| `../phase_transition/crown_warden_phase_transition_001.png` | RGBA `192x192` runtime frame | `6c2bfff8f12cd59b8d6615a805a3320143e9564f57158d1ffcfe5878b11dd5d6` |
| `../phase_transition/crown_warden_phase_transition_002.png` | RGBA `192x192` runtime frame | `7f5ff3cea75a909bbcc7619d87704bf44f3227a8d39d74f952abc8cb996644a0` |

## Alpha Processing

The generated border was sampled as `#fb03fa`. Alpha cleanup used the project
image-generation helper:

```bash
python3 /Users/zhaok/.codex/skills/.system/imagegen/scripts/remove_chroma_key.py \
  --input crown_warden_phase_transition_sheet_imagegen_20260719.png \
  --out crown_warden_phase_transition_sheet_alpha_20260719.png \
  --auto-key border --soft-matte --transparent-threshold 12 \
  --opaque-threshold 220 --despill --force
```

The result contains `1,229,575` transparent and `26,038` partially transparent
pixels out of `1,572,528` total pixels.

## Runtime Normalization

- Split at exact source columns `0..723`, `724..1447`, and `1448..2171`.
- Nearest-resize each full square cell to `188x188`.
- Composite on transparent `192x192` canvases at offsets `(2,9)`, `(2,9)`,
  and `(27,9)` respectively; the third offset corrects source-cell placement.
- Do not repaint, synthesize duplicate frames, add baked shadows, or merge the
  existing runtime overlay/debris into character textures.
- Godot 4.7 imported all source/intermediate/runtime PNGs and produced their
  adjacent `.import` sidecars.
