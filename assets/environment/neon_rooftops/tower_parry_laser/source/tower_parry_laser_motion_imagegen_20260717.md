# Tower Parry Laser Motion Image Generation Record

> **Date**: 2026-07-17
> **Generator**: built-in image generation
> **Story**: Player Abilities Story170
> **Reference**: `../../vfx_neon_tower_laser_pulse_512x128.png`

## Common Prompt Contract

Create a production 2D pixel-art VFX animation strip for a horizontal action
game using the referenced Central Tower laser for style, palette, thickness
and scale. Output exactly three equal cells in one horizontal row with a common
vertical center, anchor and side-view camera. Use crisp white, signal-red,
cyan, gold or orange clusters as required by the state. No text, labels,
borders, gutters, UI, blur or extra objects. Use a perfectly flat solid
`#FF00FF` chroma-key background with no magenta subject pixels.

## State Prompts

- `telegraph`: red-white energy gathers inward from two broken halves; frame 0
  is sparse and separated, frame 1 is brighter convergence, frame 2 is a
  compressed near-strike center gap with controlled cyan arcs.
- `strike`: frame 0 ignites one complete core, frame 1 becomes thick and
  intensely bright, frame 2 reaches peak crackling impact; all frames remain a
  solid uninterrupted damaging beam.
- `recovery_reflected`: frame 0 fractures at one compact gold parry spark,
  frame 1 reverses as a cyan-white outward surge with directional chevrons,
  frame 2 retracts into cyan fragments and a small gold afterglow.
- `recovery_missed`: frame 0 collapses the red-white beam inward, frame 1
  separates it into red-orange segments, frame 2 leaves faint residue and
  falling sparks; no cyan or gold success language.

## Files

- Generated RGB strips: `tower_parry_laser_*_strip_imagegen_20260717.png`,
  each `2172x724`.
- Chroma-key alpha strips: `tower_parry_laser_*_strip_alpha_20260717.png`,
  each `2172x724` sRGBA.
- Runtime preview: `tower_parry_laser_motion_frames_preview_20260717.png`
  (`1536x512`, four rows by three columns).
- Runtime frames: `../telegraph/`, `../strike/`,
  `../recovery_reflected/`, and `../recovery_missed/`, three continuous
  transparent sRGBA `512x128` PNGs per state.

## Processing

- Removed the sampled magenta border with soft matte thresholds `28/90`, one
  pixel edge contract and despill.
- Split each source into three fixed `724px` cells, fixed-cropped rows
  `226..481`, resized to `492x128`, and centered on a transparent `512x128`
  canvas with ten-pixel side padding.
- Verified all twelve frames are non-empty RGBA, use alpha blend, keep fully
  transparent canvas edges and preserve a shared center.
- Retained all generated RGB sources, alpha intermediates and the preview.

Godot 4.7 imported all source and runtime files before GdUnit and MCP runtime
acceptance.
