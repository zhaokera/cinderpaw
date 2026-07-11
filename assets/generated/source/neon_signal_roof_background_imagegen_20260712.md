# Neon Signal Roof Background Image Generation Record

- Generated: 2026-07-12
- Tool: built-in image generation
- Use case: `stylized-concept`
- Story: `production/epics/player-abilities/story-137-neon-rooftops-signal-rat-ambush.md`
- Style reference: generated Neon Rooftops entry background
- Source: `neon_signal_roof_background_imagegen_20260712.png`
- Runtime: `assets/environment/neon_rooftops/env_neon_signal_roof_1280x720.png`

## Prompt

Create a new fixed 16:9 side-view continuation of the Neon Rooftops for a
polished 2D ACT game. Match the first generated rooftop screen's detailed
ruined-industrial material language, but compose a distinct Signal Roof: a
high ledge entering from the upper left, a readable descent into one broad
grounded combat arena, and an open route at the right edge. Fill the distance
with ruined cat-city towers, antenna arrays, cables, relay dishes, vents,
broken billboards, moonlit storm clouds, and restrained cyan, violet, signal
red, and amber lights. Keep the playable floor and combat silhouettes clear.
No characters, enemies, gates, cache, UI, text, logos, watermark, floating
platforms, primitive blocks, transparency, camera tilt, or foreground cover.

## Processing

- Built-in generation produced opaque RGB `1672x941`.
- The source was resized to exact opaque RGB `1280x720` without cropping, so
  the authored descent and arena composition remain intact.
- Runtime collision is authored separately in Godot over the painted roof.
- Godot 4.7 imported the source and runtime PNG through its texture pipeline.
