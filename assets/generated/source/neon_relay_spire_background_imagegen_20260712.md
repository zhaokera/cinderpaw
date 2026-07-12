# Neon Relay Spire Background Image Generation Record

- Generated: 2026-07-12
- Tool: built-in image generation
- Use case: `stylized-concept`
- Story: `production/epics/player-abilities/story-138-neon-rooftops-relay-spire-savepoint-traverse.md`
- Source dimensions: `1672x941`, opaque RGB
- Source: `neon_relay_spire_background_imagegen_20260712.png`
- Runtime: `assets/environment/neon_rooftops/env_neon_relay_spire_1280x720.png`

## Prompt

Create a production-quality fixed 16:9 side-view third Neon Rooftops viewport
for a polished 2D ACT game. Match the ruined-industrial moonlit cat-city
continuity: a short safe approach roof on the left, a wide lethal gap, a tall
central magnetic relay spire with readable climb bars and upper perch, and a
solid exit roof on the right leading toward a distant monumental electronic
tower. Fill the distance with ruined skyscrapers, dishes, cables, broken
billboards, vents, storm clouds, and moonlight. Use cold blue, cyan magnetic
seams, restrained violet/magenta neon, signal red, sparse amber, dark steel,
and oxidized metal. Keep route silhouettes clear. No characters, enemies, gate,
savepoint, endpoint prop, UI, text, logo, watermark, floating platforms,
primitive collision guides, transparency, camera tilt, or foreground cover.

## Processing

- The near-16:9 source was resized to exact opaque RGB `1280x720` without
  cropping, preserving the authored left roof, central spire, and right roof.
- Collision and interactive props remain separate Godot nodes aligned to the
  painted surfaces.
- Godot 4.7 imported source and runtime PNG through the texture pipeline.
