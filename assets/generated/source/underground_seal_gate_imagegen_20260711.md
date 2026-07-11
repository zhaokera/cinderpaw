# Underground Seal Gate Image Generation Record

- Date: 2026-07-11
- Tool: built-in image generation
- Purpose: Story131 rear/front combat-room seals
- Generated RGB source:
  `assets/generated/source/underground_seal_gate_imagegen_20260711.png`
- Retained alpha source:
  `assets/generated/source/underground_seal_gate_alpha_20260711.png`
- Runtime asset:
  `assets/environment/underground_passage/prop_underground_seal_gate_256x384.png`
- Source dimensions: `1024x1536`, opaque RGB
- Alpha source dimensions: `1024x1536`, RGBA
- Runtime dimensions: `256x384`, transparent RGBA

## Prompt

Generate one isolated tall Underground bulkhead combat seal in polished
side-view pixel art: corroded steel sliding plates, cyan conduits, amber warning
lamps, a cat-eye mechanical latch, damp oxidation, and limited toxic residue.
Use a perfectly flat `#ff00ff` chroma-key background with generous padding and
no shadow, characters, text, UI, watermark, smoke, or extra objects.

## Processing

The border-sampled key color was `#fb02fb`. The standard chroma-key helper used
soft matte thresholds `12/220` plus despill. The retained alpha source was
trimmed, resized, and centered on a transparent `256x384` runtime canvas.
