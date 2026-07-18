# Scrap Roost Dodge Trial Background

- Tool: built-in image generation (`gpt-image-2` path)
- Date: 2026-07-19
- Use: `res://scenes/areas/scrap_roost_dodge_trial.tscn`
- Source: `scrap_roost_dodge_trial_background_imagegen_20260719.png`
- Runtime: `../scrap_roost_dodge_trial_background_1280x720.png`

## Prompt

Create a production-quality `16:9` hand-painted side-view Scrap Roost exhaust
trial chamber: a safe lower-left entry lane, central patched-metal floor exhaust
trench, low overhead scrap-beam ceiling, and clear far-right mechanical exit
frame. Use layered ruined masonry, welded panels, pipes, cables and distant
smokestacks with cool blue-grey shadows and restrained amber dawn work lights.
Keep the lower gameplay lane readable and reserve space for separate animated
player and steam-hazard layers. No characters, enemies, UI, text, logos,
watermark, tutorial arrows, baked steam plume, hazard effects, closed gate leaf,
collision guides, boss framing, dominant purple or foreground occlusion.

## Processing

The generated `1672x941` opaque RGB source was resized with `sips` to the exact
`1280x720` runtime texture. No alpha processing was required. The existing
image-generated Old Factory steam-vent SpriteFrames provide the separate
runtime `safe`, `warning` and `active` animation layers.
