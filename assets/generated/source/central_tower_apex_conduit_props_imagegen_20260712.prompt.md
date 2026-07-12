# Central Tower Apex Conduit Props Prompt

**Generator**: Built-in image generation
**Date**: 2026-07-12
**Source layout**: strict `3x2`, `512x512` cells on `#ff00ff`

```text
Use case: stylized-concept
Asset type: production 2D side-scrolling ACT game prop and VFX sprite source sheet for local chroma-key extraction
Primary request: one strict 3-column by 2-row contact sheet containing six isolated Central Tower apex conduit assets, exactly one asset centered in each equal cell
Scene/backdrop: every cell uses the same perfectly flat solid #ff00ff chroma-key background for removal; no floor plane
Subject: top-left compact mechanical cat-shaped Apex Roost with cyan-white core and small amber activation ring; top-center tall climbable magnetic spine with black steel rails, cyan current strips and obvious grip ridges; top-right wall-mounted purge emitter with ceramic coils and restrained red warning lamp; bottom-left compact Apex Approach beacon with cyan vertical core and amber completion halo; bottom-center narrow full-height ionized purge energy wall with bright red-orange leading edge, translucent cyan-white electrical interior and a crisp vertical silhouette; bottom-right small triangular warning pulse light with amber-red concentric energy ticks
Style/medium: polished hand-painted pixel-art-inspired 2D game sprites, crisp readable silhouettes, industrial cyberpunk feline action game, orthographic side view
Composition/framing: exact 3x2 equal grid, one complete isolated object per cell, generous padding, no object touches cell edges, no overlap between cells, tall assets remain fully visible from top to bottom
Lighting/mood: self-lit cyan machinery, restrained amber safety, red only for danger; neutral object lighting
Color palette: charcoal black steel, cool gray, cyan, white, amber, red; do not use #ff00ff anywhere in any subject
Materials/textures: worn steel, ceramic insulators, cables, electrical plasma; no realistic smoke or soft shadows
Constraints: the background in every cell must be one uniform #ff00ff with no shadows, gradients, texture, reflections, grid lines, borders, floor, cast shadows or lighting variation; no text, no letters, no numbers, no characters, no enemies, no boss, no logos, no watermark; each asset must have crisp closed edges suitable for alpha extraction; exact 3 columns and 2 rows
```

## Processing

- Generated source: exact `1536x1024` PNG with six equal `512x512` cells.
- The installed imagegen chroma-key helper sampled the border, applied a soft
  matte and magenta despill, and retained the full alpha source.
- Selected cells were trimmed, aspect-fit, and centered into exact transparent
  runtime canvases: Roost `256x256`, magnetic spine `256x512`, purge emitter
  `256x384`, beacon `256x384`, and purge wall `192x640`.
- The sixth warning-light cell remains source-only; runtime warning uses the
  purge wall's authored pre-motion state to keep the slice bounded.
