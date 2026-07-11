# Underground Corrosive Runoff Image Generation Record

- Date: 2026-07-11
- Tool: built-in image generation
- Purpose: Story131 jumpable contact hazard
- Generated RGB source:
  `assets/generated/source/underground_corrosive_runoff_imagegen_20260711.png`
- Retained alpha source:
  `assets/generated/source/underground_corrosive_runoff_alpha_20260711.png`
- Runtime asset:
  `assets/environment/underground_passage/prop_underground_corrosive_runoff_512x160.png`
- Source dimensions: `1935x813`, opaque RGB
- Alpha source dimensions: `1935x813`, RGBA
- Runtime dimensions: `512x160`, transparent RGBA

## Prompt

Generate one isolated, long, shallow corrosive runoff trench in polished
side-view pixel art: broken rusted steel gutter, dark stone supports, luminous
toxic yellow-green liquid, restrained bubbles, and cyan mineral reflections.
Use a perfectly flat `#ff00ff` chroma-key background with no shadow, gradient,
floor, characters, text, UI, watermark, or extra objects.

## Processing

The border-sampled key color was `#fb03fa`. The standard chroma-key helper used
soft matte thresholds `12/220` plus despill. The retained alpha source was
trimmed, resized, and centered on a transparent `512x160` runtime canvas.
