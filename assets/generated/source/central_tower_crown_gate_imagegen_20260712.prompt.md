# Central Tower Crown Gate Prompt

**Generator**: Built-in image generation
**Date**: 2026-07-12
**Runtime destination**:
`res://assets/environment/central_tower/prop_central_tower_crown_gate_256x384.png`

```text
Use case: stylized-concept
Asset type: one production 2D side-scrolling ACT environment prop for chroma-key extraction
Primary request: a single Central Tower Crown Observatory transition gate, a tall compact mechanical portal used both at the Apex Approach and as the arena return marker
Subject: blackened steel arch shaped like a restrained mechanical crown, two narrow outward crown prongs, circular cyan-white observatory lens at center, aged brass trim, small amber route lights, cables and ceramic insulators, clear open lower doorway silhouette; no creature, no owl, no character
Style/medium: polished hand-painted pixel-art-inspired game sprite, crisp closed silhouette, orthographic exact side view, premium cyberpunk feline action game, not photorealistic, not vector flat art
Composition/framing: exactly one complete isolated object centered, portrait proportions roughly 2:3, generous 12 percent padding on every side, nothing touches the image edge, no floor and no cast shadow
Background: perfectly uniform flat solid #FF00FF across every background pixel, no gradient, texture, grid, border, reflection or lighting variation
Lighting/colors: charcoal steel, neutral black, cyan-white lens, aged brass and restrained amber; tiny signal red only in two inactive safety lamps; never use #FF00FF inside the subject
Constraints: one object only, transparent-ready closed edges, no text, no letters, no numbers, no logo, no watermark, no characters, no enemies, no boss, no bird, no cat, no duplicate, no separate particles, no scenery, no floor, no cropped extremities, no translucent rectangular haze
```

## Processing

- Generated source: `1024x1536` RGB PNG.
- The border key sampled as `#fb02f9`; the installed chroma helper applied a
  soft matte and magenta despill and retained the full RGBA alpha source.
- The visible subject was trimmed, aspect-fit to `224x352`, centered on an exact
  transparent `256x384` runtime canvas, and validated with transparent corners.
