# Sluice Matriarch Phase Transition Sheet -- Image Generation Record

Date: 2026-07-18
Mode: built-in image generation with identity reference
Use: Story174 Phase II invulnerable transition

## Reference

`assets/characters/sluice_matriarch/source/sluice_matriarch_geyser_recovery_runtime_preview_20260718.png`
was supplied as an identity, proportion, palette, armor, and facing reference.
It was not used as a runtime source.

## Prompt

```text
Use case: stylized-concept
Asset type: production 2D pixel-art boss animation sprite sheet for Godot 4.7
Input image: identity reference only; preserve the same Sluice Matriarch industrial leech anatomy, proportions, palette, armor construction, and right-facing orientation.
Primary request: create a strict single-row, exactly three-column chronological loop for the Sluice Matriarch Phase II pressure transformation. Frame 1: planted low body compresses while steel clamps lock and cyan seams begin to pulse. Frame 2: cracked ceramic pressure plates lift slightly, pale pressure sacs inflate, cyan-white energy intensifies through the body. Frame 3: fully charged planted silhouette, clamps engaged, cyan seams and inner mouth core at peak, designed to flow seamlessly back into frame 1.
Style/medium: crisp hard-edged hand-authored pixel art matching the reference, readable at 192x192 per frame, no soft painting, no 3D render.
Composition/framing: three equal cells in one horizontal row; one complete full-body subject centered in every cell; consistent scale, pivot, body length, ground baseline, and generous padding; no crop, overlap, separator, panel border, or extra frame.
Scene/backdrop: perfectly flat uniform solid #ff00ff chroma-key background, identical everywhere, no floor plane.
Color palette: wet charcoal-purple body, cracked pale ceramic, rust-orange industrial hardware, cyan mutation seams, restrained existing signal-red spines. The transition must read as safe invulnerable power-up, not an imminent attack.
Constraints: exactly three poses; preserve giant mutated industrial leech identity; every frame right-facing; no movement translation; no projectile, pressure lance, geyser, warning ring, hit effect, injury collapse, death pose, character duplication, text, UI, watermark, cast shadow, contact shadow, glow bleeding into the background, gradients, texture, reflections, or lighting variation in the background. Do not use #ff00ff inside the subject.
```

## Retained Files

- Generated RGB source:
  `sluice_matriarch_phase_transition_sheet_imagegen_20260718.png`
- Alpha source:
  `sluice_matriarch_phase_transition_sheet_alpha_20260718.png`
- Runtime preview:
  `sluice_matriarch_phase_transition_runtime_preview_20260718.png`
- Runtime frames:
  `../phase_transition/sluice_matriarch_phase_transition_000.png` through
  `_002.png`

## Processing

- Generated source: `2172x724` RGB, exactly three `724x724` cells.
- Sampled chroma key: `#fb04fa`.
- Alpha removal: border auto-key, soft matte, despill, transparent threshold
  `12`, opaque threshold `220`.
- Trimmed source bounds: `616x259`, `595x309`, and `632x330`.
- Shared nearest-neighbor scale: `29.746835443%`, derived from the maximum
  `632px` width fitting the `188px` subject budget.
- Runtime subjects: `183x77`, `177x92`, and `188x98`, centered horizontally and
  aligned to the same bottom baseline on transparent `192x192` sRGBA canvases.
- Every frame has a transparent top-left pixel and a unique SHA-256 hash.

## Hashes

- RGB source:
  `90737d62266e19e562125adec33861033ddb2e7b7747b37ca0a89504abd88fad`
- Alpha source:
  `6647b997e5bc1250fb641782dcdbdb17971cee7481a91e40336b986c68e3db77`
- Runtime preview:
  `25af291b0ed6784984bfd2752a5f571e672e4cbfd870cb0f7ed902f64b290a86`
- Frames: `fc30e4e310a89f546de009e5fd2a132b60dab71a9ef6253b2e8c2ce77ba759e4`,
  `602d0546fee5f43f388e9be83590b933255ffa78bef4c08fc4532a5303afdd1a`,
  `c268a667e676953e77816a86d64755d35e742eb2f21c3f4ae22b1a38dbe6314f`.
