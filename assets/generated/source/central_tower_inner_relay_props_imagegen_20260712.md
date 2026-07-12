# Image Generation Record: Central Tower Inner Relay Props

- **Tool**: built-in image generation
- **Date**: 2026-07-12
- **Use**: Story141 relay, shutter, perch, cache, and pulse
- **Source**: `central_tower_inner_relay_props_imagegen_20260712.png`
- **Source size**: `1536x1024`
- **Alpha source**: `central_tower_inner_relay_props_alpha_20260712.png`
- **Detected border key**: `#fb03fa`

## Prompt Summary

Exactly five isolated high-detail pixel-art game props on one flat `#ff00ff`
sheet: a cyan service relay, red-locked observation shutter, light Mantis
maintenance perch, safe-latched relay cache, and a horizontal red-white pulse.
The prompt forbade text, labels, shadows, floors, grid lines, characters,
duplicates, and magenta within the subjects.

## Processing

The installed imagegen chroma helper used border auto-key, soft matte, despill,
and one-pixel edge contraction. It produced `1,295,866` transparent and `43,775`
partially transparent pixels. The five isolated regions were trimmed, resized,
and centered/bottom-aligned on exact transparent runtime canvases:

- relay `256x512`
- shutter `384x512`
- perch `256x256`
- cache `256x256`
- pulse `512x128`
