# Crown Warden Wall Climb Core Generation Record

- Date: 2026-07-13
- Mode: built-in image generation
- Use: Story147 Boss4 `wall_climb` one-shot reward source and reveal pulse
- Runtime destination:
  `assets/environment/crown_warden_reward/prop_crown_warden_wall_climb_core_256x256.png`

## Exact Prompt

```text
Use case: stylized-concept
Asset type: 2D side-scrolling action game ability reward prop, isolated sprite source
Primary request: Create one compact mechanical Crown Core that appears after defeating the Crown Warden and represents the Wall Climb ability.
Subject: A strong owl-crown silhouette wrapped around a magnetic climbing gyroscope core; three curved crown talons point upward, a central cat-eye-shaped golden lens, small cyan magnetic arcs and concentric brass-steel rings. The object must look collectible, powered, and about to rise toward the player.
Style/medium: detailed hand-painted pixel-art inspired game prop with crisp chunky shapes, matching a dark industrial post-apocalyptic mechanical observatory; readable at 64x64 after downscaling.
Composition/framing: single centered object, front three-quarter view, fully contained with generous even padding, no floor.
Lighting/mood: rare victory reward, warm cat-eye gold ownership light against cool cyan magnetic energy, strong silhouette.
Color palette: steel charcoal, aged brass, restrained rust, cat-eye gold #ECC94B, cyan-blue magnetic light. Do not use magenta in the subject.
Scene/backdrop: perfectly flat solid #ff00ff chroma-key background for background removal.
Constraints: the background must be one uniform #ff00ff with no gradients, texture, reflections, shadows, floor plane, bloom spill, vignette, or lighting variation. Crisp opaque object edges. No cast shadow, contact shadow, reflection, particles detached far from the object, text, letters, numbers, icon border, UI panel, watermark, character, animal body, or environment.
Avoid: photorealism, soft fur, feathers with hair-like wisps, transparent glass, smoke, blur, tiny unreadable filigree, square crate shape, plain orb.
```

## Processing

1. Retained built-in source as opaque sRGB `1254x1254` PNG.
2. Sampled the border key as `#fa03eb` and ran the installed imagegen
   `remove_chroma_key.py` helper with soft matte, thresholds `12/220` and
   despill. Retained the full-resolution sRGBA alpha intermediate.
3. Trimmed transparent borders, fit the subject within `224x224`, centered it
   on a transparent `256x256` canvas and retained nearest-filtered runtime art.

## Validation

- Source: `1254x1254`, sRGB.
- Alpha intermediate: `1254x1254`, sRGBA, transparent corner.
- Runtime: `256x256`, sRGBA, transparent corner, used rect
  `184x224+36+16`.
- The runtime object remains readable as a crown/eye/magnetic core at gameplay
  scale and contains no visible key-color background or primitive placeholder.
