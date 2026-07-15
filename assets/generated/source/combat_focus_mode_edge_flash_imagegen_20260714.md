# Combat Focus Mode Edge Flash Image Generation

> **Date**: 2026-07-14
> **Tool**: Built-in image generation
> **Story**: Player Abilities Story154

## Purpose

One-shot transparent `1280x720` combat overlay for the low-HP focus-mode entry
signal required by `TR-health-007`. It must keep the gameplay center readable
and distinguish focus activation from the existing radial parry flash.

## Prompt

```text
Use case: stylized-concept
Asset type: transparent full-screen Godot 2D combat VFX overlay source for a
1280x720 side-scrolling pixel-art ACT game.
Primary request: create a restrained low-health focus-mode activation overlay
that reads as a feline hunter's eyes opening in darkness, designed to flash for
only 0.3 seconds.
Scene/backdrop: perfectly flat uniform solid #FF00FF chroma-key background.
Subject: thin luminous cat-eye-gold (#ECC94B) energy strokes hugging the left
and right screen edges, with subtle top and bottom edge accents; central 70%
remains empty chroma-key so gameplay stays visible.
Style: crisp authored pixel-art VFX, hard readable pixels, ruined-industrial
feline-tech language, restrained gold-white highlights.
Constraints: no characters, environment, UI panels, text, icons, logos or
watermark; no radial explosion, red warning, blue/cyan, dense particles or
screen-filling fog.
```

## Pipeline

- Generated source:
  `assets/generated/source/combat_focus_mode_edge_flash_imagegen_20260714.png`
  (`1672x941`, opaque RGB, magenta chroma key).
- Chroma-key helper sampled `#F803F8`, removed `1,498,108 / 1,573,352` pixels
  and retained a soft/despilled alpha edge at:
  `assets/generated/source/combat_focus_mode_edge_flash_alpha_20260714.png`.
- Runtime output was resized to exact transparent `1280x720` RGBA:
  `assets/generated/combat_focus_mode_edge_flash_overlay.png`.
- Godot 4.7 Import System generated the runtime import metadata before tests.
