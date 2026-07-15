# Asset Spec: Boss Phase Overlay Readability

> **Story**: Combat Presentation 019
> **Generation policy**: built-in image generation edit, retained keyed source,
> deterministic alpha processing, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Readable Boss phase overlay | Transparent sRGBA `1280x720`; all visual mass stays near the outer border; exact center `Rect2i(320, 180, 640, 360)` has alpha `0`; nearest filtering | `res://assets/generated/combat_boss_phase_overlay_readable.png` |
| Retained generated source | Opaque `1672x941` source with flat green empty regions and no text/UI/watermark | `res://assets/generated/source/combat_boss_phase_overlay_readable_imagegen_20260714.png` |
| Alpha intermediate | `1672x941` chroma-keyed source retained before runtime normalization and center hard-clear | `res://assets/generated/combat_boss_phase_overlay_readable_alpha_raw.png` |

## Visual Direction

Preserve Story010's steel-blue/charcoal mechanical fragments, restrained
signal-red energy cracks, and sparse cat-eye-gold sparks, but move their visual
weight to the corners and outer edges. The overlay must announce a violent
phase change without hiding the player, Boss, attack lane, or HUD.

## Canonical Generation Prompt

The source was generated as an edit of
`assets/generated/combat_boss_phase_overlay.png` with this exact prompt:

```text
Use case: precise-object-edit
Asset type: Godot 4.7 pixel-art fullscreen Boss phase transition edge overlay
Primary request: Recompose the provided mechanical phase-explosion overlay into an edge-only frame. Remove the central red core, all central shards, all central cracks, and all visual mass from the middle 50% width by 50% height. Move the steel-blue mechanical fragments, sparse signal-red energy cracks, and very sparse cat-eye-gold sparks into the outer 25% border only.
Scene/backdrop: perfectly flat solid #00FF00 chroma-key background across every empty area, including the entire central safe area, for later transparency removal.
Style/medium: preserve the source's polished high-detail pixel-art style, hard mechanical silhouettes, steel-blue/charcoal metal, signal-red danger accents, sparse gold highlights.
Composition/framing: 16:9 landscape overlay; visual weight concentrated in corners and outer edges; the central rectangle must be completely empty and uninterrupted; no element may cross into the middle 50% width or middle 50% height safe rectangle.
Constraints: preserve the source visual identity; one edge frame only; no second inner frame; no background scenery; no character; no boss; no UI; no text; no logo; no watermark; no shadow or glow bleeding into the central safe rectangle; do not use #00FF00 in any fragment.
Avoid: central explosion, central focal object, radial burst through the middle, opaque black background, gradients in the key background, smoke, blur, bokeh.
```

## Processing And Import

1. Retain the generated `1672x941` keyed source unchanged.
2. Remove the sampled green key `#08f708` with soft matte, transparent threshold
   `16`, opaque threshold `180`, despill, and one-pixel edge contraction.
3. Resize to exact `1280x720` with nearest-compatible pixel geometry.
4. Replace alpha with a hard-zero rectangle at `320,180..959,539` so the center
   safety contract cannot depend on prompt compliance alone.
5. Import source, intermediate, and runtime PNG through Godot 4.7. Runtime uses
   the final PNG only and `TextureRect.TEXTURE_FILTER_NEAREST`.

The initial automatic border-key probe selected a near-black corner fragment and
was rejected. The explicit sampled green key produced the retained alpha
intermediate.

## Validation

- Final geometry: `1280x720`, 8-bit sRGBA `TrueColorAlpha`.
- Center alpha statistics: minimum `0`, maximum `0`, mean `0`.
- Runtime SHA-256:
  `e0bff6b66f8ff3ace83b03a068d79ebef49ff3b20543d8827d49b398d69f6dbf`.
- MCP screenshot and runtime diagnostics verify that the edge frame, gameplay
  actors, Phase II Boss HUD, player HUD, and weapon HUD are simultaneously
  visible.
