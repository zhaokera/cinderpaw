# Combat Focus Environment Dust Mote Image Generation

> **Date**: 2026-07-14
> **Tool**: Built-in image generation
> **Story**: Player Abilities Story159

## Purpose

Sparse harmless background dust for one Main `CPUParticles2D` ambience layer.
The generated fleck stays behind gameplay actors and becomes less intrusive at
30% CanvasItem alpha while low-HP focus mode is active.

## Prompt

```text
Use case: stylized-concept
Asset type: transparent-source particle texture for a Godot 4.7 CPUParticles2D environment layer, normalized later to 64x64.
Primary request: create exactly one tiny restrained wasteland dust mote cluster for slow background ambience in a side-scrolling pixel-art ACT game.
Scene/backdrop: perfectly flat uniform solid #00FF00 chroma-key background for local alpha removal; no shadows, gradients, texture, floor, reflections, lighting variation, or green spill.
Subject: one compact irregular angular dust fleck, with one small central pixel fragment and at most two minuscule attached or nearby grains; it must read as harmless airborne dust, not impact debris.
Style/medium: crisp authored 2D pixel art, hard readable pixels, sparse ruined-industrial atmosphere, no antialiased painting or photorealism.
Composition/framing: exactly one centered compact mote occupying less than 18 percent of the image width and height, enormous uniform green padding on every side, fully uncropped.
Color palette: muted steel grey #8A96A3, dusty amber #C39B5A, tiny pale ash highlight #C6C8C4; do not use signal red, cat-eye gold, cyan, violet, black fills, white glow, or #00FF00 in the subject.
Constraints: no character, animal, environment, UI, text, number, logo, watermark, smoke cloud, fog bank, explosion, spark burst, slash, fire, rock pile, floor, cast shadow, contact shadow, reflection, multiple separate asset panels, opaque rectangle, or border.
```

## Pipeline

- Generated source:
  `assets/generated/source/combat_focus_environment_dust_mote_imagegen_20260714.png`
  (`1254x1254`, opaque RGB, green chroma key).
- Built-in output was retained at its generated-image location and copied into
  the project source directory without modifying the original.
- Chroma-key processing used the project imagegen helper with `--auto-key
  border --soft-matte --transparent-threshold 12 --opaque-threshold 220
  --despill`; it sampled `#0CF80A`, made `1,570,287 / 1,572,516` pixels fully
  transparent and retained `338` partial-alpha edge pixels.
- Alpha intermediate:
  `assets/generated/source/combat_focus_environment_dust_mote_alpha_20260714.png`
  (`1254x1254` RGBA, visible bounds `77x77+580+578`).
- The subject was trimmed, nearest-neighbor fit within `24x24`, centered, and
  extended to exact transparent `64x64` RGBA at:
  `assets/generated/combat_focus_environment_dust_mote.png`.
- Runtime alpha spans `0..1`, all four corners are transparent, and visible
  bounds are `24x24+20+20`.
- Godot 4.7 Import System generated import metadata before GREEN verification.
