# Image Generation Record: Central Tower Relay Mantis Sprite Sheet

- **Tool**: built-in image generation
- **Date**: 2026-07-12
- **Use**: Story141 ordinary Tower enemy
- **Source**: `central_tower_relay_mantis_sprite_sheet_imagegen_20260712.png`
- **Source size**: `887x1774`
- **Alpha source**: `central_tower_relay_mantis_sprite_sheet_alpha_20260712.png`
- **Preview**: `central_tower_relay_mantis_frames_preview_20260712.png`
- **Detected border key**: `#fb03f9`

## Prompt Summary

One strict `3x6` sheet containing exactly eighteen right-facing poses of the
same tall, narrow steel-blue maintenance Mantis. Rows are `idle`, `run`,
`attack_tell`, forward scythe-dash `attack`, `hurt`, and `death`. Signal red is
restricted to attack rows. The prompt forbade rat anatomy, heavy square guard
silhouette, Boss scale, text, grid lines, shadows, particles, detached weapons,
cropping, and inconsistent anatomy.

## Processing

The installed imagegen chroma helper used border auto-key, soft matte, despill,
and one-pixel edge contraction. It produced `1,424,484` transparent and `65,464`
partially transparent pixels. The alpha sheet was divided by exact `3x6` cell
boundaries. All cells share one scale factor (`0.298305`), were centered on
transparent `96x96` canvases, and were bottom-aligned to y `88`. Every runtime
frame reports the same used-image bottom and continuous `_000.._002` naming.
