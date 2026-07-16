# Old Factory Steam Vent Motion Image Generation Record

> **Date**: 2026-07-16
> **Generator**: built-in image generation
> **Story**: Combat Presentation Story033
> **Reference**: `../factory_steam_vent_hazard.png`

## Generation Prompt

Create a production-ready 2D pixel-art animation contact sheet for the
referenced Cinderpaw Old Factory steam vent hazard. Preserve the exact same
squat circular cracked dark-steel vent base, red-orange front status lamp,
side pipe silhouette, perspective, scale, center point, and ground baseline in
every cell. Layout must be a precise 4-column by 3-row grid of twelve equal
square cells, with no gutters, no borders, no labels, no numbers, no text, and
no extra objects. Row 1 SAFE: four subtly different frames with only tiny low
white vapor wisps close to the grate, clearly non-dangerous. Row 2 WARNING:
four buildup frames with medium compressed steam pulses and the front lamp
glowing brighter amber-red, readable anticipation but not yet a full blast.
Row 3 ACTIVE: four forceful upward white steam plume frames, high and
turbulent, clearly dangerous while keeping the metal base unchanged. Flat pure
`#FF00FF` chroma-key background in every cell, hard pixel edges, no cast shadow
outside the vent, no bloom, no transparency, no gradients in the background.
Cohesive industrial dark steel, rust orange, cool white steam, limited palette,
side-view action game readability. The animation motion must come from the
steam and lamp only; do not move, resize, rotate, or redraw the vent base
between cells.

## Files

- Generated RGB contact sheet:
  `factory_steam_vent_motion_sheet_imagegen_20260716.png` (`1254x1254`).
- Chroma-key alpha sheet:
  `factory_steam_vent_motion_sheet_alpha_20260716.png` (`1254x1254`, sRGBA).
- Runtime preview:
  `factory_steam_vent_motion_frames_preview_20260716.png` (`1024x768`).
- Runtime frames: `../safe/`, `../warning/`, and `../active/`, four continuous
  transparent sRGBA `256x256` PNGs per state.

## Processing

- Removed uniform `#ff00ff` using soft matte thresholds `28/90`, one-pixel
  edge contract and despill.
- Isolated all twelve cells and downsampled each subject onto the same
  transparent `256x256` runtime canvas.
- Safe and warning frames use a `333px` source crop; active frames use a
  `375px` source crop so the tallest plume remains inside the canvas.
- Retained the generated RGB source, alpha intermediate and contact preview.

Godot 4.7 imported the source, alpha intermediate, preview and all twelve
runtime frames.
