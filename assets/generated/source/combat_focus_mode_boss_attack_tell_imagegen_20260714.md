# Combat Focus Mode Boss Attack Tell Image Generation

> **Date**: 2026-07-14
> **Tool**: Built-in image generation
> **Story**: Player Abilities Story158

## Purpose

Shared transparent signal-red warning aura for Rat King and Echo Guardian attack
startup. The center remains open so the existing multi-frame Boss animation is
readable while focus mode enlarges the warning area and display duration.

## Prompt

```text
Use case: stylized-concept
Asset type: reusable transparent-source Godot 2D combat VFX for a 1280x720 side-scrolling pixel-art ACT game.
Primary request: create one hostile signal-red boss attack warning aura that will sit behind an existing animated character during attack startup.
Scene/backdrop: perfectly flat uniform solid #00FF00 chroma-key background for local alpha removal; no shadows, gradients, texture, floor, reflections, or lighting variation in the background.
Subject: a wide open-center broken elliptical warning ring made of angular signal-red and red-orange pixel energy, four short inward-facing claw-like directional accents, a few restrained square sparks, and thin industrial feline-tech seams. Keep the entire center empty so a character remains fully readable.
Style/medium: crisp authored 2D pixel-art VFX, hard readable pixels, restrained ruined-industrial feline-tech language, not painterly and not photorealistic.
Composition/framing: one centered horizontal aura, approximately 2:1 aspect ratio, generous green padding on every side, complete uncropped silhouette.
Color palette: dominant signal red #D92828, bright red-orange #FF5A24 highlights, tiny dark crimson accents; do not use cat-eye gold, violet, cyan, blue, white, black fills, or #00FF00 in the subject.
Constraints: no character, animal, boss, environment, weapon, UI panel, icon, text, number, logo, watermark, opaque rectangle, radial explosion, full-screen border, smoke, glass, cast shadow, contact shadow, reflection, or multiple separate assets.
```

## Pipeline

- Generated source:
  `assets/generated/source/combat_focus_mode_boss_attack_tell_imagegen_20260714.png`
  (`1672x941`, opaque RGB, green chroma key).
- Chroma-key helper sampled `#0BF708`, removed `1,391,515 / 1,573,352`
  pixels and retained a soft/despilled alpha edge at:
  `assets/generated/source/combat_focus_mode_boss_attack_tell_alpha_20260714.png`.
- The effect was trimmed and normalized with nearest-neighbor filtering to exact
  transparent `256x128` RGBA at:
  `assets/generated/combat_focus_mode_boss_attack_tell.png`.
- Runtime alpha spans `0..1`; all four corners are transparent and the trimmed
  visible bounds are `209x89+23+19`.
- Godot 4.7 Import System generated import metadata before the GREEN run.
