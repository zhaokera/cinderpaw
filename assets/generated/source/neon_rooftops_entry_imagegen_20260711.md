# Neon Rooftops Entry Image Generation Record

- Generated: 2026-07-11
- Tool: built-in image generation
- Use case: `stylized-concept`
- Story: `production/epics/player-abilities/story-136-neon-rooftops-magnetic-wall-gate-handoff.md`
- Style reference: `assets/environment/factory_upper_altar/env_factory_upper_altar_approach_1280x720.png`
- Source: `neon_rooftops_entry_imagegen_20260711.png`
- Runtime: `assets/environment/neon_rooftops/env_neon_rooftops_entry_1280x720.png`

## Prompt

Create a completely new fixed 16:9 side-view Neon Rooftops entry for a polished
2D ACT game, using the Factory upper-works reference only for rendering quality,
ruined-industrial continuity, depth, and material detail. Show an open night
skyline immediately above the Old Factory: a broad lower roof from the left to
roughly two thirds of the frame, a narrow vertical climb break, and a high roof
lip continuing to the right. Include distant ruined cat-city towers, cables,
vents, antennae, broken billboards, moonlit haze, and glimpses of the Factory
below. Keep the lower roof, vertical lane, and high roof exceptionally readable.
Use cold moonlight, restrained cyan route lights, magenta/violet settlement
neon, and sparse amber utility lamps without collapsing into a one-hue palette.
No characters, enemies, UI, text, readable letters, logos, watermark, floating
platforms, primitive blocks, baked collision guides, transparency, camera tilt,
or foreground obstruction.

## Processing

- Built-in generation produced opaque RGB `1672x941`.
- The near-16:9 source was resized to exact opaque RGB `1280x720`; no crop was
  needed, preserving the authored lower-roof gap and upper-roof silhouette.
- Runtime collision is authored separately in Godot and aligned to the painted
  lower roof, vertical break, and upper roof.
- Godot 4.7 imported source and runtime PNGs through the standard texture
  pipeline.
