# Asset Spec: Echo Guardian Attack Tell Frame Animation

Date: 2026-07-14
Story: `production/epics/player-abilities/story-165-boss2-echo-guardian-attack-tell-frame-animation-runtime.md`
Status: Implemented

## Role

The Echo Guardian's startup must read as stored tension before its existing
active swipe. The new frames separate anticipation from damage without changing
the Boss silhouette, timing, hitbox, or Story158 external Focus warning.

## Runtime Contract

| Asset | Contract |
| --- | --- |
| Node/resource | Existing `AnimatedSprite2D + SpriteFrames` |
| Animation | `attack_tell`, non-looping, `18 FPS` |
| Frame count | Exactly three PNGs |
| Frame size | `160x128` RGBA with transparent corners |
| Path | `assets/characters/boss2_echo_guardian/attack_tell/` |
| Naming | `boss2_echo_guardian_attack_tell_000.png` through `_002.png` |
| State mapping | startup = `attack_tell`; active = existing `attack` |
| Extended startup | Hold frame `2`; never restart the completed tell |

## Art Direction

- Preserve the existing side-view cyber-feline identity: gunmetal scrap armor,
  brass trim, violet cat-eye core, feline ears and clawed paws.
- Progress from crouched anticipation to a deeper coil and then maximum stored
  tension. The core becomes brighter and more concentrated across the strip.
- Keep scale, ground baseline, facing, and pivot consistent across all cells.
- Do not show a strike, slash, projectile, forward lunge, shadow, scenery, UI,
  text, watermark, or frame border.

## Generation And Processing

Built-in image generation used the retained original Echo Guardian sprite sheet
as a visual reference. The prompt and exact paths are stored in:

`assets/characters/boss2_echo_guardian/source/boss2_echo_guardian_attack_tell_imagegen_20260714.json`

The generated source is an exact three-cell `2172x724` strip on a flat green
background. Local processing detected key color `#09ed13`, produced the alpha
source, split three equal `724x724` cells, point-resized each to `150x150`, and
composited at `+5,+2` on transparent `160x128` canvases.

Retained sources:

- `assets/characters/boss2_echo_guardian/source/boss2_echo_guardian_attack_tell_sheet_imagegen_20260714.png`
- `assets/characters/boss2_echo_guardian/source/boss2_echo_guardian_attack_tell_sheet_alpha_20260714.png`

## Validation

- All runtime frames are TrueColorAlpha PNGs with transparent corners and
  continuous names.
- Godot 4.7 imports all frames and exposes exactly three `attack_tell` frames.
- Focus-extended startup holds frame `2`; active entry selects `attack`.
- MCP verifies the real Main handoff, animation resource, hitbox boundary,
  clean logs, and visually distinct startup/active screenshots.
