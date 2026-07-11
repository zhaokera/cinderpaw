# Neon Signal Roof Props Image Generation Record

- Generated: 2026-07-12
- Tool: built-in image generation
- Use case: `stylized-concept`
- Story: `production/epics/player-abilities/story-137-neon-rooftops-signal-rat-ambush.md`
- RGB source: `neon_signal_roof_props_imagegen_20260712.png`
- Alpha source: `neon_signal_roof_props_alpha_20260712.png`
- Runtime outputs:
  - `assets/environment/neon_rooftops/prop_neon_signal_seal_256x384.png`
  - `assets/environment/neon_rooftops/prop_neon_signal_cache_256x256.png`

## Prompt

Create exactly two isolated full-object side-view Neon Rooftops props on one
perfectly uniform flat `#ff00ff` chroma-key sheet. Left: a tall retractable
signal-seal gate with weathered dark steel, cyan edge conduits, a red locked
core, antenna details, and a grounded industrial base. Right: a compact rooftop
signal cache with reinforced steel casing, violet relay glow, cyan seams, a
cat-paw latch, and a readable reward core. Match the generated rooftop's rich
industrial game art. Center the objects separately with generous padding. No
characters, enemies, text, UI, logos, watermark, floor, shadow, reflections,
haze, extra props, overlap, crop, or key color inside either object.

## Processing

- Built-in generation produced an RGB `1624x969` two-prop sheet.
- The installed imagegen helper auto-sampled border key `#fa02fa`, then used
  soft matte thresholds `12/220`, despill, one-pixel edge contraction, and
  `0.25` edge feathering to retain a full-sheet RGBA alpha source.
- Equal halves were sliced, alpha-trimmed, proportionally fit, and centered on
  transparent `256x384` and `256x256` runtime canvases.
- Godot 4.7 imported the RGB source, alpha source, and both runtime PNGs.
