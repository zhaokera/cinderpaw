# Factory Aerial Breach Floor Image Generation Record

- Date: 2026-07-11
- Tool: built-in image generation
- Purpose: Story130 `aerial_attack` breakable floor gate and Underground return
- Generated RGB source:
  `assets/generated/source/factory_aerial_breach_floor_imagegen_20260711.png`
- Retained alpha source:
  `assets/generated/source/factory_aerial_breach_floor_alpha_20260711.png`
- Runtime asset:
  `assets/environment/underground_passage/prop_factory_aerial_breach_floor_384x160.png`
- Source dimensions: `1774x887`, opaque RGB
- Alpha source dimensions: `1774x887`, RGBA
- Runtime dimensions: `384x160`, transparent RGBA

## Prompt Intent

Generate one isolated wide industrial floor hatch on flat `#ff00ff`: corroded
steel, bolts, clamps, branching cracks, cyan light leaking through fissures,
amber lamps, and downward claw chevrons. It must read as a floor that an aerial
strike can shatter. Exclude characters, creatures, text, logos, UI, scene
background, cast shadow, and multiple variants.

## Processing

The border-sampled key color was `#fb03f9`. The standard chroma-key script used
soft matte thresholds `12/220` plus despill. The alpha source was trimmed,
normalized to a `364x104` visible object, and centered on a transparent
`384x160` runtime canvas.
