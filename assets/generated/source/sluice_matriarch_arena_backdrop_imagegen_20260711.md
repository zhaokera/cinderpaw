# Image Generation Record: Sluice Matriarch Arena Backdrop

Date: 2026-07-11
Mode: built-in image generation
Use case: stylized-concept
Story: `production/epics/player-abilities/story-127-old-factory-tailrace-sluice-matriarch-arena-handoff.md`

## Prompt

Create a polished 16:9 pixel-art environment backdrop for a Godot 4.7
side-scrolling action game. Show the Old Factory tailrace pressure cathedral in
strict side view: riveted dark steel bulkheads, dense damp pipes, rust-orange
pressure machinery, cyan-blue route lighting near the entrance, runoff stains,
and a broad readable floor plane across the lower frame. Behind cracked
containment glass, show a dormant giant mutated sluice-leech cocoon as clear
Boss3 foreshadowing without depicting an active character. Keep foreground
collision silhouettes readable and reserve open space for Cinderpaw and combat.
Use crisp authored pixel art, chunky industrial detail, controlled
charcoal/steel-blue/rust-orange/cyan contrast, and no gradients used as empty
decoration. No text, UI, watermark, health bars, player, active enemy, plain
boxes, decorative border, or photorealism.

## Outputs

- Generated source:
  `assets/generated/source/sluice_matriarch_arena_backdrop_imagegen_20260711.png`
- Source properties: `1672x941`, RGB, opaque.
- Runtime output:
  `assets/environment/sluice_matriarch_arena/env_sluice_matriarch_arena_backdrop_1280x720.png`
- Runtime properties: `1280x720`, RGB, opaque.

## Processing

The generated source was retained unchanged. macOS `sips` resized it to exactly
`1280x720` for the fixed-format arena viewport. No alpha extraction, crop, or
chroma-key processing was needed because the asset is a full-screen opaque
backdrop. Godot 4.7 imported both files through the standard import pipeline.

## Runtime Use

The runtime texture is mounted as `Background` in
`scenes/bosses/sluice_matriarch_arena.tscn`. It provides the player-visible
arena environment for Story127; the cocoon remains environmental foreshadowing
until Story128 supplies the frame-animated boss.
