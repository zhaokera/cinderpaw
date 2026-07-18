# Sewer Dash Route Background Generation

- Generator: built-in image generation
- Date: 2026-07-19
- Final source: `sewer_dash_route_background_imagegen_20260719.png`
- Runtime: `../sewer_dash_route_background_1280x720.png`
- Purpose: opaque environment plate behind separate Godot character, collision,
  animated hazard, reset, exit and HUD layers.

## Initial Prompt

```text
Create a single 16:9 opaque raster background for a polished 2D side-scrolling action game, shown in strict orthographic side view. Scene: an abandoned storm sewer route bridging a ruined commercial street into an old industrial factory. Finely painted pixel-art aesthetic with crisp readable shapes, restrained texture, no photorealism and no perspective floor. Composition must support gameplay: the left 35 percent is a broad safe run-up platform with its walkable top visually aligned around 67 percent of image height; the center has one unmistakable dark floor gap about 8 percent of image width, with a low overhead drainage pipe/ceiling that visually prevents jumping; the right side has a wide stable landing platform slightly lower than the left, then a circular riveted industrial return hatch near the far right. The gap must be real open negative space down into a deep drain, with no bridge, grate, debris, pipe, reflection, ledge, or painted surface that looks walkable across it. Materials transition from cracked concrete and wet charcoal brick on the left, through oxidized copper drainage pipes, to riveted steel on the right. Palette: blue-black steel grey, wet charcoal, oxidized copper and dark rust; small amber lights only on safe landing edges and a subtle cyan-blue guide light at the far-right hatch. Keep the player gameplay band clear and high contrast. No characters, enemies, creatures, text, letters, numbers, UI, icons, arrows, signs, tutorial prompts, red warning overlays, toxic green liquid, foreground occlusion, collision lines, outlines, borders, frames, logos, or watermarks. Full-bleed environment background, camera fixed exactly side-on, readable at 1280x720.
```

## Edit 1 Prompt

```text
Edit this existing 16:9 sewer side-scroller background while preserving its exact art style, lighting, materials, circular hatch, orthographic camera, left run-up, right landing, low overhead pipe, and all other composition. Change only the central floor opening: narrow the real open gap to approximately 7 percent of the full image width by extending the left platform edge to the right and the right platform edge to the left. Keep the gap centered around the current opening, clearly open and dark, with vertical platform lips and absolutely no bridge, grate, debris, pipe, reflection, or false walkable surface across it. The left platform remains slightly higher than the right. Preserve a clear gameplay band and the low overhead drainage pipe that blocks a normal jump. No characters, text, UI, symbols, arrows, signs, warning overlays, foreground objects, collision lines, borders, logos, or watermarks. Output one full-bleed opaque RGB image.
```

## Edit 2 Prompt

```text
Make one surgical geometry edit to this exact sewer side-view image. Preserve everything else exactly: style, camera, pipes, walls, lighting, hatch, platform heights and colors. Narrow the central open floor gap much more: the dark opening between the two inner vertical platform lips must be exactly about ONE TWENTIETH (5 percent) of the full canvas width. Extend both solid platform tops inward until the two amber edge lamps are only that narrow distance apart. Keep the opening centered, truly empty and vertically deep, with crisp visible platform lips. Do not add any bridge, grate, plank, pipe, debris, reflection, or fake walkable pixels across it. Keep the low overhead pipe. No characters, text, UI, signs, arrows, symbols, collision marks, borders, logos, or watermarks. One full-bleed opaque RGB image.
```

## Final Edit Prompt

```text
Final surgical gameplay-geometry edit of this exact sewer side-view background. Preserve the entire image and art style except for the central crossing geometry. Set the dark floor gap between the two platform lips to about 7 percent of the full canvas width (roughly 90 pixels when resized to 1280 wide), centered in the same place. Add or lower one thick horizontal riveted drainage pipe/brick lintel directly across the central gap so its bottom edge sits only about 56 pixels above the left platform walking surface; this must read as a low solid ceiling with just enough standing clearance, clearly preventing a normal jump while allowing a horizontal dash. The low ceiling should span about 20 percent of the canvas around the gap and connect naturally into the existing sewer pipework. Keep the right landing slightly lower than the left and retain both amber edge lamps and the far-right circular hatch. The gap remains truly open below with no bridge, grate, plank, debris, pipe, reflection, or fake walkable surface. No characters, text, UI, signs, arrows, symbols, collision marks, borders, logos, or watermarks. Strict orthographic side view, full-bleed opaque RGB.
```

## Selection And Runtime Alignment

The final selected generated output was normalized from opaque RGB `1672x941`
to opaque RGB `1280x720`. Its visible opening measures approximately `92px` at
runtime, matching authored platform edges `588..680`. Image generation did not
lower the overhead pipe to the requested gameplay clearance, so the Godot scene
uses the existing visible four-frame exhaust animation as the physical jump
rejection volume. No hidden ceiling or bridge was added.
