# Sluice Matriarch Image Generation Record

Date: 2026-07-11
Mode: built-in image generation with local magenta-key removal
Use case: `stylized-concept`
Story: `production/epics/player-abilities/story-128-sluice-matriarch-playable-boss3-core.md`

## Prompt

Create one coherent Sluice Matriarch for a polished Godot 4.7 2D action
platformer as a strict three-column by six-row pixel-art sprite sheet. Rows in
order: idle, crawl/run, pressure-lunge attack tell, pressure-lunge attack,
hurt, death. Each row contains three distinct frames of the same right-facing
giant mutated industrial leech at one scale, pivot, and ground baseline. Give
her a low heavy silhouette, charcoal-purple wet body, steel pressure clamps,
cracked ceramic armour, rust-orange hardware, restrained cyan mutation seams,
and signal-red warning spines in the attack tell. The active attack projects a
readable organic pressure lance without changing the character identity. Use
crisp authored pixel art, strong ACT silhouettes, and large-pose readability.
Place exactly eighteen isolated full-body sprites on a perfectly uniform flat
`#ff00ff` chroma-key background with equal-cell spacing. No rat anatomy, mouse
ears, text, labels, separators, UI, environment, floor, cast shadow, watermark,
crop, overlap, gradient, or 3D rendering.

## Outputs

- Chroma source: `sluice_matriarch_sprite_sheet_imagegen_20260711.png`
- Alpha source: `sluice_matriarch_sprite_sheet_alpha_20260711.png`
- Transparent preview: `sluice_matriarch_frames_preview_20260711.png`
- Runtime frames: `../<animation>/sluice_matriarch_<animation>_000.png` through
  `_002.png`
- Runtime resource: `../sluice_matriarch_sprite_frames.tres`

## Processing

- The generated source is `1254x1254` opaque RGB. Border sampling selected
  `#f703f7` as the magenta key.
- Chroma removal used the installed image-generation helper with auto-key,
  soft matte, despill, transparent threshold `12`, and opaque threshold `220`.
- The `1254x1254` RGBA alpha sheet was split into exact `418x209` cells in a
  `3x6` grid.
- Each complete cell was normalized to `188x94`, then centered on a transparent
  `192x192` canvas with one shared pivot and ground baseline. This preserves
  the long boss silhouette and leaves transparent safety padding.
- The resulting eighteen RGBA frames are grouped as `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death`, three continuous frames each.
- Godot 4.7 imported the source, alpha, preview, and runtime PNGs. Runtime
  scenes use nearest texture filtering and no mipmaps.
