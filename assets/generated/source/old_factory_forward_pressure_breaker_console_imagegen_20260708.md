# Old Factory Forward Pressure Breaker Console Image Generation

Date: 2026-07-08
Tool: built-in image generation
Story: `production/epics/player-abilities/story-079-old-factory-lower-deck-forward-pressure-breaker.md`

## Runtime Asset

- `res://assets/environment/old_factory_forward_pressure_breaker/env_old_factory_forward_pressure_breaker_console_256.png`

## Preserved Sources

- Chroma-key source:
  `assets/generated/source/old_factory_forward_pressure_breaker_console_imagegen_20260708.png`
- Alpha-matted source:
  `assets/generated/source/old_factory_forward_pressure_breaker_console_alpha_20260708.png`
- Local processing scratch:
  `tmp/imagegen/old_factory_forward_pressure_breaker_console_chroma.png`
  and `tmp/imagegen/old_factory_forward_pressure_breaker_console_alpha_raw.png`

## Prompt

Use case: stylized-concept

Asset type: Godot 2D side-scrolling ACT environment prop, 256x256 transparent
PNG source via chroma-key removal.

Primary request: compact side-view scrap-metal pressure breaker console for an
abandoned factory route.

Subject: small steel pressure breaker stand with rugged casing, cyan analog
pressure gauge, yellow-black warning stripes, red cut cable details, bolts,
worn metal panels, readable silhouette at gameplay scale.

Style/medium: stylized hand-painted 2D game asset, slightly painterly
pixel-adjacent edges, no realism photo texture, side-view orthographic prop.

Composition/framing: centered full object, generous padding, 3/4 side view
suitable for a platformer, no floor plane.

Lighting/mood: neutral game asset lighting, crisp edges.

Constraints: subject on a perfectly flat solid `#00ff00` chroma-key background
for background removal. Background must be one uniform color with no shadows,
gradients, texture, reflections, floor plane, or lighting variation. Keep the
subject fully separated from the background with crisp edges and generous
padding. Do not use `#00ff00` anywhere in the subject. No cast shadow, contact
shadow, reflection, watermark, or text.

Avoid: letters, numbers, logos, UI labels, green subject details, smoke,
transparency effects, soft shadows, cropped object.

## Processing

The generated chroma-key PNG was processed with the local
`remove_chroma_key.py` helper using border auto-key sampling, soft matte, and
despill. The resulting alpha image was resized to `256x256` RGBA for Godot.

Validation: final runtime PNG is RGBA, `256x256`, with transparent corners and
opaque subject coverage.
