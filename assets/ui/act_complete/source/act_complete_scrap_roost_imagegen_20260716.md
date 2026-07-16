# ACT Complete Scrap Roost Image Generation Record

> **Date**: 2026-07-16
> **Generator**: built-in image generation
> **Story**: Player Abilities Story168

## Generation Prompt

Create a polished 16:9 2D game background for a post-victory ACT-complete
screen in Cinderpaw's stylized dieselpunk mechanical wasteland. Show Scrap
Roost at sunrise as a dense side-view settlement built from rusted steel,
catwalks, cables, towers and scavenged machinery. In the readable foreground,
place the Crown Warden's broken mechanical owl crown beside a glowing brass
cat-paw lantern, suggesting that the three-region hunt is secured. Use warm
sunrise gold against cool teal and charcoal shadows, rich production-ready
detail, strong depth and a calm triumphant mood. Keep the central area readable
for an overlaid menu. No text, logos, UI, borders, living characters, gradients
or primitive placeholder shapes.

## Files

- Retained source:
  `assets/ui/act_complete/source/act_complete_scrap_roost_imagegen_20260716.png`
  (`1672x941`, RGB).
- Runtime:
  `assets/ui/act_complete/act_complete_scrap_roost_1280x720.png`
  (`1280x720`, RGB).

## Deterministic Processing

```text
magick <source> -resize '1280x720^' -gravity center -extent 1280x720 \
  -alpha off -colorspace sRGB -strip <runtime>
```

Godot 4.7 imported both PNGs. `HUDManager` preloads only the runtime texture.
