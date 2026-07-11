# Underground Recovery Relay Image Generation Record

- Date: 2026-07-11
- Tool: built-in image generation
- Purpose: Story132 recovery savepoint and respawn anchor
- Generated source:
  `assets/generated/source/underground_recovery_relay_imagegen_20260711.png`
- Retained alpha source:
  `assets/generated/source/underground_recovery_relay_alpha_20260711.png`
- Runtime asset:
  `assets/environment/underground_passage/prop_underground_recovery_relay_256x256.png`
- Source dimensions: `1254x1254`, opaque RGB
- Alpha dimensions: `1254x1254`, transparent RGBA
- Runtime dimensions: `256x256`, transparent RGBA

## Prompt

Create one isolated side-view Underground recovery relay savepoint on a flat
`#ff00ff` chroma-key background. Use a corroded steel pedestal, amber heart-like
core, cyan mineral conduits, cat-paw motifs, and folding repair clamps. Keep the
silhouette readable at gameplay scale with no cast shadow, text, UI, logo,
watermark, or extra objects.

## Processing

The generated magenta key sampled near `#f903f7`. The project chroma-key helper
removed the background with edge despill, retained the full RGBA alpha source,
then trimmed, resized, and centered the prop on an exact transparent `256x256`
canvas. Godot 4.7 imported source, alpha, and runtime files.
