# Neon Rooftops Entry Props Image Generation Record

- Generated: 2026-07-11
- Tool: built-in image generation
- Use case: `stylized-concept`
- Story: `production/epics/player-abilities/story-136-neon-rooftops-magnetic-wall-gate-handoff.md`
- Style reference: generated Neon Rooftops entry background
- RGB source: `neon_rooftops_entry_props_imagegen_20260711.png`
- Alpha source: `neon_rooftops_entry_props_alpha_20260711.png`
- Runtime outputs:
  - `assets/environment/neon_rooftops/prop_neon_magnetic_tower_256x512.png`
  - `assets/environment/neon_rooftops/prop_neon_factory_bridge_beacon_256x384.png`

## Prompt

Create exactly two isolated full-object 2D Neon Rooftops props on one perfectly
uniform flat `#ff00ff` chroma-key sheet. Left: a tall narrow magnetic climbing
tower with riveted dark steel, claw-worn grip strips, cyan energy seams,
restrained violet lamps, and a broken cat-ear billboard frame. Right: a compact
Factory bridge beacon with a weathered steel arch, cat-paw route core, cyan
energy, small violet signal lamps, and a grated base. Match the generated
rooftop background's detailed side-view game-art materials. Center one prop in
each equal half with generous padding and no overlap. No characters, enemies,
text, UI, logos, watermark, cast shadow, floor, reflection, haze, extra props,
crossing cables, translucent glass, crop, or key color inside either object.

## Processing

- Built-in generation produced an RGB `1672x941` two-prop sheet.
- Border auto-key selected sampled `#fb02fa`; soft matte thresholds `12/220`,
  despill, one-pixel edge contraction, and `0.25` edge feathering produced the
  retained full-sheet RGBA source.
- Equal `836x941` halves were cropped, alpha-trimmed, proportionally fit, and
  centered on transparent `256x512` and `256x384` runtime canvases.
- Final alpha bounds are `204x496+26+8` for the tower and `240x304+8+40` for
  the bridge beacon, leaving safe transparent padding with no visible magenta
  fringe.
- Godot 4.7 imported RGB source, alpha source, and both runtime PNGs.
