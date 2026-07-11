# Underground Deep Route Endpoint Image Generation Record

- Date: 2026-07-11
- Tool: built-in image generation
- Purpose: Story132 far-side traversal endpoint
- Generated source:
  `assets/generated/source/underground_deep_route_endpoint_imagegen_20260711.png`
- Retained alpha source:
  `assets/generated/source/underground_deep_route_endpoint_alpha_20260711.png`
- Runtime asset:
  `assets/environment/underground_passage/prop_underground_deep_route_endpoint_256x384.png`
- Source dimensions: `887x1774`, opaque RGB
- Alpha dimensions: `887x1774`, transparent RGBA
- Runtime dimensions: `256x384`, transparent RGBA

## Prompt

Create one isolated tall Underground deep-route endpoint on a flat `#ff00ff`
chroma-key background. Use an open corroded pressure-door control frame, steel
ribs, a vertical cyan conduit, two amber lamps, and a cat-eye mechanical lock.
Keep it distinct from the earlier combat seal, with no cast shadow, text, UI,
logo, watermark, or extra objects.

## Processing

The generated magenta key sampled near `#fb02f9`. The project chroma-key helper
removed the background with edge despill, retained the full RGBA alpha source,
then trimmed, resized, and centered the prop on an exact transparent `256x384`
canvas. Godot 4.7 imported source, alpha, and runtime files.
