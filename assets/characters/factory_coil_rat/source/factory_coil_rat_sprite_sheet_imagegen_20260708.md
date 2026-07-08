# Factory Coil Rat Sprite Sheet Generation

Date: 2026-07-08
Tool: Built-in image generation + local chroma-key alpha removal
Runtime target: `res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`
Used by: Story081 Old Factory Lower Deck Forward Pressure Coil Rat Breakthrough

## Prompt

Pixel-art 2D side-view enemy sprite sheet for a Godot 4.7 action platformer,
laid out as six animation rows with three frames per row: `idle`, `run`,
`attack_tell`, `attack`, `hurt`, and `death`.

Character: Factory Coil Rat, an Old Factory mechanical rat variant with a low
rat body, heavy rusted scrap armor, exposed copper tail cable, raised
back-mounted electric coil/capacitor pack, small glowing cyan arcs, sharp
triangular warning fins, and red danger triangle accents only during
`attack_tell`. The silhouette must differ from the existing Factory Spark Rat:
taller coil profile, jagged vertical wires, heavier front shoulders, and
readable at small gameplay scale.

Style: crisp pixel art, Cinderpaw art direction, cute-danger contrast,
rust-orange and steel-gray factory materials, cyan electric rim light, signal
red only for immediate threat, sparse cat-eye gold as tiny reflected highlights.

Composition: isolated sprites on a flat #00ff00 chroma-key background,
consistent scale and pivot, same feet contact point, no environment, no UI,
no text, no shadows, no cropped tail or coil. Each frame should fit cleanly when
sliced into a 96x96 transparent PNG.

Avoid: photorealistic rendering, painterly blur, 3D render, background scene,
floor shadow, labels, UI, cropped tail, cropped coil, inconsistent scale, extra
limbs, different character per frame, or green subject details.

## Processing Notes

- Source retained:
  `assets/characters/factory_coil_rat/source/factory_coil_rat_sprite_sheet_imagegen_20260708.png`
- Alpha source retained:
  `assets/characters/factory_coil_rat/source/factory_coil_rat_sprite_sheet_alpha_20260708.png`
- Preview retained:
  `assets/characters/factory_coil_rat/source/factory_coil_rat_frames_preview_20260708.png`
- The source was generated on a flat green chroma key, alpha-matted locally,
  sliced as 3 columns x 6 rows, cropped around non-transparent pixels, scaled
  into 96x96 RGBA frames, and written to
  `assets/characters/factory_coil_rat/<animation>/`.
