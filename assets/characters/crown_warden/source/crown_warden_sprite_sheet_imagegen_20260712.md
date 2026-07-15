# Crown Warden Image Generation Record

Date: 2026-07-12
Mode: built-in image generation with local magenta-key removal
Use case: `stylized-concept`
Story: `production/epics/player-abilities/story-146-crown-warden-playable-boss4-core.md`

## Prompt

Create one coherent Crown Warden for a polished Godot 4.7 horizontal 2D action
platformer as a strict three-column by eight-row pixel-art sprite sheet. Rows in
order: idle hover, flight/run, talon-dive attack tell, talon-dive attack,
wing-sweep attack tell, wing-sweep attack, hurt, death. Each row contains three
distinct frames of the same right-facing giant mechanical owl at one scale,
pivot, and baseline. Give it a broad royal owl silhouette, charcoal steel
plating, restrained brass crown and trim, bright cyan optics, a violet chest
coil, amber feather-edge highlights, and signal-red warning vanes only during
attack tells. Talon-dive frames must clearly compress then drive forward with
extended talons. Wing-sweep frames must clearly open one segmented metal wing
into a wide horizontal strike. Death frames must collapse the crown and coil
without dismemberment. Use crisp authored pixel art, strong ACT silhouettes,
large-pose readability, and consistent lighting. Place exactly twenty-four
isolated full-body sprites on a perfectly uniform flat `#ff00ff` chroma-key
background with equal-cell spacing. No organic bird body, cat anatomy, text,
labels, separators, UI, environment, floor, cast shadow, watermark, crop,
overlap, gradient, glow spilling into the background, or 3D rendering.

## Outputs

- Chroma source: `crown_warden_sprite_sheet_imagegen_20260712.png`
- Alpha source: `crown_warden_sprite_sheet_alpha_20260712.png`
- Transparent preview: `crown_warden_frames_preview_20260712.png`
- Runtime frames: `../<animation>/crown_warden_<animation>_000.png` through
  `_002.png`
- Runtime resource: `../crown_warden_sprite_frames.tres`

## Processing

- The generated source is `887x1774` opaque RGB. Border sampling selected
  `#f903f6` as the magenta key.
- Chroma removal used the installed image-generation helper with auto-key,
  soft matte, despill, transparent threshold `12`, and opaque threshold `220`.
- The `887x1774` RGBA alpha sheet was divided at proportional boundaries into
  a strict `3x8` grid. Twelve source pixels were excluded from the top and
  bottom of each cell to remove neighboring-row bleed while preserving every
  complete character silhouette.
- Every cell was resized as one untrimmed unit inside a `188x188` fit box, then
  centered on a transparent `192x192` canvas. This keeps one shared source
  scale, pivot convention, and baseline instead of independently scaling each
  character contour.
- The three collapsed death poses were shifted down by `17`, `17`, and `15`
  transparent pixels respectively after extraction. This deterministic canvas
  correction aligns every runtime frame's opaque ground edge at `y=158..159`
  without rescaling or repainting the generated pixels.
- The resulting twenty-four RGBA frames are grouped as `idle`, `run`,
  `talon_dive_tell`, `talon_dive`, `wing_sweep_tell`, `wing_sweep`, `hurt`,
  and `death`, three continuous frames each.
- The transparent preview was rebuilt from the corrected runtime frames.
  Validation confirmed all runtime frames are `192x192` sRGBA, non-empty,
  transparent at the top-left pixel, and share a ground anchor within two
  pixels. Godot scenes use nearest filtering.
