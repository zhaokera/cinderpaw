# Asset Spec: Crown Warden Playable Boss4 Core

> **Story**: 146
> **Generation policy**: built-in image generation, retained keyed source,
> deterministic alpha processing, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Crown Warden frame resource | `AnimatedSprite2D + SpriteFrames`; eight animations named `idle`, `run`, `talon_dive_tell`, `talon_dive`, `wing_sweep_tell`, `wing_sweep`, `hurt`, `death`; exactly three frames each | `res://assets/characters/crown_warden/crown_warden_sprite_frames.tres` |
| Runtime frames | Twenty-four transparent sRGBA `192x192` PNGs, one shared scale and center pivot, ground edge within `y=158..159`, continuous `_000..002` names | `res://assets/characters/crown_warden/<animation>/crown_warden_<animation>_<frame>.png` |
| Retained source | Opaque keyed image-generation source, full RGBA alpha intermediate, corrected transparent preview, and exact generation/processing record | `res://assets/characters/crown_warden/source/` |

## Visual Direction

Crown Warden is a giant mechanical owl sentinel with a broad royal silhouette,
charcoal steel armor, restrained brass crown and trim, cyan optics, violet chest
coil and amber feather edges. Signal red appears only in attack tells. Talon
Dive compresses then drives forward with extended talons; Wing Sweep opens one
segmented wing into a wide horizontal strike. The silhouette must remain legible
against the cyan/violet/amber Crown Observatory without looking like a static
prop or enlarged normal enemy.

## Canonical Generation Prompt

The exact prompt is retained verbatim in
`assets/characters/crown_warden/source/crown_warden_sprite_sheet_imagegen_20260712.md`.
It requests one coherent right-facing mechanical owl in a strict `3x8` sheet,
rows ordered by the eight gameplay animations above, on uniform `#ff00ff`, with
consistent scale, pivot and baseline. It excludes organic bird anatomy, cat
anatomy, text, separators, UI, environment, shadows, crop, overlap, background
variation and 3D rendering.

## Processing And Import

- Retain the `887x1774` opaque source and same-size alpha source.
- Split at proportional `3x8` boundaries; preserve one global scale and place
  each untrimmed cell inside a transparent `192x192` canvas.
- Remove the sampled magenta key with soft matte/despill thresholds `12/220`.
- Shift only the three collapsed death canvases down `17`, `17`, and `15`
  transparent pixels so all opaque ground edges align within two pixels; do not
  rescale, repaint or regenerate the selected art.
- Use nearest filtering. The character scene remains
  `scenes/characters/crown_warden.tscn`; the gameplay shell remains
  `src/gameplay/crown_warden_boss.tscn`.
- Focused tests inspect dimensions, alpha, ground anchor, animation names/frame
  counts and runtime state mapping. MCP must verify visible animation, non-empty
  screenshots and clean current-run logs.

## Source Files

- `crown_warden_sprite_sheet_imagegen_20260712.png`
- `crown_warden_sprite_sheet_alpha_20260712.png`
- `crown_warden_frames_preview_20260712.png`
- `crown_warden_sprite_sheet_imagegen_20260712.md`
