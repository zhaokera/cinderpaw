# Neon Relay Spire Props Image Generation Record

- Generated: 2026-07-12
- Tool: built-in image generation
- Use case: `stylized-concept`
- Story: `production/epics/player-abilities/story-138-neon-rooftops-relay-spire-savepoint-traverse.md`
- RGB source dimensions: `1693x929`
- RGB source: `neon_relay_spire_props_imagegen_20260712.png`
- Alpha source: `neon_relay_spire_props_alpha_20260712.png`
- Runtime outputs:
  - `assets/environment/neon_rooftops/prop_neon_relay_spire_roost_256x256.png`
  - `assets/environment/neon_rooftops/prop_neon_magnetic_relay_spire_256x512.png`
  - `assets/environment/neon_rooftops/prop_neon_tower_approach_beacon_256x384.png`

## Prompt

Create exactly three isolated full-object side-view Neon Rooftops props on one
perfectly uniform flat `#ff00ff` chroma-key sheet. Left: a low safe cat-nest
Relay Spire Roost built from steel and woven cables with warm amber paw core,
cyan seams, and violet lamps. Center: a tall narrow magnetic climb panel with
dark riveted steel, cyan grip bars, claw wear, antenna ribs, and cat-ear crown.
Right: a Tower Approach endpoint beacon with weathered pedestal, moonlight-blue
cat-eye signal core, cyan route light, amber details, and stable base. Match the
generated rooftop background. Keep clean separation and padding. No characters,
enemy, text, UI, logo, watermark, floor, shadow, reflection, haze, extra props,
overlap, crop, grid, transparency, or magenta inside objects.

## Processing

- The installed imagegen helper auto-sampled border key `#fa03e2`, then applied
  soft matte thresholds `12/220`, despill, one-pixel edge contraction, and
  `0.25` edge feathering. The retained RGBA sheet has `1,120,024` transparent
  and `60,163` partially transparent pixels out of `1,572,797`.
- Source thirds were `564`, `564`, and `565` pixels wide. Alpha-trimmed bounds
  were `477x293`, `338x801`, and `399x592` before proportional normalization.
- The objects were centered with safe transparent padding on exact RGBA
  `256x256`, `256x512`, and `256x384` runtime canvases.
- Godot 4.7 imported RGB source, alpha source, and all runtime PNGs.
