# Central Tower Threshold Props Image Generation Record

- Generated: 2026-07-12
- Tool: built-in image generation with local chroma-key removal
- Use case: `stylized-concept`
- Purpose: Story140 inner seal, Threshold Roost, and guard dock
- Reference: `neon_tower_parry_trial_props_imagegen_20260712.png`
- Chroma source dimensions: `1774x887`, opaque RGB
- Alpha source dimensions: `1774x887`, transparent RGBA

## Prompt Summary

Generate exactly three isolated pixel-art props on uniform `#ff00ff`: a tall
closed cat-ear inner security seal with a signal-red lock, a safe compact
Threshold Roost with cat-eye gold and cyan lights, and a low guard docking
plinth. Preserve wide spacing, opaque silhouettes, and no shadows, floor, text,
characters, particles, rewards, or baked prompts.

## Outputs

- Chroma source: `central_tower_threshold_props_imagegen_20260712.png`
- Alpha source: `central_tower_threshold_props_alpha_20260712.png`
- Runtime seal: `../../environment/central_tower/prop_central_tower_inner_seal_384x512.png`
- Runtime roost: `../../environment/central_tower/prop_central_tower_threshold_roost_256x256.png`
- Runtime dock: `../../environment/central_tower/prop_central_tower_guard_dock_256x256.png`

## Processing

- The helper sampled border key `#f904eb`, applied soft matte thresholds
  `12/220`, despill, one-pixel edge contraction, and `0.25` feathering.
- Runtime props were isolated, trimmed, proportionally fitted, and centered on
  exact transparent canvases with clear corners.
