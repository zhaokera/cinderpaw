# Cinderpaw Title Idle Image Generation Record

- Date: 2026-07-18
- Tool: built-in image generation, stylized-concept
- Identity reference: `assets/generated/cinderpaw_player.png`
- Chroma source: `cinderpaw_title_idle_sheet_imagegen_20260718.png`
- Alpha source: `cinderpaw_title_idle_sheet_alpha_20260718.png`
- Runtime frames: `../title_idle/cinderpaw_title_idle_000.png` through `_005.png`
- Runtime resource: `../cinderpaw_title_sprite_frames.tres`
- Chroma source SHA-256: `bc0dca18d473ea36ba6885940b925b89bb732e4318d65e5004748d4a5bfaaeba`
- Alpha source SHA-256: `2a72c691bd7788706ee03dd64b6a84450f88e04b8c827fd1dc9eb85c22e70317`

## Exact Prompt

Use case: stylized-concept.

Asset type: production sprite sheet for a Godot 2D title-screen
AnimatedSprite2D.

Input image: character identity reference. Preserve Cinderpaw's exact
black-and-orange fur markings, amber eye, teal torn scarf, patched leather/metal
armor, proportions, silhouette, and hand-painted action-game rendering.

Primary request: Create exactly six sequential full-body seated idle animation
frames arranged as a strict 3 columns by 2 rows sprite sheet. In every frame
Cinderpaw sits upright in right-facing side profile on the same invisible ground
line, looking alert at the cold/warm wasteland boundary. Motion must be subtle
and coherent: frames 1-2 neutral breathing; frames 3-4 one tail-tip twitch;
frames 5-6 one ear rotates then settles. Keep torso, paws, head location, scale,
camera, baseline, and visual center identical across all six cells so there is
no animation jitter.

Sheet constraints: every cell has equal dimensions; one complete character per
cell; generous identical padding; character never touches a cell edge; no crop;
no overlap between cells; no duplicate limbs; no grid labels, numbers, guides,
separators, text, UI, shadow, floor, scenery, particles, watermark, or extra
objects.

Background: perfectly flat uniform solid `#FF00FF` chroma key across the entire
sheet, with no gradient, texture, lighting variation, reflection, contact
shadow, or cast shadow. Do not use magenta anywhere in the character.

Style: same painterly high-contrast side-scrolling action-game sprite style as
the reference, crisp readable silhouette, production-ready frame consistency.

## Processing

- Built-in generation returned exact RGB `1536x1024`, a `3x2` grid of
  `512x512` cells.
- The project imagegen helper sampled border key `#f505f2`, then applied soft
  matte, thresholds `12/180`, and despill to a retained sRGBA alpha sheet.
- Connected-component isolation removed cross-cell tail fragments. Each
  complete character component was placed on a transparent `512x512` canvas
  with common right edge `x=470` and baseline `y=480`.
- All six runtime hashes are unique. Godot 4.7 imported the sources and frames;
  `cinderpaw_title_sprite_frames.tres` exposes looping six-frame `title_idle`.
