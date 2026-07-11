# Underground Deep Cistern Image Generation Record

- Date: 2026-07-11
- Tool: built-in image generation
- Use case: `stylized-concept`
- Purpose: Story133 fourth Underground viewport and Stalker combat arena
- Generated source:
  `assets/generated/source/underground_deep_cistern_imagegen_20260711.png`
- Runtime asset:
  `assets/environment/underground_passage/env_underground_deep_cistern_1280x720.png`
- Source dimensions: `1672x941`, opaque RGB
- Runtime dimensions: `1280x720`, opaque RGB

## Prompt

Create one polished opaque 16:9 deep Underground cistern combat arena for a 2D
side-scrolling action game. Use wet dark brick, oxidized iron, large pressure
tanks, riveted pipes, cracked masonry, iron grates, short chains, cyan mineral
seepage, restrained amber maintenance lamps, and small toxic-green reflections.
Keep one continuous flat stone-and-metal floor across the lower gameplay lane,
with a spacious central arena and visual depth only behind the lane. No pits,
stairs, foreground collision, characters, creatures, blocking doors, text, UI,
logos, watermarks, borders, fog, or empty canvas.

## Processing

The opaque source was center-cropped to exact 16:9 and downsampled with Pillow
to an RGB `1280x720` runtime PNG. Godot 4.7 imported both source and runtime
files. The authored collision remains a separate continuous `StaticBody2D` so
the visible floor and gameplay floor agree.
