# Crown Warden Victory Recall Image Generation Record

> **Story**: 148
> **Generator**: built-in image generation
> **Date**: 2026-07-13

## Prompt

```text
Use case: stylized-concept
Asset type: isolated 2D action-platformer environment prop for Godot, a post-boss fast-recall transmitter
Primary request: create one compact Crown Observatory victory recall transmitter, an ornate but readable mechanical device that lets the cat warrior return to its home roost
Scene/backdrop: perfectly flat uniform solid #FF00FF chroma-key background for later removal; no floor plane
Subject: one narrow vertical owl-crown transmitter, symmetrical brass and dark steel casing, crown-shaped top, restrained cyan concentric signal rings around a central mechanism, one small cat-eye gold status lens, sturdy compact base, visually distinct from a doorway and from the Crown Core reward
Style/medium: crisp authored pixel-art inspired 2D action game asset, 16-32bit visual language, sharp chunky silhouette, polished production game art, cute-danger contrast, no smoothing
Composition/framing: single centered full object, orthographic side-view, object entirely inside frame with 12 percent padding, tall 2:3 silhouette, no crop
Lighting/mood: restrained cool observatory light with readable brass highlights, no cast shadow
Color palette: dark steel-blue, aged brass, cyan signal light, sparse cat-eye gold; do not use magenta in the object
Materials/textures: mechanical plates, ceramic insulators, compact antenna rings, clean readable pixel clusters
Constraints: background must be one perfectly uniform #FF00FF with no gradient, texture, shadow, reflection or lighting variation; crisp fully separated edges; no floor, no scenery, no character, no enemy, no UI, no letters, no symbols that resemble text, no watermark, no duplicate objects, no transparent-looking glass, no smoke, no particles extending into the padding
```

## Processing

- Retained generated keyed source: exact `1024x1536` sRGB PNG.
- Sampled border key: `#f903ec`.
- Ran the shared imagegen chroma-key helper with soft matte, transparent
  threshold `12`, opaque threshold `220` and despill.
- Retained alpha intermediate: `1,140,658 / 1,572,864` fully transparent
  pixels and `13,877` partially transparent edge pixels.
- Trimmed, nearest-neighbor fit inside `224x344`, centered on an exact
  transparent sRGBA `256x384` canvas.
- Runtime corner pixel: `srgba(0,0,0,0)`.

## Outputs

- `crown_warden_victory_recall_imagegen_20260713.png`
- `crown_warden_victory_recall_alpha_20260713.png`
- `../prop_crown_warden_victory_recall_256x384.png`
