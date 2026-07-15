# Combat Player Death + Revive Feedback Image Generation

> **Date**: 2026-07-14
> **Tool**: Built-in image generation
> **Story**: Death & Respawn Story008

## Purpose

Two transparent pixel-art Presentation assets for the real Main death/respawn
flow: a compact cat-eye-gold soul wisp and a hollow cat-eye-gold revive halo.
The full-screen grayscale transition remains a Godot screen shader rather than
a bitmap overlay.

## Prompt

```text
Use case: stylized-concept
Asset type: two-panel pixel-art VFX source sheet for a 1280x720 side-scrolling
Godot ACT game.
Primary request: create exactly two isolated feline death-and-revive VFX assets
in a strict left/right layout for later alpha extraction.
Scene/backdrop: perfectly flat uniform #FF00FF chroma-key background.
Left panel: one compact cat-eye-gold soul wisp shaped like an upward-drifting
feline-eye flame, centered with generous padding.
Right panel: one large hollow cat-eye-gold revive halo, straight-on, with
feline ear points and paw/claw motifs; center remains chroma-key empty.
Style: crisp authored pixel art, ruined-industrial feline-tech language, hard
readable pixels, restrained #ECC94B and pale-gold highlights.
Constraints: exact two equal vertical halves; no characters, environment, text,
UI, logos, watermark, panel labels, red/cyan/blue, shadows, fog or blur.
```

## Pipeline

- Generated source:
  `assets/generated/source/combat_player_death_revive_feedback_sheet_imagegen_20260714.png`
  (`1672x941`, opaque RGB, magenta chroma key).
- Chroma-key helper sampled `#F703F0`, removed `1,447,016 / 1,573,352`
  pixels and retained a soft/despilled alpha edge at:
  `assets/generated/source/combat_player_death_revive_feedback_sheet_alpha_20260714.png`.
- The alpha sheet was split at the exact center, trimmed with ImageMagick
  point filtering, fit and centered into:
  - `assets/generated/combat_player_death_soul_wisp.png` (`256x256`, RGBA)
  - `assets/generated/combat_player_revive_halo.png` (`512x512`, RGBA)
- Godot 4.7 Import System generated import metadata before implementation tests.
