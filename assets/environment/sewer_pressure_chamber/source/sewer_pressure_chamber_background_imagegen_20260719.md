# Sewer Pressure Chamber Background Generation

- Generator: built-in image generation
- Date: 2026-07-19
- Final source: `sewer_pressure_chamber_background_imagegen_20260719.png`
- Runtime: `../sewer_pressure_chamber_background_1280x720.png`
- Purpose: opaque second Sewer room behind separate Godot collision, Player,
  enemy, seal, pressure vent, reward cache and HUD nodes.

## Final Prompt

```text
Use case: stylized-concept
Asset type: Godot 4.7 side-scrolling 2D ACT environment background plate
Primary request: Create a production-ready second Sewer combat chamber for Cinderpaw, continuing the visual language of a rain-soaked industrial sewer beneath a neon cat city.
Scene/backdrop: strict side-view underground pressure-regulation chamber, one continuous clearly walkable floor spanning the entire bottom third, entrance pipe corridor visible at far left, broad unobstructed combat lane in the middle, deeper wastewater machinery and a clearly unreachable high maintenance ledge suggesting a future double-jump route at upper right.
Style/medium: polished hand-painted 2D game environment, crisp readable silhouettes, detailed but gameplay-readable, no photorealism, no pixel art.
Composition/framing: exact 16:9 wide composition intended for 1280x720; camera perpendicular to the play plane; player scale approximately 90 px tall; keep the combat lane clear from x=180 to x=980; reserve the far-right foreground for separate Godot seal-gate and reward-cache nodes.
Lighting/mood: damp, dangerous, readable; steel-blue ambient light, rusted copper and amber work lights, restrained toxic green wastewater accents, cyan only as distant route guidance.
Materials/textures: wet concrete, oxidized pipes, riveted steel, cracked masonry, shallow runoff channels, subtle reflections.
Constraints: opaque RGB background; no transparency; no characters, enemies, creatures, reward chest, gate, steam plume, VFX, UI, text, logos, watermark, baked collision markers, floating platforms, foreground objects that block the combat lane, or pure color rectangles. Do not duplicate identical pipe modules in a grid. The floor top should read consistently near 64% of image height for Godot collision alignment.
```

## Selection And Processing

The selected built-in output was opaque RGB `1672x941`. It was normalized with
`sips` to exact opaque RGB `1280x720` and imported by Godot 4.7. The plate does
not authorize gameplay: `PressureChamberFloor`, `PressureRoomSeal`,
`PressureBackflowHazard`, `SewerSluiceLeech` and `SewerPressureCache` remain
separate runtime nodes.
