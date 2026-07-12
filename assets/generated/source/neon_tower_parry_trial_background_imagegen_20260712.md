# Neon Tower Parry Trial Background Generation Record

- Date: 2026-07-12
- Generator: built-in image generation
- Use case: stylized-concept
- Source: `neon_tower_parry_trial_background_imagegen_20260712.png`
- Source dimensions: opaque RGB `1672x941`
- Runtime: `res://assets/environment/neon_rooftops/env_neon_tower_parry_trial_1280x720.png`
- Runtime dimensions: opaque RGB `1280x720`

## Prompt

Create the fourth Neon Rooftops viewport at the exterior threshold of Central
Tower as a polished high-detail side-view pixel-art ACT platformer background.
Use a post-industrial rooftop at night with a readable horizontal roof deck,
safe entry at left, open laser-trial lane in the center, and the immense tower
facade at far right. Add distant ruined city silhouettes, antennae, cables,
vents, rain-dark steel, cyan moonlight, restrained magenta signs, and amber
maintenance lamps. Keep the collision floor around y `560`, preserve a clear
player silhouette lane, and omit every interactive prop: no characters, UI,
text, laser beams, pylons, freestanding gate, beacon, savepoint, collectible,
logo, watermark, blur, or placeholder geometry.

## Processing

The retained source was center-filled and cropped to exact runtime dimensions:

```bash
magick neon_tower_parry_trial_background_imagegen_20260712.png \
  -resize '1280x720^' -gravity center -extent 1280x720 \
  -colorspace sRGB env_neon_tower_parry_trial_1280x720.png
```

Visual inspection confirmed an opaque frame, uninterrupted gameplay floor,
clear tower silhouette, no baked interactive gate, no text, and no visible
placeholder blocks.
