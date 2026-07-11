# Underground Salvage Cache Image Generation Record

- Date: 2026-07-11
- Tool: built-in image generation
- Purpose: Story131 post-combat reward payoff
- Generated RGB source:
  `assets/generated/source/underground_salvage_cache_imagegen_20260711.png`
- Retained alpha source:
  `assets/generated/source/underground_salvage_cache_alpha_20260711.png`
- Runtime asset:
  `assets/environment/underground_passage/prop_underground_salvage_cache_256x256.png`
- Source dimensions: `1448x1086`, opaque RGB
- Alpha source dimensions: `1448x1086`, RGBA
- Runtime dimensions: `256x256`, transparent RGBA

## Prompt

Generate one isolated compact Underground salvage lockbox in polished side-view
pixel art: corroded steel, masonry brackets, cat-paw latch, bright amber gear
core, cyan mineral inlays, wet oxidation, and restrained toxic stains. Use a
perfectly flat `#ff00ff` chroma-key background with no shadow, characters, text,
UI, watermark, smoke, or extra objects.

## Processing

The border-sampled key color was `#fb02fa`. The standard chroma-key helper used
soft matte thresholds `12/220` plus despill. The retained alpha source was
trimmed, resized, and centered on a transparent `256x256` runtime canvas.
